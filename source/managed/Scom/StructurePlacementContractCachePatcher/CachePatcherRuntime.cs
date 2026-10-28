using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace StructurePlacementContractCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class CachedResource
	{
		public PlacementSpec Spec { get; }

		public string Path { get; }

		public object Stock { get; }

		public object? Replacement { get; set; }

		public bool AssignmentWasAttempted { get; set; }

		public CachedResource(PlacementSpec spec, string path, object stock)
		{
			Spec = spec;
			Path = path;
			Stock = stock;
		}
	}

	private const string OverrideMarker = "-- Supreme Commander Overhaul Structure Placement Contract 1.0.1";

	static CachePatcherRuntime()
	{
		StructurePlacementManifest.Validate();
	}

	public static void Apply()
	{
		object obj = null;
		List<CachedResource> list = new List<CachedResource>(StructurePlacementManifest.Specs.Length);
		bool flag = false;
		try
		{
			obj = GetLuaFileCache();
			PlacementSpec[] specs = StructurePlacementManifest.Specs;
			foreach (PlacementSpec spec in specs)
			{
				list.Add(GetCachedResource(obj, spec));
			}
			int num = list.Count((CachedResource resource) => ContainsOverride(resource.Stock));
			if (num == list.Count)
			{
				foreach (CachedResource item in list)
				{
					ValidatePatchedText(GetResourceText(item.Stock), item.Spec);
				}
				DualWaterPlacementRuntime.Apply();
				Log("All 87 static FA structure templates already contain the placement contract.");
				return;
			}
			if (num != 0)
			{
				throw new InvalidOperationException("A partial structure-placement cache override was found; the patcher will not mix old and new placement grids.");
			}
			foreach (CachedResource item2 in list)
			{
				item2.Replacement = CreateReplacement(item2.Stock, item2.Spec);
				ValidatePatchedText(GetResourceText(item2.Replacement), item2.Spec);
			}
			foreach (CachedResource item3 in list)
			{
				object obj2 = item3.Replacement ?? throw new InvalidOperationException("Placement template '" + item3.Spec.TargetId + "' has no prepared replacement.");
				item3.AssignmentWasAttempted = true;
				SetCachedResource(obj, item3.Path, obj2);
				ValidateCachedByteIdentity(obj, item3.Path, obj2, item3.Spec.TargetId);
			}
			DualWaterPlacementRuntime.Apply();
			flag = true;
			foreach (CachedResource item4 in list)
			{
				TryDisposeNativeArray(item4.Stock.GetType(), item4.Stock, "stock " + item4.Spec.TargetId);
			}
			Log("Applied the explicit 87-template FA logical/source-skirt/model-safe structure placement contract.");
		}
		catch (Exception ex)
		{
			if (flag)
			{
				Log($"Structure placement cache commit completed, but post-commit cleanup failed: {ex}");
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
				AggregateException ex4 = new AggregateException("The structure placement contract transaction failed and rollback was incomplete.", ex, ex2);
				Log($"Failed to apply the structure placement contract with an incomplete rollback: {ex4}");
				throw ex4;
			}
			Log($"Failed to apply the structure placement contract after a complete rollback: {ex}");
			throw;
		}
	}

	private static CachedResource GetCachedResource(object cache, PlacementSpec spec)
	{
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string fullPath = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), spec.RelativePath));
		if ((bool)obj.Invoke(cache, new object[1] { fullPath }))
		{
			object obj2 = propertyInfo.GetValue(cache, new object[1] { fullPath }) ?? throw new InvalidOperationException("Cached placement template '" + spec.TargetId + "' has no value.");
			EnsureNativeArray(obj2, spec.TargetId);
			return new CachedResource(spec, fullPath, obj2);
		}
		string value = "/" + spec.RelativePath;
		string text = null;
		object obj3 = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text2 && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (text != null)
				{
					throw new InvalidOperationException("More than one cached template matches '" + spec.RelativePath + "'.");
				}
				object obj4 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("Cached placement template '" + spec.TargetId + "' has no value.");
				EnsureNativeArray(obj4, spec.TargetId);
				text = text2;
				obj3 = obj4;
			}
		}
		if (text == null || obj3 == null)
		{
			throw new FileNotFoundException("The required static placement template '" + spec.TargetId + "' was not present after its source module completed.", spec.RelativePath);
		}
		return new CachedResource(spec, text, obj3);
	}

	private static object CreateReplacement(object stockResource, PlacementSpec spec)
	{
		Type type = stockResource.GetType();
		string resourceText = GetResourceText(stockResource);
		string text = "\n\n-- Supreme Commander Overhaul Structure Placement Contract 1.0.1\n" + $"-- {spec.TargetId} <- {spec.SourceUnitId}; policy={spec.Policy}; " + $"faLogical={spec.SourceGridX}x{spec.SourceGridZ}.\n" + "UnitTemplate.skirtSize = {\n" + $"    x = {spec.GridX},\n" + $"    y = {spec.GridZ},\n" + "}\n";
		if (DualWaterPlacementRuntime.IsTarget(spec.TargetId))
		{
			text += "-- FA Physics.BuildOnLayerCaps Land+Water; Footprint.MinWaterDepth=1.\nUnitTemplate.general.faDualWaterPlacement = true\n";
		}
		return NativeArrayByteFactory.CreatePersistent(type, Encoding.UTF8.GetBytes(resourceText + text));
	}

	private static void ValidatePatchedText(string text, PlacementSpec spec)
	{
		if (CountOccurrences(text, "-- Supreme Commander Overhaul Structure Placement Contract 1.0.1") != 1)
		{
			throw new InvalidOperationException("Placement template '" + spec.TargetId + "' does not contain exactly one contract marker.");
		}
		int startIndex = text.IndexOf("-- Supreme Commander Overhaul Structure Placement Contract 1.0.1", StringComparison.Ordinal);
		string source = text.Substring(startIndex);
		RequireToken(source, $"-- {spec.TargetId} <- {spec.SourceUnitId}; policy={spec.Policy}; faLogical={spec.SourceGridX}x{spec.SourceGridZ}.", spec.TargetId);
		RequireToken(source, "UnitTemplate.skirtSize = {", spec.TargetId);
		RequireToken(source, $"    x = {spec.GridX},", spec.TargetId);
		RequireToken(source, $"    y = {spec.GridZ},", spec.TargetId);
		if (DualWaterPlacementRuntime.IsTarget(spec.TargetId))
		{
			RequireToken(source, "UnitTemplate.general.faDualWaterPlacement = true", spec.TargetId);
		}
	}

	private static void RequireToken(string source, string token, string targetId)
	{
		if (!source.Contains(token))
		{
			throw new InvalidOperationException("Placement template '" + targetId + "' is missing expected contract token '" + token + "'.");
		}
	}

	private static int CountOccurrences(string source, string token)
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

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void ValidateCachedByteIdentity(object cache, string path, object expectedResource, string targetId)
	{
		object obj = (cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("Cached placement template '" + targetId + "' has no value after assignment.");
		EnsureNativeArray(obj, targetId);
		if (!GetNativeArrayBytes(obj.GetType(), obj).SequenceEqual(GetNativeArrayBytes(expectedResource.GetType(), expectedResource)))
		{
			throw new InvalidOperationException("Cached placement template '" + targetId + "' failed byte-identity validation.");
		}
	}

	private static void RollBackAndDispose(object cache, IEnumerable<CachedResource> resources)
	{
		List<Exception> list = new List<Exception>();
		foreach (CachedResource item in resources.Reverse())
		{
			if (item.AssignmentWasAttempted)
			{
				try
				{
					SetCachedResource(cache, item.Path, item.Stock);
					ValidateCachedByteIdentity(cache, item.Path, item.Stock, "restored " + item.Spec.TargetId);
					item.AssignmentWasAttempted = false;
				}
				catch (Exception innerException)
				{
					list.Add(new InvalidOperationException("Could not restore placement template '" + item.Spec.TargetId + "'; the cache may still own its replacement.", innerException));
					continue;
				}
			}
			if (item.Replacement != null)
			{
				try
				{
					DisposeNativeArray(item.Replacement.GetType(), item.Replacement);
					item.Replacement = null;
				}
				catch (Exception innerException2)
				{
					list.Add(new InvalidOperationException("Could not dispose replacement placement template '" + item.Spec.TargetId + "'.", innerException2));
				}
			}
		}
		if (list.Count != 0)
		{
			throw new AggregateException("The structure placement cache rollback was incomplete.", list);
		}
	}

	private static string GetResourceText(object nativeArray)
	{
		return Encoding.UTF8.GetString(GetNativeArrayBytes(nativeArray.GetType(), nativeArray));
	}

	private static byte[] GetNativeArrayBytes(Type nativeArrayType, object nativeArray)
	{
		return (byte[])(nativeArrayType.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "ToArray")).Invoke(nativeArray, null);
	}

	private static void EnsureNativeArray(object nativeArray, string targetId)
	{
		if (!IsNativeArrayCreated(nativeArray))
		{
			throw new InvalidOperationException("Cached placement template '" + targetId + "' is not an initialized NativeArray.");
		}
	}

	private static bool IsNativeArrayCreated(object nativeArray)
	{
		return (bool)(nativeArray.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(nativeArray.GetType().FullName, "IsCreated")).GetValue(nativeArray);
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

	private static bool ContainsOverride(object resource)
	{
		if (IsNativeArrayCreated(resource))
		{
			return GetResourceText(resource).IndexOf("-- Supreme Commander Overhaul Structure Placement Contract 1.0.1", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	private static void Log(string message)
	{
		try
		{
			string text = "[Structure Placement Contract Cache Patcher] " + message;
			Console.WriteLine(text);
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => (object)type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}
}
