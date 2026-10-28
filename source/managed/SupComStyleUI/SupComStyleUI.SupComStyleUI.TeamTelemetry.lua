local GLOBAL_NAME = "__SupComStyleUITeamTelemetry"
local VERSION = 2
local MAX_SAFE_INTEGER = 9007199254740991
local MAX_STRENGTH = 1000000000000
local ALLOY_STRENGTH_DIVISOR = 10
local FACTORY_STRENGTH_MULTIPLIER = 1.2
local COMMAND_STRENGTH = 50

local existing = rawget(_G, GLOBAL_NAME)
if type(existing) == "table"
    and existing.version == VERSION
    and type(existing.EnsureWrapped) == "function"
    and type(existing.SampleTsv) == "function" then
    existing.active = true
    existing.EnsureWrapped()
    return existing
end

if type(existing) == "table" and type(existing.Cleanup) == "function" then
    pcall(existing.Cleanup)
end

local bridge = {
    version = VERSION,
    active = true,
    firesByArmy = {},
    fireMuzzleOwner = nil,
    originalFireMuzzle = nil,
    fireMuzzleWrapper = nil,
}

local function isFinite(value)
    return type(value) == "number"
        and value == value
        and value ~= math.huge
        and value ~= -math.huge
end

local function clamp01(value)
    if not isFinite(value) or value <= 0 then
        return 0
    end
    if value >= 1 then
        return 1
    end
    return value
end

local function sanitizeText(value, maximumLength)
    local valueType = type(value)
    if valueType ~= "string" and valueType ~= "number" then
        return ""
    end

    local text = tostring(value)
    text = string.gsub(text, "[%c]", " ")
    text = string.gsub(text, "%s+", " ")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    if string.len(text) > maximumLength then
        text = string.sub(text, 1, maximumLength)
    end
    return text
end

local function sanitizeKeyToken(value)
    local text = sanitizeText(value, 40)
    text = string.gsub(text, "[^%w_.%-]", "_")
    text = string.gsub(text, "_+", "_")
    if text == "" then
        return nil
    end
    return text
end

local function safeMethodNumber(object, methodName)
    if type(object) ~= "table" then
        return nil
    end
    local method = object[methodName]
    if type(method) ~= "function" then
        return nil
    end
    local success, value = pcall(method, object)
    if success and isFinite(value) then
        return value
    end
    return nil
end

local function safeMethodBoolean(object, methodName)
    if type(object) ~= "table" then
        return false
    end
    local method = object[methodName]
    if type(method) ~= "function" then
        return false
    end
    local success, value = pcall(method, object)
    return success and value == true
end

local function canObserveUnit(unit)
    local isObserver = rawget(_G, "IsObserver")
    if type(isObserver) == "function" then
        local success, observer = pcall(isObserver)
        if success and observer == true then
            return true
        end
    end
    if safeMethodBoolean(unit, "IsOwnedOrAlly") then
        return true
    end
    return safeMethodBoolean(unit, "IsIntelVisionVisible")
end

local function hasTag(unitTemplate, wantedTag)
    local tags = type(unitTemplate) == "table" and unitTemplate.tags or nil
    if type(tags) ~= "table" then
        return false
    end
    for _, tag in pairs(tags) do
        if tag == wantedTag then
            return true
        end
    end
    return false
end

local function isPlacementGhost(unit)
    if type(unit.IsPlacementGhost) == "function" then
        local success, result = pcall(unit.IsPlacementGhost, unit)
        if success then
            return result == true
        end
    end
    return isFinite(unit.progress) and unit.progress <= 0
end

local function completionFraction(unit)
    local fraction = safeMethodNumber(unit, "GetFractionComplete")
    if fraction ~= nil then
        return clamp01(fraction)
    end

    local buildTime = unit.tp
        and unit.tp.economy
        and unit.tp.economy.buildTime
    if isFinite(unit.progress) and isFinite(buildTime) and buildTime > 0 then
        return clamp01(unit.progress / buildTime)
    end
    return 0
end

local function healthFraction(unit)
    local health = safeMethodNumber(unit, "GetHealth")
    local maximum = safeMethodNumber(unit, "GetMaxHealth")
    if health == nil or maximum == nil or maximum <= 0 then
        return 0
    end
    return clamp01(health / maximum)
end

local function unitStrength(unit)
    if type(unit) ~= "table"
        or unit.dead == true
        or unit.upgrader ~= nil
        or type(unit.tp) ~= "table"
        or not canObserveUnit(unit)
        or isPlacementGhost(unit) then
        return 0
    end

    local completion = completionFraction(unit)
    local health = healthFraction(unit)
    if completion <= 0 or health <= 0 then
        return 0
    end

    local baseValue
    if hasTag(unit.tp, "COMMAND") then
        baseValue = COMMAND_STRENGTH
    else
        local alloys = unit.tp.economy
            and unit.tp.economy.cost
            and unit.tp.economy.cost.alloys
        if not isFinite(alloys) or alloys <= 0 then
            return 0
        end
        baseValue = alloys / ALLOY_STRENGTH_DIVISOR
        if hasTag(unit.tp, "FACTORY") then
            baseValue = baseValue * FACTORY_STRENGTH_MULTIPLIER
        end
    end

    local strength = baseValue * math.min(completion, health)
    if not isFinite(strength) or strength < 0 then
        return 0
    end
    return strength
end

local function recordFire(muzzleId)
    local muzzles = rawget(_G, "__Muzzles")
    if type(muzzles) ~= "table" or type(muzzleId) ~= "table" then
        return
    end

    local muzzle = muzzles[muzzleId.index]
    local unit = muzzle and muzzle.weapon and muzzle.weapon.unit
    local armyId = unit and unit.armyId
    if armyId == nil or not canObserveUnit(unit) then
        return
    end

    local count = bridge.firesByArmy[armyId]
    if not isFinite(count) or count < 0 then
        count = 0
    end
    if count < MAX_SAFE_INTEGER then
        bridge.firesByArmy[armyId] = count + 1
    end
end

bridge.fireMuzzleWrapper = function(muzzleId, ...)
    if bridge.active then
        pcall(recordFire, muzzleId)
    end
    return bridge.originalFireMuzzle(muzzleId, ...)
end

local function resolveFireMuzzle()
    local importFunction = rawget(_G, "Import")
    if type(importFunction) == "function" then
        local success, unitsUpdate = pcall(importFunction, "client/units/unitsUpdate.lua")
        if success and type(unitsUpdate) == "table" then
            local moduleFunction = rawget(unitsUpdate, "FireMuzzle")
            if type(moduleFunction) == "function" then
                return unitsUpdate, moduleFunction
            end
        end
    end

    local globalFunction = rawget(_G, "FireMuzzle")
    if type(globalFunction) == "function" then
        return _G, globalFunction
    end
    return nil, nil
end

function bridge.EnsureWrapped()
    local owner, current = resolveFireMuzzle()
    if owner == bridge.fireMuzzleOwner and current == bridge.fireMuzzleWrapper then
        return true
    end

    if bridge.originalFireMuzzle == nil then
        if owner == nil then
            return false
        end
        bridge.fireMuzzleOwner = owner
        bridge.originalFireMuzzle = current
        rawset(owner, "FireMuzzle", bridge.fireMuzzleWrapper)
        return true
    end

    if owner == bridge.fireMuzzleOwner and current == bridge.originalFireMuzzle then
        rawset(owner, "FireMuzzle", bridge.fireMuzzleWrapper)
        return true
    end

    -- Another wrapper owns the global now. Do not clobber it or create a cycle.
    return false
end

local function explicitTeam(armyId, army)
    local options = type(army.lobbyOptions) == "table" and army.lobbyOptions or nil
    if options and options.team ~= nil then
        return options.team, options.teamName
    end

    local armyToPlayer = rawget(_G, "ArmyToPlayer")
    local player = type(armyToPlayer) == "table" and armyToPlayer[armyId] or nil
    if type(player) == "table" and player.team ~= nil then
        return player.team, player.teamName
    end
    return nil, nil
end

local function memberName(armyId, army)
    local options = type(army.lobbyOptions) == "table" and army.lobbyOptions or nil
    if options then
        local name = sanitizeText(options.playerName, 64)
        if name ~= "" then
            return name
        end
    end

    local armyToPlayer = rawget(_G, "ArmyToPlayer")
    local player = type(armyToPlayer) == "table" and armyToPlayer[armyId] or nil
    if type(player) == "table" then
        local name = sanitizeText(player.nickname or player.name, 64)
        if name ~= "" then
            return name
        end
    end

    local name = sanitizeText(army.name, 64)
    if name ~= "" then
        return name
    end
    return "Army " .. (sanitizeKeyToken(armyId) or "unknown")
end

local function areAllied(left, right)
    if left.id == right.id then
        return true
    end
    local leftAllies = left.army.allyIDs
    if type(leftAllies) == "table" and leftAllies[right.id] then
        return true
    end
    local rightAllies = right.army.allyIDs
    return type(rightAllies) == "table" and rightAllies[left.id] == true
end

local function collectArmies()
    local result = {}
    local armies = rawget(_G, "Armies")
    if type(armies) ~= "table" then
        return result
    end

    for tableId, army in pairs(armies) do
        local lobbyOptions = type(army) == "table" and army.lobbyOptions or nil
        if type(army) == "table"
            and army.civilian ~= true
            and not (type(lobbyOptions) == "table" and lobbyOptions.isEmptySlot == true) then
            local armyId = army.id
            if armyId == nil then
                armyId = tableId
            end
            local idToken = sanitizeKeyToken(armyId)
            if idToken then
                local teamValue, teamName = explicitTeam(armyId, army)
                result[#result + 1] = {
                    id = armyId,
                    idToken = idToken,
                    army = army,
                    explicitToken = sanitizeKeyToken(teamValue),
                    explicitName = sanitizeText(teamName, 96),
                }
            end
        end
    end

    table.sort(result, function(left, right)
        return left.idToken < right.idToken
    end)
    return result
end

local function resolveTeam(entry, entries)
    if entry.explicitToken then
        return "team:" .. entry.explicitToken, entry.explicitToken, entry.explicitName
    end

    local alliedExplicitToken = nil
    local alliedExplicitName = ""
    for _, other in ipairs(entries) do
        if other.explicitToken and areAllied(entry, other) then
            if alliedExplicitToken == nil or other.explicitToken < alliedExplicitToken then
                alliedExplicitToken = other.explicitToken
                alliedExplicitName = other.explicitName
            end
        end
    end
    if alliedExplicitToken then
        return "team:" .. alliedExplicitToken, alliedExplicitToken, alliedExplicitName
    end

    local representative = entry.idToken
    for _, other in ipairs(entries) do
        if areAllied(entry, other) and other.idToken < representative then
            representative = other.idToken
        end
    end
    return "alliance:" .. representative, nil, ""
end

local function addMemberName(team, name)
    if name == "" or team.memberNameSet[name] then
        return
    end
    team.memberNameSet[name] = true
    team.memberNames[#team.memberNames + 1] = name
end

local function teamDisplayName(team)
    if team.explicitName ~= "" then
        return team.explicitName
    end

    table.sort(team.memberNames)
    local members = sanitizeText(table.concat(team.memberNames, " + "), 112)
    if team.explicitToken then
        if #team.memberNames > 1 then
            return sanitizeText("Team " .. team.explicitToken .. ": " .. members, 120)
        end
        if members ~= "" then
            return members
        end
        return sanitizeText("Team " .. team.explicitToken, 120)
    end
    if members ~= "" then
        return members
    end
    return "Unknown team"
end

function bridge.SampleTsv()
    if not bridge.EnsureWrapped() then
        error("FireMuzzle telemetry wrapper is not installed")
    end

    local entries = collectArmies()
    local teamsByKey = {}
    for _, entry in ipairs(entries) do
        local key, explicitToken, explicitName = resolveTeam(entry, entries)
        local team = teamsByKey[key]
        if not team then
            team = {
                key = key,
                explicitToken = explicitToken,
                explicitName = explicitName,
                memberNames = {},
                memberNameSet = {},
                strength = 0,
                fires = 0,
            }
            teamsByKey[key] = team
        elseif team.explicitName == "" and explicitName ~= "" then
            team.explicitName = explicitName
        end

        addMemberName(team, memberName(entry.id, entry.army))

        local units = entry.army.units
        if type(units) == "table" then
            for _, unit in pairs(units) do
                team.strength = team.strength + unitStrength(unit)
            end
        end

        local fires = bridge.firesByArmy[entry.id]
        if isFinite(fires) and fires > 0 then
            team.fires = team.fires + math.floor(fires)
        end
    end

    local teams = {}
    for _, team in pairs(teamsByKey) do
        if not isFinite(team.strength) or team.strength < 0 or team.strength > MAX_STRENGTH then
            error("team strength is outside the supported range")
        end
        if not isFinite(team.fires) or team.fires < 0 or team.fires > MAX_SAFE_INTEGER then
            error("team fire count is outside the supported range")
        end
        teams[#teams + 1] = team
    end

    table.sort(teams, function(left, right)
        return left.key < right.key
    end)

    local rows = {}
    for _, team in ipairs(teams) do
        rows[#rows + 1] = table.concat({
            sanitizeText(team.key, 64),
            teamDisplayName(team),
            string.format("%.6f", team.strength),
            string.format("%.0f", team.fires),
        }, "\t")
    end
    return table.concat(rows, "\n")
end

function bridge.Reset()
    bridge.firesByArmy = {}
    bridge.active = true
    bridge.EnsureWrapped()
end

function bridge.Cleanup()
    bridge.active = false
    if type(bridge.fireMuzzleOwner) == "table"
        and rawget(bridge.fireMuzzleOwner, "FireMuzzle") == bridge.fireMuzzleWrapper then
        rawset(bridge.fireMuzzleOwner, "FireMuzzle", bridge.originalFireMuzzle)
    end
    if rawget(_G, GLOBAL_NAME) == bridge then
        rawset(_G, GLOBAL_NAME, nil)
    end
end

rawset(_G, GLOBAL_NAME, bridge)
bridge.EnsureWrapped()
return bridge
