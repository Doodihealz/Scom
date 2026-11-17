-- Native map scenery already declares harvest work and rewards. Give those
-- existing instances gameplay owners; never replace their visible meshes.
local M = {}
local CellSize = 16
local definitions, records, cells, retired = {}, {}, {}, {}
local generation, maximumRadius = 0, 0
local installed, hostInstalled, clientInstalled, HostScenery = false, false, false, nil
local pendingScenery, pendingProgress, waitingBuilders = {}, {}, {}
local bit = require("bit")
local floatBytes = {}

-- Keep native float precision through the sandbox-safe serializers. This byte
-- buffer is private to the Lua state; these arithmetic helpers never yield.
local function f32(value)
    floatBytes[1],floatBytes[2],floatBytes[3],floatBytes[4]=nil,nil,nil,nil
    Engine.SerializeFloat(value,floatBytes)
    return (Engine.DeserializeFloat(table.concat(floatBytes),1))
end

local function dot2(ax,az,bx,bz)
    return f32(f32(ax*bx)+f32(az*bz))
end

local function finite(value)
    return type(value)=="number" and value==value and math.abs(value)<math.huge
end

local function sameID(a,b)
    return a and b and a.index==b.index and a.version==b.version
end

local function key(id) return id.index..":"..id.version end
local function cell(x,z) return math.floor(x/CellSize)..":"..math.floor(z/CellSize) end
local function commands() return Import("common/commands/definitions/scoScenery.lua") end

local function current(prop)
    return prop and not prop.dead and not prop.deleted and __Entities.Props[prop.id.index]==prop
        and Engine.IsValidGlobalID(prop.id)
end

function M.SetPosition(id,position)
    local prop=__Entities.Props[id.index]
    if prop and prop.scoScenery and sameID(prop.id,id) then
        -- A write updates the local transform before the world matrix is published.
        -- Moved props keep reading the engine's world position.
        prop.scoSceneryPosition=false
    end
    return Engine.SetGlobalEntityPosition(id,position)
end

local function sceneryInRange(prop,center,radius)
    local status,matrix=Engine.GetGlobalEntityWorldMatrix(prop.id)
    if status~=EngineErrorCode.Success then return false end
    local size,offset=prop.tp.collider.size,prop.tp.collider.center
    local r,u,f,p=matrix.c0,matrix.c1,matrix.c2,matrix.c3
    local cx,cz=f32(center.x),f32(center.z)
    local ox,oy,oz=f32(offset.x),f32(offset.y),f32(offset.z)
    local bx=f32(f32(f32(f32(r.x*ox)+f32(u.x*oy))+f32(f.x*oz))+p.x)
    local bz=f32(f32(f32(f32(r.z*ox)+f32(u.z*oy))+f32(f.z*oz))+p.z)
    local hx,hz=f32(f32(size.x)*0.5),f32(f32(size.z)*0.5)
    local ax,az=f32(r.x*hx),f32(r.z*hx)
    local zx,zz=f32(f.x*hz),f32(f.z*hz)
    local lx,lz=f32(math.sqrt(dot2(ax,az,ax,az))),f32(math.sqrt(dot2(zx,zz,zx,zz)))
    if not finite(bx) or not finite(bz) or not finite(lx) or not finite(lz) then return false end

    -- Native CollisionChecks.BoxCircleAxes / BoxAgainstSingleCircle project
    -- each axis independently onto XZ, including tilted or collapsed trees.
    if lx>1.1754943508222875e-38 then ax,az=f32(ax/lx),f32(az/lx) else ax,az=0,0 end
    if lz>1.1754943508222875e-38 then zx,zz=f32(zx/lz),f32(zz/lz) else zx,zz=0,0 end
    local dx,dz=f32(cx-bx),f32(cz-bz)
    local px=math.max(-lx,math.min(lx,dot2(dx,dz,ax,az)))
    local pz=math.max(-lz,math.min(lz,dot2(dx,dz,zx,zz)))
    local nx=f32(f32(bx+f32(ax*px))+f32(zx*pz))
    local nz=f32(f32(bz+f32(az*px))+f32(zz*pz))
    local ex,ez=f32(cx-nx),f32(cz-nz)
    return dot2(ex,ez,ex,ez)<=f32(radius*radius)
end

function M.PrepareTemplate(tp)
    local harvestable=false
    for _,tag in ipairs(tp.tags or {}) do if tag=="HARVESTABLE" then harvestable=true end end
    local economy,collider=tp.economy,tp.collider
    if not harvestable or not economy or not collider or not collider.size or not collider.center
        or not finite(economy.harvestTime) or economy.harvestTime<=0 then return nil end
    for _,axis in ipairs({"x","y","z"}) do
        if not finite(collider.size[axis]) or collider.size[axis]<=0
            or not finite(collider.center[axis]) then return nil end
    end
    local rewards={}
    for resource,amount in pairs(economy.harvest or {}) do
        if not finite(amount) or amount<0 then error("SCOM scenery has invalid harvest reward") end
        -- Environment.santp retains the older plasma name. Native Economy owns
        -- alloys and energy; keep the authored quantities and map only that alias.
        local name=resource=="plasma" and "energy" or resource
        if name~="alloys" and name~="energy" then
            error("SCOM scenery has unknown harvest currency: "..tostring(resource))
        end
        rewards[name]=(rewards[name] or 0)+amount
    end
    if next(rewards)==nil then return nil end
    local result={}
    for name,value in pairs(tp) do result[name]=value end
    result.economy={harvestTime=economy.harvestTime,harvest=rewards}
    result.collisionInfo={collisionSize=collider.size,centerOffset=collider.center}
    result.scoScenery=true
    return result
end

local function unregister(prop)
    records[key(prop.id)]=nil
    local bucket=cells[prop.scoSceneryCell]
    if bucket then bucket[prop]=nil;if next(bucket)==nil then cells[prop.scoSceneryCell]=nil end end
end

local function hostClass()
    if HostScenery then return HostScenery end
    local HostProp=Import("host/props/propsClasses/propBaseClass.lua").HostProp
    local Reclaimable=Import("host/interfaces/work/tasks/reclaimable.lua").Reclaimable
    local ResourceEntity=Import("host/systems/resourceEntity.lua").ResourceEntity
    local Work=Import("common/commands/definitions/work.lua")
    HostScenery=Class("SCOMHarvestableScenery",HostProp,Reclaimable)
    function HostScenery:__init(id,tp)
        HostProp.__init(self,id,tp)
        Reclaimable.__init(self)
        self.scoScenery=true
        local armyId
        for index in pairs(Armies) do if not armyId or index<armyId then armyId=index end end
        assert(armyId~=nil,"SCOM scenery cannot register before army economies")
        -- Native builder updates require a registered ledger. Its cost/income
        -- stay empty; actual refunds belong to each contributing army below.
        local ledger=ResourceEntity(armyId,id,"harvest",nil,nil,true)
        ledger:SetCost({})
        ledger:SetBuildTime(tp.economy.harvestTime)
        self.resourceEntities={harvest=ledger}
    end
    function HostScenery:GetPosition()
        local position=self.scoSceneryPosition
        if position==false or self.dead or self.deleted or (Tick or 0)<=0 then
            return HostProp.GetPosition(self)
        end
        if not position then
            local status
            status,position=Engine.GetGlobalEntityWorldPosition(self.id)
            if status~=EngineErrorCode.Success then return position end
            self.scoSceneryPosition=position
        end
        -- Match the native wrapper's fresh position table on every call.
        return {x=position.x,y=position.y,z=position.z}
    end
    function HostScenery:SetPosition(position)
        M.SetPosition(self.id,position)
    end
    function HostScenery:IsReclaimProcessComplete()
        return self.reclaimProgress>=self.tp.economy.harvestTime
    end
    function HostScenery:ReclaimProcessThread()
        while self:CanContinueReclaimProcess() and Engine.IsValidGlobalID(self.id) do
            local workers,total={},0
            for _,builder in ipairs(self.reclaimers) do
                local contribution=self.resourceEntities.harvest.buildPowerSources[builder.id]
                if contribution and not builder.dead and not builder.deleted
                    and GetUnitById(builder.id)==builder and builder.unitBeingReclaimed==self
                    and not builder:GetPause() and builder.army and builder.army.economy
                    and finite(contribution.buildPower) and contribution.buildPower>0 then
                    local work=contribution.buildPower/Constants.TickRate
                    workers[#workers+1]={army=builder.army,work=work};total=total+work
                end
            end
            if total>0 then
                local duration=self.tp.economy.harvestTime
                local step=math.min(total,math.max(0,duration-self.reclaimProgress))
                self.reclaimProgress=self.reclaimProgress+step
                for _,worker in ipairs(workers) do
                    for resource,amount in pairs(self.tp.economy.harvest) do
                        worker.army.economy:GiveResources(resource,amount*step/duration*worker.work/total)
                    end
                end
                commands().SCOSceneryProgress.Send(self.id,self.reclaimProgress)
                if self:IsReclaimProcessComplete() then self:EndReclaimProcess();return end
            end
            WaitTicks(1)
        end
        self:EndReclaimProcess()
    end
    function HostScenery:OnReclaimProcessEnded()
        if self:IsReclaimProcessComplete() then
            Work.OnUnitReclaimed.Send(self.id)
            self:Delete()
        end
    end
    function HostScenery:OnDestroy()
        if self:IsReclaimProcessEnabled() then self:EndReclaimProcess() end
        self.resourceEntities.harvest:SetEnabled(false)
    end
    function HostScenery:Delete()
        if self.deleted then return end
        if not self.dead then self:Destroy();return end
        unregister(self)
        commands().SCOSceneryRemoved.Send(self.id)
        return HostProp.Delete(self)
    end
    return HostScenery
end

local function registerHost(id,tp,position,scale)
    if not tp or not Engine.IsValidGlobalID(id) then return end
    local prior=__Entities.Props[id.index]
    if prior then
        assert(sameID(prior.id,id) and prior.scoScenery,"SCOM scenery entity ownership collision")
        return prior
    end
    local prop=hostClass()(id,tp)
    __Entities.Props[id.index]=prop
    records[key(id)]=prop
    prop.scoSceneryCell=cell(position.x,position.z)
    local bucket=cells[prop.scoSceneryCell] or {};cells[prop.scoSceneryCell]=bucket;bucket[prop]=true
    local c,s=tp.collider.center,tp.collider.size
    local radius=0
    for _,axis in ipairs({"x","y","z"}) do
        radius=radius+((math.abs(c[axis])+s[axis]/2)*math.abs(scale[axis]))^2
    end
    -- Also encloses the existing tree fall owner's root-pivot translation.
    maximumRadius=math.max(maximumRadius,2*math.sqrt(radius))
    return prop
end

local function reset()
    generation=generation+1
    for _,prop in pairs(records) do
        prop.dead=true
        prop:OnDestroy()
        if prop.garbage then prop.garbage:Delete();prop.garbage=nil end
        prop.deleted=true
        if __Entities.Props[prop.id.index]==prop then __Entities.Props[prop.id.index]=nil end
    end
    records,cells,retired={},{},{};maximumRadius=0
    pendingScenery,pendingProgress,waitingBuilders={},{},{}
end

local function cancelWaiting(id)
    for builder,request in pairs(waitingBuilders) do
        if sameID(request.id,id) then
            waitingBuilders[builder]=nil
            if sameID(builder.scoSceneryPendingReclaimID,id) then
                builder.scoSceneryPendingReclaimID=nil
                if not builder.dead and not builder.deleted and __Entities.Units[builder.id.index]==builder then
                    request.stop(builder)
                end
            end
        end
    end
end


function M.ReceiveCreated(entries)
    if not IsClient then return end
    local pending={}
    for _,entry in ipairs(entries) do
        pending[#pending+1]=entry
        pendingScenery[key(entry.id)]=true
        pendingProgress[key(entry.id)]=math.max(pendingProgress[key(entry.id)] or 0,entry.progress or 0)
    end
    local epoch=generation
    NewThread(function()
        for attempt=1,300 do
            if epoch~=generation then return end
            for index=#pending,1,-1 do
                local entry=pending[index]
                local tp=definitions[entry.tpId]
                local status,localId=Engine.GetGlobalEntityPairedLocalID(entry.id)
                if retired[key(entry.id)] then
                    table.remove(pending,index)
                elseif tp and status==EngineErrorCode.Success and Engine.IsValidLocalID(localId) then
                    local old=__Entities.Props[entry.id.index]
                    if not old or not sameID(old.id,entry.id) then
                        local Prop=Import("client/props/propsClasses/propsBaseClass.lua").ClientProp
                        local prop=Prop(entry.id,localId)
                        prop:ApplyTemplate(tp)
                        prop.scoScenery=true
                        prop.reclaimProgress=pendingProgress[key(entry.id)] or entry.progress or 0
                        __Entities.Props[entry.id.index]=prop
                    end
                    pendingScenery[key(entry.id)]=nil
                    pendingProgress[key(entry.id)]=nil
                    for builder,request in pairs(waitingBuilders) do
                        if sameID(request.id,entry.id) then
                            waitingBuilders[builder]=nil
                            if not builder.dead and not builder.deleted and __Entities.Units[builder.id.index]==builder
                                and sameID(builder.scoSceneryPendingReclaimID,entry.id) then
                                builder.scoSceneryPendingReclaimID=nil
                                request.start(builder,entry.id)
                            end
                        end
                    end
                    table.remove(pending,index)
                end
            end
            if #pending==0 then return end
            WaitTicks(1)
        end
        for _,entry in ipairs(pending) do
            pendingScenery[key(entry.id)]=nil
            pendingProgress[key(entry.id)]=nil
            cancelWaiting(entry.id)
        end
        Warn("SCOM scenery client registration timed out: "..#pending.." props")
    end)
end

function M.ReceiveProgress(id,progress)
    if not finite(progress) or progress<0 or retired[key(id)] then return end
    local prop=__Entities.Props[id.index]
    if prop and prop.scoScenery and sameID(prop.id,id) then
        prop.reclaimProgress=math.max(prop.reclaimProgress or 0,progress)
    else
        pendingProgress[key(id)]=math.max(pendingProgress[key(id)] or 0,progress)
    end
end


function M.ReceiveRemoved(id)
    retired[key(id)]=true
    pendingScenery[key(id)]=nil
    pendingProgress[key(id)]=nil
    cancelWaiting(id)
    local prop=__Entities.Props[id.index]
    if prop and prop.scoScenery and sameID(prop.id,id) then
        prop:OnDestroy();prop:Delete();__Entities.Props[id.index]=nil
    end
end

function M.Delete(id)
    local prop=__Entities.Props[id.index]
    if not prop or not prop.scoScenery or not sameID(prop.id,id) then return false end
    prop:Delete()
    return true
end

function M.FindBlocker(target)
    local skirt=target.tp.skirtSize
    if not skirt then return nil end
    local p=target:GetPosition()
    local halfX,halfZ=skirt.x/2,skirt.y/2
    local minX,maxX=p.x-halfX,p.x+halfX
    local minZ,maxZ=p.z-halfZ,p.z+halfZ
    local best,distance
    for x=math.floor((minX-maximumRadius)/CellSize),math.floor((maxX+maximumRadius)/CellSize) do
        for z=math.floor((minZ-maximumRadius)/CellSize),math.floor((maxZ+maximumRadius)/CellSize) do
            for prop in pairs(cells[x..":"..z] or {}) do
                if current(prop) then
                    local status,matrix=Engine.GetGlobalEntityWorldMatrix(prop.id)
                    if status~=EngineErrorCode.Success then return prop end
                    local center,size=prop.tp.collider.center,prop.tp.collider.size
                    local loX,hiX,loZ,hiZ=math.huge,-math.huge,math.huge,-math.huge
                    for _,sx in ipairs({-1,1}) do for _,sy in ipairs({-1,1}) do for _,sz in ipairs({-1,1}) do
                        local a,b,c=center.x+sx*size.x/2,center.y+sy*size.y/2,center.z+sz*size.z/2
                        local wx=matrix.c3.x+matrix.c0.x*a+matrix.c1.x*b+matrix.c2.x*c
                        local wz=matrix.c3.z+matrix.c0.z*a+matrix.c1.z*b+matrix.c2.z*c
                        loX,hiX,loZ,hiZ=math.min(loX,wx),math.max(hiX,wx),math.min(loZ,wz),math.max(hiZ,wz)
                    end end end
                    if loX<maxX and hiX>minX and loZ<maxZ and hiZ>minZ then
                        local d=(matrix.c3.x-p.x)^2+(matrix.c3.z-p.z)^2
                        if not best or d<distance or (d==distance and prop.id.index<best.id.index) then best,distance=prop,d end
                    end
                else
                    M.Delete(prop.id)
                end
            end
        end
    end
    return best
end

function M.InstallClient(ClientUnit)
    if clientInstalled then return end
    clientInstalled=true
    local start,stop=ClientUnit.ClientOnStartReclaim,ClientUnit.ClientOnStopReclaim
    function ClientUnit:ClientOnStartReclaim(id,...)
        self.scoSceneryPendingReclaimID=nil
        waitingBuilders[self]=nil
        if pendingScenery[key(id)] and not retired[key(id)] then
            self.scoSceneryPendingReclaimID={index=id.index,version=id.version}
            self.isReclaiming=true
            waitingBuilders[self]={id=self.scoSceneryPendingReclaimID,start=start,stop=stop}
            return
        end
        return start(self,id,...)
    end
    function ClientUnit:ClientOnStopReclaim(...)
        self.scoSceneryPendingReclaimID=nil
        waitingBuilders[self]=nil
        return stop(self,...)
    end
end

function M.InstallHost(HostUnit)
    if hostInstalled then return end
    hostInstalled=true
    local Detector=Import("host/managers/colliders/constructionDetector.lua").ConstructionDetector
    local overlap=Detector.IsOverlappingUnit
    function Detector:IsOverlappingUnit(target)
        if not target or not target.scoScenery then return overlap(self,target) end
        if not current(target) or not Engine.IsValidGlobalID(self.id) then return false end
        local status,enabled=Engine.GetVolumeColliderEnabled(self.id)
        if status~=EngineErrorCode.Success or not enabled then return false end
        local colliderType
        status,colliderType=Engine.GetVolumeColliderType(self.id)
        if status~=EngineErrorCode.Success then return false end
        assert(colliderType==ColliderType.Circle,"SCOM scenery requires a native Circle construction detector")
        local mask
        status,mask=Engine.GetVolumeColliderCollisionMask(self.id)
        if status~=EngineErrorCode.Success
            or bit.band(mask,Import("common/layers.lua").CollisionLayer.Units)==0 then return false end
        local size,offset,matrix
        status,size=Engine.GetVolumeColliderSize(self.id)
        if status~=EngineErrorCode.Success then return false end
        status,offset=Engine.GetVolumeColliderOffset(self.id)
        if status~=EngineErrorCode.Success then return false end
        status,matrix=Engine.GetGlobalEntityWorldMatrix(self.id)
        if status~=EngineErrorCode.Success then return false end
        local r,f=matrix.c0,matrix.c2
        -- Match native Box/Circle overlap: transform the offset and scale by
        -- the larger full-length Right/Forward column, including terrain tilt.
        local radius=size.x*math.sqrt(math.max(r.x*r.x+r.y*r.y+r.z*r.z,f.x*f.x+f.y*f.y+f.z*f.z))
        local center=EngineClasses.float3(
            matrix.c3.x+r.x*offset.x+matrix.c1.x*offset.y+f.x*offset.z,
            matrix.c3.y+r.y*offset.x+matrix.c1.y*offset.y+f.y*offset.z,
            matrix.c3.z+r.z*offset.x+matrix.c1.z*offset.y+f.z*offset.z)
        if not finite(radius) or radius<1e-5 or not finite(center.x)
            or not finite(center.y) or not finite(center.z) then return false end
        -- Query only the requested prop. Registering a simulated collider on
        -- every map prop makes native collision jobs revisit all of them each tick.
        return sceneryInRange(target,center,f32(radius))
    end
    local build,stop=HostUnit.BuildBehaviorThread,HostUnit.BuildBehaviorStop
    function HostUnit:BuildBehaviorThread(...)
        local target=self.buildBehaviorActualUnit
        while self.buildBehaviorIsActive and self:BuildBehaviorIsValidFor(target) do
            local prop=M.FindBlocker(target)
            if not prop then return build(self,...) end
            if not self:IsCompleted() then WaitTicks(1)
            elseif not self:ReclaimBehaviorIsValidFor(prop) then self:BuildBehaviorStop();return
            else
                self.scoSceneryBuildReclaim=prop
                self:ReclaimBehaviorStart(prop)
                while self.buildBehaviorIsActive and self:BuildBehaviorIsValidFor(target)
                    and current(prop) and self.reclaimBehaviorIsActive do WaitTicks(1) end
                if self.reclaimBehaviorTarget==prop then self:ReclaimBehaviorStop() end
                self.scoSceneryBuildReclaim=nil
                if current(prop) then self:BuildBehaviorStop();return end
            end
        end
        self:BuildBehaviorStop()
    end
    function HostUnit:BuildBehaviorStop(...)
        local prop=self.scoSceneryBuildReclaim
        self.scoSceneryBuildReclaim=nil
        if prop and self.reclaimBehaviorTarget==prop then self:ReclaimBehaviorStop() end
        return stop(self,...)
    end
end

function M.Install()
    if installed then return end
    installed=true
    local loader=Import("common/loading/propTemplateLoader.lua")
    local create=loader.CreatePropPrefab
    loader.CreatePropPrefab=function(tp)
        local prepared=M.PrepareTemplate(tp)
        if not prepared then return create(tp) end
        local status,prefab=create(prepared)
        if status==EngineErrorCode.Success then
            definitions[prefab.Value]=prepared;definitions[prepared.general.tpId]=prepared
        end
        return status,prefab
    end
    local map=Import("common/mapUtils.lua")
    local setup=map.RunMapSetup
    map.RunMapSetup=function(instantiate,...)
        reset()
        if not IsHost or not instantiate then return setup(instantiate,...) end
        local spawn=Engine.InstantiatePrefab
        local entries={}
        Engine.InstantiatePrefab=function(prefab,position,scale,rotation,...)
            local status,id=spawn(prefab,position,scale,rotation,...)
            local tp=definitions[prefab.Value]
            if status==EngineErrorCode.Success and tp then
                local prop=registerHost(id,tp,position,scale)
                if prop then entries[#entries+1]={id=prop.id,tpId=prop.tpId,progress=prop.reclaimProgress} end
            end
            return status,id
        end
        local result={pcall(setup,instantiate,...)}
        Engine.InstantiatePrefab=spawn
        if not result[1] then reset();error(result[2],0) end
        for first=1,#entries,64 do
            local batch={}
            for index=first,math.min(first+63,#entries) do batch[#batch+1]=entries[index] end
            commands().SCOSceneryCreated.Send(batch)
        end
        return unpack(result,2)
    end
end

local environment=getfenv(1)
for name,value in pairs(M) do environment[name]=value end
return M
