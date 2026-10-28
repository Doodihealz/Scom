using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using SupremeCommanderOverhaulCanonical;

namespace SupremeCommanderOverhaulGameplayCorrections;

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

	public const string UnitTemplateLoaderPath = "LJ/lua/common/loading/unitTemplateLoader.lua";

	public const string ClientDefaultPath = "LJ/lua/client/units/unitsClasses/unitsDefault.lua";

	public const string EdaClientDefaultPath = "LJ/lua/client/units/unitsClasses/unitsDefaultEDA.lua";

	public const string HostDefaultPath = "LJ/lua/host/units/unitsClasses/unitsDefault.lua";

	public const string HostEntityPath = "LJ/lua/host/entity.lua";

	public const string SeraphimFactoryHostPath = "LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua";

	private const string MainRuntimeType = "SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime";

	private const string BuildBoxRuntimeType = "SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime";

	private const string AudioCompatRuntimeType = "SupremeCommanderOverhaulAudioCompat.CachePatcherRuntime";

	private const string ExpectedMainMvid = "48dd1991-b31b-4297-bd60-0597d33328b5";

	private const string ExpectedMainSha256 = "3EED7306200D5910786221547FF0FB959FA8CF92C85C99D62B98A12175C28B76";

	private const long ExpectedMainBytes = 3819520L;

	private const string ExpectedAudioCompatMvid = "04ece079-4982-4ceb-b33d-91e62f2511f5";

	private const string ExpectedAudioCompatSha256 = "3D44C760EB3088BADC89A841A4951B12910F04BDBBF5734F3FF92FA3C50574AA";

	private const long ExpectedAudioCompatBytes = 65024L;

	private static bool _isApplied;

	public static void Apply()
	{
		if (_isApplied)
		{
			return;
		}
		object obj = null;
		CacheMutation[] array = Array.Empty<CacheMutation>();
		try
		{
			ValidateUpstreamIdentity();
			obj = GetLuaFileCache();
			array = new CacheMutation[6]
			{
				CreateMutation(obj, "LJ/lua/common/loading/unitTemplateLoader.lua", "unit-template and builder-facing correction policy", PatchUnitTemplateLoaderSource),
				CreateMutation(obj, "LJ/lua/client/units/unitsClasses/unitsDefaultEDA.lua", "UEF land-factory construction-beam palette", GameplayCorrectionsPolicy.PatchEdaClientDefaultSource),
				CreateMutation(obj, "LJ/lua/client/units/unitsClasses/unitsDefault.lua", "UEF air-factory construction-beam palette", GameplayCorrectionsPolicy.PatchGenericClientDefaultSource),
				CreateMutation(obj, "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "engineer water-medium probe and builder-facing lifecycle", PatchHostDefaultSource),
				CreateMutation(obj, "LJ/lua/host/entity.lua", "host orientation API compatibility", GameplayCorrectionsPolicy.PatchHostEntitySource),
				CreateMutation(obj, "LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua", "Seraphim factory mobile-ramp orientation gate", GameplayCorrectionsPolicy.PatchSeraphimFactoryHostSource)
			};
			if (array.All((CacheMutation mutation) => !mutation.NeedsWrite))
			{
				_isApplied = true;
				Log("The engineer, commander-beam, builder-facing, faction-palette, Fervor, host-orientation API, and Seraphim factory-orientation corrections are already active.");
				return;
			}
			foreach (CacheMutation item2 in array.Where((CacheMutation cacheMutation2) => cacheMutation2.NeedsWrite))
			{
				item2.Replacement = CreateNativeArrayFromText(item2.Resource.Value.GetType(), item2.NewSource);
			}
			foreach (CacheMutation item3 in array.Where((CacheMutation cacheMutation2) => cacheMutation2.NeedsWrite))
			{
				item3.Assigned = true;
				SetCachedResource(obj, item3.Resource.Path, item3.Replacement);
				if (!string.Equals(ReadText(GetExactCachedResource(obj, item3.Resource.Path)), item3.NewSource, StringComparison.Ordinal))
				{
					throw new InvalidOperationException(item3.Description + " cache write verification failed.");
				}
			}
			foreach (CacheMutation item4 in array.Where((CacheMutation cacheMutation2) => cacheMutation2.NeedsWrite))
			{
				TryDispose(item4.Resource.Value, "replaced " + item4.Description);
			}
			_isApplied = true;
			Log("Restored floating altitude for six FA amphibious engineers, installed exact thin commander-beam contracts and faction-colored construction beams, added dedicated commander/engineer structure-facing during construction, repaired Fervor turret yaw, added a height-aware water probe, set FA gravity/reduction for all four T1 artillery ports, repaired HostEntity orientation through Sanctuary's live engine API, and limited Seraphim side-ramp yaw to mobile products.");
		}
		catch (Exception ex)
		{
			List<Exception> list = new List<Exception>();
			if (obj != null)
			{
				foreach (CacheMutation item5 in array.Reverse())
				{
					if (!item5.Assigned)
					{
						continue;
					}
					try
					{
						Exception ex2 = null;
						try
						{
							SetCachedResource(obj, item5.Resource.Path, item5.Resource.Value);
						}
						catch (Exception ex3)
						{
							ex2 = ex3;
						}
						string a = ReadText(GetExactCachedResource(obj, item5.Resource.Path));
						if (string.Equals(a, item5.OldSource, StringComparison.Ordinal))
						{
							item5.Assigned = false;
							continue;
						}
						if (ex2 != null)
						{
							list.Add(ex2);
						}
						if (string.Equals(a, item5.NewSource, StringComparison.Ordinal))
						{
							throw new InvalidOperationException(item5.Description + " cache rollback retained its replacement.");
						}
						throw new InvalidOperationException(item5.Description + " cache rollback produced unknown contents.");
					}
					catch (Exception item)
					{
						list.Add(item);
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
			if (list.Count != 0)
			{
				Log("Cache mutation failed and rollback was incomplete: " + ex.GetBaseException().Message);
				throw new AggregateException("Gameplay-corrections mutation and rollback both failed.", new Exception[1] { ex }.Concat(list));
			}
			throw new InvalidOperationException("SCOM gameplay corrections could not be installed atomically.", ex);
		}
	}

	private static CacheMutation CreateMutation(object cache, string relativePath, string description, Func<string, string> transform)
	{
		CachedResource cachedResource = GetCachedResource(cache, relativePath);
		string text = ReadText(cachedResource.Value);
		string newSource = transform(text);
		return new CacheMutation(cachedResource, description, text, newSource);
	}

	private static string PatchUnitTemplateLoaderSource(string source)
	{
		return BuilderFacingPolicy.PatchUnitTemplateLoaderSource(GameplayCorrectionsPolicy.PatchUnitTemplateLoaderSource(source));
	}

	private static string PatchHostDefaultSource(string source)
	{
		return BuilderFacingPolicy.PatchHostDefaultSource(GameplayCorrectionsPolicy.PatchHostDefaultSource(source));
	}

	private static void ValidateUpstreamIdentity()
	{
		CachePatcher.ValidateMvid(FindLoadedType("EM.Lua.FilesCache").Module.ModuleVersionId);
		CanonicalAssemblyContract.RequireCanonicalTypes("SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime", "SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime", "SupremeCommanderOverhaulAudioCompat.CachePatcherRuntime", "SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime");
	}

	private static void ValidateSameAssembly(Type runtimeType, Assembly expectedAssembly, string description)
	{
		if ((object)runtimeType.Assembly != expectedAssembly)
		{
			throw new InvalidOperationException(description + " is not linked into the consolidated patcher.");
		}
	}

	private static void ValidateAssemblyIdentity(Assembly assembly, string expectedMvid, long expectedBytes, string expectedSha256, string description)
	{
		string text = assembly.ManifestModule.ModuleVersionId.ToString("D");
		if (!string.Equals(text, expectedMvid, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException(description + " MVID drifted: expected " + expectedMvid + ", found " + text + ".");
		}
		string location = assembly.Location;
		if (string.IsNullOrWhiteSpace(location) || !File.Exists(location))
		{
			throw new InvalidOperationException(description + " has no verifiable file location.");
		}
		FileInfo fileInfo = new FileInfo(location);
		if (fileInfo.Length != expectedBytes)
		{
			throw new InvalidOperationException($"{description} size drifted: expected {expectedBytes}, found {fileInfo.Length}.");
		}
		using FileStream inputStream = File.OpenRead(location);
		using SHA256 sHA = SHA256.Create();
		string text2 = BitConverter.ToString(sHA.ComputeHash(inputStream)).Replace("-", string.Empty);
		if (!string.Equals(text2, expectedSha256, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException(description + " SHA-256 drifted: expected " + expectedSha256 + ", found " + text2 + ".");
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

	private static void Log(string message)
	{
		string text = "[SCOM Gameplay Corrections] " + message;
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
