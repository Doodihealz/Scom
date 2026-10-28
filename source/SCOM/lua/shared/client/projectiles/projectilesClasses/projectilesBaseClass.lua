-- SCOM source torpedo splash waterline placement 1.0.0
-- These imported graphs contain FA SnapToWaterline splash emitters. Keep
-- their visible origin at the water surface, independent of hull height.
local SCO_WaterSplashGraphs = {
    ['VFX/SCOM/Source/psf0012/impact_land.sanvfx'] = true,
    ['VFX/SCOM/Source/psf0027/impact_unit.sanvfx'] = true,
    ['VFX/SCOM/Source/psf0042/impact_unit.sanvfx'] = true,
    ['VFX/SCOM/Source/psf0084/impact_land.sanvfx'] = true,
}
local function SCO_WaterSplashPose(path, position, orientation)
    if not SCO_WaterSplashGraphs[path] then return position, orientation end
    local status, hasWater = Engine.HasWater()
    if status ~= EngineErrorCode.Success or not hasWater then return position, orientation end
    local waterStatus, water = Engine.GetWaterLevel()
    local terrainStatus, terrain = Engine.SampleTerrainHeight(position)
    if waterStatus ~= EngineErrorCode.Success or terrainStatus ~= EngineErrorCode.Success
        or terrain >= water then return position, orientation end
    return EngineClasses.float3(position.x, water, position.z),
        EngineClasses.quaternion(EngineClasses.float4(0, 0, 0, 1))
end

-- Tiny projectile impacts use a 22-particle derivative of the native small
-- splash with baked spatial scale. Only a hit on the native water prefab selects it.
local SCO_ProjectileSplashPath = 'VFX/SCOM/Naval/projectile_water_splash_tiny.sanvfx'
local SCO_ProjectileSplashPrefab
local SCO_ProjectileSplashActive = 0
local SCO_ProjectileSplashGeneration = 0
local SCO_ProjectileSplashClock
local function SCO_ProjectileSplashSyncClock()
    local now = Engine.GetSimulationTime()
    if SCO_ProjectileSplashClock and now < SCO_ProjectileSplashClock then
        -- Never delete an old match's handle in a new match with recycled IDs.
        SCO_ProjectileSplashGeneration = SCO_ProjectileSplashGeneration + 1
        SCO_ProjectileSplashActive = 0
        SCO_ProjectileSplashPrefab = nil
    end
    SCO_ProjectileSplashClock = now
end
local function SCO_PlayProjectileWaterSplash(position, hitGlobalId)
    -- Current native impact events identify water through the hit prefab.
    if not _G.WaterGlobalPrefabID or not Engine.IsValidGlobalID(hitGlobalId) then return false end
    local hitStatus, hitPrefabID = Engine.GetGlobalEntityPrefabID(hitGlobalId)
    if hitStatus ~= EngineErrorCode.Success or hitPrefabID.Value ~= _G.WaterGlobalPrefabID.Value then return false end
    local status, hasWater = Engine.HasWater()
    if status ~= EngineErrorCode.Success or not hasWater then return false end
    local waterStatus, water = Engine.GetWaterLevel()
    local terrainStatus, terrain = Engine.SampleTerrainHeight(position)
    if waterStatus ~= EngineErrorCode.Success or terrainStatus ~= EngineErrorCode.Success
        or terrain >= water then return false end
    SCO_ProjectileSplashSyncClock()
    -- Suppress the ordinary explosion even when the visual budget is full;
    -- native impact audio still executes after this branch.
    if SCO_ProjectileSplashActive >= 12 then return true end
    if not SCO_ProjectileSplashPrefab then
        if not Engine.LoadEffect(SCO_ProjectileSplashPath) then return false end
        SCO_ProjectileSplashPrefab = Import('common/loading/vfxTemplateLoader.lua')
            .GetOrCreateVFXPrefab(SCO_ProjectileSplashPath)
        if not SCO_ProjectileSplashPrefab then return false end
    end
    local result, id = Engine.InstantiatePrefab(SCO_ProjectileSplashPrefab,
        EngineClasses.float3(position.x, water, position.z),
        EngineClasses.float3(1, 1, 1), GetIdentityQuaternion())
    if result ~= EngineErrorCode.Success or not id or not Engine.IsValidLocalID(id) then return false end
    SCO_ProjectileSplashActive = SCO_ProjectileSplashActive + 1
    local generation = SCO_ProjectileSplashGeneration
    -- The finite, non-looping graph uses native destroyUponCompletion.
    -- This timer releases only our visual-budget slot. LocalID validity can
    -- outlive the native ECS entity, so it must never delete the effect again.
    NewThread(function()
        WaitSeconds(3.5)
        SCO_ProjectileSplashSyncClock()
        if generation ~= SCO_ProjectileSplashGeneration then return end
        SCO_ProjectileSplashActive = SCO_ProjectileSplashActive - 1
    end)
    return true
end

local ClientEntity = Import("client/entities/entity.lua").ClientEntity
local Icon = Import("client/entities/icon.lua").StrategicIcon
local AudioManager = Import("client/audio/audioManager.lua")
local IntelBitMask = Import("common/intelBitMask.lua").IntelBitMask
local Shields = __Entities.Shields

--- Do not wait for any impact time below this very small number. Its pointless!
local SmallestImpactTime = Constants.TickTimeStep / 10

---@class ClientProjectile: ClientEntity
---@field tp table Template
---@field name string Projectile's name
---@field tpId TemplateId Projectile's template ID
---@field armyId ArmyId Template
---@field impactSizeIndex integer Size of the projectile, 1 (small) to 4 (huge).
ClientProjectile = Class("ClientProjectile", ClientEntity)

---@param tpId TemplateId
---@return integer sizeIndex 1 (small) to 4 (huge).
local function GetImpactSizeIndex(tpId)
    local techDigit = string.sub(tpId, 1, 3) == "pxd" and string.sub(tpId, 6, 6) or string.sub(tpId, 4, 4)
    return math.clamp(tonumber(techDigit), 1, 4)
end

---Inicializes new instance of a projectile
---@param globalId globalId Global ID
---@param localId localId Local ID
---@param armyId ArmyId Army index
---@param template any Template
function ClientProjectile:__init(globalId, localId, armyId, template)
    ClientEntity.__init(self, globalId, localId)

    self.tp = template
    self.name = self.tp.general.name
    self.tpId = self.tp.general.tpId
    self.armyId = armyId
    self.impactSizeIndex = GetImpactSizeIndex(self.tpId)

    self:SetUpIcon()
    self:SetUpPersistentEffects()

    self.isIntelVisionVisible = false
    self.visibilityMask = IntelBitMask.FromArmyId(self.armyId)
    self:RecalculateIntel(true)
end

-- Sets the emit state of all persistent particles on the projectile.
function ClientProjectile:SetPersistentEffectsState(enabled)
    
    for _, localId in ipairs(self.persistentEffects) do
        Engine.SetParticleCanEmit(localId, enabled)
    end
end

---Destroys the projectile, used for displaying impact effects before the projectile is deleted
---@param impactTime number
---@param orientation quaternion
---@param hitGlobalId GlobalID The entity that was hit, invalid when the projectile hit the terrain.
function ClientProjectile:Destroy(impactTime, orientation, hitGlobalId)

    -- If we are close enough to the impact time, we do not wait, just destroy!
    if impactTime > SmallestImpactTime then
        --TODO: We call projectile:Delete() after this which cleans up any threads apart of this entity.
        -- So we cannot have the projectile own the destroy thread. If we wanted this, we would have to change how the projectiles delete.
        NewThread(self.DestroyThread, self, impactTime, orientation, hitGlobalId);
    else
        self:OnDestroy(impactTime, orientation, hitGlobalId)
    end
end

function ClientProjectile:DestroyThread(impactTime, orientation, hitGlobalId)
    WaitSeconds(impactTime)
    self:OnDestroy(impactTime, orientation, hitGlobalId)
end

function ClientProjectile:OnDestroy(impactTime, orientation, hitGlobalId)
    self:CreateImpactEffects(self:GetPosition(), orientation, hitGlobalId)
    self:SetPersistentEffectsState(false)
    self.icon:SetEnabled(false)
end

function ClientProjectile:Delete()
    ClientEntity.Delete(self)
    self:OnDelete()
end

function ClientProjectile:OnDelete()
end

---Returns if the projectile is visible to the player on vision.
---@return boolean isIntelVisionVisible If the projectile is visible to the player.
function ClientProjectile:IsIntelVisionVisible()
    return self.isIntelVisionVisible
end

---@public Update the projectile's intel visibility mask. Will call OnIntelHidden or OnIntelVision if the intel state changed to the player.
---@param visionDetectionMask IntelBitMask
function ClientProjectile:UpdateIntelVisionDetection(visionDetectionMask)
    self.visibilityMask = visionDetectionMask
    self:RecalculateIntel()
end

---@protected Called whenever the projectile has no source of intel and should be "hidden" to the player.
function ClientProjectile:OnIntelHidden()
    Engine.SetRendererEnabled(self.localId, false)
    self:SetPersistentEffectsState(false)
    self.icon:SetEnabled(false)
end

---@protected Called whenever the source of intel becomes vision.
function ClientProjectile:OnIntelVision()
    Engine.SetRendererEnabled(self.localId, true)
    self:SetPersistentEffectsState(true)
    self.icon:SetEnabled(true)
end

---@protected Recalculate if the projectile is visible to the player. Will call OnIntelHidden or OnIntelVision if the visibility changed.
---@param forceEvent? boolean Force the OnIntelHidden or OnIntelVision event even if there was no change to the intel state.
function ClientProjectile:RecalculateIntel(forceEvent)

    local focusArmyID = GetFocusArmy()

    if focusArmyID == nil then
        return
    end

    local wasIntelVisionVisible = self.isIntelVisionVisible

    -- If focusArmyID == -1 then we are allowed to see all armies.
    if focusArmyID == -1 then
        self.isIntelVisionVisible = true
    else
        self.isIntelVisionVisible = self.visibilityMask:IsVisible(Armies[focusArmyID].intelMask)
    end

    if self.isIntelVisionVisible then
        if forceEvent or wasIntelVisionVisible == false then
            self:OnIntelVision()
        end
    elseif forceEvent or wasIntelVisionVisible ~= false then
        self:OnIntelHidden()
    end
end

---Creates projectile's impact effects if any are defined
---@param position float3 Impact position
---@param orientation quaternion Impact orientation, applied to the spawned particle prefab.
---@param hitGlobalId GlobalID The entity that was hit, invalid when the projectile hit the terrain.
function ClientProjectile:CreateImpactEffects(position, orientation, hitGlobalId)
    if not self:IsIntelVisionVisible() then
        return
    end

    local shield = Shields[hitGlobalId.index]

    if shield then
        shield:PlayImpactEffect(position, self.impactSizeIndex)
    elseif SCO_PlayProjectileWaterSplash(position, hitGlobalId) then
        -- Water visuals are handled; keep the native audio path below.
    else
        local visuals = self.tp.visuals
        local data = visuals and visuals.onImpactEffects

        if visuals and visuals.onWaterImpactEffects and _G.WaterGlobalPrefabID
            and Engine.IsValidGlobalID(hitGlobalId) then

            local errorCode, hitPrefabID = Engine.GetGlobalEntityPrefabID(hitGlobalId)

            if errorCode == EngineErrorCode.Success and hitPrefabID.Value == _G.WaterGlobalPrefabID.Value then
                data = visuals.onWaterImpactEffects
            end
        end

        if data then
            local effectData = table.random(data)
            local effects = table.random(effectData.effects)
            local particlePrefabID = effects.particlePrefabID
            if particlePrefabID then
                local instantiatedID = {}
                local effectPosition, effectOrientation = SCO_WaterSplashPose(effects.particleName, position, orientation)
                Engine.InstantiatePrefab(particlePrefabID, effectPosition, { x = 1.0, y = 1.0, z = 1.0 }, effectOrientation, instantiatedID)
            end
        end
    end

    AudioManager.NotifyCombatActivity()

    if not (shield and shield:PlayImpactAudio(position, orientation)) then
        local impactAudio = self.tp.audio and self.tp.audio.onImpact

        if impactAudio and impactAudio.prefabID then
            AudioManager.PlayOneShot(impactAudio.prefabID, position, orientation)
        end
    end
end

---Creates the projectile's strategic icon, using value saved in `tp` else `projectile` by default
function ClientProjectile:SetUpIcon()
    self.icon = Icon(self.localId, 0, self.tp.general.icon or "projectile")
end

function ClientProjectile:SetUpPersistentEffects()

    self.persistentEffects = {}

    if self.tp.visuals and self.tp.visuals.persistantEffects then
        for _, effectGroup in ipairs(self.tp.visuals.persistantEffects) do
            for i, effect in ipairs(effectGroup.effects) do
                
                local boneId = self:GetBoneId(effect.boneName or TemplateHeadEntityName)
                if Engine.IsValidLocalID(boneId) then
                    table.insert(self.persistentEffects, boneId)
                else
                    -- We have too many of these, so I've commented it out to avoid spamming the console
                    Warn(string.format("ClientProjectile:SetUpPersistentEffects: tpId: %s, Effect num: %d has no bone.", self.tpId, i))
                end
            end
        end
    end
end
-- Appended to ClientProjectile. Host phase events only toggle named source
-- particle children; the native projectile owns their transforms and lifetime.
do
    if not _G.SCO_SourceNukeClientInstalled then
        local allowed={psf0020=true,psf0040=true,psf0136=true,psf0180=true,psf0181=true,psf0182=true}
        local pending={}
        local function refresh(projectile,enabled)
            local state=projectile.scoSourceNukeFx
            if not state then return end
            for phase,id in ipairs(state.bones) do
                Engine.SetParticleCanEmit(id,enabled and not state.destroyed and phase<=state.phase)
            end
        end
        local function apply(projectile,phase)
            local state=projectile.scoSourceNukeFx
            if not state or phase<=state.phase or state.destroyed then return end
            state.phase=phase
            refresh(projectile,projectile:IsIntelVisionVisible())
        end
        function _G.SCO_SetSourceNukePhase(value)
            if type(value)~='table' or type(value.projectileId)~='table' or not allowed[value.tpId]
                or type(value.phase)~='number' or value.phase~=math.floor(value.phase) or value.phase<1 or value.phase>3 then return end
            local id=value.projectileId
            for _,key in ipairs({'index','version'}) do
                local n=id[key]
                if type(n)~='number' or n~=math.floor(n) or n<(key=='index' and 1 or 0) or n>2147483647 then return end
            end
            local now=_G.Time or 0
            for index,record in pairs(pending) do if now>record.receivedAt+610 then pending[index]=nil end end
            local projectile=__Entities.Projectiles[id.index]
            if projectile then
                if projectile.id.version==id.version then
                    if projectile.tpId==value.tpId then apply(projectile,value.phase) end
                    return
                end
                if projectile.id.version>id.version then return end
            end
            local previous=pending[id.index]
            if previous and (previous.projectileId.version>id.version or previous.projectileId.version==id.version and previous.phase>=value.phase) then return end
            pending[id.index]={projectileId={index=id.index,version=id.version},tpId=value.tpId,phase=value.phase,receivedAt=now}
        end
        local oldInit,oldEffects,oldDestroy,oldDelete=ClientProjectile.__init,ClientProjectile.SetPersistentEffectsState,ClientProjectile.Destroy,ClientProjectile.Delete
        function ClientProjectile:__init(...)
            local result=oldInit(self,...)
            if self.tpId=='psf0136' then
                -- Static RTS/Unit meshes use the same army-color instance buffer
                -- as ClientUnit; the material's serialized color is not the owner.
                Engine.SetRendererInstanceData0(self.localId,Armies[self.armyId]:GetColor())
            end
            local phases=self.tp.visuals and self.tp.visuals.scoNukePhases
            if phases then
                assert(allowed[self.tpId],'Unscoped source nuclear visuals')
                self.scoSourceNukeFx={phase=0,bones={}}
                for _,effect in ipairs(phases) do
                    local id=self:GetBoneId(effect.boneName)
                    assert(Engine.IsValidLocalID(id),'Source nuclear phase child missing')
                    self.scoSourceNukeFx.bones[#self.scoSourceNukeFx.bones+1]=id
                end
                local value=pending[self.id.index]
                if value and value.projectileId.version<=self.id.version then pending[self.id.index]=nil end
                if value and value.projectileId.version==self.id.version and value.tpId==self.tpId then apply(self,value.phase)
                else apply(self,1) end
            end
            return result
        end
        function ClientProjectile:SetPersistentEffectsState(enabled)
            local result=oldEffects(self,enabled)
            refresh(self,enabled)
            return result
        end
        function ClientProjectile:Destroy(...)
            if self.scoSourceNukeFx then self.scoSourceNukeFx.destroyed=true;refresh(self,false) end
            return oldDestroy(self,...)
        end
        function ClientProjectile:Delete(...)
            local value=pending[self.id.index]
            if value and value.projectileId.version<=self.id.version then pending[self.id.index]=nil end
            if self.scoSourceNukeFx then self.scoSourceNukeFx.destroyed=true;refresh(self,false) end
            return oldDelete(self,...)
        end
        _G.SCO_SourceNukeClientInstalled=true
    end
end
-- Yolona's delayed source effect controller outlives the destroyed projectile.
-- Its one scoped prefab disables native destroyUponCompletion; this independent
-- thread owns the bounded lifetime instead. Ordinary impacts stay native.
do
    if not _G.SCO_YolonaImpactClientInstalled then
        local oldImpact = ClientProjectile.CreateImpactEffects
        local function dispose(id)
            if id and Engine.IsValidLocalID(id) then
                Engine.SetParticleCanEmit(id, false)
                Engine.DeletePrefabInstance(id)
            end
        end
        function ClientProjectile:CreateImpactEffects(position, orientation, hitGlobalId, impactSurface)
            if self.tpId ~= 'psf0136' or Shields[hitGlobalId.index] then
                return oldImpact(self, position, orientation, hitGlobalId, impactSurface)
            end
            if not self:IsIntelVisionVisible() then return end
            local visuals = assert(self.tp.visuals, 'Yolona impact visuals missing')
            local lifetime = visuals.scoYolonaImpactLifetime
            assert(type(lifetime) == 'number' and lifetime == math.floor(lifetime)
                and lifetime >= 5 and lifetime <= 45, 'Yolona impact lifetime changed')
            local groups = assert(visuals.onImpactEffects, 'Yolona impact binding missing')
            local effect = groups[1] and groups[1].effects and groups[1].effects[1]
            assert(#groups == 1 and #groups[1].effects == 1 and effect
                and effect.particleName == 'VFX/SCOM/Source/psf0136/impact.sanvfx'
                and effect.particlePrefabID, 'Yolona impact prefab not registered')
            local status, id = Engine.InstantiatePrefab(effect.particlePrefabID, position,
                { x = 1, y = 1, z = 1 }, orientation)
            if status == EngineErrorCode.Success and id and Engine.IsValidLocalID(id) then
                NewThread(function()
                    WaitSeconds(lifetime)
                    dispose(id)
                end)
            else
                dispose(id)
            end
            -- These are the native non-shield impact audio semantics.
            AudioManager.NotifyCombatActivity()
            local impactAudio = self.tp.audio and self.tp.audio.onImpact
            if impactAudio and impactAudio.prefabID then
                AudioManager.PlayOneShot(impactAudio.prefabID, position, orientation)
            end
        end
        _G.SCO_YolonaImpactClientInstalled = true
    end
end
