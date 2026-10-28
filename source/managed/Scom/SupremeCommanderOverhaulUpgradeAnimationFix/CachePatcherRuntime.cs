using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using SupremeCommanderOverhaulCanonical;

namespace SupremeCommanderOverhaulUpgradeAnimationFix;

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

	private const string ScomRuntimeType = "SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime";

	private const string ExpectedScomMvid = "48dd1991-b31b-4297-bd60-0597d33328b5";

	private const string ExpectedScomSha256 = "3EED7306200D5910786221547FF0FB959FA8CF92C85C99D62B98A12175C28B76";

	private const long ExpectedScomBytes = 3819520L;

	private static bool _isApplied;

	public static void Apply()
	{
		if (_isApplied)
		{
			return;
		}
		object cache = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			ValidateManifest();
			ValidateUpstreamIdentity();
			ValidateManagedPlayAnimationField();
			cache = GetLuaFileCache();
			ProgressAnimationSpec[] specs = ProgressAnimationManifest.Specs;
			foreach (ProgressAnimationSpec spec in specs)
			{
				list.Add(CreateMutation(cache, spec.TemplatePath, spec.UnitId + " unit template", (string source) => ProgressAnimationPolicy.PatchTemplateSource(source, spec)));
			}
			if (list.All((CacheMutation mutation) => !mutation.NeedsWrite))
			{
				_isApplied = true;
				Log("The managed exact-time route and 35-unit progress freeze are already active.");
				return;
			}
			foreach (CacheMutation item in list.Where((CacheMutation item) => item.NeedsWrite))
			{
				item.Replacement = CreateNativeArrayFromText(item.Resource.Value.GetType(), item.NewSource);
			}
			foreach (CacheMutation item2 in list.Where((CacheMutation item) => item.NeedsWrite))
			{
				item2.Assigned = true;
				SetCachedResource(cache, item2.Resource.Path, item2.Replacement);
				VerifyCachedText(cache, item2.Resource.Path, item2.NewSource, item2.Description + " cache write");
			}
			foreach (CacheMutation item3 in list.Where((CacheMutation item) => item.NeedsWrite))
			{
				TryDispose(item3.Resource.Value, "replaced " + item3.Description);
				item3.Assigned = false;
			}
			_isApplied = true;
			Log("Installed exact progress poses for all 35 audited SCOM structure upgrades; original animation assets and clip IDs are unchanged.");
		}
		catch (Exception ex)
		{
			List<Exception> list2 = RollBackLua(cache, list);
			if (list2.Count != 0)
			{
				Log("Cache mutation failed and rollback was incomplete: " + ex.GetBaseException().Message);
				throw new AggregateException("Upgrade-animation cache mutation and rollback both failed.", new Exception[1] { ex }.Concat(list2));
			}
			Log("Aborting Lua startup after a clean cache rollback; the managed animation route cannot safely run without all 35 progress freezes: " + ex.GetBaseException().Message);
			throw new InvalidOperationException("SCOM upgrade-animation fix could not be installed atomically.", ex);
		}
	}

	private static void ValidateManifest()
	{
		ProgressAnimationSpec[] specs = ProgressAnimationManifest.Specs;
		if (specs.Length != 35 || specs.Select((ProgressAnimationSpec spec) => spec.UnitId).Distinct<string>(StringComparer.OrdinalIgnoreCase).Count() != specs.Length || specs.Select((ProgressAnimationSpec spec) => spec.TemplatePath).Distinct<string>(StringComparer.OrdinalIgnoreCase).Count() != specs.Length)
		{
			throw new InvalidOperationException("The 35-unit progress-animation manifest is incomplete or ambiguous.");
		}
		ProgressAnimationSpec[] array = specs;
		foreach (ProgressAnimationSpec progressAnimationSpec in array)
		{
			if (progressAnimationSpec.SourceAssetBytes <= 0 || progressAnimationSpec.SourceDurationSeconds <= 0.0 || progressAnimationSpec.SourceFrameCount < 2 || !IsSha256(progressAnimationSpec.SourceAssetSha256))
			{
				throw new InvalidOperationException(progressAnimationSpec.UnitId + " has invalid progress-animation metadata.");
			}
		}
	}

	private static bool IsSha256(string value)
	{
		if (value.Length == 64)
		{
			return value.All((char character) => (character >= '0' && character <= '9') || (character >= 'A' && character <= 'F'));
		}
		return false;
	}

	private static void ValidateManagedPlayAnimationField()
	{
		Type type = FindLoadedType("EM.Lua.Host.GeneratedDelegates");
		CachePatcher.ValidateMvid(type.Module.ModuleVersionId);
		FieldInfo fieldInfo = type.GetField("PlayAnimationHostDelegate", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingFieldException(type.FullName, "PlayAnimationHostDelegate");
		if (fieldInfo.FieldType.IsGenericType || !string.Equals(fieldInfo.FieldType.FullName, "EM.Lua.Host.GeneratedDelegates+PlayAnimation", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("PlayAnimationHostDelegate is not the pinned rooted managed delegate.");
		}
	}

	private static void ValidateUpstreamIdentity()
	{
		CachePatcher.ValidateMvid(FindLoadedType("EM.Lua.FilesCache").Module.ModuleVersionId);
		CanonicalAssemblyContract.RequireCanonicalTypes("SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime", "SupremeCommanderOverhaulUpgradeAnimationFix.CachePatcherRuntime");
	}

	private static void ValidateFile(string path, long expectedBytes, string expectedSha256, string description)
	{
		if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
		{
			throw new FileNotFoundException(description + " has no verifiable file location.", path);
		}
		FileInfo fileInfo = new FileInfo(path);
		if (fileInfo.Length != expectedBytes)
		{
			throw new InvalidOperationException($"{description} size drifted: expected {expectedBytes}, found {fileInfo.Length}.");
		}
		string text;
		using (FileStream inputStream = File.OpenRead(path))
		{
			using SHA256 sHA = SHA256.Create();
			text = BitConverter.ToString(sHA.ComputeHash(inputStream)).Replace("-", string.Empty);
		}
		if (!string.Equals(text, expectedSha256, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException(description + " SHA-256 drifted: expected " + expectedSha256 + ", found " + text + ".");
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

	private static CacheMutation CreateMutation(object cache, string relativePath, string description, Func<string, string> transform)
	{
		CachedResource cachedResource = GetCachedResource(cache, relativePath);
		string text = ReadText(cachedResource.Value);
		string newSource = transform(text);
		return new CacheMutation(cachedResource, description, text, newSource);
	}

	private static CachedResource GetCachedResource(object cache, string relativePath)
	{
		string value = "/" + NormalizePath(relativePath);
		CachedResource cachedResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type = item.GetType();
			if (type.GetProperty("Key")?.GetValue(item, null) is string path && NormalizePath(path).EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cachedResource != null)
				{
					throw new InvalidOperationException("Multiple Lua cache resources match " + relativePath + ".");
				}
				object obj = type.GetProperty("Value")?.GetValue(item, null) ?? throw new InvalidOperationException("Cached " + relativePath + " has no value.");
				EnsureCreated(obj, relativePath);
				cachedResource = new CachedResource(path, obj);
			}
		}
		return cachedResource ?? throw new FileNotFoundException("Required cached Lua source is unavailable.", relativePath);
	}

	private static string NormalizePath(string path)
	{
		return path.Replace('\\', '/').TrimStart(new char[1] { '/' });
	}

	private static string ReadText(object resource)
	{
		EnsureCreated(resource, "Lua cache resource");
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

	private static void VerifyCachedText(object cache, string path, string expected, string description)
	{
		if (!string.Equals(ReadText(GetExactCachedResource(cache, path)), expected, StringComparison.Ordinal))
		{
			throw new InvalidOperationException(description + " verification failed.");
		}
	}

	private static List<Exception> RollBackLua(object? cache, IEnumerable<CacheMutation> mutations)
	{
		CacheMutation[] array = mutations.ToArray();
		List<Exception> list = new List<Exception>();
		if (cache != null)
		{
			foreach (CacheMutation item2 in array.Reverse())
			{
				if (item2.Assigned)
				{
					try
					{
						VerifyCachedText(cache, item2.Resource.Path, item2.NewSource, item2.Description + " rollback ownership");
						SetCachedResource(cache, item2.Resource.Path, item2.Resource.Value);
						VerifyCachedText(cache, item2.Resource.Path, item2.OldSource, item2.Description + " cache rollback");
						item2.Assigned = false;
					}
					catch (Exception item)
					{
						list.Add(item);
					}
				}
			}
		}
		CacheMutation[] array2 = array;
		foreach (CacheMutation cacheMutation in array2)
		{
			if (!cacheMutation.Assigned && cacheMutation.Replacement != null)
			{
				TryDispose(cacheMutation.Replacement, "rolled-back " + cacheMutation.Description);
			}
		}
		return list;
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

	private static void Log(string message)
	{
		string text = "[SCOM Upgrade Animation Fix] " + message;
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
