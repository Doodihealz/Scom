local PlayableAreaManager = Import("host/managers/playableArea/hostPlayableAreaManager.lua")
local CommanderCommands = Import("common/commands/definitions/commander.lua")
local UnitCommands      = Import("common/commands/definitions/units.lua")
local Layers = Import("common/layers.lua")
local UnitEnums = Import("common/units/unitEnums.lua")
local Units = __Entities.Units
local Shields = __Entities.Shields

--# dash tuning constants ==================
local DashTimeoutSeconds = 5.0  -- cooldown between consecutive dashes (seconds)
local DashEnergyBudget = 15000  -- energy cost of a full max-distance dash
local DashMaxDistance  = 45     -- cells (1 cell == 1 world unit)
local DashCostGrowth   = 1.04   -- per-cell exponential growth of dash cost (tunable steepness)
local DashDamagePoints = 2000.0 -- total damage a dash deals before it is stopped by what it hits
local DashHitboxWidth  = 6.0    -- width of the dash sweep box used for collision (world units)
local DashHitboxHeight = 15.0   -- height of the dash sweep box used for collision (world units)
local DashMinDistance  = 0.01   -- below this distance a dash is a no-op (no move/charge/cooldown)
local DashDebugDraw    = false
local DashCargeTimeSeconds = 1.0 -- how long the unit must idle for the dash to execute.
local dashCostDenominator = DashCostGrowth ^ DashMaxDistance - 1

-- TODO: DashBehavior requires the fact towards beahvior so face towards would be included in the dash behavior.
---@class DashBehavior: HostEntity
---@field protected dashBehaviorIsActive boolean True while a dash is mid-flight (movement disabled, dash order holding the unit).
---@field protected dashBehaviorTarget float3 The clamped, affordable world target the active dash is moving toward.
---@field protected dashBehaviorThread thread|nil The coroutine running DashBehaviorUpdate for the active dash.
---@field protected dashCooldownUntil number Game time (seconds) until which the next dash is gated; nil when no cooldown is armed.
DashBehavior = Class("DashBehavior")

---@protected Initializes a new DashBehavior class.
function DashBehavior:__init()
    self.dashBehaviorIsActive = false
    self.dashBehaviorThread = nil
    self.dashBehaviorTarget = EngineClasses.float3()
    self.dashCooldownUntil = Time
end

---@protected Energy required to dash a given distance (clamped to DashMaxDistance).
---@param distance number Dash distance in cells/world units.
---@return number energyCost Energy needed to cover that distance.
local function DashEnergyCost(distance)
    distance = math.min(distance, DashMaxDistance)
    return DashEnergyBudget * (DashCostGrowth ^ distance - 1) / dashCostDenominator
end

---@protected Inverse of DashEnergyCost: the furthest distance a given amount of energy can buy.
---@param energy number Available energy.
---@return number distance Affordable distance in cells/world units (0 .. DashMaxDistance).
local function DashAffordableDistance(energy)
    if energy <= 0 then return 0 end
    if energy >= DashEnergyBudget then return DashMaxDistance end
    local distance = math.log(1 + (energy / DashEnergyBudget) * dashCostDenominator) / math.log(DashCostGrowth)
    return math.min(distance, DashMaxDistance)
end

--- Whether this unit type is allowed to dash.
--* base units cannot dash; subclasses (e.g. Commander) override this to opt in
--* gates both the order's ValidateUnitAssignment and DashBehaviorStart
---@return boolean canDash
function DashBehavior:DashBehaviorIsValidFor()
    return false
end

---Begins a dash toward targetPosition.
---@param targetPosition float3 Requested dash destination (may be clamped by range/energy).
function DashBehavior:DashBehaviorStart(targetPosition)
    if not self:DashBehaviorIsValidFor() then return end

    local currentPosition = self:GetPosition()
    -- Clamp the request to the playable area and valid areas to navigate through.
    targetPosition = PlayableAreaManager.GetNearestPointInPlayableArea(targetPosition)

    -- TODO: We should be able to go through factories if our damage is high enough. But factories are navmap blockers...
    targetPosition = self:CheckDashCollisionsWithNavmap(currentPosition, targetPosition, self.tp.general.navigationLayer)

    local _, terrainHeight = Engine.SampleTerrainHeight(targetPosition)
    targetPosition.y = terrainHeight

    -- Early exit if the dash is too close to be considered valid.
    if math3D.distance(currentPosition, targetPosition) < DashMinDistance then
        return
    end

    if self.dashBehaviorIsActive then
        self:DashBehaviorStop()
    end

    self.dashBehaviorIsActive = true
    self.dashBehaviorTarget = targetPosition
    self.dashBehaviorThread = self:NewThread(self.DashBehaviorUpdate)
end

---@protected Sweeps a box along the dash path, damaging units/shields it passes through.
--- the dash carries a fixed pool of damage (DashDamagePoints); it plows through targets it can
--- afford to destroy, and stops at the first one whose health exhausts the remaining pool.
---@param currentPosition float3 Dash start position.
---@param targetPosition float3 Intended dash end position.
---@return float3 targetPosition End position, clamped to the hit that stopped the dash (if any).
function DashBehavior:CheckDashCollisionsWithUnits(currentPosition, targetPosition)
    
    local difference = math3D.sub(targetPosition, currentPosition)
    local distance = math3D.length(difference)

    if distance < DashMinDistance then
        return targetPosition
    end

    local direction = math3D.divide(difference, distance)
    local rotation = Engine.QuaternionLookRotation(direction, EngineClasses.float3(0, 1, 0))

    local damagePointsRemaining = DashDamagePoints

    -- Build an oriented box spanning from the start to the midpoint, facing the target.
    local boxPosition = math3D.scale(math3D.add(currentPosition, targetPosition), 0.5)
    local boxSize = EngineClasses.float3(DashHitboxWidth, DashHitboxHeight, math3D.distance(currentPosition, targetPosition))

    -- Draw the dash collider.
    if DashDebugDraw then
        -- Debug gizmo: draw the oriented box cast as 12 wireframe edges.
        -- boxSize is the full size of the collider, so use half-extents for the corners.
        local halfExtents = EngineClasses.float3(boxSize.x * 0.5, boxSize.y * 0.5, boxSize.z * 0.5)
        local debugColor = EngineClasses.float4(1, 0, 0, 1)

        -- Rotate a local corner offset into world space and translate to the box center.
        local function corner(sx, sy, sz)
            local localOffset = EngineClasses.float3(sx * halfExtents.x, sy * halfExtents.y, sz * halfExtents.z)
            local rotated = Engine.QuaternionRotateVector(rotation, localOffset)
            return EngineClasses.float3(boxPosition.x + rotated.x, boxPosition.y + rotated.y, boxPosition.z + rotated.z)
        end

        -- Bottom face corners (y = -1), then top face corners (y = +1).
        local b1 = corner(-1, -1, -1)
        local b2 = corner( 1, -1, -1)
        local b3 = corner( 1, -1,  1)
        local b4 = corner(-1, -1,  1)
        local t1 = corner(-1,  1, -1)
        local t2 = corner( 1,  1, -1)
        local t3 = corner( 1,  1,  1)
        local t4 = corner(-1,  1,  1)

        -- Bottom face.
        Engine.DrawLine(b1, b2, debugColor)
        Engine.DrawLine(b2, b3, debugColor)
        Engine.DrawLine(b3, b4, debugColor)
        Engine.DrawLine(b4, b1, debugColor)

        -- Top face.
        Engine.DrawLine(t1, t2, debugColor)
        Engine.DrawLine(t2, t3, debugColor)
        Engine.DrawLine(t3, t4, debugColor)
        Engine.DrawLine(t4, t1, debugColor)

        -- Vertical edges connecting bottom to top.
        Engine.DrawLine(b1, t1, debugColor)
        Engine.DrawLine(b2, t2, debugColor)
        Engine.DrawLine(b3, t3, debugColor)
        Engine.DrawLine(b4, t4, debugColor)
    end

    local collisionEvents = Engine.BoxCast(CollisionWorld.Collision, boxPosition, boxSize, rotation, Layers.CollisionLayer.Shields + Layers.CollisionLayer.Units)

    -- Resolve hits nearest-first so the dash stops at the closest thing it can't break.
    table.sort(collisionEvents, function(a, b)
        return math3D.distanceSquared(currentPosition, a.hitPosition) < math3D.distanceSquared(currentPosition, b.hitPosition)
    end)

    for _, collisionEvent in ipairs(collisionEvents) do
        if collisionEvent.colliderGlobalID.index ~= 0 and Engine.IsValidGlobalID(collisionEvent.colliderGlobalID) then

            ---@type HostUnit
            local unit = Units[collisionEvent.colliderGlobalID.index]
            if unit and self.army:IsEnemy(unit.army) then

                local unitHealth = unit:GetHealth()
                local damage = math.min(damagePointsRemaining, unitHealth)

                unit:TakeDamage(damage, DestroyType.Dissolve, self)

                damagePointsRemaining = damagePointsRemaining - damage

                if unit.dead then
                    UnitCommands.OnUnitDissolve.Send(unit.id, direction)
                else
                    targetPosition = collisionEvent.hitPosition
                    break;
                end
            end

            local shield = Shields[collisionEvent.colliderGlobalID.index]
            if shield and shield.enabled and self.army:IsEnemy(shield.army) then

                local otherShieldHealth = shield:GetHealth()
                if otherShieldHealth <= damagePointsRemaining then
                    damagePointsRemaining = damagePointsRemaining - otherShieldHealth
                    shield:TakeDamage(otherShieldHealth)
                end

                if damagePointsRemaining < 0 then
                    targetPosition = collisionEvent.hitPosition
                    break;
                end
            end
        end
    end

    return targetPosition
end

---@protected Clamps the dash end position to the first impassable navmap blocker along the path.
--- keeps units from dashing through walls/cliffs.
---@param currentPosition float3 Dash start position.
---@param targetPosition float3 Intended dash end position (after unit collisions).
---@param navigationLayer integer The unit's navigation layer (see Layers.NavigationLayer).
---@return float3 targetPosition End position, clamped to the navmap blocker hit (if any).
function DashBehavior:CheckDashCollisionsWithNavmap(currentPosition, targetPosition, navigationLayer)
    if navigationLayer == Layers.NavigationLayer.Invalid then
        return targetPosition
    end

    local source = EngineClasses.float2(currentPosition.x, currentPosition.z)
    local target = EngineClasses.float2(targetPosition.x, targetPosition.z)

    local _, result, hitPosition = Engine.NavmapLineCast(source, target, navigationLayer)
    if result == NavmapLineCastResult.Hit then
        return EngineClasses.float3(hitPosition.x, targetPosition.y, hitPosition.y)
    end

    if result == NavmapLineCastResult.OutOfTerrainBounds or result == NavmapLineCastResult.InvalidStartPosition then
        return EngineClasses.float3(source.x, targetPosition.y, source.y)
    end

    return targetPosition
end

--- Coroutine body of a dash: resolves the path, teleports the unit, charges for the
--- distance actually travelled, then arms the cooldown for the next dash.
function DashBehavior:DashBehaviorUpdate()

    local dashTarget = self.dashBehaviorTarget
    local dashTargetDirection = self:GetAlignRotation(math3D.tofloat2(dashTarget))

    self:AlignBehaviorStart(dashTargetDirection)
    WaitUntil(function()
        return not self.alignBehaviorIsActive and self.dashCooldownUntil <= Time
    end)

    local worldPosition = self:GetPosition()
    local dashDirection = math3D.normalize(math3D.sub(dashTarget, worldPosition))

    local economy = self:GetEconomy()
    ---@type number
    local availableEnergy = economy and economy:GetResourceStored("energy") or 0

    local distance = math3D.distance(self.dashBehaviorTarget, worldPosition)
    distance = math.min(distance, DashAffordableDistance(availableEnergy), DashMaxDistance)
    dashTarget = math3D.add(worldPosition, math3D.scale(math3D.normalize(dashDirection), distance))

    -- Snap to the terrain surface at the landing spot.
    local _, terrainHeight = Engine.SampleTerrainHeight(dashTarget)
    dashTarget.y = terrainHeight

    distance = math3D.distance(dashTarget, worldPosition)

    if economy then
        economy:TakeResources("energy", DashEnergyCost(distance))
    end

    -- Begin charge.
    CommanderCommands.OnStartCommanderDash.Send(self.id, dashTarget)
    
    -- Wait for charge time.
    WaitTicks(ConvertTimeToTick(DashCargeTimeSeconds))

    -- Resolve where the dash actually ends: stop at units/shields, then at navmap blockers.
    dashTarget = self:CheckDashCollisionsWithUnits(worldPosition, dashTarget)

    -- Snap to the terrain surface at the landing spot.
    local _, terrainHeight = Engine.SampleTerrainHeight(dashTarget)
    dashTarget.y = terrainHeight

    -- Execute charge.
    dashDirection = math3D.normalize(math3D.sub(dashTarget, worldPosition))
    local _, newRotation = Engine.GetTerrainAlignedRotation(dashDirection, EngineClasses.float2(dashTarget.x, dashTarget.z))
    Engine.SetGlobalEntityLocalRotation(self.id, newRotation)
    Engine.SetGlobalEntityPosition(self.id, dashTarget)
    CommanderCommands.OnExecuteCommanderDash.Send(self.id, dashTarget)

    self.dashCooldownUntil = Time + DashTimeoutSeconds

    WaitTicks(1)

    -- Hand the unit back to normal movement and clear the active-dash state.
    self:DashBehaviorStop()
end

--- Stop/Cancels an in-progress dash and restores normal movement.
function DashBehavior:DashBehaviorStop()
    if not self.dashBehaviorIsActive then return end

    -- Kill the dash coroutine before it can reposition the unit.
    if self.dashBehaviorThread then
        KillThread(self.dashBehaviorThread)
    end
    self:AlignBehaviorStop()

    Engine.SetMovementEnabled(self.id, true)
    -- End charge.
    CommanderCommands.OnEndCommanderDash.Send(self.id)

    self.dashBehaviorIsActive = false
    self.dashBehaviorThread = nil
    self.dashBehaviorTarget = EngineClasses.float3()
end

-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0
