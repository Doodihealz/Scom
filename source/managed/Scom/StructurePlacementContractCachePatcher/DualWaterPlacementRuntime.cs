using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace StructurePlacementContractCachePatcher;

internal static class DualWaterPlacementRuntime
{
	private const string Marker = "-- Supreme Commander Overhaul dual land-water structures 1.0.0";

	private static readonly HashSet<string> Targets = new HashSet<string>(StringComparer.Ordinal)
	{
		"ugs1201", "ugs2201", "ugs3201", "ues1201", "ues2201", "ues3201", "uss1201", "uss2201", "uss2402", "uss3201",
		"ucs1201", "ucs2201", "ucs2402", "ucs3201"
	};

	private static readonly Dictionary<string, string> AeonSources = new Dictionary<string, string>(StringComparer.Ordinal)
	{
		["ucs1201"] = "UAB2104",
		["ucs2201"] = "UAB2204",
		["ucs2402"] = "UAB4201",
		["ucs3201"] = "UAB2304"
	};

	private static readonly string[] ResourcePaths = new string[8] { "LJ/lua/common/layers.lua", "LJ/lua/common/systems/placementUtils.lua", "LJ/lua/host/managers/orders/orderClasses/hostBuildOrder.lua", "LJ/lua/client/input/constructionPreviewSystem.lua", "LJ/lua/common/units/unitsTemplates/ucs1201/ucs1201.santp", "LJ/lua/common/units/unitsTemplates/ucs2201/ucs2201.santp", "LJ/lua/common/units/unitsTemplates/ucs2402/ucs2402.santp", "LJ/lua/common/units/unitsTemplates/ucs3201/ucs3201.santp" };

	internal static bool IsTarget(string id)
	{
		return Targets.Contains(id);
	}

	internal static void Apply()
	{
		if (Targets.Count != 14 || AeonSources.Count != 4 || ResourcePaths.Length != 8)
		{
			throw new InvalidOperationException("The source-backed dual land-water structure manifest changed.");
		}
		foreach (string target in Targets)
		{
			int num = 0;
			PlacementSpec[] specs = StructurePlacementManifest.Specs;
			for (int i = 0; i < specs.Length; i++)
			{
				if (specs[i].TargetId == target)
				{
					num++;
				}
			}
			if (num != ((!AeonSources.ContainsKey(target)) ? 1 : 0))
			{
				throw new InvalidOperationException("The dual placement target lost its source route: " + target);
			}
		}
		object cache = GetCache();
		string[] array = new string[ResourcePaths.Length];
		object[] array2 = new object[ResourcePaths.Length];
		object[] array3 = new object[ResourcePaths.Length];
		bool[] array4 = new bool[ResourcePaths.Length];
		for (int j = 0; j < ResourcePaths.Length; j++)
		{
			FindResource(cache, ResourcePaths[j], out array[j], out array2[j]);
		}
		int num2 = 0;
		object[] array5 = array2;
		for (int i = 0; i < array5.Length; i++)
		{
			if (Read(array5[i]).Contains("-- Supreme Commander Overhaul dual land-water structures 1.0.0"))
			{
				num2++;
			}
		}
		if (num2 == ResourcePaths.Length)
		{
			for (int k = 0; k < ResourcePaths.Length; k++)
			{
				ValidateMarked(Read(array2[k]), ResourcePaths[k]);
			}
			return;
		}
		if (num2 != 0)
		{
			throw new InvalidOperationException("The dual land-water placement cache is partially marked.");
		}
		try
		{
			for (int l = 0; l < ResourcePaths.Length; l++)
			{
				string text = Transform(ResourcePaths[l], Read(array2[l]));
				ValidateMarked(text, ResourcePaths[l]);
				array3[l] = NativeArrayByteFactory.CreatePersistent(array2[l].GetType(), Encoding.UTF8.GetBytes(text));
			}
			for (int m = 0; m < ResourcePaths.Length; m++)
			{
				array4[m] = true;
				Set(cache, array[m], array3[m]);
				if (!Read(Get(cache, array[m])).Equals(Read(array3[m]), StringComparison.Ordinal))
				{
					throw new InvalidOperationException("Dual placement cache byte verification failed at " + array[m]);
				}
			}
		}
		catch (Exception item)
		{
			List<Exception> list = new List<Exception>();
			for (int num3 = ResourcePaths.Length - 1; num3 >= 0; num3--)
			{
				if (array4[num3])
				{
					try
					{
						Set(cache, array[num3], array2[num3]);
						if (!Read(Get(cache, array[num3])).Equals(Read(array2[num3]), StringComparison.Ordinal))
						{
							throw new InvalidOperationException("Restored cache bytes differ.");
						}
					}
					catch (Exception innerException)
					{
						list.Add(new InvalidOperationException("Dual placement cache rollback failed at " + array[num3], innerException));
						continue;
					}
				}
				if (array3[num3] != null)
				{
					TryDispose(array3[num3]);
				}
			}
			if (list.Count != 0)
			{
				List<Exception> list2 = new List<Exception> { item };
				list2.AddRange(list);
				throw new AggregateException("Dual placement cache mutation and rollback both failed.", list2);
			}
			throw;
		}
		array5 = array2;
		for (int i = 0; i < array5.Length; i++)
		{
			TryDispose(array5[i]);
		}
	}

	private static string Transform(string path, string source)
	{
		switch (path)
		{
		case "LJ/lua/common/layers.lua":
			return TransformLayers(source);
		case "LJ/lua/common/systems/placementUtils.lua":
			return TransformPlacementUtils(source);
		case "LJ/lua/host/managers/orders/orderClasses/hostBuildOrder.lua":
			return TransformHostBuildOrder(source);
		case "LJ/lua/client/input/constructionPreviewSystem.lua":
			return TransformClientPreview(source);
		default:
			foreach (KeyValuePair<string, string> aeonSource in AeonSources)
			{
				if (path == "LJ/lua/common/units/unitsTemplates/" + aeonSource.Key + "/" + aeonSource.Key + ".santp")
				{
					return TransformAeonTemplate(source, aeonSource.Key, aeonSource.Value);
				}
			}
			throw new InvalidOperationException("Unknown dual placement resource " + path);
		}
	}

	private static string TransformLayers(string source)
	{
		source = Normalize(source);
		source = ReplaceOnce(source, "function GetPlacementDomainFromTemplate(tp)\n    if Tags.NAVAL[tp.general.tpId] and not Tags.NAVAL_TECH_CENTRE[tp.general.tpId] then", "function GetPlacementDomainFromTemplate(tp)\n    if tp.general.faDualWaterPlacement == true then\n        return PlacementDomain.Any\n    end\n    if Tags.NAVAL[tp.general.tpId] and not Tags.NAVAL_TECH_CENTRE[tp.general.tpId] then");
		return source + "\n-- Supreme Commander Overhaul dual land-water structures 1.0.0\n";
	}

	private static string TransformPlacementUtils(string source)
	{
		source = Normalize(source);
		source = ReplaceOnce(source, "    elseif domain ~= PlacementDomain.Any then\n        if bit.band(flags, PlacementLayer.InvalidTerrain) ~= 0 then", "    elseif domain == PlacementDomain.Any then\n        if bit.band(flags, PlacementLayer.InvalidTerrain) ~= 0\n            and bit.band(flags, PlacementLayer.Water) == 0 then\n            return false\n        end\n    else\n        if bit.band(flags, PlacementLayer.InvalidTerrain) ~= 0 then");
		source = ReplaceOnce(source, "function GetPlacementHeight(tp, x, z)\n", "--- Classify an FA land-water structure's entire build skirt. A shallow or\n--- shoreline-straddling footprint has no valid height and must be rejected.\nfunction GetDualPlacementSurface(tp, x, z)\n    if not (tp and tp.general and tp.general.faDualWaterPlacement == true) then\n        return nil\n    end\n\n    local waterError, hasWater = Engine.HasWater()\n    if waterError ~= EngineErrorCode.Success then return nil end\n    if not hasWater then return PlacementDomain.Land end\n    local levelError, waterLevel = Engine.GetWaterLevel()\n    if levelError ~= EngineErrorCode.Success or waterLevel == nil then return nil end\n\n    local minX, minZ, maxX, maxZ = GetPlacementBounds(\n        { x = x, z = z }, tp.skirtSize)\n    local allLand, allWater = true, true\n    for cellX = minX, maxX + 1 do\n        for cellZ = minZ, maxZ + 1 do\n            local errorCode, terrainHeight = Engine.SampleTerrainHeightFromCell(\n                EngineClasses.int2(cellX, cellZ))\n            if errorCode ~= EngineErrorCode.Success or terrainHeight == nil then\n                return nil\n            end\n            if terrainHeight < waterLevel then allLand = false end\n            if terrainHeight > waterLevel - 1 then allWater = false end\n        end\n    end\n    if allWater then return PlacementDomain.Water end\n    if allLand then return PlacementDomain.Land end\n    return nil\nend\n\nfunction GetPlacementHeight(tp, x, z)\n");
		source = ReplaceOnce(source, "    if GetPlacementDomain(tp) == PlacementDomain.Water then\n", "    if GetPlacementDomain(tp) == PlacementDomain.Water\n        or GetDualPlacementSurface(tp, x, z) == PlacementDomain.Water then\n");
		source = ReplaceOnce(source, "    GetPlacementDomain = GetPlacementDomain,\n    GetPlacementHeight = GetPlacementHeight", "    GetPlacementDomain = GetPlacementDomain,\n    GetDualPlacementSurface = GetDualPlacementSurface,\n    GetPlacementHeight = GetPlacementHeight");
		return source + "\n-- Supreme Commander Overhaul dual land-water structures 1.0.0\n";
	}

	private static string TransformHostBuildOrder(string source)
	{
		source = ReplaceOnce(Normalize(source), "    local domain = PlacementUtils.GetPlacementDomain(self.tp)\n\n    for _, gridQueryResult in ipairs(results) do", "    local domain = PlacementUtils.GetPlacementDomain(self.tp)\n    if self.tp.general.faDualWaterPlacement == true\n        and not PlacementUtils.GetDualPlacementSurface(\n            self.tp, self.positionFloat3.x, self.positionFloat3.z) then\n        return false\n    end\n\n    for _, gridQueryResult in ipairs(results) do");
		return source + "\n-- Supreme Commander Overhaul dual land-water structures 1.0.0\n";
	}

	private static string TransformClientPreview(string source)
	{
		source = Normalize(source);
		source = ReplaceOnce(source, "function CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, tp, position)\n", "function CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, tp, position)\n    if tp and tp.general.faDualWaterPlacement == true\n        and (not position or not PlacementUtils.GetDualPlacementSurface(tp, position.x, position.z)) then\n        return false\n    end\n");
		source = ReplaceOnce(source, "            local hasInvalidCells = false\n", "            local dualSiteIsValid = unitTemplate.general.faDualWaterPlacement ~= true\n                or PlacementUtils.GetDualPlacementSurface(unitTemplate, position.x, position.z) ~= nil\n            local hasInvalidCells = false\n");
		source = ReplaceOnce(source, "                    cellIsValid[x][y] = isValid\n", "                    isValid = isValid and dualSiteIsValid\n                    cellIsValid[x][y] = isValid\n");
		return source + "\n-- Supreme Commander Overhaul dual land-water structures 1.0.0\n";
	}

	private static string TransformAeonTemplate(string source, string id, string sourceId)
	{
		source = Normalize(source);
		if (Count(source, "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0") != 1 || Count(source, "sourceId = \"" + sourceId + "\"") != 1 || Count(source, "UnitTemplate.general.faDualWaterPlacement") != 0)
		{
			throw new InvalidOperationException("Aeon dual placement source changed for " + id + " <- " + sourceId);
		}
		return source + "\n-- Supreme Commander Overhaul dual land-water structures 1.0.0\n-- " + id + " <- " + sourceId + "; Physics.BuildOnLayerCaps Land+Water; Footprint.MinWaterDepth=1.\nUnitTemplate.general.faDualWaterPlacement = true\n";
	}

	private static void ValidateMarked(string source, string path)
	{
		if (Count(source, "-- Supreme Commander Overhaul dual land-water structures 1.0.0") != 1)
		{
			throw new InvalidOperationException("Dual placement marker count changed in " + path);
		}
		foreach (KeyValuePair<string, string> aeonSource in AeonSources)
		{
			if (path == "LJ/lua/common/units/unitsTemplates/" + aeonSource.Key + "/" + aeonSource.Key + ".santp")
			{
				if (Count(source, "-- " + aeonSource.Key + " <- " + aeonSource.Value + "; Physics.BuildOnLayerCaps Land+Water; Footprint.MinWaterDepth=1.") != 1 || Count(source, "UnitTemplate.general.faDualWaterPlacement = true") != 1 || Count(source, "sourceId = \"" + aeonSource.Value + "\"") != 1)
				{
					throw new InvalidOperationException("Aeon dual placement contract changed in " + path);
				}
				return;
			}
		}
		string[] array = path switch
		{
			"LJ/lua/common/layers.lua" => new string[2] { "if tp.general.faDualWaterPlacement == true then", "return PlacementDomain.Any" }, 
			"LJ/lua/common/systems/placementUtils.lua" => new string[6] { "elseif domain == PlacementDomain.Any then", "function GetDualPlacementSurface(tp, x, z)", "if terrainHeight > waterLevel - 1 then allWater = false end", "if allLand then return PlacementDomain.Land end", "or GetDualPlacementSurface(tp, x, z) == PlacementDomain.Water then", "GetDualPlacementSurface = GetDualPlacementSurface" }, 
			"LJ/lua/host/managers/orders/orderClasses/hostBuildOrder.lua" => new string[2] { "self.tp.general.faDualWaterPlacement == true", "self.tp, self.positionFloat3.x, self.positionFloat3.z" }, 
			"LJ/lua/client/input/constructionPreviewSystem.lua" => new string[4] { "tp.general.faDualWaterPlacement == true", "if includeInvalid or (CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, unitTemplate, point) and OverhaulFactoryPlacementReservationsAreClear(point, unitTemplate)) then", "local dualSiteIsValid =", "isValid = isValid and dualSiteIsValid" }, 
			_ => throw new InvalidOperationException("Unknown dual placement resource " + path), 
		};
		foreach (string text in array)
		{
			if (Count(source, text) != 1)
			{
				throw new InvalidOperationException("Dual placement consumer changed in " + path + ": " + text);
			}
		}
	}

	private static string ReplaceOnce(string source, string oldText, string newText)
	{
		if (Count(source, oldText) != 1)
		{
			throw new InvalidOperationException("Expected one native placement token: " + oldText.Split(new char[1] { '\n' })[0]);
		}
		return source.Replace(oldText, newText);
	}

	private static int Count(string source, string token)
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

	private static string Normalize(string source)
	{
		return source.Replace("\r\n", "\n");
	}

	private static object GetCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static void FindResource(object cache, string relativePath, out string resolvedPath, out object stock)
	{
		resolvedPath = null;
		stock = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type = item.GetType();
			if (type.GetProperty("Key")?.GetValue(item) is string text && text.Replace('\\', '/').EndsWith("/" + relativePath, StringComparison.OrdinalIgnoreCase))
			{
				if (resolvedPath != null)
				{
					throw new InvalidOperationException("Duplicate cached placement resource " + relativePath);
				}
				object obj = type.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("Null cached placement resource " + relativePath);
				resolvedPath = text;
				stock = obj;
			}
		}
		if (resolvedPath == null)
		{
			throw new InvalidOperationException("Missing cached placement resource " + relativePath);
		}
	}

	private static object Get(object cache, string path)
	{
		return (cache.GetType().GetProperty("Item") ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("Null cached placement resource " + path);
	}

	private static void Set(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item") ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static string Read(object resource)
	{
		return Encoding.UTF8.GetString((byte[])(resource.GetType().GetMethod("ToArray", Type.EmptyTypes) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null));
	}

	private static void TryDispose(object resource)
	{
		try
		{
			(resource.GetType().GetMethod("Dispose", Type.EmptyTypes) ?? throw new MissingMethodException(resource.GetType().FullName, "Dispose")).Invoke(resource, null);
		}
		catch (Exception ex)
		{
			Console.WriteLine("[Structure Placement] NativeArray cleanup warning: " + ex.GetBaseException().Message);
		}
	}
}
