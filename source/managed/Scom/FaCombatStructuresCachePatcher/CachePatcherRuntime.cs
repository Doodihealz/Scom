using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace FaCombatStructuresCachePatcher;

public static class CachePatcherRuntime
{
	private enum PatchCategory
	{
		AlloyExtractor,
		Radar,
		CombatDefense
	}

	private sealed class StructureGeometry
	{
		public double CenterY { get; }

		public double CenterZ { get; }

		public double CollisionX { get; }

		public double CollisionY { get; }

		public double CollisionZ { get; }

		public double TarmacX { get; }

		public double TarmacZ { get; }

		public double SelectionX { get; }

		public double SelectionZ { get; }

		public int GridX { get; }

		public int GridZ { get; }

		public StructureGeometry(double centerY, double centerZ, double collisionX, double collisionY, double collisionZ, double tarmacX, double tarmacZ, double selectionX, double selectionZ, int gridX, int gridZ)
		{
			CenterY = centerY;
			CenterZ = centerZ;
			CollisionX = collisionX;
			CollisionY = collisionY;
			CollisionZ = collisionZ;
			TarmacX = tarmacX;
			TarmacZ = tarmacZ;
			SelectionX = selectionX;
			SelectionZ = selectionZ;
			GridX = gridX;
			GridZ = gridZ;
		}
	}

	private sealed class WeaponRig
	{
		public string YawBone { get; }

		public string PitchBone { get; }

		public string AimBone { get; }

		public IReadOnlyList<string[]> MuzzleGroups { get; }

		public IReadOnlyList<string> RequiredAliases { get; }

		public WeaponRig(string yawBone, string pitchBone, string aimBone, IReadOnlyList<string[]> muzzleGroups, IReadOnlyList<string>? requiredAliases = null)
		{
			if (muzzleGroups.Count == 0 || muzzleGroups.Any((string[] group) => group.Length == 0))
			{
				throw new ArgumentException("A combat weapon rig needs at least one non-empty muzzle group.", "muzzleGroups");
			}
			YawBone = yawBone;
			PitchBone = pitchBone;
			AimBone = aimBone;
			MuzzleGroups = muzzleGroups;
			RequiredAliases = requiredAliases ?? Array.Empty<string>();
		}

		public string BuildLua(string templateId)
		{
			string text = string.Join("\n", MuzzleGroups.Select((string[] group, int index) => string.Format("            combatWeapon.muzzleGroups[{0}].muzzles = {{ {1} }}", index + 1, string.Join(", ", group.Select((string muzzle) => "\"" + muzzle + "\"")))));
			string text2 = ((RequiredAliases.Count == 0) ? string.Empty : ("            -- Required identity muzzle aliases supplied by the model conversion: " + string.Join(", ", RequiredAliases) + "\n"));
			return string.Format("-- SCOM startup recovery 2.1.88.5: the imported rig owns its complete\n-- muzzle topology, not the incoming donor's group count. Weapon gameplay\n-- fields remain unchanged; later source-parity stages remain authoritative.\n{0}do\n    assert(type(UnitTemplate) == \"table\" and type(UnitTemplate.general) == \"table\"\n        and UnitTemplate.general.tpId == \"{2}\", \"SCOM rig scope drift: {2}\")\n    local original = UnitTemplate.weapons and UnitTemplate.weapons[1]\n    assert(type(original) == \"table\" and original.category ~= \"DeathExplosion\"\n        and type(original.aimControllers) == \"table\"\n        and type(original.aimControllers[1]) == \"table\",\n        \"SCOM rig requires the primary aimed weapon: {2}\")\n    local function copy(value)\n        local result = {{}}\n        for key, item in pairs(value or {{}}) do result[key] = item end\n        return result\n    end\n    -- Build a detached replacement. No partial rig mutation on validation failure.\n    local combatWeapon = copy(original)\n    combatWeapon.aimControllers = copy(original.aimControllers)\n    local aimController = copy(original.aimControllers[1])\n    aimController.aimBone = \"{3}\"\n    aimController.yawBone = \"{4}\"\n    aimController.pitchBone = \"{5}\"\n    combatWeapon.aimControllers[1] = aimController\n    combatWeapon.muzzleGroups = {{}}\n    for index = 1, {1} do\n        local oldGroup = original.muzzleGroups and original.muzzleGroups[index]\n        combatWeapon.muzzleGroups[index] = type(oldGroup) == \"table\" and copy(oldGroup) or {{}}\n    end\n{6}\n    local muzzleMap = {{}}\n    for _, group in ipairs(combatWeapon.muzzleGroups) do\n        assert(type(group.muzzles) == \"table\" and #group.muzzles > 0,\n            \"SCOM rig generated an empty muzzle group: {2}\")\n        for _, bone in ipairs(group.muzzles) do\n            assert(type(bone) == \"string\" and #bone > 0, \"SCOM rig generated an invalid muzzle: {2}\")\n            local oldMuzzle = original.muzzles and original.muzzles[bone]\n            local muzzle = type(oldMuzzle) == \"table\" and copy(oldMuzzle) or {{}}\n            muzzle.aimController = \"{3}\"\n            muzzleMap[bone] = muzzle\n        end\n    end\n    combatWeapon.muzzles = muzzleMap\n    assert(#combatWeapon.muzzleGroups == {1}, \"SCOM rig output group count drift: {2}\")\n    UnitTemplate.weapons[1] = combatWeapon\nend\n", text2, MuzzleGroups.Count, templateId, AimBone, YawBone, PitchBone, text);
		}
	}

	private sealed class PatchSpec
	{
		public PatchCategory Category { get; }

		public string TargetId { get; }

		public string Description { get; }

		public string RelativePath { get; }

		public string Appendix { get; }

		public IReadOnlyList<string> RequiredAliases { get; }

		public PatchSpec(PatchCategory category, string targetId, string description, string appendix)
		{
			Category = category;
			TargetId = targetId;
			Description = description;
			RelativePath = "LJ/lua/common/units/unitsTemplates/" + targetId + "/" + targetId + ".santp";
			Appendix = "\n\n-- FA Combat Structures Cache Patcher 1.1.0\n" + appendix.TrimStart('\r', '\n');
			RequiredAliases = ExtractRequiredAliases(appendix);
		}

		private static IReadOnlyList<string> ExtractRequiredAliases(string appendix)
		{
			int num = appendix.IndexOf("-- Required identity muzzle aliases supplied by the model conversion: ", StringComparison.Ordinal);
			if (num < 0)
			{
				return Array.Empty<string>();
			}
			num += "-- Required identity muzzle aliases supplied by the model conversion: ".Length;
			int num2 = appendix.IndexOf('\n', num);
			return appendix.Substring(num, (num2 < 0) ? (appendix.Length - num) : (num2 - num)).Split(new string[1] { ", " }, StringSplitOptions.RemoveEmptyEntries);
		}
	}

	private sealed class CachedResource
	{
		public PatchSpec Spec { get; }

		public string Path { get; }

		public object Stock { get; }

		public object? Replacement { get; set; }

		public bool ReplacementWasAssigned { get; set; }

		public CachedResource(PatchSpec spec, string path, object stock)
		{
			Spec = spec;
			Path = path;
			Stock = stock;
		}
	}

	private const string OverrideMarker = "-- FA Combat Structures Cache Patcher 1.1.0";

	private const string FaUnitsArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	private static readonly HashSet<string> NativeOneCellCoreTemplates;

	private static readonly HashSet<string> ImportedAnimatedStructureTemplates;

	private static readonly PatchSpec[] PatchSpecs;

	static CachePatcherRuntime()
	{
		NativeOneCellCoreTemplates = new HashSet<string>(StringComparer.Ordinal)
		{
			"ugs1601", "ugs2601", "ugs3601", "ues1601", "ues2601", "ues3601", "ugs1001", "ugs2001", "ugs1201", "ugs2201",
			"ugs3201", "ues1001", "ues2001", "ues1201", "ues2201", "ues3201"
		};
		ImportedAnimatedStructureTemplates = new HashSet<string>(StringComparer.Ordinal) { "ugs1601", "ugs2601", "ugs3601", "ues1601", "ues2601", "ues3601", "ugs1701", "ugs2701", "ues1701", "ues2701" };
		PatchSpecs = new PatchSpec[22]
		{
			new PatchSpec(PatchCategory.AlloyExtractor, "ugs1601", "Guard T1 alloy extractor template", StructureTemplateOverride("ugs1601", new StructureGeometry(0.76, -0.1, 1.21, 2.67, 1.08, 1.29, 1.16, 1.44, 1.31, 2, 2), null)),
			new PatchSpec(PatchCategory.AlloyExtractor, "ugs2601", "Guard T2 alloy extractor template", StructureTemplateOverride("ugs2601", new StructureGeometry(1.11, -0.1, 1.21, 2.67, 1.08, 1.29, 1.16, 1.44, 1.31, 2, 2), null)),
			new PatchSpec(PatchCategory.AlloyExtractor, "ugs3601", "Guard T3 alloy extractor template", StructureTemplateOverride("ugs3601", new StructureGeometry(1.13, -0.2, 1.58, 2.4, 1.39, 1.66, 1.47, 1.81, 1.62, 2, 2), null)),
			new PatchSpec(PatchCategory.AlloyExtractor, "ues1601", "EDA T1 alloy extractor template", StructureTemplateOverride("ues1601", new StructureGeometry(0.42, 0.0, 1.08, 2.22, 1.08, 1.16, 1.16, 1.31, 1.31, 2, 2), null)),
			new PatchSpec(PatchCategory.AlloyExtractor, "ues2601", "EDA T2 alloy extractor template", StructureTemplateOverride("ues2601", new StructureGeometry(0.61, 0.0, 1.08, 1.8, 1.08, 1.16, 1.16, 1.31, 1.31, 2, 2), null)),
			new PatchSpec(PatchCategory.AlloyExtractor, "ues3601", "EDA T3 alloy extractor template", StructureTemplateOverride("ues3601", new StructureGeometry(0.84, 0.0, 1.43, 1.82, 1.08, 1.51, 1.16, 1.66, 1.31, 2, 2), null)),
			new PatchSpec(PatchCategory.Radar, "ugs1701", "Guard T1 radar template", StructureTemplateOverride("ugs1701", new StructureGeometry(0.67, 0.11, 1.69, 4.21, 1.54, 1.77, 1.62, 1.92, 1.77, 2, 2), null)),
			new PatchSpec(PatchCategory.Radar, "ugs2701", "Guard T2 radar template", StructureTemplateOverride("ugs2701", new StructureGeometry(1.81, 0.13, 1.76, 4.66, 1.58, 1.84, 1.66, 1.99, 1.81, 2, 2), null)),
			new PatchSpec(PatchCategory.Radar, "ugs3701", "Guard T3 omni/radar template", StructureTemplateOverride("ugs3701", new StructureGeometry(2.32, 0.18, 2.14, 4.79, 1.93, 2.22, 2.01, 2.37, 2.16, 3, 2), null)),
			new PatchSpec(PatchCategory.Radar, "ues1701", "EDA T1 radar template", StructureTemplateOverride("ues1701", new StructureGeometry(1.04, 0.0, 1.18, 3.41, 1.18, 1.26, 1.26, 1.41, 1.41, 2, 2), null)),
			new PatchSpec(PatchCategory.Radar, "ues2701", "EDA T2 radar template", StructureTemplateOverride("ues2701", new StructureGeometry(1.35, 0.0, 1.18, 4.03, 1.18, 1.26, 1.26, 1.41, 1.41, 2, 2), null)),
			new PatchSpec(PatchCategory.Radar, "ues3701", "EDA T3 omni/radar template", StructureTemplateOverride("ues3701", new StructureGeometry(1.94, 0.0, 2.16, 4.12, 2.16, 2.24, 2.24, 2.39, 2.39, 3, 3), null)),
			new PatchSpec(PatchCategory.CombatDefense, "ugs1001", "Guard T1 point-defense template", StructureTemplateOverride("ugs1001", new StructureGeometry(0.43, -0.05, 0.73, 1.01, 1.08, 0.81, 1.16, 0.96, 1.31, 2, 2), new WeaponRig("Turret", "Turret_Barrel", "Turret_Muzzle", new string[1][] { new string[1] { "Turret_Muzzle" } }))),
			new PatchSpec(PatchCategory.CombatDefense, "ugs2001", "Guard T2 point-defense template", StructureTemplateOverride("ugs2001", new StructureGeometry(0.51, 0.01, 1.35, 2.01, 1.36, 1.43, 1.44, 1.58, 1.59, 2, 2), new WeaponRig("Turret_B01", "Turret_B02", "Turret_Muzzle01", new string[1][] { new string[2] { "Turret_Muzzle01", "Turret_Muzzle02" } }))),
			new PatchSpec(PatchCategory.CombatDefense, "ues1001", "EDA T1 point-defense template", StructureTemplateOverride("ues1001", new StructureGeometry(0.42, 0.0, 1.1, 0.98, 1.1, 1.18, 1.18, 1.33, 1.33, 2, 2), new WeaponRig("Turret", "Turret_Barrel", "Turret_Muzzle", new string[2][]
			{
				new string[1] { "Turret_Muzzle" },
				new string[1] { "Turret_Muzzle_02" }
			}, new string[1] { "Turret_Muzzle_02" }))),
			new PatchSpec(PatchCategory.CombatDefense, "ues2001", "EDA T2 point-defense template", StructureTemplateOverride("ues2001", new StructureGeometry(0.51, 0.0, 1.45, 1.17, 1.44, 1.53, 1.52, 1.68, 1.67, 2, 2), new WeaponRig("Turret", "Turret_Barrel", "Turret_Muzzle02", new string[1][] { new string[3] { "Turret_Muzzle01", "Turret_Muzzle02", "Turret_Muzzle03" } }))),
			new PatchSpec(PatchCategory.CombatDefense, "ugs1201", "Guard T1 anti-air template", StructureTemplateOverride("ugs1201", new StructureGeometry(0.13, -0.08, 1.02, 1.64, 1.0, 1.1, 1.08, 1.25, 1.23, 2, 2), new WeaponRig("Turret", "Turret_Barrel", "Turret_Muzzle_01", new string[1][] { new string[1] { "Turret_Muzzle_01" } }))),
			new PatchSpec(PatchCategory.CombatDefense, "ugs2201", "Guard T2 anti-air template", StructureTemplateOverride("ugs2201", new StructureGeometry(0.09, 0.05, 1.23, 1.85, 1.5, 1.31, 1.58, 1.46, 1.73, 2, 2), new WeaponRig("Turret", "Turret_Barrel", "Turret_Recoil01_Muzzle01", new string[1][] { new string[3] { "Turret_Recoil01_Muzzle01", "Turret_Recoil01_Muzzle02", "Turret_Recoil02_Muzzle01" } }))),
			new PatchSpec(PatchCategory.CombatDefense, "ugs3201", "Guard T3 anti-air template", StructureTemplateOverride("ugs3201", new StructureGeometry(0.28, -0.02, 1.23, 2.15, 1.12, 1.31, 1.2, 1.46, 1.35, 2, 2), new WeaponRig("Turret", "Turret_Barrel", "Turret_Left_Muzzle01", new string[1][] { new string[1] { "Turret_Left_Muzzle01" } }))),
			new PatchSpec(PatchCategory.CombatDefense, "ues1201", "EDA T1 anti-air template", StructureTemplateOverride("ues1201", new StructureGeometry(0.02, 0.0, 1.1, 1.74, 1.1, 1.18, 1.18, 1.33, 1.33, 2, 2), new WeaponRig("Turret", "Turret_Barrel", "Turret_Muzzle_01", new string[4][]
			{
				new string[1] { "Turret_Muzzle_01" },
				new string[1] { "Turret_Muzzle_02" },
				new string[1] { "Turret_Muzzle_03" },
				new string[1] { "Turret_Muzzle_04" }
			}, new string[2] { "Turret_Muzzle_03", "Turret_Muzzle_04" }))),
			new PatchSpec(PatchCategory.CombatDefense, "ues2201", "EDA T2 anti-air template", StructureTemplateOverride("ues2201", new StructureGeometry(-0.07, -0.14, 1.02, 1.47, 1.42, 1.1, 1.5, 1.25, 1.65, 2, 2), new WeaponRig("Turret", "Turret_Barrel", "Turret_Muzzle_Right", new string[1][] { new string[1] { "Turret_Muzzle_Right" } }))),
			new PatchSpec(PatchCategory.CombatDefense, "ues3201", "EDA T3 anti-air template", StructureTemplateOverride("ues3201", new StructureGeometry(0.09, 0.0, 1.33, 2.35, 1.32, 1.41, 1.4, 1.56, 1.55, 2, 2), new WeaponRig("Turret", "Turret_Barrel", "Turret_Muzzle_Left01", new string[12][]
			{
				new string[1] { "Turret_Muzzle_Left01" },
				new string[1] { "Turret_Muzzle_Right01" },
				new string[1] { "Turret_Muzzle_Left02" },
				new string[1] { "Turret_Muzzle_Right02" },
				new string[1] { "Turret_Muzzle_Left03" },
				new string[1] { "Turret_Muzzle_Right03" },
				new string[1] { "Turret_Muzzle_Left04" },
				new string[1] { "Turret_Muzzle_Right04" },
				new string[1] { "Turret_Muzzle_Left05" },
				new string[1] { "Turret_Muzzle_Right05" },
				new string[1] { "Turret_Muzzle_Left06" },
				new string[1] { "Turret_Muzzle_Right06" }
			}, new string[6] { "Turret_Muzzle_Left04", "Turret_Muzzle_Right04", "Turret_Muzzle_Left05", "Turret_Muzzle_Right05", "Turret_Muzzle_Left06", "Turret_Muzzle_Right06" })))
		};
		ValidatePatchSpecs();
	}

	private static string StructureTemplateOverride(string templateId, StructureGeometry geometry, WeaponRig? weaponRig)
	{
		string text = weaponRig?.BuildLua(templateId) ?? string.Empty;
		int num = (NativeOneCellCoreTemplates.Contains(templateId) ? 1 : geometry.GridX);
		int num2 = (NativeOneCellCoreTemplates.Contains(templateId) ? 1 : geometry.GridZ);
		string text2 = (ImportedAnimatedStructureTemplates.Contains(templateId) ? "-- Preserve the verified extractor/radar animation map installed by the earlier animation module." : "UnitTemplate.visuals.animations = nil");
		string text3 = SourceGameplayOverride(templateId);
		return $"\n-- Apply measured imported-art bounds, then replace the donor's\n-- gameplay with the hash-pinned same-role FA source contract.\nUnitTemplate.additions = UnitTemplate.additions or {{}}\nUnitTemplate.visuals = UnitTemplate.visuals or {{}}\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.tarmacSize = {{\n    x = {Lua(geometry.TarmacX)},\n    y = {Lua(geometry.TarmacZ)},\n}}\nUnitTemplate.additions.selectionHit = {{\n    size = {{\n        x = {Lua(geometry.SelectionX)},\n        y = {Lua(geometry.SelectionZ)},\n    }},\n    offset = {{\n        x = 0,\n        y = {Lua(geometry.CenterY)},\n        z = {Lua(geometry.CenterZ)},\n    }},\n}}\n{text2}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.collisionInfo = {{\n    centerOffset = {{\n        x = 0,\n        y = {Lua(geometry.CenterY)},\n        z = {Lua(geometry.CenterZ)},\n    }},\n    collisionSize = {{\n        x = {Lua(geometry.CollisionX)},\n        y = {Lua(geometry.CollisionY)},\n        z = {Lua(geometry.CollisionZ)},\n    }},\n}}\nUnitTemplate.visuals.selection = {{\n    offset = {{\n        x = 0,\n        y = {Lua(geometry.CenterY)},\n        z = {Lua(geometry.CenterZ)},\n    }},\n    size = {{\n        x = {Lua(geometry.SelectionX)},\n        y = {Lua(geometry.SelectionZ)},\n    }},\n}}\nUnitTemplate.footprint = {{\n    x = {num},\n    y = {num2},\n}}\nUnitTemplate.skirtSize = {{\n    x = {geometry.GridX},\n    y = {geometry.GridZ},\n}}\n{text3}\n\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do\n            effect.boneName = \"Root\"\n        end\n    end\nend\n{text}";
		static string Lua(double value)
		{
			return value.ToString("0.##", CultureInfo.InvariantCulture);
		}
	}

	private static string SourceGameplayOverride(string targetId)
	{
		return targetId switch
		{
			"ugs1601" => AlloyExtractorGameplayOverride("URB1103", targetId, "e723b2d7f3b916bd24f46587a9ef7c3691b60265830553bb234505cd162db1ef", "URB1103_script.lua", "4cb15562c13b6c34b7ac751aadd39f36e67f62ae4ea2bd1e2a3dac3b01055078", 600, 60, 36, 360, 2, 2, 0, sourceVisionRadiusDeclared: false, 10, "urb1202", "ugs2601", "T1MassExtractorAdjacencyBuffs"), 
			"ugs2601" => AlloyExtractorGameplayOverride("URB1202", targetId, "b89469f2fa005d292b134e78aa46bf36d3ba3693085bf4b2a991d84635924a9c", "URB1202_script.lua", "415f197ffaf57d3983f9528984f6bce30b90c88137e605d6d5d7187c608a885b", 3000, 900, 900, 5400, 6, 9, 20, sourceVisionRadiusDeclared: true, 15, "urb1302", "ugs3601", "T2MassExtractorAdjacencyBuffs"), 
			"ugs3601" => AlloyExtractorGameplayOverride("URB1302", targetId, "8e6c44d30877de9829061ac604f160ed81797698d6bed13c3580dc98ea5baf8c", "URB1302_script.lua", "9028c6b987da4164e97fdd9dbecc39abb1a8a40efbebbfc61d2a9264f45e9ebc", 8400, 2875, 4600, 31625, 18, 54, 20, sourceVisionRadiusDeclared: true, 0, null, null, "T3MassExtractorAdjacencyBuffs"), 
			"ues1601" => AlloyExtractorGameplayOverride("UEB1103", targetId, "86c7f83bd2c803cd1640e9a88785bf847aff377287ceabedbe7d7735083e55bf", "UEB1103_script.lua", "0bc78e289e8912ab401f3fcede51cc89530e4ff10a913b2b0c52ff1625affa72", 600, 60, 36, 360, 2, 2, 0, sourceVisionRadiusDeclared: false, 10, "ueb1202", "ues2601", "T1MassExtractorAdjacencyBuffs"), 
			"ues2601" => AlloyExtractorGameplayOverride("UEB1202", targetId, "a9cd0868668e03102cfa642387727daacb22fc6b1816c857ad1d95cd3efe02a2", "UEB1202_script.lua", "ca6ae6f1f6aa44cb4b85051b77196a508994d6e34444a11d350e3d5347e7fdf5", 3000, 900, 900, 5400, 6, 9, 20, sourceVisionRadiusDeclared: true, 15, "ueb1302", "ues3601", "T2MassExtractorAdjacencyBuffs"), 
			"ues3601" => AlloyExtractorGameplayOverride("UEB1302", targetId, "4f488f277b85b44ea8d422228e936d2933e8e667b690e633e89a13e6560558ef", "UEB1302_script.lua", "42ca7242bb5362e5f396dd628e144df3b14789491c8d20bcc84669ae8eed3849", 8400, 2875, 4600, 31625, 18, 54, 20, sourceVisionRadiusDeclared: true, 0, null, null, "T3MassExtractorAdjacencyBuffs"), 
			"ugs1701" => RadarGameplayOverride("URB3101", targetId, "9ad39baea926509e420f233c500da4d9180404fd93ee5035aa435d6cbc4627ce", "URB3101_script.lua", "64e0786f75876a4ad96b6a709f0b86d429dbf9b5f53c4cc3ff11984843ed434b", 10, 80, 80, 720, 20, 20, 115, null, null, 10, "urb3201", "ugs2701", sourceUpgradeAnimationMapped: true, sourceRandomDishMotion: true, "UnitTemplate.additions.rotators = nil"), 
			"ugs2701" => RadarGameplayOverride("URB3201", targetId, "3863c2abaae011903c08ba6921bec62e995c043fee8591d81591a807d5ba4b32", "URB3201_script.lua", "42f30013928cd63e8de2c72540b9e20f40ae842ba40fb5d3b46e1fe8427fab17", 50, 600, 180, 3600, 250, 25, 200, null, null, 15, "urb3104", "ugs3701", sourceUpgradeAnimationMapped: true, sourceRandomDishMotion: true, "UnitTemplate.additions.rotators = nil"), 
			"ugs3701" => RadarGameplayOverride("URB3104", targetId, "d72ec56d15d1a0ff351a580ce5afabd127f16817d6e4a0134316d5193c3735fa", "URB3104_script.lua", "97d45c808e24410434d2f7ad417f45d2af9c0e9410cf232e1b63b8e174825702", 100, 1800, 2400, 30000, 2000, 30, 600, 200, null, 0, null, null, sourceUpgradeAnimationMapped: false, sourceRandomDishMotion: true, "UnitTemplate.additions.rotators = {\n    { boneName = \"Spinner\", speed = { x = 0, y = 0, z = 3 } },\n}"), 
			"ues1701" => RadarGameplayOverride("UEB3101", targetId, "ee05e5e121a66c6e9f1fd13aa971044c6d9f5b553af6867683a02772ce96a5b3", "UEB3101_Script.lua", "5c94a1e0cc57c419a4b7243e763d3e09890ad08493d94b3d361fb2b8c225b757", 10, 80, 80, 720, 20, 20, 115, null, 10, 10, "ueb3201", "ues2701", sourceUpgradeAnimationMapped: true, sourceRandomDishMotion: false, "UnitTemplate.additions.rotators = nil"), 
			"ues2701" => RadarGameplayOverride("UEB3201", targetId, "be211ff99f795a86a2d21974e8c12e5f5358fd07aa4eeec000b6f56a9b14ed7f", "UEB3201_script.lua", "a7736cca4cc54d74ea88bc3fc49155265f185dff99e0f1af7da83ff704b06b07", 50, 600, 180, 3600, 250, 25, 200, null, 5, 15, "ueb3104", "ues3701", sourceUpgradeAnimationMapped: true, sourceRandomDishMotion: false, "UnitTemplate.additions.rotators = {\n    { boneName = \"Upper_Array\", speed = { x = 0, y = 0, z = 10 } },\n}"), 
			"ues3701" => RadarGameplayOverride("UEB3104", targetId, "0850c6139f625e2bbe6ff575a0950f786c1526cfb2a59e2aaf5661c3b0e8e495", "UEB3104_script.lua", "1b503994719bacb8ddebf014fdfb743228dbcf6a02ac3ff89478689898c4d653", 100, 1800, 2400, 30000, 2000, 30, 600, 200, 10, 0, null, null, sourceUpgradeAnimationMapped: false, sourceRandomDishMotion: false, "UnitTemplate.additions.rotators = {\n    { boneName = \"Upper_Array\", speed = { x = 0, y = 0, z = 10 } },\n    { boneName = \"Lower_Array_Detail\", speed = { x = 0, y = 0, z = -10 } },\n}"), 
			"ugs1001" => DefenseGameplayOverride("URB2101", targetId, "65793eefd69516a503a00c9dc6fd6ec53cbf3f6b41c1aeef042fafddcc29acee", "URB2101_Script.lua", "b8ab02c1335332de6de6055b4ae6193f04346af6d3660d5c6764852cd8d75c41", 1300, 250, 250, 2000, 24, "CDFLaserHeavy01"), 
			"ugs2001" => DefenseGameplayOverride("URB2301", targetId, "6f61e9f0f4d02f1dcf9ca03ecd2206dd15aa1476709d470f448c4af3e6e69c0f", "URB2301_Script.lua", "8af1d38542249dcfec00b39de44407947dca5bad5f1e5514811faf4957894b22", 2000, 400, 480, 3400, 28, "beam (no FA ProjectileId)"), 
			"ugs1201" => DefenseGameplayOverride("URB2104", targetId, "4e4cb9ea8dbc35a9a8967db16ab88111a545aa306ab764a875d3f7c0e9b35a1e", "URB2104_script.lua", "cc7c9d674749dccf33a302a2cbe287b04baa906bfb3db902e48ae0e57e58a5c4", 1200, 250, 200, 2000, 24, "CAAAutocannon01"), 
			"ugs2201" => DefenseGameplayOverride("URB2204", targetId, "6794c891d2df57fb0f930c046bcbf88a229b29f057277eb1b0bb0504e4688499", "URB2204_script.lua", "cb85591748575c17f1e7472859d103b15a6b532eaf1084d70987fcece9430cc9", 3400, 700, 560, 5600, 24, "CAABurstCloud01"), 
			"ugs3201" => DefenseGameplayOverride("URB2304", targetId, "1d9170532ed36fa790a5cd50931ad1888e50b039091ec5590d4aa74c2ff23b64", "URB2304_script.lua", "e734a52d2acd547499ea1ea351e0137a1ec59a7861c2c828be15aa0e3044b0ad", 10500, 800, 800, 8000, 28, "CAAMissileNanite02"), 
			"ues1001" => DefenseGameplayOverride("UEB2101", targetId, "96819759123b21cac02aea99aaf5ceee1821801b3d0d6041d8811d1e4f8e01c5", "UEB2101_Script.lua", "d238a8e19ad7a8d06d47e8814d20f159962c5bb3f1964be193926b72cad72339", 1300, 250, 250, 2000, 24, "TDFPlasma01"), 
			"ues2001" => DefenseGameplayOverride("UEB2301", targetId, "97f831fed87fef94266593852b044fd26b7b09e2066b494b0c6bb15aa93d67b9", "UEB2301_Script.lua", "0d73fab7b3e01e0e07dd665acef30de28019210633ac29aa5ad0dbb667146d8c", 2250, 450, 540, 3600, 28, "TDFGauss02"), 
			"ues1201" => DefenseGameplayOverride("UEB2104", targetId, "05006a48235854f089ba007e1a2ef255d495155668a9c381dbc792349deb9d03", "UEB2104_script.lua", "c03ab64190fd97b2556395636df2ecdeb14d2f804782bd71fce4298702548ecb", 1200, 250, 200, 2000, 24, "TAARailgun01"), 
			"ues2201" => DefenseGameplayOverride("UEB2204", targetId, "8e459e3d4f2528c88597b13df611cb6999ddd113e97d83237cd1049ab0788099", "UEB2204_script.lua", "96a7e4dc1adb2bb28ea52bcf636f4d47f7d3ac7528bbccaec5ee8bd949f7b362", 3700, 700, 560, 5600, 24, "TAALightFragmentationShell01"), 
			"ues3201" => DefenseGameplayOverride("UEB2304", targetId, "6a0bfa968a2df65ad01e877ef63235e93a3e8ed66b9a2fe2a53d9bb97c7dc878", "UEB2304_script.lua", "1402433c0c128ed89356e5df501ba8dd5e710eb793587a5e1420681fc9199b4b", 10500, 800, 800, 8000, 28, "TAAMissileFlayer01"), 
			_ => throw new InvalidOperationException("No FA gameplay contract is registered for " + targetId + "."), 
		};
	}

	private static string AlloyExtractorGameplayOverride(string sourceId, string targetId, string sourceBlueprintSha256, string sourceScriptName, string sourceScriptSha256, int health, int buildTime, int alloys, int energy, int productionAlloys, int maintenanceEnergy, int visionRadius, bool sourceVisionRadiusDeclared, int buildPower, string? sourceUpgradesTo, string? sanctuaryUpgradesTo, string sourceAdjacency)
	{
		string text = ((sanctuaryUpgradesTo == null) ? "UnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.buildPower = nil\nUnitTemplate.construction.canBuild = nil\nUnitTemplate.construction.upgradesTo = nil" : $"UnitTemplate.construction = UnitTemplate.construction or {{}}\nUnitTemplate.construction.buildPower = {buildPower}\nUnitTemplate.construction.canBuild = \"Tags.{sanctuaryUpgradesTo}\"\nUnitTemplate.construction.upgradesTo = \"{sanctuaryUpgradesTo}\"");
		string text2 = ((sourceUpgradesTo == null) ? "sourceUpgradesTo = nil,\n                sanctuaryUpgradesTo = nil," : ("sourceUpgradesTo = \"" + sourceUpgradesTo + "\",\nsanctuaryUpgradesTo = \"" + sanctuaryUpgradesTo + "\","));
		return string.Format("-- Exact FA extractor health, economy, upgrade power, and production.\nUnitTemplate.additions.faSourceContract = {{\n    mapping = \"{0} -> {1}\",\n    sourceArchiveSha256 = \"{2}\",\n    sourceBlueprint = \"units/{3}/{4}_unit.bp\",\n    sourceBlueprintSha256 = \"{5}\",\n    sourceScript = \"units/{6}/{7}\",\n    sourceScriptSha256 = \"{8}\",\n    sourceVisionRadiusDeclared = {9},\n    resolvedSourceVisionRadius = {10},\n    sourceAdjacency = \"{11}\",\n    sanctuaryAdjacency = \"AlloyExtractorAdjacencyBuff\",\n    {12}\n    sourceProductionToggle = true,\n    sourcePumpAnimationMapped = true,\n    sourcePauseResumeAnimationSupported = true,\n    sourceEnergyStallAnimationSupported = true,\n    sourceUpgradeAnimationMapped = {13},\n    sourceAudioBanksImported = false,\n    sourceActiveLoopSupported = false,\n    donorRootPersistentLoopRetained = false,\n    sourceCommanderBuildCategoriesSupported = false,\n}}\nUnitTemplate.adjacency = \"AlloyExtractorAdjacencyBuff\"\nUnitTemplate.defence = UnitTemplate.defence or {{}}\nUnitTemplate.defence.health = {{ max = {14}, regen = 0, value = {15} }}\nUnitTemplate.economy = {{\n    buildTime = {16},\n    cost = {{ alloys = {17}, energy = {18} }},\n    maintenanceConsumption = {{ energy = {19} }},\n    production = {{ alloys = {20} }},\n}}\nUnitTemplate.intel = {{ visionRadius = {21} }}\nUnitTemplate.general.toggles = UnitTemplate.general.toggles or {{}}\nUnitTemplate.general.toggles.Production = true\n{22}\n-- FA declares no primary or death weapon for these extractors.\nUnitTemplate.weapons = nil\nlocal SCO_CombatDestroyedAudio = UnitTemplate.audio and UnitTemplate.audio.onDestroyed\nUnitTemplate.audio = SCO_CombatDestroyedAudio\n    and {{ onDestroyed = SCO_CombatDestroyedAudio }}\n    or nil", sourceId, targetId, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", sourceId, sourceId, sourceBlueprintSha256, sourceId, sourceScriptName, sourceScriptSha256, sourceVisionRadiusDeclared ? "true" : "false", visionRadius, sourceAdjacency, text2, (sourceUpgradesTo == null) ? "false" : "true", health, health, buildTime, alloys, energy, maintenanceEnergy, productionAlloys, visionRadius, text);
	}

	private static string RadarGameplayOverride(string sourceId, string targetId, string sourceBlueprintSha256, string sourceScriptName, string sourceScriptSha256, int health, int buildTime, int alloys, int energy, int maintenanceEnergy, int visionRadius, int radarRadius, int? sourceOmniRadius, int? sourceReactivateTime, int buildPower, string? sourceUpgradesTo, string? sanctuaryUpgradesTo, bool sourceUpgradeAnimationMapped, bool sourceRandomDishMotion, string rotatorsLua)
	{
		string text = ((sanctuaryUpgradesTo == null) ? "UnitTemplate.construction = nil" : $"UnitTemplate.construction = {{\n    buildPower = {buildPower},\n    canBuild = \"Tags.{sanctuaryUpgradesTo}\",\n    upgradesTo = \"{sanctuaryUpgradesTo}\",\n}}");
		string text2 = ((sourceUpgradesTo == null) ? "sourceUpgradesTo = nil,\n                sanctuaryUpgradesTo = nil," : ("sourceUpgradesTo = \"" + sourceUpgradesTo + "\",\nsanctuaryUpgradesTo = \"" + sanctuaryUpgradesTo + "\","));
		string text3 = (sourceOmniRadius.HasValue ? sourceOmniRadius.Value.ToString(CultureInfo.InvariantCulture) : "nil");
		string text4 = (sourceReactivateTime.HasValue ? sourceReactivateTime.Value.ToString(CultureInfo.InvariantCulture) : "nil");
		return string.Format("-- Exact FA radar health, economy, radar radius, and upgrade power.\nUnitTemplate.additions.faSourceContract = {{\n    mapping = \"{0} -> {1}\",\n    sourceArchiveSha256 = \"{2}\",\n    sourceBlueprint = \"units/{3}/{4}_unit.bp\",\n    sourceBlueprintSha256 = \"{5}\",\n    sourceScript = \"units/{6}/{7}\",\n    sourceScriptSha256 = \"{8}\",\n    {9}\n    sourceOmniRadius = {10},\n    sanctuaryOmniRadiusSupported = false,\n    sourceReactivateTime = {11},\n    sanctuaryReactivateTimeSupported = false,\n    sourceShowIntelOnSelect = true,\n    sanctuaryShowIntelOnSelectSupported = false,\n    sourceUpgradeAnimationMapped = {12},\n    sourceRandomDishMotion = {13},\n    sanctuaryRandomDishMotionSupported = false,\n    sourceRotatorAccelerationSupported = false,\n    radarStateRotatorGateSupported = true,\n    sourceEmitterGraphSupported = false,\n    sourceAudioBanksImported = false,\n    donorRootPersistentLoopRetained = false,\n    sourceCommanderBuildCategoriesSupported = false,\n}}\nUnitTemplate.defence = UnitTemplate.defence or {{}}\nUnitTemplate.defence.health = {{ max = {14}, regen = 0, value = {15} }}\nUnitTemplate.economy = {{\n    buildTime = {16},\n    cost = {{ alloys = {17}, energy = {18} }},\n    maintenanceConsumption = {{ energy = {19} }},\n}}\nUnitTemplate.intel = {{\n    radarRadius = {20},\n    visionRadius = {21},\n}}\nUnitTemplate.general.toggles = UnitTemplate.general.toggles or {{}}\nUnitTemplate.general.toggles.Intel = true\n{22}\n{23}\nlocal SCO_CombatDestroyedAudio = UnitTemplate.audio and UnitTemplate.audio.onDestroyed\nUnitTemplate.audio = SCO_CombatDestroyedAudio\n    and {{ onDestroyed = SCO_CombatDestroyedAudio }}\n    or nil", sourceId, targetId, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", sourceId, sourceId, sourceBlueprintSha256, sourceId, sourceScriptName, sourceScriptSha256, text2, text3, text4, sourceUpgradeAnimationMapped ? "true" : "false", sourceRandomDishMotion ? "true" : "false", health, health, buildTime, alloys, energy, maintenanceEnergy, radarRadius, visionRadius, text, rotatorsLua);
	}

	private static string DefenseGameplayOverride(string sourceId, string targetId, string sourceBlueprintSha256, string sourceScriptName, string sourceScriptSha256, int health, int buildTime, int alloys, int energy, int visionRadius, string sourceProjectile)
	{
		return string.Format("-- Exact FA defense health/economy/intel; the bounded defensive\n-- transaction below owns this unit's source weapon and projectile.\nUnitTemplate.additions.faSourceContract = {{\n    mapping = \"{0} -> {1}\",\n    sourceArchiveSha256 = \"{2}\",\n    sourceBlueprint = \"units/{3}/{4}_unit.bp\",\n    sourceBlueprintSha256 = \"{5}\",\n    sourceScript = \"units/{6}/{7}\",\n    sourceScriptSha256 = \"{8}\",\n    sourcePrimaryWeapon = \"{9}\",\n    sourceWeaponRuntimeParityApplied = true,\n    sourceWeaponAudioBanksImported = false,\n    donorWeaponOnFireFallbackRetained = true,\n    sourceWeaponEmitterGraphSupported = false,\n    donorRootPersistentLoopRetained = false,\n}}\nUnitTemplate.defence = UnitTemplate.defence or {{}}\nUnitTemplate.defence.health = {{ max = {10}, regen = 0, value = {11} }}\nUnitTemplate.economy = {{\n    buildTime = {12},\n    cost = {{ alloys = {13}, energy = {14} }},\n}}\nUnitTemplate.intel = {{ visionRadius = {15} }}\nlocal SCO_CombatDestroyedAudio = UnitTemplate.audio and UnitTemplate.audio.onDestroyed\nUnitTemplate.audio = SCO_CombatDestroyedAudio\n    and {{ onDestroyed = SCO_CombatDestroyedAudio }}\n    or nil", sourceId, targetId, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", sourceId, sourceId, sourceBlueprintSha256, sourceId, sourceScriptName, sourceScriptSha256, sourceProjectile, health, health, buildTime, alloys, energy, visionRadius);
	}

	public static void Apply()
	{
		ApplyVisualTemplateOverrides();
		CybranDefenseParityRuntime.Apply();
	}

	private static void ApplyVisualTemplateOverrides()
	{
		List<CachedResource> list = new List<CachedResource>(PatchSpecs.Length);
		object obj = null;
		bool flag = false;
		try
		{
			obj = GetLuaFileCache();
			PatchSpec[] patchSpecs = PatchSpecs;
			foreach (PatchSpec patchSpec in patchSpecs)
			{
				if (!TryGetCachedResource(obj, patchSpec, out CachedResource resource))
				{
					throw new FileNotFoundException("The required " + patchSpec.Description + " was not present in Sanctuary's Lua file cache.", patchSpec.RelativePath);
				}
				list.Add(resource);
			}
			int num = list.Count((CachedResource cachedResource) => ContainsOverride(cachedResource.Stock));
			if (num == list.Count)
			{
				Log("All 22 combat-structure templates already contain the visual override.");
				return;
			}
			if (num != 0)
			{
				throw new InvalidOperationException("A partial combat-structure cache override was found; the patcher will not mix cached template generations.");
			}
			foreach (CachedResource item in list)
			{
				item.Replacement = CreateReplacement(item.Stock, item.Spec);
				if (!ContainsOverride(item.Replacement))
				{
					throw new InvalidOperationException("The replacement " + item.Spec.Description + " did not retain its override marker.");
				}
			}
			foreach (CachedResource item2 in list)
			{
				item2.ReplacementWasAssigned = true;
				SetCachedResource(obj, item2.Path, item2.Replacement);
			}
			flag = true;
			foreach (CachedResource item3 in list)
			{
				TryDisposeNativeArray(item3.Stock.GetType(), item3.Stock, "stock " + item3.Spec.Description);
			}
			Log("Replaced 22 cache templates: six alloy extractors, six radars, and ten defense units.");
		}
		catch (Exception arg)
		{
			if (!flag)
			{
				if (obj != null)
				{
					RollBackAndDispose(obj, list);
				}
				else
				{
					foreach (CachedResource item4 in list)
					{
						if (item4.Replacement != null && IsNativeArrayCreated(item4.Replacement))
						{
							TryDisposeNativeArray(item4.Replacement.GetType(), item4.Replacement, "replacement " + item4.Spec.Description);
						}
					}
				}
			}
			Log($"Failed to replace the cached combat-structure templates: {arg}");
			throw;
		}
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static bool TryGetCachedResource(object cache, PatchSpec spec, out CachedResource resource)
	{
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string fullPath = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), spec.RelativePath));
		if ((bool)obj.Invoke(cache, new object[1] { fullPath }))
		{
			object obj2 = propertyInfo.GetValue(cache, new object[1] { fullPath }) ?? throw new InvalidOperationException("The cached " + spec.Description + " has no value.");
			if (!IsNativeArrayCreated(obj2))
			{
				throw new InvalidOperationException("The cached " + spec.Description + " is not an initialized NativeArray.");
			}
			resource = new CachedResource(spec, fullPath, obj2);
			return true;
		}
		string value = "/" + spec.RelativePath;
		string text = null;
		object obj3 = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			string text2 = (string)type2.GetProperty("Key")?.GetValue(item);
			if (text2 != null && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (text != null)
				{
					throw new InvalidOperationException("More than one cached resource matches the exact " + spec.RelativePath + " suffix.");
				}
				object obj4 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("The cached " + spec.Description + " has no value.");
				if (!IsNativeArrayCreated(obj4))
				{
					throw new InvalidOperationException("The cached " + spec.Description + " is not an initialized NativeArray.");
				}
				text = text2;
				obj3 = obj4;
			}
		}
		if (text == null || obj3 == null)
		{
			resource = null;
			return false;
		}
		resource = new CachedResource(spec, text, obj3);
		return true;
	}

	private static object CreateReplacement(object stockResource, PatchSpec spec)
	{
		Type type = stockResource.GetType();
		byte[] nativeArrayBytes = GetNativeArrayBytes(type, stockResource);
		string text = Encoding.UTF8.GetString(nativeArrayBytes).Replace("\r\n", "\n");
		byte[] bytes = Encoding.UTF8.GetBytes(text + spec.Appendix);
		return NativeArrayByteFactory.CreatePersistent(type, bytes);
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void RollBackAndDispose(object cache, IEnumerable<CachedResource> resources)
	{
		foreach (CachedResource item in resources.Reverse())
		{
			bool flag = !item.ReplacementWasAssigned;
			if (item.ReplacementWasAssigned)
			{
				try
				{
					SetCachedResource(cache, item.Path, item.Stock);
					flag = true;
				}
				catch (Exception arg)
				{
					Log($"Rollback failed for {item.Spec.Description}: {arg}");
				}
			}
			if (flag && item.Replacement != null && IsNativeArrayCreated(item.Replacement))
			{
				TryDisposeNativeArray(item.Replacement.GetType(), item.Replacement, "replacement " + item.Spec.Description);
			}
		}
	}

	private static byte[] GetNativeArrayBytes(Type nativeArrayType, object nativeArray)
	{
		return (byte[])(nativeArrayType.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "ToArray")).Invoke(nativeArray, null);
	}

	private static bool IsNativeArrayCreated(object nativeArray)
	{
		return (bool)(nativeArray.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(nativeArray.GetType().FullName, "IsCreated")).GetValue(nativeArray);
	}

	private static void TryDisposeNativeArray(Type nativeArrayType, object nativeArray, string description)
	{
		try
		{
			(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
		}
		catch (Exception arg)
		{
			Log($"Could not dispose {description}: {arg}");
		}
	}

	private static bool ContainsOverride(object resource)
	{
		if (IsNativeArrayCreated(resource))
		{
			return Encoding.UTF8.GetString(GetNativeArrayBytes(resource.GetType(), resource)).IndexOf("-- FA Combat Structures Cache Patcher 1.1.0", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	private static void ValidatePatchSpecs()
	{
		if (PatchSpecs.Length != 22)
		{
			throw new InvalidOperationException("Combat-structure patch count changed unexpectedly.");
		}
		if (PatchSpecs.Count((PatchSpec spec) => spec.Category == PatchCategory.AlloyExtractor) != 6 || PatchSpecs.Count((PatchSpec spec) => spec.Category == PatchCategory.Radar) != 6 || PatchSpecs.Count((PatchSpec spec) => spec.Category == PatchCategory.CombatDefense) != 10)
		{
			throw new InvalidOperationException("Combat-structure patch categories changed unexpectedly.");
		}
		IEnumerable<string> other = from spec in PatchSpecs
			where spec.Category == PatchCategory.AlloyExtractor
			select spec.TargetId;
		if (!ImportedAnimatedStructureTemplates.IsSupersetOf(other))
		{
			throw new InvalidOperationException("Every alloy extractor must retain its verified animation map.");
		}
		if (PatchSpecs.Select((PatchSpec spec) => spec.RelativePath).Distinct<string>(StringComparer.OrdinalIgnoreCase).Count() != PatchSpecs.Length)
		{
			throw new InvalidOperationException("Combat-structure patch paths must be unique.");
		}
		PatchSpec[] patchSpecs = PatchSpecs;
		foreach (PatchSpec patchSpec in patchSpecs)
		{
			string value = "/" + patchSpec.TargetId + "/" + patchSpec.TargetId + ".santp";
			if (!patchSpec.RelativePath.Replace('\\', '/').EndsWith(value, StringComparison.Ordinal))
			{
				throw new InvalidOperationException("The patch path for " + patchSpec.TargetId + " is not its exact template path.");
			}
			if (!Contains(patchSpec.Appendix, "UnitTemplate.collisionInfo") || !Contains(patchSpec.Appendix, "UnitTemplate.footprint") || !Contains(patchSpec.Appendix, "UnitTemplate.skirtSize") || !Contains(patchSpec.Appendix, "UnitTemplate.additions.tarmacSize") || !Contains(patchSpec.Appendix, "-- FA Combat Structures Cache Patcher 1.1.0"))
			{
				throw new InvalidOperationException("The " + patchSpec.TargetId + " visual override is incomplete.");
			}
			if (ImportedAnimatedStructureTemplates.Contains(patchSpec.TargetId) && Contains(patchSpec.Appendix, "UnitTemplate.visuals.animations = nil"))
			{
				throw new InvalidOperationException("The " + patchSpec.TargetId + " override erased its verified animation map.");
			}
			if (!ImportedAnimatedStructureTemplates.Contains(patchSpec.TargetId) && !Contains(patchSpec.Appendix, "UnitTemplate.visuals.animations = nil"))
			{
				throw new InvalidOperationException("The " + patchSpec.TargetId + " static rig override must clear incompatible animations.");
			}
			if (patchSpec.Category == PatchCategory.CombatDefense && (!Contains(patchSpec.Appendix, "combatWeapon.aimControllers") || !Contains(patchSpec.Appendix, "combatWeapon.muzzleGroups")))
			{
				throw new InvalidOperationException("The " + patchSpec.TargetId + " combat rig override is incomplete.");
			}
			foreach (string requiredAlias in patchSpec.RequiredAliases)
			{
				if (!Contains(patchSpec.Appendix, "\"" + requiredAlias + "\""))
				{
					throw new InvalidOperationException("The required " + patchSpec.TargetId + " muzzle alias " + requiredAlias + " is not declared in its Lua override.");
				}
			}
		}
	}

	private static bool Contains(string value, string expected)
	{
		return value.IndexOf(expected, StringComparison.Ordinal) >= 0;
	}

	private static void Log(string message)
	{
		string text = "[FA Combat Structures Cache Patcher] " + message;
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
