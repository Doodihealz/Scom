-- SCOM mock Hydro placement provider 2.1.88.6
local policies = {["ucs1614"]={["sourceId"]="UAB1102",["targetId"]="ucs1614",["sourceBlueprint"]={["archive"]="units.scd",["entry"]="units/UAB1102/UAB1102_unit.bp",["sha256"]="226e38c51f687f906d0d30ba449d032223b40eed65aaff7bb8c0607b021f25b6",["bytes"]=5485},["sourceRequirement"]="RULEUBR_OnHydrocarbonDeposit",["normalConstructionSupported"]=true,["reason"]="Mock Hydro uses ordinary native land placement; no deposit is required.",["creativeDirectSpawnPreserved"]=true,["nativeResourceTypes"]={"alloys"},["fallback"]="mock_land_placement"},["ues5015"]={["sourceId"]="UEB1102",["targetId"]="ues5015",["sourceBlueprint"]={["archive"]="units.scd",["entry"]="units/UEB1102/UEB1102_unit.bp",["sha256"]="c881c49165ff33b9644eb62910fad3ed2075fdf732f1fc5dceb028b673f710fc",["bytes"]=5342},["sourceRequirement"]="RULEUBR_OnHydrocarbonDeposit",["normalConstructionSupported"]=true,["reason"]="Mock Hydro uses ordinary native land placement; no deposit is required.",["creativeDirectSpawnPreserved"]=true,["nativeResourceTypes"]={"alloys"},["fallback"]="mock_land_placement"},["ugs5003"]={["sourceId"]="URB1102",["targetId"]="ugs5003",["sourceBlueprint"]={["archive"]="units.scd",["entry"]="units/URB1102/URB1102_unit.bp",["sha256"]="5d744a449a2f1c66a8523324b5f37581b2bea656169fc6c260b7d096316bcd99",["bytes"]=5202},["sourceRequirement"]="RULEUBR_OnHydrocarbonDeposit",["normalConstructionSupported"]=true,["reason"]="Mock Hydro uses ordinary native land placement; no deposit is required.",["creativeDirectSpawnPreserved"]=true,["nativeResourceTypes"]={"alloys"},["fallback"]="mock_land_placement"},["uss1614"]={["sourceId"]="XSB1102",["targetId"]="uss1614",["sourceBlueprint"]={["archive"]="units.scd",["entry"]="units/XSB1102/XSB1102_unit.bp",["sha256"]="3c83b8f1ac1224e0d65768164ff3e9b791e22ca81fa4a3d17a214a2130692473",["bytes"]=5800},["sourceRequirement"]="RULEUBR_OnHydrocarbonDeposit",["normalConstructionSupported"]=true,["reason"]="Mock Hydro uses ordinary native land placement; no deposit is required.",["creativeDirectSpawnPreserved"]=true,["nativeResourceTypes"]={"alloys"},["fallback"]="mock_land_placement"}}
-- The source rule is retained as provenance only. This mock does not fabricate
-- a native resource type or reserve an alloy deposit. Native construction owns
-- terrain, obstruction, faction/builder eligibility, payment, and occupancy.
local M = {}
local function Id(value)
    if type(value) == "table" then
        if type(value.general) == "table" then return value.general.tpId end
        return value.tpId
    end
    if type(value) == "string" then return value end
end
function M.GetPolicy(value)
    return policies[Id(value)]
end
function M.CanBuildNormally(value)
    -- Other units are unaffected; Hydro-specific wrappers delegate to native
    -- routines rather than reporting a fabricated positive placement result.
    return true
end
local function Copy(value, name, id)
    assert(value == nil or type(value) == "table", "SCOM mock Hydro: invalid " .. name .. " (" .. id .. ")")
    local result = {}
    for key, item in pairs(value or {}) do result[key] = item end
    return result
end
function M.PrepareTemplate(tp)
    local id = Id(tp)
    local policy = policies[id]
    if not policy then return end
    assert(type(tp) == "table" and type(tp.tags) == "table", "SCOM mock Hydro: missing template/tags (" .. id .. ")")
    assert(tp.additions == nil or type(tp.additions) == "table", "SCOM mock Hydro: invalid additions (" .. id .. ")")
    local additions = tp.additions or {}
    local fa = Copy(additions.faHydrocarbonPlacement, "faHydrocarbonPlacement", id)
    local sco = Copy(additions.scoHydroPlacement or policy, "scoHydroPlacement", id)
    local seen = {}
    for _, tag in ipairs(tp.tags) do
        assert(type(tag) == "string", "SCOM mock Hydro: non-string tag (" .. id .. ")")
        seen[tag] = true
    end
    fa.sourceRequirement = "hydrocarbon_deposit"
    fa.supported = true
    fa.mock = true
    fa.nativeResourceSupported = false
    fa.fallback = "mock_land_placement"
    sco.normalConstructionSupported = true
    sco.mock = true
    sco.nativeResourceSupported = false
    sco.nativePlacementValidation = true
    sco.creativeDirectSpawnPreserved = true
    sco.fallback = "mock_land_placement"
    sco.reason = "Mock Hydro uses ordinary native land placement; no deposit is required."
    sco.mockPlacementVersion = "2.1.88.6"
    tp.additions = additions
    additions.faHydrocarbonPlacement = fa
    additions.scoHydroPlacement = sco
    for _, tag in ipairs({"BUILDABLE_BY_T1_ENGINEER", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER"}) do
        if not seen[tag] then tp.tags[#tp.tags + 1] = tag; seen[tag] = true end
    end
end
for _, policy in pairs(policies) do
    policy.mock = true
    policy.nativeResourceSupported = false
    policy.nativePlacementValidation = true
    policy.mockPlacementVersion = "2.1.88.6"
end
-- Sanctuary's Import uses the module environment. Preserve that Lua 5.1 API.
local moduleEnvironment = getfenv(1)
for name, value in pairs(M) do moduleEnvironment[name] = value end
return M
