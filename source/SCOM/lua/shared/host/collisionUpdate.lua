local Layers = Import("common/layers.lua")
local CollisionLayer = Layers.CollisionLayer
local TargetingLayer = Layers.TargetingLayer
local Water = Import("common/water.lua")

local Units = __Entities.Units
local Shields = __Entities.Shields
local Projectiles = __Entities.Projectiles
local Props = __Entities.Props

function CollisionUpdate()
    for _, muzzle in pairs(__Muzzles) do
        muzzle:Update()
    end

    local environmentCollisionEvents = Engine.GetRayCollisionEventsForWorld(_G.CollisionWorld.EnvironmentCollision)
    for _, data in ipairs(environmentCollisionEvents) do
        xpcall(ProcessEnvironmentCollisionEvent, ErrorHandler, data)
    end

    local rayCollisionEvents = Engine.GetRayCollisionEventsForWorld(_G.CollisionWorld.Collision)
    for i, data in ipairs(rayCollisionEvents) do
        xpcall(ProcessRayCollisionEvent, ErrorHandler, data)
    end

    if _G.WaterGlobalID then
        local waterVolumeEvents = Engine.GetVolumeCollisionEventsForWorld(_G.CollisionWorld.EnvironmentCollision)
        for _, data in ipairs(waterVolumeEvents) do
            xpcall(ProcessWaterVolumeEvent, ErrorHandler, data)
        end
    end
end

---comment
---@param projectileGlobalID GlobalID
---@param tickImpactTime number
---@param hitGlobalID GlobalID The entity that was hit, so the client knows what to play the impact effects of. Invalid when the projectile hit the terrain.
local function DestroyProjectile(projectileGlobalID, tickImpactTime, hitGlobalID)
    Projectiles[projectileGlobalID.index]:Destroy(tickImpactTime, hitGlobalID)
end

-- Static artillery clears trees only after an accepted solid impact.
-- Source split children retain sourceUnit and the firing weapon snapshot.
local function SCO_ArtilleryTreeImpact(projectile, position)
    if projectile.scoArtilleryTreeImpactApplied then return end
    local source = projectile.sourceUnit
    local tags = source and source.tp and source.tp.hasTags
    if not tags or not tags.STRUCTURE
        or not (tags.ARTILLERY or tags.SCFA_ARTILLERY)
        or not (tags.TECH2 or tags.TECH3 or tags.TECH4 or tags.TECH5) then return end

    local motion = projectile.scoSourceMotion
    -- Impact-split carriers have no blast; their leaf impacts own the effect.
    if motion and motion.split then return end
    local radius, damage = projectile.damageRadius, projectile.damage
    if motion and motion.weapon and (motion.weapon.DoTTime or 0) > 0 then
        radius, damage = motion.radius, motion.damage
    end
    if type(radius) ~= "number" or radius ~= radius or radius < 0 or radius == math.huge
        or type(damage) ~= "number" or damage ~= damage or damage <= 0 then return end

    local terrainStatus, terrain = Engine.SampleTerrainHeight(position)
    if terrainStatus ~= EngineErrorCode.Success or type(terrain) ~= "number"
        or terrain ~= terrain or math.abs(terrain) == math.huge then return end
    local waterStatus, hasWater = Engine.HasWater()
    if waterStatus ~= EngineErrorCode.Success then return end
    if hasWater then
        local levelStatus, level = Engine.GetWaterLevel()
        if levelStatus ~= EngineErrorCode.Success or type(level) ~= "number"
            or level ~= level or math.abs(level) == math.huge or terrain < level then return end
    end

    projectile.scoArtilleryTreeImpactApplied = true
    -- Keep the real impact height: the shared sphere test rejects distant trees.
    -- The shared owner caps all requests at 64; artillery retains a 3-unit floor.
    Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown.Impact(
        position, math.max(3, radius))
end

--- Returns how much of the damage gets from the hitPosition to the targetPosition through the shields in between.
---@param hitPosition float3
---@param targetPosition float3
---@param damage number
---@param shieldOverflows table<HostShield, number> Damage each shield let through, keyed by the shields that already took the area damage.
---@return number
local function GetDamageThroughShields(hitPosition, targetPosition, damage, shieldOverflows)
    if hitPosition.x == targetPosition.x and hitPosition.y == targetPosition.y
        and hitPosition.z == targetPosition.z then return damage end

    -- TODO: It is overkill (but more robust) to dispatch another linecast. We already have the shields from earlier.
    local shieldCollisionEvents = Engine.LineCast(CollisionWorld.Collision, hitPosition, targetPosition, CollisionLayer.Shields)

    for _, collisionEvent in ipairs(shieldCollisionEvents) do
        
        local shield = Shields[collisionEvent.otherGlobalID.index]
        local overflow = shieldOverflows[shield]
        
        if overflow then
            damage = math.min(damage, overflow)
        end
    end
    return damage
end

---Damage all units and shields in an area.
---@param position float3 Center point for the damage.
---@param radius number
---@param damage number
---@param army HostArmy Which army does the damage belong too. To damage all units, set damage friendly to true.
---@param damageFriendly boolean
function ProcessAreaDamage(position, radius, damage, army, damageFriendly, sourceUnit)

    -- Draw Area Damage
    --Engine.DrawCircle(position, radius, { x = 0, y = 1, z = 0, w = 1 })
    
    -- Create a capsule cast based on the set radius. The +4 is to meet the engine requirements `that the start and end position of the capsule cast needs a minimum distance of 4`.
    local collisionEvents = Engine.CapsuleCast(CollisionWorld.Collision, position, radius * 2 + 4, radius, GetIdentityQuaternion(), CollisionLayer.Shields + CollisionLayer.Units)

    ---@type HostUnit[]
    local units = { }
    ---@type HostShield[]
    local shields = { }
    ---@type table<HostShield, number> Distance from the hit position to the shield's surface, negative inside the shield.
    local shieldSurfaceDistances = { }
    ---@type table<HostShield, float3> Point on the shield's surface closest to the hit position.
    local shieldNearestPoints = { }

    -- Sort hits.
    for _, collisionEvent in ipairs(collisionEvents) do

        local unit = Units[collisionEvent.colliderGlobalID.index]
        local shield = Shields[collisionEvent.colliderGlobalID.index]

        -- Hit unit!
        if unit and (damageFriendly or army:IsEnemy(unit.army)) then
            table.insert(units, unit)
        -- Hit Shield
        elseif shield and shield.enabled and (damageFriendly or army:IsEnemy(shield.army)) then
            table.insert(shields, shield)

            local shieldPosition = shield:GetPosition()
            local shieldRadius = shield.tp.radii.x
            local shieldDistance = math3D.distance(position, shieldPosition)
            shieldSurfaceDistances[shield] = shieldDistance - shieldRadius
            if shieldDistance == 0 then
                shieldNearestPoints[shield] = shieldPosition
            else
                shieldNearestPoints[shield] = math3D.add(shieldPosition, math3D.scale(math3D.sub(position, shieldPosition), shieldRadius / shieldDistance))
            end
        end
    end

    local hitShields = #shields > 0
    ---@type table<HostShield, number> Damage each shield let through.
    local shieldOverflows = { }

    -- Process shields, closest surface first. A shield only takes the damage the shields in front of it let through.
    table.sort(shields, function(a, b)
        return shieldSurfaceDistances[a] < shieldSurfaceDistances[b]
    end)

    for _, shield in ipairs(shields) do
        local shieldDamage = GetDamageThroughShields(position, shieldNearestPoints[shield], damage, shieldOverflows)
        if shieldDamage > 0 then
            shieldOverflows[shield] = shield:TakeDamage(shieldDamage)
        else
            shieldOverflows[shield] = 0
        end
    end

    -- Process units.
    if hitShields then
        -- If we did hit shields, units behind them only take the damage the shields let through.
        for _, unit in ipairs(units) do
            -- TODO: We create another linecast inside this function.
            -- It is overkill. Instead, we can check the shields from earlier.
            local unitDamage = GetDamageThroughShields(position, unit:GetPosition(), damage, shieldOverflows)
            if unitDamage > 0 then
                unit:TakeDamage(unitDamage, DestroyType.Kinetic, sourceUnit)
            end
        end
    else
        -- If we did not hit any shields, all units hit will take damage.
        for _, unit in ipairs(units) do
            unit:TakeDamage(damage, DestroyType.Kinetic, sourceUnit)
        end
    end
end

---@param rayCollisionEvent RayCollisionEvent
function ProcessRayCollisionEvent(rayCollisionEvent)

    ---@type Projectile
    local projectile = Projectiles[rayCollisionEvent.rayGlobalID.index]

    -- If the ray global entity is a projectile. A projectile hit a collider.
    if projectile then

        -- We subtract a little from the impact time so any collision queries we make will be slightly behind the real impact point.
        -- This will remove any inprecision created when querying with a hit point that is starting on an edge of a collider. 
        -- (We already knows its on an edge of some collider becuase this is a collision event with a collider!)
        local hitDistance = math.max(rayCollisionEvent.hitDistance - 0.01, 0)

        -- Hit position of our projectile.
        local hitPosition = math3D.add(rayCollisionEvent.rayOrigin, math3D.scale(rayCollisionEvent.rayDirection, hitDistance))

        -- The percent [0.0, 1.0] from the ray origin to its max distance where the ray hit occured.
        local rayImpactTime = hitDistance / rayCollisionEvent.rayMaxDistance
        
        -- Convert the ray impact time [0,0, 1.0] to tick time [0.0, Constants.TickTimeStep]
        -- NOTE: We never want an impact time exactly one whole tick (Constants.TickTimeStep). 
        -- This falls into the next tick which is undesired -- after all, the impact happens this tick!
        -- Luckly, we handle this case by clamping the time within the range [0.01, 0.99]
        -- In the future, this information will be ommited. Instead, we will send the identity of the hit object and use client side collisions to predict the collision poi
        local tickImpactTime = math.clamp(rayImpactTime, 0.01, 0.99) * Constants.TickTimeStep

        local projectileArmy = Armies[projectile.armyId]

        -- Did we hit the terrain?
        if rayCollisionEvent.otherGlobalID.index == 0 then
            if projectile.damageRadius > 0 then
                -- Process Area Damage.
                ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, projectile.damageFriendly == true, projectile.sourceUnit)
            end

            DestroyProjectile(rayCollisionEvent.rayGlobalID, tickImpactTime, rayCollisionEvent.otherGlobalID)
            SCO_ArtilleryTreeImpact(projectile, hitPosition)
        else
            -- If we hit another global entity, the GlobalID will be valid.
            if Engine.IsValidGlobalID(rayCollisionEvent.otherGlobalID) then
                ---@type HostUnit
                local unit = Units[rayCollisionEvent.otherGlobalID.index]
                local shield = Shields[rayCollisionEvent.otherGlobalID.index]

                if unit and projectileArmy:IsEnemy(unit.army) then                 
                    if projectile.damageRadius > 0 then
                        -- Process Area Damage.
                        ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, projectile.damageFriendly == true, projectile.sourceUnit)
                    else
                        unit:TakeDamage(projectile.damage, DestroyType.Kinetic, projectile.sourceUnit)
                    end

                    -- Only destroy the projectile if its an enemy unit.
                    DestroyProjectile(rayCollisionEvent.rayGlobalID, tickImpactTime, rayCollisionEvent.otherGlobalID)
                    SCO_ArtilleryTreeImpact(projectile, hitPosition)
                elseif shield and shield.enabled and projectileArmy:IsEnemy(shield.army) then             
                    if projectile.damageRadius > 0 then
                        -- Process Area Damage.
                        ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, projectile.damageFriendly == true, projectile.sourceUnit)
                    else
                        shield:TakeDamage(projectile.damage)
                    end

                    -- Only destroy the projectile if its an enemy shield.
                    DestroyProjectile(rayCollisionEvent.rayGlobalID, tickImpactTime, rayCollisionEvent.otherGlobalID)
                end
            end
        end
    end
end

---Handle a projectile crossing the water surface.
---@param rayCollisionEvent RayCollisionEvent
function ProcessWaterCollisionEvent(rayCollisionEvent)
    local level = Water.GetLevel() or 0

    if rayCollisionEvent.colliderHitIndex ~= 0 or rayCollisionEvent.rayOrigin.y <= level then
        return
    end

    local errorCode, projectileGlobalID = Engine.GetGlobalEntityRoot(rayCollisionEvent.rayGlobalID)
    if errorCode ~= EngineErrorCode.Success then
        return
    end

    ---@type HostProjectile
    local projectile = Projectiles[projectileGlobalID.index]
    if not projectile then
        return
    end

    local hitDistance = math.max(rayCollisionEvent.hitDistance - 0.01, 0)
    local hitPosition = math3D.add(rayCollisionEvent.rayOrigin, math3D.scale(rayCollisionEvent.rayDirection, hitDistance))

    local _, terrainHeight = Engine.SampleTerrainHeight(hitPosition)
    if terrainHeight >= level then
        return
    end

    local tickImpactTime = math.clamp(hitDistance / rayCollisionEvent.rayMaxDistance, 0.01, 0.99) * Constants.TickTimeStep

    projectile:OnCrossedWaterline(hitPosition, tickImpactTime, rayCollisionEvent.otherGlobalID)
end

---@param volumeColliderEvents VolumeColliderEvents
function ProcessWaterVolumeEvent(volumeColliderEvents)
    if #volumeColliderEvents.enterEvents == 0 and #volumeColliderEvents.exitEvents == 0 then
        return
    end

    local errorCode, unitGlobalID = Engine.GetGlobalEntityRoot(volumeColliderEvents.colliderID)
    if errorCode ~= EngineErrorCode.Success then
        return
    end

    ---@type HostUnit
    local unit = Units[unitGlobalID.index]
    if not unit then
        return
    end

    local waterIndex = _G.WaterGlobalID.index

    for _, exitEvent in ipairs(volumeColliderEvents.exitEvents) do
        if exitEvent.colliderGlobalID.index == waterIndex then
            unit:OnWaterSensorChanged(volumeColliderEvents.colliderID, false)
        end
    end

    for _, enterEvent in ipairs(volumeColliderEvents.enterEvents) do
        if enterEvent.colliderGlobalID.index == waterIndex then
            unit:OnWaterSensorChanged(volumeColliderEvents.colliderID, true)
        end
    end
end

---Handle all ray collision events in the EnvironmentCollision collision world.
---@param rayCollisionEvent RayCollisionEvent
function ProcessEnvironmentCollisionEvent(rayCollisionEvent)
    if _G.WaterGlobalID and rayCollisionEvent.otherGlobalID.index == _G.WaterGlobalID.index then
        ProcessWaterCollisionEvent(rayCollisionEvent)
        return
    end

    local wreck = Props[rayCollisionEvent.rayGlobalID.index]
    if not wreck then
        return
    end

    local hitDistance = math.max(rayCollisionEvent.hitDistance - 0.01, 0)
    wreck.crashImpactPosition = math3D.add(rayCollisionEvent.rayOrigin, math3D.scale(rayCollisionEvent.rayDirection, hitDistance))
end


-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0
-- Sanctuary exposes damage-over-time fields to templates and AI, but its
-- stock projectile collision path applies only the direct damage value and
-- hardcodes friendly area damage off. Restore source friendly-area damage
-- for all ten private surface bombs and UEA0103's 15 x 4 area pulses at
-- one 10-Hz simulation tick apart. Stock collision still owns impact
-- classification, projectile destruction, and the client impact event.
-- XSA0402's DestroyOnWater bomb is culled before stock collision dispatch,
-- so even a one-tick shallow-water crossing cannot damage the seabed. Its
-- separately source-authored DeathImpact area damage is applied once when
-- the aircraft wreck first reaches water or stock reports terrain impact.
local SCO_FaBomberGroundFireEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCO_FaBomberGroundFireInstalled = rawget(
    SCO_FaBomberGroundFireEnvironment,
    "SCO_FaBomberGroundFireInstalled")
if SCO_FaBomberGroundFireInstalled ~= nil
    and SCO_FaBomberGroundFireInstalled ~= "1.1.0"
then
    error("Unsupported SCOM Scorcher ground-fire runtime "
        .. tostring(SCO_FaBomberGroundFireInstalled))
end
if SCO_FaBomberGroundFireInstalled == nil then
    if type(CollisionUpdate) ~= "function"
        or type(ProcessRayCollisionEvent) ~= "function"
        or type(ProcessAreaDamage) ~= "function"
        or type(DestroyProjectile) ~= "function"
        or type(NewThread) ~= "function"
        or type(WaitTicks) ~= "function"
        or type(Engine.GetGlobalEntityWorldPosition) ~= "function"
        or type(Engine.HasWater) ~= "function"
        or type(Engine.GetWaterLevel) ~= "function"
        or type(Engine.SampleTerrainHeight) ~= "function"
    then
        error("SCOM Scorcher ground-fire runtime cannot resolve collision functions")
    end

    local SCO_FaBomberStockCollisionUpdate = CollisionUpdate
    local SCO_FaBomberStockRayCollision = ProcessRayCollisionEvent
    local SCO_FaBomberStockWaterCollision = ProcessWaterCollisionEvent
    local SCO_FaBomberStockAreaDamage = ProcessAreaDamage
    local SCO_FaBomberActiveProjectile = nil

    local SCO_FaBomberImpactProfiles = {
        pab101 = { damage = 200, radius = 4, damageFriendly = true },
        pab301 = { damage = 3450, radius = 4, damageFriendly = true },
        peb101 = { damage = 60, radius = 2.5, damageFriendly = false },
        peb301 = { damage = 3000, radius = 6, damageFriendly = true },
        pgb101 = { damage = 50, radius = 3, damageFriendly = true },
        pgb301 = { damage = 2750, radius = 7, damageFriendly = true },
        psb101 = { damage = 250, radius = 4, damageFriendly = true },
        psb202 = { damage = 1175, radius = 3, damageFriendly = true },
        psb301 = { damage = 3250, radius = 5, damageFriendly = true },
        psb402 = { damage = 11000, radius = 20, damageFriendly = true },
    }
    local SCO_FaBomberDestroyOnWaterProfiles = {
        pab101 = { sourceId = "AIFBombGraviton01" },
        pab301 = { sourceId = "AIFBombQuark01" },
        psb101 = { sourceId = "SBOOtheTacticalBomb01" },
        psb202 = { sourceId = "SBOOtheTacticalBomb02" },
        psb301 = { sourceId = "SBOZhanaseeBomb01" },
        psb402 = { sourceId = "SBOOhwalliStrategicBomb01" },
    }
    local SCO_FaBomberCrashImpactProfiles = {
        XSA0402 = { damage = 10000, radius = 8 },
    }

    local function SCO_FaBomberImpactContract(projectile)
        local additions = projectile and projectile.tp
            and projectile.tp.additions
        local contract = additions and additions.scoFaBomberImpact
        if contract == nil then return nil end
        local profile = SCO_FaBomberImpactProfiles[
            contract.runtimeProjectileId]
        if profile == nil
            or contract.version ~= "1.0.0"
            or contract.damageFriendly ~= profile.damageFriendly
            or projectile.damage ~= profile.damage
            or projectile.damageRadius ~= profile.radius
        then
            error("Malformed SCOM FA bomber impact contract")
        end
        return contract
    end

    local function SCO_FaBomberDestroyOnWaterContract(projectile)
        local additions = projectile and projectile.tp
            and projectile.tp.additions
        local contract = additions and additions.scoFaDestroyOnWater
        if contract == nil then return nil end
        local profile = SCO_FaBomberDestroyOnWaterProfiles[
            contract.runtimeProjectileId]
        if profile == nil
            or contract.version ~= "1.0.0"
            or contract.sourceId ~= profile.sourceId
            or contract.sourceDestroyOnWater ~= true
            or contract.runtimeMode
                ~= "HostPreCollisionWaterlineCull"
            or projectile.tp.general == nil
            or projectile.tp.general.tpId
                ~= contract.runtimeProjectileId
        then
            error("Malformed SCOM FA bomber DestroyOnWater contract")
        end
        return contract
    end

    local function SCO_FaBomberCullWaterProjectiles()
        local _, hasWater = Engine.HasWater()
        if not hasWater then return end
        local _, waterLevel = Engine.GetWaterLevel()
        if type(waterLevel) ~= "number" then
            error("SCOM FA bomber water level is unavailable")
        end
        local toDestroy = {}
        for _, projectile in pairs(Projectiles) do
            if SCO_FaBomberDestroyOnWaterContract(projectile) ~= nil then
                local _, position =
                    Engine.GetGlobalEntityWorldPosition(projectile.id)
                if position ~= nil and position.y <= waterLevel then
                    table.insert(toDestroy, projectile)
                end
            end
        end
        for _, projectile in ipairs(toDestroy) do
            if Projectiles[projectile.id.index] == projectile then
                DestroyProjectile(projectile.id, 0)
            end
        end
    end

    local function SCO_FaBomberCrashImpactContract(wreck)
        local contract = wreck and wreck.scoFaBomberCrashImpact
        if contract == nil then return nil end
        local profile = SCO_FaBomberCrashImpactProfiles[
            contract.sourceUnitId]
        if profile == nil
            or contract.version ~= "1.0.0"
            or contract.sourceLabel ~= "DeathImpact"
            or contract.damage ~= profile.damage
            or contract.damageRadius ~= profile.radius
            or contract.damageFriendly ~= true
            or contract.runtimeMode ~= "WreckImpactAreaDamage"
            or contract.army == nil
        then
            error("Malformed SCOM Ahwassa wreck crash-impact contract")
        end
        return contract
    end

    local function SCO_FaBomberApplyCrashImpact(wreck, position)
        local contract = SCO_FaBomberCrashImpactContract(wreck)
        if contract == nil
            or wreck.scoFaBomberCrashImpactApplied == true
        then
            return
        end
        if wreck.scoAircraftCrashActive then
            if wreck.deleted or Props[wreck.id.index] ~= wreck then return end
            position = wreck.scoAircraftCrashContactPosition
            if position == nil then return end
        end
        if position == nil
            or type(position.x) ~= "number"
            or type(position.y) ~= "number"
            or type(position.z) ~= "number"
        then
            error("SCOM Ahwassa crash impact has no valid position")
        end
        wreck.scoFaBomberCrashImpactApplied = true
        SCO_FaBomberStockAreaDamage(
            position,
            contract.damageRadius,
            contract.damage,
            contract.army,
            contract.damageFriendly)
    end

    -- Native Import exposes this function from the collision module environment.
    -- Physics invokes it at actual contact, before an overkill actor is deleted.
    function SCO_ApplyAircraftCrashContact(wreck)
        if not wreck or wreck.deleted or not wreck.id
            or Props[wreck.id.index] ~= wreck or wreck.scoAircraftCrashActive ~= true
            or wreck.scoAircraftCrashContactPosition == nil then return end
        local position = wreck.scoAircraftCrashContactPosition
        Import("common/systems/scoMissingCrash.lua").Apply(wreck, position, ProcessAreaDamage)
        SCO_FaBomberApplyCrashImpact(wreck, position)
    end

    local function SCO_FaBomberApplyWaterCrashImpacts()
        local _, hasWater = Engine.HasWater()
        if not hasWater then return end
        local _, waterLevel = Engine.GetWaterLevel()
        if type(waterLevel) ~= "number" then
            error("SCOM Ahwassa crash water level is unavailable")
        end
        for _, wreck in pairs(Props) do
            local contract = SCO_FaBomberCrashImpactContract(wreck)
            if contract ~= nil
                and wreck.scoFaBomberCrashImpactApplied ~= true
            then
                local _, position =
                    Engine.GetGlobalEntityWorldPosition(wreck.id)
                if position ~= nil and position.y <= waterLevel then
                    local _, terrainHeight =
                        Engine.SampleTerrainHeight(position)
                    if type(terrainHeight) ~= "number" then
                        error("SCOM Ahwassa crash terrain height is unavailable")
                    end
                    if terrainHeight < waterLevel then
                        SCO_FaBomberApplyCrashImpact(wreck, {
                            x = position.x,
                            y = waterLevel,
                            z = position.z,
                        })
                    end
                end
            end
        end
    end

    local function SCO_FaBomberApplyTerrainCrashImpacts()
        for _, wreck in pairs(Props) do
            if wreck.crashImpactPosition ~= nil then
                SCO_FaBomberApplyCrashImpact(
                    wreck,
                    wreck.crashImpactPosition)
            end
        end
    end

    local function SCO_FaBomberGroundFireContract(projectile)
        local additions = projectile and projectile.tp
            and projectile.tp.additions
        local contract = additions and additions.scoFaBomberGroundFire
        if contract == nil then return nil end
        local impactContract = SCO_FaBomberImpactContract(projectile)
        if impactContract == nil
            or impactContract.runtimeProjectileId ~= "peb101"
            or contract.version ~= "1.0.0"
            or contract.sourceId ~= "TIFNapalmCarpetBomb01"
            or contract.runtimeProjectileId ~= "peb101"
            or contract.pulseCount ~= 15
            or contract.pulseDamage ~= 4
            or contract.pulseIntervalTicks ~= 1
            or contract.durationSeconds ~= 1.5
            or contract.damageRadius ~= 2.5
            or contract.damageFriendly ~= false
            or projectile.damage ~= 60
            or projectile.damageRadius ~= 2.5
        then
            error("Malformed SCOM Scorcher ground-fire projectile contract")
        end
        return contract
    end

    local function SCO_FaBomberGroundFireThread(
        position,
        projectileArmy,
        sourceUnit,
        contract)
        for _ = 1, contract.pulseCount do
            SCO_FaBomberStockAreaDamage(
                position,
                contract.damageRadius,
                contract.pulseDamage,
                projectileArmy,
                contract.damageFriendly,
                sourceUnit)
            WaitTicks(contract.pulseIntervalTicks)
        end
    end

    local function SCO_FaBomberRecoverScorcherTerrainImpacts()
        -- Native rays test only the previous/current segment. Once both
        -- endpoints are below terrain, another crossing cannot be found.
        -- Let native unit/shield/water/terrain events consume bombs first,
        -- then recover only surviving Scorcher bombs at the actual floor.
        for _, projectile in pairs(Projectiles) do
            local general = projectile.tp and projectile.tp.general
            if general and general.tpId == "peb101"
                and SCO_FaBomberGroundFireContract(projectile) ~= nil
            then
                local result, position =
                    Engine.GetGlobalEntityWorldPosition(projectile.id)
                if result == EngineErrorCode.Success and position ~= nil then
                    local terrainResult, height = Engine.SampleTerrainHeight(position)
                    if terrainResult == EngineErrorCode.Success
                        and type(height) == "number" and position.y <= height
                    then
                        local _, hasWater = Engine.HasWater()
                        local _, waterLevel = Engine.GetWaterLevel()
                        if not hasWater or (type(waterLevel) == "number" and height >= waterLevel) then
                            local contact = EngineClasses.float3(position.x, height + 0.01, position.z)
                            -- Replicate the contact before native destruction
                            -- so damage and the client impact share the floor.
                            if Engine.SetGlobalEntityPosition(projectile.id, contact)
                                == EngineErrorCode.Success
                            then
                                ProcessRayCollisionEvent({
                                    rayGlobalID = projectile.id,
                                    otherGlobalID = EngineClasses.GlobalID(),
                                    rayOrigin = contact,
                                    rayDirection = EngineClasses.float3(0, -1, 0),
                                    rayMaxDistance = 0.01,
                                    hitDistance = 0.01,
                                    colliderHitIndex = 0,
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    function CollisionUpdate()
        SCO_FaBomberCullWaterProjectiles()
        SCO_FaBomberApplyWaterCrashImpacts()
        local result = SCO_FaBomberStockCollisionUpdate()
        SCO_FaBomberRecoverScorcherTerrainImpacts()
        SCO_FaBomberApplyTerrainCrashImpacts()
        return result
    end

    function ProcessAreaDamage(
        position,
        radius,
        damage,
        army,
        damageFriendly,
        ...)
        local projectile = SCO_FaBomberActiveProjectile
        local impactContract = SCO_FaBomberImpactContract(projectile)
        local groundFireContract =
            SCO_FaBomberGroundFireContract(projectile)
        if impactContract ~= nil
            and radius == projectile.damageRadius
            and damage == projectile.damage
            and army == Armies[projectile.armyId]
        then
            if groundFireContract ~= nil then
                if projectile.scoFaBomberGroundFireStarted ~= true then
                    local projectileArmy = Armies[projectile.armyId]
                    if projectileArmy == nil then
                        error("SCOM Scorcher ground-fire projectile has no owning army")
                    end
                    projectile.scoFaBomberGroundFireStarted = true
                    local sourceUnit = projectile.sourceUnit or select(1, ...)
                    NewThread(
                        SCO_FaBomberGroundFireThread,
                        position,
                        projectileArmy,
                        sourceUnit,
                        groundFireContract)
                end
                -- Suppress the stock direct area call. The exact 15 source
                -- pulses above are the complete 60 damage for this bomb.
                return
            end
            return SCO_FaBomberStockAreaDamage(
                position,
                radius,
                damage,
                army,
                impactContract.damageFriendly,
                ...)
        end
        return SCO_FaBomberStockAreaDamage(
            position,
            radius,
            damage,
            army,
            damageFriendly,
            ...)
    end

    function ProcessRayCollisionEvent(event)
        local projectile = event and event.rayGlobalID
            and Projectiles[event.rayGlobalID.index]
        if SCO_FaBomberImpactContract(projectile) ~= nil then
            local projectileArmy = Armies[projectile.armyId]
            if projectileArmy == nil then
                error("SCOM Scorcher ground-fire projectile has no owning army")
            end
            local previous = SCO_FaBomberActiveProjectile
            SCO_FaBomberActiveProjectile = projectile
            local succeeded, result = pcall(
                SCO_FaBomberStockRayCollision,
                event)
            SCO_FaBomberActiveProjectile = previous
            if not succeeded then
                error(result)
            end
            return result
        end
        return SCO_FaBomberStockRayCollision(event)
    end

    function ProcessWaterCollisionEvent(event)
        if not event or not event.rayGlobalID then
            return SCO_FaBomberStockWaterCollision(event)
        end
        local result, root = Engine.GetGlobalEntityRoot(event.rayGlobalID)
        local projectile = result == EngineErrorCode.Success and root
            and Projectiles[root.index]
        if SCO_FaBomberImpactContract(projectile) == nil then
            return SCO_FaBomberStockWaterCollision(event)
        end
        local previous = SCO_FaBomberActiveProjectile
        SCO_FaBomberActiveProjectile = projectile
        local succeeded, value = pcall(SCO_FaBomberStockWaterCollision, event)
        SCO_FaBomberActiveProjectile = previous
        if not succeeded then error(value) end
        return value
    end

    rawset(
        SCO_FaBomberGroundFireEnvironment,
        "SCO_FaBomberGroundFireInstalled",
        "1.1.0")
end

-- SCOM support commander scope 2ffb334fdf8cc07a90e61ec3dc92d6a2e277fcae3a47e388b8e9956691355853 C482FC4C267EA7E946BFF65D9345DF3B1DB2D7E935614ADF6EC5F71A6C94E9A0
-- Supreme Commander Overhaul commander enhancements 1.0.0
-- Supreme Commander Overhaul commander missile collision 1.0.0
-- Append inside host/collisionUpdate.lua after its stock functions exist.  Only
-- runtime-tagged commander missiles are intercepted; every other projectile is
-- delegated to the previously composed collision handler.
local SCOCommanderAbilityCollisionEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderAbilityCollisionVersion = "1.0.0"
local SCOCommanderAbilityCollisionMarker = rawget(
    SCOCommanderAbilityCollisionEnvironment,
    "SCO_CommanderAbilityCollisionInstalled")
if SCOCommanderAbilityCollisionMarker ~= nil
    and SCOCommanderAbilityCollisionMarker
        ~= SCOCommanderAbilityCollisionVersion
then
    error("Unsupported SCOM commander-ability collision marker "
        .. tostring(SCOCommanderAbilityCollisionMarker))
end

if SCOCommanderAbilityCollisionMarker == nil then
    if type(ProcessRayCollisionEvent) ~= "function"
        or type(ProcessAreaDamage) ~= "function"
        or type(DestroyProjectile) ~= "function"
    then
        error("SCOM commander missile collision could not resolve stock functions")
    end

    local SCOStockRayCollision = ProcessRayCollisionEvent
    local SCOExpectedProfiles = {
        uefTactical = {
            donorProjectile = "pei141",
            damage = 6000,
            damageRadius = 2,
            damageFriendly = true,
        },
        uefBilly = {
            donorProjectile = "pei241",
            damage = 0,
            damageRadius = 0,
            damageFriendly = true,
            innerRing = { damage = 12000, radius = 15, ticks = 24,
                totalTime = 0 },
            outerRing = { damage = 250, radius = 25, ticks = 20,
                totalTime = 0 },
        },
        seraphimTactical = {
            donorProjectile = "pca341",
            damage = 6000,
            damageRadius = 3,
            damageFriendly = true,
        },
    }

    SCOExpectedProfiles.sacuSeraphimTactical = {donorProjectile="psf0141",damage=6000,damageRadius=3,damageFriendly=true}

    local function SCOFinite(value)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    local function SCOSameGlobalId(left, right)
        return left ~= nil and right ~= nil
            and left.index == right.index
            and left.version == right.version
    end

    local function SCORingMatches(actual, expected)
        if expected == nil then return actual == nil end
        return type(actual) == "table"
            and actual.damage == expected.damage
            and actual.radius == expected.radius
            and actual.ticks == expected.ticks
            and actual.totalTime == expected.totalTime
    end

    local function SCOCommanderMissileContract(projectile)
        local contract = projectile and projectile.scoCommanderMissile
        if contract == nil then return nil end
        local expected = type(contract) == "table"
            and SCOExpectedProfiles[contract.profileId] or nil
        local sourceId = type(contract) == "table" and contract.sourceId or nil
        if not expected
            or contract.version ~= SCOCommanderAbilityCollisionVersion
            or contract.donorProjectile ~= expected.donorProjectile
            or projectile.tp == nil
            or projectile.tp.general == nil
            or projectile.tp.general.tpId ~= expected.donorProjectile
            or contract.damage ~= expected.damage
            or contract.damageRadius ~= expected.damageRadius
            or contract.damageFriendly ~= expected.damageFriendly
            or not SCORingMatches(contract.innerRing, expected.innerRing)
            or not SCORingMatches(contract.outerRing, expected.outerRing)
            or type(sourceId) ~= "table"
            or type(sourceId.index) ~= "number"
            or type(sourceId.version) ~= "number"
        then
            error("Malformed SCOM commander missile contract")
        end
        return contract, expected
    end

    local function SCOHitPosition(rayCollisionEvent)
        local hitDistance = math.max(rayCollisionEvent.hitDistance - 0.01, 0)
        local position = math3D.add(
            rayCollisionEvent.rayOrigin,
            math3D.scale(rayCollisionEvent.rayDirection, hitDistance))
        local rayImpactTime = hitDistance / rayCollisionEvent.rayMaxDistance
        local tickImpactTime = math.clamp(
            rayImpactTime, 0.01, 0.99) * Constants.TickTimeStep
        return position, tickImpactTime
    end

    local function SCOSnapshotEnabledShields(position, radius)
        local snapshot = {}
        local collisionEvents = Engine.CircleCast(
            CollisionWorld.Collision,
            position,
            radius,
            CollisionLayer.Shields)
        for _, collisionEvent in ipairs(collisionEvents) do
            local shieldId = collisionEvent.colliderGlobalID
            local shield = shieldId and Shields[shieldId.index]
            if shield and shield.enabled then snapshot[shieldId.index] = true end
        end
        return snapshot
    end

    local function SCOProtectedBySnapshot(position, unit, snapshot)
        local collisionEvents = Engine.LineCast(
            CollisionWorld.Collision,
            position,
            unit:GetPosition(),
            CollisionLayer.Shields)
        for _, collisionEvent in ipairs(collisionEvents) do
            local shieldId = collisionEvent.otherGlobalID
            if shieldId and snapshot[shieldId.index] then return true end
        end
        return false
    end

    local function SCOApplyBillyRing(
        position, ring, shieldSnapshot, sourceUnit)
        local collisionEvents = Engine.CircleCast(
            CollisionWorld.Collision,
            position,
            ring.radius,
            CollisionLayer.Shields + CollisionLayer.Units)
        local units = {}
        local shields = {}
        for _, collisionEvent in ipairs(collisionEvents) do
            local colliderId = collisionEvent.colliderGlobalID
            local index = colliderId and colliderId.index
            local unit = index and Units[index]
            local shield = index and Shields[index]
            if unit then
                units[index] = unit
            elseif shield and shieldSnapshot[index] then
                shields[index] = shield
            end
        end
        for _, shield in pairs(shields) do
            if shield.enabled then shield:TakeDamage(ring.damage) end
        end
        for _, unit in pairs(units) do
            if not SCOProtectedBySnapshot(position, unit, shieldSnapshot) then
                unit:TakeDamage(
                    ring.damage, DestroyType.Kinetic, sourceUnit)
            end
        end
    end

    local function SCOIsAcceptedImpact(rayCollisionEvent, projectileArmy)
        local otherId = rayCollisionEvent.otherGlobalID
        if otherId and otherId.index == 0 then return true, nil end
        if not otherId or not Engine.IsValidGlobalID(otherId) then
            return false, nil
        end
        local unit = Units[otherId.index]
        if unit and projectileArmy:IsEnemy(unit.army) then return true, nil end
        local shield = Shields[otherId.index]
        if shield and shield.enabled and projectileArmy:IsEnemy(shield.army) then
            return true, otherId
        end
        return false, nil
    end

    ProcessRayCollisionEvent = function(rayCollisionEvent)
        local projectile = rayCollisionEvent
            and rayCollisionEvent.rayGlobalID
            and Projectiles[rayCollisionEvent.rayGlobalID.index]
        local contract, profile = SCOCommanderMissileContract(projectile)
        if not contract then return SCOStockRayCollision(rayCollisionEvent) end

        if SCOSameGlobalId(
            rayCollisionEvent.otherGlobalID,
            contract.sourceId)
        then
            return
        end
        local projectileArmy = Armies[projectile.armyId]
        if not projectileArmy then
            error("SCOM commander missile has no owning army")
        end
        local accepted =
            SCOIsAcceptedImpact(rayCollisionEvent, projectileArmy)
        if not accepted then return SCOStockRayCollision(rayCollisionEvent) end

        local hitPosition, tickImpactTime = SCOHitPosition(rayCollisionEvent)
        if not SCOFinite(hitPosition.x)
            or not SCOFinite(hitPosition.y)
            or not SCOFinite(hitPosition.z)
        then
            error("SCOM commander missile produced a non-finite impact")
        end
        if contract.profileId == "uefBilly" then
            -- Shields enabled at detonation start protect units from both
            -- synchronous rings even if the inner ring collapses the shield.
            local snapshot = SCOSnapshotEnabledShields(
                hitPosition, profile.outerRing.radius)
            SCOApplyBillyRing(
                hitPosition,
                profile.innerRing,
                snapshot,
                projectile.sourceUnit)
            SCOApplyBillyRing(
                hitPosition,
                profile.outerRing,
                snapshot,
                projectile.sourceUnit)
            if type(SendToAllClients) == "function" then
                SendToAllClients({ position = hitPosition }, "NukeAtHome")
            end
        else
            ProcessAreaDamage(
                hitPosition,
                profile.damageRadius,
                profile.damage,
                projectileArmy,
                true,
                projectile.sourceUnit)
        end
        DestroyProjectile(
            rayCollisionEvent.rayGlobalID, tickImpactTime, rayCollisionEvent.otherGlobalID)
    end

    rawset(
        SCOCommanderAbilityCollisionEnvironment,
        "SCO_CommanderAbilityCollisionInstalled",
        SCOCommanderAbilityCollisionVersion)
end

-- SCOM Field Fixes 1.2.4 - strategic impact on terrain and water.
local SCOFieldFixStrategicSiloCollisionEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOFieldFixStrategicSiloCollisionMarker = rawget(
    SCOFieldFixStrategicSiloCollisionEnvironment,
    "SCO_FieldFixStrategicSiloCollisionInstalled")
if SCOFieldFixStrategicSiloCollisionMarker ~= nil
    and SCOFieldFixStrategicSiloCollisionMarker ~= "1.2.4"
then
    error("Unsupported SCOM strategic silo collision marker "
        .. tostring(SCOFieldFixStrategicSiloCollisionMarker))
end
if SCOFieldFixStrategicSiloCollisionMarker == nil then
    if type(ProcessRayCollisionEvent) ~= "function"
        or type(DestroyProjectile) ~= "function"
    then
        error("SCOM strategic silo collision hook could not resolve stock functions")
    end

    local SCONukeExpected = {
        psn001 = { version = "1.0.0", innerDamage = 70000,
            innerRadius = 30, outerDamage = 500, outerRadius = 40 },
        psn002 = { version = "1.0.0", innerDamage = 70000,
            innerRadius = 30, outerDamage = 500, outerRadius = 40 },
        psn003 = { version = "1.1.0", innerDamage = 140000,
            innerRadius = 60, outerDamage = 1000, outerRadius = 80,
            impactProfile = "ApocalypseAeon2x" },
        psn004 = { version = "1.0.0", innerDamage = 70000,
            innerRadius = 30, outerDamage = 500, outerRadius = 40 },
        psn005 = { version = "1.0.0", innerDamage = 75000,
            innerRadius = 30, outerDamage = 500, outerRadius = 40 },
    }
    local SCOFaArtilleryExpected = {
        psk201 = {
            sourceId = "TIFArtillery01",
            sourceForcePulseCount = 0,
        },
        psm401 = {
            sourceId = "TIFHETacticalNuclearShell01",
            sourceForcePulseCount = 2,
            sourceForcePulseDamage = 1,
            sourceForcePulseRadius = 7,
            sourceForcePulseFriendly = true,
        },
    }
    -- script.lua publishes this bootstrap module through require(), which
    -- leaves a boolean in Import's shared package cache. Use its global API.
    local SCOSendToAllClients = SendToAllClients
    if type(SCOSendToAllClients) ~= "function" then
        error("SCOM strategic silo collision hook could not resolve networking")
    end
    local SCOStockRayCollision = ProcessRayCollisionEvent

    local function SCOSameGlobalId(left, right)
        return left ~= nil
            and right ~= nil
            and left.index == right.index
            and left.version == right.version
    end

    local function SCOGetNukeContract(projectile)
        local template = projectile and projectile.tp
        local additions = template and template.additions
        local nuke = additions and additions.scoStrategicNuke
        if nuke == nil then return nil end
        local tpId = template.general and template.general.tpId
        local expected = SCONukeExpected[tpId]
        if not expected
            or nuke.version ~= expected.version
            or nuke.damageFriendly ~= true
            or nuke.impactProfile ~= expected.impactProfile
            or type(nuke.innerDamage) ~= "table"
            or type(nuke.outerDamage) ~= "table"
            or nuke.innerDamage.amount ~= expected.innerDamage
            or nuke.innerDamage.radius ~= expected.innerRadius
            or nuke.innerDamage.ticks ~= 24
            or nuke.innerDamage.totalTime ~= 0
            or nuke.outerDamage.amount ~= expected.outerDamage
            or nuke.outerDamage.radius ~= expected.outerRadius
            or nuke.outerDamage.ticks ~= 20
            or nuke.outerDamage.totalTime ~= 0
        then
            error("Malformed SCOM strategic nuke projectile contract "
                .. tostring(tpId))
        end
        return nuke
    end

    local function SCOGetFaArtilleryContract(projectile)
        local template = projectile and projectile.tp
        local additions = template and template.additions
        local artillery = additions and additions.scoFaArtillery
        if artillery == nil then return nil end
        local tpId = template.general and template.general.tpId
        local expected = SCOFaArtilleryExpected[tpId]
        if not expected
            or artillery.version ~= "1.0.0"
            or artillery.sourceId ~= expected.sourceId
            or artillery.destroyOnWater ~= true
            or artillery.sourceForcePulseCount
                ~= expected.sourceForcePulseCount
            or artillery.sourceForcePulseDamage
                ~= expected.sourceForcePulseDamage
            or artillery.sourceForcePulseRadius
                ~= expected.sourceForcePulseRadius
            or artillery.sourceForcePulseFriendly
                ~= expected.sourceForcePulseFriendly
        then
            error("Malformed SCOM FA artillery projectile contract "
                .. tostring(tpId))
        end
        return artillery
    end

    local function SCOFaArtilleryHitPosition(rayCollisionEvent)
        local hitDistance = math.max(rayCollisionEvent.hitDistance - 0.01, 0)
        return math3D.add(
            rayCollisionEvent.rayOrigin,
            math3D.scale(rayCollisionEvent.rayDirection, hitDistance)),
            hitDistance
    end

    local function SCOFaArtilleryIsOrdinaryImpact(
        rayCollisionEvent,
        projectileArmy)
        local otherId = rayCollisionEvent.otherGlobalID
        if otherId and otherId.index == 0 then
            return true, nil
        end
        if not otherId or not Engine.IsValidGlobalID(otherId) then
            return false, nil
        end
        local unit = Units[otherId.index]
        local shield = Shields[otherId.index]
        if unit and projectileArmy:IsEnemy(unit.army) then
            return true, nil
        end
        if shield and shield.enabled
            and projectileArmy:IsEnemy(shield.army)
        then
            return true, otherId
        end
        return false, nil
    end

    local function SCOFaArtilleryApplySourceForcePulses(
        projectile,
        artillery,
        hitPosition,
        projectileArmy)
        for _ = 1, artillery.sourceForcePulseCount do
            ProcessAreaDamage(
                hitPosition,
                artillery.sourceForcePulseRadius,
                artillery.sourceForcePulseDamage,
                projectileArmy,
                artillery.sourceForcePulseFriendly == true,
                projectile.sourceUnit)
        end
    end

    local function SCOSnapshotEnabledShields(position, radius)
        local snapshot = {}
        local collisionEvents = Engine.CircleCast(
            CollisionWorld.Collision,
            position,
            radius,
            CollisionLayer.Shields)
        for _, collisionEvent in ipairs(collisionEvents) do
            local shieldId = collisionEvent.colliderGlobalID
            local shield = shieldId and Shields[shieldId.index]
            if shield and shield.enabled then
                snapshot[shieldId.index] = true
            end
        end
        return snapshot
    end

    local function SCOIsProtectedBySnapshot(position, unit, snapshot)
        local shieldCollisionEvents = Engine.LineCast(
            CollisionWorld.Collision,
            position,
            unit:GetPosition(),
            CollisionLayer.Shields)
        for _, collisionEvent in ipairs(shieldCollisionEvents) do
            local shieldId = collisionEvent.otherGlobalID
            if shieldId and snapshot[shieldId.index] then
                return true
            end
        end
        return false
    end

    local function SCOApplyNukeRing(position, radius, damage, shieldSnapshot, sourceUnit)
        local collisionEvents = Engine.CircleCast(
            CollisionWorld.Collision,
            position,
            radius,
            CollisionLayer.Shields + CollisionLayer.Units)
        local units = {}
        local shields = {}
        for _, collisionEvent in ipairs(collisionEvents) do
            local colliderId = collisionEvent.colliderGlobalID
            local index = colliderId and colliderId.index
            local unit = index and Units[index]
            local shield = index and Shields[index]
            if unit then
                units[index] = unit
            elseif shield and shieldSnapshot[index] then
                shields[index] = shield
            end
        end

        for _, shield in pairs(shields) do
            if shield.enabled then
                shield:TakeDamage(damage)
            end
        end
        for _, unit in pairs(units) do
            if not SCOIsProtectedBySnapshot(position, unit, shieldSnapshot) then
                unit:TakeDamage(damage, DestroyType.Kinetic, sourceUnit)
            end
        end
    end

    local function SCOResolveStrategicNukeBlast(projectile, nuke, hitPosition)
        -- Both collision worlds must apply the same two rings and one impact
        -- event before the projectile is destroyed.
        local shieldSnapshot = SCOSnapshotEnabledShields(
            hitPosition, nuke.outerDamage.radius)
        SCOApplyNukeRing(
            hitPosition,
            nuke.innerDamage.radius,
            nuke.innerDamage.amount,
            shieldSnapshot, projectile.sourceUnit)
        SCOApplyNukeRing(
            hitPosition,
            nuke.outerDamage.radius,
            nuke.outerDamage.amount,
            shieldSnapshot, projectile.sourceUnit)
        if not projectile.scoNukeTreeImpactApplied then
            projectile.scoNukeTreeImpactApplied = true
            Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown.NukeImpact(
                hitPosition, nuke.outerDamage.radius * 2)
        end
        if nuke.impactProfile == "ApocalypseAeon2x" then
            SCOSendToAllClients(
                { position = hitPosition }, "SCOApocalypseNukeAtHome")
        else
            SCOSendToAllClients(
                { position = hitPosition, scoStrategicNuke = true },
                "NukeAtHome")
        end
    end

    function _G.SCO_SourceApplyNukeRings(position, rings, sourceUnit)
        local radius = 0
        for _, ring in ipairs(rings) do radius = math.max(radius, ring.radius) end
        local snapshot = SCOSnapshotEnabledShields(position, radius)
        for _, ring in ipairs(rings) do
            SCOApplyNukeRing(position, ring.radius, ring.damage, snapshot, sourceUnit)
        end
    end

    function ProcessRayCollisionEvent(rayCollisionEvent)
        local projectile = rayCollisionEvent
            and rayCollisionEvent.rayGlobalID
            and Projectiles[rayCollisionEvent.rayGlobalID.index]
        local artillery = SCOGetFaArtilleryContract(projectile)
        if artillery and artillery.sourceForcePulseCount > 0 then
            local projectileArmy = Armies[projectile.armyId]
            if not projectileArmy then
                error("SCOM FA artillery projectile has no owning army")
            end
            local isImpact, hitShield = SCOFaArtilleryIsOrdinaryImpact(
                rayCollisionEvent,
                projectileArmy)
            if isImpact then
                local hitPosition, hitDistance =
                    SCOFaArtilleryHitPosition(rayCollisionEvent)
                local rayImpactTime = hitDistance
                    / rayCollisionEvent.rayMaxDistance
                local tickImpactTime = math.clamp(
                    rayImpactTime, 0.01, 0.99)
                    * Constants.TickTimeStep
                SCOFaArtilleryApplySourceForcePulses(
                    projectile,
                    artillery,
                    hitPosition,
                    projectileArmy)
                -- Own the accepted Mavor impact after capturing its target.
                -- Either one-point source pulse may kill that target or drop
                -- its shield; the following 12,000 blast must still resolve.
                ProcessAreaDamage(
                    hitPosition,
                    projectile.damageRadius,
                    projectile.damage,
                    projectileArmy,
                    projectile.damageFriendly == true,
                    projectile.sourceUnit)
                DestroyProjectile(
                    rayCollisionEvent.rayGlobalID,
                    tickImpactTime,
                    hitShield)
                if not hitShield then SCO_ArtilleryTreeImpact(projectile, hitPosition) end
                return
            end
        end
        local nuke = SCOGetNukeContract(projectile)
        if not nuke then
            return SCOStockRayCollision(rayCollisionEvent)
        end

        local otherId = rayCollisionEvent.otherGlobalID
        local sourceId = projectile.scoStrategicNukeSourceId
        if sourceId == nil or sourceId.index == nil or sourceId.version == nil then
            error("SCOM strategic nuke projectile has no exact source identity")
        end
        -- Spawned missiles can begin inside their source volume. Ignore only
        -- that exact versioned unit so the next terrain/target event owns impact.
        if SCOSameGlobalId(otherId, sourceId) then
            return
        end

        local projectileArmy = Armies[projectile.armyId]
        if not projectileArmy then
            error("SCOM strategic nuke projectile has no owning army")
        end
        local hitShield = nil
        local isImpact = otherId and otherId.index == 0
        if not isImpact
            and otherId
            and Engine.IsValidGlobalID(otherId)
        then
            local unit = Units[otherId.index]
            local shield = Shields[otherId.index]
            if unit then
                isImpact = true
            elseif shield and shield.enabled
                and projectileArmy:IsEnemy(shield.army)
            then
                isImpact = true
                hitShield = otherId
            end
        end
        if not isImpact then
            return SCOStockRayCollision(rayCollisionEvent)
        end

        local hitDistance = math.max(rayCollisionEvent.hitDistance - 0.01, 0)
        local hitPosition = math3D.add(
            rayCollisionEvent.rayOrigin,
            math3D.scale(rayCollisionEvent.rayDirection, hitDistance))
        local rayImpactTime = hitDistance / rayCollisionEvent.rayMaxDistance
        local tickImpactTime = math.clamp(rayImpactTime, 0.01, 0.99)
            * Constants.TickTimeStep
        SCOResolveStrategicNukeBlast(projectile, nuke, hitPosition)
        DestroyProjectile(
            rayCollisionEvent.rayGlobalID,
            tickImpactTime,
            rayCollisionEvent.otherGlobalID)
    end

    -- SCOM Field Fix: Supreme Commander artillery water impact 1.0.0
    -- Preserve native water sensing and wreck collisions; apply the two FA shells'
    -- source damage rules at the native child collider's projectile root.
    local function SCOProcessSpecialWaterImpact(rayCollisionEvent)
        if not _G.WaterGlobalID
            or rayCollisionEvent.otherGlobalID.index ~= _G.WaterGlobalID.index
        then
            return ProcessEnvironmentCollisionEvent(rayCollisionEvent)
        end
        local rootError, projectileId = Engine.GetGlobalEntityRoot(rayCollisionEvent.rayGlobalID)
        if rootError ~= EngineErrorCode.Success then return end
        local projectile = Projectiles[projectileId.index]
        local nuke = SCOGetNukeContract(projectile)
        if nuke then
            local sourceId = projectile.scoStrategicNukeSourceId
            if sourceId == nil or sourceId.index == nil
                or sourceId.version == nil
            then
                error("SCOM strategic nuke projectile has no exact source identity")
            end
            local _, level = Engine.GetWaterLevel()
            if rayCollisionEvent.colliderHitIndex ~= 0
                or rayCollisionEvent.rayOrigin.y <= level
            then
                return
            end
            local hitPosition, hitDistance =
                SCOFaArtilleryHitPosition(rayCollisionEvent)
            local _, terrainHeight = Engine.SampleTerrainHeight(hitPosition)
            if terrainHeight >= level then return end
            local tickImpactTime = math.clamp(
                hitDistance / rayCollisionEvent.rayMaxDistance, 0.01, 0.99)
                * Constants.TickTimeStep
            SCOResolveStrategicNukeBlast(projectile, nuke, hitPosition)
            projectile:Destroy(tickImpactTime, rayCollisionEvent.otherGlobalID)
            return
        end
        local artillery = SCOGetFaArtilleryContract(projectile)
        if not artillery then
            return ProcessEnvironmentCollisionEvent(rayCollisionEvent)
        end
        local _, level = Engine.GetWaterLevel()
        if rayCollisionEvent.colliderHitIndex ~= 0 or rayCollisionEvent.rayOrigin.y <= level then return end
        local hitPosition, hitDistance =
            SCOFaArtilleryHitPosition(rayCollisionEvent)
        local _, terrainHeight = Engine.SampleTerrainHeight(hitPosition)
        if terrainHeight >= level then return end
        local rayImpactTime = hitDistance / rayCollisionEvent.rayMaxDistance
        local tickImpactTime = math.clamp(rayImpactTime, 0.01, 0.99)
            * Constants.TickTimeStep
        if projectile.damageRadius > 0 then
            local projectileArmy = Armies[projectile.armyId]
            if not projectileArmy then
                error("SCOM artillery water impact has no owning army")
            end
            SCOFaArtilleryApplySourceForcePulses(
                projectile,
                artillery,
                hitPosition,
                projectileArmy)
            ProcessAreaDamage(
                hitPosition,
                projectile.damageRadius,
                projectile.damage,
                projectileArmy,
                projectile.damageFriendly == true,
                projectile.sourceUnit)
        end
        projectile:Destroy(tickImpactTime, rayCollisionEvent.otherGlobalID)
    end

    function CollisionUpdate()
        for _, muzzle in pairs(__Muzzles) do
            muzzle:Update()
        end

        local rayCollisionEvents = Engine.GetRayCollisionEventsForWorld(
            CollisionWorld.Collision)
        local waterCollisionEvents = {}
        local environmentCollisionWorld =
            CollisionWorld and CollisionWorld.EnvironmentCollision
        if environmentCollisionWorld ~= nil then
            waterCollisionEvents = Engine.GetRayCollisionEventsForWorld(
                environmentCollisionWorld)
        end

        -- Resolve the physically nearest collision world first for each shell.
        -- A nearer friendly collider can be ignored by the stock handler, so
        -- water events behind ordinary collisions are deferred, not discarded.
        local nearestCollisionDistance = {}
        for _, data in ipairs(rayCollisionEvents) do
            local projectileIndex = data.rayGlobalID.index
            local nearest = nearestCollisionDistance[projectileIndex]
            if nearest == nil or data.hitDistance < nearest then
                nearestCollisionDistance[projectileIndex] = data.hitDistance
            end
        end

        local deferredWaterCollisionEvents = {}
        for _, data in ipairs(waterCollisionEvents) do
            local _, projectileId = Engine.GetGlobalEntityRoot(data.rayGlobalID)
            local collisionDistance = projectileId and nearestCollisionDistance[projectileId.index]
            if collisionDistance == nil or data.hitDistance < collisionDistance then
                xpcall(SCOProcessSpecialWaterImpact, ErrorHandler, data)
            else
                table.insert(deferredWaterCollisionEvents, data)
            end
        end

        for _, data in ipairs(rayCollisionEvents) do
            xpcall(ProcessRayCollisionEvent, ErrorHandler, data)
        end
        for _, data in ipairs(deferredWaterCollisionEvents) do
            xpcall(SCOProcessSpecialWaterImpact, ErrorHandler, data)
        end

        if _G.WaterGlobalID then
            local waterVolumeEvents = Engine.GetVolumeCollisionEventsForWorld(
                CollisionWorld.EnvironmentCollision)
            for _, data in ipairs(waterVolumeEvents) do
                xpcall(ProcessWaterVolumeEvent, ErrorHandler, data)
            end
        end
    end

    rawset(
        SCOFieldFixStrategicSiloCollisionEnvironment,
        "SCO_FieldFixStrategicSiloCollisionInstalled",
        "1.2.4")
    _G.SCO_FieldFixStrategicSiloCollisionInstalled = "1.2.4"
end

-- SCOM tactical missiles 1.0.0. Append to host/collisionUpdate.lua after stock definitions.
do
    if _G.SCO_TacticalCollisionInstalled and _G.SCO_TacticalCollisionInstalled ~= "1.0.0" then
        error("Unsupported tactical collision version")
    end
    if not _G.SCO_TacticalCollisionInstalled then
        local oldRay = ProcessRayCollisionEvent
        local function api() return _G.SCO_Tactical end
        local function segmentDistance(a, b, p)
            local x,y,z = b.x-a.x,b.y-a.y,b.z-a.z
            local length = x*x+y*y+z*z
            local t = length > 0 and ((p.x-a.x)*x+(p.y-a.y)*y+(p.z-a.z)*z)/length or 0
            t = math.max(0, math.min(1,t))
            x,y,z = a.x+t*x-p.x,a.y+t*y-p.y,a.z+t*z-p.z
            return math.sqrt(x*x+y*y+z*z)
        end
        local function missileTurn(projectile, position, now)
            local state = projectile.scoTactical
            if not state.config.steppedTurn or state.turnDone or now < state.turnAt then return end
            if state.pendingTurn then
                Engine.SetHomingProjectileRotationSpeed(projectile.id,state.pendingTurn)
                state.pendingTurn = nil
                state.turnAt = now+0.1
                return
            end
            local dx,dz = position.x-state.target.x,position.z-state.target.z
            local distance = math.sqrt(dx*dx+dz*dz)
            -- Preserve source branch ordering: its >128 branch is shadowed by >50.
            if distance > 50 then state.pendingTurn,state.turnAt = 20,now+2
            elseif distance > 43 then state.pendingTurn,state.turnAt = 50,now+0.3
            else Engine.SetHomingProjectileRotationSpeed(projectile.id,100); state.turnDone=true end
        end
        local function decoyTarget(projectile, position)
            local state, tactical = projectile.scoTactical, api()
            if state.config.flareRadius then
                for _, missile in pairs(tactical.missiles) do
                    local mp = tactical.point(missile.id)
                    if mp and Armies[projectile.armyId]:IsEnemy(Armies[missile.armyId]) then
                        local dx,dy,dz = position.x-mp.x,position.y-mp.y,position.z-mp.z
                        if dx*dx+dy*dy+dz*dz <= state.config.flareRadius*state.config.flareRadius then
                            missile.scoTactical.decoy = projectile.id
                        end
                    end
                end
            elseif state.decoy then
                local decoy = __Entities.Projectiles[state.decoy.index]
                if decoy and tactical.same(decoy.id,state.decoy) then
                    local dp = tactical.point(decoy.id)
                    if dp then Engine.SetHomingProjectileTargetPosition(projectile.id,dp) end
                else state.decoy=nil; Engine.SetHomingProjectileTargetPosition(projectile.id,state.target) end
            end
        end
        local function intercept(projectile, position)
            local state, tactical = projectile.scoTactical, api()
            if not state.config.interceptor then return false end
            if _G.SCO_SourceIntercept then return _G.SCO_SourceIntercept(projectile,position,state.previous) end
            assert(not state.config.targetClass,"Source interceptor runtime missing")
            local targetId = state.interceptorTarget
            local target = targetId and __Entities.Projectiles[targetId.index]
            if target and tactical.same(target.id,targetId) and state.config.track then
                local p = tactical.point(target.id)
                if p then Engine.SetHomingProjectileTargetPosition(projectile.id,p) end
            end
            local ids = {}
            for index in pairs(tactical.missiles) do ids[#ids+1]=index end
            table.sort(ids)
            for _, index in ipairs(ids) do
                local missile = tactical.missiles[index]
                local mp = missile and tactical.point(missile.id)
                if mp and Armies[projectile.armyId]:IsEnemy(Armies[missile.armyId])
                    and segmentDistance(state.previous,position,mp) <= (missile.scoTactical.config.collisionRadius or 2)
                        + (state.config.collisionRadius or 0) then
                    tactical.HitMissile(missile,projectile.damage)
                    if not state.config.persistOnMissileImpact then
                        state.destroyed=true; projectile:Destroy(0); return true
                    end
                end
            end
            return false
        end
        function _G.SCO_TacticalInstallProjectileHooks(Projectile)
        if Projectile.scoTacticalHooksInstalled then return end
        local oldUpdate, oldDelete, oldWater = Projectile.Update, Projectile.Delete, Projectile.OnCrossedWaterline
        function Projectile:Update(...)
            local state = self.scoTactical
            if not state then return oldUpdate(self,...) end
            local tactical = api()
            local position = tactical.point(self.id)
            if not position then return oldUpdate(self,...) end
            if state.previous then
                local dt = Constants.TickTimeStep
                state.velocity = EngineClasses.float3((position.x-state.previous.x)/dt,
                    (position.y-state.previous.y)/dt,(position.z-state.previous.z)/dt)
            end
            if state.config.child and not state.childActivated and GetGameTimeSeconds() >= state.born+0.3 then
                state.childActivated=true
                Engine.SetHomingProjectileRotationSpeed(self.id,80)
                Engine.SetHomingProjectileMaxSpeed(self.id,25)
                Engine.SetHomingProjectileAcceleration(self.id,25)
                Engine.SetHomingProjectileTargetPosition(self.id,state.target)
            end
            missileTurn(self,position,GetGameTimeSeconds())
            decoyTarget(self,position)
            if intercept(self,position) then return end
            state.previous=position
            return oldUpdate(self,...)
        end
        function Projectile:Delete(...)
            if self.scoTactical and api() then api().missiles[self.id.index]=nil end
            return oldDelete(self,...)
        end
        function Projectile:OnCrossedWaterline(position,tick,waterGlobalID)
            local state=self.scoTactical
            if not state then return oldWater(self,position,tick,waterGlobalID) end
            if state.destroyed then return end
            if state.config.destroyOnWater==false and not (state.config.child and state.childActivated) then return end
            state.destroyed=true
            if not state.config.interceptor then
                ProcessAreaDamage(position,self.damageRadius,self.damage,Armies[self.armyId],true,state.source)
            end
            self:Destroy(tick,waterGlobalID)
        end
        Projectile.scoTacticalHooksInstalled = true
        end
        function ProcessRayCollisionEvent(event)
            local projectile = event and event.rayGlobalID and Projectiles[event.rayGlobalID.index]
            local state = projectile and projectile.scoTactical
            if not state then return oldRay(event) end
            local tactical = api()
            if tactical.same(event.otherGlobalID,state.sourceId) then return end
            if state.config.interceptor then
                -- Projectile interception is handled by the swept source-sphere test.
                -- Its shell cannot damage ordinary units or terrain.
                if event.otherGlobalID and event.otherGlobalID.index == 0 then
                    state.destroyed=true; projectile:Destroy(0)
                end
                return
            end
            if state.destroyed then return end
            local other = event.otherGlobalID
            local unit = other and Units[other.index]
            if unit and not Armies[projectile.armyId]:IsEnemy(unit.army) then return end
            local hitDistance=math.max(event.hitDistance-0.01,0)
            local position=math3D.add(event.rayOrigin,math3D.scale(event.rayDirection,hitDistance))
            local tick=event.rayMaxDistance>0 and math.max(0.01,math.min(0.99,hitDistance/event.rayMaxDistance))*Constants.TickTimeStep or 0
            state.destroyed=true
            ProcessAreaDamage(position,projectile.damageRadius,projectile.damage,
                Armies[projectile.armyId],true,state.source)
            projectile:Destroy(tick,other)
        end
        _G.SCO_TacticalCollisionInstalled="1.0.0"
    end
end

-- Append to host/collisionUpdate.lua after tactical collision, before HostProjectile loads.
do
    if not _G.SCO_SourceInterceptionCollisionInstall then
        local oldRay=ProcessRayCollisionEvent
        function _G.SCO_SourceInterceptionCollisionInstall(source)
            source.areaDamage=ProcessAreaDamage
        end
        function ProcessRayCollisionEvent(event)
            local projectile=event and event.rayGlobalID and Projectiles[event.rayGlobalID.index]
            local state=projectile and projectile.scoSourceNuke
            if not state then return oldRay(event) end
            if _G.SCO_Tactical.same(event.otherGlobalID,state.sourceId) then return end
            local distance=math.max(0,event.hitDistance-.01)
            local position=math3D.add(event.rayOrigin,math3D.scale(event.rayDirection,distance))
            local tick=event.rayMaxDistance>0 and math.min(.99,distance/event.rayMaxDistance)*Constants.TickTimeStep or 0
            _G.SCO_SourceInterception.NukeImpact(projectile,position,tick,event.otherGlobalID)
        end
    end
end

-- Observe completed impacts after the native damage owner. Never stun through a shield.
do
    local previousRay = ProcessRayCollisionEvent
    function ProcessRayCollisionEvent(event)
        local projectile = event and event.rayGlobalID and Projectiles[event.rayGlobalID.index]
        local spec = projectile and projectile.scoSourceStunSpec
        local hit = event and event.otherGlobalID
        local shield = hit and Shields[hit.index]
        local position
        if spec and not shield then
            local distance = math.max(0, event.hitDistance - 0.01)
            position = math3D.add(event.rayOrigin, math3D.scale(event.rayDirection, distance))
        end
        previousRay(event)
        -- Friendly/invalid collision events do not consume the projectile.
        if position and projectile.deleted and not projectile.scoSourceStunApplied then
            projectile.scoSourceStunApplied = true
            local runtime = _G.SCO_SourceStun
            assert(runtime and runtime.version == 1, "Source stun owner unavailable")
            runtime.Impact(projectile, position)
        end
    end
end

-- SCOM source aircraft crash collision installation 1.0.0
CollisionUpdate = Import('common/systems/scoMissingCrash.lua').WrapCollisionUpdate(CollisionUpdate, ProcessAreaDamage)
ProcessRayCollisionEvent = Import('common/systems/scoSourceProjectileMotion.lua').WrapRayCollision(ProcessRayCollisionEvent)
local sourceMotionCollision = CollisionUpdate
CollisionUpdate = function(...)
    sourceMotionCollision(...)
    Import('common/systems/scoSourceProjectileMotion.lua').TickDamage()
end

-- SCOM original Forged Alliance Overcharge collision 1.0.0.
-- Keep armor scaling local to this projectile; native damage has no damage-type argument.
do
    local previousRay = ProcessRayCollisionEvent
    local previousWater = ProcessWaterCollisionEvent
    local sourceIds = {
        uel0000 = "UEL0001", ucl0000 = "UAL0001",
        ugl0000 = "URL0001", usl0000 = "XSL0001",
    }

    local function projectileForEvent(event)
        if not event or not event.rayGlobalID then return nil end
        local projectile = Projectiles[event.rayGlobalID.index]
        if projectile then return projectile, event.rayGlobalID end
        local status, root = Engine.GetGlobalEntityRoot(event.rayGlobalID)
        if status == EngineErrorCode.Success and root then
            return Projectiles[root.index], root
        end
    end

    local function isOvercharge(projectile)
        local marker = projectile and projectile.scoOvercharge
        if marker == nil then return false end
        local source = projectile.sourceUnit
        local id = source and source.tp and source.tp.general and source.tp.general.tpId
        if type(marker) ~= "table" or marker.version ~= "1.0.0"
            or sourceIds[id] == nil or sourceIds[id] ~= marker.sourceId
            or projectile.damage ~= 12000 or projectile.damageRadius ~= 2.5 then
            error("SCOM Overcharge projectile contract mismatch")
        end
        return true
    end

    local function armorMultiplier(unit)
        local tags = unit and unit.tp and unit.tp.hasTags or {}
        if tags.COMMAND or tags.SCFA_COMMAND then return 0.033333 end
        if tags.STRUCTURE or tags.SCFA_STRUCTURE then return 0.066666 end
        return 1
    end

    local function impactPosition(event)
        local distance = math.max(event.hitDistance - 0.01, 0)
        local position = math3D.add(event.rayOrigin, math3D.scale(event.rayDirection, distance))
        local fraction = event.rayMaxDistance > 0 and distance / event.rayMaxDistance or 0
        return position, math.max(0.01, math.min(0.99, fraction)) * Constants.TickTimeStep
    end

    local function applyAreaDamage(projectile, position)
        local army = Armies[projectile.armyId]
        local radius, damage = projectile.damageRadius, projectile.damage
        local collisions = Engine.CapsuleCast(CollisionWorld.Collision, position,
            radius * 2 + 4, radius, GetIdentityQuaternion(), CollisionLayer.Shields + CollisionLayer.Units)
        local units, shields, seen = {}, {}, {}
        local distances, nearest = {}, {}
        for _, collision in ipairs(collisions) do
            local id = collision.colliderGlobalID.index
            local unit, shield = Units[id], Shields[id]
            if unit and not seen[unit] and army:IsEnemy(unit.army) then
                seen[unit] = true
                units[#units + 1] = unit
            elseif shield and not seen[shield] and shield.enabled and army:IsEnemy(shield.army) then
                seen[shield] = true
                shields[#shields + 1] = shield
                local center = shield:GetPosition()
                local distance = math3D.distance(position, center)
                local shieldRadius = shield.tp.radii.x
                distances[shield] = distance - shieldRadius
                nearest[shield] = distance == 0 and center
                    or math3D.add(center, math3D.scale(math3D.sub(position, center), shieldRadius / distance))
            end
        end
        table.sort(units, function(a, b) return a.id.index < b.id.index end)
        table.sort(shields, function(a, b)
            if distances[a] == distances[b] then return a.id.index < b.id.index end
            return distances[a] < distances[b]
        end)

        -- Store overflow in unscaled projectile-damage units. Every downstream
        -- receiver applies its own armor once, including overlapping shields.
        local overflows = {}
        for _, shield in ipairs(shields) do
            local incoming = GetDamageThroughShields(position, nearest[shield], damage, overflows)
            local multiplier = armorMultiplier(shield.owner)
            overflows[shield] = incoming > 0 and shield:TakeDamage(incoming * multiplier) / multiplier or 0
        end
        for _, unit in ipairs(units) do
            local incoming = #shields > 0
                and GetDamageThroughShields(position, unit:GetPosition(), damage, overflows) or damage
            if incoming > 0 then
                unit:TakeDamage(incoming * armorMultiplier(unit), DestroyType.Kinetic, projectile.sourceUnit)
            end
        end
    end

    ProcessRayCollisionEvent = function(event)
        local projectile, root = projectileForEvent(event)
        if not isOvercharge(projectile) then return previousRay(event) end
        if projectile.deleted or projectile.scoOverchargeImpacted then return end
        if projectile.id.index ~= root.index or projectile.id.version ~= root.version then return end
        if not Engine.IsValidGlobalID(event.rayGlobalID) then return end
        local hit = event.otherGlobalID
        local army = Armies[projectile.armyId]
        if hit.index ~= 0 then
            if not Engine.IsValidGlobalID(hit) then return end
            local unit, shield = Units[hit.index], Shields[hit.index]
            if not ((unit and army:IsEnemy(unit.army))
                or (shield and shield.enabled and army:IsEnemy(shield.army))) then return end
        end
        local position, tick = impactPosition(event)
        projectile.scoOverchargeImpacted = true
        applyAreaDamage(projectile, position)
        projectile:Destroy(tick, hit)
    end

    ProcessWaterCollisionEvent = function(event)
        local projectile, root = projectileForEvent(event)
        if not isOvercharge(projectile) then return previousWater(event) end
        if projectile.deleted or projectile.scoOverchargeImpacted then return end
        if projectile.id.index ~= root.index or projectile.id.version ~= root.version then return end
        if not Engine.IsValidGlobalID(event.rayGlobalID) then return end
        local level = Water.GetLevel()
        if level == nil or event.colliderHitIndex ~= 0 or event.rayOrigin.y <= level then return end
        local position, tick = impactPosition(event)
        local status, terrain = Engine.SampleTerrainHeight(position)
        if status ~= EngineErrorCode.Success or terrain >= level then return end
        -- All four original projectiles use DestroyOnWater: no detonation on entry.
        projectile.scoOverchargeImpacted = true
        projectile:Destroy(tick, event.otherGlobalID)
    end
end


return {
    CollisionUpdate = CollisionUpdate,
    ProcessAreaDamage = ProcessAreaDamage,
}

-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0
