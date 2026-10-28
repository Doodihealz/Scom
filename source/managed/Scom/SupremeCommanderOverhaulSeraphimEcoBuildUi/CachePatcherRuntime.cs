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

namespace SupremeCommanderOverhaulSeraphimEcoBuildUi;

public static class CachePatcherRuntime
{
	private sealed class CacheResource
	{
		public string Path { get; }

		public object Value { get; }

		public CacheResource(string path, object value)
		{
			Path = path;
			Value = value;
		}
	}

	private sealed class BuilderContract
	{
		public string Id { get; }

		public int Tier { get; }

		public BuilderContract(string id, int tier)
		{
			Id = id;
			Tier = tier;
		}
	}

	private sealed class ResourceContract
	{
		public string Id { get; }

		public int MinimumBuilderTier { get; }

		public IReadOnlyList<string> Tags { get; }

		public ResourceContract(string id, int minimumBuilderTier, params string[] tags)
		{
			Id = id;
			MinimumBuilderTier = minimumBuilderTier;
			Tags = tags;
		}
	}

	private sealed class MutationPlan
	{
		public string Path { get; }

		public object Stock { get; }

		public string OldSource { get; }

		public string NewSource { get; }

		public object? Replacement { get; set; }

		public bool AssignmentAttempted { get; set; }

		public MutationPlan(string path, object stock, string oldSource, string newSource)
		{
			Path = path;
			Stock = stock;
			OldSource = oldSource;
			NewSource = newSource;
		}
	}

	private sealed class CompatibilityException : InvalidOperationException
	{
		public CompatibilityException(string message)
			: base(message)
		{
		}
	}

	private sealed class RollbackException : AggregateException
	{
		public RollbackException(Exception commitError, IEnumerable<Exception> rollbackErrors)
			: base("Seraphim eco UI cache commit and rollback both failed.", new Exception[1] { commitError }.Concat<Exception>(rollbackErrors))
		{
		}
	}

	public const string Marker = "-- Supreme Commander Overhaul Seraphim resource registration repair 1.1.0";

	public const string BuildQueuePath = "LJ/lua/common/utilities/buildQueueUtils.lua";

	public const string QuickLaunchPath = "LJ/lua/common/units/quickLaunchUnits.lua";

	public const string AvailableUnitsPath = "LJ/lua/common/units/availableUnits.lua";

	public const string ExpectedScomSha256 = "3EED7306200D5910786221547FF0FB959FA8CF92C85C99D62B98A12175C28B76";

	public const string ExpectedScomMvid = "48dd1991-b31b-4297-bd60-0597d33328b5";

	public const long ExpectedScomBytes = 3819520L;

	public const string ExpectedGeneratorSha256 = "4981EFE18ECF6BE6F47DF8996564808B0AC8C7CF22FADAF6F1490B44B34D355C";

	public const string ExpectedGeneratorMvid = "29e22108-0a14-4ec3-be24-b65214f2ecf5";

	public const long ExpectedGeneratorBytes = 56832L;

	private const string ScomRuntimeType = "SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime";

	private const string GeneratorRuntimeType = "SupremeCommanderOverhaulGeneratorBuildability.CachePatcherRuntime";

	private const string ScomMarker = "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0";

	private static readonly BuilderContract[] BuilderContracts = new BuilderContract[4]
	{
		new BuilderContract("usl0000", 1),
		new BuilderContract("usl1501", 1),
		new BuilderContract("usl2501", 2),
		new BuilderContract("usl3501", 3)
	};

	private static readonly ResourceContract[] ResourceContracts = new ResourceContract[10]
	{
		new ResourceContract("uss1601", 1, "ALLOYS_EXTRACTION", "BUILDABLE_BY_T1_ENGINEER", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "CONSTRUCTION", "ECONOMIC", "STRUCTURE", "TECH1"),
		new ResourceContract("uss1602", 1, "ALLOYS_STORAGE", "BUILDABLE_BY_T1_ENGINEER", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "STRUCTURE", "TECH1"),
		new ResourceContract("uss1611", 1, "BUILDABLE_BY_T1_ENGINEER", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "ENERGY_PRODUCTION", "STRUCTURE", "TECH1"),
		new ResourceContract("uss1612", 1, "BUILDABLE_BY_T1_ENGINEER", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "ENERGY_STORAGE", "STRUCTURE", "TECH1"),
		new ResourceContract("uss2601", 2, "ALLOYS_EXTRACTION", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "CONSTRUCTION", "ECONOMIC", "STRUCTURE", "TECH2"),
		new ResourceContract("uss2611", 2, "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "ENERGY_PRODUCTION", "STRUCTURE", "TECH2"),
		new ResourceContract("uss2806", 2, "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "LAND", "STRUCTURE", "TECH2", "ALLOYS_PRODUCTION", "ECONOMIC"),
		new ResourceContract("uss3601", 3, "ALLOYS_EXTRACTION", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "STRUCTURE", "TECH3"),
		new ResourceContract("uss3603", 3, "ALLOYS_PRODUCTION", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "STRUCTURE", "TECH3"),
		new ResourceContract("uss3611", 3, "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "ENERGY_PRODUCTION", "STRUCTURE", "TECH3")
	};

	private static bool _isApplied;

	public static IReadOnlyList<string> ManagedPaths => new string[3] { "LJ/lua/common/utilities/buildQueueUtils.lua", "LJ/lua/common/units/quickLaunchUnits.lua", "LJ/lua/common/units/availableUnits.lua" }.Concat<string>(BuilderContracts.Select((BuilderContract contract) => TemplatePath(contract.Id))).Concat<string>(ResourceContracts.Select((ResourceContract contract) => TemplatePath(contract.Id))).ToArray();

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
			List<MutationPlan> list = BuildMutationPlans(luaFileCache);
			if (list.Count == 0)
			{
				_isApplied = true;
				Log("Seraphim tiered eco build UI guard is already active.");
			}
			else
			{
				Commit(luaFileCache, list);
				_isApplied = true;
				Log("Repaired the stock registration schema for the 10 non-hydro Seraphim resource structures; stock tags own the exact T1/T2/T3 builder matrix.");
			}
		}
		catch (RollbackException)
		{
			throw;
		}
		catch (Exception ex2)
		{
			Log(ex2.Message + " [Seraphim eco stage not applied; transaction unchanged or rolled back. Continuing to required prefab completion.]");
		}
	}

	public static string PatchBuildQueueSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		ValidateStockBuildQueue(text);
		return text;
	}

	public static string PatchTargetTemplateSource(string source, string id)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		if (id == null)
		{
			throw new ArgumentNullException("id");
		}
		ResourceContract contract = ResourceContracts.SingleOrDefault((ResourceContract candidate) => string.Equals(candidate.Id, id, StringComparison.Ordinal)) ?? throw Incompatible("Unsupported Seraphim resource target " + id + ".");
		string text = Normalize(source);
		string token = TargetMarker(contract);
		int num = Count(text, token);
		if (Count(text, "-- Supreme Commander Overhaul Seraphim resource registration repair 1.1.0") != num)
		{
			throw Incompatible(id + " template contains a foreign registration-repair marker.");
		}
		switch (num)
		{
		case 1:
			ValidatePatchedTargetTemplate(text, contract);
			return text;
		default:
			throw Incompatible($"Expected zero or one {id} registration-repair markers, found {num}.");
		case 0:
		{
			ValidateTargetTemplate(text, contract);
			RequireExactly(text, TargetAppendix(contract), 0, id + " pre-existing registration repair");
			RequireExactly(text, "UnitTemplate.intel.visionRadius = UnitTemplate.intel.visionRadius or 0", 0, id + " pre-existing vision-radius repair");
			RequireExactly(text, "UnitTemplate.intel.visionRadius = 0", 0, id + " forced vision-radius override");
			string text2 = text.TrimEnd(Array.Empty<char>()) + "\n\n" + TargetAppendix(contract) + "\n";
			ValidatePatchedTargetTemplate(text2, contract);
			return text2;
		}
		}
	}

	public static void ValidatePrerequisiteSources(IReadOnlyDictionary<string, string> sources)
	{
		if (sources == null)
		{
			throw new ArgumentNullException("sources");
		}
		PatchBuildQueueSource(RequireSource(sources, "LJ/lua/common/utilities/buildQueueUtils.lua"));
		ValidateLoadabilityTable(RequireSource(sources, "LJ/lua/common/units/quickLaunchUnits.lua"), "QuickLaunchUnits", "quick-launch table");
		ValidateLoadabilityTable(RequireSource(sources, "LJ/lua/common/units/availableUnits.lua"), "AvailableUnits", "available-unit table");
		BuilderContract[] builderContracts = BuilderContracts;
		foreach (BuilderContract builderContract in builderContracts)
		{
			ValidateBuilderTemplate(RequireSource(sources, TemplatePath(builderContract.Id)), builderContract);
		}
		ResourceContract[] resourceContracts = ResourceContracts;
		foreach (ResourceContract resourceContract in resourceContracts)
		{
			PatchTargetTemplateSource(RequireSource(sources, TemplatePath(resourceContract.Id)), resourceContract.Id);
		}
	}

	private static void ValidateStockBuildQueue(string source)
	{
		RequireExactly(source, "function buildQueueUtils.GetBuildableTags(unit)", 1, "stock GetBuildableTags definition");
		RequireExactly(source, "function buildQueueUtils.CanBuild(unit, tpId, maxIndex, isPredicted)", 1, "stock CanBuild definition");
		RequireExactly(source, "return ParseTagsFromString(construction.canBuild)", 1, "stock build-tag result");
		RequireExactly(source, "return currentTierTags[tpId]", 1, "stock buildability result");
		RequireExactly(source, "SCO_SeraphimEcoPreviousGetBuildableTags", 0, "pre-existing GetBuildableTags wrapper");
		RequireExactly(source, "SCO_SeraphimEcoPreviousCanBuild", 0, "pre-existing CanBuild wrapper");
		RequireExactly(source, "-- Supreme Commander Overhaul Seraphim resource registration repair 1.1.0", 0, "unexpected registration-repair marker in stock build queue");
	}

	private static void ValidateBuilderTemplate(string source, BuilderContract contract)
	{
		if (!CacheCompatibilityRepair.HasWord(source, "SCO_RemapSeraphimValue"))
		{
			string id = contract.Id;
			CacheCompatibilityRepair.RequireUnit(source, id, (!(id == "usl0000")) ? "|unitsDefaultSeraphim:SeraphimEngineer|" : "|unitsDefaultSeraphim:SeraphimCommander|", "SERAPHIM");
			string source2 = Normalize(source);
			RequireExactly(source2, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", 1, id + " fourth-faction marker");
			if (!((CacheCompatibilityRepair.LastStringAssignment(source, "canBuild") ?? throw Incompatible("Native Seraphim builder has no literal canBuild expression: " + id)).Replace(" ", "").Replace("\t", "").Replace("\r", "")
				.Replace("\n", "") == "Tags.SERAPHIM*Tags.BUILDABLE_BY_T" + contract.Tier + "_ENGINEER"))
			{
				throw Incompatible("Native Seraphim builder has an unsupported build expression: " + id);
			}
			RequireExactly(source2, "-- Supreme Commander Overhaul Seraphim source gameplay 2.1 " + id, 1, id + " source-gameplay marker");
			ValidateStockRequiredDisplaySchema(source2, id);
		}
		else
		{
			string id = contract.Id;
			string source3 = Normalize(source);
			RequireExactly(source3, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", 1, id + " fourth-faction marker");
			RequireExactly(source3, "UnitTemplate.general.tpId = \"" + id + "\"", 1, id + " target ID assignment");
			RequireExactly(source3, "canBuild = \"Tags.CHOSEN * Tags.BUILDABLE_BY_T" + contract.Tier + "_ENGINEER\"", 1, id + " donor build expression");
			RequireExactly(source3, "value = string.gsub(value, \"Tags%.CHOSEN\", \"Tags.SERAPHIM\")", 1, id + " faction-expression remap");
			RequireExactly(source3, "-- Supreme Commander Overhaul Seraphim source gameplay 2.1 " + id, 1, id + " source-gameplay marker");
			ValidateStockRequiredDisplaySchema(source3, id);
		}
	}

	private static void ValidateTargetTemplate(string source, ResourceContract contract)
	{
		string text;
		object obj;
		string id;
		if (!CacheCompatibilityRepair.HasWord(source, "SCO_RemapSeraphimValue"))
		{
			id = contract.Id;
			text = id;
			if (id == "uss1611")
			{
				goto IL_0073;
			}
			switch (id)
			{
			case "uss2611":
			case "uss3611":
				goto IL_0073;
			case "uss1602":
			case "uss1612":
				goto IL_007d;
			}
			obj = "|unitsDefaultSeraphim:SeraphimAlloyExtractor|";
			goto IL_0082;
		}
		id = contract.Id;
		string source2 = Normalize(source);
		RequireExactly(source2, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", 1, id + " fourth-faction marker");
		RequireExactly(source2, "UnitTemplate.general.tpId = \"" + id + "\"", 1, id + " target ID assignment");
		RequireExactly(source2, "-- Supreme Commander Overhaul Seraphim canonical resource tags 1.0 " + id, 1, id + " canonical tag marker");
		RequireExactly(source2, BuildCanonicalResourceTagBlock(contract), 1, id + " canonical resource-tag block");
		ValidateStockRequiredDisplaySchema(source2, id);
		RequireExactly(source2, "UnitTemplate.intel = {", 1, id + " intel reset");
		return;
		IL_0073:
		obj = "|unitsDefaultSeraphim:SeraphimEnergyGenerator|";
		goto IL_0082;
		IL_0082:
		CacheCompatibilityRepair.RequireUnit(source, text, (string)obj, "SERAPHIM");
		string source3 = Normalize(source);
		RequireExactly(source3, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", 1, id + " fourth-faction marker");
		RequireExactly(source3, "-- Supreme Commander Overhaul Seraphim canonical resource tags 1.0 " + id, 1, id + " canonical tag marker");
		RequireExactly(source3, BuildCanonicalResourceTagBlock(contract), 1, id + " canonical resource-tag block");
		ValidateStockRequiredDisplaySchema(source3, id);
		RequireExactly(source3, "UnitTemplate.intel = {", 1, id + " intel reset");
		return;
		IL_007d:
		obj = "|unitsDefaultSeraphim:SeraphimStorage|";
		goto IL_0082;
	}

	private static void ValidatePatchedTargetTemplate(string source, ResourceContract contract)
	{
		ValidateTargetTemplate(source, contract);
		RequireExactly(source, TargetAppendix(contract), 1, contract.Id + " registration repair");
		RequireExactly(source, "UnitTemplate.intel.visionRadius = UnitTemplate.intel.visionRadius or 0", 1, contract.Id + " vision-radius repair");
		RequireExactly(source, "UnitTemplate.intel.visionRadius = 0", 0, contract.Id + " forced vision-radius override");
	}

	private static string TargetMarker(ResourceContract contract)
	{
		return "-- Supreme Commander Overhaul Seraphim resource registration repair 1.1.0 " + contract.Id;
	}

	private static string TargetAppendix(ResourceContract contract)
	{
		return TargetMarker(contract) + "\nUnitTemplate.intel.visionRadius = UnitTemplate.intel.visionRadius or 0";
	}

	private static string BuildCanonicalResourceTagBlock(ResourceContract contract)
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.Append("-- Supreme Commander Overhaul Seraphim canonical resource tags 1.0 ").AppendLine(contract.Id);
		stringBuilder.AppendLine("UnitTemplate.tags = {");
		foreach (string tag in contract.Tags)
		{
			stringBuilder.Append("    \"").Append(tag).AppendLine("\",");
		}
		stringBuilder.Append('}');
		return Normalize(stringBuilder.ToString());
	}

	private static void ValidateStockRequiredDisplaySchema(string source, string id)
	{
		RequireExactly(source, "subBarDisplayScale = {", 1, id + " sub-bar scale");
		RequireExactly(source, "subBarOffSet = {", 1, id + " sub-bar offset");
	}

	private static void ValidateLoadabilityTable(string source, string tableName, string description)
	{
		string source2 = Normalize(source);
		RequireExactly(source2, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", 1, description + " fourth-faction marker");
		foreach (string item in BuilderContracts.Select((BuilderContract contract) => contract.Id).Concat<string>(ResourceContracts.Select((ResourceContract contract) => contract.Id)))
		{
			RequireExactly(source2, tableName + "[\"" + item + "\"] = true", 1, description + " " + item + " assignment");
		}
	}

	private static List<MutationPlan> BuildMutationPlans(object cache)
	{
		Dictionary<string, CacheResource> dictionary = ManagedPaths.ToDictionary<string, string, CacheResource>((string path) => path, (string path) => GetCachedResource(cache, path), StringComparer.Ordinal);
		Dictionary<string, string> dictionary2 = dictionary.ToDictionary<KeyValuePair<string, CacheResource>, string, string>((KeyValuePair<string, CacheResource> pair) => pair.Key, (KeyValuePair<string, CacheResource> pair) => ReadText(pair.Value.Value), StringComparer.Ordinal);
		ValidatePrerequisiteSources(dictionary2);
		List<MutationPlan> list = new List<MutationPlan>();
		ResourceContract[] resourceContracts = ResourceContracts;
		foreach (ResourceContract resourceContract in resourceContracts)
		{
			string key = TemplatePath(resourceContract.Id);
			QueueIfChanged(list, dictionary[key], PatchTargetTemplateSource(dictionary2[key], resourceContract.Id));
		}
		return list;
	}

	private static void QueueIfChanged(ICollection<MutationPlan> plans, CacheResource resource, string newSource)
	{
		string text = ReadText(resource.Value);
		if (!string.Equals(text, newSource, StringComparison.Ordinal))
		{
			plans.Add(new MutationPlan(resource.Path, resource.Value, text, newSource));
		}
	}

	private static void Commit(object cache, IReadOnlyList<MutationPlan> plans)
	{
		try
		{
			foreach (MutationPlan plan in plans)
			{
				plan.Replacement = CreateNativeArrayFromText(plan.Stock.GetType(), plan.NewSource);
			}
		}
		catch
		{
			foreach (MutationPlan item in plans.Where((MutationPlan plan) => plan.Replacement != null))
			{
				TryDispose(item.Replacement, "uncommitted " + item.Path);
			}
			throw;
		}
		try
		{
			foreach (MutationPlan plan2 in plans)
			{
				plan2.AssignmentAttempted = true;
				SetCachedResource(cache, plan2.Path, plan2.Replacement);
				if (!string.Equals(ReadText(GetExactCachedResource(cache, plan2.Path)), plan2.NewSource, StringComparison.Ordinal))
				{
					throw new InvalidOperationException("Cache write verification failed for " + plan2.Path + ".");
				}
			}
		}
		catch (Exception ex)
		{
			List<Exception> list = RollBack(cache, plans);
			if (list.Count != 0)
			{
				throw new RollbackException(ex, list);
			}
			foreach (MutationPlan plan3 in plans)
			{
				TryDispose(plan3.Replacement, "rolled-back " + plan3.Path);
			}
			throw new InvalidOperationException("Seraphim eco UI cache transaction failed and was rolled back.", ex);
		}
		foreach (MutationPlan plan4 in plans)
		{
			TryDispose(plan4.Stock, "replaced " + plan4.Path);
		}
	}

	private static List<Exception> RollBack(object cache, IReadOnlyList<MutationPlan> plans)
	{
		List<Exception> list = new List<Exception>();
		for (int num = plans.Count - 1; num >= 0; num--)
		{
			MutationPlan mutationPlan = plans[num];
			if (mutationPlan.AssignmentAttempted)
			{
				try
				{
					SetCachedResource(cache, mutationPlan.Path, mutationPlan.Stock);
					if (!string.Equals(ReadText(GetExactCachedResource(cache, mutationPlan.Path)), mutationPlan.OldSource, StringComparison.Ordinal))
					{
						throw new InvalidOperationException("Cache rollback verification failed for " + mutationPlan.Path + ".");
					}
				}
				catch (Exception item)
				{
					list.Add(item);
				}
			}
		}
		return list;
	}

	private static void ValidateUpstreamIdentity()
	{
		CachePatcher.ValidateMvid(FindLoadedType("EM.Lua.FilesCache").Module.ModuleVersionId);
		CanonicalAssemblyContract.RequireCanonicalTypes("SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime", "SupremeCommanderOverhaulGeneratorBuildability.CachePatcherRuntime", "SupremeCommanderOverhaulSeraphimEcoBuildUi.CachePatcherRuntime");
	}

	private static void ValidateAssemblyIdentity(Assembly assembly, string expectedMvid, long expectedBytes, string expectedSha256, string description)
	{
		string text = assembly.ManifestModule.ModuleVersionId.ToString("D");
		if (!string.Equals(text, expectedMvid, StringComparison.OrdinalIgnoreCase))
		{
			throw Incompatible(description + " MVID drifted: expected " + expectedMvid + ", found " + text + ".");
		}
		string location = assembly.Location;
		if (string.IsNullOrWhiteSpace(location) || !File.Exists(location))
		{
			throw Incompatible(description + " has no verifiable file location.");
		}
		FileInfo fileInfo = new FileInfo(location);
		if (fileInfo.Length != expectedBytes)
		{
			throw Incompatible($"{description} size drifted: expected {expectedBytes}, found {fileInfo.Length}.");
		}
		using FileStream inputStream = File.OpenRead(location);
		using SHA256 sHA = SHA256.Create();
		string text2 = BitConverter.ToString(sHA.ComputeHash(inputStream)).Replace("-", "");
		if (!string.Equals(text2, expectedSha256, StringComparison.OrdinalIgnoreCase))
		{
			throw Incompatible(description + " SHA-256 drifted: expected " + expectedSha256 + ", found " + text2 + ".");
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
			throw Incompatible($"Expected one loaded {fullName} type, found {array.Length}.");
		}
		return array[0];
	}

	private static object GetLuaFileCache()
	{
		Type type = FindLoadedType("EM.Lua.FilesCache");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CacheResource GetCachedResource(object cache, string relativePath)
	{
		string value = "/" + relativePath.Replace('\\', '/');
		CacheResource cacheResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type = item.GetType();
			if (type.GetProperty("Key")?.GetValue(item, null) is string text && text.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cacheResource != null)
				{
					throw Incompatible("Multiple cache resources match " + relativePath + ".");
				}
				object obj = type.GetProperty("Value")?.GetValue(item, null) ?? throw new InvalidOperationException("Cached " + relativePath + " has no value.");
				EnsureCreated(obj, relativePath);
				cacheResource = new CacheResource(text, obj);
			}
		}
		return cacheResource ?? throw new FileNotFoundException("Required cached Lua source is unavailable.", relativePath);
	}

	private static string ReadText(object resource)
	{
		EnsureCreated(resource, "Lua resource");
		byte[] bytes = ((resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null) as byte[]) ?? throw new InvalidOperationException("NativeArray.ToArray returned null.");
		return Encoding.UTF8.GetString(bytes);
	}

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		if (!nativeArrayType.IsGenericType || nativeArrayType.GetGenericArguments().Length != 1 || nativeArrayType.GetGenericArguments()[0] != typeof(byte))
		{
			throw new ArgumentException("Expected Unity NativeArray<byte>.", "nativeArrayType");
		}
		Type type = nativeArrayType.Assembly.GetType("Unity.Collections.Allocator", throwOnError: false) ?? (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType("Unity.Collections.Allocator", throwOnError: false)).FirstOrDefault((Type type2) => type2 != null) ?? throw new TypeLoadException("Unity.Collections.Allocator is unavailable.");
		return (nativeArrayType.GetConstructor(BindingFlags.Instance | BindingFlags.Public, null, new Type[2]
		{
			typeof(byte[]),
			type
		}, null) ?? throw new MissingMethodException(nativeArrayType.FullName, ".ctor(Byte[], Allocator)")).Invoke(new object[2]
		{
			Encoding.UTF8.GetBytes(source),
			Enum.Parse(type, "Persistent")
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

	private static string RequireSource(IReadOnlyDictionary<string, string> sources, string path)
	{
		if (!sources.TryGetValue(path, out string value) || value == null)
		{
			throw Incompatible("Required prerequisite source is missing: " + path + ".");
		}
		return value;
	}

	private static string TemplatePath(string id)
	{
		return "LJ/lua/common/units/unitsTemplates/" + id + "/" + id + ".santp";
	}

	private static string Normalize(string source)
	{
		return source.Replace("\r\n", "\n").Replace("\r", "\n");
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

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = Count(source, token);
		if (num != expected)
		{
			throw Incompatible($"Expected {expected} {description}, found {num}.");
		}
	}

	private static void RequireAtLeast(string source, string token, int expected, string description)
	{
		int num = Count(source, token);
		if (num < expected)
		{
			throw Incompatible($"Expected at least {expected} {description}, found {num}.");
		}
	}

	private static CompatibilityException Incompatible(string message)
	{
		return new CompatibilityException(message);
	}

	private static void Log(string message)
	{
		string text = "[SCOM Seraphim Eco Build UI] " + message;
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
