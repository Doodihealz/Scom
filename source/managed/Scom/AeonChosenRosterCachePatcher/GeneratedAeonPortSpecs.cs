using System;

namespace AeonChosenRosterCachePatcher;

internal static class GeneratedAeonPortSpecs
{
	internal const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	internal const string ManifestSha256 = "14e172d2796065a956dd18bd1c1ddab9462df8eff65c5990e4e8364c162861df";

	internal const string ProtectedSourceId = "UAL0001";

	internal const string ProtectedTargetId = "ucl0000";

	internal const string CzarFactoryScriptSha256 = "af2458bd797acffbe8c28ca9d683a020d17aa9a7e0ed6df3780e58274e82e3f2";

	internal const string CzarFactoryBuildableCategory = "BUILTBYTIER3FACTORY AEON MOBILE AIR";

	internal const double CzarFactoryRearOffsetZ = -20.0;

	internal const double CzarFactoryDefaultMoveOffZ = -40.0;

	internal const int CzarFactoryStorageSlots = 150;

	internal static readonly GeneratedPortSpec[] All = new GeneratedPortSpec[94]
	{
		new GeneratedPortSpec("uca1701", "UAA0101", "air", "AeonPortAirUnit", "Mirage", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAA0101/UAA0101_unit.bp", "5ef55f0c32ded72630188dc7867d4113d80c5e29b37772eb2637f998f38dce71", new string[14]
		{
			"AEON", "AIR", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "HIGHALTAIR", "INTELLIGENCE", "MOBILE", "PRODUCTSC1", "RECLAIMABLE",
			"SCOUT", "SELECTABLE", "TECH1", "VISIBLETORECON"
		}, "", "", 29.0, 0.0, 0.4, 0.15, 0.6, 0.0, 0.0, 0.0, 0.55, 0.45, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(42.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Plane", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance.", 20.0, 3.0, 2.5, 7.0, 0.009558921679854393, "Units/uca1701/LOD0/uca1701_lod0.sanmodel", "8003311d26c076b761fb8b7779aa76f217d31e47d81d5a6f8497f51567d35d89", 20.0, 17.0, 10.0, 0.0, hasSourceMaxBrake: false, 100.0, air: true, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(400.0, 40.0, 1600.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 10.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca1201", "UAA0102", "air", "AeonPortAirUnit", "Conservator", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAA0102/UAA0102_unit.bp", "752eb83d1d4df00c05fe973708086529a47bef1c48abc266419f9978500086eb", new string[14]
		{
			"AEON", "AIR", "ANTIAIR", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "HIGHALTAIR", "MOBILE", "OVERLAYANTIAIR", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "TECH1", "VISIBLETORECON"
		}, "", "", 285.0, 0.0, 0.8, 0.2, 1.0, 0.0, 0.0, 0.0, 0.4, 0.75, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(28.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Plane", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.", 18.0, 3.0, 2.5, 7.0, 0.0, "Units/uca1201/LOD0/uca1201_lod0.sanmodel", "dca551358efa780723c5bf458e2d46ddc0fd472202a68e3ca8c82c30f4778e68", 15.0, 10.0, 15.0, 0.0, hasSourceMaxBrake: false, 90.0, air: true, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(500.0, 50.0, 2250.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[3]
		{
			new GeneratedWeaponSpec("SonicPulseBattery1", "Anti Air", isDeath: false, isBeam: false, "Turret_Muzzle_Right", "Turret_Muzzle_Right", "Turret_Muzzle_Right", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Muzzle_Right", new string[1] { "Turret_Muzzle_Right" })
			}, rackFireTogether: false, 1, 3, 0.1, 0.0, 10.0, 3, 8.0, 0.0, 0.0, 25.0, 1.0, 1.0, 120.0, 25.0 / 96.0, "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp", "paa111", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 55.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 55.0, 360.0, 0.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("SonicPulseBattery2", "Anti Air", isDeath: false, isBeam: false, "Turret_Muzzle_Left", "Turret_Muzzle_Left", "Turret_Muzzle_Left", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Muzzle_Left", new string[1] { "Turret_Muzzle_Left" })
			}, rackFireTogether: false, 1, 3, 0.1, 0.0, 10.0, 3, 8.0, 0.0, 0.0, 25.0, 1.0, 1.0, 120.0, 0.3, "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp", "paa111", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 55.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 55.0, 360.0, 0.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 25.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca1001", "UAA0103", "air", "AeonPortAirUnit", "Shimmer", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAA0103/UAA0103_unit.bp", "c6d9d7169db4e2f2e49f85ce71c20181f6cc0be50e9b36b4064932a59053530e", new string[15]
		{
			"AEON", "AIR", "BOMBER", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "HIGHALTAIR", "MOBILE", "OVERLAYRADAR", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "SHOWATTACKRETICLE", "TECH1", "VISIBLETORECON"
		}, "", "", 205.0, 0.0, 2.0, 0.25, 0.625, 0.0, 0.0, 0.0, 1.55, 0.45, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, 65.0, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Plane", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.", 18.0, 3.0, 2.5, 7.0, 0.0, "Units/uca1001/LOD0/uca1001_lod0.sanmodel", "edb69ae2bbb35ab6a2b128821ac04bfd85d8ae4cee397e70d985c0c469533cf8", 10.0, 10.0, 10.0, 0.0, hasSourceMaxBrake: false, 90.0, air: true, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(400.0, 80.0, 1400.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[2]
		{
			new GeneratedWeaponSpec("Bomb", "Bomb", isDeath: false, isBeam: false, "Right_Projectile", "Right_Projectile", "Right_Projectile", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Right_Projectile", new string[1] { "Right_Projectile" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 200.0, 4.0, 0.0, 40.0, 0.5, 2.0, 0.0, 1.0, "/projectiles/AIFBombGraviton01/AIFBombGraviton01_proj.bp", "pad002", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "NoArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 60.0, 3.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 100.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca2502", "UAA0104", "air", "AeonPortAirUnit", "Aluminar", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAA0104/UAA0104_unit.bp", "a5d905de315ec71969abc312276cbad2495933398cf2318191d712bca3221742", new string[15]
		{
			"AEON", "AIR", "CANNOTUSEAIRSTAGING", "CANTRANSPORTCOMMANDER", "MOBILE", "OVERLAYANTIAIR", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "TECH2",
			"TRANSPORTATION", "TRANSPORTBUILTBYTIER2FACTORY", "TRANSPORTBUILTBYTIER3FACTORY", "TRANSPORTFOCUS", "VISIBLETORECON"
		}, "", "", 2500.0, 0.0, 2.2, 2.5, 6.0, 0.0, -1.5, -1.5, 2.75, 3.8, "", new string[2] { "Rest", "AnimAopen01" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 6.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Gunship", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.", 9.0, 2.0, 2.0, 8.0, 0.4878074526786804, "Units/uca2502/LOD0/uca2502_lod0.sanmodel", "53a4e8ca7c16f94c6b0846536992a43b099139268165662eceda555793890fed", 15.0, 0.0, 15.0, 0.0, hasSourceMaxBrake: false, 90.0, air: true, airHover: true, "", 0.0, 0.0), new GeneratedEconomySpec(1200.0, 150.0, 4800.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[4]
		{
			new GeneratedWeaponSpec("SonicPulseBattery1", "Anti Air", isDeath: false, isBeam: false, "Muzzle_R", "Turret_Right", "Turret_Right", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Right", new string[1] { "Muzzle_R" })
			}, rackFireTogether: false, 1, 3, 0.1, 0.0, 10.0, 1, 6.0, 0.0, 0.0, 20.0, 0.4, 2.5, 35.0, 0.7142857142857142, "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp", "paa211", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 90.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 75.0, 360.0, 0.5, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("SonicPulseBattery2", "Anti Air", isDeath: false, isBeam: false, "Muzzle_L", "Turret_Left", "Turret_Left", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Left", new string[1] { "Muzzle_L" })
			}, rackFireTogether: false, 1, 3, 0.1, 0.0, 10.0, 1, 6.0, 0.0, 0.0, 20.0, 0.4, 2.5, 35.0, 0.7142857142857142, "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp", "paa211", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 90.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 75.0, 360.0, 0.5, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("SonicPulseBattery3", "Anti Air", isDeath: false, isBeam: false, "Muzzle_F", "Turret_Front", "Turret_Front", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Front", new string[1] { "Muzzle_F" })
			}, rackFireTogether: false, 1, 3, 0.1, 0.0, 10.0, 1, 6.0, 0.0, 0.0, 20.0, 0.4, 2.5, 35.0, 0.7142857142857142, "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp", "paa211", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 180.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 45.0, 360.0, 0.5, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("SonicPulseBattery4", "Anti Air", isDeath: false, isBeam: false, "Muzzle_B", "Turret_Back", "Turret_Back", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Back", new string[1] { "Muzzle_B" })
			}, rackFireTogether: false, 1, 3, 0.1, 0.0, 10.0, 1, 6.0, 0.0, 0.0, 20.0, 0.4, 2.5, 35.0, 0.7142857142857142, "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp", "paa211", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 180.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 45.0, 360.0, 0.5, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca1502", "UAA0107", "air", "AeonPortAirUnit", "Chariot", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAA0107/UAA0107_unit.bp", "e9634d62ac929cfc3712c3b776d0958c53f569046039a9c8eb8e2a5161361a6d", new string[15]
		{
			"AEON", "AIR", "CANNOTUSEAIRSTAGING", "CANTRANSPORTCOMMANDER", "MOBILE", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "TECH1", "TRANSPORTATION",
			"TRANSPORTBUILTBYTIER1FACTORY", "TRANSPORTBUILTBYTIER2FACTORY", "TRANSPORTBUILTBYTIER3FACTORY", "TRANSPORTFOCUS", "VISIBLETORECON"
		}, "", "", 500.0, 0.0, 3.0, 2.5, 3.0, 0.0, -2.0, 0.0, 0.9, 0.9, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 4.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Gunship", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.", 8.0, 2.0, 2.0, 8.0, 0.0, "Units/uca1502/LOD0/uca1502_lod0.sanmodel", "b807d3966a3bb8e8905a76bc4542e6b3d62788634b4010942a986b3316b913f3", 10.0, 0.0, 10.0, 0.0, hasSourceMaxBrake: false, 90.0, air: true, airHover: true, "", 0.0, 0.0), new GeneratedEconomySpec(400.0, 80.0, 1600.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 100.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca2011", "UAA0203", "air", "AeonPortAirUnit", "Specter", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAA0203/UAA0203_unit.bp", "d6d81b195040dd1ee1fb0f63e683895bb13b3c155717d05e09bc27e4521e4c01", new string[12]
		{
			"AEON", "AIR", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "GROUNDATTACK", "MOBILE", "OVERLAYDIRECTFIRE", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE",
			"TECH2", "VISIBLETORECON"
		}, "", "", 1060.0, 0.0, 1.0, 0.5, 1.0, 0.0, -0.075, 0.0, 1.0, 0.75, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Gunship", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.", 10.0, 3.0, 2.5, 7.0, 0.0, "Units/uca2011/LOD0/uca2011_lod0.sanmodel", "e58acbaa3b7797a510ead6a9f4e8610444d7f1a15fcd085b8532ef19c32372cc", 12.0, 3.0, 12.0, 0.0, hasSourceMaxBrake: false, 90.0, air: true, airHover: true, "", 0.0, 0.0), new GeneratedEconomySpec(1600.0, 240.0, 4800.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[2]
		{
			new GeneratedWeaponSpec("Turret", "Direct Fire", isDeath: false, isBeam: false, "Turret_Muzzle01", "C_Turret", "C_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("C_Barrel", new string[4] { "Turret_Muzzle01", "Turret_Muzzle02", "Turret_Muzzle03", "Turret_Muzzle04" })
			}, rackFireTogether: false, 1, 4, 0.2, 0.0, 10.0, 4, 13.0, 0.0, 0.0, 22.0, 1.25, 0.8, 40.0, 0.6325, "/projectiles/ADFLaserLight01/ADFLaserLight01_proj.bp", "pad131", "DirectFire", new string[4] { "Air", "Land", "WaterSurface", "Water" }, "Above", "NoArc", 180.0, 90.0, hasHeadingArc: false, 0.0, 0.0, 60.0, 360.0, 2.0, 0.0, -20.0, 0.0),
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 100.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca2301", "UAA0204", "air", "AeonPortAirUnit", "Skimmer", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAA0204/UAA0204_unit.bp", "166e53fe13aa5dc2c6f430ee6fa75d0b1e6a01f9c2ddf30aa0e299e991a401a9", new string[14]
		{
			"AEON", "AIR", "ANTINAVY", "BOMBER", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "HIGHALTAIR", "MOBILE", "OVERLAYSONAR", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "TECH2", "VISIBLETORECON"
		}, "", "", 820.0, 0.0, 1.0, 0.5, 1.0, 0.0, 0.0, 0.1, 0.75, 0.7, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, null, 90.0, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Plane", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.", 18.0, 3.0, 2.5, 7.0, 0.0, "Units/uca2301/LOD0/uca2301_lod0.sanmodel", "baca0c768765aabe25372ec64249e1782dce49a9a65e24ed71ba8f3a0b8f0bde", 15.0, 13.0, 15.0, 0.0, hasSourceMaxBrake: false, 90.0, air: true, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1600.0, 240.0, 4800.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[2]
		{
			new GeneratedWeaponSpec("Bomb", "Anti Navy", isDeath: false, isBeam: false, "Torpedo", "Torpedo", "Torpedo", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Torpedo", new string[2] { "Torpedo", "Torpedo" })
			}, rackFireTogether: false, 1, 2, 1.8, 0.0, 10.0, 2, 375.0, 0.0, 4.0, 42.0, 0.08, 12.5, 14.0, 20.0, "/projectiles/AANDepthCharge03/AANDepthCharge03_proj.bp", "pad002", "DirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "NoArc", 0.0, 0.0, hasHeadingArc: true, 0.0, 30.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 150.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca3701", "UAA0302", "air", "AeonPortAirUnit", "Seer", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAA0302/UAA0302_unit.bp", "10f13ff89abd5e4a2d56ea9409818b3a9c315f53b5ba30a0d0ea6129bfeaa6c5", new string[14]
		{
			"AEON", "AIR", "BUILTBYTIER3FACTORY", "HIGHALTAIR", "INTELLIGENCE", "MOBILE", "OVERLAYOMNI", "OVERLAYRADAR", "PRODUCTSC1", "RADAR",
			"RECLAIMABLE", "SELECTABLE", "TECH3", "VISIBLETORECON"
		}, "", "", 1050.0, 0.0, 0.8, 0.25, 1.4, 0.0, 0.0, 0.0, 0.55, 1.05, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(64.0, 96.0, null, 30.0, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Plane", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.", 25.0, 3.0, 2.5, 7.0, 0.0, "Units/uca3701/LOD0/uca3701_lod0.sanmodel", "cba5a9c98528d5952da03d8fc0e7bb63ac43bcc713fdb032b9744f9cb70c38b0", 30.0, 25.0, 30.0, 0.0, hasSourceMaxBrake: false, 90.0, air: true, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(900.0, 195.0, 7500.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 100.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca3201", "UAA0303", "air", "AeonPortAirUnit", "Corona", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAA0303/UAA0303_unit.bp", "be489b6ab5bde1ef6951fa492d58a2a00ac22b5ad75ca899a3061a59830e38e6", new string[12]
		{
			"AEON", "AIR", "ANTIAIR", "BUILTBYTIER3FACTORY", "HIGHALTAIR", "MOBILE", "OVERLAYANTIAIR", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE",
			"TECH3", "VISIBLETORECON"
		}, "", "", 2500.0, 0.0, 1.0, 0.3, 1.0, 0.0, 0.0, -0.2, 1.0, 1.1, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Plane", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.", 20.0, 3.0, 2.5, 7.0, 0.0, "Units/uca3201/LOD0/uca3201_lod0.sanmodel", "33326c708f83f52a2d5e3389a14eecc5d19f78273aa0ade97fa162732bb0f79f", 25.0, 8.0, 25.0, 0.0, hasSourceMaxBrake: false, 90.0, air: true, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(3000.0, 400.0, 40000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[2]
		{
			new GeneratedWeaponSpec("AutoCannon1", "Anti Air", isDeath: false, isBeam: false, "Muzzle", "Muzzle", "Muzzle", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Muzzle", new string[1] { "Muzzle" })
			}, rackFireTogether: false, 1, 3, 0.1, 0.0, 10.0, 3, 135.0, 0.0, 0.0, 30.0, 1.0, 1.0, 120.0, 0.3125, "/projectiles/AAAAutocannonQuantum01/AAAAutocannonQuantum01_proj.bp", "paa311", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 55.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 55.0, 360.0, 0.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 200.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca3001", "UAA0304", "air", "AeonPortAirUnit", "Shocker", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAA0304/UAA0304_unit.bp", "915bd856451b093319ffad7cb2cf988cec9df8b53a959edaefbfb9a69c1a062c", new string[13]
		{
			"AEON", "AIR", "BOMBER", "BUILTBYTIER3FACTORY", "HIGHALTAIR", "MOBILE", "OVERLAYRADAR", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE",
			"SHOWATTACKRETICLE", "TECH3", "VISIBLETORECON"
		}, "", "", 3800.0, 0.0, 2.0, 0.5, 1.6, 0.0, 0.0, 0.2, 2.0, 1.3, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, 65.0, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Plane", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.", 20.0, 3.0, 2.5, 7.0, 0.0, "Units/uca3001/LOD0/uca3001_lod0.sanmodel", "f1c38cc0546bc7d41d32bb8dee88dac1f99041924e6e2426c4965e4b310e2c3c", 17.0, 15.0, 17.0, 0.0, hasSourceMaxBrake: false, 90.0, air: true, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(8400.0, 2100.0, 105000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[2]
		{
			new GeneratedWeaponSpec("Bomb", "Bomb", isDeath: false, isBeam: false, "Muzzle", "Muzzle", "Muzzle", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Muzzle", new string[1] { "Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 3450.0, 4.0, 0.0, 90.0, 0.2, 5.0, 0.0, 1.0, "/projectiles/AIFBombQuark01/AIFBombQuark01_proj.bp", "pad004", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "NoArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 60.0, 3.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 500.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca4011", "UAA0310", "czar", "AeonPortCzar", "CZAR", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAA0310/UAA0310_unit.bp", "0d40e224ed63f9e53e7128c4ee9c34fb73255209d38a2193b4d80bd5eaf5932e", new string[25]
		{
			"AEON", "AIR", "AIRSTAGINGPLATFORM", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "CANNOTUSEAIRSTAGING", "CARRIER", "DRAGBUILD", "EXPERIMENTAL", "FACTORY",
			"HIGHALTAIR", "MOBILE", "NEEDMOBILEBUILD", "OVERLAYANTIAIR", "OVERLAYANTINAVY", "OVERLAYMISC", "OVERLAYRADAR", "OVERLAYSONAR", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SHOWATTACKRETICLE", "SHOWQUEUE", "TARGETCHASER", "VISIBLETORECON"
		}, "", "", 48000.0, 15.0, 21.0, 3.0, 21.0, 0.0, -1.5, 0.0, 13.0, 13.0, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 20.0, 20.0, hasSourceSkirt: true, 24.0, 24.0, -2.0, -2.0), new GeneratedIntelSpec(70.0, 200.0, 150.0, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Gunship", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance.", 25.0, 2.0, 3.5, 7.0, 2.8341667652130127, "Units/uca4011/LOD0/uca4011_lod0.sanmodel", "e2cd1bd7867aee210e0afd3d6f310d6850de9672b3f58fb979759d6b815a6cfc", 8.0, 0.0, 1.0, 0.0, hasSourceMaxBrake: false, 20.0, air: true, airHover: true, "", 0.0, 0.0), new GeneratedEconomySpec(33750.0, 45000.0, 731250.0, 180.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[10]
		{
			new GeneratedWeaponSpec("QuantumBeamGeneratorWeapon", "Direct Fire Experimental", isDeath: false, isBeam: true, "Center_Muzzle", "Center_Muzzle", "Center_Muzzle", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Center_Muzzle", new string[1] { "Center_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 0.0, 1, 1000.0, 4.0, 0.0, 30.0, 0.2, 5.0, 0.0, 0.1, "", "pad171", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "NoArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 60.0, 0.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("SonicPulseBattery1", "Anti Air", isDeath: false, isBeam: false, "Left_Turret01_Muzzle", "Left_Turret01", "Left_Turret01_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Left_Turret01_Barrel", new string[1] { "Left_Turret01_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.1, 0.0, 10.0, 1, 300.0, 0.0, 0.0, 64.0, 0.8, 1.25, 50.0, 4.0, "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp", "paa341", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 100.0, 360.0, hasHeadingArc: true, 230.0, 120.0, 180.0, 360.0, 10.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("SonicPulseBattery2", "Anti Air", isDeath: false, isBeam: false, "Left_Turret03_Muzzle", "Left_Turret03", "Left_Turret03_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Left_Turret03_Barrel", new string[1] { "Left_Turret03_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.1, 0.0, 10.0, 1, 300.0, 0.0, 0.0, 64.0, 0.8, 1.25, 50.0, 4.0, "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp", "paa341", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 100.0, 360.0, hasHeadingArc: true, 310.0, 120.0, 180.0, 360.0, 10.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("SonicPulseBattery3", "Anti Air", isDeath: false, isBeam: false, "Right_Turret01_Muzzle", "Right_Turret01", "Right_Turret01_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Right_Turret01_Barrel", new string[1] { "Right_Turret01_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 300.0, 0.0, 0.0, 64.0, 0.8, 1.25, 50.0, 4.0, "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp", "paa341", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 100.0, 360.0, hasHeadingArc: true, 130.0, 120.0, 180.0, 360.0, 10.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("SonicPulseBattery4", "Anti Air", isDeath: false, isBeam: false, "Right_Turret03_Muzzle", "Right_Turret03", "Right_Turret03_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Right_Turret03_Barrel", new string[1] { "Right_Turret03_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 300.0, 0.0, 0.0, 64.0, 0.8, 1.25, 50.0, 4.0, "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp", "paa341", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 100.0, 360.0, hasHeadingArc: true, 50.0, 120.0, 180.0, 360.0, 10.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("DepthCharge01", "Anti Navy", isDeath: false, isBeam: false, "Harmonic_Muzzle01", "Harmonic_Muzzle01", "Harmonic_Muzzle01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Harmonic_Muzzle01", new string[1] { "Harmonic_Muzzle01" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 150.0, 1.5, 0.0, 50.0, 0.25, 4.0, 0.0, 1.0, "/projectiles/AANDepthCharge01/AANDepthCharge01_proj.bp", "pai311", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 60.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("DepthCharge02", "Anti Navy", isDeath: false, isBeam: false, "Harmonic_Muzzle02", "Harmonic_Muzzle02", "Harmonic_Muzzle02", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Harmonic_Muzzle02", new string[1] { "Harmonic_Muzzle02" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 150.0, 1.5, 0.0, 50.0, 0.25, 4.0, 0.0, 1.0, "/projectiles/AANDepthCharge01/AANDepthCharge01_proj.bp", "pai311", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 60.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("AAFizz01", "Anti Air", isDeath: false, isBeam: false, "Left_Turret02_WepFocus", "Left_Turret02", "Left_Turret02_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Left_Turret02_Barrel", new string[2] { "Left_Turret02_Muzzle01", "Left_Turret02_Muzzle02" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 240.0, 3.0, 0.0, 44.0, 2.0, 0.5, 20.0, 2.75, "/projectiles/AAAFizz01/AAAFizz01_proj.bp", "paa341", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 90.0, 180.0, hasHeadingArc: true, 270.0, 120.0, 90.0, 180.0, 3.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("AAFizz02", "Anti Air", isDeath: false, isBeam: false, "Right_Turret02_WepFocus", "Right_Turret02", "Right_Turret02_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Right_Turret02_Barrel", new string[2] { "Right_Turret02_Muzzle01", "Right_Turret02_Muzzle02" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 240.0, 3.0, 0.0, 44.0, 2.0, 0.5, 20.0, 2.75, "/projectiles/AAAFizz01/AAAFizz01_proj.bp", "paa341", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 90.0, 180.0, hasHeadingArc: true, 90.0, 120.0, 90.0, 180.0, 1.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 15000.0, 15.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: true, "Center_Muzzle", "VFX/SupremeCommanderOverhaul/Czar/Impact/czar_quantum_impact.sanvfx", "VFX/SupremeCommanderOverhaul/Czar/Materials/czar_quantum_beam_core.sanmaterial", 0.0, -1.0, 0.0, 1000.0, 0.2, 4.0, 50.0, 30.0, 5.0)),
		new GeneratedPortSpec("ucs1511", "UAB0101", "land_factory", "AeonPortLandFactory", "Land Factory", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB0101/UAB0101_unit.bp", "fc7b959e42555e8c9f70a33c837519b91bb234fb3963d88ac9022496e2302fc7", new string[19]
		{
			"AEON", "BUILTBYCOMMANDER", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3ENGINEER", "CONSTRUCTION", "DRAGBUILD", "FACTORY", "LAND", "PRODUCTSC1",
			"RALLYPOINT", "RECLAIMABLE", "SELECTABLE", "SHOWQUEUE", "SIZE16", "SORTCONSTRUCTION", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "UAB0201", 4400.0, 0.0, 3.6, 1.0, 3.6, 0.0, 0.0, 0.0, 2.75, 2.75, "Attachpoint", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Footprint.Size", 5.0, 5.0, hasSourceSkirt: true, 8.0, 8.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(300.0, 240.0, 2100.0, 20.0, 0.0, 0.0, 0.0, 0.0, 80.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1512", "UAB0102", "air_factory", "AeonPortAirFactory", "Air Factory", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB0102/UAB0102_unit.bp", "9b5583fba065681bed436f0777ab1e6187c10dda2da0e99e20b934aaa7bd84d8", new string[19]
		{
			"AEON", "AIR", "BUILTBYCOMMANDER", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3ENGINEER", "CONSTRUCTION", "DRAGBUILD", "FACTORY", "PRODUCTSC1",
			"RALLYPOINT", "RECLAIMABLE", "SELECTABLE", "SHOWQUEUE", "SIZE16", "SORTCONSTRUCTION", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "UAB0202", 4400.0, 0.0, 3.0, 0.7, 3.0, 0.0, 0.0, 0.0, 2.85, 2.75, "Attachpoint", new string[2] { "Rest", "AnimUpgrade" }, new GeneratedPlacementSpec("Footprint.Size", 5.0, 5.0, hasSourceSkirt: true, 8.0, 8.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(300.0, 210.0, 2400.0, 20.0, 0.0, 0.0, 0.0, 0.0, 80.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1513", "UAB0103", "naval_factory", "AeonPortNavalFactory", "Naval Factory", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB0103/UAB0103_unit.bp", "c4a4ecbc0b8e053b8bb4d46a90fa47e19c137038f297572ea53db6b3e9deedb6", new string[19]
		{
			"AEON", "BUILTBYCOMMANDER", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3ENGINEER", "CONSTRUCTION", "DRAGBUILD", "FACTORY", "NAVAL", "PRODUCTSC1",
			"RALLYPOINT", "RECLAIMABLE", "SELECTABLE", "SHOWQUEUE", "SIZE16", "SORTCONSTRUCTION", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "UAB0203", 4400.0, 0.0, 4.0, 2.0, 10.0, 0.0, -1.0, 0.0, 2.5, 6.5, "Attachpoint01", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 12.0, 14.0, hasSourceSkirt: true, 12.0, 14.0, -6.0, -2.0), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(300.0, 300.0, 1500.0, 20.0, 0.0, 0.0, 0.0, 0.0, 80.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2511", "UAB0201", "land_factory", "AeonPortLandFactory", "Land Factory", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB0201/UAB0201_unit.bp", "1ca3d3a1df107982c346943ead1522fd6ad4108a440617cf1f08fed2e8e0ff7f", new string[17]
		{
			"AEON", "BUILTBYTIER1FACTORY", "CONSTRUCTION", "CONSTRUCTIONSORTDOWN", "DRAGBUILD", "FACTORY", "LAND", "PRODUCTSC1", "RALLYPOINT", "RECLAIMABLE",
			"SELECTABLE", "SHOWQUEUE", "SIZE16", "SORTCONSTRUCTION", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "UAB0101", "UAB0301", 8200.0, 0.0, 3.6, 1.0, 3.6, 0.0, 0.0, 0.0, 2.75, 2.75, "Attachpoint", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Footprint.Size", 5.0, 5.0, hasSourceSkirt: true, 8.0, 8.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1600.0, 800.0, 7200.0, 40.0, 0.0, 0.0, 0.0, 0.0, 160.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2512", "UAB0202", "air_factory", "AeonPortAirFactory", "Air Factory", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB0202/UAB0202_unit.bp", "24f7d32122abf9346431a991316c66c99e3e93feccc6309411a425d5c645785e", new string[17]
		{
			"AEON", "AIR", "BUILTBYTIER1FACTORY", "CONSTRUCTION", "CONSTRUCTIONSORTDOWN", "DRAGBUILD", "FACTORY", "PRODUCTSC1", "RALLYPOINT", "RECLAIMABLE",
			"SELECTABLE", "SHOWQUEUE", "SIZE16", "SORTCONSTRUCTION", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "UAB0102", "UAB0302", 8200.0, 0.0, 4.0, 0.7, 4.0, 0.0, 0.0, 0.0, 2.85, 2.75, "Attachpoint", new string[2] { "Rest", "AnimUpgrade" }, new GeneratedPlacementSpec("Footprint.Size", 5.0, 5.0, hasSourceSkirt: true, 8.0, 8.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1800.0, 630.0, 11700.0, 40.0, 0.0, 0.0, 0.0, 0.0, 160.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2513", "UAB0203", "naval_factory", "AeonPortNavalFactory", "Naval Factory", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB0203/UAB0203_unit.bp", "374293416b2af4a97e4cb208eefa6edbd7824eca5bd9763e112f1425b7fe6cb3", new string[17]
		{
			"AEON", "BUILTBYTIER1FACTORY", "CONSTRUCTION", "CONSTRUCTIONSORTDOWN", "DRAGBUILD", "FACTORY", "NAVAL", "PRODUCTSC1", "RALLYPOINT", "RECLAIMABLE",
			"SELECTABLE", "SHOWQUEUE", "SIZE16", "SORTCONSTRUCTION", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "UAB0103", "UAB0303", 16000.0, 0.0, 4.0, 2.0, 10.0, 0.0, -1.0, 0.0, 2.5, 7.5, "Attachpoint01", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 12.0, 14.0, hasSourceSkirt: true, 12.0, 14.0, -6.0, -2.0), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1800.0, 1170.0, 5400.0, 40.0, 0.0, 0.0, 0.0, 0.0, 160.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3511", "UAB0301", "land_factory", "AeonPortLandFactory", "Land Factory", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB0301/UAB0301_unit.bp", "bc1c32309fd20def2b2e24bd71edf1532c07b28992ac228fc8e8995df57e63f9", new string[17]
		{
			"AEON", "BUILTBYTIER2FACTORY", "CONSTRUCTION", "CONSTRUCTIONSORTDOWN", "DRAGBUILD", "FACTORY", "LAND", "PRODUCTSC1", "RALLYPOINT", "RECLAIMABLE",
			"SELECTABLE", "SHOWQUEUE", "SIZE16", "SORTCONSTRUCTION", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "UAB0201", "", 20000.0, 0.0, 3.6, 1.0, 3.6, 0.0, 0.0, 0.0, 2.75, 2.75, "Attachpoint", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 5.0, 5.0, hasSourceSkirt: true, 8.0, 8.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(8400.0, 3150.0, 28350.0, 60.0, 0.0, 0.0, 0.0, 0.0, 320.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3512", "UAB0302", "air_factory", "AeonPortAirFactory", "Air Factory", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB0302/UAB0302_unit.bp", "d475f08ab1fc0434b548f6f2959c808750615bfb2dc9f7dc1dd25bf8f336abfd", new string[17]
		{
			"AEON", "AIR", "BUILTBYTIER2FACTORY", "CONSTRUCTION", "CONSTRUCTIONSORTDOWN", "DRAGBUILD", "FACTORY", "PRODUCTSC1", "RALLYPOINT", "RECLAIMABLE",
			"SELECTABLE", "SHOWQUEUE", "SIZE16", "SORTCONSTRUCTION", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "UAB0202", "", 20000.0, 0.0, 4.0, 0.7, 4.0, 0.0, 0.0, 0.0, 2.85, 2.75, "Attachpoint", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 5.0, 5.0, hasSourceSkirt: true, 8.0, 8.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(8400.0, 3150.0, 105000.0, 60.0, 0.0, 0.0, 0.0, 0.0, 320.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3513", "UAB0303", "naval_factory", "AeonPortNavalFactory", "Naval Factory", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB0303/UAB0303_unit.bp", "7ab2f1b00839e1f449406dfd87ec8b1884a393ba857d1a2f59c258d02694c2c0", new string[17]
		{
			"AEON", "BUILTBYTIER2FACTORY", "CONSTRUCTION", "CONSTRUCTIONSORTDOWN", "DRAGBUILD", "FACTORY", "NAVAL", "PRODUCTSC1", "RALLYPOINT", "RECLAIMABLE",
			"SELECTABLE", "SHOWQUEUE", "SIZE16", "SORTCONSTRUCTION", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "UAB0203", "", 37500.0, 0.0, 4.0, 2.0, 10.0, 0.0, -1.0, 0.0, 2.5, 8.8, "Attachpoint01", new string[1] { "Rest" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 12.0, 14.0, hasSourceSkirt: true, 12.0, 14.0, -6.0, -2.0), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(7200.0, 3150.0, 23400.0, 60.0, 0.0, 0.0, 0.0, 0.0, 320.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2510", "UAB0304", "gateway", "AeonPortLandFactory", "Portal", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB0304/UAB0304_unit.bp", "3e0029f156b49dd168a2f0bd3b46086c3f1e3be1c4f7ec4c899fa9e49f7a71d7", new string[16]
		{
			"AEON", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "FACTORY", "GATE", "PRODUCTSC1", "RALLYPOINT", "RECLAIMABLE", "SELECTABLE",
			"SHOWQUEUE", "SIZE20", "SORTSTRATEGIC", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "", "", 10000.0, 0.0, 5.0, 1.5, 5.0, 0.0, 0.0, 0.0, 3.75, 3.5, "Attachpoint", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 7.0, 7.0, hasSourceSkirt: true, 10.0, 10.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(3000.0, 3000.0, 30000.0, 120.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1611", "UAB1101", "power", "AeonPortEnergyGenerator", "Power Generator", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB1101/UAB1101_unit.bp", "ee45b4f2d63480574a0d370ae2372cd5d44b20e88869cac5003b2500d479094d", new string[16]
		{
			"AEON", "BUILTBYCOMMANDER", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "ECONOMIC", "ENERGYPRODUCTION", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SIZE4", "SORTECONOMY", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "", 600.0, 0.0, 0.75, 0.5, 0.75, 0.0, 0.0, 0.0, 0.65, 0.65, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 2.0, 2.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(null, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(125.0, 75.0, 750.0, 0.0, 0.0, 20.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("DeathWeapon", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 250.0, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1614", "UAB1102", "power", "AeonPortEnergyGenerator", "Hydrocarbon Power Plant", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB1102/UAB1102_unit.bp", "226e38c51f687f906d0d30ba449d032223b40eed65aaff7bb8c0607b021f25b6", new string[16]
		{
			"AEON", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3ENGINEER", "ECONOMIC", "ENERGYPRODUCTION", "HYDROCARBON", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SIZE12", "SORTECONOMY", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "", 1600.0, 0.0, 1.75, 2.5, 1.75, 0.0, -0.25, 0.0, 1.9, 1.9, "", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Footprint.Size", 3.0, 3.0, hasSourceSkirt: true, 6.0, 6.0, -1.5, -1.5), new GeneratedIntelSpec(null, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(400.0, 160.0, 800.0, 0.0, 0.0, 100.0, 0.0, 0.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1601", "UAB1103", "extractor", "AeonPortAlloyExtractor", "Mass Extractor", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB1103/UAB1103_unit.bp", "a689422b2297f98499348c07ad287c27814ca9c136c92043e055e16f82e3989f", new string[17]
		{
			"AEON", "BUILTBYCOMMANDER", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3ENGINEER", "ECONOMIC", "MASSEXTRACTION", "MASSPRODUCTION", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SHOWQUEUE", "SIZE4", "SORTECONOMY", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "UAB1202", 600.0, 0.0, 0.75, 1.4, 0.75, 0.0, 0.0, 0.0, 0.65, 0.65, "", new string[3] { "Rest", "AnimPump", "AnimUpgrade" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 2.0, 2.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(null, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(60.0, 36.0, 360.0, 10.0, 2.0, 0.0, 0.0, 2.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2806", "UAB1104", "fabricator", "AeonPortStructure", "Mass Fabricator", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB1104/UAB1104_unit.bp", "3c4eb4cef01985a92ce78af0b587346f9df08d3fc471cb52f22b307e3e47ff5f", new string[17]
		{
			"AEON", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "ECONOMIC", "MASSFABRICATION", "MASSPRODUCTION", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "SIZE4", "SORTECONOMY", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "", "UAB1303", 360.0, 0.0, 0.75, 0.35, 0.75, 0.0, 0.0, 0.0, 0.65, 0.65, "", new string[2] { "Rest", "AnimAopen01" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 2.0, 2.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(null, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(500.0, 100.0, 4000.0, 0.0, 1.0, 0.0, 0.0, 150.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("DeathWeapon", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 370.0, 5.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1612", "UAB1105", "storage", "AeonPortStorage", "Energy Storage", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB1105/UAB1105_unit.bp", "a956cc05ab2d449c1252d0d2e088f55347da95b85f91428c4dde955dbcd2bd7b", new string[16]
		{
			"AEON", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "ECONOMIC", "ENERGYSTORAGE", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SIZE4", "SORTECONOMY", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "", 500.0, 0.0, 0.8, 0.4, 0.8, 0.0, 0.0, 0.0, 0.65, 0.65, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 2.0, 2.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(null, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(200.0, 250.0, 1200.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5000.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("DeathWeapon", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 2000.0, 5.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1602", "UAB1106", "storage", "AeonPortStorage", "Mass Storage", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB1106/UAB1106_unit.bp", "67fa5432484ba5a246f0ed1920b3de446472d3d424d06547bdae20977b38776d", new string[16]
		{
			"AEON", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "ECONOMIC", "MASSSTORAGE", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SIZE4", "SORTECONOMY", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "", 1600.0, 0.0, 0.85, 0.5, 0.85, 0.0, 0.0, 0.0, 0.65, 0.65, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(null, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(250.0, 200.0, 1500.0, 0.0, 0.0, 0.0, 0.0, 0.0, 500.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2611", "UAB1201", "power", "AeonPortEnergyGenerator", "Power Generator", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB1201/UAB1201_unit.bp", "780b0749722ac6c56861949cd03a8a40de76a3b0c1e026d07ea861460b99fc9f", new string[16]
		{
			"AEON", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "ECONOMIC", "ENERGYPRODUCTION", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SIZE12", "SORTECONOMY", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "", "", 2160.0, 0.0, 2.2, 1.3, 2.2, 0.0, 0.0, 0.0, 1.8, 1.8, "", new string[2] { "Rest", "AnimAdeath" }, new GeneratedPlacementSpec("Footprint.Size", 3.0, 3.0, hasSourceSkirt: true, 6.0, 6.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(2000.0, 1200.0, 12000.0, 0.0, 0.0, 500.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("DeathWeapon", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 1500.0, 5.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2601", "UAB1202", "extractor", "AeonPortAlloyExtractor", "Mass Extractor", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB1202/UAB1202_unit.bp", "79b006969a88b2e16acebe9cfd234890397b5fcd77a7e9c9f9e783efef0725d7", new string[17]
		{
			"AEON", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "ECONOMIC", "MASSEXTRACTION", "MASSPRODUCTION", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SHOWQUEUE", "SIZE4", "SORTECONOMY", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "UAB1103", "UAB1302", 3000.0, 0.0, 0.75, 1.4, 0.75, 0.0, 0.0, 0.0, 0.65, 0.65, "", new string[3] { "Rest", "AnimPump", "AnimUpgrade" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 2.0, 2.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(900.0, 900.0, 5400.0, 15.0, 6.0, 0.0, 0.0, 9.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3611", "UAB1301", "power", "AeonPortEnergyGenerator", "Quantum Reactor", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB1301/UAB1301_unit.bp", "96e85f646efd233848af22f3cd6c6bfc74afde1f5dd27e5d2975f1b0fd11dfcf", new string[14]
		{
			"AEON", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "ECONOMIC", "ENERGYPRODUCTION", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "SIZE16",
			"SORTECONOMY", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "", "", 9720.0, 0.0, 4.0, 2.75, 4.0, 0.0, 0.0, 0.0, 2.9, 2.9, "", new string[2] { "Rest", "AnimAdeath" }, new GeneratedPlacementSpec("Footprint.Size", 5.0, 5.0, hasSourceSkirt: true, 8.0, 8.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(5400.0, 3240.0, 57600.0, 0.0, 0.0, 2500.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("DeathWeapon", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 8000.0, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3601", "UAB1302", "extractor", "AeonPortAlloyExtractor", "Mass Extractor", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB1302/UAB1302_unit.bp", "18a5d6b6e2a027d0d599dc47177e48883190de7fadc97e3da3eab25a0010ad83", new string[14]
		{
			"AEON", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "ECONOMIC", "MASSEXTRACTION", "MASSPRODUCTION", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "SIZE4",
			"SORTECONOMY", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "UAB1202", "", 8400.0, 0.0, 0.75, 1.4, 0.75, 0.0, 0.0, 0.0, 0.65, 0.65, "", new string[2] { "Rest", "AnimPump" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 2.0, 2.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(2875.0, 4600.0, 31625.0, 0.0, 18.0, 0.0, 0.0, 54.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3603", "UAB1303", "fabricator", "AeonPortStructure", "Mass Fabricator", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB1303/UAB1303_unit.bp", "dfc725ed7309bf0bb00f1bd07b83cd25d356413cc9783cee81be55463f237be1", new string[15]
		{
			"AEON", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "ECONOMIC", "MASSFABRICATION", "MASSPRODUCTION", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE",
			"SIZE12", "SORTECONOMY", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "UAB1104", "", 6000.0, 0.0, 1.75, 1.75, 1.75, 0.0, -0.25, 0.0, 1.55, 1.55, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 3.0, 3.0, hasSourceSkirt: true, 6.0, 6.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(3750.0, 3000.0, 65000.0, 0.0, 12.0, 0.0, 0.0, 3500.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("DeathWeapon", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 5000.0, 14.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1001", "UAB2101", "defence", "AeonPortStructure", "Erupter", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB2101/UAB2101_unit.bp", "aefde7f0fdc1f1a9054034603351377ef77ebcefa125f02a8286f561126b220d", new string[17]
		{
			"AEON", "BUILTBYCOMMANDER", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3ENGINEER", "DEFENSE", "DIRECTFIRE", "DRAGBUILD", "OVERLAYDIRECTFIRE", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "SIZE4", "SORTDEFENSE", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "", 1300.0, 0.0, 0.5, 0.75, 0.5, 0.0, 0.0, 0.0, 0.55, 0.55, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 1.0, 1.0, hasSourceSkirt: true, 1.0, 1.0, 0.0, 0.0), new GeneratedIntelSpec(24.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(250.0, 250.0, 2000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MainGun", "Direct Fire", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 50.0, 0.0, 0.0, 26.0, 3.0, 1.0 / 3.0, 35.0, 0.8542857142857142, "/projectiles/ADFGraviton01/ADFGraviton01_proj.bp", "pad111", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 180.0, 90.0, hasHeadingArc: false, 0.0, 0.0, 60.0, 90.0, 2.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1201", "UAB2104", "defence", "AeonPortStructure", "Seeker", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB2104/UAB2104_unit.bp", "692e8e43f7de6c75379bd7c6955ad3711157ff0f2a0574d3958e957fedf05311", new string[17]
		{
			"AEON", "ANTIAIR", "BUILTBYCOMMANDER", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3ENGINEER", "DEFENSE", "DRAGBUILD", "OVERLAYANTIAIR", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "SIZE4", "SORTDEFENSE", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "", 1200.0, 0.0, 0.5, 1.2, 0.5, 0.0, -0.45, 0.0, 0.55, 0.55, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 1.0, 1.0, hasSourceSkirt: true, 1.0, 1.0, 0.0, 0.0), new GeneratedIntelSpec(24.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(250.0, 200.0, 2000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("AAGun", "Anti Air", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 3, 0.2, 0.0, 10.0, 3, 14.0, 0.0, 0.0, 44.0, 1.6, 0.625, 45.0, 1.222222222222222, "/projectiles/AAASonicPulse01/AAASonicPulse01_proj.bp", "paa111", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 180.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 45.0, 180.0, 0.5, 0.0, 45.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2102", "UAB2108", "defence", "AeonPortStructure", "Serpentine", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB2108/UAB2108_unit.bp", "f957f075831aa8e18a1d2a67f93335d0593d94463b7b0b55d3c2c894ef4edeec", new string[19]
		{
			"AEON", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "INDIRECTFIRE", "OVERLAYINDIRECTFIRE", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SILO", "SIZE4", "SORTSTRATEGIC", "STRATEGIC", "STRUCTURE", "TACTICALMISSILEPLATFORM", "TECH2", "VISIBLETORECON"
		}, "", "", 1500.0, 0.0, 0.65, 0.35, 1.0, 0.0, 0.0, 0.0, 0.47, 0.8, "", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(24.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(700.0, 700.0, 3500.0, 80.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("CruiseMissile", "Missile", isDeath: false, isBeam: false, "Turret", "Turret", "Turret", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret", new string[1] { "Turret" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 6000.0, 2.0, 15.0, 256.0, 3.0, 1.0 / 3.0, 5.0, 30.0, "/projectiles/AIFMissileTactical01/AIFMissileTactical01_proj.bp", "pai211", "IndirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "HighArc", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1301", "UAB2109", "defence", "AeonPortStructure", "Tide", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB2109/UAB2109_unit.bp", "49f595281ffbb407e2274945ef9768c95798d9ef6a69c6c6efae4b257cfbc05a", new string[18]
		{
			"AEON", "ANTINAVY", "BUILTBYCOMMANDER", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3ENGINEER", "DEFENSE", "DRAGBUILD", "OVERLAYANTINAVY", "OVERLAYSONAR",
			"PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "SIZE4", "SORTDEFENSE", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "", 1625.0, 0.0, 0.9, 2.0, 0.9, 0.0, -1.0, 0.05, 0.65, 0.65, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 1.0, 1.0, hasSourceSkirt: true, 1.0, 1.0, 0.0, 0.0), new GeneratedIntelSpec(12.0, null, 35.0, null, null, null, null, null, null, null, 45.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(450.0, 450.0, 3600.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("Turret01", "Anti Navy", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 2, 0.8, 0.0, 10.0, 1, 150.0, 0.0, 0.0, 50.0, 0.25, 4.0, 5.0, 7.0, "/projectiles/AANTorpedo01/AANTorpedo01_proj.bp", "pai111", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 25.0, hasHeadingArc: false, 0.0, 0.0, 35.0, 35.0, 30.0, 0.0, -20.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2201", "UAB2204", "defence", "AeonPortStructure", "Marr", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB2204/UAB2204_unit.bp", "ed67446216872bcd5678c401c84b0087b238d02dc5301ada7515296edaaa9458", new string[17]
		{
			"AEON", "ANTIAIR", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DEFENSE", "DRAGBUILD", "OVERLAYANTIAIR", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "SIZE4", "SORTDEFENSE", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "", "", 3500.0, 0.0, 0.8, 1.2, 0.8, 0.0, -0.4, 0.0, 0.65, 0.7, "", new string[2] { "Rest", "AnimActivate" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 2.0, 2.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(24.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(700.0, 560.0, 5600.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("AAFizz", "Anti Air", isDeath: false, isBeam: false, "WepFocus", "Turret", "Barrel_Right", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("WepFocus", new string[1] { "WepFocus" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.1, 10.0, 1, 150.0, 4.0, 0.0, 44.0, 1.0, 1.0, 20.0, 2.75, "/projectiles/AAAFizz01/AAAFizz01_proj.bp", "paa211", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 180.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 40.0, 180.0, 2.0, 0.0, 35.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2301", "UAB2205", "defence", "AeonPortStructure", "Wave Break", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB2205/UAB2205_unit.bp", "00f2eb18ab01337858a23dcf097b34ae08e5952cb6c6e23827160ed34b40a6f4", new string[18]
		{
			"AEON", "ANTINAVY", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DEFENSE", "DRAGBUILD", "OVERLAYANTINAVY", "OVERLAYSONAR",
			"PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "SIZE4", "SORTDEFENSE", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "", "", 6100.0, 0.0, 1.5, 2.2, 1.5, 0.0, -1.0, 0.0, 1.0, 1.0, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 2.0, 2.0, hasSourceSkirt: true, 3.0, 3.0, -0.5, -0.5), new GeneratedIntelSpec(20.0, null, 35.0, null, true, true, null, null, null, null, 45.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1200.0, 1080.0, 9000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("Turret01", "Anti Navy", isDeath: false, isBeam: false, "Turret_Muzzle_01", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[4] { "Turret_Muzzle_01", "Turret_Muzzle_02", "Turret_Muzzle_03", "Turret_Muzzle_04" })
			}, rackFireTogether: false, 1, 4, 0.6, 0.0, 10.0, 1, 150.0, 0.0, 0.0, 60.0, 0.25, 4.0, 5.0, 12.0, "/projectiles/AANTorpedoChronoPack01/AANTorpedoChronoPack01_proj.bp", "pai211", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 30.0, hasHeadingArc: false, 0.0, 0.0, 35.0, 35.0, 60.0, 0.0, -20.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2001", "UAB2301", "defence", "AeonPortStructure", "Oblivion", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB2301/UAB2301_unit.bp", "26f1431c63b23a3d3f414331db4c1824d171527e1f59c7f637ec100b4f197f49", new string[17]
		{
			"AEON", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DEFENSE", "DIRECTFIRE", "DRAGBUILD", "OVERLAYDIRECTFIRE", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "SIZE4", "SORTDEFENSE", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "", "", 2000.0, 0.0, 1.0, 1.25, 1.0, 0.0, -0.25, 0.0, 0.9, 1.1, "", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(28.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(480.0, 528.0, 3648.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MainGun", "Direct Fire", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel_Recoil", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 600.0, 2.0, 0.0, 50.0, 0.25, 4.0, 45.0, 1.2777777777777777, "/projectiles/ADFOblivionCannon03/ADFOblivionCannon03_proj.bp", "pad131", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 30.0, 44.0, 0.5, 0.0, 10.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3101", "UAB2302", "defence", "AeonPortStructure", "Emissary", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB2302/UAB2302_unit.bp", "8c8e58b4ea9a3b74aded12e3db0276383fe8b4db6adc2d92c703dd6bf8074999", new string[17]
		{
			"AEON", "ARTILLERY", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "INDIRECTFIRE", "OVERLAYINDIRECTFIRE", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE",
			"SHOWATTACKRETICLE", "SIZE16", "SORTSTRATEGIC", "STRATEGIC", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "", "", 12000.0, 0.0, 3.5, 4.0, 3.5, 0.0, -0.25, 0.0, 3.4, 3.4, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 5.0, 5.0, hasSourceSkirt: true, 8.0, 8.0, -1.5, -1.5), new GeneratedIntelSpec(28.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(30500.0, 91500.0, 915000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MainGun", "Artillery", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret_B01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_B01", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 0.0, 1, 6000.0, 4.0, 150.0, 900.0, 0.05, 20.0, 65.0, 120.0, "/projectiles/AIFSonanceShell02/AIFSonanceShell02_proj.bp", "pai311", "IndirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 3.0, hasHeadingArc: false, 0.0, 0.0, 45.0, 3.0, 2.0, 0.0, 30.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2101", "UAB2303", "defence", "AeonPortStructure", "Miasma", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB2303/UAB2303_unit.bp", "f056166ac1588ee419d833f890aefbf3db56798f05bfc914925c44a8dfc98bac", new string[18]
		{
			"AEON", "ARTILLERY", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "INDIRECTFIRE", "OVERLAYINDIRECTFIRE", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "SIZE4", "SORTSTRATEGIC", "STRATEGIC", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "", "", 2200.0, 0.0, 1.0, 1.2, 1.0, 0.0, -0.25, 0.0, 0.85, 1.0, "", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 2.0, 2.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(28.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1980.0, 2772.0, 19800.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MainGun", "Artillery", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Recoil", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 14.0, 1, 575.0, 2.0, 5.0, 128.0, 0.05, 20.0, 26.13, 6.123230003827019, "/projectiles/AIFMiasmaShell01/AIFMiasmaShell01_proj.bp", "pai211", "IndirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 180.0, 6.0, hasHeadingArc: false, 0.0, 0.0, 60.0, 6.0, 1.0, 0.0, 30.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3201", "UAB2304", "defence", "AeonPortStructure", "Transcender", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB2304/UAB2304_unit.bp", "66bec16f278856954b999095ca49e2a1eb5133b4efccb21756fdebd21218ccd7", new string[15]
		{
			"AEON", "ANTIAIR", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DEFENSE", "DRAGBUILD", "OVERLAYANTIAIR", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE",
			"SIZE4", "SORTDEFENSE", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "", "", 10500.0, 0.0, 0.6, 1.4, 0.6, 0.0, -0.65, 0.0, 0.65, 0.65, "", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 2.0, 2.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(28.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(800.0, 800.0, 8000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("AntiAirMissiles", "Anti Air", isDeath: false, isBeam: false, "Turret_Muzzle01", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[2] { "Turret_Muzzle01", "Turret_Muzzle02" })
			}, rackFireTogether: false, 1, 2, 0.6, 0.0, 10.0, 2, 600.0, 0.0, 0.0, 60.0, 0.28, 3.571428571428571, 30.0, 5.0, "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp", "paa311", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 360.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 80.0, 180.0, 10.0, 0.0, 25.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3102", "UAB2305", "structure", "AeonPortStructure", "Apocalypse", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB2305/UAB2305_unit.bp", "038993929f7375646f6173a401adc214417afc7766d97ce62dc4c50870bb59f2", new string[15]
		{
			"AEON", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "NUKE", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "SILO", "SIZE12",
			"SORTSTRATEGIC", "STRATEGIC", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "", "", 4000.0, 0.0, 2.0, 1.0, 2.0, 0.0, -0.25, 0.0, 1.8, 1.8, "", new string[3] { "Rest", "AnimAlaunchsequence", "AnimOpen" }, new GeneratedPlacementSpec("Footprint.Size", 3.0, 3.0, hasSourceSkirt: true, 6.0, 6.0, -1.5, -1.5), new GeneratedIntelSpec(28.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(9000.0, 15000.0, 210000.0, 1080.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[2]
		{
			new GeneratedWeaponSpec("QuantumMissiles", "Missile", isDeath: false, isBeam: false, "Turret_Muzzle01", "Turret_Muzzle01", "Turret_Muzzle01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Muzzle01", new string[1] { "Turret_Muzzle01" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 0.0, 0.0, 0.0, 20000.0, 1.0, 1.0, 0.0, 1.0, "/projectiles/AIFQuantumWarhead01/AIFQuantumWarhead01_proj.bp", "pai311", "IndirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "HighArc", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("DeathWeapon", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 10000.0, 6.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1701", "UAB3101", "intel", "AeonPortStructure", "Radar System", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB3101/UAB3101_unit.bp", "2e13daff88938b7da55e308ee696a4abcc2be3d01cd5023ecd32b79a4ae14262", new string[19]
		{
			"AEON", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "INTELLIGENCE", "OVERLAYRADAR", "PRODUCTSC1",
			"RADAR", "RECLAIMABLE", "SELECTABLE", "SHOWQUEUE", "SIZE4", "SORTINTEL", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "UAB3201", 10.0, 0.0, 0.5, 1.35, 0.5, 0.0, -0.25, 0.0, 0.75, 0.75, "", new string[2] { "Rest", "AnimUpgrade" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(20.0, 115.0, null, null, null, null, null, null, null, 5.0, null, null, true), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(80.0, 80.0, 720.0, 10.0, 0.0, 0.0, 0.0, 20.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1702", "UAB3102", "intel", "AeonPortStructure", "Sonar System", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB3102/UAB3102_unit.bp", "cb7096bdf0dbbfd477ae6ec7625a37f339e3a6fb2f36b2b283f9d78af5cecb09", new string[19]
		{
			"AEON", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "INTELLIGENCE", "OVERLAYSONAR", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "SHOWQUEUE", "SIZE4", "SONAR", "SORTINTEL", "STRUCTURE", "TECH1", "VISIBLETORECON"
		}, "", "UAB3202", 500.0, 0.0, 0.6, 0.5, 0.6, 0.0, -0.25, 0.0, 0.4, 0.4, "", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 1.0, 1.0, hasSourceSkirt: true, 1.0, 1.0, 0.0, 0.0), new GeneratedIntelSpec(20.0, null, 115.0, null, null, null, null, null, null, null, null, null, true), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(80.0, 64.0, 544.0, 10.0, 0.0, 0.0, 0.0, 10.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3701", "UAB3104", "intel", "AeonPortStructure", "Oculus", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB3104/UAB3104_unit.bp", "8516e303d6a5eebc125dff13ec3ab8d11f036d44c46c5b565f56ddd47daea626", new string[16]
		{
			"AEON", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "INTELLIGENCE", "OMNI", "OVERLAYOMNI", "OVERLAYRADAR", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SIZE4", "SORTINTEL", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "UAB3201", "", 100.0, 0.0, 0.5, 2.8, 0.5, 0.0, -0.25, 0.0, 0.75, 0.75, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(30.0, 600.0, null, 200.0, null, null, null, null, null, 5.0, null, null, true), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1800.0, 2400.0, 30000.0, 0.0, 0.0, 0.0, 0.0, 2000.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2701", "UAB3201", "intel", "AeonPortStructure", "Radar System", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB3201/UAB3201_unit.bp", "1e03af433f4bdd50b7de22a2f4c53053c8b3551eb85b542336f4d3ce74611ea3", new string[18]
		{
			"AEON", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "INTELLIGENCE", "OVERLAYRADAR", "PRODUCTSC1", "RADAR",
			"RECLAIMABLE", "SELECTABLE", "SHOWQUEUE", "SIZE4", "SORTINTEL", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "UAB3101", "UAB3104", 50.0, 0.0, 0.5, 2.1, 0.5, 0.0, -0.25, 0.0, 0.75, 0.75, "", new string[2] { "Rest", "AnimUpgrade" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(25.0, 200.0, null, null, null, null, null, null, null, 5.0, null, null, true), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(600.0, 180.0, 3600.0, 15.0, 0.0, 0.0, 0.0, 250.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2702", "UAB3202", "intel", "AeonPortStructure", "Sonar System", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB3202/UAB3202_unit.bp", "d2ec861ba7994346569793b39236cfc8c4447adf80f3cdfc2cb8770511c2baa5", new string[18]
		{
			"AEON", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "INTELLIGENCE", "OVERLAYSONAR", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SHOWQUEUE", "SIZE4", "SONAR", "SORTINTEL", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "UAB3102", "UAS0305", 1000.0, 0.0, 0.5, 0.5, 0.5, 0.0, -0.25, 0.0, 0.55, 0.55, "", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 1.0, 1.0, hasSourceSkirt: true, 1.0, 1.0, 0.0, 0.0), new GeneratedIntelSpec(25.0, null, 230.0, null, null, null, null, null, null, null, null, null, true), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(600.0, 120.0, 3600.0, 15.0, 0.0, 0.0, 0.0, 100.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2402", "UAB4201", "defence", "AeonPortStructure", "Volcano", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB4201/UAB4201_unit.bp", "96d6ae783a48f8c18d929e707a710e0d0a54fa9df16fed6d27c3f986d764533a", new string[17]
		{
			"AEON", "ANTIMISSILE", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DEFENSE", "DRAGBUILD", "OVERLAYDEFENSE", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "SIZE4", "SORTDEFENSE", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "", "", 500.0, 0.0, 0.65, 0.5, 1.25, 0.0, 0.0, 0.0, 0.5, 0.95, "", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: true, 2.0, 2.0, -0.5, -0.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(400.0, 280.0, 3200.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("AntiMissile", "Defense", isDeath: false, isBeam: false, "Barrel", "Barrel", "Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Dome", new string[1] { "Barrel" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 30.0, 0.0, 0.0, 30.0, 0.32, 3.125, 5.0, 4.0, "/projectiles/AIMAntiMissile01/AIMAntiMissile01_proj.bp", "pai211", "IndirectFire", new string[1] { "Air" }, "Above", "HighArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 60.0, 360.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2401", "UAB4202", "shield", "AeonPortStructure", "Shield of Light", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB4202/UAB4202_unit.bp", "c39cfe68ae22bc35afc3b0ad385f2c10cc9cc6d2c13c5150dab76a74bea5219a", new string[17]
		{
			"AEON", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DEFENSE", "DRAGBUILD", "OVERLAYDEFENSE", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SHIELD", "SIZE12", "SORTDEFENSE", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "", "", 150.0, 0.0, 1.75, 2.5, 1.75, 0.0, -0.25, 0.0, 1.5, 1.5, "", new string[2] { "Rest", "AnimAdeath" }, new GeneratedPlacementSpec("Footprint.Size", 3.0, 3.0, hasSourceSkirt: true, 6.0, 6.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: true, null, 11000.0, 16.0, 138.0, 1.0, 20.0, 10.0, -3.0, 5.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(480.0, 480.0, 5760.0, 10.0, 0.0, 0.0, 0.0, 150.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2711", "UAB4203", "structure", "AeonPortStructure", "Veil", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB4203/UAB4203_unit.bp", "4e6fc2e1040b81a2683494f85bfbadab1205f664f3d4a337a095ea236017a9b8", new string[17]
		{
			"AEON", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "COUNTERINTELLIGENCE", "DRAGBUILD", "INTELLIGENCE", "OVERLAYCOUNTERINTEL", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "SIZE12", "SORTINTEL", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "", "", 175.0, 0.0, 2.0, 3.0, 2.0, 0.0, -0.25, 0.0, 1.7, 1.7, "", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Footprint.Size", 3.0, 3.0, hasSourceSkirt: true, 6.0, 6.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, 24.0, 24.0, null, 5.0, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(500.0, 400.0, 6000.0, 0.0, 0.0, 0.0, 0.0, 125.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3401", "UAB4301", "shield", "AeonPortStructure", "Radiance", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB4301/UAB4301_unit.bp", "10a69396b3f055763593e01f361fd6fd53b804707e92fc745607aa02e0122f0a", new string[15]
		{
			"AEON", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DEFENSE", "DRAGBUILD", "OVERLAYDEFENSE", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "SHIELD",
			"SIZE12", "SORTDEFENSE", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "", "", 300.0, 0.0, 2.3, 4.0, 2.3, 0.0, -0.25, 0.0, 1.5, 1.5, "", new string[2] { "Rest", "AnimAdeath" }, new GeneratedPlacementSpec("Footprint.Size", 3.0, 3.0, hasSourceSkirt: true, 6.0, 6.0, -1.5, -1.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: true, null, 18000.0, 24.0, 150.0, 1.0, 35.0, 17.5, -5.0, 5.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(3000.0, 2400.0, 44000.0, 0.0, 0.0, 0.0, 0.0, 300.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3402", "UAB4302", "defence", "AeonPortStructure", "Patron", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB4302/UAB4302_unit.bp", "d72db5e3fc2233509f6de9b3cc3351b8c4e053351fd4c14b5be4aa9cea23ed5a", new string[16]
		{
			"AEON", "ANTIMISSILE", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DEFENSE", "DRAGBUILD", "OVERLAYDEFENSE", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE",
			"SILO", "SIZE8", "SORTDEFENSE", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "", "", 3800.0, 0.0, 1.75, 0.6, 1.75, 0.0, -0.25, 0.0, 1.25, 1.25, "", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 3.0, 3.0, hasSourceSkirt: true, 3.0, 3.0, -0.5, -0.5), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(4500.0, 7500.0, 105000.0, 1080.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MissileRack", "Defense", isDeath: false, isBeam: false, "Turret", "Turret", "Turret", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret", new string[1] { "Turret" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 30.0, 0.0, 0.0, 90.0, 0.6, 1.6666666666666667, 90.0, 1.25, "/projectiles/AIMSaintAntiNuke01/AIMSaintAntiNuke01_proj.bp", "pai311", "IndirectFire", new string[1] { "Air" }, "Above", "HighArc", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 60.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1804", "UAB5101", "defence", "AeonPortStructure", "Wall Section", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB5101/UAB5101_unit.bp", "c45240d7f6dca864b7655334cd842630363c43c22b1d91892cd75e2f56c87d41", new string[16]
		{
			"AEON", "BENIGN", "BUILTBYCOMMANDER", "BUILTBYTIER1ENGINEER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3ENGINEER", "DEFENSE", "DRAGBUILD", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SORTDEFENSE", "STRUCTURE", "TECH1", "VISIBLETORECON", "WALL"
		}, "", "", 4000.0, 0.0, 1.0, 0.4, 1.0, 0.0, 0.0, 0.0, 0.6, 0.6, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 1.0, 1.0, hasSourceSkirt: true, 1.0, 1.0, 0.0, 0.0), new GeneratedIntelSpec(0.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(10.0, 2.0, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2802", "UAB5102", "hidden_helper", "AeonPortStructure", "Aeon Transport Beacon", structure: true, rosterVisible: false, hasVisualAsset: true, "units/UAB5102/UAB5102_unit.bp", "4ae10b1c9c9d77fd92ce9198c1281c41f25047327a201734c2b457f500baffaf", new string[4] { "AEON", "FERRYBEACON", "PRODUCTSC1", "UNTARGETABLE" }, "", "", 10.0, 0.0, 0.5, 0.75, 0.5, 0.0, -0.25, 0.0, 1.0, 1.0, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 1.0, 1.0, hasSourceSkirt: true, 1.0, 1.0, 0.0, 0.0), new GeneratedIntelSpec(0.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(50.0, 5.0, 50.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2801", "UAB5103", "hidden_helper", "AeonPortStructure", "Aeon Quantum Gate Beacon", structure: true, rosterVisible: false, hasVisualAsset: true, "units/UAB5103/UAB5103_unit.bp", "ba6bfa88f60e79b2bcc76dcb1b8ee6ad12558ef7cfaa13e10be20a27dbc072af", new string[7] { "AEON", "PRODUCTSC1", "SIZE4", "STRUCTURE", "TECH3", "TELEPORTBEACON", "VISIBLETORECON" }, "", "", 10.0, 0.0, 1.0, 1.0, 1.0, 0.0, -0.25, 0.0, 0.3, 0.3, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 1.0, 1.0, hasSourceSkirt: true, 1.0, 1.0, 0.0, 0.0), new GeneratedIntelSpec(0.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(50.0, 5.0, 50.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3501", "UAB5202", "air_staging", "AeonPortStructure", "Cradle", structure: true, rosterVisible: true, hasVisualAsset: true, "units/UAB5202/UAB5202_unit.bp", "9d5e85fde40b8fe631a3feb849f6aeb623629b7d8d068e7d6335aa80a5acba12", new string[17]
		{
			"AEON", "AIRSTAGINGPLATFORM", "BUILTBYTIER2COMMANDER", "BUILTBYTIER2ENGINEER", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "OVERLAYMISC", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SIZE12", "SORTSTRATEGIC", "STRATEGIC", "STRUCTURE", "TECH2", "VISIBLETORECON"
		}, "", "", 500.0, 0.0, 2.75, 1.0, 2.75, 0.0, 0.0, 0.0, 1.7, 1.7, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 6.0, 6.0, hasSourceSkirt: true, 6.0, 6.0, -1.5, -1.5), new GeneratedIntelSpec(null, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(350.0, 175.0, 2100.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1501", "UAB5204", "decal_helper", "AeonPortStructure", "Concrete", structure: true, rosterVisible: false, hasVisualAsset: false, "units/UAB5204/UAB5204_unit.bp", "ff93064a01e268e2dc4d32d281463edd21de979132bbc076f4dbe05a4e8e7ab3", new string[6] { "AEON", "LAND", "PRODUCTSC1", "STRUCTURE", "TECH1", "VISIBLETORECON" }, "", "", 1.0, 0.0, 0.5, 0.75, 0.5, 0.0, -0.25, 0.0, 0.5, 0.5, "", Array.Empty<string>(), new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 1.0, 1.0, hasSourceSkirt: true, 1.0, 1.0, 0.0, 0.0), new GeneratedIntelSpec(0.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl1701", "UAL0101", "land", "AeonPortLandUnit", "Spirit", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0101/UAL0101_unit.bp", "14f3317d890005b6861e5be43fc0a33db1518d14dace2c67431fec37d3840f99", new string[17]
		{
			"AEON", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "COUNTERINTELLIGENCE", "DIRECTFIRE", "HOVER", "LAND", "MOBILE", "OVERLAYDIRECTFIRE",
			"OVERLAYRADAR", "PRODUCTSC1", "RECLAIMABLE", "SCOUT", "SELECTABLE", "TECH1", "VISIBLETORECON"
		}, "", "", 20.0, 0.0, 0.5, 0.3, 0.6, 0.0, -0.1, 0.05, 0.4, 0.4, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.5, 0.6, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(24.0, 50.0, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Hover", "Hover", "", 0.25, 0.0, 0.0, 0.0, 0.0, "", "", 5.0, 0.0, 5.0, 5.0, hasSourceMaxBrake: true, 90.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(80.0, 8.0, 40.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("LaserTurret", "Direct Fire", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 2.0, 0.0, 0.0, 25.0, 0.5, 2.0, 25.0, 1.15, "/projectiles/ADFLaserLight02/ADFLaserLight02_proj.bp", "pad111", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 180.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 180.0, 85.0, 2.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl1101", "UAL0103", "land", "AeonPortLandUnit", "Fervor", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0103/UAL0103_unit.bp", "12fcb0c622a8509568b0e5066b59dd41181c7b8ac2f4a180bf9f66168a84619e", new string[14]
		{
			"AEON", "ARTILLERY", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "INDIRECTFIRE", "LAND", "MOBILE", "OVERLAYINDIRECTFIRE", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "TECH1", "VISIBLETORECON"
		}, "", "", 150.0, 0.0, 0.55, 0.25, 0.6, 0.0, 0.0, 0.0, 0.35, 0.45, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.55, 0.6, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(18.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Land", "TracksLand", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 2.7, 0.0, 2.7, 2.7, hasSourceMaxBrake: true, 90.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(180.0, 36.0, 180.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MainGun", "Artillery", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret_Barrel", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 200.0, 0.5, 5.0, 30.0, 0.5, 2.0, 14.0, 2.6785714285714284, "/projectiles/AIFMortar01/AIFMortar01_proj.bp", "pai111", "IndirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "HighArc", 45.0, 70.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 70.0, 3.0, 0.0, 45.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl1201", "UAL0104", "land", "AeonPortLandUnit", "Thistle", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0104/UAL0104_unit.bp", "30d63d4bcce2ddbc396c78b2884909a66924aa4c3a96f164d83dac3111712dbd", new string[13]
		{
			"AEON", "ANTIAIR", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "LAND", "MOBILE", "OVERLAYANTIAIR", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "TECH1", "VISIBLETORECON"
		}, "", "", 200.0, 0.0, 0.55, 0.45, 0.65, 0.0, 0.0, 0.0, 0.5, 0.55, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.55, 0.65, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(18.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Land", "TracksLand", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 3.0, 0.0, 3.0, 3.0, hasSourceMaxBrake: true, 80.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(140.0, 28.0, 140.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("AAGun", "Anti Air", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 3, 0.2, 0.0, 10.0, 1, 5.0, 0.0, 0.0, 32.0, 1.0, 1.0, 45.0, 0.888888888888889, "/projectiles/AAASonicPulse01/AAASonicPulse01_proj.bp", "paa111", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 180.0, 240.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 240.0, 0.5, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl1501", "UAL0105", "engineer", "AeonPortEngineer", "Engineer", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0105/UAL0105_unit.bp", "26a8ccae2bff7b45e5c41cbd44977fb3a6a9cc0ff32e71d1eeb7b25561c8aaf5", new string[19]
		{
			"AEON", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "CAPTURE", "CONSTRUCTION", "ENGINEER", "HOVER", "LAND", "MOBILE",
			"PATROLHELPER", "PRODUCTSC1", "RECLAIM", "RECLAIMABLE", "REPAIR", "SELECTABLE", "SHOWQUEUE", "TECH1", "VISIBLETORECON"
		}, "", "", 120.0, 0.0, 0.8, 0.7, 0.8, 0.0, -0.25, 0.0, 0.4, 0.4, "Muzzle", new string[2] { "Rest", "AnimAopen01" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.8, 0.8, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(18.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Hover", "Hover", "", 0.5, 0.0, 0.0, 0.0, 0.0, "", "", 1.9, 0.0, 1.9, 1.9, hasSourceMaxBrake: true, 120.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(260.0, 52.0, 260.0, 5.0, 0.0, 0.0, 0.0, 0.0, 10.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl1002", "UAL0106", "land", "AeonPortLandUnit", "Flare", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0106/UAL0106_unit.bp", "0a90859fa334b0689927356349f8d462b4596c9782c02cfd8a419f144f0b3e06", new string[14]
		{
			"AEON", "BOT", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "DIRECTFIRE", "LAND", "MOBILE", "OVERLAYDIRECTFIRE", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "TECH1", "VISIBLETORECON"
		}, "", "", 70.0, 0.0, 0.6, 0.6, 0.6, 0.0, 0.0, 0.0, 0.3, 0.3, "", new string[6] { "Rest", "AnimAdeath01", "AnimAdeath02", "AnimFold", "AnimAidle01", "AnimWalk" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.6, 0.6, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(18.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Land", "LegsLand", "", 2.0, 0.0, 0.0, 0.0, 0.0, "", "", 4.0, 0.0, 4.0, 4.0, hasSourceMaxBrake: true, 45.0, air: false, airHover: false, "AnimWalk", 2.0, 2.0), new GeneratedEconomySpec(140.0, 35.0, 140.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("ArmLaserTurret", "Direct Fire", isDeath: false, isBeam: false, "Turret", "Turret", "Turret", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret", new string[3] { "Turret", "Turret", "Turret" })
			}, rackFireTogether: true, 1, 1, 0.0, 0.0, 10.0, 3, 7.0, 0.0, 0.0, 14.0, 1.0, 1.0, 25.0, 0.644, "/projectiles/ADFSonicPulsar01/ADFSonicPulsar01_proj.bp", "pad111", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 180.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 60.0, 180.0, 2.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl2101", "UAL0111", "land", "AeonPortLandUnit", "Evensong", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0111/UAL0111_unit.bp", "458841c9b1ba7edfcb221afdb71b6eb02be6d8bedbd9a34290abc492d2be944b", new string[13]
		{
			"AEON", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "INDIRECTFIRE", "LAND", "MOBILE", "OVERLAYINDIRECTFIRE", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE",
			"SILO", "TECH2", "VISIBLETORECON"
		}, "", "", 750.0, 0.0, 0.75, 0.3, 1.1, 0.0, 0.0, 0.1, 0.5, 0.8, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.75, 1.1, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(18.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Land", "TracksLand", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 2.7, 0.0, 2.7, 2.7, hasSourceMaxBrake: true, 90.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1000.0, 200.0, 1500.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MissileRack", "Missile", isDeath: false, isBeam: false, "Missile", "Missile", "Missile", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Missile", new string[1] { "Missile" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 600.0, 1.0, 3.0, 60.0, 0.1, 10.0, 3.0, 25.0, "/projectiles/AIFMissileSerpentine01/AIFMissileSerpentine01_proj.bp", "pai211", "IndirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "HighArc", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl1001", "UAL0201", "land", "AeonPortLandUnit", "Aurora", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0201/UAL0201_unit.bp", "4da88bb7c3a7093d752e90132129d0a4732033f843b8f88892df6b0645ce41f9", new string[15]
		{
			"AEON", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "DIRECTFIRE", "HOVER", "LAND", "MOBILE", "OVERLAYDIRECTFIRE", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "TANK", "TECH1", "VISIBLETORECON"
		}, "", "", 140.0, 0.0, 0.7, 0.5, 0.9, 0.0, 0.0, 0.0, 0.5, 0.7, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.7, 0.9, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Hover", "Hover", "", 0.25, 0.0, 0.0, 0.0, 0.0, "", "", 3.1, 0.0, 3.1, 3.1, hasSourceMaxBrake: true, 90.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(260.0, 52.0, 260.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MainGun", "Direct Fire", isDeath: false, isBeam: false, "Turret_Barrel", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[1] { "Turret_Barrel" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 40.0, 0.0, 0.0, 26.0, 0.66, 1.5151515151515151, 30.0, 0.9966666666666666, "/projectiles/ADFDisruptor01/ADFDisruptor01_proj.bp", "pad111", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 10.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 20.0, 60.0, 2.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl2002", "UAL0202", "land", "AeonPortLandUnit", "Obsidian", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0202/UAL0202_unit.bp", "facbf9a97d7c33ec049a5bff9e9e24dbc0c5914b1d7c36f598460335d5582748", new string[14]
		{
			"AEON", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "DIRECTFIRE", "LAND", "MOBILE", "OVERLAYDIRECTFIRE", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE",
			"SHIELD", "TANK", "TECH2", "VISIBLETORECON"
		}, "", "", 1000.0, 0.0, 0.8, 0.5, 0.9, 0.0, 0.0, 0.1, 0.6, 0.75, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.8, 0.9, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: true, true, 1750.0, 75.0, 2.0, 1.0, 3.0, 1.5, 0.0, 5.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Land", "TracksLand", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 2.6, 0.0, 2.6, 2.6, hasSourceMaxBrake: true, 90.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1600.0, 360.0, 1800.0, 0.0, 0.0, 0.0, 0.0, 10.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MainGun", "Direct Fire", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 480.0, 0.0, 0.0, 20.0, 0.25, 4.0, 30.0, 0.7666666666666666, "/projectiles/ADFQuantumCannon02/ADFQuantumCannon02_proj.bp", "pad131", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 180.0, 90.0, hasHeadingArc: false, 0.0, 0.0, 30.0, 45.0, 1.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl2201", "UAL0205", "land", "AeonPortLandUnit", "Ascendant", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0205/UAL0205_unit.bp", "415d7e168677cecfa62a08c87f8370f6ad75a4ccb22ef33ac2119ec7d1d080a3", new string[13]
		{
			"AEON", "ANTIAIR", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "HOVER", "LAND", "MOBILE", "OVERLAYANTIAIR", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "TECH2", "VISIBLETORECON"
		}, "", "", 1000.0, 0.0, 0.9, 0.3, 0.9, 0.0, 0.0, 0.0, 0.55, 0.65, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.9, 0.9, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Hover", "Hover", "", 0.25, 0.0, 0.0, 0.0, 0.0, "", "", 3.6, 0.0, 3.6, 3.6, hasSourceMaxBrake: true, 120.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(800.0, 160.0, 800.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("AAGun", "Anti Air", isDeath: false, isBeam: false, "WepFocus", "Barrel_R", "Barrel_R", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("WepFocus", new string[1] { "WepFocus" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.1, 0.0, 1, 72.0, 4.0, 0.0, 40.0, 2.0, 0.5, 20.0, 2.5, "/projectiles/AAAFizz01/AAAFizz01_proj.bp", "paa211", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 180.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 80.0, 180.0, 2.0, 0.0, 35.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl2501", "UAL0208", "engineer", "AeonPortEngineer", "Engineer", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0208/UAL0208_unit.bp", "493b427a1d15e2231537c86ce443e413ec43816e96676573b6dc97c5d747ef92", new string[18]
		{
			"AEON", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "CAPTURE", "CONSTRUCTION", "ENGINEER", "HOVER", "LAND", "MOBILE", "PATROLHELPER",
			"PRODUCTSC1", "RECLAIM", "RECLAIMABLE", "REPAIR", "SELECTABLE", "SHOWQUEUE", "TECH2", "VISIBLETORECON"
		}, "", "", 620.0, 0.0, 1.0, 0.8, 0.8, 0.0, -0.25, 0.0, 0.65, 0.6, "Muzzle", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Collision.SizeFallback", 1.0, 0.8, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Hover", "Hover", "", 0.5, 0.0, 0.0, 0.0, 0.0, "", "", 1.9, 0.0, 1.9, 1.9, hasSourceMaxBrake: true, 120.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(800.0, 160.0, 840.0, 10.0, 0.0, 0.0, 0.0, 0.0, 20.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl4002", "UAL0301", "engineer", "AeonPortEngineer", "Support Armored Command Unit", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0301/UAL0301_unit.bp", "c6a4a267f6ba09053a0099d6bf8d2ea29a4b8d67a9920eacc35aba2f0b2eb458", new string[19]
		{
			"AEON", "BUILTBYQUANTUMGATE", "CAPTURE", "CONSTRUCTION", "ENGINEER", "LAND", "MOBILE", "OVERLAYDIRECTFIRE", "OVERLAYOMNI", "PATROLHELPER",
			"PRODUCTSC1", "REBUILDER", "RECLAIM", "REPAIR", "SELECTABLE", "SHOWQUEUE", "SUBCOMMANDER", "TECH3", "VISIBLETORECON"
		}, "", "", 30000.0, 17.0, 0.85, 1.95, 0.4, 0.0, 0.0, 0.0, 0.55, 0.5, "AttachPoint", new string[4] { "Rest", "AnimFold", "AnimUnfold", "AnimWalk" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.85, 0.4, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(26.0, null, null, 16.0, null, null, null, null, null, null, 26.0, true, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Amphibious", "LegsSeabed", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 2.2, 0.0, 2.2, 2.2, hasSourceMaxBrake: true, 150.0, air: false, airHover: false, "AnimWalk", 3.5, 0.6285714285714287), new GeneratedEconomySpec(36000.0, 8700.0, 123000.0, 60.0, 3.0, 300.0, 0.0, 0.0, 275.0, 5000.0), new GeneratedWeaponSpec[2]
		{
			new GeneratedWeaponSpec("RightReactonCannon", "Direct Fire", isDeath: false, isBeam: false, "Arm_Left_Muzzle", "Torso", "Arm_Left_B03", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Arm_Left_B03", new string[1] { "Arm_Left_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 200.0, 0.0, 1.0, 30.0, 1.0, 1.0, 25.0, 1.38, "/projectiles/ADFReactonCannon01/ADFReactonCannon01_proj.bp", "pad311", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 360.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 160.0, 90.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("DeathWeapon", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 1000.0, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl3001", "UAL0303", "land", "AeonPortLandUnit", "Harbinger Mark IV", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0303/UAL0303_unit.bp", "699d3ac2d7cecd9e7990b31328b4af069511eda4dddeae08971eb60c063d606b", new string[14]
		{
			"AEON", "BOT", "BUILTBYTIER3FACTORY", "DIRECTFIRE", "LAND", "MOBILE", "OVERLAYDIRECTFIRE", "PRODUCTSC1", "RECLAIM", "RECLAIMABLE",
			"REPAIR", "SELECTABLE", "TECH3", "VISIBLETORECON"
		}, "", "", 4600.0, 0.0, 1.0, 1.5, 1.2, 0.0, 0.0, 0.0, 0.85, 0.85, "", new string[5] { "Rest", "AnimAdeath01", "AnimAdeath02", "AnimFold", "AnimWalk" }, new GeneratedPlacementSpec("Collision.SizeFallback", 1.0, 1.2, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(22.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: true, null, 1300.0, 60.0, 9.0, 3.0, 2.5, 1.25, 0.0, 5.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Land", "LegsLand", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 3.0, 0.0, 3.0, 3.0, hasSourceMaxBrake: true, 120.0, air: false, airHover: false, "AnimWalk", 10.0, 0.3), new GeneratedEconomySpec(3600.0, 840.0, 9600.0, 3.0, 0.0, 0.0, 0.0, 25.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("FrontTurret01", "Direct Fire", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 300.0, 0.0, 0.0, 28.0, 1.25, 0.8, 30.0, 1.0733333333333333, "/projectiles/ADFLaserHighIntensity01/ADFLaserHighIntensity01_proj.bp", "pad311", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 180.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 50.0, 30.0, 2.0, 0.0, 10.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl3101", "UAL0304", "land", "AeonPortLandUnit", "Serenity", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0304/UAL0304_unit.bp", "534beed9c3eb773567e50e37e0a4140c0206a0150b05d87e8eb5d26c29a756d2", new string[13]
		{
			"AEON", "ARTILLERY", "BUILTBYTIER3FACTORY", "INDIRECTFIRE", "LAND", "MOBILE", "OVERLAYINDIRECTFIRE", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE",
			"SHOWATTACKRETICLE", "TECH3", "VISIBLETORECON"
		}, "", "", 900.0, 0.0, 1.0, 0.4, 1.5, 0.0, 0.0, 0.0, 0.85, 1.0, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Collision.SizeFallback", 1.0, 1.5, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(26.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Land", "TracksLand", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 2.5, 0.0, 2.5, 2.5, hasSourceMaxBrake: true, 75.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(4800.0, 800.0, 8000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MainGun", "Artillery", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 95.0, 3.0, 0.0, 90.0, 0.05, 20.0, 22.0, 5.113636363636363, "/projectiles/AIFSonanceShell01/AIFSonanceShell01_proj.bp", "pai311", "IndirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 30.0, hasHeadingArc: false, 0.0, 0.0, 45.0, 20.0, 2.0, 0.0, 30.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl4401", "UAL0307", "land", "AeonPortLandUnit", "Asylum", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0307/UAL0307_unit.bp", "c4ceb4acc4ada9f5e88a4182e895873d9ae518a7cd3be1f2898690696f3a191b", new string[14]
		{
			"AEON", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "DEFENSE", "HOVER", "LAND", "MOBILE", "OVERLAYDEFENSE", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SHIELD", "TECH2", "VISIBLETORECON"
		}, "", "", 100.0, 0.0, 0.8, 0.5, 0.8, 0.0, 0.0, 0.0, 0.55, 0.55, "", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.8, 0.8, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(20.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: true, null, 5000.0, 26.0, 65.0, 1.0, 16.0, 8.0, -3.0, 5.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Hover", "Hover", "", 0.25, 0.0, 0.0, 0.0, 0.0, "", "", 4.0, 0.0, 4.0, 4.0, hasSourceMaxBrake: true, 150.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(720.0, 144.0, 1080.0, 0.0, 0.0, 0.0, 0.0, 125.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl3501", "UAL0309", "engineer", "AeonPortEngineer", "Engineer", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0309/UAL0309_unit.bp", "f63765b2f4de5013503bbab1ea12d4462c9fb5b3965a3ffbc1f257f91b47bb29", new string[17]
		{
			"AEON", "BUILTBYTIER3FACTORY", "CAPTURE", "CONSTRUCTION", "ENGINEER", "HOVER", "LAND", "MOBILE", "PATROLHELPER", "PRODUCTSC1",
			"RECLAIM", "RECLAIMABLE", "REPAIR", "SELECTABLE", "SHOWQUEUE", "TECH3", "VISIBLETORECON"
		}, "", "", 1180.0, 0.0, 0.9, 0.7, 0.9, 0.0, -0.25, 0.0, 0.7, 0.7, "Muzzle", new string[2] { "Rest", "AnimOpen" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.9, 0.9, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(26.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Hover", "Hover", "", 0.5, 0.0, 0.0, 0.0, 0.0, "", "", 1.9, 0.0, 1.9, 1.9, hasSourceMaxBrake: true, 120.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(2100.0, 490.0, 3150.0, 20.0, 0.0, 0.0, 0.0, 0.0, 40.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl4004", "UAL0401", "land", "AeonPortLandUnit", "Galactic Colossus", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAL0401/UAL0401_unit.bp", "a2f573ee202a2f236858057119ff099f93b25a121e94b13271045cf29f955f88", new string[15]
		{
			"AEON", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DIRECTFIRE", "DRAGBUILD", "EXPERIMENTAL", "LAND", "MOBILE", "NEEDMOBILEBUILD", "OVERLAYDIRECTFIRE",
			"OVERLAYOMNI", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "VISIBLETORECON"
		}, "", "", 99999.0, 10.0, 2.5, 6.5, 1.5, 0.0, 0.3, 0.0, 2.2, 1.6, "", new string[6] { "Rest", "AnimActivate", "AnimAdeath01", "AnimAdeath02", "AnimOpen", "AnimWalk" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 6.0, 6.0, hasSourceSkirt: true, 6.0, 6.0, -1.5, -1.5), new GeneratedIntelSpec(50.0, null, null, 50.0, null, null, null, null, null, null, 50.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Amphibious", "LegsSeabed", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 2.5, 0.0, 2.5, 2.5, hasSourceMaxBrake: true, 40.0, air: false, airHover: false, "AnimWalk", 2.0, 1.25), new GeneratedEconomySpec(20625.0, 27500.0, 343750.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[4]
		{
			new GeneratedWeaponSpec("EyeWeapon", "Direct Fire Experimental", isDeath: false, isBeam: true, "Head_Muzzle", "Head", "Head", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Head", new string[1] { "Head" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 500.0, 0.5, 2.0, 40.0, 3.0, 1.0 / 3.0, 0.0, 0.1, "", "pad171", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "NoArc", 70.0, 70.0, hasHeadingArc: false, 0.0, 0.0, 70.0, 60.0, 2.0, 0.0, -20.0, 0.0),
			new GeneratedWeaponSpec("RightArmTractor", "Experimental", isDeath: false, isBeam: true, "Right_Arm_Muzzle01", "Right_Arm_B01", "Right_Arm_B02", "Right_Arm_Muzzle02", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Right_Arm_B02", new string[1] { "Right_Arm_Muzzle01" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 0.01, 0.0, 2.0, 40.0, 1.0, 1.0, 0.0, 0.1, "", "pad171", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "NoArc", 65.0, 20.0, hasHeadingArc: true, -35.0, 35.0, 70.0, 180.0, 5.0, -25.0, 0.0, 0.0),
			new GeneratedWeaponSpec("LeftArmTractor", "Experimental", isDeath: false, isBeam: true, "Left_Arm_Muzzle01", "Left_Arm_B01", "Left_Arm_B02", "Left_Arm_Muzzle02", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Left_Arm_B02", new string[1] { "Left_Arm_Muzzle01" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 0.01, 0.0, 2.0, 40.0, 1.0, 1.0, 0.0, 0.1, "", "pad171", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "NoArc", 65.0, 20.0, hasHeadingArc: true, 35.0, 35.0, 70.0, 180.0, 5.0, 25.0, 0.0, 0.0),
			new GeneratedWeaponSpec("CollossusDeath", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 7500.0, 4.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1802", "UAS0102", "naval", "AeonPortNavalUnit", "Shard", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAS0102/UAS0102_unit.bp", "fb4a21dbf21dcb31c1cf2b8d4e7488d5c5d62a55febf8e97a3eda9d9ce9183e4", new string[15]
		{
			"AEON", "ANTIAIR", "BUILTBYEXPERIMENTALSUB", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "LIGHTBOAT", "MOBILE", "NAVAL", "OVERLAYANTIAIR",
			"PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "TECH1", "VISIBLETORECON"
		}, "", "", 750.0, 0.0, 0.65, 0.65, 1.65, 0.0, -0.25, 0.1, 0.36, 0.9, "", new string[4] { "Rest", "AnimAdeath01", "AnimAdeath02", "AnimAdeath03" }, new GeneratedPlacementSpec("Footprint.Size", 2.0, 6.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Water", "WaterSurface", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 8.0, 0.0, 8.0, 8.0, hasSourceMaxBrake: true, 100.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(800.0, 120.0, 1200.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MainGun", "Anti Air", isDeath: false, isBeam: false, "Turret_Muzzle01", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[1] { "Turret_Muzzle01" })
			}, rackFireTogether: false, 1, 3, 0.2, 0.0, 10.0, 3, 7.0, 0.0, 0.0, 48.0, 1.6, 0.625, 45.0, 1.3333333333333333, "/projectiles/AAASonicPulse01/AAASonicPulse01_proj.bp", "paa111", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 180.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 180.0, 180.0, 0.5, 0.0, 10.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucn1001", "UAS0103", "naval", "AeonPortNavalUnit", "Beacon Class", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAS0103/UAS0103_unit.bp", "f12cf1201829165c56c838dc2f8736f6795a14cbcc48f47c42d04fbe645f883a", new string[21]
		{
			"AEON", "ANTINAVY", "BUILTBYEXPERIMENTALSUB", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "FRIGATE", "INTELLIGENCE", "MOBILE", "NAVAL",
			"OVERLAYDEFENSE", "OVERLAYDIRECTFIRE", "OVERLAYRADAR", "OVERLAYSONAR", "PRODUCTSC1", "RADAR", "RECLAIMABLE", "SELECTABLE", "SONAR", "TECH1",
			"VISIBLETORECON"
		}, "", "", 1800.0, 0.0, 0.6, 1.1, 4.3, 0.0, -0.375, 0.0, 0.65, 2.75, "", new string[4] { "Rest", "AnimAdeath01", "AnimAdeath02", "AnimAdeath03" }, new GeneratedPlacementSpec("Footprint.Size", 2.0, 6.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, 80.0, 82.0, null, null, null, null, null, null, null, 16.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Water", "WaterSurface", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 6.0, 0.0, 6.0, 6.0, hasSourceMaxBrake: true, 60.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1350.0, 270.0, 2700.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[3]
		{
			new GeneratedWeaponSpec("MainGun", "Direct Fire Naval", isDeath: false, isBeam: false, "Turret_Front_Muzzle", "Turret_Front", "Turret_Front_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Front_Barrel", new string[1] { "Turret_Front_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 140.0, 1.0, 0.0, 31.0, 0.2, 5.0, 30.0, 1.2916666666666667, "/projectiles/ADFQuantumCannon01/ADFQuantumCannon01_proj.bp", "pad111", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 150.0, 90.0, hasHeadingArc: true, 0.0, 150.0, 40.0, 30.0, 2.0, 0.0, 10.0, 0.0),
			new GeneratedWeaponSpec("MainGun2", "Direct Fire Naval", isDeath: false, isBeam: false, "Turret_Back_Muzzle", "Turret_Back", "Turret_Back_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Back", new string[1] { "Turret_Back_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 140.0, 1.0, 0.0, 31.0, 0.2, 5.0, 30.0, 1.2916666666666667, "/projectiles/ADFQuantumCannon01/ADFQuantumCannon01_proj.bp", "pad111", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 150.0, 90.0, hasHeadingArc: true, 180.0, 150.0, 40.0, 30.0, 2.0, 0.0, 10.0, 0.0),
			new GeneratedWeaponSpec("AntiTorpedo01", "Defense", isDeath: false, isBeam: false, "Projectile01", "Projectile01", "Projectile01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Projectile01", new string[1] { "Projectile01" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 0.0, 1, 2.0, 0.0, 10.0, 32.0, 0.1, 10.0, 2.0, 1.0, "/projectiles/AIMAntiTorpedo01/AIMAntiTorpedo01_proj.bp", "pai111", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 10.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1803", "UAS0201", "naval", "AeonPortNavalUnit", "Exodus Class", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAS0201/UAS0201_unit.bp", "7f7c33ecbcf0b6ba7d49b3401f71912dcb7a78f284fea0a91e55e7c35767a5e6", new string[18]
		{
			"AEON", "ANTISUB", "BUILTBYEXPERIMENTALSUB", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "DESTROYER", "MOBILE", "NAVAL", "OVERLAYANTINAVY", "OVERLAYDEFENSE",
			"OVERLAYDIRECTFIRE", "OVERLAYRADAR", "OVERLAYSONAR", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "TECH2", "VISIBLETORECON"
		}, "", "", 7500.0, 0.0, 1.5, 1.3, 5.4, 0.0, -0.375, 0.0, 0.8, 3.4, "", new string[4] { "Rest", "AnimAdeath01", "AnimAdeath02", "AnimAdeath03" }, new GeneratedPlacementSpec("Footprint.Size", 2.0, 8.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, 35.0, 37.0, null, null, null, null, null, null, null, 45.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Water", "WaterSurface", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 5.0, 0.0, 5.0, 5.0, hasSourceMaxBrake: true, 50.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(10000.0, 2250.0, 15000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[4]
		{
			new GeneratedWeaponSpec("FrontTurret", "Direct Fire Naval", isDeath: false, isBeam: false, "Turret_Front_Muzzle", "Turret_Front", "Turret_Front_Barrel01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Front_Barrel02", new string[1] { "Turret_Front_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 1060.0, 1.0, 0.0, 80.0, 0.2, 5.0, 30.0, 3.333333333333333, "/projectiles/ADFOblivionCannon01/ADFOblivionCannon01_proj.bp", "pad131", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 160.0, 90.0, hasHeadingArc: false, 0.0, 0.0, 40.0, 30.0, 2.0, 0.0, 10.0, 0.0),
			new GeneratedWeaponSpec("DepthCharge", "Anti Navy", isDeath: false, isBeam: false, "Root", "Root", "Root", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Root", new string[1] { "Root" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 350.0, 0.0, 0.0, 45.0, 0.3, 3.3333333333333335, 15.0, 15.0, "/projectiles/AANDepthCharge02/AANDepthCharge02_proj.bp", "pai211", "IndirectFire", new string[1] { "Water" }, "Below", "HighArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 60.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("Torpedo1", "Anti Navy", isDeath: false, isBeam: false, "Projectile01", "Projectile01", "Projectile01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Projectile01", new string[2] { "Projectile01", "Projectile03" })
			}, rackFireTogether: false, 1, 2, 1.0, 0.0, 10.0, 1, 150.0, 0.0, 0.0, 45.0, 0.25, 4.0, 5.0, 7.0, "/projectiles/AANTorpedo01/AANTorpedo01_proj.bp", "pai211", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 60.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("AntiTorpedo", "Defense", isDeath: false, isBeam: false, "Projectile02", "Projectile02", "Projectile02", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Projectile02", new string[2] { "Projectile02", "Projectile04" })
			}, rackFireTogether: false, 1, 2, 0.0, 0.0, 0.0, 1, 2.0, 0.0, 15.0, 45.0, 0.26, 3.846153846153846, 80.0, 4.0, "/projectiles/AIMAntiTorpedo01/AIMAntiTorpedo01_proj.bp", "pai211", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca2806", "UAS0202", "naval", "AeonPortNavalUnit", "Infinity Class", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAS0202/UAS0202_unit.bp", "3f7292a2de40c3828a172279767840262b5bddaf78a1364cf9a17e935bde4f31", new string[19]
		{
			"AEON", "ANTIAIR", "ANTIMISSILE", "BUILTBYEXPERIMENTALSUB", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "CRUISER", "MOBILE", "NAVAL", "OVERLAYANTIAIR",
			"OVERLAYDEFENSE", "OVERLAYDIRECTFIRE", "OVERLAYRADAR", "OVERLAYSONAR", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "TECH2", "VISIBLETORECON"
		}, "", "", 3250.0, 0.0, 1.6, 1.5, 5.7, 0.0, -0.4, 0.0, 1.0, 3.8, "", new string[4] { "Rest", "AnimAdeath01", "AnimAdeath02", "AnimAdeath03" }, new GeneratedPlacementSpec("Footprint.Size", 2.0, 9.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(65.0, 150.0, 120.0, null, null, null, null, null, null, null, 60.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Water", "WaterSurface", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 4.5, 0.0, 4.5, 4.5, hasSourceMaxBrake: true, 40.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(8000.0, 2000.0, 18000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[4]
		{
			new GeneratedWeaponSpec("FrontTurret", "Direct Fire Naval", isDeath: false, isBeam: false, "Turret_Front_Barrel", "Turret_Front", "Turret_Front_Barrel", "", new GeneratedRackSpec[2]
			{
				new GeneratedRackSpec("Turret_Front_Barrel", new string[1] { "Muzzle_Front01" }),
				new GeneratedRackSpec("Turret_Front_Barrel", new string[1] { "Muzzle_Front02" })
			}, rackFireTogether: true, 1, 1, 0.0, 0.0, 10.0, 1, 140.0, 1.0, 0.0, 60.0, 0.25, 4.0, 40.0, 1.875, "/projectiles/ADFQuantumCannon01/ADFQuantumCannon01_proj.bp", "pad131", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 140.0, 90.0, hasHeadingArc: false, 0.0, 0.0, 20.0, 30.0, 2.0, 0.0, 10.0, 0.0),
			new GeneratedWeaponSpec("AntiAirMissiles01", "Anti Air", isDeath: false, isBeam: false, "Turret_Right_Barrel", "Turret_Right", "Turret_Right", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Right_Barrel", new string[1] { "Muzzle_Right" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 375.0, 0.0, 0.0, 75.0, 1.0, 1.0, 40.0, 6.0, "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp", "paa211", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 20.0, 30.0, hasHeadingArc: false, 0.0, 0.0, 40.0, 30.0, 1.0, 10.0, 10.0, 0.0),
			new GeneratedWeaponSpec("AntiAirMissiles02", "Anti Air", isDeath: false, isBeam: false, "Turret_Left_Barrel", "Turret_Left", "Turret_Left", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Left_Barrel", new string[1] { "Muzzle_Left" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 375.0, 0.0, 0.0, 75.0, 1.0, 1.0, 30.0, 6.0, "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp", "paa211", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 20.0, 30.0, hasHeadingArc: false, 0.0, 0.0, 40.0, 30.0, 1.0, 10.0, 10.0, 0.0),
			new GeneratedWeaponSpec("AntiMissile", "Defense", isDeath: false, isBeam: false, "Projectile", "Projectile", "Projectile", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Projectile", new string[1] { "Projectile" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 30.0, 0.0, 0.0, 30.0, 0.5, 2.0, 5.0, 4.0, "/projectiles/AIMAntiMissile01/AIMAntiMissile01_proj.bp", "pai211", "IndirectFire", new string[1] { "Air" }, "Above", "HighArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 60.0, 360.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs1801", "UAS0203", "naval", "AeonPortNavalUnit", "Sylph", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAS0203/UAS0203_unit.bp", "849a1a43346211abb8e54137d1504252d95e9c4202b110de82a2440296d7decc", new string[17]
		{
			"AEON", "ANTINAVY", "BUILTBYEXPERIMENTALSUB", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "MOBILE", "NAVAL", "OVERLAYANTINAVY", "OVERLAYSONAR",
			"PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "SUBMERSIBLE", "T1SUBMARINE", "TECH1", "VISIBLETORECON"
		}, "", "", 550.0, 0.0, 0.35, 0.5, 1.85, 0.05, -0.25, -0.01, 0.35, 1.5, "", new string[2] { "Rest", "AnimAdeath01" }, new GeneratedPlacementSpec("Footprint.Size", 2.0, 3.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, null, 60.0, null, null, null, null, null, null, null, 32.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_SurfacingSub", "WaterSurface", "Sanctuary routes UnderWater but has no FA SurfacingSub transition state machine; the functional WaterSurface fallback retains source speed/acceleration/turn while submerge depth stays provenance.", -1.5, 0.0, 0.0, 0.0, 0.0, "", "", 6.0, 0.0, 6.0, 6.0, hasSourceMaxBrake: true, 80.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1440.0, 360.0, 2880.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("Torpedo01", "Anti Navy", isDeath: false, isBeam: false, "muzzle_01", "muzzle_01", "muzzle_01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("muzzle_01", new string[2] { "muzzle_01", "Muzzle_02" })
			}, rackFireTogether: false, 1, 2, 0.8, 0.0, 10.0, 2, 75.0, 0.0, 0.0, 32.0, 0.25, 4.0, 5.0, 7.0, "/projectiles/AANTorpedo01/AANTorpedo01_proj.bp", "pai111", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucn3001", "UAS0302", "naval", "AeonPortNavalUnit", "Omen Class", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAS0302/UAS0302_unit.bp", "cb09aed494d9a715d3620cefdcf7b87a567d2aa399e3589d8106e32c33af8af5", new string[16]
		{
			"AEON", "ANTIMISSILE", "BATTLESHIP", "BUILTBYTIER3FACTORY", "DIRECTFIRE", "MOBILE", "NAVAL", "OVERLAYDEFENSE", "OVERLAYDIRECTFIRE", "OVERLAYRADAR",
			"OVERLAYSONAR", "PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "TECH3", "VISIBLETORECON"
		}, "", "", 48000.0, 0.0, 3.3, 2.8, 12.8, 0.0, -1.0, 0.0, 1.8, 8.9, "", new string[4] { "Rest", "AnimAdeath01", "AnimAdeath02", "AnimAdeath03" }, new GeneratedPlacementSpec("Footprint.Size", 5.0, 16.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(50.0, 50.0, 20.0, null, null, null, null, null, null, null, 50.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Water", "WaterSurface", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 3.6, 0.0, 3.6, 3.6, hasSourceMaxBrake: true, 35.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(18000.0, 9000.0, 54000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[4]
		{
			new GeneratedWeaponSpec("FrontTurret", "Direct Fire Naval", isDeath: false, isBeam: false, "Turret_Front_Muzzle", "Turret_Front", "Turret_Front_Barrel01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Front_Barrel02", new string[1] { "Turret_Front_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 1000.0, 2.0, 0.0, 100.0, 0.17, 5.88235294117647, 50.0, 2.5, "/projectiles/ADFOblivionCannon02/ADFOblivionCannon02_proj.bp", "pad311", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 160.0, 60.0, hasHeadingArc: true, 0.0, 160.0, 25.0, 10.0, 2.0, 0.0, 10.0, 0.0),
			new GeneratedWeaponSpec("MidTurret", "Direct Fire Naval", isDeath: false, isBeam: false, "Turret_Middle_Muzzle", "Turret_Middle", "Turret_Middle_Barrel01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Middle_Barrel02", new string[1] { "Turret_Middle_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 1000.0, 2.0, 0.0, 100.0, 0.17, 5.88235294117647, 50.0, 2.5, "/projectiles/ADFOblivionCannon02/ADFOblivionCannon02_proj.bp", "pad311", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 160.0, 60.0, hasHeadingArc: true, 0.0, 160.0, 25.0, 10.0, 2.0, 0.0, 10.0, 0.0),
			new GeneratedWeaponSpec("BackTurret", "Direct Fire Naval", isDeath: false, isBeam: false, "Turret_Back_Muzzle", "Turret_Back", "Turret_Back_Barrel01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Back_Barrel02", new string[1] { "Turret_Back_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 1000.0, 2.0, 0.0, 100.0, 0.17, 5.88235294117647, 50.0, 2.5, "/projectiles/ADFOblivionCannon02/ADFOblivionCannon02_proj.bp", "pad311", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 160.0, 60.0, hasHeadingArc: true, 180.0, 165.0, 25.0, 10.0, 2.0, 0.0, 10.0, 0.0),
			new GeneratedWeaponSpec("AntiMissile1", "Defense", isDeath: false, isBeam: false, "Projectile02", "Projectile02", "Projectile02", "", new GeneratedRackSpec[2]
			{
				new GeneratedRackSpec("Projectile01", new string[1] { "Projectile02" }),
				new GeneratedRackSpec("Projectile02", new string[1] { "Projectile01" })
			}, rackFireTogether: false, 1, 2, 2.3, 0.0, 10.0, 1, 30.0, 0.0, 0.0, 50.0, 0.25, 4.0, 5.0, 6.0, "/projectiles/AIMAntiMissile01/AIMAntiMissile01_proj.bp", "pai311", "IndirectFire", new string[1] { "Air" }, "Above", "HighArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 60.0, 360.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2803", "UAS0303", "naval", "AeonPortNavalUnit", "Keefer Class", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAS0303/UAS0303_unit.bp", "e81be2657406fe199d88ea9b1ae654de3d78d72057d0490a78c2261e479fc259", new string[20]
		{
			"AEON", "AIRSTAGINGPLATFORM", "ANTIAIR", "BUILTBYTIER3FACTORY", "CARRIER", "FACTORY", "MOBILE", "NAVAL", "NAVALCARRIER", "OVERLAYANTIAIR",
			"OVERLAYMISC", "OVERLAYRADAR", "OVERLAYSONAR", "PRODUCTSC1", "RECLAIMABLE", "REPAIR", "SELECTABLE", "SHOWQUEUE", "TECH3", "VISIBLETORECON"
		}, "", "", 22000.0, 0.0, 6.5, 2.9, 15.7, 0.0, -0.6, 0.0, 3.0, 10.6, "", new string[4] { "Rest", "AnimAdeath01", "AnimAdeath02", "AnimAdeath03" }, new GeneratedPlacementSpec("Footprint.Size", 5.0, 17.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(85.0, 200.0, 40.0, null, null, null, null, null, null, null, 36.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Water", "WaterSurface", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 3.0, 0.0, 3.0, 2.5, hasSourceMaxBrake: true, 30.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(12000.0, 4000.0, 40000.0, 150.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[2]
		{
			new GeneratedWeaponSpec("AntiAirMissiles01", "Anti Air", isDeath: false, isBeam: false, "Muzzle_Right", "Turret_Right", "Turret_Right_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Right_Barrel", new string[1] { "Muzzle_Right" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 120.0, 0.0, 0.0, 75.0, 1.0, 1.0, 30.0, 6.0, "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp", "paa311", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 180.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 40.0, 180.0, 50.0, 0.0, 30.0, 0.0),
			new GeneratedWeaponSpec("AntiAirMissiles01", "Anti Air", isDeath: false, isBeam: false, "Muzzle_Left", "Turret_Left", "Turret_Left_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Left_Barrel", new string[1] { "Muzzle_Left" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 120.0, 0.0, 0.0, 75.0, 1.0, 1.0, 30.0, 6.0, "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp", "paa311", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 180.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 40.0, 180.0, 50.0, 0.0, 30.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl4001", "UAS0304", "naval", "AeonPortNavalUnit", "Silencer", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAS0304/UAS0304_unit.bp", "501eff2d24fcf9b447af0f15ffa81aa5976bf0f3049e79e7003ba1f4ba8c926c", new string[16]
		{
			"AEON", "BUILTBYTIER3FACTORY", "INDIRECTFIRE", "MOBILE", "NAVAL", "NUKE", "NUKESUB", "OVERLAYINDIRECTFIRE", "OVERLAYSONAR", "PRODUCTSC1",
			"RECLAIMABLE", "SELECTABLE", "SILO", "SUBMERSIBLE", "TECH3", "VISIBLETORECON"
		}, "", "", 3750.0, 0.0, 0.7, 0.7, 3.5, 0.0, -0.375, 0.0, 0.6, 2.2, "", new string[2] { "Rest", "AnimAdeath01" }, new GeneratedPlacementSpec("Footprint.Size", 2.0, 5.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(16.0, null, 60.0, null, null, null, null, null, null, null, 35.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_SurfacingSub", "WaterSurface", "Sanctuary routes UnderWater but has no FA SurfacingSub transition state machine; the functional WaterSurface fallback retains source speed/acceleration/turn while submerge depth stays provenance.", -2.0, 0.0, 0.0, 0.0, 0.0, "", "", 3.5, 0.0, 3.5, 3.5, hasSourceMaxBrake: true, 50.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(20000.0, 10000.0, 800000.0, 1080.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[2]
		{
			new GeneratedWeaponSpec("CruiseMissiles", "Missile", isDeath: false, isBeam: false, "Muzzle_01", "Muzzle_01", "Muzzle_01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Muzzle_01", new string[1] { "Muzzle_01" })
			}, rackFireTogether: false, 1, 5, 1.5, 0.0, 0.0, 1, 1500.0, 2.0, 20.0, 175.0, 0.05, 20.0, 5.0, 50.0, "/projectiles/AIFMissileSerpentine02/AIFMissileSerpentine02_proj.bp", "pai311", "IndirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "HighArc", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("NukeMissiles", "Missile", isDeath: false, isBeam: false, "Muzzle_05", "Muzzle_05", "Muzzle_05", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Muzzle_05", new string[1] { "Muzzle_05" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 0.0, 1, 0.0, 0.0, 128.0, 1024.0, 1.0, 1.0, 0.0, 1.0, "/projectiles/AIFQuantumWarhead03/AIFQuantumWarhead03_proj.bp", "pai311", "IndirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 60.0, 2.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl3701", "UAS0305", "naval", "AeonPortNavalUnit", "Sonar Platform", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAS0305/UAS0305_unit.bp", "ed8d3dbcc37b49abbba54a08043739f9f938336ffe2ee58e7c549e293aecffb0", new string[17]
		{
			"AEON", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "INTELLIGENCE", "MOBILE", "MOBILESONAR", "NEEDMOBILEBUILD", "OVERLAYDEFENSE", "OVERLAYSONAR",
			"PRODUCTSC1", "RECLAIMABLE", "SELECTABLE", "SONAR", "SORTINTEL", "TECH3", "VISIBLETORECON"
		}, "UAB3202", "", 1500.0, 0.0, 1.0, 1.1, 1.0, 0.0, -0.25, 0.0, 0.65, 0.65, "", new string[2] { "Rest", "AnimAdeath01" }, new GeneratedPlacementSpec("Footprint.Size", 2.0, 2.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, null, 450.0, null, null, null, null, null, null, null, 24.0, null, true), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Water", "WaterSurface", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 4.5, 0.0, 4.5, 4.5, hasSourceMaxBrake: true, 100.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(750.0, 400.0, 12000.0, 0.0, 0.0, 0.0, 0.0, 100.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("AntiTorpedo01", "Defense", isDeath: false, isBeam: false, "Muzzle_01", "Muzzle_01", "Muzzle_01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Muzzle_01", new string[1] { "Muzzle_01" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 1.0, 0.0, 0.0, 32.0, 0.15, 6.666666666666667, 30.0, 1.5, "/projectiles/AIMAntiTorpedo01/AIMAntiTorpedo01_proj.bp", "pai311", "IndirectFire", new string[1] { "WaterSurface" }, "Above", "HighArc", 180.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 180.0, 2.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl4003", "UAS0401", "mobile_naval_factory", "AeonPortNavalUnit", "Tempest", structure: false, rosterVisible: true, hasVisualAsset: true, "units/UAS0401/UAS0401_unit.bp", "42ad52043c056a4d0d9ac9471449f621eda818dd37c0699eee8e8bd0c3bf05e3", new string[25]
		{
			"AEON", "BATTLESHIP", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "CARRIER", "DIRECTFIRE", "DRAGBUILD", "EXPERIMENTAL", "FACTORY", "INTELLIGENCE",
			"MOBILE", "NAVAL", "NEEDMOBILEBUILD", "OVERLAYANTINAVY", "OVERLAYDEFENSE", "OVERLAYDIRECTFIRE", "OVERLAYRADAR", "OVERLAYSONAR", "PRODUCTSC1", "RECLAIMABLE",
			"SELECTABLE", "SHOWATTACKRETICLE", "SHOWQUEUE", "SUBMERSIBLE", "VISIBLETORECON"
		}, "", "", 35000.0, 0.0, 12.0, 4.0, 12.0, 0.0, -0.375, 0.0, 8.5, 8.5, "Attachpoint01", new string[3] { "Rest", "AnimAdeath01", "AnimAopen01" }, new GeneratedPlacementSpec("Physics.SkirtSizeFallback", 16.0, 16.0, hasSourceSkirt: true, 16.0, 16.0, -1.5, -1.5), new GeneratedIntelSpec(100.0, 150.0, 250.0, null, null, null, null, null, null, null, 100.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_SurfacingSub", "WaterSurface", "Sanctuary routes UnderWater but has no FA SurfacingSub transition state machine; the functional WaterSurface fallback retains source speed/acceleration/turn while submerge depth stays provenance.", -5.0, 0.0, 0.0, 0.0, 0.0, "", "", 2.5, 0.0, 2.5, 2.5, hasSourceMaxBrake: true, 30.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(12000.0, 28000.0, 350000.0, 240.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[3]
		{
			new GeneratedWeaponSpec("MainGun", "Direct Fire Naval", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret_Barrel01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel02", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 6000.0, 5.0, 0.0, 150.0, 0.1, 10.0, 30.0, 10.0, "/projectiles/ADFOblivionCannon04/ADFOblivionCannon04_proj.bp", "pad411", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 180.0, 10.0, hasHeadingArc: false, 0.0, 0.0, 50.0, 30.0, 2.0, 0.0, 40.0, 0.0),
			new GeneratedWeaponSpec("Torpedo01", "Anti Navy", isDeath: false, isBeam: false, "Torpedo_Muzzle01", "Torpedo_Muzzle01", "Torpedo_Muzzle01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Torpedo_Muzzle01", new string[6] { "Torpedo_Muzzle01", "Torpedo_Muzzle02", "Torpedo_Muzzle03", "Torpedo_Muzzle04", "Torpedo_Muzzle05", "Torpedo_Muzzle06" })
			}, rackFireTogether: false, 1, 6, 0.5, 0.0, 10.0, 1, 235.0, 0.0, 0.0, 80.0, 0.25, 4.0, 5.0, 7.0, "/projectiles/AANTorpedo01/AANTorpedo01_proj.bp", "pai311", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("AntiTorpedo01", "Defense", isDeath: false, isBeam: false, "Anti_Torpedo_Muzzle01", "Anti_Torpedo_Muzzle01", "Anti_Torpedo_Muzzle01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Anti_Torpedo_Muzzle01", new string[2] { "Anti_Torpedo_Muzzle01", "Anti_Torpedo_Muzzle02" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 3.0, 0.0, 15.0, 45.0, 1.0, 1.0, 80.0, 1.5, "/projectiles/AIMAntiTorpedo02/AIMAntiTorpedo02_proj.bp", "pai311", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 60.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 60.0, 180.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca2101", "XAA0202", "air", "AeonPortAirUnit", "Swift Wind", structure: false, rosterVisible: true, hasVisualAsset: true, "units/XAA0202/XAA0202_unit.bp", "ebe411a25fa5a1efc5a4c98a7e373d3aa0a1966b06198a899e48dc8e262a0fb1", new string[13]
		{
			"AEON", "AIR", "ANTIAIR", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "HIGHALTAIR", "MOBILE", "OVERLAYANTIAIR", "PRODUCTFA", "RECLAIMABLE",
			"SELECTABLE", "TECH2", "VISIBLETORECON"
		}, "", "", 800.0, 0.0, 1.0, 0.3, 1.0, 0.0, 0.0, -0.2, 0.75, 1.0, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Plane", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.", 20.0, 3.0, 2.5, 7.0, 0.0, "Units/uca2101/LOD0/uca2101_lod0.sanmodel", "69ec96069fa123f0fcb93ea49d6dfc6d869e8e60d8df0cae31a53a8edc6c0612", 18.0, 8.0, 18.0, 0.0, hasSourceMaxBrake: false, 90.0, air: true, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1600.0, 200.0, 6000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[2]
		{
			new GeneratedWeaponSpec("AutoCannon1", "Anti Air", isDeath: false, isBeam: false, "Muzzle", "Muzzle", "Muzzle", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Muzzle", new string[1] { "Muzzle" })
			}, rackFireTogether: false, 1, 3, 0.2, 0.0, 10.0, 3, 50.0, 0.0, 0.0, 30.0, 1.0, 1.0, 120.0, 0.6, "/projectiles/AAALightDisplacementAutoCannonMissile01/AAALightDisplacementAutoCannonMissile01_proj.bp", "paa211", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 55.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 55.0, 360.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 100.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca3011", "XAA0305", "air", "AeonPortAirUnit", "Restorer", structure: false, rosterVisible: true, hasVisualAsset: true, "units/XAA0305/XAA0305_unit.bp", "2613f37cfda2ed1120a7406d3d974b440a1eed008517528f2633abd74481f661", new string[13]
		{
			"AEON", "AIR", "ANTIAIR", "BUILTBYTIER3FACTORY", "GROUNDATTACK", "MOBILE", "OVERLAYANTIAIR", "OVERLAYDIRECTFIRE", "PRODUCTFA", "RECLAIMABLE",
			"SELECTABLE", "TECH3", "VISIBLETORECON"
		}, "", "", 6000.0, 0.0, 1.0, 0.5, 1.0, 0.0, -0.075, 0.0, 1.4, 1.2, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Gunship", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.", 10.0, 3.0, 2.5, 7.0, 0.0, "Units/uca3011/LOD0/uca3011_lod0.sanmodel", "30a1b5b8ff5d4589c143e95fa1cf73f6a730c648c23c51d685214a6db5f01433", 8.0, 3.0, 8.0, 0.0, hasSourceMaxBrake: false, 90.0, air: true, airHover: true, "", 0.0, 0.0), new GeneratedEconomySpec(4800.0, 1200.0, 60000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[4]
		{
			new GeneratedWeaponSpec("Turret", "Direct Fire", isDeath: false, isBeam: false, "Turret_Muzzle03", "C_Turret", "C_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("C_Barrel", new string[2] { "Turret_Muzzle03", "Turret_Muzzle04" })
			}, rackFireTogether: false, 1, 4, 0.2, 0.0, 10.0, 4, 24.0, 0.0, 0.0, 25.0, 1.25, 0.8, 40.0, 23.0 / 32.0, "/projectiles/ADFQuadLaserLight01/ADFQuadLaserLight01_proj.bp", "pad311", "DirectFire", new string[4] { "Air", "Land", "WaterSurface", "Water" }, "Above", "NoArc", 180.0, 90.0, hasHeadingArc: false, 0.0, 0.0, 70.0, 360.0, 2.0, 0.0, -20.0, 0.0),
			new GeneratedWeaponSpec("AAGun01", "Anti Air", isDeath: false, isBeam: false, "Turret_Muzzle01", "R_Turret", "R_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("R_Barrel", new string[1] { "Turret_Muzzle01" })
			}, rackFireTogether: false, 1, 1, 0.1, 0.0, 10.0, 1, 65.0, 0.0, 0.0, 60.0, 1.0, 1.0, 35.0, 4.0, "/projectiles/AAAZealotMissile02/AAAZealotMissile02_proj.bp", "paa311", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 180.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 180.0, 360.0, 180.0, 0.0, 20.0, 0.0),
			new GeneratedWeaponSpec("AAGun02", "Anti Air", isDeath: false, isBeam: false, "Turret_Muzzle02", "L_Turret", "L_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("L_Barrel", new string[1] { "Turret_Muzzle02" })
			}, rackFireTogether: false, 1, 1, 0.1, 0.0, 10.0, 1, 65.0, 0.0, 0.0, 60.0, 1.0, 1.0, 35.0, 4.0, "/projectiles/AAAZealotMissile02/AAAZealotMissile02_proj.bp", "paa311", "AntiAir", new string[1] { "Air" }, "Above", "NoArc", 180.0, 360.0, hasHeadingArc: false, 0.0, 0.0, 180.0, 360.0, 180.0, 0.0, 20.0, 0.0),
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 100.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("uca2701", "XAA0306", "air", "AeonPortAirUnit", "Solace", structure: false, rosterVisible: true, hasVisualAsset: true, "units/XAA0306/XAA0306_unit.bp", "8914143f45b075d4616c69e38b909ffc806e37687bdc9c9d71076a1b3d71116a", new string[12]
		{
			"AEON", "AIR", "ANTINAVY", "BUILTBYTIER3FACTORY", "HIGHALTAIR", "MOBILE", "OVERLAYSONAR", "PRODUCTFA", "RECLAIMABLE", "SELECTABLE",
			"TECH3", "VISIBLETORECON"
		}, "", "", 3750.0, 0.0, 1.5, 0.5, 1.5, 0.0, -0.2, 0.0, 1.6, 1.2, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 1.0, 1.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, null, 90.0, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Air", "Plane", "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.", 25.0, 3.0, 2.5, 7.0, 0.0, "Units/uca2701/LOD0/uca2701_lod0.sanmodel", "d6107d85d8b4b43c5d8f30987e7d021c64febc82cce957cae9598bcbea626f41", 20.0, 18.0, 20.0, 0.0, hasSourceMaxBrake: false, 90.0, air: true, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(6600.0, 1650.0, 55000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[2]
		{
			new GeneratedWeaponSpec("Bomb", "Anti Navy", isDeath: false, isBeam: false, "Torpedo_Muzzle", "Torpedo_Muzzle", "Torpedo_Muzzle", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Torpedo_Muzzle", new string[1] { "Torpedo_Muzzle" })
			}, rackFireTogether: false, 2, 4, 0.4, 0.0, 10.0, 4, 500.0, 0.0, 4.0, 42.0, 0.08, 12.5, 14.0, 30.0, "/projectiles/AANTorpedoCluster01/AANTorpedoCluster01_proj.bp", "pad004", "DirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "NoArc", 0.0, 0.0, hasHeadingArc: true, 0.0, 30.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("DeathImpact", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 150.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs4102", "XAB1401", "fabricator", "AeonPortStructure", "Paragon", structure: true, rosterVisible: true, hasVisualAsset: true, "units/XAB1401/XAB1401_unit.bp", "8002739b4c792f498d8dc4ed779f26bfdffe2c748e629163170158d0a66222b9", new string[15]
		{
			"AEON", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "ECONOMIC", "ENERGYPRODUCTION", "EXPERIMENTAL", "MASSFABRICATION", "MASSPRODUCTION", "PRODUCTFA",
			"RECLAIMABLE", "SELECTABLE", "SIZE12", "STRUCTURE", "VISIBLETORECON"
		}, "UAB1104", "", 5000.0, 0.0, 4.0, 4.0, 4.0, 0.0, 0.0, 0.0, 3.4, 3.4, "", new string[2] { "Rest", "AnimAdeath" }, new GeneratedPlacementSpec("Footprint.Size", 7.0, 7.0, hasSourceSkirt: true, 10.0, 10.0, -1.5, -1.5), new GeneratedIntelSpec(15.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(125100.0, 250200.0, 7506000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("DeathWeapon", "Death", isDeath: true, isBeam: false, "", "", "", "", Array.Empty<GeneratedRackSpec>(), rackFireTogether: false, 1, 1, 0.0, 0.0, -1.0, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, "", "", "", Array.Empty<string>(), "", "", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3001", "XAB2307", "defence", "AeonPortStructure", "Salvation", structure: true, rosterVisible: true, hasVisualAsset: true, "units/XAB2307/XAB2307_unit.bp", "ea23580adb52cdaf56103f7ef9e73afa2094cb7f6032f16585a02b0fc48fed22", new string[16]
		{
			"AEON", "ARTILLERY", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "DRAGBUILD", "INDIRECTFIRE", "OVERLAYINDIRECTFIRE", "PRODUCTFA", "RECLAIMABLE", "SELECTABLE",
			"SIZE4", "SORTSTRATEGIC", "STRATEGIC", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "", "", 10000.0, 0.0, 3.0, 2.7, 3.6, 0.0, 0.0, 0.0, 3.2, 3.85, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 7.0, 7.0, hasSourceSkirt: true, 10.0, 10.0, -1.5, -1.5), new GeneratedIntelSpec(28.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(90000.0, 270000.0, 5400000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MainGun", "Artillery", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 14.0, 25, 220.0, 2.0, 175.0, 1800.0, 0.32, 3.125, 98.0, 50.0, "/projectiles/AIFFragmentationSensorShell01/AIFFragmentationSensorShell01_proj.bp", "pai311", "IndirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 6.0, hasHeadingArc: false, 0.0, 0.0, 90.0, 6.0, 0.01, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs3702", "XAB3301", "structure", "AeonPortStructure", "Eye of Rhianne", structure: true, rosterVisible: true, hasVisualAsset: true, "units/XAB3301/XAB3301_unit.bp", "f666e7fb908a73d315b27397b47550eed5ba36bac94326b99ca2509cfa0c1e9b", new string[14]
		{
			"ABILITYBUTTON", "AEON", "BUILTBYTIER3COMMANDER", "BUILTBYTIER3ENGINEER", "INTELLIGENCE", "OPTICS", "PRODUCTFA", "RECLAIMABLE", "SELECTABLE", "SIZE4",
			"SORTINTEL", "STRUCTURE", "TECH3", "VISIBLETORECON"
		}, "UAB3201", "", 250.0, 0.0, 2.0, 5.0, 2.0, 0.0, -0.25, 0.0, 0.9, 0.9, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 6.0, 6.0, hasSourceSkirt: true, 10.0, 10.0, -1.5, -1.5), new GeneratedIntelSpec(15.0, null, null, null, null, null, null, null, 25.0, 10.0, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: false, "RULEUMT_None", "", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 0.0, 0.0, 0.0, 0.0, hasSourceMaxBrake: false, 0.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(1800.0, 3000.0, 48000.0, 0.0, 0.0, 0.0, 0.0, 5000.0, 0.0, 0.0), Array.Empty<GeneratedWeaponSpec>(), new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl2806", "XAL0203", "land", "AeonPortLandUnit", "Blaze", structure: false, rosterVisible: true, hasVisualAsset: true, "units/XAL0203/XAL0203_unit.bp", "bfe8fa65517b2c7959535fa79bfff36a9c14c6dda1a56bc20c607a2e550ef59d", new string[14]
		{
			"AEON", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "DIRECTFIRE", "HOVER", "LAND", "MOBILE", "OVERLAYDIRECTFIRE", "PRODUCTFA", "RECLAIMABLE",
			"SELECTABLE", "TANK", "TECH2", "VISIBLETORECON"
		}, "", "", 1050.0, 0.0, 0.9, 0.5, 1.2, 0.0, 0.0, 0.0, 0.6, 0.95, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.9, 1.2, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(15.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Hover", "Hover", "", 0.15, 0.0, 0.0, 0.0, 0.0, "", "", 3.7, 0.0, 3.7, 3.7, hasSourceMaxBrake: true, 90.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(880.0, 220.0, 1320.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MainGun", "Direct Fire", isDeath: false, isBeam: false, "Gun_Muzzle01", "Root", "Gun_Barrel", "", new GeneratedRackSpec[2]
			{
				new GeneratedRackSpec("Gun_Barrel", new string[1] { "Gun_Muzzle01" }),
				new GeneratedRackSpec("Gun_Barrel", new string[1] { "Gun_Muzzle02" })
			}, rackFireTogether: false, 1, 0, 0.0, 0.0, 10.0, 1, 15.0, 0.0, 0.0, 23.0, 3.0, 1.0 / 3.0, 30.0, 529.0 / 600.0, "/projectiles/ADFQuatumAutoGun01/ADFQuatumAutoGun01_proj.bp", "pad131", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "LowArc", 10.0, 90.0, hasHeadingArc: false, 0.0, 0.0, 30.0, 45.0, 2.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl3801", "XAL0305", "land", "AeonPortLandUnit", "Sprite Striker", structure: false, rosterVisible: true, hasVisualAsset: true, "units/XAL0305/XAL0305_unit.bp", "b5ba4a2ba84fabd475a6ac44a9bfec9b5e00bb471e870a4610ca291be8bd0deb", new string[12]
		{
			"AEON", "BOT", "BUILTBYTIER3FACTORY", "DIRECTFIRE", "LAND", "MOBILE", "OVERLAYDIRECTFIRE", "PRODUCTFA", "RECLAIMABLE", "SELECTABLE",
			"TECH3", "VISIBLETORECON"
		}, "", "", 450.0, 0.0, 0.8, 1.0, 0.6, 0.0, 0.0, 0.0, 0.5, 0.5, "", new string[7] { "Rest", "AnimAdeath01", "AnimAdeath02", "AnimAdeath03", "AnimFold", "AnimAsetup", "AnimWalk" }, new GeneratedPlacementSpec("Collision.SizeFallback", 0.8, 0.6, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(26.0, null, null, null, null, null, null, null, null, null, null, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Land", "LegsLand", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 3.0, 0.0, 3.0, 3.0, hasSourceMaxBrake: true, 90.0, air: false, airHover: false, "AnimWalk", 6.4, 15.0 / 32.0), new GeneratedEconomySpec(4800.0, 800.0, 8000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[1]
		{
			new GeneratedWeaponSpec("MainGun", "Direct Fire", isDeath: false, isBeam: false, "Turret_Muzzle", "Turret", "Turret_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Barrel", new string[1] { "Turret_Muzzle" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 10.0, 1, 1300.0, 0.0, 0.0, 70.0, 0.1, 10.0, 120.0, 161.0 / 240.0, "/projectiles/ADFHeavyDisruptorCannon01/ADFHeavyDisruptorCannon01_proj.bp", "pad311", "DirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "NoArc", 180.0, 75.0, hasHeadingArc: false, 0.0, 0.0, 60.0, 30.0, 2.0, 0.0, 10.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucs2501", "XAS0204", "naval", "AeonPortNavalUnit", "Vesper", structure: false, rosterVisible: true, hasVisualAsset: true, "units/XAS0204/XAS0204_unit.bp", "d0576bfabb7db5e9ba4a1b239cac026a3e97070c52129ceb5e1bbd3c769667a0", new string[17]
		{
			"AEON", "ANTINAVY", "BUILTBYEXPERIMENTALSUB", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "MOBILE", "NAVAL", "OVERLAYANTINAVY", "OVERLAYDEFENSE", "OVERLAYSONAR",
			"PRODUCTFA", "RECLAIMABLE", "SELECTABLE", "SUBMERSIBLE", "T2SUBMARINE", "TECH2", "VISIBLETORECON"
		}, "", "", 1800.0, 0.0, 0.65, 0.5, 2.8, 0.05, -0.2, -0.01, 0.6, 1.8, "", new string[1] { "Rest" }, new GeneratedPlacementSpec("Footprint.Size", 2.0, 3.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(32.0, null, 60.0, null, null, null, null, null, null, null, 45.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_SurfacingSub", "WaterSurface", "Sanctuary routes UnderWater but has no FA SurfacingSub transition state machine; the functional WaterSurface fallback retains source speed/acceleration/turn while submerge depth stays provenance.", -1.5, 0.0, 0.0, 0.0, 0.0, "", "", 6.5, 0.0, 6.5, 6.5, hasSourceMaxBrake: true, 80.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(4400.0, 1100.0, 8800.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[2]
		{
			new GeneratedWeaponSpec("Torpedo01", "Anti Navy", isDeath: false, isBeam: false, "Projectile_Front_Right", "Projectile_Front_Right", "Projectile_Front_Right", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Projectile_Front_Right", new string[2] { "Projectile_Front_Right", "Projectile_Front_Left" })
			}, rackFireTogether: false, 1, 4, 0.4, 0.0, 10.0, 1, 90.0, 0.0, 0.0, 45.0, 0.25, 4.0, 5.0, 7.0, "/projectiles/AANTorpedo01/AANTorpedo01_proj.bp", "pai211", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("AntiTorpedo01", "Defense", isDeath: false, isBeam: false, "Projectile_Right_Center01", "Projectile_Right_Center01", "Projectile_Right_Center01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Projectile_Right_Center01", new string[2] { "Projectile_Right_Center01", "Projectile_Left_Center01" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 0.0, 1, 2.0, 0.0, 0.0, 32.0, 0.13, 7.692307692307692, 80.0, 4.0, "/projectiles/AIMAntiTorpedo02/AIMAntiTorpedo02_proj.bp", "pai211", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 0.0, 0.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
		new GeneratedPortSpec("ucl4005", "XAS0306", "naval", "AeonPortNavalUnit", "Torrent Class", structure: false, rosterVisible: true, hasVisualAsset: true, "units/XAS0306/XAS0306_unit.bp", "35ed8ed276b5972f4d92701efa59627353b210e8ed66da7e00b6cb7cfa41172b", new string[17]
		{
			"AEON", "ANTIMISSILE", "BATTLESHIP", "BUILTBYTIER3FACTORY", "DIRECTFIRE", "MOBILE", "NAVAL", "OVERLAYDEFENSE", "OVERLAYINDIRECTFIRE", "OVERLAYRADAR",
			"OVERLAYSONAR", "PRODUCTFA", "RECLAIMABLE", "SELECTABLE", "SHOWATTACKRETICLE", "TECH3", "VISIBLETORECON"
		}, "", "", 15000.0, 0.0, 2.25, 2.8, 11.5, 0.0, -1.0, 0.0, 1.8, 8.0, "", new string[4] { "Rest", "AnimAdeath01", "AnimAdeath02", "AnimAdeath03" }, new GeneratedPlacementSpec("Footprint.Size", 5.0, 16.0, hasSourceSkirt: false, 0.0, 0.0, 0.0, 0.0), new GeneratedIntelSpec(70.0, 110.0, 20.0, null, null, null, null, null, null, null, 50.0, null, null), new GeneratedShieldSpec(enabled: false, null, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedMovementSpec(enabled: true, "RULEUMT_Water", "WaterSurface", "", 0.0, 0.0, 0.0, 0.0, 0.0, "", "", 3.0, 0.0, 3.0, 3.0, hasSourceMaxBrake: true, 30.0, air: false, airHover: false, "", 0.0, 0.0), new GeneratedEconomySpec(16000.0, 8000.0, 80000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), new GeneratedWeaponSpec[6]
		{
			new GeneratedWeaponSpec("MissileRackFront", "Missile", isDeath: false, isBeam: false, "Turret_Front_Muzzle02", "Turret_Front", "Turret_Front_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Front", new string[5] { "Turret_Front_Muzzle", "Turret_Front_Muzzle01", "Turret_Front_Muzzle02", "Turret_Front_Muzzle03", "Turret_Front_Muzzle04" })
			}, rackFireTogether: false, 1, 5, 1.0, 0.0, 0.0, 1, 1000.0, 5.0, 25.0, 200.0, 0.05, 20.0, 5.0, 25.0, "/projectiles/AIFMissileSerpentine03/AIFMissileSerpentine03_proj.bp", "pai311", "IndirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 30.0, hasHeadingArc: true, 0.0, 165.0, 0.0, 15.0, 2.0, 0.0, 55.0, 0.0),
			new GeneratedWeaponSpec("MissileRackBack", "Missile", isDeath: false, isBeam: false, "Turret_Back_Muzzle02", "Turret_Back", "Turret_Back_Barrel", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Turret_Back", new string[5] { "Turret_Back_Muzzle", "Turret_Back_Muzzle01", "Turret_Back_Muzzle02", "Turret_Back_Muzzle03", "Turret_Back_Muzzle04" })
			}, rackFireTogether: false, 1, 5, 1.0, 0.0, 0.0, 1, 1000.0, 5.0, 25.0, 200.0, 0.05, 20.0, 5.0, 25.0, "/projectiles/AIFMissileSerpentine03/AIFMissileSerpentine03_proj.bp", "pai311", "IndirectFire", new string[3] { "Land", "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 30.0, hasHeadingArc: true, 180.0, 165.0, 0.0, 15.0, 2.0, 0.0, 55.0, 0.0),
			new GeneratedWeaponSpec("AntiTorpedoLeft1", "Defense", isDeath: false, isBeam: false, "Projectile04", "Projectile04", "Projectile04", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Projectile04", new string[1] { "Projectile04" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 0.0, 1, 3.0, 0.0, 15.0, 45.0, 0.26, 3.846153846153846, 80.0, 4.0, "/projectiles/AIMAntiTorpedo02/AIMAntiTorpedo02_proj.bp", "pai311", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("AntiTorpedoLeft2", "Defense", isDeath: false, isBeam: false, "Projectile03", "Projectile03", "Projectile03", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Projectile03", new string[1] { "Projectile03" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 0.0, 1, 3.0, 0.0, 15.0, 45.0, 0.26, 3.846153846153846, 80.0, 4.0, "/projectiles/AIMAntiTorpedo02/AIMAntiTorpedo02_proj.bp", "pai311", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("AntiTorpedoRight1", "Defense", isDeath: false, isBeam: false, "Projectile02", "Projectile02", "Projectile02", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Projectile02", new string[1] { "Projectile02" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 0.0, 1, 3.0, 0.0, 15.0, 45.0, 0.26, 3.846153846153846, 80.0, 4.0, "/projectiles/AIMAntiTorpedo02/AIMAntiTorpedo02_proj.bp", "pai311", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0),
			new GeneratedWeaponSpec("AntiTorpedoRight2", "Defense", isDeath: false, isBeam: false, "Projectile01", "Projectile01", "Projectile01", "", new GeneratedRackSpec[1]
			{
				new GeneratedRackSpec("Projectile01", new string[1] { "Projectile01" })
			}, rackFireTogether: false, 1, 1, 0.0, 0.0, 0.0, 1, 3.0, 0.0, 15.0, 45.0, 0.26, 3.846153846153846, 80.0, 4.0, "/projectiles/AIMAntiTorpedo02/AIMAntiTorpedo02_proj.bp", "pai311", "IndirectFire", new string[2] { "WaterSurface", "Water" }, "Above", "HighArc", 180.0, 180.0, hasHeadingArc: false, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0)
		}, new GeneratedCzarBeamHook(enabled: false, "", "", "", 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0))
	};
}
