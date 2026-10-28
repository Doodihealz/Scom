-- Build queue and rally point, in both directions.
--
-- Clients predict queue changes locally and ask the host to apply them; the host echoes the
-- authoritative queue back, and acknowledges each pending prediction as it lands.

local Registry = Import("common/commands/registry.lua")
local Layouts  = Import("common/commands/layouts.lua")

local Units = __Entities.Units

--== Layouts ===================================================================

local buildQueueItemLayout = {
    { key = "entryIds", type = Layouts.Array("int") },
    { key = "tpId",     type = "string" },
}

local addToBuildQueueLayout = {
    { key = "unitsIDs",           type = Layouts.Array(Layouts.GlobalID) },
    { key = "entryIds",           type = Layouts.Array(Layouts.Array("int")) },
    { key = "targetItemEntryIds", type = Layouts.Array("int") },
    { key = "tpId",               type = "string" },
}

local removeFromBuildQueueLayout = {
    { key = "unitsIDs", type = Layouts.Array(Layouts.GlobalID) },
    { key = "entryIds", type = Layouts.Array(Layouts.Array("int")) },
}

--== Host to client ============================================================

---@class UpdateBuildQueue : Command
UpdateBuildQueue = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "unitID",     type = Layouts.GlobalID },
    { key = "buildQueue", type = Layouts.Array(buildQueueItemLayout) },
})

---@param unitID GlobalID
---@param buildQueue table[] The unit's authoritative build queue.
function UpdateBuildQueue.Send(unitID, buildQueue)
    return { unitID = unitID, buildQueue = buildQueue }
end

function UpdateBuildQueue.Receive(data)
    GetUnitById(data.unitID):UpdateBuildQueue(data.buildQueue)
end

---@class OnPendingQueueOperationCompleted : Command
OnPendingQueueOperationCompleted = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, Layouts.UnitEvent)

---@param unitID GlobalID
function OnPendingQueueOperationCompleted.Send(unitID)
    return { unitID = unitID }
end

function OnPendingQueueOperationCompleted.Receive(data)
    table.remove(Units[data.unitID.index].buildQueuePendingOperations, 1)
end

--== Client to host ============================================================

---@class RequestAddToBuildQueue : Command
RequestAddToBuildQueue = Registry.RegisterCommand(Registry.CommandChannel.ClientToHost, addToBuildQueueLayout)

---@param unitsIDs GlobalID[]
---@param entryIds integer[][] The new entry ids for each unit, in the same order.
---@param targetItemEntryIds integer[] For each unit, an entry id of the item to add to. 0 adds to the back of the queue.
---@param tpId string
function RequestAddToBuildQueue.Send(unitsIDs, entryIds, targetItemEntryIds, tpId)
    -- Observers may not control units.
    if IsObserver() then
        return
    end

    return {
        unitsIDs           = unitsIDs,
        entryIds           = entryIds,
        targetItemEntryIds = targetItemEntryIds,
        tpId               = tpId,
    }
end

function RequestAddToBuildQueue.Receive(data)
    for index, unitID in ipairs(data.unitsIDs) do
        local unit = GetUnitById(unitID)
        if unit then
            OnPendingQueueOperationCompleted.Send(unitID)
            buildQueueUtils.AddToBuildQueue(unit, data.tpId, data.entryIds[index], data.targetItemEntryIds[index])
        end
    end
end

---@class RequestRemoveFromBuildQueue : Command
RequestRemoveFromBuildQueue = Registry.RegisterCommand(Registry.CommandChannel.ClientToHost, removeFromBuildQueueLayout)

---@param unitsIDs GlobalID[]
---@param entryIds integer[][] The entry ids to remove from each unit's queue, in the same order.
function RequestRemoveFromBuildQueue.Send(unitsIDs, entryIds)
    -- Observers may not control units.
    if IsObserver() then
        return
    end

    return { unitsIDs = unitsIDs, entryIds = entryIds }
end

function RequestRemoveFromBuildQueue.Receive(data)
    for index, unitID in ipairs(data.unitsIDs) do
        local unit = GetUnitById(unitID)
        if unit then
            OnPendingQueueOperationCompleted.Send(unitID)
            buildQueueUtils.RemoveFromBuildQueue(unit, data.entryIds[index])
        end
    end
end

--- Adds count entries of tpId to each unit's predicted queue, and asks the host to add the same entries.
---@param units table<integer, ClientUnit|PredictedUnit> Units without a global id are only predicted.
---@param tpId string
---@param count integer
---@param queueItemPerUnit table<integer, table>? Keyed like units, the queue item to add to. Nil adds to the back of the queue.
function AddToBuildQueueForUnits(units, tpId, count, queueItemPerUnit)
    local unitsIDs = {}
    local entryIdsPerUnit = {}
    local targetItemEntryIds = {}

    for localIDIndex, unit in pairs(units) do
        local targetItemEntryId = 0
        if queueItemPerUnit then
            local itemEntryIds = queueItemPerUnit[localIDIndex].entryIds
            for entryIndex = #itemEntryIds, 1, -1 do
                if buildQueueUtils.FindEntry(unit.predictedBuildQueue, itemEntryIds[entryIndex]) then
                    targetItemEntryId = itemEntryIds[entryIndex]
                    break
                end
            end
        end

        local entryIds = buildQueueUtils.NewEntryIds(count)

        -- Only request entries the predicted queue kept, units that can't build tpId drop them
        if buildQueueUtils.AddToBuildQueue(unit, tpId, entryIds, targetItemEntryId, true) and unit.id then
            table.insert(unitsIDs, unit.id)
            table.insert(entryIdsPerUnit, entryIds)
            table.insert(targetItemEntryIds, targetItemEntryId)
            table.insert(unit.buildQueuePendingOperations, {
                tpId = tpId,
                entryIds = entryIds,
                targetItemEntryId = targetItemEntryId,
            })
        end
    end

    RequestAddToBuildQueue.Send(unitsIDs, entryIdsPerUnit, targetItemEntryIds, tpId)
end

--- Removes the last count entries of tpId from each unit's predicted queue, and asks the host to remove the same entries.
---@param units table<integer, ClientUnit|PredictedUnit> Units without a global id are only predicted.
---@param tpId string
---@param count integer
---@param queueItemPerUnit table<integer, table>? Keyed like units, the queue item to remove from. Nil removes from every item of tpId, starting at the back of the queue.
function RemoveFromBuildQueueForUnits(units, tpId, count, queueItemPerUnit)
    local unitsIDs = {}
    local entryIdsPerUnit = {}

    for localIDIndex, unit in pairs(units) do
        local items = queueItemPerUnit and { queueItemPerUnit[localIDIndex] } or unit.predictedBuildQueue
        local entryIds = {}
        for itemIndex = #items, 1, -1 do
            local item = items[itemIndex]
            if item.tpId == tpId then
                for entryIndex = #item.entryIds, 1, -1 do
                    if #entryIds == count then
                        break
                    end
                    local entryId = item.entryIds[entryIndex]
                    if buildQueueUtils.FindEntry(unit.predictedBuildQueue, entryId) then
                        table.insert(entryIds, entryId)
                    end
                end
            end
        end

        buildQueueUtils.RemoveFromBuildQueue(unit, entryIds, true)

        if unit.id then
            table.insert(unitsIDs, unit.id)
            table.insert(entryIdsPerUnit, entryIds)
            table.insert(unit.buildQueuePendingOperations, {
                isRemoval = true,
                entryIds = entryIds,
            })
        end
    end

    RequestRemoveFromBuildQueue.Send(unitsIDs, entryIdsPerUnit)
end

---@class RequestRallyPoint : Command
RequestRallyPoint = Registry.RegisterCommand(Registry.CommandChannel.ClientToHost, {
    { key = "unitsIDs",       type = Layouts.Array(Layouts.GlobalID) },
    { key = "targetPosition", type = Layouts.Float3 },
})

---@param selectedUnits table[] Units to give the rally point to.
---@param targetPosition float3
function RequestRallyPoint.Send(selectedUnits, targetPosition)
    -- Observers may not control units.
    if IsObserver() then
        return
    end

    local unitsIDs = {}
    for index = 1, #selectedUnits do
        table.insert(unitsIDs, selectedUnits[index].id)
    end

    return { unitsIDs = unitsIDs, targetPosition = targetPosition }
end

function RequestRallyPoint.Receive(data)
    for _, unitID in ipairs(data.unitsIDs) do
        local unit = GetUnitById(unitID)
        if unit then
            unit:SetRallyPoint(EngineClasses.float3(data.targetPosition.x, data.targetPosition.y,
                data.targetPosition.z))
        end
    end
end
-- SCOM Field Fixes 1.0.3 - validated silo and stationary-factory commands.
local SCOFieldFixStrategicSiloCommandsEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOFieldFixStrategicSiloCommandsMarker = rawget(
    SCOFieldFixStrategicSiloCommandsEnvironment,
    "SCO_FieldFixStrategicSiloCommandsInstalled")
if SCOFieldFixStrategicSiloCommandsMarker ~= nil
    and SCOFieldFixStrategicSiloCommandsMarker ~= "1.0.3"
then
    error("Unsupported SCOM strategic silo commands marker "
        .. tostring(SCOFieldFixStrategicSiloCommandsMarker))
end
if SCOFieldFixStrategicSiloCommandsMarker == nil then

    local SCORegistry = Import("common/commands/registry.lua")
    local SCOLayouts = Import("common/commands/layouts.lua")
    local SCOBinarySerialization = Import("common/commands/binarySerialization.lua")
    local SCOToggleCommands = Import("common/commands/definitions/toggles.lua")
    local SCOToggleTypeToName = Import("common/toggles.lua").ToggleTypeToToggleName
    if type(SCORegistry.RegisterCommand) ~= "function"
        or type(SCOLayouts.GlobalID) ~= "table"
        or type(SCOLayouts.Float3) ~= "table"
        or type(RequestRallyPoint) ~= "table"
        or type(SCOToggleCommands.RequestUnitsToggle) ~= "table"
        or type(SCOToggleTypeToName) ~= "function"
        or type(SCOBinarySerialization.Serialize) ~= "function"
        or type(Engine) ~= "table"
        or type(Engine.CreateCustomCommand) ~= "function"
        or type(Engine.Error) ~= "function"
        or type(EngineErrorCode) ~= "table"
        or EngineErrorCode.Success == nil
    then
        error("SCOM strategic silo could not resolve custom-command contracts")
    end

    local SCOMapUtils = Import("common/mapUtils.lua")
    local SCOLobby = Import("common/lobby.lua")
    if type(SCOLobby) ~= "table"
        or type(SCOLobby.ArmyToPlayer) ~= "table"
    then
        error("SCOM strategic silo could not resolve lobby ownership")
    end
    local SCOActions = {
        Queue = 1,
        SetAuto = 2,
        Launch = 3,
        Clear = 4,
    }
    local SCOMaxUnitsPerCommand = 64
    local SCOEncodedSiloMaxBytes = 536
    local SCOEncodedRallyMaxBytes = 528
    local SCOEncodedToggleMaxBytes = 521
    local SCOAllowedToggleNames = {
        Production = true,
        Pause = true,
        RepeatBuild = true,
        Shield = true,
        Intel = true,
        CounterIntel = true,
        Submerge = true,
        SwiftSwimmer = true,
    }

    local function SCOFinite(value)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    local function SCOValidPosition(position)
        return type(position) == "table"
            and SCOFinite(position.x)
            and SCOFinite(position.y)
            and SCOFinite(position.z)
            and SCOMapUtils.IsPositionOnMap(position)
    end

    local function SCOEncodedPayloadWithin(command, maximum)
        local payload = command and command.commandData
        return type(payload) ~= "string" or #payload <= maximum
    end

    local SCODiagnosticBudget = 16
    local function SCODiagnostic(message)
        if SCODiagnosticBudget <= 0 then return end
        SCODiagnosticBudget = SCODiagnosticBudget - 1
        Engine.Error("[SCOM Strategic Silo Diagnostic] " .. message)
    end

    local function SCOArmyClientId(army)
        local player = army
            and type(army.id) == "number"
            and SCOLobby.ArmyToPlayer[army.id]
        return type(player) == "table" and player.clientID or nil
    end

    local function SCOOwnedUnit(unit, clientId)
        return type(clientId) == "number"
            and unit ~= nil
            and not unit.dead
            and unit.army ~= nil
            and SCOArmyClientId(unit.army) == clientId
    end

    local function SCOLogLaunch(unit, accepted, detail)
        local outcome = accepted and "accepted" or "rejected"
        local reason = detail
        if accepted and detail ~= "launching" then
            reason = "launched"
        end
        SCODiagnostic("Host launch " .. outcome
            .. ": tp=" .. tostring(unit and unit.tpId)
            .. " id=" .. tostring(unit and unit.id)
            .. " reason=" .. tostring(reason))
    end

    local SCOSiloLayout = {
        { key = "unitsIDs", type = { type = "array", item_type = SCOLayouts.GlobalID } },
        { key = "action", type = "int" },
        { key = "amount", type = "int" },
        { key = "targetPosition", type = SCOLayouts.Float3 },
    }

    SCOStrategicSiloCommand = SCORegistry.RegisterCommand(
        SCORegistry.CommandChannel.ClientToHost, SCOSiloLayout)
    function SCOStrategicSiloCommand.Send(payload)
        return payload
    end

    function SendSCOStrategicSiloCommand(units, action, amount, targetPosition)
        if IsObserver and IsObserver() then
            if action == SCOActions.Launch then
                SCODiagnostic("Client launch rejected: observer=true")
            end
            return false, "observer"
        end
        if action ~= SCOActions.Queue
            and action ~= SCOActions.SetAuto
            and action ~= SCOActions.Launch
            and action ~= SCOActions.Clear
        then
            return false
        end

        local unitsIDs = {}
        local sent = false
        local failed = false
        local failureResult = nil
        local submittedCount = 0
        targetPosition = targetPosition or EngineClasses.float3(0, 0, 0)
        local function sendBatch()
            if #unitsIDs == 0 then return end
            local payload = {
                unitsIDs = unitsIDs,
                action = action,
                amount = amount or 0,
                targetPosition = targetPosition,
            }
            local commandString = SCOBinarySerialization.Serialize(
                SCOSiloLayout, payload)
            -- Native Send discards the engine result. Keep the UI's enqueue
            -- acknowledgement while resolving the registry-assigned ID at send time.
            local commandId = SCOStrategicSiloCommand.CommandID
            if commandId == nil then error("SCOM silo command sent before registry initialization") end
            local result = Engine.CreateCustomCommand(
                commandId, commandString)
            if result == EngineErrorCode.Success then
                sent = true
            else
                failed = true
                failureResult = result
                if action == SCOActions.Launch then
                    SCODiagnostic("Client launch enqueue rejected: units="
                        .. tostring(#unitsIDs)
                        .. " result=" .. tostring(result))
                end
            end
            unitsIDs = {}
        end
        for _, unit in pairs(units or {}) do
            if unit and unit.id then
                submittedCount = submittedCount + 1
                unitsIDs[#unitsIDs + 1] = unit.id
                if #unitsIDs >= SCOMaxUnitsPerCommand then sendBatch() end
            end
        end
        sendBatch()
        if action == SCOActions.Launch and sent and not failed then
            SCODiagnostic("Client launch enqueue accepted: units="
                .. tostring(submittedCount))
        end
        return sent and not failed,
            failed and ("engine-result=" .. tostring(failureResult)) or nil
    end

    function ReceiveSCOStrategicSiloCommand(data, command)
        if type(command) ~= "table" or type(command.clientID) ~= "number"
            or not SCOEncodedPayloadWithin(command, SCOEncodedSiloMaxBytes)
        then
            return false
        end
        if type(data) ~= "table" or type(data.unitsIDs) ~= "table"
            or #data.unitsIDs == 0
            or #data.unitsIDs > SCOMaxUnitsPerCommand
        then
            return false
        end
        if data.action == SCOActions.Queue then
            if type(data.amount) ~= "number"
                or data.amount ~= math.floor(data.amount)
                or data.amount < 1
                or data.amount > 5
            then
                return false
            end
        elseif data.action == SCOActions.SetAuto then
            if data.amount ~= 0 and data.amount ~= 1 then return false end
        elseif data.action == SCOActions.Launch then
            if not SCOValidPosition(data.targetPosition) then
                if type(Log) == "function" then
                    Log("[SCOM Strategic Silo] Launch rejected: client="
                        .. tostring(command.clientID)
                        .. " reason=target-command")
                end
                return false
            end
        elseif data.action ~= SCOActions.Clear then
            return false
        end

        local handled = false
        local visited = {}
        for _, unitId in ipairs(data.unitsIDs) do
            local key = tostring(unitId.index) .. ":" .. tostring(unitId.version)
            if not visited[key] then
                visited[key] = true
                local unit = GetUnitById(unitId)
                if SCOOwnedUnit(unit, command.clientID)
                    and type(unit.SCOCanClientControlStrategicSilo) == "function"
                    and unit:SCOCanClientControlStrategicSilo(command.clientID)
                then
                    local accepted = false
                    local detail = nil
                    if data.action == SCOActions.Queue then
                        accepted = unit:SCOQueueNuke(data.amount)
                    elseif data.action == SCOActions.SetAuto then
                        accepted = unit:SCOSetNukeAutoBuild(data.amount == 1)
                    elseif data.action == SCOActions.Launch then
                        accepted, detail = unit:SCOLaunchNuke(data.targetPosition)
                        SCOLogLaunch(unit, accepted, detail)
                    else
                        accepted = unit:SCOClearNukeQueue()
                    end
                    handled = accepted or handled
                elseif data.action == SCOActions.Launch then
                    SCOLogLaunch(unit, false, "control")
                end
            end
        end
        return handled
    end

    SCOStrategicSiloCommand.Receive = ReceiveSCOStrategicSiloCommand
    SCOStrategicSilo = {
        Send = SendSCOStrategicSiloCommand,
        Actions = SCOActions,
    }

    -- Replace the unvalidated stock rally receiver. The client routes this command
    -- only for stationary structure factories; the host enforces the same contract.
    function ReceiveSCOValidatedSetRallyPointCommand(data, command)
        if type(command) ~= "table" or type(command.clientID) ~= "number"
            or not SCOEncodedPayloadWithin(command, SCOEncodedRallyMaxBytes)
        then
            return false
        end
        if type(data) ~= "table" or type(data.unitsIDs) ~= "table"
            or #data.unitsIDs == 0
            or #data.unitsIDs > SCOMaxUnitsPerCommand
            or not SCOValidPosition(data.targetPosition)
        then
            return false
        end

        local target = EngineClasses.float3(
            data.targetPosition.x,
            data.targetPosition.y,
            data.targetPosition.z)
        local handled = false
        local visited = {}
        for _, unitId in ipairs(data.unitsIDs) do
            local key = tostring(unitId.index) .. ":" .. tostring(unitId.version)
            if not visited[key] then
                visited[key] = true
                local unit = GetUnitById(unitId)
                if SCOOwnedUnit(unit, command.clientID)
                    and unit:IsFactory()
                    and unit:HasTags(Tags.STRUCTURE)
                    and not unit:HasTags(Tags.MOBILE)
                    and type(unit.SetRallyPoint) == "function"
                then
                    unit:SetRallyPoint(target)
                    handled = true
                end
            end
        end
        return handled
    end

    RequestRallyPoint.Receive =
        ReceiveSCOValidatedSetRallyPointCommand

    -- Stock 0.0.1.11 accepts SetToggle for any decoded GlobalID and contains an
    -- explicit ownership-validation TODO. Pause controls the paid silo drain,
    -- so validate this shared command at its authoritative host boundary.
    function ReceiveSCOValidatedSetToggleCommand(data, command)
        if type(command) ~= "table" or type(command.clientID) ~= "number"
            or not SCOEncodedPayloadWithin(command, SCOEncodedToggleMaxBytes)
        then
            return false
        end
        if type(data) ~= "table" or type(data.unitIds) ~= "table"
            or #data.unitIds == 0
            or #data.unitIds > SCOMaxUnitsPerCommand
            or type(data.toggleType) ~= "number"
            or data.toggleType ~= math.floor(data.toggleType)
            or type(data.enabled) ~= "boolean"
        then
            return false
        end
        local nameOk, toggleName = pcall(SCOToggleTypeToName, data.toggleType)
        if not nameOk or not SCOAllowedToggleNames[toggleName] then
            return false
        end

        local handled = false
        local visited = {}
        for _, unitId in ipairs(data.unitIds) do
            local key = tostring(unitId.index) .. ":" .. tostring(unitId.version)
            if not visited[key] then
                visited[key] = true
                local lookupOk, unit = pcall(GetUnitById, unitId)
                if lookupOk and SCOOwnedUnit(unit, command.clientID)
                    and type(unit.toggles) == "table"
                    and unit.toggles[toggleName] ~= nil
                    and type(unit.SetToggle) == "function"
                then
                    local toggleOk = pcall(
                        unit.SetToggle, unit, toggleName, data.enabled)
                    handled = toggleOk or handled
                end
            end
        end
        return handled
    end

    SCOToggleCommands.RequestUnitsToggle.Receive =
        ReceiveSCOValidatedSetToggleCommand

    rawset(
        SCOFieldFixStrategicSiloCommandsEnvironment,
        "SCO_FieldFixStrategicSiloCommandsInstalled",
        "1.0.3")
    _G.SCO_FieldFixStrategicSiloCommandsInstalled = "1.0.3"
end
