using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using ScomDeterministicLua;
using SupremeCommanderOverhaul.Shared;

namespace FaAirBomberCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class BomberSpec
	{
		public string TargetId { get; }

		public string SourceId { get; }

		public string SourceBlueprintSha256 { get; }

		public string SourceScriptPath { get; }

		public string SourceScriptSha256 { get; }

		public string FactionCategory { get; }

		public string FactionTag { get; }

		public string ExpectedClassOwner { get; }

		public string ExpectedUnitClass { get; }

		public string Name { get; }

		public int Tier { get; }

		public int Health { get; }

		public double MassCost { get; }

		public double EnergyCost { get; }

		public double BuildTime { get; }

		public double VisionRadius { get; }

		public double? RadarRadius { get; }

		public double? SonarRadius { get; }

		public double CollisionX { get; }

		public double CollisionY { get; }

		public double CollisionZ { get; }

		public double CollisionOffsetY { get; }

		public double CollisionOffsetZ { get; }

		public double SelectionX { get; }

		public double SelectionZ { get; }

		public double SelectionThickness { get; }

		public double Elevation { get; }

		public double? AttackElevation { get; }

		public double MaxAirspeed { get; }

		public double MinAirspeed { get; }

		public double BreakOffDistance { get; }

		public double KMoveDamping { get; }

		public double? TightTurnMultiplier { get; }

		public double FuelUseTime { get; }

		public bool IsUef => string.Equals(FactionTag, "EDA", StringComparison.Ordinal);

		public bool IsTorpedo => Tier == 2;

		public bool HasAntiAir => Tier == 3;

		public string SourceBlueprintPath => "units/" + SourceId + "/" + SourceId + "_unit.bp";

		public string RelativePath => "LJ/lua/common/units/unitsTemplates/" + TargetId + "/" + TargetId + ".santp";

		public string Description => TargetId + " <- " + SourceId + " bomber template";

		public BomberSpec(string targetId, string sourceId, string sourceBlueprintSha256, string sourceScriptPath, string sourceScriptSha256, string factionCategory, string factionTag, string expectedClassOwner, string expectedUnitClass, string name, int tier, int health, double massCost, double energyCost, double buildTime, double visionRadius, double? radarRadius, double? sonarRadius, double collisionX, double collisionY, double collisionZ, double collisionOffsetY, double collisionOffsetZ, double selectionX, double selectionZ, double selectionThickness, double elevation, double? attackElevation, double maxAirspeed, double minAirspeed, double breakOffDistance, double kMoveDamping, double? tightTurnMultiplier, double fuelUseTime)
		{
			TargetId = targetId;
			SourceId = sourceId;
			SourceBlueprintSha256 = sourceBlueprintSha256;
			SourceScriptPath = sourceScriptPath;
			SourceScriptSha256 = sourceScriptSha256;
			FactionCategory = factionCategory;
			FactionTag = factionTag;
			ExpectedClassOwner = expectedClassOwner;
			ExpectedUnitClass = expectedUnitClass;
			Name = name;
			Tier = tier;
			Health = health;
			MassCost = massCost;
			EnergyCost = energyCost;
			BuildTime = buildTime;
			VisionRadius = visionRadius;
			RadarRadius = radarRadius;
			SonarRadius = sonarRadius;
			CollisionX = collisionX;
			CollisionY = collisionY;
			CollisionZ = collisionZ;
			CollisionOffsetY = collisionOffsetY;
			CollisionOffsetZ = collisionOffsetZ;
			SelectionX = selectionX;
			SelectionZ = selectionZ;
			SelectionThickness = selectionThickness;
			Elevation = elevation;
			AttackElevation = attackElevation;
			MaxAirspeed = maxAirspeed;
			MinAirspeed = minAirspeed;
			BreakOffDistance = breakOffDistance;
			KMoveDamping = kMoveDamping;
			TightTurnMultiplier = tightTurnMultiplier;
			FuelUseTime = fuelUseTime;
		}
	}

	private sealed class ProjectileSpec
	{
		public string Id { get; }

		public string Name { get; }

		public string SourceId { get; }

		public string SourceBlueprintSha256 { get; }

		public string SourceScriptSha256 { get; }

		public string ImpactVfx { get; }

		public string TrailVfx { get; }

		public bool Torpedo { get; }

		public double SpeedMax { get; }

		public double Acceleration { get; }

		public double RotationSpeed { get; }

		public double Lifetime { get; }

		public string SourceBlueprintPath => "projectiles/" + SourceId + "/" + SourceId + "_proj.bp";

		public string SourceScriptPath => "projectiles/" + SourceId + "/" + SourceId + "_script.lua";

		public ProjectileSpec(string id, string name, string sourceId, string sourceBlueprintSha256, string sourceScriptSha256, string impactVfx, string trailVfx, bool torpedo, double speedMax, double acceleration, double rotationSpeed, double lifetime)
		{
			Id = id;
			Name = name;
			SourceId = sourceId;
			SourceBlueprintSha256 = sourceBlueprintSha256;
			SourceScriptSha256 = sourceScriptSha256;
			ImpactVfx = impactVfx;
			TrailVfx = trailVfx;
			Torpedo = torpedo;
			SpeedMax = speedMax;
			Acceleration = acceleration;
			RotationSpeed = rotationSpeed;
			Lifetime = lifetime;
		}
	}

	private sealed class SurfaceBomberSpec
	{
		public string TargetId { get; }

		public string SourceId { get; }

		public string SourceBlueprintSha256 { get; }

		public string SourceScriptPath { get; }

		public string SourceScriptSha256 { get; }

		public int WeaponIndex { get; }

		public string MuzzleBone { get; }

		public string ProjectileId { get; }

		public string SourceProjectileId { get; }

		public double Damage { get; }

		public double DamageRadius { get; }

		public double RangeMax { get; }

		public double ReloadTime { get; }

		public double ProjectileLifetime { get; }

		public double BombDropThreshold { get; }

		public int PredictAhead { get; }

		public double BreakOffDistance { get; }

		public double BreakOffTrigger { get; }

		public double SourceMaxAirspeed { get; }

		public double SourceMinAirspeed { get; }

		public double FiringRandomness { get; }

		public double TrackingRadius { get; }

		public string SourceBlueprintPath => "units/" + SourceId + "/" + SourceId + "_unit.bp";

		public string RelativePath => "LJ/lua/common/units/unitsTemplates/" + TargetId + "/" + TargetId + ".santp";

		public string Description => TargetId + " <- " + SourceId + " FA surface-bomber contract";

		public SurfaceBomberSpec(string targetId, string sourceId, string sourceBlueprintSha256, string sourceScriptPath, string sourceScriptSha256, int weaponIndex, string muzzleBone, string projectileId, string sourceProjectileId, double damage, double damageRadius, double rangeMax, double reloadTime, double projectileLifetime, double bombDropThreshold, int predictAhead, double breakOffDistance, double breakOffTrigger, double sourceMaxAirspeed, double sourceMinAirspeed, double firingRandomness, double trackingRadius)
		{
			TargetId = targetId;
			SourceId = sourceId;
			SourceBlueprintSha256 = sourceBlueprintSha256;
			SourceScriptPath = sourceScriptPath;
			SourceScriptSha256 = sourceScriptSha256;
			WeaponIndex = weaponIndex;
			MuzzleBone = muzzleBone;
			ProjectileId = projectileId;
			SourceProjectileId = sourceProjectileId;
			Damage = damage;
			DamageRadius = damageRadius;
			RangeMax = rangeMax;
			ReloadTime = reloadTime;
			ProjectileLifetime = projectileLifetime;
			BombDropThreshold = bombDropThreshold;
			PredictAhead = predictAhead;
			BreakOffDistance = breakOffDistance;
			BreakOffTrigger = breakOffTrigger;
			SourceMaxAirspeed = sourceMaxAirspeed;
			SourceMinAirspeed = sourceMinAirspeed;
			FiringRandomness = firingRandomness;
			TrackingRadius = trackingRadius;
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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0";

	internal const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	internal const string SourceProjectileArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12";

	private const string ImportRelativePath = "LJ/lua/common/systems/import.lua";

	private const string HostCollisionRelativePath = "LJ/lua/host/collisionUpdate.lua";

	private const string HostWeaponsRelativePath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string HostAirUnitsRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefault.lua";

	private const string HostCollisionReturnAnchor = "return {\n    CollisionUpdate = CollisionUpdate,";

	private const string HostWeaponsFiringRotationStock = "local firingRotation = ApplyFiringRandomness(muzzleRotation, self.tp.firingRandomness or 1.0)\n                    local _, projectileID = Engine.InstantiatePrefab(projectilePrefabID, muzzlePosition, EngineClasses.float3(1.0, 1.0, 1.0), firingRotation)";

	private const string HostWeaponsFiringRotationReplacement = "local launchRotation = muzzleRotation\n                    if self.tp.scoFaBombDrop ~= nil then\n                        launchRotation = SCO_FaBomberCarrierFiringRotation(\n                            self,\n                            muzzleRotation)\n                    end\n                    local firingRotation = ApplyFiringRandomness(\n                        launchRotation,\n                        self.tp.firingRandomness or 1.0)\n                    local _, projectileID = Engine.InstantiatePrefab(projectilePrefabID, muzzlePosition, EngineClasses.float3(1.0, 1.0, 1.0), firingRotation)\n                    if self.tp.scoFaBombDrop ~= nil\n                        and type(self.unit.SCO_FaBomberOnBombReleased) == \"function\"\n                    then\n                        self.unit:SCO_FaBomberOnBombReleased(projectileID)\n                    end";

	private const string ProjectileRootRelativePath = "LJ/lua/common/projectiles/projectilesTemplates";

	private const string ScorcherFireVfx = "VFX/SupremeCommanderOverhaul/Bombers/scorcher_napalm_ground_fire.sanvfx";

	private static readonly BomberSpec[] BomberSpecs = new BomberSpec[6]
	{
		new BomberSpec("uea1001", "UEA0103", "2542a2987caa5f1dff73f78aef19717370e94f56347ffd4aa408c2508360e4c6", "units/UEA0103/UEA0103_Script.lua", "65ce7bbd1be553e5328edd2915024882e8a696f823a4a511526babdc81ff94a7", "UEF", "EDA", "unitsDefaultEDA", "EDAAirUnit", "Scorcher", 1, 215, 80.0, 1400.0, 400.0, 32.0, 65.0, null, 1.2, 0.3, 1.0, 0.0, 0.0, 0.8, 0.7, 0.54, 18.0, null, 10.0, 10.0, 18.0, 2.0, 0.0, 400.0),
		new BomberSpec("uea2301", "UEA0204", "62ecc2982777d399eecded2debc18fda33fe288fcd88980453a27fca7f7eebcd", "units/UEA0204/UEA0204_script.lua", "6430a68b6094a6262edc2ba6ef1dc09d52c6e322d912a8f51514d731f3572786", "UEF", "EDA", "unitsDefaultEDA", "EDAAirUnit", "Stork", 2, 860, 240.0, 4800.0, 1600.0, 32.0, null, 90.0, 1.0, 0.5, 1.0, -0.2, -0.1, 1.1, 0.6, 0.4, 18.0, 4.0, 15.0, 13.0, 34.0, 2.0, 0.0, 600.0),
		new BomberSpec("uea3001", "UEA0304", "5b04162f30361bbfec13f34b6ba6c0af776fa266076606c66a054cf1f5b7613f", "units/UEA0304/UEA0304_Script.lua", "74135e5032aebcc1b4e8bb0dc129bdf47772ea3e1ee4e510dcedd0d9ff1f76a0", "UEF", "EDA", "unitsDefaultEDA", "EDAAirUnit", "Ambassador", 3, 4000, 2100.0, 105000.0, 8400.0, 32.0, 65.0, null, 2.0, 0.5, 1.6, 0.0, 0.0, 1.2, 1.0, 0.38, 20.0, null, 17.0, 15.0, 60.0, 2.0, 0.0, 1500.0),
		new BomberSpec("uga1001", "URA0103", "f720f101b4ba128c813fd64d6128718c88e4a8e3cdcf0d07d77fac2cfa09a7cf", "units/URA0103/URA0103_Script.lua", "b927ec462264e1681f8f3496ce0d04053469180e66ceb4d862613f69a75e741c", "CYBRAN", "GUARD", "unitsDefaultGuard", "GuardAirUnit", "Zeus", 1, 200, 80.0, 1400.0, 400.0, 32.0, 65.0, null, 1.5, 0.2, 1.0, 0.0, 0.0, 1.1, 0.6, 0.37, 18.0, null, 10.0, 10.0, 30.0, 2.0, 0.0, 400.0),
		new BomberSpec("uga2301", "URA0204", "930e5a4a708b9bfa9454736420e4ca1a6bd1e9500c74f09028e33a2fbd9b6549", "units/URA0204/URA0204_script.lua", "b6ddee669c6bbe0a612125c45239ddeb91c682a286f824fecc45566be5f86651", "CYBRAN", "GUARD", "unitsDefaultGuard", "GuardAirUnit", "Cormorant", 2, 800, 240.0, 4800.0, 1600.0, 32.0, null, 90.0, 1.0, 0.5, 1.0, -0.2, 0.0, 0.9, 1.0, 0.44, 18.0, 4.0, 15.0, 13.0, 34.0, 1.0, null, 600.0),
		new BomberSpec("uga3001", "URA0304", "ef3981b71c36609efe3ba32cf05dbd66b3bdced7e44924cfcb3d9de1bdaa4f46", "units/URA0304/URA0304_Script.lua", "1f9f233ee34089ce6102cf1f729793a6d8938c4c43631d2295d9c5af7ed6649c", "CYBRAN", "GUARD", "unitsDefaultGuard", "GuardAirUnit", "Revenant", 3, 3700, 2100.0, 105000.0, 8400.0, 32.0, 65.0, null, 2.0, 0.5, 1.5, 0.0, 0.0, 1.6, 1.2, 0.43, 20.0, null, 17.0, 15.0, 60.0, 2.0, 0.0, 1000.0)
	};

	private static readonly SurfaceBomberSpec[] SurfaceBomberSpecs = new SurfaceBomberSpec[6]
	{
		new SurfaceBomberSpec("uca1001", "UAA0103", "c6d9d7169db4e2f2e49f85ce71c20181f6cc0be50e9b36b4064932a59053530e", "units/UAA0103/UAA0103_Script.lua", "62959bc318524975b2ecdcd86461bb4b280fa14f3192624ce96f8725767baf4a", 1, "Right_Projectile", "pab101", "AIFBombGraviton01", 200.0, 4.0, 40.0, 2.0, 3.0, 1.5, 3, 30.0, 20.0, 10.0, 10.0, 0.0, 1.25),
		new SurfaceBomberSpec("uca3001", "UAA0304", "915bd856451b093319ffad7cb2cf988cec9df8b53a959edaefbfb9a69c1a062c", "units/UAA0304/UAA0304_Script.lua", "fdaa62c52dd2848546047c18791af918a15f346260491329d0dfe14ab2e2fed6", 1, "Muzzle", "pab301", "AIFBombQuark01", 3450.0, 4.0, 90.0, 5.0, 8.0, 3.5, 3, 60.0, 30.0, 17.0, 15.0, 0.0, 1.15),
		new SurfaceBomberSpec("usa1001", "XSA0103", "d23ca7e7cd8e1c17985fe9ab418ec458f6559201af1870ba67a08392ee667a2d", "units/XSA0103/XSA0103_Script.lua", "47e2e0b17df35f9824fe944a4cc45b3013e2045ce31355ecffe66a383be500a3", 1, "Center_Projectile", "psb101", "SBOOtheTacticalBomb01", 250.0, 4.0, 40.0, 2.0, 3.0, 3.0, 3, 30.0, 20.0, 10.0, 10.0, 0.0, 1.25),
		new SurfaceBomberSpec("usa2101", "XSA0202", "b0e15d543fdd34b0ecf3521380f41a5c0b4ef0a628b9677b2a84bf4e0a44d1dc", "units/XSA0202/XSA0202_Script.lua", "d63f137391f722128f62f799cba71308854ee86daef792864c33623d89119f9d", 3, "Bomb_Muzzle", "psb202", "SBOOtheTacticalBomb02", 1175.0, 3.0, 40.0, 10.0, 8.0, 2.0, 3, 40.0, 20.0, 15.0, 10.0, 0.0, 1.0),
		new SurfaceBomberSpec("usa3001", "XSA0304", "8890281d908a9f0e996de289731718516b281a22e16b80e6ea99acb4dbb8039d", "units/XSA0304/XSA0304_Script.lua", "00e68ca7dc39ffe01762e30a94422bd41614539ab1e39a2c705c3d083fecd55e", 1, "Center_Projectile", "psb301", "SBOZhanaseeBomb01", 3250.0, 5.0, 90.0, 5.0, 8.0, 3.5, 3, 60.0, 30.0, 17.0, 15.0, 0.0, 1.15),
		new SurfaceBomberSpec("usa4011", "XSA0402", "19ad26d88df8e9b1e7ae5fbfd680e266d935659a843dea3c6931325b81e799c5", "units/XSA0402/XSA0402_script.lua", "cc5ed04e75391ddab44ec20826b6e78ad26ab926df8fe138a36e25e4ea0e9354", 1, "Center_Muzzle", "psb402", "SBOOhwalliStrategicBomb01", 11000.0, 20.0, 90.0, 10.0, 8.0, 4.0, 2, 60.0, 30.0, 20.0, 18.0, 3.0, 1.15)
	};

	private static readonly ProjectileSpec[] ProjectileSpecs = new ProjectileSpec[13]
	{
		new ProjectileSpec("pab101", "Aeon_Shimmer_Graviton_Bomb", "AIFBombGraviton01", "cdc00f032be9fea0ac4c6b9f5738b9f705052a05badfec72a45771f84f0f4c44", "ec40f79950401890363a06bcc1ade8e59ffb415cbe3b9831641db7e72d3f356b", "VFX/Impact/vci1101_cannon_plasma_small_impact.sanvfx", "VFX/Trails/vct1201_cannon_plasma_medium_trail.sanvfx", torpedo: false, 40.0, 0.0, 0.0, 3.0),
		new ProjectileSpec("pab301", "Aeon_Shocker_Quark_Bomb", "AIFBombQuark01", "418285aaae897c7e47d2ac191105a27082950de3dddb663de2a49004776f8ba3", "7ee67db187f1009c76785e983479240a0bc90eeffff44dd57cb0762fce15de50", "VFX/Impact/vci1441_cannon_artillery_huge_impact.sanvfx", "VFX/Trails/vct1201_cannon_plasma_medium_trail.sanvfx", torpedo: false, 20.0, 0.0, 0.0, 8.0),
		new ProjectileSpec("peb101", "UEF_Scorcher_Napalm_Carpet_Bomb", "TIFNapalmCarpetBomb01", "58a4511cb4d575f5f8b96dd51be654b4b4662ec67fdfa05ad139c70322680954", "fb52ef413bec3ed05de3e92641259cd89b1e595932f327ba65aa67b922961b25", "VFX/SupremeCommanderOverhaul/Bombers/scorcher_napalm_ground_fire.sanvfx", "VFX/Trails/TrailGeneric_01.sanvfx", torpedo: false, 20.0, 0.0, 360.0, 8.0),
		new ProjectileSpec("peb231", "UEF_Stork_Angler_Torpedo", "TANAnglerTorpedo06", "55e293247e1e0c3675563582954ccbc5b0eee894475abb09eeba0fb4bc90971b", "d35c124b1be07811a2acf7436ebb1ba9b95017b19bd3d22bf0ca8125fbef8dac", "VFX/Impact/vei3301_missile_antiair_large_impact.sanvfx", "VFX/Trails/vet3301_missile_antiair_large_trail.sanvfx", torpedo: true, 18.0, 4.0, 240.0, 20.0),
		new ProjectileSpec("peb301", "UEF_Ambassador_Small_Yield_Nuclear_Bomb", "TIFSmallYieldNuclearBomb01", "808c092a0d3f6fe101050af17f22705fa7a72cdf96842a7962200efc8fc5d36a", "d9c88f50f05988fc6e7565135c8b76515220f83250481a2fa2a4dbd958613a77", "VFX/Impact/vei8301_bomb_large_impact.sanvfx", "VFX/Trails/TrailGeneric_01.sanvfx", torpedo: false, 20.0, 0.0, 360.0, 8.0),
		new ProjectileSpec("pgb101", "Cybran_Zeus_Neutron_Cluster_Bomb", "CIFNeutronClusterBomb01", "d8d893a306a94ef13e6b660c72a2f8023598f7fba27752ecc21c88da9e8ed399", "39740ef89c603eb5b01989afdefd2f0c9745f8b227b056c24a5d7502af326875", "VFX/Death/vgd1301_death_land_large.sanvfx", "VFX/Trails/TrailGeneric_01.sanvfx", torpedo: false, 25.0, 0.0, 30.0, 8.0),
		new ProjectileSpec("pgb231", "Cybran_Cormorant_Nanite_Torpedo", "CANTorpedoNanite03", "07cabdfb78f90b37c86ed7bc45a8b795f221425ed36a13f2cd1d8092790e90f7", "de8af2f4a66f566dc2463030c02661977f9f033bb73c7593373f922f8a114ab6", "VFX/Impact/vgi1741_grenade_medium_impact.sanvfx", "VFX/Trails/vgt1741_grenade_medium_trail.sanvfx", torpedo: true, 14.0, 0.0, 240.0, 20.0),
		new ProjectileSpec("pgb301", "Cybran_Revenant_Proton_Bomb", "CIFProtonBomb01", "8cce9628c7c2af978337c8ff38a0f6aee6be00bc1db49cf83132472205d30a89", "f6ec5c492cb0dc5bead4b07c6b8dd679b930f98d9749b0e3bb7a760522b91a7c", "VFX/Death/vgd1301_death_land_large.sanvfx", "VFX/Trails/TrailGeneric_01.sanvfx", torpedo: false, 20.0, 0.0, 0.0, 8.0),
		new ProjectileSpec("pgb302", "Cybran_Revenant_Electron_Autocannon", "CAAAutocannon01", "0460b42285f54f1b3cd041b431805ab8a0d54c1d6246c0ba26d6980156f19152", "7aaff4e111849bbf457f95985bd862fd91fc2f8be82f4719cb757c3091cb0975", "VFX/Impact/vgi1121_autocannon_plasma_small_impact.sanvfx", "VFX/Trails/vgt1121_autocannon_plasma_small_trail.sanvfx", torpedo: false, 35.0, 0.0, 0.0, 1.5),
		new ProjectileSpec("psb101", "Seraphim_Sinnve_Othe_Tactical_Bomb", "SBOOtheTacticalBomb01", "157076800c4a9cbb2c970ecd89065ba2d42304d0f5f6b23fd5765917fbf6a30b", "4a3d936e2ca311d20071945ce500c56154a1d3e097ffbf35aa38081f1c02cdc1", "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx", "VFX/Trails/TrailGeneric_01.sanvfx", torpedo: false, 40.0, 0.0, 0.0, 3.0),
		new ProjectileSpec("psb202", "Seraphim_Notha_Othe_Tactical_Bomb", "SBOOtheTacticalBomb02", "1f96bc42cae307c9e116b960e7dc8f0955baf831f17ac1409b91796e1fc4c5cb", "601d17860a124be6a0acbe6be5cb331ca5d54a6a04c57f09399b7d9c308a5dbe", "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx", "VFX/Trails/TrailGeneric_01.sanvfx", torpedo: false, 20.0, 0.0, 30.0, 8.0),
		new ProjectileSpec("psb301", "Seraphim_Sinntha_Zhanasee_Strategic_Bomb", "SBOZhanaseeBomb01", "ca131429be3e508d043617e3fc522e6381eb579f6dc3c53dd70ccbd13a5e2428", "a13dd7da0abeba1921d111adb8430cd065babe4e7ba1023fb10bd776a17b3382", "VFX/Death/vcd1301_death_land_large.sanvfx", "VFX/Trails/TrailGeneric_01.sanvfx", torpedo: false, 20.0, 0.0, 0.0, 8.0),
		new ProjectileSpec("psb402", "Seraphim_Ahwassa_Ohwalli_Strategic_Bomb", "SBOOhwalliStrategicBomb01", "20609138dea5be8fef07140aacb1dbf240c85f679c1433329b5f46f7604f1c47", "b83acef1689a917ee98cac7c83991b83001fcc33f9d8d9d176872bf84787ca67", "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx", "VFX/SCOM/FieldFixes/Ahwassa/ahwassa_strategic_bomb_6x.sanvfx", torpedo: false, 20.0, 0.0, 0.0, 8.0)
	};

	private static readonly string ImportScannerAppendix = "\n-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0\n-- These private projectile templates exist only in FilesCache. Chain the\n-- earlier scanner and publish each reviewed logical folder once.\nlocal SCO_FaAirBomberScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_FaAirBomberScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n\n    local bomberFolders = {\n        directory .. \"pab101\",\n        directory .. \"pab301\",\n        directory .. \"peb101\",\n        directory .. \"peb231\",\n        directory .. \"peb301\",\n        directory .. \"pgb101\",\n        directory .. \"pgb231\",\n        directory .. \"pgb301\",\n        directory .. \"pgb302\",\n        directory .. \"psb101\",\n        directory .. \"psb202\",\n        directory .. \"psb301\",\n        directory .. \"psb402\",\n    }\n    for _, bomberFolder in ipairs(bomberFolders) do\n        local found = false\n        for _, folder in ipairs(folders) do\n            if folder == bomberFolder then\n                found = true\n                break\n            end\n        end\n        if not found then\n            table.insert(folders, bomberFolder)\n        end\n    end\n    return folders\nend";

	private static readonly string HostCollisionAppendix = "\n-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0\n-- Sanctuary exposes damage-over-time fields to templates and AI, but its\n-- stock projectile collision path applies only the direct damage value and\n-- hardcodes friendly area damage off. Restore source friendly-area damage\n-- for all ten private surface bombs and UEA0103's 15 x 4 area pulses at\n-- one 10-Hz simulation tick apart. Stock collision still owns impact\n-- classification, projectile destruction, and the client impact event.\n-- XSA0402's DestroyOnWater bomb is culled before stock collision dispatch,\n-- so even a one-tick shallow-water crossing cannot damage the seabed. Its\n-- separately source-authored DeathImpact area damage is applied once when\n-- the aircraft wreck first reaches water or stock reports terrain impact.\nlocal SCO_FaBomberGroundFireEnvironment =\n    type(getfenv) == \"function\" and getfenv(1) or _ENV\nlocal SCO_FaBomberGroundFireInstalled = rawget(\n    SCO_FaBomberGroundFireEnvironment,\n    \"SCO_FaBomberGroundFireInstalled\")\nif SCO_FaBomberGroundFireInstalled ~= nil\n    and SCO_FaBomberGroundFireInstalled ~= \"1.1.0\"\nthen\n    error(\"Unsupported SCOM Scorcher ground-fire runtime \"\n        .. tostring(SCO_FaBomberGroundFireInstalled))\nend\nif SCO_FaBomberGroundFireInstalled == nil then\n    if type(CollisionUpdate) ~= \"function\"\n        or type(ProcessRayCollisionEvent) ~= \"function\"\n        or type(ProcessAreaDamage) ~= \"function\"\n        or type(DestroyProjectile) ~= \"function\"\n        or type(NewThread) ~= \"function\"\n        or type(WaitTicks) ~= \"function\"\n        or type(Engine.GetGlobalEntityWorldPosition) ~= \"function\"\n        or type(Engine.HasWater) ~= \"function\"\n        or type(Engine.GetWaterLevel) ~= \"function\"\n        or type(Engine.SampleTerrainHeight) ~= \"function\"\n    then\n        error(\"SCOM Scorcher ground-fire runtime cannot resolve collision functions\")\n    end\n\n    local SCO_FaBomberStockCollisionUpdate = CollisionUpdate\n    local SCO_FaBomberStockRayCollision = ProcessRayCollisionEvent\n    local SCO_FaBomberStockWaterCollision = ProcessWaterCollisionEvent\n    local SCO_FaBomberStockAreaDamage = ProcessAreaDamage\n    local SCO_FaBomberActiveProjectile = nil\n\n    local SCO_FaBomberImpactProfiles = {\n        pab101 = { damage = 200, radius = 4, damageFriendly = true },\n        pab301 = { damage = 3450, radius = 4, damageFriendly = true },\n        peb101 = { damage = 60, radius = 2.5, damageFriendly = false },\n        peb301 = { damage = 3000, radius = 6, damageFriendly = true },\n        pgb101 = { damage = 50, radius = 3, damageFriendly = true },\n        pgb301 = { damage = 2750, radius = 7, damageFriendly = true },\n        psb101 = { damage = 250, radius = 4, damageFriendly = true },\n        psb202 = { damage = 1175, radius = 3, damageFriendly = true },\n        psb301 = { damage = 3250, radius = 5, damageFriendly = true },\n        psb402 = { damage = 11000, radius = 20, damageFriendly = true },\n    }\n    local SCO_FaBomberDestroyOnWaterProfiles = {\n        pab101 = { sourceId = \"AIFBombGraviton01\" },\n        pab301 = { sourceId = \"AIFBombQuark01\" },\n        psb101 = { sourceId = \"SBOOtheTacticalBomb01\" },\n        psb202 = { sourceId = \"SBOOtheTacticalBomb02\" },\n        psb301 = { sourceId = \"SBOZhanaseeBomb01\" },\n        psb402 = { sourceId = \"SBOOhwalliStrategicBomb01\" },\n    }\n    local SCO_FaBomberCrashImpactProfiles = {\n        XSA0402 = { damage = 10000, radius = 8 },\n    }\n\n    local function SCO_FaBomberImpactContract(projectile)\n        local additions = projectile and projectile.tp\n            and projectile.tp.additions\n        local contract = additions and additions.scoFaBomberImpact\n        if contract == nil then return nil end\n        local profile = SCO_FaBomberImpactProfiles[\n            contract.runtimeProjectileId]\n        if profile == nil\n            or contract.version ~= \"1.0.0\"\n            or contract.damageFriendly ~= profile.damageFriendly\n            or projectile.damage ~= profile.damage\n            or projectile.damageRadius ~= profile.radius\n        then\n            error(\"Malformed SCOM FA bomber impact contract\")\n        end\n        return contract\n    end\n\n    local function SCO_FaBomberDestroyOnWaterContract(projectile)\n        local additions = projectile and projectile.tp\n            and projectile.tp.additions\n        local contract = additions and additions.scoFaDestroyOnWater\n        if contract == nil then return nil end\n        local profile = SCO_FaBomberDestroyOnWaterProfiles[\n            contract.runtimeProjectileId]\n        if profile == nil\n            or contract.version ~= \"1.0.0\"\n            or contract.sourceId ~= profile.sourceId\n            or contract.sourceDestroyOnWater ~= true\n            or contract.runtimeMode\n                ~= \"HostPreCollisionWaterlineCull\"\n            or projectile.tp.general == nil\n            or projectile.tp.general.tpId\n                ~= contract.runtimeProjectileId\n        then\n            error(\"Malformed SCOM FA bomber DestroyOnWater contract\")\n        end\n        return contract\n    end\n\n    local function SCO_FaBomberCullWaterProjectiles()\n        local _, hasWater = Engine.HasWater()\n        if not hasWater then return end\n        local _, waterLevel = Engine.GetWaterLevel()\n        if type(waterLevel) ~= \"number\" then\n            error(\"SCOM FA bomber water level is unavailable\")\n        end\n        local toDestroy = {}\n        for _, projectile in pairs(Projectiles) do\n            if SCO_FaBomberDestroyOnWaterContract(projectile) ~= nil then\n                local _, position =\n                    Engine.GetGlobalEntityWorldPosition(projectile.id)\n                if position ~= nil and position.y <= waterLevel then\n                    table.insert(toDestroy, projectile)\n                end\n            end\n        end\n        for _, projectile in ipairs(toDestroy) do\n            if Projectiles[projectile.id.index] == projectile then\n                DestroyProjectile(projectile.id, 0)\n            end\n        end\n    end\n\n    local function SCO_FaBomberCrashImpactContract(wreck)\n        local contract = wreck and wreck.scoFaBomberCrashImpact\n        if contract == nil then return nil end\n        local profile = SCO_FaBomberCrashImpactProfiles[\n            contract.sourceUnitId]\n        if profile == nil\n            or contract.version ~= \"1.0.0\"\n            or contract.sourceLabel ~= \"DeathImpact\"\n            or contract.damage ~= profile.damage\n            or contract.damageRadius ~= profile.radius\n            or contract.damageFriendly ~= true\n            or contract.runtimeMode ~= \"WreckImpactAreaDamage\"\n            or contract.army == nil\n        then\n            error(\"Malformed SCOM Ahwassa wreck crash-impact contract\")\n        end\n        return contract\n    end\n\n    local function SCO_FaBomberApplyCrashImpact(wreck, position)\n        local contract = SCO_FaBomberCrashImpactContract(wreck)\n        if contract == nil\n            or wreck.scoFaBomberCrashImpactApplied == true\n        then\n            return\n        end\n        if wreck.scoAircraftCrashActive then\n            if wreck.deleted or Props[wreck.id.index] ~= wreck then return end\n            position = wreck.scoAircraftCrashContactPosition\n            if position == nil then return end\n        end\n        if position == nil\n            or type(position.x) ~= \"number\"\n            or type(position.y) ~= \"number\"\n            or type(position.z) ~= \"number\"\n        then\n            error(\"SCOM Ahwassa crash impact has no valid position\")\n        end\n        wreck.scoFaBomberCrashImpactApplied = true\n        SCO_FaBomberStockAreaDamage(\n            position,\n            contract.damageRadius,\n            contract.damage,\n            contract.army,\n            contract.damageFriendly)\n    end\n\n    -- Native Import exposes this function from the collision module environment.\n    -- Physics invokes it at actual contact, before an overkill actor is deleted.\n    function SCO_ApplyAircraftCrashContact(wreck)\n        if not wreck or wreck.deleted or not wreck.id\n            or Props[wreck.id.index] ~= wreck or wreck.scoAircraftCrashActive ~= true\n            or wreck.scoAircraftCrashContactPosition == nil then return end\n        local position = wreck.scoAircraftCrashContactPosition\n        Import(\"common/systems/scoMissingCrash.lua\").Apply(wreck, position, ProcessAreaDamage)\n        SCO_FaBomberApplyCrashImpact(wreck, position)\n    end\n\n    local function SCO_FaBomberApplyWaterCrashImpacts()\n        local _, hasWater = Engine.HasWater()\n        if not hasWater then return end\n        local _, waterLevel = Engine.GetWaterLevel()\n        if type(waterLevel) ~= \"number\" then\n            error(\"SCOM Ahwassa crash water level is unavailable\")\n        end\n        for _, wreck in pairs(Props) do\n            local contract = SCO_FaBomberCrashImpactContract(wreck)\n            if contract ~= nil\n                and wreck.scoFaBomberCrashImpactApplied ~= true\n            then\n                local _, position =\n                    Engine.GetGlobalEntityWorldPosition(wreck.id)\n                if position ~= nil and position.y <= waterLevel then\n                    local _, terrainHeight =\n                        Engine.SampleTerrainHeight(position)\n                    if type(terrainHeight) ~= \"number\" then\n                        error(\"SCOM Ahwassa crash terrain height is unavailable\")\n                    end\n                    if terrainHeight < waterLevel then\n                        SCO_FaBomberApplyCrashImpact(wreck, {\n                            x = position.x,\n                            y = waterLevel,\n                            z = position.z,\n                        })\n                    end\n                end\n            end\n        end\n    end\n\n    local function SCO_FaBomberApplyTerrainCrashImpacts()\n        for _, wreck in pairs(Props) do\n            if wreck.crashImpactPosition ~= nil then\n                SCO_FaBomberApplyCrashImpact(\n                    wreck,\n                    wreck.crashImpactPosition)\n            end\n        end\n    end\n\n    local function SCO_FaBomberGroundFireContract(projectile)\n        local additions = projectile and projectile.tp\n            and projectile.tp.additions\n        local contract = additions and additions.scoFaBomberGroundFire\n        if contract == nil then return nil end\n        local impactContract = SCO_FaBomberImpactContract(projectile)\n        if impactContract == nil\n            or impactContract.runtimeProjectileId ~= \"peb101\"\n            or contract.version ~= \"1.0.0\"\n            or contract.sourceId ~= \"TIFNapalmCarpetBomb01\"\n            or contract.runtimeProjectileId ~= \"peb101\"\n            or contract.pulseCount ~= 15\n            or contract.pulseDamage ~= 4\n            or contract.pulseIntervalTicks ~= 1\n            or contract.durationSeconds ~= 1.5\n            or contract.damageRadius ~= 2.5\n            or contract.damageFriendly ~= false\n            or projectile.damage ~= 60\n            or projectile.damageRadius ~= 2.5\n        then\n            error(\"Malformed SCOM Scorcher ground-fire projectile contract\")\n        end\n        return contract\n    end\n\n    local function SCO_FaBomberGroundFireThread(\n        position,\n        projectileArmy,\n        sourceUnit,\n        contract)\n        for _ = 1, contract.pulseCount do\n            SCO_FaBomberStockAreaDamage(\n                position,\n                contract.damageRadius,\n                contract.pulseDamage,\n                projectileArmy,\n                contract.damageFriendly,\n                sourceUnit)\n            WaitTicks(contract.pulseIntervalTicks)\n        end\n    end\n\n    local function SCO_FaBomberRecoverScorcherTerrainImpacts()\n        -- Native rays test only the previous/current segment. Once both\n        -- endpoints are below terrain, another crossing cannot be found.\n        -- Let native unit/shield/water/terrain events consume bombs first,\n        -- then recover only surviving Scorcher bombs at the actual floor.\n        for _, projectile in pairs(Projectiles) do\n            local general = projectile.tp and projectile.tp.general\n            if general and general.tpId == \"peb101\"\n                and SCO_FaBomberGroundFireContract(projectile) ~= nil\n            then\n                local result, position =\n                    Engine.GetGlobalEntityWorldPosition(projectile.id)\n                if result == EngineErrorCode.Success and position ~= nil then\n                    local terrainResult, height = Engine.SampleTerrainHeight(position)\n                    if terrainResult == EngineErrorCode.Success\n                        and type(height) == \"number\" and position.y <= height\n                    then\n                        local _, hasWater = Engine.HasWater()\n                        local _, waterLevel = Engine.GetWaterLevel()\n                        if not hasWater or (type(waterLevel) == \"number\" and height >= waterLevel) then\n                            local contact = EngineClasses.float3(position.x, height + 0.01, position.z)\n                            -- Replicate the contact before native destruction\n                            -- so damage and the client impact share the floor.\n                            if Engine.SetGlobalEntityPosition(projectile.id, contact)\n                                == EngineErrorCode.Success\n                            then\n                                ProcessRayCollisionEvent({\n                                    rayGlobalID = projectile.id,\n                                    otherGlobalID = EngineClasses.GlobalID(),\n                                    rayOrigin = contact,\n                                    rayDirection = EngineClasses.float3(0, -1, 0),\n                                    rayMaxDistance = 0.01,\n                                    hitDistance = 0.01,\n                                    colliderHitIndex = 0,\n                                })\n                            end\n                        end\n                    end\n                end\n            end\n        end\n    end\n\n    function CollisionUpdate()\n        SCO_FaBomberCullWaterProjectiles()\n        SCO_FaBomberApplyWaterCrashImpacts()\n        local result = SCO_FaBomberStockCollisionUpdate()\n        SCO_FaBomberRecoverScorcherTerrainImpacts()\n        SCO_FaBomberApplyTerrainCrashImpacts()\n        return result\n    end\n\n    function ProcessAreaDamage(\n        position,\n        radius,\n        damage,\n        army,\n        damageFriendly,\n        ...)\n        local projectile = SCO_FaBomberActiveProjectile\n        local impactContract = SCO_FaBomberImpactContract(projectile)\n        local groundFireContract =\n            SCO_FaBomberGroundFireContract(projectile)\n        if impactContract ~= nil\n            and radius == projectile.damageRadius\n            and damage == projectile.damage\n            and army == Armies[projectile.armyId]\n        then\n            if groundFireContract ~= nil then\n                if projectile.scoFaBomberGroundFireStarted ~= true then\n                    local projectileArmy = Armies[projectile.armyId]\n                    if projectileArmy == nil then\n                        error(\"SCOM Scorcher ground-fire projectile has no owning army\")\n                    end\n                    projectile.scoFaBomberGroundFireStarted = true\n                    local sourceUnit = projectile.sourceUnit or select(1, ...)\n                    NewThread(\n                        SCO_FaBomberGroundFireThread,\n                        position,\n                        projectileArmy,\n                        sourceUnit,\n                        groundFireContract)\n                end\n                -- Suppress the stock direct area call. The exact 15 source\n                -- pulses above are the complete 60 damage for this bomb.\n                return\n            end\n            return SCO_FaBomberStockAreaDamage(\n                position,\n                radius,\n                damage,\n                army,\n                impactContract.damageFriendly,\n                ...)\n        end\n        return SCO_FaBomberStockAreaDamage(\n            position,\n            radius,\n            damage,\n            army,\n            damageFriendly,\n            ...)\n    end\n\n    function ProcessRayCollisionEvent(event)\n        local projectile = event and event.rayGlobalID\n            and Projectiles[event.rayGlobalID.index]\n        if SCO_FaBomberImpactContract(projectile) ~= nil then\n            local projectileArmy = Armies[projectile.armyId]\n            if projectileArmy == nil then\n                error(\"SCOM Scorcher ground-fire projectile has no owning army\")\n            end\n            local previous = SCO_FaBomberActiveProjectile\n            SCO_FaBomberActiveProjectile = projectile\n            local succeeded, result = pcall(\n                SCO_FaBomberStockRayCollision,\n                event)\n            SCO_FaBomberActiveProjectile = previous\n            if not succeeded then\n                error(result)\n            end\n            return result\n        end\n        return SCO_FaBomberStockRayCollision(event)\n    end\n\n    function ProcessWaterCollisionEvent(event)\n        if not event or not event.rayGlobalID then\n            return SCO_FaBomberStockWaterCollision(event)\n        end\n        local result, root = Engine.GetGlobalEntityRoot(event.rayGlobalID)\n        local projectile = result == EngineErrorCode.Success and root\n            and Projectiles[root.index]\n        if SCO_FaBomberImpactContract(projectile) == nil then\n            return SCO_FaBomberStockWaterCollision(event)\n        end\n        local previous = SCO_FaBomberActiveProjectile\n        SCO_FaBomberActiveProjectile = projectile\n        local succeeded, value = pcall(SCO_FaBomberStockWaterCollision, event)\n        SCO_FaBomberActiveProjectile = previous\n        if not succeeded then error(value) end\n        return value\n    end\n\n    rawset(\n        SCO_FaBomberGroundFireEnvironment,\n        \"SCO_FaBomberGroundFireInstalled\",\n        \"1.1.0\")\nend";

	private static readonly string HostWeaponsAppendix = "\n-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0\n-- FA surface bombers do not fire when a target merely enters weapon\n-- range. NeedToComputeBombDrop predicts the impact point using the\n-- carrier's velocity plus a reviewed forward release bonus and releases\n-- only inside BombDropThreshold. Keep\n-- Sanctuary's stock targeting and salvo state machine, but restore that\n-- source-owned release gate and RealisticOrdinance velocity inheritance\n-- for the ten private surface-bomb projectile IDs. Ahwassa's four fixed\n-- AA stations also retain their source-relative heading acquisition arcs.\nlocal SCO_FaBomberDropEnvironment =\n    type(getfenv) == \"function\" and getfenv(1) or _ENV\nlocal SCO_FaBomberDropInstalled = rawget(\n    SCO_FaBomberDropEnvironment,\n    \"SCO_FaBomberDropInstalled\")\nif SCO_FaBomberDropInstalled ~= nil\n    and SCO_FaBomberDropInstalled ~= \"1.0.0\"\nthen\n    error(\"Unsupported SCOM FA bomber drop runtime \"\n        .. tostring(SCO_FaBomberDropInstalled))\nend\nif SCO_FaBomberDropInstalled == nil then\n    if type(HostWeapon) ~= \"table\"\n        or type(HostWeapon.CanShootAt) ~= \"function\"\n        or type(HostWeapon.IsWeaponOnTarget) ~= \"function\"\n        or type(HostWeapon.GetDesiredProjectileValues) ~= \"function\"\n        or type(Engine.GetGlobalEntityWorldPosition) ~= \"function\"\n        or type(Engine.GetMovementHeadingDegrees) ~= \"function\"\n        or type(Engine.GetMovementChassisYawDegrees) ~= \"function\"\n        or type(Engine.GetMovementCurrentSpeed) ~= \"function\"\n        or type(Engine.QuaternionLookRotationSafe) ~= \"function\"\n        or type(Engine.HasWater) ~= \"function\"\n        or type(Engine.GetWaterLevel) ~= \"function\"\n    then\n        error(\"SCOM FA bomber drop runtime cannot resolve host weapon functions\")\n    end\n\n    local SCO_FaBomberStockCanShootAt =\n        HostWeapon.CanShootAt\n    local SCO_FaBomberStockIsWeaponOnTarget =\n        HostWeapon.IsWeaponOnTarget\n    local SCO_FaBomberStockGetDesiredProjectileValues =\n        HostWeapon.GetDesiredProjectileValues\n    local SCO_FaBomberDropProfiles = {\n        pab101 = { threshold = 1.5, lifetime = 3, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 40 },\n        pab301 = { threshold = 3.5, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 },\n        peb101 = { threshold = 3, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 },\n        peb301 = { threshold = 3.5, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 },\n        pgb101 = { threshold = 3, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 25 },\n        pgb301 = { threshold = 3.5, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 },\n        psb101 = { threshold = 3, lifetime = 3, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 40 },\n        psb202 = { threshold = 2, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 },\n        psb301 = { threshold = 3.5, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 },\n        psb402 = { threshold = 4, lifetime = 8, predictAhead = 2, forwardSpeedBonus = 3, maxSpeed = 20 },\n    }\n    local SCO_FaBomberHeadingProfiles = {\n        RightFrontAutocannon = { center = 310, range = 80 },\n        LeftFrontAutocannon = { center = 60, range = 90 },\n        RightRearAutocannon = { center = 180, range = 120 },\n        LeftRearAutocannon = { center = 180, range = 130 },\n    }\n\n    local function SCO_FaBomberDropContract(weapon)\n        local contract = weapon and weapon.tp\n            and weapon.tp.scoFaBombDrop\n        if contract == nil then return nil end\n        local profile = SCO_FaBomberDropProfiles[\n            contract.runtimeProjectileId]\n        if profile == nil\n            or contract.version ~= \"1.0.0\"\n            or contract.sourceNeedToComputeBombDrop ~= true\n            or contract.sourceRealisticOrdinance ~= true\n            or contract.sourceMuzzleVelocity ~= 0\n            or contract.sourcePredictAheadForBombDrop ~= profile.predictAhead\n            or contract.sourceBombDropThreshold ~= profile.threshold\n            or contract.runtimeAimProjectileSpeed ~= 0.0001\n            or contract.runtimeGravity ~= 4.9\n            or contract.runtimeProjectileLifetime ~= profile.lifetime\n            or contract.runtimeForwardSpeedBonus ~= profile.forwardSpeedBonus\n            or contract.sourceProjectileMaxSpeed ~= profile.maxSpeed\n            or contract.runtimeReleaseMode\n                ~= \"PredictedHorizontalImpactThreshold\"\n            or contract.runtimeVelocityMode\n                ~= \"CarrierCurrentMovementSpeedPlusForwardBonus\"\n            or weapon.tp.projectileTemplate\n                ~= contract.runtimeProjectileId\n            or weapon.tp.projectileLifetime ~= profile.lifetime\n        then\n            error(\"Malformed SCOM FA bomber drop weapon contract\")\n        end\n        return contract\n    end\n\n    local function SCO_FaBomberHeadingContract(weapon)\n        local contract = weapon and weapon.tp\n            and weapon.tp.scoFaHeadingArc\n        if contract == nil then return nil end\n        local profile = SCO_FaBomberHeadingProfiles[\n            contract.sourceLabel]\n        local unitTemplate = weapon.unit and weapon.unit.tp\n        local unitId = unitTemplate and unitTemplate.general\n            and unitTemplate.general.tpId\n        local aim = weapon.tp.aimControllers\n            and weapon.tp.aimControllers[1]\n        local gravity = aim and aim.aimGravity\n        if profile == nil\n            or contract.version ~= \"1.0.0\"\n            or contract.sourceUnitId ~= \"XSA0402\"\n            or contract.sourceHeadingArcCenter ~= profile.center\n            or contract.sourceHeadingArcRange ~= profile.range\n            or contract.runtimeMode ~= \"HostRelativeHeadingGate\"\n            or unitId ~= \"usa4011\"\n            or weapon.tp.projectileTemplate ~= \"pca111\"\n            or weapon.tp.damage ~= 450\n            or aim == nil\n            or aim.solverType ~= \"NoArc\"\n            or aim.projectileSpeed ~= 90\n            or gravity == nil\n            or gravity.x ~= 0\n            or gravity.y ~= 0\n            or gravity.z ~= 0\n        then\n            error(\"Malformed SCOM Ahwassa AA heading contract\")\n        end\n        return contract\n    end\n\n    local function SCO_FaBomberNormalizeHeading(value)\n        return (value + 180) % 360 - 180\n    end\n\n    local function SCO_FaBomberPassesHeadingArc(\n        weapon,\n        target,\n        contract)\n        local ownerPosition = weapon.unit:GetPosition()\n        local targetPosition = target and target:GetPosition()\n        if ownerPosition == nil or targetPosition == nil then\n            return false\n        end\n        local deltaX = targetPosition.x - ownerPosition.x\n        local deltaZ = targetPosition.z - ownerPosition.z\n        if deltaX == 0 and deltaZ == 0 then return true end\n        local _, ownerYaw = Engine.GetMovementChassisYawDegrees(weapon.unit.id)\n        if type(ownerYaw) ~= \"number\" then return false end\n        local targetHeading = math.deg(math.atan2(deltaX, deltaZ))\n        local relativeHeading = SCO_FaBomberNormalizeHeading(\n            targetHeading\n                - ownerYaw\n                - contract.sourceHeadingArcCenter)\n        return math.abs(relativeHeading)\n            <= contract.sourceHeadingArcRange\n    end\n\n    local function SCO_FaBomberHorizontalForward(entityId)\n        local _, heading = Engine.GetMovementHeadingDegrees(entityId)\n        if type(heading) ~= \"number\" then return nil end\n        local radians = math.rad(heading)\n        return { x = math.sin(radians), z = math.cos(radians) }\n    end\n\n    local function SCO_FaBomberMovementSpeed(unit, useFlightFallback)\n        -- Stationary targets have no native Movement component.\n        if not (unit.tp and unit.tp.movement) then return 0 end\n        local _, speed = Engine.GetMovementCurrentSpeed(unit.id)\n        if type(speed) == \"number\" and speed > 0 then\n            return speed\n        end\n        if useFlightFallback then\n            local movement = unit.tp and unit.tp.movement\n            return movement and (movement.minSpeed or movement.speed) or 0\n        end\n        return 0\n    end\n\n    local function SCO_FaBomberLaunchSpeed(weapon, contract)\n        local inheritedSpeed =\n            SCO_FaBomberMovementSpeed(weapon.unit, true)\n        return math.min(\n            inheritedSpeed + contract.runtimeForwardSpeedBonus,\n            contract.sourceProjectileMaxSpeed)\n    end\n\n    function SCO_FaBomberCarrierFiringRotation(\n        weapon,\n        fallbackRotation)\n        local contract = SCO_FaBomberDropContract(weapon)\n        if contract == nil then return fallbackRotation end\n        local forward = SCO_FaBomberHorizontalForward(weapon.unit.id)\n        if forward == nil then return fallbackRotation end\n        return Engine.QuaternionLookRotationSafe(\n            EngineClasses.float3(forward.x, 0, forward.z),\n            EngineClasses.float3(0, 1, 0))\n    end\n\n    local function SCO_FaBomberDropIsAligned(weapon, contract)\n        local target = weapon.targetUnit\n        local muzzleGroup = weapon.muzzleGroups[\n            weapon.currentMuzzleGroupIndex]\n            or weapon.muzzleGroups[1]\n        local muzzle = muzzleGroup and muzzleGroup[1]\n        if target == nil or muzzle == nil\n            or target.dead or target.deleted or weapon.unit.dead or weapon.unit.deleted\n            or not Engine.IsValidGlobalID(weapon.unit.id)\n            or not Engine.IsValidGlobalID(muzzle.id)\n            or not Engine.IsValidGlobalID(target.id) then return false end\n\n        local muzzleResult, muzzlePosition =\n            Engine.GetGlobalEntityWorldPosition(muzzle.id)\n        local targetResult, targetPosition =\n            Engine.GetGlobalEntityWorldPosition(target.id)\n        if muzzleResult ~= EngineErrorCode.Success\n            or targetResult ~= EngineErrorCode.Success then return false end\n        local carrierForward =\n            SCO_FaBomberHorizontalForward(weapon.unit.id)\n        if muzzlePosition == nil\n            or targetPosition == nil\n            or carrierForward == nil\n        then\n            return false\n        end\n\n        local height = muzzlePosition.y - targetPosition.y\n        if height <= 0 then return false end\n        local fallTime = math.sqrt(\n            (2 * height) / contract.runtimeGravity)\n        if fallTime >= contract.runtimeProjectileLifetime then\n            return false\n        end\n\n        local launchSpeed = SCO_FaBomberLaunchSpeed(weapon, contract)\n        local impactX = muzzlePosition.x\n            + carrierForward.x * launchSpeed * fallTime\n        local impactZ = muzzlePosition.z\n            + carrierForward.z * launchSpeed * fallTime\n\n        local predictedTargetX = targetPosition.x\n        local predictedTargetZ = targetPosition.z\n        local targetSpeed = SCO_FaBomberMovementSpeed(target, false)\n        if targetSpeed > 0 then\n            local targetForward =\n                SCO_FaBomberHorizontalForward(target.id)\n            if targetForward ~= nil then\n                predictedTargetX = predictedTargetX\n                    + targetForward.x * targetSpeed * fallTime\n                predictedTargetZ = predictedTargetZ\n                    + targetForward.z * targetSpeed * fallTime\n            end\n        end\n\n        local missX = impactX - predictedTargetX\n        local missZ = impactZ - predictedTargetZ\n        local threshold = contract.sourceBombDropThreshold\n        return missX * missX + missZ * missZ\n            <= threshold * threshold\n    end\n\n    function HostWeapon:CanShootAt(target)\n        if not SCO_FaBomberStockCanShootAt(self, target) then\n            return false\n        end\n        -- Nine source bomb weapons explicitly require an above-water\n        -- target. Sanctuary's targetWaterLimits field is descriptive;\n        -- enforce that source constraint after the native target gate.\n        -- UAA0103/pab101 omits AboveWaterTargetsOnly and is unchanged.\n        local bomb = SCO_FaBomberDropContract(self)\n        if bomb ~= nil and bomb.runtimeProjectileId ~= \"pab101\" then\n            local waterResult, hasWater = Engine.HasWater()\n            if waterResult ~= EngineErrorCode.Success then return false end\n            if hasWater then\n                local levelResult, level = Engine.GetWaterLevel()\n                if levelResult ~= EngineErrorCode.Success\n                    or type(level) ~= \"number\"\n                    or target == nil\n                    or type(target.GetPosition) ~= \"function\"\n                then\n                    return false\n                end\n                local position = target:GetPosition()\n                if position == nil or type(position.y) ~= \"number\"\n                    or position.y < level - 0.05\n                then\n                    return false\n                end\n            end\n        end\n        local contract = SCO_FaBomberHeadingContract(self)\n        if contract == nil then return true end\n        return SCO_FaBomberPassesHeadingArc(\n            self,\n            target,\n            contract)\n    end\n\n    function HostWeapon:IsWeaponOnTarget()\n        if not SCO_FaBomberStockIsWeaponOnTarget(self) then\n            return false\n        end\n        local contract = SCO_FaBomberDropContract(self)\n        if contract == nil then return true end\n        return SCO_FaBomberDropIsAligned(self, contract)\n    end\n\n    function HostWeapon:GetDesiredProjectileValues(aimControllerId)\n        local desiredSpeed, gravity, targetBoneId =\n            SCO_FaBomberStockGetDesiredProjectileValues(\n                self,\n                aimControllerId)\n        if desiredSpeed == nil then return nil end\n        local contract = SCO_FaBomberDropContract(self)\n        if contract == nil then\n            return desiredSpeed, gravity, targetBoneId\n        end\n        local launchSpeed = SCO_FaBomberLaunchSpeed(self, contract)\n        return launchSpeed,\n            EngineClasses.float3(0, -contract.runtimeGravity, 0),\n            targetBoneId\n    end\n\n    rawset(\n        SCO_FaBomberDropEnvironment,\n        \"SCO_FaBomberDropInstalled\",\n        \"1.0.0\")\nend";

	private static readonly string HostAirUnitsAppendix = "\n-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0\n-- Stock Sanctuary aircraft pursue at an orbit-sized standoff. That is a\n-- good default for gunships and fighters, but it makes fixed-forward FA\n-- surface bombers brake beside the target after their first approach.\n-- A zero ingress standoff keeps the source-pinned surface bombers nose-on.\n-- Actual bomb creation then issues a forward breakoff leg beyond the target;\n-- the stock Arrived callback naturally resumes pursuit. All other air\n-- units, including both torpedo bombers, keep the stock behavior. Ahwassa's\n-- source DeathImpact damage follows its spawned wreck so it occurs at the\n-- later land or water impact instead of at the aircraft's destruction\n-- altitude.\nlocal SCO_FaBomberAttackRunEnvironment =\n    type(getfenv) == \"function\" and getfenv(1) or _ENV\nlocal SCO_FaBomberAttackRunInstalled = rawget(\n    SCO_FaBomberAttackRunEnvironment,\n    \"SCO_FaBomberAttackRunInstalled\")\nif SCO_FaBomberAttackRunInstalled ~= nil\n    and SCO_FaBomberAttackRunInstalled ~= \"1.0.0\"\nthen\n    error(\"Unsupported SCOM FA bomber attack-run runtime \"\n        .. tostring(SCO_FaBomberAttackRunInstalled))\nend\nif SCO_FaBomberAttackRunInstalled == nil then\n    if type(HostAirUnit) ~= \"table\"\n        or type(HostAirUnit.GetAttackRadius) ~= \"function\"\n        or type(CreateWreckageFromUnit) ~= \"function\"\n        or type(Engine.GetMovementHeadingDegrees) ~= \"function\"\n        or type(Engine.MovementMove) ~= \"function\"\n        or type(EngineClasses) ~= \"table\"\n        or type(EngineClasses.float2) ~= \"function\"\n    then\n        error(\"SCOM FA bomber air runtime cannot resolve host functions\")\n    end\n\n    local SCO_FaBomberStockGetAttackRadius =\n        HostAirUnit.GetAttackRadius\n    local SCO_FaBomberStockCreateWreckageFromUnit =\n        CreateWreckageFromUnit\n    local SCO_FaBomberAttackRunProfiles = {\n        uca1001 = { breakOffDistance = 30, breakOffTrigger = 20 },\n        uca3001 = { breakOffDistance = 60, breakOffTrigger = 30 },\n        uea1001 = { breakOffDistance = 18, breakOffTrigger = 20 },\n        uea3001 = { breakOffDistance = 60, breakOffTrigger = 30 },\n        uga1001 = { breakOffDistance = 30, breakOffTrigger = 20 },\n        uga3001 = { breakOffDistance = 60, breakOffTrigger = 30 },\n        usa1001 = { breakOffDistance = 30, breakOffTrigger = 20 },\n        usa2101 = { breakOffDistance = 40, breakOffTrigger = 20 },\n        usa3001 = { breakOffDistance = 60, breakOffTrigger = 30 },\n        usa4011 = { breakOffDistance = 60, breakOffTrigger = 30 },\n    }\n    local SCO_FaBomberCrashImpactProfiles = {\n        usa4011 = { damage = 10000, radius = 8 },\n    }\n\n    local function SCO_FaBomberAttackRunContract(unit)\n        local additions = unit and unit.tp and unit.tp.additions\n        local contract = additions and additions.scoFaBomberAttackRun\n        if contract == nil then return nil end\n        local tpId = unit.tp.general and unit.tp.general.tpId\n        local profile = SCO_FaBomberAttackRunProfiles[tpId]\n        if profile == nil\n            or contract.version ~= \"1.0.0\"\n            or contract.sourceBreakOffDistance\n                ~= profile.breakOffDistance\n            or contract.sourceBreakOffIfNearNewTarget ~= true\n            or contract.sourceBreakOffTrigger ~= profile.breakOffTrigger\n            or contract.sourceEngageDistance ~= 50\n            or contract.runtimePursueStandoff ~= 0\n            or contract.runtimeMode ~= \"ReleaseBreakOffReentry\"\n        then\n            error(\"Malformed SCOM FA bomber attack-run contract\")\n        end\n        return contract\n    end\n\n    function HostAirUnit:SCO_FaBomberOnBombReleased(projectileId)\n        local contract = SCO_FaBomberAttackRunContract(self)\n        local target = self.attackBehaviorTargetUnit\n        if contract == nil\n            or projectileId == nil\n            or self.dead == true\n            or self.attackBehaviorIsActive ~= true\n            or type(target) ~= \"table\"\n            or target.dead == true\n            or type(self.GetPosition) ~= \"function\"\n            or type(target.GetPosition) ~= \"function\"\n        then\n            return false\n        end\n\n        local position = self:GetPosition()\n        local targetPosition = target:GetPosition()\n        local _, heading = Engine.GetMovementHeadingDegrees(self.id)\n        if type(position) ~= \"table\"\n            or type(targetPosition) ~= \"table\"\n            or type(heading) ~= \"number\"\n        then\n            return false\n        end\n\n        local radians = math.rad(heading)\n        local forwardX = math.sin(radians)\n        local forwardZ = math.cos(radians)\n        local targetForwardDistance =\n            (targetPosition.x - position.x) * forwardX\n            + (targetPosition.z - position.z) * forwardZ\n        local legLength = math.max(\n            contract.sourceBreakOffDistance,\n            targetForwardDistance + contract.sourceBreakOffDistance)\n        local waypoint = EngineClasses.float2(\n            position.x + forwardX * legLength,\n            position.z + forwardZ * legLength)\n        local result = Engine.MovementMove(\n            self.id,\n            waypoint,\n            EngineClasses.float2(0, 0),\n            0)\n        local success = result == nil\n            or result == 0\n            or (type(EngineErrorCode) == \"table\"\n                and result == EngineErrorCode.Success)\n        if success then\n            self.scoFaBomberAttackRunBreakOff = { target = target, waypoint = waypoint }\n        end\n        return success\n    end\n\n    local function SCO_FaBomberCrashImpactContract(unit)\n        local additions = unit and unit.tp and unit.tp.additions\n        local contract = additions and additions.scoFaBomberCrashImpact\n        if contract == nil then return nil end\n        local tpId = unit.tp.general and unit.tp.general.tpId\n        local profile = SCO_FaBomberCrashImpactProfiles[tpId]\n        if unit.tpId == \"wra0401\" or tpId == \"wra0401\" then\n            local class = unit.tp.general.class\n            local source = additions.faSurfaceBomberSourceContract\n            if unit.tpId ~= tpId or type(class) ~= \"table\"\n                or class[1] ~= \"unitsDefaultSeraphim\" or class[2] ~= \"SeraphimAirUnit\"\n                or type(source) ~= \"table\" or source.sourceUnitId ~= \"XSA0402\"\n                or source.targetUnitId ~= \"usa4011\"\n                or source.sourceBlueprintSha256\n                    ~= \"19ad26d88df8e9b1e7ae5fbfd680e266d935659a843dea3c6931325b81e799c5\"\n            then\n                error(\"Aircraft alias Ahwassa crash donor identity drift\")\n            end\n            profile = SCO_FaBomberCrashImpactProfiles.usa4011\n        end\n        if profile == nil\n            or contract.version ~= \"1.0.0\"\n            or contract.sourceUnitId ~= \"XSA0402\"\n            or contract.sourceLabel ~= \"DeathImpact\"\n            or contract.damage ~= profile.damage\n            or contract.damageRadius ~= profile.radius\n            or contract.damageFriendly ~= true\n            or contract.runtimeMode ~= \"WreckImpactAreaDamage\"\n            or unit.army == nil\n        then\n            error(\"Malformed SCOM Ahwassa crash-impact contract\")\n        end\n        return contract\n    end\n\n    -- Source surface bombers keep release-driven ingress and breakoff. The new\n    -- native Strafe goal would start its runout independently of bomb release.\n    local SCO_FaBomberStockGetPatternID = HostAirUnit.GetPatternID\n    function HostAirUnit:GetPatternID(situation)\n        if situation == \"attack\" and SCO_FaBomberAttackRunContract(self) then\n            return 0\n        end\n        return SCO_FaBomberStockGetPatternID(self, situation)\n    end\n\n    local SCO_FaBomberStockAttackBehaviorStop = HostAirUnit.AttackBehaviorStop\n    function HostAirUnit:AttackBehaviorStop()\n        self.scoFaBomberAttackRunBreakOff = nil\n        return SCO_FaBomberStockAttackBehaviorStop(self)\n    end\n\n    function HostAirUnit:GetAttackRadius(patternID, range)\n        local contract = SCO_FaBomberAttackRunContract(self)\n        if contract ~= nil then\n            return contract.runtimePursueStandoff\n        end\n        return SCO_FaBomberStockGetAttackRadius(self, patternID, range)\n    end\n\n    function CreateWreckageFromUnit(unit)\n        local contract = SCO_FaBomberCrashImpactContract(unit)\n        local wreck = SCO_FaBomberStockCreateWreckageFromUnit(unit)\n        if wreck ~= nil and contract ~= nil then\n            wreck.scoFaBomberCrashImpact = {\n                version = contract.version,\n                sourceUnitId = contract.sourceUnitId,\n                sourceLabel = contract.sourceLabel,\n                damage = contract.damage,\n                damageRadius = contract.damageRadius,\n                damageFriendly = contract.damageFriendly,\n                runtimeMode = contract.runtimeMode,\n                army = unit.army,\n            }\n        end\n        return wreck\n    end\n\n    rawset(\n        SCO_FaBomberAttackRunEnvironment,\n        \"SCO_FaBomberAttackRunInstalled\",\n        \"1.0.0\")\nend";

	private const string AttackMoveMarker = "-- Supreme Commander Overhaul FA Air Bomber Attack Move 1.1.0";

	private const string AttackMoveMarkerFamily = "-- Supreme Commander Overhaul FA Air Bomber Attack Move ";

	private static readonly string HostAirAttackMoveAppendix = "-- Supreme Commander Overhaul FA Air Bomber Attack Move 1.1.0\n-- Stock attack-move owns an auto-acquired weapon target, not an explicit\n-- attackBehaviorTargetUnit. Complete the source breakoff for a released\n-- bomb while preserving the stock pursuit loop for every other aircraft.\nlocal SCO_FaBomberAttackMoveEnvironment =\n    type(getfenv) == \"function\" and getfenv(1) or _ENV\nlocal SCO_FaBomberAttackMoveInstalled = rawget(\n    SCO_FaBomberAttackMoveEnvironment,\n    \"SCO_FaBomberAttackMoveInstalled\")\nif SCO_FaBomberAttackMoveInstalled ~= nil\n    and SCO_FaBomberAttackMoveInstalled ~= \"1.1.0\"\nthen\n    error(\"Unsupported SCOM bomber attack-move runtime \"\n        .. tostring(SCO_FaBomberAttackMoveInstalled))\nend\nif SCO_FaBomberAttackMoveInstalled == nil then\n    if type(HostAirUnit) ~= \"table\"\n        or type(HostAirUnit.SCO_FaBomberOnBombReleased) ~= \"function\"\n        or type(HostAirUnit.GetMainWeaponTarget) ~= \"function\"\n        or type(HostAirUnit.MoveIntoRangeBehaviorEnteredRange) ~= \"function\"\n        or type(HostAirUnit.AttackMoveBehaviorStop) ~= \"function\"\n        or type(MovementEventType) ~= \"table\"\n        or MovementEventType.Arrived == nil\n        or type(Engine.GetMovementHeadingDegrees) ~= \"function\"\n        or type(Engine.MovementMove) ~= \"function\"\n        or type(Engine.MovementMoveToTarget) ~= \"function\"\n        or MovementEventType.ArrivedBestEffort == nil\n        or type(EngineClasses.float2) ~= \"function\"\n    then\n        error(\"SCOM bomber attack-move runtime cannot resolve host functions\")\n    end\n\n    local SCO_FaBomberOriginalRelease =\n        HostAirUnit.SCO_FaBomberOnBombReleased\n    local SCO_FaBomberOriginalMainTarget =\n        HostAirUnit.GetMainWeaponTarget\n    local SCO_FaBomberOriginalEnteredRange =\n        HostAirUnit.MoveIntoRangeBehaviorEnteredRange\n    local SCO_FaBomberOriginalAttackMoveStop =\n        HostAirUnit.AttackMoveBehaviorStop\n\n    local function SCO_FaBomberAttackMoveBombTarget(unit)\n        local bombWeapon = nil\n        for _, weapon in ipairs(unit.weapons or {}) do\n            if weapon.tp and weapon.tp.scoFaBombDrop then\n                if bombWeapon ~= nil then return nil end\n                bombWeapon = weapon\n            end\n        end\n        return bombWeapon and bombWeapon:GetAimTarget() or nil\n    end\n\n    function HostAirUnit:GetMainWeaponTarget()\n        local target = SCO_FaBomberOriginalMainTarget(self)\n        local breakOff = self.scoFaBomberAttackMoveBreakOff\n        if breakOff ~= nil and breakOff.target ~= target then\n            self.scoFaBomberAttackMoveBreakOff = nil\n            self.scoFaBomberAttackRunBreakOff = nil\n        end\n        return target\n    end\n\n    HostAirUnit.SCO_FaBomberOnBombReleased = function(self, projectileId)\n        local handled = SCO_FaBomberOriginalRelease(self, projectileId)\n        if handled\n            or projectileId == nil\n            or self.dead == true\n            or self.isAirborne ~= true\n            or self.attackBehaviorIsActive == true\n            or self.attackMoveBehaviorIsActive ~= true\n            or self.moveIntoRangeBehaviorIsActive == true\n        then\n            return handled\n        end\n\n        local additions = self.tp and self.tp.additions\n        local contract = additions and additions.scoFaBomberAttackRun\n        if contract == nil then return false end\n        local target = SCO_FaBomberAttackMoveBombTarget(self)\n        if target == nil\n            or target.dead == true\n            or target ~= self:GetMainWeaponTarget()\n            or type(target.GetPosition) ~= \"function\"\n        then\n            return false\n        end\n        if self.scoFaBomberAttackMoveBreakOff ~= nil then\n            return false\n        end\n\n        local position = self:GetPosition()\n        local targetPosition = target:GetPosition()\n        local _, heading = Engine.GetMovementHeadingDegrees(self.id)\n        if type(position) ~= \"table\"\n            or type(targetPosition) ~= \"table\"\n            or type(heading) ~= \"number\"\n        then\n            return false\n        end\n        local radians = math.rad(heading)\n        local forwardX = math.sin(radians)\n        local forwardZ = math.cos(radians)\n        local targetForwardDistance =\n            (targetPosition.x - position.x) * forwardX\n            + (targetPosition.z - position.z) * forwardZ\n        local legLength = math.max(\n    \t\tcontract.sourceBreakOffDistance,\n    \t\ttargetForwardDistance + contract.sourceBreakOffDistance)\n        local waypoint = EngineClasses.float2(\n            position.x + forwardX * legLength,\n            position.z + forwardZ * legLength)\n        local result = Engine.MovementMove(self.id, waypoint, EngineClasses.float2(0, 0), 0)\n        local success = result == nil\n            or result == 0\n            or (type(EngineErrorCode) == \"table\"\n                and result == EngineErrorCode.Success)\n        if success then\n            self.scoFaBomberAttackMoveBreakOff = {\n                target = target,\n                waypoint = waypoint,\n            }\n        end\n        return success\n    end\n\n    function HostAirUnit:MoveIntoRangeBehaviorEnteredRange(reason)\n        local explicit = self.scoFaBomberAttackRunBreakOff\n        local breakOff = explicit or self.scoFaBomberAttackMoveBreakOff\n        if breakOff ~= nil and self.moveIntoRangeBehaviorIsActive == true then\n            self.scoFaBomberAttackMoveBreakOff = nil\n            self.scoFaBomberAttackRunBreakOff = nil\n        elseif breakOff ~= nil\n            and (reason == MovementEventType.Arrived\n                or reason == MovementEventType.ArrivedBestEffort)\n        then\n            if reason == MovementEventType.Arrived then\n                local position = self:GetPosition()\n                -- World position uses x/z; the movement waypoint is\n                -- float2 x/y. A previous pursuit's distant arrival\n                -- cannot complete this breakoff leg.\n                local nearWaypoint = type(position) == \"table\"\n                    and type(position.x) == \"number\"\n                    and type(position.z) == \"number\"\n                    and (position.x - breakOff.waypoint.x) ^ 2\n                        + (position.z - breakOff.waypoint.y) ^ 2 <= 25\n                if not nearWaypoint then return end\n            end\n            -- BestEffort is terminal even when pathfinding stops\n            -- farther from the waypoint; reenter instead of latching.\n            self.scoFaBomberAttackMoveBreakOff = nil\n            self.scoFaBomberAttackRunBreakOff = nil\n            if self.dead ~= true\n                and self.isAirborne == true\n                and breakOff.target.dead ~= true\n                and ((explicit ~= nil and self.attackBehaviorIsActive == true\n                        and self.attackBehaviorTargetUnit == breakOff.target)\n                    or (explicit == nil and self.attackMoveBehaviorIsActive == true\n                        and self:GetMainWeaponTarget() == breakOff.target))\n            then\n                self:PursueTarget(breakOff.target)\n                return\n            end\n        end\n        return SCO_FaBomberOriginalEnteredRange(self, reason)\n    end\n\n    function HostAirUnit:AttackMoveBehaviorStop()\n        self.scoFaBomberAttackMoveBreakOff = nil\n        return SCO_FaBomberOriginalAttackMoveStop(self)\n    end\n\n    rawset(\n        SCO_FaBomberAttackMoveEnvironment,\n        \"SCO_FaBomberAttackMoveInstalled\",\n        \"1.1.0\")\nend";

	private const string ZeusExhaustMarkerFamily = "-- Supreme Commander Overhaul FA Cybran Zeus Exhaust ";

	private const string ZeusExhaustMarker = "-- Supreme Commander Overhaul FA Cybran Zeus Exhaust 1.0.0";

	private const string ZeusExhaustAppendix = "\n-- Supreme Commander Overhaul FA Cybran Zeus Exhaust 1.0.0\n-- URA0103 BeamExhaust names both converted rear engine bones and is\n-- enabled at idle and cruise. The native Guard medium-aircraft effect\n-- supplies a persistent local exhaust without altering host movement.\nassert(UnitTemplate.general and UnitTemplate.general.tpId == \"uga1001\", \"Zeus exhaust target drift\")\nassert(UnitTemplate.additions and UnitTemplate.additions.faSourceContract\n    and UnitTemplate.additions.faSourceContract.sourceId == \"URA0103\",\n    \"Zeus exhaust source drift\")\nassert(UnitTemplate.visuals and UnitTemplate.visuals.effectsPersistent == nil,\n    \"Zeus exhaust requires the reviewed empty visual slot\")\nUnitTemplate.visuals.effectsPersistent = {\n    { boneName = \"Exhaust_L\", particleName = \"VFX/Unit/vgu4201_exhaust_aircraft_medium.sanvfx\" },\n    { boneName = \"Exhaust_R\", particleName = \"VFX/Unit/vgu4201_exhaust_aircraft_medium.sanvfx\" },\n}\n";

	public static void Apply()
	{
		ValidatePinnedScope();
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			BomberSpec[] bomberSpecs = BomberSpecs;
			foreach (BomberSpec bomber in bomberSpecs)
			{
				if (bomber.TargetId == "uga1001")
				{
					QueueZeusExhaust(obj, list, bomber);
					continue;
				}
				QueueAppend(obj, list, bomber.RelativePath, bomber.Description, delegate(string source)
				{
					ValidateStockUnit(source, bomber);
				}, BuildUnitOverride(bomber), delegate(string source)
				{
					ValidatePatchedUnit(source, bomber);
				});
			}
			SurfaceBomberSpec[] surfaceBomberSpecs = SurfaceBomberSpecs;
			foreach (SurfaceBomberSpec bomber2 in surfaceBomberSpecs)
			{
				QueueAppend(obj, list, bomber2.RelativePath, bomber2.Description, delegate(string source)
				{
					ValidateStockSurfaceBomber(source, bomber2);
				}, BuildSurfaceBomberOverride(bomber2), delegate(string source)
				{
					ValidatePatchedSurfaceBomber(source, bomber2);
				});
			}
			QueueAppend(obj, list, "LJ/lua/common/systems/import.lua", "FA bomber virtual-projectile scanner", ValidateStockImportScanner, ImportScannerAppendix, ValidateImportScanner);
			QueueReplaceAndAppend(obj, list, "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "FA bomber computed-drop host weapon runtime", ValidateStockHostWeapons, "local firingRotation = ApplyFiringRandomness(muzzleRotation, self.tp.firingRandomness or 1.0)\n                    local _, projectileID = Engine.InstantiatePrefab(projectilePrefabID, muzzlePosition, EngineClasses.float3(1.0, 1.0, 1.0), firingRotation)", "local launchRotation = muzzleRotation\n                    if self.tp.scoFaBombDrop ~= nil then\n                        launchRotation = SCO_FaBomberCarrierFiringRotation(\n                            self,\n                            muzzleRotation)\n                    end\n                    local firingRotation = ApplyFiringRandomness(\n                        launchRotation,\n                        self.tp.firingRandomness or 1.0)\n                    local _, projectileID = Engine.InstantiatePrefab(projectilePrefabID, muzzlePosition, EngineClasses.float3(1.0, 1.0, 1.0), firingRotation)\n                    if self.tp.scoFaBombDrop ~= nil\n                        and type(self.unit.SCO_FaBomberOnBombReleased) == \"function\"\n                    then\n                        self.unit:SCO_FaBomberOnBombReleased(projectileID)\n                    end", HostWeaponsAppendix, ValidatePatchedHostWeapons);
			QueueHostAirAttackMove(obj, list);
			QueueInsertBefore(obj, list, "LJ/lua/host/collisionUpdate.lua", "Scorcher ground-fire host collision runtime", ValidateStockHostCollision, HostCollisionAppendix, "return {\n    CollisionUpdate = CollisionUpdate,", ValidatePatchedHostCollision);
			ProjectileSpec[] projectileSpecs = ProjectileSpecs;
			foreach (ProjectileSpec projectile in projectileSpecs)
			{
				QueueVirtualProjectile(obj, list, projectile);
			}
			if (list.Count == 0)
			{
				Log("All twelve FA surface/torpedo bombers, thirteen private projectiles, computed bomb drops, repeated overflights, and Scorcher ground fire are already current.");
				return;
			}
			Commit(obj, list);
			Log("Applied UEA/URA, Aeon, and Seraphim bomber parity with computed gravity drops, repeated overflights, isolated projectiles, and Scorcher ground fire.");
		}
		catch (Exception ex)
		{
			if (obj != null)
			{
				RollBack(obj, list);
			}
			else
			{
				DisposeUncommitted(list);
			}
			Log("Failed to apply the FA bomber transaction: " + ex);
			throw;
		}
	}

	private static void ValidatePinnedScope()
	{
		string[] second = new string[6] { "uea1001:UEA0103", "uea2301:UEA0204", "uea3001:UEA0304", "uga1001:URA0103", "uga2301:URA0204", "uga3001:URA0304" };
		string[] first = BomberSpecs.Select((BomberSpec spec) => spec.TargetId + ":" + spec.SourceId).ToArray();
		string[] second2 = new string[6] { "uca1001:UAA0103", "uca3001:UAA0304", "usa1001:XSA0103", "usa2101:XSA0202", "usa3001:XSA0304", "usa4011:XSA0402" };
		string[] first2 = SurfaceBomberSpecs.Select((SurfaceBomberSpec spec) => spec.TargetId + ":" + spec.SourceId).ToArray();
		string[] second3 = new string[13]
		{
			"pab101", "pab301", "peb101", "peb231", "peb301", "pgb101", "pgb231", "pgb301", "pgb302", "psb101",
			"psb202", "psb301", "psb402"
		};
		if (!first.SequenceEqual(second, StringComparer.Ordinal) || !first2.SequenceEqual(second2, StringComparer.Ordinal) || !ProjectileSpecs.Select((ProjectileSpec spec) => spec.Id).SequenceEqual<string>(second3, StringComparer.Ordinal))
		{
			throw new InvalidOperationException("The FA bomber mapping/projectile scope changed from the reviewed inventory.");
		}
		if (BomberSpecs.Any((BomberSpec spec) => spec.SourceBlueprintSha256.Length != 64 || spec.SourceScriptSha256.Length != 64) || SurfaceBomberSpecs.Any((SurfaceBomberSpec spec) => spec.SourceBlueprintSha256.Length != 64 || spec.SourceScriptSha256.Length != 64) || ProjectileSpecs.Any((ProjectileSpec spec) => spec.SourceBlueprintSha256.Length != 64 || spec.SourceScriptSha256.Length != 64))
		{
			throw new InvalidOperationException("An FA bomber source hash lock is invalid.");
		}
	}

	private static string BuildSurfaceBomberOverride(SurfaceBomberSpec bomber)
	{
		ProjectileSpec projectileSpec = ProjectileSpecs.Single((ProjectileSpec spec) => spec.Id == bomber.ProjectileId);
		string text = ((bomber.TargetId == "uea1001") ? "false" : "true");
		string text2 = ((bomber.TargetId == "usa2101") ? "    sourceBaseBreakOffDistance = 5,\n    sourceBaseBreakOffTrigger = 10,\n    sourceBombTargetBreakOffDistanceMultiplier = 8,\n    sourceBombTargetBreakOffTriggerMultiplier = 2,\n    sourceBombTargetSpeedMultiplier = 0.67," : string.Empty);
		string text3 = ((bomber.TargetId == "usa4011") ? "\n-- The oversized Ahwassa traverses Sanctuary terrain at twice the\n-- observed FA cadence when the numerical FA airspeed is copied\n-- directly. Preserve the authoritative source values above and\n-- apply the explicit 0.5 native presentation conversion requested\n-- for this port.\nUnitTemplate.movement.speed = 10\nUnitTemplate.movement.acceleration = 10\nUnitTemplate.movement.deceleration = 10\nUnitTemplate.movement.minSpeed = 9\nUnitTemplate.movement.orbitSpeed = 9\nUnitTemplate.movement.orbitRange = 5.729577951308232" : string.Empty);
		return string.Format("\n{0}\n-- Installed FA units.scd/projectiles.scd are authoritative. Sanctuary\n-- has no native NeedToComputeBombDrop/RealisticOrdinance pair, so the\n-- shared host runtime releases at the predicted horizontal impact point,\n-- gives the projectile the carrier's current forward speed plus the\n-- reviewed three-meter-per-second release bonus (bounded by FA MaxSpeed), and applies\n-- the reviewed deterministic gravity fallback.\nUnitTemplate.additions = UnitTemplate.additions or {{}}\nUnitTemplate.additions.scoFaBomberAttackRun = {{\n    version = \"1.0.0\",\n    sourceBreakOffDistance = {1},\n    sourceBreakOffIfNearNewTarget = true,\n    sourceBreakOffTrigger = {2},\n    sourceEngageDistance = 50,\n    runtimePursueStandoff = 0,\n    runtimeMode = \"ReleaseBreakOffReentry\",\n}}\nUnitTemplate.additions.faSurfaceBomberSourceContract = {{\n    version = \"1.0.0\",\n    sourceArchiveSha256 = \"{3}\",\n    sourceUnitId = \"{4}\",\n    targetUnitId = \"{5}\",\n    sourceBlueprint = \"{6}\",\n    sourceBlueprintSha256 = \"{7}\",\n    sourceScript = \"{8}\",\n    sourceScriptSha256 = \"{9}\",\n    sourceProjectileArchiveSha256 = \"{10}\",\n    sourceProjectileId = \"{11}\",\n    sourceProjectileBlueprint = \"{12}\",\n    sourceProjectileBlueprintSha256 = \"{13}\",\n    sourceProjectileScript = \"{14}\",\n    sourceProjectileScriptSha256 = \"{15}\",\n    sourceProjectileMaxSpeed = {16},\n    sourceMaxAirspeed = {17},\n    sourceMinAirspeed = {18},\n    sourcePhysicsMaxSpeed = 0.5,\n{19}    nativeAhwassaSpeedScale = {20},\n    nativeGravityFallback = 4.9,\n    nativeGravitySourceOwned = false,\n    runtimeProjectileId = \"{21}\",\n}}\n\nlocal surfaceBombWeapon = UnitTemplate.weapons\n    and UnitTemplate.weapons[{22}]\nif surfaceBombWeapon == nil then\n    error(\"{23} requires its FA surface-bomb weapon\")\nend\nlocal surfaceBombMuzzles = surfaceBombWeapon.muzzles\nif surfaceBombMuzzles == nil\n    or surfaceBombMuzzles[\"{24}\"] == nil\nthen\n    error(\"{25} lost bomb muzzle {26}\")\nend\n\nsurfaceBombWeapon.name = \"Bomb\"\nsurfaceBombWeapon.aimControllers = {{\n    {{\n        aimBone = \"{27}\",\n        aimGravity = {{ x = 0, y = -4.9, z = 0 }},\n        aimTolerance = 180,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = false,\n        pitchBone = \"{28}\",\n        pitchMax = 0,\n        pitchMin = 0,\n        pitchSpeed = 0,\n        poseResetTime = -1,\n        projectileSpeed = 0.0001,\n        solverType = \"NoArc\",\n        yawBone = \"{29}\",\n        yawMax = 0,\n        yawMin = 0,\n        yawSpeed = 0,\n    }},\n}}\nsurfaceBombWeapon.collideFriendly = false\nsurfaceBombWeapon.damage = {30}\nsurfaceBombWeapon.damageFriendly = {31}\nsurfaceBombWeapon.damageRadius = {32}\nsurfaceBombWeapon.damageType = \"Normal\"\nsurfaceBombWeapon.firingRandomness = {33}\nsurfaceBombWeapon.layerTargetLimits = {{\n    \"Land\",\n    \"WaterSurface\",\n    \"Seabed\",\n}}\nsurfaceBombWeapon.layerWeaponLimits = {{ \"Air\" }}\nsurfaceBombWeapon.muzzleGroupChargeDelay = 0\nsurfaceBombWeapon.muzzleGroupTimeOut = -1\nsurfaceBombWeapon.muzzleGroups = {{\n    {{ muzzles = {{ \"{34}\" }} }},\n}}\nsurfaceBombWeapon.muzzles = {{\n    [\"{35}\"] = {{\n        aimController = \"{36}\",\n    }},\n}}\nsurfaceBombWeapon.muzzleSalvoDelay = 0\nsurfaceBombWeapon.muzzleSalvoSize = 1\nsurfaceBombWeapon.projectileLifetime = {37}\nsurfaceBombWeapon.projectileTemplate = \"{38}\"\nsurfaceBombWeapon.rangeMax = {39}\nsurfaceBombWeapon.rangeMin = 0\nsurfaceBombWeapon.rangeRingType = \"DirectFire\"\nsurfaceBombWeapon.rangeTracking = {40}\nsurfaceBombWeapon.reloadTime = {41}\nsurfaceBombWeapon.targetWaterLimits = \"Above\"\nsurfaceBombWeapon.scoFaBombDrop = {{\n    version = \"1.0.0\",\n    runtimeProjectileId = \"{42}\",\n    sourceNeedToComputeBombDrop = true,\n    sourceRealisticOrdinance = true,\n    sourceMuzzleVelocity = 0,\n    sourcePredictAheadForBombDrop = {43},\n    sourceBombDropThreshold = {44},\n    sourceProjectileMaxSpeed = {45},\n    runtimeAimProjectileSpeed = 0.0001,\n    runtimeForwardSpeedBonus = 3,\n    runtimeGravity = 4.9,\n    runtimeProjectileLifetime = {46},\n    runtimeReleaseMode = \"PredictedHorizontalImpactThreshold\",\n    runtimeVelocityMode = \"CarrierCurrentMovementSpeedPlusForwardBonus\",\n}}\n{47}", "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", Lua(bomber.BreakOffDistance), Lua(bomber.BreakOffTrigger), "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", bomber.SourceId, bomber.TargetId, bomber.SourceBlueprintPath, bomber.SourceBlueprintSha256, bomber.SourceScriptPath, bomber.SourceScriptSha256, "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12", bomber.SourceProjectileId, projectileSpec.SourceBlueprintPath, projectileSpec.SourceBlueprintSha256, projectileSpec.SourceScriptPath, projectileSpec.SourceScriptSha256, Lua(projectileSpec.SpeedMax), Lua(bomber.SourceMaxAirspeed), Lua(bomber.SourceMinAirspeed), text2, (bomber.TargetId == "usa4011") ? "0.5" : "1", bomber.ProjectileId, bomber.WeaponIndex, bomber.TargetId, bomber.MuzzleBone, bomber.TargetId, bomber.MuzzleBone, bomber.MuzzleBone, bomber.MuzzleBone, bomber.MuzzleBone, Lua(bomber.Damage), text, Lua(bomber.DamageRadius), Lua(bomber.FiringRandomness), bomber.MuzzleBone, bomber.MuzzleBone, bomber.MuzzleBone, Lua(bomber.ProjectileLifetime), bomber.ProjectileId, Lua(bomber.RangeMax), Lua(bomber.TrackingRadius), Lua(bomber.ReloadTime), bomber.ProjectileId, bomber.PredictAhead, Lua(bomber.BombDropThreshold), Lua(projectileSpec.SpeedMax), Lua(bomber.ProjectileLifetime), text3).Replace("\r\n", "\n");
	}

	private static string BuildUnitOverride(BomberSpec bomber)
	{
		double value = bomber.MinAirspeed / (Math.PI / 2.0);
		string text = FormatLuaStrings(BuildSourceCategories(bomber), 8);
		string text2 = FormatLuaStrings(BuildRuntimeTags(bomber), 4);
		string text3 = (bomber.AttackElevation.HasValue ? ("        sourceAttackElevation = " + Lua(bomber.AttackElevation.Value) + ",\n") : string.Empty);
		string text4 = (bomber.TightTurnMultiplier.HasValue ? ("        sourceTightTurnMultiplier = " + Lua(bomber.TightTurnMultiplier.Value) + ",\n") : string.Empty);
		string text5 = (bomber.RadarRadius.HasValue ? ("    radarRadius = " + Lua(bomber.RadarRadius.Value) + ",\n") : string.Empty);
		string text6 = (bomber.SonarRadius.HasValue ? ("    sonarRadius = " + Lua(bomber.SonarRadius.Value) + ",\n") : string.Empty);
		double value2 = ((bomber.Tier == 1) ? 0.7 : ((bomber.Tier == 2) ? 0.48 : 0.8));
		double value3 = ((bomber.Tier == 1) ? 0.7 : ((bomber.Tier == 2) ? 0.5 : 0.8));
		double value4 = ((bomber.Tier == 1) ? 3.0 : ((bomber.Tier == 2) ? 4.0 : 2.5));
		int num = ((bomber.Tier == 3) ? 30 : 20);
		int num2 = ((bomber.Tier == 2) ? 75 : 50);
		int num3 = ((bomber.Tier == 2) ? 4 : 2);
		double value5 = ((bomber.Tier == 1) ? 0.7 : ((bomber.Tier == 2) ? 1.0 : 0.8));
		int num4 = ((bomber.Tier == 3) ? 15 : 5);
		string text7 = ((bomber.Tier == 2) ? string.Empty : "        sourcePredictAheadForBombDrop = 3,\n");
		double value6 = bomber.TargetId switch
		{
			"uea1001" => 0.125, 
			"uea2301" => 0.04, 
			"uea3001" => 0.035, 
			"uga1001" => 0.1, 
			"uga2301" => 0.08, 
			"uga3001" => 0.2, 
			_ => throw new InvalidOperationException("No reviewed FA bomber scale exists for " + bomber.TargetId + "."), 
		};
		string text8 = ((bomber.TargetId == "uga3001") ? "true" : "false");
		int num5 = ((bomber.TargetId == "uga3001") ? 60 : 0);
		string text9 = ((bomber.TargetId == "uea1001") ? "true" : "false");
		string text10 = (bomber.IsTorpedo ? "Torpedo Bomber" : "Bomber");
		int num6 = (bomber.IsTorpedo ? 5 : 4);
		string text11 = (bomber.IsTorpedo ? string.Empty : $"UnitTemplate.additions.scoFaBomberAttackRun = {{\n    version = \"1.0.0\",\n    sourceBreakOffDistance = {Lua(bomber.BreakOffDistance)},\n    sourceBreakOffIfNearNewTarget = true,\n    sourceBreakOffTrigger = {num},\n    sourceEngageDistance = {num2},\n    runtimePursueStandoff = 0,\n    runtimeMode = \"ReleaseBreakOffReentry\",\n}}");
		return string.Format("\n{0}\n-- Installed FA units.scd is authoritative. Sanctuary exposes exact\n-- Plane speed, minimum speed, altitude, health, economy, intel, and\n-- weapon values. Controller coefficients without native fields stay\n-- pinned below; native fallbacks are explicit and deterministic.\nUnitTemplate.additions = UnitTemplate.additions or {{}}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {{\n    size = {{ x = {1}, y = {2} }},\n    offset = {{ x = 0, y = 0, z = 0 }},\n}}\n{3}\nUnitTemplate.additions.faSourceContract = {{\n    sourceId = \"{4}\",\n    targetId = \"{5}\",\n    sourceArchiveSha256 = \"{6}\",\n    sourceBlueprint = \"{7}\",\n    sourceBlueprintSha256 = \"{8}\",\n    sourceScript = \"{9}\",\n    sourceScriptSha256 = \"{10}\",\n    sourceUniformScale = {11},\n    sourceCategories = {{\n{12}\n    }},\n    collision = {{\n        centerOffset = {{ x = 0, y = {13}, z = {14} }},\n        size = {{ x = {15}, y = {16}, z = {17} }},\n    }},\n    selection = {{\n        size = {{ x = {18}, y = {19} }},\n        thickness = {20},\n    }},\n    footprint = {{ x = 1, y = 1, sourceMaxSlope = 0.25 }},\n    health = {{ max = {21}, regen = 0 }},\n    economy = {{\n        mass = {22},\n        energy = {23},\n        buildTime = {24},\n        sourceMaintenanceConsumptionPerSecondEnergy = {25},\n    }},\n    intel = {{\n        visionRadius = {26},\n        radarRadius = {27},\n        sonarRadius = {28},\n        sourceRadarStealth = {29},\n        nativeRadarStealthSupported = false,\n    }},\n    movement = {{\n        sourceMotionType = \"RULEUMT_Air\",\n        sourceElevation = {30},\n{31}        sourcePhysicsMaxSpeed = 0.5,\n        sourceMaxAirspeed = {32},\n        sourceMinAirspeed = {33},\n        sourceAutoLandTime = 1,\n        sourceBankFactor = {34},\n        sourceBankForward = false,\n        sourceBreakOffDistance = {35},\n        sourceBreakOffIfNearNewTarget = true,\n        sourceBreakOffTrigger = {36},\n        sourceCanFly = true,\n        sourceCombatTurnSpeed = {37},\n        sourceEngageDistance = {38},\n        sourceKLift = 3,\n        sourceKLiftDamping = 2.5,\n        sourceLiftFactor = 7,\n        sourceKMove = 1,\n        sourceKMoveDamping = {39},\n        sourceKRoll = 2,\n        sourceKRollDamping = {40},\n        sourceKTurn = {41},\n        sourceKTurnDamping = 1,\n{42}        sourceStartTurnDistance = 5,\n{43}        sourceTurnSpeed = {44},\n        sourceWinged = true,\n        sourceFuelRechargeRate = {45},\n        sourceFuelUseTime = {46},\n        nativeFuelSupported = false,\n        nativeAccelerationFallback = {47},\n        nativeRotationSpeedFallback = 90,\n        nativeOrbitRange = {48},\n        nativeOrbitSpeed = {49},\n    }},\n    limitations = {{\n        sourceEmitterGraphAvailable = false,\n        sourceFuelControllerAvailable = false,\n        sourceRadarStealthAvailable = false,\n        sourceControllerCoefficientsAvailable = false,\n        temporalPulseTimingPreserved = {50},\n        totalTemporalDamagePreserved = true,\n    }},\n    weapons = {{\n{51}\n    }},\n}}\n\nUnitTemplate.general.displayName = \"Tier {52}: {53}\"\nUnitTemplate.general.name = \"{54}\"\n\nUnitTemplate.collisionInfo = {{\n    centerOffset = {{ x = 0, y = {55}, z = {56} }},\n    collisionSize = {{ x = {57}, y = {58}, z = {59} }},\n}}\nUnitTemplate.footprint = {{ x = 1, y = 1 }}\nUnitTemplate.defence = {{\n    health = {{ max = {60}, regen = 0, value = {61} }},\n}}\nUnitTemplate.economy = {{\n    buildTime = {62},\n    cost = {{ alloys = {63}, energy = {64} }},\n}}\nUnitTemplate.intel = {{\n    visionRadius = {65},\n{66}{67}}}\n\nlocal SCO_BomberDonorPatterns = UnitTemplate.movement and UnitTemplate.movement.patterns\nlocal SCO_BomberDonorSituations = UnitTemplate.movement and UnitTemplate.movement.patternBySituation\nUnitTemplate.movement = {{\n    acceleration = {68},\n    air = true,\n    airHover = false,\n    altitudeJitterFactor = 1,\n    bankFactor = 1,\n    collisionMaskDefault = {{ \"Air\" }},\n    collisionMaskSpawn = {{ \"LandSmall\" }},\n    landWhenIdleSeconds = 1,\n    minSpeed = {69},\n    orbitRange = {70},\n    orbitSpeed = {71},\n    preferredAltitude = {72},\n    referenceAltitude = \"GroundOrWater\",\n    rotationSpeed = 90,\n    sortOrder = {73},\n    speed = {74},\n    terrainAlignmentFactor = 0,\n    type = \"Plane\",\n}}\nUnitTemplate.tags = {{\n{75}\n}}\nUnitTemplate.turrets = nil\n{76}\n\n-- None of the six FA source bombers references an SCA animation.\n-- Donor exhaust bones are invalid for the converted source skeletons.\nUnitTemplate.visuals = UnitTemplate.visuals or {{}}\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {{}}\nUnitTemplate.visuals.selection.size = {{ x = {77}, y = {78} }}\nUnitTemplate.visuals.selection.offset = {{ x = 0, y = 0 }}\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do\n            effect.boneName = \"Root\"\n        end\n    end\nend\nUnitTemplate.movement.patterns = SCO_BomberDonorPatterns\nUnitTemplate.movement.patternBySituation = SCO_BomberDonorSituations\n", "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", Lua(bomber.SelectionX), Lua(bomber.SelectionZ), text11, bomber.SourceId, bomber.TargetId, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", bomber.SourceBlueprintPath, bomber.SourceBlueprintSha256, bomber.SourceScriptPath, bomber.SourceScriptSha256, Lua(value6), text, Lua(bomber.CollisionOffsetY), Lua(bomber.CollisionOffsetZ), Lua(bomber.CollisionX), Lua(bomber.CollisionY), Lua(bomber.CollisionZ), Lua(bomber.SelectionX), Lua(bomber.SelectionZ), Lua(bomber.SelectionThickness), bomber.Health, Lua(bomber.MassCost), Lua(bomber.EnergyCost), Lua(bomber.BuildTime), num5, Lua(bomber.VisionRadius), Lua(bomber.RadarRadius.GetValueOrDefault()), Lua(bomber.SonarRadius.GetValueOrDefault()), text8, Lua(bomber.Elevation), text3, Lua(bomber.MaxAirspeed), Lua(bomber.MinAirspeed), Lua(value4), Lua(bomber.BreakOffDistance), num, Lua(value3), num2, Lua(bomber.KMoveDamping), num3, Lua(value5), text7, text4, Lua(value2), num4, Lua(bomber.FuelUseTime), Lua(bomber.MaxAirspeed), Lua(value), Lua(bomber.MinAirspeed), text9, BuildWeaponContract(bomber), bomber.Tier, text10, bomber.Name, Lua(bomber.CollisionOffsetY), Lua(bomber.CollisionOffsetZ), Lua(bomber.CollisionX), Lua(bomber.CollisionY), Lua(bomber.CollisionZ), bomber.Health, bomber.Health, Lua(bomber.BuildTime), Lua(bomber.MassCost), Lua(bomber.EnergyCost), Lua(bomber.VisionRadius), text5, text6, Lua(bomber.MaxAirspeed), Lua(bomber.MinAirspeed), Lua(value), Lua(bomber.MinAirspeed), Lua(bomber.Elevation), num6, Lua(bomber.MaxAirspeed), text2, BuildWeapons(bomber), Lua(bomber.SelectionX), Lua(bomber.SelectionZ)).Replace("\r\n", "\n");
	}

	private static IReadOnlyList<string> BuildSourceCategories(BomberSpec bomber)
	{
		List<string> list = new List<string> { "PRODUCTSC1", "SELECTABLE" };
		if (bomber.Tier == 1)
		{
			list.AddRange(new string[3] { "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY" });
		}
		else if (bomber.Tier == 2)
		{
			list.AddRange(new string[2] { "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY" });
		}
		else
		{
			list.Add("BUILTBYTIER3FACTORY");
		}
		list.AddRange(new string[5]
		{
			bomber.FactionCategory,
			"MOBILE",
			"AIR",
			"HIGHALTAIR",
			"TECH" + bomber.Tier
		});
		if (bomber.Tier == 2)
		{
			list.Add("ANTINAVY");
		}
		list.Add("BOMBER");
		if (bomber.TargetId == "uea3001")
		{
			list.Add("NUKE");
		}
		list.AddRange(new string[2] { "VISIBLETORECON", "RECLAIMABLE" });
		if (!bomber.IsUef || bomber.Tier == 3)
		{
			list.Add("SHOWATTACKRETICLE");
		}
		if (bomber.Tier == 2)
		{
			list.Add("OVERLAYSONAR");
		}
		else
		{
			if (bomber.Tier == 3)
			{
				list.Add("OVERLAYANTIAIR");
			}
			list.Add("OVERLAYRADAR");
		}
		return list;
	}

	private static IReadOnlyList<string> BuildRuntimeTags(BomberSpec bomber)
	{
		List<string> list = new List<string> { "AIR" };
		list.Add(bomber.IsTorpedo ? "ANTI_NAVY" : "ANTI_SURFACE");
		if (bomber.HasAntiAir)
		{
			list.Add("ANTI_AIR");
		}
		list.Add("BOMBER");
		if (bomber.Tier == 1)
		{
			list.AddRange(new string[3] { "BUILDABLE_BY_T1_FACTORY", "BUILDABLE_BY_T2_FACTORY", "BUILDABLE_BY_T3_FACTORY" });
		}
		else if (bomber.Tier == 2)
		{
			list.AddRange(new string[2] { "BUILDABLE_BY_T2_FACTORY", "BUILDABLE_BY_T3_FACTORY" });
		}
		else
		{
			list.Add("BUILDABLE_BY_T3_FACTORY");
		}
		list.Add("DIRECT_FIRE");
		list.Add(bomber.FactionTag);
		if (bomber.IsTorpedo)
		{
			list.AddRange(new string[2] { "INTEL", "SONAR" });
		}
		list.AddRange(new string[2]
		{
			"MOBILE",
			"TECH" + bomber.Tier
		});
		if (bomber.IsTorpedo)
		{
			list.Add("TORPEDO_BOMBER");
		}
		return list;
	}

	private static string FormatLuaStrings(IEnumerable<string> values, int spaces)
	{
		string indent = new string(' ', spaces);
		return string.Join("\n", values.Select((string value) => indent + "\"" + value + "\","));
	}

	private static string BuildWeaponContract(BomberSpec bomber)
	{
		return (bomber.TargetId switch
		{
			"uea1001" => "    {\n        label = \"Bomb\",\n        sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n        sourceProjectile = \"projectiles/TIFNapalmCarpetBomb01/TIFNapalmCarpetBomb01_proj.bp\",\n        sourceProjectileSha256 = \"58a4511cb4d575f5f8b96dd51be654b4b4662ec67fdfa05ad139c70322680954\",\n        sourceProjectileScript = \"projectiles/TIFNapalmCarpetBomb01/TIFNapalmCarpetBomb01_script.lua\",\n        sourceProjectileScriptSha256 = \"fb52ef413bec3ed05de3e92641259cd89b1e595932f327ba65aa67b922961b25\",\n        rackBone = \"Projectile\",\n        muzzleBones = { \"Projectile\" },\n        sourceDamage = 4,\n        sourceDamageRadius = 2.5,\n        sourceDoTPulses = 15,\n        sourceDoTTime = 1.5,\n        runtimeDamageCarrier = 60,\n        runtimeDirectDamage = 0,\n        runtimeDamageOverTimePulseCount = 15,\n        runtimeDamageOverTimePulseDamage = 4,\n        runtimeDamageOverTimePulseIntervalTicks = 1,\n        runtimeDamageOverTimeDurationSeconds = 1.5,\n        runtimeTotalDamage = 60,\n        runtimeTemporalPulseMode = \"FixedImpactAreaGlobalThread\",\n        maxRadius = 40,\n        minRadius = 0,\n        muzzleVelocity = 0,\n        sourceNeedToComputeBombDrop = true,\n        sourceBombDropThreshold = 3,\n        sourcePredictAheadForBombDrop = 3,\n        sourceFiringTolerance = 3,\n        sourceRealisticOrdinance = true,\n        sourceProjectileMaxSpeed = 20,\n        runtimeAimProjectileSpeed = 0.0001,\n        runtimeForwardSpeedBonus = 3,\n        runtimeGravity = 4.9,\n        runtimeProjectileLifetime = 8,\n        runtimeVelocityMode = \"CarrierCurrentMovementSpeedPlusForwardBonus\",\n        runtimeReleaseMode = \"PredictedHorizontalImpactThreshold\",\n        muzzleSalvoDelay = 0.2,\n        muzzleSalvoSize = 5,\n        projectilesPerOnFire = 5,\n        rateOfFire = 0.5,\n        runtimeReloadTime = 2,\n        targetLayerCaps = { \"Land\", \"Water\", \"Seabed\" },\n    },\n    { label = \"DeathImpact\", damage = 100, damageRadius = 1, damageFriendly = true },", 
			"uea2301" => "    {\n        label = \"Torpedo\",\n        sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n        sourceProjectile = \"projectiles/TANAnglerTorpedo06/TANAnglerTorpedo06_proj.bp\",\n        sourceProjectileSha256 = \"55e293247e1e0c3675563582954ccbc5b0eee894475abb09eeba0fb4bc90971b\",\n        sourceProjectileScript = \"projectiles/TANAnglerTorpedo06/TANAnglerTorpedo06_script.lua\",\n        sourceProjectileScriptSha256 = \"d35c124b1be07811a2acf7436ebb1ba9b95017b19bd3d22bf0ca8125fbef8dac\",\n        rackBone = \"Projectile\",\n        muzzleBones = { \"Projectile\", \"Projectile\" },\n        sourceDamage = 375,\n        sourceDamageRadius = 0,\n        runtimeDamage = 375,\n        maxRadius = 42,\n        minRadius = 4,\n        muzzleVelocity = 14,\n        projectileLifetime = 20,\n        muzzleSalvoDelay = 1.8,\n        muzzleSalvoSize = 2,\n        projectilesPerOnFire = 2,\n        rateOfFire = 0.08,\n        runtimeReloadTime = 12.5,\n        sourceWaterEntryTurnRate = 240,\n        sourceWaterEntryMaxSpeed = 18,\n        runtimeWaterEntryMode = \"ContinuousHoming\",\n        targetLayerCaps = { \"Seabed\", \"Water\" },\n    },\n    { label = \"DeathImpact\", damage = 150, damageRadius = 1, damageFriendly = true },", 
			"uea3001" => "    {\n        label = \"Bomb\",\n        sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n        sourceProjectile = \"projectiles/TIFSmallYieldNuclearBomb01/TIFSmallYieldNuclearBomb01_proj.bp\",\n        sourceProjectileSha256 = \"808c092a0d3f6fe101050af17f22705fa7a72cdf96842a7962200efc8fc5d36a\",\n        sourceProjectileScript = \"projectiles/TIFSmallYieldNuclearBomb01/TIFSmallYieldNuclearBomb01_script.lua\",\n        sourceProjectileScriptSha256 = \"d9c88f50f05988fc6e7565135c8b76515220f83250481a2fa2a4dbd958613a77\",\n        rackBone = \"Projectile02\",\n        muzzleBones = { \"Projectile02\" },\n        sourceDamage = 3000,\n        sourceDamageRadius = 6,\n        runtimeDamage = 3000,\n        maxRadius = 90,\n        minRadius = 0,\n        muzzleVelocity = 0,\n        sourceNeedToComputeBombDrop = true,\n        sourceBombDropThreshold = 3.5,\n        sourcePredictAheadForBombDrop = 3,\n        sourceFiringTolerance = 3,\n        sourceRealisticOrdinance = true,\n        sourceProjectileMaxSpeed = 20,\n        runtimeAimProjectileSpeed = 0.0001,\n        runtimeForwardSpeedBonus = 3,\n        runtimeGravity = 4.9,\n        runtimeProjectileLifetime = 8,\n        runtimeVelocityMode = \"CarrierCurrentMovementSpeedPlusForwardBonus\",\n        runtimeReleaseMode = \"PredictedHorizontalImpactThreshold\",\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectilesPerOnFire = 1,\n        rateOfFire = 0.2,\n        runtimeReloadTime = 5,\n    },\n    {\n        label = \"LinkedRailGun1\",\n        sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n        sourceProjectile = \"projectiles/TAARailgun01/TAARailgun01_proj.bp\",\n        sourceProjectileSha256 = \"27f4839a8b5b048073055a42fc728537303e8fae0a28266fe6674fbdb18bbc8f\",\n        sourceProjectileScript = \"projectiles/TAARailgun01/TAARailgun01_script.lua\",\n        sourceProjectileScriptSha256 = \"36c2417368fb105b30325e2ee1fa1f63f51c79ddf18e0fece8842108333cd92e\",\n        runtimeProjectileOwnedBy = \"fa-air-fighters\",\n        rackBone = \"Left_Barrel_AA\",\n        muzzleBones = { \"Left_Muzzle_AA\" },\n        sourceDamage = 16,\n        runtimeDamage = 16,\n        sourceFiringTolerance = 0,\n        runtimeAimTolerance = 0.1,\n        runtimeAimToleranceMode = \"MinimumPositiveSanctuaryFallback\",\n        maxRadius = 44,\n        muzzleVelocity = 45,\n        projectileLifetimeUsesMultiplier = 1.25,\n        rateOfFire = 1.5,\n    },\n    {\n        label = \"LinkedRailGun2\",\n        runtimeProjectileOwnedBy = \"fa-air-fighters\",\n        rackBone = \"Right_Barrel_AA\",\n        muzzleBones = { \"Right_Muzzle_AA\" },\n        sourceDamage = 16,\n        runtimeDamage = 16,\n        sourceFiringTolerance = 0,\n        runtimeAimTolerance = 0.1,\n        runtimeAimToleranceMode = \"MinimumPositiveSanctuaryFallback\",\n        maxRadius = 44,\n        muzzleVelocity = 45,\n        projectileLifetimeUsesMultiplier = 1.25,\n        rateOfFire = 1.5,\n        prefersPrimaryWeaponTarget = true,\n    },\n    { label = \"DeathImpact\", damage = 500, damageRadius = 1, damageFriendly = true },", 
			"uga1001" => "    {\n        label = \"Bomb\",\n        sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n        sourceProjectile = \"projectiles/CIFNeutronClusterBomb01/CIFNeutronClusterBomb01_proj.bp\",\n        sourceProjectileSha256 = \"d8d893a306a94ef13e6b660c72a2f8023598f7fba27752ecc21c88da9e8ed399\",\n        sourceProjectileScript = \"projectiles/CIFNeutronClusterBomb01/CIFNeutronClusterBomb01_script.lua\",\n        sourceProjectileScriptSha256 = \"39740ef89c603eb5b01989afdefd2f0c9745f8b227b056c24a5d7502af326875\",\n        rackBone = \"Muzzle_L03\",\n        muzzleBones = { \"Muzzle_L03\", \"Muzzle_R03\", \"Muzzle_L02\", \"Muzzle_R02\", \"Muzzle_L01\", \"Muzzle_R01\" },\n        sourceDamage = 50,\n        sourceDamageRadius = 3,\n        runtimeDamage = 50,\n        maxRadius = 40,\n        minRadius = 0,\n        muzzleVelocity = 0,\n        sourceNeedToComputeBombDrop = true,\n        sourceBombDropThreshold = 3,\n        sourcePredictAheadForBombDrop = 3,\n        sourceFiringTolerance = 3,\n        sourceRealisticOrdinance = true,\n        sourceProjectileMaxSpeed = 25,\n        runtimeAimProjectileSpeed = 0.0001,\n        runtimeForwardSpeedBonus = 3,\n        runtimeGravity = 4.9,\n        runtimeProjectileLifetime = 8,\n        runtimeVelocityMode = \"CarrierCurrentMovementSpeedPlusForwardBonus\",\n        runtimeReleaseMode = \"PredictedHorizontalImpactThreshold\",\n        muzzleSalvoDelay = 0.2,\n        muzzleSalvoSize = 6,\n        projectilesPerOnFire = 6,\n        rateOfFire = 0.5,\n        runtimeReloadTime = 2,\n        targetLayerCaps = { \"Land\", \"Water\", \"Seabed\" },\n    },\n    { label = \"DeathImpact\", damage = 100, damageRadius = 1, damageFriendly = true },", 
			"uga2301" => "    {\n        label = \"Bomb\",\n        sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n        sourceProjectile = \"projectiles/CANTorpedoNanite03/CANTorpedoNanite03_proj.bp\",\n        sourceProjectileSha256 = \"07cabdfb78f90b37c86ed7bc45a8b795f221425ed36a13f2cd1d8092790e90f7\",\n        sourceProjectileScript = \"projectiles/CANTorpedoNanite03/CANTorpedoNanite03_script.lua\",\n        sourceProjectileScriptSha256 = \"de8af2f4a66f566dc2463030c02661977f9f033bb73c7593373f922f8a114ab6\",\n        rackBone = \"TorpedoL\",\n        muzzleBones = { \"TorpedoL\", \"TorpedoR\" },\n        sourceDamage = 75,\n        sourceDamageRadius = 0,\n        sourceDoTPulses = 5,\n        sourceDoTTime = 1,\n        runtimeDamage = 375,\n        runtimeTemporalPulseMode = \"CollapsedEqualTotal\",\n        maxRadius = 42,\n        minRadius = 4,\n        muzzleVelocity = 14,\n        projectileLifetime = 20,\n        muzzleSalvoDelay = 1.8,\n        muzzleSalvoSize = 2,\n        projectilesPerOnFire = 2,\n        rateOfFire = 0.08,\n        runtimeReloadTime = 12.5,\n        sourceWaterEntryTurnRate = 240,\n        sourceMaxZigZag = 0.5,\n        sourceZigZagFrequency = 1,\n        runtimeZigZagAvailable = false,\n        targetLayerCaps = { \"Seabed\", \"Water\" },\n    },\n    { label = \"DeathImpact\", damage = 150, damageRadius = 1, damageFriendly = true },", 
			"uga3001" => "    {\n        label = \"Bomb\",\n        sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n        sourceProjectile = \"projectiles/CIFProtonBomb01/CIFProtonBomb01_proj.bp\",\n        sourceProjectileSha256 = \"8cce9628c7c2af978337c8ff38a0f6aee6be00bc1db49cf83132472205d30a89\",\n        sourceProjectileScript = \"projectiles/CIFProtonBomb01/CIFProtonBomb01_script.lua\",\n        sourceProjectileScriptSha256 = \"f6ec5c492cb0dc5bead4b07c6b8dd679b930f98d9749b0e3bb7a760522b91a7c\",\n        rackBone = \"Projectile01\",\n        muzzleBones = { \"Projectile01\" },\n        sourceDamage = 2750,\n        sourceDamageRadius = 7,\n        runtimeDamage = 2750,\n        maxRadius = 90,\n        minRadius = 0,\n        muzzleVelocity = 0,\n        sourceNeedToComputeBombDrop = true,\n        sourceBombDropThreshold = 3.5,\n        sourcePredictAheadForBombDrop = 3,\n        sourceFiringTolerance = 3,\n        sourceRealisticOrdinance = true,\n        sourceProjectileMaxSpeed = 20,\n        runtimeAimProjectileSpeed = 0.0001,\n        runtimeForwardSpeedBonus = 3,\n        runtimeGravity = 4.9,\n        runtimeProjectileLifetime = 8,\n        runtimeVelocityMode = \"CarrierCurrentMovementSpeedPlusForwardBonus\",\n        runtimeReleaseMode = \"PredictedHorizontalImpactThreshold\",\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectilesPerOnFire = 1,\n        rateOfFire = 0.2,\n        runtimeReloadTime = 5,\n    },\n    {\n        label = \"AAGun1\",\n        sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n        sourceProjectile = \"projectiles/CAAAutocannon01/CAAAutocannon01_proj.bp\",\n        sourceProjectileSha256 = \"0460b42285f54f1b3cd041b431805ab8a0d54c1d6246c0ba26d6980156f19152\",\n        sourceProjectileScript = \"projectiles/CAAAutocannon01/CAAAutocannon01_script.lua\",\n        sourceProjectileScriptSha256 = \"7aaff4e111849bbf457f95985bd862fd91fc2f8be82f4719cb757c3091cb0975\",\n        rackBone = \"Left_Barrel_AA\",\n        muzzleBones = { \"Left_Muzzle_AA_01\", \"Left_Muzzle_AA_02\" },\n        sourceDamage = 5,\n        runtimeDamage = 5,\n        sourceFiringTolerance = 0,\n        runtimeAimTolerance = 0.1,\n        runtimeAimToleranceMode = \"MinimumPositiveSanctuaryFallback\",\n        maxRadius = 44,\n        muzzleVelocity = 45,\n        projectileLifetimeUsesMultiplier = 1.25,\n        rateOfFire = 1.5,\n    },\n    {\n        label = \"AAGun2\",\n        rackBone = \"Right_Barrel_AA\",\n        muzzleBones = { \"Right_Muzzle_AA_01\", \"Right_Muzzle_AA_02\" },\n        sourceDamage = 5,\n        runtimeDamage = 5,\n        sourceFiringTolerance = 0,\n        runtimeAimTolerance = 0.1,\n        runtimeAimToleranceMode = \"MinimumPositiveSanctuaryFallback\",\n        maxRadius = 44,\n        muzzleVelocity = 45,\n        projectileLifetimeUsesMultiplier = 1.25,\n        rateOfFire = 1.5,\n        prefersPrimaryWeaponTarget = true,\n    },\n    { label = \"DeathImpact\", damage = 500, damageRadius = 1, damageFriendly = true },", 
			_ => throw new InvalidOperationException("No reviewed FA bomber weapon contract exists for " + bomber.TargetId + "."), 
		}).Replace("\r\n", "\n");
	}

	private static string BuildWeapons(BomberSpec bomber)
	{
		return ("local function SCO_FaBomberFixedAim(\n    muzzle,\n    projectileSpeed,\n    bombDropThreshold)\n    return {\n        aimBone = muzzle,\n        aimGravity = bombDropThreshold and {\n            x = 0,\n            y = -4.9,\n            z = 0,\n        } or nil,\n        aimTolerance = 180,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = false,\n        pitchBone = muzzle,\n        pitchMax = 0,\n        pitchMin = 0,\n        pitchSpeed = 0,\n        poseResetTime = -1,\n        projectileSpeed = projectileSpeed,\n        solverType = \"NoArc\",\n        yawBone = muzzle,\n        yawMax = 0,\n        yawMin = 0,\n        yawSpeed = 0,\n    }\nend\n\nlocal function SCO_FaBomberFixedWeapon(\n    name,\n    muzzleSequence,\n    projectileTemplate,\n    projectileSpeed,\n    damage,\n    damageRadius,\n    reloadTime,\n    rangeMin,\n    rangeMax,\n    rangeTracking,\n    projectileLifetime,\n    muzzleSalvoSize,\n    muzzleSalvoDelay,\n    firingRandomness,\n    damageFriendly,\n    bombDropThreshold,\n    sourceProjectileMaxSpeed,\n    targetLayers,\n    rangeRingType\n)\n    local aimControllers = {}\n    local muzzleGroups = {}\n    local muzzles = {}\n    local seen = {}\n    for _, muzzle in ipairs(muzzleSequence) do\n        if not seen[muzzle] then\n            table.insert(aimControllers, SCO_FaBomberFixedAim(\n                muzzle,\n                projectileSpeed,\n                bombDropThreshold))\n            muzzles[muzzle] = { aimController = muzzle }\n            seen[muzzle] = true\n        end\n        table.insert(muzzleGroups, { muzzles = { muzzle } })\n    end\n    local weapon = {\n        name = name,\n        aimControllers = aimControllers,\n        collideFriendly = false,\n        damage = damage,\n        damageFriendly = damageFriendly,\n        damageRadius = damageRadius,\n        damageType = \"Normal\",\n        firingRandomness = firingRandomness,\n        layerTargetLimits = targetLayers,\n        layerWeaponLimits = { \"Air\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        muzzleGroups = muzzleGroups,\n        muzzles = muzzles,\n        muzzleSalvoDelay = muzzleSalvoDelay,\n        muzzleSalvoSize = muzzleSalvoSize,\n        projectileLifetime = projectileLifetime,\n        projectileTemplate = projectileTemplate,\n        rangeMax = rangeMax,\n        rangeMin = rangeMin,\n        rangeRingType = rangeRingType,\n        rangeTracking = rangeTracking,\n        reloadTime = reloadTime,\n        targetWaterLimits = \"Above\",\n    }\n    if bombDropThreshold ~= nil then\n        weapon.scoFaBombDrop = {\n            version = \"1.0.0\",\n            runtimeProjectileId = projectileTemplate,\n            sourceNeedToComputeBombDrop = true,\n            sourceRealisticOrdinance = true,\n            sourceMuzzleVelocity = 0,\n            sourcePredictAheadForBombDrop = 3,\n            sourceBombDropThreshold = bombDropThreshold,\n            sourceProjectileMaxSpeed = sourceProjectileMaxSpeed,\n            runtimeAimProjectileSpeed = projectileSpeed,\n            runtimeForwardSpeedBonus = 3,\n            runtimeGravity = 4.9,\n            runtimeProjectileLifetime = projectileLifetime,\n            runtimeReleaseMode = \"PredictedHorizontalImpactThreshold\",\n            runtimeVelocityMode = \"CarrierCurrentMovementSpeedPlusForwardBonus\",\n        }\n    end\n    return weapon\nend\n\nlocal function SCO_FaBomberAAWeapon(name, rackBone, muzzleSequence, projectileTemplate, damage)\n    local firstMuzzle = muzzleSequence[1]\n    local muzzles = {}\n    for _, muzzle in ipairs(muzzleSequence) do\n        muzzles[muzzle] = { aimController = firstMuzzle }\n    end\n    return {\n        name = name,\n        aimControllers = {\n            {\n                aimBone = firstMuzzle,\n                -- FA authors zero tolerance, but Sanctuary rejects\n                -- non-positive aim tolerance before prefab creation.\n                -- 0.1 is the engine's minimum reviewed fallback and\n                -- leaves every other source aiming field unchanged.\n                aimTolerance = 0.1,\n                defaultPitchAdjustment = 0,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = rackBone,\n                pitchMax = 40,\n                pitchMin = -40,\n                pitchSpeed = 360,\n                poseResetTime = 0,\n                projectileSpeed = 45,\n                solverType = \"NoArc\",\n                yawBone = rackBone,\n                yawMax = 55,\n                yawMin = -55,\n                yawSpeed = 360,\n            },\n        },\n        collideFriendly = false,\n        damage = damage,\n        damageFriendly = false,\n        damageRadius = 0,\n        damageType = \"Normal\",\n        firingRandomness = 0,\n        layerTargetLimits = { \"Air\" },\n        layerWeaponLimits = { \"Air\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        -- FA fires every rack muzzle together whenever its source\n        -- MuzzleSalvoDelay is zero. One Sanctuary muzzle group is\n        -- the exact equivalent; Cybran racks therefore emit both\n        -- numbered autocannon rounds per firing cycle.\n        muzzleGroups = { { muzzles = muzzleSequence } },\n        muzzles = muzzles,\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 1.2222222222222223,\n        projectileTemplate = projectileTemplate,\n        rangeMax = 44,\n        rangeMin = 0,\n        rangeRingType = \"AntiAir\",\n        rangeTracking = 1.4,\n        reloadTime = 0.6666666666666666,\n        targetWaterLimits = \"Above\",\n    }\nend\n\nlocal function SCO_FaBomberDeathWeapon(damage)\n    return {\n        category = \"DeathExplosion\",\n        damage = damage,\n        damageFriendly = true,\n        damageRadius = 1,\n        damageType = \"Normal\",\n    }\nend\n" + bomber.TargetId switch
		{
			"uea1001" => "UnitTemplate.weapons = {\n    -- The positive 60 value is only a HostProjectile carrier;\n    -- the collision hook suppresses that direct area call and\n    -- applies FA's exact 15 x 4 fixed-position pulse sequence.\n    SCO_FaBomberFixedWeapon(\n        \"Bomb\", { \"Projectile\" }, \"peb101\", 0.0001,\n        60, 2.5, 2, 0, 40, 1.25, 8, 5, 0.2, 3, false, 3, 20,\n        { \"Land\", \"WaterSurface\", \"Seabed\" }, \"DirectFire\"),\n    SCO_FaBomberDeathWeapon(100),\n}", 
			"uea2301" => "UnitTemplate.weapons = {\n    SCO_FaBomberFixedWeapon(\n        \"Torpedo\", { \"Projectile\", \"Projectile\" }, \"peb231\", 14,\n        375, 0, 12.5, 4, 42, 1.15, 20, 2, 1.8, 3, false,\n        nil, nil, { \"Seabed\", \"Water\", \"WaterSurface\" }, \"AntiNaval\"),\n    SCO_FaBomberDeathWeapon(150),\n}", 
			"uea3001" => "UnitTemplate.weapons = {\n    SCO_FaBomberFixedWeapon(\n        \"Bomb\", { \"Projectile02\" }, \"peb301\", 0.0001,\n        3000, 6, 5, 0, 90, 1.15, 8, 1, 0, 0, true, 3.5, 20,\n        { \"Land\", \"WaterSurface\", \"Seabed\" }, \"DirectFire\"),\n    SCO_FaBomberAAWeapon(\n        \"LinkedRailGun1\", \"Left_Barrel_AA\", { \"Left_Muzzle_AA\" },\n        \"pef102\", 16),\n    SCO_FaBomberAAWeapon(\n        \"LinkedRailGun2\", \"Right_Barrel_AA\", { \"Right_Muzzle_AA\" },\n        \"pef102\", 16),\n    SCO_FaBomberDeathWeapon(500),\n}", 
			"uga1001" => "UnitTemplate.weapons = {\n    SCO_FaBomberFixedWeapon(\n        \"Bomb\",\n        { \"Muzzle_L03\", \"Muzzle_R03\", \"Muzzle_L02\", \"Muzzle_R02\", \"Muzzle_L01\", \"Muzzle_R01\" },\n        \"pgb101\", 0.0001, 50, 3, 2, 0, 40, 1.25, 8, 6, 0.2, 3, true, 3, 25,\n        { \"Land\", \"WaterSurface\", \"Seabed\" }, \"DirectFire\"),\n    SCO_FaBomberDeathWeapon(100),\n}", 
			"uga2301" => "UnitTemplate.weapons = {\n    -- FA delivers 75 damage over five temporal pulses. The\n    -- unsupported one-second cadence is collapsed to its exact\n    -- 375 total. FA zigzag remains pinned in faSourceContract.\n    SCO_FaBomberFixedWeapon(\n        \"Bomb\", { \"TorpedoL\", \"TorpedoR\" }, \"pgb231\", 14,\n        375, 0, 12.5, 4, 42, 1.15, 20, 2, 1.8, 3, false,\n        nil, nil, { \"Seabed\", \"Water\", \"WaterSurface\" }, \"AntiNaval\"),\n    SCO_FaBomberDeathWeapon(150),\n}", 
			"uga3001" => "UnitTemplate.weapons = {\n    SCO_FaBomberFixedWeapon(\n        \"Bomb\", { \"Projectile01\" }, \"pgb301\", 0.0001,\n        2750, 7, 5, 0, 90, 1.15, 8, 1, 0, 0, true, 3.5, 20,\n        { \"Land\", \"WaterSurface\", \"Seabed\" }, \"DirectFire\"),\n    SCO_FaBomberAAWeapon(\n        \"AAGun1\", \"Left_Barrel_AA\",\n        { \"Left_Muzzle_AA_01\", \"Left_Muzzle_AA_02\" }, \"pgb302\", 5),\n    SCO_FaBomberAAWeapon(\n        \"AAGun2\", \"Right_Barrel_AA\",\n        { \"Right_Muzzle_AA_01\", \"Right_Muzzle_AA_02\" }, \"pgb302\", 5),\n    SCO_FaBomberDeathWeapon(500),\n}", 
			_ => throw new InvalidOperationException("No reviewed runtime weapon set exists for " + bomber.TargetId + "."), 
		}).Replace("\r\n", "\n");
	}

	private static string BuildVirtualProjectile(ProjectileSpec projectile)
	{
		bool flag;
		switch (projectile.Id)
		{
		case "pab101":
		case "peb101":
		case "pgb101":
		case "psb101":
		case "pab301":
		case "peb301":
		case "pgb301":
		case "psb301":
		case "psb202":
		case "psb402":
			flag = true;
			break;
		default:
			flag = false;
			break;
		}
		bool flag2 = flag;
		string text = ((projectile.Id == "peb101") ? "false" : "true");
		string text2 = ((projectile.Id == "peb101") ? "        scoFaBomberGroundFire = {\n            version = \"1.0.0\",\n            sourceId = \"TIFNapalmCarpetBomb01\",\n            runtimeProjectileId = \"peb101\",\n            pulseCount = 15,\n            pulseDamage = 4,\n            pulseIntervalTicks = 1,\n            durationSeconds = 1.5,\n            damageRadius = 2.5,\n            damageFriendly = false,\n            impactVfx = \"VFX/SupremeCommanderOverhaul/Bombers/scorcher_napalm_ground_fire.sanvfx\",\n        }," : string.Empty);
		string text3 = ((projectile.Id.StartsWith("pab", StringComparison.Ordinal) || projectile.Id.StartsWith("psb", StringComparison.Ordinal)) ? ("    scoFaDestroyOnWater = {\n        version = \"1.0.0\",\n        sourceId = \"" + projectile.SourceId + "\",\n        runtimeProjectileId = \"" + projectile.Id + "\",\n        sourceDestroyOnWater = true,\n        runtimeMode = \"HostPreCollisionWaterlineCull\",\n    },") : string.Empty);
		string text4 = (flag2 ? ("    additions = {\n        scoFaBomberImpact = {\n            version = \"1.0.0\",\n            runtimeProjectileId = \"" + projectile.Id + "\",\n            damageFriendly = " + text + ",\n        },\n    " + text2 + text3 + "},") : string.Empty);
		string text5 = (projectile.Torpedo ? ("    movement = {\n        acceleration = " + Lua(projectile.Acceleration) + ",\n        alignToVelocity = true,\n        gravityMultiplier = 0,\n        rotationSpeed = " + Lua(projectile.RotationSpeed) + ",\n        speedMax = " + Lua(projectile.SpeedMax) + ",\n        type = \"TargetEntity\",\n    },\n    timeToLive = " + Lua(projectile.Lifetime) + ",") : ((projectile.Id == "pgb302") ? string.Empty : ("    isBomb = true,\n    speed = " + Lua(projectile.SpeedMax) + ",\n    timeToLive = " + Lua(projectile.Lifetime) + ",")));
		string text6 = projectile.Id switch
		{
			"pab101" => "source MaxSpeed=40; realistic ordnance; MuzzleVelocity=0; PredictAheadForBombDrop=3; DestroyOnWater=true", 
			"pab301" => "source realistic ordnance; MuzzleVelocity=0; PredictAheadForBombDrop=3; TurnRate=0; DestroyOnWater=true", 
			"peb101" => "sourceMaxSpeed=20; realistic ordnance; TurnRate=360; DestroyOnWater=true", 
			"peb231" => "source Initial/MaxSpeed=14 and TurnRate=230; water-entry runtime MaxSpeed=18 and TurnRate=240", 
			"peb301" => "source realistic ordnance; no explicit speed/lifetime; TurnRate=360", 
			"pgb101" => "source MaxSpeed=25; realistic ordnance; TurnRate=30; child visual burst unavailable", 
			"pgb231" => "source Initial/MaxSpeed=14 and TurnRate=230; water-entry TurnRate=240; zigzag unavailable", 
			"pgb301" => "source realistic ordnance; no explicit speed/lifetime; TurnRate=0; ambient effect children unavailable", 
			"pgb302" => "source InitialSpeed=35; Lifetime=1.5; weapon MuzzleVelocity=45; gravity-free direct fire", 
			"psb101" => "source MaxSpeed=40; realistic ordnance; MuzzleVelocity=0; PredictAheadForBombDrop=3; DestroyOnWater=true", 
			"psb202" => "source MaxSpeed=20; realistic ordnance; MuzzleVelocity=0; PredictAheadForBombDrop=3; DestroyOnWater=true", 
			"psb301" => "source realistic ordnance; MuzzleVelocity=0; PredictAheadForBombDrop=3; DestroyOnWater=true; impact children unavailable", 
			"psb402" => "source realistic ordnance; MuzzleVelocity=0; PredictAheadForBombDrop=2; DestroyOnWater=true; dedicated local mesh renderer at authored scale six", 
			_ => throw new InvalidOperationException("No reviewed projectile movement contract exists for " + projectile.Id + "."), 
		};
		int num;
		switch (projectile.Id)
		{
		case "pab101":
		case "pab301":
			num = 4;
			break;
		case "psb402":
			num = 6;
			break;
		default:
			num = 1;
			break;
		}
		int num2 = num;
		string text7 = ((projectile.Id == "psb402") ? "boneName = \"SCO_Ahwassa_Commander_Projectile_Visual\", " : string.Empty);
		string text8 = ((projectile.Id == "psb402") ? "    -- Dedicated commander-blue bomb VFX owns a local scale-six mesh core; hierarchy and root collision remain 1.\n" : string.Empty);
		return string.Format("---@type ProjectileTemplate\nProjectileTemplate = {{\n{0}    \n    collisionInfo = {{\n        centerOffset = {{ x = 0, y = 0.5, z = 0 }},\n        collisionSize = {{ x = 1, y = 1, z = 1 }},\n    }},\n    general = {{\n        icon = \"projectile\",\n        name = \"{1}\",\n        tpId = \"{2}\",\n    }},\n    -- FA provenance: {3}.\n    -- Source projectile archive: {4}\n    -- Source blueprint: {5}\n    -- Source blueprint SHA-256: {6}\n    -- Source script: {7}\n    -- Source script SHA-256: {8}\n{9}{10}    nonUniformScale = {{ x = {11}, y = {12}, z = {13} }},\n    visuals = {{\n        mesh = {{ lod0distance = 60 }},\n        onImpactEffects = {{\n            {{ effects = {{ {{ particleName = \"{14}\" }} }} }},\n        }},\n        persistantEffects = {{\n            {{ effects = {{ {{ {15}particleName = \"{16}\" }} }} }},\n        }},\n    }},\n}}\n\n{17}", text4, projectile.Name, projectile.Id, text6, "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12", projectile.SourceBlueprintPath, projectile.SourceBlueprintSha256, projectile.SourceScriptPath, projectile.SourceScriptSha256, text5, text8, num2, num2, num2, projectile.ImpactVfx, text7, projectile.TrailVfx, "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0").Replace("\r\n", "\n");
	}

	private static void ValidateStockSurfaceBomber(string source, SurfaceBomberSpec bomber)
	{
		RequireTokens(source, "UnitTemplate =", "tpId = \"" + bomber.TargetId + "\"");
		if (bomber.TargetId.StartsWith("uca", StringComparison.Ordinal))
		{
			RequireTokens(source, "sourceId = \"" + bomber.SourceId + "\"", "UnitTemplate.additions.faSourceContract = {", "targetId = \"" + bomber.TargetId + "\"");
		}
		else
		{
			RequireTokens(source, "-- Apply the audited " + bomber.SourceId + " gameplay contract to the independent", "-- Supreme Commander Overhaul Seraphim source gameplay 2.1 " + bomber.TargetId);
		}
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", 0, bomber.TargetId + " FA bomber marker");
	}

	private static void ValidatePatchedSurfaceBomber(string source, SurfaceBomberSpec bomber)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", 1, bomber.TargetId + " FA bomber marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "sourceUnitId = \"" + bomber.SourceId + "\"", "targetUnitId = \"" + bomber.TargetId + "\"", "sourceBlueprintSha256 = \"" + bomber.SourceBlueprintSha256 + "\"", "sourceScriptSha256 = \"" + bomber.SourceScriptSha256 + "\"", "sourceProjectileId = \"" + bomber.SourceProjectileId + "\"", "runtimeProjectileId = \"" + bomber.ProjectileId + "\"", "UnitTemplate.weapons[" + bomber.WeaponIndex + "]", "surfaceBombMuzzles[\"" + bomber.MuzzleBone + "\"]", "aimBone = \"" + bomber.MuzzleBone + "\"", "aimGravity = { x = 0, y = -4.9, z = 0 }", "projectileSpeed = 0.0001", "solverType = \"NoArc\"", "surfaceBombWeapon.damage = " + Lua(bomber.Damage), "surfaceBombWeapon.damageRadius = " + Lua(bomber.DamageRadius), "surfaceBombWeapon.damageFriendly = " + ((bomber.TargetId == "uea1001") ? "false" : "true"), "surfaceBombWeapon.layerWeaponLimits = { \"Air\" }", "surfaceBombWeapon.projectileLifetime = " + Lua(bomber.ProjectileLifetime), "surfaceBombWeapon.projectileTemplate = \"" + bomber.ProjectileId + "\"", "surfaceBombWeapon.reloadTime = " + Lua(bomber.ReloadTime), "sourceBreakOffDistance = " + Lua(bomber.BreakOffDistance), "sourceBreakOffTrigger = " + Lua(bomber.BreakOffTrigger), "sourcePredictAheadForBombDrop = " + bomber.PredictAhead, "sourceBombDropThreshold = " + Lua(bomber.BombDropThreshold), "sourceProjectileMaxSpeed = " + Lua(ProjectileSpecs.Single((ProjectileSpec spec) => spec.Id == bomber.ProjectileId).SpeedMax), "runtimeForwardSpeedBonus = 3", "runtimeReleaseMode = \"PredictedHorizontalImpactThreshold\"", "runtimeVelocityMode = \"CarrierCurrentMovementSpeedPlusForwardBonus\"");
		RequireExactly(source2, "\"Air\"", 1, bomber.TargetId + " bomb origin layer");
		RequireExactly(source2, "\"Land\"", 1, bomber.TargetId + " bomb land target layer");
		RequireExactly(source2, "\"WaterSurface\"", 1, bomber.TargetId + " bomb water target layer");
		RequireExactly(source2, "\"Seabed\"", 1, bomber.TargetId + " bomb seabed target layer");
		RequireNotContains(source2, "pxd002", "solverType = \"LowArc\"");
		if (bomber.TargetId == "usa2101")
		{
			RequireTokens(source2, "sourceBaseBreakOffDistance = 5", "sourceBaseBreakOffTrigger = 10", "sourceBombTargetBreakOffDistanceMultiplier = 8", "sourceBombTargetBreakOffTriggerMultiplier = 2", "sourceBombTargetSpeedMultiplier = 0.67");
		}
		if (bomber.TargetId == "usa4011")
		{
			RequireTokens(source2, "sourceMaxAirspeed = 20", "sourceMinAirspeed = 18", "nativeAhwassaSpeedScale = 0.5", "UnitTemplate.movement.speed = 10", "UnitTemplate.movement.acceleration = 10", "UnitTemplate.movement.deceleration = 10", "UnitTemplate.movement.minSpeed = 9");
		}
	}

	private static void ValidateStockUnit(string source, BomberSpec bomber)
	{
		RequireTokens(source, "UnitTemplate =", "tpId = \"" + bomber.TargetId + "\"", "\"" + bomber.ExpectedClassOwner + "\"", "\"" + bomber.ExpectedUnitClass + "\"");
		RequireExactly(source, "tpId = \"" + bomber.TargetId + "\"", 1, bomber.TargetId + " stock tpId");
		string pattern = "class\\s*=\\s*\\{\\s*\\\"" + Regex.Escape(bomber.ExpectedClassOwner) + "\\\"\\s*,\\s*\\\"" + Regex.Escape(bomber.ExpectedUnitClass) + "\\\"\\s*,?\\s*\\}";
		if (!Regex.IsMatch(source, pattern, RegexOptions.CultureInvariant))
		{
			throw new InvalidOperationException(bomber.Description + " no longer exposes its reviewed Sanctuary class table.");
		}
	}

	private static void ValidatePatchedUnit(string source, BomberSpec bomber)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", 1, bomber.TargetId + " bomber marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "sourceId = \"" + bomber.SourceId + "\"", "targetId = \"" + bomber.TargetId + "\"", "sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\"", "sourceBlueprint = \"" + bomber.SourceBlueprintPath + "\"", "sourceBlueprintSha256 = \"" + bomber.SourceBlueprintSha256 + "\"", "sourceScript = \"" + bomber.SourceScriptPath + "\"", "sourceScriptSha256 = \"" + bomber.SourceScriptSha256 + "\"", "UnitTemplate.general.name = \"" + bomber.Name + "\"", "max = " + bomber.Health, "regen = 0", "buildTime = " + Lua(bomber.BuildTime), "alloys = " + Lua(bomber.MassCost), "energy = " + Lua(bomber.EnergyCost), "visionRadius = " + Lua(bomber.VisionRadius), "collisionSize = { x = " + Lua(bomber.CollisionX) + ", y = " + Lua(bomber.CollisionY) + ", z = " + Lua(bomber.CollisionZ) + " }", "UnitTemplate.movement = {", "acceleration = " + Lua(bomber.MaxAirspeed), "landWhenIdleSeconds = 1", "minSpeed = " + Lua(bomber.MinAirspeed), "orbitSpeed = " + Lua(bomber.MinAirspeed), "preferredAltitude = " + Lua(bomber.Elevation), "rotationSpeed = 90", "speed = " + Lua(bomber.MaxAirspeed), "type = \"Plane\"", "sourceKLift = 3", "sourceKLiftDamping = 2.5", "sourceLiftFactor = 7", "sourceKMoveDamping = " + Lua(bomber.KMoveDamping), "sourceFuelUseTime = " + Lua(bomber.FuelUseTime), "nativeFuelSupported = false", "sourceRadarStealthAvailable = false", "UnitTemplate.visuals.animations = nil", "UnitTemplate.visuals.effectsPersistent = nil", "category = \"DeathExplosion\"");
		if (bomber.RadarRadius.HasValue)
		{
			RequireTokens(source2, "radarRadius = " + Lua(bomber.RadarRadius.Value));
		}
		if (bomber.SonarRadius.HasValue)
		{
			RequireTokens(source2, "sonarRadius = " + Lua(bomber.SonarRadius.Value));
		}
		if (bomber.IsTorpedo)
		{
			RequireNotContains(source2, "UnitTemplate.additions.scoFaBomberAttackRun");
		}
		else
		{
			RequireTokens(source2, "UnitTemplate.additions.scoFaBomberAttackRun = {", "sourceBreakOffDistance = " + Lua(bomber.BreakOffDistance), "sourceBreakOffIfNearNewTarget = true", "sourceBreakOffTrigger = " + ((bomber.Tier == 3) ? "30" : "20"), "sourceEngageDistance = 50", "runtimePursueStandoff = 0", "runtimeMode = \"ReleaseBreakOffReentry\"", "runtimeAimProjectileSpeed = projectileSpeed", "sourceProjectileMaxSpeed = sourceProjectileMaxSpeed", "runtimeForwardSpeedBonus = 3", "runtimeGravity = 4.9", "runtimeProjectileLifetime = projectileLifetime", "runtimeReleaseMode = \"PredictedHorizontalImpactThreshold\"", "runtimeVelocityMode = \"CarrierCurrentMovementSpeedPlusForwardBonus\"");
		}
		RequireNotContains(source2, "DEMO_UI_ONLY", "UnitTemplate.general.tpId", "UnitTemplate.general.class", "UnitTemplate.movement.fuelUseTime", "UnitTemplate.movement.fuelRechargeRate", "AeonProjectiles", "pad002", "pcl001", "Turret01_");
		switch (bomber.TargetId)
		{
		case "uea1001":
			RequireTokens(source2, "{ \"Projectile\" }, \"peb101\", 0.0001", "60, 2.5, 2, 0, 40", "8, 5, 0.2, 3, false, 3, 20", "runtimeDamageCarrier = 60", "runtimeDirectDamage = 0", "runtimeDamageOverTimePulseCount = 15", "runtimeDamageOverTimePulseDamage = 4", "runtimeDamageOverTimePulseIntervalTicks = 1", "runtimeDamageOverTimeDurationSeconds = 1.5", "runtimeTotalDamage = 60", "runtimeTemporalPulseMode = \"FixedImpactAreaGlobalThread\"");
			break;
		case "uea2301":
			RequireTokens(source2, "{ \"Projectile\", \"Projectile\" }, \"peb231\", 14", "375, 0, 12.5, 4, 42", "20, 2, 1.8, 3, false");
			break;
		case "uea3001":
			RequireTokens(source2, "{ \"Projectile02\" }, \"peb301\", 0.0001", "8, 1, 0, 0, true, 3.5, 20", "\"pef102\", 16", "\"Left_Barrel_AA\"", "\"Right_Barrel_AA\"");
			RequireExactly(source2, "\"pef102\", 16", 2, "UEF T3 bomber AA calls");
			break;
		case "uga1001":
			RequireTokens(source2, "\"Muzzle_L03\", \"Muzzle_R03\", \"Muzzle_L02\", \"Muzzle_R02\", \"Muzzle_L01\", \"Muzzle_R01\"", "\"pgb101\", 0.0001, 50, 3", "8, 6, 0.2, 3, true, 3, 25");
			break;
		case "uga2301":
			RequireTokens(source2, "{ \"TorpedoL\", \"TorpedoR\" }, \"pgb231\", 14", "375, 0, 12.5, 4, 42", "runtimeTemporalPulseMode = \"CollapsedEqualTotal\"", "runtimeZigZagAvailable = false");
			break;
		case "uga3001":
			RequireTokens(source2, "{ \"Projectile01\" }, \"pgb301\", 0.0001", "8, 1, 0, 0, true, 3.5, 20", "\"pgb302\", 5", "\"Left_Muzzle_AA_01\", \"Left_Muzzle_AA_02\"", "\"Right_Muzzle_AA_01\", \"Right_Muzzle_AA_02\"", "sourceRadarStealth = true", "sourceMaintenanceConsumptionPerSecondEnergy = 60");
			RequireExactly(source2, "\"pgb302\", 5", 2, "Cybran T3 bomber AA calls");
			break;
		default:
			throw new InvalidOperationException("No patched-unit validator exists for " + bomber.TargetId + ".");
		}
	}

	private static void ValidateStockImportScanner(string source)
	{
		RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory");
	}

	private static void ValidateStockHostWeapons(string source)
	{
		RequireTokens(source, "function HostWeapon:CanShootAt(targetUnit)", "function HostWeapon:IsWeaponOnTarget()", "function HostWeapon:GetDesiredProjectileValues(aimControllerId)", "function HostWeapon:UpdateProjectile(isOnTarget)", "Engine.SetCurvedProjectileSpeed(projectileID, desiredProjectileSpeed)", "Engine.SetProjectileGravity(projectileID, math3D.scale(projectileGravity, gravityMultiplier))", "local firingRotation = ApplyFiringRandomness(muzzleRotation, self.tp.firingRandomness or 1.0)\n                    local _, projectileID = Engine.InstantiatePrefab(projectilePrefabID, muzzlePosition, EngineClasses.float3(1.0, 1.0, 1.0), firingRotation)");
		RequireExactly(source, "local firingRotation = ApplyFiringRandomness(muzzleRotation, self.tp.firingRandomness or 1.0)\n                    local _, projectileID = Engine.InstantiatePrefab(projectilePrefabID, muzzlePosition, EngineClasses.float3(1.0, 1.0, 1.0), firingRotation)", 1, "stock host weapon firing-rotation assignment");
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", 0, "FA bomber drop marker");
	}

	private static void ValidatePatchedHostWeapons(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", 1, "FA bomber drop marker");
		RequireExactly(source, "local launchRotation = muzzleRotation\n                    if self.tp.scoFaBombDrop ~= nil then\n                        launchRotation = SCO_FaBomberCarrierFiringRotation(\n                            self,\n                            muzzleRotation)\n                    end\n                    local firingRotation = ApplyFiringRandomness(\n                        launchRotation,\n                        self.tp.firingRandomness or 1.0)\n                    local _, projectileID = Engine.InstantiatePrefab(projectilePrefabID, muzzlePosition, EngineClasses.float3(1.0, 1.0, 1.0), firingRotation)\n                    if self.tp.scoFaBombDrop ~= nil\n                        and type(self.unit.SCO_FaBomberOnBombReleased) == \"function\"\n                    then\n                        self.unit:SCO_FaBomberOnBombReleased(projectileID)\n                    end", 1, "FA bomber carrier-aligned firing rotation");
		RequireExactly(source, "local firingRotation = ApplyFiringRandomness(muzzleRotation, self.tp.firingRandomness or 1.0)\n                    local _, projectileID = Engine.InstantiatePrefab(projectilePrefabID, muzzlePosition, EngineClasses.float3(1.0, 1.0, 1.0), firingRotation)", 0, "obsolete stock firing-rotation assignment");
		RequireTokens(source, "SCO_FaBomberDropInstalled", "local SCO_FaBomberStockCanShootAt =", "local SCO_FaBomberStockIsWeaponOnTarget =", "local SCO_FaBomberStockGetDesiredProjectileValues =", "peb101 = { threshold = 3, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 }", "peb301 = { threshold = 3.5, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 }", "pgb101 = { threshold = 3, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 25 }", "pgb301 = { threshold = 3.5, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 }", "pab101 = { threshold = 1.5, lifetime = 3, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 40 }", "pab301 = { threshold = 3.5, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 }", "psb101 = { threshold = 3, lifetime = 3, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 40 }", "psb202 = { threshold = 2, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 }", "psb301 = { threshold = 3.5, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 }", "psb402 = { threshold = 4, lifetime = 8, predictAhead = 2, forwardSpeedBonus = 3, maxSpeed = 20 }", "RightFrontAutocannon = { center = 310, range = 80 }", "LeftFrontAutocannon = { center = 60, range = 90 }", "RightRearAutocannon = { center = 180, range = 120 }", "LeftRearAutocannon = { center = 180, range = 130 }", "local function SCO_FaBomberHeadingContract(weapon)", "contract.runtimeMode ~= \"HostRelativeHeadingGate\"", "aim.solverType ~= \"NoArc\"", "Engine.GetMovementChassisYawDegrees(weapon.unit.id)", "function HostWeapon:CanShootAt(target)", "return SCO_FaBomberPassesHeadingArc(", "contract.sourceNeedToComputeBombDrop ~= true", "contract.sourceRealisticOrdinance ~= true", "contract.sourceMuzzleVelocity ~= 0", "contract.sourcePredictAheadForBombDrop ~= profile.predictAhead", "contract.runtimeAimProjectileSpeed ~= 0.0001", "contract.runtimeGravity ~= 4.9", "contract.runtimeReleaseMode", "~= \"PredictedHorizontalImpactThreshold\"", "contract.runtimeVelocityMode", "contract.runtimeForwardSpeedBonus ~= profile.forwardSpeedBonus", "contract.sourceProjectileMaxSpeed ~= profile.maxSpeed", "~= \"CarrierCurrentMovementSpeedPlusForwardBonus\"", "local function SCO_FaBomberLaunchSpeed(weapon, contract)", "inheritedSpeed + contract.runtimeForwardSpeedBonus", "contract.sourceProjectileMaxSpeed", "Engine.GetMovementHeadingDegrees(entityId)", "Engine.GetMovementCurrentSpeed(unit.id)", "function SCO_FaBomberCarrierFiringRotation(", "Engine.QuaternionLookRotationSafe(", "local fallTime = math.sqrt(", "(2 * height) / contract.runtimeGravity", "local predictedTargetX = targetPosition.x", "local predictedTargetZ = targetPosition.z", "<= threshold * threshold", "function HostWeapon:IsWeaponOnTarget()", "return SCO_FaBomberDropIsAligned(self, contract)", "function HostWeapon:GetDesiredProjectileValues(aimControllerId)", "EngineClasses.float3(0, -contract.runtimeGravity, 0)", "type(self.unit.SCO_FaBomberOnBombReleased) == \"function\"", "self.unit:SCO_FaBomberOnBombReleased(projectileID)");
		RequireExactly(source, "self.unit:SCO_FaBomberOnBombReleased(projectileID)", 1, "surface-bomb release callback");
	}

	private static void ValidateStockHostAirUnits(string source)
	{
		RequireTokens(source, "function HostAirUnit:GetAttackRadius(patternID, range)", "radius = self:GetPatternMode(patternID) == \"Strafe\" and range * StrafeDesiredRangeFraction or range", "Engine.MovementMoveToTarget(self.id, targetUnit.id, self:GetAttackRadius(attackID, range))");
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", 0, "FA bomber attack-run marker");
	}

	private static void ValidatePatchedHostAirUnits(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", 1, "FA bomber attack-run marker");
		RequireTokens(source, "SCO_FaBomberAttackRunInstalled", "local SCO_FaBomberStockGetAttackRadius =", "HostAirUnit.GetAttackRadius", "local SCO_FaBomberStockCreateWreckageFromUnit =", "CreateWreckageFromUnit", "uca1001 = { breakOffDistance = 30, breakOffTrigger = 20 }", "uca3001 = { breakOffDistance = 60, breakOffTrigger = 30 }", "uea1001 = { breakOffDistance = 18, breakOffTrigger = 20 }", "uea3001 = { breakOffDistance = 60, breakOffTrigger = 30 }", "uga1001 = { breakOffDistance = 30, breakOffTrigger = 20 }", "uga3001 = { breakOffDistance = 60, breakOffTrigger = 30 }", "usa1001 = { breakOffDistance = 30, breakOffTrigger = 20 }", "usa2101 = { breakOffDistance = 40, breakOffTrigger = 20 }", "usa3001 = { breakOffDistance = 60, breakOffTrigger = 30 }", "usa4011 = { breakOffDistance = 60, breakOffTrigger = 30 }", "additions.scoFaBomberAttackRun", "contract.sourceBreakOffIfNearNewTarget ~= true", "contract.sourceEngageDistance ~= 50", "contract.runtimePursueStandoff ~= 0", "contract.runtimeMode ~= \"ReleaseBreakOffReentry\"", "function HostAirUnit:SCO_FaBomberOnBombReleased(projectileId)", "self.attackBehaviorIsActive ~= true", "local _, heading = Engine.GetMovementHeadingDegrees(self.id)", "targetForwardDistance + contract.sourceBreakOffDistance", "local waypoint = EngineClasses.float2(", "local result = Engine.MovementMove(", "waypoint,\n            EngineClasses.float2(0, 0),\n            0)", "usa4011 = { damage = 10000, radius = 8 }", "additions.scoFaBomberCrashImpact", "contract.sourceUnitId ~= \"XSA0402\"", "contract.sourceLabel ~= \"DeathImpact\"", "contract.runtimeMode ~= \"WreckImpactAreaDamage\"", "function HostAirUnit:GetAttackRadius(patternID, range)", "return contract.runtimePursueStandoff", "return SCO_FaBomberStockGetAttackRadius(self, patternID, range)", "function CreateWreckageFromUnit(unit)", "wreck.scoFaBomberCrashImpact = {", "army = unit.army");
		RequireExactly(source, "function HostAirUnit:GetAttackRadius(patternID, range)", 2, "stock plus SCOM HostAirUnit pursue-standoff functions");
		RequireExactly(source, "function HostAirUnit:SCO_FaBomberOnBombReleased(projectileId)", 1, "SCOM bomber release-to-breakoff callback");
		RequireExactly(source, "function CreateWreckageFromUnit(unit)", 1, "SCOM Ahwassa wreck-contract wrapper");
	}

	private static void ValidateStockHostCollision(string source)
	{
		RequireTokens(source, "function CollisionUpdate()", "function ProcessAreaDamage(position, radius, damage, army, damageFriendly)", "function ProcessRayCollisionEvent(rayCollisionEvent)", "DestroyProjectile(", "return {\n    CollisionUpdate = CollisionUpdate,");
		RequireExactly(source, "return {\n    CollisionUpdate = CollisionUpdate,", 1, "host collision terminal return anchor");
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", 0, "Scorcher ground-fire marker");
	}

	private static void ValidatePatchedHostCollision(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", 1, "Scorcher ground-fire marker");
		RequireExactly(source, "return {\n    CollisionUpdate = CollisionUpdate,", 1, "host collision terminal return anchor");
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", StringComparison.Ordinal);
		int num2 = source.IndexOf("return {\n    CollisionUpdate = CollisionUpdate,", StringComparison.Ordinal);
		if (num < 0 || num2 <= num)
		{
			throw new InvalidOperationException("Scorcher ground-fire runtime is not before collisionUpdate.lua's terminal return.");
		}
		RequireTokens(source, "SCO_FaBomberGroundFireInstalled", "local SCO_FaBomberStockCollisionUpdate = CollisionUpdate", "local SCO_FaBomberStockRayCollision = ProcessRayCollisionEvent", "local SCO_FaBomberStockAreaDamage = ProcessAreaDamage", "local SCO_FaBomberActiveProjectile = nil", "peb101 = { damage = 60, radius = 2.5, damageFriendly = false }", "peb301 = { damage = 3000, radius = 6, damageFriendly = true }", "pgb101 = { damage = 50, radius = 3, damageFriendly = true }", "pgb301 = { damage = 2750, radius = 7, damageFriendly = true }", "pab101 = { damage = 200, radius = 4, damageFriendly = true }", "pab301 = { damage = 3450, radius = 4, damageFriendly = true }", "psb101 = { damage = 250, radius = 4, damageFriendly = true }", "psb202 = { damage = 1175, radius = 3, damageFriendly = true }", "psb301 = { damage = 3250, radius = 5, damageFriendly = true }", "psb402 = { damage = 11000, radius = 20, damageFriendly = true }", "pab101 = { sourceId = \"AIFBombGraviton01\" }", "pab301 = { sourceId = \"AIFBombQuark01\" }", "psb101 = { sourceId = \"SBOOtheTacticalBomb01\" }", "psb202 = { sourceId = \"SBOOtheTacticalBomb02\" }", "psb301 = { sourceId = \"SBOZhanaseeBomb01\" }", "psb402 = { sourceId = \"SBOOhwalliStrategicBomb01\" }", "XSA0402 = { damage = 10000, radius = 8 }", "local function SCO_FaBomberDestroyOnWaterContract(projectile)", "additions.scoFaDestroyOnWater", "contract.sourceDestroyOnWater ~= true", "~= \"HostPreCollisionWaterlineCull\"", "local function SCO_FaBomberCullWaterProjectiles()", "Engine.GetGlobalEntityWorldPosition(projectile.id)", "position.y <= waterLevel", "DestroyProjectile(projectile.id, 0)", "function CollisionUpdate()", "SCO_FaBomberCullWaterProjectiles()", "local function SCO_FaBomberCrashImpactContract(wreck)", "wreck.scoFaBomberCrashImpact", "contract.sourceLabel ~= \"DeathImpact\"", "contract.runtimeMode ~= \"WreckImpactAreaDamage\"", "local function SCO_FaBomberApplyCrashImpact(wreck, position)", "wreck.scoFaBomberCrashImpactApplied = true", "local function SCO_FaBomberApplyWaterCrashImpacts()", "Engine.SampleTerrainHeight(position)", "terrainHeight < waterLevel", "y = waterLevel", "local function SCO_FaBomberApplyTerrainCrashImpacts()", "wreck.crashImpactPosition", "SCO_FaBomberApplyWaterCrashImpacts()", "local result = SCO_FaBomberStockCollisionUpdate()", "SCO_FaBomberApplyTerrainCrashImpacts()", "return result", "local function SCO_FaBomberImpactContract(projectile)", "additions.scoFaBomberImpact", "contract.damageFriendly ~= profile.damageFriendly", "projectile.damage ~= profile.damage", "projectile.damageRadius ~= profile.radius", "contract.sourceId ~= \"TIFNapalmCarpetBomb01\"", "contract.runtimeProjectileId ~= \"peb101\"", "contract.pulseCount ~= 15", "contract.pulseDamage ~= 4", "contract.pulseIntervalTicks ~= 1", "contract.durationSeconds ~= 1.5", "contract.damageRadius ~= 2.5", "contract.damageFriendly ~= false", "projectile.damage ~= 60", "projectile.damageRadius ~= 2.5", "SCO_FaBomberStockAreaDamage(", "WaitTicks(contract.pulseIntervalTicks)", "function ProcessAreaDamage(", "local sourceUnit = projectile.sourceUnit or select(1, ...)", "NewThread(", "impactContract.damageFriendly", "return SCO_FaBomberStockAreaDamage(", "function ProcessRayCollisionEvent(event)", "if SCO_FaBomberImpactContract(projectile) ~= nil then", "local succeeded, result = pcall(", "return SCO_FaBomberStockRayCollision(event)");
		if (!Regex.IsMatch(source, "SCO_FaBomberStockAreaDamage\\(\\s*position,\\s*contract\\.damageRadius,\\s*contract\\.pulseDamage,\\s*projectileArmy,\\s*contract\\.damageFriendly,\\s*sourceUnit\\)", RegexOptions.CultureInvariant))
		{
			throw new InvalidOperationException("Scorcher pulse damage no longer forwards its friendly-fire policy and source-unit attribution.");
		}
		if (!Regex.IsMatch(source, "SCO_FaBomberStockAreaDamage\\(\\s*position,\\s*contract\\.damageRadius,\\s*contract\\.damage,\\s*contract\\.army,\\s*contract\\.damageFriendly\\)", RegexOptions.CultureInvariant))
		{
			throw new InvalidOperationException("Ahwassa crash impact no longer applies its exact source area-damage contract.");
		}
		RequireExactly(source, "function CollisionUpdate()", 2, "stock plus SCOM collision-update functions");
		RequireExactly(source, "function ProcessRayCollisionEvent(event)", 1, "Scorcher ray-collision wrapper");
		RequireExactly(source, "function ProcessAreaDamage(\n", 1, "Scorcher area-damage wrapper");
		RequireExactly(source, "projectile.scoFaBomberGroundFireStarted = true", 1, "Scorcher ground-fire start guard");
	}

	private static void ValidateImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", 1, "bomber scanner marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "local SCO_FaAirBomberScanDir = ScanDir", "function ScanDir(directory)", "local folders = SCO_FaAirBomberScanDir(directory)", "directory ~= \"common/projectiles/projectilesTemplates/\"");
		ProjectileSpec[] projectileSpecs = ProjectileSpecs;
		foreach (ProjectileSpec projectileSpec in projectileSpecs)
		{
			RequireExactly(source2, "directory .. \"" + projectileSpec.Id + "\"", 1, projectileSpec.Id + " bomber scanner folder");
		}
		RequireExactly(source2, "function ScanDir(directory)", 1, "bomber scanner function");
		RequireExactly(source2, "table.insert(folders, bomberFolder)", 1, "bomber scanner insertion");
		RequireNotContains(source2, "pef102", "scanRoot");
	}

	private static void ValidateVirtualProjectile(string source, ProjectileSpec projectile)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", 1, projectile.Id + " marker");
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"" + projectile.Id + "\"", "name = \"" + projectile.Name + "\"", projectile.SourceId, "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12", projectile.SourceBlueprintPath, projectile.SourceBlueprintSha256, projectile.SourceScriptPath, projectile.SourceScriptSha256, projectile.ImpactVfx, projectile.TrailVfx);
		RequireNotContains(source, "AeonProjectiles", "pad002", "pcl001");
		bool flag;
		switch (projectile.Id)
		{
		case "pab101":
		case "peb101":
		case "pgb101":
		case "psb101":
		case "pab301":
		case "peb301":
		case "pgb301":
		case "psb301":
		case "psb202":
		case "psb402":
			flag = true;
			break;
		default:
			flag = false;
			break;
		}
		if (flag)
		{
			string text = ((projectile.Id == "peb101") ? "false" : "true");
			RequireTokens(source, "scoFaBomberImpact = {", "runtimeProjectileId = \"" + projectile.Id + "\"", "damageFriendly = " + text);
			RequireExactly(source, "scoFaBomberImpact = {", 1, projectile.Id + " impact contract");
		}
		else
		{
			RequireNotContains(source, "scoFaBomberImpact");
		}
		if (projectile.Id == "peb101")
		{
			RequireTokens(source, "scoFaBomberGroundFire = {", "version = \"1.0.0\"", "sourceId = \"TIFNapalmCarpetBomb01\"", "runtimeProjectileId = \"peb101\"", "pulseCount = 15", "pulseDamage = 4", "pulseIntervalTicks = 1", "durationSeconds = 1.5", "damageRadius = 2.5", "damageFriendly = false", "impactVfx = \"VFX/SupremeCommanderOverhaul/Bombers/scorcher_napalm_ground_fire.sanvfx\"");
			RequireExactly(source, "scoFaBomberGroundFire = {", 1, "Scorcher projectile ground-fire contract");
		}
		else
		{
			RequireNotContains(source, "scoFaBomberGroundFire");
		}
		if (projectile.Id == "peb301")
		{
			RequireExactly(source, "VFX/Impact/vei8301_bomb_large_impact.sanvfx", 1, "Ambassador EDA bomb impact");
			RequireNotContains(source, "VFX/Death/vcd1301_death_land_large.sanvfx");
		}
		if (projectile.Id.StartsWith("pab", StringComparison.Ordinal) || projectile.Id.StartsWith("psb", StringComparison.Ordinal))
		{
			RequireTokens(source, "scoFaDestroyOnWater = {", "sourceId = \"" + projectile.SourceId + "\"", "runtimeProjectileId = \"" + projectile.Id + "\"", "sourceDestroyOnWater = true", "runtimeMode = \"HostPreCollisionWaterlineCull\"");
			RequireExactly(source, "scoFaDestroyOnWater = {", 1, projectile.Id + " DestroyOnWater contract");
		}
		else
		{
			RequireNotContains(source, "scoFaDestroyOnWater");
		}
		if (projectile.Id == "psb402")
		{
			RequireTokens(source, "nonUniformScale = { x = 6, y = 6, z = 6 }", "boneName = \"SCO_Ahwassa_Commander_Projectile_Visual\"", "VFX/SCOM/FieldFixes/Ahwassa/ahwassa_strategic_bomb_6x.sanvfx", "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx");
			RequireExactly(source, "boneName = \"SCO_Ahwassa_Commander_Projectile_Visual\"", 1, "Ahwassa commander-blue presentation binding");
			RequireExactly(source, "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx", 1, "Ahwassa commander-blue impact visual");
		}
		string id = projectile.Id;
		if (id == "pab101" || id == "pab301")
		{
			RequireTokens(source, "nonUniformScale = { x = 4, y = 4, z = 4 }", "VFX/Trails/vct1201_cannon_plasma_medium_trail.sanvfx");
		}
		if (projectile.Torpedo)
		{
			RequireTokens(source, "movement = {", "acceleration = " + Lua(projectile.Acceleration), "alignToVelocity = true", "gravityMultiplier = 0", "rotationSpeed = " + Lua(projectile.RotationSpeed), "speedMax = " + Lua(projectile.SpeedMax), "type = \"TargetEntity\"", "timeToLive = " + Lua(projectile.Lifetime));
			RequireNotContains(source, "isBomb = true");
		}
		else
		{
			RequireNotContains(source, "movement = {");
			if (projectile.Id == "pgb302")
			{
				RequireNotContains(source, "isBomb = true");
				return;
			}
			RequireTokens(source, "isBomb = true", "speed = " + Lua(projectile.SpeedMax), "timeToLive = " + Lua(projectile.Lifetime));
		}
	}

	private static void QueueAppend(object cache, List<CacheMutation> mutations, string relativePath, string description, Action<string> validateStock, string appendix, Action<string> validatePatched)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string text = NormalizeNewlines(GetResourceText(cachedResource.Stock));
		if (text.IndexOf("-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", StringComparison.Ordinal) >= 0)
		{
			validatePatched(text);
			return;
		}
		validateStock(text);
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), AppendOverride(text, appendix));
		try
		{
			validatePatched(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
		}
		catch
		{
			TryDisposeNativeArray(obj, "uncommitted " + description);
			throw;
		}
	}

	private static void QueueInsertBefore(object cache, List<CacheMutation> mutations, string relativePath, string description, Action<string> validateStock, string appendix, string anchor, Action<string> validatePatched)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string text = NormalizeNewlines(GetResourceText(cachedResource.Stock));
		if (text.IndexOf("-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", StringComparison.Ordinal) >= 0)
		{
			validatePatched(text);
			return;
		}
		validateStock(text);
		RequireExactly(text, anchor, 1, description + " insertion anchor");
		string source = text.Replace(anchor, appendix + "\n" + anchor);
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), source);
		try
		{
			validatePatched(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
		}
		catch
		{
			TryDisposeNativeArray(obj, "uncommitted " + description);
			throw;
		}
	}

	private static void QueueReplaceAndAppend(object cache, List<CacheMutation> mutations, string relativePath, string description, Action<string> validateStock, string stockFragment, string replacementFragment, string appendix, Action<string> validatePatched)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string text = NormalizeNewlines(GetResourceText(cachedResource.Stock));
		if (text.IndexOf("-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", StringComparison.Ordinal) >= 0)
		{
			validatePatched(text);
			return;
		}
		validateStock(text);
		RequireExactly(text, stockFragment, 1, description + " replacement fragment");
		string source = AppendOverride(text.Replace(stockFragment, replacementFragment), appendix);
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), source);
		try
		{
			validatePatched(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
		}
		catch
		{
			TryDisposeNativeArray(obj, "uncommitted " + description);
			throw;
		}
	}

	private static void QueueVirtualProjectile(object cache, List<CacheMutation> mutations, ProjectileSpec projectile)
	{
		string relativePath = ProjectileRelativePath(projectile.Id);
		string text = projectile.SourceId + " virtual projectile";
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, text);
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Reserved bomber projectile ID " + projectile.Id + " already exists without the bomber marker.");
			}
			if (projectile.Id == "peb301")
			{
				string text2 = BuildVirtualProjectile(projectile);
				RequireExactly(text2, "VFX/Impact/vei8301_bomb_large_impact.sanvfx", 1, "Ambassador generated EDA impact");
				RequireExactly(text2, "VFX/Death/vcd1301_death_land_large.sanvfx", 0, "Ambassador retired impact");
				string b = text2.Replace("VFX/Impact/vei8301_bomb_large_impact.sanvfx", "VFX/Death/vcd1301_death_land_large.sanvfx");
				if (string.Equals(resourceText, b, StringComparison.Ordinal))
				{
					object obj = CreateNativeArrayFromText(GetNativeArrayType(cache), text2);
					try
					{
						ValidateVirtualProjectile(GetResourceText(obj), projectile);
						mutations.Add(new CacheMutation(cacheResource.Path, cacheResource.Stock, obj, added: false, text));
						return;
					}
					catch
					{
						TryDisposeNativeArray(obj, "uncommitted " + text);
						throw;
					}
				}
			}
			ValidateVirtualProjectile(resourceText, projectile);
			return;
		}
		string source = BuildVirtualProjectile(projectile);
		ValidateVirtualProjectile(source, projectile);
		object obj3 = CreateNativeArrayFromText(GetNativeArrayType(cache), source);
		try
		{
			ValidateVirtualProjectile(GetResourceText(obj3), projectile);
			mutations.Add(new CacheMutation(ResolvePath(relativePath), null, obj3, added: true, text));
		}
		catch
		{
			TryDisposeNativeArray(obj3, "uncommitted " + text);
			throw;
		}
	}

	private static void Commit(object cache, IReadOnlyList<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			mutation.Assigned = true;
			SetCachedResource(cache, mutation.Path, mutation.Replacement);
		}
		foreach (CacheMutation mutation2 in mutations)
		{
			if (mutation2.Stock != null)
			{
				TryDisposeNativeArray(mutation2.Stock, "stock " + mutation2.Description);
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
						SetCachedResource(cache, item.Path, item.Stock ?? throw new InvalidOperationException(item.Description + " has no stock resource."));
					}
					item.Assigned = false;
				}
				catch (Exception ex)
				{
					Log("Rollback failed for " + item.Description + ": " + ex);
				}
			}
			if (!item.Assigned)
			{
				TryDisposeNativeArray(item.Replacement, "replacement " + item.Description);
			}
		}
	}

	private static void DisposeUncommitted(IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			TryDisposeNativeArray(mutation.Replacement, "uncommitted " + mutation.Description);
		}
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CacheResource GetCachedResource(object cache, string relativePath, string description)
	{
		return TryGetCachedResource(cache, relativePath, description) ?? throw new FileNotFoundException("Required " + description + " was not present in Sanctuary's Lua cache.", relativePath);
	}

	private static CacheResource? TryGetCachedResource(object cache, string relativePath, string description)
	{
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string text = ResolvePath(relativePath);
		object obj2 = obj.Invoke(cache, new object[1] { text });
		if (obj2 is bool && (bool)obj2)
		{
			object obj3 = propertyInfo.GetValue(cache, new object[1] { text }) ?? throw new InvalidOperationException("Cached " + description + " has no value.");
			EnsureNativeArray(obj3, description);
			return new CacheResource(text, obj3);
		}
		string value = "/" + relativePath.Replace('\\', '/');
		CacheResource cacheResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text2 && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cacheResource != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + relativePath + ".");
				}
				object obj4 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("Cached " + description + " has no value.");
				EnsureNativeArray(obj4, description);
				cacheResource = new CacheResource(text2, obj4);
			}
		}
		return cacheResource;
	}

	private static Type GetNativeArrayType(object cache)
	{
		foreach (object item in (IEnumerable)cache)
		{
			object obj = item.GetType().GetProperty("Value")?.GetValue(item);
			if (obj != null)
			{
				EnsureNativeArray(obj, "Lua cache resource");
				return obj.GetType();
			}
		}
		throw new InvalidOperationException("Sanctuary's Lua file cache contains no NativeArray resource type.");
	}

	private static string ResolvePath(string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, Encoding.UTF8.GetBytes(source));
	}

	private static string GetResourceText(object resource)
	{
		EnsureNativeArray(resource, "Lua cache resource");
		byte[] bytes = ((resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null) as byte[]) ?? throw new InvalidOperationException("NativeArray.ToArray returned no byte array.");
		return Encoding.UTF8.GetString(bytes);
	}

	private static void EnsureNativeArray(object resource, string description)
	{
		object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource);
		if (!(value is bool) || !(bool)value)
		{
			throw new InvalidOperationException("Cached " + description + " is not an initialized NativeArray.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void RemoveCachedResource(object cache, string path)
	{
		(cache.GetType().GetMethod("Remove", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "Remove")).Invoke(cache, new object[1] { path });
	}

	private static void TryDisposeNativeArray(object resource, string description)
	{
		try
		{
			object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource);
			if (value is bool && (bool)value)
			{
				(resource.GetType().GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "Dispose")).Invoke(resource, null);
			}
		}
		catch (Exception ex)
		{
			Log("Could not dispose " + description + ": " + ex);
		}
	}

	private static string AppendOverride(string source, string appendix)
	{
		if (!source.EndsWith("\n", StringComparison.Ordinal))
		{
			return source + "\n" + appendix;
		}
		return source + appendix;
	}

	private static string NormalizeNewlines(string source)
	{
		return source.Replace("\r\n", "\n").Replace('\r', '\n');
	}

	private static string ProjectileRelativePath(string projectileId)
	{
		return "LJ/lua/common/projectiles/projectilesTemplates/" + projectileId + "/" + projectileId + ".santp";
	}

	private static string OwnedAppendix(string source)
	{
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Bomber marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0".Length, StringComparison.Ordinal);
		if (num2 < 0)
		{
			return source.Substring(num);
		}
		return source.Substring(num, num2 - num);
	}

	private static string Lua(double value)
	{
		return StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture);
	}

	private static void RequireTokens(string source, params string[] tokens)
	{
		foreach (string text in tokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Expected cached Lua source to contain '" + text + "'.");
			}
		}
	}

	private static void RequireNotContains(string source, params string[] tokens)
	{
		foreach (string text in tokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) >= 0)
			{
				throw new InvalidOperationException("FA bomber-owned source must not contain '" + text + "'.");
			}
		}
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(token, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += token.Length;
		}
		if (num != expected)
		{
			throw new InvalidOperationException("Expected " + expected + " " + description + ", found " + num + ".");
		}
	}

	private static void Log(string message)
	{
		string text = "[FA Air Bomber Cache Patcher] " + message;
		Console.WriteLine(text);
		try
		{
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}

	private static void ValidatePatchedHostAirAttackMove(string source)
	{
		ValidatePatchedHostAirUnits(source);
		RequireExactly(source, HostAirUnitsAppendix, 1, "exact existing FA bomber host-air appendix");
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Attack Move 1.1.0", 1, "FA bomber attack-move marker");
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Bomber Attack Move ", 1, "FA bomber attack-move marker family");
		RequireExactly(source, HostAirAttackMoveAppendix, 1, "exact FA bomber attack-move appendix");
	}

	private static void QueueHostAirAttackMove(object cache, List<CacheMutation> mutations)
	{
		CacheResource cachedResource = GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "FA bomber attack-move breakoff and reentry host air runtime");
		string text = NormalizeNewlines(GetResourceText(cachedResource.Stock));
		RequireTokens(text, "function HostAirUnit:AttackMoveEngageTargets()", "local target = self:GetMainWeaponTarget()", "if self.isAirborne and not pursuing then", "function HostAirUnit:PursueTarget(targetUnit, range)", "self:SetMovementPatterns(\"attack\")");
		if (text.Contains("-- Supreme Commander Overhaul FA Air Bomber Attack Move ") && !text.Contains("-- Supreme Commander Overhaul FA Air Bomber Attack Move 1.1.0"))
		{
			throw new InvalidOperationException("Unsupported FA bomber attack-move cache marker.");
		}
		if (text.Contains("-- Supreme Commander Overhaul FA Air Bomber Attack Move 1.1.0"))
		{
			ValidatePatchedHostAirAttackMove(text);
			return;
		}
		if (text.Contains("-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0"))
		{
			ValidatePatchedHostAirUnits(text);
			RequireExactly(text, HostAirUnitsAppendix, 1, "exact existing FA bomber host-air appendix");
		}
		else
		{
			ValidateStockHostAirUnits(text);
			text = AppendOverride(text, HostAirUnitsAppendix);
			ValidatePatchedHostAirUnits(text);
		}
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), AppendOverride(text, HostAirAttackMoveAppendix));
		try
		{
			ValidatePatchedHostAirAttackMove(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, "FA bomber attack-move breakoff and reentry host air runtime"));
		}
		catch
		{
			TryDisposeNativeArray(obj, "uncommitted FA bomber attack-move breakoff and reentry host air runtime");
			throw;
		}
	}

	private static void QueueZeusExhaust(object cache, List<CacheMutation> mutations, BomberSpec bomber)
	{
		if (bomber.TargetId != "uga1001" || bomber.SourceId != "URA0103")
		{
			throw new InvalidOperationException("Zeus exhaust patch received a different bomber.");
		}
		CacheResource cachedResource = GetCachedResource(cache, bomber.RelativePath, bomber.Description);
		string text = NormalizeNewlines(GetResourceText(cachedResource.Stock));
		string text2 = BuildUnitOverride(bomber);
		if (Regex.Matches(text, Regex.Escape("-- Supreme Commander Overhaul FA Cybran Zeus Exhaust ")).Count != 0)
		{
			RequireExactly(text, "-- Supreme Commander Overhaul FA Cybran Zeus Exhaust 1.0.0", 1, "Zeus exhaust version");
			RequireExactly(text, "-- Supreme Commander Overhaul FA Cybran Zeus Exhaust ", 1, "Zeus exhaust marker family");
			RequireExactly(text, "\n-- Supreme Commander Overhaul FA Cybran Zeus Exhaust 1.0.0\n-- URA0103 BeamExhaust names both converted rear engine bones and is\n-- enabled at idle and cruise. The native Guard medium-aircraft effect\n-- supplies a persistent local exhaust without altering host movement.\nassert(UnitTemplate.general and UnitTemplate.general.tpId == \"uga1001\", \"Zeus exhaust target drift\")\nassert(UnitTemplate.additions and UnitTemplate.additions.faSourceContract\n    and UnitTemplate.additions.faSourceContract.sourceId == \"URA0103\",\n    \"Zeus exhaust source drift\")\nassert(UnitTemplate.visuals and UnitTemplate.visuals.effectsPersistent == nil,\n    \"Zeus exhaust requires the reviewed empty visual slot\")\nUnitTemplate.visuals.effectsPersistent = {\n    { boneName = \"Exhaust_L\", particleName = \"VFX/Unit/vgu4201_exhaust_aircraft_medium.sanvfx\" },\n    { boneName = \"Exhaust_R\", particleName = \"VFX/Unit/vgu4201_exhaust_aircraft_medium.sanvfx\" },\n}\n", 1, "Zeus exhaust appendix");
			ValidatePatchedUnit(text, bomber);
			RequireExactly(text, text2, 1, "Zeus FA bomber source appendix");
			int num = text.IndexOf("\n-- Supreme Commander Overhaul FA Cybran Zeus Exhaust 1.0.0\n-- URA0103 BeamExhaust names both converted rear engine bones and is\n-- enabled at idle and cruise. The native Guard medium-aircraft effect\n-- supplies a persistent local exhaust without altering host movement.\nassert(UnitTemplate.general and UnitTemplate.general.tpId == \"uga1001\", \"Zeus exhaust target drift\")\nassert(UnitTemplate.additions and UnitTemplate.additions.faSourceContract\n    and UnitTemplate.additions.faSourceContract.sourceId == \"URA0103\",\n    \"Zeus exhaust source drift\")\nassert(UnitTemplate.visuals and UnitTemplate.visuals.effectsPersistent == nil,\n    \"Zeus exhaust requires the reviewed empty visual slot\")\nUnitTemplate.visuals.effectsPersistent = {\n    { boneName = \"Exhaust_L\", particleName = \"VFX/Unit/vgu4201_exhaust_aircraft_medium.sanvfx\" },\n    { boneName = \"Exhaust_R\", particleName = \"VFX/Unit/vgu4201_exhaust_aircraft_medium.sanvfx\" },\n}\n", StringComparison.Ordinal);
			int num2 = text.IndexOf(text2, StringComparison.Ordinal) + text2.Length;
			if (num < num2 || HasLaterZeusEffectsAssignment(text.Substring(num2, num - num2)) || HasLaterZeusEffectsAssignment(text.Substring(num + "\n-- Supreme Commander Overhaul FA Cybran Zeus Exhaust 1.0.0\n-- URA0103 BeamExhaust names both converted rear engine bones and is\n-- enabled at idle and cruise. The native Guard medium-aircraft effect\n-- supplies a persistent local exhaust without altering host movement.\nassert(UnitTemplate.general and UnitTemplate.general.tpId == \"uga1001\", \"Zeus exhaust target drift\")\nassert(UnitTemplate.additions and UnitTemplate.additions.faSourceContract\n    and UnitTemplate.additions.faSourceContract.sourceId == \"URA0103\",\n    \"Zeus exhaust source drift\")\nassert(UnitTemplate.visuals and UnitTemplate.visuals.effectsPersistent == nil,\n    \"Zeus exhaust requires the reviewed empty visual slot\")\nUnitTemplate.visuals.effectsPersistent = {\n    { boneName = \"Exhaust_L\", particleName = \"VFX/Unit/vgu4201_exhaust_aircraft_medium.sanvfx\" },\n    { boneName = \"Exhaust_R\", particleName = \"VFX/Unit/vgu4201_exhaust_aircraft_medium.sanvfx\" },\n}\n".Length)))
			{
				throw new InvalidOperationException("A later Zeus visual override replaced the source exhaust.");
			}
			return;
		}
		string text3;
		if (text.IndexOf("-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0", StringComparison.Ordinal) >= 0)
		{
			ValidatePatchedUnit(text, bomber);
			RequireExactly(text, text2, 1, "Zeus FA bomber source appendix");
			text3 = text;
		}
		else
		{
			ValidateStockUnit(text, bomber);
			text3 = AppendOverride(text, text2);
		}
		int startIndex = text3.IndexOf(text2, StringComparison.Ordinal) + text2.Length;
		if (HasLaterZeusEffectsAssignment(text3.Substring(startIndex)))
		{
			throw new InvalidOperationException("A later Zeus visual override owns the exhaust slot.");
		}
		text3 = AppendOverride(text3, "\n-- Supreme Commander Overhaul FA Cybran Zeus Exhaust 1.0.0\n-- URA0103 BeamExhaust names both converted rear engine bones and is\n-- enabled at idle and cruise. The native Guard medium-aircraft effect\n-- supplies a persistent local exhaust without altering host movement.\nassert(UnitTemplate.general and UnitTemplate.general.tpId == \"uga1001\", \"Zeus exhaust target drift\")\nassert(UnitTemplate.additions and UnitTemplate.additions.faSourceContract\n    and UnitTemplate.additions.faSourceContract.sourceId == \"URA0103\",\n    \"Zeus exhaust source drift\")\nassert(UnitTemplate.visuals and UnitTemplate.visuals.effectsPersistent == nil,\n    \"Zeus exhaust requires the reviewed empty visual slot\")\nUnitTemplate.visuals.effectsPersistent = {\n    { boneName = \"Exhaust_L\", particleName = \"VFX/Unit/vgu4201_exhaust_aircraft_medium.sanvfx\" },\n    { boneName = \"Exhaust_R\", particleName = \"VFX/Unit/vgu4201_exhaust_aircraft_medium.sanvfx\" },\n}\n");
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), text3);
		try
		{
			string source = NormalizeNewlines(GetResourceText(obj));
			ValidatePatchedUnit(source, bomber);
			RequireExactly(source, "\n-- Supreme Commander Overhaul FA Cybran Zeus Exhaust 1.0.0\n-- URA0103 BeamExhaust names both converted rear engine bones and is\n-- enabled at idle and cruise. The native Guard medium-aircraft effect\n-- supplies a persistent local exhaust without altering host movement.\nassert(UnitTemplate.general and UnitTemplate.general.tpId == \"uga1001\", \"Zeus exhaust target drift\")\nassert(UnitTemplate.additions and UnitTemplate.additions.faSourceContract\n    and UnitTemplate.additions.faSourceContract.sourceId == \"URA0103\",\n    \"Zeus exhaust source drift\")\nassert(UnitTemplate.visuals and UnitTemplate.visuals.effectsPersistent == nil,\n    \"Zeus exhaust requires the reviewed empty visual slot\")\nUnitTemplate.visuals.effectsPersistent = {\n    { boneName = \"Exhaust_L\", particleName = \"VFX/Unit/vgu4201_exhaust_aircraft_medium.sanvfx\" },\n    { boneName = \"Exhaust_R\", particleName = \"VFX/Unit/vgu4201_exhaust_aircraft_medium.sanvfx\" },\n}\n", 1, "Zeus exhaust appendix");
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, bomber.Description + " source exhaust"));
		}
		catch
		{
			TryDisposeNativeArray(obj, "uncommitted Zeus exhaust");
			throw;
		}
	}

	private static bool HasLaterZeusEffectsAssignment(string source)
	{
		return Regex.IsMatch(source, "UnitTemplate\\.visuals\\.effectsPersistent\\s*=");
	}
}
