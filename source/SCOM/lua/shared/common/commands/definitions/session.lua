-- Session-wide commands: chat, the log panel, simulation speed, and the generic function-call
-- bridge that common/systems/networking.lua is built on.

local Registry = Import("common/commands/registry.lua")

local Panels = nil
if IsClient then
    Panels = Import("client/ui/panels.lua")
end

--== Log =======================================================================

---@class AddLog : Command
AddLog = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "text", type = "string" },
})

---Tell the clients to show a log line to the player.
---@param text string
function AddLog.Send(text)
    return { text = text }
end

function AddLog.Receive(data)
    if Panels ~= nil then
        Panels.LogPanel.AddLog(data.text)
    end
end

--== Unit damage alerts ========================================================

local missingDamageAlertWarnings = {}

---@class PlayUnitDamagedAlert : Command
PlayUnitDamagedAlert = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "eventName", type = "string" },
})

---@param eventName string
function PlayUnitDamagedAlert.Send(eventName)
    return { eventName = eventName }
end

---@param data {eventName: string}
function PlayUnitDamagedAlert.Receive(data)
    local AudioCategories = Import("client/audio/audioCategories.lua")
    local eventID = AudioCategories.TryResolveEventName(data.eventName)
    if eventID == nil then
        if not missingDamageAlertWarnings[data.eventName] then
            Engine.Warn("Missing Wwise event: " .. data.eventName)
            missingDamageAlertWarnings[data.eventName] = true
        end
        return
    end

    Engine.PostAudioEvent(eventID)
end

--== Chat ======================================================================

---@class RequestChatMessage : Command
RequestChatMessage = Registry.RegisterCommand(Registry.CommandChannel.ClientToHost, {
    { key = "channel", type = "byte" },
    { key = "text",    type = "string" },
})

---@param text string
---@param channel ChatChannel
function RequestChatMessage.Send(text, channel)
    return { channel = channel, text = text }
end

function RequestChatMessage.Receive(data, command)
    Import("common/systems/chat.lua").ReceiveFromClient(command.clientID, data.channel, data.text)
end

---@class BroadcastChatMessage : Command
BroadcastChatMessage = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "senderClientID", type = "byte" },
    { key = "channel",        type = "byte" },
    { key = "text",           type = "string" },
})

---Send with no target to reach everyone, or SendTo(clientID, message) to reach one player.
---@param message ChatMessage
function BroadcastChatMessage.Send(message)
    return message
end

function BroadcastChatMessage.Receive(data)
    Import("common/systems/chat.lua").ReceiveMessage(data)
end

--== Simulation speed ==========================================================

local minSimulationSpeed = Constants.MinimumSimulationSpeed
local maxSimulationSpeed = Constants.MaximumSimulationSpeed

---@param speed number
---@param faster boolean
---@return number
function StepSimulationSpeed(speed, faster)
    local stepped
    if faster then
        if speed < 1 then
            stepped = (math.floor(speed * 10 + 0.5) + 1) / 10
        else
            stepped = math.floor(speed) + 1
        end
    elseif speed > 1 then
        stepped = math.ceil(speed) - 1
    else
        stepped = (math.floor(speed * 10 + 0.5) - 1) / 10
    end
    return math.clamp(stepped, minSimulationSpeed, maxSimulationSpeed)
end

---@class AdjustSimulationSpeed : Command
AdjustSimulationSpeed = Registry.RegisterCommand(Registry.CommandChannel.ClientToHost, {
    { key = "faster", type = "bool" },
})

---@param faster boolean
function AdjustSimulationSpeed.Send(faster)
    return { faster = faster }
end

function AdjustSimulationSpeed.Receive(data)
    Engine.SetSimulationSpeed(StepSimulationSpeed(Engine.GetSimulationSpeed(), data.faster))
    AddLog.Send("Speed changed to " .. math.floor(Engine.GetSimulationSpeed() * 10 + 0.5) / 10)
end

--== Function call bridge ======================================================

-- These two carry an arbitrary named call rather than a fixed shape, so they json-encode it into a
-- single string field. The registry knows nothing about json: it is this command's business.
--
-- Pinned ids: the command manifest handshake travels over ExecuteClientFunction, so it has to keep
-- working even when a mismatch is exactly what is being reported.

local functionCallLayout = {
    { key = "call", type = "string" },
}

---@param functionName string
---@param functionData any
---@return table payload
local function EncodeFunctionCall(functionName, functionData)
    return { call = json.encode({ functionName = functionName, functionData = functionData }) }
end

---@class ExecuteClientFunction : Command
ExecuteClientFunction = Registry.RegisterCommand(Registry.CommandChannel.HostToClient,
    functionCallLayout, 0)

---Send with no target to reach everyone, or SendTo(clientID, name, data) to reach one player.
---@param functionName string
---@param functionData any
function ExecuteClientFunction.Send(functionName, functionData)
    return EncodeFunctionCall(functionName, functionData)
end

function ExecuteClientFunction.Receive(data)
    local functionCall = json.decode(data.call)
    ReceiveDataClient(functionCall.functionName, functionCall.functionData)
end

---@class ExecuteHostFunction : Command
ExecuteHostFunction = Registry.RegisterCommand(Registry.CommandChannel.ClientToHost,
    functionCallLayout, 0)

---@param functionName string
---@param functionData any
function ExecuteHostFunction.Send(functionName, functionData)
    return EncodeFunctionCall(functionName, functionData)
end

function ExecuteHostFunction.Receive(data)
    local functionCall = json.decode(data.call)
    ReceiveDataHost(functionCall.functionName, functionCall.functionData)
end

-- Supreme Commander Overhaul commander enhancements 1.0.0
-- Uses Sanctuary's generic execute-function command without allocating a new
-- command ID. Enhancement messages and stock Stop are intercepted only so the
-- authenticated native clientID can reach host-authoritative enhancement work.
local SCOCommanderEnhancementCommandsEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderEnhancementCommandsMarker = rawget(
    SCOCommanderEnhancementCommandsEnvironment,
    "SCO_CommanderEnhancementCommandsInstalled")
if SCOCommanderEnhancementCommandsMarker ~= nil
    and SCOCommanderEnhancementCommandsMarker ~= "1.2.0"
then
    error("Unsupported SCOM commander-enhancement commands marker "
        .. tostring(SCOCommanderEnhancementCommandsMarker))
end
if SCOCommanderEnhancementCommandsMarker == nil then
    local SCOGenericCommand = ExecuteHostFunction
    local SCOHostToClientCommand = ExecuteClientFunction
    if type(SCOGenericCommand) ~= "table"
        or type(SCOGenericCommand.Send) ~= "function"
        or type(SCOGenericCommand.Receive) ~= "function"
        or type(SCOHostToClientCommand) ~= "table"
        or type(SCOHostToClientCommand.Send) ~= "function"
        or type(json) ~= "table"
        or type(json.decode) ~= "function"
    then
        error("SCOM commander enhancements could not resolve generic RPC contracts")
    end

    local SCOStockGenericHostReceive = SCOGenericCommand.Receive
    -- Registry.Initialize replaces payload constructors after this module loads.
    -- Resolve the transmitting wrappers when each request is actually sent.
    local function SCOGenericClientSend(name, data)
        return SCOGenericCommand.Send(name, data)
    end
    local function SCOGenericHostSend(name, data, clientID)
        return SCOHostToClientCommand.SendTo(clientID, name, data)
    end
    local SCOMaxEncodedRequestBytes = 1024
    local SCOMaxIdentifierLength = 96
    local SCORpcByAction = {
        install = "SCOCommanderEnhancementStart",
        cancel = "SCOCommanderEnhancementCancel",
        remove = "SCOCommanderEnhancementRemove",
        state = "SCOCommanderEnhancementStateRequest",
        visual = "SCOCommanderEnhancementVisualStateRequest",
    }
    local SCOActionByRpc = {}
    for action, rpcName in pairs(SCORpcByAction) do
        SCOActionByRpc[rpcName] = action
    end

    local function SCOInteger(value, minimum, maximum)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
            and value == math.floor(value)
            and value >= minimum
            and value <= maximum
    end

    local function SCOIdentifier(value)
        return type(value) == "string"
            and #value >= 1
            and #value <= SCOMaxIdentifierLength
            and string.match(value, "^[%w_%-]+$") ~= nil
    end

    local function SCOGlobalId(value)
        if type(value) ~= "table"
            or not SCOInteger(value.index, 1, 2147483647)
            or not SCOInteger(value.version, 0, 2147483647)
        then
            return nil
        end
        return { index = value.index, version = value.version }
    end

    local function SCOHasExactKeys(value, allowed, expectedCount)
        if type(value) ~= "table" then return false end
        local count = 0
        for key in pairs(value) do
            if not allowed[key] then return false end
            count = count + 1
        end
        return count == expectedCount
    end

    local function SCOCanonicalRequest(action, value)
        local needsEnhancement = action == "install" or action == "remove"
        local allowed = needsEnhancement
            and { unitId = true, enhancementId = true }
            or { unitId = true }
        if not SCOHasExactKeys(value, allowed, needsEnhancement and 2 or 1) then
            return nil
        end
        local unitId = SCOGlobalId(value.unitId)
        if not unitId then return nil end
        local request = { unitId = unitId }
        if needsEnhancement then
            if not SCOIdentifier(value.enhancementId) then return nil end
            request.enhancementId = value.enhancementId
        end
        return request
    end

    local function SCOEmitCurrentState(clientID, unitId)
        local getState = _G.SCO_CommanderEnhancementHostGetState
        local emitState = _G.SCO_CommanderEnhancementEmitState
        if type(getState) ~= "function" or type(emitState) ~= "function" then
            return false
        end
        local ok, state = pcall(getState, clientID, unitId)
        if not ok or type(state) ~= "table" then return false end
        local sent, result = pcall(emitState, clientID, state)
        return sent and result == true
    end

    local function SCOEmitCurrentVisualState(clientID, unitId)
        local getState = _G.SCO_CommanderEnhancementHostGetVisualState
        local emitState = _G.SCO_CommanderEnhancementEmitVisualState
        if type(getState) ~= "function" or type(emitState) ~= "function" then
            return false
        end
        local ok, state = pcall(getState, clientID, unitId)
        if not ok or type(state) ~= "table" then return false end
        local sent, result = pcall(emitState, clientID, state)
        return sent and result == true
    end

    local function SCOReceiveEnhancementRpc(command, action, request)
        if not SCOInteger(command.clientID, 0, 2147483647) then return false end
        local clientID = command.clientID
        if action == "state" then
            return SCOEmitCurrentState(clientID, request.unitId)
        elseif action == "visual" then
            return SCOEmitCurrentVisualState(clientID, request.unitId)
        end

        local hostFunction = nil
        if action == "install" then
            hostFunction = _G.SCO_CommanderEnhancementHostStart
        elseif action == "cancel" then
            hostFunction = _G.SCO_CommanderEnhancementHostCancel
        elseif action == "remove" then
            hostFunction = _G.SCO_CommanderEnhancementHostRemove
        end
        if type(hostFunction) ~= "function" then return false end

        local ok, accepted
        if action == "cancel" then
            ok, accepted = pcall(hostFunction, clientID, request.unitId)
        else
            ok, accepted = pcall(
                hostFunction,
                clientID,
                request.unitId,
                request.enhancementId)
        end
        if not ok or accepted ~= true then
            -- Re-publish the unchanged authority state so a stale client can
            -- recover without receiving internal rejection details.
            SCOEmitCurrentState(clientID, request.unitId)
            return false
        end
        return true
    end

    local function SCOCancelEnhancementsForClearOrder(command, envelope)
        if envelope.functionName ~= "ClearOrder"
            or not SCOInteger(command.clientID, 0, 2147483647)
            or type(envelope.functionData) ~= "table"
            or type(envelope.functionData.unitGlobalIds) ~= "table"
        then
            return
        end

        local cancel = _G.SCO_CommanderEnhancementHostCancel
        if type(cancel) ~= "function" then return end
        local seen = {}
        for _, candidate in pairs(envelope.functionData.unitGlobalIds) do
            local unitId = SCOGlobalId(candidate)
            if unitId then
                local key = tostring(unitId.index)
                    .. ":" .. tostring(unitId.version)
                if not seen[key] then
                    seen[key] = true
                    -- The stock ClearOrder receiver remains authoritative for
                    -- ordinary orders. This extra call reaches only the
                    -- separately hosted enhancement work and reuses its exact
                    -- GlobalID and owner validation.
                    pcall(cancel, command.clientID, unitId)
                end
            end
        end
    end

    local function SCOAuthenticatedGenericHostReceive(data, command)
        if type(data) ~= "table"
            or type(command) ~= "table"
            or type(data.call) ~= "string"
        then
            return false
        end
        local decoded, envelope = pcall(json.decode, data.call)
        if not decoded or type(envelope) ~= "table" then
            -- Stock decodes without protection and blindly resolves the
            -- requested listener. Never forward an envelope that would make
            -- that path throw on the simulation host.
            return false
        end
        local action = SCOActionByRpc[envelope.functionName]
        if not action then
            local stockResult = SCOStockGenericHostReceive(data, command)
            SCOCancelEnhancementsForClearOrder(command, envelope)
            return stockResult
        end
        if #data.call > SCOMaxEncodedRequestBytes then return false end
        if not SCOHasExactKeys(
            envelope,
            { functionName = true, functionData = true },
            2)
        then
            return false
        end
        local request = SCOCanonicalRequest(action, envelope.functionData)
        if not request then return false end
        return SCOReceiveEnhancementRpc(command, action, request)
    end

    SCOGenericCommand.Receive = SCOAuthenticatedGenericHostReceive

    local function SCOClientRequest(action, unitId, enhancementId)
        local rpcName = SCORpcByAction[action]
        local canonicalUnitId = SCOGlobalId(unitId)
        if not rpcName or not canonicalUnitId then return false end
        if IsObserver and IsObserver() and action ~= "visual" then
            return false
        end
        local payload = { unitId = canonicalUnitId }
        if action == "install" or action == "remove" then
            if not SCOIdentifier(enhancementId) then return false end
            payload.enhancementId = enhancementId
        end
        local ok = pcall(SCOGenericClientSend, rpcName, payload)
        return ok
    end

    local SCOClientRequestDispatcher =
        _G.SCO_CommanderEnhancementClientRequest
    if SCOClientRequestDispatcher ~= nil
        and type(SCOClientRequestDispatcher) ~= "function"
    then
        error("SCOM commander-enhancement client request dispatcher is occupied")
    end
    if SCOClientRequestDispatcher == nil then
        SCOClientRequestDispatcher = function(action, unitId, enhancementId)
            local handler = _G.SCO_CommanderEnhancementClientRequestHandler
            if type(handler) ~= "function" then return false end
            return handler(action, unitId, enhancementId)
        end
        _G.SCO_CommanderEnhancementClientRequest = SCOClientRequestDispatcher
    end
    _G.SCO_CommanderEnhancementClientRequestHandler = SCOClientRequest

    local function SCOEmitOwnerState(clientID, snapshot)
        if not SCOInteger(clientID, 0, 2147483647)
            or type(snapshot) ~= "table"
        then
            return false
        end
        local ok = pcall(
            SCOGenericHostSend,
            "SCOCommanderEnhancementState",
            snapshot,
            clientID)
        return ok
    end

    local SCOEmitStateDispatcher = _G.SCO_CommanderEnhancementEmitState
    if SCOEmitStateDispatcher ~= nil
        and type(SCOEmitStateDispatcher) ~= "function"
    then
        error("SCOM commander-enhancement state emitter is occupied")
    end
    if SCOEmitStateDispatcher == nil then
        SCOEmitStateDispatcher = function(clientID, snapshot)
            local handler = _G.SCO_CommanderEnhancementEmitStateHandler
            if type(handler) ~= "function" then return false end
            return handler(clientID, snapshot)
        end
        _G.SCO_CommanderEnhancementEmitState = SCOEmitStateDispatcher
    end
    _G.SCO_CommanderEnhancementEmitStateHandler = SCOEmitOwnerState

    local function SCOEmitVisualState(clientID, snapshot)
        if not SCOInteger(clientID, 0, 2147483647)
            or type(snapshot) ~= "table"
        then
            return false
        end
        local ok = pcall(
            SCOGenericHostSend,
            "SCOCommanderEnhancementVisualState",
            snapshot,
            clientID)
        return ok
    end

    local SCOEmitVisualDispatcher =
        _G.SCO_CommanderEnhancementEmitVisualState
    if SCOEmitVisualDispatcher ~= nil
        and type(SCOEmitVisualDispatcher) ~= "function"
    then
        error("SCOM commander-enhancement visual emitter is occupied")
    end
    if SCOEmitVisualDispatcher == nil then
        SCOEmitVisualDispatcher = function(clientID, snapshot)
            local handler =
                _G.SCO_CommanderEnhancementEmitVisualStateHandler
            if type(handler) ~= "function" then return false end
            return handler(clientID, snapshot)
        end
        _G.SCO_CommanderEnhancementEmitVisualState =
            SCOEmitVisualDispatcher
    end
    _G.SCO_CommanderEnhancementEmitVisualStateHandler =
        SCOEmitVisualState

    rawset(
        SCOCommanderEnhancementCommandsEnvironment,
        "SCO_CommanderEnhancementCommandsInstalled",
        "1.2.0")
end

-- Supreme Commander Overhaul commander ability commands 1.0.0
-- Load after commander_enhancement_commands_appendix.lua. This extends the
-- existing authenticated generic-RPC boundary without allocating command IDs.
local SCOCommanderAbilityCommandsEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderAbilityCommandsMarker = rawget(
    SCOCommanderAbilityCommandsEnvironment,
    "SCO_CommanderAbilityCommandsInstalled")
if SCOCommanderAbilityCommandsMarker ~= nil
    and SCOCommanderAbilityCommandsMarker ~= "1.0.0"
then
    error("Unsupported SCOM commander-ability commands marker "
        .. tostring(SCOCommanderAbilityCommandsMarker))
end

if SCOCommanderAbilityCommandsMarker == nil then
        if rawget(
            SCOCommanderAbilityCommandsEnvironment,
            "SCO_CommanderEnhancementCommandsInstalled") ~= "1.2.0"
    then
        error("SCOM commander abilities require enhancement commands 1.2.0")
    end

    local SCOGenericCommand = ExecuteHostFunction
    if type(SCOGenericCommand) ~= "table"
        or type(SCOGenericCommand.Send) ~= "function"
        or type(SCOGenericCommand.Receive) ~= "function"
        or type(json) ~= "table"
        or type(json.decode) ~= "function"
    then
        error("SCOM commander abilities could not resolve generic RPC contracts")
    end

    local SCOPreviousGenericHostReceive = SCOGenericCommand.Receive
    local function SCOGenericClientSend(name, data)
        return SCOGenericCommand.Send(name, data)
    end
    local SCOMaxEncodedRequestBytes = 1536
    local SCORpcByAction = {
        Overcharge = "SCOCommanderAbilityOvercharge",
        MissileBuild = "SCOCommanderAbilityMissileBuild",
        MissileBuildCancel = "SCOCommanderAbilityMissileBuildCancel",
        MissileLaunch = "SCOCommanderAbilityMissileLaunch",
        Teleport = "SCOCommanderAbilityTeleport",
        TeleportCancel = "SCOCommanderAbilityTeleportCancel",
        CloakToggle = "SCOCommanderAbilityCloakToggle",
        AbilityCancel = "SCOCommanderAbilityCancel",
    }
    local SCOActionByRpc = {}
    for action, rpcName in pairs(SCORpcByAction) do
        SCOActionByRpc[rpcName] = action
    end

    local SCOTargetActions = {
        Overcharge = true,
        MissileLaunch = true,
        Teleport = true,
    }

    local function SCOFinite(value)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    local function SCOInteger(value, minimum, maximum)
        return SCOFinite(value)
            and value == math.floor(value)
            and value >= minimum
            and value <= maximum
    end

    local function SCOGlobalId(value)
        if type(value) ~= "table"
            or not SCOInteger(value.index, 1, 2147483647)
            or not SCOInteger(value.version, 0, 2147483647)
        then
            return nil
        end
        return { index = value.index, version = value.version }
    end

    local function SCOPosition(value)
        if type(value) ~= "table"
            or not SCOFinite(value.x)
            or not SCOFinite(value.y)
            or not SCOFinite(value.z)
            or math.abs(value.x) > 1000000
            or math.abs(value.y) > 1000000
            or math.abs(value.z) > 1000000
        then
            return nil
        end
        return { x = value.x, y = value.y, z = value.z }
    end

    local function SCOHasExactKeys(value, allowed, expectedCount)
        if type(value) ~= "table" then return false end
        local count = 0
        for key in pairs(value) do
            if not allowed[key] then return false end
            count = count + 1
        end
        return count == expectedCount
    end

    local function SCOCanonicalRequest(action, value)
        local needsTarget = SCOTargetActions[action] == true
        local allowed = needsTarget
            and { unitId = true, target = true }
            or { unitId = true }
        if not SCOHasExactKeys(value, allowed, needsTarget and 2 or 1) then
            return nil
        end
        local unitId = SCOGlobalId(value.unitId)
        if unitId == nil then return nil end
        local result = { unitId = unitId }
        if needsTarget then
            if action == "Overcharge" then
                if not SCOHasExactKeys(value.target, { index = true, version = true }, 2) then
                    return nil
                end
                result.target = SCOGlobalId(value.target)
            else
                result.target = SCOPosition(value.target)
            end
            if result.target == nil then return nil end
        end
        return result
    end

    local function SCOHostFunction(action)
        local nameByAction = {
            Overcharge = "SCO_CommanderAbilityHostOvercharge",
            MissileBuild = "SCO_CommanderAbilityHostBuildMissile",
            MissileBuildCancel = "SCO_CommanderAbilityHostCancelMissile",
            MissileLaunch = "SCO_CommanderAbilityHostLaunchMissile",
            Teleport = "SCO_CommanderAbilityHostTeleport",
            TeleportCancel = "SCO_CommanderAbilityHostCancelTeleport",
            CloakToggle = "SCO_CommanderAbilityHostToggleCloak",
            AbilityCancel = "SCO_CommanderAbilityHostCancel",
        }
        return rawget(_G, nameByAction[action])
    end

    local function SCORepublishState(clientID, unitId)
        local getter = rawget(_G, "SCO_CommanderEnhancementHostGetState")
        local emitter = rawget(_G, "SCO_CommanderEnhancementEmitState")
        if type(getter) ~= "function" or type(emitter) ~= "function" then
            return false
        end
        local ok, snapshot = pcall(getter, clientID, unitId)
        if not ok or type(snapshot) ~= "table" then return false end
        local sent, result = pcall(emitter, clientID, snapshot)
        return sent and result == true
    end

    local function SCOReceiveAbilityRpc(command, action, request)
        if not SCOInteger(command.clientID, 0, 2147483647) then return false end
        local handler = SCOHostFunction(action)
        if type(handler) ~= "function" then return false end
        local ok, accepted
        if SCOTargetActions[action] then
            ok, accepted = pcall(
                handler,
                command.clientID,
                request.unitId,
                request.target)
        else
            ok, accepted = pcall(handler, command.clientID, request.unitId)
        end
        if not ok or accepted ~= true then
            SCORepublishState(command.clientID, request.unitId)
            return false
        end
        return true
    end

    local function SCOAuthenticatedAbilityHostReceive(data, command)
        if type(data) ~= "table"
            or type(command) ~= "table"
            or type(data.call) ~= "string"
        then
            return false
        end
        local decoded, envelope = pcall(json.decode, data.call)
        if not decoded or type(envelope) ~= "table" then return false end
        local action = SCOActionByRpc[envelope.functionName]
        if not action then return SCOPreviousGenericHostReceive(data, command) end
        if #data.call > SCOMaxEncodedRequestBytes then return false end
        if not SCOHasExactKeys(
            envelope,
            { functionName = true, functionData = true },
            2)
        then
            return false
        end
        local request = SCOCanonicalRequest(action, envelope.functionData)
        if request == nil then return false end
        return SCOReceiveAbilityRpc(command, action, request)
    end

    SCOGenericCommand.Receive = SCOAuthenticatedAbilityHostReceive

    local function SCOClientRequest(action, unitId, target)
        local rpcName = SCORpcByAction[action]
        local canonicalUnitId = SCOGlobalId(unitId)
        if not rpcName or not canonicalUnitId then return false end
        if type(IsObserver) == "function" and IsObserver() then return false end
        local payload = { unitId = canonicalUnitId }
        if SCOTargetActions[action] then
            if action == "Overcharge" then
                payload.target = SCOGlobalId(target)
            else
                payload.target = SCOPosition(target)
            end
            if payload.target == nil then return false end
        elseif target ~= nil then
            return false
        end
        local ok = pcall(SCOGenericClientSend, rpcName, payload)
        return ok
    end

    local dispatcher = rawget(_G, "SCO_CommanderAbilityClientRequest")
    if dispatcher ~= nil and type(dispatcher) ~= "function" then
        error("SCOM commander-ability client request dispatcher is occupied")
    end
    if dispatcher == nil then
        dispatcher = function(action, unitId, target)
            local handler = rawget(
                _G,
                "SCO_CommanderAbilityClientRequestHandler")
            if type(handler) ~= "function" then return false end
            return handler(action, unitId, target)
        end
        _G.SCO_CommanderAbilityClientRequest = dispatcher
    end
    local previousHandler = rawget(
        _G,
        "SCO_CommanderAbilityClientRequestHandler")
    if previousHandler ~= nil and type(previousHandler) ~= "function" then
        error("SCOM commander-ability client request handler is occupied")
    end
    _G.SCO_CommanderAbilityClientRequestHandler = SCOClientRequest

    rawset(
        SCOCommanderAbilityCommandsEnvironment,
        "SCO_CommanderAbilityCommandsInstalled",
        "1.0.0")
end
