using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulCanonical;

public static class LargeMapPlacementGridCompat
{
	private sealed class CachedResource
	{
		public string Path { get; }

		public object Value { get; }

		public CachedResource(string path, object value)
		{
			Path = path;
			Value = value;
		}
	}

	private sealed class CacheEdit
	{
		public CachedResource Resource { get; }

		public string OriginalText { get; }

		public string PatchedText { get; }

		public string Description { get; }

		public bool Changed => !string.Equals(OriginalText, PatchedText, StringComparison.Ordinal);

		public object? Replacement { get; set; }

		public bool Assigned { get; set; }

		public CacheEdit(CachedResource resource, string originalText, string patchedText, string description)
		{
			Resource = resource;
			OriginalText = originalText;
			PatchedText = patchedText;
			Description = description;
		}
	}

	public const string Marker = "-- SCOM Large Map Load Compat: placement grid 1.0.1";

	public const string InitializationMarker = "-- SCOM Large Map Load Compat: client initialization ordering 1.0.0";

	private const string ScriptPath = "LJ/lua/script.lua";

	private const string GameUtilsPath = "LJ/lua/common/gameUtils.lua";

	private const string FieldFixApply = "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::Apply()";

	private const string OwnApply = "System.Void SupremeCommanderOverhaulCanonical.LargeMapPlacementGridCompat::Apply()";

	private const string FileReadAllBytes = "System.Byte[] System.IO.File::ReadAllBytes(System.String)";

	private const string OwnRootScriptReader = "System.Byte[] SupremeCommanderOverhaulCanonical.LargeMapPlacementGridCompat::ReadCachedRootScript(System.String)";

	private const string StockHostArmyPrelude = "        Import(\"host/managers/targeting/targeterManager.lua\")\n        Import(\"common/gameUtils.lua\").CreateArmies()";

	private const string OrderedHostArmyPrelude = "        Import(\"host/managers/targeting/targeterManager.lua\")\n        local GameUtils = Import(\"common/gameUtils.lua\")\n        GameUtils.CreateArmies(true)";

	private const string StockHostStartLine = "        Import(\"host/hostMain.lua\").Start()";

	private const string OrderedHostStartBlock = "        -- SCOM Large Map Load Compat: client initialization ordering 1.0.0\n        -- Armies and relationships must reach the client before focus initialization.\n        -- Initial units must wait until InitClient registers the map's prop prefabs.\n        GameUtils.SpawnInitialUnits()\n        Import(\"host/hostMain.lua\").Start()";

	private const string StockCreateArmiesSignature = "---@return nil\nfunction CreateArmies()";

	private const string DeferredCreateArmiesSignature = "-- SCOM Large Map Load Compat: deferred initial units 1.0.0\n---@param deferInitialUnits? boolean When true, the caller must invoke SpawnInitialUnits after client initialization is queued.\n---@return nil\nfunction CreateArmies(deferInitialUnits)";

	private const string DeferredInitialUnitsMarker = "-- SCOM Large Map Load Compat: deferred initial units 1.0.0";

	private const string StockCreateArmiesTail = "    SpawnInitialUnits()\nend\n\n---Returns the lobby options table if the (debug) file exists.";

	private const string DeferredCreateArmiesTail = "    if not deferInitialUnits then\n        SpawnInitialUnits()\n    end\nend\n\n---Returns the lobby options table if the (debug) file exists.";

	public const string NativeDepthAwarePlacementGridBlock = "local function GetCellWaterFlags(x, y, waterLevel, depth)\n    local deepThreshold = waterLevel - depth\n    local isPartialWater = false\n    local isDeepWater = true\n\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success then\n                if height < waterLevel then\n                    isPartialWater = true\n                end\n                if height > deepThreshold then\n                    isDeepWater = false\n                end\n            else\n                isDeepWater = false\n            end\n        end\n    end\n\n    return isPartialWater, isDeepWater\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local NavalPlacementDepth = Import(\"common/systems/placementUtils.lua\").NavalPlacementDepth\n    local Water = Import(\"common/water.lua\")\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local hasWater = Water.HasWater()\n    local waterLevel = Water.GetLevel()\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n\n            local isPartialWater, isDeepWater = false, false\n            if hasWater then\n                isPartialWater, isDeepWater = GetCellWaterFlags(x, y, waterLevel, NavalPlacementDepth)\n            end\n\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep or isPartialWater)\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, isDeepWater)\n        end\n    end\nend";

	private const string StockPlacementGridBlock = "--- Returns true if any corner of the heightmap cell at (x, y) is below the water level.\nlocal function IsCellUnderwater(x, y, waterLevel)\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success and height < waterLevel then\n                return true\n            end\n        end\n    end\n    return false\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local _, hasWater = Engine.HasWater()\n    local waterLevel\n    if hasWater then\n        _, waterLevel = Engine.GetWaterLevel()\n    end\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep)\n\n            if hasWater then\n                setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, IsCellUnderwater(x, y, waterLevel))\n            end\n        end\n    end\nend";

	private const string OptimizedPlacementGridBlock = "--- Returns true if any corner of the heightmap cell at (x, y) is below the water level.\nlocal function IsCellUnderwater(x, y, waterLevel)\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success and height < waterLevel then\n                return true\n            end\n        end\n    end\n    return false\nend\n\n-- SCOM Large Map Load Compat: placement grid 1.0.1\n-- Preserve Sanctuary's exact terrain-normal result while batching grid writes and\n-- sampling each water vertex once instead of up to four times per adjacent cell.\nlocal function SCOMSampleWaterColumn(column, x, mapSizeY, waterLevel, coordinate)\n    coordinate.x = x\n    for y = 1, mapSizeY do\n        coordinate.y = y\n        local errorCode, height = Engine.SampleTerrainHeightFromCell(coordinate)\n        column[y] = errorCode == EngineErrorCode.Success and height < waterLevel\n    end\nend\n\nlocal function SCOMSetPlacementRun(\n    setCellBaseFlags, gridID, x, firstY, lastY, flags, runMin, runMax)\n    runMin.x = x\n    runMin.y = firstY\n    runMax.x = x\n    runMax.y = lastY\n    setCellBaseFlags(gridID, runMin, runMax, flags, true)\nend\n\nlocal function SCOMInitializeLargePlacementGrid(\n    setCellBaseFlags, gridID, PlacementLayer, mapSizeX, mapSizeY,\n    steepnessThreshold, hasWater, waterLevel)\n    local lastX = mapSizeX - 1\n    local lastY = mapSizeY - 1\n    local clearMin = EngineClasses.int2(1, 1)\n    local clearMax = EngineClasses.int2(1, lastY)\n    local targetFlags = PlacementLayer.InvalidTerrain\n    if hasWater then\n        targetFlags = targetFlags + PlacementLayer.Water\n    end\n\n    local coordinate = EngineClasses.int2(1, 1)\n    local firstNormal = {}\n    local secondNormal = {}\n    local runMin = EngineClasses.int2(1, 1)\n    local runMax = EngineClasses.int2(1, 1)\n    local columnFlags = {}\n    local currentWaterColumn\n    local nextWaterColumn\n    if hasWater then\n        currentWaterColumn = {}\n        nextWaterColumn = {}\n        SCOMSampleWaterColumn(\n            currentWaterColumn, 1, mapSizeY, waterLevel, coordinate)\n        SCOMSampleWaterColumn(\n            nextWaterColumn, 2, mapSizeY, waterLevel, coordinate)\n    end\n\n    for x = 1, lastX do\n        for y = 1, lastY do\n            coordinate.x = x\n            coordinate.y = y\n            Engine.SampleTerrainNormals(coordinate, firstNormal, secondNormal)\n\n            local cellFlags = 0\n            if firstNormal.y < steepnessThreshold\n                or secondNormal.y < steepnessThreshold\n            then\n                cellFlags = PlacementLayer.InvalidTerrain\n            end\n            if hasWater and (\n                currentWaterColumn[y]\n                or currentWaterColumn[y + 1]\n                or nextWaterColumn[y]\n                or nextWaterColumn[y + 1])\n            then\n                cellFlags = cellFlags + PlacementLayer.Water\n            end\n            columnFlags[y] = cellFlags\n        end\n\n        -- Classify the complete column before its first destructive write. A\n        -- sampling failure therefore cannot clear unclassified map columns.\n        clearMin.x = x\n        clearMax.x = x\n        setCellBaseFlags(gridID, clearMin, clearMax, targetFlags, false)\n\n        local runFlags = 0\n        local runStart\n        for y = 1, lastY do\n            local cellFlags = columnFlags[y]\n            if cellFlags ~= runFlags then\n                if runFlags ~= 0 then\n                    SCOMSetPlacementRun(\n                        setCellBaseFlags, gridID, x, runStart, y - 1,\n                        runFlags, runMin, runMax)\n                end\n                runFlags = cellFlags\n                runStart = cellFlags ~= 0 and y or nil\n            end\n        end\n        if runFlags ~= 0 then\n            SCOMSetPlacementRun(\n                setCellBaseFlags, gridID, x, runStart, lastY,\n                runFlags, runMin, runMax)\n        end\n\n        if hasWater and x < lastX then\n            currentWaterColumn, nextWaterColumn =\n                nextWaterColumn, currentWaterColumn\n            SCOMSampleWaterColumn(\n                nextWaterColumn, x + 2, mapSizeY, waterLevel, coordinate)\n        end\n    end\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local _, hasWater = Engine.HasWater()\n    local waterLevel\n    if hasWater then\n        _, waterLevel = Engine.GetWaterLevel()\n    end\n\n    if (mapSizeX >= 2048 or mapSizeY >= 2048)\n        and mapSizeX > 1 and mapSizeY > 1\n    then\n        local side = IsHost and \"Host\" or \"Client\"\n        Engine.Log(\"[SCOM Large Map Load Compat] \" .. side\n            .. \" placement-grid optimization begin \"\n            .. mapSizeX .. \"x\" .. mapSizeY .. \".\")\n        SCOMInitializeLargePlacementGrid(\n            setCellBaseFlags, gridID, PlacementLayer, mapSizeX, mapSizeY,\n            steepnessThreshold, hasWater, waterLevel)\n        Engine.Log(\"[SCOM Large Map Load Compat] \" .. side\n            .. \" placement-grid optimization completed \"\n            .. mapSizeX .. \"x\" .. mapSizeY .. \".\")\n        return\n    end\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep)\n\n            if hasWater then\n                setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, IsCellUnderwater(x, y, waterLevel))\n            end\n        end\n    end\nend";

	internal static void Install(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		MethodDefinition methodDefinition = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache").Methods.Single((MethodDefinition methodDefinition2) => methodDefinition2.Name == "CreateFileCache" && methodDefinition2.IsStatic && methodDefinition2.Parameters.Count == 0 && methodDefinition2.HasBody);
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction[] array = instructions.Where((Instruction instruction2) => IsCallTo(instruction2, "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::Apply()")).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException("Large-map placement optimization requires exactly one final Field Fixes cache callback.");
		}
		Instruction[] array2 = instructions.Where((Instruction instruction2) => IsCallTo(instruction2, "System.Void SupremeCommanderOverhaulCanonical.LargeMapPlacementGridCompat::Apply()")).ToArray();
		if (array2.Length == 0)
		{
			MethodInfo method = typeof(LargeMapPlacementGridCompat).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(typeof(LargeMapPlacementGridCompat).FullName, "Apply");
			MethodReference method2 = assembly.MainModule.ImportReference(method);
			Instruction instruction = Instruction.Create(OpCodes.Call, method2);
			methodDefinition.Body.GetILProcessor().InsertAfter(array[0], instruction);
			array2 = new Instruction[1] { instruction };
		}
		if (array2.Length != 1 || array2[0].Previous != array[0])
		{
			throw new InvalidOperationException("Large-map placement optimization callback is missing, duplicated, or out of order.");
		}
		InstallRootScriptCacheReader(assembly);
	}

	private static void InstallRootScriptCacheReader(AssemblyDefinition assembly)
	{
		Collection<Instruction> instructions = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.Lua.LuaInterface").Methods.Single((MethodDefinition methodDefinition) => methodDefinition.Name == "InitLuaState" && methodDefinition.IsStatic && methodDefinition.Parameters.Count == 3 && methodDefinition.HasBody).Body.Instructions;
		Instruction[] array = instructions.Where((Instruction instruction) => IsCallTo(instruction, "System.Byte[] SupremeCommanderOverhaulCanonical.LargeMapPlacementGridCompat::ReadCachedRootScript(System.String)")).ToArray();
		if (array.Length == 0)
		{
			Instruction[] array2 = instructions.Where((Instruction instruction) => IsCallTo(instruction, "System.Byte[] System.IO.File::ReadAllBytes(System.String)")).ToArray();
			if (array2.Length != 2)
			{
				throw new InvalidOperationException("Root-script cache routing requires exactly two stock file reads in LuaInterface.InitLuaState.");
			}
			MethodInfo method = typeof(LargeMapPlacementGridCompat).GetMethod("ReadCachedRootScript", BindingFlags.Static | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(typeof(LargeMapPlacementGridCompat).FullName, "ReadCachedRootScript");
			array2[1].Operand = assembly.MainModule.ImportReference(method);
			array = new Instruction[1] { array2[1] };
		}
		Instruction[] array3 = instructions.Where((Instruction instruction) => IsCallTo(instruction, "System.Byte[] System.IO.File::ReadAllBytes(System.String)")).ToArray();
		if (array.Length != 1 || array3.Length != 1 || instructions.IndexOf(array3[0]) >= instructions.IndexOf(array[0]))
		{
			throw new InvalidOperationException("Root script is not routed exactly once through the verified Lua cache after the stock bootstrap read.");
		}
	}

	public static void Apply()
	{
		object obj = null;
		CacheEdit[] array = Array.Empty<CacheEdit>();
		try
		{
			obj = GetLuaFileCache();
			CachedResource cachedResource = GetCachedResource(obj, "LJ/lua/script.lua");
			string text = ReadText(cachedResource.Value);
			CachedResource cachedResource2 = GetCachedResource(obj, "LJ/lua/common/gameUtils.lua");
			string text2 = ReadText(cachedResource2.Value);
			array = new CacheEdit[2]
			{
				new CacheEdit(cachedResource, text, TransformForVerification(text), "script.lua"),
				new CacheEdit(cachedResource2, text2, TransformGameUtilsForVerification(text2), "common/gameUtils.lua")
			}.Where((CacheEdit edit) => edit.Changed).ToArray();
			if (array.Length == 0)
			{
				Log("Large-map placement-grid and client-initialization compatibility are already active.");
				return;
			}
			CacheEdit[] array2 = array;
			foreach (CacheEdit cacheEdit in array2)
			{
				cacheEdit.Replacement = CreateNativeArray(cacheEdit.Resource.Value.GetType(), cacheEdit.PatchedText);
			}
			array2 = array;
			foreach (CacheEdit cacheEdit2 in array2)
			{
				cacheEdit2.Assigned = true;
				SetCachedResource(obj, cacheEdit2.Resource.Path, cacheEdit2.Replacement);
				if (!string.Equals(ReadText(GetExactCachedResource(obj, cacheEdit2.Resource.Path)), cacheEdit2.PatchedText, StringComparison.Ordinal))
				{
					throw new InvalidOperationException("Large-map compatibility cache write verification failed for " + cacheEdit2.Description + ".");
				}
			}
			array2 = array;
			foreach (CacheEdit cacheEdit3 in array2)
			{
				TryDispose(cacheEdit3.Resource.Value, "replaced stock " + cacheEdit3.Description);
			}
			Log("Committed verified placement-grid handling and ordered client initialization.");
		}
		catch (Exception ex)
		{
			List<Exception> list = new List<Exception>();
			if (obj != null)
			{
				for (int num2 = array.Length - 1; num2 >= 0; num2--)
				{
					CacheEdit cacheEdit4 = array[num2];
					if (cacheEdit4.Assigned)
					{
						try
						{
							SetCachedResource(obj, cacheEdit4.Resource.Path, cacheEdit4.Resource.Value);
							if (!string.Equals(ReadText(GetExactCachedResource(obj, cacheEdit4.Resource.Path)), cacheEdit4.OriginalText, StringComparison.Ordinal))
							{
								throw new InvalidOperationException("Large-map compatibility cache rollback verification failed for " + cacheEdit4.Description + ".");
							}
							cacheEdit4.Assigned = false;
						}
						catch (Exception item)
						{
							list.Add(item);
						}
					}
				}
			}
			CacheEdit[] array2 = array;
			foreach (CacheEdit cacheEdit5 in array2)
			{
				if (!cacheEdit5.Assigned && cacheEdit5.Replacement != null)
				{
					TryDispose(cacheEdit5.Replacement, "rolled-back large-map compatibility replacement for " + cacheEdit5.Description);
				}
			}
			Log("Large-map compatibility transaction failed: " + ex.GetBaseException().Message);
			if (list.Count != 0)
			{
				throw new AggregateException("Large-map compatibility transaction and rollback both failed.", new Exception[1] { ex }.Concat(list));
			}
			throw;
		}
	}

	public static byte[] ReadCachedRootScript(string fullPath)
	{
		if (string.IsNullOrWhiteSpace(fullPath))
		{
			throw new ArgumentException("Root script path is required.", "fullPath");
		}
		CachedResource cachedResource = GetCachedResource(GetLuaFileCache(), "LJ/lua/script.lua");
		string fullPath2 = Path.GetFullPath(fullPath);
		string fullPath3 = Path.GetFullPath(cachedResource.Path);
		if (!string.Equals(fullPath2, fullPath3, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Root script cache path does not match LuaInterface.InitLuaState: " + fullPath3 + " != " + fullPath2 + ".");
		}
		byte[] result = ReadBytes(cachedResource.Value);
		Log("Supplied transformed root script.lua from the verified Lua cache.");
		return result;
	}

	public static string TransformForVerification(string source)
	{
		source = Normalize(source ?? throw new ArgumentNullException("source"));
		source = TransformPlacementGrid(source);
		return TransformClientInitialization(source);
	}

	public static string TransformGameUtilsForVerification(string source)
	{
		source = Normalize(source ?? throw new ArgumentNullException("source"));
		switch (Count(source, "-- SCOM Large Map Load Compat: deferred initial units 1.0.0"))
		{
		case 1:
			if (Count(source, "---@return nil\nfunction CreateArmies()") != 0 || Count(source, "-- SCOM Large Map Load Compat: deferred initial units 1.0.0\n---@param deferInitialUnits? boolean When true, the caller must invoke SpawnInitialUnits after client initialization is queued.\n---@return nil\nfunction CreateArmies(deferInitialUnits)") != 1 || Count(source, "    SpawnInitialUnits()\nend\n\n---Returns the lobby options table if the (debug) file exists.") != 0 || Count(source, "    if not deferInitialUnits then\n        SpawnInitialUnits()\n    end\nend\n\n---Returns the lobby options table if the (debug) file exists.") != 1)
			{
				throw new InvalidOperationException("Deferred initial-unit marker has a malformed implementation.");
			}
			return source;
		default:
			throw new InvalidOperationException("Deferred initial-unit marker is duplicated.");
		case 0:
		{
			if (Count(source, "---@return nil\nfunction CreateArmies()") != 1 || Count(source, "    SpawnInitialUnits()\nend\n\n---Returns the lobby options table if the (debug) file exists.") != 1 || Count(source, "-- SCOM Large Map Load Compat: deferred initial units 1.0.0\n---@param deferInitialUnits? boolean When true, the caller must invoke SpawnInitialUnits after client initialization is queued.\n---@return nil\nfunction CreateArmies(deferInitialUnits)") != 0 || Count(source, "    if not deferInitialUnits then\n        SpawnInitialUnits()\n    end\nend\n\n---Returns the lobby options table if the (debug) file exists.") != 0)
			{
				throw new InvalidOperationException("Stock CreateArmies implementation changed; refusing an unverified transform.");
			}
			string text = source.Replace("---@return nil\nfunction CreateArmies()", "-- SCOM Large Map Load Compat: deferred initial units 1.0.0\n---@param deferInitialUnits? boolean When true, the caller must invoke SpawnInitialUnits after client initialization is queued.\n---@return nil\nfunction CreateArmies(deferInitialUnits)").Replace("    SpawnInitialUnits()\nend\n\n---Returns the lobby options table if the (debug) file exists.", "    if not deferInitialUnits then\n        SpawnInitialUnits()\n    end\nend\n\n---Returns the lobby options table if the (debug) file exists.");
			if (Count(text, "-- SCOM Large Map Load Compat: deferred initial units 1.0.0") != 1 || Count(text, "---@return nil\nfunction CreateArmies()") != 0 || Count(text, "-- SCOM Large Map Load Compat: deferred initial units 1.0.0\n---@param deferInitialUnits? boolean When true, the caller must invoke SpawnInitialUnits after client initialization is queued.\n---@return nil\nfunction CreateArmies(deferInitialUnits)") != 1 || Count(text, "    SpawnInitialUnits()\nend\n\n---Returns the lobby options table if the (debug) file exists.") != 0 || Count(text, "    if not deferInitialUnits then\n        SpawnInitialUnits()\n    end\nend\n\n---Returns the lobby options table if the (debug) file exists.") != 1)
			{
				throw new InvalidOperationException("Deferred initial-unit transform did not produce its exact single-marker contract.");
			}
			return text;
		}
		}
	}

	private static string TransformPlacementGrid(string source)
	{
		int num = Count(source, "-- SCOM Large Map Load Compat: placement grid 1.0.1");
		if (Count(source, "local function GetCellWaterFlags(x, y, waterLevel, depth)\n    local deepThreshold = waterLevel - depth\n    local isPartialWater = false\n    local isDeepWater = true\n\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success then\n                if height < waterLevel then\n                    isPartialWater = true\n                end\n                if height > deepThreshold then\n                    isDeepWater = false\n                end\n            else\n                isDeepWater = false\n            end\n        end\n    end\n\n    return isPartialWater, isDeepWater\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local NavalPlacementDepth = Import(\"common/systems/placementUtils.lua\").NavalPlacementDepth\n    local Water = Import(\"common/water.lua\")\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local hasWater = Water.HasWater()\n    local waterLevel = Water.GetLevel()\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n\n            local isPartialWater, isDeepWater = false, false\n            if hasWater then\n                isPartialWater, isDeepWater = GetCellWaterFlags(x, y, waterLevel, NavalPlacementDepth)\n            end\n\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep or isPartialWater)\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, isDeepWater)\n        end\n    end\nend") == 1)
		{
			switch (num)
			{
			case 0:
				return source.Replace("local function GetCellWaterFlags(x, y, waterLevel, depth)\n    local deepThreshold = waterLevel - depth\n    local isPartialWater = false\n    local isDeepWater = true\n\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success then\n                if height < waterLevel then\n                    isPartialWater = true\n                end\n                if height > deepThreshold then\n                    isDeepWater = false\n                end\n            else\n                isDeepWater = false\n            end\n        end\n    end\n\n    return isPartialWater, isDeepWater\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local NavalPlacementDepth = Import(\"common/systems/placementUtils.lua\").NavalPlacementDepth\n    local Water = Import(\"common/water.lua\")\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local hasWater = Water.HasWater()\n    local waterLevel = Water.GetLevel()\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n\n            local isPartialWater, isDeepWater = false, false\n            if hasWater then\n                isPartialWater, isDeepWater = GetCellWaterFlags(x, y, waterLevel, NavalPlacementDepth)\n            end\n\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep or isPartialWater)\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, isDeepWater)\n        end\n    end\nend", "-- SCOM Large Map Load Compat: placement grid 1.0.1\n-- Preserve the native depth-aware placement grid.\nlocal function GetCellWaterFlags(x, y, waterLevel, depth)\n    local deepThreshold = waterLevel - depth\n    local isPartialWater = false\n    local isDeepWater = true\n\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success then\n                if height < waterLevel then\n                    isPartialWater = true\n                end\n                if height > deepThreshold then\n                    isDeepWater = false\n                end\n            else\n                isDeepWater = false\n            end\n        end\n    end\n\n    return isPartialWater, isDeepWater\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local NavalPlacementDepth = Import(\"common/systems/placementUtils.lua\").NavalPlacementDepth\n    local Water = Import(\"common/water.lua\")\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local hasWater = Water.HasWater()\n    local waterLevel = Water.GetLevel()\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n\n            local isPartialWater, isDeepWater = false, false\n            if hasWater then\n                isPartialWater, isDeepWater = GetCellWaterFlags(x, y, waterLevel, NavalPlacementDepth)\n            end\n\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep or isPartialWater)\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, isDeepWater)\n        end\n    end\nend");
			case 1:
				if (Count(source, "-- SCOM Large Map Load Compat: placement grid 1.0.1\n-- Preserve the native depth-aware placement grid.\nlocal function GetCellWaterFlags(x, y, waterLevel, depth)\n    local deepThreshold = waterLevel - depth\n    local isPartialWater = false\n    local isDeepWater = true\n\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success then\n                if height < waterLevel then\n                    isPartialWater = true\n                end\n                if height > deepThreshold then\n                    isDeepWater = false\n                end\n            else\n                isDeepWater = false\n            end\n        end\n    end\n\n    return isPartialWater, isDeepWater\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local NavalPlacementDepth = Import(\"common/systems/placementUtils.lua\").NavalPlacementDepth\n    local Water = Import(\"common/water.lua\")\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local hasWater = Water.HasWater()\n    local waterLevel = Water.GetLevel()\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n\n            local isPartialWater, isDeepWater = false, false\n            if hasWater then\n                isPartialWater, isDeepWater = GetCellWaterFlags(x, y, waterLevel, NavalPlacementDepth)\n            end\n\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep or isPartialWater)\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, isDeepWater)\n        end\n    end\nend") == 1)
				{
					return source;
				}
				break;
			}
			throw new InvalidOperationException("Native placement-grid ownership marker is malformed.");
		}
		switch (num)
		{
		case 1:
			if (Count(source, "--- Returns true if any corner of the heightmap cell at (x, y) is below the water level.\nlocal function IsCellUnderwater(x, y, waterLevel)\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success and height < waterLevel then\n                return true\n            end\n        end\n    end\n    return false\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local _, hasWater = Engine.HasWater()\n    local waterLevel\n    if hasWater then\n        _, waterLevel = Engine.GetWaterLevel()\n    end\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep)\n\n            if hasWater then\n                setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, IsCellUnderwater(x, y, waterLevel))\n            end\n        end\n    end\nend") != 0 || Count(source, "--- Returns true if any corner of the heightmap cell at (x, y) is below the water level.\nlocal function IsCellUnderwater(x, y, waterLevel)\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success and height < waterLevel then\n                return true\n            end\n        end\n    end\n    return false\nend\n\n-- SCOM Large Map Load Compat: placement grid 1.0.1\n-- Preserve Sanctuary's exact terrain-normal result while batching grid writes and\n-- sampling each water vertex once instead of up to four times per adjacent cell.\nlocal function SCOMSampleWaterColumn(column, x, mapSizeY, waterLevel, coordinate)\n    coordinate.x = x\n    for y = 1, mapSizeY do\n        coordinate.y = y\n        local errorCode, height = Engine.SampleTerrainHeightFromCell(coordinate)\n        column[y] = errorCode == EngineErrorCode.Success and height < waterLevel\n    end\nend\n\nlocal function SCOMSetPlacementRun(\n    setCellBaseFlags, gridID, x, firstY, lastY, flags, runMin, runMax)\n    runMin.x = x\n    runMin.y = firstY\n    runMax.x = x\n    runMax.y = lastY\n    setCellBaseFlags(gridID, runMin, runMax, flags, true)\nend\n\nlocal function SCOMInitializeLargePlacementGrid(\n    setCellBaseFlags, gridID, PlacementLayer, mapSizeX, mapSizeY,\n    steepnessThreshold, hasWater, waterLevel)\n    local lastX = mapSizeX - 1\n    local lastY = mapSizeY - 1\n    local clearMin = EngineClasses.int2(1, 1)\n    local clearMax = EngineClasses.int2(1, lastY)\n    local targetFlags = PlacementLayer.InvalidTerrain\n    if hasWater then\n        targetFlags = targetFlags + PlacementLayer.Water\n    end\n\n    local coordinate = EngineClasses.int2(1, 1)\n    local firstNormal = {}\n    local secondNormal = {}\n    local runMin = EngineClasses.int2(1, 1)\n    local runMax = EngineClasses.int2(1, 1)\n    local columnFlags = {}\n    local currentWaterColumn\n    local nextWaterColumn\n    if hasWater then\n        currentWaterColumn = {}\n        nextWaterColumn = {}\n        SCOMSampleWaterColumn(\n            currentWaterColumn, 1, mapSizeY, waterLevel, coordinate)\n        SCOMSampleWaterColumn(\n            nextWaterColumn, 2, mapSizeY, waterLevel, coordinate)\n    end\n\n    for x = 1, lastX do\n        for y = 1, lastY do\n            coordinate.x = x\n            coordinate.y = y\n            Engine.SampleTerrainNormals(coordinate, firstNormal, secondNormal)\n\n            local cellFlags = 0\n            if firstNormal.y < steepnessThreshold\n                or secondNormal.y < steepnessThreshold\n            then\n                cellFlags = PlacementLayer.InvalidTerrain\n            end\n            if hasWater and (\n                currentWaterColumn[y]\n                or currentWaterColumn[y + 1]\n                or nextWaterColumn[y]\n                or nextWaterColumn[y + 1])\n            then\n                cellFlags = cellFlags + PlacementLayer.Water\n            end\n            columnFlags[y] = cellFlags\n        end\n\n        -- Classify the complete column before its first destructive write. A\n        -- sampling failure therefore cannot clear unclassified map columns.\n        clearMin.x = x\n        clearMax.x = x\n        setCellBaseFlags(gridID, clearMin, clearMax, targetFlags, false)\n\n        local runFlags = 0\n        local runStart\n        for y = 1, lastY do\n            local cellFlags = columnFlags[y]\n            if cellFlags ~= runFlags then\n                if runFlags ~= 0 then\n                    SCOMSetPlacementRun(\n                        setCellBaseFlags, gridID, x, runStart, y - 1,\n                        runFlags, runMin, runMax)\n                end\n                runFlags = cellFlags\n                runStart = cellFlags ~= 0 and y or nil\n            end\n        end\n        if runFlags ~= 0 then\n            SCOMSetPlacementRun(\n                setCellBaseFlags, gridID, x, runStart, lastY,\n                runFlags, runMin, runMax)\n        end\n\n        if hasWater and x < lastX then\n            currentWaterColumn, nextWaterColumn =\n                nextWaterColumn, currentWaterColumn\n            SCOMSampleWaterColumn(\n                nextWaterColumn, x + 2, mapSizeY, waterLevel, coordinate)\n        end\n    end\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local _, hasWater = Engine.HasWater()\n    local waterLevel\n    if hasWater then\n        _, waterLevel = Engine.GetWaterLevel()\n    end\n\n    if (mapSizeX >= 2048 or mapSizeY >= 2048)\n        and mapSizeX > 1 and mapSizeY > 1\n    then\n        local side = IsHost and \"Host\" or \"Client\"\n        Engine.Log(\"[SCOM Large Map Load Compat] \" .. side\n            .. \" placement-grid optimization begin \"\n            .. mapSizeX .. \"x\" .. mapSizeY .. \".\")\n        SCOMInitializeLargePlacementGrid(\n            setCellBaseFlags, gridID, PlacementLayer, mapSizeX, mapSizeY,\n            steepnessThreshold, hasWater, waterLevel)\n        Engine.Log(\"[SCOM Large Map Load Compat] \" .. side\n            .. \" placement-grid optimization completed \"\n            .. mapSizeX .. \"x\" .. mapSizeY .. \".\")\n        return\n    end\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep)\n\n            if hasWater then\n                setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, IsCellUnderwater(x, y, waterLevel))\n            end\n        end\n    end\nend") != 1)
			{
				throw new InvalidOperationException("Placement-grid optimization marker has a malformed implementation.");
			}
			return source;
		default:
			throw new InvalidOperationException("Placement-grid optimization marker is duplicated.");
		case 0:
		{
			if (Count(source, "--- Returns true if any corner of the heightmap cell at (x, y) is below the water level.\nlocal function IsCellUnderwater(x, y, waterLevel)\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success and height < waterLevel then\n                return true\n            end\n        end\n    end\n    return false\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local _, hasWater = Engine.HasWater()\n    local waterLevel\n    if hasWater then\n        _, waterLevel = Engine.GetWaterLevel()\n    end\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep)\n\n            if hasWater then\n                setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, IsCellUnderwater(x, y, waterLevel))\n            end\n        end\n    end\nend") != 1)
			{
				throw new InvalidOperationException("Stock placement-grid implementation changed; refusing an unverified transform.");
			}
			string text = source.Replace("--- Returns true if any corner of the heightmap cell at (x, y) is below the water level.\nlocal function IsCellUnderwater(x, y, waterLevel)\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success and height < waterLevel then\n                return true\n            end\n        end\n    end\n    return false\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local _, hasWater = Engine.HasWater()\n    local waterLevel\n    if hasWater then\n        _, waterLevel = Engine.GetWaterLevel()\n    end\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep)\n\n            if hasWater then\n                setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, IsCellUnderwater(x, y, waterLevel))\n            end\n        end\n    end\nend", "--- Returns true if any corner of the heightmap cell at (x, y) is below the water level.\nlocal function IsCellUnderwater(x, y, waterLevel)\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success and height < waterLevel then\n                return true\n            end\n        end\n    end\n    return false\nend\n\n-- SCOM Large Map Load Compat: placement grid 1.0.1\n-- Preserve Sanctuary's exact terrain-normal result while batching grid writes and\n-- sampling each water vertex once instead of up to four times per adjacent cell.\nlocal function SCOMSampleWaterColumn(column, x, mapSizeY, waterLevel, coordinate)\n    coordinate.x = x\n    for y = 1, mapSizeY do\n        coordinate.y = y\n        local errorCode, height = Engine.SampleTerrainHeightFromCell(coordinate)\n        column[y] = errorCode == EngineErrorCode.Success and height < waterLevel\n    end\nend\n\nlocal function SCOMSetPlacementRun(\n    setCellBaseFlags, gridID, x, firstY, lastY, flags, runMin, runMax)\n    runMin.x = x\n    runMin.y = firstY\n    runMax.x = x\n    runMax.y = lastY\n    setCellBaseFlags(gridID, runMin, runMax, flags, true)\nend\n\nlocal function SCOMInitializeLargePlacementGrid(\n    setCellBaseFlags, gridID, PlacementLayer, mapSizeX, mapSizeY,\n    steepnessThreshold, hasWater, waterLevel)\n    local lastX = mapSizeX - 1\n    local lastY = mapSizeY - 1\n    local clearMin = EngineClasses.int2(1, 1)\n    local clearMax = EngineClasses.int2(1, lastY)\n    local targetFlags = PlacementLayer.InvalidTerrain\n    if hasWater then\n        targetFlags = targetFlags + PlacementLayer.Water\n    end\n\n    local coordinate = EngineClasses.int2(1, 1)\n    local firstNormal = {}\n    local secondNormal = {}\n    local runMin = EngineClasses.int2(1, 1)\n    local runMax = EngineClasses.int2(1, 1)\n    local columnFlags = {}\n    local currentWaterColumn\n    local nextWaterColumn\n    if hasWater then\n        currentWaterColumn = {}\n        nextWaterColumn = {}\n        SCOMSampleWaterColumn(\n            currentWaterColumn, 1, mapSizeY, waterLevel, coordinate)\n        SCOMSampleWaterColumn(\n            nextWaterColumn, 2, mapSizeY, waterLevel, coordinate)\n    end\n\n    for x = 1, lastX do\n        for y = 1, lastY do\n            coordinate.x = x\n            coordinate.y = y\n            Engine.SampleTerrainNormals(coordinate, firstNormal, secondNormal)\n\n            local cellFlags = 0\n            if firstNormal.y < steepnessThreshold\n                or secondNormal.y < steepnessThreshold\n            then\n                cellFlags = PlacementLayer.InvalidTerrain\n            end\n            if hasWater and (\n                currentWaterColumn[y]\n                or currentWaterColumn[y + 1]\n                or nextWaterColumn[y]\n                or nextWaterColumn[y + 1])\n            then\n                cellFlags = cellFlags + PlacementLayer.Water\n            end\n            columnFlags[y] = cellFlags\n        end\n\n        -- Classify the complete column before its first destructive write. A\n        -- sampling failure therefore cannot clear unclassified map columns.\n        clearMin.x = x\n        clearMax.x = x\n        setCellBaseFlags(gridID, clearMin, clearMax, targetFlags, false)\n\n        local runFlags = 0\n        local runStart\n        for y = 1, lastY do\n            local cellFlags = columnFlags[y]\n            if cellFlags ~= runFlags then\n                if runFlags ~= 0 then\n                    SCOMSetPlacementRun(\n                        setCellBaseFlags, gridID, x, runStart, y - 1,\n                        runFlags, runMin, runMax)\n                end\n                runFlags = cellFlags\n                runStart = cellFlags ~= 0 and y or nil\n            end\n        end\n        if runFlags ~= 0 then\n            SCOMSetPlacementRun(\n                setCellBaseFlags, gridID, x, runStart, lastY,\n                runFlags, runMin, runMax)\n        end\n\n        if hasWater and x < lastX then\n            currentWaterColumn, nextWaterColumn =\n                nextWaterColumn, currentWaterColumn\n            SCOMSampleWaterColumn(\n                nextWaterColumn, x + 2, mapSizeY, waterLevel, coordinate)\n        end\n    end\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local _, hasWater = Engine.HasWater()\n    local waterLevel\n    if hasWater then\n        _, waterLevel = Engine.GetWaterLevel()\n    end\n\n    if (mapSizeX >= 2048 or mapSizeY >= 2048)\n        and mapSizeX > 1 and mapSizeY > 1\n    then\n        local side = IsHost and \"Host\" or \"Client\"\n        Engine.Log(\"[SCOM Large Map Load Compat] \" .. side\n            .. \" placement-grid optimization begin \"\n            .. mapSizeX .. \"x\" .. mapSizeY .. \".\")\n        SCOMInitializeLargePlacementGrid(\n            setCellBaseFlags, gridID, PlacementLayer, mapSizeX, mapSizeY,\n            steepnessThreshold, hasWater, waterLevel)\n        Engine.Log(\"[SCOM Large Map Load Compat] \" .. side\n            .. \" placement-grid optimization completed \"\n            .. mapSizeX .. \"x\" .. mapSizeY .. \".\")\n        return\n    end\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep)\n\n            if hasWater then\n                setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, IsCellUnderwater(x, y, waterLevel))\n            end\n        end\n    end\nend");
			if (Count(text, "-- SCOM Large Map Load Compat: placement grid 1.0.1") != 1 || Count(text, "--- Returns true if any corner of the heightmap cell at (x, y) is below the water level.\nlocal function IsCellUnderwater(x, y, waterLevel)\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success and height < waterLevel then\n                return true\n            end\n        end\n    end\n    return false\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local _, hasWater = Engine.HasWater()\n    local waterLevel\n    if hasWater then\n        _, waterLevel = Engine.GetWaterLevel()\n    end\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep)\n\n            if hasWater then\n                setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, IsCellUnderwater(x, y, waterLevel))\n            end\n        end\n    end\nend") != 0 || Count(text, "--- Returns true if any corner of the heightmap cell at (x, y) is below the water level.\nlocal function IsCellUnderwater(x, y, waterLevel)\n    for cornerX = x, x + 1 do\n        for cornerY = y, y + 1 do\n            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))\n            if errorCode == EngineErrorCode.Success and height < waterLevel then\n                return true\n            end\n        end\n    end\n    return false\nend\n\n-- SCOM Large Map Load Compat: placement grid 1.0.1\n-- Preserve Sanctuary's exact terrain-normal result while batching grid writes and\n-- sampling each water vertex once instead of up to four times per adjacent cell.\nlocal function SCOMSampleWaterColumn(column, x, mapSizeY, waterLevel, coordinate)\n    coordinate.x = x\n    for y = 1, mapSizeY do\n        coordinate.y = y\n        local errorCode, height = Engine.SampleTerrainHeightFromCell(coordinate)\n        column[y] = errorCode == EngineErrorCode.Success and height < waterLevel\n    end\nend\n\nlocal function SCOMSetPlacementRun(\n    setCellBaseFlags, gridID, x, firstY, lastY, flags, runMin, runMax)\n    runMin.x = x\n    runMin.y = firstY\n    runMax.x = x\n    runMax.y = lastY\n    setCellBaseFlags(gridID, runMin, runMax, flags, true)\nend\n\nlocal function SCOMInitializeLargePlacementGrid(\n    setCellBaseFlags, gridID, PlacementLayer, mapSizeX, mapSizeY,\n    steepnessThreshold, hasWater, waterLevel)\n    local lastX = mapSizeX - 1\n    local lastY = mapSizeY - 1\n    local clearMin = EngineClasses.int2(1, 1)\n    local clearMax = EngineClasses.int2(1, lastY)\n    local targetFlags = PlacementLayer.InvalidTerrain\n    if hasWater then\n        targetFlags = targetFlags + PlacementLayer.Water\n    end\n\n    local coordinate = EngineClasses.int2(1, 1)\n    local firstNormal = {}\n    local secondNormal = {}\n    local runMin = EngineClasses.int2(1, 1)\n    local runMax = EngineClasses.int2(1, 1)\n    local columnFlags = {}\n    local currentWaterColumn\n    local nextWaterColumn\n    if hasWater then\n        currentWaterColumn = {}\n        nextWaterColumn = {}\n        SCOMSampleWaterColumn(\n            currentWaterColumn, 1, mapSizeY, waterLevel, coordinate)\n        SCOMSampleWaterColumn(\n            nextWaterColumn, 2, mapSizeY, waterLevel, coordinate)\n    end\n\n    for x = 1, lastX do\n        for y = 1, lastY do\n            coordinate.x = x\n            coordinate.y = y\n            Engine.SampleTerrainNormals(coordinate, firstNormal, secondNormal)\n\n            local cellFlags = 0\n            if firstNormal.y < steepnessThreshold\n                or secondNormal.y < steepnessThreshold\n            then\n                cellFlags = PlacementLayer.InvalidTerrain\n            end\n            if hasWater and (\n                currentWaterColumn[y]\n                or currentWaterColumn[y + 1]\n                or nextWaterColumn[y]\n                or nextWaterColumn[y + 1])\n            then\n                cellFlags = cellFlags + PlacementLayer.Water\n            end\n            columnFlags[y] = cellFlags\n        end\n\n        -- Classify the complete column before its first destructive write. A\n        -- sampling failure therefore cannot clear unclassified map columns.\n        clearMin.x = x\n        clearMax.x = x\n        setCellBaseFlags(gridID, clearMin, clearMax, targetFlags, false)\n\n        local runFlags = 0\n        local runStart\n        for y = 1, lastY do\n            local cellFlags = columnFlags[y]\n            if cellFlags ~= runFlags then\n                if runFlags ~= 0 then\n                    SCOMSetPlacementRun(\n                        setCellBaseFlags, gridID, x, runStart, y - 1,\n                        runFlags, runMin, runMax)\n                end\n                runFlags = cellFlags\n                runStart = cellFlags ~= 0 and y or nil\n            end\n        end\n        if runFlags ~= 0 then\n            SCOMSetPlacementRun(\n                setCellBaseFlags, gridID, x, runStart, lastY,\n                runFlags, runMin, runMax)\n        end\n\n        if hasWater and x < lastX then\n            currentWaterColumn, nextWaterColumn =\n                nextWaterColumn, currentWaterColumn\n            SCOMSampleWaterColumn(\n                nextWaterColumn, x + 2, mapSizeY, waterLevel, coordinate)\n        end\n    end\nend\n\nlocal function InitializePlacementGrid(setCellBaseFlags, gridID)\n    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client\n    local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeY = GameInfo.MapInfo.size[2]\n\n    local maxPlacementAngle = 9.0\n    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))\n\n    local _, hasWater = Engine.HasWater()\n    local waterLevel\n    if hasWater then\n        _, waterLevel = Engine.GetWaterLevel()\n    end\n\n    if (mapSizeX >= 2048 or mapSizeY >= 2048)\n        and mapSizeX > 1 and mapSizeY > 1\n    then\n        local side = IsHost and \"Host\" or \"Client\"\n        Engine.Log(\"[SCOM Large Map Load Compat] \" .. side\n            .. \" placement-grid optimization begin \"\n            .. mapSizeX .. \"x\" .. mapSizeY .. \".\")\n        SCOMInitializeLargePlacementGrid(\n            setCellBaseFlags, gridID, PlacementLayer, mapSizeX, mapSizeY,\n            steepnessThreshold, hasWater, waterLevel)\n        Engine.Log(\"[SCOM Large Map Load Compat] \" .. side\n            .. \" placement-grid optimization completed \"\n            .. mapSizeX .. \"x\" .. mapSizeY .. \".\")\n        return\n    end\n\n    for x = 1, mapSizeX -1 do\n        for y = 1, mapSizeY - 1 do\n            local coordinate = EngineClasses.int2(x, y)\n            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)\n\n            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold\n            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep)\n\n            if hasWater then\n                setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, IsCellUnderwater(x, y, waterLevel))\n            end\n        end\n    end\nend") != 1)
			{
				throw new InvalidOperationException("Placement-grid transform did not produce its exact single-marker contract.");
			}
			return text;
		}
		}
	}

	private static string TransformClientInitialization(string source)
	{
		switch (Count(source, "-- SCOM Large Map Load Compat: client initialization ordering 1.0.0"))
		{
		case 1:
			if (Count(source, "        Import(\"host/managers/targeting/targeterManager.lua\")\n        Import(\"common/gameUtils.lua\").CreateArmies()") != 0 || Count(source, "        Import(\"host/managers/targeting/targeterManager.lua\")\n        local GameUtils = Import(\"common/gameUtils.lua\")\n        GameUtils.CreateArmies(true)") != 1 || Count(source, "        -- SCOM Large Map Load Compat: client initialization ordering 1.0.0\n        -- Armies and relationships must reach the client before focus initialization.\n        -- Initial units must wait until InitClient registers the map's prop prefabs.\n        Import(\"host/hostMain.lua\").SCOSpawnInitialUnits(GameUtils)\n        Import(\"host/hostMain.lua\").Start()") != 1)
			{
				throw new InvalidOperationException("Client-initialization ordering marker has a malformed implementation.");
			}
			return source;
		default:
			throw new InvalidOperationException("Client-initialization ordering marker is duplicated.");
		case 0:
		{
			if (Count(source, "        Import(\"host/managers/targeting/targeterManager.lua\")\n        Import(\"common/gameUtils.lua\").CreateArmies()") != 1 || Count(source, "        Import(\"host/managers/targeting/targeterManager.lua\")\n        local GameUtils = Import(\"common/gameUtils.lua\")\n        GameUtils.CreateArmies(true)") != 0 || Count(source, "        Import(\"host/hostMain.lua\").Start()") != 1 || Count(source, "        -- SCOM Large Map Load Compat: client initialization ordering 1.0.0\n        -- Armies and relationships must reach the client before focus initialization.\n        -- Initial units must wait until InitClient registers the map's prop prefabs.\n        Import(\"host/hostMain.lua\").SCOSpawnInitialUnits(GameUtils)\n        Import(\"host/hostMain.lua\").Start()") != 0)
			{
				throw new InvalidOperationException("Stock host initialization order changed; refusing an unverified transform.");
			}
			string text = source.Replace("        Import(\"host/managers/targeting/targeterManager.lua\")\n        Import(\"common/gameUtils.lua\").CreateArmies()", "        Import(\"host/managers/targeting/targeterManager.lua\")\n        local GameUtils = Import(\"common/gameUtils.lua\")\n        GameUtils.CreateArmies(true)").Replace("        Import(\"host/hostMain.lua\").Start()", "        -- SCOM Large Map Load Compat: client initialization ordering 1.0.0\n        -- Armies and relationships must reach the client before focus initialization.\n        -- Initial units must wait until InitClient registers the map's prop prefabs.\n        Import(\"host/hostMain.lua\").SCOSpawnInitialUnits(GameUtils)\n        Import(\"host/hostMain.lua\").Start()");
			if (Count(text, "-- SCOM Large Map Load Compat: client initialization ordering 1.0.0") != 1 || Count(text, "        Import(\"host/managers/targeting/targeterManager.lua\")\n        Import(\"common/gameUtils.lua\").CreateArmies()") != 0 || Count(text, "        Import(\"host/managers/targeting/targeterManager.lua\")\n        local GameUtils = Import(\"common/gameUtils.lua\")\n        GameUtils.CreateArmies(true)") != 1 || Count(text, "        -- SCOM Large Map Load Compat: client initialization ordering 1.0.0\n        -- Armies and relationships must reach the client before focus initialization.\n        -- Initial units must wait until InitClient registers the map's prop prefabs.\n        Import(\"host/hostMain.lua\").SCOSpawnInitialUnits(GameUtils)\n        Import(\"host/hostMain.lua\").Start()") != 1)
			{
				throw new InvalidOperationException("Client-initialization ordering transform did not produce its exact single-marker contract.");
			}
			return text;
		}
		}
	}

	private static object GetLuaFileCache()
	{
		Type[] array = (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType("EM.Lua.FilesCache", throwOnError: false) into type
			where type != null
			select type).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException($"Expected one loaded EM.Lua.FilesCache type, found {array.Length}.");
		}
		return (array[0].GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(array[0].FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CachedResource GetCachedResource(object cache, string relativePath)
	{
		string value = "/" + relativePath.Replace('\\', '/');
		CachedResource cachedResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type = item.GetType();
			if (type.GetProperty("Key")?.GetValue(item, null) is string text && text.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cachedResource != null)
				{
					throw new InvalidOperationException("Multiple Lua cache resources match " + relativePath + ".");
				}
				object obj = type.GetProperty("Value")?.GetValue(item, null) ?? throw new InvalidOperationException("Cached " + relativePath + " has no value.");
				EnsureCreated(obj, relativePath);
				cachedResource = new CachedResource(text, obj);
			}
		}
		return cachedResource ?? throw new FileNotFoundException("Required cached Lua source is unavailable.", relativePath);
	}

	private static string ReadText(object resource)
	{
		return Normalize(Encoding.UTF8.GetString(ReadBytes(resource)));
	}

	private static byte[] ReadBytes(object resource)
	{
		EnsureCreated(resource, "Lua cache resource");
		return ((resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null) as byte[]) ?? throw new InvalidOperationException("NativeArray.ToArray returned null.");
	}

	private static object CreateNativeArray(Type type, string source)
	{
		if (!type.IsGenericType || type.GetGenericArguments().Length != 1 || type.GetGenericArguments()[0] != typeof(byte))
		{
			throw new ArgumentException("Expected Unity NativeArray<byte>.", "type");
		}
		Type type2 = type.Assembly.GetType("Unity.Collections.Allocator", throwOnError: false) ?? (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType("Unity.Collections.Allocator", throwOnError: false)).FirstOrDefault((Type candidate) => candidate != null) ?? throw new TypeLoadException("Unity.Collections.Allocator is unavailable.");
		return (type.GetConstructor(BindingFlags.Instance | BindingFlags.Public, null, new Type[2]
		{
			typeof(byte[]),
			type2
		}, null) ?? throw new MissingMethodException(type.FullName, ".ctor(Byte[], Allocator)")).Invoke(new object[2]
		{
			Encoding.UTF8.GetBytes(source),
			Enum.Parse(type2, "Persistent")
		});
	}

	private static void EnsureCreated(object resource, string description)
	{
		object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource, null);
		if (!(value is bool) || !(bool)value)
		{
			throw new InvalidOperationException("Cached " + description + " is not initialized.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static object GetExactCachedResource(object cache, string path)
	{
		return (cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("Cache returned null for " + path + ".");
	}

	private static void TryDispose(object resource, string description)
	{
		try
		{
			Type type = resource.GetType();
			object obj = type.GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public)?.GetValue(resource, null);
			if (obj is bool && (bool)obj)
			{
				(type.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, "Dispose")).Invoke(resource, null);
			}
		}
		catch (Exception ex)
		{
			Log("NativeArray cleanup warning for " + description + ": " + ex.GetBaseException().Message);
		}
	}

	private static bool IsCallTo(Instruction instruction, string fullName)
	{
		if (instruction.OpCode == OpCodes.Call || instruction.OpCode == OpCodes.Callvirt)
		{
			object operand = instruction.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			if (methodReference != null)
			{
				return string.Equals(methodReference.FullName, fullName, StringComparison.Ordinal);
			}
		}
		return false;
	}

	private static string Normalize(string source)
	{
		return source.Replace("\r\n", "\n").Replace('\r', '\n');
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

	private static void Log(string message)
	{
		string value = "[SCOM Large Map Load Compat] " + message;
		try
		{
			Console.WriteLine(value);
		}
		catch
		{
		}
	}
}
