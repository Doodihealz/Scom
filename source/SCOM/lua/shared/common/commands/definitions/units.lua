-- Host-to-client unit lifecycle and per-unit state.

local Registry = Import("common/commands/registry.lua")
local Layouts  = Import("common/commands/layouts.lua")

local UnitsUpdate = nil
if IsClient then
    UnitsUpdate = Import("client/units/unitsUpdate.lua")
end

local Units = __Entities.Units

--== Lifecycle =================================================================

---@class CreateUnit : Command
CreateUnit = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "unitID",   type = Layouts.GlobalID },
    { key = "progress", type = "float" },
    { key = "armyID",   type = "int" },
})

---@param unitID GlobalID
---@param progress number Build progress the unit starts at.
---@param armyID ArmyId
function CreateUnit.Send(unitID, progress, armyID)
    return { unitID = unitID, progress = progress, armyID = armyID }
end

function CreateUnit.Receive(data)
    local _, localID = Engine.GetGlobalEntityPairedLocalID(data.unitID)
    local _, prefabID = Engine.GetGlobalEntityPrefabID(data.unitID)

    UnitsUpdate.RegisterUnit(data.unitID, localID, data.armyID, prefabID, data.progress)
end

---@class DestroyUnit : Command
DestroyUnit = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "unitID",      type = Layouts.GlobalID },
    { key = "destroyType", type = "int" },
    { key = "deferScorch", type = "bool" },
})

---@param unitID GlobalID
---@param destroyType integer
function DestroyUnit.Send(unitID, destroyType)
    local unit = GetUnitById(unitID)
    local deferScorch = unit ~= nil and unit.isAirborne == true
        and unit.tp and unit.tp.movement ~= nil
        and unit:HasTags(Tags.AIR) and not unit:HasTags(Tags.NAVAL)
        and not unit:HasTags(Tags.ORBITAL)
    return { unitID = unitID, destroyType = destroyType, deferScorch = deferScorch == true }
end

function DestroyUnit.Receive(data)
    local unit = GetUnitById(data.unitID)
    if unit then unit.scoDeferDeathScorch = data.deferScorch end
    UnitsUpdate.DestroyUnit(data.unitID, data.destroyType)
end

---@class DeleteUnit : Command
DeleteUnit = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, Layouts.UnitEvent)

---@param unitID GlobalID
function DeleteUnit.Send(unitID)
    return { unitID = unitID }
end

function DeleteUnit.Receive(data)
    UnitsUpdate.DeleteUnit(data.unitID)
end

---@class OnUnitDissolve : Command
OnUnitDissolve = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "unitID",    type = Layouts.GlobalID },
    { key = "direction", type = Layouts.Float3 },
})

---@param unitID GlobalID
---@param direction float3 The direction the unit dissolves along.
function OnUnitDissolve.Send(unitID, direction)
    return { unitID = unitID, direction = direction }
end

function OnUnitDissolve.Receive(data)
    GetUnitById(data.unitID):OnDissolve(data.direction)
end

--== Per-unit state ============================================================

---@class SetUnitProgress : Command
SetUnitProgress = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "unitID",   type = Layouts.GlobalID },
    { key = "progress", type = "float" },
})

---@param unitID GlobalID
---@param progress number
function SetUnitProgress.Send(unitID, progress)
    return { unitID = unitID, progress = progress }
end

function SetUnitProgress.Receive(data)
    GetUnitById(data.unitID):SetBuildProgress(data.progress)
end

---@class SetBuildPower : Command
SetBuildPower = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "unitID",     type = Layouts.GlobalID },
    { key = "buildPower", type = "float" },
})

---@param unitID GlobalID
---@param buildPower number
function SetBuildPower.Send(unitID, buildPower)
    return { unitID = unitID, buildPower = buildPower }
end

function SetBuildPower.Receive(data)
    Units[data.unitID.index]:SetBuildPower(data.buildPower)
end

---@class SetVisionActive : Command
SetVisionActive = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "unitID",  type = Layouts.GlobalID },
    { key = "enabled", type = "bool" },
})

---@param unitID GlobalID
---@param enabled boolean
function SetVisionActive.Send(unitID, enabled)
    return { unitID = unitID, enabled = enabled }
end

function SetVisionActive.Receive(data)
    GetUnitById(data.unitID):SetVisionRingsEnabled(data.enabled)
end

---@class SetRadarActive : Command
SetRadarActive = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "unitID",  type = Layouts.GlobalID },
    { key = "enabled", type = "bool" },
})

---@param unitID GlobalID
---@param enabled boolean
function SetRadarActive.Send(unitID, enabled)
    return { unitID = unitID, enabled = enabled }
end

function SetRadarActive.Receive(data)
    GetUnitById(data.unitID):SetRadarRingEnabled(data.enabled)
end

---@class SetSonarActive : Command
SetSonarActive = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "unitID",  type = Layouts.GlobalID },
    { key = "enabled", type = "bool" },
})

---@param unitID GlobalID
---@param enabled boolean
function SetSonarActive.Send(unitID, enabled)
    return { unitID = unitID, enabled = enabled }
end

function SetSonarActive.Receive(data)
    GetUnitById(data.unitID):SetSonarRingEnabled(data.enabled)
end


-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0

SetVeterancyCommand = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "unitID", type = Layouts.GlobalID },
    { key = "kills", type = "int" },
})

function SetVeterancyCommand.Send(unitID, kills)
    return { unitID = unitID, kills = kills }
end

function SetVeterancyCommand.Receive(data)
    _G.SCO_SetClientVeterancyKills(data.unitID, data.kills)
end
-- SCOM Field Fix: stale client unit-command resilience 1.0.0
local SCO_FieldFixClientCommandEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCO_FieldFixClientCommandVersion = "1.0.0"
local SCO_FieldFixClientCommandInstalled = rawget(
    SCO_FieldFixClientCommandEnvironment,
    "SCO_FieldFixClientCommandResilienceInstalled")
if SCO_FieldFixClientCommandInstalled ~= nil
    and SCO_FieldFixClientCommandInstalled ~= SCO_FieldFixClientCommandVersion
then
    error("Unsupported SCOM client-command resilience marker")
end
if SCO_FieldFixClientCommandInstalled == nil then
    local visionCommand = Import("common/commands/definitions/intel.lua").SetIntelVision
    local progressCommand = SetUnitProgress
    local SCOIntelBitMask = Import("common/intelBitMask.lua").IntelBitMask
    if type(visionCommand) ~= "table"
        or type(progressCommand) ~= "table"
        or type(SCOIntelBitMask) ~= "table"
        or type(SCOIntelBitMask.new) ~= "function"
        or type(GetUnitById) ~= "function"
    then
        error("SCOM client-command resilience could not resolve stock contracts")
    end

    local diagnosticBudget = 8
    local function diagnose(kind, unitId)
        if diagnosticBudget <= 0 then return end
        diagnosticBudget = diagnosticBudget - 1
        if type(Warn) == "function" then
            Warn("[SCOM Client Command] Ignored stale " .. kind
                .. " for missing unit " .. tostring(unitId and unitId.index))
        end
    end

    local function resolveUnit(data, kind)
        if type(data) ~= "table" or data.unitID == nil then
            diagnose(kind, nil)
            return nil, nil
        end
        local lookupOk, unit = pcall(GetUnitById, data.unitID)
        if not lookupOk or unit == nil or unit.deleted then
            diagnose(kind, data.unitID)
            return nil, data
        end
        return unit, data
    end

    function ReceiveSCOResilientIntelVisionCommand(data)
        local unit, data = resolveUnit(
            data,
            "intel-vision update")
        if unit == nil or type(unit.UpdateIntelVisionDetection) ~= "function" then
            return
        end
        return unit:UpdateIntelVisionDetection(
            SCOIntelBitMask.new(data.detectionMask))
    end

    function ReceiveSCOResilientSetUnitProgressCommand(data)
        local unit, data = resolveUnit(
            data,
            "build-progress update")
        if unit == nil or type(unit.SetBuildProgress) ~= "function" then return end
        return unit:SetBuildProgress(data.progress)
    end

    visionCommand.Receive = ReceiveSCOResilientIntelVisionCommand
    progressCommand.Receive = ReceiveSCOResilientSetUnitProgressCommand
    rawset(
        SCO_FieldFixClientCommandEnvironment,
        "SCO_FieldFixClientCommandResilienceInstalled",
        SCO_FieldFixClientCommandVersion)
end
-- Authenticated ground cargo requests; define in common command registry scope.
local SCOCargoRegistry = Import("common/commands/registry.lua")
local SCOCargoLayouts = Import("common/commands/layouts.lua")
local SCOCargoLobby = Import("common/lobby.lua")
local SCOCargoMapUtils = Import("common/mapUtils.lua")

SCOSourceCargo = SCOCargoRegistry.RegisterCommand(SCOCargoRegistry.CommandChannel.ClientToHost, {
    {key="carrierID",type=SCOCargoLayouts.GlobalID},
    {key="cargoID",type=SCOCargoLayouts.GlobalID},
    {key="unload",type="bool"},
    {key="position",type=SCOCargoLayouts.Float3},
})
function SCOSourceCargo.Send(carrierID,cargoID,unload,position)
    return {carrierID=carrierID,cargoID=cargoID,unload=unload,position=position}
end

local function SCOCargoFinite(value)
    return type(value)=="number" and value==value and value~=math.huge and value~=-math.huge
end
local function SCOCargoID(id)
    return type(id)=="table" and SCOCargoFinite(id.index) and id.index>=0 and id.index==math.floor(id.index)
        and SCOCargoFinite(id.version) and id.version>=0 and id.version==math.floor(id.version)
end
local function SCOCargoOwned(unit,clientID,id)
    local player = unit and unit.army and SCOCargoLobby.ArmyToPlayer[unit.army.id]
    return unit and not unit.dead and unit.id.index==id.index and unit.id.version==id.version
        and player and player.clientID==clientID
end
local function SCOCargoCarrierAvailable(carrier,cargo,clientID)
    if not carrier.army:IsAlly(cargo.army) or not cargo.army:IsAlly(carrier.army) then return false end
    if SCOCargoOwned(carrier,clientID,carrier.id) then return true end
    -- An allied player may offer their own cargo to an idle, empty transport.
    -- Only that same pickup batch may add passengers while its approach runs;
    -- never replace the transport owner's movement, combat or unload orders.
    if carrier.scoCargoRequestClientID==clientID and carrier.scoCargoPending then return true end
    local orders=carrier.orders
    return not carrier.scoCargoPending and not carrier.scoCargoUnloadPosition
        and #(carrier.scoCargo or {})==0
        and (not orders or (not orders.activeOrder and not next(orders.queuedOrders or {})))
end
function SCOSourceCargo.Receive(data,command)
    if type(command)~="table" or type(command.clientID)~="number"
        or (type(command.commandData)=="string" and #command.commandData>64)
        or type(data)~="table" or type(data.unload)~="boolean"
        or not SCOCargoID(data.carrierID) or not SCOCargoID(data.cargoID)
    then return false end
    local carrier = GetUnitById(data.carrierID)
    if not carrier or carrier.dead or carrier.id.index~=data.carrierID.index
        or carrier.id.version~=data.carrierID.version then return false end
    if data.unload then
        if not SCOCargoOwned(carrier,command.clientID,data.carrierID) then return false end
        local p=data.position
        if type(p)~="table" or not SCOCargoFinite(p.x) or not SCOCargoFinite(p.y) or not SCOCargoFinite(p.z)
            or not SCOCargoMapUtils.IsPositionOnMap(p) then return false end
        return carrier.SCORequestCargoUnload and carrier:SCORequestCargoUnload(p) or false
    end
    local cargo=GetUnitById(data.cargoID)
    if not SCOCargoOwned(cargo,command.clientID,data.cargoID)
        or not SCOCargoCarrierAvailable(carrier,cargo,command.clientID) then return false end
    local accepted=carrier.SCORequestCargoLoad and carrier:SCORequestCargoLoad(cargo) or false
    if accepted then carrier.scoCargoRequestClientID=command.clientID end
    return accepted
end

SCOSourceCargoState = SCOCargoRegistry.RegisterCommand(SCOCargoRegistry.CommandChannel.HostToClient, {
    {key="carrierID",type=SCOCargoLayouts.GlobalID},
    {key="cargoID",type=SCOCargoLayouts.GlobalID},
    {key="attached",type="bool"}, {key="count",type="int"},
})
function SCOSourceCargoState.Send(carrierID,cargoID,attached,count)
    return {carrierID=carrierID,cargoID=cargoID,attached=attached,count=count}
end
function SCOSourceCargoState.Receive(data)
    local carrier,cargo=GetUnitById(data.carrierID),GetUnitById(data.cargoID)
    if carrier then carrier.scoCargoCount=data.count end
    if cargo then
        cargo.scoCargoCarrierID=data.attached and data.carrierID or nil
        local config=carrier and carrier.tp and carrier.tp.additions and carrier.tp.additions.scoCargo
        if cargo.SCOSetAirStorageHidden and ((config and config.airStorage) or cargo.scoAirStorageHidden) then
            cargo:SCOSetAirStorageHidden(data.attached)
        end
    end
end
-- Source lifecycle events originate only on the simulation host.
local SpecialRegistry=Import("common/commands/registry.lua")
local SpecialLayouts=Import("common/commands/layouts.lua")
SCOSourceSpecialEvent=SpecialRegistry.RegisterCommand(SpecialRegistry.CommandChannel.HostToClient,{
    {key="unitID",type=SpecialLayouts.GlobalID},
    {key="event",type="string"},{key="bone",type="string"},
})
function SCOSourceSpecialEvent.Send(unitID,event,bone)
    return {unitID=unitID,event=event,bone=bone}
end
function SCOSourceSpecialEvent.Receive(data)
    local unit=GetUnitById(data.unitID)
    if unit and unit.id.index==data.unitID.index and unit.id.version==data.unitID.version
        and unit.SCOSpecialEvent then unit:SCOSpecialEvent(data.event,data.bone) end
end
-- Append to common/commands/definitions/units.lua before export.
local ModeRegistry=Import('common/commands/registry.lua')
local ModeLayouts=Import('common/commands/layouts.lua')
local ModeLobby=Import('common/lobby.lua')
local function sourceModeOwner(data,command,targetId)
    if type(data)~='table' or type(data.unitID)~='table'
        or type(command)~='table' or type(command.clientID)~='number' then return end
    local id=data.unitID
    if type(id.index)~='number' or id.index~=math.floor(id.index) or id.index<0 or id.index>4294967295
        or type(id.version)~='number' or id.version~=math.floor(id.version) or id.version<0 or id.version>4294967295 then return end
    local unit=GetUnitById(id)
    local player=unit and unit.army and ModeLobby.ArmyToPlayer[unit.army.id]
    if not unit or unit.dead or unit.id.index~=id.index or unit.id.version~=id.version
        or not player or player.clientID~=command.clientID or unit.tpId~=targetId then return end
    return unit
end
SCOSourceUnitMode=ModeRegistry.RegisterCommand(ModeRegistry.CommandChannel.ClientToHost,{
    {key='unitID',type=ModeLayouts.GlobalID},{key='groundMode',type='bool'},
})
function SCOSourceUnitMode.Send(unitID,groundMode)
    if IsObserver and IsObserver() then return end
    return {unitID=unitID,groundMode=groundMode}
end
function SCOSourceUnitMode.Receive(data,command)
    if type(data)~='table' or type(data.groundMode)~='boolean' then return false end
    local unit=sourceModeOwner(data,command,'ugl5001')
    if not unit then return false end
    return unit.SCOSetGroundMode and unit:SCOSetGroundMode(data.groundMode) or false
end
SCOSourceStealth=ModeRegistry.RegisterCommand(ModeRegistry.CommandChannel.ClientToHost,{
    {key='unitID',type=ModeLayouts.GlobalID},{key='enabled',type='bool'},
})
function SCOSourceStealth.Send(unitID,enabled)
    if IsObserver and IsObserver() then return end
    return {unitID=unitID,enabled=enabled}
end
function SCOSourceStealth.Receive(data,command)
    if type(data)~='table' or type(data.enabled)~='boolean' then return false end
    local unit=sourceModeOwner(data,command,'uga5006')
    if not unit then return false end
    return unit.SCOSetStealth and unit:SCOSetStealth(data.enabled) or false
end
SCOSourceStealthState=ModeRegistry.RegisterCommand(ModeRegistry.CommandChannel.HostToClient,{
    {key='unitID',type=ModeLayouts.GlobalID},{key='enabled',type='bool'},
})
function SCOSourceStealthState.Send(unitID,enabled)
    return {unitID=unitID,enabled=enabled}
end
function SCOSourceStealthState.Receive(data)
    local unit=GetUnitById(data.unitID)
    if unit and unit.tpId=='uga5006' and unit.id.version==data.unitID.version then unit.scoSourceStealth=data.enabled end
end
SCOSourceUnitModeState=ModeRegistry.RegisterCommand(ModeRegistry.CommandChannel.HostToClient,{
    {key='unitID',type=ModeLayouts.GlobalID},{key='groundMode',type='bool'},
})
function SCOSourceUnitModeState.Send(unitID,groundMode)
    return {unitID=unitID,groundMode=groundMode}
end
function SCOSourceUnitModeState.Receive(data)
    local unit=GetUnitById(data.unitID)
    if unit and unit.tpId=='ugl5001' and unit.id.version==data.unitID.version then unit.scoSourceGroundMode=data.groundMode end
end
SCOSourceSniperMode=ModeRegistry.RegisterCommand(ModeRegistry.CommandChannel.ClientToHost,{
    {key='unitID',type=ModeLayouts.GlobalID},{key='enabled',type='bool'},
})
function SCOSourceSniperMode.Send(unitID,enabled)
    if IsObserver and IsObserver() then return end
    return {unitID=unitID,enabled=enabled}
end
function SCOSourceSniperMode.Receive(data,command)
    if type(data)~='table' or type(data.enabled)~='boolean' then return false end
    local unit=sourceModeOwner(data,command,'usl3801')
    if not unit then return false end
    return unit.SCOSetSniperMode and unit:SCOSetSniperMode(data.enabled) or false
end
SCOSourceSniperModeState=ModeRegistry.RegisterCommand(ModeRegistry.CommandChannel.HostToClient,{
    {key='unitID',type=ModeLayouts.GlobalID},{key='enabled',type='bool'},
})
function SCOSourceSniperModeState.Send(unitID,enabled)
    return {unitID=unitID,enabled=enabled}
end
function SCOSourceSniperModeState.Receive(data)
    if type(data)~='table' or type(data.unitID)~='table' or type(data.enabled)~='boolean' then return end
    local unit=GetUnitById(data.unitID)
    if unit and not unit.dead and unit.tpId=='usl3801'
        and unit.id.index==data.unitID.index and unit.id.version==data.unitID.version then
        unit.scoSourceSniperMode=data.enabled
    end
end
-- Append in common/commands/definitions/units.lua; export both commands.
local SCOPodRegistry=Import("common/commands/registry.lua")
local SCOPodLayouts=Import("common/commands/layouts.lua")
local SCOPodLobby=Import("common/lobby.lua")
SCOSourcePod=SCOPodRegistry.RegisterCommand(SCOPodRegistry.CommandChannel.ClientToHost,{
    {key="unitID",type=SCOPodLayouts.GlobalID},{key="remove",type="bool"},
})
function SCOSourcePod.Send(unitID,remove) return {unitID=unitID,remove=remove} end
function SCOSourcePod.Receive(data,command)
    if type(data)~="table" or type(data.unitID)~="table" or type(data.remove)~="boolean"
        or type(command)~="table" or type(command.clientID)~="number"
        or (type(command.commandData)=="string" and #command.commandData>32) then return false end
    for _,field in ipairs({"index","version"}) do
        local n=data.unitID[field]
        if type(n)~="number" or n~=n or n<0 or n>2147483647 or n~=math.floor(n) then return false end
    end
    local unit=GetUnitById(data.unitID)
    local owner=unit and unit.army and SCOPodLobby.ArmyToPlayer[unit.army.id]
    if not unit or unit.dead or unit.deleted or unit.tpId~="uel5007"
        or unit.id.index~=data.unitID.index or unit.id.version~=data.unitID.version
        or not owner or owner.clientID~=command.clientID then return false end
    if unit.tp.additions and unit.tp.additions.scoSupportCommanderEnhancements then
        local state=unit.scoCommanderEnhancements
        if data.remove and state and state.active then
            local cancel=rawget(_G,"SCO_CommanderEnhancementHostCancel")
            return type(cancel)=="function" and cancel(command.clientID,unit.id) or false
        end
        local handler=rawget(_G,data.remove and "SCO_CommanderEnhancementHostRemove" or "SCO_CommanderEnhancementHostStart")
        return type(handler)=="function" and handler(command.clientID,unit.id,"Pod") or false
    end
    return unit:SCORequestPod(data.remove)
end
SCOSourcePodState=SCOPodRegistry.RegisterCommand(SCOPodRegistry.CommandChannel.HostToClient,{
    {key="unitID",type=SCOPodLayouts.GlobalID},{key="installed",type="bool"},
    {key="working",type="bool"},{key="progress",type="float"},
})
function SCOSourcePodState.Send(unitID,installed,working,progress)
    return {unitID=unitID,installed=installed,working=working,progress=progress}
end
function SCOSourcePodState.Receive(data)
    local unit=GetUnitById(data.unitID)
    if unit and unit.id.index==data.unitID.index and unit.id.version==data.unitID.version then
        unit.scoSourcePodInstalled=data.installed;unit.scoSourcePodWorking=data.working
        unit.scoSourcePodProgress=data.progress
    end
end
-- Host owns random exhaust timing and weapon phase events.
local DynamicRegistry=Import('common/commands/registry.lua')
local DynamicLayouts=Import('common/commands/layouts.lua')
SCOSourceDynamicVisual=DynamicRegistry.RegisterCommand(DynamicRegistry.CommandChannel.HostToClient,{
    {key='unitID',type=DynamicLayouts.GlobalID},{key='kind',type='int'},
    {key='serial',type='int'},{key='enabled',type='bool'},{key='time',type='float'},
    {key='left',type='float'},{key='right',type='float'},{key='leftGoal',type='float'},{key='rightGoal',type='float'},
})
function SCOSourceDynamicVisual.Send(unitID,kind,serial,enabled,time,left,right,leftGoal,rightGoal)
    return {unitID=unitID,kind=kind,serial=serial,enabled=enabled,time=time,
        left=left or 0,right=right or 0,leftGoal=leftGoal or 0,rightGoal=rightGoal or 0}
end
function SCOSourceDynamicVisual.Receive(data)
    if _G.SCO_SourceDynamicEvent then return _G.SCO_SourceDynamicEvent(data) end
end
local ClearanceRegistry=Import('common/commands/registry.lua')
local ClearanceLayouts=Import('common/commands/layouts.lua')
SCOFactoryClearance=ClearanceRegistry.RegisterCommand(ClearanceRegistry.CommandChannel.HostToClient,{
    {key='unitID',type=ClearanceLayouts.GlobalID},{key='serial',type='int'},
    {key='time',type='float'},{key='fromPhase',type='float'},{key='goalPhase',type='float'},
})
function SCOFactoryClearance.Send(unitID,serial,time,fromPhase,goalPhase)
    return {unitID=unitID,serial=serial,time=time,fromPhase=fromPhase,goalPhase=goalPhase}
end
function SCOFactoryClearance.Receive(event)
    if _G.SCO_FactoryClearanceEvent then return _G.SCO_FactoryClearanceEvent(event) end
end
