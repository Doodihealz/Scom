using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using ScomSeraphimLogo;
using SupremeCommanderOverhaul.Shared;

namespace SeraphimFourthFactionCachePatcher;

public static class CachePatcherRuntime
{
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

		public bool AssignmentWasAttempted { get; set; }

		public CacheMutation(string path, object? stock, object replacement, bool added, string description)
		{
			Path = path;
			Stock = stock;
			Replacement = replacement;
			Added = added;
			Description = description;
		}
	}

	private const string OverrideMarker = "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0";

	private const string FactionsRelativePath = "LJ/lua/common/systems/factions.lua";

	private const string EnumsRelativePath = "LJ/lua/host/generated/lua/enums.lua";

	private const string ImportRelativePath = "LJ/lua/common/systems/import.lua";

	private const string AvailableUnitsRelativePath = "LJ/lua/common/units/availableUnits.lua";

	private const string QuickLaunchUnitsRelativePath = "LJ/lua/common/units/quickLaunchUnits.lua";

	private const string TemplateUpdaterRelativePath = "LJ/lua/common/systems/templateUpdater.lua";

	private const string LayersRelativePath = "LJ/lua/common/layers.lua";

	private const string UnitTemplateLoaderRelativePath = "LJ/lua/common/loading/unitTemplateLoader.lua";

	private const string CurrentMovementNavigationBinding = "table.insert(movementTemplates, EngineClasses.MovementTemplate(TemplateHeadEntityName,\n            false,\n            Layers.GetDefaultNavigationLayerFromTemplate(tp),\n            movement.speed,";

	private const string ShieldTemplateLoaderRelativePath = "LJ/lua/common/loading/shieldTemplateLoader.lua";

	private const string AdjacencyLoaderRelativePath = "LJ/lua/common/loading/adjacencyConnectorLoader.lua";

	private const string HostUnitsUtilitiesRelativePath = "LJ/lua/host/units/unitsUtilities.lua";

	private const string HostUnitsUpdateRelativePath = "LJ/lua/host/units/unitsUpdate.lua";

	private const string HostBuildOrderRelativePath = "LJ/lua/host/managers/orders/orderClasses/hostBuildOrder.lua";

	private const string ConstructionPreviewRelativePath = "LJ/lua/client/input/constructionPreviewSystem.lua";

	private const string ClientUnitsDefaultRelativePath = "LJ/lua/client/units/unitsClasses/unitsDefault.lua";

	private const string HostSeraphimClassesRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua";

	private const string ClientSeraphimClassesRelativePath = "LJ/lua/client/units/unitsClasses/unitsDefaultSeraphim.lua";

	private const string SeraphimFactionIconSpriteRelativePath = "UI/Sprites/Icons/Factions/seraphim.sansprite";

	private static readonly string[] NativeFactionDropdownPrefix = new string[3] { "EDA", "Chosen", "Guard" };

	private static readonly string[] FactionDropdownPrefix = new string[4] { "UEF", "Aeon", "Cybran", "Seraphim" };

	private static object? cachedSeraphimFactionIcon;

	private static string? lastFactionDropdownFailure;

	private static bool nativeRegistrationEnabled = true;

	private static bool cachePatchReady;

	private static readonly ClassRoute[] SeraphimClassRoutes = new ClassRoute[15]
	{
		new ClassRoute("ChosenStructure", "SeraphimStructure", "Structure"),
		new ClassRoute("ChosenNavalStructure", "SeraphimNavalStructure", "NavalStructure"),
		new ClassRoute("ChosenTechCentre", "SeraphimTechCentre", "TechCentre"),
		new ClassRoute("ChosenEngineeringStation", "SeraphimEngineeringStation", "EngineeringStation"),
		new ClassRoute("ChosenStorage", "SeraphimStorage", "Storage"),
		new ClassRoute("ChosenAirFactory", "SeraphimAirFactory", "AirFactory"),
		new ClassRoute("ChosenLandFactory", "SeraphimLandFactory", "LandFactory"),
		new ClassRoute("ChosenNavalFactory", "SeraphimNavalFactory", "NavalFactory"),
		new ClassRoute("ChosenAlloyExtractor", "SeraphimAlloyExtractor", "AlloyExtractor"),
		new ClassRoute("ChosenEnergyGenerator", "SeraphimEnergyGenerator", "EnergyGenerator"),
		new ClassRoute("ChosenAirUnit", "SeraphimAirUnit", "AirUnit"),
		new ClassRoute("ChosenLandUnit", "SeraphimLandUnit", "LandUnit"),
		new ClassRoute("ChosenNavalUnit", "SeraphimNavalUnit", "NavalUnit"),
		new ClassRoute("ChosenEngineer", "SeraphimEngineer", "Engineer"),
		new ClassRoute("ChosenCommander", "SeraphimCommander", "Commander")
	};

	private const string FactionsAppendix = "\n\n-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0\n-- Native enum value 3 maps to this Lua table index 4 (`faction + 1`).\ndo\n    if FactionsData[4] ~= nil then\n        error(\"Seraphim fourth-faction patch expected FactionsData[4] to be unused.\")\n    end\n\n    FactionsData[4] = {\n        name = \"Seraphim\",\n        tpLetter = \"us\",\n        tag = \"SERAPHIM\",\n        initialUnit = \"usl0000\",\n    }\nend";

	private const string EnumsAppendix = "\n\n-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0\nFaction.Seraphim = 3";

	private const string TemplateUpdaterAppendix = "\n\n-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0\nif tpIdData[2].s ~= nil then\n    error(\"Seraphim fourth-faction patch expected template faction letter s to be unused.\")\nend\ntpIdData[2].s = \"Seraphim\"";

	private const string AdjacencyAppendix = "\n\n-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0\n-- Reuse the existing Chosen connector material until a dedicated Seraphim\n-- connector asset is authored.  This avoids the loader's default/invalid path.\nadjacencyConnectorMaterials.SERAPHIM = adjacencyConnectorMaterials.CHOSEN";

	internal static void SetNativeRegistrationEnabled(bool enabled)
	{
		nativeRegistrationEnabled = enabled;
	}

	public static void Apply()
	{
		cachePatchReady = false;
		if (!nativeRegistrationEnabled)
		{
			throw new NotSupportedException("The current Sanctuary dynamic navigation-layer contract is incompatible with the legacy Seraphim runtime port.");
		}
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		bool flag = false;
		try
		{
			obj = GetLuaFileCache();
			QueueAppend(obj, list, "LJ/lua/common/systems/factions.lua", "faction definitions", ValidateStockFactions, "\n\n-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0\n-- Native enum value 3 maps to this Lua table index 4 (`faction + 1`).\ndo\n    if FactionsData[4] ~= nil then\n        error(\"Seraphim fourth-faction patch expected FactionsData[4] to be unused.\")\n    end\n\n    FactionsData[4] = {\n        name = \"Seraphim\",\n        tpLetter = \"us\",\n        tag = \"SERAPHIM\",\n        initialUnit = \"usl0000\",\n    }\nend", (string text) => ContainsText(text, "FactionsData[4]") && ContainsText(text, "name = \"Seraphim\"") && ContainsText(text, "initialUnit = \"usl0000\""));
			QueueAppend(obj, list, "LJ/lua/host/generated/lua/enums.lua", "host faction enum table", delegate(string text)
			{
				RequireTokens(text, "Faction =", "EDA = 0", "Chosen = 1", "Guard = 2");
			}, "\n\n-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0\nFaction.Seraphim = 3", (string text) => ContainsText(text, "Faction.Seraphim = 3"));
			QueueTransform(obj, list, "LJ/lua/common/systems/templateUpdater.lua", "template faction-letter map", TransformTemplateUpdater, ValidateTemplateUpdater, allowMarkedUpgrade: true);
			QueueAppend(obj, list, "LJ/lua/common/loading/adjacencyConnectorLoader.lua", "adjacency connector material map", delegate(string text)
			{
				RequireTokens(text, "adjacencyConnectorMaterials", "CHOSEN", "GUARD");
			}, "\n\n-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0\n-- Reuse the existing Chosen connector material until a dedicated Seraphim\n-- connector asset is authored.  This avoids the loader's default/invalid path.\nadjacencyConnectorMaterials.SERAPHIM = adjacencyConnectorMaterials.CHOSEN", (string text) => ContainsText(text, "adjacencyConnectorMaterials.SERAPHIM"));
			QueueTransform(obj, list, "LJ/lua/common/systems/import.lua", "virtual unit-template directory scanner", TransformImportScanner, (string text) => ContainsText(text, "SCO_ScanDir") && ContainsText(text, "function ScanDir(directory)") && ContainsText(text, "local folders = SCO_ScanDir(directory)") && ContainsText(text, "usl0000"), allowMarkedUpgrade: true);
			QueueTransform(obj, list, "LJ/lua/common/units/availableUnits.lua", "Seraphim available-unit table", TransformAvailableUnits, (string text) => ContainsText(text, "AvailableUnits[\"usl0000\"] = true"));
			QueueTransform(obj, list, "LJ/lua/common/units/quickLaunchUnits.lua", "Seraphim quick-launch table", TransformQuickLaunchUnits, (string text) => ContainsText(text, "QuickLaunchUnits[\"usl0000\"] = true"));
			QueueTransform(obj, list, "LJ/lua/common/loading/unitTemplateLoader.lua", "Seraphim construction-beam, animation, and naval movement loader", TransformConstructionBeamMaterial, ValidateSeraphimUnitTemplateLoader, allowMarkedUpgrade: true);
			QueueTransform(obj, list, "LJ/lua/common/layers.lua", "Seraphim submarine navigation-layer map", TransformNavigationLayers, ValidateSeraphimNavigationLayers, allowMarkedUpgrade: true);
			QueueTransform(obj, list, "LJ/lua/host/units/unitsUtilities.lua", "eligible Seraphim movement-unit registry", TransformHostUnitsUtilities, ValidateHostUnitsUtilities, allowMarkedUpgrade: true);
			QueueTransform(obj, list, "LJ/lua/host/units/unitsUpdate.lua", "Seraphim explicit waterline/depth correction", TransformHostUnitsUpdate, ValidateHostUnitsUpdate, allowMarkedUpgrade: true);
			QueueTransform(obj, list, "LJ/lua/host/managers/orders/orderClasses/hostBuildOrder.lua", "Seraphim naval-factory water placement validator", TransformHostBuildOrder, (string text) => ContainsText(text, "SCO_CanPlaceSeraphimWaterFactory"), allowMarkedUpgrade: true);
			QueueTransform(obj, list, "LJ/lua/client/input/constructionPreviewSystem.lua", "Seraphim naval-factory water placement preview", TransformConstructionPreview, ValidateConstructionPreview, allowMarkedUpgrade: true);
			QueueTransform(obj, list, "LJ/lua/common/loading/shieldTemplateLoader.lua", "Seraphim shield material branches", TransformShieldMaterials, (string text) => CountOccurrences(text, "table.find(tp.tags, \"SERAPHIM\")") == 2);
			QueueTransform(obj, list, "LJ/lua/client/units/unitsClasses/unitsDefault.lua", "Seraphim tarmac map", TransformTarmacMap, (string text) => ContainsText(text, "s = _G.TarmacChosenPrefabID"));
			QueueVirtualClassModule(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua", "host", "host Seraphim unit classes");
			QueueVirtualClassModule(obj, list, "LJ/lua/client/units/unitsClasses/unitsDefaultSeraphim.lua", "client", "client Seraphim unit classes");
			TemplateRoute[] routes = SeraphimTemplateManifest.Routes;
			foreach (TemplateRoute route in routes)
			{
				QueueTemplate(obj, list, route);
			}
			if (list.Count == 0)
			{
				cachePatchReady = true;
				Log("True fourth Seraphim faction cache resources are already active.");
				return;
			}
			Commit(obj, list);
			flag = true;
			cachePatchReady = true;
			DisposeSupersededStocks(list);
			Log($"Registered native faction Seraphim=3, Lua slot 4, and {SeraphimTemplateManifest.Routes.Length} independent us* templates without changing Chosen.");
		}
		catch (Exception ex)
		{
			cachePatchReady = flag;
			if (flag)
			{
				Log($"True fourth Seraphim faction cache commit completed, but post-commit cleanup failed: {ex}");
				throw;
			}
			Exception ex2 = null;
			if (obj != null)
			{
				try
				{
					RollBackAndDispose(obj, list);
				}
				catch (Exception ex3)
				{
					ex2 = ex3;
				}
			}
			if (ex2 != null)
			{
				AggregateException ex4 = new AggregateException("The true fourth Seraphim faction transaction failed and rollback was incomplete.", ex, ex2);
				Log($"Failed to apply true fourth Seraphim faction transaction with an incomplete rollback: {ex4}");
				throw ex4;
			}
			Log($"Failed to apply true fourth Seraphim faction transaction after a complete rollback: {ex}");
			throw;
		}
	}

	public static void ConfigureFactionDropdown(object playerListItem)
	{
		if (!nativeRegistrationEnabled || !cachePatchReady)
		{
			return;
		}
		try
		{
			if (playerListItem == null)
			{
				throw new ArgumentNullException("playerListItem");
			}
			Type type = playerListItem.GetType();
			object obj = (type.GetField("factionDropdown", BindingFlags.Instance | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "factionDropdown")).GetValue(playerListItem) ?? throw new InvalidOperationException("The faction dropdown was not assigned before PlayerListItem.Awake.");
			Type type2 = obj.GetType();
			FieldInfo fieldInfo = type2.GetField("items", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type2.FullName, "items");
			IList list = (fieldInfo.GetValue(obj) as IList) ?? throw new InvalidOperationException("Beam faction dropdown items are not an IList.");
			bool flag = MatchesFactionPrefix(list, NativeFactionDropdownPrefix);
			bool flag2 = flag || list.Count == 3;
			if (!flag)
			{
				RequireFactionPrefix(list, (list.Count == 3) ? 3 : FactionDropdownPrefix.Length);
			}
			else if (list.Count != 3)
			{
				RequireFactionOptionText(list, 3, FactionDropdownPrefix[3]);
			}
			if (list.Count == 3)
			{
				(type2.GetMethod("CreateNewItem", new Type[2]
				{
					typeof(string),
					typeof(bool)
				}) ?? throw new MissingMethodException(type2.FullName, "CreateNewItem(String, Boolean)")).Invoke(obj, new object[2] { "Seraphim", false });
				list = (fieldInfo.GetValue(obj) as IList) ?? throw new InvalidOperationException("Beam faction dropdown lost its item list.");
			}
			if (flag)
			{
				for (int i = 0; i < NativeFactionDropdownPrefix.Length; i++)
				{
					SetOptionText(list[i], FactionDropdownPrefix[i], i);
				}
			}
			RequireFactionPrefix(list, FactionDropdownPrefix.Length);
			try
			{
				object obj2 = LoadSeraphimFactionIcon();
				FieldInfo field = list[3].GetType().GetField("itemIcon");
				flag2 |= field == null || field.GetValue(list[3]) != obj2;
				SetOptionImage(list[3], obj2, 3);
			}
			catch (Exception ex)
			{
				Log("Seraphim faction icon was not applied: " + ex.Message);
			}
			if (flag2)
			{
				(type2.GetMethod("Initialize", Type.EmptyTypes) ?? throw new MissingMethodException(type2.FullName, "Initialize")).Invoke(obj, null);
			}
			lastFactionDropdownFailure = null;
		}
		catch (Exception ex2)
		{
			string b = ex2.ToString();
			if (!string.Equals(lastFactionDropdownFailure, b, StringComparison.Ordinal))
			{
				lastFactionDropdownFailure = b;
				Log($"Failed to configure fourth faction dropdown option: {ex2}");
			}
		}
	}

	private static bool MatchesFactionPrefix(IList options, IReadOnlyList<string> expected)
	{
		if (options.Count < expected.Count)
		{
			return false;
		}
		for (int i = 0; i < expected.Count; i++)
		{
			object obj = options[i] ?? throw new InvalidOperationException($"Faction dropdown option {i} is null.");
			if (!string.Equals((obj.GetType().GetField("itemName", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(obj.GetType().FullName, "text")).GetValue(obj) as string, expected[i], StringComparison.Ordinal))
			{
				return false;
			}
		}
		return true;
	}

	private static void RequireFactionOptionText(IList options, int index, string expected)
	{
		if (options.Count <= index)
		{
			throw new InvalidOperationException($"Expected faction dropdown option {index} to be '{expected}', found only {options.Count} options.");
		}
		object obj = options[index] ?? throw new InvalidOperationException($"Faction dropdown option {index} is null.");
		string text = ((obj.GetType().GetField("itemName", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(obj.GetType().FullName, "text")).GetValue(obj) as string) ?? "<missing>";
		if (!string.Equals(text, expected, StringComparison.Ordinal))
		{
			throw new InvalidOperationException($"Expected faction dropdown option {index} to be '{expected}', but found '{text}'.");
		}
	}

	private static void RequireFactionPrefix(IList options, int length)
	{
		if (options.Count < length)
		{
			throw new InvalidOperationException(string.Format("Expected faction dropdown prefix [{0}], found only {1} options.", string.Join(", ", FactionDropdownPrefix.Take(length)), options.Count));
		}
		for (int i = 0; i < length; i++)
		{
			object obj = options[i] ?? throw new InvalidOperationException($"Faction dropdown option {i} is null.");
			string text = ((obj.GetType().GetField("itemName", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(obj.GetType().FullName, "text")).GetValue(obj) as string) ?? "<missing>";
			if (!string.Equals(text, FactionDropdownPrefix[i], StringComparison.Ordinal))
			{
				throw new InvalidOperationException(string.Format("Expected faction dropdown prefix [{0}], but option {1} was '{2}'.", string.Join(", ", FactionDropdownPrefix.Take(length)), i, text));
			}
		}
	}

	private static void SetOptionImage(object? option, object expectedImage, int index)
	{
		if (option == null)
		{
			throw new InvalidOperationException($"Faction dropdown option {index} is null.");
		}
		FieldInfo fieldInfo = option.GetType().GetField("itemIcon", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(option.GetType().FullName, "image");
		if (!fieldInfo.FieldType.IsInstanceOfType(expectedImage))
		{
			throw new InvalidOperationException($"Faction dropdown option {index} expects {fieldInfo.FieldType.FullName}, not {expectedImage.GetType().FullName}.");
		}
		if (fieldInfo.GetValue(option) != expectedImage)
		{
			fieldInfo.SetValue(option, expectedImage);
		}
	}

	private static object LoadSeraphimFactionIcon()
	{
		return LogoBridge.LoadSprite();
	}

	private static void ValidateStockFactions(string source)
	{
		RequireTokens(source, "name = \"EDA\"", "tpLetter = \"ue\"", "name = \"Chosen\"", "tpLetter = \"uc\"", "name = \"Guard\"", "tpLetter = \"ug\"");
		if (ContainsText(source, "Seraphim"))
		{
			throw new InvalidOperationException("Stock faction definitions already contain an unexpected Seraphim entry.");
		}
	}

	private static void QueueAppend(object cache, List<CacheMutation> mutations, string relativePath, string description, Action<string> validateStock, string appendix, Func<string, bool> validatePatched)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (ContainsMarker(resourceText))
		{
			if (!validatePatched(resourceText))
			{
				throw new InvalidOperationException("The cached " + description + " has a partial fourth-faction marker.");
			}
			return;
		}
		validateStock(resourceText);
		object obj = AppendOverride(cachedResource.Stock, appendix);
		try
		{
			string resourceText2 = GetResourceText(obj);
			if (!ContainsMarker(resourceText2) || !validatePatched(resourceText2))
			{
				throw new InvalidOperationException("The patched " + description + " did not meet its postcondition.");
			}
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + description + " replacement");
			throw;
		}
	}

	private static void QueueTransform(object cache, List<CacheMutation> mutations, string relativePath, string description, Func<string, string> transform, Func<string, bool> validatePatched, bool allowMarkedUpgrade = false)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string text = NormalizeLineEndings(GetResourceText(cachedResource.Stock));
		if (ContainsMarker(text))
		{
			if (validatePatched(text))
			{
				return;
			}
			if (!allowMarkedUpgrade)
			{
				throw new InvalidOperationException("The cached " + description + " has a partial fourth-faction marker.");
			}
		}
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), transform(text));
		try
		{
			string resourceText = GetResourceText(obj);
			if (!ContainsMarker(resourceText) || !validatePatched(resourceText))
			{
				throw new InvalidOperationException("The transformed " + description + " did not meet its postcondition.");
			}
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + description + " replacement");
			throw;
		}
	}

	private static void QueueTemplate(object cache, List<CacheMutation> mutations, TemplateRoute route)
	{
		string text = TemplateRelativePath(route.SeraphimId);
		CacheResource cacheResource = TryGetCachedResource(cache, text, "Seraphim template " + route.SeraphimId);
		bool flag = cacheResource == null;
		Type nativeArrayType;
		string path;
		object obj;
		string text2;
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			text2 = (ContainsText(resourceText, "SCO_RemapSeraphimValue") ? resourceText : TransformNativeTemplateClassReferences(resourceText, route.SeraphimId));
			nativeArrayType = cacheResource.Stock.GetType();
			path = cacheResource.Path;
			obj = cacheResource.Stock;
		}
		else
		{
			string relativePath = TemplateRelativePath(route.ChosenId);
			CacheResource cacheResource2 = TryGetCachedResource(cache, relativePath, "Chosen donor template " + route.ChosenId);
			if (cacheResource2 != null)
			{
				string resourceText2 = GetResourceText(cacheResource2.Stock);
				RequireTokens(resourceText2, "UnitTemplate", "tpId = \"" + route.ChosenId + "\"", "CHOSEN");
				text2 = resourceText2 + TemplateCloneAppendix(route.SeraphimId);
				nativeArrayType = cacheResource2.Stock.GetType();
			}
			else
			{
				if (!GeneratedNavalTemplateSources.All.TryGetValue(route.SeraphimId, out string value))
				{
					throw new FileNotFoundException("Neither a Chosen donor nor a generated native source exists for Seraphim template " + route.SeraphimId + ".", text);
				}
				text2 = TransformNativeTemplateClassReferences(value, route.SeraphimId);
				nativeArrayType = GetNativeArrayType(cache);
			}
			path = ResolvePath(cache, text);
			obj = null;
		}
		ValidateRegisteredSeraphimTemplate(text2, route.SeraphimId);
		if (!SeraphimPortOverrides.IsApplied(text2, route.SeraphimId))
		{
			text2 += SeraphimPortOverrides.BuildTemplateAppendix(route.SeraphimId);
		}
		text2 = UpgradeAirFactoryAim(text2, route);
		if (!ContainsMarker(text2))
		{
			text2 += TemplateMarkerAppendix(route.SeraphimId);
		}
		ValidateRegisteredSeraphimTemplate(text2, route.SeraphimId);
		if (!flag && string.Equals(text2, GetResourceText(obj), StringComparison.Ordinal))
		{
			return;
		}
		object obj2 = CreateNativeArrayFromText(nativeArrayType, text2);
		try
		{
			if (!SeraphimPortOverrides.IsApplied(GetResourceText(obj2), route.SeraphimId) || !HasAirFactoryAim(GetResourceText(obj2), route))
			{
				throw new InvalidOperationException("Seraphim template " + route.SeraphimId + " lost its source-rig override.");
			}
			mutations.Add(new CacheMutation(path, obj, obj2, flag, "Seraphim template " + route.SeraphimId));
		}
		catch
		{
			TryDisposeNativeArray(obj2.GetType(), obj2, "uncommitted Seraphim template " + route.SeraphimId);
			throw;
		}
	}

	private static void QueueVirtualClassModule(object cache, List<CacheMutation> mutations, string relativePath, string runtimeSide, string description)
	{
		string text = SeraphimPortOverrides.BuildClassModule(runtimeSide);
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, description);
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (ContainsMarker(resourceText))
			{
				string text2 = (string.Equals(runtimeSide, "host", StringComparison.Ordinal) ? "Host" : "Client");
				bool num = string.Equals(runtimeSide, "host", StringComparison.Ordinal) && (!ContainsText(resourceText, "GetSeraphimNavalRollOffPoints") || !ContainsText(resourceText, "SeraphimHostOrderManager"));
				bool flag = !ContainsText(resourceText, text2 + "SeraphimCommander = Class(\"SeraphimCommander\"") || !ContainsText(resourceText, text2 + "SeraphimNavalStructure = Class(\"SeraphimNavalStructure\", ChosenNavalStructure)");
				if (!num && !flag)
				{
					ValidateSeraphimClassModule(resourceText, runtimeSide);
					return;
				}
				object obj = CreateNativeArrayFromText(cacheResource.Stock.GetType(), text + MarkerAppendix());
				try
				{
					ValidateSeraphimClassModule(GetResourceText(obj), runtimeSide);
					mutations.Add(new CacheMutation(cacheResource.Path, cacheResource.Stock, obj, added: false, description));
					return;
				}
				catch
				{
					TryDisposeNativeArray(obj.GetType(), obj, "uncommitted upgraded " + description);
					throw;
				}
			}
			object obj3 = CreateNativeArrayFromText(cacheResource.Stock.GetType(), resourceText + "\n\n" + text + MarkerAppendix());
			try
			{
				ValidateSeraphimClassModule(GetResourceText(obj3), runtimeSide);
				mutations.Add(new CacheMutation(cacheResource.Path, cacheResource.Stock, obj3, added: false, description));
				return;
			}
			catch
			{
				TryDisposeNativeArray(obj3.GetType(), obj3, "uncommitted " + description);
				throw;
			}
		}
		string source = text + MarkerAppendix();
		object obj5 = CreateNativeArrayFromText(GetNativeArrayType(cache), source);
		try
		{
			ValidateSeraphimClassModule(GetResourceText(obj5), runtimeSide);
			mutations.Add(new CacheMutation(ResolvePath(cache, relativePath), null, obj5, added: true, description));
		}
		catch
		{
			TryDisposeNativeArray(obj5.GetType(), obj5, "uncommitted " + description);
			throw;
		}
	}

	private static void ValidateSeraphimClassModule(string source, string runtimeSide)
	{
		string text = (string.Equals(runtimeSide, "host", StringComparison.Ordinal) ? "Host" : "Client");
		RequireTokens(source, "local ChosenNavalStructure = chosenDefaults." + text + "ChosenNavalStructure", text + "SeraphimNavalStructure = Class(\"SeraphimNavalStructure\", ChosenNavalStructure)");
		RequireTokens(source, "unitsDefaultSeraphim", "chosenDefaults." + text + "ChosenCommander", text + "SeraphimCommander = Class", text + "SeraphimStructure = Class", text + "SeraphimLandFactory = Class", text + "SeraphimNavalFactory = Class");
		if (string.Equals(runtimeSide, "host", StringComparison.Ordinal))
		{
			RequireTokens(source, "PlaySeraphimAnimation", "OnStartBuildRoutine", "OnStopBeingBuilt", "GetSeraphimNavalRollOffPoints", "SeraphimHostOrderManager");
		}
	}

	private static string TransformNativeTemplateClassReferences(string source, string targetId)
	{
		RequireTokens(source, "UnitTemplate", "\"" + targetId + "\"", "SERAPHIM");
		string text = source.Replace("\"unitsDefaultChosen\"", "\"unitsDefaultSeraphim\"");
		ClassRoute[] seraphimClassRoutes = SeraphimClassRoutes;
		foreach (ClassRoute classRoute in seraphimClassRoutes)
		{
			text = text.Replace("\"" + classRoute.ChosenClassName + "\"", "\"" + classRoute.SeraphimClassName + "\"");
		}
		if (!ContainsText(text, "unitsDefaultSeraphim"))
		{
			throw new InvalidOperationException("Seraphim template " + targetId + " did not provide a resolvable Seraphim class module.");
		}
		return text;
	}

	internal static IEnumerable<ClassRoute> GetSeraphimClassRoutes()
	{
		return SeraphimClassRoutes;
	}

	private static string TransformImportScanner(string source)
	{
		RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory");
		int num = source.LastIndexOf("-- The FilesCache owns virtual us*.santp resources, but Engine.GetFoldersInsideDirectory", StringComparison.Ordinal);
		if (num >= 0)
		{
			int num2 = source.LastIndexOf("-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", num, StringComparison.Ordinal);
			if (num2 < 0)
			{
				throw new InvalidOperationException("The existing Seraphim template scanner has no owner marker.");
			}
			source = source.Substring(0, num2).TrimEnd(Array.Empty<char>());
		}
		return source + BuildImportScannerAppendix();
	}

	private static string TransformTemplateUpdater(string source)
	{
		RequireTokens(source, "c = \"Chosen\"", "e = \"EDA\"", "g = \"Guard\"");
		return PlaceFourthFactionAppendixBeforeTerminalReturn(source, "\n\n-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0\nif tpIdData[2].s ~= nil then\n    error(\"Seraphim fourth-faction patch expected template faction letter s to be unused.\")\nend\ntpIdData[2].s = \"Seraphim\"", "\n-- Only for annotations\nreturn {", "the template-updater module return");
	}

	private static bool ValidateTemplateUpdater(string source)
	{
		if (ContainsText(source, "tpIdData[2].s = \"Seraphim\""))
		{
			return HasFourthFactionAppendixBeforeTerminalReturn(source, "\n-- Only for annotations\nreturn {");
		}
		return false;
	}

	private static string PlaceFourthFactionAppendixBeforeTerminalReturn(string source, string appendix, string terminalReturnAnchor, string description)
	{
		int num = CountOccurrences(source, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0");
		if (num > 1)
		{
			throw new InvalidOperationException("Expected at most one Seraphim marker while upgrading " + description + ".");
		}
		int num2 = source.LastIndexOf(terminalReturnAnchor, StringComparison.Ordinal);
		if (num2 < 0)
		{
			throw new InvalidOperationException("Could not locate " + description + ".");
		}
		if (num == 1)
		{
			int num3 = source.IndexOf("-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", StringComparison.Ordinal);
			if (num3 < num2)
			{
				return source;
			}
			source = source.Substring(0, num3).TrimEnd(Array.Empty<char>());
			num2 = source.LastIndexOf(terminalReturnAnchor, StringComparison.Ordinal);
			if (num2 < 0)
			{
				throw new InvalidOperationException("Could not retain " + description + " while upgrading its Seraphim suffix.");
			}
		}
		return source.Insert(num2, appendix);
	}

	private static bool HasFourthFactionAppendixBeforeTerminalReturn(string source, string terminalReturnAnchor)
	{
		if (CountOccurrences(source, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0") != 1)
		{
			return false;
		}
		int num = source.IndexOf("-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", StringComparison.Ordinal);
		int num2 = source.LastIndexOf(terminalReturnAnchor, StringComparison.Ordinal);
		if (num >= 0)
		{
			return num2 > num;
		}
		return false;
	}

	private static string TransformAvailableUnits(string source)
	{
		RequireTokens(source, "AvailableUnits =", "ucl0000", "ugl0000");
		return source + BuildTableAssignmentsAppendix("AvailableUnits");
	}

	private static string TransformQuickLaunchUnits(string source)
	{
		RequireTokens(source, "QuickLaunchUnits =", "ucl0000", "ugl0000");
		return source + BuildTableAssignmentsAppendix("QuickLaunchUnits");
	}

	private static string TransformConstructionBeamMaterial(string source)
	{
		string source2 = source;
		if (!ContainsText(source2, "elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then"))
		{
			source2 = ReplaceExactly(source2, "elseif table.find(tp.tags, \"CHOSEN\") then", "elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then", 1, "Chosen construction-beam material branch");
		}
		source2 = SeraphimPortOverrides.EnableClampPlayback(source2);
		source2 = EnableSeraphimNavalMovement(source2);
		if (!ContainsMarker(source2))
		{
			return source2 + MarkerAppendix();
		}
		return source2;
	}

	private static bool ValidateSeraphimUnitTemplateLoader(string source)
	{
		if (!ContainsText(source, "elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then"))
		{
			return false;
		}
		if (ContainsText(source, "Layers.GetGroundedNavigationLayerFromTemplate(tp)") || ContainsText(source, "table.insert(movementTemplates, EngineClasses.MovementTemplate(TemplateHeadEntityName,\n            false,\n            Layers.GetDefaultNavigationLayerFromTemplate(tp),\n            movement.speed,"))
		{
			return !ContainsText(source, "SCO_SeraphimMovementLayer");
		}
		if (ContainsText(source, "SCO_SeraphimMovementLayer"))
		{
			return ContainsText(source, "SCO_SeraphimMovementLayer,");
		}
		return false;
	}

	private static string EnableSeraphimNavalMovement(string source)
	{
		if (ContainsText(source, "Layers.GetGroundedNavigationLayerFromTemplate(tp)") || ContainsText(source, "table.insert(movementTemplates, EngineClasses.MovementTemplate(TemplateHeadEntityName,\n            false,\n            Layers.GetDefaultNavigationLayerFromTemplate(tp),\n            movement.speed,"))
		{
			return source;
		}
		if (ContainsText(source, "SCO_SeraphimMovementLayer"))
		{
			return source;
		}
		return ReplaceExactly(source, "        local capsuleInfo = Avoidance.getCapsuleInfo(tp.collisionInfo.collisionSize)\n\n        table.insert(movementTemplates, EngineClasses.MovementTemplate(TemplateHeadEntityName,\n            false,\n            0,\n            0,", "        local capsuleInfo = Avoidance.getCapsuleInfo(tp.collisionInfo.collisionSize)\n\n        -- Stock Sanctuary currently forces every movement template onto land.\n        -- Keep its stock behavior intact, but honor the authored navigation\n        -- layer for our fourth-faction ships and submarines.\n        local SCO_SeraphimMovementLayer = 0\n        if table.find(tp.tags, \"SERAPHIM\") then\n            SCO_SeraphimMovementLayer = Layers.GetNavigationLayer(tp)\n        end\n\n        table.insert(movementTemplates, EngineClasses.MovementTemplate(TemplateHeadEntityName,\n            false,\n            SCO_SeraphimMovementLayer,\n            0,", 1, "the stock movement-layer template");
	}

	private static string TransformNavigationLayers(string source)
	{
		if (IsDynamicNavigationLayerMap(source))
		{
			return PlaceFourthFactionAppendixBeforeTerminalReturn(source, MarkerAppendix(), "\n-- Only for annotations\nreturn {", "the dynamic navigation-layer module return");
		}
		string source2 = source;
		if (!ContainsText(source2, "    UnderWater      = NavigationLayer.Submarine,\n".Trim()))
		{
			source2 = ReplaceExactly(source2, "    WaterSurface    = NavigationLayer.Sea,\n", "    WaterSurface    = NavigationLayer.Sea,\n    UnderWater      = NavigationLayer.Submarine,\n", 1, "the WaterSurface navigation-layer map entry");
		}
		return PlaceFourthFactionAppendixBeforeTerminalReturn(source2, MarkerAppendix(), "\n-- Only for annotations\nreturn {", "the navigation-layer module return");
	}

	private static bool ValidateSeraphimNavigationLayers(string source)
	{
		if (IsDynamicNavigationLayerMap(source) || ContainsText(source, "UnderWater      = NavigationLayer.Submarine"))
		{
			return HasFourthFactionAppendixBeforeTerminalReturn(source, "\n-- Only for annotations\nreturn {");
		}
		return false;
	}

	private static bool IsDynamicNavigationLayerMap(string source)
	{
		if (ContainsText(source, "NavigationLayers = {}") && ContainsText(source, "LegsSeabed       = \"Amphibious\"") && ContainsText(source, "UnderWater       = \"Submarine\"") && ContainsText(source, "WaterSurface     = \"Sea\""))
		{
			if (!ContainsText(source, "function GetGroundedNavigationLayerFromTemplate"))
			{
				if (ContainsText(source, "function GetDefaultNavigationLayerFromTemplate(tp)") && ContainsText(source, "if tp.tags ~= nil and table.find(tp.tags, \"STRUCTURE\") then\n        return GetNavigationLayerByName(\"Land\")") && ContainsText(source, "local name = NavigationLayerByName[tp.movement.type]"))
				{
					return ContainsText(source, "return GetNavigationLayerByName(name)");
				}
				return false;
			}
			return true;
		}
		return false;
	}

	private static string TransformHostUnitsUtilities(string source)
	{
		if (ValidateHostUnitsUtilities(source))
		{
			return source;
		}
		string source2 = ReplaceExactly(StripMarkedHostUnitsUtilitiesRegistry(source), "local GetClass = GetClass\n", "local GetClass = GetClass\n\n-- SCO_SeraphimMovementRegistry\n-- Native movement owns land, seabed, hover, and air altitude. Register only\n-- ships/submarines whose authored root needs an explicit waterline or depth.\nlocal SCO_SeraphimMovementUnits = {}\n_G.SCO_SeraphimMovementUnits = SCO_SeraphimMovementUnits\n\nlocal function SCO_RegisterSeraphimMovementUnit(unit, unitTemplate)\n    local tags = unitTemplate and unitTemplate.tags or {}\n    if not table.find(tags, \"SERAPHIM\") or not table.find(tags, \"MOBILE\") then\n        return\n    end\n\n    local movement = unitTemplate.movement\n    local movementType = movement and movement.type\n    local general = unitTemplate.general\n    local waterlineOffset = general and general.waterlineOffset\n    local submergeDepth = general and general.submergeDepth\n    if movementType ~= \"WaterSurface\"\n        and movementType ~= \"UnderWater\"\n    then\n        return\n    end\n    if (movementType == \"WaterSurface\" and waterlineOffset == nil)\n        or (movementType == \"UnderWater\" and submergeDepth == nil)\n    then\n        return\n    end\n\n    SCO_SeraphimMovementUnits[unit.id.index] = {\n        unit = unit,\n        position = EngineClasses.float3(),\n        movementType = movementType,\n        waterlineOffset = waterlineOffset,\n        submergeDepth = submergeDepth,\n    }\nend\n\nlocal function SCO_UnregisterSeraphimMovementUnit(unit)\n    local id = unit and unit.id\n    if id then\n        SCO_SeraphimMovementUnits[id.index] = nil\n    end\nend\n", 1, "host unit-utility local declaration anchor");
		source2 = ReplaceExactly(source2, "    army:AddUnit(unit)\n", "    army:AddUnit(unit)\n    SCO_RegisterSeraphimMovementUnit(unit, unitTemplate)\n", 1, "host CreateUnit registration anchor");
		source2 = ReplaceExactly(source2, "function _G.RemoveUnit(unit)\n", "function _G.RemoveUnit(unit)\n    SCO_UnregisterSeraphimMovementUnit(unit)\n", 1, "host RemoveUnit registration anchor");
		source2 = (ContainsMarker(source2) ? source2 : (source2 + MarkerAppendix()));
		if (!ValidateHostUnitsUtilities(source2))
		{
			throw new InvalidOperationException("The Seraphim movement registry transform failed its postcondition.");
		}
		return source2;
	}

	private static bool ValidateHostUnitsUtilities(string source)
	{
		if (ContainsText(source, "-- SCO_SeraphimMovementRegistry") && ContainsText(source, "_G.SCO_SeraphimMovementUnits = SCO_SeraphimMovementUnits") && ContainsText(source, "table.find(tags, \"SERAPHIM\")") && ContainsText(source, "table.find(tags, \"MOBILE\")") && ContainsText(source, "Native movement owns land, seabed, hover, and air altitude") && ContainsText(source, "movementType ~= \"UnderWater\"") && ContainsText(source, "movementType == \"WaterSurface\" and waterlineOffset == nil") && ContainsText(source, "movementType == \"UnderWater\" and submergeDepth == nil") && ContainsText(source, "position = EngineClasses.float3()") && !ContainsText(source, "SCO_SeraphimElevationByUnit") && !ContainsText(source, "elevation = elevation") && CountOccurrences(source, "SCO_RegisterSeraphimMovementUnit") == 2)
		{
			return CountOccurrences(source, "SCO_UnregisterSeraphimMovementUnit") == 2;
		}
		return false;
	}

	private static string StripMarkedHostUnitsUtilitiesRegistry(string source)
	{
		int num = source.IndexOf("-- SCO_SeraphimMovementRegistry", StringComparison.Ordinal);
		if (num < 0)
		{
			if (ContainsMarker(source))
			{
				throw new InvalidOperationException("The marked host unit utilities have no recognized Seraphim movement registry.");
			}
			return source.TrimEnd(Array.Empty<char>());
		}
		if (source.IndexOf("-- SCO_SeraphimMovementRegistry", num + "-- SCO_SeraphimMovementRegistry".Length, StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("The host unit utilities have duplicate Seraphim movement registries.");
		}
		int num2 = source.IndexOf("local function SCO_UnregisterSeraphimMovementUnit(unit)", num, StringComparison.Ordinal);
		int num3 = ((num2 < 0) ? (-1) : source.IndexOf("    end\nend\n", num2, StringComparison.Ordinal));
		if (num3 < 0)
		{
			throw new InvalidOperationException("The marked Seraphim movement registry has no unregister boundary.");
		}
		num3 += "    end\nend\n".Length;
		if (num3 < source.Length && source[num3] == '\n')
		{
			num3++;
		}
		string text = ReplaceExactly(ReplaceExactly(source.Remove(num, num3 - num), "    SCO_RegisterSeraphimMovementUnit(unit, unitTemplate)\n", "", 1, "legacy host CreateUnit Seraphim registration"), "    SCO_UnregisterSeraphimMovementUnit(unit)\n", "", 1, "legacy host RemoveUnit Seraphim registration");
		int num4 = text.IndexOf("-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", StringComparison.Ordinal);
		if (num4 < 0)
		{
			throw new InvalidOperationException("The marked Seraphim movement registry has no terminating patch marker.");
		}
		if (!string.IsNullOrWhiteSpace(text.Substring(num4 + "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0".Length)))
		{
			throw new InvalidOperationException("The Seraphim movement registry marker is not the final host utility patch.");
		}
		return text.Substring(0, num4).TrimEnd(Array.Empty<char>());
	}

	private static string TransformHostUnitsUpdate(string source)
	{
		if (ValidateHostUnitsUpdate(source))
		{
			return source;
		}
		string text = StripMarkedHostUnitsUpdateAppendix(source) + "\n-- SCO_ApplySeraphimWaterHeights\n-- Native preferred-altitude movement owns all aircraft and hover units.\n-- Correct only authored surface-ship waterlines and explicit submarine depth\n-- at the same bounded 10 Hz cadence used by the reviewed ocean reference.\nlocal SCO_StockMovementUpdate = MovementUpdate\nlocal SCO_SeraphimMovementUpdateInterval = 2\nlocal SCO_SeraphimSubmergeDepth = 1.5\n\nlocal function SCO_GetCachedSeraphimTerrainHeight(entry, position)\n    if entry.terrainX ~= position.x\n        or entry.terrainZ ~= position.z\n        or entry.terrainHeight == nil\n    then\n        local _, terrainHeight = Engine.SampleTerrainHeight(position)\n        entry.terrainX = position.x\n        entry.terrainZ = position.z\n        entry.terrainHeight = terrainHeight\n    end\n    return entry.terrainHeight\nend\n\nlocal function SCO_ApplySeraphimWaterHeights(registry)\n    if registry == nil or next(registry) == nil then\n        return\n    end\n\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success or not hasWater then\n        return\n    end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then\n        return\n    end\n\n    for index, entry in pairs(registry) do\n        local unit = entry.unit\n        if unit == nil\n            or unit.dead\n            or __Entities.Units[index] ~= unit\n        then\n            registry[index] = nil\n        else\n            local position = entry.position\n            local positionResult =\n                Engine.GetGlobalEntityWorldPosition(unit.id, position)\n            local targetHeight = nil\n            if positionResult == EngineErrorCode.Success\n                and entry.movementType == \"WaterSurface\"\n            then\n                targetHeight = waterLevel + entry.waterlineOffset\n            elseif positionResult == EngineErrorCode.Success\n                and entry.movementType == \"UnderWater\"\n            then\n                local terrainHeight = SCO_GetCachedSeraphimTerrainHeight(entry, position)\n                local submergeDepth = entry.submergeDepth or SCO_SeraphimSubmergeDepth\n                targetHeight = math.max(terrainHeight + 0.1, waterLevel - submergeDepth)\n            end\n\n            if targetHeight ~= nil and math.abs(position.y - targetHeight) > 0.001 then\n                position.y = targetHeight\n                unit:SetPosition(position)\n            end\n        end\n    end\nend\n\nfunction MovementUpdate()\n    SCO_StockMovementUpdate()\n    if Tick % SCO_SeraphimMovementUpdateInterval == 0 then\n        SCO_ApplySeraphimWaterHeights(_G.SCO_SeraphimMovementUnits)\n    end\nend" + MarkerAppendix();
		if (!ValidateHostUnitsUpdate(text))
		{
			throw new InvalidOperationException("The Seraphim movement correction transform failed its postcondition.");
		}
		return text;
	}

	private static bool ValidateHostUnitsUpdate(string source)
	{
		int num = source.IndexOf("-- SCO_ApplySeraphimWaterHeights", StringComparison.Ordinal);
		if (num < 0 || source.IndexOf("-- SCO_ApplySeraphimWaterHeights", num + "-- SCO_ApplySeraphimWaterHeights".Length, StringComparison.Ordinal) >= 0)
		{
			return false;
		}
		string source2 = source.Substring(num);
		if (ContainsText(source2, "SCO_SeraphimMovementUpdateInterval = 2") && ContainsText(source2, "Tick % SCO_SeraphimMovementUpdateInterval") && ContainsText(source2, "local function SCO_ApplySeraphimWaterHeights(registry)") && ContainsText(source2, "SCO_ApplySeraphimWaterHeights(_G.SCO_SeraphimMovementUnits)") && ContainsText(source2, "for index, entry in pairs(registry) do") && ContainsText(source2, "__Entities.Units[index] ~= unit") && ContainsText(source2, "local position = entry.position") && ContainsText(source2, "Engine.GetGlobalEntityWorldPosition(unit.id, position)") && ContainsText(source2, "entry.terrainX ~= position.x") && ContainsText(source2, "entry.terrainZ ~= position.z") && ContainsText(source2, "registry[index] = nil") && ContainsText(source2, "waterResult ~= EngineErrorCode.Success") && ContainsText(source2, "levelResult ~= EngineErrorCode.Success") && CountOccurrences(source2, "Engine.SampleTerrainHeight") == 1 && !ContainsText(source2, "unit:GetPosition()") && !ContainsText(source2, "pairs(Units)") && !ContainsText(source2, "requiresWaterPlacement") && !ContainsText(source2, "SCO_SeraphimElevationByUnit"))
		{
			return !ContainsText(source2, "SCO_SeraphimContinuousHeight");
		}
		return false;
	}

	private static string StripMarkedHostUnitsUpdateAppendix(string source)
	{
		int num = source.IndexOf("-- SCO_ApplySeraphimWaterHeights", StringComparison.Ordinal);
		if (num < 0)
		{
			num = source.IndexOf("-- SCO_ApplySeraphimMovementHeights", StringComparison.Ordinal);
		}
		if (num < 0)
		{
			if (ContainsMarker(source))
			{
				throw new InvalidOperationException("The marked host movement update has no recognized Seraphim correction appendix.");
			}
			return source.TrimEnd(Array.Empty<char>());
		}
		if (source.IndexOf("-- SCO_ApplySeraphimWaterHeights", num + "-- SCO_ApplySeraphimWaterHeights".Length, StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("The host movement update has duplicate Seraphim correction appendices.");
		}
		int num2 = source.IndexOf("-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", num, StringComparison.Ordinal);
		if (num2 < 0)
		{
			throw new InvalidOperationException("The Seraphim correction appendix has no terminating patch marker.");
		}
		if (!string.IsNullOrWhiteSpace(source.Substring(num2 + "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0".Length)))
		{
			throw new InvalidOperationException("The Seraphim correction appendix is not the final host movement-update patch.");
		}
		return source.Substring(0, num).TrimEnd(Array.Empty<char>());
	}

	private static string TransformHostBuildOrder(string source)
	{
		if (ContainsText(source, "SCO_CanPlaceSeraphimWaterFactory"))
		{
			return source;
		}
		string text = source + "\n-- SCO_HostWaterPlacement\n-- The stock placement grid is terrain-agnostic for naval factories.  Keep\n-- the normal host checks first, then require a wholly submerged footprint and\n-- a submerged factory exit/rally lane for Seraphim naval factories.\nlocal SCO_StockHostBuildOrderIsOrderValid = HostBuildOrder.IsOrderValid\nlocal SCO_StockHostBuildOrderOrderStart = HostBuildOrder.OrderStart\nlocal SCO_SeraphimWaterPlacementMargin = 0.05\n\nlocal function SCO_RequiresSeraphimWaterPlacement(tp)\n    return tp and tp.general and tp.general.requiresWaterPlacement == true\nend\n\nlocal function SCO_IsSeraphimWaterPoint(position, waterLevel)\n    local _, terrainHeight = Engine.SampleTerrainHeight(position)\n    return terrainHeight < waterLevel - SCO_SeraphimWaterPlacementMargin\nend\n\nlocal function SCO_HasSubmergedSeraphimFootprint(position, tp, waterLevel)\n    local minX, minZ, maxX, maxZ = PlacementUtils.GetPlacementBounds(position, tp.skirtSize)\n    for x = minX, maxX do\n        for z = minZ, maxZ do\n            local _, terrainHeight = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(x, z))\n            if terrainHeight >= waterLevel - SCO_SeraphimWaterPlacementMargin then\n                return false\n            end\n        end\n    end\n    return true\nend\n\nlocal function SCO_HasUsableSeraphimNavalRollOff(position, tp, waterLevel)\n    local construction = tp.construction\n    for _, rollOff in ipairs((construction and construction.rollOffPoints) or {}) do\n        local offset = rollOff.offset\n        if offset then\n            local spawnPoint = EngineClasses.float3(\n                position.x + offset.x,\n                waterLevel,\n                position.z + offset.z\n            )\n            local rallyPoint = EngineClasses.float3(\n                position.x + offset.x * 2,\n                waterLevel,\n                position.z + offset.z * 2\n            )\n            if SCO_IsSeraphimWaterPoint(spawnPoint, waterLevel)\n                and SCO_IsSeraphimWaterPoint(rallyPoint, waterLevel)\n            then\n                return true\n            end\n        end\n    end\n    return false\nend\n\nlocal function SCO_CanPlaceSeraphimWaterFactory(position, tp)\n    local _, hasWater = Engine.HasWater()\n    if not hasWater then\n        return false\n    end\n\n    local _, waterLevel = Engine.GetWaterLevel()\n    return SCO_HasSubmergedSeraphimFootprint(position, tp, waterLevel)\n        and SCO_HasUsableSeraphimNavalRollOff(position, tp, waterLevel)\nend\n\nfunction HostBuildOrder:IsOrderValid()\n    if not SCO_StockHostBuildOrderIsOrderValid(self) then\n        return false\n    end\n    if SCO_RequiresSeraphimWaterPlacement(self.tp) then\n        return SCO_CanPlaceSeraphimWaterFactory(self.positionFloat3, self.tp)\n    end\n    return true\nend\n\nfunction HostBuildOrder:OrderStart()\n    if SCO_RequiresSeraphimWaterPlacement(self.tp) then\n        local _, hasWater = Engine.HasWater()\n        if hasWater then\n            local _, waterLevel = Engine.GetWaterLevel()\n            self.positionFloat3 = EngineClasses.float3(\n                self.positionFloat3.x,\n                waterLevel,\n                self.positionFloat3.z\n            )\n        end\n    end\n    return SCO_StockHostBuildOrderOrderStart(self)\nend";
		if (!ContainsMarker(text))
		{
			return text + MarkerAppendix();
		}
		return text;
	}

	private static string TransformConstructionPreview(string source)
	{
		if (ContainsMarker(source))
		{
			source = PlaceFourthFactionAppendixBeforeTerminalReturn(source, MarkerAppendix(), "\n--Only for annotataions\nreturn {", "the construction-preview module return");
		}
		if (ValidateConstructionPreview(source))
		{
			return source;
		}
		string text = PlaceFourthFactionAppendixBeforeTerminalReturn(InsertBeforeExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactlyOneOf(ReplaceExactly(source, "        if distance < closestDistance and CanPlaceAtArea(minX, minY, maxX, maxY, domain, true) then\n", "        if distance < closestDistance and CanPlaceAtArea(minX, minY, maxX, maxY, domain, true, unitTemplate, spotPosition) then\n", 1, "the resource-spot placement check"), "            if includeInvalid or CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor) then\n", "            if includeInvalid or CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, unitTemplate, point) then\n", "            if includeInvalid or (CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor) and OverhaulFactoryPlacementReservationsAreClear(point, unitTemplate)) then\n", "            if includeInvalid or (CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, unitTemplate, point) and OverhaulFactoryPlacementReservationsAreClear(point, unitTemplate)) then\n", "the structure-aware construction placement filter"), "                local targetHeight = PlacementUtils.GetPlacementHeight(unitTemplate, point.x, point.z)\n                table.insert(filteredPositions, EngineClasses.float3(point.x, targetHeight, point.z))", "                local targetHeight = PlacementUtils.GetPlacementHeight(unitTemplate, point.x, point.z)\n                if SCO_RequiresSeraphimWaterPlacement(unitTemplate) then\n                    targetHeight = SCO_GetSeraphimWaterPlacementHeight(point, targetHeight)\n                end\n                table.insert(filteredPositions, EngineClasses.float3(point.x, targetHeight, point.z))", 1, "the construction-preview placement height"), "            local hasInvalidCells = false\n            local cellIsValid = {}", "            local hasInvalidCells = false\n            local isWaterPlacement = SCO_RequiresSeraphimWaterPlacement(unitTemplate)\n            local waterLevel = isWaterPlacement and SCO_GetSeraphimWaterLevel() or nil\n            local waterRollOffIsValid = not isWaterPlacement\n                or (waterLevel ~= nil and SCO_CanPlaceSeraphimWaterFactory(unitTemplate, position))\n            local cellIsValid = {}", 1, "the construction-preview water-placement state"), "                    cellIsValid[x][y] = isValid\n", "                    isValid = isValid and (not isWaterPlacement\n                        or (waterRollOffIsValid and waterLevel ~= nil\n                            and SCO_IsSeraphimSubmergedCell(cellCoord, waterLevel)))\n                    cellIsValid[x][y] = isValid\n", 1, "the construction-preview cell validity branch"), "function FindClosestResourceSpot(position)", "-- SCO_ClientWaterPlacement\n-- Mirrors the host's narrow water-factory rule for local ghosts.  HostBuildOrder\n-- remains authoritative; this only prevents misleading green placement cells.\nlocal SCO_ClientWaterPlacementMargin = 0.05\n\nlocal function SCO_RequiresSeraphimWaterPlacement(tp)\n    return tp and tp.general and tp.general.requiresWaterPlacement == true\nend\n\nlocal function SCO_GetSeraphimWaterLevel()\n    local _, hasWater = Engine.HasWater()\n    if not hasWater then\n        return nil\n    end\n    local _, waterLevel = Engine.GetWaterLevel()\n    return waterLevel\nend\n\nlocal function SCO_IsSeraphimSubmergedCell(cell, waterLevel)\n    local _, terrainHeight = Engine.SampleTerrainHeightFromCell(cell)\n    return terrainHeight < waterLevel - SCO_ClientWaterPlacementMargin\nend\n\nlocal function SCO_IsSeraphimSubmergedPoint(position, waterLevel)\n    local _, terrainHeight = Engine.SampleTerrainHeight(position)\n    return terrainHeight < waterLevel - SCO_ClientWaterPlacementMargin\nend\n\nlocal function SCO_HasSubmergedSeraphimBounds(minX, minZ, maxX, maxZ, waterLevel)\n    for x = minX, maxX do\n        for z = minZ, maxZ do\n            if not SCO_IsSeraphimSubmergedCell(EngineClasses.int2(x, z), waterLevel) then\n                return false\n            end\n        end\n    end\n    return true\nend\n\nlocal function SCO_HasUsableSeraphimNavalRollOff(tp, position, waterLevel)\n    local minX, minZ, maxX, maxZ = PlacementUtils.GetPlacementBounds(position, tp.skirtSize)\n    if not SCO_HasSubmergedSeraphimBounds(minX, minZ, maxX, maxZ, waterLevel) then\n        return false\n    end\n\n    for _, rollOff in ipairs((tp.construction and tp.construction.rollOffPoints) or {}) do\n        local offset = rollOff.offset\n        if offset then\n            local spawnPoint = EngineClasses.float3(\n                position.x + offset.x,\n                waterLevel,\n                position.z + offset.z\n            )\n            local rallyPoint = EngineClasses.float3(\n                position.x + offset.x * 2,\n                waterLevel,\n                position.z + offset.z * 2\n            )\n            if SCO_IsSeraphimSubmergedPoint(spawnPoint, waterLevel)\n                and SCO_IsSeraphimSubmergedPoint(rallyPoint, waterLevel)\n            then\n                return true\n            end\n        end\n    end\n    return false\nend\n\nlocal function SCO_CanPlaceSeraphimWaterFactory(tp, position)\n    local waterLevel = SCO_GetSeraphimWaterLevel()\n    return waterLevel ~= nil and SCO_HasUsableSeraphimNavalRollOff(tp, position, waterLevel)\nend\n\nlocal function SCO_GetSeraphimWaterPlacementHeight(position, terrainHeight)\n    return SCO_GetSeraphimWaterLevel() or terrainHeight\nend\n\nlocal SCO_StockCanPlaceAtArea = CanPlaceAtArea\nfunction CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, tp, position)\n    if SCO_RequiresSeraphimWaterPlacement(tp)\n        and not SCO_CanPlaceSeraphimWaterFactory(tp, position)\n    then\n        return false\n    end\n    return SCO_StockCanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor)\nend\n", "the construction-preview resource search"), MarkerAppendix(), "\n--Only for annotataions\nreturn {", "the construction-preview module return");
		if (!ValidateConstructionPreview(text))
		{
			throw new InvalidOperationException("The composed construction-preview transform did not retain its water and reservation policies.");
		}
		return text;
	}

	private static bool ValidateConstructionPreview(string source)
	{
		if (!ContainsText(source, "SCO_CanPlaceSeraphimWaterFactory") || !ContainsText(source, "SCO_GetSeraphimWaterPlacementHeight") || !ContainsText(source, "SCO_CanPlaceSeraphimWaterFactory(unitTemplate, position)") || ContainsText(source, "SCO_CanPlaceSeraphimWaterFactory(position, unitTemplate)") || CountOccurrences(source, "CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, unitTemplate, point)") != 1)
		{
			return false;
		}
		if (!ContainsText(source, "OverhaulFactoryPlacementReservationsAreClear") || CountOccurrences(source, "CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, unitTemplate, point) and OverhaulFactoryPlacementReservationsAreClear(point, unitTemplate)") == 1)
		{
			return HasFourthFactionAppendixBeforeTerminalReturn(source, "\n--Only for annotataions\nreturn {");
		}
		return false;
	}

	private static string TransformShieldMaterials(string source)
	{
		return ReplaceExactly(source, "elseif table.find(tp.tags, \"CHOSEN\") then", "elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then", 2, "Chosen shield material branches") + MarkerAppendix();
	}

	private static string TransformTarmacMap(string source)
	{
		int num = source.IndexOf("c = _G.TarmacChosenPrefabID,", StringComparison.Ordinal);
		if (num < 0 || CountOccurrences(source, "c = _G.TarmacChosenPrefabID,") != 1)
		{
			throw new InvalidOperationException("Could not uniquely locate the Chosen tarmac map entry.");
		}
		int num2 = source.IndexOf('\n', num);
		if (num2 < 0)
		{
			throw new InvalidOperationException("The Chosen tarmac map entry did not end with a newline.");
		}
		return source.Insert(num2 + 1, "        s = _G.TarmacChosenPrefabID,\n") + MarkerAppendix();
	}

	private static string BuildImportScannerAppendix()
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0");
		stringBuilder.AppendLine("-- The FilesCache owns virtual us*.santp resources, but Engine.GetFoldersInsideDirectory");
		stringBuilder.AppendLine("-- only reports physical folders. Add these resources exactly once to the unit scan.");
		stringBuilder.AppendLine("local SCO_ScanDir = ScanDir");
		stringBuilder.AppendLine("function ScanDir(directory)");
		stringBuilder.AppendLine("    local folders = SCO_ScanDir(directory)");
		stringBuilder.AppendLine("    if directory ~= \"common/units/unitsTemplates/\" then");
		stringBuilder.AppendLine("        return folders");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local knownFolders = {}");
		stringBuilder.AppendLine("    for _, folder in ipairs(folders) do");
		stringBuilder.AppendLine("        knownFolders[folder] = true");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local seraphimFolders = {");
		TemplateRoute[] routes = SeraphimTemplateManifest.Routes;
		foreach (TemplateRoute templateRoute in routes)
		{
			stringBuilder.Append("        \"").Append(templateRoute.SeraphimId).AppendLine("\",");
		}
		stringBuilder.AppendLine("    }");
		stringBuilder.AppendLine("    for _, templateId in ipairs(seraphimFolders) do");
		stringBuilder.AppendLine("        local folder = directory .. templateId");
		stringBuilder.AppendLine("        if not knownFolders[folder] then");
		stringBuilder.AppendLine("            table.insert(folders, folder)");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    return folders");
		stringBuilder.AppendLine("end");
		return stringBuilder.ToString();
	}

	private static string BuildTableAssignmentsAppendix(string tableName)
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0");
		stringBuilder.AppendLine("-- Explicitly keep all virtual Seraphim templates loadable when either development gate is enabled.");
		TemplateRoute[] routes = SeraphimTemplateManifest.Routes;
		foreach (TemplateRoute templateRoute in routes)
		{
			stringBuilder.Append(tableName).Append("[\"").Append(templateRoute.SeraphimId)
				.AppendLine("\"] = true");
		}
		return stringBuilder.ToString();
	}

	private static string TemplateCloneAppendix(string targetId)
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0");
		stringBuilder.AppendLine("-- This cache-owned template starts as an independent copy of a Chosen donor.");
		stringBuilder.AppendLine("-- Only exact unit IDs, faction tags, build expressions, and class references are remapped;");
		stringBuilder.AppendLine("-- the donor file itself remains untouched for Chosen.");
		stringBuilder.AppendLine("do");
		stringBuilder.AppendLine("    local function SCO_RemapSeraphimValue(value, visited)");
		stringBuilder.AppendLine("        if type(value) == \"string\" then");
		stringBuilder.AppendLine("            value = string.gsub(value, \"Tags%.CHOSEN\", \"Tags.SERAPHIM\")");
		stringBuilder.AppendLine("            value = string.gsub(value, \"Tags%.uc([lsan])\", \"Tags.us%1\")");
		stringBuilder.AppendLine("            value = string.gsub(value, \"^uc([lsan])\", \"us%1\")");
		stringBuilder.AppendLine("            value = string.gsub(value, \"/uc([lsan])\", \"/us%1\")");
		stringBuilder.AppendLine("            return value");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("        if type(value) == \"table\" then");
		stringBuilder.AppendLine("            if visited[value] then");
		stringBuilder.AppendLine("                return value");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("            visited[value] = true");
		stringBuilder.AppendLine("            for key, child in pairs(value) do");
		stringBuilder.AppendLine("                value[key] = SCO_RemapSeraphimValue(child, visited)");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("        return value");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("    SCO_RemapSeraphimValue(UnitTemplate, {})");
		stringBuilder.AppendLine("    if UnitTemplate.general == nil then");
		stringBuilder.AppendLine("        error(\"Seraphim template clone has no general table.\")");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.Append("    UnitTemplate.general.tpId = \"").Append(targetId).AppendLine("\"");
		stringBuilder.AppendLine("    local replacedChosenTag = false");
		stringBuilder.AppendLine("    for index, tag in ipairs(UnitTemplate.tags or {}) do");
		stringBuilder.AppendLine("        if tag == \"CHOSEN\" then");
		stringBuilder.AppendLine("            UnitTemplate.tags[index] = \"SERAPHIM\"");
		stringBuilder.AppendLine("            replacedChosenTag = true");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("    if not replacedChosenTag then");
		stringBuilder.AppendLine("        error(\"Seraphim template clone expected a CHOSEN faction tag.\")");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("    local SCO_ClassMap = {");
		ClassRoute[] seraphimClassRoutes = SeraphimClassRoutes;
		foreach (ClassRoute classRoute in seraphimClassRoutes)
		{
			stringBuilder.Append("        [\"").Append(classRoute.ChosenClassName).Append("\"] = \"")
				.Append(classRoute.SeraphimClassName)
				.AppendLine("\",");
		}
		stringBuilder.AppendLine("    }");
		stringBuilder.AppendLine("    local classInfo = UnitTemplate.general.class");
		stringBuilder.AppendLine("    if classInfo == nil or classInfo[1] ~= \"unitsDefaultChosen\" then");
		stringBuilder.AppendLine("        error(\"Seraphim template clone expected the Chosen default class module.\")");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    classInfo[1] = \"unitsDefaultSeraphim\"");
		stringBuilder.AppendLine("    classInfo[2] = SCO_ClassMap[classInfo[2]]");
		stringBuilder.AppendLine("    if classInfo[2] == nil then");
		stringBuilder.AppendLine("        error(\"Seraphim template clone references an unmapped Chosen class.\")");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("end");
		return stringBuilder.ToString();
	}

	private static string TemplateMarkerAppendix(string targetId)
	{
		return "\n\n-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0\n-- Registered virtual Seraphim template " + targetId + ".\n";
	}

	private static string MarkerAppendix()
	{
		return "\n\n-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0\n";
	}

	private static string TemplateRelativePath(string templateId)
	{
		return "LJ/lua/common/units/unitsTemplates/" + templateId + "/" + templateId + ".santp";
	}

	private static void ValidateRegisteredSeraphimTemplate(string source, string targetId)
	{
		RequireTokens(source, "UnitTemplate", "\"" + targetId + "\"", "SERAPHIM", "unitsDefaultSeraphim");
		if (!ContainsText(source, "tpId = \"" + targetId + "\""))
		{
			throw new InvalidOperationException("Seraphim template " + targetId + " does not declare its own template ID.");
		}
		if (!ContainsText(source, "SCO_RemapSeraphimValue") && (ContainsText(source, "tpId = \"ucl") || ContainsText(source, "tpId = \"uca") || ContainsText(source, "tpId = \"ucn") || ContainsText(source, "tpId = \"ucs")))
		{
			throw new InvalidOperationException("Seraphim template " + targetId + " still declares a Chosen template ID.");
		}
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

	private static string ReplaceExactlyOneOf(string source, string firstOldValue, string firstNewValue, string secondOldValue, string secondNewValue, string description)
	{
		int num = CountOccurrences(source, firstOldValue);
		int num2 = CountOccurrences(source, secondOldValue);
		if (num + num2 != 1)
		{
			throw new InvalidOperationException($"Expected exactly one stock or composed {description}, found {num + num2}.");
		}
		if (num != 1)
		{
			return source.Replace(secondOldValue, secondNewValue);
		}
		return source.Replace(firstOldValue, firstNewValue);
	}

	private static string InsertBeforeExactly(string source, string anchor, string insertion, string description)
	{
		int num = source.IndexOf(anchor, StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Could not locate " + description + ".");
		}
		if (source.IndexOf(anchor, num + anchor.Length, StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("Found more than one " + description + ".");
		}
		return source.Insert(num, insertion);
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

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		byte[] bytes = Encoding.UTF8.GetBytes(source);
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, bytes);
	}

	private static object AppendOverride(object stockResource, string appendix)
	{
		Type type = stockResource.GetType();
		byte[] nativeArrayBytes = GetNativeArrayBytes(type, stockResource);
		byte[] bytes = Encoding.UTF8.GetBytes(appendix);
		return NativeArrayByteFactory.CreatePersistent(type, nativeArrayBytes, bytes);
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

	private static bool ContainsMarker(string source)
	{
		return ContainsText(source, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0");
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

	private static void SetOptionText(object? option, string expectedText, int index)
	{
		if (option == null)
		{
			throw new InvalidOperationException($"Faction dropdown option {index} is null.");
		}
		FieldInfo fieldInfo = option.GetType().GetField("itemName", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(option.GetType().FullName, "text");
		if (fieldInfo.IsInitOnly || fieldInfo.FieldType != typeof(string))
		{
			throw new InvalidOperationException($"Faction dropdown option {index} cannot accept the SCOM faction name.");
		}
		if (!string.Equals(fieldInfo.GetValue(option) as string, expectedText, StringComparison.Ordinal))
		{
			fieldInfo.SetValue(option, expectedText);
			option.GetType().GetField("localizationKey", BindingFlags.Instance | BindingFlags.Public)?.SetValue(option, string.Empty);
		}
	}

	private static bool ContainsCachedResource(object cache, string path)
	{
		object obj = (cache.GetType().GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "ContainsKey")).Invoke(cache, new object[1] { path });
		if (obj is bool)
		{
			return (bool)obj;
		}
		throw new InvalidOperationException(cache.GetType().FullName + ".ContainsKey did not return a Boolean value.");
	}

	private static void ValidateCachedByteIdentity(object cache, string path, object expectedResource, string description)
	{
		object obj = (cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("Cached " + description + " has no value after assignment.");
		EnsureNativeArray(obj, description);
		if (!GetNativeArrayBytes(obj.GetType(), obj).SequenceEqual(GetNativeArrayBytes(expectedResource.GetType(), expectedResource)))
		{
			throw new InvalidOperationException("Cached " + description + " failed byte-identity validation.");
		}
	}

	private static void Commit(object cache, IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			mutation.AssignmentWasAttempted = true;
			SetCachedResource(cache, mutation.Path, mutation.Replacement);
			ValidateCachedByteIdentity(cache, mutation.Path, mutation.Replacement, mutation.Description);
		}
	}

	private static void DisposeSupersededStocks(IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			if (!mutation.Added && mutation.Stock != null)
			{
				TryDisposeNativeArray(mutation.Stock.GetType(), mutation.Stock, "stock " + mutation.Description);
			}
		}
	}

	private static void RollBackAndDispose(object cache, IEnumerable<CacheMutation> mutations)
	{
		List<Exception> list = new List<Exception>();
		foreach (CacheMutation item in mutations.Reverse())
		{
			if (item.AssignmentWasAttempted)
			{
				try
				{
					if (item.Added)
					{
						RemoveCachedResource(cache, item.Path);
						if (ContainsCachedResource(cache, item.Path))
						{
							throw new InvalidOperationException("Cached " + item.Description + " remained present after rollback removal.");
						}
					}
					else
					{
						object obj = item.Stock ?? throw new InvalidOperationException(item.Description + " lost its stock resource.");
						SetCachedResource(cache, item.Path, obj);
						ValidateCachedByteIdentity(cache, item.Path, obj, "restored " + item.Description);
					}
					item.AssignmentWasAttempted = false;
				}
				catch (Exception innerException)
				{
					list.Add(new InvalidOperationException("Could not restore " + item.Description + "; the cache may still own its replacement.", innerException));
					continue;
				}
			}
			try
			{
				DisposeNativeArray(item.Replacement.GetType(), item.Replacement);
			}
			catch (Exception innerException2)
			{
				list.Add(new InvalidOperationException("Could not dispose replacement " + item.Description + ".", innerException2));
			}
		}
		if (list.Count != 0)
		{
			throw new AggregateException("The true fourth Seraphim faction cache rollback was incomplete.", list);
		}
	}

	private static void DisposeNativeArray(Type nativeArrayType, object nativeArray)
	{
		if (IsNativeArrayCreated(nativeArray))
		{
			(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
		}
	}

	private static void TryDisposeNativeArray(Type nativeArrayType, object nativeArray, string description)
	{
		try
		{
			DisposeNativeArray(nativeArrayType, nativeArray);
		}
		catch (Exception arg)
		{
			Log($"Could not dispose {description}: {arg}");
		}
	}

	private static Type FindLoadedType(string fullName)
	{
		Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
		for (int i = 0; i < assemblies.Length; i++)
		{
			Type type = assemblies[i].GetType(fullName, throwOnError: false);
			if ((object)type != null)
			{
				return type;
			}
		}
		throw new TypeLoadException("The required runtime type was not loaded: " + fullName);
	}

	private static void Log(string message)
	{
		try
		{
			string text = "[Seraphim Fourth Faction Cache Patcher] " + message;
			Console.WriteLine(text);
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => (object)type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}

	private static string UpgradeAirFactoryAim(string source, TemplateRoute route)
	{
		string text;
		string text2;
		string text3;
		string text4;
		switch (route.SeraphimId)
		{
		case "uss1512":
			if (route.ChosenId != "ucs1512")
			{
				throw new InvalidOperationException("Tier 1 Seraphim air-factory donor changed.");
			}
			text = "XSB0102";
			text2 = "2.5";
			text3 = "2.8";
			text4 = "1.4";
			break;
		case "uss2512":
			if (route.ChosenId != "ucs2512")
			{
				throw new InvalidOperationException("Tier 2 Seraphim air-factory donor changed.");
			}
			text = "XSB0202";
			text2 = "3.5";
			text3 = "2.7";
			text4 = "1.35";
			break;
		case "uss3512":
			if (route.ChosenId != "ucs3512")
			{
				throw new InvalidOperationException("Tier 3 Seraphim air-factory donor changed.");
			}
			text = "XSB0302";
			text2 = "4";
			text3 = "2.8";
			text4 = "1.4";
			break;
		default:
			return source;
		}
		string needle = "UnitTemplate.collisionInfo = {\n    centerOffset = {\n        x = 0,\n        y = " + text4 + ",\n        z = 0,\n    },\n    collisionSize = {\n        x = " + text2 + ",\n        y = " + text3 + ",\n        z = " + text2 + ",\n    },\n}";
		string needle2 = "-- Apply the audited " + text + " gameplay contract";
		string needle3 = "-- Supreme Commander Overhaul Seraphim source gameplay 2.1 " + route.SeraphimId;
		if (CountOccurrences(source, needle2) != 1 || CountOccurrences(source, needle3) != 1 || CountOccurrences(source, needle) != 1 || CountOccurrences(source, "UnitTemplate.collisionInfo = {") != 1)
		{
			throw new InvalidOperationException("Seraphim air-factory source ID or collision box changed for " + route.SeraphimId + ".");
		}
		string text5 = "-- Supreme Commander Overhaul Seraphim grounded air-factory aim 1.0 " + route.SeraphimId;
		string text6 = "UnitTemplate.collisionInfo.targetBones = { \"Target_Bottom\" }";
		string text7 = "\n" + text5 + "\n-- FA has Target_Top and Target_Bottom; ground fire uses the lower, stable source bone.\nif UnitTemplate.general.tpId ~= \"" + route.SeraphimId + "\"\n    or UnitTemplate.collisionInfo.centerOffset.x ~= 0\n    or UnitTemplate.collisionInfo.centerOffset.y ~= " + text4 + "\n    or UnitTemplate.collisionInfo.centerOffset.z ~= 0\n    or UnitTemplate.collisionInfo.collisionSize.x ~= " + text2 + "\n    or UnitTemplate.collisionInfo.collisionSize.y ~= " + text3 + "\n    or UnitTemplate.collisionInfo.collisionSize.z ~= " + text2 + " then\n    error(\"Seraphim air-factory aim contract changed: " + route.SeraphimId + "\")\nend\n" + text6 + "\n";
		int num = CountOccurrences(source, "UnitTemplate.collisionInfo.targetBones =");
		if (CountOccurrences(source, text5) == 1 && CountOccurrences(source, text7) == 1 && num == 1)
		{
			return source;
		}
		if (CountOccurrences(source, text5) != 0 || num != 0)
		{
			throw new InvalidOperationException("Seraphim air-factory aim override is mixed or unknown for " + route.SeraphimId + ".");
		}
		return source + text7;
	}

	private static bool HasAirFactoryAim(string source, TemplateRoute route)
	{
		if (route.SeraphimId != "uss1512" && route.SeraphimId != "uss2512" && route.SeraphimId != "uss3512")
		{
			return true;
		}
		return source == UpgradeAirFactoryAim(source, route);
	}
}
