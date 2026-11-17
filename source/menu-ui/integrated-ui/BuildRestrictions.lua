-- The plugin prepends the host's validated set as the local variable disabled.
local queue = buildQueueUtils
local canBuild = assert(queue and queue.CanBuild, "Build queue validation is unavailable")
local getBuildableTags = assert(queue.GetBuildableTags, "Build menu filtering is unavailable")
local templates = assert(__Templates and __Templates.Units, "Unit templates are unavailable")

local function restricted(id)
    if disabled[id] then return true end
    local template = id and templates[id]
    local canonical = template and template.general and template.general.tpId
    return canonical ~= nil and disabled[canonical] == true
end

local function requiredProductRestricted(template)
    local additions = template.additions or {}
    if additions.megalithEgg and restricted(additions.megalithEgg.product) then return true end
    local special = additions.scoSpecial
    if special and special.kind == "novaxLauncher" and restricted(special.child) then return true end
    local pods = additions.scoSourcePods
    if pods and pods.kind == "tower" then
        for _, slot in ipairs(pods.slots) do
            if restricted(slot.template) then return true end
        end
    end
    return false
end

-- Recheck final runtime metadata, including editable definitions and source
-- finalizers. The lobby also expands these links for its display/network mask.
local expanded
repeat
    expanded = false
    for id, template in pairs(templates) do
        if requiredProductRestricted(template) then
            if not disabled[id] then disabled[id] = true; expanded = true end
            local canonical = template.general and template.general.tpId
            if canonical and not disabled[canonical] then disabled[canonical] = true; expanded = true end
        end
    end
until not expanded
local availableUnits, hostOrder, isOrderValid
if IsHost then
    availableUnits = assert(Import("common/units/availableUnits.lua").AvailableUnits, "AI unit catalog is unavailable")
    hostOrder = Import("host/managers/orders/orderClasses/hostBuildOrder.lua").HostBuildOrder
    isOrderValid = assert(hostOrder and hostOrder.IsOrderValid, "Build order validation is unavailable")
end

-- Native tag expressions are cached and often share tag tables. Preserve those tables.
local function withoutDisabled(tags)
    if not tags then return tags end
    for id in pairs(tags) do
        if restricted(id) then
            local filtered = setmetatable({}, getmetatable(tags))
            for candidate, value in pairs(tags) do
                if not restricted(candidate) then filtered[candidate] = value end
            end
            return filtered
        end
    end
    return tags
end

queue.CanBuild = function(unit, id, ...)
    if restricted(id) then return false end
    return canBuild(unit, id, ...)
end

queue.GetBuildableTags = function(unit, ...)
    return withoutDisabled(getBuildableTags(unit, ...))
end

if IsHost then
    -- AI planners import this shared, template-ID-indexed catalog.
    local catalogMeta = {}
    for name, value in pairs(getmetatable(availableUnits) or {}) do catalogMeta[name] = value end
    local write = catalogMeta.__newindex
    for id in pairs(availableUnits) do if restricted(id) then rawset(availableUnits, id, nil) end end
    -- SCOM's AI refreshes the Seraphim roster after host initialization.
    catalogMeta.__newindex = function(catalog, id, value)
        if restricted(id) then return end
        if type(write) == "function" then
            write(catalog, id, value)
        elseif write then
            write[id] = value
        else
            rawset(catalog, id, value)
        end
    end
    setmetatable(availableUnits, catalogMeta)

    -- Placement goes through an order before an engineer or AI starts work on it.
    hostOrder.IsOrderValid = function(order)
        local templateId = order.tp and order.tp.general and order.tp.general.tpId
        if restricted(order.tpId) or restricted(templateId) then return false end
        return isOrderValid(order)
    end

    -- Initial and replacement Kennel drones bypass build queues. Restrict the
    -- producer in the lobby, and remove blocked slots for pre-placed owners too.
    local restrictedSacuPod, restrictedOrbital = false, false
    for _, template in pairs(templates) do
        local special = template.additions and template.additions.scoSpecial
        if special and special.kind == "novaxLauncher" and restricted(special.child) then restrictedOrbital = true end
        local config = template.additions and template.additions.scoSourcePods
        if config and config.kind == "tower" then
            local slots = {}
            for _, slot in ipairs(config.slots) do
                if not restricted(slot.template) then slots[#slots + 1] = slot end
            end
            config.slots = slots
        elseif config and config.kind == "sacu" then
            for _, slot in ipairs(config.slots) do
                if restricted(slot.template) then restrictedSacuPod = true end
            end
        end
    end

    local function blockedSacuPod(unit)
        local config = unit and unit.tp and unit.tp.additions and unit.tp.additions.scoSourcePods
        if config and config.kind == "sacu" then
            for _, slot in ipairs(config.slots) do
                if restricted(slot.template) then return true end
            end
        end
        return false
    end

    -- Reject paid pod upgrades before native enhancement code creates an economy
    -- work item. Returning nil from CreateUnit would instead crash its callers.
    if restricted("uea0001") or restrictedSacuPod then
        local start = assert(_G.SCO_CommanderEnhancementHostStart, "Commander enhancement validation is unavailable")
        _G.SCO_CommanderEnhancementHostStart = function(clientId, unitId, enhancementId, ...)
            local ok, unit = pcall(GetUnitById, unitId)
            if ok and unit then
                if (unit.tpId == "uel0000" and (enhancementId == "LeftPod" or enhancementId == "RightPod") and restricted("uea0001"))
                    or (enhancementId == "Pod" and blockedSacuPod(unit)) then
                    return false, "unit-restricted"
                end
            end
            return start(clientId, unitId, enhancementId, ...)
        end
    end

    if restrictedSacuPod or restrictedOrbital then
        local unitClass = assert(Import("host/units/unitsClasses/unitsBaseClass.lua").HostUnit, "Host unit class is unavailable")
        if restrictedSacuPod then
            local request = assert(unitClass.SCORequestPod, "Pod request validation is unavailable")
            local apply = assert(unitClass.SCOApplyPaidPodEnhancement, "Pod completion validation is unavailable")
            unitClass.SCORequestPod = function(unit, remove, ...)
                if not remove and blockedSacuPod(unit) then return false end
                return request(unit, remove, ...)
            end
            unitClass.SCOApplyPaidPodEnhancement = function(unit, remove, ...)
                if not remove and blockedSacuPod(unit) then return false end
                return apply(unit, remove, ...)
            end
        end
        if restrictedOrbital then
            local launch = assert(unitClass.SCOSpecialLauncherOpen, "Orbital launch validation is unavailable")
            unitClass.SCOSpecialLauncherOpen = function(unit, ...)
                local special = unit.tp and unit.tp.additions and unit.tp.additions.scoSpecial
                if special and restricted(special.child) then return end
                return launch(unit, ...)
            end
        end
    end
end
