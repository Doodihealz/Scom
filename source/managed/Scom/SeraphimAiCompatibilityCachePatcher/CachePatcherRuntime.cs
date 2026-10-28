using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace SeraphimAiCompatibilityCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class SourceCompatibilityException : InvalidOperationException
	{
		public SourceCompatibilityException(string message)
			: base(message)
		{
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

		public object Stock { get; }

		public object Replacement { get; }

		public string Description { get; }

		public bool AssignmentWasAttempted { get; set; }

		public CacheMutation(string path, object stock, object replacement, string description)
		{
			Path = path;
			Stock = stock;
			Replacement = replacement;
			Description = description;
		}
	}

	private const string OverrideMarker = "-- Supreme Commander Overhaul Seraphim AI compatibility 1.0.0";

	private const string ThreeFactionMap = "{[1] = \"EDA\", [2] = \"CHOSEN\", [3] = \"GUARD\" }";

	private const string FourFactionMap = "{[1] = \"EDA\", [2] = \"CHOSEN\", [3] = \"GUARD\", [4] = \"SERAPHIM\" }";

	private const string StockAirfieldFilter = "Tags.STRUCTURE * Tags.AIRFIELD * Tags.TECH1 * ( Tags.EDA + Tags.CHOSEN )";

	private const string SeraphimAirfieldFilter = "Tags.STRUCTURE * Tags.AIRFIELD * Tags.TECH1 * ( Tags.EDA + Tags.CHOSEN + Tags.SERAPHIM )";

	private const string AIFunctionsRelativePath = "LJ/lua/AI/AIFunctions.lua";

	private const string AILocationManagerRelativePath = "LJ/lua/AI/AILocationManager.lua";

	private static readonly string[] PlatoonFunctionRelativePaths = new string[2] { "LJ/lua/AI/mods/AI-Sanctuary-Rush/AIPlatoonFunctions.lua", "LJ/lua/AI/mods/AI-T2Rush/AIPlatoonFunctions.lua" };

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		bool flag = false;
		bool flag2 = false;
		try
		{
			obj = GetLuaFileCache();
			QueueTransform(obj, list, "LJ/lua/AI/AIFunctions.lua", "core AI faction selection helpers", TransformAIFunctions, ValidateAIFunctions);
			QueueTransform(obj, list, "LJ/lua/AI/AILocationManager.lua", "AI airfield-upgrade faction filter", TransformAILocationManager, ValidateAILocationManager);
			string[] platoonFunctionRelativePaths = PlatoonFunctionRelativePaths;
			foreach (string text in platoonFunctionRelativePaths)
			{
				QueueTransform(obj, list, text, Path.GetFileName(Path.GetDirectoryName(text) ?? text) + " platoon faction selection helper", TransformPlatoonFunctions, ValidatePlatoonFunctions);
			}
			if (list.Count == 0)
			{
				Log("Seraphim AI compatibility resources are already active.");
				return;
			}
			flag2 = true;
			Commit(obj, list);
			flag = true;
			DisposeSupersededStocks(list);
			Log("Extended core AI and all bundled AI behaviors for Lua faction index 4 / SERAPHIM.");
		}
		catch (Exception ex)
		{
			if (flag)
			{
				Log($"Seraphim AI compatibility cache commit completed, but post-commit cleanup failed: {ex}");
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
				AggregateException ex4 = new AggregateException("The Seraphim AI compatibility transaction failed and rollback was incomplete.", ex, ex2);
				Log($"Failed to apply Seraphim AI compatibility transaction with an incomplete rollback: {ex4}");
				throw ex4;
			}
			if (!flag2 && ex is SourceCompatibilityException)
			{
				Log("WARNING: Skipped optional Seraphim AI compatibility edits; cached AI sources are unchanged. " + ex.Message + " Unit registration will continue.");
				return;
			}
			Log($"Failed to apply Seraphim AI compatibility transaction after a complete rollback: {ex}");
			throw;
		}
	}

	private static string TransformAIFunctions(string source)
	{
		RequireTokens(source, "function CanBuildTag", "function GetWantUnits", "function GetWantStructures");
		int num = CountOccurrences(source, "{[1] = \"EDA\", [2] = \"CHOSEN\", [3] = \"GUARD\" }");
		int num2 = CountOccurrences(source, "{[1] = \"EDA\", [2] = \"CHOSEN\", [3] = \"GUARD\", [4] = \"SERAPHIM\" }");
		if (num == 0 && num2 == 3)
		{
			return source + MarkerAppendix();
		}
		if (num != 3 || num2 != 0)
		{
			throw new SourceCompatibilityException($"Expected either 3 stock or 3 Seraphim-compatible core AI faction lookup tables; found stock={num}, compatible={num2}.");
		}
		return source.Replace("{[1] = \"EDA\", [2] = \"CHOSEN\", [3] = \"GUARD\" }", "{[1] = \"EDA\", [2] = \"CHOSEN\", [3] = \"GUARD\", [4] = \"SERAPHIM\" }") + MarkerAppendix();
	}

	private static void ValidateAIFunctions(string source)
	{
		RequireTokens(source, "function CanBuildTag", "function GetWantUnits", "function GetWantStructures");
		RequireCount(source, "{[1] = \"EDA\", [2] = \"CHOSEN\", [3] = \"GUARD\", [4] = \"SERAPHIM\" }", 3, "core AI four-faction lookup table");
	}

	private static string TransformAILocationManager(string source)
	{
		RequireTokens(source, "T1 Air Field Upgrade", "NeedUpgradeableUnit");
		return ReplaceExactly(source, "Tags.STRUCTURE * Tags.AIRFIELD * Tags.TECH1 * ( Tags.EDA + Tags.CHOSEN )", "Tags.STRUCTURE * Tags.AIRFIELD * Tags.TECH1 * ( Tags.EDA + Tags.CHOSEN + Tags.SERAPHIM )", 1, "AI airfield-upgrade faction filter") + MarkerAppendix();
	}

	private static void ValidateAILocationManager(string source)
	{
		RequireTokens(source, "T1 Air Field Upgrade", "NeedUpgradeableUnit");
		RequireCount(source, "Tags.STRUCTURE * Tags.AIRFIELD * Tags.TECH1 * ( Tags.EDA + Tags.CHOSEN + Tags.SERAPHIM )", 1, "Seraphim airfield-upgrade faction filter");
	}

	private static string TransformPlatoonFunctions(string source)
	{
		RequireTokens(source, "function getNextbuildingAndSpacing", "local armyFactionName");
		return ReplaceExactly(source, "{[1] = \"EDA\", [2] = \"CHOSEN\", [3] = \"GUARD\" }", "{[1] = \"EDA\", [2] = \"CHOSEN\", [3] = \"GUARD\", [4] = \"SERAPHIM\" }", 1, "AI platoon three-faction lookup table") + MarkerAppendix();
	}

	private static void ValidatePlatoonFunctions(string source)
	{
		RequireTokens(source, "function getNextbuildingAndSpacing", "local armyFactionName");
		RequireCount(source, "{[1] = \"EDA\", [2] = \"CHOSEN\", [3] = \"GUARD\", [4] = \"SERAPHIM\" }", 1, "AI platoon four-faction lookup table");
	}

	private static void QueueTransform(object cache, List<CacheMutation> mutations, string relativePath, string description, Func<string, string> transform, Action<string> validatePatched)
	{
		CacheResource cachedResource;
		try
		{
			cachedResource = GetCachedResource(cache, relativePath, description);
		}
		catch (FileNotFoundException ex) when (PlatoonFunctionRelativePaths.Contains<string>(relativePath) && string.Equals(ex.FileName, relativePath, StringComparison.Ordinal))
		{
			throw new SourceCompatibilityException("Optional AI profile source is not cached: " + relativePath);
		}
		string resourceText = GetResourceText(cachedResource.Stock);
		if (ContainsMarker(resourceText))
		{
			validatePatched(resourceText);
			return;
		}
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), transform(resourceText));
		try
		{
			string resourceText2 = GetResourceText(obj);
			if (!ContainsMarker(resourceText2))
			{
				throw new InvalidOperationException("The patched " + description + " lost its Seraphim AI marker.");
			}
			validatePatched(resourceText2);
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, description));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + description + " replacement");
			throw;
		}
	}

	private static string MarkerAppendix()
	{
		return "\n\n-- Supreme Commander Overhaul Seraphim AI compatibility 1.0.0\n";
	}

	private static string ReplaceExactly(string source, string oldValue, string newValue, int expectedOccurrences, string description)
	{
		RequireCount(source, oldValue, expectedOccurrences, description);
		return source.Replace(oldValue, newValue);
	}

	private static void RequireCount(string source, string needle, int expectedCount, string description)
	{
		int num = CountOccurrences(source, needle);
		if (num != expectedCount)
		{
			throw new SourceCompatibilityException($"Expected {expectedCount} {description}, found {num}.");
		}
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

	private static bool ContainsMarker(string source)
	{
		return source.IndexOf("-- Supreme Commander Overhaul Seraphim AI compatibility 1.0.0", StringComparison.Ordinal) >= 0;
	}

	private static void RequireTokens(string source, params string[] requiredTokens)
	{
		foreach (string text in requiredTokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) < 0)
			{
				throw new SourceCompatibilityException("Expected cached Lua source to contain '" + text + "'.");
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
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string fullPath = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
		object obj2 = obj.Invoke(cache, new object[1] { fullPath });
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
			object obj3 = propertyInfo.GetValue(cache, new object[1] { fullPath }) ?? throw new InvalidOperationException("The cached " + description + " has no value.");
			EnsureNativeArray(obj3, description);
			return new CacheResource(fullPath, obj3);
		}
		string value = "/" + relativePath.Replace('\\', '/');
		string text = null;
		object obj4 = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text2 && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (text != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + relativePath + ".");
				}
				object obj5 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("The cached " + description + " has no value.");
				EnsureNativeArray(obj5, description);
				text = text2;
				obj4 = obj5;
			}
		}
		if (text == null || obj4 == null)
		{
			throw new FileNotFoundException("The required " + description + " was not present in Sanctuary's Lua file cache.", relativePath);
		}
		return new CacheResource(text, obj4);
	}

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		byte[] bytes = Encoding.UTF8.GetBytes(source);
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, bytes);
	}

	private static byte[] GetNativeArrayBytes(Type nativeArrayType, object nativeArray)
	{
		return (byte[])((nativeArrayType.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "ToArray")).Invoke(nativeArray, null) ?? throw new InvalidOperationException(nativeArrayType.FullName + ".ToArray returned null."));
	}

	private static string GetResourceText(object resource)
	{
		EnsureNativeArray(resource, "Lua cache resource");
		return Encoding.UTF8.GetString(GetNativeArrayBytes(resource.GetType(), resource));
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
			TryDisposeNativeArray(mutation.Stock.GetType(), mutation.Stock, "stock " + mutation.Description);
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
					SetCachedResource(cache, item.Path, item.Stock);
					ValidateCachedByteIdentity(cache, item.Path, item.Stock, "restored " + item.Description);
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
			throw new AggregateException("The Seraphim AI compatibility cache rollback was incomplete.", list);
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

	private static void Log(string message)
	{
		try
		{
			string text = "[Seraphim AI Compatibility Cache Patcher] " + message;
			Console.WriteLine(text);
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => (object)type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}
}
