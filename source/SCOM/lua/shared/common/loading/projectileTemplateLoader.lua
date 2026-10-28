local HierarchyTemplateLoader = Import("common/loading/hierarchyTemplateLoader.lua") 
local ParticleTemplateLoader  = Import("common/loading/particleTemplateLoader.lua")
local CollisionLayer = Import("common/layers.lua").CollisionLayer

local ProjectileIconHeightCutoff = 100
--This sorting priority mean projectiles always render on top of selected/hovered unit icons.
local ProjectileIconSortingPriority = 30000

_G.IntelVisionSignatureColliderName = "IntelVisionSignatureCollider"
local WaterColliderEntityName = "WaterCollider"

--- Converts loaded projectile template to a projectile prefab and registers it with the engine.
-- @param the projectile template
function CreateProjectilePrefab(tp)

    local hierarchyEntities = HierarchyTemplateLoader.GetHierarchyEntities(nil)

    table.insert(hierarchyEntities, EngineClasses.EntityTemplate(
        IntelVisionSignatureColliderName,
        TemplateHeadEntityName,
        EngineClasses.float3(0, 0, 0),
        1.0,
        GetIdentityQuaternion(),
        true
    ))

    table.insert(hierarchyEntities, EngineClasses.EntityTemplate(
        WaterColliderEntityName,
        TemplateHeadEntityName,
        EngineClasses.float3(0, 0, 0),
        1.0,
        GetIdentityQuaternion(),
        true
    ))

    local projectileTemplates = {
        EngineClasses.ProjectileTemplate(TemplateHeadEntityName,
            0,
            (tp.movement and tp.movement.acceleration) or 0,
            (tp.movement and tp.movement.rotationSpeed) or 0,
            (tp.movement and tp.movement.speedMax) or 0,
            EngineClasses.float3(0, 0, 0),
            (tp.movement and tp.movement.type) and ProjectileMovementType.Homing or ProjectileMovementType.Curved
        )
    }
    
    local rayColliderTemplates = {
        EngineClasses.RayColliderTemplate(TemplateHeadEntityName,
            EngineClasses.float3(0, 0, 0),
            CollisionWorld.Collision,
            CollisionLayer.Projectiles,
            CollisionLayer.Units + CollisionLayer.Shields,
            ColliderFlags.None
        ),
        EngineClasses.RayColliderTemplate(WaterColliderEntityName,
            EngineClasses.float3(0, 0, 0),
            CollisionWorld.EnvironmentCollision,
            CollisionLayer.Projectiles,
            CollisionLayer.Water,
            ColliderFlags.EventsDisabled
        )
    }

    -- SCOM Field Fix: Supreme Commander artillery water collider 1.0.0
    -- Use the native water child collider and preserve its event lifecycle.
    local globalVolumeColliderTemplates = {
        EngineClasses.VolumeColliderTemplate(
            IntelVisionSignatureColliderName,
            tp.collisionInfo.collisionSize,
            tp.collisionInfo.centerOffset,
            ColliderType.Box,
            CollisionWorld.IntelVision,
            CollisionLayer.None,
            1,
            ColliderFlags.None
        )
    }

    -- TODO: Proper culling radius?
    local cullingTemplates = {
        EngineClasses.CullingTemplate(TemplateHeadEntityName, 1.0)
    }

    local iconsTemplates = {
        EngineClasses.IconsTemplate(TemplateHeadEntityName, {
            EngineClasses.IconTemplate(tp.general.icon or "projectile",
                "",
                EngineClasses.float4(1, 1, 0, 1),
                EngineClasses.float2(0, 0),
                0.25,
                ProjectileIconHeightCutoff,
                nil,
                0,
                true, nil, nil, nil
            )
        }, 1.0, ProjectileIconSortingPriority, true)
    }

    local particleTemplates = nil
    if (tp.visuals.persistantEffects ~= nil) then
        particleTemplates = ParticleTemplateLoader.CreateParticleTemplatesProjectile(tp.visuals.persistantEffects)
    end

    if tp.audio and tp.audio.onImpact and tp.audio.onImpact.name then
        local AudioPrefabLoader = Import("common/loading/audioPrefabLoader.lua")
        local audio = tp.audio.onImpact
        audio.prefabID = AudioPrefabLoader.CreateOneShotAudioPrefab(tp.general.tpId .. "_onImpactAudio", audio.name, "impacts", audio.basePriority)
    end

    local prefabTemplate = EngineClasses.PrefabTemplate(tp.general.tpId,
        EngineClasses.HierarchyTemplate(SCO_FieldFixSeraphimProjectileHierarchy(tp, hierarchyEntities)),
        EngineClasses.GlobalTemplate(nil, nil, rayColliderTemplates, globalVolumeColliderTemplates, nil, projectileTemplates, nil, nil),
        EngineClasses.LocalTemplate(nil, nil, nil, nil, nil, cullingTemplates, nil, iconsTemplates, nil, nil, particleTemplates, nil, nil, nil, nil)
    )

    local projectilePrefabID = {}
    SCO_FieldFixAttachProjectileMesh(tp, prefabTemplate)
    SCO_SourceNukeParticles(tp, prefabTemplate)
    local errorCode = Engine.CreatePrefab(prefabTemplate, projectilePrefabID)
    return errorCode, projectilePrefabID
end
-- Supreme Commander Overhaul projectile field fixes 1.0.1

function SCO_FieldFixCybran(tp, tpId)
    local version = "1.0.4"

    if type(tp) ~= "table" then
        error("SCO Cybran field fix requires a template table.", 2)
    end
    if tpId == nil and type(tp.general) == "table" then
        tpId = tp.general.tpId
    end
    if type(tpId) ~= "string" or tpId == "" then
        error("SCO Cybran field fix requires a non-empty template id.", 2)
    end

    local factoryTiers = { ugs1511 = 1, ugs2511 = 2, ugs3511 = 3 }
    local targeted = factoryTiers[tpId] ~= nil
        or tpId == "ugs3101"
        or tpId == "ugl4011"
        or tpId == "ugl2101"
        or tpId == "pgh204"
        or tpId == "ugs2001"
        or tpId == "ugn3001"
        or tpId == "ugl1101"
        or tpId == "ugl3002"
        or tpId == "pgr303d"
        or tpId == "pgr303b"
        or tpId == "ugs2501"
        or tpId == "ugs3501"

    -- UGL4001 remains owned by the installed Monkeylord final-owner pack.
    if not targeted then
        return tp
    end

    local function fail(message)
        error("SCO Cybran field fix [" .. tpId .. "]: " .. message, 2)
    end

    local function requireTable(value, path)
        if type(value) ~= "table" then
            fail(path .. " must be a table")
        end
        return value
    end

    local function requireNumber(value, path)
        if type(value) ~= "number" then
            fail(path .. " must be a number")
        end
        return value
    end

    local function requireExact(value, expected, path)
        if value ~= expected then
            fail(path .. " must be " .. tostring(expected) .. ", found " .. tostring(value))
        end
    end

    local function isAllowed(value, allowed)
        for _, candidate in ipairs(allowed) do
            if value == candidate then
                return true
            end
        end
        return false
    end

    local function requireAllowed(value, allowed, path)
        if not isAllowed(value, allowed) then
            fail(path .. " has an unowned value " .. tostring(value))
        end
    end

    local function countKeys(value)
        local count = 0
        for _ in pairs(value) do
            count = count + 1
        end
        return count
    end

    local function weaponByProjectile(projectileId)
        local weapons = requireTable(tp.weapons, "weapons")
        local found = nil
        local foundIndex = nil
        for index, weapon in ipairs(weapons) do
            requireTable(weapon, "weapons[" .. index .. "]")
            if weapon.projectileTemplate == projectileId then
                if found ~= nil then
                    fail("weapons contains more than one " .. projectileId .. " weapon")
                end
                found = weapon
                foundIndex = index
            end
        end
        if found == nil then
            fail("weapons is missing the verified " .. projectileId .. " weapon")
        end
        return found, foundIndex
    end

    if tp.additions == nil then
        tp.additions = {}
    else
        requireTable(tp.additions, "additions")
    end
    local marker = tp.additions.scoFieldFixCybran
    if marker == version then
        return tp
    end
    if marker ~= nil then
        fail("unsupported additions.scoFieldFixCybran marker " .. tostring(marker))
    end

    if factoryTiers[tpId] then
        local tier = factoryTiers[tpId]
        local construction = requireTable(tp.construction, "construction")
        local broken = "Tags.GUARD * Tags.BUILDABLE_BY_T" .. tier .. "_FACTORY * Tags.LAND"
        local legacyRepaired = "Tags.GUARD * Tags.BUILDABLE_BY_T" .. tier
            .. "_FACTORY * ((Tags.LAND * Tags.MOBILE) + Tags.LAND_FACTORY)"
        -- Salem must carry LAND for TracksAmphibious validation, while its FA
        -- production ownership remains NAVAL. Keep naval mobiles out of the
        -- land branch instead of weakening Salem's movement or naval tags.
        local repaired = "Tags.GUARD * Tags.BUILDABLE_BY_T" .. tier
            .. "_FACTORY * (((Tags.LAND * Tags.MOBILE) - Tags.NAVAL) + Tags.LAND_FACTORY)"
        requireAllowed(construction.canBuild,
            { broken, legacyRepaired, repaired }, "construction.canBuild")
        construction.canBuild = repaired

        -- Material schemas vary between generated and loose templates. Only
        -- update a NormalScale key already present in a material-owned subtree.
        if tier > 1 then
            local visited = {}
            local function repairNormalScale(value, path)
                if type(value) ~= "table" or visited[value] then
                    return
                end
                visited[value] = true
                for _, field in ipairs({ "NormalScale", "_NormalScale", "normalScale" }) do
                    if value[field] ~= nil then
                        requireNumber(value[field], path .. "." .. field)
                        value[field] = 1.25
                    end
                end
                for key, child in pairs(value) do
                    if type(child) == "table" then
                        repairNormalScale(child, path .. "." .. tostring(key))
                    end
                end
            end
            if tp.materials ~= nil then repairNormalScale(tp.materials, "materials") end
            if type(tp.visuals) == "table" then
                if tp.visuals.materials ~= nil then
                    repairNormalScale(tp.visuals.materials, "visuals.materials")
                end
                if tp.visuals.material ~= nil then
                    repairNormalScale(tp.visuals.material, "visuals.material")
                end
            end
            if tp.additions.materials ~= nil then
                repairNormalScale(tp.additions.materials, "additions.materials")
            end
        end

    elseif tpId == "ugs3101" then
        local weapon, weaponIndex = weaponByProjectile("pcg312")
        requireExact(weapon.rangeMin, 150, "Disruptor rangeMin")
        requireExact(weapon.rangeMax, 700, "Disruptor rangeMax")
        requireExact(weapon.projectileLifetime, 120,
            "Disruptor projectileLifetime")
        local controllers = requireTable(weapon.aimControllers, "weapons[" .. weaponIndex .. "].aimControllers")
        if #controllers ~= 1 then
            fail("Disruptor must have exactly one verified aim controller")
        end
        local controller = requireTable(controllers[1], "weapons[" .. weaponIndex .. "].aimControllers[1]")
        requireExact(controller.aimBone, "Turret_Muzzle", "Disruptor aimBone")
        requireExact(controller.yawBone, "Turret", "Disruptor yawBone")
        requireExact(controller.pitchBone, "Turret_Barrel", "Disruptor pitchBone")
        requireExact(controller.defaultYawAdjustment, 0,
            "Disruptor defaultYawAdjustment")
        requireExact(controller.yawMin, -180, "Disruptor yawMin")
        requireExact(controller.yawMax, 180, "Disruptor yawMax")
        requireAllowed(controller.yawSpeed, { 3, 5 }, "Disruptor yawSpeed")
        requireExact(controller.leadTarget, false, "Disruptor leadTarget")
        if controller.aimGravity ~= nil then
            local gravity = requireTable(controller.aimGravity,
                "Disruptor aimGravity")
            requireExact(gravity.x, 0, "Disruptor aimGravity.x")
            requireExact(gravity.y, -1, "Disruptor aimGravity.y")
            requireExact(gravity.z, 0, "Disruptor aimGravity.z")
        end
        requireAllowed(controller.defaultPitchAdjustment, { 30, 0, -30 }, "Disruptor defaultPitchAdjustment")
        requireAllowed(controller.pitchMin, { 0, -25, -60 }, "Disruptor pitchMin")
        requireAllowed(controller.pitchMax, { 60, 80, 0 }, "Disruptor pitchMax")
        requireAllowed(controller.poseResetTime, { -1, 3 }, "Disruptor poseResetTime")
        requireAllowed(controller.projectileSpeed, { 60, 30 },
            "Disruptor projectileSpeed")
        requireExact(controller.solverType, "HighArc", "Disruptor solverType")
        requireExact(controller.reduceMuzzleVelocityToTarget, true,
            "Disruptor velocity reduction")
        requireNumber(controller.aimTolerance, "Disruptor aimTolerance")
        if controller.aimTolerance <= 0 then
            fail("Disruptor aimTolerance must be positive")
        end
        local groups = requireTable(weapon.muzzleGroups,
            "weapons[" .. weaponIndex .. "].muzzleGroups")
        if #groups ~= 1 then
            fail("Disruptor must have exactly one verified muzzle group")
        end
        local groupMuzzles = requireTable(groups[1].muzzles,
            "weapons[" .. weaponIndex .. "].muzzleGroups[1].muzzles")
        if #groupMuzzles ~= 1 or groupMuzzles[1] ~= "Turret_Muzzle" then
            fail("Disruptor muzzle group must contain only Turret_Muzzle")
        end
        local muzzles = requireTable(weapon.muzzles,
            "weapons[" .. weaponIndex .. "].muzzles")
        local muzzle = requireTable(muzzles.Turret_Muzzle,
            "weapons[" .. weaponIndex .. "].muzzles.Turret_Muzzle")
        requireExact(muzzle.aimController, "Turret_Muzzle",
            "Disruptor muzzle aimController")
        -- The prior field fix inverted the complete imported pitch envelope.
        -- HighArc can never acquire a level target when its maximum pitch is
        -- zero, so preserve the final owner's verified runtime articulation.
        controller.defaultPitchAdjustment = 0
        controller.pitchMin = -25
        controller.pitchMax = 80
        controller.pitchSpeed = 5
        controller.poseResetTime = -1
        controller.projectileSpeed = 30
        controller.aimTolerance = 2
        controller.leadTarget = false
        controller.aimGravity = { x = 0, y = -1, z = 0 }
        controller.defaultYawAdjustment = 0
        controller.yawMin = -180
        controller.yawMax = 180
        controller.yawSpeed = 5
        weapon.muzzleGroups = { { muzzles = { "Turret_Muzzle" } } }
        weapon.muzzles = {
            Turret_Muzzle = { aimController = "Turret_Muzzle" },
        }

    elseif tpId == "ugl4011" then
        local weapons = requireTable(tp.weapons, "weapons")
        local weapon = requireTable(weapons[1], "weapons[1]")
        requireExact(weapon.rangeMin, 100, "Scathis rangeMin")
        requireExact(weapon.rangeMax, 4000, "Scathis rangeMax")
        requireExact(weapon.projectileLifetime, 100,
            "Scathis projectileLifetime")
        local controllers = requireTable(weapon.aimControllers, "weapons[1].aimControllers")
        if #controllers ~= 1 then
            fail("Scathis must have exactly one verified aim controller")
        end
        local controller = requireTable(controllers[1], "weapons[1].aimControllers[1]")
        requireExact(controller.aimBone, "Turret_Aim_Barrel_Muzzle", "Scathis aimBone")
        requireExact(controller.pitchBone, "Turret_Aim_Barrel", "Scathis pitchBone")
        requireExact(controller.yawBone, "Turret_Aim", "Scathis yawBone")
        requireAllowed(controller.aimTolerance, { 0, 0.1 }, "Scathis aimTolerance")
        requireExact(controller.pitchMin, -45, "Scathis pitchMin")
        requireAllowed(controller.pitchMax, { 45, 85 }, "Scathis pitchMax")
        requireExact(controller.projectileSpeed, 160, "Scathis projectileSpeed")
        requireExact(controller.solverType, "HighArc", "Scathis solverType")
        requireExact(controller.reduceMuzzleVelocityToTarget, true,
            "Scathis velocity reduction")
        if controller.aimGravity ~= nil then
            local gravity = requireTable(controller.aimGravity,
                "Scathis aimGravity")
            requireExact(gravity.x, 0, "Scathis aimGravity.x")
            requireExact(gravity.y, -4.9, "Scathis aimGravity.y")
            requireExact(gravity.z, 0, "Scathis aimGravity.z")
        end
        controller.aimTolerance = 0.1
        controller.pitchMax = 85
        controller.aimGravity = { x = 0, y = -4.9, z = 0 }

        local groups = requireTable(weapon.muzzleGroups,
            "weapons[1].muzzleGroups")
        local muzzles = requireTable(weapon.muzzles, "weapons[1].muzzles")
        if #groups ~= 7 or countKeys(muzzles) ~= 7 then
            fail("Scathis requires one central and six outer muzzle routes")
        end
        local central = requireTable(groups[1],
            "weapons[1].muzzleGroups[1]")
        local centralMuzzles = requireTable(central.muzzles,
            "weapons[1].muzzleGroups[1].muzzles")
        if #centralMuzzles ~= 1 then
            fail("Scathis central muzzle group must contain exactly one muzzle")
        end
        requireExact(centralMuzzles[1], "Turret_Aim_Barrel_Muzzle",
            "Scathis central projectile muzzle")

        local barrelOrder = { "F", "E", "D", "C", "B", "A" }
        local visibleOrder = {}
        for index, barrel in ipairs(barrelOrder) do
            local legacy = "Turret_Barrel_" .. barrel .. "_B03"
            local visible = "Turret_Barrel_" .. barrel .. "_Muzzle"
            local group = requireTable(groups[index + 1],
                "weapons[1].muzzleGroups[" .. tostring(index + 1) .. "]")
            local groupMuzzles = requireTable(group.muzzles,
                "Scathis outer muzzle group " .. tostring(index))
            if #groupMuzzles ~= 1 then
                fail("Scathis outer muzzle group " .. tostring(index)
                    .. " must contain exactly one muzzle")
            end
            requireExact(groupMuzzles[1], legacy,
                "Scathis source fake-muzzle order " .. tostring(index))
            local legacyRoute = requireTable(muzzles[legacy],
                "weapons[1].muzzles." .. legacy)
            requireExact(legacyRoute.aimController,
                "Turret_Aim_Barrel_Muzzle",
                "Scathis fake-muzzle aim route " .. tostring(index))

            groupMuzzles[1] = visible
            muzzles[legacy] = nil
            muzzles[visible] = {
                aimController = "Turret_Aim_Barrel_Muzzle",
            }
            visibleOrder[index] = visible
        end
        tp.additions.scoScathisVisibleMuzzleParity = {
            version = "1.0.0",
            ballisticMuzzle = "Turret_Aim_Barrel_Muzzle",
            barrelOrder = visibleOrder,
            recoilSuffix = "_B02",
        }

    elseif tpId == "ugl2101" then
        local weapon, weaponIndex = weaponByProjectile("pgh204")
        local controllers = requireTable(weapon.aimControllers, "weapons[" .. weaponIndex .. "].aimControllers")
        if #controllers ~= 1 then
            fail("Hoplite must have exactly one verified aim controller")
        end
        local controller = requireTable(controllers[1], "weapons[" .. weaponIndex .. "].aimControllers[1]")
        requireExact(controller.aimBone, "Turret_Muzzle_01", "Hoplite aimBone")
        requireExact(controller.yawBone, "Turret", "Hoplite yawBone")
        requireExact(controller.pitchBone, "Turret_Barrel", "Hoplite pitchBone")
        requireExact(controller.pitchMin, -45, "Hoplite pitchMin")
        requireExact(controller.pitchMax, 45, "Hoplite pitchMax")
        requireAllowed(controller.projectileSpeed, { 15, 14 }, "Hoplite projectileSpeed")
        requireAllowed(controller.solverType, { "LowArc", "HighArc" }, "Hoplite solverType")
        requireExact(weapon.rangeMax, 37, "Hoplite rangeMax")
        requireAllowed(weapon.projectileLifetime, { 2.8366666666666664, 4.25 }, "Hoplite projectileLifetime")
        if controller.aimGravity ~= nil then
            local gravity = requireTable(controller.aimGravity, "Hoplite aimGravity")
            requireExact(gravity.x, 0, "Hoplite aimGravity.x")
            requireExact(gravity.y, -4.9, "Hoplite aimGravity.y")
            requireExact(gravity.z, 0, "Hoplite aimGravity.z")
        end
        controller.aimGravity = { x = 0, y = -4.9, z = 0 }
        controller.projectileSpeed = 14
        controller.reduceMuzzleVelocityToTarget = true
        -- At range 37 the high solution is about 56 degrees and 4.6 seconds,
        -- outside this rig's 45-degree pitch cap and the bounded lifetime.
        -- The low solution keeps the requested gravity while remaining valid.
        controller.solverType = "LowArc"
        weapon.projectileLifetime = 4.25

    elseif tpId == "pgh204" then
        local movement = requireTable(tp.movement, "movement")
        requireAllowed(movement.acceleration, { 120, 0 }, "movement.acceleration")
        requireAllowed(movement.gravityMultiplier, { 0, 1 }, "movement.gravityMultiplier")
        requireAllowed(movement.speedMax, { 45, 18 }, "movement.speedMax")
        if movement.type ~= nil and movement.type ~= "TargetEntity" then
            fail("movement.type has an unowned value " .. tostring(movement.type))
        end
        if movement.alignToVelocity ~= nil then
            requireExact(movement.alignToVelocity, true, "movement.alignToVelocity")
        end
        if movement.rotationSpeed ~= nil then
            requireExact(movement.rotationSpeed, 0, "movement.rotationSpeed")
        end
        movement.acceleration = 0
        movement.gravityMultiplier = 1
        movement.speedMax = 18
        movement.type = nil

    elseif tpId == "ugs2001" then
        local weapons = requireTable(tp.weapons, "weapons")
        local weapon = requireTable(weapons[1], "weapons[1]")
        local controllers = requireTable(weapon.aimControllers, "weapons[1].aimControllers")
        if #controllers ~= 1 then
            fail("Cerberus must have exactly one verified aim controller")
        end
        local controller = requireTable(controllers[1], "weapons[1].aimControllers[1]")
        requireExact(controller.aimBone, "Turret_Muzzle01", "Cerberus aimBone")
        requireExact(controller.yawBone, "Turret_B01", "Cerberus yawBone")
        requireExact(controller.pitchBone, "Turret_B02", "Cerberus pitchBone")
        local aggregateDamage = 5.5
        local simultaneousBeamDamage = aggregateDamage / 3
        requireAllowed(weapon.damage, { aggregateDamage, simultaneousBeamDamage }, "Cerberus damage")
        requireExact(weapon.reloadTime, 0.6666666666666666, "Cerberus reloadTime")
        requireExact(weapon.beamLifetime, 6, "Cerberus beamLifetime")
        requireExact(weapon.muzzleSalvoSize, 1, "Cerberus muzzleSalvoSize")
        local expected = { "Turret_Muzzle01", "Turret_Muzzle02", "Turret_Muzzle03" }
        local muzzles = requireTable(weapon.muzzles, "weapons[1].muzzles")
        if countKeys(muzzles) ~= 3 then
            fail("Cerberus muzzles must contain exactly the three verified barrels")
        end
        for _, muzzle in ipairs(expected) do
            local entry = requireTable(muzzles[muzzle], "weapons[1].muzzles." .. muzzle)
            requireExact(entry.aimController, "Turret_Muzzle01", "Cerberus " .. muzzle .. " aimController")
        end
        local groups = requireTable(weapon.muzzleGroups, "weapons[1].muzzleGroups")
        if #groups ~= 3 and #groups ~= 1 then
            fail("Cerberus muzzleGroups must be the verified split or simultaneous form")
        end
        local flattened = {}
        for groupIndex, group in ipairs(groups) do
            local groupMuzzles = requireTable(group.muzzles, "weapons[1].muzzleGroups[" .. groupIndex .. "].muzzles")
            for _, muzzle in ipairs(groupMuzzles) do
                flattened[#flattened + 1] = muzzle
            end
        end
        if #flattened ~= 3 then
            fail("Cerberus muzzleGroups must reference exactly three muzzles")
        end
        for index, muzzle in ipairs(expected) do
            requireExact(flattened[index], muzzle, "Cerberus muzzle order " .. index)
        end
        local beam = requireTable(weapon.beam, "weapons[1].beam")
        local subMesh = requireTable(beam.subMesh, "weapons[1].beam.subMesh")
        if #subMesh ~= 2 then
            fail("Cerberus beam must have the verified two-layer mesh")
        end
        requireExact(subMesh[1].model, "VFX/Models/Beams/BeamBasicLongSingle.sanmodel", "Cerberus beam core model")
        requireExact(subMesh[2].model, "VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel", "Cerberus beam aura model")
        requireAllowed(subMesh[1].material, {
            "VFX/Materials/Beam/Beam ugs1201_01.sanmaterial",
            "VFX/Materials/Beam/Beam ugl3001_01.sanmaterial",
        }, "Cerberus beam core material")
        requireAllowed(subMesh[2].material, {
            "VFX/Materials/Beam/Beam ugs1201_02.sanmaterial",
            "VFX/Materials/Beam/Beam ugl3001_02.sanmaterial",
        }, "Cerberus beam aura material")
        -- Sanctuary applies weapon.damage independently for every enabled
        -- HostBeam. Preserve the prior one-beam aggregate while enabling all
        -- three visual emitters together.
        weapon.damage = simultaneousBeamDamage
        weapon.muzzleGroups = { { muzzles = expected } }
        subMesh[1].material = "VFX/Materials/Beam/Beam ugl3001_01.sanmaterial"
        subMesh[2].material = "VFX/Materials/Beam/Beam ugl3001_02.sanmaterial"

    elseif tpId == "ugn3001" then
        local weapons = requireTable(tp.weapons, "weapons")
        local function repairBattery(weaponIndex, prefix)
            local weapon = requireTable(weapons[weaponIndex], "weapons[" .. weaponIndex .. "]")
            requireExact(weapon.projectileTemplate, "pgd311", prefix .. " projectileTemplate")
            -- Native Guard Grinder artillery: a registered, media-backed
            -- heavy cannon report, played by each real firing muzzle.
            weapon.audio = weapon.audio or {}
            weapon.audio.onFire = { name = "agom2234", looping = false }
            local controllers = requireTable(weapon.aimControllers, "weapons[" .. weaponIndex .. "].aimControllers")
            if #controllers ~= 3 then
                fail(prefix .. " battery must have three aim controllers")
            end
            local byAim = {}
            for index, controller in ipairs(controllers) do
                requireTable(controller, "weapons[" .. weaponIndex .. "].aimControllers[" .. index .. "]")
                if byAim[controller.aimBone] ~= nil then
                    fail(prefix .. " battery duplicates aimBone " .. tostring(controller.aimBone))
                end
                byAim[controller.aimBone] = controller
            end
            local muzzles = requireTable(weapon.muzzles, "weapons[" .. weaponIndex .. "].muzzles")
            if countKeys(muzzles) ~= 3 then
                fail(prefix .. " battery must have exactly three muzzle entries")
            end
            local seen = {}
            for barrel = 1, 3 do
                local muzzle = prefix .. "_Muzzle0" .. barrel
                local pitch = prefix .. "_Turret_Barrel0" .. barrel
                local controller = requireTable(byAim[muzzle], prefix .. " controller " .. muzzle)
                requireExact(controller.yawBone, prefix .. "_Turret", prefix .. " yawBone")
                requireAllowed(controller.pitchBone, { prefix .. "_Turret_Barrel02", pitch }, prefix .. " pitchBone")
                local muzzleEntry = requireTable(muzzles[muzzle], prefix .. " muzzle " .. muzzle)
                requireAllowed(muzzleEntry.aimController, { muzzle, prefix .. "_Muzzle02" }, prefix .. " muzzle aimController")
                controller.pitchBone = pitch
                -- Native animated-bone rendering adds every controller's yaw.
                -- One center-barrel owner prevents three shared yaw rotations
                -- while each physical barrel keeps its independent pitch.
                if barrel ~= 2 then controller.yawBone = nil end
                muzzleEntry.aimController = muzzle
                seen[muzzle] = false
            end
            local groups = requireTable(weapon.muzzleGroups, "weapons[" .. weaponIndex .. "].muzzleGroups")
            for groupIndex, group in ipairs(groups) do
                local groupMuzzles = requireTable(group.muzzles, "weapons[" .. weaponIndex .. "].muzzleGroups[" .. groupIndex .. "].muzzles")
                for _, muzzle in ipairs(groupMuzzles) do
                    if seen[muzzle] == nil or seen[muzzle] then
                        fail(prefix .. " muzzleGroups contains an unknown or duplicate muzzle " .. tostring(muzzle))
                    end
                    seen[muzzle] = true
                end
            end
            for muzzle, present in pairs(seen) do
                if not present then fail(prefix .. " muzzleGroups is missing " .. muzzle) end
            end
        end
        repairBattery(1, "Front")
        repairBattery(2, "Back")

        local torpedo = requireTable(weapons[5], "weapons[5]")
        requireExact(torpedo.projectileTemplate, "pgi201", "Galaxy torpedo projectileTemplate")
        requireExact(torpedo.rangeMax, 60, "Galaxy torpedo rangeMax")
        local torpedoMuzzles = requireTable(torpedo.muzzles, "weapons[5].muzzles")
        local ordered = {
            "Left_Attachpoint01", "Right_Attachpoint01",
            "Left_Attachpoint02", "Right_Attachpoint02",
        }
        if countKeys(torpedoMuzzles) ~= #ordered then
            fail("Galaxy torpedo weapon must have exactly four verified root attachpoints")
        end
        local allowedMuzzles = {}
        for _, muzzle in ipairs(ordered) do allowedMuzzles[muzzle] = false end
        local groups = requireTable(torpedo.muzzleGroups, "weapons[5].muzzleGroups")
        for groupIndex, group in ipairs(groups) do
            local groupMuzzles = requireTable(group.muzzles, "weapons[5].muzzleGroups[" .. groupIndex .. "].muzzles")
            for _, muzzle in ipairs(groupMuzzles) do
                if allowedMuzzles[muzzle] == nil or allowedMuzzles[muzzle] then
                    fail("Galaxy torpedo muzzleGroups contains an unknown or duplicate muzzle " .. tostring(muzzle))
                end
                allowedMuzzles[muzzle] = true
            end
        end
        for muzzle, present in pairs(allowedMuzzles) do
            if not present then fail("Galaxy torpedo muzzleGroups is missing " .. muzzle) end
        end
        local oldControllers = requireTable(torpedo.aimControllers, "weapons[5].aimControllers")
        if #oldControllers ~= 1 and #oldControllers ~= 4 then
            fail("Galaxy torpedo weapon must use the verified shared or per-muzzle controller form")
        end
        if #oldControllers == 1 then
            local old = requireTable(oldControllers[1], "weapons[5].aimControllers[1]")
            requireExact(old.aimBone, "Left_Attachpoint01", "Galaxy stock torpedo aimBone")
            requireExact(old.pitchBone, "Left_Attachpoint02", "Galaxy stock torpedo pitchBone")
            requireExact(old.yawBone, "Left_Attachpoint02", "Galaxy stock torpedo yawBone")
        end
        local controllers = {}
        for _, muzzle in ipairs(ordered) do
            controllers[#controllers + 1] = {
                aimBone = muzzle,
                aimTolerance = 180,
                defaultPitchAdjustment = 0,
                defaultYawAdjustment = 0,
                leadTarget = false,
                pitchBone = "Root",
                pitchMax = 0,
                pitchMin = 0,
                pitchSpeed = 0,
                poseResetTime = -1,
                projectileSpeed = 5,
                solverType = "NoArc",
                yawBone = "Root",
                yawMax = 0,
                yawMin = 0,
                yawSpeed = 0,
            }
            requireTable(torpedoMuzzles[muzzle], "weapons[5].muzzles." .. muzzle).aimController = muzzle
        end
        torpedo.aimControllers = controllers

    elseif tpId == "ugl1101" then
        local weapon, weaponIndex = weaponByProjectile("pcg103")
        requireAllowed(weapon.damage, { 195, 100 }, "weapons[" .. weaponIndex .. "].damage")
        requireAllowed(weapon.damageRadius, { 2, 1.5 }, "weapons[" .. weaponIndex .. "].damageRadius")
        requireExact(weapon.rangeMin, 5, "Medusa rangeMin")
        requireExact(weapon.rangeMax, 30, "Medusa rangeMax")
        local controllers = requireTable(weapon.aimControllers, "weapons[" .. weaponIndex .. "].aimControllers")
        if #controllers ~= 1 then fail("Medusa must have exactly one verified aim controller") end
        requireExact(controllers[1].solverType, "HighArc", "Medusa solverType")
        weapon.damage = 100
        weapon.damageRadius = 1.5

    elseif tpId == "ugl3002" then
        local disintegrator, disintegratorIndex = weaponByProjectile("pgr303d")
        local bolter, bolterIndex = weaponByProjectile("pgr303b")
		local disintegratorGroups = requireTable(disintegrator.muzzleGroups,
			"weapons[" .. disintegratorIndex .. "].muzzleGroups")
		if #disintegratorGroups ~= 1 then
			fail("Loyalist disintegrator must have exactly one muzzle group")
		end
		local disintegratorMuzzles = requireTable(
			requireTable(disintegratorGroups[1],
				"weapons[" .. disintegratorIndex .. "].muzzleGroups[1]").muzzles,
			"weapons[" .. disintegratorIndex .. "].muzzleGroups[1].muzzles")
		if (#disintegratorMuzzles ~= 1 and #disintegratorMuzzles ~= 3) then
			fail("Loyalist disintegrator has an unowned projectile multiplier")
		end
		for index, muzzle in ipairs(disintegratorMuzzles) do
			requireExact(muzzle, "Muzzle_Left",
				"Loyalist disintegrator muzzleGroups[1].muzzles[" .. index .. "]")
		end
		requireExact(disintegrator.damage, 175, "Loyalist disintegrator damage")
		requireExact(disintegrator.muzzleSalvoSize, 3,
			"Loyalist disintegrator muzzleSalvoSize")
		local sourceContract = requireTable(tp.additions.faSourceContract,
			"additions.faSourceContract")
		local disintegratorContract = requireTable(sourceContract.disintegrator,
			"additions.faSourceContract.disintegrator")
		requireAllowed(disintegratorContract.sanctuaryProjectilesPerCycle,
			{ 9, 3 }, "Loyalist sanctuaryProjectilesPerCycle")
		-- FA's ProjectilesPerOnFire mirrors MuzzleSalvoSize; it is not a
		-- second multiplier. One physical muzzle over three salvos is three
		-- 175-damage rounds per cycle, not nine.
		disintegratorGroups[1].muzzles = { "Muzzle_Left" }
		disintegratorContract.sanctuaryProjectilesPerCycle = 3
        local disintegratorMuzzle =
            "VFX/SCOM/FieldFixes/Loyalist/loyalist_disintegrator_muzzle.sanvfx"
        local bolterMuzzle =
            "VFX/SCOM/FieldFixes/Loyalist/loyalist_bolter_muzzle.sanvfx"
        if disintegrator.effects == nil then disintegrator.effects = {} end
        if bolter.effects == nil then bolter.effects = {} end
        requireTable(disintegrator.effects, "weapons[" .. disintegratorIndex .. "].effects")
        requireTable(bolter.effects, "weapons[" .. bolterIndex .. "].effects")
        if disintegrator.effects.onFire ~= nil then
            requireAllowed(disintegrator.effects.onFire, {
                "VFX/Muzzle/vgm1281_cannon_plasma_medium_muzzle.sanvfx",
                disintegratorMuzzle,
            }, "Loyalist disintegrator onFire")
        end
        if bolter.effects.onFire ~= nil then
            requireAllowed(bolter.effects.onFire, {
                "VFX/Muzzle/vgm1121_autocannon_plasma_small_muzzle.sanvfx",
                bolterMuzzle,
            }, "Loyalist bolter onFire")
        end
        disintegrator.effects.onFire = disintegratorMuzzle
        bolter.effects.onFire = bolterMuzzle

    elseif tpId == "pgr303d" or tpId == "pgr303b" then
        local visuals = requireTable(tp.visuals, "visuals")
        local persistent = requireTable(visuals.persistantEffects, "visuals.persistantEffects")
        if #persistent ~= 1 then fail("Loyalist projectile must have one verified persistent effect group") end
        local effects = requireTable(persistent[1].effects, "visuals.persistantEffects[1].effects")
        if #effects ~= 1 then fail("Loyalist projectile must have one verified trail effect") end
        local effect = requireTable(effects[1], "visuals.persistantEffects[1].effects[1]")
        local trailReplacement = tpId == "pgr303d"
            and "VFX/SCOM/FieldFixes/Loyalist/loyalist_disintegrator_trail.sanvfx"
            or "VFX/SCOM/FieldFixes/Loyalist/loyalist_bolter_trail.sanvfx"
        requireAllowed(effect.particleName, {
            "VFX/Trails/vgt1101_cannon_small_trail.sanvfx",
            tpId == "pgr303d"
                and "VFX/Trails/vgt1281_cannon_plasma_medium_trail.sanvfx"
                or "VFX/Trails/vgt1121_autocannon_plasma_small_trail.sanvfx",
            trailReplacement,
        }, "Loyalist projectile trail")
        effect.particleName = trailReplacement

        local impactGroups = requireTable(visuals.onImpactEffects, "visuals.onImpactEffects")
        if #impactGroups ~= 1 then fail("Loyalist projectile must have one verified impact effect group") end
        local impactEffects = requireTable(impactGroups[1].effects, "visuals.onImpactEffects[1].effects")
        if #impactEffects ~= 1 then fail("Loyalist projectile must have one verified impact effect") end
        local impact = requireTable(impactEffects[1], "visuals.onImpactEffects[1].effects[1]")
        local impactReplacement = tpId == "pgr303d"
            and "VFX/SCOM/FieldFixes/Loyalist/loyalist_disintegrator_impact.sanvfx"
            or "VFX/SCOM/FieldFixes/Loyalist/loyalist_bolter_impact.sanvfx"
        requireAllowed(impact.particleName, {
            "VFX/Impact/vgi1101_cannon_small_impact.sanvfx",
            tpId == "pgr303d"
                and "VFX/Impact/vgi1281_cannon_plasma_medium_impact.sanvfx"
                or "VFX/Impact/vgi1121_autocannon_plasma_small_impact.sanvfx",
            impactReplacement,
        }, "Loyalist projectile impact")
        impact.particleName = impactReplacement

    elseif tpId == "ugs2501" or tpId == "ugs3501" then
        local footprint = requireTable(tp.footprint, "footprint")
        local skirt = requireTable(tp.skirtSize, "skirtSize")
        local source = requireTable(tp.additions.faSourceContract, "additions.faSourceContract")
        local expectedMapping = tpId == "ugs2501" and "XRB0104 -> ugs2501" or "XRB0304 -> ugs3501"
        requireExact(source.mapping, expectedMapping, "Hive source mapping")
        local sourceOffset = requireTable(source.sourceSkirtOffset, "additions.faSourceContract.sourceSkirtOffset")
        requireExact(sourceOffset.x, -0.5, "Hive sourceSkirtOffset.x")
        requireExact(sourceOffset.z, -0.5, "Hive sourceSkirtOffset.z")
        requireAllowed(source.sanctuarySkirtOffsetSupported, { false, true },
            "Hive sanctuarySkirtOffsetSupported")
        requireExact(footprint.x, 1, "Hive footprint.x")
        requireExact(footprint.y, 1, "Hive footprint.y")
        requireExact(skirt.x, 2, "Hive skirtSize.x")
        requireExact(skirt.y, 2, "Hive skirtSize.y")
        if tp.additions.scoFieldFixHivePlacement ~= nil then
            fail("additions.scoFieldFixHivePlacement is already owned without this module marker")
        end
        tp.additions.scoFieldFixHivePlacement = {
            version = "1.0.0",
            owner = "SCO_FieldFixHivePlacementRuntime",
            offset = { x = -0.5, z = -0.5 },
        }
        source.sanctuarySkirtOffsetSupported = true
    end

    tp.additions.scoFieldFixCybran = version
    return tp
end

-- SCOM Field Fixes 1.3.1 - owned presentation-only projectile hierarchies.
-- Integration routes the stock projectile hierarchy through the validated
-- helper below before constructing the engine hierarchy template.
-- The same established dispatcher now owns Titan's independently validated,
-- presentation-only commander-projectile child and Ahwassa's neutral bomb
-- child. Ahwassa's dedicated VFX owns its local scale-six mesh core internally;
-- neither its hierarchy nor its root collision is scaled.

local SCO_FieldFixSeraphimProjectileHierarchyVersion = "1.3.1"
local SCO_FieldFixSeraphimProjectileHierarchyInstalled =
    _G.SCO_FieldFixSeraphimProjectileHierarchyInstalled

if SCO_FieldFixSeraphimProjectileHierarchyInstalled ~= nil
    and SCO_FieldFixSeraphimProjectileHierarchyInstalled
        ~= SCO_FieldFixSeraphimProjectileHierarchyVersion
then
    error("SCOM Field Fixes found an unsupported Seraphim projectile hierarchy appendix")
end

if SCO_FieldFixSeraphimProjectileHierarchyInstalled
    == SCO_FieldFixSeraphimProjectileHierarchyVersion
then
    if type(_G.SCO_FieldFixSeraphimProjectileHierarchy) ~= "function" then
        error("SCOM Field Fixes lost its installed Seraphim projectile hierarchy mutator")
    end
elseif SCO_FieldFixSeraphimProjectileHierarchyInstalled == nil then
    if _G.SCO_FieldFixSeraphimProjectileHierarchy ~= nil then
        error("SCOM Field Fixes found an unowned Seraphim projectile hierarchy mutator")
    end

    local projectileId = "psu404s"
    local childName = "SCO_Ythotha_Projectile_Visual"
    local trailPath =
        "VFX/Trails/vct1301_cannon_plasma_large_trail.sanvfx"

    local function requireHierarchyConstructors()
        if type(EngineClasses) ~= "table"
            or type(EngineClasses.EntityTemplate) ~= "function"
            or type(EngineClasses.float3) ~= "function"
            or type(GetIdentityQuaternion) ~= "function"
            or type(TemplateHeadEntityName) ~= "string"
            or TemplateHeadEntityName == ""
        then
            error("SCOM Field Fixes could not resolve projectile hierarchy constructors")
        end
    end

    local function requireDedicatedContract(tp)
        local expectedTrailPath = trailPath
        local sourceVisual = tp.additions and tp.additions.scoSourceVisualIdentity
        if sourceVisual ~= nil then
            -- The roster's source-effect owner replaces the baseline trail while
            -- preserving this child and its scale. Accept only that exact port.
            if type(sourceVisual) ~= "table"
                or sourceVisual.sourceId ~= "sdfsinnuntheweapon01"
                or sourceVisual.dedicatedTemplate ~= "psf0134"
                or sourceVisual.blueprintSha256 ~=
                    "5fd91d2d4cf835ff44072a55399c843ec1865f123543863a82c6c3c3582893fe"
            then
                error(projectileId .. " has an invalid source presentation identity")
            end
            expectedTrailPath = "VFX/SCOM/Source/psf0134/trail.sanvfx"
        end

        local scale = tp.nonUniformScale
        if type(scale) ~= "table"
            or scale.x ~= 3 or scale.y ~= 3 or scale.z ~= 3
        then
            error(projectileId .. " requires an exact uniform presentation scale of 3")
        end

        local collisionSize = tp.collisionInfo
            and tp.collisionInfo.collisionSize
        if type(collisionSize) ~= "table"
            or collisionSize.x ~= 1
            or collisionSize.y ~= 1
            or collisionSize.z ~= 1
        then
            error(projectileId .. " requires its root collision size to remain one")
        end

        local persistentEffects = tp.visuals
            and tp.visuals.persistantEffects
        if type(persistentEffects) ~= "table" then
            error(projectileId .. " requires its presentation-child trail binding")
        end
        local bindingCount = 0
        for _, effectGroup in ipairs(persistentEffects) do
            local effects = effectGroup and effectGroup.effects
            if type(effects) == "table" then
                for _, effect in ipairs(effects) do
                    if effect and effect.boneName == childName then
                        bindingCount = bindingCount + 1
                        if effect.particleName ~= expectedTrailPath then
                            error(projectileId .. " has a corrupt presentation-child trail")
                        end
                    end
                end
            end
        end
        if bindingCount ~= 1 then
            error(projectileId .. " requires exactly one presentation-child trail binding")
        end
    end

    local function appendPresentationChild(tp, hierarchyEntities)
        if type(tp) ~= "table" or type(hierarchyEntities) ~= "table" then
            error("SCOM Field Fixes requires projectile and hierarchy tables")
        end
        local tpId = tp.general and tp.general.tpId
        if tpId ~= projectileId then return hierarchyEntities end

        -- templateLoader.lua imports this module before publishing
        -- TemplateHeadEntityName. Validate only when psu404s is instantiated,
        -- after template-loader initialization has completed.
        requireHierarchyConstructors()
        requireDedicatedContract(tp)

        local rootCount = 0
        for _, entity in ipairs(hierarchyEntities) do
            if type(entity) ~= "table" then
                error(projectileId .. " has a corrupt hierarchy entity")
            end
            if entity.entityName == TemplateHeadEntityName then
                rootCount = rootCount + 1
                if entity.parentEntityName ~= nil or entity.localScale ~= 1 then
                    error(projectileId .. " requires an unscaled root hierarchy entity")
                end
            elseif entity.entityName == childName then
                error(projectileId .. " already has a presentation hierarchy child")
            end
        end
        if rootCount ~= 1 then
            error(projectileId .. " requires exactly one root hierarchy entity")
        end

        local child = EngineClasses.EntityTemplate(
            childName,
            TemplateHeadEntityName,
            EngineClasses.float3(0, 0, 0),
            3,
            GetIdentityQuaternion(),
            false)
        if type(child) ~= "table"
            or child.entityName ~= childName
            or child.parentEntityName ~= TemplateHeadEntityName
            or child.localScale ~= 3
        then
            error(projectileId .. " presentation hierarchy child construction failed")
        end
        table.insert(hierarchyEntities, child)
        return hierarchyEntities
    end

    local titanProjectileId = "per303"
    local titanChildName = "SCO_Titan_Commander_Projectile_Visual"
    local titanTrailPath =
        "VFX/Trails/vct2101_rocket_antitank_small_trail.sanvfx"
    local titanScale = 0.65
    local requireTitanHierarchyConstructors = requireHierarchyConstructors

    local function requireTitanDedicatedContract(tp)
        local scale = tp.nonUniformScale
        if type(scale) ~= "table"
            or scale.x ~= titanScale
            or scale.y ~= titanScale
            or scale.z ~= titanScale
        then
            error(titanProjectileId
                .. " requires an exact uniform presentation scale of 0.65")
        end

        local collisionSize = tp.collisionInfo
            and tp.collisionInfo.collisionSize
        if type(collisionSize) ~= "table"
            or collisionSize.x ~= 1
            or collisionSize.y ~= 1
            or collisionSize.z ~= 1
        then
            error(titanProjectileId
                .. " requires its root collision size to remain one")
        end

        local persistentEffects = tp.visuals
            and tp.visuals.persistantEffects
        if type(persistentEffects) ~= "table" then
            error(titanProjectileId
                .. " requires its presentation-child trail binding")
        end
        local bindingCount = 0
        for _, effectGroup in ipairs(persistentEffects) do
            local effects = effectGroup and effectGroup.effects
            if type(effects) == "table" then
                for _, effect in ipairs(effects) do
                    if effect and effect.boneName == titanChildName then
                        bindingCount = bindingCount + 1
                        if effect.particleName ~= titanTrailPath then
                            error(titanProjectileId
                                .. " has a corrupt commander-projectile trail")
                        end
                    end
                end
            end
        end
        if bindingCount ~= 1 then
            error(titanProjectileId
                .. " requires exactly one presentation-child trail binding")
        end
    end

    local function appendTitanPresentationChild(tp, hierarchyEntities)
        if type(tp) ~= "table" or type(hierarchyEntities) ~= "table" then
            error("SCOM Field Fixes requires projectile and hierarchy tables")
        end
        local tpId = tp.general and tp.general.tpId
        if tpId ~= titanProjectileId then return hierarchyEntities end

        requireTitanHierarchyConstructors()
        requireTitanDedicatedContract(tp)

        local rootCount = 0
        for _, entity in ipairs(hierarchyEntities) do
            if type(entity) ~= "table" then
                error(titanProjectileId .. " has a corrupt hierarchy entity")
            end
            if entity.entityName == TemplateHeadEntityName then
                rootCount = rootCount + 1
                if entity.parentEntityName ~= nil or entity.localScale ~= 1 then
                    error(titanProjectileId
                        .. " requires an unscaled root hierarchy entity")
                end
            elseif entity.entityName == titanChildName then
                error(titanProjectileId
                    .. " already has a presentation hierarchy child")
            end
        end
        if rootCount ~= 1 then
            error(titanProjectileId
                .. " requires exactly one root hierarchy entity")
        end

        local child = EngineClasses.EntityTemplate(
            titanChildName,
            TemplateHeadEntityName,
            EngineClasses.float3(0, 0, 0),
            titanScale,
            GetIdentityQuaternion(),
            false)
        if type(child) ~= "table"
            or child.entityName ~= titanChildName
            or child.parentEntityName ~= TemplateHeadEntityName
            or child.localScale ~= titanScale
        then
            error(titanProjectileId
                .. " presentation hierarchy child construction failed")
        end
        table.insert(hierarchyEntities, child)
        return hierarchyEntities
    end

    local ahwassaProjectileId = "psb402"
    local ahwassaChildName = "SCO_Ahwassa_Commander_Projectile_Visual"
    local ahwassaTrailPath =
        "VFX/SCOM/FieldFixes/Ahwassa/ahwassa_strategic_bomb_6x.sanvfx"
    local ahwassaImpactPath =
        "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx"
    local ahwassaScale = 6
    local ahwassaHierarchyScale = 1
    local requireAhwassaHierarchyConstructors = requireHierarchyConstructors

    local function requireAhwassaDedicatedContract(tp)
        local ahwassaScaleMetadata = tp.nonUniformScale
        if type(ahwassaScaleMetadata) ~= "table"
            or ahwassaScaleMetadata.x ~= ahwassaScale
            or ahwassaScaleMetadata.y ~= ahwassaScale
            or ahwassaScaleMetadata.z ~= ahwassaScale
        then
            error(ahwassaProjectileId
                .. " requires an exact uniform presentation scale of 6")
        end

        local collisionSize = tp.collisionInfo
            and tp.collisionInfo.collisionSize
        if type(collisionSize) ~= "table"
            or collisionSize.x ~= 1
            or collisionSize.y ~= 1
            or collisionSize.z ~= 1
        then
            error(ahwassaProjectileId
                .. " requires its root collision size to remain one")
        end

        local visuals = tp.visuals
        local persistentEffects = visuals and visuals.persistantEffects
        if type(persistentEffects) ~= "table" then
            error(ahwassaProjectileId
                .. " requires its presentation-child trail binding")
        end
        local bindingCount = 0
        for _, effectGroup in ipairs(persistentEffects) do
            local effects = effectGroup and effectGroup.effects
            if type(effects) == "table" then
                for _, effect in ipairs(effects) do
                    if effect and effect.boneName == ahwassaChildName then
                        bindingCount = bindingCount + 1
                        if effect.particleName ~= ahwassaTrailPath then
                            error(ahwassaProjectileId
                                .. " has a corrupt commander-blue trail")
                        end
                    end
                end
            end
        end
        if bindingCount ~= 1 then
            error(ahwassaProjectileId
                .. " requires exactly one presentation-child trail binding")
        end

        local impactEffects = visuals and visuals.onImpactEffects
        if type(impactEffects) ~= "table" then
            error(ahwassaProjectileId
                .. " requires its commander-blue impact effect")
        end
        local impactCount = 0
        for _, effectGroup in ipairs(impactEffects) do
            local effects = effectGroup and effectGroup.effects
            if type(effects) == "table" then
                for _, effect in ipairs(effects) do
                    impactCount = impactCount + 1
                    if not effect
                        or effect.particleName ~= ahwassaImpactPath
                    then
                        error(ahwassaProjectileId
                            .. " has a corrupt commander-blue impact effect")
                    end
                end
            end
        end
        if impactCount ~= 1 then
            error(ahwassaProjectileId
                .. " requires exactly one commander-blue impact effect")
        end
    end

    local function appendAhwassaPresentationChild(tp, hierarchyEntities)
        if type(tp) ~= "table" or type(hierarchyEntities) ~= "table" then
            error("SCOM Field Fixes requires projectile and hierarchy tables")
        end
        local tpId = tp.general and tp.general.tpId
        if tpId ~= ahwassaProjectileId then return hierarchyEntities end

        requireAhwassaHierarchyConstructors()
        requireAhwassaDedicatedContract(tp)

        local rootCount = 0
        for _, entity in ipairs(hierarchyEntities) do
            if type(entity) ~= "table" then
                error(ahwassaProjectileId .. " has a corrupt hierarchy entity")
            end
            if entity.entityName == TemplateHeadEntityName then
                rootCount = rootCount + 1
                if entity.parentEntityName ~= nil or entity.localScale ~= 1 then
                    error(ahwassaProjectileId
                        .. " requires an unscaled root hierarchy entity")
                end
            elseif entity.entityName == ahwassaChildName then
                error(ahwassaProjectileId
                    .. " already has a presentation hierarchy child")
            end
        end
        if rootCount ~= 1 then
            error(ahwassaProjectileId
                .. " requires exactly one root hierarchy entity")
        end

        local child = EngineClasses.EntityTemplate(
            ahwassaChildName,
            TemplateHeadEntityName,
            EngineClasses.float3(0, 0, 0),
            ahwassaHierarchyScale,
            GetIdentityQuaternion(),
            false)
        if type(child) ~= "table"
            or child.entityName ~= ahwassaChildName
            or child.parentEntityName ~= TemplateHeadEntityName
            or child.localScale ~= ahwassaHierarchyScale
        then
            error(ahwassaProjectileId
                .. " presentation hierarchy child construction failed")
        end
        table.insert(hierarchyEntities, child)
        return hierarchyEntities
    end

    local function appendOwnedPresentationChildren(tp, hierarchyEntities)
        hierarchyEntities = appendPresentationChild(tp, hierarchyEntities)
        hierarchyEntities = appendTitanPresentationChild(tp, hierarchyEntities)
        return appendAhwassaPresentationChild(tp, hierarchyEntities)
    end

    _G.SCO_FieldFixSeraphimProjectileHierarchy =
        appendOwnedPresentationChildren
    _G.SCO_FieldFixSeraphimProjectileHierarchyInstalled =
        SCO_FieldFixSeraphimProjectileHierarchyVersion
end

-- SCOM restrained commander projectile presentation 1.0.0
local SCO_CommanderBrightnessPaths = {
    ["Projectiles/" .. "psf0006/LOD0/psf0006.sanmaterial"] = "Projectiles/CommanderBrightness/768bfb442e0ac3dd95e2.sanmaterial",
    ["Projectiles/" .. "psf0148/LOD0/psf0148.sanmaterial"] = "Projectiles/CommanderBrightness/5bdc5c337d0b084cf00c.sanmaterial",
    ["VFX/" .. "AeonProjectiles/Impact/vci1201_cannon_plasma_medium_impact.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/cb383031a72999e6d0ee.sanvfx",
    ["VFX/" .. "AeonProjectiles/Impact/vci1301_cannon_plasma_large_impact.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/51eaa4a0c9701b823296.sanvfx",
    ["VFX/" .. "AeonProjectiles/Muzzle/vcm1203_aeon_acu_clean_muzzle.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/8303b30e7ac4b7642b08.sanvfx",
    ["VFX/" .. "AeonProjectiles/Trails/vct1301_cannon_plasma_large_trail.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/c3c6b675192822a024de.sanvfx",
    ["VFX/" .. "CybranAcuProjectiles/Impact/vci1301_cannon_plasma_large_impact.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/df24f3bd74383755d049.sanvfx",
    ["VFX/" .. "Impact/vci1101_cannon_plasma_small_impact.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/98288bd95532bcfc2a90.sanvfx",
    ["VFX/" .. "Impact/vci1241_cannon_artillery_medium_impact.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/21cd4789abb05c6d81a6.sanvfx",
    ["VFX/" .. "Impact/vci1301_cannon_plasma_large_impact.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/460b58f1ef10be15be72.sanvfx",
    ["VFX/" .. "Muzzle/vcm7101_beam_antitank_small_muzzle.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/4cb2e20e50b93c2320be.sanvfx",
    ["VFX/" .. "Muzzle/vgm1101_cannon_small_muzzle.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/cf89c7d9bbd679dcec96.sanvfx",
    ["VFX/" .. "SCOM/Commanders/Aeon/projectile.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/7efc3cc1cbb0e9621ca5.sanvfx",
    ["VFX/" .. "SCOM/Commanders/Cybran/muzzle.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/79ba050abdfc07e0a53d.sanvfx",
    ["VFX/" .. "SCOM/Commanders/Cybran/projectile.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/3843f003450f4f491001.sanvfx",
    ["VFX/" .. "SCOM/Commanders/Seraphim/muzzle.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/0147088bd1c5681b4fe8.sanvfx",
    ["VFX/" .. "SCOM/Commanders/Seraphim/projectile.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/5211a2f7cf59cc6927ce.sanvfx",
    ["VFX/" .. "SCOM/FieldFixes/UEFAcu/uef_acu_blue_projectile.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/b91135f3eb9b616a5067.sanvfx",
    ["VFX/" .. "SCOM/FieldFixes/UEFAcu/uef_acu_clean_muzzle.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/f091c5024cc82e75bd1b.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0006/impact_land.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/a753f539e23e5049a925.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0006/ribbon_0.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/4e2f5e9fc1f1d5efd250.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0006/ribbon_particles.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/d3cab48804ab441af8f0.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0012/impact_land.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/9eb4aa17fc4bed62a378.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0015/impact_land.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/5847e76679a584338ad2.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0015/ribbon_1.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/9f3dd24a5ae411bf5eb7.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0015/ribbon_2.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/cc13dfe027f25df1d8e6.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0015/ribbon_3.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/51176089e41472485942.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0015/ribbon_particles.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/1e7c076e3d704622c962.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0033/impact_land.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/2f1de037d4807a932180.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0033/ribbon_1.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/86f6a37a2fd71fee3716.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0033/ribbon_2.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/b29f3852764003ae00bb.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0033/ribbon_3.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/ba934266abc7ef46cd2a.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0033/ribbon_particles.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/e54f59cd41169573c73b.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0148/trail.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/4f754cd9e209ab6dd121.sanvfx",
    ["VFX/" .. "SCOM/Source/psf0168/impact_land.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/3ad0ef98fef395a9f6c8.sanvfx",
    ["VFX/" .. "SCOM/Source/pxd003/beam_end.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/d084b2aff6961fe6fa85.sanvfx",
    ["VFX/" .. "SCOM/Source/ucl4002/muzzle_rightreactoncannon.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/1c80798ce6e7f387deb7.sanvfx",
    ["VFX/" .. "SCOM/Source/uel5007/muzzle_rightheavyplasmacannon.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/c1809bf171bd828f4fb8.sanvfx",
    ["VFX/" .. "SCOM/Source/ugl5004/muzzle_nmissile.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/65349bb416e05b0eb805.sanvfx",
    ["VFX/" .. "SCOM/Source/usl4002/muzzle_lightchronatroncannon.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/67f193c0a63061c7fda6.sanvfx",
    ["VFX/" .. "SupremeCommanderOverhaul/Materials/Monkeylord/monkeylord_microwave_beam.sanmaterial"] = "VFX/SCOM/Source/CommanderBrightness/bf77ab57130f809e25e7.sanmaterial",
    ["VFX/" .. "Trails/vct1101_cannon_plasma_small_trail.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/73e106fbe835042423ce.sanvfx",
    ["VFX/" .. "Trails/vct1241_cannon_artillery_medium_trail.sanvfx"] = "VFX/SCOM/Source/CommanderBrightness/854b8003056d5750b3af.sanvfx",
}
local SCO_CommanderBrightnessProjectiles = {["psf0168"]=true,["psf0165"]=true,["psf0166"]=true,["psf0169"]=true,["psf0033"]=true,["psf0069"]=true,["psf0015"]=true,["psf0170"]=true,["psf0006"]=true,["pgr305t"]=true,["psf0171"]=true,["psf0141"]=true,["pxd003"]=true}
function SCO_CommanderBrightnessPath(tpId, path)
    if SCO_CommanderBrightnessProjectiles[string.lower(tpId)] then
        return SCO_CommanderBrightnessPaths[path] or path
    end
    return path
end
local function SCO_RemapCommanderVisualFields(value)
    if type(value) ~= "table" then return end
    for key, item in pairs(value) do
        if type(item) == "table" then
            SCO_RemapCommanderVisualFields(item)
        elseif type(item) == "string" and SCO_CommanderBrightnessPaths[item] then
            local path = SCO_CommanderBrightnessPaths[item]
            -- Native effect preloading runs before the final source rewrites.
            if IsClient and path:sub(-7) == '.sanvfx' then Engine.LoadEffect(path) end
            value[key] = path
        end
    end
end
local function SCO_ApplyCommanderProjectileBrightness(tp)
    if SCO_CommanderBrightnessProjectiles[string.lower(tp.general.tpId)] then
        SCO_RemapCommanderVisualFields(tp.visuals)
    end
end
local SCO_FieldFixPreviousCreateProjectilePrefab = CreateProjectilePrefab
function CreateProjectilePrefab(tp)
    if type(tp) ~= "table" then
        error("SCOM field-fix dispatcher requires a projectile template table.", 2)
    end
    local tpId = tp.general and tp.general.tpId
    if type(tpId) ~= "string" or tpId == "" then
        error("SCOM field-fix dispatcher requires ProjectileTemplate.general.tpId.", 2)
    end

    SCO_FieldFixCybran(tp, tpId)
    Import('common/systems/scoTorpedoVisuals.lua').Apply(tp)
    SCO_ApplyCommanderProjectileBrightness(tp)
    return SCO_FieldFixPreviousCreateProjectilePrefab(tp)
end

-- SCOM source projectile mesh rendering 1.0.1
-- MeshTemplate consumes the converted bind-pose vertices. Presentation scale
-- belongs to the renderer, leaving the projectile's simulation and colliders intact.
local function AttachProjectileTrailOwners(tp, prefab)
    local directory = 'VFX/SCOM/Source/' .. tp.general.tpId .. '/'
    local configured = tp.visuals and tp.visuals.scoTrailOwners
    local names = { 'SCO_HeavyLaser_Red', 'SCO_HeavyLaser_Core' }
    local roles = { 'trail', 'trail_core' }
    if tp.general.tpId == 'psf0151' then
        names = { 'SCO_Gauss_01', 'SCO_Gauss_02' }
    elseif tp.general.tpId == 'pep305' then
        -- Percival retains the accepted four named Zephyr effects.
        directory = 'VFX/SCOM/Source/psf0168/'
        names = { 'SCO_Zephyr_01', 'SCO_Zephyr_02', 'SCO_Zephyr_03', 'SCO_Zephyr_Particles' }
        roles = { 'trail', 'trail_core', 'trail_white', 'trail_particles' }
    end
    local expected = {}
    if configured then
        assert(type(configured) == 'table', 'Invalid source ribbon owner map')
        names = {}
        for name, path in pairs(configured) do
            local index = type(name) == 'string' and name:match('^SCO_SourceRibbon_(%d+)$')
            local role = index and ('ribbon_' .. index) or
                (name == 'SCO_SourceParticles' and 'ribbon_particles')
            assert(role and path == SCO_CommanderBrightnessPath(tp.general.tpId, directory .. role .. '.sanvfx')
                and (not index or tonumber(index) < 64), 'Invalid source ribbon asset binding')
            names[#names + 1], expected[name] = name, path
        end
        assert(#names > 0 and #names <= 64, 'Invalid source ribbon owner count')
        table.sort(names)
    else
        for index, name in ipairs(names) do expected[name] = SCO_CommanderBrightnessPath(tp.general.tpId, directory .. roles[index] .. '.sanvfx') end
    end
    local effects = assert(tp.visuals and tp.visuals.persistantEffects,
        'source projectile requires persistent trails')
    local bound, effectCount = {}, 0
    for _, group in ipairs(effects) do
        for _, effect in ipairs(assert(group.effects)) do
            local name = effect.boneName
            assert(expected[name] and effect.particleName == expected[name] and not bound[name],
                'Invalid or duplicate source projectile trail binding')
            bound[name], effectCount = true, effectCount + 1
        end
    end
    assert(effectCount == #names, 'source projectile requires every trail binding')

    -- The native particle loader already created one component per named bone.
    -- Only supply its missing hierarchy owner; adding another component here
    -- would cause duplicate emission and break native visibility ownership.
    local randomRiotRibbon = tp.general.tpId == 'psf0035'
    if randomRiotRibbon then
        assert(tp.visuals.scoRandomPolyTrails == 1 and #names == 3,
            'Invalid riot ribbon selection contract')
    end
    local particles = assert(prefab.localTemplate and prefab.localTemplate.particleTemplates)
    local particleOwners = {}
    assert(#particles == #names, 'Unexpected source projectile particle components')
    for _, particle in ipairs(particles) do
        local name = particle.entityName
        assert(expected[name] and particle.particlePath == expected[name]
            and particle.destroyUponCompletion == false and (particle.canEmit == true or randomRiotRibbon and particle.canEmit == false)
            and not particleOwners[name], 'Invalid source projectile particle owner')
        particleOwners[name] = true
    end

    local entities = assert(prefab.hierarchyTemplate and prefab.hierarchyTemplate.entities)
    local existing = {}
    for _, entity in ipairs(entities) do
        local name = entity.entityName
        if expected[name] then
            local position = entity.localTranslation
            local rotation = entity.localRotation and (entity.localRotation.value or entity.localRotation)
            assert(not existing[name] and entity.parentEntityName == TemplateHeadEntityName
                and position and position.x == 0 and position.y == 0 and position.z == 0
                and entity.localScale == 1 and entity.forceSimulated == false
                and rotation and rotation.x == 0 and rotation.y == 0 and rotation.z == 0 and rotation.w == 1,
                'Invalid or duplicate source projectile hierarchy owner')
            existing[name] = true
        end
    end
    local additions = {}
    for _, name in ipairs(names) do
        if not existing[name] then
            if IsClient then Engine.LoadEffect(expected[name]) end
            additions[#additions + 1] = EngineClasses.EntityTemplate(name, TemplateHeadEntityName,
                EngineClasses.float3(0, 0, 0), 1, GetIdentityQuaternion(), false)
        end
    end
    for _, entity in ipairs(additions) do table.insert(entities, entity) end
    -- All three variants exist, but the client selects one before first emission.
    if randomRiotRibbon then
        for _, particle in ipairs(particles) do particle.canEmit = false end
    end
end

function SCO_FieldFixAttachProjectileMesh(tp, prefab)
    if tp.general.tpId == 'psf0017' or tp.general.tpId == 'psf0151'
        or tp.general.tpId == 'pep305'
        or (tp.visuals and tp.visuals.scoTrailOwners) then
        AttachProjectileTrailOwners(tp, prefab)
    end
    local visual = tp.visuals and tp.visuals.scoProjectileMesh
    if not visual then return end
    local function assetPath(value, extension)
        return type(value) == 'string' and value:match('^Projectiles/')
            and value:sub(-#extension) == extension and not value:find('..', 1, true)
    end
    assert(assetPath(visual.model, '.sanmodel'), 'Invalid source projectile model path')
    assert(assetPath(visual.material, '.sanmaterial'), 'Invalid source projectile material path')
    local scale = visual.scale or { x = 1, y = 1, z = 1 }
    for _, axis in ipairs({ 'x', 'y', 'z' }) do
        local value = scale[axis]
        assert(type(value) == 'number' and value > 0 and value < math.huge,
            'Invalid source projectile presentation scale')
    end
    local localTemplate = assert(prefab.localTemplate)
    localTemplate.meshTemplates = localTemplate.meshTemplates or {}
    -- RTS/Unit projectile materials use the static unit renderer's completed,
    -- intact instance state; legacy HDRP projectile materials retain theirs.
    local unitMaterial = tp.general.tpId == 'psf0136' or tp.general.tpId == 'psf0151'
        or tp.general.tpId == 'psf0154' or tp.general.tpId == 'psf5035' or tp.general.tpId == 'psf0008'
        or tp.general.tpId == 'pst001' or tp.general.tpId == 'pst002'
        or tp.general.tpId == 'pst003' or tp.general.tpId == 'pst005'
        or tp.general.tpId == 'psf0174' or tp.general.tpId == 'psf0073' or tp.general.tpId == 'psf0021'
    local materialState = unitMaterial
        and EngineClasses.float4(0, 0, 0, 0) or EngineClasses.float4(0, 1, 0, 0)
    table.insert(localTemplate.meshTemplates, EngineClasses.MeshTemplate(
        TemplateHeadEntityName, visual.model, visual.material,
        EngineClasses.float3(scale.x, scale.y, scale.z), ShadowCastingMode.Off,
        EngineClasses.float4(1, 1, 1, 1), materialState, false
    ))
end

-- Source launch effects get separate native children so client visibility and
-- source phase events can control their emission independently.
function SCO_SourceNukeParticles(tp,prefab)
    local phases=tp.visuals and tp.visuals.scoNukePhases
    if not phases then return end
    local config=tp.additions.scoTacticalProjectile
    local count=config.nukeProfile and config.nukeProfile.effectPhases or 3
    assert(config.sourceNuke and (count==1 or count==3) and #phases==count,'Invalid source nuclear effect owner')
    local entities=assert(prefab.hierarchyTemplate.entities)
    local localTemplate=assert(prefab.localTemplate)
    localTemplate.particleTemplates=localTemplate.particleTemplates or {}
    local names={}
    for _,entity in ipairs(entities) do names[entity.entityName]=true end
    for phase,effect in ipairs(phases) do
        assert(effect.phase==phase and effect.startTime==({0,2.5,5})[phase]
            and effect.boneName:match('^SCO_SourceNuke_%l+$')
            and effect.particleName:match('^VFX/SCOM/Source/')
            and effect.particleName:sub(-7)=='.sanvfx'
            and not effect.particleName:find('..',1,true),'Invalid source nuclear phase descriptor')
        if not names[effect.boneName] then
            if IsClient then Engine.LoadEffect(effect.particleName) end
            table.insert(entities,EngineClasses.EntityTemplate(effect.boneName,TemplateHeadEntityName,
                EngineClasses.float3(0,0,0),1,GetIdentityQuaternion(),false))
            table.insert(localTemplate.particleTemplates,EngineClasses.ParticleTemplate(effect.boneName,effect.particleName,false,false))
            names[effect.boneName]=true
        end
    end
end
