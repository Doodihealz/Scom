using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace EdaUefFatboyCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class ProjectileSpec
	{
		public string Id { get; }

		public string Name { get; }

		public string Trail { get; }

		public string Impact { get; }

		public string? Movement { get; }

		public ProjectileSpec(string id, string name, string trail, string impact, string? movement)
		{
			Id = id;
			Name = name;
			Trail = trail;
			Impact = impact;
			Movement = movement;
		}
	}

	private sealed class CacheResource
	{
		public string Path { get; }

		public object Stock { get; }

		public CacheResource(string path, object stock)
		{
			Path = path;
			Stock = stock;
		}
	}

	private sealed class CacheMutation
	{
		public string Path { get; }

		public object? Stock { get; }

		public object Replacement { get; }

		public bool Added { get; }

		public string Description { get; }

		public bool Assigned { get; set; }

		public CacheMutation(string path, object? stock, object replacement, bool added, string description)
		{
			Path = path;
			Stock = stock;
			Replacement = replacement;
			Added = added;
			Description = description;
		}
	}

	private const string OverrideMarker = "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0";

	private const string TemplateRelativePath = "LJ/lua/common/units/unitsTemplates/uel4511/uel4511.santp";

	private const string GaussArcMarker = "-- Supreme Commander Overhaul UEF Fatboy Gauss arc 2.0.0";

	private const string PreviousGaussArcMarker = "-- Supreme Commander Overhaul UEF Fatboy Gauss arc 1.0.0";

	private const string LegacyGaussControllerSettings = "        local controllerSettings = {\n            aimTolerance = 2,\n            reduceMuzzleVelocityToTarget = true,\n        }";

	private const string PreviousGaussControllerSettings = "        local controllerSettings = {\n            aimGravity = {\n                x = 0,\n                y = -4.9,\n                z = 0,\n            },\n            aimTolerance = 2,\n            reduceMuzzleVelocityToTarget = true,\n        }\n        -- Supreme Commander Overhaul UEF Fatboy Gauss arc 1.0.0";

	private const string HighArcGaussControllerSettings = "        local controllerSettings = {\n            aimGravity = {\n                x = 0,\n                y = -4.9,\n                z = 0,\n            },\n            aimTolerance = 2,\n            pitchAxis = {\n                x = 0,\n                y = 0,\n                z = string.find(turret, \"Right\", 1, true) and -1 or 1,\n            },\n            reduceMuzzleVelocityToTarget = true,\n        }\n        -- Supreme Commander Overhaul UEF Fatboy Gauss arc 2.0.0";

	private const string LegacyGaussRandomnessComment = "            -- Sanctuary applies firing randomness after it has solved the very\n            -- shallow LowArc trajectory.  The source 1.1-degree cone can therefore\n            -- pitch a shell down enough to miss roughly a quarter of its range.\n            -- Keep the Gauss battery deterministic until the engine exposes\n            -- aim-space spread that preserves the ballistic solution.";

	private const string PreviousGaussRandomnessComment = "            -- FA uses 4.9 gravity for this LowArc battery. Sanctuary applies\n            -- firing randomness after solving that trajectory, so the source\n            -- 1.1-degree cone can still shorten a shell's flight. Keep the Gauss\n            -- battery deterministic until the engine exposes aim-space spread\n            -- that preserves the ballistic solution.";

	private const string HighArcGaussRandomnessComment = "            -- The converted Fatboy needs Sanctuary's HighArc branch to clear\n            -- its hull and intervening terrain. Post-solve firing randomness can\n            -- still pull a shell off that ballistic solution, so keep the Gauss\n            -- battery deterministic until aim-space spread is available.";

	private const string HostClassesRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua";

	private const string HostUnitBaseRelativePath = "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua";

	private const string ClientClassesRelativePath = "LJ/lua/client/units/unitsClasses/unitsDefaultEDA.lua";

	private const string AvailableUnitsRelativePath = "LJ/lua/common/units/availableUnits.lua";

	private const string ImportRelativePath = "LJ/lua/common/systems/import.lua";

	private const string UnitTemplateLoaderRelativePath = "LJ/lua/common/loading/unitTemplateLoader.lua";

	private const string ProjectileRootRelativePath = "LJ/lua/common/projectiles/projectilesTemplates";

	private const string ColliderPromotionHook = "\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\n-- HostUnit:PromoteToUnit enables collision exactly once when a placement\n-- ghost becomes a real unit. Factory-owned children must remain pinned\n-- until their host moves them clear of imported hull geometry.\nif not _G.SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled then\n    _G.SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled = true\n    local SCOFatboyUnit = HostUnit or Unit\n    if not SCOFatboyUnit then\n        error(\"Fatboy collider hook could not resolve the host unit base class\")\n    end\n    local StockUnitPromoteToUnit = SCOFatboyUnit.PromoteToUnit\n    function SCOFatboyUnit:PromoteToUnit()\n        StockUnitPromoteToUnit(self)\n        if self.scoFactoryColliderPinOwner ~= nil then\n            Engine.SetVolumeColliderEnabled(self.id, false)\n        end\n    end\nend\n\n-- Native HostUnit:SetTargetable owns collider enablement; current targeting\n-- queries unit state directly and has no TargetCollider:Dirty event bridge.";

	private static readonly ProjectileSpec[] Projectiles = new ProjectileSpec[4]
	{
		new ProjectileSpec("psf401", "Fatboy_Gauss_Cannon", "VFX/Trails/vet1301_cannon_large_trail.sanvfx", "VFX/Impact/vei1301_cannon_large_impact.sanvfx", null),
		new ProjectileSpec("psf402", "Fatboy_Riot_Gun", "VFX/Trails/vet1121_autocannon_small_trail.sanvfx", "VFX/Impact/vei1121_autocannon_small_impact.sanvfx", null),
		new ProjectileSpec("psf403", "Fatboy_Linked_Railgun", "VFX/Trails/vct3121_cannon_antiair_small_trail.sanvfx", "VFX/Impact/vci3121_cannon_antiair_small_impact.sanvfx", null),
		new ProjectileSpec("psf404", "Fatboy_Angler_Torpedo", "VFX/Trails/vet2101_rocket_antitank_small_trail.sanvfx", "VFX/Environment/vxi5201_water_splash_medium_impact.sanvfx", "movement = {\n    acceleration = 5,\n    alignToVelocity = true,\n    gravityMultiplier = 0,\n    rotationSpeed = 230,\n    speedMax = 18,\n    type = \"TargetEntity\",\n},")
	};

	private const string TemplateOverride = "\n\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\n-- UEL0401 gameplay data is intentionally explicit here. UEL4511 is a dormant\n-- Sanctuary placeholder, so no stock Grendel combat or structure behavior is\n-- retained.\nUnitTemplate.general.displayName = \"Tier 4: Experimental Mobile Factory\"\nUnitTemplate.general.name = \"Fatboy\"\nUnitTemplate.general.class = {\n    \"unitsDefaultEDA\",\n    \"EDAFatboyMobileFactory\",\n}\nUnitTemplate.general.icon = {\n    shape = \"experimental1\",\n    symbol = \"land\",\n    tech = \"t1\",\n}\nUnitTemplate.general.iconUI = \"tech3_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 80\nUnitTemplate.general.iconUIType = \"amphibious\"\nUnitTemplate.general.orders = {\n    Assist = true,\n    Attack = true,\n    AttackMove = true,\n    Move = true,\n    Patrol = true,\n    Pause = false,\n    Stop = true,\n}\nUnitTemplate.general.toggles = {\n    Pause = false,\n    RepeatBuild = true,\n    Shield = true,\n}\n\nUnitTemplate.collisionInfo = {\n    centerOffset = {\n        x = 0,\n        y = 0.75,\n        z = 0,\n    },\n    collisionSize = {\n        x = 5.5,\n        y = 1.5,\n        z = 8,\n    },\n    targetBones = {\n        \"Bay_Cover\",\n        \"Front_Core\",\n        \"Rear_Core\",\n        \"Ramp\",\n        \"Turret_Left01\",\n        \"Turret_Left02\",\n        \"Turret_Right01\",\n        \"Turret_Right02\",\n        \"Root\",\n    },\n}\nUnitTemplate.footprint = {\n    x = 5.5,\n    y = 8,\n}\nUnitTemplate.skirtSize = {\n    x = 9,\n    y = 9,\n}\n\nUnitTemplate.construction = {\n    beam = {\n        boneName = \"Build_Attachpoint\",\n        offset = {\n            x = 0,\n            y = 0,\n            z = 0,\n        },\n        shrink = 0.6,\n    },\n    buildPower = 180,\n    canBuild = \"Tags.EDA * Tags.LAND * Tags.MOBILE * Tags.BUILDABLE_BY_T3_FACTORY\",\n    range = 20,\n    rollOffPoints = {\n        {\n            offset = {\n                x = 0,\n                y = 0,\n                z = -2.083794,\n            },\n            platformOffset = {\n                x = 0,\n                y = 0,\n                z = 0,\n            },\n            rollOffTime = 2,\n            unitSpin = 0,\n        },\n    },\n}\n\nUnitTemplate.defence = {\n    health = {\n        max = 12500,\n        regen = 20,\n        value = 12500,\n    },\n    shields = {\n        {\n            boneName = \"Root\",\n            max = 20000,\n            name = \"Bubble Shield\",\n            offset = {\n                y = -7,\n            },\n            radii = {\n                x = 25,\n                y = 25,\n                z = 25,\n            },\n            -- Damage pops retain FA's 160-second ShieldRechargeTime. Energy\n            -- stalls and manual toggles use the separate five-second drain\n            -- recharge handled by EDAFatboyMobileFactory.\n            energyDrainRechargeTime = 5,\n            rechargeHPRatio = 1,\n            rechargeTime = 160,\n            regen = 64,\n            regenDelay = 1,\n            type = 0,\n            value = 20000,\n        },\n    },\n}\n\nUnitTemplate.economy = {\n    buildTime = 21000,\n    cost = {\n        alloys = 28000,\n        energy = 350000,\n    },\n    maintenanceConsumption = {\n        energy = 500,\n    },\n    storage = {\n        alloys = 200,\n        energy = 1000,\n    },\n}\n\nUnitTemplate.intel = {\n    -- The Fatboy must acquire any enemy its DirectFire battery can reach\n    -- without depending on external radar.\n    visionRadius = 100,\n    waterVisionRadius = 100,\n}\nUnitTemplate.movement = {\n    acceleration = 1.75,\n    deceleration = 1.75,\n    mass = 0,\n    rotationSpeed = 30,\n    sortOrder = 6,\n    speed = 1.75,\n    type = \"TracksSeabed\",\n    walkAnimation = {\n        authoredSpeed = 1.75,\n    },\n}\nUnitTemplate.tags = {\n    \"AMPHIBIOUS\",\n    \"ANTI_AIR\",\n    \"ANTI_NAVY\",\n    \"ANTI_SURFACE\",\n    \"BUILDABLE_BY_T3_ENGINEER\",\n    \"CONSTRUCTION\",\n    \"DIRECT_FIRE\",\n    \"EDA\",\n    \"ENERGY_STORAGE\",\n    \"FACTORY\",\n    \"LAND\",\n    \"MOBILE\",\n    \"SEABED\",\n    \"SHIELD\",\n    \"TANK\",\n    \"TECH4\",\n}\n\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.buildBeamBones = {\n    \"Arm_Right01_Build_Emitter\",\n    \"Arm_Right02_Build_Emitter\",\n    \"Arm_Right03_Build_Emitter\",\n    \"Arm_Left01_Build_Emitter\",\n    \"Arm_Left02_Build_Emitter\",\n    \"Arm_Left03_Build_Emitter\",\n}\n-- The stock schema would otherwise generate one embedded Construction Beam at\n-- Build_Attachpoint. This port owns six loose endpoint-aware beams through\n-- EDAUefLandFactory, so leave the construction gameplay table intact but do\n-- not create an unmanaged renderer.\nUnitTemplate.construction.beam = nil\nUnitTemplate.additions.selectionHit = {\n    offset = {\n        x = 0,\n        y = 0.75,\n        z = -0.3,\n    },\n    size = {\n        x = 4,\n        y = 5.25,\n    },\n}\n\nUnitTemplate.visuals.animations = {\n    build = {\n        clipName = \"AnimBuild\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/uel4511/LOD0/uel4511.sananimation\",\n    },\n    close = {\n        clipName = \"AnimClose\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/uel4511/LOD0/uel4511.sananimation\",\n    },\n    walk = {\n        clipName = \"Rest\",\n        sanAnimationPath = \"Units/uel4511/LOD0/uel4511.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsInstant = {\n    onDeath = {\n        {\n            audioName = \"unit_death_land_eda_large\",\n            boneName = \"Root\",\n            particleName = \"VFX/Death/ved2301_death_building_large.sanvfx\",\n        },\n    },\n}\nUnitTemplate.visuals.effectsPersistent = {\n    {\n        boneName = \"Wheel_Left01\",\n        particleName = \"VFX/SCOM/Fatboy/track_trail.sanvfx\",\n    },\n    {\n        boneName = \"Wheel_Left02\",\n        particleName = \"VFX/SCOM/Fatboy/track_trail.sanvfx\",\n    },\n    {\n        boneName = \"Wheel_Right01\",\n        particleName = \"VFX/SCOM/Fatboy/track_trail.sanvfx\",\n    },\n    {\n        boneName = \"Wheel_Right02\",\n        particleName = \"VFX/SCOM/Fatboy/track_trail.sanvfx\",\n    },\n}\n-- These particle effects are ambient factory machinery, not construction\n-- beams: they have no live endpoint and produce detached white streaks when\n-- mounted on the animated arm emitters. EDAUefLandFactory already supplies\n-- one endpoint-aware construction beam per entry in buildBeamBones.\nUnitTemplate.visuals.effectsWhenActive = nil\nUnitTemplate.visuals.mesh = {\n    lod0distance = 300,\n    lod1distance = 780,\n}\nUnitTemplate.visuals.selection = {\n    offset = {\n        x = 0,\n        y = 0.75,\n        z = -0.3,\n    },\n    size = {\n        x = 4,\n        y = 5.25,\n    },\n}\n\ndo\n    local function FatboyAimController(\n        aimBone,\n        yawBone,\n        pitchBone,\n        defaultYaw,\n        yawRange,\n        yawSpeed,\n        defaultPitch,\n        pitchMin,\n        pitchMax,\n        pitchSpeed,\n        projectileSpeed,\n        solverType,\n        leadTarget,\n        controllerSettings\n    )\n        return {\n            aimBone = aimBone,\n            aimGravity = controllerSettings.aimGravity,\n            aimTolerance = controllerSettings.aimTolerance,\n            defaultPitchAdjustment = defaultPitch,\n            defaultYawAdjustment = defaultYaw,\n            leadTarget = leadTarget,\n            pitchBone = pitchBone,\n            pitchMax = pitchMax,\n            pitchMin = pitchMin,\n            pitchSpeed = pitchSpeed,\n            poseResetTime = 3,\n            projectileSpeed = projectileSpeed,\n            reduceMuzzleVelocityToTarget = controllerSettings.reduceMuzzleVelocityToTarget,\n            solverType = solverType,\n            yawBone = yawBone,\n            -- Sanctuary uses defaultYawAdjustment only while a controller has\n            -- no target.  The live yaw clamp is relative to the rig's rest\n            -- axis, so FA's TurretYaw must also center the target-time limits.\n            yawMax = defaultYaw + yawRange,\n            yawMin = defaultYaw - yawRange,\n            yawSpeed = yawSpeed,\n        }\n    end\n\n    local function FatboyMuzzleMap(muzzles, aimBones)\n        local result = {}\n        for index, muzzle in ipairs(muzzles) do\n            result[muzzle] = {\n                aimController = aimBones[index],\n            }\n        end\n        return result\n    end\n\n    local function FatboyGaussWeapon(turret, defaultYaw, yawRange)\n        local muzzles = {\n            turret .. \"_Muzzle01\",\n            turret .. \"_Muzzle02\",\n            turret .. \"_Muzzle03\",\n        }\n        local controllerSettings = {\n            aimTolerance = 2,\n            reduceMuzzleVelocityToTarget = true,\n        }\n        -- The three FA rack barrels share one yaw bone but own independent\n        -- pitch bones. Sanctuary's stock shared-turret pattern uses one\n        -- yaw-only controller plus one pitch-only controller per muzzle.\n        local aimControllers = {\n            FatboyAimController(\n                turret,\n                turret,\n                nil,\n                defaultYaw,\n                yawRange,\n                50,\n                nil,\n                nil,\n                nil,\n                nil,\n                25,\n                \"LowArc\",\n                true,\n                controllerSettings\n            ),\n        }\n        for index, muzzle in ipairs(muzzles) do\n            table.insert(aimControllers, FatboyAimController(\n                muzzle,\n                nil,\n                turret .. \"_Barrel0\" .. index,\n                0,\n                yawRange,\n                50,\n                0,\n                -60,\n                60,\n                50,\n                25,\n                \"LowArc\",\n                true,\n                controllerSettings\n            ))\n        end\n\n        return {\n            aimControllers = aimControllers,\n            damage = 250,\n            damageRadius = 1.5,\n            damageType = \"Normal\",\n            effects = {\n                onFire = \"VFX/Muzzle/vem1301_cannon_large_muzzle.sanvfx\",\n            },\n            -- Sanctuary applies firing randomness after it has solved the very\n            -- shallow LowArc trajectory.  The source 1.1-degree cone can therefore\n            -- pitch a shell down enough to miss roughly a quarter of its range.\n            -- Keep the Gauss battery deterministic until the engine exposes\n            -- aim-space spread that preserves the ballistic solution.\n            firingRandomness = 0,\n            layerTargetLimits = {\n                \"Land\",\n                \"WaterSurface\",\n                \"Seabed\",\n            },\n            layerWeaponLimits = {\n                \"Land\",\n                \"Seabed\",\n            },\n            muzzleGroupChargeDelay = 0,\n            muzzleGroupTimeOut = -1,\n            muzzleGroups = {\n                {\n                    muzzles = muzzles,\n                },\n            },\n            muzzleSalvoDelay = 0,\n            muzzleSalvoSize = 1,\n            muzzles = FatboyMuzzleMap(muzzles, muzzles),\n            projectileLifetime = 4.6,\n            projectileTemplate = \"psf401\",\n            rangeMax = 100,\n            rangeMin = 0,\n            rangeRingType = \"DirectFire\",\n            rangeTracking = 1.15,\n            reloadTime = 1,\n            targetWaterLimits = \"Above\",\n        }\n    end\n\n    local function FatboyRiotWeapon(side, defaultYaw)\n        local yawBone = \"Riot_Gun_\" .. side\n        local pitchBone = yawBone .. \"_Barrel\"\n        local muzzle = pitchBone .. \"_Muzzle\"\n        return {\n            aimControllers = {\n                FatboyAimController(\n                    muzzle,\n                    yawBone,\n                    pitchBone,\n                    defaultYaw,\n                    90,\n                    60,\n                    0,\n                    -25,\n                    25,\n                    30,\n                    45,\n                    \"LowArc\",\n                    true,\n                    {\n                        aimGravity = {\n                            x = 0,\n                            y = 0,\n                            z = 0,\n                        },\n                        aimTolerance = 2,\n                        reduceMuzzleVelocityToTarget = false,\n                    }\n                ),\n            },\n            damage = 150,\n            damageRadius = 0,\n            damageType = \"Normal\",\n            effects = {\n                onFire = \"VFX/Muzzle/vem1121_autocannon_small_muzzle.sanvfx\",\n            },\n            firingRandomness = 0,\n            layerTargetLimits = {\n                \"Land\",\n                \"WaterSurface\",\n                \"Seabed\",\n            },\n            layerWeaponLimits = {\n                \"Land\",\n                \"Seabed\",\n            },\n            muzzleGroupChargeDelay = 0,\n            muzzleGroupTimeOut = -1,\n            muzzleGroups = {\n                {\n                    muzzles = {\n                        muzzle,\n                    },\n                },\n            },\n            muzzleSalvoDelay = 0,\n            muzzleSalvoSize = 1,\n            muzzles = {\n                [muzzle] = {\n                    aimController = muzzle,\n                },\n            },\n            projectileLifetime = 1.15,\n            projectileTemplate = \"psf402\",\n            rangeMax = 45,\n            rangeMin = 0,\n            rangeRingType = \"DirectFire\",\n            rangeTracking = 1.15,\n            reloadTime = 0.3333333333333333,\n            targetWaterLimits = \"Above\",\n        }\n    end\n\n    local function FatboyAAWeapon(side)\n        local yawBone = \"Turret_\" .. side .. \"_AA\"\n        local pitchBone = yawBone .. \"_Barrel\"\n        local muzzle01 = yawBone .. \"_Muzzle01\"\n        local muzzle02 = yawBone .. \"_Muzzle02\"\n        return {\n            aimControllers = {\n                FatboyAimController(\n                    muzzle01,\n                    yawBone,\n                    pitchBone,\n                    0,\n                    180,\n                    180,\n                    45,\n                    -45,\n                    45,\n                    180,\n                    90,\n                    \"NoArc\",\n                    true,\n                    {\n                        aimGravity = {\n                            x = 0,\n                            y = 0,\n                            z = 0,\n                        },\n                        aimTolerance = 0.05,\n                        reduceMuzzleVelocityToTarget = false,\n                    }\n                ),\n            },\n            damage = 20,\n            damageRadius = 0,\n            damageType = \"Normal\",\n            effects = {\n                onFire = \"VFX/Muzzle/vem1121_autocannon_antiair_small_muzzle.sanvfx\",\n            },\n            firingRandomness = 0.01,\n            layerTargetLimits = {\n                \"Air\",\n            },\n            layerWeaponLimits = {\n                \"Land\",\n                \"Seabed\",\n                \"Water\",\n            },\n            muzzleGroupChargeDelay = 0,\n            muzzleGroupTimeOut = -1,\n            muzzleGroups = {\n                {\n                    muzzles = {\n                        muzzle01,\n                    },\n                },\n                {\n                    muzzles = {\n                        muzzle02,\n                    },\n                },\n            },\n            muzzleSalvoDelay = 0,\n            muzzleSalvoSize = 1,\n            muzzles = {\n                [muzzle01] = {\n                    aimController = muzzle01,\n                },\n                [muzzle02] = {\n                    aimController = muzzle01,\n                },\n            },\n            projectileLifetime = 0.625,\n            projectileTemplate = \"psf403\",\n            rangeMax = 45,\n            rangeMin = 0,\n            rangeRingType = \"AntiAir\",\n            rangeTracking = 1.4,\n            reloadTime = 0.6666666666666666,\n            targetWaterLimits = \"Above\",\n        }\n    end\n\n    local function FatboyTorpedoWeapon()\n        local muzzles = {\n            \"Torpedo_01\",\n            \"Torpedo_02\",\n            \"Torpedo_03\",\n            \"Torpedo_04\",\n        }\n        local aimControllers = {}\n        local muzzleGroups = {}\n        for _, muzzle in ipairs(muzzles) do\n            -- FA marks this launcher Turreted=false. Sanctuary nevertheless\n            -- requires an on-target aim controller to spawn any projectile and\n            -- to pass the homing target ID into TargetEntity movement. A fixed\n            -- zero-rate controller with a 180-degree tolerance is therefore a\n            -- non-visual compatibility adapter: the native muzzle never turns,\n            -- and the 230-degree/second turn rate remains on the torpedo itself.\n            table.insert(aimControllers, {\n                aimBone = muzzle,\n                aimTolerance = 180,\n                defaultPitchAdjustment = 0,\n                defaultYawAdjustment = 0,\n                leadTarget = false,\n                pitchBone = muzzle,\n                pitchMax = 0,\n                pitchMin = 0,\n                pitchSpeed = 0,\n                poseResetTime = -1,\n                projectileSpeed = 5,\n                solverType = \"NoArc\",\n                yawBone = muzzle,\n                yawMax = 0,\n                yawMin = 0,\n                yawSpeed = 0,\n            })\n            table.insert(muzzleGroups, {\n                muzzles = {\n                    muzzle,\n                },\n            })\n        end\n\n        return {\n            aimControllers = aimControllers,\n            damage = 75,\n            damageRadius = 0,\n            damageType = \"Normal\",\n            firingRandomness = 0,\n            layerTargetLimits = {\n                \"Seabed\",\n                \"Water\",\n                \"WaterSurface\",\n            },\n            layerWeaponLimits = {\n                \"Seabed\",\n            },\n            muzzleGroupChargeDelay = 0,\n            muzzleGroupTimeOut = -1,\n            muzzleGroups = muzzleGroups,\n            muzzleSalvoDelay = 0,\n            muzzleSalvoSize = 1,\n            muzzles = FatboyMuzzleMap(muzzles, muzzles),\n            projectileLifetime = 9,\n            projectileTemplate = \"psf404\",\n            rangeMax = 40,\n            rangeMin = 0,\n            rangeRingType = \"AntiNaval\",\n            rangeTracking = 1.15,\n            reloadTime = 4,\n            targetWaterLimits = \"Below\",\n        }\n    end\n\n    UnitTemplate.weapons = {\n        FatboyGaussWeapon(\"Turret_Right01\", -20, 100),\n        FatboyGaussWeapon(\"Turret_Right02\", 30, 110),\n        FatboyGaussWeapon(\"Turret_Left01\", 20, 100),\n        FatboyGaussWeapon(\"Turret_Left02\", -30, 110),\n        -- Both source manipulators have TurretYaw = 0. Their authored native\n        -- bone orientations already face the right/left side arcs.\n        FatboyRiotWeapon(\"Right\", 0),\n        FatboyRiotWeapon(\"Left\", 0),\n        FatboyAAWeapon(\"Right\"),\n        FatboyAAWeapon(\"Left\"),\n        FatboyTorpedoWeapon(),\n        {\n            category = \"DeathExplosion\",\n            damage = 4000,\n            damageFriendly = true,\n            damageRadius = 7,\n            damageType = \"Normal\",\n        },\n    }\nend";

	private const string HostClassOverride = "\r\n\r\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\r\n-- Mobile Factory composition: retain Factory queue ownership, but delegate the\r\n-- mobile lifecycle to EDALandUnit and never reserve a permanent structure grid.\r\nlocal FatboyTargetingLayer = Import(\"common/layers.lua\").TargetingLayer\r\nlocal FatboyOrderTasks = Import(\"common/commonOrders.lua\").OrderTasks\r\nlocal FatboyHostOrderManager = Import(\"host/managers/orders/hostOrderManager.lua\")\r\nlocal FatboyCurve = Import(\"host/curves.lua\").Curve\r\nlocal FatboyBayAnimationSeconds = 2.87333336\r\n\r\nlocal function FatboyIsAlive(unit)\r\n    return unit ~= nil and not unit.dead and not unit.deleted\r\nend\r\n\r\nlocal function FatboyWorldPoint(factory, x, y, z)\r\n    local rotated = Engine.QuaternionRotateVector(\r\n        factory:GetOrientation(),\r\n        EngineClasses.float3(x, y, z)\r\n    )\r\n    local origin = factory:GetPosition()\r\n    return EngineClasses.float3(\r\n        origin.x + rotated.x,\r\n        origin.y + rotated.y,\r\n        origin.z + rotated.z\r\n    )\r\nend\r\n\r\nlocal function FatboyRearOrientation(factory)\r\n    return Engine.QuaternionRotateY(factory:GetOrientation(), math.pi)\r\nend\r\n\r\nlocal function FatboyGroundPoint(factory, x, z)\r\n    local position = FatboyWorldPoint(factory, x, 0, z)\r\n    local _, terrainHeight = Engine.SampleTerrainHeight(\r\n        EngineClasses.float3(position.x, 0, position.z)\r\n    )\r\n    return EngineClasses.float3(position.x, terrainHeight, position.z)\r\nend\r\n\r\nlocal function FatboyIsSubmerged(factory)\r\n    local _, hasWater = Engine.HasWater()\r\n    if not hasWater then\r\n        return false\r\n    end\r\n\r\n    local _, waterLevel = Engine.GetWaterLevel()\r\n    return factory:GetPosition().y < waterLevel - 0.25\r\nend\r\n\r\nHostEDAFatboyMobileFactory = Class(\"EDAFatboyMobileFactory\", EDALandFactory)\r\nlocal EDAFatboyMobileFactory = HostEDAFatboyMobileFactory\r\n\r\nlocal function FatboyShieldEnergyState(factory)\r\n    local economy = factory.army and factory.army.economy\r\n    local energy = economy and economy.resources and economy.resources.energy\r\n    if not economy or not energy then\r\n        return 0, false\r\n    end\r\n\r\n    -- Sanctuary reports an energy stall whenever storage is below one, even\r\n    -- when generation exactly meets demand. Satisfaction is the authoritative\r\n    -- per-tick supply fraction and therefore avoids that zero-storage deadlock.\r\n    if not economy.isEnergyDown then\r\n        return 1, true\r\n    end\r\n\r\n    local satisfaction = energy.satisfaction or 0\r\n    satisfaction = math.max(0, math.min(satisfaction, 1))\r\n    return satisfaction, satisfaction >= 1\r\nend\r\n\r\nlocal function FatboyCancelNativeShieldTimers(shield)\r\n    if shield.rechargeThread then\r\n        KillThread(shield.rechargeThread)\r\n        shield.rechargeThread = nil\r\n    end\r\n    if shield.regenAfterDelayThread then\r\n        KillThread(shield.regenAfterDelayThread)\r\n        shield.regenAfterDelayThread = nil\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:CancelFatboyShieldRestart(resetProgress)\r\n    self.fatboyShieldRestartGeneration =\r\n        (self.fatboyShieldRestartGeneration or 0) + 1\r\n    if self.fatboyShieldRestartThread then\r\n        KillThread(self.fatboyShieldRestartThread)\r\n        self.fatboyShieldRestartThread = nil\r\n    end\r\n    if resetProgress then\r\n        self.fatboyShieldRestartProgress = 0\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:CancelFatboyShieldEnergyMonitor()\r\n    self.fatboyShieldEnergyMonitorGeneration =\r\n        (self.fatboyShieldEnergyMonitorGeneration or 0) + 1\r\n    if self.fatboyShieldEnergyMonitorThread then\r\n        KillThread(self.fatboyShieldEnergyMonitorThread)\r\n        self.fatboyShieldEnergyMonitorThread = nil\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:BeginFatboyShieldOperationalDisable(shield)\r\n    self:CancelFatboyShieldEnergyMonitor()\r\n    if self.fatboyShieldOperationallyDisabled then\r\n        return\r\n    end\r\n\r\n    self:CancelFatboyShieldRestart(true)\r\n    -- This override never uses Shield.rechargeThread for operational restarts,\r\n    -- so an existing native thread uniquely identifies damage-pop recharge.\r\n    -- Do not inspect HP: Sanctuary clamps Entity health to at least one.\r\n    self.fatboyShieldDamageRechargePending = shield.rechargeThread ~= nil\r\n\r\n    FatboyCancelNativeShieldTimers(shield)\r\n\r\n    shield.isEnableable = false\r\n    shield:SetEnabled(false)\r\n    shield:SetRegenEnabled(false)\r\n    self.fatboyShieldOperationallyDisabled = true\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:EnableFatboyShieldImmediately(shield, fullHealth)\r\n    self:CancelFatboyShieldRestart(true)\r\n    self:CancelFatboyShieldEnergyMonitor()\r\n    FatboyCancelNativeShieldTimers(shield)\r\n    self.fatboyShieldOperationallyDisabled = false\r\n    self.fatboyShieldDamageRechargePending = false\r\n    shield.isEnableable = true\r\n    shield:SetEnabled(true)\r\n    shield:SetRegenEnabled(true)\r\n    if fullHealth then\r\n        shield:SetHealth(shield:GetMaxHealth())\r\n    end\r\n    self.fatboyShieldRestartFullHealth = false\r\n    self:StartFatboyShieldEnergyMonitor(shield)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:FatboyShieldRestartThread(generation, shield)\r\n    local shieldTemplate = shield.tp or {}\r\n    local rechargeTicks =\r\n        (shieldTemplate.energyDrainRechargeTime or 5) * Constants.TickRate\r\n\r\n    while FatboyIsAlive(self)\r\n        and FatboyIsAlive(shield)\r\n        and generation == self.fatboyShieldRestartGeneration\r\n        and self:IsCompleted()\r\n        and self:GetShieldToggle()\r\n    do\r\n        local _, energyStable = FatboyShieldEnergyState(self)\r\n\r\n        if self.fatboyShieldDamageRechargePending then\r\n            if energyStable then\r\n                self.fatboyShieldRestartThread = nil\r\n                self.fatboyShieldOperationallyDisabled = false\r\n                self.fatboyShieldDamageRechargePending = false\r\n                shield.isEnableable = true\r\n                shield.rechargeThread = shield:NewThread(shield.RechargeThread)\r\n                self:StartFatboyShieldEnergyMonitor(shield)\r\n                return\r\n            end\r\n        elseif (self.fatboyShieldRestartProgress or 0) >= rechargeTicks then\r\n            if energyStable then\r\n                self.fatboyShieldRestartThread = nil\r\n                self.fatboyShieldOperationallyDisabled = false\r\n                shield.isEnableable = true\r\n                shield:SetEnabled(true)\r\n                shield:SetRegenEnabled(true)\r\n                if self.fatboyShieldRestartFullHealth then\r\n                    shield:SetHealth(shield:GetMaxHealth())\r\n                end\r\n                self.fatboyShieldRestartFullHealth = false\r\n                self:StartFatboyShieldEnergyMonitor(shield)\r\n                return\r\n            end\r\n        end\r\n\r\n        WaitTicks(1)\r\n        if not self.fatboyShieldDamageRechargePending then\r\n            local tickSatisfaction = FatboyShieldEnergyState(self)\r\n            self.fatboyShieldRestartProgress =\r\n                (self.fatboyShieldRestartProgress or 0)\r\n                + tickSatisfaction\r\n        end\r\n    end\r\n\r\n    if generation == self.fatboyShieldRestartGeneration then\r\n        self.fatboyShieldRestartThread = nil\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:FatboyShieldEnergyMonitorThread(generation, shield)\r\n    while FatboyIsAlive(self)\r\n        and FatboyIsAlive(shield)\r\n        and generation == self.fatboyShieldEnergyMonitorGeneration\r\n        and self:IsCompleted()\r\n        and self:GetShieldToggle()\r\n    do\r\n        local economy = self.army and self.army.economy\r\n        if not economy or not economy.isEnergyDown then\r\n            break\r\n        end\r\n\r\n        local _, energyStable = FatboyShieldEnergyState(self)\r\n        if not energyStable then\r\n            self.fatboyShieldEnergyMonitorThread = nil\r\n            self:BeginFatboyShieldOperationalDisable(shield)\r\n            self:StartFatboyShieldRestart(shield)\r\n            return\r\n        end\r\n        WaitTicks(1)\r\n    end\r\n\r\n    if generation == self.fatboyShieldEnergyMonitorGeneration then\r\n        self.fatboyShieldEnergyMonitorThread = nil\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:StartFatboyShieldEnergyMonitor(shield)\r\n    local economy = self.army and self.army.economy\r\n    if self.fatboyShieldEnergyMonitorThread\r\n        or not economy\r\n        or not economy.isEnergyDown\r\n    then\r\n        return\r\n    end\r\n\r\n    self.fatboyShieldEnergyMonitorGeneration =\r\n        (self.fatboyShieldEnergyMonitorGeneration or 0) + 1\r\n    local generation = self.fatboyShieldEnergyMonitorGeneration\r\n    self.fatboyShieldEnergyMonitorThread = self:NewThread(\r\n        self.FatboyShieldEnergyMonitorThread,\r\n        generation,\r\n        shield\r\n    )\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:StartFatboyShieldRestart(shield)\r\n    if self.fatboyShieldRestartThread\r\n        or not self:IsCompleted()\r\n        or not self:GetShieldToggle()\r\n    then\r\n        return\r\n    end\r\n\r\n    self.fatboyShieldRestartGeneration =\r\n        (self.fatboyShieldRestartGeneration or 0) + 1\r\n    local generation = self.fatboyShieldRestartGeneration\r\n    self.fatboyShieldRestartThread = self:NewThread(\r\n        self.FatboyShieldRestartThread,\r\n        generation,\r\n        shield\r\n    )\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:CheckShieldState(skipRecharge)\r\n    local shield = self.shields and self.shields[1]\r\n    if not shield then\r\n        return\r\n    end\r\n\r\n    local wantsShield = self:IsCompleted() and self:GetShieldToggle()\r\n    if self.resourceEntities.consumption then\r\n        self.resourceEntities.consumption:SetEnabled(wantsShield)\r\n    end\r\n\r\n    local _, energyStable = FatboyShieldEnergyState(self)\r\n    self:SetRotatorsEnabled(wantsShield and energyStable)\r\n\r\n    if not wantsShield then\r\n        self:BeginFatboyShieldOperationalDisable(shield)\r\n        self:CancelFatboyShieldRestart(true)\r\n        return\r\n    end\r\n\r\n    if skipRecharge then\r\n        if energyStable then\r\n            self:EnableFatboyShieldImmediately(shield, true)\r\n            return\r\n        end\r\n        self.fatboyShieldRestartFullHealth = true\r\n    end\r\n\r\n    if shield:IsEnabled() then\r\n        if energyStable then\r\n            self:StartFatboyShieldEnergyMonitor(shield)\r\n            return\r\n        end\r\n        self:BeginFatboyShieldOperationalDisable(shield)\r\n    elseif shield.rechargeThread and not self.fatboyShieldOperationallyDisabled then\r\n        if energyStable then\r\n            self:StartFatboyShieldEnergyMonitor(shield)\r\n            return\r\n        end\r\n        self:BeginFatboyShieldOperationalDisable(shield)\r\n    elseif not self.fatboyShieldOperationallyDisabled then\r\n        self:BeginFatboyShieldOperationalDisable(shield)\r\n    end\r\n\r\n    self:StartFatboyShieldRestart(shield)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:CanBeSlaveFactory()\r\n    return false\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:CanBeMasterFactory()\r\n    return false\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:PromoteToUnit()\r\n    EDALandUnit.PromoteToUnit(self)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:UpdateAnimations()\r\n    -- The mobile factory has event-driven build/close clips, not walk/run\r\n    -- clips. Placement ghosts have no Movement component, so avoid the base\r\n    -- animation loop's movement-speed query.\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnBuildProcessStarted()\r\n    -- External builders construct the Fatboy itself through Buildable, not\r\n    -- through this factory's child-production callback. Start the deployment\r\n    -- clip here so the bay opens while its own construction is in progress.\r\n    EDALandFactory.OnBuildProcessStarted(self)\r\n    self:SetAnimatorEnabled(true)\r\n    self:PlayFatboyAnimation(\"build\")\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnBuildProcessEnded()\r\n    EDALandFactory.OnBuildProcessEnded(self)\r\n    -- A completed Fatboy may immediately start an already queued child build;\r\n    -- leave its bay open in that case. Paused or canceled external construction\r\n    -- returns safely to the closed pose.\r\n    if not self.dead and not self:IsCompleted() then\r\n        self:PlayFatboyAnimation(\"close\")\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:RefreshFatboyWeaponTargets()\r\n    -- A targeter can be created while an enemy is already inside its range.\r\n    -- Mark only empty targeters and let TargeterManager perform its normal\r\n    -- next-tick recalculation/dirty-clear after collision state has settled.\r\n    for _, weapon in ipairs(self.weapons or {}) do\r\n        if weapon.targeterCollider and not weapon:HasTarget() then\r\n            weapon.targeterCollider.isDirty = true\r\n        end\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:CancelFatboyTargetRefresh()\r\n    self.fatboyTargetRefreshGeneration =\r\n        (self.fatboyTargetRefreshGeneration or 0) + 1\r\n    if self.fatboyTargetRefreshThread then\r\n        KillThread(self.fatboyTargetRefreshThread)\r\n        self.fatboyTargetRefreshThread = nil\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:FatboyTargetRefreshThread(generation)\r\n    -- Collision registration and intel visibility settle on separate ticks.\r\n    -- This bounded retry covers enemies already in range at completion or\r\n    -- attack-order time; new entrants remain event-driven.\r\n    for _, delayTicks in ipairs({ 1, 4, 12 }) do\r\n        WaitTicks(delayTicks)\r\n        if not FatboyIsAlive(self)\r\n            or not self:IsCompleted()\r\n            or generation ~= self.fatboyTargetRefreshGeneration\r\n        then\r\n            break\r\n        end\r\n        self:RefreshFatboyWeaponTargets()\r\n    end\r\n\r\n    if generation == self.fatboyTargetRefreshGeneration then\r\n        self.fatboyTargetRefreshThread = nil\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:StartFatboyTargetRefresh()\r\n    self:CancelFatboyTargetRefresh()\r\n    if not FatboyIsAlive(self) or not self:IsCompleted() then\r\n        return\r\n    end\r\n\r\n    self:RefreshFatboyWeaponTargets()\r\n    local generation = self.fatboyTargetRefreshGeneration\r\n    self.fatboyTargetRefreshThread = self:NewThread(\r\n        self.FatboyTargetRefreshThread,\r\n        generation\r\n    )\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnStopBeingBuilt()\r\n    -- EDALandFactory supplies Unit completion plus the factory production\r\n    -- monitor. Add only MobileUnit's movement/grid tail to avoid a double Unit\r\n    -- completion callback.\r\n    EDALandFactory.OnStopBeingBuilt(self)\r\n    Engine.SetMovementEnabled(self.id, true)\r\n    Engine.SetNavmapModifierEnabled(self.id, false)\r\n    Engine.SetGlobalGridModifierEnabled(self.id, false)\r\n    self.fatboyMovementLocked = false\r\n    self.fatboySubmerged = nil\r\n    self.fatboyLayerThread = self:NewThread(self.FatboyLayerUpdateThread)\r\n    self:StartFatboyTargetRefresh()\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:AttackBehaviorStart(targetUnit, range)\r\n    EDALandFactory.AttackBehaviorStart(self, targetUnit, range)\r\n    if self.attackBehaviorIsActive then\r\n        self:StartFatboyTargetRefresh()\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:AttackBehaviorStop()\r\n    self:CancelFatboyTargetRefresh()\r\n    EDALandFactory.AttackBehaviorStop(self)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:SetFatboyMovementLocked(locked)\r\n    if self.fatboyMovementLocked == locked then\r\n        return\r\n    end\r\n\r\n    self.fatboyMovementLocked = locked\r\n    Engine.SetMovementEnabled(self.id, not locked)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:PlayFatboyAnimation(name)\r\n    local animations = self.tp.visuals and self.tp.visuals.animations\r\n    local animation = animations and animations[name]\r\n    if animation and animation.id then\r\n        Engine.PlayAnimation(self.id, animation.id, 0.1)\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:StopFatboyBuildColliderPin(targetUnit)\r\n    if targetUnit ~= nil and self.fatboyPinnedBuildTarget ~= targetUnit then\r\n        return\r\n    end\r\n    local pinnedTarget = self.fatboyPinnedBuildTarget\r\n    if self.fatboyBuildPoseThread then\r\n        KillThread(self.fatboyBuildPoseThread)\r\n        self.fatboyBuildPoseThread = nil\r\n    end\r\n    if pinnedTarget and pinnedTarget.scoFactoryColliderPinOwner == self then\r\n        local callbacks = self.fatboyBuildCallbacks\r\n        if callbacks then\r\n            pinnedTarget.OnStopBeingBuilt = callbacks.onStopBeingBuilt\r\n            pinnedTarget.UpdateAnimations = callbacks.updateAnimations\r\n        end\r\n        pinnedTarget.scoFactoryColliderPinOwner = nil\r\n    end\r\n    self.fatboyPinnedBuildTarget = nil\r\n    self.fatboyBuildCallbacks = nil\r\n    self.fatboyRollOffTarget = nil\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:HoldFatboyBuildPose(targetUnit)\r\n    if not FatboyIsAlive(targetUnit) then return end\r\n    Engine.SetMovementEnabled(targetUnit.id, false)\r\n    Engine.SetVolumeColliderEnabled(targetUnit.id, false)\r\n    targetUnit:SetOrientation(FatboyRearOrientation(self))\r\n    if self.fatboyRollOffTarget ~= targetUnit then\r\n        targetUnit:SetPosition(FatboyWorldPoint(self, 0, 0.669224, -2.083794))\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:FatboyBuildPoseThread(targetUnit)\r\n    while FatboyIsAlive(self) and FatboyIsAlive(targetUnit)\r\n        and self.fatboyPinnedBuildTarget == targetUnit\r\n    do\r\n        self:HoldFatboyBuildPose(targetUnit)\r\n        WaitTicks(1)\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:PinFatboyBuildCollider(targetUnit)\r\n    if not FatboyIsAlive(targetUnit) then return end\r\n    if self.fatboyPinnedBuildTarget == targetUnit then\r\n        self:HoldFatboyBuildPose(targetUnit)\r\n        return\r\n    end\r\n    self:StopFatboyBuildColliderPin()\r\n    self.fatboyPinnedBuildTarget = targetUnit\r\n    self.fatboyBuildCallbacks = {\r\n        onStopBeingBuilt = rawget(targetUnit, \"OnStopBeingBuilt\"),\r\n        updateAnimations = rawget(targetUnit, \"UpdateAnimations\"),\r\n    }\r\n    local onStopBeingBuilt = targetUnit.OnStopBeingBuilt\r\n    targetUnit.OnStopBeingBuilt = function(unit, ...)\r\n        onStopBeingBuilt(unit, ...)\r\n        -- Mobile completion enables movement after the factory's stop callback.\r\n        if unit.scoFactoryColliderPinOwner == self then\r\n            self:HoldFatboyBuildPose(unit)\r\n        end\r\n    end\r\n    -- Native animation speed follows actual SimVelocity while Curve.Play drives\r\n    -- the child; the ordinary updater reads the disabled mover's stale speed.\r\n    targetUnit.UpdateAnimations = function() end\r\n    targetUnit.scoFactoryColliderPinOwner = self\r\n    self:HoldFatboyBuildPose(targetUnit)\r\n    self.fatboyBuildPoseThread = self:NewThread(self.FatboyBuildPoseThread, targetUnit)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:GetFatboyRollOffGroundPoint(targetUnit)\r\n    local hull = self.tp.collisionInfo\r\n    local child = targetUnit.tp.collisionInfo\r\n    local hullRear = (hull.centerOffset.z or 0) - hull.collisionSize.z * 0.5\r\n    local childRear = child.collisionSize.z * 0.5 - (child.centerOffset.z or 0)\r\n    -- FA's 17-unit attachment slide is 3.74 at the converted 0.22 scale.\r\n    -- Large products must also clear the carrier's collision hull completely.\r\n    local rear = math.min(-5.823794, hullRear - childRear - 0.25)\r\n    local position = FatboyGroundPoint(self, 0, rear)\r\n    position.y = position.y + (targetUnit.tp.movement.preferredAltitude or 0)\r\n    return position\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:ReleaseFatboyBuiltUnit(targetUnit, interrupted)\r\n    if not FatboyIsAlive(targetUnit) or not targetUnit:IsCompleted() then\r\n        return false\r\n    end\r\n    if self.fatboyPinnedBuildTarget ~= targetUnit then\r\n        return true\r\n    end\r\n    if interrupted then\r\n        -- A stopped production coroutine cannot finish its curve. Preserve the\r\n        -- completed unit at a clear terrain point before releasing ownership.\r\n        targetUnit:SetPosition(self:GetFatboyRollOffGroundPoint(targetUnit))\r\n        targetUnit:SetOrientation(FatboyRearOrientation(self))\r\n    end\r\n    self:StopFatboyBuildColliderPin(targetUnit)\r\n    Engine.SetVolumeColliderEnabled(targetUnit.id, true)\r\n    Engine.SetMovementEnabled(targetUnit.id, true)\r\n    targetUnit:UpdateAnimations()\r\n    return true\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:MoveFatboyBuiltUnit(targetUnit, destination, duration, startPosition)\r\n    local origin = startPosition or targetUnit:GetPosition()\r\n    local curve = FatboyCurve.Play(targetUnit, {\r\n        duration = duration,\r\n        position = {\r\n            mode = FatboyCurve.Absolute,\r\n            x = FatboyCurve.Linear(origin.x, destination.x),\r\n            y = FatboyCurve.EaseInOut(origin.y, destination.y),\r\n            z = FatboyCurve.Linear(origin.z, destination.z),\r\n        },\r\n    })\r\n    while FatboyIsAlive(self) and FatboyIsAlive(targetUnit)\r\n        and self.fatboyPinnedBuildTarget == targetUnit\r\n    do\r\n        local progress = duration > 0 and (_G.Time - curve.startTime) / duration or 1\r\n        -- World-position reads lag transform writes until the next native tick.\r\n        -- Clamp the next sample before applying it, without reading it back.\r\n        local position = curve:Sample(math.clamp(progress, 0, 1))\r\n        local _, terrainHeight = Engine.SampleTerrainHeight(position)\r\n        local groundY = terrainHeight + (targetUnit.tp.movement.preferredAltitude or 0)\r\n        if position.y < groundY then\r\n            position.y = groundY\r\n        end\r\n        Engine.SetGlobalEntityPosition(targetUnit.id, position)\r\n        if progress >= 1 then return true, position end\r\n        WaitTicks(1)\r\n    end\r\n    return false\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:FatboyLayerUpdateThread()\r\n    while not self.dead do\r\n        local submerged = FatboyIsSubmerged(self)\r\n        if submerged ~= self.fatboySubmerged then\r\n            self.fatboySubmerged = submerged\r\n            self:SetTargetingLayer(submerged\r\n                and FatboyTargetingLayer.Seabed\r\n                or FatboyTargetingLayer.Land)\r\n\r\n            -- The FA Fatboy cannot manufacture underwater. Preserve the queued\r\n            -- item, but abort/delete the partial child as soon as it submerges.\r\n            if submerged and self.productionBehaviorIsActive then\r\n                self:ProductionBehaviorStop()\r\n            end\r\n        end\r\n        WaitTicks(4)\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:ProductionBehaviorIsValidFor()\r\n    if FatboyIsSubmerged(self) then\r\n        return false\r\n    end\r\n    return EDALandFactory.ProductionBehaviorIsValidFor(self)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:GetRollOffPoint()\r\n    -- Build-box compatibility maps this hook to the live construction API.\r\n    -- The native attachment sits just above the rear tray surface.\r\n    return FatboyWorldPoint(self, 0, 0.669224, -2.083794)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnStartBuildRoutine(targetUnit)\r\n    local newTarget = self.fatboyPinnedBuildTarget ~= targetUnit\r\n    self:SetFatboyMovementLocked(true)\r\n    self:PinFatboyBuildCollider(targetUnit)\r\n    EDALandFactory.OnStartBuildRoutine(self, targetUnit)\r\n    self:HoldFatboyBuildPose(targetUnit)\r\n    if newTarget then\r\n        self:PlayFatboyAnimation(\"build\")\r\n        self.fatboyBayReadyTime = _G.Time + FatboyBayAnimationSeconds\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnStopBuildRoutine(targetUnit)\r\n    if FatboyIsAlive(targetUnit) then\r\n        self:HoldFatboyBuildPose(targetUnit)\r\n    end\r\n    EDALandFactory.OnStopBuildRoutine(self, targetUnit)\r\n    -- A pause keeps the partial child on the open tray. Completed products\r\n    -- leave through RollOffUnit before the bay closes.\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:ProductionBehaviorBuildOne(item)\r\n    self:SetFatboyMovementLocked(true)\r\n    self.fatboyClosePending = false\r\n    EDALandFactory.ProductionBehaviorBuildOne(self, item)\r\n    if self.fatboyClosePending and not self.dead then\r\n        -- The stock queue already waits two seconds after RollOffUnit.\r\n        WaitSeconds(FatboyBayAnimationSeconds - 2)\r\n    end\r\n    self.fatboyClosePending = false\r\n    self:SetFatboyMovementLocked(false)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:RollOffUnit(targetUnit)\r\n    if not FatboyIsAlive(targetUnit) then\r\n        self:StopFatboyBuildColliderPin(targetUnit)\r\n        return\r\n    end\r\n    self:SetFatboyMovementLocked(true)\r\n    if self.fatboyPinnedBuildTarget ~= targetUnit then\r\n        self:PinFatboyBuildCollider(targetUnit)\r\n        self:PlayFatboyAnimation(\"build\")\r\n        self.fatboyBayReadyTime = _G.Time + FatboyBayAnimationSeconds\r\n    end\r\n    while FatboyIsAlive(self) and FatboyIsAlive(targetUnit)\r\n        and self.fatboyPinnedBuildTarget == targetUnit\r\n        and _G.Time < (self.fatboyBayReadyTime or 0)\r\n    do\r\n        WaitTicks(1)\r\n    end\r\n    if not FatboyIsAlive(self) or not FatboyIsAlive(targetUnit)\r\n        or self.fatboyPinnedBuildTarget ~= targetUnit\r\n    then\r\n        self:StopFatboyBuildColliderPin(targetUnit)\r\n        return\r\n    end\r\n    self:HoldFatboyBuildPose(targetUnit)\r\n    self.fatboyRollOffTarget = targetUnit\r\n    local animations = targetUnit.tp.visuals.animations\r\n    local gait = animations and (animations.run or animations.walk)\r\n    if gait and gait.id then\r\n        targetUnit:SetAnimatorEnabled(true)\r\n        targetUnit.isWalking = animations.run == nil\r\n        Engine.PlayAnimation(targetUnit.id, gait.id, 0.1)\r\n    end\r\n    local groundPoint = self:GetFatboyRollOffGroundPoint(targetUnit)\r\n    local origin = targetUnit:GetPosition()\r\n    local deckEnd = EngineClasses.float3(\r\n        groundPoint.x, math.max(origin.y, groundPoint.y), groundPoint.z)\r\n    local dx, dz = deckEnd.x - origin.x, deckEnd.z - origin.z\r\n    local speed = math.max(0.1, math.min(2.2, targetUnit.tp.movement.speed or 2.2))\r\n    local moved, position = self:MoveFatboyBuiltUnit(\r\n        targetUnit, deckEnd, math.sqrt(dx * dx + dz * dz) / speed)\r\n    if moved then\r\n        moved = self:MoveFatboyBuiltUnit(targetUnit, groundPoint, 0.3, position)\r\n    end\r\n    if moved and self:ReleaseFatboyBuiltUnit(targetUnit) then\r\n        local clearance = FatboyGroundPoint(self, 0, -15)\r\n        FatboyHostOrderManager.HostIssueOrder(\r\n            FatboyOrderTasks.MOVE, {targetUnit}, false, clearance, nil)\r\n        local source = self.unitBeingBuiltSource or self\r\n        if source.rallyPoint then\r\n            FatboyHostOrderManager.HostIssueOrder(\r\n                FatboyOrderTasks.MOVE, {targetUnit}, true, source.rallyPoint, nil)\r\n        end\r\n    else\r\n        self:StopFatboyBuildColliderPin(targetUnit)\r\n    end\r\n    if FatboyIsAlive(self) then\r\n        self:PlayFatboyAnimation(\"close\")\r\n        self.fatboyClosePending = true\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:ProductionBehaviorStop()\r\n    local targetUnit = self.fatboyPinnedBuildTarget or self.productionBehaviorTargetUnit\r\n    local closeAfterStop = FatboyIsAlive(targetUnit) and not targetUnit:IsCompleted()\r\n    self:ReleaseFatboyBuiltUnit(targetUnit, true)\r\n    self:StopFatboyBuildColliderPin(targetUnit)\r\n    EDALandFactory.ProductionBehaviorStop(self)\r\n    self:SetFatboyMovementLocked(false)\r\n    if closeAfterStop then\r\n        self:PlayFatboyAnimation(\"close\")\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnCancelConstruction()\r\n    self:ReleaseFatboyBuiltUnit(self.fatboyPinnedBuildTarget, true)\r\n    self:StopFatboyBuildColliderPin()\r\n    EDALandFactory.OnCancelConstruction(self)\r\n    self:SetFatboyMovementLocked(false)\r\n    self:PlayFatboyAnimation(\"close\")\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnDestroy(isDelete)\r\n    self:CancelFatboyTargetRefresh()\r\n    self:CancelFatboyShieldRestart(true)\r\n    self:CancelFatboyShieldEnergyMonitor()\r\n    if self.fatboyLayerThread then\r\n        KillThread(self.fatboyLayerThread)\r\n        self.fatboyLayerThread = nil\r\n    end\r\n    self:ReleaseFatboyBuiltUnit(self.fatboyPinnedBuildTarget, true)\r\n    self:StopFatboyBuildColliderPin()\r\n    self:SetFatboyMovementLocked(false)\r\n    EDALandFactory.OnDestroy(self, isDelete)\r\nend";

	private const string ClientClassOverride = "\n\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\n-- Reuse the imported UEF endpoint-beam implementation when the structure\n-- module precedes this one. Mobile overrides below still suppress tarmac,\n-- permanent-grid, structure selection, and structure intel behavior.\nlocal FatboyClientFactoryBase = EDAUefLandFactory or EDALandFactory\n\nlocal function FatboySetLocalVolumeColliderEnabled(globalId, enabled)\n    local localId = EngineClasses.LocalID()\n    local errorCode = Engine.GetGlobalEntityPairedLocalID(globalId, localId)\n    if errorCode == EngineErrorCode.Success and Engine.IsValidLocalID(localId) then\n        Engine.SetVolumeColliderEnabled(localId, enabled)\n    end\nend\n\nClientEDAFatboyMobileFactory = Class(\"EDAFatboyMobileFactory\", FatboyClientFactoryBase)\nlocal EDAFatboyMobileFactory = ClientEDAFatboyMobileFactory\n\nfunction EDAFatboyMobileFactory:CreateTarmac()\nend\n\nfunction EDAFatboyMobileFactory:OnPromoteToUnit()\n    EDALandUnit.OnPromoteToUnit(self)\nend\n\nfunction EDAFatboyMobileFactory:OnCompleted()\n    EDALandUnit.OnCompleted(self)\nend\n\nfunction EDAFatboyMobileFactory:IsHighlightable()\n    return EDALandUnit.IsHighlightable(self)\nend\n\nfunction EDAFatboyMobileFactory:IsSelectable()\n    return EDALandUnit.IsSelectable(self)\nend\n\nfunction EDAFatboyMobileFactory:OnIntelHidden()\n    EDALandUnit.OnIntelHidden(self)\nend\n\nfunction EDAFatboyMobileFactory:OnIntelVision()\n    EDALandUnit.OnIntelVision(self)\nend\n\nfunction EDAFatboyMobileFactory:OnIntelRadar()\n    EDALandUnit.OnIntelRadar(self)\n    self:RecalculateConstructionBeamState()\nend\n\nfunction EDAFatboyMobileFactory:ClientOnStopBuilding()\n    local targetUnit = self.buildTarget\n    FatboyClientFactoryBase.ClientOnStopBuilding(self)\n    if targetUnit and not targetUnit:IsCompleted() then\n        -- Host construction ownership persists across a production pause.\n        targetUnit:SetSelectionEnabled(false)\n        FatboySetLocalVolumeColliderEnabled(targetUnit.id, false)\n    end\nend\n\nfunction EDAFatboyMobileFactory:OnDestroy(isDelete)\n    -- This parent call owns endpoint-beam disposal. CreateTarmac and the intel\n    -- overrides above keep its structure-only presentation inert.\n    FatboyClientFactoryBase.OnDestroy(self, isDelete)\nend\n\nfunction EDAFatboyMobileFactory:OnDelete()\n    FatboyClientFactoryBase.OnDelete(self)\nend";

	private const string AvailableUnitsAppendix = "\n\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\nAvailableUnits[\"uel4511\"] = true";

	private const string ImportScannerAppendix = "\n\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\n-- FilesCache owns these virtual projectile templates, while the stock scanner\n-- sees physical folders only. Chain whichever scanner a prior patcher supplied.\nlocal SCO_FatboyScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_FatboyScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n\n    local knownFolders = {}\n    for _, folder in ipairs(folders) do\n        knownFolders[folder] = true\n    end\n\n    local fatboyProjectiles = {\n        \"psf401\",\n        \"psf402\",\n        \"psf403\",\n        \"psf404\",\n    }\n    for _, templateId in ipairs(fatboyProjectiles) do\n        local folder = directory .. templateId\n        if not knownFolders[folder] then\n            table.insert(folders, folder)\n        end\n    end\n    return folders\nend";

	private const string PrematureFatboyMovementLock = "function EDAFatboyMobileFactory:ProductionBehaviorBuildOne(item)\r\n    self:SetFatboyMovementLocked(true)\r\n    self.fatboyClosePending = false";

	private const string CapSafeFatboyMovementLock = "function EDAFatboyMobileFactory:ProductionBehaviorBuildOne(item)\r\n    -- Mirror the native pre-build wait before locking the mobile hull.\r\n    while not self.dead and (self:GetPause() or not self.army:HasUnitCapSpace()) do\r\n        WaitTicks(5)\r\n    end\r\n    if self.dead then return end\r\n    self:SetFatboyMovementLocked(true)\r\n    self.fatboyClosePending = false";

	private const string NativeFactoryClassesRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefault.lua";

	private const string NativeFactoryPreBuildWait = "function HostFactory:ProductionBehaviorBuildOne(item)\n    -- Keep the queue intact while waiting for unit cap space.\n    while not self.dead and (self:GetPause() or not self.army:HasUnitCapSpace()) do\n        WaitTicks(5)\n    end\n    if self.dead then return end\n    self.unitBeingBuiltSource = self.unitBeingBuiltSource or self";

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			ValidateNativeFactoryPreBuildWait(obj);
			QueueAppend(obj, list, "LJ/lua/common/units/unitsTemplates/uel4511/uel4511.santp", "UEL4511 Fatboy unit template", delegate(string source)
			{
				if (source.Contains("UnitTemplate =") && source.Contains("tpId = \"uel4511\"") && source.Contains("\"EDAStructure\"") && source.Contains("\"DEMO_UI_ONLY\""))
				{
					RequireTokens(source, "UnitTemplate =", "tpId = \"uel4511\"", "\"EDAStructure\"", "\"DEMO_UI_ONLY\"");
				}
				else
				{
					RequireTokens(source, "UnitTemplate =", "tpId = \"uel4511\"", "\"unitsDefaultEDA\"", "\"EDAFatboyMobileFactory\"");
				}
			}, "\n\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\n-- UEL0401 gameplay data is intentionally explicit here. UEL4511 is a dormant\n-- Sanctuary placeholder, so no stock Grendel combat or structure behavior is\n-- retained.\nUnitTemplate.general.displayName = \"Tier 4: Experimental Mobile Factory\"\nUnitTemplate.general.name = \"Fatboy\"\nUnitTemplate.general.class = {\n    \"unitsDefaultEDA\",\n    \"EDAFatboyMobileFactory\",\n}\nUnitTemplate.general.icon = {\n    shape = \"experimental1\",\n    symbol = \"land\",\n    tech = \"t1\",\n}\nUnitTemplate.general.iconUI = \"tech3_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 80\nUnitTemplate.general.iconUIType = \"amphibious\"\nUnitTemplate.general.orders = {\n    Assist = true,\n    Attack = true,\n    AttackMove = true,\n    Move = true,\n    Patrol = true,\n    Pause = false,\n    Stop = true,\n}\nUnitTemplate.general.toggles = {\n    Pause = false,\n    RepeatBuild = true,\n    Shield = true,\n}\n\nUnitTemplate.collisionInfo = {\n    centerOffset = {\n        x = 0,\n        y = 0.75,\n        z = 0,\n    },\n    collisionSize = {\n        x = 5.5,\n        y = 1.5,\n        z = 8,\n    },\n    targetBones = {\n        \"Bay_Cover\",\n        \"Front_Core\",\n        \"Rear_Core\",\n        \"Ramp\",\n        \"Turret_Left01\",\n        \"Turret_Left02\",\n        \"Turret_Right01\",\n        \"Turret_Right02\",\n        \"Root\",\n    },\n}\nUnitTemplate.footprint = {\n    x = 5.5,\n    y = 8,\n}\nUnitTemplate.skirtSize = {\n    x = 9,\n    y = 9,\n}\n\nUnitTemplate.construction = {\n    beam = {\n        boneName = \"Build_Attachpoint\",\n        offset = {\n            x = 0,\n            y = 0,\n            z = 0,\n        },\n        shrink = 0.6,\n    },\n    buildPower = 180,\n    canBuild = \"Tags.EDA * Tags.LAND * Tags.MOBILE * Tags.BUILDABLE_BY_T3_FACTORY\",\n    range = 20,\n    rollOffPoints = {\n        {\n            offset = {\n                x = 0,\n                y = 0,\n                z = -2.083794,\n            },\n            platformOffset = {\n                x = 0,\n                y = 0,\n                z = 0,\n            },\n            rollOffTime = 2,\n            unitSpin = 0,\n        },\n    },\n}\n\nUnitTemplate.defence = {\n    health = {\n        max = 12500,\n        regen = 20,\n        value = 12500,\n    },\n    shields = {\n        {\n            boneName = \"Root\",\n            max = 20000,\n            name = \"Bubble Shield\",\n            offset = {\n                y = -7,\n            },\n            radii = {\n                x = 25,\n                y = 25,\n                z = 25,\n            },\n            -- Damage pops retain FA's 160-second ShieldRechargeTime. Energy\n            -- stalls and manual toggles use the separate five-second drain\n            -- recharge handled by EDAFatboyMobileFactory.\n            energyDrainRechargeTime = 5,\n            rechargeHPRatio = 1,\n            rechargeTime = 160,\n            regen = 64,\n            regenDelay = 1,\n            type = 0,\n            value = 20000,\n        },\n    },\n}\n\nUnitTemplate.economy = {\n    buildTime = 21000,\n    cost = {\n        alloys = 28000,\n        energy = 350000,\n    },\n    maintenanceConsumption = {\n        energy = 500,\n    },\n    storage = {\n        alloys = 200,\n        energy = 1000,\n    },\n}\n\nUnitTemplate.intel = {\n    -- The Fatboy must acquire any enemy its DirectFire battery can reach\n    -- without depending on external radar.\n    visionRadius = 100,\n    waterVisionRadius = 100,\n}\nUnitTemplate.movement = {\n    acceleration = 1.75,\n    deceleration = 1.75,\n    mass = 0,\n    rotationSpeed = 30,\n    sortOrder = 6,\n    speed = 1.75,\n    type = \"TracksSeabed\",\n    walkAnimation = {\n        authoredSpeed = 1.75,\n    },\n}\nUnitTemplate.tags = {\n    \"AMPHIBIOUS\",\n    \"ANTI_AIR\",\n    \"ANTI_NAVY\",\n    \"ANTI_SURFACE\",\n    \"BUILDABLE_BY_T3_ENGINEER\",\n    \"CONSTRUCTION\",\n    \"DIRECT_FIRE\",\n    \"EDA\",\n    \"ENERGY_STORAGE\",\n    \"FACTORY\",\n    \"LAND\",\n    \"MOBILE\",\n    \"SEABED\",\n    \"SHIELD\",\n    \"TANK\",\n    \"TECH4\",\n}\n\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.buildBeamBones = {\n    \"Arm_Right01_Build_Emitter\",\n    \"Arm_Right02_Build_Emitter\",\n    \"Arm_Right03_Build_Emitter\",\n    \"Arm_Left01_Build_Emitter\",\n    \"Arm_Left02_Build_Emitter\",\n    \"Arm_Left03_Build_Emitter\",\n}\n-- The stock schema would otherwise generate one embedded Construction Beam at\n-- Build_Attachpoint. This port owns six loose endpoint-aware beams through\n-- EDAUefLandFactory, so leave the construction gameplay table intact but do\n-- not create an unmanaged renderer.\nUnitTemplate.construction.beam = nil\nUnitTemplate.additions.selectionHit = {\n    offset = {\n        x = 0,\n        y = 0.75,\n        z = -0.3,\n    },\n    size = {\n        x = 4,\n        y = 5.25,\n    },\n}\n\nUnitTemplate.visuals.animations = {\n    build = {\n        clipName = \"AnimBuild\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/uel4511/LOD0/uel4511.sananimation\",\n    },\n    close = {\n        clipName = \"AnimClose\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/uel4511/LOD0/uel4511.sananimation\",\n    },\n    walk = {\n        clipName = \"Rest\",\n        sanAnimationPath = \"Units/uel4511/LOD0/uel4511.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsInstant = {\n    onDeath = {\n        {\n            audioName = \"unit_death_land_eda_large\",\n            boneName = \"Root\",\n            particleName = \"VFX/Death/ved2301_death_building_large.sanvfx\",\n        },\n    },\n}\nUnitTemplate.visuals.effectsPersistent = {\n    {\n        boneName = \"Wheel_Left01\",\n        particleName = \"VFX/SCOM/Fatboy/track_trail.sanvfx\",\n    },\n    {\n        boneName = \"Wheel_Left02\",\n        particleName = \"VFX/SCOM/Fatboy/track_trail.sanvfx\",\n    },\n    {\n        boneName = \"Wheel_Right01\",\n        particleName = \"VFX/SCOM/Fatboy/track_trail.sanvfx\",\n    },\n    {\n        boneName = \"Wheel_Right02\",\n        particleName = \"VFX/SCOM/Fatboy/track_trail.sanvfx\",\n    },\n}\n-- These particle effects are ambient factory machinery, not construction\n-- beams: they have no live endpoint and produce detached white streaks when\n-- mounted on the animated arm emitters. EDAUefLandFactory already supplies\n-- one endpoint-aware construction beam per entry in buildBeamBones.\nUnitTemplate.visuals.effectsWhenActive = nil\nUnitTemplate.visuals.mesh = {\n    lod0distance = 300,\n    lod1distance = 780,\n}\nUnitTemplate.visuals.selection = {\n    offset = {\n        x = 0,\n        y = 0.75,\n        z = -0.3,\n    },\n    size = {\n        x = 4,\n        y = 5.25,\n    },\n}\n\ndo\n    local function FatboyAimController(\n        aimBone,\n        yawBone,\n        pitchBone,\n        defaultYaw,\n        yawRange,\n        yawSpeed,\n        defaultPitch,\n        pitchMin,\n        pitchMax,\n        pitchSpeed,\n        projectileSpeed,\n        solverType,\n        leadTarget,\n        controllerSettings\n    )\n        return {\n            aimBone = aimBone,\n            aimGravity = controllerSettings.aimGravity,\n            aimTolerance = controllerSettings.aimTolerance,\n            defaultPitchAdjustment = defaultPitch,\n            defaultYawAdjustment = defaultYaw,\n            leadTarget = leadTarget,\n            pitchBone = pitchBone,\n            pitchMax = pitchMax,\n            pitchMin = pitchMin,\n            pitchSpeed = pitchSpeed,\n            poseResetTime = 3,\n            projectileSpeed = projectileSpeed,\n            reduceMuzzleVelocityToTarget = controllerSettings.reduceMuzzleVelocityToTarget,\n            solverType = solverType,\n            yawBone = yawBone,\n            -- Sanctuary uses defaultYawAdjustment only while a controller has\n            -- no target.  The live yaw clamp is relative to the rig's rest\n            -- axis, so FA's TurretYaw must also center the target-time limits.\n            yawMax = defaultYaw + yawRange,\n            yawMin = defaultYaw - yawRange,\n            yawSpeed = yawSpeed,\n        }\n    end\n\n    local function FatboyMuzzleMap(muzzles, aimBones)\n        local result = {}\n        for index, muzzle in ipairs(muzzles) do\n            result[muzzle] = {\n                aimController = aimBones[index],\n            }\n        end\n        return result\n    end\n\n    local function FatboyGaussWeapon(turret, defaultYaw, yawRange)\n        local muzzles = {\n            turret .. \"_Muzzle01\",\n            turret .. \"_Muzzle02\",\n            turret .. \"_Muzzle03\",\n        }\n        local controllerSettings = {\n            aimTolerance = 2,\n            reduceMuzzleVelocityToTarget = true,\n        }\n        -- The three FA rack barrels share one yaw bone but own independent\n        -- pitch bones. Sanctuary's stock shared-turret pattern uses one\n        -- yaw-only controller plus one pitch-only controller per muzzle.\n        local aimControllers = {\n            FatboyAimController(\n                turret,\n                turret,\n                nil,\n                defaultYaw,\n                yawRange,\n                50,\n                nil,\n                nil,\n                nil,\n                nil,\n                25,\n                \"LowArc\",\n                true,\n                controllerSettings\n            ),\n        }\n        for index, muzzle in ipairs(muzzles) do\n            table.insert(aimControllers, FatboyAimController(\n                muzzle,\n                nil,\n                turret .. \"_Barrel0\" .. index,\n                0,\n                yawRange,\n                50,\n                0,\n                -60,\n                60,\n                50,\n                25,\n                \"LowArc\",\n                true,\n                controllerSettings\n            ))\n        end\n\n        return {\n            aimControllers = aimControllers,\n            damage = 250,\n            damageRadius = 1.5,\n            damageType = \"Normal\",\n            effects = {\n                onFire = \"VFX/Muzzle/vem1301_cannon_large_muzzle.sanvfx\",\n            },\n            -- Sanctuary applies firing randomness after it has solved the very\n            -- shallow LowArc trajectory.  The source 1.1-degree cone can therefore\n            -- pitch a shell down enough to miss roughly a quarter of its range.\n            -- Keep the Gauss battery deterministic until the engine exposes\n            -- aim-space spread that preserves the ballistic solution.\n            firingRandomness = 0,\n            layerTargetLimits = {\n                \"Land\",\n                \"WaterSurface\",\n                \"Seabed\",\n            },\n            layerWeaponLimits = {\n                \"Land\",\n                \"Seabed\",\n            },\n            muzzleGroupChargeDelay = 0,\n            muzzleGroupTimeOut = -1,\n            muzzleGroups = {\n                {\n                    muzzles = muzzles,\n                },\n            },\n            muzzleSalvoDelay = 0,\n            muzzleSalvoSize = 1,\n            muzzles = FatboyMuzzleMap(muzzles, muzzles),\n            projectileLifetime = 4.6,\n            projectileTemplate = \"psf401\",\n            rangeMax = 100,\n            rangeMin = 0,\n            rangeRingType = \"DirectFire\",\n            rangeTracking = 1.15,\n            reloadTime = 1,\n            targetWaterLimits = \"Above\",\n        }\n    end\n\n    local function FatboyRiotWeapon(side, defaultYaw)\n        local yawBone = \"Riot_Gun_\" .. side\n        local pitchBone = yawBone .. \"_Barrel\"\n        local muzzle = pitchBone .. \"_Muzzle\"\n        return {\n            aimControllers = {\n                FatboyAimController(\n                    muzzle,\n                    yawBone,\n                    pitchBone,\n                    defaultYaw,\n                    90,\n                    60,\n                    0,\n                    -25,\n                    25,\n                    30,\n                    45,\n                    \"LowArc\",\n                    true,\n                    {\n                        aimGravity = {\n                            x = 0,\n                            y = 0,\n                            z = 0,\n                        },\n                        aimTolerance = 2,\n                        reduceMuzzleVelocityToTarget = false,\n                    }\n                ),\n            },\n            damage = 150,\n            damageRadius = 0,\n            damageType = \"Normal\",\n            effects = {\n                onFire = \"VFX/Muzzle/vem1121_autocannon_small_muzzle.sanvfx\",\n            },\n            firingRandomness = 0,\n            layerTargetLimits = {\n                \"Land\",\n                \"WaterSurface\",\n                \"Seabed\",\n            },\n            layerWeaponLimits = {\n                \"Land\",\n                \"Seabed\",\n            },\n            muzzleGroupChargeDelay = 0,\n            muzzleGroupTimeOut = -1,\n            muzzleGroups = {\n                {\n                    muzzles = {\n                        muzzle,\n                    },\n                },\n            },\n            muzzleSalvoDelay = 0,\n            muzzleSalvoSize = 1,\n            muzzles = {\n                [muzzle] = {\n                    aimController = muzzle,\n                },\n            },\n            projectileLifetime = 1.15,\n            projectileTemplate = \"psf402\",\n            rangeMax = 45,\n            rangeMin = 0,\n            rangeRingType = \"DirectFire\",\n            rangeTracking = 1.15,\n            reloadTime = 0.3333333333333333,\n            targetWaterLimits = \"Above\",\n        }\n    end\n\n    local function FatboyAAWeapon(side)\n        local yawBone = \"Turret_\" .. side .. \"_AA\"\n        local pitchBone = yawBone .. \"_Barrel\"\n        local muzzle01 = yawBone .. \"_Muzzle01\"\n        local muzzle02 = yawBone .. \"_Muzzle02\"\n        return {\n            aimControllers = {\n                FatboyAimController(\n                    muzzle01,\n                    yawBone,\n                    pitchBone,\n                    0,\n                    180,\n                    180,\n                    45,\n                    -45,\n                    45,\n                    180,\n                    90,\n                    \"NoArc\",\n                    true,\n                    {\n                        aimGravity = {\n                            x = 0,\n                            y = 0,\n                            z = 0,\n                        },\n                        aimTolerance = 0.05,\n                        reduceMuzzleVelocityToTarget = false,\n                    }\n                ),\n            },\n            damage = 20,\n            damageRadius = 0,\n            damageType = \"Normal\",\n            effects = {\n                onFire = \"VFX/Muzzle/vem1121_autocannon_antiair_small_muzzle.sanvfx\",\n            },\n            firingRandomness = 0.01,\n            layerTargetLimits = {\n                \"Air\",\n            },\n            layerWeaponLimits = {\n                \"Land\",\n                \"Seabed\",\n                \"Water\",\n            },\n            muzzleGroupChargeDelay = 0,\n            muzzleGroupTimeOut = -1,\n            muzzleGroups = {\n                {\n                    muzzles = {\n                        muzzle01,\n                    },\n                },\n                {\n                    muzzles = {\n                        muzzle02,\n                    },\n                },\n            },\n            muzzleSalvoDelay = 0,\n            muzzleSalvoSize = 1,\n            muzzles = {\n                [muzzle01] = {\n                    aimController = muzzle01,\n                },\n                [muzzle02] = {\n                    aimController = muzzle01,\n                },\n            },\n            projectileLifetime = 0.625,\n            projectileTemplate = \"psf403\",\n            rangeMax = 45,\n            rangeMin = 0,\n            rangeRingType = \"AntiAir\",\n            rangeTracking = 1.4,\n            reloadTime = 0.6666666666666666,\n            targetWaterLimits = \"Above\",\n        }\n    end\n\n    local function FatboyTorpedoWeapon()\n        local muzzles = {\n            \"Torpedo_01\",\n            \"Torpedo_02\",\n            \"Torpedo_03\",\n            \"Torpedo_04\",\n        }\n        local aimControllers = {}\n        local muzzleGroups = {}\n        for _, muzzle in ipairs(muzzles) do\n            -- FA marks this launcher Turreted=false. Sanctuary nevertheless\n            -- requires an on-target aim controller to spawn any projectile and\n            -- to pass the homing target ID into TargetEntity movement. A fixed\n            -- zero-rate controller with a 180-degree tolerance is therefore a\n            -- non-visual compatibility adapter: the native muzzle never turns,\n            -- and the 230-degree/second turn rate remains on the torpedo itself.\n            table.insert(aimControllers, {\n                aimBone = muzzle,\n                aimTolerance = 180,\n                defaultPitchAdjustment = 0,\n                defaultYawAdjustment = 0,\n                leadTarget = false,\n                pitchBone = muzzle,\n                pitchMax = 0,\n                pitchMin = 0,\n                pitchSpeed = 0,\n                poseResetTime = -1,\n                projectileSpeed = 5,\n                solverType = \"NoArc\",\n                yawBone = muzzle,\n                yawMax = 0,\n                yawMin = 0,\n                yawSpeed = 0,\n            })\n            table.insert(muzzleGroups, {\n                muzzles = {\n                    muzzle,\n                },\n            })\n        end\n\n        return {\n            aimControllers = aimControllers,\n            damage = 75,\n            damageRadius = 0,\n            damageType = \"Normal\",\n            firingRandomness = 0,\n            layerTargetLimits = {\n                \"Seabed\",\n                \"Water\",\n                \"WaterSurface\",\n            },\n            layerWeaponLimits = {\n                \"Seabed\",\n            },\n            muzzleGroupChargeDelay = 0,\n            muzzleGroupTimeOut = -1,\n            muzzleGroups = muzzleGroups,\n            muzzleSalvoDelay = 0,\n            muzzleSalvoSize = 1,\n            muzzles = FatboyMuzzleMap(muzzles, muzzles),\n            projectileLifetime = 9,\n            projectileTemplate = \"psf404\",\n            rangeMax = 40,\n            rangeMin = 0,\n            rangeRingType = \"AntiNaval\",\n            rangeTracking = 1.15,\n            reloadTime = 4,\n            targetWaterLimits = \"Below\",\n        }\n    end\n\n    UnitTemplate.weapons = {\n        FatboyGaussWeapon(\"Turret_Right01\", -20, 100),\n        FatboyGaussWeapon(\"Turret_Right02\", 30, 110),\n        FatboyGaussWeapon(\"Turret_Left01\", 20, 100),\n        FatboyGaussWeapon(\"Turret_Left02\", -30, 110),\n        -- Both source manipulators have TurretYaw = 0. Their authored native\n        -- bone orientations already face the right/left side arcs.\n        FatboyRiotWeapon(\"Right\", 0),\n        FatboyRiotWeapon(\"Left\", 0),\n        FatboyAAWeapon(\"Right\"),\n        FatboyAAWeapon(\"Left\"),\n        FatboyTorpedoWeapon(),\n        {\n            category = \"DeathExplosion\",\n            damage = 4000,\n            damageFriendly = true,\n            damageRadius = 7,\n            damageType = \"Normal\",\n        },\n    }\nend", ValidateFatboyTemplate);
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua", "host Unit promotion collider hook", delegate(string source)
			{
				RequireTokens(source, "local HostEntity = Import", "HostUnit = Class");
			}, "\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\n-- HostUnit:PromoteToUnit enables collision exactly once when a placement\n-- ghost becomes a real unit. Factory-owned children must remain pinned\n-- until their host moves them clear of imported hull geometry.\nif not _G.SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled then\n    _G.SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled = true\n    local SCOFatboyUnit = HostUnit or Unit\n    if not SCOFatboyUnit then\n        error(\"Fatboy collider hook could not resolve the host unit base class\")\n    end\n    local StockUnitPromoteToUnit = SCOFatboyUnit.PromoteToUnit\n    function SCOFatboyUnit:PromoteToUnit()\n        StockUnitPromoteToUnit(self)\n        if self.scoFactoryColliderPinOwner ~= nil then\n            Engine.SetVolumeColliderEnabled(self.id, false)\n        end\n    end\nend\n\n-- Native HostUnit:SetTargetable owns collider enablement; current targeting\n-- queries unit state directly and has no TargetCollider:Dirty event bridge.", delegate(string source)
			{
				RequireTokens(source, "SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled", "function SCOFatboyUnit:PromoteToUnit()", "if self.scoFactoryColliderPinOwner ~= nil then", "function HostUnit:SetTargetable(enabled)", "self.targetCollider:SetEnabled(enabled)");
			});
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", "host EDA unit classes", delegate(string source)
			{
				RequireTokens(source, "EDALandFactory =", "EDALandUnit =");
			}, "\r\n\r\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\r\n-- Mobile Factory composition: retain Factory queue ownership, but delegate the\r\n-- mobile lifecycle to EDALandUnit and never reserve a permanent structure grid.\r\nlocal FatboyTargetingLayer = Import(\"common/layers.lua\").TargetingLayer\r\nlocal FatboyOrderTasks = Import(\"common/commonOrders.lua\").OrderTasks\r\nlocal FatboyHostOrderManager = Import(\"host/managers/orders/hostOrderManager.lua\")\r\nlocal FatboyCurve = Import(\"host/curves.lua\").Curve\r\nlocal FatboyBayAnimationSeconds = 2.87333336\r\n\r\nlocal function FatboyIsAlive(unit)\r\n    return unit ~= nil and not unit.dead and not unit.deleted\r\nend\r\n\r\nlocal function FatboyWorldPoint(factory, x, y, z)\r\n    local rotated = Engine.QuaternionRotateVector(\r\n        factory:GetOrientation(),\r\n        EngineClasses.float3(x, y, z)\r\n    )\r\n    local origin = factory:GetPosition()\r\n    return EngineClasses.float3(\r\n        origin.x + rotated.x,\r\n        origin.y + rotated.y,\r\n        origin.z + rotated.z\r\n    )\r\nend\r\n\r\nlocal function FatboyRearOrientation(factory)\r\n    return Engine.QuaternionRotateY(factory:GetOrientation(), math.pi)\r\nend\r\n\r\nlocal function FatboyGroundPoint(factory, x, z)\r\n    local position = FatboyWorldPoint(factory, x, 0, z)\r\n    local _, terrainHeight = Engine.SampleTerrainHeight(\r\n        EngineClasses.float3(position.x, 0, position.z)\r\n    )\r\n    return EngineClasses.float3(position.x, terrainHeight, position.z)\r\nend\r\n\r\nlocal function FatboyIsSubmerged(factory)\r\n    local _, hasWater = Engine.HasWater()\r\n    if not hasWater then\r\n        return false\r\n    end\r\n\r\n    local _, waterLevel = Engine.GetWaterLevel()\r\n    return factory:GetPosition().y < waterLevel - 0.25\r\nend\r\n\r\nHostEDAFatboyMobileFactory = Class(\"EDAFatboyMobileFactory\", EDALandFactory)\r\nlocal EDAFatboyMobileFactory = HostEDAFatboyMobileFactory\r\n\r\nlocal function FatboyShieldEnergyState(factory)\r\n    local economy = factory.army and factory.army.economy\r\n    local energy = economy and economy.resources and economy.resources.energy\r\n    if not economy or not energy then\r\n        return 0, false\r\n    end\r\n\r\n    -- Sanctuary reports an energy stall whenever storage is below one, even\r\n    -- when generation exactly meets demand. Satisfaction is the authoritative\r\n    -- per-tick supply fraction and therefore avoids that zero-storage deadlock.\r\n    if not economy.isEnergyDown then\r\n        return 1, true\r\n    end\r\n\r\n    local satisfaction = energy.satisfaction or 0\r\n    satisfaction = math.max(0, math.min(satisfaction, 1))\r\n    return satisfaction, satisfaction >= 1\r\nend\r\n\r\nlocal function FatboyCancelNativeShieldTimers(shield)\r\n    if shield.rechargeThread then\r\n        KillThread(shield.rechargeThread)\r\n        shield.rechargeThread = nil\r\n    end\r\n    if shield.regenAfterDelayThread then\r\n        KillThread(shield.regenAfterDelayThread)\r\n        shield.regenAfterDelayThread = nil\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:CancelFatboyShieldRestart(resetProgress)\r\n    self.fatboyShieldRestartGeneration =\r\n        (self.fatboyShieldRestartGeneration or 0) + 1\r\n    if self.fatboyShieldRestartThread then\r\n        KillThread(self.fatboyShieldRestartThread)\r\n        self.fatboyShieldRestartThread = nil\r\n    end\r\n    if resetProgress then\r\n        self.fatboyShieldRestartProgress = 0\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:CancelFatboyShieldEnergyMonitor()\r\n    self.fatboyShieldEnergyMonitorGeneration =\r\n        (self.fatboyShieldEnergyMonitorGeneration or 0) + 1\r\n    if self.fatboyShieldEnergyMonitorThread then\r\n        KillThread(self.fatboyShieldEnergyMonitorThread)\r\n        self.fatboyShieldEnergyMonitorThread = nil\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:BeginFatboyShieldOperationalDisable(shield)\r\n    self:CancelFatboyShieldEnergyMonitor()\r\n    if self.fatboyShieldOperationallyDisabled then\r\n        return\r\n    end\r\n\r\n    self:CancelFatboyShieldRestart(true)\r\n    -- This override never uses Shield.rechargeThread for operational restarts,\r\n    -- so an existing native thread uniquely identifies damage-pop recharge.\r\n    -- Do not inspect HP: Sanctuary clamps Entity health to at least one.\r\n    self.fatboyShieldDamageRechargePending = shield.rechargeThread ~= nil\r\n\r\n    FatboyCancelNativeShieldTimers(shield)\r\n\r\n    shield.isEnableable = false\r\n    shield:SetEnabled(false)\r\n    shield:SetRegenEnabled(false)\r\n    self.fatboyShieldOperationallyDisabled = true\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:EnableFatboyShieldImmediately(shield, fullHealth)\r\n    self:CancelFatboyShieldRestart(true)\r\n    self:CancelFatboyShieldEnergyMonitor()\r\n    FatboyCancelNativeShieldTimers(shield)\r\n    self.fatboyShieldOperationallyDisabled = false\r\n    self.fatboyShieldDamageRechargePending = false\r\n    shield.isEnableable = true\r\n    shield:SetEnabled(true)\r\n    shield:SetRegenEnabled(true)\r\n    if fullHealth then\r\n        shield:SetHealth(shield:GetMaxHealth())\r\n    end\r\n    self.fatboyShieldRestartFullHealth = false\r\n    self:StartFatboyShieldEnergyMonitor(shield)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:FatboyShieldRestartThread(generation, shield)\r\n    local shieldTemplate = shield.tp or {}\r\n    local rechargeTicks =\r\n        (shieldTemplate.energyDrainRechargeTime or 5) * Constants.TickRate\r\n\r\n    while FatboyIsAlive(self)\r\n        and FatboyIsAlive(shield)\r\n        and generation == self.fatboyShieldRestartGeneration\r\n        and self:IsCompleted()\r\n        and self:GetShieldToggle()\r\n    do\r\n        local _, energyStable = FatboyShieldEnergyState(self)\r\n\r\n        if self.fatboyShieldDamageRechargePending then\r\n            if energyStable then\r\n                self.fatboyShieldRestartThread = nil\r\n                self.fatboyShieldOperationallyDisabled = false\r\n                self.fatboyShieldDamageRechargePending = false\r\n                shield.isEnableable = true\r\n                shield.rechargeThread = shield:NewThread(shield.RechargeThread)\r\n                self:StartFatboyShieldEnergyMonitor(shield)\r\n                return\r\n            end\r\n        elseif (self.fatboyShieldRestartProgress or 0) >= rechargeTicks then\r\n            if energyStable then\r\n                self.fatboyShieldRestartThread = nil\r\n                self.fatboyShieldOperationallyDisabled = false\r\n                shield.isEnableable = true\r\n                shield:SetEnabled(true)\r\n                shield:SetRegenEnabled(true)\r\n                if self.fatboyShieldRestartFullHealth then\r\n                    shield:SetHealth(shield:GetMaxHealth())\r\n                end\r\n                self.fatboyShieldRestartFullHealth = false\r\n                self:StartFatboyShieldEnergyMonitor(shield)\r\n                return\r\n            end\r\n        end\r\n\r\n        WaitTicks(1)\r\n        if not self.fatboyShieldDamageRechargePending then\r\n            local tickSatisfaction = FatboyShieldEnergyState(self)\r\n            self.fatboyShieldRestartProgress =\r\n                (self.fatboyShieldRestartProgress or 0)\r\n                + tickSatisfaction\r\n        end\r\n    end\r\n\r\n    if generation == self.fatboyShieldRestartGeneration then\r\n        self.fatboyShieldRestartThread = nil\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:FatboyShieldEnergyMonitorThread(generation, shield)\r\n    while FatboyIsAlive(self)\r\n        and FatboyIsAlive(shield)\r\n        and generation == self.fatboyShieldEnergyMonitorGeneration\r\n        and self:IsCompleted()\r\n        and self:GetShieldToggle()\r\n    do\r\n        local economy = self.army and self.army.economy\r\n        if not economy or not economy.isEnergyDown then\r\n            break\r\n        end\r\n\r\n        local _, energyStable = FatboyShieldEnergyState(self)\r\n        if not energyStable then\r\n            self.fatboyShieldEnergyMonitorThread = nil\r\n            self:BeginFatboyShieldOperationalDisable(shield)\r\n            self:StartFatboyShieldRestart(shield)\r\n            return\r\n        end\r\n        WaitTicks(1)\r\n    end\r\n\r\n    if generation == self.fatboyShieldEnergyMonitorGeneration then\r\n        self.fatboyShieldEnergyMonitorThread = nil\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:StartFatboyShieldEnergyMonitor(shield)\r\n    local economy = self.army and self.army.economy\r\n    if self.fatboyShieldEnergyMonitorThread\r\n        or not economy\r\n        or not economy.isEnergyDown\r\n    then\r\n        return\r\n    end\r\n\r\n    self.fatboyShieldEnergyMonitorGeneration =\r\n        (self.fatboyShieldEnergyMonitorGeneration or 0) + 1\r\n    local generation = self.fatboyShieldEnergyMonitorGeneration\r\n    self.fatboyShieldEnergyMonitorThread = self:NewThread(\r\n        self.FatboyShieldEnergyMonitorThread,\r\n        generation,\r\n        shield\r\n    )\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:StartFatboyShieldRestart(shield)\r\n    if self.fatboyShieldRestartThread\r\n        or not self:IsCompleted()\r\n        or not self:GetShieldToggle()\r\n    then\r\n        return\r\n    end\r\n\r\n    self.fatboyShieldRestartGeneration =\r\n        (self.fatboyShieldRestartGeneration or 0) + 1\r\n    local generation = self.fatboyShieldRestartGeneration\r\n    self.fatboyShieldRestartThread = self:NewThread(\r\n        self.FatboyShieldRestartThread,\r\n        generation,\r\n        shield\r\n    )\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:CheckShieldState(skipRecharge)\r\n    local shield = self.shields and self.shields[1]\r\n    if not shield then\r\n        return\r\n    end\r\n\r\n    local wantsShield = self:IsCompleted() and self:GetShieldToggle()\r\n    if self.resourceEntities.consumption then\r\n        self.resourceEntities.consumption:SetEnabled(wantsShield)\r\n    end\r\n\r\n    local _, energyStable = FatboyShieldEnergyState(self)\r\n    self:SetRotatorsEnabled(wantsShield and energyStable)\r\n\r\n    if not wantsShield then\r\n        self:BeginFatboyShieldOperationalDisable(shield)\r\n        self:CancelFatboyShieldRestart(true)\r\n        return\r\n    end\r\n\r\n    if skipRecharge then\r\n        if energyStable then\r\n            self:EnableFatboyShieldImmediately(shield, true)\r\n            return\r\n        end\r\n        self.fatboyShieldRestartFullHealth = true\r\n    end\r\n\r\n    if shield:IsEnabled() then\r\n        if energyStable then\r\n            self:StartFatboyShieldEnergyMonitor(shield)\r\n            return\r\n        end\r\n        self:BeginFatboyShieldOperationalDisable(shield)\r\n    elseif shield.rechargeThread and not self.fatboyShieldOperationallyDisabled then\r\n        if energyStable then\r\n            self:StartFatboyShieldEnergyMonitor(shield)\r\n            return\r\n        end\r\n        self:BeginFatboyShieldOperationalDisable(shield)\r\n    elseif not self.fatboyShieldOperationallyDisabled then\r\n        self:BeginFatboyShieldOperationalDisable(shield)\r\n    end\r\n\r\n    self:StartFatboyShieldRestart(shield)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:CanBeSlaveFactory()\r\n    return false\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:CanBeMasterFactory()\r\n    return false\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:PromoteToUnit()\r\n    EDALandUnit.PromoteToUnit(self)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:UpdateAnimations()\r\n    -- The mobile factory has event-driven build/close clips, not walk/run\r\n    -- clips. Placement ghosts have no Movement component, so avoid the base\r\n    -- animation loop's movement-speed query.\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnBuildProcessStarted()\r\n    -- External builders construct the Fatboy itself through Buildable, not\r\n    -- through this factory's child-production callback. Start the deployment\r\n    -- clip here so the bay opens while its own construction is in progress.\r\n    EDALandFactory.OnBuildProcessStarted(self)\r\n    self:SetAnimatorEnabled(true)\r\n    self:PlayFatboyAnimation(\"build\")\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnBuildProcessEnded()\r\n    EDALandFactory.OnBuildProcessEnded(self)\r\n    -- A completed Fatboy may immediately start an already queued child build;\r\n    -- leave its bay open in that case. Paused or canceled external construction\r\n    -- returns safely to the closed pose.\r\n    if not self.dead and not self:IsCompleted() then\r\n        self:PlayFatboyAnimation(\"close\")\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:RefreshFatboyWeaponTargets()\r\n    -- A targeter can be created while an enemy is already inside its range.\r\n    -- Mark only empty targeters and let TargeterManager perform its normal\r\n    -- next-tick recalculation/dirty-clear after collision state has settled.\r\n    for _, weapon in ipairs(self.weapons or {}) do\r\n        if weapon.targeterCollider and not weapon:HasTarget() then\r\n            weapon.targeterCollider.isDirty = true\r\n        end\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:CancelFatboyTargetRefresh()\r\n    self.fatboyTargetRefreshGeneration =\r\n        (self.fatboyTargetRefreshGeneration or 0) + 1\r\n    if self.fatboyTargetRefreshThread then\r\n        KillThread(self.fatboyTargetRefreshThread)\r\n        self.fatboyTargetRefreshThread = nil\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:FatboyTargetRefreshThread(generation)\r\n    -- Collision registration and intel visibility settle on separate ticks.\r\n    -- This bounded retry covers enemies already in range at completion or\r\n    -- attack-order time; new entrants remain event-driven.\r\n    for _, delayTicks in ipairs({ 1, 4, 12 }) do\r\n        WaitTicks(delayTicks)\r\n        if not FatboyIsAlive(self)\r\n            or not self:IsCompleted()\r\n            or generation ~= self.fatboyTargetRefreshGeneration\r\n        then\r\n            break\r\n        end\r\n        self:RefreshFatboyWeaponTargets()\r\n    end\r\n\r\n    if generation == self.fatboyTargetRefreshGeneration then\r\n        self.fatboyTargetRefreshThread = nil\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:StartFatboyTargetRefresh()\r\n    self:CancelFatboyTargetRefresh()\r\n    if not FatboyIsAlive(self) or not self:IsCompleted() then\r\n        return\r\n    end\r\n\r\n    self:RefreshFatboyWeaponTargets()\r\n    local generation = self.fatboyTargetRefreshGeneration\r\n    self.fatboyTargetRefreshThread = self:NewThread(\r\n        self.FatboyTargetRefreshThread,\r\n        generation\r\n    )\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnStopBeingBuilt()\r\n    -- EDALandFactory supplies Unit completion plus the factory production\r\n    -- monitor. Add only MobileUnit's movement/grid tail to avoid a double Unit\r\n    -- completion callback.\r\n    EDALandFactory.OnStopBeingBuilt(self)\r\n    Engine.SetMovementEnabled(self.id, true)\r\n    self:SetNavmapModifiersEnabled(false)\r\n    Engine.SetGlobalGridModifierEnabled(self.id, false)\r\n    self.fatboyMovementLocked = false\r\n    self.fatboySubmerged = nil\r\n    self.fatboyLayerThread = self:NewThread(self.FatboyLayerUpdateThread)\r\n    self:StartFatboyTargetRefresh()\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:AttackBehaviorStart(targetUnit, range)\r\n    EDALandFactory.AttackBehaviorStart(self, targetUnit, range)\r\n    if self.attackBehaviorIsActive then\r\n        self:StartFatboyTargetRefresh()\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:AttackBehaviorStop()\r\n    self:CancelFatboyTargetRefresh()\r\n    EDALandFactory.AttackBehaviorStop(self)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:SetFatboyMovementLocked(locked)\r\n    if self.fatboyMovementLocked == locked then\r\n        return\r\n    end\r\n\r\n    self.fatboyMovementLocked = locked\r\n    Engine.SetMovementEnabled(self.id, not locked)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:PlayFatboyAnimation(name)\r\n    local animations = self.tp.visuals and self.tp.visuals.animations\r\n    local animation = animations and animations[name]\r\n    if animation and animation.id then\r\n        Engine.PlayAnimation(self.id, animation.id, 0.1)\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:StopFatboyBuildColliderPin(targetUnit)\r\n    if targetUnit ~= nil and self.fatboyPinnedBuildTarget ~= targetUnit then\r\n        return\r\n    end\r\n    local pinnedTarget = self.fatboyPinnedBuildTarget\r\n    if self.fatboyBuildPoseThread then\r\n        KillThread(self.fatboyBuildPoseThread)\r\n        self.fatboyBuildPoseThread = nil\r\n    end\r\n    if pinnedTarget and pinnedTarget.scoFactoryColliderPinOwner == self then\r\n        local callbacks = self.fatboyBuildCallbacks\r\n        if callbacks then\r\n            pinnedTarget.OnStopBeingBuilt = callbacks.onStopBeingBuilt\r\n            pinnedTarget.UpdateAnimations = callbacks.updateAnimations\r\n        end\r\n        pinnedTarget.scoFactoryColliderPinOwner = nil\r\n    end\r\n    self.fatboyPinnedBuildTarget = nil\r\n    self.fatboyBuildCallbacks = nil\r\n    self.fatboyRollOffTarget = nil\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:HoldFatboyBuildPose(targetUnit)\r\n    if not FatboyIsAlive(targetUnit) then return end\r\n    Engine.SetMovementEnabled(targetUnit.id, false)\r\n    Engine.SetVolumeColliderEnabled(targetUnit.id, false)\r\n    targetUnit:SetOrientation(FatboyRearOrientation(self))\r\n    if self.fatboyRollOffTarget ~= targetUnit then\r\n        targetUnit:SetPosition(FatboyWorldPoint(self, 0, 0.669224, -2.083794))\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:FatboyBuildPoseThread(targetUnit)\r\n    while FatboyIsAlive(self) and FatboyIsAlive(targetUnit)\r\n        and self.fatboyPinnedBuildTarget == targetUnit\r\n    do\r\n        self:HoldFatboyBuildPose(targetUnit)\r\n        WaitTicks(1)\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:PinFatboyBuildCollider(targetUnit)\r\n    if not FatboyIsAlive(targetUnit) then return end\r\n    if self.fatboyPinnedBuildTarget == targetUnit then\r\n        self:HoldFatboyBuildPose(targetUnit)\r\n        return\r\n    end\r\n    self:StopFatboyBuildColliderPin()\r\n    self.fatboyPinnedBuildTarget = targetUnit\r\n    self.fatboyBuildCallbacks = {\r\n        onStopBeingBuilt = rawget(targetUnit, \"OnStopBeingBuilt\"),\r\n        updateAnimations = rawget(targetUnit, \"UpdateAnimations\"),\r\n    }\r\n    local onStopBeingBuilt = targetUnit.OnStopBeingBuilt\r\n    targetUnit.OnStopBeingBuilt = function(unit, ...)\r\n        onStopBeingBuilt(unit, ...)\r\n        -- Mobile completion enables movement after the factory's stop callback.\r\n        if unit.scoFactoryColliderPinOwner == self then\r\n            self:HoldFatboyBuildPose(unit)\r\n        end\r\n    end\r\n    -- Native animation speed follows actual SimVelocity while Curve.Play drives\r\n    -- the child; the ordinary updater reads the disabled mover's stale speed.\r\n    targetUnit.UpdateAnimations = function() end\r\n    targetUnit.scoFactoryColliderPinOwner = self\r\n    self:HoldFatboyBuildPose(targetUnit)\r\n    self.fatboyBuildPoseThread = self:NewThread(self.FatboyBuildPoseThread, targetUnit)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:GetFatboyRollOffGroundPoint(targetUnit)\r\n    local hull = self.tp.collisionInfo\r\n    local child = targetUnit.tp.collisionInfo\r\n    local hullRear = (hull.centerOffset.z or 0) - hull.collisionSize.z * 0.5\r\n    local childRear = child.collisionSize.z * 0.5 - (child.centerOffset.z or 0)\r\n    -- FA's 17-unit attachment slide is 3.74 at the converted 0.22 scale.\r\n    -- Large products must also clear the carrier's collision hull completely.\r\n    local rear = math.min(-5.823794, hullRear - childRear - 0.25)\r\n    local position = FatboyGroundPoint(self, 0, rear)\r\n    position.y = position.y + (targetUnit.tp.movement.preferredAltitude or 0)\r\n    return position\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:ReleaseFatboyBuiltUnit(targetUnit, interrupted)\r\n    if not FatboyIsAlive(targetUnit) or not targetUnit:IsCompleted() then\r\n        return false\r\n    end\r\n    if self.fatboyPinnedBuildTarget ~= targetUnit then\r\n        return true\r\n    end\r\n    if interrupted then\r\n        -- A stopped production coroutine cannot finish its curve. Preserve the\r\n        -- completed unit at a clear terrain point before releasing ownership.\r\n        targetUnit:SetPosition(self:GetFatboyRollOffGroundPoint(targetUnit))\r\n        targetUnit:SetOrientation(FatboyRearOrientation(self))\r\n    end\r\n    self:StopFatboyBuildColliderPin(targetUnit)\r\n    Engine.SetVolumeColliderEnabled(targetUnit.id, true)\r\n    Engine.SetMovementEnabled(targetUnit.id, true)\r\n    targetUnit:UpdateAnimations()\r\n    return true\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:MoveFatboyBuiltUnit(targetUnit, destination, duration, startPosition)\r\n    local origin = startPosition or targetUnit:GetPosition()\r\n    local curve = FatboyCurve.Play(targetUnit, {\r\n        duration = duration,\r\n        position = {\r\n            mode = FatboyCurve.Absolute,\r\n            x = FatboyCurve.Linear(origin.x, destination.x),\r\n            y = FatboyCurve.EaseInOut(origin.y, destination.y),\r\n            z = FatboyCurve.Linear(origin.z, destination.z),\r\n        },\r\n    })\r\n    while FatboyIsAlive(self) and FatboyIsAlive(targetUnit)\r\n        and self.fatboyPinnedBuildTarget == targetUnit\r\n    do\r\n        local progress = duration > 0 and (_G.Time - curve.startTime) / duration or 1\r\n        -- World-position reads lag transform writes until the next native tick.\r\n        -- Clamp the next sample before applying it, without reading it back.\r\n        local position = curve:Sample(math.clamp(progress, 0, 1))\r\n        local _, terrainHeight = Engine.SampleTerrainHeight(position)\r\n        local groundY = terrainHeight + (targetUnit.tp.movement.preferredAltitude or 0)\r\n        if position.y < groundY then\r\n            position.y = groundY\r\n        end\r\n        Engine.SetGlobalEntityPosition(targetUnit.id, position)\r\n        if progress >= 1 then return true, position end\r\n        WaitTicks(1)\r\n    end\r\n    return false\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:FatboyLayerUpdateThread()\r\n    while not self.dead do\r\n        local submerged = FatboyIsSubmerged(self)\r\n        if submerged ~= self.fatboySubmerged then\r\n            self.fatboySubmerged = submerged\r\n            self:SetTargetingLayer(submerged\r\n                and FatboyTargetingLayer.Seabed\r\n                or FatboyTargetingLayer.Land)\r\n\r\n            -- The FA Fatboy cannot manufacture underwater. Preserve the queued\r\n            -- item, but abort/delete the partial child as soon as it submerges.\r\n            if submerged and self.productionBehaviorIsActive then\r\n                self:ProductionBehaviorStop()\r\n            end\r\n        end\r\n        WaitTicks(4)\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:ProductionBehaviorIsValidFor()\r\n    if FatboyIsSubmerged(self) then\r\n        return false\r\n    end\r\n    return EDALandFactory.ProductionBehaviorIsValidFor(self)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:GetRollOffPoint()\r\n    -- Build-box compatibility maps this hook to the live construction API.\r\n    -- The native attachment sits just above the rear tray surface.\r\n    return FatboyWorldPoint(self, 0, 0.669224, -2.083794)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnStartBuildRoutine(targetUnit)\r\n    local newTarget = self.fatboyPinnedBuildTarget ~= targetUnit\r\n    self:SetFatboyMovementLocked(true)\r\n    self:PinFatboyBuildCollider(targetUnit)\r\n    EDALandFactory.OnStartBuildRoutine(self, targetUnit)\r\n    self:HoldFatboyBuildPose(targetUnit)\r\n    if newTarget then\r\n        self:PlayFatboyAnimation(\"build\")\r\n        self.fatboyBayReadyTime = _G.Time + FatboyBayAnimationSeconds\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnStopBuildRoutine(targetUnit)\r\n    if FatboyIsAlive(targetUnit) then\r\n        self:HoldFatboyBuildPose(targetUnit)\r\n    end\r\n    EDALandFactory.OnStopBuildRoutine(self, targetUnit)\r\n    -- A pause keeps the partial child on the open tray. Completed products\r\n    -- leave through RollOffUnit before the bay closes.\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:ProductionBehaviorBuildOne(item)\r\n    -- Mirror the native pre-build wait before locking the mobile hull.\r\n    while not self.dead and (self:GetPause() or not self.army:HasUnitCapSpace()) do\r\n        WaitTicks(5)\r\n    end\r\n    if self.dead then return end\r\n    self:SetFatboyMovementLocked(true)\r\n    self.fatboyClosePending = false\r\n    EDALandFactory.ProductionBehaviorBuildOne(self, item)\r\n    if self.fatboyClosePending and not self.dead then\r\n        -- The stock queue already waits two seconds after RollOffUnit.\r\n        WaitSeconds(FatboyBayAnimationSeconds - 2)\r\n    end\r\n    self.fatboyClosePending = false\r\n    self:SetFatboyMovementLocked(false)\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:RollOffUnit(targetUnit)\r\n    if not FatboyIsAlive(targetUnit) then\r\n        self:StopFatboyBuildColliderPin(targetUnit)\r\n        return\r\n    end\r\n    self:SetFatboyMovementLocked(true)\r\n    if self.fatboyPinnedBuildTarget ~= targetUnit then\r\n        self:PinFatboyBuildCollider(targetUnit)\r\n        self:PlayFatboyAnimation(\"build\")\r\n        self.fatboyBayReadyTime = _G.Time + FatboyBayAnimationSeconds\r\n    end\r\n    while FatboyIsAlive(self) and FatboyIsAlive(targetUnit)\r\n        and self.fatboyPinnedBuildTarget == targetUnit\r\n        and _G.Time < (self.fatboyBayReadyTime or 0)\r\n    do\r\n        WaitTicks(1)\r\n    end\r\n    if not FatboyIsAlive(self) or not FatboyIsAlive(targetUnit)\r\n        or self.fatboyPinnedBuildTarget ~= targetUnit\r\n    then\r\n        self:StopFatboyBuildColliderPin(targetUnit)\r\n        return\r\n    end\r\n    self:HoldFatboyBuildPose(targetUnit)\r\n    self.fatboyRollOffTarget = targetUnit\r\n    local animations = targetUnit.tp.visuals.animations\r\n    local gait = animations and (animations.run or animations.walk)\r\n    if gait and gait.id then\r\n        targetUnit:SetAnimatorEnabled(true)\r\n        targetUnit.isWalking = animations.run == nil\r\n        Engine.PlayAnimation(targetUnit.id, gait.id, 0.1)\r\n    end\r\n    local groundPoint = self:GetFatboyRollOffGroundPoint(targetUnit)\r\n    local origin = targetUnit:GetPosition()\r\n    local deckEnd = EngineClasses.float3(\r\n        groundPoint.x, math.max(origin.y, groundPoint.y), groundPoint.z)\r\n    local dx, dz = deckEnd.x - origin.x, deckEnd.z - origin.z\r\n    local speed = math.max(0.1, math.min(2.2, targetUnit.tp.movement.speed or 2.2))\r\n    local moved, position = self:MoveFatboyBuiltUnit(\r\n        targetUnit, deckEnd, math.sqrt(dx * dx + dz * dz) / speed)\r\n    if moved then\r\n        moved = self:MoveFatboyBuiltUnit(targetUnit, groundPoint, 0.3, position)\r\n    end\r\n    if moved and self:ReleaseFatboyBuiltUnit(targetUnit) then\r\n        local clearance = FatboyGroundPoint(self, 0, -15)\r\n        FatboyHostOrderManager.HostIssueOrder(\r\n            FatboyOrderTasks.MOVE, {targetUnit}, false, clearance, nil)\r\n        local source = self.unitBeingBuiltSource or self\r\n        if source.rallyPoint then\r\n            FatboyHostOrderManager.HostIssueOrder(\r\n                FatboyOrderTasks.MOVE, {targetUnit}, true, source.rallyPoint, nil)\r\n        end\r\n    else\r\n        self:StopFatboyBuildColliderPin(targetUnit)\r\n    end\r\n    if FatboyIsAlive(self) then\r\n        self:PlayFatboyAnimation(\"close\")\r\n        self.fatboyClosePending = true\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:ProductionBehaviorStop()\r\n    local targetUnit = self.fatboyPinnedBuildTarget or self.productionBehaviorTargetUnit\r\n    local closeAfterStop = FatboyIsAlive(targetUnit) and not targetUnit:IsCompleted()\r\n    self:ReleaseFatboyBuiltUnit(targetUnit, true)\r\n    self:StopFatboyBuildColliderPin(targetUnit)\r\n    EDALandFactory.ProductionBehaviorStop(self)\r\n    self:SetFatboyMovementLocked(false)\r\n    if closeAfterStop then\r\n        self:PlayFatboyAnimation(\"close\")\r\n    end\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnCancelConstruction()\r\n    self:ReleaseFatboyBuiltUnit(self.fatboyPinnedBuildTarget, true)\r\n    self:StopFatboyBuildColliderPin()\r\n    EDALandFactory.OnCancelConstruction(self)\r\n    self:SetFatboyMovementLocked(false)\r\n    self:PlayFatboyAnimation(\"close\")\r\nend\r\n\r\nfunction EDAFatboyMobileFactory:OnDestroy(isDelete)\r\n    self:CancelFatboyTargetRefresh()\r\n    self:CancelFatboyShieldRestart(true)\r\n    self:CancelFatboyShieldEnergyMonitor()\r\n    if self.fatboyLayerThread then\r\n        KillThread(self.fatboyLayerThread)\r\n        self.fatboyLayerThread = nil\r\n    end\r\n    self:ReleaseFatboyBuiltUnit(self.fatboyPinnedBuildTarget, true)\r\n    self:StopFatboyBuildColliderPin()\r\n    self:SetFatboyMovementLocked(false)\r\n    EDALandFactory.OnDestroy(self, isDelete)\r\nend", ValidateHostClasses, UpgradeFatboyMovementLock);
			QueueAppend(obj, list, "LJ/lua/client/units/unitsClasses/unitsDefaultEDA.lua", "client EDA unit classes", delegate(string source)
			{
				RequireTokens(source, "EDALandFactory =", "EDALandUnit =");
			}, "\n\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\n-- Reuse the imported UEF endpoint-beam implementation when the structure\n-- module precedes this one. Mobile overrides below still suppress tarmac,\n-- permanent-grid, structure selection, and structure intel behavior.\nlocal FatboyClientFactoryBase = EDAUefLandFactory or EDALandFactory\n\nlocal function FatboySetLocalVolumeColliderEnabled(globalId, enabled)\n    local localId = EngineClasses.LocalID()\n    local errorCode = Engine.GetGlobalEntityPairedLocalID(globalId, localId)\n    if errorCode == EngineErrorCode.Success and Engine.IsValidLocalID(localId) then\n        Engine.SetVolumeColliderEnabled(localId, enabled)\n    end\nend\n\nClientEDAFatboyMobileFactory = Class(\"EDAFatboyMobileFactory\", FatboyClientFactoryBase)\nlocal EDAFatboyMobileFactory = ClientEDAFatboyMobileFactory\n\nfunction EDAFatboyMobileFactory:CreateTarmac()\nend\n\nfunction EDAFatboyMobileFactory:OnPromoteToUnit()\n    EDALandUnit.OnPromoteToUnit(self)\nend\n\nfunction EDAFatboyMobileFactory:OnCompleted()\n    EDALandUnit.OnCompleted(self)\nend\n\nfunction EDAFatboyMobileFactory:IsHighlightable()\n    return EDALandUnit.IsHighlightable(self)\nend\n\nfunction EDAFatboyMobileFactory:IsSelectable()\n    return EDALandUnit.IsSelectable(self)\nend\n\nfunction EDAFatboyMobileFactory:OnIntelHidden()\n    EDALandUnit.OnIntelHidden(self)\nend\n\nfunction EDAFatboyMobileFactory:OnIntelVision()\n    EDALandUnit.OnIntelVision(self)\nend\n\nfunction EDAFatboyMobileFactory:OnIntelRadar()\n    EDALandUnit.OnIntelRadar(self)\n    self:RecalculateConstructionBeamState()\nend\n\nfunction EDAFatboyMobileFactory:ClientOnStopBuilding()\n    local targetUnit = self.buildTarget\n    FatboyClientFactoryBase.ClientOnStopBuilding(self)\n    if targetUnit and not targetUnit:IsCompleted() then\n        -- Host construction ownership persists across a production pause.\n        targetUnit:SetSelectionEnabled(false)\n        FatboySetLocalVolumeColliderEnabled(targetUnit.id, false)\n    end\nend\n\nfunction EDAFatboyMobileFactory:OnDestroy(isDelete)\n    -- This parent call owns endpoint-beam disposal. CreateTarmac and the intel\n    -- overrides above keep its structure-only presentation inert.\n    FatboyClientFactoryBase.OnDestroy(self, isDelete)\nend\n\nfunction EDAFatboyMobileFactory:OnDelete()\n    FatboyClientFactoryBase.OnDelete(self)\nend\n\n-- SCOM Fatboy private client module 1.0.0\ndo\n    ClientEDAFatboyMobileFactory = Import(\"common/loading/unitTemplateLoader.lua\").SCOMUnitLibrary.DeriveClass(\n        assert(ClientEDAFatboyMobileFactory, \"Fatboy client library missing\"),\n        \"scom/units/uel4511/client.lua\", \"client\")\nend\n", ValidateClientClasses);
			QueueAppend(obj, list, "LJ/lua/common/units/availableUnits.lua", "available-unit table", delegate(string source)
			{
				RequireTokens(source, "AvailableUnits =", "uel4511");
			}, "\n\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\nAvailableUnits[\"uel4511\"] = true", delegate(string source)
			{
				ContainsText(source, "AvailableUnits[\"uel4511\"] = true");
			});
			QueueAppend(obj, list, "LJ/lua/common/systems/import.lua", "virtual Fatboy projectile directory scanner", delegate(string source)
			{
				RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory");
			}, "\n\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\n-- FilesCache owns these virtual projectile templates, while the stock scanner\n-- sees physical folders only. Chain whichever scanner a prior patcher supplied.\nlocal SCO_FatboyScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_FatboyScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n\n    local knownFolders = {}\n    for _, folder in ipairs(folders) do\n        knownFolders[folder] = true\n    end\n\n    local fatboyProjectiles = {\n        \"psf401\",\n        \"psf402\",\n        \"psf403\",\n        \"psf404\",\n    }\n    for _, templateId in ipairs(fatboyProjectiles) do\n        local folder = directory .. templateId\n        if not knownFolders[folder] then\n            table.insert(folders, folder)\n        end\n    end\n    return folders\nend", ValidateImportScanner, UpgradeImportScanner);
			QueueTransform(obj, list, "LJ/lua/common/loading/unitTemplateLoader.lua", "per-clip animation playback-mode loader", TransformAnimationPlaybackMode, delegate(string source)
			{
				ContainsText(source, "animationInfo.playbackMode or AnimationPlaybackMode.Loop");
			});
			ProjectileSpec[] projectiles = Projectiles;
			foreach (ProjectileSpec projectile in projectiles)
			{
				QueueVirtualProjectile(obj, list, projectile);
			}
			Commit(obj, list);
			Log($"Applied {list.Count} atomic cache mutations for UEL4511: mobile-factory lifecycle, " + "full source weapon battery, animation playback, and four projectile templates.");
		}
		catch (Exception arg)
		{
			if (obj != null)
			{
				RollBack(obj, list);
			}
			else
			{
				DisposeUncommitted(list);
			}
			Log($"Failed to apply the UEL4511 Fatboy cache patch: {arg}");
			throw;
		}
	}

	private static void ValidateFatboyTemplate(string source)
	{
		if (CountOccurrences(source, "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0") != 1)
		{
			throw new InvalidOperationException("The Fatboy template must contain exactly one authoritative override marker.");
		}
		string text = source;
		source = text.Substring(text.IndexOf("-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0", StringComparison.Ordinal));
		RequireTokens(source, "EDAFatboyMobileFactory", "Tags.EDA * Tags.LAND * Tags.MOBILE * Tags.BUILDABLE_BY_T3_FACTORY", "type = \"TracksSeabed\"", "energyDrainRechargeTime = 5", "rechargeHPRatio = 1", "rechargeTime = 160", "visionRadius = 100", "waterVisionRadius = 100", "Arm_Right01_Build_Emitter", "Arm_Left03_Build_Emitter", "Wheel_Left01", "Wheel_Left02", "Wheel_Right01", "Wheel_Right02", "turret .. \"_Muzzle01\"", "turret .. \"_Muzzle02\"", "turret .. \"_Muzzle03\"", "local yawBone = \"Riot_Gun_\" .. side", "local muzzle = pitchBone .. \"_Muzzle\"", "local yawBone = \"Turret_\" .. side .. \"_AA\"", "local muzzle02 = yawBone .. \"_Muzzle02\"", "Torpedo_04", "aimGravity = controllerSettings.aimGravity", "aimTolerance = controllerSettings.aimTolerance", "reduceMuzzleVelocityToTarget = controllerSettings.reduceMuzzleVelocityToTarget", "yawMax = defaultYaw + yawRange", "yawMin = defaultYaw - yawRange", "aimTolerance = 180", "yawMax = 0", "yawMin = 0", "yawSpeed = 0", "FatboyGaussWeapon(\"Turret_Right01\", -20, 100)", "FatboyGaussWeapon(\"Turret_Right02\", 30, 110)", "FatboyGaussWeapon(\"Turret_Left01\", 20, 100)", "FatboyGaussWeapon(\"Turret_Left02\", -30, 110)", "projectileTemplate = \"psf401\"", "projectileTemplate = \"psf402\"", "projectileTemplate = \"psf403\"", "projectileTemplate = \"psf404\"", "category = \"DeathExplosion\"");
		int num = source.IndexOf("-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("The Fatboy template replacement lost its authoritative marker.");
		}
		string text2 = source.Substring(num);
		int num2 = text2.IndexOf("UnitTemplate.defence =", StringComparison.Ordinal);
		int num3 = text2.IndexOf("UnitTemplate.economy =", num2, StringComparison.Ordinal);
		if (num2 < 0 || num3 <= num2)
		{
			throw new InvalidOperationException("The Fatboy shield declaration is missing or malformed.");
		}
		string source2 = text2.Substring(num2, num3 - num2);
		RequireTokens(source2, "boneName = \"Root\"", "y = -7", "x = 25", "y = 25", "z = 25", "energyDrainRechargeTime = 5", "rechargeTime = 160");
		if (ContainsText(source2, "VFX/Unit/veu1222_active_shield_generator.sanvfx"))
		{
			throw new InvalidOperationException("The Fatboy must not use the static world-space EDA shield-generator emitter.");
		}
		if (CountOccurrences(text2, "rangeRingType = \"DirectFire\"") != 2 || CountOccurrences(text2, "rangeRingType = \"AntiAir\"") != 1 || CountOccurrences(text2, "rangeRingType = \"AntiNaval\"") != 1 || ContainsText(text2, "rangeRingType = \"AntiNavy\""))
		{
			throw new InvalidOperationException("The Fatboy range-ring types must use Sanctuary's DirectFire, AntiAir, and AntiNaval names.");
		}
		if (CountOccurrences(source, "FatboyGaussWeapon(") != 5)
		{
			throw new InvalidOperationException("The Fatboy template no longer declares exactly four Gauss weapons plus the helper.");
		}
		int num4 = text2.IndexOf("local function FatboyGaussWeapon", StringComparison.Ordinal);
		int num5 = text2.IndexOf("\n    local function FatboyRiotWeapon", num4, StringComparison.Ordinal);
		if (num4 < 0 || num5 <= num4)
		{
			throw new InvalidOperationException("The Fatboy Gauss helper is missing or malformed.");
		}
		string source3 = text2.Substring(num4, num5 - num4);
		RequireTokens(source3, "FatboyAimController(\n                turret,\n                turret,\n                nil,", "for index, muzzle in ipairs(muzzles) do", "FatboyAimController(\n                muzzle,\n                nil,\n                turret .. \"_Barrel0\" .. index,", "muzzles = FatboyMuzzleMap(muzzles, muzzles)", "projectileLifetime = 4.6", "rangeMax = 100");
		if (CountOccurrences(source3, "FatboyAimController(") != 2 || CountOccurrences(source3, "muzzles = muzzles,") != 1 || ContainsText(source3, "local aimMuzzle"))
		{
			throw new InvalidOperationException("Each Fatboy Gauss rack must own one yaw-only controller, three loop-expanded pitch-only controllers, unique muzzle mappings, and one simultaneous group.");
		}
		if (CountOccurrences(source3, "firingRandomness = 0,") != 1 || ContainsText(source3, "firingRandomness = 1.1"))
		{
			throw new InvalidOperationException("The Fatboy Gauss battery must not apply post-solve spread to its LowArc trajectory.");
		}
		if (CountOccurrences(source3, "        local controllerSettings = {\n            aimGravity = {\n                x = 0,\n                y = -4.9,\n                z = 0,\n            },\n            aimTolerance = 2,\n            pitchAxis = {\n                x = 0,\n                y = 0,\n                z = string.find(turret, \"Right\", 1, true) and -1 or 1,\n            },\n            reduceMuzzleVelocityToTarget = true,\n        }\n        -- Supreme Commander Overhaul UEF Fatboy Gauss arc 2.0.0") != 1 || CountOccurrences(source3, "-- Supreme Commander Overhaul UEF Fatboy Gauss arc 2.0.0") != 1 || CountOccurrences(source3, "                25,\n                \"LowArc\",") != 2 || CountOccurrences(source3, "                -60,\n                60,\n                50,\n                25,\n                \"LowArc\",") != 1 || ContainsText(source3, "            -- Sanctuary applies firing randomness after it has solved the very\n            -- shallow LowArc trajectory.  The source 1.1-degree cone can therefore\n            -- pitch a shell down enough to miss roughly a quarter of its range.\n            -- Keep the Gauss battery deterministic until the engine exposes\n            -- aim-space spread that preserves the ballistic solution.") || ContainsText(source3, "            -- FA uses 4.9 gravity for this LowArc battery. Sanctuary applies\n            -- firing randomness after solving that trajectory, so the source\n            -- 1.1-degree cone can still shorten a shell's flight. Keep the Gauss\n            -- battery deterministic until the engine exposes aim-space spread\n            -- that preserves the ballistic solution.") || CountOccurrences(source3, "            -- FA UEL0401 uses the shallow LowArc branch, muzzle velocity 25,\n            -- gravity 4.9 and a 60-degree elevation envelope. Preserve the\n            -- converted pitch axes and deterministic post-solve spread policy.") != 1)
		{
			throw new InvalidOperationException("The Fatboy Gauss battery lost its low-arc gravity, elevation, or lifetime envelope.");
		}
		ValidateFatboyGaussEnvelope();
		if (CountOccurrences(source, "FatboyRiotWeapon(") != 3 || CountOccurrences(source, "FatboyAAWeapon(") != 3)
		{
			throw new InvalidOperationException("The Fatboy template no longer declares its two riot guns and two linked AA guns.");
		}
		if (CountOccurrences(text2, "aimGravity = {\n                            x = 0,\n                            y = 0,\n                            z = 0,\n                        }") != 2 || CountOccurrences(text2, "aimGravity = 0") != 0 || CountOccurrences(text2, "aimTolerance = 2") != 2 || CountOccurrences(text2, "aimTolerance = 0.05") != 1 || CountOccurrences(text2, "reduceMuzzleVelocityToTarget = true") != 1 || CountOccurrences(text2, "reduceMuzzleVelocityToTarget = false") != 2)
		{
			throw new InvalidOperationException("The Fatboy Gauss, riot, and AA aim-controller physics no longer match FA.");
		}
		if (CountOccurrences(source, "layerWeaponLimits = {\n                \"Land\",\n                \"Seabed\",\n            }") != 2 || CountOccurrences(source, "layerWeaponLimits = {\n                \"Land\",\n                \"Seabed\",\n                \"Water\",\n            }") != 1)
		{
			throw new InvalidOperationException("The Fatboy surface and AA batteries no longer match FA's firing-layer caps.");
		}
		if (CountOccurrences(source, "layerTargetLimits = {\n                \"Seabed\",\n                \"Water\",\n                \"WaterSurface\",\n            }") != 1)
		{
			throw new InvalidOperationException("The Fatboy torpedo must target seabed, submerged, and surface-water units.");
		}
		if (CountOccurrences(source, "particleName = \"VFX/SCOM/Fatboy/track_trail.sanvfx\"") != 4)
		{
			throw new InvalidOperationException("The Fatboy template must retain one tread-mark emitter on each native wheel bone.");
		}
	}

	private static string TuneFatboyGaussArc(string source)
	{
		int num = CountOccurrences(source, "-- Supreme Commander Overhaul UEF Fatboy Gauss arc 2.0.0");
		int num2 = CountOccurrences(source, "-- Supreme Commander Overhaul UEF Fatboy Gauss arc 1.0.0");
		switch (num)
		{
		case 1:
			if (num2 != 0)
			{
				throw new InvalidOperationException("The Fatboy Gauss template contains mixed arc contract versions.");
			}
			ValidateMarkedFatboyGaussArc(source);
			return source;
		case 0:
			if (num2 <= 1)
			{
				string oldValue = ((num2 == 1) ? "        local controllerSettings = {\n            aimGravity = {\n                x = 0,\n                y = -4.9,\n                z = 0,\n            },\n            aimTolerance = 2,\n            reduceMuzzleVelocityToTarget = true,\n        }\n        -- Supreme Commander Overhaul UEF Fatboy Gauss arc 1.0.0" : "        local controllerSettings = {\n            aimTolerance = 2,\n            reduceMuzzleVelocityToTarget = true,\n        }");
				string oldValue2 = ((num2 == 1) ? "            -- FA uses 4.9 gravity for this LowArc battery. Sanctuary applies\n            -- firing randomness after solving that trajectory, so the source\n            -- 1.1-degree cone can still shorten a shell's flight. Keep the Gauss\n            -- battery deterministic until the engine exposes aim-space spread\n            -- that preserves the ballistic solution." : "            -- Sanctuary applies firing randomness after it has solved the very\n            -- shallow LowArc trajectory.  The source 1.1-degree cone can therefore\n            -- pitch a shell down enough to miss roughly a quarter of its range.\n            -- Keep the Gauss battery deterministic until the engine exposes\n            -- aim-space spread that preserves the ballistic solution.");
				string text = ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(source, oldValue, "        local controllerSettings = {\n            aimGravity = {\n                x = 0,\n                y = -4.9,\n                z = 0,\n            },\n            aimTolerance = 2,\n            pitchAxis = {\n                x = 0,\n                y = 0,\n                z = string.find(turret, \"Right\", 1, true) and -1 or 1,\n            },\n            reduceMuzzleVelocityToTarget = true,\n        }\n        -- Supreme Commander Overhaul UEF Fatboy Gauss arc 2.0.0", 1, "Fatboy Gauss controller settings"), oldValue2, "            -- FA UEL0401 uses the shallow LowArc branch, muzzle velocity 25,\n            -- gravity 4.9 and a 60-degree elevation envelope. Preserve the\n            -- converted pitch axes and deterministic post-solve spread policy.", 1, "Fatboy Gauss randomness comment"), "            pitchBone = pitchBone,\n            pitchMax = pitchMax,", "            pitchAxis = pitchBone and controllerSettings.pitchAxis or nil,\n            pitchBone = pitchBone,\n            pitchMax = pitchMax,", 1, "Fatboy aim-controller pitch axis"), "                25,\n                \"LowArc\",", "                25,\n                \"LowArc\",", 2, "Fatboy Gauss solver branches"), "                -60,\n                60,\n                50,\n                25,\n                \"LowArc\",", "                -60,\n                60,\n                50,\n                25,\n                \"LowArc\",", 1, "Fatboy Gauss pitch envelope"), "            projectileLifetime = 4.6,", "            projectileLifetime = 4.6,", 1, "Fatboy Gauss projectile lifetime");
				ValidateMarkedFatboyGaussArc(text);
				return text;
			}
			break;
		}
		throw new InvalidOperationException($"Expected one supported Fatboy Gauss arc marker at most, found current={num}, previous={num2}.");
	}

	private static void ValidateMarkedFatboyGaussArc(string source)
	{
		if (CountOccurrences(source, "        local controllerSettings = {\n            aimGravity = {\n                x = 0,\n                y = -4.9,\n                z = 0,\n            },\n            aimTolerance = 2,\n            pitchAxis = {\n                x = 0,\n                y = 0,\n                z = string.find(turret, \"Right\", 1, true) and -1 or 1,\n            },\n            reduceMuzzleVelocityToTarget = true,\n        }\n        -- Supreme Commander Overhaul UEF Fatboy Gauss arc 2.0.0") != 1 || CountOccurrences(source, "            -- FA UEL0401 uses the shallow LowArc branch, muzzle velocity 25,\n            -- gravity 4.9 and a 60-degree elevation envelope. Preserve the\n            -- converted pitch axes and deterministic post-solve spread policy.") != 1 || CountOccurrences(source, "            pitchAxis = pitchBone and controllerSettings.pitchAxis or nil,") != 1 || CountOccurrences(source, "                z = string.find(turret, \"Right\", 1, true) and -1 or 1,") != 1 || ContainsText(source, "            -- Sanctuary applies firing randomness after it has solved the very\n            -- shallow LowArc trajectory.  The source 1.1-degree cone can therefore\n            -- pitch a shell down enough to miss roughly a quarter of its range.\n            -- Keep the Gauss battery deterministic until the engine exposes\n            -- aim-space spread that preserves the ballistic solution.") || ContainsText(source, "            -- FA uses 4.9 gravity for this LowArc battery. Sanctuary applies\n            -- firing randomness after solving that trajectory, so the source\n            -- 1.1-degree cone can still shorten a shell's flight. Keep the Gauss\n            -- battery deterministic until the engine exposes aim-space spread\n            -- that preserves the ballistic solution.") || CountOccurrences(source, "                25,\n                \"LowArc\",") != 2 || CountOccurrences(source, "                25,\n                \"HighArc\",") != 0 || CountOccurrences(source, "                -60,\n                60,\n                50,\n                25,\n                \"LowArc\",") != 1 || CountOccurrences(source, "            projectileLifetime = 4.6,") != 1)
		{
			throw new InvalidOperationException("The marked Fatboy Gauss low-arc contract is incomplete.");
		}
	}

	private static void ValidateFatboyGaussEnvelope()
	{
		double num = 150524.99999999994;
		if (num <= 0.0)
		{
			throw new InvalidOperationException("The Fatboy Gauss muzzle velocity cannot reach its vanilla range under FA gravity.");
		}
		double num2 = (625.0 - Math.Sqrt(num)) / 490.00000000000006;
		double num3 = 1.0 / Math.Sqrt(1.0 + num2 * num2);
		double num4 = Math.Atan(num2) * 180.0 / Math.PI;
		double num5 = 100.0 / (25.0 * num3);
		if (num4 > 60.0)
		{
			throw new InvalidOperationException($"The Fatboy Gauss {num4:F6}-degree low arc exceeds its {60.0:F1}-degree pitch envelope.");
		}
		if (num5 > 4.6)
		{
			throw new InvalidOperationException($"The Fatboy Gauss projectile lifetime {4.6} is shorter than its {num5:F6}-second low-arc vanilla-range flight.");
		}
	}

	private static void ValidateHostClasses(string source)
	{
		if (CountOccurrences(source, "function EDAFatboyMobileFactory:ProductionBehaviorBuildOne(item)\r\n    -- Mirror the native pre-build wait before locking the mobile hull.\r\n    while not self.dead and (self:GetPause() or not self.army:HasUnitCapSpace()) do\r\n        WaitTicks(5)\r\n    end\r\n    if self.dead then return end\r\n    self:SetFatboyMovementLocked(true)\r\n    self.fatboyClosePending = false") != 1 || CountOccurrences(source, "function EDAFatboyMobileFactory:ProductionBehaviorBuildOne(item)\r\n    self:SetFatboyMovementLocked(true)\r\n    self.fatboyClosePending = false") != 0)
		{
			throw new InvalidOperationException("Fatboy movement must remain enabled while the native factory waits for unit cap or unpause.");
		}
		RequireTokens(source, "EDAFatboyMobileFactory", "EDALandFactory.OnStopBeingBuilt(self)", "EDALandUnit.PromoteToUnit(self)", "CanBeSlaveFactory", "CanBeMasterFactory", "function EDAFatboyMobileFactory:UpdateAnimations()", "function EDAFatboyMobileFactory:OnBuildProcessStarted()", "EDALandFactory.OnBuildProcessStarted(self)", "function EDAFatboyMobileFactory:OnBuildProcessEnded()", "EDALandFactory.OnBuildProcessEnded(self)", "function EDAFatboyMobileFactory:RefreshFatboyWeaponTargets()", "function EDAFatboyMobileFactory:CancelFatboyTargetRefresh()", "function EDAFatboyMobileFactory:FatboyTargetRefreshThread(generation)", "function EDAFatboyMobileFactory:StartFatboyTargetRefresh()", "weapon.targeterCollider.isDirty = true", "function EDAFatboyMobileFactory:AttackBehaviorStart(targetUnit, range)", "function EDAFatboyMobileFactory:AttackBehaviorStop()", "local function FatboyShieldEnergyState(factory)", "energy.satisfaction", "local function FatboyCancelNativeShieldTimers(shield)", "function EDAFatboyMobileFactory:CancelFatboyShieldRestart(resetProgress)", "function EDAFatboyMobileFactory:CancelFatboyShieldEnergyMonitor()", "function EDAFatboyMobileFactory:BeginFatboyShieldOperationalDisable(shield)", "function EDAFatboyMobileFactory:FatboyShieldRestartThread(generation, shield)", "function EDAFatboyMobileFactory:FatboyShieldEnergyMonitorThread(generation, shield)", "function EDAFatboyMobileFactory:StartFatboyShieldEnergyMonitor(shield)", "function EDAFatboyMobileFactory:StartFatboyShieldRestart(shield)", "function EDAFatboyMobileFactory:CheckShieldState(skipRecharge)", "QuaternionRotateVector", "SampleTerrainHeight", "GetWaterLevel", "FatboyTargetingLayer.Seabed", "ProductionBehaviorIsValidFor", "ProductionBehaviorBuildOne", "PinFatboyBuildCollider", "StopFatboyBuildColliderPin", "ReleaseFatboyBuiltUnit", "scoFactoryColliderPinOwner == self", "targetUnit.scoFactoryColliderPinOwner = self", "Engine.SetVolumeColliderEnabled(targetUnit.id, false)", "Engine.SetVolumeColliderEnabled(targetUnit.id, true)", "function EDAFatboyMobileFactory:OnStopBuildRoutine", "targetUnit:SetPosition", "EDALandFactory.OnStopBuildRoutine(self, targetUnit)", "SetVolumeColliderEnabled", "SetMovementEnabled", "RollOffUnit");
		if (ContainsText(source, "FatboyBuildColliderPinThread"))
		{
			throw new InvalidOperationException("The Fatboy must not retain a per-tick collider-pin thread.");
		}
		string source2 = SliceFunction(source, "function EDAFatboyMobileFactory:FatboyTargetRefreshThread(generation)");
		RequireTokens(source2, "ipairs({ 1, 4, 12 })", "WaitTicks(delayTicks)", "not FatboyIsAlive(self)", "not self:IsCompleted()", "self:RefreshFatboyWeaponTargets()");
		if (ContainsText(source2, "while "))
		{
			throw new InvalidOperationException("The Fatboy target refresh must remain a bounded handoff, not an idle poll.");
		}
		RequireTokens(SliceFunction(source, "function EDAFatboyMobileFactory:OnStopBeingBuilt()"), "EDALandFactory.OnStopBeingBuilt(self)", "self:StartFatboyTargetRefresh()");
		RequireTokens(SliceFunction(source, "function EDAFatboyMobileFactory:AttackBehaviorStart(targetUnit, range)"), "EDALandFactory.AttackBehaviorStart(self, targetUnit, range)", "self.attackBehaviorIsActive", "self:StartFatboyTargetRefresh()");
		RequireTokens(SliceFunction(source, "function EDAFatboyMobileFactory:AttackBehaviorStop()"), "self:CancelFatboyTargetRefresh()", "EDALandFactory.AttackBehaviorStop(self)");
		string source3 = SliceFunction(source, "function EDAFatboyMobileFactory:BeginFatboyShieldOperationalDisable(shield)");
		RequireTokens(source3, "self.fatboyShieldDamageRechargePending = shield.rechargeThread ~= nil", "Sanctuary clamps Entity health to at least one", "FatboyCancelNativeShieldTimers(shield)", "shield:SetEnabled(false)", "shield:SetRegenEnabled(false)", "self.fatboyShieldOperationallyDisabled = true");
		if (ContainsText(source3, "shield:SetHealth("))
		{
			throw new InvalidOperationException("Energy and manual shield shutdowns must preserve the Fatboy shield's health.");
		}
		RequireTokens(SliceFunction(source, "function EDAFatboyMobileFactory:FatboyShieldRestartThread(generation, shield)"), "energyDrainRechargeTime or 5", "Constants.TickRate", "self.fatboyShieldRestartProgress", "self.fatboyShieldDamageRechargePending", "self.fatboyShieldRestartFullHealth", "shield.rechargeThread = shield:NewThread(shield.RechargeThread)", "shield:SetEnabled(true)", "shield:SetRegenEnabled(true)", "WaitTicks(1)");
		RequireTokens(SliceFunction(source, "function EDAFatboyMobileFactory:FatboyShieldEnergyMonitorThread(generation, shield)"), "economy.isEnergyDown", "FatboyShieldEnergyState(self)", "self:BeginFatboyShieldOperationalDisable(shield)", "self:StartFatboyShieldRestart(shield)", "WaitTicks(1)");
		RequireTokens(SliceFunction(source, "function EDAFatboyMobileFactory:CheckShieldState(skipRecharge)"), "self.resourceEntities.consumption:SetEnabled(wantsShield)", "FatboyShieldEnergyState(self)", "self.fatboyShieldRestartFullHealth = true", "self:BeginFatboyShieldOperationalDisable(shield)", "self:EnableFatboyShieldImmediately(shield, true)", "self:StartFatboyShieldRestart(shield)");
		string text = SliceFunction(source, "function EDAFatboyMobileFactory:OnDestroy(isDelete)");
		int num = text.IndexOf("self:CancelFatboyTargetRefresh()", StringComparison.Ordinal);
		int num2 = text.IndexOf("self:CancelFatboyShieldRestart(true)", StringComparison.Ordinal);
		int num3 = text.IndexOf("self:CancelFatboyShieldEnergyMonitor()", StringComparison.Ordinal);
		int num4 = text.IndexOf("EDALandFactory.OnDestroy(self, isDelete)", StringComparison.Ordinal);
		if (num < 0 || num2 < 0 || num3 < 0 || num4 < 0 || num >= num4 || num2 >= num4 || num3 >= num4)
		{
			throw new InvalidOperationException("Fatboy target and shield refresh threads must be canceled before base destruction.");
		}
		string source4 = SliceFunction(source, "function EDAFatboyMobileFactory:UpdateAnimations()");
		if (ContainsText(source4, "Engine.GetMovementCurrentSpeed") || ContainsText(source4, "EDALandFactory.UpdateAnimations"))
		{
			throw new InvalidOperationException("The Fatboy animation override must not query movement on placement ghosts.");
		}
		string text2 = SliceFunction(source, "function EDAFatboyMobileFactory:OnBuildProcessStarted()");
		int num5 = text2.IndexOf("EDALandFactory.OnBuildProcessStarted(self)", StringComparison.Ordinal);
		int num6 = text2.IndexOf("self:SetAnimatorEnabled(true)", StringComparison.Ordinal);
		int num7 = text2.IndexOf("self:PlayFatboyAnimation(\"build\")", StringComparison.Ordinal);
		if (num5 < 0 || num6 < 0 || num7 < 0 || num5 >= num6 || num6 >= num7)
		{
			throw new InvalidOperationException("The Fatboy must enable its animator and open the bay when external construction starts.");
		}
		RequireTokens(SliceFunction(source, "function EDAFatboyMobileFactory:OnBuildProcessEnded()"), "EDALandFactory.OnBuildProcessEnded(self)", "not self.dead and not self:IsCompleted()", "self:PlayFatboyAnimation(\"close\")");
		string text3 = SliceFunction(source, "function EDAFatboyMobileFactory:ReleaseFatboyBuiltUnit");
		int num8 = text3.IndexOf("targetUnit:SetPosition", StringComparison.Ordinal);
		int num9 = text3.IndexOf("self:StopFatboyBuildColliderPin(targetUnit)", StringComparison.Ordinal);
		int num10 = text3.IndexOf("Engine.SetVolumeColliderEnabled(targetUnit.id, true)", StringComparison.Ordinal);
		if (num8 < 0 || num9 < 0 || num10 < 0 || num8 >= num9 || num9 >= num10)
		{
			throw new InvalidOperationException("An interrupted Fatboy rollout must reach safe terrain before collision is restored.");
		}
		string text4 = SliceFunction(source, "function EDAFatboyMobileFactory:OnStopBuildRoutine");
		int num11 = text4.IndexOf("self:HoldFatboyBuildPose(targetUnit)", StringComparison.Ordinal);
		int num12 = text4.IndexOf("EDALandFactory.OnStopBuildRoutine(self, targetUnit)", StringComparison.Ordinal);
		if (num11 < 0 || num12 < 0 || num11 >= num12)
		{
			throw new InvalidOperationException("The Fatboy must retain the child's platform pose before the base completion callback.");
		}
		string text5 = SliceFunction(source, "function EDAFatboyMobileFactory:RollOffUnit");
		RequireTokens(source, "Engine.QuaternionRotateY(factory:GetOrientation(), math.pi)", "FatboyWorldPoint(self, 0, 0.669224, -2.083794)", "FatboyCurve.Play(targetUnit", "targetUnit.OnStopBeingBuilt = function(unit, ...)", "targetUnit.UpdateAnimations = function() end", "pinnedTarget.OnStopBeingBuilt = callbacks.onStopBeingBuilt", "pinnedTarget.UpdateAnimations = callbacks.updateAnimations", "function EDAFatboyMobileFactory:GetFatboyRollOffGroundPoint(targetUnit)", "if interrupted then");
		RequireTokens(text5, "self.fatboyRollOffTarget = targetUnit", "self:MoveFatboyBuiltUnit(", "self:ReleaseFatboyBuiltUnit(targetUnit)", "FatboyOrderTasks.MOVE, {targetUnit}, false, clearance, nil", "FatboyOrderTasks.MOVE, {targetUnit}, true, source.rallyPoint, nil");
		int num13 = text5.IndexOf("FatboyHostOrderManager.HostIssueOrder", StringComparison.Ordinal);
		int num14 = text5.IndexOf("self:PlayFatboyAnimation(\"close\")", StringComparison.Ordinal);
		if (num13 < 0 || num14 < 0 || num13 >= num14)
		{
			throw new InvalidOperationException("The Fatboy bay must close only after the completed child receives its move-off order.");
		}
		if (CountOccurrences(source, "self:PlayFatboyAnimation(\"walk\")") != 0)
		{
			throw new InvalidOperationException("The static Rest clip must not truncate the Fatboy's clamped close animation.");
		}
	}

	private static void ValidateClientClasses(string source)
	{
		RequireTokens(source, "EDAFatboyMobileFactory", "local FatboyClientFactoryBase = EDAUefLandFactory or EDALandFactory", "local function FatboySetLocalVolumeColliderEnabled", "local localId = EngineClasses.LocalID()", "Engine.GetGlobalEntityPairedLocalID(globalId, localId)", "Engine.SetVolumeColliderEnabled(localId, enabled)", "function EDAFatboyMobileFactory:CreateTarmac()", "EDALandUnit.OnPromoteToUnit(self)", "EDALandUnit.OnCompleted(self)", "EDALandUnit.IsHighlightable(self)", "EDALandUnit.IsSelectable(self)", "EDALandUnit.OnIntelVision(self)", "function EDAFatboyMobileFactory:ClientOnStopBuilding()", "not targetUnit:IsCompleted()", "FatboySetLocalVolumeColliderEnabled(targetUnit.id, false)", "FatboyClientFactoryBase.OnDestroy(self, isDelete)", "FatboyClientFactoryBase.OnDelete(self)");
	}

	private static void ValidateImportScanner(string source)
	{
		if (CountOccurrences(source, "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0") != 1)
		{
			throw new InvalidOperationException("Fatboy projectile scanning must contain exactly one owned override appendix.");
		}
		string ownedImportScannerAppendix = GetOwnedImportScannerAppendix(source);
		RequireTokens(ownedImportScannerAppendix, "local SCO_FatboyScanDir = ScanDir", "function ScanDir(directory)", "local folders = SCO_FatboyScanDir(directory)", "common/projectiles/projectilesTemplates/", "\"psf401\"", "\"psf402\"", "\"psf403\"", "\"psf404\"");
		if (CountOccurrences(ownedImportScannerAppendix, "function ScanDir(directory)") != 1 || CountOccurrences(ownedImportScannerAppendix, "local folders = SCO_FatboyScanDir(directory)") != 1)
		{
			throw new InvalidOperationException("Fatboy projectile scanner must define one one-argument ScanDir call-through.");
		}
		if (ContainsText(ownedImportScannerAppendix, "scanRoot"))
		{
			throw new InvalidOperationException("Fatboy projectile scanner must call the prior ScanDir with directory only.");
		}
	}

	private static string UpgradeImportScanner(string source)
	{
		if (CountOccurrences(source, "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0") != 1)
		{
			throw new InvalidOperationException("Fatboy projectile scanning must contain exactly one owned override appendix.");
		}
		int num = source.LastIndexOf("-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0", StringComparison.Ordinal);
		string ownedImportScannerAppendix = GetOwnedImportScannerAppendix(source);
		string text = UpgradeScanDirWrapper(ownedImportScannerAppendix, "SCO_FatboyScanDir");
		if (!string.Equals(ownedImportScannerAppendix, text, StringComparison.Ordinal))
		{
			return source.Substring(0, num) + text + source.Substring(num + ownedImportScannerAppendix.Length);
		}
		return source;
	}

	private static string GetOwnedImportScannerAppendix(string source)
	{
		int num = source.LastIndexOf("-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Fatboy projectile scanner marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0".Length, StringComparison.Ordinal);
		int num3 = source.IndexOf("local SCO_FatboyScanDir = ScanDir", num + "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0".Length, StringComparison.Ordinal);
		if (num3 < 0)
		{
			throw new InvalidOperationException("Fatboy projectile scanner no longer declares its prior ScanDir owner.");
		}
		int num4 = source.IndexOf("\nlocal SCO_", num3 + "local SCO_FatboyScanDir = ScanDir".Length, StringComparison.Ordinal);
		int num5 = new int[2] { num2, num4 }.Where((int index) => index >= 0).DefaultIfEmpty(source.Length).Min();
		return source.Substring(num, num5 - num);
	}

	private static string UpgradeScanDirWrapper(string appendix, string priorScanner)
	{
		if (!ContainsText(appendix, "scanRoot"))
		{
			return appendix;
		}
		string newValue = "local folders = " + priorScanner + "(directory)";
		string oldValue = (ContainsText(appendix, "function ScanDir(scanRoot, directory)") ? "function ScanDir(scanRoot, directory)" : "function ScanDir(scanRoot,directory)");
		string oldValue2 = (ContainsText(appendix, "local folders = " + priorScanner + "(scanRoot, directory)") ? ("local folders = " + priorScanner + "(scanRoot, directory)") : ("local folders = " + priorScanner + "(scanRoot,directory)"));
		return ReplaceExactly(ReplaceExactly(appendix, oldValue, "function ScanDir(directory)", 1, "legacy Fatboy scanner wrapper function"), oldValue2, newValue, 1, "legacy Fatboy prior-scanner call-through");
	}

	private static string TransformAnimationPlaybackMode(string source)
	{
		string text;
		if (ContainsText(source, "                animationInfo.playbackMode or AnimationPlaybackMode.Loop,\n"))
		{
			text = source;
		}
		else
		{
			RequireTokens(source, "EngineClasses.AnimationClipTemplate(", "                AnimationPlaybackMode.Loop,\n".Trim());
			text = ReplaceExactly(source, "                AnimationPlaybackMode.Loop,\n", "                animationInfo.playbackMode or AnimationPlaybackMode.Loop,\n", 1, "unit-template animation playback-mode argument");
		}
		if (!ContainsText(text, "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0"))
		{
			return text + MarkerAppendix();
		}
		return text;
	}

	private static string BuildProjectileSource(ProjectileSpec projectile)
	{
		string text = string.Empty;
		if (projectile.Movement != null)
		{
			string text2 = NormalizeLineEndings(projectile.Movement).Trim();
			text = string.Join("\n", from line in text2.Split(new char[1] { '\n' })
				select "    " + line) + "\n";
		}
		return "---@type ProjectileTemplate\nProjectileTemplate = {\n    collisionInfo = {\n        centerOffset = {\n            x = 0,\n            y = 0.25,\n            z = 0,\n        },\n        collisionSize = {\n            x = 0.5,\n            y = 0.5,\n            z = 0.5,\n        },\n    },\n    general = {\n        name = \"" + projectile.Name + "\",\n        tpId = \"" + projectile.Id + "\",\n    },\n" + text + "    nonUniformScale = {\n        x = 1,\n        y = 1,\n        z = 1,\n    },\n    visuals = {\n        mesh = {\n            lod0distance = 60,\n        },\n        onImpactEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"" + projectile.Impact + "\",\n                    },\n                },\n            },\n        },\n        persistantEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"" + projectile.Trail + "\",\n                    },\n                },\n            },\n        },\n    },\n}\n\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\n-- Compatibility VFX are explicit Sanctuary stand-ins until native FA projectile\n-- meshes/materials can be converted; damage, trajectory, lifetime, and cadence\n-- are owned by the UEL4511 weapon tables above.";
	}

	private static void QueueAppend(object cache, List<CacheMutation> mutations, string relativePath, string description, Action<string> validateStock, string appendix, Action<string> validatePatched, Func<string, string>? upgradeMarked = null)
	{
		bool flag = string.Equals(relativePath, "LJ/lua/common/units/unitsTemplates/uel4511/uel4511.santp", StringComparison.Ordinal);
		if (flag)
		{
			appendix = TuneFatboyGaussArc(appendix);
		}
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (ContainsText(resourceText, "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0"))
		{
			string text = ((upgradeMarked == null) ? resourceText : upgradeMarked(resourceText));
			if (flag)
			{
				text = TuneFatboyGaussArc(text);
			}
			if (string.Equals(text, resourceText, StringComparison.Ordinal))
			{
				validatePatched(resourceText);
				return;
			}
			object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), text);
			try
			{
				validatePatched(GetResourceText(obj));
				mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
				return;
			}
			catch
			{
				TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + description + " upgrade");
				throw;
			}
		}
		validateStock(resourceText);
		object obj3 = AppendOverride(cachedResource.Stock, appendix);
		try
		{
			string resourceText2 = GetResourceText(obj3);
			if (!ContainsText(resourceText2, "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0"))
			{
				throw new InvalidOperationException("The patched " + description + " did not retain its Fatboy marker.");
			}
			validatePatched(resourceText2);
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj3, added: false, description));
		}
		catch
		{
			TryDisposeNativeArray(obj3.GetType(), obj3, "uncommitted " + description + " replacement");
			throw;
		}
	}

	private static void QueueTransform(object cache, List<CacheMutation> mutations, string relativePath, string description, Func<string, string> transform, Action<string> validatePatched)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string text = NormalizeLineEndings(GetResourceText(cachedResource.Stock));
		if (ContainsText(text, "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0"))
		{
			validatePatched(text);
			return;
		}
		string source = transform(text);
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), source);
		try
		{
			string resourceText = GetResourceText(obj);
			if (!ContainsText(resourceText, "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0"))
			{
				throw new InvalidOperationException("The transformed " + description + " did not retain its Fatboy marker.");
			}
			validatePatched(resourceText);
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + description + " replacement");
			throw;
		}
	}

	private static void QueueVirtualProjectile(object cache, List<CacheMutation> mutations, ProjectileSpec projectile)
	{
		string relativePath = ProjectileRelativePath(projectile.Id);
		string text = "Fatboy projectile template " + projectile.Id;
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, text);
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (!ContainsText(resourceText, "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0"))
			{
				throw new InvalidOperationException("The reserved virtual projectile ID " + projectile.Id + " already exists without the Fatboy marker.");
			}
			ValidateProjectile(resourceText, projectile);
			return;
		}
		string source = BuildProjectileSource(projectile);
		ValidateProjectile(source, projectile);
		object obj = CreateNativeArrayFromText(GetNativeArrayType(cache), source);
		try
		{
			ValidateProjectile(GetResourceText(obj), projectile);
			mutations.Add(new CacheMutation(ResolvePath(cache, relativePath), null, obj, added: true, text));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + text);
			throw;
		}
	}

	private static void ValidateProjectile(string source, ProjectileSpec projectile)
	{
		RequireTokens(source, "-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0", "ProjectileTemplate =", "tpId = \"" + projectile.Id + "\"", "particleName = \"" + projectile.Trail + "\"", "particleName = \"" + projectile.Impact + "\"");
		if (projectile.Movement != null)
		{
			RequireTokens(source, "type = \"TargetEntity\"", "acceleration = 5", "rotationSpeed = 230", "speedMax = 18");
		}
	}

	private static string ProjectileRelativePath(string projectileId)
	{
		return "LJ/lua/common/projectiles/projectilesTemplates/" + projectileId + "/" + projectileId + ".santp";
	}

	private static string SliceFunction(string source, string signature)
	{
		int num = source.IndexOf(signature, StringComparison.Ordinal);
		if (num < 0)
		{
			return string.Empty;
		}
		int num2 = source.IndexOf("\nfunction ", num + signature.Length, StringComparison.Ordinal);
		if (num2 >= 0)
		{
			return source.Substring(num, num2 - num);
		}
		return source.Substring(num);
	}

	private static string ReplaceExactly(string source, string oldValue, string newValue, int expectedOccurrences, string description)
	{
		int num = CountOccurrences(source, oldValue);
		if (num != expectedOccurrences)
		{
			throw new InvalidOperationException($"Expected {expectedOccurrences} {description}, found {num}.");
		}
		return source.Replace(oldValue, newValue);
	}

	private static int CountOccurrences(string source, string needle)
	{
		int num = 0;
		int startIndex = 0;
		while (true)
		{
			int num2 = source.IndexOf(needle, startIndex, StringComparison.Ordinal);
			if (num2 < 0)
			{
				break;
			}
			num++;
			startIndex = num2 + needle.Length;
		}
		return num;
	}

	private static bool ContainsText(string source, string token)
	{
		return source.IndexOf(token, StringComparison.Ordinal) >= 0;
	}

	private static void RequireTokens(string source, params string[] requiredTokens)
	{
		foreach (string text in requiredTokens)
		{
			if (!ContainsText(source, text))
			{
				throw new InvalidOperationException("Expected cached Lua source to contain '" + text + "'.");
			}
		}
	}

	private static string MarkerAppendix()
	{
		return "\n\n-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0\n";
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CacheResource GetCachedResource(object cache, string relativePath, string description)
	{
		return TryGetCachedResource(cache, relativePath, description) ?? throw new FileNotFoundException("The required " + description + " was not present in Sanctuary's Lua file cache.", relativePath);
	}

	private static CacheResource? TryGetCachedResource(object cache, string relativePath, string description)
	{
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string text = ResolvePath(cache, relativePath);
		object obj2 = obj.Invoke(cache, new object[1] { text });
		bool flag = false;
		int num;
		if (obj2 is bool)
		{
			flag = (bool)obj2;
			num = 1;
		}
		else
		{
			num = 0;
		}
		if (((uint)num & (flag ? 1u : 0u)) != 0)
		{
			object obj3 = propertyInfo.GetValue(cache, new object[1] { text }) ?? throw new InvalidOperationException("The cached " + description + " has no value.");
			EnsureNativeArray(obj3, description);
			return new CacheResource(text, obj3);
		}
		string value = "/" + relativePath.Replace('\\', '/');
		string text2 = null;
		object obj4 = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text3 && text3.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (text2 != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + relativePath + ".");
				}
				object obj5 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("The cached " + description + " has no value.");
				EnsureNativeArray(obj5, description);
				text2 = text3;
				obj4 = obj5;
			}
		}
		if (text2 != null && obj4 != null)
		{
			return new CacheResource(text2, obj4);
		}
		return null;
	}

	private static string ResolvePath(object cache, string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static Type GetNativeArrayType(object cache)
	{
		foreach (Type item in new Type[1] { cache.GetType() }.Concat(cache.GetType().GetInterfaces()))
		{
			if (item.IsGenericType)
			{
				Type[] genericArguments = item.GetGenericArguments();
				if (genericArguments.Length == 2 && genericArguments[0] == typeof(string))
				{
					return genericArguments[1];
				}
			}
		}
		throw new InvalidOperationException("The Lua file cache no longer exposes a string-to-NativeArray mapping.");
	}

	private static object AppendOverride(object stockResource, string appendix)
	{
		Type type = stockResource.GetType();
		byte[] nativeArrayBytes = GetNativeArrayBytes(type, stockResource);
		byte[] bytes = Encoding.UTF8.GetBytes(appendix);
		return NativeArrayByteFactory.CreatePersistent(type, nativeArrayBytes, bytes);
	}

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		byte[] bytes = Encoding.UTF8.GetBytes(source);
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, bytes);
	}

	private static string GetResourceText(object resource)
	{
		EnsureNativeArray(resource, "Lua cache resource");
		return Encoding.UTF8.GetString(GetNativeArrayBytes(resource.GetType(), resource));
	}

	private static string NormalizeLineEndings(string text)
	{
		return text.Replace("\r\n", "\n").Replace("\r", "\n");
	}

	private static byte[] GetNativeArrayBytes(Type nativeArrayType, object nativeArray)
	{
		return (byte[])((nativeArrayType.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "ToArray")).Invoke(nativeArray, null) ?? throw new InvalidOperationException(nativeArrayType.FullName + ".ToArray returned null."));
	}

	private static void EnsureNativeArray(object value, string description)
	{
		if (!IsNativeArrayCreated(value))
		{
			throw new InvalidOperationException("The cached " + description + " is not an initialized NativeArray.");
		}
	}

	private static bool IsNativeArrayCreated(object nativeArray)
	{
		object value = (nativeArray.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(nativeArray.GetType().FullName, "IsCreated")).GetValue(nativeArray);
		bool flag = false;
		int num;
		if (value is bool)
		{
			flag = (bool)value;
			num = 1;
		}
		else
		{
			num = 0;
		}
		return (byte)(num & (flag ? 1 : 0)) != 0;
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void RemoveCachedResource(object cache, string path)
	{
		(cache.GetType().GetMethod("Remove", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "Remove")).Invoke(cache, new object[1] { path });
	}

	private static void Commit(object cache, IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			mutation.Assigned = true;
			SetCachedResource(cache, mutation.Path, mutation.Replacement);
		}
		foreach (CacheMutation mutation2 in mutations)
		{
			if (!mutation2.Added && mutation2.Stock != null)
			{
				TryDisposeNativeArray(mutation2.Stock.GetType(), mutation2.Stock, "stock " + mutation2.Description);
			}
		}
	}

	private static void RollBack(object cache, IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation item in mutations.Reverse())
		{
			if (item.Assigned)
			{
				try
				{
					if (item.Added)
					{
						RemoveCachedResource(cache, item.Path);
					}
					else
					{
						SetCachedResource(cache, item.Path, item.Stock ?? throw new InvalidOperationException(item.Description + " lost its stock resource."));
					}
					item.Assigned = false;
				}
				catch (Exception arg)
				{
					Log($"Rollback failed for {item.Description}: {arg}");
				}
			}
			if (!item.Assigned)
			{
				TryDisposeNativeArray(item.Replacement.GetType(), item.Replacement, "replacement " + item.Description);
			}
		}
	}

	private static void DisposeUncommitted(IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			TryDisposeNativeArray(mutation.Replacement.GetType(), mutation.Replacement, "uncommitted " + mutation.Description);
		}
	}

	private static void TryDisposeNativeArray(Type nativeArrayType, object nativeArray, string description)
	{
		try
		{
			if (IsNativeArrayCreated(nativeArray))
			{
				(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
			}
		}
		catch (Exception arg)
		{
			Log($"Could not dispose {description}: {arg}");
		}
	}

	private static void Log(string message)
	{
		string text = "[EDA UEF Fatboy Cache Patcher] " + message;
		Console.WriteLine(text);
		try
		{
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => (object)type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}

	private static void ValidateNativeFactoryPreBuildWait(object cache)
	{
		if (CountOccurrences(NormalizeLineEndings(GetResourceText(GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "native factory pre-build wait").Stock)), "function HostFactory:ProductionBehaviorBuildOne(item)\n    -- Keep the queue intact while waiting for unit cap space.\n    while not self.dead and (self:GetPause() or not self.army:HasUnitCapSpace()) do\n        WaitTicks(5)\n    end\n    if self.dead then return end\n    self.unitBeingBuiltSource = self.unitBeingBuiltSource or self") != 1)
		{
			throw new InvalidOperationException("The native factory pre-build wait changed; Fatboy cannot mirror its cap/pause gate safely.");
		}
	}

	private static string UpgradeFatboyMovementLock(string source)
	{
		int num = CountOccurrences(source, "function EDAFatboyMobileFactory:ProductionBehaviorBuildOne(item)\r\n    self:SetFatboyMovementLocked(true)\r\n    self.fatboyClosePending = false");
		int num2 = CountOccurrences(source, "function EDAFatboyMobileFactory:ProductionBehaviorBuildOne(item)\r\n    -- Mirror the native pre-build wait before locking the mobile hull.\r\n    while not self.dead and (self:GetPause() or not self.army:HasUnitCapSpace()) do\r\n        WaitTicks(5)\r\n    end\r\n    if self.dead then return end\r\n    self:SetFatboyMovementLocked(true)\r\n    self.fatboyClosePending = false");
		if (num == 0 && num2 == 1)
		{
			return source;
		}
		if (num == 1 && num2 == 0)
		{
			return ReplaceExactly(source, "function EDAFatboyMobileFactory:ProductionBehaviorBuildOne(item)\r\n    self:SetFatboyMovementLocked(true)\r\n    self.fatboyClosePending = false", "function EDAFatboyMobileFactory:ProductionBehaviorBuildOne(item)\r\n    -- Mirror the native pre-build wait before locking the mobile hull.\r\n    while not self.dead and (self:GetPause() or not self.army:HasUnitCapSpace()) do\r\n        WaitTicks(5)\r\n    end\r\n    if self.dead then return end\r\n    self:SetFatboyMovementLocked(true)\r\n    self.fatboyClosePending = false", 1, "Fatboy pre-build movement lock");
		}
		throw new InvalidOperationException("Fatboy pre-build movement lock has mixed or unknown provenance.");
	}
}
