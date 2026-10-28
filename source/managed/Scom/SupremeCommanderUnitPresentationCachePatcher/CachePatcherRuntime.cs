using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace SupremeCommanderUnitPresentationCachePatcher;

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

		public object Stock { get; }

		public object Replacement { get; }

		public string Description { get; }

		public bool Assigned { get; set; }

		public CacheMutation(string path, object stock, object replacement, string description)
		{
			Path = path;
			Stock = stock;
			Replacement = replacement;
			Description = description;
		}
	}

	internal const string OverrideMarker = "-- Supreme Commander Overhaul Forged Alliance Unit Presentation 1.0.0";

	private const string UnitTemplateRoot = "LJ/lua/common/units/unitsTemplates";

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			UnitPresentationRule[] all = UnitPresentationRules.All;
			foreach (UnitPresentationRule rule in all)
			{
				QueueTransform(obj, list, rule);
			}
			if (list.Count == 0)
			{
				Log("Forged Alliance unit portraits and names are already active.");
				return;
			}
			Commit(obj, list);
			Log($"Applied exact Forged Alliance names to {UnitPresentationRules.All.Length} active ports.");
		}
		catch (Exception arg)
		{
			if (obj != null)
			{
				RollBack(obj, list);
			}
			Log($"Failed to apply Forged Alliance unit presentation transaction: {arg}");
			throw;
		}
	}

	private static void QueueTransform(object cache, List<CacheMutation> mutations, UnitPresentationRule rule)
	{
		string relativePath = "LJ/lua/common/units/unitsTemplates/" + rule.TargetId + "/" + rule.TargetId + ".santp";
		CacheResource cachedResource = GetCachedResource(cache, relativePath, rule.TargetId + " unit template");
		string resourceText = GetResourceText(cachedResource.Stock);
		if (ContainsMarker(resourceText))
		{
			ValidatePatched(resourceText, rule);
			return;
		}
		if (resourceText.IndexOf("UnitTemplate", StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("The cached " + rule.TargetId + " template does not define UnitTemplate.");
		}
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), Transform(resourceText, rule));
		try
		{
			ValidatePatched(GetResourceText(obj), rule);
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, rule.TargetId));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + rule.TargetId + " replacement");
			throw;
		}
	}

	private static string Transform(string source, UnitPresentationRule rule)
	{
		string text = (source.EndsWith("\n", StringComparison.Ordinal) ? string.Empty : "\n");
		string text2 = EscapeLuaString(rule.DisplayName);
		return source + text + "\n-- Supreme Commander Overhaul Forged Alliance Unit Presentation 1.0.0\n-- Local FA source: " + rule.SourceId + " -> Sanctuary template " + rule.TargetId + "\nUnitTemplate.general = UnitTemplate.general or {}\nUnitTemplate.general.displayName = \"" + text2 + "\"\nUnitTemplate.general.name = \"" + text2 + "\"";
	}

	private static void ValidatePatched(string source, UnitPresentationRule rule)
	{
		RequireCount(source, "-- Supreme Commander Overhaul Forged Alliance Unit Presentation 1.0.0", 1, rule.TargetId + " presentation marker");
		string text = EscapeLuaString(rule.DisplayName);
		RequireContains(source, "UnitTemplate.general.displayName = \"" + text + "\"", rule.TargetId + " display name");
		RequireContains(source, "UnitTemplate.general.name = \"" + text + "\"", rule.TargetId + " primary name");
	}

	private static string EscapeLuaString(string value)
	{
		return value.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "\\r")
			.Replace("\n", "\\n");
	}

	private static bool ContainsMarker(string source)
	{
		return source.IndexOf("-- Supreme Commander Overhaul Forged Alliance Unit Presentation 1.0.0", StringComparison.Ordinal) >= 0;
	}

	private static void RequireContains(string source, string token, string description)
	{
		if (source.IndexOf(token, StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("The " + description + " is missing its expected presentation value.");
		}
	}

	private static void RequireCount(string source, string token, int expected, string description)
	{
		int num = 0;
		int startIndex = 0;
		while (true)
		{
			int num2 = source.IndexOf(token, startIndex, StringComparison.Ordinal);
			if (num2 < 0)
			{
				break;
			}
			num++;
			startIndex = num2 + token.Length;
		}
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {description}, found {num}.");
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
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, Encoding.UTF8.GetBytes(source));
	}

	private static string GetResourceText(object resource)
	{
		EnsureNativeArray(resource, "Lua cache resource");
		Type type = resource.GetType();
		byte[] bytes = (byte[])((type.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, "ToArray")).Invoke(resource, null) ?? throw new InvalidOperationException(type.FullName + ".ToArray returned null."));
		return Encoding.UTF8.GetString(bytes);
	}

	private static void EnsureNativeArray(object value, string description)
	{
		object value2 = (value.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(value.GetType().FullName, "IsCreated")).GetValue(value);
		if (!(value2 is bool) || !(bool)value2)
		{
			throw new InvalidOperationException("The cached " + description + " is not an initialized NativeArray.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
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
			TryDisposeNativeArray(mutation2.Stock.GetType(), mutation2.Stock, "stock " + mutation2.Description);
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
					SetCachedResource(cache, item.Path, item.Stock);
					item.Assigned = false;
				}
				catch (Exception arg)
				{
					Log($"Rollback failed for {item.Description}: {arg}");
				}
			}
			if (!item.Assigned)
			{
				TryDisposeNativeArray(item.Replacement.GetType(), item.Replacement, "replacement " + item.Description);
			}
		}
	}

	private static void TryDisposeNativeArray(Type nativeArrayType, object nativeArray, string description)
	{
		try
		{
			object value = (nativeArrayType.GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(nativeArrayType.FullName, "IsCreated")).GetValue(nativeArray);
			if (value is bool && (bool)value)
			{
				(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
			}
		}
		catch (Exception arg)
		{
			Log($"Could not dispose {description}: {arg}");
		}
	}

	private static void Log(string message)
	{
		string text = "[Supreme Commander Unit Presentation Cache Patcher] " + message;
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
