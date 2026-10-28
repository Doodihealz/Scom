_G.buildQueueUtils = {}

---@class BuildQueueItem
---@field tpId string Template of the units this item builds.
---@field entryIds integer[] One id per queued unit, in build order.

---@alias BuildQueueOwner HostStructure|ClientUnit|PredictedUnit

---@param unit ClientUnit|PredictedUnit
---@return string tpId The highest tech template in the predicted queue, or the unit's own template if none is higher.
---@return integer techNumber Tech level of that template.
function buildQueueUtils.GetHighestQueuedUpgradeTemplateId(unit)
    local highestTpId = unit.tp.general.tpId
    local highestTier = unit.tp.general.techNumber
    local upgradeTemplate = unit.tp

    for _, item in ipairs(unit.predictedBuildQueue) do
        local template = __Templates.Units[item.tpId]
        local tier = template.general.techNumber
        local construction = upgradeTemplate.construction
        local isNextUpgrade = construction
            and construction.upgradesTo == item.tpId
            and upgradeTemplate.general.tpId ~= item.tpId
        if isNextUpgrade then
            upgradeTemplate = template
        end
        if tier > highestTier or (isNextUpgrade and tier == highestTier) then
            highestTier = tier
            highestTpId = item.tpId
        end
    end

    return highestTpId, highestTier
end

---@param unit ClientUnit|PredictedUnit
---@return table<string, boolean> tags What the unit can build once its queued upgrades finish.
function buildQueueUtils.GetBuildableTags(unit)
    local highestQueuedTemplateId = buildQueueUtils.GetHighestQueuedUpgradeTemplateId(unit)
    local construction = __Templates.Units[highestQueuedTemplateId].construction
    if not construction or not construction.canBuild then
        return {}
    end
    return ParseTagsFromString(construction.canBuild)
end

--- Last id handed out by NewEntryIds. The host starts at a large value so its ids never collide with the ids clients hand out, which start at 0
---@type integer
buildQueueUtils.lastEntryId = IsHost and 1073741823 or 0

---Returns count new entry ids, one for each unit about to be queued
---@param count integer
---@return integer[] entryIds
function buildQueueUtils.NewEntryIds(count)
    local entryIds = {}
    for entryIndex = 1, count do
        buildQueueUtils.lastEntryId = buildQueueUtils.lastEntryId + 1
        entryIds[entryIndex] = buildQueueUtils.lastEntryId
    end
    return entryIds
end

---Returns the index of the item holding entryId and the entry's index within it, or nil if no item holds it
---@param buildQueue BuildQueueItem[]
---@param entryId integer?
---@return integer? itemIndex
---@return integer? entryIndex
function buildQueueUtils.FindEntry(buildQueue, entryId)
    for itemIndex, item in ipairs(buildQueue) do
        for entryIndex, itemEntryId in ipairs(item.entryIds) do
            if itemEntryId == entryId then
                return itemIndex, entryIndex
            end
        end
    end
end

---Adds one entry per id in entryIds to the end of the item holding targetItemEntryId,
---or to a new item of tpId at the back of the queue if no item holds it.
---Returns true if the entries are still queued after cleanup.
---@param unit BuildQueueOwner
---@param tpId string
---@param entryIds integer[] New ids from NewEntryIds, one per unit to queue.
---@param targetItemEntryId integer? An id in the item to add to. 0 or nil adds to the back of the queue.
---@param isPredicted boolean? True to edit the client's predicted queue instead of the unit's build queue.
---@return boolean isQueued
function buildQueueUtils.AddToBuildQueue(unit, tpId, entryIds, targetItemEntryId, isPredicted)
    local buildQueue = isPredicted and unit.predictedBuildQueue or unit.buildQueue

    local itemIndex = buildQueueUtils.FindEntry(buildQueue, targetItemEntryId)
    if not itemIndex then
        table.insert(buildQueue, {tpId = tpId, entryIds = {}})
        itemIndex = #buildQueue
    end

    local itemEntryIds = buildQueue[itemIndex].entryIds
    for _, entryId in ipairs(entryIds) do
        table.insert(itemEntryIds, entryId)
    end

    buildQueueUtils.CleanUpAndMergeQueueItems(unit, isPredicted)

    local isQueued = buildQueueUtils.FindEntry(buildQueue, entryIds[1]) ~= nil

    if IsHost then
        unit:SendUpdateBuildQueueCommand()
    end

    return isQueued
end

---Removes the entries with the given ids wherever they are in the queue.
---Ids no item holds are skipped, their units were already built or removed.
---Cancels the unit under construction if needed.
---@param unit BuildQueueOwner
---@param entryIds integer[]
---@param isPredicted boolean? True to edit the client's predicted queue instead of the unit's build queue.
function buildQueueUtils.RemoveFromBuildQueue(unit, entryIds, isPredicted)
    local buildQueue = isPredicted and unit.predictedBuildQueue or unit.buildQueue

    local firstQueueItem = buildQueue[1]
    for _, entryId in ipairs(entryIds) do
        local itemIndex, entryIndex = buildQueueUtils.FindEntry(buildQueue, entryId)
        if itemIndex then
            local itemEntryIds = buildQueue[itemIndex].entryIds
            table.remove(itemEntryIds, entryIndex)
            if not itemEntryIds[1] then
                table.remove(buildQueue, itemIndex)
            end
        end
    end

    if firstQueueItem and firstQueueItem ~= buildQueue[1] and unit.OnCancelConstruction then
        unit:OnCancelConstruction()
    end

    buildQueueUtils.CleanUpAndMergeQueueItems(unit, isPredicted)

    if IsHost then
        unit:SendUpdateBuildQueueCommand()
    end
end

---@param unit BuildQueueOwner
---@param isPredicted boolean? True to clean the client's predicted queue instead of the unit's build queue.
function buildQueueUtils.CleanUpAndMergeQueueItems(unit, isPredicted)
    local buildQueue = isPredicted and unit.predictedBuildQueue or unit.buildQueue

    -- Remove all items from the build queue that can't be built, happens when we cancel a factory upgrade
    local i = 1
    while i <= #buildQueue do
        if not buildQueueUtils.CanBuild(unit, buildQueue[i].tpId, i, isPredicted) then
            table.remove(buildQueue, i)
        else
            i = i + 1
        end
    end

    -- Upgrades can only be queued once
    local upgradesToTemplate = unit.tp.construction.upgradesTo
    if upgradesToTemplate then
        local alreadyHasUpgrade = false
        i = 1
        while i <= #buildQueue do
            local item = buildQueue[i]
            if item.tpId == upgradesToTemplate then
                item.entryIds = {item.entryIds[1]} -- Upgrades can only be queued once
                if alreadyHasUpgrade then
                    table.remove(buildQueue, i)
                else
                    alreadyHasUpgrade = true
                    i = i + 1
                end
            else
                i = i + 1
            end
        end
    end

    -- Merge adjacent items with the same tpId
    i = 1
    while i < #buildQueue do
        local current = buildQueue[i]
        local nextItem = buildQueue[i + 1]
        if current.tpId == nextItem.tpId then
            -- Merge the entryIds from the next item into the current one
            for _, entryId in ipairs(nextItem.entryIds) do
                table.insert(current.entryIds, entryId)
            end
            table.remove(buildQueue, i + 1)
            -- Stay at the same index in case there are more adjacent items with same tpId
        else
            i = i + 1
        end
    end
end

---@param unit HostUnit|ClientUnit|PredictedUnit A unit that can construct.
---@param tpId string
---@param maxIndex integer? Only queued items before this position can enable tpId. Defaults to the whole queue.
---@param isPredicted boolean? True to read the client's predicted queue instead of the unit's build queue.
---@return boolean? canBuild
function buildQueueUtils.CanBuild(unit, tpId, maxIndex, isPredicted)

    -- Unit must be able to construct.
    assert(unit.tp.construction.canBuild)

    local buildQueue = isPredicted and unit.predictedBuildQueue or unit.buildQueue
    local currentTierTags = ParseTagsFromString(unit.tp.construction.canBuild)
    
    if not maxIndex then
        maxIndex = #buildQueue
    end

    -- Iterate through the queue up until (maxIndex - 1)
    -- This ensures future upgrades don't validate items appearing before them during CleanUpAndMergeQueueItems
    for i = 1, maxIndex - 1 do
        local item = buildQueue[i]
        local templateConstruction = __Templates.Units[item.tpId].construction
        if Tags.STRUCTURE[item.tpId] and templateConstruction and templateConstruction.canBuild and ParseTagsFromString(templateConstruction.canBuild)[tpId] then
            return true
        end
    end

    return currentTierTags[tpId]
end

-- Supreme Commander Overhaul commander enhancements 1.0.0
-- Engineering suites extend only the queried per-unit build expression. The
-- immutable unit template, its canBuild string, and global Tags remain intact.
local SCOCommanderEnhancementBuildQueueEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderEnhancementBuildQueueMarker = rawget(
    SCOCommanderEnhancementBuildQueueEnvironment,
    "SCO_CommanderEnhancementBuildQueueInstalled")
if SCOCommanderEnhancementBuildQueueMarker ~= nil
    and SCOCommanderEnhancementBuildQueueMarker ~= "1.0.2"
then
    error("Unsupported SCOM commander-enhancement build-queue marker "
        .. tostring(SCOCommanderEnhancementBuildQueueMarker))
end
if SCOCommanderEnhancementBuildQueueMarker == nil then
    local SCOBuildQueueUtils = rawget(_G, "buildQueueUtils")
    if type(SCOBuildQueueUtils) ~= "table"
        or type(SCOBuildQueueUtils.GetBuildableTags) ~= "function"
        or type(SCOBuildQueueUtils.CanBuild) ~= "function"
    then
        error("SCOM commander enhancements could not resolve build-queue module exports")
    end

    local SCOPreviousGetBuildableTags = SCOBuildQueueUtils.GetBuildableTags
    local SCOPreviousCanBuild = SCOBuildQueueUtils.CanBuild
    local SCOFactionTagByCommander = {
        uel0000 = "EDA",
        ugl0000 = "GUARD",
        ucl0000 = "CHOSEN",
        usl0000 = "SERAPHIM",
    }
    local SCOBuildTagByTier = {
        "BUILDABLE_BY_T1_ENGINEER",
        "BUILDABLE_BY_T2_ENGINEER",
        "BUILDABLE_BY_T3_ENGINEER",
    }

    local function SCOUnitTpId(unit)
        return unit and (unit.tpId
            or (unit.tp and unit.tp.general and unit.tp.general.tpId))
    end

    local function SCOState(unit)
        if IsHost then
            return unit and unit.scoCommanderEnhancements
        end
        local getter = _G.SCO_GetCommanderEnhancementClientState
        return type(getter) == "function" and getter(unit) or nil
    end

    local function SCOCommanderContract(tpId)
        local contract = _G.SCO_CommanderEnhancementContract
        local commanders = type(contract) == "table" and contract.commanders
        local commander = type(commanders) == "table" and commanders[tpId]
        if type(commander) ~= "table"
            or type(commander.enhancements) ~= "table"
        then
            return nil
        end
        return commander
    end

    local function SCOEngineeringEffect(rule)
        local engineering = type(rule.effects) == "table"
            and rule.effects.engineering
        if type(engineering) ~= "table" then return nil end
        if type(engineering.tier) == "number" then return engineering end
        for _, effect in pairs(engineering) do
            if type(effect) == "table" and type(effect.tier) == "number" then
                return effect
            end
        end
        return nil
    end

    local function SCOInstalledEngineeringTier(unit)
        local tpId = SCOUnitTpId(unit)
        local commander = SCOCommanderContract(tpId)
        local state = SCOState(unit)
        if not commander
            or type(state) ~= "table"
            or state.version ~= "1.0.0"
            or type(state.installed) ~= "table"
            or type(state.capabilities) ~= "table"
        then
            return nil
        end

        local highestTier = 1
        for enhancementId, installed in pairs(state.installed) do
            if installed ~= true then return nil end
            local rule = commander.enhancements[enhancementId]
            if type(rule) ~= "table" then return nil end
            local engineering = SCOEngineeringEffect(rule)
            if engineering ~= nil then
                local tier = engineering.tier
                local expectedTag = SCOBuildTagByTier[tier]
                if tier ~= math.floor(tier)
                    or expectedTag == nil
                    or engineering.sanctuaryBuildTag ~= expectedTag
                then
                    return nil
                end
                highestTier = math.max(highestTier, tier)
            end
        end
        if state.capabilities.engineeringTier ~= highestTier then
            return nil
        end
        return highestTier
    end

    local function SCOEngineeringBuildTags(unit)
        local tpId = SCOUnitTpId(unit)
        local factionTagName = SCOFactionTagByCommander[tpId]
        local highestTier = factionTagName
            and SCOInstalledEngineeringTier(unit)
        if not highestTier then return nil end

        -- script.lua imports buildQueueUtils six entries before tags.lua. Resolve
        -- the global at call time, after template/tag publication, rather than
        -- rejecting both Lua states during this module's import.
        local tags = rawget(_G, "Tags")
        if type(tags) ~= "table" then return nil end
        local factionTags = tags[factionTagName]
        if type(factionTags) ~= "table" then return nil end
        local result = nil
        for tier = 1, highestTier do
            local buildTags = tags[SCOBuildTagByTier[tier]]
            if type(buildTags) ~= "table" then return nil end
            local tierTags = factionTags * buildTags
            result = result and (result + tierTags) or tierTags
        end
        return result
    end

    SCOBuildQueueUtils.GetBuildableTags = function(unit)
        local baseTags = SCOPreviousGetBuildableTags(unit)
        local engineeringTags = SCOEngineeringBuildTags(unit)
        if engineeringTags == nil then return baseTags end
        return baseTags + engineeringTags
    end

    SCOBuildQueueUtils.CanBuild = function(unit, tpId, maxIndex, isPredicted)
        if SCOPreviousCanBuild(unit, tpId, maxIndex, isPredicted) then
            return true
        end
        local engineeringTags = SCOEngineeringBuildTags(unit)
        return engineeringTags ~= nil and engineeringTags[tpId] == true
    end

    -- Keep upgraded ACU options under the same domain as ordinary builders.
    -- Resolve Tags lazily: this module loads before the native tag index.
    local function SCOUsesPortedBuildDomain(unit)
        local tags = unit and unit.tp and unit.tp.hasTags
        return tags and not tags.PROMETHEAN
            and (tags.EDA or tags.CHOSEN or tags.GUARD or tags.SERAPHIM)
    end
    -- Hives are engineer-built stations, never land-factory products. Apply the
    -- same restriction to the displayed choices and native queue validation.
    local SCOHiveTemplates = { ugs2501 = true, ugs5026 = true, ugs3501 = true }
    local SCOLandFactories = { ugs1511 = true, ugs2511 = true, ugs3511 = true }
    local function SCOIsFactoryHive(unit, tpId)
        return SCOLandFactories[SCOUnitTpId(unit)] and SCOHiveTemplates[tpId]
    end

    local SCOEnhancedGetBuildableTags = SCOBuildQueueUtils.GetBuildableTags
    local SCOEnhancedCanBuild = SCOBuildQueueUtils.CanBuild
    SCOBuildQueueUtils.GetBuildableTags = function(unit)
        local result = SCOEnhancedGetBuildableTags(unit)
        if not SCOUsesPortedBuildDomain(unit) then return result end
        local allowed = assert(Tags.SCFA_ALLUNITS, 'SCOM build-domain tag is missing')
        local filtered = allowed - allowed
        for tpId in pairs(result) do
            if allowed[tpId] and not SCOIsFactoryHive(unit, tpId) then
                filtered[tpId] = true
            end
        end
        return filtered
    end
    SCOBuildQueueUtils.CanBuild = function(unit, tpId, maxIndex, isPredicted)
        if SCOIsFactoryHive(unit, tpId) then return false end
        if SCOUsesPortedBuildDomain(unit) and not Tags.SCFA_ALLUNITS[tpId] then
            return false
        end
        return SCOEnhancedCanBuild(unit, tpId, maxIndex, isPredicted)
    end

    rawset(
        SCOCommanderEnhancementBuildQueueEnvironment,
        "SCO_CommanderEnhancementBuildQueueInstalled",
        "1.0.2")
end
-- Hydrocarbons remain spawnable but never enter a unit's construction options.
local SourceHydro=Import("common/systems/scoSourceHydroPlacement.lua")
local PreviousHydroBuildableTags=buildQueueUtils.GetBuildableTags
local PreviousHydroCanBuild=buildQueueUtils.CanBuild

function buildQueueUtils.GetBuildableTags(unit)
    local result=PreviousHydroBuildableTags(unit)
    -- Parsed tag expressions are shared caches; never remove entries in place.
    local filtered=setmetatable({},getmetatable(result))
    for tpId,value in pairs(result) do
        if SourceHydro.CanBuildNormally(tpId) then filtered[tpId]=value end
    end
    return filtered
end

function buildQueueUtils.CanBuild(unit,tpId,maxIndex,isPredicted)
    if not SourceHydro.CanBuildNormally(tpId) then return false end
    return PreviousHydroCanBuild(unit,tpId,maxIndex,isPredicted)
end
