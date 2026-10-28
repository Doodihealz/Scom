using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Reflection;
using System.Resources;
using System.Security.Cryptography;

namespace CommanderEnhancementsCachePatcher;

public static class Uea0001AssetRuntime
{
	private sealed class AssetSpec
	{
		public string Path { get; }

		public long Bytes { get; }

		public string Sha256 { get; }

		public string LoadedDictionary { get; }

		public AssetSpec(string path, long bytes, string sha256, string loadedDictionary)
		{
			Path = path;
			Bytes = bytes;
			Sha256 = sha256;
			LoadedDictionary = loadedDictionary;
		}
	}

	private sealed class EmbeddedAsset
	{
		public AssetSpec Spec { get; }

		public byte[] Bytes { get; }

		public EmbeddedAsset(AssetSpec spec, byte[] bytes)
		{
			Spec = spec;
			Bytes = bytes;
		}
	}

	private sealed class GamedataMutation
	{
		public uint Id { get; }

		public EmbeddedAsset Asset { get; }

		public object? Original { get; }

		public byte[]? OriginalBytes { get; }

		public object Replacement { get; }

		public bool Assigned { get; set; }

		public GamedataMutation(uint id, EmbeddedAsset asset, object? original, byte[]? originalBytes, object replacement)
		{
			Id = id;
			Asset = asset;
			Original = original;
			OriginalBytes = originalBytes;
			Replacement = replacement;
		}
	}

	private const string AssetPackResource = "CommanderEnhancements.uea0001-assets.sanpack";

	private const string SupportedTrebuchetMvid = "2cc1c6fa-e909-410e-8fd9-2f307b231dfb";

	public const int ExpectedAssetCount = 8;

	public const long AssetPackBytes = 80985L;

	public const string AssetPackSha256 = "5bf1cf61c0c0a64ccb87113210a155e75afd30eb14524c30755d4a0a4136c696";

	private static readonly IReadOnlyList<AssetSpec> Specs = new AssetSpec[8]
	{
		new AssetSpec("UI/Sprites/Icons/Units/uea0001.dds", 4224L, "048e9951e32d1f7246d0ca1591f25b0c6e38a21af39e8e143f73236f3f29009a", "LoadedTextures"),
		new AssetSpec("UI/Sprites/Icons/Units/uea0001.sansprite", 405L, "018c5b3b6067685a774948c891403ec979df2c7a684820c453fe38c86b07c8ce", "SanSpriteDictionary"),
		new AssetSpec("Units/uea0001/LOD0/uea0001.sanskeleton", 1751L, "c2bf5e1a7f30b00ba68e9b5cc816fd82e04399b386a416c0461250c417bb8ab9", "SanSkeletonsDictionary"),
		new AssetSpec("Units/uea0001/LOD0/uea0001_lod0.sanmaterial", 2078L, "eab02edc87a4af0f1097fe3e49c3d67bcfe780977fd38de4ddee38b85cdca5e6", "SanMaterialsDictionary"),
		new AssetSpec("Units/uea0001/LOD0/uea0001_lod0.sanmodel", 5217L, "d066a22f7885edee241fcb21e0051b906134c5a6fb5a27d5a61e091702180f72", "SanModelsDictionary"),
		new AssetSpec("Units/uea0001/LOD0/uea0001_uef_uea0001_albedo.dds", 22000L, "ab08c9bb0fb73d865bae115ee2a76135dec9a21fc6b67fb66660fc529838badf", "LoadedTextures"),
		new AssetSpec("Units/uea0001/LOD0/uea0001_uef_uea0001_mask.dds", 22000L, "4cbbc91b8558d86f64d200987935cfc55c522d9b9a7d14f2d4cbe95174535bd2", "LoadedTextures"),
		new AssetSpec("Units/uea0001/LOD0/uea0001_uef_uea0001_normal.dds", 22000L, "6fa7f5709de5bfb7decca36bef8790cc60b9f8746d56d4cdded48b37c43dca58", "LoadedTextures")
	};

	private static bool _isInstalled;

	public static void InstallEmbeddedAssets()
	{
		if (_isInstalled)
		{
			return;
		}
		IReadOnlyList<EmbeddedAsset> readOnlyList = ReadEmbeddedAssets();
		Type type = FindSingleLoadedType("EM.Gamedata.Data");
		if (!string.Equals(type.Assembly.ManifestModule.ModuleVersionId.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("UEA0001 assets reached an unsupported Trebuchet.dll.");
		}
		Type type2 = type.GetNestedType("GamedataByteEntry", BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingMemberException(type.FullName, "GamedataByteEntry");
		Type type3 = FindSingleLoadedType("EM.Gamedata.IGamedataEntry");
		if (!type3.IsAssignableFrom(type2))
		{
			throw new InvalidOperationException("Trebuchet GamedataByteEntry no longer implements IGamedataEntry.");
		}
		ConstructorInfo constructorInfo = type2.GetConstructor(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic, null, new Type[3]
		{
			typeof(string),
			typeof(string),
			typeof(byte[])
		}, null) ?? throw new MissingMethodException(type2.FullName, ".ctor(string,string,byte[])");
		MethodInfo methodInfo = type3.GetMethod("ID", Type.EmptyTypes) ?? throw new MissingMethodException(type3.FullName, "ID");
		MethodInfo pathMethod = type3.GetMethod("Path", Type.EmptyTypes) ?? throw new MissingMethodException(type3.FullName, "Path");
		MethodInfo methodInfo2 = type3.GetMethod("ReadBytes", Type.EmptyTypes) ?? throw new MissingMethodException(type3.FullName, "ReadBytes");
		MethodInfo methodInfo3 = type.GetMethod("GetFileEntry", BindingFlags.Static | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "GetFileEntry(string)");
		MethodInfo methodInfo4 = type.GetMethod("AddGamedataEntry", BindingFlags.Static | BindingFlags.NonPublic, null, new Type[1] { type3 }, null) ?? throw new MissingMethodException(type.FullName, "AddGamedataEntry");
		object obj = (type.GetField("SanPackLoadedFiles", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "SanPackLoadedFiles")).GetValue(null) ?? throw new InvalidOperationException("SanPackLoadedFiles is null.");
		MethodInfo tryRemove = obj.GetType().GetMethod("TryRemove", BindingFlags.Instance | BindingFlags.Public, null, new Type[2]
		{
			typeof(uint),
			type3.MakeByRefType()
		}, null) ?? throw new MissingMethodException(obj.GetType().FullName, "TryRemove(uint,out IGamedataEntry)");
		Type loadType = FindSingleLoadedType("EM.Gamedata.Load");
		Dictionary<string, object> dictionary = Specs.Select((AssetSpec spec) => spec.LoadedDictionary).Distinct<string>(StringComparer.Ordinal).ToDictionary<string, string, object>((string fieldName) => fieldName, (string fieldName) => (loadType.GetField(fieldName, BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(loadType.FullName, fieldName)).GetValue(null) ?? throw new InvalidOperationException(fieldName + " is null."), StringComparer.Ordinal);
		List<GamedataMutation> list = new List<GamedataMutation>(readOnlyList.Count);
		try
		{
			foreach (EmbeddedAsset item in readOnlyList)
			{
				object obj2 = constructorInfo.Invoke(new object[3]
				{
					typeof(Uea0001AssetRuntime).Assembly.Location,
					item.Spec.Path,
					item.Bytes
				});
				uint id = (uint)(methodInfo.Invoke(obj2, null) ?? throw new InvalidOperationException("GamedataByteEntry.ID returned null."));
				object obj3 = methodInfo3.Invoke(null, new object[1] { item.Spec.Path });
				byte[] originalBytes = null;
				if (obj3 != null)
				{
					ValidateEntryPath(pathMethod, obj3, item.Spec.Path);
					originalBytes = (byte[])(methodInfo2.Invoke(obj3, null) ?? throw new InvalidOperationException("IGamedataEntry.ReadBytes returned null."));
					ValidateDesired(item.Spec, originalBytes);
				}
				else
				{
					EnsureNotLoaded(dictionary[item.Spec.LoadedDictionary], id, item.Spec.Path);
					list.Add(new GamedataMutation(id, item, obj3, originalBytes, obj2));
				}
			}
			foreach (GamedataMutation item2 in list)
			{
				item2.Assigned = true;
				methodInfo4.Invoke(null, new object[1] { item2.Replacement });
				object obj4 = methodInfo3.Invoke(null, new object[1] { item2.Asset.Spec.Path }) ?? throw new InvalidOperationException("UEA0001 gamedata assignment vanished for " + item2.Asset.Spec.Path);
				ValidateEntryPath(pathMethod, obj4, item2.Asset.Spec.Path);
				byte[] bytes = (byte[])(methodInfo2.Invoke(obj4, null) ?? throw new InvalidOperationException("Installed IGamedataEntry.ReadBytes returned null."));
				ValidateDesired(item2.Asset.Spec, bytes);
			}
		}
		catch (Exception ex)
		{
			List<Exception> list2 = RollBack(list, methodInfo4, methodInfo3, methodInfo2, tryRemove, obj);
			if (list2.Count != 0)
			{
				throw new AggregateException("UEA0001 asset installation and rollback both failed.", new Exception[1] { ex }.Concat(list2));
			}
			throw;
		}
		_isInstalled = true;
		Log("Installed eight source-pinned UEA0001 assets transactionally.");
	}

	public static IReadOnlyDictionary<string, byte[]> EmbeddedAssetsForTests()
	{
		return ReadEmbeddedAssets().ToDictionary<EmbeddedAsset, string, byte[]>((EmbeddedAsset asset) => asset.Spec.Path, (EmbeddedAsset asset) => (byte[])asset.Bytes.Clone(), StringComparer.Ordinal);
	}

	public static void ApplyEmbeddedAssetTransactionForTests(IDictionary<string, byte[]> cache, int failAfterAssignments = -1)
	{
		if (cache == null)
		{
			throw new ArgumentNullException("cache");
		}
		IReadOnlyList<EmbeddedAsset> readOnlyList = ReadEmbeddedAssets();
		Dictionary<string, byte[]> dictionary = new Dictionary<string, byte[]>(StringComparer.Ordinal);
		foreach (EmbeddedAsset item in readOnlyList)
		{
			if (cache.TryGetValue(item.Spec.Path, out byte[] value))
			{
				ValidateDesired(item.Spec, value);
				dictionary.Add(item.Spec.Path, value);
			}
			else
			{
				dictionary.Add(item.Spec.Path, null);
			}
		}
		List<string> list = new List<string>(readOnlyList.Count);
		try
		{
			foreach (EmbeddedAsset item2 in readOnlyList)
			{
				if (cache.TryGetValue(item2.Spec.Path, out byte[] value2))
				{
					ValidateDesired(item2.Spec, value2);
					continue;
				}
				cache[item2.Spec.Path] = (byte[])item2.Bytes.Clone();
				list.Add(item2.Spec.Path);
				ValidateDesired(item2.Spec, cache[item2.Spec.Path]);
				if (failAfterAssignments < 0 || list.Count != failAfterAssignments)
				{
					continue;
				}
				throw new InvalidOperationException("Injected UEA0001 asset-transaction failure.");
			}
		}
		catch
		{
			for (int num = list.Count - 1; num >= 0; num--)
			{
				string key = list[num];
				byte[] array = dictionary[key];
				if (array == null)
				{
					cache.Remove(key);
				}
				else
				{
					cache[key] = array;
				}
			}
			throw;
		}
	}

	private static IReadOnlyList<EmbeddedAsset> ReadEmbeddedAssets()
	{
		ValidateManifest();
		using Stream stream = typeof(Uea0001AssetRuntime).Assembly.GetManifestResourceStream("CommanderEnhancements.uea0001-assets.sanpack") ?? throw new MissingManifestResourceException("Missing embedded resource CommanderEnhancements.uea0001-assets.sanpack.");
		if (!stream.CanSeek || stream.Length != 80985 || !string.Equals(Hash(stream), "5bf1cf61c0c0a64ccb87113210a155e75afd30eb14524c30755d4a0a4136c696", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Embedded UEA0001 asset pack identity drifted.");
		}
		stream.Position = 0L;
		using ZipArchive zipArchive = new ZipArchive(stream, ZipArchiveMode.Read, leaveOpen: true);
		ZipArchiveEntry[] array = zipArchive.Entries.Where((ZipArchiveEntry entry) => !string.IsNullOrEmpty(entry.Name)).ToArray();
		string[] second = Specs.Select((AssetSpec spec) => spec.Path).ToArray();
		if (!array.Select((ZipArchiveEntry entry) => entry.FullName).SequenceEqual(second, StringComparer.Ordinal) || array.Any((ZipArchiveEntry entry) => entry.Length != entry.CompressedLength))
		{
			throw new InvalidOperationException("Embedded UEA0001 pack allowlist, order, or store mode drifted.");
		}
		List<EmbeddedAsset> list = new List<EmbeddedAsset>(Specs.Count);
		for (int num = 0; num < Specs.Count; num++)
		{
			byte[] bytes = ReadExactly(array[num]);
			ValidateDesired(Specs[num], bytes);
			list.Add(new EmbeddedAsset(Specs[num], bytes));
		}
		return list;
	}

	private static byte[] ReadExactly(ZipArchiveEntry entry)
	{
		byte[] array = new byte[checked((int)entry.Length)];
		using Stream stream = entry.Open();
		int num;
		for (int i = 0; i < array.Length; i += num)
		{
			num = stream.Read(array, i, array.Length - i);
			if (num == 0)
			{
				throw new EndOfStreamException("Embedded UEA0001 asset ended early: " + entry.FullName + ".");
			}
		}
		if (stream.ReadByte() != -1)
		{
			throw new InvalidDataException("Embedded UEA0001 asset exceeded its declared length: " + entry.FullName + ".");
		}
		return array;
	}

	private static void ValidateManifest()
	{
		if (Specs.Count != 8 || Specs.Select((AssetSpec spec) => spec.Path).Distinct<string>(StringComparer.Ordinal).Count() != 8 || Specs.Any((AssetSpec spec) => spec.Bytes <= 0 || !IsSha256(spec.Sha256)))
		{
			throw new InvalidOperationException("UEA0001 asset manifest drifted.");
		}
	}

	private static void ValidateDesired(AssetSpec spec, byte[] bytes)
	{
		if (bytes.LongLength != spec.Bytes || !string.Equals(Hash(bytes), spec.Sha256, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("UEA0001 asset identity drifted: " + spec.Path + ".");
		}
	}

	private static void ValidateEntryPath(MethodInfo pathMethod, object entry, string expectedPath)
	{
		string text = (string)(pathMethod.Invoke(entry, null) ?? throw new InvalidOperationException("IGamedataEntry.Path returned null."));
		if (!string.Equals(NormalizePath(text), expectedPath, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Gamedata ID collision for " + expectedPath + ": " + text + ".");
		}
	}

	private static void EnsureNotLoaded(object dictionary, uint id, string path)
	{
		if ((bool)((dictionary.GetType().GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(uint) }, null) ?? throw new MissingMethodException(dictionary.GetType().FullName, "ContainsKey(uint)")).Invoke(dictionary, new object[1] { id }) ?? throw new InvalidOperationException("ContainsKey returned null.")))
		{
			throw new InvalidOperationException("UEA0001 asset was loaded before deterministic ownership: " + path + ".");
		}
	}

	private static List<Exception> RollBack(IEnumerable<GamedataMutation> mutations, MethodInfo addGamedataEntry, MethodInfo getFileEntry, MethodInfo readBytesMethod, MethodInfo tryRemove, object indexedEntries)
	{
		List<Exception> list = new List<Exception>();
		foreach (GamedataMutation item2 in mutations.Reverse())
		{
			if (!item2.Assigned)
			{
				continue;
			}
			try
			{
				if (item2.Original == null)
				{
					if (getFileEntry.Invoke(null, new object[1] { item2.Asset.Spec.Path }) != null)
					{
						object[] parameters = new object[2] { item2.Id, null };
						if (!(bool)(tryRemove.Invoke(indexedEntries, parameters) ?? throw new InvalidOperationException("TryRemove returned null.")))
						{
							throw new InvalidOperationException("Could not remove inserted UEA0001 asset " + item2.Asset.Spec.Path + ".");
						}
					}
					if (getFileEntry.Invoke(null, new object[1] { item2.Asset.Spec.Path }) != null)
					{
						throw new InvalidOperationException("Inserted UEA0001 asset survived rollback: " + item2.Asset.Spec.Path + ".");
					}
				}
				else
				{
					addGamedataEntry.Invoke(null, new object[1] { item2.Original });
					object obj = getFileEntry.Invoke(null, new object[1] { item2.Asset.Spec.Path }) ?? throw new InvalidOperationException("Restored UEA0001 asset disappeared: " + item2.Asset.Spec.Path + ".");
					byte[] first = (byte[])(readBytesMethod.Invoke(obj, null) ?? throw new InvalidOperationException("Restored IGamedataEntry.ReadBytes returned null."));
					if (item2.OriginalBytes == null || !first.SequenceEqual(item2.OriginalBytes))
					{
						throw new InvalidOperationException("Restored UEA0001 bytes differ from the exact preimage: " + item2.Asset.Spec.Path + ".");
					}
				}
				item2.Assigned = false;
			}
			catch (Exception item)
			{
				list.Add(item);
			}
		}
		return list;
	}

	private static Type FindSingleLoadedType(string fullName)
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

	private static string Hash(byte[] bytes)
	{
		using SHA256 sHA = SHA256.Create();
		return BitConverter.ToString(sHA.ComputeHash(bytes)).Replace("-", "");
	}

	private static string Hash(Stream stream)
	{
		using SHA256 sHA = SHA256.Create();
		return BitConverter.ToString(sHA.ComputeHash(stream)).Replace("-", "");
	}

	private static bool IsSha256(string value)
	{
		if (value.Length == 64)
		{
			return value.All(Uri.IsHexDigit);
		}
		return false;
	}

	private static string NormalizePath(string path)
	{
		return path.Replace('\\', '/').TrimStart(new char[1] { '/' });
	}

	private static void Log(string message)
	{
		string text = "[SCOM Commander Enhancements] " + message;
		Console.WriteLine(text);
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
