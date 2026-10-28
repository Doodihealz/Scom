end
-- SCOM Field Fix: direct Creative nuclear-structure host boundary 1.0.0
local SCOFieldFixCreativeHostEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOFieldFixCreativeHostMarker = rawget(
    SCOFieldFixCreativeHostEnvironment,
    "SCO_FieldFixCreativeHostListenerInstalled")
if SCOFieldFixCreativeHostMarker ~= nil
    and SCOFieldFixCreativeHostMarker ~= "1.0.0"
then
    error("Unsupported SCOM Creative host-listener marker "
        .. tostring(SCOFieldFixCreativeHostMarker))
end
if SCOFieldFixCreativeHostMarker == nil then
    if type(functions) ~= "table"
        or type(functions.TestUtilities) ~= "function"
        or (functions.CreativeMode ~= nil
            and type(functions.CreativeMode) ~= "function")
    then
        error("SCOM Creative host bridge could not resolve Creative handlers")
    end

    local SCOFieldFixCreativeMode = functions.CreativeMode
    local SCOFieldFixTestUtilities = functions.TestUtilities
    local SCOCreativeNuclearStructures = {
        ucs3102 = true,
        ues3102 = true,
        ugs3102 = true,
        ugs5007 = true,
        uss3102 = true,
        uss4102 = true,
    }

    local function SCOCreativeRequestedTpId(route, data)
        if route == "CreativeMode" and type(data) == "table" then
            return data.engineTpId
        end
        if route == "TestUtilities"
            and type(data) == "table"
            and data.fn == "SpawnUnits"
            and type(data.args) == "table"
            and type(data.args[1]) == "table"
        then
            return data.args[1].engineTpId
        end
        return nil
    end

    local function SCORunCreativeHandler(route, handler, data)
        local tpId = SCOCreativeRequestedTpId(route, data)
        if not SCOCreativeNuclearStructures[tpId] then
            return handler(data)
        end

        -- Wrap the actual host listener, not only TestUtilities.SpawnUnits.
        -- Creative Mode may capture its spawn callback before another module
        -- can decorate it; this boundary still encloses synchronous CreateUnit.
        local previousContext = _G.SCO_FieldFixCreativeSpawnContext
        _G.SCO_FieldFixCreativeSpawnContext = "1.0.0"
        if type(Log) == "function" then
            Log("[SCOM Strategic Silo] Creative request: route="
                .. route .. " tp=" .. tpId .. " context=1.0.0")
        end
        local ok, result = pcall(handler, data)
        _G.SCO_FieldFixCreativeSpawnContext = previousContext
        if not ok then
            error(result, 0)
        end
        return result
    end

    if SCOFieldFixCreativeMode then
        function functions.CreativeMode(data)
            return SCORunCreativeHandler(
                "CreativeMode", SCOFieldFixCreativeMode, data)
        end
    end

    function functions.TestUtilities(data)
        return SCORunCreativeHandler(
            "TestUtilities", SCOFieldFixTestUtilities, data)
    end

    rawset(
        SCOFieldFixCreativeHostEnvironment,
        "SCO_FieldFixCreativeHostListenerInstalled",
        "1.0.0")
    _G.SCO_FieldFixCreativeHostListenerInstalled = "1.0.0"
    _G.SCO_FieldFixCreativeHostListenerVersion = "1.0.0"
end
-- SCOM factory rally visibility host snapshot 1.0.0
function functions.FactoryRallySnapshot(data)
    if type(data) ~= "table" then
        return
    end
    local index, version = data.unitIndex, data.unitVersion
    if type(index) ~= "number" or type(version) ~= "number"
        or index < 0 or version < 0 or index ~= math.floor(index) or version ~= math.floor(version) then
        return
    end

    local unit = GetUnitById(EngineClasses.GlobalID(index, version))
    if unit ~= nil and not unit.dead and unit.id.index == index and unit.id.version == version and unit:IsFactory() then
        Import("host/units/unitsClasses/unitsDefault.lua").PublishFactoryRally(unit)
    end
end
