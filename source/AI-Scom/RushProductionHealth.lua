-- AI-Scom base ownership and factory recovery. Native queues and paid work remain authoritative.
local AF = Import("AI/AIFunctions.lua")
local Creator = Import("AI/AILocationCreator.lua")
local Reliability = Import("AI/mods/AI-Scom/RushReliability.lua")
local Log = Import("AI/debugUtilities.lua").AILog
local IsRushArmy
local installed = false

local function Live(unit)
    return unit and not unit.dead and not unit.deleted
end

local function DeadThread(thread)
    return thread == nil or type(thread) == "thread" and coroutine.status(thread) == "dead"
end

local function Record(army, event, unit)
    Log("[RushRecovery] army=" .. army.id .. " event=" .. event
        .. " factory=" .. tostring(unit and unit.id.index or "none"), true)
end

local function HiveBase(base)
    return base and (base.baseType == "MAIN" or base.baseType == "EXPANSION"
        or base.baseType == "OUTPOST" or base.baseType == "NAVAL")
end

function ReassignFactories(armyIndex, baseName)
    local army = Armies[armyIndex]
    local base = army.ai.bases[baseName]
    if not base then return end
    local navalBase = base.baseType == "NAVAL"
    for _, unit in pairs(army.units) do
        local factory = Reliability.Has(unit.tp, "STRUCTURE") and Reliability.Has(unit.tp, "FACTORY")
        local station = Reliability.Has(unit.tp, "STRUCTURE")
            and (Reliability.Has(unit.tp, "ENGINEERING_STATION") or Reliability.Has(unit.tp, "SCFA_ENGINEERSTATION"))
        if Reliability.Own(army, unit) and (factory or station) and unit:IsCompleted() then
            local hive = army.faction == 3 and station and Reliability.Has(unit.tp, "GUARD")
                and Reliability.Has(unit.tp, "SCFA_ENGINEERSTATION")
            -- Tag lookups are sparse: a missing NAVAL tag is nil, not false.
            local navalFactory = (not hive and factory and (Reliability.Has(unit.tp, "NAVAL_FACTORY")
                or Reliability.Has(unit.tp, "NAVAL"))) == true
            local position = unit:GetPosition()
            local area = navalBase and navalFactory and AF.GetNavalUnitGraphArea(unit)
            local matches = false
            if hive then
                -- A shore hive belongs to the nearest containing base, including
                -- a shipyard manager. It has no naval movement graph area.
                matches = HiveBase(base)
                    and (position.x - base.position.x)^2 + (position.z - base.position.z)^2 <= base.radius^2
            elseif navalBase == navalFactory then
                if navalBase then
                    matches = area == base.waterGraphArea
                else
                    matches = (position.x - base.position.x)^2 + (position.z - base.position.z)^2 <= base.radius^2
                end
            end
            if unit.assignedToBase == baseName and not matches then
                AF.SetUnitBaseAssignment(armyIndex, unit, nil)
            elseif unit.assignedToBase ~= baseName and matches then
                -- Enlarged base radii can overlap. Keep the nearest valid owner
                -- instead of moving factories between managers on every pass.
                local current = army.ai.bases[unit.assignedToBase]
                local distance = (position.x-base.position.x)^2 + (position.z-base.position.z)^2
                local currentDistance = current and current.position
                    and (position.x-current.position.x)^2 + (position.z-current.position.z)^2 or math.huge
                local currentValid
                if hive then
                    currentValid = HiveBase(current) and currentDistance <= current.radius^2
                else
                    currentValid = current and ((current.baseType == "NAVAL") == navalFactory)
                        and (navalFactory and current.waterGraphArea == area
                            or not navalFactory and currentDistance <= current.radius^2)
                end
                if not currentValid or distance < currentDistance
                    or distance == currentDistance and tostring(baseName) < tostring(unit.assignedToBase) then
                    AF.SetUnitBaseAssignment(armyIndex, unit, baseName)
                end
            end
        end
    end
end

function RemoveEmptyBases(armyIndex)
    local army = Armies[armyIndex]
    local navalBases = {}
    for _, unit in pairs(army.units) do
        if Reliability.Own(army, unit) and unit:IsCompleted()
            and Reliability.Has(unit.tp, "MOBILE") and Reliability.Has(unit.tp, "NAVAL")
            and unit.assignedToBase then navalBases[unit.assignedToBase] = true end
    end
    local names = {}
    for name in pairs(army.ai.bases) do names[#names + 1] = name end
    table.sort(names)
    for _, name in ipairs(names) do
        local base = army.ai.bases[name]
        if base and not (base.baseType == "NAVAL" and navalBases[name])
            and AF.GetNumUnitsAssignedToBase(armyIndex, name,
                (Tags.STRUCTURE * Tags.FACTORY) + (Tags.ENGINEER + Tags.COMMAND), 1) <= 0 then
            Creator.RemoveExpansion(armyIndex, name)
            Creator.ValidateMAINBase(armyIndex)
        end
    end
end

-- A factory coroutine can fail after setting its active flag. The native monitor
-- then never starts it again. Restart only a proven dead owner with no live target;
-- native Stop deletes incomplete targets, so a timer alone must never authorize it.
function RecoverNativeQueue(army, factory, canBuild)
    if not Reliability.Own(army, factory) or not factory:IsCompleted() then return false end
    local item = factory.buildQueue and factory.buildQueue[1]
    if not item or factory.productionBehaviorIsActive ~= true
        or not DeadThread(factory.productionBehaviorThread) or factory.isSlaveFactory
        or factory.upgradeBehaviorIsActive or factory:GetPause() or not army:HasUnitCapSpace()
        or Live(factory.unitBeingBuilt) or Live(factory.productionBehaviorTargetUnit)
        or Live(factory.upgradeTarget) or Live(factory.upgradeBehaviorTargetUnit)
        or type(factory.ProductionBehaviorStop) ~= "function"
        or type(factory.ProductionBehaviorStart) ~= "function" or not canBuild(army, factory, item.tpId) then return false end
    factory.ai = factory.ai or {}
    local now = GetGameTimeSeconds()
    if now < (factory.ai.rushQueueRecoveryAt or 0) then return false end
    factory.ai.rushQueueRecoveryAt = now + 10
    factory:ProductionBehaviorStop()
    factory:ProductionBehaviorStart()
    Record(army, "native-production-restarted", factory)
    return true
end

local function ReleaseDeadQueueOwner(army,factory)
    local record=factory.ai and factory.ai.rushProductionQueue
    if not record or factory.ai~=record.unitAI then return false end
    local platoon=record.platoon
    local data=platoon and platoon.ai
    local stale=not platoon or factory.platoon~=platoon or data~=record.platoonAI
        or not army:PlatoonExists(platoon) or DeadThread(platoon.aiThread)
        or data.rushProductionHeartbeat and GetGameTimeSeconds()-data.rushProductionHeartbeat>10
    if not stale then return false end
    -- A dead selector does not authorize deleting native products or queues.
    -- Release only its exact metadata; the existing native monitor drains work.
    if record.army==army and record.armyAI==army.ai and record.reservation
        and army.ai.ecoReserve and army.ai.ecoReserve[factory.id.index]==record.reservation then
        AF.ClearReserveEco(army.id,factory.id.index)
    end
    if factory.ai.rushProductionQueue==record then factory.ai.rushProductionQueue=nil end
    return true
end

local function ReleaseDeadAssignment(army, factory)
    local platoon = factory.platoon
    local data = platoon and platoon.ai
    local former = data and data.formerTable
    if not former or former.AIPlan ~= "RushV7Production" or former.RushFactory ~= factory
        or Reliability.Working(factory) then return false end
    local stale = data.rushProductionHeartbeat and GetGameTimeSeconds() - data.rushProductionHeartbeat > 10
    if not DeadThread(platoon.aiThread) and not stale then return false end
    if type(platoon.aiThread) == "thread" then KillThread(platoon.aiThread) end
    -- ReleaseDeadQueueOwner already released the selector's exact reservation.
    -- A newer order may own the current row even while this assignment is stale.
    factory.ai = factory.ai or {}
    factory.ai.eState = nil
    platoon:OnUnitRemoved(factory)
    -- OnUnitRemoved already destroys an empty platoon in the native implementation.
    if army:PlatoonExists(platoon) and platoon:GetNumOfUnits() == 0 then army:DisbandPlatoon(platoon) end
    Record(army, "production-assignment-released", factory)
    return true
end

function RecoverFactories(army, factories, canBuild, report)
    local changed = false
    for _, factory in ipairs(factories) do
        if Reliability.Own(army, factory) and factory:IsCompleted() then
            -- Each factory is isolated: one unsupported native object cannot
            -- prevent the remaining production lines from being recovered.
            local ok, err = pcall(function()
                if ReleaseDeadQueueOwner(army,factory) then changed=true end
                if ReleaseDeadAssignment(army, factory) then changed = true end
                if not factory.assignedToBase or not army.ai.bases[factory.assignedToBase] then
                    AF.SetUnitBaseAssignment(army.id, factory, nil)
                    Creator.AddUnitToClosestManager(army.id, factory)
                    if factory.assignedToBase and army.ai.bases[factory.assignedToBase] then
                        Record(army, "factory-base-restored", factory)
                        changed = true
                    end
                end
                if RecoverNativeQueue(army, factory, canBuild) then changed = true end
            end)
            if not ok then report(army, "factory recovery " .. factory.id.index, err) end
        end
    end
    return changed
end

function Install(isRush)
    IsRushArmy = isRush
    if installed then return end
    installed = true
    local originalReassign = Creator.ReAssignFactoriesAndEngineerstationsToLocation
    Creator.ReAssignFactoriesAndEngineerstationsToLocation = function(index, name, ...)
        if IsRushArmy(Armies[index]) then return ReassignFactories(index, name) end
        return originalReassign(index, name, ...)
    end
    local originalCleanup = Creator.RemoveLocationWithoutFactoryOrEngineer
    Creator.RemoveLocationWithoutFactoryOrEngineer = function(index, ...)
        if IsRushArmy(Armies[index]) then return RemoveEmptyBases(index) end
        return originalCleanup(index, ...)
    end
end
