using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;
using SupremeCommanderOverhaulAudioCompat;

namespace StructurePersistentAudioCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class AudioTarget
	{
		public string Id { get; }

		public IReadOnlyList<string> OwningMarkers { get; }

		public string TemplateRelativePath => "LJ/lua/common/units/unitsTemplates/" + Id + "/" + Id + ".santp";

		public AudioTarget(string id, params string[] owningMarkers)
		{
			Id = id;
			OwningMarkers = owningMarkers;
		}
	}

	private const string TargetRelativePath = "LJ/lua/client/units/unitsClasses/unitsBaseClass.lua";

	private const string TargetPathSuffix = "/LJ/lua/client/units/unitsClasses/unitsBaseClass.lua";

	internal const string OverrideMarker = "-- Supreme Commander Overhaul Structure Persistent Audio 1.0.0";

	private const string StructuresMarker = "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1";

	private const string EdaLandPowerMarker = "-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0";

	private const string SupportStructuresMarker = "-- FA Support Structures Cache Patcher 1.1.2";

	private const string CombatStructuresMarker = "-- FA Combat Structures Cache Patcher 1.1.0";

	private const string FourthFactionMarker = "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0";

	private static readonly AudioTarget[] AudioTargets = new AudioTarget[34]
	{
		new AudioTarget("ugs1611", "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1"),
		new AudioTarget("ugs2611", "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1"),
		new AudioTarget("ugs3611", "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1"),
		new AudioTarget("ugs2511", "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1"),
		new AudioTarget("ugs3511", "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1"),
		new AudioTarget("ugs2401", "-- FA Support Structures Cache Patcher 1.1.2"),
		new AudioTarget("ugs1701", "-- FA Combat Structures Cache Patcher 1.1.0"),
		new AudioTarget("ugs2701", "-- FA Combat Structures Cache Patcher 1.1.0"),
		new AudioTarget("ugs3701", "-- FA Combat Structures Cache Patcher 1.1.0"),
		new AudioTarget("ues1511", "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1"),
		new AudioTarget("ues2511", "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1"),
		new AudioTarget("ues1611", "-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0"),
		new AudioTarget("ues2611", "-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0"),
		new AudioTarget("ues3611", "-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0"),
		new AudioTarget("ues2401", "-- FA Support Structures Cache Patcher 1.1.2"),
		new AudioTarget("ues3401", "-- FA Support Structures Cache Patcher 1.1.2"),
		new AudioTarget("ues1701", "-- FA Combat Structures Cache Patcher 1.1.0"),
		new AudioTarget("ues2701", "-- FA Combat Structures Cache Patcher 1.1.0"),
		new AudioTarget("ues3701", "-- FA Combat Structures Cache Patcher 1.1.0"),
		new AudioTarget("uss1511", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss1512", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss1611", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss1701", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss2401", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss2511", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss2512", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss2611", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss2701", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss2711", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss3401", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss3511", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss3512", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss3611", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0"),
		new AudioTarget("uss3701", "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0")
	};

	private static string BuildOverrideAppendix(IReadOnlyList<string> eligibleTargetIds)
	{
		string text = string.Join(", ", eligibleTargetIds.Select((string id) => id + " = true"));
		return "\n-- Supreme Commander Overhaul Structure Persistent Audio 1.0.0\n-- Imported static structures retain stock audio metadata even when their\n-- original animated/VFX rig is removed. Suppress only their inherited looping\n-- sources after stock setup; do not mute one-shots or unrelated factions.\nlocal SCO_StructurePersistentAudioIds = {\n    " + text + ",\n}\n\nlocal SCO_StructurePersistentAudioStockSetUpEngineAudio = ClientUnit.SetUpEngineAudio\n\nlocal function SCO_DisablePersistentStructureAudio(localId)\n    if localId then\n        Engine.SetAudioSourceCanEmitPersistentSound(localId, false)\n    end\nend\n\nfunction ClientUnit:SetUpEngineAudio()\n    SCO_StructurePersistentAudioStockSetUpEngineAudio(self)\n\n    if not SCO_StructurePersistentAudioIds[self.tpId]\n        or not self:HasTags(Tags.STRUCTURE) then\n        return\n    end\n\n    local audio = self.tp and self.tp.audio\n    if audio and audio.active and audio.active.looping then\n        SCO_DisablePersistentStructureAudio(self.localId)\n    end\n    if self.engineAudioLocalId\n        and audio\n        and audio.engine\n        and audio.engine.looping then\n        SCO_DisablePersistentStructureAudio(self.engineAudioLocalId)\n    end\n\n    -- ClientShield:Enable re-enables a configured source. Clearing only the\n    -- copied local metadata after disabling its loop keeps it silent on later\n    -- shield enable/disable transitions while leaving shield visuals intact.\n    for _, shield in ipairs(self.shields or {}) do\n        if shield.audio and shield.audio.looping then\n            SCO_DisablePersistentStructureAudio(shield.localId)\n            shield.audio = nil\n        end\n    end\nend";
	}

	public static void Apply()
	{
		object obj = null;
		object obj2 = null;
		object obj3 = null;
		PropertyInfo propertyInfo = null;
		string text = null;
		bool flag = false;
		bool flag2 = false;
		try
		{
			obj = GetLuaFileCache();
			if (!TryGetResource(obj, out string path, out object resource))
			{
				throw new FileNotFoundException("The client unit-base Lua source was not present in Sanctuary's Lua file cache.", "LJ/lua/client/units/unitsClasses/unitsBaseClass.lua");
			}
			text = path;
			obj2 = resource;
			string nativeArrayText = GetNativeArrayText(obj2);
			if (nativeArrayText.IndexOf("function ClientUnit:SetUpAudioSources()", StringComparison.Ordinal) >= 0)
			{
				SupremeCommanderOverhaulAudioCompat.CachePatcherRuntime.PatchSource(nativeArrayText);
				Log("Validated current audio source API; the canonical audio compatibility stage owns this gate.");
				return;
			}
			if (ContainsOverride(nativeArrayText))
			{
				ValidatePatchedSource(nativeArrayText);
				Log("The cached client unit base already contains the structure persistent-audio gate.");
				return;
			}
			ValidateStockSource(nativeArrayText);
			IReadOnlyList<string> eligibleTargetIds = GetEligibleTargetIds(obj);
			if (eligibleTargetIds.Count == 0)
			{
				Log("No SCOM-owned static-structure templates were committed; left stock persistent audio unchanged.");
				return;
			}
			string text2 = EnsureTrailingNewline(nativeArrayText) + BuildOverrideAppendix(eligibleTargetIds);
			ValidatePatchedSource(text2);
			obj3 = NativeArrayByteFactory.CreatePersistent(obj2.GetType(), Encoding.UTF8.GetBytes(text2));
			ValidatePatchedSource(GetNativeArrayText(obj3));
			propertyInfo = obj.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(obj.GetType().FullName, "Item");
			flag = true;
			propertyInfo.SetValue(obj, obj3, new object[1] { text });
			DisposeNativeArray(obj2.GetType(), obj2);
			flag2 = true;
			Log($"Installed the persistent-audio gate for {eligibleTargetIds.Count} committed imported static structures.");
		}
		catch (Exception arg)
		{
			if (flag && !flag2 && obj != null && obj2 != null && (object)propertyInfo != null && text != null)
			{
				try
				{
					propertyInfo.SetValue(obj, obj2, new object[1] { text });
					flag = false;
				}
				catch (Exception arg2)
				{
					Log($"Failed to roll back the structure persistent-audio gate: {arg2}");
				}
			}
			if (obj3 != null && IsNativeArrayCreated(obj3) && !flag2)
			{
				DisposeNativeArray(obj3.GetType(), obj3);
			}
			Log($"Failed to install the structure persistent-audio gate: {arg}");
			throw;
		}
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static bool TryGetResource(object cache, out string path, out object resource)
	{
		path = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), "LJ/lua/client/units/unitsClasses/unitsBaseClass.lua"));
		resource = null;
		Type type = cache.GetType();
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		if ((bool)obj.Invoke(cache, new object[1] { path }))
		{
			resource = propertyInfo.GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("The cached client unit-base Lua source has no value.");
			return IsNativeArrayCreated(resource);
		}
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text && text.Replace('\\', '/').EndsWith("/LJ/lua/client/units/unitsClasses/unitsBaseClass.lua", StringComparison.OrdinalIgnoreCase))
			{
				object obj2 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("The cached client unit-base Lua source has no value.");
				if (IsNativeArrayCreated(obj2))
				{
					path = text;
					resource = obj2;
					return true;
				}
			}
		}
		return false;
	}

	private static IReadOnlyList<string> GetEligibleTargetIds(object cache)
	{
		List<string> list = new List<string>();
		AudioTarget[] audioTargets = AudioTargets;
		foreach (AudioTarget audioTarget in audioTargets)
		{
			if (TryGetCachedText(cache, audioTarget.TemplateRelativePath, out string source) && audioTarget.OwningMarkers.Any((string marker) => source.IndexOf(marker, StringComparison.Ordinal) >= 0))
			{
				list.Add(audioTarget.Id);
			}
		}
		return list;
	}

	private static bool TryGetCachedText(object cache, string relativePath, out string source)
	{
		source = string.Empty;
		string text = relativePath.Replace('\\', '/');
		string fullPath = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
		Type type = cache.GetType();
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		if ((bool)obj.Invoke(cache, new object[1] { fullPath }))
		{
			object value = propertyInfo.GetValue(cache, new object[1] { fullPath });
			if (value != null && IsNativeArrayCreated(value))
			{
				source = GetNativeArrayText(value);
				return true;
			}
			return false;
		}
		string value2 = "/" + text;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text2 && text2.Replace('\\', '/').EndsWith(value2, StringComparison.OrdinalIgnoreCase))
			{
				object obj2 = type2.GetProperty("Value")?.GetValue(item);
				if (obj2 == null || !IsNativeArrayCreated(obj2))
				{
					return false;
				}
				source = GetNativeArrayText(obj2);
				return true;
			}
		}
		return false;
	}

	private static string GetNativeArrayText(object resource)
	{
		byte[] nativeArrayBytes = GetNativeArrayBytes(resource.GetType(), resource);
		return Encoding.UTF8.GetString(nativeArrayBytes);
	}

	private static byte[] GetNativeArrayBytes(Type nativeArrayType, object nativeArray)
	{
		return (byte[])(nativeArrayType.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "ToArray")).Invoke(nativeArray, null);
	}

	private static bool IsNativeArrayCreated(object nativeArray)
	{
		return (bool)(nativeArray.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(nativeArray.GetType().FullName, "IsCreated")).GetValue(nativeArray);
	}

	private static void DisposeNativeArray(Type nativeArrayType, object nativeArray)
	{
		(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
	}

	private static bool ContainsOverride(string source)
	{
		return source.IndexOf("-- Supreme Commander Overhaul Structure Persistent Audio 1.0.0", StringComparison.Ordinal) >= 0;
	}

	private static string EnsureTrailingNewline(string source)
	{
		if (!source.EndsWith("\n", StringComparison.Ordinal))
		{
			return source + "\n";
		}
		return source;
	}

	private static void ValidateStockSource(string source)
	{
		RequireContains(source, "ClientUnit = Class(\"UnitBase\", ClientEntity", "function ClientUnit:SetUpEngineAudio()", "self.engineAudioLocalId = self:GetBoneId(\"EngineAudioEntity\")", "Engine.SetAudioSourceRTPC(self.engineAudioLocalId");
	}

	private static void ValidatePatchedSource(string source)
	{
		ValidateStockSource(source);
		RequireExactly(source, "-- Supreme Commander Overhaul Structure Persistent Audio 1.0.0", 1, "structure persistent-audio marker");
		RequireExactly(source, "local SCO_StructurePersistentAudioStockSetUpEngineAudio = ClientUnit.SetUpEngineAudio", 1, "structure persistent-audio wrapper");
		RequireExactly(source, "SCO_StructurePersistentAudioStockSetUpEngineAudio(self)", 1, "structure base engine-audio setup call");
		RequireContains(source, "local SCO_StructurePersistentAudioIds = {", "not self:HasTags(Tags.STRUCTURE)", "SCO_DisablePersistentStructureAudio(self.localId)", "SCO_DisablePersistentStructureAudio(self.engineAudioLocalId)", "shield.audio = nil");
		string text = source.Substring(source.IndexOf("-- Supreme Commander Overhaul Structure Persistent Audio 1.0.0", StringComparison.Ordinal));
		Require(Count(text, " = true") >= 1 && Count(text, " = true") <= AudioTargets.Length, "The structure persistent-audio gate has an invalid audited target set.");
		Require(text.IndexOf("upl", StringComparison.Ordinal) < 0, "The structure persistent-audio gate must not target Prometheans units.");
	}

	private static void RequireContains(string source, params string[] tokens)
	{
		foreach (string text in tokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Client unit-base Lua source is missing required token: " + text);
			}
		}
	}

	private static void RequireExactly(string source, string token, int expectedCount, string description)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(token, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += token.Length;
		}
		if (num != expectedCount)
		{
			throw new InvalidOperationException($"Expected {expectedCount} {description} occurrence(s), found {num}.");
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

	private static void Require(bool condition, string message)
	{
		if (!condition)
		{
			throw new InvalidOperationException(message);
		}
	}

	private static void Log(string message)
	{
		string text = "[Structure Persistent Audio Cache Patcher] " + message;
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
