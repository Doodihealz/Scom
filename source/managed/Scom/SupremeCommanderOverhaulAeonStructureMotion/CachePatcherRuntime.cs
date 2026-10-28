using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Reflection;
using System.Resources;
using System.Security.Cryptography;
using System.Text;
using ScomDeterministicLua;

namespace SupremeCommanderOverhaulAeonStructureMotion;

public static class CachePatcherRuntime
{
	private sealed class PatchSpec
	{
		public string RelativePath { get; }

		public string Description { get; }

		public string Appendix { get; }

		public Action<string> ValidateStock { get; }

		public Action<string> ValidatePatched { get; }

		public PatchSpec(string relativePath, string description, string body, Action<string> validateStock, Action<string> validatePatched)
		{
			RelativePath = relativePath;
			Description = description;
			Appendix = "\n\n-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0\n" + body.TrimStart('\r', '\n');
			ValidateStock = validateStock;
			ValidatePatched = validatePatched;
		}
	}

	private sealed class CachedResource
	{
		public string Path { get; }

		public object Stock { get; }

		public string Description { get; }

		public CachedResource(string path, object stock, string description)
		{
			Path = path;
			Stock = stock;
			Description = description;
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

	private sealed class EmbeddedAnimationAsset
	{
		public MotionContract Contract { get; }

		public AssetPin Desired { get; }

		public AssetPin Preimage { get; }

		public byte[] Bytes { get; }

		public EmbeddedAnimationAsset(MotionContract contract, AssetPin desired, AssetPin preimage, byte[] bytes)
		{
			Contract = contract;
			Desired = desired;
			Preimage = preimage;
			Bytes = bytes;
		}
	}

	private sealed class GamedataMutation
	{
		public uint Id { get; }

		public EmbeddedAnimationAsset Asset { get; }

		public object Original { get; }

		public byte[] OriginalBytes { get; }

		public object Replacement { get; }

		public bool Assigned { get; set; }

		public GamedataMutation(uint id, EmbeddedAnimationAsset asset, object original, byte[] originalBytes, object replacement)
		{
			Id = id;
			Asset = asset;
			Original = original;
			OriginalBytes = originalBytes;
			Replacement = replacement;
		}
	}

	public const string OverrideMarker = "-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0";

	private const string AeonUpstreamMarker = "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0";

	private const string AnimationClosureMarker = "-- Supreme Commander Overhaul FA animation closure 1.0.1";

	private const string HostPath = "LJ/lua/host/units/unitsClasses/unitsDefaultChosen.lua";

	private const string WeaponPath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string StorageAssetResource = "AeonStructureMotion.AeonStorageAnimationAssets.sanpack";

	private const string ExtractorAssetResource = "AeonStructureMotion.AeonExtractorAnimationAssets.sanpack";

	private const int ClampPlaybackMode = 0;

	private const int LoopPlaybackMode = 1;

	public static IReadOnlyList<string> PatchPathsForTests => (from spec in BuildPatchSpecs()
		select spec.RelativePath).ToArray();

	public static void InstallEmbeddedStorageAssets()
	{
		ValidatePinnedManifest();
		IReadOnlyList<EmbeddedAnimationAsset> readOnlyList = ReadEmbeddedAnimationAssets();
		Type type = FindSingleLoadedType("EM.Gamedata.Data");
		if (!string.Equals(type.Assembly.ManifestModule.ModuleVersionId.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Embedded storage assets reached an unsupported Trebuchet.dll.");
		}
		Type type2 = type.GetNestedType("GamedataByteEntry", BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingMemberException(type.FullName, "GamedataByteEntry");
		Type type3 = FindSingleLoadedType("EM.Gamedata.IGamedataEntry");
		if (!type3.IsAssignableFrom(type2))
		{
			throw new InvalidOperationException("Trebuchet GamedataByteEntry no longer implements IGamedataEntry.");
		}
		ConstructorInfo constructorInfo = type2.GetConstructor(new Type[3]
		{
			typeof(string),
			typeof(string),
			typeof(byte[])
		}) ?? throw new MissingMethodException(type2.FullName, ".ctor(string,string,byte[])");
		MethodInfo methodInfo = type3.GetMethod("ID", Type.EmptyTypes) ?? throw new MissingMethodException(type3.FullName, "ID");
		MethodInfo methodInfo2 = type3.GetMethod("Path", Type.EmptyTypes) ?? throw new MissingMethodException(type3.FullName, "Path");
		MethodInfo methodInfo3 = type3.GetMethod("ReadBytes", Type.EmptyTypes) ?? throw new MissingMethodException(type3.FullName, "ReadBytes");
		MethodInfo methodInfo4 = type.GetMethod("GetFileEntry", BindingFlags.Static | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "GetFileEntry(string)");
		MethodInfo methodInfo5 = type.GetMethod("AddGamedataEntry", BindingFlags.Static | BindingFlags.NonPublic, null, new Type[1] { type3 }, null) ?? throw new MissingMethodException(type.FullName, "AddGamedataEntry");
		Type type4 = FindSingleLoadedType("EM.Gamedata.Load");
		object obj = (type4.GetField("SanAnimationsDictionary", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type4.FullName, "SanAnimationsDictionary")).GetValue(null) ?? throw new InvalidOperationException("SanAnimationsDictionary is null.");
		MethodInfo methodInfo6 = obj.GetType().GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(uint) }, null) ?? throw new MissingMethodException(obj.GetType().FullName, "ContainsKey(uint)");
		List<GamedataMutation> list = new List<GamedataMutation>(readOnlyList.Count);
		try
		{
			foreach (EmbeddedAnimationAsset item2 in readOnlyList)
			{
				object obj2 = constructorInfo.Invoke(new object[3]
				{
					typeof(CachePatcherRuntime).Assembly.Location,
					item2.Contract.TargetAnimation.Path,
					item2.Bytes
				});
				uint num = (uint)(methodInfo.Invoke(obj2, null) ?? throw new InvalidOperationException("GamedataByteEntry.ID returned null."));
				object obj3 = methodInfo4.Invoke(null, new object[1] { item2.Contract.TargetAnimation.Path });
				if (obj3 == null)
				{
					throw new InvalidOperationException("Required stock gamedata entry is absent: " + item2.Contract.TargetAnimation.Path);
				}
				string text = (string)(methodInfo2.Invoke(obj3, null) ?? throw new InvalidOperationException("IGamedataEntry.Path returned null."));
				if (!string.Equals(NormalizeResourcePath(text), item2.Contract.TargetAnimation.Path, StringComparison.OrdinalIgnoreCase))
				{
					throw new InvalidOperationException("Gamedata ID collision for " + item2.Contract.TargetAnimation.Path + ": " + text);
				}
				byte[] array = (byte[])(methodInfo3.Invoke(obj3, null) ?? throw new InvalidOperationException("IGamedataEntry.ReadBytes returned null."));
				ValidateEmbeddedAnimationPreimage(item2, array);
				if ((bool)(methodInfo6.Invoke(obj, new object[1] { num }) ?? throw new InvalidOperationException("ContainsKey returned null.")))
				{
					throw new InvalidOperationException("Animation was loaded before deterministic cache ownership: " + item2.Contract.TargetAnimation.Path);
				}
				list.Add(new GamedataMutation(num, item2, obj3, array, obj2));
			}
			foreach (GamedataMutation item3 in list)
			{
				methodInfo5.Invoke(null, new object[1] { item3.Replacement });
				item3.Assigned = true;
				object obj4 = methodInfo4.Invoke(null, new object[1] { item3.Asset.Contract.TargetAnimation.Path });
				if (obj4 == null)
				{
					throw new InvalidOperationException("Embedded gamedata assignment vanished for " + item3.Asset.Contract.TargetAnimation.Path);
				}
				byte[] bytes = (byte[])(methodInfo3.Invoke(obj4, null) ?? throw new InvalidOperationException("Installed IGamedataEntry.ReadBytes returned null."));
				ValidateDesiredEmbeddedAnimation(item3.Asset, bytes);
			}
		}
		catch (Exception ex)
		{
			List<Exception> list2 = new List<Exception>();
			for (int num2 = list.Count - 1; num2 >= 0; num2--)
			{
				GamedataMutation gamedataMutation = list[num2];
				if (gamedataMutation.Assigned)
				{
					try
					{
						methodInfo5.Invoke(null, new object[1] { gamedataMutation.Original });
						object obj5 = methodInfo4.Invoke(null, new object[1] { gamedataMutation.Asset.Contract.TargetAnimation.Path }) ?? throw new InvalidOperationException("Rolled-back gamedata entry vanished for " + gamedataMutation.Asset.Contract.TargetAnimation.Path);
						if (!((byte[])(methodInfo3.Invoke(obj5, null) ?? throw new InvalidOperationException("Rolled-back IGamedataEntry.ReadBytes returned null."))).SequenceEqual(gamedataMutation.OriginalBytes))
						{
							throw new InvalidOperationException("Rolled-back gamedata bytes differ from the exact preimage: " + gamedataMutation.Asset.Contract.TargetAnimation.Path);
						}
					}
					catch (Exception item)
					{
						list2.Add(item);
					}
				}
			}
			Log("Embedded animation installation failed closed after rollback: " + ex);
			if (list2.Count != 0)
			{
				throw new AggregateException("Embedded animation installation and rollback both failed.", new Exception[1] { ex }.Concat(list2));
			}
			throw;
		}
		Log("Installed five deterministic embedded Aeon animations after gamedata enumeration.");
	}

	public static IReadOnlyDictionary<string, byte[]> EmbeddedStorageAssetsForTests()
	{
		return ReadEmbeddedAnimationAssets().ToDictionary<EmbeddedAnimationAsset, string, byte[]>((EmbeddedAnimationAsset asset) => asset.Contract.TargetAnimation.Path, (EmbeddedAnimationAsset asset) => (byte[])asset.Bytes.Clone(), StringComparer.Ordinal);
	}

	public static void ApplyEmbeddedStorageTransactionForTests(IDictionary<string, byte[]> cache, int failAfterAssignments = -1)
	{
		if (cache == null)
		{
			throw new ArgumentNullException("cache");
		}
		IReadOnlyList<EmbeddedAnimationAsset> readOnlyList = ReadEmbeddedAnimationAssets();
		Dictionary<string, byte[]> dictionary = new Dictionary<string, byte[]>(StringComparer.Ordinal);
		foreach (EmbeddedAnimationAsset item in readOnlyList)
		{
			if (!cache.TryGetValue(item.Contract.TargetAnimation.Path, out byte[] value))
			{
				throw new InvalidOperationException("Test cache lacks " + item.Contract.TargetAnimation.Path);
			}
			ValidateEmbeddedAnimationPreimage(item, value);
			dictionary.Add(item.Contract.TargetAnimation.Path, value);
		}
		List<string> list = new List<string>(readOnlyList.Count);
		try
		{
			foreach (EmbeddedAnimationAsset item2 in readOnlyList)
			{
				cache[item2.Contract.TargetAnimation.Path] = (byte[])item2.Bytes.Clone();
				list.Add(item2.Contract.TargetAnimation.Path);
				if (failAfterAssignments >= 0 && list.Count == failAfterAssignments)
				{
					throw new InvalidOperationException("Injected embedded-storage failure.");
				}
			}
		}
		catch
		{
			for (int num = list.Count - 1; num >= 0; num--)
			{
				cache[list[num]] = dictionary[list[num]];
			}
			throw;
		}
	}

	public static void Apply()
	{
		ValidatePinnedManifest();
		PatchSpec[] array = BuildPatchSpecs();
		object cache = null;
		List<CacheMutation> mutations = new List<CacheMutation>(array.Length);
		try
		{
			cache = GetLuaFileCache();
			KeyValuePair<PatchSpec, CachedResource>[] array2 = array.Select((PatchSpec spec) => new KeyValuePair<PatchSpec, CachedResource>(spec, GetCachedResource(cache, spec.RelativePath, spec.Description))).ToArray();
			int num = array2.Count((KeyValuePair<PatchSpec, CachedResource> pair) => ContainsMarker(GetText(pair.Value.Stock)));
			KeyValuePair<PatchSpec, CachedResource>[] array3;
			if (num == array2.Length)
			{
				array3 = array2;
				for (int num2 = 0; num2 < array3.Length; num2++)
				{
					KeyValuePair<PatchSpec, CachedResource> keyValuePair = array3[num2];
					keyValuePair.Key.ValidatePatched(GetText(keyValuePair.Value.Stock));
				}
				Log("The 24-template Aeon structure-motion closure is already current against its exact 50-structure disposition ledger.");
				return;
			}
			if (num != 0)
			{
				throw new InvalidOperationException("A partial Aeon structure-motion transaction was found " + $"({num}/{array2.Length}); refusing mixed state ownership.");
			}
			array3 = array2;
			for (int num2 = 0; num2 < array3.Length; num2++)
			{
				KeyValuePair<PatchSpec, CachedResource> keyValuePair2 = array3[num2];
				string text = GetText(keyValuePair2.Value.Stock);
				keyValuePair2.Key.ValidateStock(text);
				QueueAppend(mutations, keyValuePair2.Value, keyValuePair2.Key.Appendix, keyValuePair2.Key.ValidatePatched);
			}
			Commit(cache, mutations);
			Log("Committed 24 exact Aeon structure templates plus host and projectile-fire appendices; 46 structures remain active/visible, both storage rows are asset-backed, the detector-free jammer is visual-only, and hydro remains inactive.");
		}
		catch (Exception ex)
		{
			if (cache != null)
			{
				RollBack(cache, mutations);
			}
			else
			{
				DisposeUncommitted(mutations);
			}
			Log("Disabled for this launch after complete rollback; later cache owners may continue: " + ex.GetBaseException().Message);
		}
	}

	public static string TransformForTests(string relativePath, string source)
	{
		ValidatePinnedManifest();
		PatchSpec[] array = (from spec in BuildPatchSpecs()
			where string.Equals(spec.RelativePath, relativePath, StringComparison.OrdinalIgnoreCase)
			select spec).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException($"Expected one test patch for {relativePath}, found {array.Length}.");
		}
		PatchSpec patchSpec = array[0];
		if (ContainsMarker(source))
		{
			patchSpec.ValidatePatched(source);
			return source;
		}
		patchSpec.ValidateStock(source);
		string text = Append(source, patchSpec.Appendix);
		patchSpec.ValidatePatched(text);
		return text;
	}

	public static void ApplyTextTransactionForTests(IDictionary<string, string> cache, int failAfterAssignments = -1)
	{
		if (cache == null)
		{
			throw new ArgumentNullException("cache");
		}
		ValidatePinnedManifest();
		PatchSpec[] array = BuildPatchSpecs();
		Dictionary<string, string> dictionary = cache.ToDictionary<KeyValuePair<string, string>, string, string>((KeyValuePair<string, string> pair) => pair.Key, (KeyValuePair<string, string> pair) => pair.Value, StringComparer.OrdinalIgnoreCase);
		string value2;
		int num = array.Count((PatchSpec spec) => cache.TryGetValue(spec.RelativePath, out value2) && ContainsMarker(value2));
		PatchSpec[] array2;
		if (num == array.Length)
		{
			array2 = array;
			foreach (PatchSpec patchSpec in array2)
			{
				patchSpec.ValidatePatched(cache[patchSpec.RelativePath]);
			}
			return;
		}
		if (num != 0)
		{
			throw new InvalidOperationException($"A partial test transaction was found ({num}/{array.Length}).");
		}
		Dictionary<string, string> dictionary2 = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
		array2 = array;
		foreach (PatchSpec patchSpec2 in array2)
		{
			if (!cache.TryGetValue(patchSpec2.RelativePath, out string value))
			{
				throw new FileNotFoundException("Test cache lacks " + patchSpec2.Description, patchSpec2.RelativePath);
			}
			patchSpec2.ValidateStock(value);
			string text = Append(value, patchSpec2.Appendix);
			patchSpec2.ValidatePatched(text);
			dictionary2.Add(patchSpec2.RelativePath, text);
		}
		int num3 = 0;
		try
		{
			foreach (KeyValuePair<string, string> item in dictionary2)
			{
				cache[item.Key] = item.Value;
				num3++;
				if (failAfterAssignments >= 0 && num3 == failAfterAssignments)
				{
					throw new InvalidOperationException("Injected text-cache commit failure.");
				}
			}
		}
		catch
		{
			cache.Clear();
			foreach (KeyValuePair<string, string> item2 in dictionary)
			{
				cache.Add(item2.Key, item2.Value);
			}
			throw;
		}
	}

	public static void ValidateManifestForTests()
	{
		ValidatePinnedManifest();
	}

	private static PatchSpec[] BuildPatchSpecs()
	{
		List<PatchSpec> list = new List<PatchSpec>(MotionManifest.ReadyContracts.Count + 2);
		foreach (MotionContract readyContract in MotionManifest.ReadyContracts)
		{
			MotionContract captured = readyContract;
			list.Add(new PatchSpec(readyContract.TemplatePath, readyContract.TargetId + " <- " + readyContract.SourceId + " motion template", BuildTemplateBody(readyContract), delegate(string source)
			{
				ValidateStockTemplate(source, captured);
			}, delegate(string source)
			{
				ValidatePatchedTemplate(source, captured);
			}));
		}
		list.Add(new PatchSpec("LJ/lua/host/units/unitsClasses/unitsDefaultChosen.lua", "Aeon structure-motion lifecycle host classes", LoadEmbeddedText("AeonStructureMotion.host_appendix.lua"), ValidateStockHost, ValidatePatchedHost));
		list.Add(new PatchSpec("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Aeon Dome projectile-fire observer", LoadEmbeddedText("AeonStructureMotion.weapon_appendix.lua"), ValidateStockWeapon, ValidatePatchedWeapon));
		IGrouping<string, PatchSpec> grouping = list.GroupBy<PatchSpec, string>((PatchSpec spec) => spec.RelativePath, StringComparer.OrdinalIgnoreCase).FirstOrDefault((IGrouping<string, PatchSpec> group) => group.Count() != 1);
		if (grouping != null)
		{
			throw new InvalidOperationException("Aeon structure-motion patch path is duplicated: " + grouping.Key);
		}
		return list.ToArray();
	}

	private static int PlaybackModeFor(ClipPin clip)
	{
		return (clip.Role == "pump") ? 1 : 0;
	}

	private static string BuildTemplateBody(MotionContract contract)
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("UnitTemplate.additions = UnitTemplate.additions or {}");
		stringBuilder.AppendLine("UnitTemplate.visuals = UnitTemplate.visuals or {}");
		stringBuilder.AppendLine("UnitTemplate.visuals.animations = UnitTemplate.visuals.animations or {}");
		foreach (ClipPin item in contract.Clips.Where((ClipPin clip) => clip.Role != "preserved_deploy"))
		{
			stringBuilder.Append("if not UnitTemplate.visuals.animations.").Append(item.TemplateKey).Append(" or UnitTemplate.visuals.animations.")
				.Append(item.TemplateKey)
				.Append(".clipName ~= \"")
				.Append(EscapeLua(item.ClipName))
				.AppendLine("\" then");
			stringBuilder.Append("    error(\"").Append(contract.TargetId).Append(" requires exact clip ")
				.Append(EscapeLua(item.ClipName))
				.AppendLine("\")");
			stringBuilder.AppendLine("end");
			stringBuilder.Append("UnitTemplate.visuals.animations.").Append(item.TemplateKey).Append(".playbackMode = ")
				.Append(PlaybackModeFor(item).ToString(CultureInfo.InvariantCulture))
				.AppendLine();
			if (item.Role == "upgrade")
			{
				stringBuilder.Append("UnitTemplate.visuals.animations.").Append(item.TemplateKey).AppendLine(".authoredSpeed = 1");
			}
		}
		if (contract.StorageClip != null)
		{
			StorageClipPin storageClip = contract.StorageClip;
			stringBuilder.Append("if UnitTemplate.visuals.animations.").Append(storageClip.TemplateKey).AppendLine(" ~= nil then");
			stringBuilder.Append("    error(\"").Append(contract.TargetId).Append(" requires unowned storage clip key ")
				.Append(EscapeLua(storageClip.TemplateKey))
				.AppendLine("\")");
			stringBuilder.AppendLine("end");
			stringBuilder.Append("UnitTemplate.visuals.animations.").Append(storageClip.TemplateKey).AppendLine(" = {");
			stringBuilder.Append("    clipName = \"").Append(EscapeLua(storageClip.ClipName)).AppendLine("\",");
			stringBuilder.Append("    sanAnimationPath = \"").Append(EscapeLua(contract.TargetAnimation.Path)).AppendLine("\",");
			stringBuilder.Append("    playbackMode = ").Append(0.ToString(CultureInfo.InvariantCulture)).AppendLine(",");
			stringBuilder.AppendLine("}");
		}
		if (contract.TargetId == "ucs3603")
		{
			stringBuilder.AppendLine("UnitTemplate.general.toggles = {");
			stringBuilder.AppendLine("    Production = true,");
			stringBuilder.AppendLine("}");
		}
		if (contract.RotatorBones.Count > 0)
		{
			stringBuilder.AppendLine("UnitTemplate.additions.rotators = {");
			foreach (string rotatorBone in contract.RotatorBones)
			{
				stringBuilder.AppendLine("    {");
				stringBuilder.Append("        boneName = \"").Append(EscapeLua(rotatorBone)).AppendLine("\",");
				stringBuilder.AppendLine("        speed = { x = 0, y = 0, z = 0 },");
				stringBuilder.AppendLine("        isVelocityScalingEnabled = false,");
				stringBuilder.AppendLine("    },");
			}
			stringBuilder.AppendLine("}");
		}
		stringBuilder.AppendLine("UnitTemplate.additions.aeonStructureMotion = {");
		stringBuilder.Append("    version = \"").Append("1.0.2").AppendLine("\",");
		stringBuilder.Append("    mapping = \"").Append(contract.SourceId).Append(" -> ")
			.Append(contract.TargetId)
			.AppendLine("\",");
		stringBuilder.Append("    kind = \"").Append(contract.Kind).AppendLine("\",");
		stringBuilder.Append("    stateOwner = \"").Append(EscapeLua(contract.StateContract)).AppendLine("\",");
		if (!string.IsNullOrEmpty(contract.AuditedLimitation))
		{
			stringBuilder.Append("    auditedLimitation = \"").Append(EscapeLua(contract.AuditedLimitation)).AppendLine("\",");
		}
		stringBuilder.AppendLine("    aimBoneOwnership = \"Sanctuary runtime only\",");
		stringBuilder.Append("    sourceArchiveSha256 = \"").Append("c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26".ToLowerInvariant()).AppendLine("\",");
		stringBuilder.Append("    sourceLuaArchiveSha256 = \"").Append("3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb").AppendLine("\",");
		stringBuilder.Append("    sourceBlueprint = \"").Append(contract.SourceBlueprintPath).AppendLine("\",");
		stringBuilder.Append("    sourceBlueprintSha256 = \"").Append(contract.SourceBlueprintSha256).AppendLine("\",");
		stringBuilder.Append("    sourceScript = \"").Append(contract.SourceScriptPath).AppendLine("\",");
		stringBuilder.Append("    sourceScriptSha256 = \"").Append(contract.SourceScriptSha256).AppendLine("\",");
		stringBuilder.Append("    sourceModelSha256 = \"").Append(contract.SourceModelSha256).AppendLine("\",");
		AppendAsset(stringBuilder, "targetModel", contract.TargetModel);
		AppendAsset(stringBuilder, "targetSkeleton", contract.TargetSkeleton);
		AppendAsset(stringBuilder, "targetAnimation", contract.TargetAnimation);
		stringBuilder.Append("    targetClipCount = ").Append(contract.TargetClipCount).AppendLine(",");
		stringBuilder.Append("    rotatorCount = ").Append(contract.RotatorBones.Count).AppendLine(",");
		stringBuilder.AppendLine("    sourceClips = {");
		foreach (ClipPin clip in contract.Clips)
		{
			stringBuilder.AppendLine("        {");
			stringBuilder.Append("            name = \"").Append(clip.ClipName).AppendLine("\",");
			stringBuilder.Append("            key = \"").Append(clip.TemplateKey).AppendLine("\",");
			stringBuilder.Append("            role = \"").Append(clip.Role).AppendLine("\",");
			stringBuilder.Append("            source = \"").Append(clip.SourcePath).AppendLine("\",");
			stringBuilder.Append("            sha256 = \"").Append(clip.SourceSha256).AppendLine("\",");
			stringBuilder.Append("            frames = ").Append(clip.SourceFrames).AppendLine(",");
			stringBuilder.Append("            durationSeconds = ").Append(Lua(clip.SourceDurationSeconds)).AppendLine(",");
			stringBuilder.Append("            rate = ").Append(Lua(clip.SourceRate)).AppendLine(",");
			stringBuilder.AppendLine("        },");
		}
		stringBuilder.AppendLine("    },");
		ClipPin clipPin = contract.Clips.FirstOrDefault((ClipPin clip) => clip.Role == "pump" || clip.Role == "open" || clip.Role == "permanent_open" || clip.Role == "intel_open");
		if (clipPin != null)
		{
			AppendRuntimeClip(stringBuilder, "primaryClip", clipPin);
		}
		if (contract.DeathClip != null)
		{
			AppendRuntimeClip(stringBuilder, "deathClip", contract.DeathClip);
		}
		if (contract.StorageClip != null)
		{
			StorageClipPin storageClip2 = contract.StorageClip;
			stringBuilder.AppendLine("    storageClip = {");
			stringBuilder.Append("        key = \"").Append(storageClip2.TemplateKey).AppendLine("\",");
			stringBuilder.Append("        name = \"").Append(storageClip2.ClipName).AppendLine("\",");
			stringBuilder.Append("        resource = \"").Append(storageClip2.ResourceName).AppendLine("\",");
			stringBuilder.Append("        durationSeconds = ").Append(Lua(storageClip2.DurationSeconds)).AppendLine(",");
			stringBuilder.Append("        localZDelta = ").Append(Lua(storageClip2.LocalZDelta)).AppendLine(",");
			stringBuilder.Append("        assetPackBytes = ").Append(9166L).AppendLine(",");
			stringBuilder.Append("        assetPackSha256 = \"").Append("1c343fb3c33848d3e16e546edbee827f66b4a8f25fe4324c302829eef979c297").AppendLine("\",");
			stringBuilder.AppendLine("    },");
		}
		stringBuilder.AppendLine("}");
		ClipPin clipPin2 = contract.Clips.SingleOrDefault((ClipPin clip) => clip.Role == "upgrade");
		if (clipPin2 != null)
		{
			stringBuilder.AppendLine("UnitTemplate.additions.progressBoundUpgradeAnimation = {");
			stringBuilder.Append("    animationKey = \"").Append(clipPin2.TemplateKey).AppendLine("\",");
			stringBuilder.Append("    durationSeconds = ").Append(Lua(clipPin2.SourceDurationSeconds)).AppendLine(",");
			stringBuilder.AppendLine("    restAnimationKey = \"walk\",");
			stringBuilder.AppendLine("}");
		}
		if (contract.Kind == "dome_recoil")
		{
			stringBuilder.AppendLine("if not UnitTemplate.weapons or not UnitTemplate.weapons[1] then");
			stringBuilder.AppendLine("    error(\"ucs2402 Dome step requires its source anti-missile weapon\")");
			stringBuilder.AppendLine("end");
			stringBuilder.AppendLine("UnitTemplate.weapons[1].scoAeonStructureMotionDomeStep = true");
		}
		return stringBuilder.ToString();
	}

	private static void AppendAsset(StringBuilder builder, string key, AssetPin asset)
	{
		builder.Append("    ").Append(key).AppendLine(" = {");
		builder.Append("        path = \"").Append(asset.Path).AppendLine("\",");
		builder.Append("        bytes = ").Append(asset.Bytes).AppendLine(",");
		builder.Append("        sha256 = \"").Append(asset.Sha256).AppendLine("\",");
		builder.AppendLine("    },");
	}

	private static void AppendRuntimeClip(StringBuilder builder, string key, ClipPin clip)
	{
		builder.Append("    ").Append(key).AppendLine(" = {");
		builder.Append("        key = \"").Append(clip.TemplateKey).AppendLine("\",");
		builder.Append("        durationSeconds = ").Append(Lua(clip.SourceDurationSeconds)).AppendLine(",");
		builder.Append("        rate = ").Append(Lua(clip.SourceRate)).AppendLine(",");
		builder.AppendLine("    },");
	}

	private static void ValidateStockTemplate(string source, MotionContract contract)
	{
		RequireTokens(source, "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0", "tpId = \"" + contract.TargetId + "\"", "sourceId = \"" + contract.SourceId + "\"", "sourceBlueprintSha256 = \"" + contract.SourceBlueprintSha256 + "\"", "\"unitsDefaultChosen\"", "\"" + contract.ClassName + "\"", contract.TargetAnimation.Path);
		foreach (ClipPin clip in contract.Clips)
		{
			RequireTokens(source, "clipName = \"" + clip.ClipName + "\"", clip.TemplateKey);
			if (clip.Role == "upgrade")
			{
				RequireExactly(source, "UnitTemplate.visuals.animations." + clip.TemplateKey + ".authoredSpeed", 0, contract.TargetId + " preexisting progress-animation speed owner");
			}
		}
		if (contract.StorageClip != null)
		{
			RequireExactly(source, contract.StorageClip.TemplateKey, 0, contract.TargetId + " preexisting storage clip key");
		}
		ValidateOperationalInputs(source, contract, isPatched: false);
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0", 0, contract.TargetId + " preexisting marker");
		if (contract.TargetId == "ucs2402")
		{
			RequireTokens(source, "-- Supreme Commander Overhaul FA animation closure 1.0.1", "faAnimationClosureWeaponDeploy", "scoFaAnimationClosureDeploy = true");
			RequireExactly(source, "-- Supreme Commander Overhaul FA animation closure 1.0.1", 1, "ucs2402 deploy owner marker");
		}
		else
		{
			RequireExactly(source, "-- Supreme Commander Overhaul FA animation closure 1.0.1", 0, contract.TargetId + " unexpected FA animation-closure owner");
		}
	}

	private static void ValidatePatchedTemplate(string source, MotionContract contract)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0", 1, contract.TargetId + " marker");
		ValidateOperationalInputs(source, contract, isPatched: true);
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "mapping = \"" + contract.SourceId + " -> " + contract.TargetId + "\"", "kind = \"" + contract.Kind + "\"", contract.SourceBlueprintSha256, contract.SourceScriptSha256, contract.SourceModelSha256, contract.TargetModel.Sha256, contract.TargetSkeleton.Sha256, contract.TargetAnimation.Sha256, "aimBoneOwnership = \"Sanctuary runtime only\"", "targetClipCount = " + contract.TargetClipCount.ToString(CultureInfo.InvariantCulture), "rotatorCount = " + contract.RotatorBones.Count.ToString(CultureInfo.InvariantCulture));
		foreach (string rotatorBone in contract.RotatorBones)
		{
			RequireExactly(source2, "boneName = \"" + rotatorBone + "\"", 1, contract.TargetId + "/" + rotatorBone + " rotator");
		}
		foreach (ClipPin clip in contract.Clips)
		{
			RequireTokens(source2, clip.SourceSha256, "role = \"" + clip.Role + "\"");
			if (clip.Role != "preserved_deploy")
			{
				RequireTokens(source2, "UnitTemplate.visuals.animations." + clip.TemplateKey + ".playbackMode = " + PlaybackModeFor(clip));
			}
		}
		if (contract.StorageClip != null)
		{
			StorageClipPin storageClip = contract.StorageClip;
			RequireTokens(source2, "UnitTemplate.visuals.animations." + storageClip.TemplateKey + " = {", "clipName = \"" + storageClip.ClipName + "\"", "sanAnimationPath = \"" + contract.TargetAnimation.Path + "\"", "playbackMode = " + 0.ToString(CultureInfo.InvariantCulture), "resource = \"" + storageClip.ResourceName + "\"", "durationSeconds = " + Lua(storageClip.DurationSeconds), "localZDelta = " + Lua(storageClip.LocalZDelta), "assetPackBytes = " + 9166L.ToString(CultureInfo.InvariantCulture), "assetPackSha256 = \"1c343fb3c33848d3e16e546edbee827f66b4a8f25fe4324c302829eef979c297\"");
			RequireExactly(source2, storageClip.TemplateKey, 4, contract.TargetId + " storage clip-key contract");
			foreach (string requiredBone in contract.RequiredBones)
			{
				RequireExactly(source2, "boneName = \"" + requiredBone + "\"", 0, contract.TargetId + "/" + requiredBone + " forbidden runtime rotator");
			}
		}
		if (!string.IsNullOrEmpty(contract.AuditedLimitation))
		{
			RequireExactly(source2, "auditedLimitation = \"" + EscapeLua(contract.AuditedLimitation) + "\"", 1, contract.TargetId + " audited retail limitation");
			RequireExactly(source2, "UnitTemplate.visuals.animations.source_animaopen", 0, contract.TargetId + " invented/missing AnimOpen binding");
		}
		if (contract.HasUpgradeClip)
		{
			ClipPin clipPin = contract.Clips.Single((ClipPin clip) => clip.Role == "upgrade");
			RequireExactly(source2, "progressBoundUpgradeAnimation = {", 1, contract.TargetId + " progress binding");
			RequireExactly(source2, "UnitTemplate.visuals.animations." + clipPin.TemplateKey + ".authoredSpeed = 1", 1, contract.TargetId + " progress-animation freeze owner");
		}
		if (contract.Kind == "dome_recoil")
		{
			RequireExactly(source2, "scoAeonStructureMotionDomeStep = true", 1, "ucs2402 Dome-only weapon flag");
			RequireTokens(source, "-- Supreme Commander Overhaul FA animation closure 1.0.1", "faAnimationClosureWeaponDeploy", "scoFaAnimationClosureDeploy = true");
		}
	}

	private static void ValidateOperationalInputs(string source, MotionContract contract, bool isPatched)
	{
		string source2 = NormalizeNewlines(source);
		switch (contract.TargetId)
		{
		case "ucs3603":
			RequireExactly(source2, "UnitTemplate.economy.production = {\n    alloys = 12,\n    energy = 0,\n}", 1, "ucs3603 generated production contract");
			RequireExactly(source2, "UnitTemplate.economy.maintenanceConsumption = {\n    alloys = 0,\n    energy = 3500,\n}", 1, "ucs3603 generated maintenance contract");
			RequireExactly(source2, "UnitTemplate.general.toggles = {\n    Production = true,\n}", isPatched ? 1 : 0, isPatched ? "ucs3603 owned Production-toggle contract" : "ucs3603 unowned Production-toggle slot");
			RequireExactly(source2, "Production = true", isPatched ? 1 : 0, isPatched ? "ucs3603 sole Production-toggle owner" : "ucs3603 completely unowned toggle slot");
			break;
		case "ucs1701":
			RequireTokens(source2, "radarRadius = 115");
			break;
		case "ucs3701":
			RequireTokens(source2, "radarRadius = 600");
			break;
		case "ucs2701":
			RequireTokens(source2, "radarRadius = 200");
			break;
		case "ucs2711":
			RequireTokens(source2, "radarStealthFieldRadius = 24");
			RequireExactly(source2, "radarRadius =", 0, "ucs2711 unsupported Sanctuary radar detector");
			break;
		}
	}

	private static void ValidateStockHost(string source)
	{
		RequireTokens(source, "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0", "-- Supreme Commander Overhaul FA animation closure 1.0.1", "AeonPortStructure = Class(\"AeonPortStructure\"", "AeonPortStorage = Class(\"AeonPortStorage\"", "AeonPortAlloyExtractor = Class(\"AeonPortAlloyExtractor\"", "AeonPortEnergyGenerator = Class(\"AeonPortEnergyGenerator\"", "function AeonPortStructure:OnStopBeingBuilt()");
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0", 0, "host preexisting marker");
	}

	private static void ValidatePatchedHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0", 1, "host marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "SCO_ASM_SENTINEL = -10000", "SCO_ASM_LOOP_SENTINEL = -20000", "SCO_ASM_LOOP_SENTINEL - elapsed", "unit.scoAsmPumpElapsed = elapsed", "local stockStop = unitClass.OnStopBeingBuilt", "local stockPause = unitClass.SetPause", "local stockCheckProductionState = unitClass.CheckProductionState", "local stockCheckRadarState = unitClass.CheckRadarState", "local stockCheckShieldState = unitClass.CheckShieldState", "local stockDestroy = unitClass.OnDestroy", "local stockDelete = unitClass.Delete", "local stockDeath = unitClass.DeathThread", "function unitClass:OnStopBeingBuilt()", "function unitClass:SetPause(value)", "function unitClass:CheckProductionState()", "function unitClass:CheckRadarState()", "function unitClass:CheckShieldState(skipRecharge)", "function unitClass:DeathThread(overkillRatio)", "SCO_ASM_Install(AeonPortStructure", "SCO_ASM_Install(AeonPortStorage", "SCO_ASM_Install(AeonPortAlloyExtractor", "SCO_ASM_Install(AeonPortEnergyGenerator", "local function SCO_ASM_PumpLoopThread(unit, generation)", "local function SCO_ASM_PumpStateThread(unit, generation)", "sample = SCO_ASM_AdvanceLoopSample(sample, clip)", "phase = \"stopped\"", "local SCO_ASM_INSTALL_VERSION = \"1.0.2\"", "local function SCO_ASM_StorageThread(unit, generation)", "economy:GetResourceStoredRatio(clip.resource)", "unit.scoAsmStorageRatio ~= ratio", "SCO_ASM_Sample(unit, clip.key, ratio * clip.durationSeconds)", "unit.scoAsmStorageRatio = nil", "unit.radarDetector:GetEnabled() == true", "unit.toggles and unit.toggles.Intel ~= nil", "not unit.army.economy.isEnergyDown", "return SCO_ASM_JammerEnabled(unit)", "SCO_ASM_UpdateIntelState(self)", "if unit.progress == nil then return end", "local function SCO_ASM_RotatorThread(unit, generation)", "local function SCO_ASM_RotatorAcceleration(kind, active)", "unit:GetProductionToggle() == true", "local function SCO_ASM_PreservesRotatorsDuringUpgrade(contract)", "if not SCO_ASM_PreservesRotatorsDuringUpgrade(contract) then", "if kind == \"intel_rotor_pair_upgrade\" and not active then", "return 60", "return 20", "return 15", "speed,\n            enabled and 60 or 0,\n            50 * Constants.TickTimeStep", "11 * 0.1 * 40 + 1 * 0.1 * 10 = exactly 45 degrees", "local function SCO_ASM_ShieldThread(unit, generation)", "if unit.progress == nil or unit.shields == nil then return end", "pod = SCO_ASM_Approach(pod, enabled and 60 or 0, 50 * tick)", "orbPrimary, enabled and -45 or 0, 45 * tick", "SCO_ASM_SetRotator(unit, 1, 0, 0, pod)", "SCO_ASM_SetRotator(unit, 2, orbPrimary, 0, orbZ)", "SCO_ASM_SetRotator(unit, 2, 0, orbPrimary, orbZ)", "unitClass.SCO_AeonStructureMotionDomeStep = SCO_ASM_DomeStep", "return inherited(unit, overkillRatio)");
		RequireExactly(source2, "math.random", 0, "nondeterministic host random call");
		RequireExactly(source2, "function unitClass:SetIntelEnabled", 0, "obsolete promotion-only intel lifecycle wrapper");
		RequireExactly(source2, "SCO_ASM_ApplySteady", 0, "instant source-rotator speed application");
		RequireExactly(source2, "playbackDurationSeconds", 0, "obsolete compressed extractor timeline");
		RequireExactly(source2, "authoredHoldStartSeconds", 0, "obsolete compressed extractor hold map");
		RequireExactly(source2, "phase = \"close\"", 0, "obsolete T3 reverse-close phase");
		RequireExactly(source2, "kind == \"fabricator_rotators\"\n        return not unit:GetPause()", 0, "generic-Pause-owned fabricator rotators");
		RequireExactly(source2, "Engine.PlayAnimation", 3, "host animation transports");
	}

	private static void ValidateStockWeapon(string source)
	{
		RequireTokens(source, "-- Supreme Commander Overhaul FA animation closure 1.0.1", "function HostWeapon:Update()", "function HostWeapon:UpdateProjectile(isOnTarget)", "ShootSalvo                    = 2", "local projectilePrefabID = self.projectileTemplate.general.prefabID", "if projectilePrefabID then", "self:GetDesiredProjectileValues(muzzle.aimControllerId)", "if desiredProjectileSpeed then", "Engine.InstantiatePrefab(projectilePrefabID");
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0", 0, "weapon preexisting marker");
	}

	private static void ValidatePatchedWeapon(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0", 1, "weapon marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "local SCO_ASM_StockUpdateProjectile = HostWeapon.UpdateProjectile", "local function SCO_ASM_SpawnCapableProjectileCount(weapon)", "function HostWeapon:UpdateProjectile(isOnTarget)", "weapon.muzzleGroups[weapon.currentMuzzleGroupIndex]", "weapon.projectileTemplate", "general.prefabID", "weapon:GetDesiredProjectileValues(muzzle.aimControllerId)", "if desiredProjectileSpeed then", "self.tp.scoAeonStructureMotionDomeStep == true", "local spawnCapableShots = ownsDomeStep", "for _ = 1, spawnCapableShots do", "self.unit:SCO_AeonStructureMotionDomeStep()", "SCO_ASM_StockUpdateProjectile(self, isOnTarget)");
		RequireExactly(source2, "local wasShootSalvo", 0, "state-transition-only Dome fire gate");
		RequireExactly(source2, "function HostWeapon:Update()", 0, "unexpected takeover of FA Animation Closure HostWeapon.Update");
	}

	private static void ValidatePinnedManifest()
	{
		string[] second = new string[24]
		{
			"ucs1601", "ucs2806", "ucs2601", "ucs2611", "ucs3611", "ucs3601", "ucs3603", "ucs2201", "ucs2001", "ucs2101",
			"ucs3201", "ucs1701", "ucs1702", "ucs3701", "ucs2701", "ucs2702", "ucs2402", "ucs2711", "ucs3402", "ucs4102",
			"ucs2401", "ucs3401", "ucs1612", "ucs1602"
		};
		string[] second2 = Array.Empty<string>();
		if (!MotionManifest.ReadyContracts.Select((MotionContract motionContract5) => motionContract5.TargetId).SequenceEqual<string>(second, StringComparer.Ordinal) || !MotionManifest.QuarantinedContracts.Select((MotionContract motionContract5) => motionContract5.TargetId).SequenceEqual<string>(second2, StringComparer.Ordinal) || !MotionManifest.InactiveContracts.Select((MotionContract motionContract5) => motionContract5.TargetId).SequenceEqual<string>(new string[1] { "ucs1614" }, StringComparer.Ordinal))
		{
			throw new InvalidOperationException("The reviewed 24/0/1 motion scope changed.");
		}
		if (MotionManifest.All.Select((MotionContract motionContract5) => motionContract5.TargetId).Distinct<string>(StringComparer.Ordinal).Count() != MotionManifest.All.Count)
		{
			throw new InvalidOperationException("The Aeon motion manifest contains duplicate targets.");
		}
		string[] second3 = new string[50]
		{
			"ucs1601", "ucs2806", "ucs2601", "ucs2611", "ucs3611", "ucs3601", "ucs3603", "ucs2201", "ucs2001", "ucs2101",
			"ucs3201", "ucs1701", "ucs1702", "ucs3701", "ucs2701", "ucs2702", "ucs2402", "ucs2711", "ucs3402", "ucs4102",
			"ucs2401", "ucs3401", "ucs1612", "ucs1602", "ucs1614", "ucs2102", "ucs3102", "ucs1511", "ucs2511", "ucs1512",
			"ucs2512", "ucs1513", "ucs2513", "ucs3511", "ucs3512", "ucs3513", "ucs2510", "ucs1611", "ucs1804", "ucs3501",
			"ucs3702", "ucs1001", "ucs1201", "ucs1301", "ucs2301", "ucs3101", "ucs3001", "ucs2802", "ucs2801", "ucs1501"
		};
		if (MotionManifest.StructureLedger.Count != 50 || !MotionManifest.StructureLedger.Select((StructureDisposition row) => row.TargetId).SequenceEqual<string>(second3, StringComparer.Ordinal) || MotionManifest.StructureLedger.Select((StructureDisposition row) => row.TargetId).Distinct<string>(StringComparer.Ordinal).Count() != 50 || MotionManifest.StructureLedger.Count((StructureDisposition row) => row.RosterVisible && row.Owner != "inactive") != 46 || MotionManifest.StructureLedger.Count((StructureDisposition row) => row.Owner == "inactive") != 1 || MotionManifest.StructureLedger.Count((StructureDisposition row) => !row.RosterVisible) != 3 || MotionManifest.StructureLedger.Count((StructureDisposition row) => row.Owner == "closure") != 24 || MotionManifest.StructureLedger.Count((StructureDisposition row) => row.Owner == "existing_owner") != 8 || MotionManifest.StructureLedger.Count((StructureDisposition row) => row.Owner == "factory_runtime") != 4 || MotionManifest.StructureLedger.Count((StructureDisposition row) => row.Owner == "source_static") != 4 || MotionManifest.StructureLedger.Count((StructureDisposition row) => row.Owner == "aim_only") != 6 || MotionManifest.StructureLedger.Count((StructureDisposition row) => row.Owner == "hidden") != 3 || MotionManifest.StructureLedger.Any((StructureDisposition row) => string.IsNullOrWhiteSpace(row.SourceId) || string.IsNullOrWhiteSpace(row.Rationale)))
		{
			throw new InvalidOperationException("The exact 50-structure disposition ledger changed.");
		}
		Dictionary<string, StructureDisposition> dictionary = MotionManifest.StructureLedger.ToDictionary<StructureDisposition, string>((StructureDisposition row) => row.TargetId, StringComparer.Ordinal);
		foreach (MotionContract item2 in MotionManifest.All)
		{
			StructureDisposition structureDisposition = dictionary[item2.TargetId];
			string text = ((item2.Status == MotionStatus.Ready) ? "closure" : "inactive");
			if (structureDisposition.SourceId != item2.SourceId || structureDisposition.Owner != text)
			{
				throw new InvalidOperationException(item2.TargetId + " manifest/ledger ownership diverged.");
			}
		}
		string[] first = (from row in MotionManifest.StructureLedger
			where row.Owner == "existing_owner"
			select row.TargetId).ToArray();
		string[] second4 = MotionManifest.PreservedOwnerTargets.Where((string value) => value != "ucs2402:deploy").ToArray();
		if (!first.SequenceEqual<string>(second4, StringComparer.Ordinal))
		{
			throw new InvalidOperationException("The external-owner ledger changed.");
		}
		foreach (MotionContract contract in MotionManifest.All)
		{
			foreach (string item3 in new string[6]
			{
				contract.SourceBlueprintSha256,
				contract.SourceScriptSha256,
				contract.SourceModelSha256,
				contract.TargetModel.Sha256,
				contract.TargetSkeleton.Sha256,
				contract.TargetAnimation.Sha256
			}.Concat<string>(contract.Clips.Select((ClipPin clip) => clip.SourceSha256)).Concat((contract.StorageClip == null) ? Array.Empty<string>() : new string[1] { contract.StorageClip.StockAnimationSha256 }))
			{
				if (!IsSha256(item3))
				{
					throw new InvalidOperationException(contract.TargetId + " contains an invalid SHA-256 pin.");
				}
			}
			if (contract.TargetModel.Bytes <= 0 || contract.TargetSkeleton.Bytes <= 0 || contract.TargetAnimation.Bytes <= 0 || contract.TargetClipCount < 1 || contract.RequiredBones.Distinct<string>(StringComparer.Ordinal).Count() != contract.RequiredBones.Count || contract.RotatorBones.Distinct<string>(StringComparer.Ordinal).Count() != contract.RotatorBones.Count || contract.RotatorBones.Any((string bone) => !contract.RequiredBones.Contains<string>(bone, StringComparer.Ordinal)) || contract.RequiredBones.Any((string bone) => bone.IndexOf("Muzzle", StringComparison.OrdinalIgnoreCase) >= 0 || bone.IndexOf("Turret", StringComparison.OrdinalIgnoreCase) >= 0 || bone.IndexOf("Barrel", StringComparison.OrdinalIgnoreCase) >= 0))
			{
				throw new InvalidOperationException(contract.TargetId + " has an invalid asset/bone ownership contract.");
			}
			foreach (ClipPin clip in contract.Clips)
			{
				if (clip.SourceBytes <= 0 || clip.SourceFrames <= 0 || clip.SourceDurationSeconds <= 0.0 || clip.SourceRate <= 0.0 || !clip.SourcePath.StartsWith("units/" + contract.SourceId + "/", StringComparison.OrdinalIgnoreCase))
				{
					throw new InvalidOperationException(contract.TargetId + "/" + clip.ClipName + " has an invalid clip ABI.");
				}
			}
			if (contract.Status == MotionStatus.Ready && (!string.IsNullOrEmpty(contract.Blocker) || !string.IsNullOrEmpty(contract.FutureRequirement)))
			{
				throw new InvalidOperationException(contract.TargetId + " ready row is blocked.");
			}
			if (contract.Status != MotionStatus.Ready && (string.IsNullOrWhiteSpace(contract.Blocker) || string.IsNullOrWhiteSpace(contract.FutureRequirement)))
			{
				throw new InvalidOperationException(contract.TargetId + " excluded row lacks its fail-closed requirement.");
			}
			if ((contract.Kind == "shield_rotators_t2" || contract.Kind == "shield_rotators_t3") != !string.IsNullOrEmpty(contract.AuditedLimitation))
			{
				throw new InvalidOperationException(contract.TargetId + " audited-retail limitation ownership drifted.");
			}
			if (contract.Kind == "storage_level" != (contract.StorageClip != null))
			{
				throw new InvalidOperationException(contract.TargetId + " storage clip ownership drifted.");
			}
			if (contract.StorageClip != null)
			{
				StorageClipPin storageClip = contract.StorageClip;
				if (contract.ClassName != "AeonPortStorage" || contract.TargetClipCount != 2 || contract.Clips.Count != 0 || contract.RotatorBones.Count != 0 || storageClip.ClipName != "AnimStorageLevel" || storageClip.TemplateKey != "source_animstoragelevel" || (storageClip.ResourceName != "energy" && storageClip.ResourceName != "alloys") || storageClip.DurationSeconds != 1.0 || storageClip.LocalZDelta <= 0.0 || storageClip.StockAnimationBytes <= 0 || !IsSha256(storageClip.StockAnimationSha256))
				{
					throw new InvalidOperationException(contract.TargetId + " has an invalid storage animation contract.");
				}
			}
		}
		if (MotionManifest.ReadyContracts.Count((MotionContract motionContract5) => motionContract5.DeathClip != null) != 5 || MotionManifest.ReadyContracts.Count((MotionContract motionContract5) => motionContract5.HasUpgradeClip) != 6 || MotionManifest.ReadyContracts.Count((MotionContract motionContract5) => motionContract5.Kind == "permanent_open") != 5 || MotionManifest.ReadyContracts.Single((MotionContract motionContract5) => motionContract5.TargetId == "ucs2402").Clips.Single().Role != "preserved_deploy")
		{
			throw new InvalidOperationException("The reviewed death/upgrade/deploy ownership changed.");
		}
		MotionContract motionContract = MotionManifest.ReadyContracts.Single((MotionContract motionContract5) => motionContract5.Kind == "shield_rotators_t2");
		MotionContract motionContract2 = MotionManifest.ReadyContracts.Single((MotionContract motionContract5) => motionContract5.Kind == "shield_rotators_t3");
		if (motionContract.RequiredBones.SequenceEqual<string>(new string[2] { "Pod", "Orb" }, StringComparer.Ordinal) && motionContract2.RequiredBones.SequenceEqual<string>(new string[2] { "Pod", "Orb" }, StringComparer.Ordinal))
		{
			ClipPin deathClip = motionContract.DeathClip;
			if (deathClip != null && deathClip.SourceRate == 0.5)
			{
				ClipPin deathClip2 = motionContract2.DeathClip;
				if (deathClip2 != null && deathClip2.SourceRate == 0.5)
				{
					if (!(from motionContract5 in MotionManifest.ReadyContracts
						where motionContract5.Kind == "intel_rotor_upgrade" || motionContract5.Kind == "intel_rotor_triple" || motionContract5.Kind == "intel_rotor_pair_upgrade" || motionContract5.Kind == "jammer"
						select motionContract5.TargetId).ToArray().SequenceEqual<string>(new string[4] { "ucs1701", "ucs3701", "ucs2701", "ucs2711" }, StringComparer.Ordinal))
					{
						throw new InvalidOperationException("The effective-intel motion scope changed.");
					}
					var array = new[]
					{
						new
						{
							Id = "ucs3611",
							Required = new string[2] { "accelerates at 15", "independent of production Pause" }
						},
						new
						{
							Id = "ucs3603",
							Required = new string[3] { "accelerate at 15", "Production toggle-off", "Generic Pause does not own" }
						},
						new
						{
							Id = "ucs4102",
							Required = new string[2] { "accelerates at 15", "independent of production Pause" }
						},
						new
						{
							Id = "ucs1701",
							Required = new string[2] { "accelerates at 20", "spins down at 20" }
						},
						new
						{
							Id = "ucs3701",
							Required = new string[2] { "accelerate at 20", "spins all three down at 20" }
						},
						new
						{
							Id = "ucs2701",
							Required = new string[2] { "accelerate at 20", "spins both down at 60" }
						},
						new
						{
							Id = "ucs2711",
							Required = new string[3] { "concurrently accelerates at 50", "spin B02 down at 50", "RadarStealthFieldRadius remains provenance-only" }
						}
					};
					foreach (var item in array)
					{
						string state = MotionManifest.ReadyContracts.Single((MotionContract motionContract5) => motionContract5.TargetId == item.Id).StateContract;
						if (item.Required.Any((string token) => state.IndexOf(token, StringComparison.Ordinal) < 0))
						{
							throw new InvalidOperationException(item.Id + " source rotator-rate manifest drifted.");
						}
					}
					MotionContract motionContract3 = MotionManifest.ReadyContracts.Single((MotionContract motionContract5) => motionContract5.TargetId == "ucs1612");
					MotionContract motionContract4 = MotionManifest.ReadyContracts.Single((MotionContract motionContract5) => motionContract5.TargetId == "ucs1602");
					StorageClipPin storageClip2 = motionContract3.StorageClip;
					StorageClipPin storageClip3 = motionContract4.StorageClip;
					if (storageClip2 == null || storageClip2.ResourceName != "energy" || storageClip2.LocalZDelta != 0.045 || !motionContract3.RequiredBones.SequenceEqual<string>(new string[2] { "Side_Pods", "Center_Pod" }, StringComparer.Ordinal) || motionContract3.TargetAnimation.Bytes != 5052 || motionContract3.TargetAnimation.Sha256 != "53b939b0d3dd705549cdc2d6d8aae839c5eee0ea21c3fe92d9c222b68bcd5710" || storageClip2.StockAnimationBytes != 2522 || storageClip2.StockAnimationSha256 != "aacbe385d003d3ad746ffb1f00ad868fb9e48943de7e1345eb57e3df53d5fde5" || storageClip3 == null || storageClip3.ResourceName != "alloys" || storageClip3.LocalZDelta != 0.0615 || !motionContract4.RequiredBones.SequenceEqual<string>(new string[1] { "B01" }, StringComparer.Ordinal) || motionContract4.TargetAnimation.Bytes != 3784 || motionContract4.TargetAnimation.Sha256 != "df18bf803e7b60b51e24ad3cf560f357902213ee10413ab0ea78e28dcd4ca544" || storageClip3.StockAnimationBytes != 1888 || storageClip3.StockAnimationSha256 != "edf1e4492856403d1726ddf26f148aca4c27d464d97e512122705ee4cee7bddd")
					{
						throw new InvalidOperationException("The reviewed storage animation matrix changed.");
					}
					IReadOnlyList<AssetPin> extractorAnimationOverrides = MotionManifest.ExtractorAnimationOverrides;
					AssetPin[] array2 = new AssetPin[3]
					{
						new AssetPin("Units/ucs1601/LOD0/ucs1601.sananimation", 1063968L, "1e619db040eba68cc459a6bbd105fa5b5f94fae2d7c1fcb7291d2028bdcf4b45"),
						new AssetPin("Units/ucs2601/LOD0/ucs2601.sananimation", 1053188L, "fe9e317d557496766de314ec014aa6664e3ae5acc96ec5821dffc3f868f58f09"),
						new AssetPin("Units/ucs3601/LOD0/ucs3601.sananimation", 832202L, "1a4babd08cff018faa0ccb14eef46785b2f3340e34f1431270a444fd4c565deb")
					};
					if (extractorAnimationOverrides.Count != array2.Length || !extractorAnimationOverrides.Zip(array2, (AssetPin actual, AssetPin expected) => actual.Path == expected.Path && actual.Bytes == expected.Bytes && actual.Sha256 == expected.Sha256).All((bool matches) => matches))
					{
						throw new InvalidOperationException("The reviewed extractor animation override matrix changed.");
					}
					if (MotionManifest.PreservedOwnerTargets.Count != 9 || !IsSha256("c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26") || !IsSha256("3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb") || !IsSha256("8f53fb2b88bfacad95e07d6f8925cd2c7cb60f40be5d39e3b77b94a93ee8462b") || !IsSha256("1c343fb3c33848d3e16e546edbee827f66b4a8f25fe4324c302829eef979c297") || !IsSha256("8699116f6c8603842d8366b92f61a1ce1d2c4b44a769dd379f37eccf506e1b92") || !IsSha256("3eed7306200d5910786221547ff0fb959fa8cf92c85c99d62b98a12175c28b76") || !IsSha256("17da3a108f2610c0734f1bbdb164f1f04335835add2f6a9f70bb4b43d15703b0") || !IsSha256("ce6d3a51954ed37c1909f2314f3b006b52d5c2ab0413ffda365e330446c61981") || !IsSha256("8dcae5456e370f928db9a6d44f3448cbaa637dd2fc13efebd6af7b4ce18896a9") || !IsSha256("92872df06372d3d705388a038d09457a72dcb4c090b65dc3a2a7ce95ddba162f") || !Guid.TryParseExact("a902d100-d199-4124-96d1-48a92de713d5", "D", out var _))
					{
						throw new InvalidOperationException("The immutable upstream/owner pins changed.");
					}
					return;
				}
			}
		}
		throw new InvalidOperationException("The reviewed shield bone/death ownership changed.");
	}

	private static IReadOnlyList<EmbeddedAnimationAsset> ReadEmbeddedAnimationAssets()
	{
		EmbeddedAnimationAsset[] array = ReadEmbeddedStorageAssets().Concat<EmbeddedAnimationAsset>(ReadEmbeddedExtractorAssets()).ToArray();
		if (array.Length != 5 || array.Select((EmbeddedAnimationAsset asset) => asset.Desired.Path).Distinct<string>(StringComparer.Ordinal).Count() != array.Length)
		{
			throw new InvalidOperationException("Embedded Aeon animation ownership is not exactly five unique paths.");
		}
		return array;
	}

	private static IReadOnlyList<EmbeddedAnimationAsset> ReadEmbeddedStorageAssets()
	{
		byte[] array = LoadEmbeddedBytes("AeonStructureMotion.AeonStorageAnimationAssets.sanpack");
		if (array.LongLength != 9166 || !string.Equals(HashBytes(array), "1c343fb3c33848d3e16e546edbee827f66b4a8f25fe4324c302829eef979c297", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Embedded Aeon storage asset pack identity drifted.");
		}
		MotionContract[] array2 = MotionManifest.ReadyContracts.Where((MotionContract contract) => contract.StorageClip != null).ToArray();
		if (array2.Length != 2)
		{
			throw new InvalidOperationException("Embedded storage ownership is not exactly two contracts.");
		}
		using MemoryStream stream = new MemoryStream(array, writable: false);
		using ZipArchive zipArchive = new ZipArchive(stream, ZipArchiveMode.Read, leaveOpen: false);
		ZipArchiveEntry[] array3 = zipArchive.Entries.Where((ZipArchiveEntry entry) => !string.IsNullOrEmpty(entry.Name)).ToArray();
		if (array3.Length != array2.Length || array3.Select((ZipArchiveEntry entry) => entry.FullName).Distinct(StringComparer.Ordinal).Count() != array2.Length)
		{
			throw new InvalidOperationException("Embedded storage pack does not contain exactly two unique files.");
		}
		Dictionary<string, ZipArchiveEntry> dictionary = array3.ToDictionary((ZipArchiveEntry entry) => entry.FullName, StringComparer.Ordinal);
		List<EmbeddedAnimationAsset> list = new List<EmbeddedAnimationAsset>(array2.Length);
		MotionContract[] array4 = array2;
		foreach (MotionContract motionContract in array4)
		{
			if (!dictionary.TryGetValue(motionContract.TargetAnimation.Path, out var value))
			{
				throw new InvalidOperationException("Embedded storage pack lacks " + motionContract.TargetAnimation.Path);
			}
			byte[] bytes;
			using (Stream stream2 = value.Open())
			{
				using MemoryStream memoryStream = new MemoryStream();
				stream2.CopyTo(memoryStream);
				bytes = memoryStream.ToArray();
			}
			StorageClipPin storageClipPin = motionContract.StorageClip ?? throw new InvalidOperationException(motionContract.TargetId + " lost its storage asset contract.");
			AssetPin preimage = new AssetPin(motionContract.TargetAnimation.Path, storageClipPin.StockAnimationBytes, storageClipPin.StockAnimationSha256);
			EmbeddedAnimationAsset embeddedAnimationAsset = new EmbeddedAnimationAsset(motionContract, motionContract.TargetAnimation, preimage, bytes);
			ValidateDesiredEmbeddedAnimation(embeddedAnimationAsset, bytes);
			list.Add(embeddedAnimationAsset);
		}
		return list;
	}

	private static IReadOnlyList<EmbeddedAnimationAsset> ReadEmbeddedExtractorAssets()
	{
		byte[] array = LoadEmbeddedBytes("AeonStructureMotion.AeonExtractorAnimationAssets.sanpack");
		if (array.LongLength != 296150 || !string.Equals(HashBytes(array), "8699116f6c8603842d8366b92f61a1ce1d2c4b44a769dd379f37eccf506e1b92", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Embedded Aeon extractor asset pack identity drifted.");
		}
		Dictionary<string, AssetPin> desiredByPath = MotionManifest.ExtractorAnimationOverrides.ToDictionary<AssetPin, string>((AssetPin asset) => asset.Path, StringComparer.Ordinal);
		if (desiredByPath.Count != 3)
		{
			throw new InvalidOperationException("Embedded extractor ownership is not exactly three assets.");
		}
		using MemoryStream stream = new MemoryStream(array, writable: false);
		using ZipArchive zipArchive = new ZipArchive(stream, ZipArchiveMode.Read, leaveOpen: false);
		ZipArchiveEntry[] array2 = zipArchive.Entries.Where((ZipArchiveEntry entry) => !string.IsNullOrEmpty(entry.Name)).ToArray();
		if (array2.Length != desiredByPath.Count || array2.Select((ZipArchiveEntry entry) => entry.FullName).Distinct(StringComparer.Ordinal).Count() != desiredByPath.Count)
		{
			throw new InvalidOperationException("Embedded extractor pack does not contain exactly three unique files.");
		}
		Dictionary<string, MotionContract> dictionary = MotionManifest.ReadyContracts.Where((MotionContract contract) => desiredByPath.ContainsKey(contract.TargetAnimation.Path)).ToDictionary<MotionContract, string>((MotionContract contract) => contract.TargetAnimation.Path, StringComparer.Ordinal);
		if (dictionary.Count != desiredByPath.Count)
		{
			throw new InvalidOperationException("Embedded extractor paths do not resolve to three ready contracts.");
		}
		List<EmbeddedAnimationAsset> list = new List<EmbeddedAnimationAsset>(array2.Length);
		foreach (ZipArchiveEntry item in array2.OrderBy((ZipArchiveEntry item) => item.FullName, StringComparer.Ordinal))
		{
			if (!desiredByPath.TryGetValue(item.FullName, out AssetPin value) || !dictionary.TryGetValue(item.FullName, out var value2) || (value2.Kind != "pump_loop_upgrade" && value2.Kind != "pump_state_machine"))
			{
				throw new InvalidOperationException("Unexpected embedded extractor animation: " + item.FullName);
			}
			byte[] bytes;
			using (Stream stream2 = item.Open())
			{
				using MemoryStream memoryStream = new MemoryStream();
				stream2.CopyTo(memoryStream);
				bytes = memoryStream.ToArray();
			}
			EmbeddedAnimationAsset embeddedAnimationAsset = new EmbeddedAnimationAsset(value2, value, value2.TargetAnimation, bytes);
			ValidateDesiredEmbeddedAnimation(embeddedAnimationAsset, bytes);
			list.Add(embeddedAnimationAsset);
		}
		return list;
	}

	private static void ValidateEmbeddedAnimationPreimage(EmbeddedAnimationAsset asset, byte[] bytes)
	{
		string a = HashBytes(bytes);
		bool num = bytes.LongLength == asset.Preimage.Bytes && string.Equals(a, asset.Preimage.Sha256, StringComparison.OrdinalIgnoreCase);
		bool flag = bytes.LongLength == asset.Desired.Bytes && string.Equals(a, asset.Desired.Sha256, StringComparison.OrdinalIgnoreCase);
		if (!num && !flag)
		{
			throw new InvalidOperationException(asset.Desired.Path + " is neither the pinned preimage nor embedded animation.");
		}
	}

	private static void ValidateDesiredEmbeddedAnimation(EmbeddedAnimationAsset asset, byte[] bytes)
	{
		if (bytes.LongLength != asset.Desired.Bytes || !string.Equals(HashBytes(bytes), asset.Desired.Sha256, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Embedded animation identity drifted: " + asset.Desired.Path);
		}
	}

	private static string HashBytes(byte[] bytes)
	{
		using SHA256 sHA = SHA256.Create();
		return BitConverter.ToString(sHA.ComputeHash(bytes)).Replace("-", "");
	}

	private static string NormalizeResourcePath(string path)
	{
		return path.Replace('\\', '/').TrimStart(new char[1] { '/' });
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

	private static bool IsSha256(string value)
	{
		if (value.Length == 64)
		{
			return value.All(Uri.IsHexDigit);
		}
		return false;
	}

	private static byte[] LoadEmbeddedBytes(string resourceName)
	{
		using Stream stream = typeof(CachePatcherRuntime).Assembly.GetManifestResourceStream(resourceName) ?? throw new MissingManifestResourceException("Missing embedded resource " + resourceName);
		using MemoryStream memoryStream = new MemoryStream();
		stream.CopyTo(memoryStream);
		return memoryStream.ToArray();
	}

	private static string LoadEmbeddedText(string resourceName)
	{
		using Stream stream = typeof(CachePatcherRuntime).Assembly.GetManifestResourceStream(resourceName) ?? throw new MissingManifestResourceException("Missing embedded Lua appendix " + resourceName);
		using StreamReader streamReader = new StreamReader(stream, new UTF8Encoding(encoderShouldEmitUTF8Identifier: false), detectEncodingFromByteOrderMarks: true);
		return NormalizeNewlines(streamReader.ReadToEnd());
	}

	private static void QueueAppend(ICollection<CacheMutation> mutations, CachedResource resource, string appendix, Action<string> validate)
	{
		object obj = CreateNativeArray(resource.Stock.GetType(), Append(GetText(resource.Stock), appendix));
		try
		{
			validate(GetText(obj));
			mutations.Add(new CacheMutation(resource.Path, resource.Stock, obj, resource.Description));
		}
		catch
		{
			TryDispose(obj, "uncommitted " + resource.Description);
			throw;
		}
	}

	private static void Commit(object cache, IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			mutation.Assigned = true;
			SetCachedResource(cache, mutation.Path, mutation.Replacement);
		}
		foreach (CacheMutation mutation2 in mutations)
		{
			TryDispose(mutation2.Stock, "stock " + mutation2.Description);
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
				catch (Exception ex)
				{
					Log("Rollback failed for " + item.Description + ": " + ex);
				}
			}
			if (!item.Assigned)
			{
				TryDispose(item.Replacement, "replacement " + item.Description);
			}
		}
	}

	private static void DisposeUncommitted(IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			TryDispose(mutation.Replacement, "uncommitted " + mutation.Description);
		}
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CachedResource GetCachedResource(object cache, string relativePath, string description)
	{
		Type type = cache.GetType();
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		string text = ResolvePath(relativePath);
		if ((bool)(obj.Invoke(cache, new object[1] { text }) ?? ((object)false)))
		{
			object obj2 = propertyInfo.GetValue(cache, new object[1] { text }) ?? throw new InvalidOperationException("Cached " + description + " has no value.");
			EnsureCreated(obj2, description);
			return new CachedResource(text, obj2, description);
		}
		string value = "/" + relativePath.Replace('\\', '/');
		CachedResource cachedResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text2 && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cachedResource != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + relativePath + ".");
				}
				object obj3 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("Cached " + description + " has no value.");
				EnsureCreated(obj3, description);
				cachedResource = new CachedResource(text2, obj3, description);
			}
		}
		return cachedResource ?? throw new FileNotFoundException("Required " + description + " was not present in Sanctuary's Lua cache.", relativePath);
	}

	private static string ResolvePath(string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static object CreateNativeArray(Type type, string source)
	{
		return NativeArrayByteFactory.CreatePersistent(type, Encoding.UTF8.GetBytes(source));
	}

	private static string GetText(object resource)
	{
		EnsureCreated(resource, "Lua cache resource");
		MethodInfo methodInfo = resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray");
		return Encoding.UTF8.GetString((byte[])(methodInfo.Invoke(resource, null) ?? throw new InvalidOperationException("NativeArray.ToArray returned null.")));
	}

	private static void EnsureCreated(object resource, string description)
	{
		object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource);
		if (!(value is bool) || !(bool)value)
		{
			throw new InvalidOperationException("Cached " + description + " is not initialized.");
		}
	}

	private static void SetCachedResource(object cache, string path, object resource)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, resource, new object[1] { path });
	}

	private static void TryDispose(object resource, string description)
	{
		try
		{
			object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource);
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
			if (((uint)num & (flag ? 1u : 0u)) != 0)
			{
				(resource.GetType().GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "Dispose")).Invoke(resource, null);
			}
		}
		catch (Exception ex)
		{
			Log("Could not dispose " + description + ": " + ex);
		}
	}

	private static bool ContainsMarker(string source)
	{
		return source.IndexOf("-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0", StringComparison.Ordinal) >= 0;
	}

	private static string Append(string source, string appendix)
	{
		source = NormalizeNewlines(source);
		appendix = NormalizeNewlines(appendix);
		if (!source.EndsWith("\n", StringComparison.Ordinal))
		{
			return source + "\n" + appendix.TrimStart(new char[1] { '\n' });
		}
		return source + appendix.TrimStart(new char[1] { '\n' });
	}

	private static string NormalizeNewlines(string value)
	{
		return value.Replace("\r\n", "\n").Replace('\r', '\n');
	}

	private static string OwnedAppendix(string source)
	{
		int num = source.IndexOf("-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Aeon structure-motion marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0".Length, StringComparison.Ordinal);
		if (num2 < 0)
		{
			return source.Substring(num);
		}
		return source.Substring(num, num2 - num);
	}

	private static void RequireTokens(string source, params string[] tokens)
	{
		foreach (string text in tokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Expected cached Lua source to contain '" + text + "'.");
			}
		}
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(token, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += token.Length;
		}
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {description}, found {num}.");
		}
	}

	private static string Lua(double value)
	{
		return StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture);
	}

	private static string EscapeLua(string value)
	{
		return value.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "\\r")
			.Replace("\n", "\\n");
	}

	private static void Log(string message)
	{
		string text = "[SCOM Aeon Structure Motion] " + message;
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
