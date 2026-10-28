-- Missing Seraphim DeathImpact weapons use the native falling wreck actor.
-- No damage occurs when the aircraft is destroyed in mid-air.
local M = {pending = {}}
-- SCOM surface hover units spawn above the terrain; their wrecks must not retain that altitude.
local surfaceHoverUnits = {
    ucl1001 = true, ucl1501 = true, ucl1701 = true, ucl2201 = true,
    ucl2501 = true, ucl2806 = true, ucl3501 = true, ucl4401 = true,
    usl1101 = true, usl1501 = true, usl2201 = true, usl2501 = true,
    usl2806 = true, usl3501 = true, usl4401 = true,
    wal0309 = true, wsl0205 = true, wsl0308 = true,
}

function M.Configure(expected)
    M.expected = expected
end

function M.Attach(unit, wreck)
    local source = unit.tp and unit.tp.additions and unit.tp.additions.scoMissingCrashImpact
    if not source or not wreck then return wreck end
    -- These current aircraft retain their donor's hash-pinned crash contract.
    local aliases = {
        waa0305 = "usa3001", wea0305 = "usa3701", wra0202 = "usa2101",
        wra0303 = "usa3201", wsa0306 = "usa2301",
    }
    local expectedId = unit.tpId
    local donorId = aliases[expectedId]
    if donorId then
        local general = unit.tp.general
        local class = general and general.class
        assert(general and general.tpId == unit.tpId and type(class) == "table"
            and class[1] == "unitsDefaultSeraphim" and class[2] == "SeraphimAirUnit"
            and source.targetId == donorId, "Aircraft alias crash donor identity drift")
        expectedId = donorId
    end
    local expected = assert(M.expected and M.expected[expectedId], "Unscoped source crash impact")
    for key, value in pairs(expected) do
        assert(source[key] == value, "Source crash impact identity drift: " .. key)
    end
    assert(source.damageType == "Normal", "Unsupported source crash damage type")
    local snapshot = {}
    for key, value in pairs(source) do snapshot[key] = value end
    snapshot.army = assert(unit.army)
    snapshot.sourceUnit = unit
    wreck.scoMissingCrashImpact = snapshot
    M.pending[wreck.id.index] = wreck
    return wreck
end

function M.WrapCreateWreckage(previous)
    return function(unit, ...)
        local wreck = previous(unit, ...)
        if wreck and surfaceHoverUnits[unit.tpId] then
            local position = wreck:GetPosition()
            local terrainStatus, terrainHeight = Engine.SampleTerrainHeight(position)
            if terrainStatus == EngineErrorCode.Success and terrainHeight then
                local groundHeight = terrainHeight
                local lod = wreck.tp and wreck.tp.visuals and wreck.tp.visuals.lods and wreck.tp.visuals.lods[1]
                if lod and lod.model then
                    local boundsStatus, center, size = Engine.GetMeshBounds(lod.model)
                    if boundsStatus == EngineErrorCode.Success and center and size then
                        groundHeight = terrainHeight - (center.y - size.y * 0.5)
                    end
                end
                Engine.SetGlobalEntityPosition(wreck.id,
                    EngineClasses.float3(position.x, groundHeight, position.z))
            end
        end
        return M.Attach(unit, wreck)
    end
end

function M.Apply(wreck, position, areaDamage)
    local source = wreck.scoMissingCrashImpact
    if not source or wreck.scoMissingCrashApplied then return end
    if wreck.scoAircraftCrashActive then
        if wreck.deleted or __Entities.Props[wreck.id.index] ~= wreck then return end
        position = wreck.scoAircraftCrashContactPosition
        if not position then return end
    end
    wreck.scoMissingCrashApplied = true
    M.pending[wreck.id.index] = nil
    areaDamage(position, source.damageRadius, source.damage, source.army, source.damageFriendly, source.sourceUnit)
end

function M.Tick(areaDamage)
    local _, water = Engine.HasWater()
    local level
    if water then _, level = Engine.GetWaterLevel() end
    for index, wreck in pairs(M.pending) do
        if wreck.deleted or __Entities.Props[index] ~= wreck then
            M.pending[index] = nil
        elseif wreck.scoAircraftCrashActive then
            M.Apply(wreck, wreck.scoAircraftCrashContactPosition, areaDamage)
        elseif wreck.crashImpactPosition then
            M.Apply(wreck, wreck.crashImpactPosition, areaDamage)
        elseif water then
            local _, position = Engine.GetGlobalEntityWorldPosition(wreck.id)
            if position and position.y <= level then
                local _, ground = Engine.SampleTerrainHeight(position)
                if ground < level then
                    M.Apply(wreck, EngineClasses.float3(position.x, level, position.z), areaDamage)
                end
            end
        end
    end
end

function M.WrapCollisionUpdate(previous, areaDamage)
    return function(...)
        local result = previous(...)
        M.Tick(areaDamage)
        return result
    end
end

-- Native Import returns this module environment; plain Lua loaders keep the return API.
local moduleEnvironment = getfenv(1)
for name, value in pairs(M) do moduleEnvironment[name] = value end
return M
