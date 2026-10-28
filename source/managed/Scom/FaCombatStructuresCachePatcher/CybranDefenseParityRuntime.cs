using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace FaCombatStructuresCachePatcher;

public static class CybranDefenseParityRuntime
{
	private sealed class WeaponSpec
	{
		public string TemplateId { get; }

		public string SourceUnitId { get; }

		public string SourceProjectileId { get; }

		public string ProjectileId { get; }

		public WeaponStats Stats { get; }

		public AimSpec Aim { get; }

		public IReadOnlyList<string[]> MuzzleGroups { get; }

		public BeamSpec? Beam { get; }

		public string TemplateRelativePath { get; }

		public WeaponSpec(string templateId, string sourceUnitId, string sourceProjectileId, string projectileId, WeaponStats stats, AimSpec aim, IReadOnlyList<string[]> muzzleGroups, BeamSpec? beam)
		{
			TemplateId = templateId;
			SourceUnitId = sourceUnitId;
			SourceProjectileId = sourceProjectileId;
			ProjectileId = projectileId;
			Stats = stats;
			Aim = aim;
			MuzzleGroups = muzzleGroups;
			Beam = beam;
			TemplateRelativePath = "LJ/lua/common/units/unitsTemplates/" + templateId + "/" + templateId + ".santp";
		}
	}

	private sealed class WeaponStats
	{
		public string Damage { get; }

		public string DamageRadius { get; }

		public string FiringRandomness { get; }

		public IReadOnlyList<string> LayerTargetLimits { get; }

		public IReadOnlyList<string> LayerWeaponLimits { get; }

		public string TargetWaterLimits { get; }

		public string MuzzleSalvoDelay { get; }

		public int MuzzleSalvoSize { get; }

		public string? ProjectileLifetime { get; }

		public string RangeMin { get; }

		public string RangeMax { get; }

		public string RangeRingType { get; }

		public string RangeTracking { get; }

		public string ReloadTime { get; }

		public string MuzzleEffect { get; }

		public bool DamageFriendly { get; }

		public bool ReloadProgressBar { get; }

		public WeaponStats(string damage, string damageRadius, string firingRandomness, IReadOnlyList<string> layerTargetLimits, IReadOnlyList<string> layerWeaponLimits, string targetWaterLimits, string muzzleSalvoDelay, int muzzleSalvoSize, string? projectileLifetime, string rangeMin, string rangeMax, string rangeRingType, string rangeTracking, string reloadTime, string muzzleEffect, bool damageFriendly = false, bool reloadProgressBar = false)
		{
			Damage = damage;
			DamageRadius = damageRadius;
			FiringRandomness = firingRandomness;
			LayerTargetLimits = layerTargetLimits;
			LayerWeaponLimits = layerWeaponLimits;
			TargetWaterLimits = targetWaterLimits;
			MuzzleSalvoDelay = muzzleSalvoDelay;
			MuzzleSalvoSize = muzzleSalvoSize;
			ProjectileLifetime = projectileLifetime;
			RangeMin = rangeMin;
			RangeMax = rangeMax;
			RangeRingType = rangeRingType;
			RangeTracking = rangeTracking;
			ReloadTime = reloadTime;
			MuzzleEffect = muzzleEffect;
			DamageFriendly = damageFriendly;
			ReloadProgressBar = reloadProgressBar;
		}
	}

	private sealed class AimSpec
	{
		public string AimBone { get; }

		public string YawBone { get; }

		public string PitchBone { get; }

		public string AimTolerance { get; }

		public string DefaultYaw { get; }

		public string YawRange { get; }

		public string YawSpeed { get; }

		public string DefaultPitch { get; }

		public string PitchMin { get; }

		public string PitchMax { get; }

		public string PitchSpeed { get; }

		public string ProjectileSpeed { get; }

		public string SolverType { get; }

		public bool LeadTarget { get; }

		public bool ReduceMuzzleVelocityToTarget { get; }

		public string? AimGravity { get; }

		public string? CompatibilityNote { get; }

		public string PoseResetTime { get; }

		public AimSpec(string aimBone, string yawBone, string pitchBone, string aimTolerance, string defaultYaw, string yawRange, string yawSpeed, string defaultPitch, string pitchMin, string pitchMax, string pitchSpeed, string projectileSpeed, string solverType, bool leadTarget, bool reduceMuzzleVelocityToTarget, string? aimGravity, string? compatibilityNote, string poseResetTime = "-1")
		{
			AimBone = aimBone;
			YawBone = yawBone;
			PitchBone = pitchBone;
			AimTolerance = aimTolerance;
			DefaultYaw = defaultYaw;
			YawRange = yawRange;
			YawSpeed = yawSpeed;
			DefaultPitch = defaultPitch;
			PitchMin = pitchMin;
			PitchMax = pitchMax;
			PitchSpeed = pitchSpeed;
			ProjectileSpeed = projectileSpeed;
			SolverType = solverType;
			LeadTarget = leadTarget;
			ReduceMuzzleVelocityToTarget = reduceMuzzleVelocityToTarget;
			AimGravity = aimGravity;
			CompatibilityNote = compatibilityNote;
			PoseResetTime = poseResetTime;
		}
	}

	private sealed class BeamSpec
	{
		public string LifetimeTicks { get; }

		public string MaxLengthMultiplier { get; }

		public BeamSpec(string lifetimeTicks, string maxLengthMultiplier)
		{
			LifetimeTicks = lifetimeTicks;
			MaxLengthMultiplier = maxLengthMultiplier;
		}
	}

	private sealed class ProjectileSpec
	{
		public string Id { get; }

		public string SourceProjectileId { get; }

		public string Name { get; }

		public string? Trail { get; }

		public string? Impact { get; }

		public string? BeamEffect { get; }

		public string? Movement { get; }

		public string? SourceBlueprintSha256 { get; }

		public string? SourceScriptSha256 { get; }

		public string? UnsupportedSourceFields { get; }

		public ProjectileSpec(string id, string sourceProjectileId, string name, string? trail, string? impact, string? beamEffect, string? movement, string? sourceBlueprintSha256 = null, string? sourceScriptSha256 = null, string? unsupportedSourceFields = null)
		{
			Id = id;
			SourceProjectileId = sourceProjectileId;
			Name = name;
			Trail = trail;
			Impact = impact;
			BeamEffect = beamEffect;
			Movement = movement;
			SourceBlueprintSha256 = sourceBlueprintSha256;
			SourceScriptSha256 = sourceScriptSha256;
			UnsupportedSourceFields = unsupportedSourceFields;
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

	private const string OverrideMarker = "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0";

	private const string ImportRelativePath = "LJ/lua/common/systems/import.lua";

	private const string AvailableUnitsRelativePath = "LJ/lua/common/units/availableUnits.lua";

	private const string HostUnitsRelativePath = "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua";

	private const string ProjectileRootRelativePath = "LJ/lua/common/projectiles/projectilesTemplates";

	private const string FaUnitsScdSha256 = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26";

	private const string FaProjectilesScdSha256 = "60D2732597CDE9EF046A663C8D439E60844F967147E14737C7AD5A08C641BE12";

	private static readonly WeaponSpec[] WeaponSpecs;

	private static readonly ProjectileSpec[] ProjectileSpecs;

	private static readonly string[] ProjectileIds;

	private static readonly string ImportScannerAppendix;

	private static readonly string HostLifecycleAppendix;

	private static readonly string AvailableUnitsAppendix;

	static CybranDefenseParityRuntime()
	{
		WeaponSpecs = new WeaponSpec[11]
		{
			new WeaponSpec("ues1001", "UEB2101", "TDFPlasma01", "psu101", new WeaponStats("50", "0", "0", new string[3] { "Land", "WaterSurface", "Seabed" }, new string[1] { "Land" }, "Above", "0", 1, "2.875", "0", "26", "DirectFire", "1.15", "0.3333333333333333", "VFX/Muzzle/vem1101_cannon_small_muzzle.sanvfx"), new AimSpec("Turret_Muzzle", "Turret", "Turret_Barrel", "2", "0", "180", "90", "0", "-60", "60", "60", "35", "LowArc", leadTarget: true, reduceMuzzleVelocityToTarget: false, null, null), new string[1][] { new string[1] { "Turret_Muzzle" } }, null),
			new WeaponSpec("ues1201", "UEB2104", "TAARailgun01", "psu121", new WeaponStats("23", "0", "0", new string[1] { "Air" }, new string[1] { "Land" }, "Above", "0", 1, "3.125", "0", "44", "AntiAir", "1.4", "0.6666666666666666", "VFX/Muzzle/vem1121_autocannon_antiair_small_muzzle.sanvfx"), new AimSpec("Turret_Muzzle_01", "Turret", "Turret_Barrel", "0.5", "0", "180", "180", "-45", "-90", "0", "180", "45", "NoArc", leadTarget: true, reduceMuzzleVelocityToTarget: false, "{ x = 0, y = 0, z = 0 }", null), new string[1][] { new string[2] { "Turret_Muzzle_01", "Turret_Muzzle_02" } }, null),
			new WeaponSpec("ues2201", "UEB2204", "TAALightFragmentationShell01", "psu221", new WeaponStats("102", "4", "2.5", new string[1] { "Air" }, new string[1] { "Land" }, "Above", "0.1", 2, "3.75", "0", "44", "AntiAir", "1.4", "0.6666666666666666", "VFX/Muzzle/vem7601_railgun_flak_medium_muzzle.sanvfx"), new AimSpec("Turret_Barrel", "Turret", "Turret_Barrel", "2", "0", "180", "180", "35", "-10", "80", "180", "20", "NoArc", leadTarget: false, reduceMuzzleVelocityToTarget: false, "{ x = 0, y = 0, z = 0 }", "FA detonate-above-height is unavailable; direct collision preserves source flak damage and radius."), new string[2][]
			{
				new string[1] { "Turret_Muzzle_Right" },
				new string[1] { "Turret_Muzzle_Left" }
			}, null),
			new WeaponSpec("ues3201", "UEB2304", "TAAMissileFlayer01", "psu321", new WeaponStats("200", "0", "0", new string[1] { "Air" }, new string[1] { "Land" }, "Above", "0.2", 6, "6", "0", "60", "AntiAir", "1.4", "3.571428571428571", "VFX/Muzzle/vem3301_missile_antiair_large_muzzle.sanvfx"), new AimSpec("Turret_Barrel", "Turret", "Turret_Barrel", "10", "0", "180", "180", "25", "-55", "105", "180", "30", "NoArc", leadTarget: false, reduceMuzzleVelocityToTarget: false, "{ x = 0, y = 0, z = 0 }", "FA on-lost-target tracking duration is unavailable; Sanctuary retains target-entity steering."), new string[6][]
			{
				new string[1] { "Turret_Muzzle_Left01" },
				new string[1] { "Turret_Muzzle_Right01" },
				new string[1] { "Turret_Muzzle_Left02" },
				new string[1] { "Turret_Muzzle_Right02" },
				new string[1] { "Turret_Muzzle_Left03" },
				new string[1] { "Turret_Muzzle_Right03" }
			}, null),
			new WeaponSpec("ues2001", "UEB2301", "TDFGauss02", "psu201", new WeaponStats("70", "2", "0.1", new string[3] { "Land", "WaterSurface", "Seabed" }, new string[1] { "Land" }, "Above", "0", 1, "1.6428571428571428", "0", "50", "DirectFire", "1.15", "1.6666666666666667", "VFX/Muzzle/vem1101_cannon_small_muzzle.sanvfx"), new AimSpec("Turret_Muzzle02", "Turret", "Turret_Barrel", "1", "0", "180", "65", "0", "-55", "55", "30", "35", "LowArc", leadTarget: true, reduceMuzzleVelocityToTarget: false, null, null), new string[1][] { new string[3] { "Turret_Muzzle01", "Turret_Muzzle02", "Turret_Muzzle03" } }, null),
			new WeaponSpec("ugs1001", "URB2101", "CDFLaserHeavy01", "pcg101", new WeaponStats("50", "0", "0", new string[3] { "Land", "WaterSurface", "Seabed" }, new string[1] { "Land" }, "Above", "0", 1, "2.875", "0", "26", "DirectFire", "1.15", "0.3333333333333333", "VFX/Muzzle/vgm1121_autocannon_plasma_small_muzzle.sanvfx"), new AimSpec("Turret_Muzzle", "Turret", "Turret_Barrel", "2", "0", "180", "90", "10", "-45", "65", "60", "35", "LowArc", leadTarget: true, reduceMuzzleVelocityToTarget: false, null, null), new string[1][] { new string[1] { "Turret_Muzzle" } }, null),
			new WeaponSpec("ugs2001", "URB2301", "beam (no FA ProjectileId)", "pcg201", new WeaponStats("5.5", "0", "0", new string[3] { "Land", "WaterSurface", "Seabed" }, new string[1] { "Land" }, "Above", "0", 1, null, "0", "50", "DirectFire", "1.15", "0.6666666666666666", "VFX/Muzzle/vgm7301_beam_plasma_large_muzzle_loop.sanvfx"), new AimSpec("Turret_Muzzle01", "Turret_B01", "Turret_B02", "2", "0", "180", "60", "10", "-45", "65", "60", "100", "NoArc", leadTarget: false, reduceMuzzleVelocityToTarget: false, null, "FA beams have no muzzle velocity; 100 is a Sanctuary aim-controller-only sentinel."), new string[3][]
			{
				new string[1] { "Turret_Muzzle01" },
				new string[1] { "Turret_Muzzle02" },
				new string[1] { "Turret_Muzzle03" }
			}, new BeamSpec("6", "1")),
			new WeaponSpec("ugs1201", "URB2104", "CAAAutocannon01", "pcg121", new WeaponStats("14", "0", "0", new string[1] { "Air" }, new string[1] { "Land" }, "Above", "0.1", 2, "1.875", "0", "44", "AntiAir", "1.4", "0.4", "VFX/Muzzle/vcm3121_cannon_antiair_small_muzzle.sanvfx"), new AimSpec("Turret_Muzzle_01", "Turret", "Turret_Barrel", "0.5", "0", "180", "180", "45", "0", "90", "180", "45", "NoArc", leadTarget: true, reduceMuzzleVelocityToTarget: false, "{ x = 0, y = 0, z = 0 }", null), new string[2][]
			{
				new string[1] { "Turret_Muzzle_01" },
				new string[1] { "Turret_Muzzle_02" }
			}, null),
			new WeaponSpec("ugs2201", "URB2204", "CAABurstCloud01", "pcg221", new WeaponStats("38", "4", "2.5", new string[1] { "Air" }, new string[1] { "Land" }, "Above", "0.1", 2, "5", "0", "44", "AntiAir", "1.4", "0.5", "VFX/Muzzle/vgm3221_cannon_antiair_medium_muzzle.sanvfx"), new AimSpec("Turret_Recoil01_Muzzle01", "Turret", "Turret_Barrel", "2", "0", "180", "180", "35", "-5", "75", "180", "20", "NoArc", leadTarget: true, reduceMuzzleVelocityToTarget: false, "{ x = 0, y = 0, z = 0 }", null, "3"), new string[4][]
			{
				new string[1] { "Turret_Recoil01_Muzzle01" },
				new string[1] { "Turret_Recoil01_Muzzle02" },
				new string[1] { "Turret_Recoil02_Muzzle01" },
				new string[1] { "Turret_Recoil02_Muzzle02" }
			}, null),
			new WeaponSpec("ugs3201", "URB2304", "CAAMissileNanite02", "pcg321", new WeaponStats("300", "0", "0", new string[1] { "Air" }, new string[1] { "Land" }, "Above", "0.3", 4, "3", "0", "60", "AntiAir", "1.4", "3.571428571428571", "VFX/Muzzle/vcm3301_missile_antiair_large_muzzle.sanvfx"), new AimSpec("Turret_Left_Muzzle01", "Turret", "Turret_Barrel", "50", "0", "180", "180", "25", "-25", "75", "180", "30", "NoArc", leadTarget: false, reduceMuzzleVelocityToTarget: false, "{ x = 0, y = 0, z = 0 }", null), new string[8][]
			{
				new string[1] { "Turret_Left_Muzzle01" },
				new string[1] { "Turret_Left_Muzzle02" },
				new string[1] { "Turret_Left_Muzzle03" },
				new string[1] { "Turret_Left_Muzzle04" },
				new string[1] { "Turret_Right_Muzzle01" },
				new string[1] { "Turret_Right_Muzzle02" },
				new string[1] { "Turret_Right_Muzzle03" },
				new string[1] { "Turret_Right_Muzzle04" }
			}, null),
			new WeaponSpec("ugs3101", "URB2302", "CIFArtilleryProton01", "pcg312", new WeaponStats("4600", "8", "0.75", new string[3] { "Land", "WaterSurface", "Seabed" }, new string[1] { "Land" }, "Above", "0", 1, "120", "150", "700", "IndirectFire", "1.1", "10", "VFX/Muzzle/vgm8321_plasma_stream_large_muzzle.sanvfx", damageFriendly: true, reloadProgressBar: true), new AimSpec("Turret_Muzzle", "Turret", "Turret_Barrel", "2", "0", "180", "3", "30", "0", "60", "3", "60", "HighArc", leadTarget: false, reduceMuzzleVelocityToTarget: true, null, "FA reduces muzzle velocity beyond 650 range; Sanctuary exposes only the boolean adapter."), new string[1][] { new string[1] { "Turret_Muzzle" } }, null)
		};
		ProjectileSpecs = new ProjectileSpec[11]
		{
			new ProjectileSpec("psu101", "TDFPlasma01", "UEF_Plasma_T1_PointDefense", "VFX/Trails/vet1101_cannon_small_trail.sanvfx", "VFX/Impact/vei1101_cannon_small_impact.sanvfx", null, null, "cd2fa28e058af6a39e8ca4ef7e440b5c655fad3f899cf06cea0eb20d70586103", "c8ee9063b2a1273a8ed4fc389df315c1c6bff3a3365763bbaa332e73dcd591c0", "DestroyOnWater; FA emitter graph"),
			new ProjectileSpec("psu121", "TAARailgun01", "UEF_Railgun_T1_AntiAir", "VFX/Trails/vet1121_autocannon_small_trail.sanvfx", "VFX/Impact/vei1121_autocannon_small_impact.sanvfx", null, null, "27f4839a8b5b048073055a42fc728537303e8fae0a28266fe6674fbdb18bbc8f", "36c2417368fb105b30325e2ee1fa1f63f51c79ddf18e0fece8842108333cd92e", "DestroyOnWater; FA velocity-aligned mesh; FA emitter graph"),
			new ProjectileSpec("psu221", "TAALightFragmentationShell01", "UEF_FragmentationShell_T2_AntiAir", "VFX/Trails/vet1121_autocannon_small_trail.sanvfx", "VFX/Impact/vei1121_autocannon_small_impact.sanvfx", null, null, "40248b18e2d77e9ee0659444c440511b4232b515eff6372774d1c42b539dc588", "a22c5d63a904bd719fadf2c7826248ec83c92602e7334cb6ccbce7f9fa5a89e7", "DestroyOnWater; DetonateAboveHeight 10; FA velocity-aligned mesh; FA emitter graph"),
			new ProjectileSpec("psu321", "TAAMissileFlayer01", "UEF_Flayer_Missile_T3_AntiAir", "VFX/Trails/vet3301_missile_antiair_large_trail.sanvfx", "VFX/Impact/vei3301_missile_antiair_large_impact.sanvfx", null, "movement = {\n    acceleration = 6,\n    alignToVelocity = true,\n    gravityMultiplier = 0,\n    rotationSpeed = 180,\n    speedMax = 50,\n    type = \"TargetEntity\",\n},", "8b0ec153e08f756d7623a671a2dcc2852bd3b54ca1e2a23af4cf83e81f5d6fc9", "ba368ff670768bbd3897c154140e85f35922d47aeba96feab22d017cc6342726", "DestroyOnWater; OnLostTargetLifetime 0.7; FA emitter graph"),
			new ProjectileSpec("psu201", "TDFGauss02", "UEF_Gauss_T2_PointDefense", "VFX/Trails/vet1101_cannon_small_trail.sanvfx", "VFX/Impact/vei1101_cannon_small_impact.sanvfx", null, null),
			new ProjectileSpec("pcg101", "CDFLaserHeavy01", "Cybran_Laser_Heavy", "VFX/Trails/vgt1281_cannon_plasma_medium_trail.sanvfx", "VFX/Impact/vgi1281_cannon_plasma_medium_impact.sanvfx", null, null),
			new ProjectileSpec("pcg201", "beam (no FA ProjectileId)", "Cybran_Beam_Heavy", null, "VFX/Impact/vgi1281_cannon_plasma_medium_impact.sanvfx", "VFX/Beams/vgb7301_beam_plasma_large_beam.sanvfx", null),
			new ProjectileSpec("pcg121", "CAAAutocannon01", "Cybran_Autocannon_AntiAir", "VFX/Trails/vgt3221_cannon_antiair_medium_trail.sanvfx", "VFX/Impact/vgi3221_cannon_antiair_medium_impact.sanvfx", null, null),
			new ProjectileSpec("pcg221", "CAABurstCloud01", "Cybran_BurstCloud_AntiAir", "VFX/Trails/vgt3221_cannon_antiair_medium_trail.sanvfx", "VFX/Impact/vgi3221_cannon_antiair_medium_impact.sanvfx", null, null),
			new ProjectileSpec("pcg321", "CAAMissileNanite02", "Cybran_Nanite_Missile_AntiAir", "VFX/Trails/vgt3301_missile_antiair_large_trail.sanvfx", "VFX/Impact/vci3301_missile_antiair_large_impact.sanvfx", null, "movement = {\n    acceleration = 5,\n    alignToVelocity = true,\n    gravityMultiplier = 0,\n    rotationSpeed = 180,\n    speedMax = 50,\n    type = \"TargetEntity\",\n},"),
			new ProjectileSpec("pcg312", "CIFArtilleryProton01", "Cybran_Proton_Artillery", "VFX/Trails/vgt8321_plasma_stream_large_trail.sanvfx", "VFX/Impact/vgi8321_plasma_stream_large_impact.sanvfx", null, null)
		};
		ProjectileIds = ProjectileSpecs.Select((ProjectileSpec projectile) => projectile.Id).ToArray();
		ImportScannerAppendix = "\n\n-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0\n-- FilesCache owns these source-specific virtual projectile templates.  Chain\n-- the scanner installed by any earlier module instead of replacing it.\nlocal SCO_CybranDefenseScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_CybranDefenseScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n\n    local knownFolders = {}\n    for _, folder in ipairs(folders) do\n        knownFolders[folder] = true\n    end\n\n    local cybranDefenseProjectiles = {\n        \"psu101\",\n        \"psu121\",\n        \"psu221\",\n        \"psu321\",\n        \"psu201\",\n        \"pcg101\",\n        \"pcg201\",\n        \"pcg121\",\n        \"pcg221\",\n        \"pcg321\",\n        \"pcg312\",\n    }\n    for _, templateId in ipairs(cybranDefenseProjectiles) do\n        local folder = directory .. templateId\n        if not knownFolders[folder] then\n            table.insert(folders, folder)\n            knownFolders[folder] = true\n        end\n    end\n    return folders\nend";
		HostLifecycleAppendix = "\n\n-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0\n-- Exact supported portions of the FA extractor/radar lifecycle. Every wrapper\n-- delegates first (except the pre-upgrade animator wake-up) and is ID-gated, so\n-- unrelated units and wrappers installed by earlier modules keep ownership.\nlocal SCO_FaCombatHostUnit = HostUnit or Unit\nif not SCO_FaCombatHostUnit then\n    error(\"FA combat structures could not resolve the host unit base class.\")\nend\n\nlocal SCO_FaCombatExtractorIds = {\n    [\"ugs1601\"] = true,\n    [\"ugs2601\"] = true,\n    [\"ugs3601\"] = true,\n    [\"ues1601\"] = true,\n    [\"ues2601\"] = true,\n    [\"ues3601\"] = true,\n}\nlocal SCO_FaCombatRadarIds = {\n    [\"ugs1701\"] = true,\n    [\"ugs2701\"] = true,\n    [\"ugs3701\"] = true,\n    [\"ues1701\"] = true,\n    [\"ues2701\"] = true,\n    [\"ues3701\"] = true,\n    [\"uss1701\"] = true,\n    [\"uss2701\"] = true,\n    [\"uss3701\"] = true,\n}\n\nlocal SCO_FaCombatStockCheckProductionState = SCO_FaCombatHostUnit.CheckProductionState\nlocal SCO_FaCombatStockCheckRadarState = SCO_FaCombatHostUnit.CheckRadarState\nlocal SCO_FaCombatStockOnEnergyDown = SCO_FaCombatHostUnit.OnEnergyDown\nlocal SCO_FaCombatStockOnEnergyUp = SCO_FaCombatHostUnit.OnEnergyUp\nlocal SCO_FaCombatStockOnStopBeingBuilt = SCO_FaCombatHostUnit.OnStopBeingBuilt\nlocal SCO_FaCombatStockOnStartUpgrading = SCO_FaCombatHostUnit.OnStartUpgrading\nlocal SCO_FaCombatStockOnEndUpgrading = SCO_FaCombatHostUnit.OnEndUpgrading\n\nfunction SCO_FaCombatHostUnit:SCOApplyFaExtractorState()\n    if not SCO_FaCombatExtractorIds[self.tpId] then\n        return\n    end\n    local active = self:IsCompleted()\n        and self:GetProductionToggle()\n        and not self.army.economy.isEnergyDown\n    if self.resourceEntities.production then\n        self.resourceEntities.production:SetEnabled(active)\n    end\n    -- Progress-bound upgrade clips share this animator. Keep it awake during an\n    -- upgrade; otherwise the source pump follows production/power state.\n    self:SetAnimatorEnabled(self:IsUpgrading() or active)\nend\n\nfunction SCO_FaCombatHostUnit:CheckProductionState()\n    SCO_FaCombatStockCheckProductionState(self)\n    self:SCOApplyFaExtractorState()\nend\n\nfunction SCO_FaCombatHostUnit:CheckRadarState()\n    SCO_FaCombatStockCheckRadarState(self)\n    if SCO_FaCombatRadarIds[self.tpId] and self.radarDetector then\n        self:SetRotatorsEnabled(self.radarDetector:GetEnabled())\n    end\nend\n\nfunction SCO_FaCombatHostUnit:OnEnergyDown()\n    SCO_FaCombatStockOnEnergyDown(self)\n    self:SCOApplyFaExtractorState()\nend\n\nfunction SCO_FaCombatHostUnit:OnEnergyUp()\n    SCO_FaCombatStockOnEnergyUp(self)\n    self:SCOApplyFaExtractorState()\nend\n\nfunction SCO_FaCombatHostUnit:OnStopBeingBuilt()\n    SCO_FaCombatStockOnStopBeingBuilt(self)\n    self:SCOApplyFaExtractorState()\n    if SCO_FaCombatRadarIds[self.tpId] then\n        self:CheckRadarState()\n    end\nend\n\nfunction SCO_FaCombatHostUnit:OnStartUpgrading(targetUnit)\n    if SCO_FaCombatExtractorIds[self.tpId] then\n        self:SetAnimatorEnabled(true)\n    end\n    return SCO_FaCombatStockOnStartUpgrading(self, targetUnit)\nend\n\nfunction SCO_FaCombatHostUnit:OnEndUpgrading(targetUnit)\n    local result = SCO_FaCombatStockOnEndUpgrading(self, targetUnit)\n    self:SCOApplyFaExtractorState()\n    return result\nend";
		AvailableUnitsAppendix = "\n\n-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0\n-- The current engine already lists UGS3201 as available.  Reassert that roster\n-- state only after URB2304's complete weapon/muzzle contract is installed in\n-- this same cache transaction, so the marker attests one complete generation.\n-- This is a roster-loader gate only.  The stock UGS3201 tags still determine\n-- builder eligibility; this patch does not create a factory rule or canBuild\n-- expression.\nAvailableUnits[\"ugs3201\"] = true";
		ValidateSpecs();
	}

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			if (ValidateExistingGeneration(obj))
			{
				Log("All eleven defense weapons and extractor/radar lifecycle contracts already contain the parity override.");
				return;
			}
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua", "FA combat extractor/radar host lifecycle", delegate(string source)
			{
				RequireTokens(source, "function HostUnit:CheckProductionState()", "function HostUnit:CheckRadarState()", "function HostUnit:OnStopBeingBuilt()");
			}, HostLifecycleAppendix, ValidateHostLifecycle, UpgradeSeraphimRadarLifecycle);
			WeaponSpec[] weaponSpecs = WeaponSpecs;
			foreach (WeaponSpec weapon in weaponSpecs)
			{
				Func<string, string> upgradeMarked = null;
				if (string.Equals(weapon.TemplateId, "ugs2201", StringComparison.Ordinal))
				{
					upgradeMarked = UpgradeBurstMasterPoseReset;
				}
				QueueAppend(obj, list, weapon.TemplateRelativePath, weapon.TemplateId + " FA source weapon template", delegate(string source)
				{
					RequireTokens(source, "UnitTemplate =", "tpId = \"" + weapon.TemplateId + "\"", "weapons =");
				}, BuildWeaponAppendix(weapon), delegate(string source)
				{
					ValidateWeaponOverride(source, weapon);
				}, upgradeMarked);
			}
			QueueAppend(obj, list, "LJ/lua/common/systems/import.lua", "Cybran defense virtual projectile directory scanner", delegate(string source)
			{
				RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory");
			}, ImportScannerAppendix, ValidateImportScanner, UpgradeImportScanner);
			ProjectileSpec[] projectileSpecs = ProjectileSpecs;
			foreach (ProjectileSpec projectile in projectileSpecs)
			{
				QueueVirtualProjectile(obj, list, projectile);
			}
			QueueAppend(obj, list, "LJ/lua/common/units/availableUnits.lua", "UGS3201 availability table", delegate(string source)
			{
				RequireTokens(source, "AvailableUnits =", "ugs3201 = true");
			}, AvailableUnitsAppendix, ValidateAvailability);
			Commit(obj, list);
			Log($"Applied {list.Count} atomic defensive-structure parity cache mutations: " + "extractor/radar lifecycle, eleven weapon templates, eleven virtual projectiles, scanner, and UGS3201 availability.");
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
			Log($"Failed to apply defensive-structure source parity: {arg}");
			throw;
		}
	}

	private static bool ValidateExistingGeneration(object cache)
	{
		int num = 0;
		int num2 = WeaponSpecs.Length + ProjectileSpecs.Length + 3;
		if (ContainsMarker(GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua", "host unit lifecycle").Stock))
		{
			num++;
		}
		WeaponSpec[] weaponSpecs = WeaponSpecs;
		foreach (WeaponSpec weaponSpec in weaponSpecs)
		{
			if (ContainsMarker(GetCachedResource(cache, weaponSpec.TemplateRelativePath, weaponSpec.TemplateId).Stock))
			{
				num++;
			}
		}
		if (ContainsMarker(GetCachedResource(cache, "LJ/lua/common/systems/import.lua", "projectile directory scanner").Stock))
		{
			num++;
		}
		if (ContainsMarker(GetCachedResource(cache, "LJ/lua/common/units/availableUnits.lua", "available-unit table").Stock))
		{
			num++;
		}
		ProjectileSpec[] projectileSpecs = ProjectileSpecs;
		foreach (ProjectileSpec projectileSpec in projectileSpecs)
		{
			CacheResource cacheResource = TryGetCachedResource(cache, ProjectileRelativePath(projectileSpec.Id), "Cybran projectile template " + projectileSpec.Id);
			if (cacheResource != null && ContainsMarker(cacheResource.Stock))
			{
				num++;
			}
		}
		if (num == 0)
		{
			return false;
		}
		if (num != num2)
		{
			throw new InvalidOperationException("A partial defensive-structure parity cache generation was found; refusing to mix source-contract generations.");
		}
		string resourceText = GetResourceText(GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua", "host unit lifecycle").Stock);
		if (RequiresSeraphimRadarLifecycleUpgrade(resourceText))
		{
			return false;
		}
		weaponSpecs = WeaponSpecs;
		foreach (WeaponSpec weaponSpec2 in weaponSpecs)
		{
			string resourceText2 = GetResourceText(GetCachedResource(cache, weaponSpec2.TemplateRelativePath, weaponSpec2.TemplateId).Stock);
			if (string.Equals(weaponSpec2.TemplateId, "ugs2201", StringComparison.Ordinal) && RequiresBurstMasterPoseResetUpgrade(resourceText2))
			{
				return false;
			}
			ValidateWeaponOverride(resourceText2, weaponSpec2);
		}
		ValidateHostLifecycle(resourceText);
		string resourceText3 = GetResourceText(GetCachedResource(cache, "LJ/lua/common/systems/import.lua", "projectile directory scanner").Stock);
		if (RequiresImportScannerUpgrade(resourceText3))
		{
			return false;
		}
		ValidateImportScanner(resourceText3);
		ValidateAvailability(GetResourceText(GetCachedResource(cache, "LJ/lua/common/units/availableUnits.lua", "available-unit table").Stock));
		projectileSpecs = ProjectileSpecs;
		foreach (ProjectileSpec projectileSpec2 in projectileSpecs)
		{
			ValidateProjectile(GetResourceText(GetCachedResource(cache, ProjectileRelativePath(projectileSpec2.Id), "Cybran projectile template " + projectileSpec2.Id).Stock), projectileSpec2);
		}
		return true;
	}

	private static string BuildWeaponAppendix(WeaponSpec weapon)
	{
		WeaponStats stats = weapon.Stats;
		AimSpec aim = weapon.Aim;
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0");
		stringBuilder.AppendLine("-- FA source: " + weapon.SourceUnitId + " / " + weapon.SourceProjectileId + "; units.scd SHA-256 C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26, projectiles.scd SHA-256 60D2732597CDE9EF046A663C8D439E60844F967147E14737C7AD5A08C641BE12.");
		stringBuilder.AppendLine("-- Source gameplay values are explicit below. Native Sanctuary audio and the listed VFX remain documented compatibility fallbacks until FA effects are converted.");
		stringBuilder.AppendLine("local sourceWeapon = UnitTemplate.weapons and UnitTemplate.weapons[1]");
		stringBuilder.AppendLine("if not sourceWeapon then");
		stringBuilder.AppendLine("    error(\"" + weapon.TemplateId + " requires a stock primary weapon\")");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("sourceWeapon.aimControllers = {");
		stringBuilder.AppendLine("    {");
		stringBuilder.AppendLine("        aimBone = \"" + aim.AimBone + "\",");
		if (aim.AimGravity != null)
		{
			stringBuilder.AppendLine("        aimGravity = " + aim.AimGravity + ",");
		}
		stringBuilder.AppendLine("        aimTolerance = " + aim.AimTolerance + ",");
		stringBuilder.AppendLine("        defaultPitchAdjustment = " + aim.DefaultPitch + ",");
		stringBuilder.AppendLine("        defaultYawAdjustment = " + aim.DefaultYaw + ",");
		stringBuilder.AppendLine("        leadTarget = " + LuaBoolean(aim.LeadTarget) + ",");
		stringBuilder.AppendLine("        pitchBone = \"" + aim.PitchBone + "\",");
		stringBuilder.AppendLine("        pitchMax = " + aim.PitchMax + ",");
		stringBuilder.AppendLine("        pitchMin = " + aim.PitchMin + ",");
		stringBuilder.AppendLine("        pitchSpeed = " + aim.PitchSpeed + ",");
		stringBuilder.AppendLine("        poseResetTime = " + aim.PoseResetTime + ",");
		stringBuilder.AppendLine("        projectileSpeed = " + aim.ProjectileSpeed + ",");
		stringBuilder.AppendLine("        reduceMuzzleVelocityToTarget = " + LuaBoolean(aim.ReduceMuzzleVelocityToTarget) + ",");
		stringBuilder.AppendLine("        solverType = \"" + aim.SolverType + "\",");
		stringBuilder.AppendLine("        yawBone = \"" + aim.YawBone + "\",");
		stringBuilder.AppendLine("        yawMax = " + aim.YawRange + ",");
		stringBuilder.AppendLine("        yawMin = -" + aim.YawRange + ",");
		stringBuilder.AppendLine("        yawSpeed = " + aim.YawSpeed + ",");
		stringBuilder.AppendLine("    },");
		stringBuilder.AppendLine("}");
		if (aim.CompatibilityNote != null)
		{
			stringBuilder.AppendLine("-- Compatibility adapter: " + aim.CompatibilityNote);
		}
		stringBuilder.AppendLine("sourceWeapon.damage = " + stats.Damage);
		stringBuilder.AppendLine("sourceWeapon.damageFriendly = " + LuaBoolean(stats.DamageFriendly));
		stringBuilder.AppendLine("sourceWeapon.damageRadius = " + stats.DamageRadius);
		stringBuilder.AppendLine("sourceWeapon.damageType = \"Normal\"");
		stringBuilder.AppendLine("sourceWeapon.effects = {");
		stringBuilder.AppendLine("    onFire = \"" + stats.MuzzleEffect + "\",");
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine("sourceWeapon.firingRandomness = " + stats.FiringRandomness);
		stringBuilder.AppendLine("sourceWeapon.layerTargetLimits = " + BuildStringList(stats.LayerTargetLimits));
		stringBuilder.AppendLine("sourceWeapon.layerWeaponLimits = " + BuildStringList(stats.LayerWeaponLimits));
		stringBuilder.AppendLine("sourceWeapon.muzzleGroupChargeDelay = 0");
		stringBuilder.AppendLine("sourceWeapon.muzzleGroupTimeOut = -1");
		stringBuilder.AppendLine("sourceWeapon.muzzleGroups = " + BuildMuzzleGroups(weapon.MuzzleGroups));
		stringBuilder.AppendLine("sourceWeapon.muzzleSalvoDelay = " + stats.MuzzleSalvoDelay);
		stringBuilder.AppendLine($"sourceWeapon.muzzleSalvoSize = {stats.MuzzleSalvoSize}");
		stringBuilder.AppendLine("sourceWeapon.muzzles = " + BuildMuzzleMap(weapon.MuzzleGroups, aim.AimBone));
		if (stats.ProjectileLifetime == null)
		{
			stringBuilder.AppendLine("sourceWeapon.projectileLifetime = nil");
		}
		else
		{
			stringBuilder.AppendLine("sourceWeapon.projectileLifetime = " + stats.ProjectileLifetime);
		}
		stringBuilder.AppendLine("sourceWeapon.projectileTemplate = \"" + weapon.ProjectileId + "\"");
		stringBuilder.AppendLine("sourceWeapon.rangeMax = " + stats.RangeMax);
		stringBuilder.AppendLine("sourceWeapon.rangeMin = " + stats.RangeMin);
		stringBuilder.AppendLine("sourceWeapon.rangeRingType = \"" + stats.RangeRingType + "\"");
		stringBuilder.AppendLine("sourceWeapon.rangeTracking = " + stats.RangeTracking);
		stringBuilder.AppendLine("sourceWeapon.reloadProgressBar = " + LuaBoolean(stats.ReloadProgressBar));
		stringBuilder.AppendLine("sourceWeapon.reloadTime = " + stats.ReloadTime);
		stringBuilder.AppendLine("sourceWeapon.targetWaterLimits = \"" + stats.TargetWaterLimits + "\"");
		if (weapon.Beam == null)
		{
			stringBuilder.AppendLine("sourceWeapon.beam = nil");
			stringBuilder.AppendLine("sourceWeapon.beamLifetime = nil");
			stringBuilder.AppendLine("sourceWeapon.beamMaxLenghtMultiplier = nil");
		}
		else
		{
			stringBuilder.AppendLine("sourceWeapon.beamLifetime = " + weapon.Beam.LifetimeTicks);
			stringBuilder.AppendLine("sourceWeapon.beamMaxLenghtMultiplier = " + weapon.Beam.MaxLengthMultiplier);
			stringBuilder.AppendLine("sourceWeapon.beam = {");
			stringBuilder.AppendLine("    subMesh = {");
			stringBuilder.AppendLine("        {");
			stringBuilder.AppendLine("            model = \"VFX/Models/Beams/BeamBasicLongSingle.sanmodel\",");
			stringBuilder.AppendLine("            material = \"VFX/Materials/Beam/Beam ugs1201_01.sanmaterial\",");
			stringBuilder.AppendLine("        },");
			stringBuilder.AppendLine("        {");
			stringBuilder.AppendLine("            model = \"VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel\",");
			stringBuilder.AppendLine("            material = \"VFX/Materials/Beam/Beam ugs1201_02.sanmaterial\",");
			stringBuilder.AppendLine("        },");
			stringBuilder.AppendLine("    },");
			stringBuilder.AppendLine("    fadeInTime = 1.0,");
			stringBuilder.AppendLine("    fadeOutTime = 1.0,");
			stringBuilder.AppendLine("    cullDistance = 500.0,");
			stringBuilder.AppendLine("}");
		}
		stringBuilder.AppendLine("-- Rack order is FA authored order; every imported muzzle shares one controller.");
		return stringBuilder.ToString();
	}

	private static string BuildProjectileSource(ProjectileSpec projectile)
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("---@type ProjectileTemplate");
		stringBuilder.AppendLine("ProjectileTemplate = {");
		stringBuilder.AppendLine("    collisionInfo = {");
		stringBuilder.AppendLine("        centerOffset = { x = 0, y = 0.5, z = 0 },");
		stringBuilder.AppendLine("        collisionSize = { x = 1, y = 1, z = 1 },");
		stringBuilder.AppendLine("    },");
		stringBuilder.AppendLine("    general = {");
		stringBuilder.AppendLine("        name = \"" + projectile.Name + "\",");
		stringBuilder.AppendLine("        tpId = \"" + projectile.Id + "\",");
		stringBuilder.AppendLine("    },");
		if (projectile.Movement != null)
		{
			string[] array = NormalizeLineEndings(projectile.Movement).Trim().Split(new char[1] { '\n' });
			foreach (string text in array)
			{
				stringBuilder.AppendLine("    " + text);
			}
		}
		stringBuilder.AppendLine("    nonUniformScale = { x = 1, y = 1, z = 1 },");
		stringBuilder.AppendLine("    visuals = {");
		if (projectile.BeamEffect != null)
		{
			stringBuilder.AppendLine("        beamEffectName = \"" + projectile.BeamEffect + "\",");
		}
		stringBuilder.AppendLine("        mesh = { lod0distance = 60 },");
		if (projectile.Impact != null)
		{
			stringBuilder.AppendLine("        onImpactEffects = {");
			stringBuilder.AppendLine("            {");
			stringBuilder.AppendLine("                effects = {");
			stringBuilder.AppendLine("                    { particleName = \"" + projectile.Impact + "\" },");
			stringBuilder.AppendLine("                },");
			stringBuilder.AppendLine("            },");
			stringBuilder.AppendLine("        },");
		}
		if (projectile.Trail != null)
		{
			stringBuilder.AppendLine("        persistantEffects = {");
			stringBuilder.AppendLine("            {");
			stringBuilder.AppendLine("                effects = {");
			stringBuilder.AppendLine("                    { particleName = \"" + projectile.Trail + "\" },");
			stringBuilder.AppendLine("                },");
			stringBuilder.AppendLine("            },");
			stringBuilder.AppendLine("        },");
		}
		stringBuilder.AppendLine("    },");
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0");
		stringBuilder.AppendLine("-- FA source projectile: " + projectile.SourceProjectileId + "; units.scd SHA-256 C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26, projectiles.scd SHA-256 60D2732597CDE9EF046A663C8D439E60844F967147E14737C7AD5A08C641BE12.");
		if (projectile.SourceBlueprintSha256 != null)
		{
			stringBuilder.AppendLine("-- Source projectile blueprint SHA-256 " + projectile.SourceBlueprintSha256 + "; script SHA-256 " + projectile.SourceScriptSha256 + ".");
		}
		if (projectile.UnsupportedSourceFields != null)
		{
			stringBuilder.AppendLine("-- Unsupported source fields: " + projectile.UnsupportedSourceFields + ".");
		}
		stringBuilder.AppendLine("-- Compatibility VFX are explicit Sanctuary stand-ins; the weapon tables own source damage, cadence, range, and lifetime.");
		return stringBuilder.ToString();
	}

	private static string BuildStringList(IEnumerable<string> values)
	{
		return "{ " + string.Join(", ", values.Select((string value) => "\"" + value + "\"")) + " }";
	}

	private static string BuildMuzzleGroups(IReadOnlyList<string[]> muzzleGroups)
	{
		IEnumerable<string> values = muzzleGroups.Select((string[] group) => "{ muzzles = { " + string.Join(", ", group.Select((string muzzle) => "\"" + muzzle + "\"")) + " } }");
		return "{ " + string.Join(", ", values) + " }";
	}

	private static string BuildMuzzleMap(IReadOnlyList<string[]> muzzleGroups, string aimBone)
	{
		IEnumerable<string> values = from muzzle in muzzleGroups.SelectMany((string[] @group) => @group)
			select "[\"" + muzzle + "\"] = { aimController = \"" + aimBone + "\" }";
		return "{ " + string.Join(", ", values) + " }";
	}

	private static string LuaBoolean(bool value)
	{
		if (!value)
		{
			return "false";
		}
		return "true";
	}

	private static void QueueAppend(object cache, List<CacheMutation> mutations, string relativePath, string description, Action<string> validateStock, string appendix, Action<string> validatePatched, Func<string, string>? upgradeMarked = null)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (ContainsText(resourceText, "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0"))
		{
			string text = ((upgradeMarked == null) ? resourceText : upgradeMarked(resourceText));
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
			if (!ContainsText(resourceText2, "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0"))
			{
				throw new InvalidOperationException("The patched " + description + " did not retain its defensive-structure parity marker.");
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

	private static void QueueVirtualProjectile(object cache, List<CacheMutation> mutations, ProjectileSpec projectile)
	{
		string relativePath = ProjectileRelativePath(projectile.Id);
		string text = "Cybran projectile template " + projectile.Id;
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, text);
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (!ContainsText(resourceText, "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0"))
			{
				throw new InvalidOperationException("The reserved virtual projectile ID " + projectile.Id + " already exists without the defensive-structure parity marker.");
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

	private static void ValidateSpecs()
	{
		HashSet<string> hashSet = new HashSet<string>(StringComparer.Ordinal)
		{
			"ues1001", "ues1201", "ues2001", "ues2201", "ues3201", "ugs1001", "ugs1201", "ugs2001", "ugs2201", "ugs3201",
			"ugs3101"
		};
		HashSet<string> hashSet2 = new HashSet<string>(StringComparer.Ordinal)
		{
			"psu101", "psu121", "psu201", "psu221", "psu321", "pcg101", "pcg121", "pcg201", "pcg221", "pcg321",
			"pcg312"
		};
		if (WeaponSpecs.Length != hashSet.Count || !hashSet.SetEquals(WeaponSpecs.Select((WeaponSpec weapon) => weapon.TemplateId)))
		{
			throw new InvalidOperationException("Combat-structure defensive-parity template scope changed unexpectedly.");
		}
		if (ProjectileSpecs.Length != hashSet2.Count || !hashSet2.SetEquals(ProjectileSpecs.Select((ProjectileSpec projectile) => projectile.Id)))
		{
			throw new InvalidOperationException("Combat-structure defensive-parity projectile scope changed unexpectedly.");
		}
		if (WeaponSpecs.Select((WeaponSpec weapon) => weapon.ProjectileId).Distinct<string>(StringComparer.Ordinal).Count() != WeaponSpecs.Length || !hashSet2.SetEquals(WeaponSpecs.Select((WeaponSpec weapon) => weapon.ProjectileId)))
		{
			throw new InvalidOperationException("Every defensive structure must own one distinct source projectile template.");
		}
		WeaponSpec[] weaponSpecs = WeaponSpecs;
		foreach (WeaponSpec weaponSpec in weaponSpecs)
		{
			string b = (string.Equals(weaponSpec.TemplateId, "ugs2201", StringComparison.Ordinal) ? "3" : "-1");
			if (!string.Equals(weaponSpec.Aim.PoseResetTime, b, StringComparison.Ordinal))
			{
				throw new InvalidOperationException(weaponSpec.TemplateId + " has an unexpected weapon-pose reset contract.");
			}
			if (weaponSpec.MuzzleGroups.Count == 0 || weaponSpec.MuzzleGroups.Any((string[] group) => group.Length == 0) || weaponSpec.Stats.MuzzleSalvoSize <= 0 || weaponSpec.Stats.MuzzleSalvoSize > weaponSpec.MuzzleGroups.Count)
			{
				throw new InvalidOperationException(weaponSpec.TemplateId + " has an invalid muzzle-group/salvo contract.");
			}
			if (weaponSpec.Beam != null && weaponSpec.Stats.ProjectileLifetime != null)
			{
				throw new InvalidOperationException(weaponSpec.TemplateId + " is a beam and must not carry an invented projectile lifetime.");
			}
			if (weaponSpec.Beam == null && weaponSpec.Stats.ProjectileLifetime == null)
			{
				throw new InvalidOperationException(weaponSpec.TemplateId + " is a projectile weapon and requires an explicit source lifetime.");
			}
			ValidateWeaponOverride(BuildWeaponAppendix(weaponSpec), weaponSpec);
		}
		ProjectileSpec[] projectileSpecs = ProjectileSpecs;
		foreach (ProjectileSpec projectileSpec in projectileSpecs)
		{
			if (projectileSpec.SourceBlueprintSha256 == null != (projectileSpec.SourceScriptSha256 == null))
			{
				throw new InvalidOperationException(projectileSpec.Id + " must pin both projectile blueprint and script hashes together.");
			}
			ValidateProjectile(BuildProjectileSource(projectileSpec), projectileSpec);
		}
		ValidateHostLifecycle(HostLifecycleAppendix);
		ValidateImportScanner(ImportScannerAppendix);
		ValidateAvailability(AvailableUnitsAppendix);
	}

	private static void ValidateWeaponOverride(string source, WeaponSpec weapon)
	{
		WeaponStats stats = weapon.Stats;
		RequireTokens(source, "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0", "FA source: " + weapon.SourceUnitId + " / " + weapon.SourceProjectileId, "local sourceWeapon = UnitTemplate.weapons and UnitTemplate.weapons[1]", "aimBone = \"" + weapon.Aim.AimBone + "\"", "yawBone = \"" + weapon.Aim.YawBone + "\"", "pitchBone = \"" + weapon.Aim.PitchBone + "\"", "poseResetTime = " + weapon.Aim.PoseResetTime + ",", "sourceWeapon.damage = " + stats.Damage, "sourceWeapon.damageRadius = " + stats.DamageRadius, "sourceWeapon.muzzleSalvoDelay = " + stats.MuzzleSalvoDelay, $"sourceWeapon.muzzleSalvoSize = {stats.MuzzleSalvoSize}", "sourceWeapon.projectileTemplate = \"" + weapon.ProjectileId + "\"", "sourceWeapon.rangeMax = " + stats.RangeMax, "sourceWeapon.rangeMin = " + stats.RangeMin, "sourceWeapon.reloadTime = " + stats.ReloadTime, "sourceWeapon.targetWaterLimits = \"" + stats.TargetWaterLimits + "\"");
		RequireExactly(GetOwnedParityAppendix(source, weapon.TemplateId + " weapon template"), "poseResetTime = " + weapon.Aim.PoseResetTime + ",", 1, weapon.TemplateId + " pose reset");
		foreach (string item in weapon.MuzzleGroups.SelectMany((string[] group) => group))
		{
			RequireTokens(source, "\"" + item + "\"");
		}
		if (weapon.Beam == null)
		{
			RequireTokens(source, "sourceWeapon.beam = nil", "sourceWeapon.beamLifetime = nil");
			RequireTokens(source, "sourceWeapon.projectileLifetime = " + stats.ProjectileLifetime);
		}
		else
		{
			RequireTokens(source, "sourceWeapon.beamLifetime = " + weapon.Beam.LifetimeTicks, "sourceWeapon.beam = {", "BeamBasicLongSingle.sanmodel", "Beam ugs1201_01.sanmaterial");
		}
	}

	private static void ValidateProjectile(string source, ProjectileSpec projectile)
	{
		List<string> list = new List<string>
		{
			"-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0",
			"ProjectileTemplate =",
			"tpId = \"" + projectile.Id + "\"",
			"FA source projectile: " + projectile.SourceProjectileId
		};
		if (projectile.Trail != null)
		{
			list.Add("particleName = \"" + projectile.Trail + "\"");
		}
		if (projectile.Impact != null)
		{
			list.Add("particleName = \"" + projectile.Impact + "\"");
		}
		if (projectile.BeamEffect != null)
		{
			list.Add("beamEffectName = \"" + projectile.BeamEffect + "\"");
		}
		if (projectile.Movement != null)
		{
			list.AddRange(from line in NormalizeLineEndings(projectile.Movement).Split(new char[1] { '\n' })
				select line.Trim() into line
				where line.Length != 0
				select line);
		}
		if (projectile.SourceBlueprintSha256 != null)
		{
			list.Add("Source projectile blueprint SHA-256 " + projectile.SourceBlueprintSha256);
			list.Add("script SHA-256 " + projectile.SourceScriptSha256);
		}
		if (projectile.UnsupportedSourceFields != null)
		{
			list.Add("Unsupported source fields: " + projectile.UnsupportedSourceFields);
		}
		RequireTokens(source, list.ToArray());
	}

	private static bool RequiresBurstMasterPoseResetUpgrade(string source)
	{
		string ownedParityAppendix = GetOwnedParityAppendix(source, "UGS2201 weapon template");
		if (ContainsText(ownedParityAppendix, "poseResetTime = 3,"))
		{
			return false;
		}
		return ContainsText(ownedParityAppendix, "poseResetTime = -1,");
	}

	private static string UpgradeBurstMasterPoseReset(string source)
	{
		if (!RequiresBurstMasterPoseResetUpgrade(source))
		{
			return source;
		}
		return ReplaceOwnedParityAppendix(source, "poseResetTime = -1,", "poseResetTime = 3,", "legacy UGS2201 infinite pose reset");
	}

	private static bool RequiresSeraphimRadarLifecycleUpgrade(string source)
	{
		string ownedParityAppendix = GetOwnedParityAppendix(source, "FA combat host lifecycle");
		bool flag = ContainsText(ownedParityAppendix, "[\"uss1701\"] = true");
		bool flag2 = ContainsText(ownedParityAppendix, "[\"uss2701\"] = true");
		bool flag3 = ContainsText(ownedParityAppendix, "[\"uss3701\"] = true");
		if (flag && flag2 && flag3)
		{
			return false;
		}
		if (!flag && !flag2 && !flag3)
		{
			return true;
		}
		throw new InvalidOperationException("A partial Seraphim radar lifecycle gate was found; refusing an ambiguous in-place upgrade.");
	}

	private static string UpgradeSeraphimRadarLifecycle(string source)
	{
		if (!RequiresSeraphimRadarLifecycleUpgrade(source))
		{
			return source;
		}
		string text = "    [\"ues3701\"] = true,";
		string newValue = text + "\n    [\"uss1701\"] = true,\n    [\"uss2701\"] = true,\n    [\"uss3701\"] = true,";
		return ReplaceOwnedParityAppendix(source, text, newValue, "legacy radar lifecycle table anchor");
	}

	private static string ReplaceOwnedParityAppendix(string source, string oldValue, string newValue, string description)
	{
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0", StringComparison.Ordinal);
		string ownedParityAppendix = GetOwnedParityAppendix(source, description);
		RequireExactly(ownedParityAppendix, oldValue, 1, description);
		string text = ownedParityAppendix.Replace(oldValue, newValue);
		return source.Substring(0, num) + text + source.Substring(num + ownedParityAppendix.Length);
	}

	private static string GetOwnedParityAppendix(string source, string description)
	{
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException(description + " is missing the defensive-structure parity marker.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0".Length, StringComparison.Ordinal);
		if (num2 >= 0)
		{
			return source.Substring(num, num2 - num);
		}
		return source.Substring(num);
	}

	private static void ValidateImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0", 1, "Cybran defense scanner marker");
		string ownedImportScannerAppendix = GetOwnedImportScannerAppendix(source);
		RequireExactly(ownedImportScannerAppendix, "local SCO_CybranDefenseScanDir = ScanDir", 1, "scanner wrapper alias");
		RequireExactly(ownedImportScannerAppendix, "function ScanDir(directory)", 1, "scanner wrapper function");
		RequireExactly(ownedImportScannerAppendix, "local folders = SCO_CybranDefenseScanDir(directory)", 1, "previous-scanner call-through");
		RequireExactly(ownedImportScannerAppendix, "if directory ~= \"common/projectiles/projectilesTemplates/\" then", 1, "projectile-directory guard");
		RequireExactly(ownedImportScannerAppendix, "local knownFolders = {}", 1, "virtual-folder de-duplication table");
		RequireExactly(ownedImportScannerAppendix, "for _, folder in ipairs(folders) do", 1, "existing-folder scan");
		RequireExactly(ownedImportScannerAppendix, "for _, templateId in ipairs(cybranDefenseProjectiles) do", 1, "virtual-projectile scan");
		RequireExactly(ownedImportScannerAppendix, "local folder = directory .. templateId", 1, "virtual-folder path builder");
		RequireExactly(ownedImportScannerAppendix, "if not knownFolders[folder] then", 1, "virtual-folder membership gate");
		RequireExactly(ownedImportScannerAppendix, "table.insert(folders, folder)", 1, "virtual-folder insertion");
		RequireExactly(ownedImportScannerAppendix, "knownFolders[folder] = true", 2, "virtual-folder de-duplication writes");
		RequireExactly(ownedImportScannerAppendix, "return folders", 2, "scanner return paths");
		RequireTokensInOrder(ownedImportScannerAppendix, "local SCO_CybranDefenseScanDir = ScanDir", "function ScanDir(directory)", "local folders = SCO_CybranDefenseScanDir(directory)", "if directory ~= \"common/projectiles/projectilesTemplates/\" then", "return folders", "local knownFolders = {}", "for _, folder in ipairs(folders) do", "local cybranDefenseProjectiles = {", "for _, templateId in ipairs(cybranDefenseProjectiles) do", "local folder = directory .. templateId", "if not knownFolders[folder] then", "table.insert(folders, folder)", "knownFolders[folder] = true", "return folders");
		string[] projectileIds = ProjectileIds;
		foreach (string text in projectileIds)
		{
			RequireExactly(ownedImportScannerAppendix, "\"" + text + "\"", 1, "virtual projectile " + text);
		}
		if (!ownedImportScannerAppendix.TrimEnd(Array.Empty<char>()).EndsWith("end", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("Cybran defense projectile scanner must return the wrapped ScanDir function normally.");
		}
		if (ContainsText(ownedImportScannerAppendix, "scanRoot"))
		{
			throw new InvalidOperationException("Cybran defense projectile scanner must call the prior ScanDir with directory only.");
		}
	}

	private static bool RequiresImportScannerUpgrade(string source)
	{
		return ContainsText(GetOwnedImportScannerAppendix(source), "scanRoot");
	}

	private static string UpgradeImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0", 1, "Cybran defense scanner marker");
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0", StringComparison.Ordinal);
		string ownedImportScannerAppendix = GetOwnedImportScannerAppendix(source);
		string text = UpgradeScanDirWrapper(ownedImportScannerAppendix, "SCO_CybranDefenseScanDir");
		if (!string.Equals(ownedImportScannerAppendix, text, StringComparison.Ordinal))
		{
			return source.Substring(0, num) + text + source.Substring(num + ownedImportScannerAppendix.Length);
		}
		return source;
	}

	private static string GetOwnedImportScannerAppendix(string source)
	{
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Cybran defense projectile scanner marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0".Length, StringComparison.Ordinal);
		if (num2 >= 0)
		{
			return source.Substring(num, num2 - num);
		}
		return source.Substring(num);
	}

	private static string UpgradeScanDirWrapper(string appendix, string priorScanner)
	{
		if (!ContainsText(appendix, "scanRoot"))
		{
			return appendix;
		}
		string newValue = "local folders = " + priorScanner + "(directory)";
		string text = (ContainsText(appendix, "function ScanDir(scanRoot, directory)") ? "function ScanDir(scanRoot, directory)" : "function ScanDir(scanRoot,directory)");
		string text2 = (ContainsText(appendix, "local folders = " + priorScanner + "(scanRoot, directory)") ? ("local folders = " + priorScanner + "(scanRoot, directory)") : ("local folders = " + priorScanner + "(scanRoot,directory)"));
		RequireExactly(appendix, text, 1, "legacy Cybran defense scanner wrapper function");
		RequireExactly(appendix, text2, 1, "legacy Cybran defense prior-scanner call-through");
		return appendix.Replace(text, "function ScanDir(directory)").Replace(text2, newValue);
	}

	private static void ValidateHostLifecycle(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0", 1, "FA combat host lifecycle marker");
		RequireTokens(source, "local SCO_FaCombatHostUnit = HostUnit or Unit", "local SCO_FaCombatStockCheckProductionState = SCO_FaCombatHostUnit.CheckProductionState", "local SCO_FaCombatStockCheckRadarState = SCO_FaCombatHostUnit.CheckRadarState", "local SCO_FaCombatStockOnEnergyDown = SCO_FaCombatHostUnit.OnEnergyDown", "local SCO_FaCombatStockOnEnergyUp = SCO_FaCombatHostUnit.OnEnergyUp", "local SCO_FaCombatStockOnStopBeingBuilt = SCO_FaCombatHostUnit.OnStopBeingBuilt", "local SCO_FaCombatStockOnStartUpgrading = SCO_FaCombatHostUnit.OnStartUpgrading", "local SCO_FaCombatStockOnEndUpgrading = SCO_FaCombatHostUnit.OnEndUpgrading", "function SCO_FaCombatHostUnit:SCOApplyFaExtractorState()", "local active = self:IsCompleted()", "and self:GetProductionToggle()", "and not self.army.economy.isEnergyDown", "self.resourceEntities.production:SetEnabled(active)", "self:SetAnimatorEnabled(self:IsUpgrading() or active)", "function SCO_FaCombatHostUnit:CheckProductionState()", "SCO_FaCombatStockCheckProductionState(self)", "function SCO_FaCombatHostUnit:CheckRadarState()", "SCO_FaCombatStockCheckRadarState(self)", "self:SetRotatorsEnabled(self.radarDetector:GetEnabled())", "function SCO_FaCombatHostUnit:OnEnergyDown()", "SCO_FaCombatStockOnEnergyDown(self)", "function SCO_FaCombatHostUnit:OnEnergyUp()", "SCO_FaCombatStockOnEnergyUp(self)", "function SCO_FaCombatHostUnit:OnStopBeingBuilt()", "SCO_FaCombatStockOnStopBeingBuilt(self)", "function SCO_FaCombatHostUnit:OnStartUpgrading(targetUnit)", "return SCO_FaCombatStockOnStartUpgrading(self, targetUnit)", "function SCO_FaCombatHostUnit:OnEndUpgrading(targetUnit)", "local result = SCO_FaCombatStockOnEndUpgrading(self, targetUnit)");
		string[] array = new string[15]
		{
			"ugs1601", "ugs2601", "ugs3601", "ues1601", "ues2601", "ues3601", "ugs1701", "ugs2701", "ugs3701", "ues1701",
			"ues2701", "ues3701", "uss1701", "uss2701", "uss3701"
		};
		foreach (string text in array)
		{
			RequireExactly(source, "[\"" + text + "\"] = true", 1, text + " lifecycle gate");
		}
		RequireExactly(source, "function SCO_FaCombatHostUnit:CheckProductionState()", 1, "extractor production wrapper");
		RequireExactly(source, "function SCO_FaCombatHostUnit:CheckRadarState()", 1, "radar-state wrapper");
		RequireExactly(source, "function SCO_FaCombatHostUnit:OnStopBeingBuilt()", 1, "construction-completion wrapper");
	}

	private static void ValidateAvailability(string source)
	{
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("UGS3201 availability is missing the Cybran defensive-parity appendix.");
		}
		string source2 = source.Substring(num);
		RequireTokens(source2, "-- This is a roster-loader gate only.", "builder eligibility; this patch does not create a factory rule or canBuild", "AvailableUnits[\"ugs3201\"] = true");
		RequireExactly(source2, "AvailableUnits[\"ugs3201\"] = true", 1, "UGS3201 roster enablement");
	}

	private static void RequireTokensInOrder(string source, params string[] requiredTokens)
	{
		int startIndex = 0;
		foreach (string text in requiredTokens)
		{
			int num = source.IndexOf(text, startIndex, StringComparison.Ordinal);
			if (num < 0)
			{
				throw new InvalidOperationException("Expected cached Lua source to contain '" + text + "' in order.");
			}
			startIndex = num + text.Length;
		}
	}

	private static void RequireExactly(string source, string token, int expectedCount, string description)
	{
		int num = CountText(source, token);
		if (num != expectedCount)
		{
			throw new InvalidOperationException($"Expected {description} to occur {expectedCount} time(s), but found {num}.");
		}
	}

	private static int CountText(string source, string token)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(token, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += token.Length;
		}
		return num;
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

	private static bool ContainsText(string source, string token)
	{
		return source.IndexOf(token, StringComparison.Ordinal) >= 0;
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
					throw new InvalidOperationException("More than one cached resource matches the exact " + relativePath + " suffix.");
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

	private static string ProjectileRelativePath(string projectileId)
	{
		return "LJ/lua/common/projectiles/projectilesTemplates/" + projectileId + "/" + projectileId + ".santp";
	}

	private static object AppendOverride(object stockResource, string appendix)
	{
		Type type = stockResource.GetType();
		return NativeArrayByteFactory.CreatePersistent(type, GetNativeArrayBytes(type, stockResource), Encoding.UTF8.GetBytes(appendix));
	}

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, Encoding.UTF8.GetBytes(source));
	}

	private static string GetResourceText(object resource)
	{
		EnsureNativeArray(resource, "Lua cache resource");
		return Encoding.UTF8.GetString(GetNativeArrayBytes(resource.GetType(), resource));
	}

	private static string NormalizeLineEndings(string source)
	{
		return source.Replace("\r\n", "\n").Replace("\r", "\n");
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

	private static bool ContainsMarker(object resource)
	{
		if (IsNativeArrayCreated(resource))
		{
			return ContainsText(GetResourceText(resource), "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0");
		}
		return false;
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
			if (CanDisposeReplacement(cache, item))
			{
				TryDisposeNativeArray(item.Replacement.GetType(), item.Replacement, "replacement " + item.Description);
			}
			else
			{
				Log("Preserved replacement " + item.Description + " because rollback could not prove that the cache detached it.");
			}
		}
	}

	private static bool CanDisposeReplacement(object cache, CacheMutation mutation)
	{
		try
		{
			CacheResource cacheResource = TryGetCachedResource(cache, mutation.Path, mutation.Description);
			return cacheResource == null || !ContainsMarker(cacheResource.Stock);
		}
		catch (Exception ex)
		{
			Log("Could not verify rollback ownership for " + mutation.Description + "; retaining its replacement: " + ex);
			return false;
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
		string text = "[Cybran Defensive Parity] " + message;
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
}
