using System;

namespace SupremeCommanderOverhaulFieldFixes;

internal static class ConstructionBeamPalette
{
	private const string Marker = "-- SCOM private construction palette 1.0.2";

	private const string Root = "VFX/SCOM/ConstructionBeams/";

	private const string NativeRoot = "VFX/Materials/ConstructionBeams/";

	private const string AeonFactoryMaterial = "VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial";

	internal static string PatchUnitLoader(string source)
	{
		return source;
	}

	internal static string PatchFactoryBeams(string source)
	{
		source = PatchHelper(source, "local function GetCybranFactoryConstructionBeamPrefabID()", "function CybranFactoryConstructionBeamGroup:SetTarget", uef: false);
		source = PatchHelper(source, "local function GetEdaUefFactoryConstructionBeamPrefabID()", "function EdaUefFactoryConstructionBeamGroup:SetTarget", uef: true);
		source = PatchHelper(source, "local function SCOFaAirFactoryBeamMaterial(factory)", "function SCOFaAirFactoryBeamGroup:SetTarget", uef: true);
		source = PatchPrometheanFactoryException(source);
		return source;
	}

	private static string PatchPrometheanFactoryException(string source)
	{
		if (source.Contains("-- SCOM Promethean factory beam isolation 1.0.0"))
		{
			return source;
		}
		if (!source.Contains("local CybranFactoryConstructionBeamPrefabID = nil"))
		{
			return source;
		}
		source = ReplaceOnce(source, "local CybranFactoryConstructionBeamPrefabID = nil", "-- SCOM Promethean factory beam isolation 1.0.0\nlocal CybranFactoryConstructionBeamPrefabIDs = {}");
		int num = source.IndexOf("local function GetCybranFactoryConstructionBeamPrefabID()", StringComparison.Ordinal);
		int num2 = source.IndexOf("local function DisposeCybranFactoryConstructionBeam(factory)", num + "local function GetCybranFactoryConstructionBeamPrefabID()".Length, StringComparison.Ordinal);
		if (num < 0 || num2 < 0)
		{
			throw new InvalidOperationException("SCOM Promethean factory beam boundary changed.");
		}
		string source2 = source.Substring(num, num2 - num);
		source2 = ReplaceOnce(source2, "local function GetCybranFactoryConstructionBeamPrefabID()\n    if CybranFactoryConstructionBeamPrefabID then\n        return CybranFactoryConstructionBeamPrefabID\n    end", "local function GetCybranFactoryConstructionBeamPrefabID(materialPath)\n    local existing = CybranFactoryConstructionBeamPrefabIDs[materialPath]\n    if existing then\n        return existing\n    end");
		source2 = ReplaceOnce(source2, "local prefab = EngineClasses.PrefabTemplate(\"SupremeCommanderOverhaulCybranFactoryConstructionBeam\")", "local prefabName = materialPath == \"Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial\"\n        and \"SupremeCommanderOverhaulPrometheanFactoryConstructionBeam\"\n        or \"SupremeCommanderOverhaulCybranFactoryConstructionBeam\"\n    local prefab = EngineClasses.PrefabTemplate(prefabName)");
		source2 = ReplaceOnce(source2, "        \"VFX/SCOM/ConstructionBeams/cybran.sanmaterial\",", "        materialPath,");
		source2 = ReplaceOnce(source2, "    CybranFactoryConstructionBeamPrefabID = prefabID\n    return prefabID", "    CybranFactoryConstructionBeamPrefabIDs[materialPath] = prefabID\n    return prefabID");
		source2 = ReplaceOnce(source2, "local function CreateCybranFactoryConstructionBeamGroup(factory, boneNames)\n    local prefabID = GetCybranFactoryConstructionBeamPrefabID()", "local function CreateCybranFactoryConstructionBeamGroup(factory, boneNames)\n    local materialPath = factory:HasTags(Tags.PROMETHEAN)\n        and \"Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial\"\n        or \"VFX/SCOM/ConstructionBeams/cybran.sanmaterial\"\n    local prefabID = GetCybranFactoryConstructionBeamPrefabID(materialPath)");
		return source.Substring(0, num) + source2 + source.Substring(num2);
	}

	private static string ReplaceOnce(string source, string original, string replacement)
	{
		int num = source.IndexOf(original, StringComparison.Ordinal);
		if (num < 0 || source.IndexOf(original, num + original.Length, StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("SCOM factory palette boundary changed: " + original);
		}
		return source.Substring(0, num) + replacement + source.Substring(num + original.Length);
	}

	private static string PatchHelper(string source, string start, string end, bool uef)
	{
		int num = source.IndexOf(start, StringComparison.Ordinal);
		if (num < 0)
		{
			return source;
		}
		int num2 = source.IndexOf(end, num + start.Length, StringComparison.Ordinal);
		if (num2 < 0)
		{
			throw new InvalidOperationException("SCOM factory beam helper boundary changed: " + start);
		}
		string text = source.Substring(num, num2 - num).Replace("VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial", "VFX/SCOM/ConstructionBeams/cybran.sanmaterial");
		if (uef)
		{
			text = text.Replace("VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial", "VFX/SCOM/ConstructionBeams/uef.sanmaterial");
		}
		if (!text.Contains("VFX/SCOM/ConstructionBeams/"))
		{
			throw new InvalidOperationException("SCOM factory beam material changed: " + start);
		}
		return source.Substring(0, num) + text + source.Substring(num2);
	}
}
