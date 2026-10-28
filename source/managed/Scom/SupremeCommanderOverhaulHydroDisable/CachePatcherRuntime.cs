using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using ScomRepair20260913;
using SupremeCommanderOverhaulCanonical;

namespace SupremeCommanderOverhaulHydroDisable;

public static class CachePatcherRuntime
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

	private sealed class CacheMutation
	{
		public CachedResource Resource { get; }

		public string Description { get; }

		public string OldSource { get; }

		public string NewSource { get; }

		public bool NeedsWrite => !string.Equals(OldSource, NewSource, StringComparison.Ordinal);

		public object? Replacement { get; set; }

		public bool Assigned { get; set; }

		public CacheMutation(CachedResource resource, string description, string oldSource, string newSource)
		{
			Resource = resource;
			Description = description;
			OldSource = oldSource;
			NewSource = newSource;
		}
	}

	private sealed class RollbackException : Exception
	{
		public RollbackException(string message, Exception innerException)
			: base(message, innerException)
		{
		}
	}

	public const string Marker = "-- Supreme Commander Overhaul hydro build disable 1.0.0";

	public const string AvailableUnitsPath = "LJ/lua/common/units/availableUnits.lua";

	public const string HostBuildOrderPath = "LJ/lua/host/managers/orders/orderClasses/hostBuildOrder.lua";

	public const string ExpectedScomSha256 = "3EED7306200D5910786221547FF0FB959FA8CF92C85C99D62B98A12175C28B76";

	public const string ExpectedScomMvid = "48dd1991-b31b-4297-bd60-0597d33328b5";

	public const long ExpectedScomBytes = 3819520L;

	public const string ExpectedGeneratorSha256 = "4981EFE18ECF6BE6F47DF8996564808B0AC8C7CF22FADAF6F1490B44B34D355C";

	public const string ExpectedGeneratorMvid = "29e22108-0a14-4ec3-be24-b65214f2ecf5";

	public const long ExpectedGeneratorBytes = 56832L;

	public static readonly HydroTemplateSpec ChosenHydro = new HydroTemplateSpec("ucs1614", "CHOSEN");

	public static readonly HydroTemplateSpec SeraphimHydro = new HydroTemplateSpec("uss1614", "SERAPHIM");

	private const string ScomRuntimeType = "SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime";

	private const string GeneratorRuntimeType = "SupremeCommanderOverhaulGeneratorBuildability.CachePatcherRuntime";

	private const string AeonMarker = "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0";

	private const string SeraphimMarker = "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0";

	private const string SeraphimGameplayMarker = "-- Supreme Commander Overhaul Seraphim source gameplay 2.1 uss1614";

	private const string SeraphimTagsMarker = "-- Supreme Commander Overhaul Seraphim canonical resource tags 1.0 uss1614";

	private const string PlacementMarker = "-- Supreme Commander Overhaul Structure Placement Contract 1.0.1";

	private const string StockValidateOrder = "function HostBuildOrder:ValidateOrder()\n    if (self.unitGettingBuilt and self.unitGettingBuilt.dead) or not self:IsOrderValid() then\n        return false\n    end\n\n    return true\nend";

	private const string StockOrderStart = "function HostBuildOrder:OrderStart()\n    HostBaseOrder:OrderStart()\n    self.unitGettingBuilt = CreateUnit(self.armyId, self.tp.general.tpId, self.positionFloat3, nil, 0)\nend";

	private static readonly string[] BuildTags = new string[3] { "BUILDABLE_BY_T1_ENGINEER", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER" };

	private static bool _isApplied;

	public static IReadOnlyList<string> ManagedPaths => new string[4] { ChosenHydro.RelativePath, SeraphimHydro.RelativePath, "LJ/lua/common/units/availableUnits.lua", "LJ/lua/host/managers/orders/orderClasses/hostBuildOrder.lua" };

	public static void Apply()
	{
		if (_isApplied)
		{
			return;
		}
		try
		{
			ValidateUpstreamIdentity();
			object luaFileCache = GetLuaFileCache();
			List<CacheMutation> list = BuildMutationPlans(luaFileCache);
			if (list.Count != 0)
			{
				Commit(luaFileCache, list);
			}
			_isApplied = true;
			Log("Installed mock Hydro template/availability policy; native placement checks retained. Four-faction provider is supplied by the Field Fixes stage.");
		}
		catch (RollbackException)
		{
			throw;
		}
		catch (Exception)
		{
			throw;
		}
	}

	public static string PatchHydroTemplateSource(string source, HydroTemplateSpec spec)
	{
		if (string.IsNullOrWhiteSpace(source) || (spec != ChosenHydro && spec != SeraphimHydro))
		{
			throw new InvalidOperationException("SCOM mock Hydro: missing source or unknown template specification.");
		}
		ValidateUpstreamTemplate(source, spec);
		return CacheCompatibilityRepair.AppendMockHydroPolicy(source, BuildTemplateAppendix(spec), (spec == ChosenHydro) ? "-- Supreme Commander Overhaul hydro build disable 1.0.0\ndo\n    local scoHydroExpected = {\n        BUILDABLE_BY_T1_ENGINEER = true,\n        BUILDABLE_BY_T2_ENGINEER = true,\n        BUILDABLE_BY_T3_ENGINEER = true,\n        [\"CHOSEN\"] = true,\n        ECONOMIC = true,\n        ENERGY_PRODUCTION = true,\n        STRUCTURE = true,\n        TECH1 = true,\n    }\n    local scoHydroSeen = {}\n    if type(UnitTemplate.tags) ~= \"table\" or #UnitTemplate.tags ~= 8 then\n        error(\"ucs1614 hydro tag contract changed before disable\")\n    end\n    for _, tag in ipairs(UnitTemplate.tags) do\n        if scoHydroExpected[tag] ~= true or scoHydroSeen[tag] then\n            error(\"ucs1614 hydro tag contract is unknown or duplicated\")\n        end\n        scoHydroSeen[tag] = true\n    end\n    local scoHydroRemoved = 0\n    for index = #UnitTemplate.tags, 1, -1 do\n        local tag = UnitTemplate.tags[index]\n        if tag == \"BUILDABLE_BY_T1_ENGINEER\"\n            or tag == \"BUILDABLE_BY_T2_ENGINEER\"\n            or tag == \"BUILDABLE_BY_T3_ENGINEER\" then\n            table.remove(UnitTemplate.tags, index)\n            scoHydroRemoved = scoHydroRemoved + 1\n        end\n    end\n    if scoHydroRemoved ~= 3 then\n        error(\"ucs1614 hydro disable did not remove exactly three engineer tags\")\n    end\n    if #UnitTemplate.tags ~= 5 then\n        error(\"ucs1614 hydro disable changed a preserved tag\")\n    end\nend\n" : "-- Supreme Commander Overhaul hydro build disable 1.0.0\ndo\n    local scoHydroExpected = {\n        BUILDABLE_BY_T1_ENGINEER = true,\n        BUILDABLE_BY_T2_ENGINEER = true,\n        BUILDABLE_BY_T3_ENGINEER = true,\n        [\"SERAPHIM\"] = true,\n        ECONOMIC = true,\n        ENERGY_PRODUCTION = true,\n        STRUCTURE = true,\n        TECH1 = true,\n    }\n    local scoHydroSeen = {}\n    if type(UnitTemplate.tags) ~= \"table\" or #UnitTemplate.tags ~= 8 then\n        error(\"uss1614 hydro tag contract changed before disable\")\n    end\n    for _, tag in ipairs(UnitTemplate.tags) do\n        if scoHydroExpected[tag] ~= true or scoHydroSeen[tag] then\n            error(\"uss1614 hydro tag contract is unknown or duplicated\")\n        end\n        scoHydroSeen[tag] = true\n    end\n    local scoHydroRemoved = 0\n    for index = #UnitTemplate.tags, 1, -1 do\n        local tag = UnitTemplate.tags[index]\n        if tag == \"BUILDABLE_BY_T1_ENGINEER\"\n            or tag == \"BUILDABLE_BY_T2_ENGINEER\"\n            or tag == \"BUILDABLE_BY_T3_ENGINEER\" then\n            table.remove(UnitTemplate.tags, index)\n            scoHydroRemoved = scoHydroRemoved + 1\n        end\n    end\n    if scoHydroRemoved ~= 3 then\n        error(\"uss1614 hydro disable did not remove exactly three engineer tags\")\n    end\n    if #UnitTemplate.tags ~= 5 then\n        error(\"uss1614 hydro disable changed a preserved tag\")\n    end\nend\n");
	}

	public static string PatchAvailableUnitsSource(string source)
	{
		return CacheCompatibilityRepair.AppendMockHydroPolicy(source, "\n-- SCOM mock Hydro placement 2.1.88.6\n-- Availability does not bypass native construction validation or builder tags.\ndo\n    assert(type(AvailableUnits) == \"table\", \"SCOM mock Hydro: missing availability table\")\n    for _, id in ipairs({\"ucs1614\", \"ues5015\", \"ugs5003\", \"uss1614\"}) do\n        AvailableUnits[id] = true\n    end\nend\n-- End SCOM mock Hydro placement 2.1.88.6\n", "-- Supreme Commander Overhaul hydro build disable 1.0.0\ndo\n    if AvailableUnits[\"ucs1614\"] ~= true\n        or AvailableUnits[\"uss1614\"] ~= true then\n        error(\"hydro availability contract changed before disable\")\n    end\n    AvailableUnits[\"ucs1614\"] = false\n    AvailableUnits[\"uss1614\"] = false\nend\n");
	}

	public static string PatchHostBuildOrderSource(string source)
	{
		return CacheCompatibilityRepair.AppendMockHydroPolicy(source, "\n-- SCOM mock Hydro placement 2.1.88.6\n-- Do not add a deposit-only rejection or force a native ValidateOrder result.\ndo\n    assert(type(HostBuildOrder) == \"table\" and type(HostBuildOrder.ValidateOrder) == \"function\",\n        \"SCOM mock Hydro: native host build-order validator is missing\")\nend\n-- End SCOM mock Hydro placement 2.1.88.6\n", "-- Supreme Commander Overhaul hydro build disable 1.0.0\nlocal SCO_HydroDisablePreviousValidateOrder = HostBuildOrder.ValidateOrder\nfunction HostBuildOrder:ValidateOrder()\n    if self.tpId == \"ucs1614\" or self.tpId == \"uss1614\" then\n        return false\n    end\n    return SCO_HydroDisablePreviousValidateOrder(self)\nend\n");
	}

	private static void ValidateUpstreamTemplate(string source, HydroTemplateSpec spec)
	{
		CacheCompatibilityRepair.LastCodeDeclarationIndex(CacheCompatibilityRepair.CanonicalLuaForProgress(source), string.Concat("tpId = \"" + spec.TargetId, "\""), spec.TargetId);
	}

	private static void ValidatePatchedTemplate(string source, HydroTemplateSpec spec)
	{
		if (source.IndexOf(BuildTemplateAppendix(spec), StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("SCOM mock Hydro: complete installed policy is missing.");
		}
	}

	private static void ValidateAvailableUpstream(string source)
	{
		if (source.IndexOf("AvailableUnits", StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("SCOM mock Hydro: required native declaration missing: AvailableUnits");
		}
	}

	private static void ValidatePatchedAvailableUnits(string source)
	{
		if (source.IndexOf(BuildAvailableUnitsAppendix(), StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("SCOM mock Hydro: complete installed policy is missing.");
		}
	}

	private static void ValidateHostBuildOrderUpstream(string source)
	{
		if (source.IndexOf("HostBuildOrder", StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("SCOM mock Hydro: required native declaration missing: HostBuildOrder");
		}
	}

	private static void ValidatePatchedHostBuildOrder(string source)
	{
		if (source.IndexOf(BuildHostBuildOrderAppendix(), StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("SCOM mock Hydro: complete installed policy is missing.");
		}
	}

	private static string[] ReadFinalLiteralTagAssignment(string source, string targetId)
	{
		int num = source.LastIndexOf("UnitTemplate.tags = {", StringComparison.Ordinal);
		if (num < 0)
		{
			throw Incompatible(targetId + " has no final literal UnitTemplate.tags assignment.");
		}
		int num2 = source.IndexOf('\n', num + "UnitTemplate.tags = {".Length);
		int num3 = ((num2 < 0) ? (-1) : source.IndexOf("\n}", num2 + 1, StringComparison.Ordinal));
		if (num2 < 0 || num3 < 0)
		{
			throw Incompatible(targetId + " final tag assignment is malformed.");
		}
		List<string> list = new List<string>();
		string[] array = source.Substring(num2 + 1, num3 - num2 - 1).Split(new char[1] { '\n' }, StringSplitOptions.RemoveEmptyEntries);
		for (int i = 0; i < array.Length; i++)
		{
			string text = array[i].Trim();
			if (text.Length < 4 || text[0] != '"' || !text.EndsWith("\",", StringComparison.Ordinal))
			{
				throw Incompatible(targetId + " final tag line is not canonical: " + text);
			}
			list.Add(text.Substring(1, text.Length - 3));
		}
		if (list.Count == 0 || list.Distinct(StringComparer.Ordinal).Count() != list.Count)
		{
			throw Incompatible(targetId + " final tag assignment is empty or duplicated.");
		}
		return list.ToArray();
	}

	private static string BuildTemplateAppendix(HydroTemplateSpec spec)
	{
		return "\n-- SCOM mock Hydro placement 2.1.88.6\n-- Compatibility policy, not a native Hydro resource or terrain modification.\ndo\n    local tp = UnitTemplate\n    assert(type(tp) == \"table\" and type(tp.general) == \"table\"\n        and tp.general.tpId == \"__TARGET__\", \"SCOM mock Hydro: target identity changed (__TARGET__)\")\n    assert(type(tp.tags) == \"table\", \"SCOM mock Hydro: missing tags (__TARGET__)\")\n    local seen = {}\n    for _, tag in ipairs(tp.tags) do seen[tag] = true end\n    for _, tag in ipairs({\"__FACTION__\", \"ECONOMIC\", \"ENERGY_PRODUCTION\", \"STRUCTURE\", \"TECH1\"}) do\n        assert(seen[tag], \"SCOM mock Hydro: missing required tag \" .. tag .. \" (__TARGET__)\")\n    end\n    assert(tp.additions == nil or type(tp.additions) == \"table\", \"SCOM mock Hydro: invalid additions (__TARGET__)\")\n    local additions = tp.additions or {}\n    local function CopyPolicy(value, field)\n        assert(value == nil or type(value) == \"table\", \"SCOM mock Hydro: invalid \" .. field .. \" (__TARGET__)\")\n        local result = {}\n        for key, item in pairs(value or {}) do result[key] = item end\n        return result\n    end\n    -- Validate and copy before committing either declaration. Keep provenance.\n    local fa = CopyPolicy(additions.faHydrocarbonPlacement, \"faHydrocarbonPlacement\")\n    local sco = CopyPolicy(additions.scoHydroPlacement, \"scoHydroPlacement\")\n    fa.sourceRequirement = \"hydrocarbon_deposit\"\n    fa.supported = true\n    fa.nativeResourceSupported = false\n    fa.mock = true\n    fa.fallback = \"mock_land_placement\"\n    sco.normalConstructionSupported = true\n    sco.nativeResourceSupported = false\n    sco.mock = true\n    sco.fallback = \"mock_land_placement\"\n    sco.reason = \"Mock Hydro uses ordinary native land placement; no deposit is required.\"\n    sco.creativeDirectSpawnPreserved = true\n    sco.nativePlacementValidation = true\n    sco.mockPlacementVersion = \"2.1.88.6\"\n    tp.additions = additions\n    additions.faHydrocarbonPlacement = fa\n    additions.scoHydroPlacement = sco\n    for _, tag in ipairs({\"BUILDABLE_BY_T1_ENGINEER\", \"BUILDABLE_BY_T2_ENGINEER\", \"BUILDABLE_BY_T3_ENGINEER\"}) do\n        if not seen[tag] then tp.tags[#tp.tags + 1] = tag; seen[tag] = true end\n    end\nend\n-- End SCOM mock Hydro placement 2.1.88.6\n".Replace("__TARGET__", spec.TargetId).Replace("__FACTION__", spec.FactionTag);
	}

	private static string BuildAvailableUnitsAppendix()
	{
		return "\n-- SCOM mock Hydro placement 2.1.88.6\n-- Availability does not bypass native construction validation or builder tags.\ndo\n    assert(type(AvailableUnits) == \"table\", \"SCOM mock Hydro: missing availability table\")\n    for _, id in ipairs({\"ucs1614\", \"ues5015\", \"ugs5003\", \"uss1614\"}) do\n        AvailableUnits[id] = true\n    end\nend\n-- End SCOM mock Hydro placement 2.1.88.6\n";
	}

	private static string BuildHostBuildOrderAppendix()
	{
		return "\n-- SCOM mock Hydro placement 2.1.88.6\n-- Do not add a deposit-only rejection or force a native ValidateOrder result.\ndo\n    assert(type(HostBuildOrder) == \"table\" and type(HostBuildOrder.ValidateOrder) == \"function\",\n        \"SCOM mock Hydro: native host build-order validator is missing\")\nend\n-- End SCOM mock Hydro placement 2.1.88.6\n";
	}

	private static List<CacheMutation> BuildMutationPlans(object cache)
	{
		return new List<CacheMutation>
		{
			CreateMutation(cache, ChosenHydro.RelativePath, "Chosen hydro template", (string source) => PatchHydroTemplateSource(source, ChosenHydro)),
			CreateMutation(cache, SeraphimHydro.RelativePath, "Seraphim hydro template", (string source) => PatchHydroTemplateSource(source, SeraphimHydro)),
			CreateMutation(cache, "LJ/lua/common/units/availableUnits.lua", "available-unit table", PatchAvailableUnitsSource),
			CreateMutation(cache, "LJ/lua/host/managers/orders/orderClasses/hostBuildOrder.lua", "host build-order validator", PatchHostBuildOrderSource)
		}.Where((CacheMutation plan) => plan.NeedsWrite).ToList();
	}

	private static CacheMutation CreateMutation(object cache, string relativePath, string description, Func<string, string> transform)
	{
		CachedResource cachedResource = GetCachedResource(cache, relativePath);
		string text = ReadText(cachedResource.Value);
		return new CacheMutation(cachedResource, description, text, transform(text));
	}

	private static void Commit(object cache, IList<CacheMutation> plans)
	{
		try
		{
			foreach (CacheMutation plan in plans)
			{
				plan.Replacement = CreateNativeArrayFromText(plan.Resource.Value.GetType(), plan.NewSource);
			}
			foreach (CacheMutation plan2 in plans)
			{
				plan2.Assigned = true;
				SetCachedResource(cache, plan2.Resource.Path, plan2.Replacement);
				if (!string.Equals(ReadText(GetExactCachedResource(cache, plan2.Resource.Path)), plan2.NewSource, StringComparison.Ordinal))
				{
					throw new InvalidOperationException(plan2.Description + " cache write verification failed.");
				}
			}
		}
		catch (Exception ex)
		{
			List<Exception> list = new List<Exception>();
			foreach (CacheMutation item2 in plans.Reverse())
			{
				if (!item2.Assigned)
				{
					continue;
				}
				try
				{
					SetCachedResource(cache, item2.Resource.Path, item2.Resource.Value);
					if (!string.Equals(ReadText(GetExactCachedResource(cache, item2.Resource.Path)), item2.OldSource, StringComparison.Ordinal))
					{
						throw new InvalidOperationException(item2.Description + " rollback verification failed.");
					}
					item2.Assigned = false;
				}
				catch (Exception item)
				{
					list.Add(item);
				}
			}
			foreach (CacheMutation plan3 in plans)
			{
				if (!plan3.Assigned && plan3.Replacement != null)
				{
					TryDispose(plan3.Replacement, "rolled-back " + plan3.Description);
				}
			}
			if (list.Count != 0)
			{
				throw new RollbackException("Hydro-disable mutation and rollback both failed.", new AggregateException(new Exception[1] { ex }.Concat(list)));
			}
			throw;
		}
		foreach (CacheMutation plan4 in plans)
		{
			TryDispose(plan4.Resource.Value, "replaced " + plan4.Description);
		}
	}

	private static void ValidateUpstreamIdentity()
	{
		CachePatcher.ValidateMvid(FindLoadedType("EM.Lua.FilesCache").Module.ModuleVersionId);
		CanonicalAssemblyContract.RequireCanonicalTypes("SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime", "SupremeCommanderOverhaulGeneratorBuildability.CachePatcherRuntime", "SupremeCommanderOverhaulHydroDisable.CachePatcherRuntime");
	}

	private static void ValidateAssemblyIdentity(Assembly assembly, string expectedMvid, string expectedHash, long expectedBytes, string description)
	{
		string text = assembly.ManifestModule.ModuleVersionId.ToString("D");
		if (!string.Equals(text, expectedMvid, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException(description + " MVID drifted: expected " + expectedMvid + ", found " + text + ".");
		}
		string location = assembly.Location;
		if (string.IsNullOrWhiteSpace(location) || !File.Exists(location))
		{
			throw new InvalidOperationException(description + " has no verifiable location.");
		}
		FileInfo fileInfo = new FileInfo(location);
		if (fileInfo.Length != expectedBytes)
		{
			throw new InvalidOperationException($"{description} size drifted: expected {expectedBytes}, found {fileInfo.Length}.");
		}
		using FileStream inputStream = File.OpenRead(location);
		using SHA256 sHA = SHA256.Create();
		string text2 = BitConverter.ToString(sHA.ComputeHash(inputStream)).Replace("-", "");
		if (!string.Equals(text2, expectedHash, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException(description + " SHA-256 drifted: expected " + expectedHash + ", found " + text2 + ".");
		}
	}

	private static Type FindLoadedType(string fullName)
	{
		Type[] array = (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType(fullName, throwOnError: false) into type
			where type != null
			select type).Cast<Type>().ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException($"Expected one loaded {fullName} type, found {array.Length}.");
		}
		return array[0];
	}

	private static object GetLuaFileCache()
	{
		Type type = FindLoadedType("EM.Lua.FilesCache");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
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
		EnsureCreated(resource, "Lua cache resource");
		byte[] bytes = ((resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null) as byte[]) ?? throw new InvalidOperationException("NativeArray.ToArray returned null.");
		return Encoding.UTF8.GetString(bytes);
	}

	private static object CreateNativeArrayFromText(Type type, string source)
	{
		if (!type.IsGenericType || type.GetGenericArguments().Single() != typeof(byte))
		{
			throw new ArgumentException("Expected Unity NativeArray<byte>.", "type");
		}
		Type type2 = type.Assembly.GetType("Unity.Collections.Allocator", throwOnError: false) ?? throw new TypeLoadException("Unity.Collections.Allocator is unavailable.");
		return (type.GetConstructor(new Type[2]
		{
			typeof(byte[]),
			type2
		}) ?? throw new MissingMethodException(type.FullName, ".ctor(Byte[], Allocator)")).Invoke(new object[2]
		{
			Encoding.UTF8.GetBytes(source),
			Enum.Parse(type2, "Persistent")
		});
	}

	private static void EnsureCreated(object resource, string description)
	{
		object value = (resource.GetType().GetProperty("IsCreated") ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource, null);
		if (!(value is bool) || !(bool)value)
		{
			throw new InvalidOperationException("Cached " + description + " is not initialized.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item") ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static object GetExactCachedResource(object cache, string path)
	{
		return (cache.GetType().GetProperty("Item") ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("Cache returned null for " + path + ".");
	}

	private static void TryDispose(object resource, string description)
	{
		try
		{
			object obj = resource.GetType().GetProperty("IsCreated")?.GetValue(resource, null);
			if (obj is bool && (bool)obj)
			{
				(resource.GetType().GetMethod("Dispose", Type.EmptyTypes) ?? throw new MissingMethodException(resource.GetType().FullName, "Dispose")).Invoke(resource, null);
			}
		}
		catch (Exception ex)
		{
			Log("NativeArray cleanup warning for " + description + ": " + ex.GetBaseException().Message);
		}
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = Count(source, token);
		if (num != expected)
		{
			throw Incompatible($"Expected {expected} {description} token(s), found {num}.");
		}
	}

	private static void RequireAtLeast(string source, string token, int expected, string description)
	{
		int num = Count(source, token);
		if (num < expected)
		{
			throw Incompatible($"Expected at least {expected} {description} token(s), found {num}.");
		}
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
		return source.Replace("\r\n", "\n").Replace('\r', '\n');
	}

	private static InvalidOperationException Incompatible(string message)
	{
		return new InvalidOperationException("Incompatible upstream cache source: " + message);
	}

	private static void Log(string message)
	{
		string text = "[SCOM Mock Hydro 2.1.88.6] " + message;
		try
		{
			Console.WriteLine(text);
		}
		catch
		{
		}
		try
		{
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}
}
