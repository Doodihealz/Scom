using System;
using System.Collections;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;
using SupremeCommanderOverhaulAudioCompat;

namespace UefAcuAudioCachePatcher;

public static class CachePatcherRuntime
{
	private const string TargetRelativePath = "LJ/lua/client/units/unitsClasses/unitsBaseClass.lua";

	private const string TargetPathSuffix = "/LJ/lua/client/units/unitsClasses/unitsBaseClass.lua";

	internal const string OverrideMarker = "-- Supreme Commander Overhaul UEF ACU Engine Audio 1.0.0";

	private const string OverrideAppendix = "\n-- Supreme Commander Overhaul UEF ACU Engine Audio 1.0.0\n-- UEL0001's aclu1305 walking event is represented by a persistent source.\n-- Start it disabled and enable it only while this one commander's actual\n-- movement speed is positive. The stock update still supplies UnitSpeed RTPC.\nlocal SCO_UefAcuAudioStockSetUpEngineAudio = ClientUnit.SetUpEngineAudio\n\nfunction ClientUnit:SetUpEngineAudio()\n    SCO_UefAcuAudioStockSetUpEngineAudio(self)\n    if self.tpId == \"uel0000\" and self.engineAudioLocalId then\n        self.scoUefAcuEngineAudioMoving = false\n        Engine.SetAudioSourceCanEmitPersistentSound(self.engineAudioLocalId, false)\n    end\nend\n\nlocal SCO_UefAcuAudioStockRenderUpdateEngineAudio = ClientUnit.RenderUpdateEngineAudio\n\nfunction ClientUnit:RenderUpdateEngineAudio()\n    SCO_UefAcuAudioStockRenderUpdateEngineAudio(self)\n    if self.tpId ~= \"uel0000\" or not self.engineAudioLocalId then\n        return\n    end\n\n    local _, currentSpeed = Engine.GetMovementCurrentSpeed(self.id)\n    local isMoving = currentSpeed > 0\n    if self.scoUefAcuEngineAudioMoving ~= isMoving then\n        self.scoUefAcuEngineAudioMoving = isMoving\n        Engine.SetAudioSourceCanEmitPersistentSound(\n            self.engineAudioLocalId,\n            isMoving)\n    end\nend";

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
				Log("The cached client unit base already contains the UEF ACU engine-audio gate.");
				return;
			}
			ValidateStockSource(nativeArrayText);
			string text2 = EnsureTrailingNewline(nativeArrayText) + "\n-- Supreme Commander Overhaul UEF ACU Engine Audio 1.0.0\n-- UEL0001's aclu1305 walking event is represented by a persistent source.\n-- Start it disabled and enable it only while this one commander's actual\n-- movement speed is positive. The stock update still supplies UnitSpeed RTPC.\nlocal SCO_UefAcuAudioStockSetUpEngineAudio = ClientUnit.SetUpEngineAudio\n\nfunction ClientUnit:SetUpEngineAudio()\n    SCO_UefAcuAudioStockSetUpEngineAudio(self)\n    if self.tpId == \"uel0000\" and self.engineAudioLocalId then\n        self.scoUefAcuEngineAudioMoving = false\n        Engine.SetAudioSourceCanEmitPersistentSound(self.engineAudioLocalId, false)\n    end\nend\n\nlocal SCO_UefAcuAudioStockRenderUpdateEngineAudio = ClientUnit.RenderUpdateEngineAudio\n\nfunction ClientUnit:RenderUpdateEngineAudio()\n    SCO_UefAcuAudioStockRenderUpdateEngineAudio(self)\n    if self.tpId ~= \"uel0000\" or not self.engineAudioLocalId then\n        return\n    end\n\n    local _, currentSpeed = Engine.GetMovementCurrentSpeed(self.id)\n    local isMoving = currentSpeed > 0\n    if self.scoUefAcuEngineAudioMoving ~= isMoving then\n        self.scoUefAcuEngineAudioMoving = isMoving\n        Engine.SetAudioSourceCanEmitPersistentSound(\n            self.engineAudioLocalId,\n            isMoving)\n    end\nend";
			ValidatePatchedSource(text2);
			obj3 = NativeArrayByteFactory.CreatePersistent(obj2.GetType(), Encoding.UTF8.GetBytes(text2));
			ValidatePatchedSource(GetNativeArrayText(obj3));
			propertyInfo = obj.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(obj.GetType().FullName, "Item");
			flag = true;
			propertyInfo.SetValue(obj, obj3, new object[1] { text });
			DisposeNativeArray(obj2.GetType(), obj2);
			flag2 = true;
			Log("Installed the UEL0000 movement-gated persistent engine-audio source.");
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
					Log($"Failed to roll back the UEF ACU engine-audio gate: {arg2}");
				}
			}
			if (obj3 != null && IsNativeArrayCreated(obj3) && !flag2)
			{
				DisposeNativeArray(obj3.GetType(), obj3);
			}
			Log($"Failed to install the UEF ACU engine-audio gate: {arg}");
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
		return source.IndexOf("-- Supreme Commander Overhaul UEF ACU Engine Audio 1.0.0", StringComparison.Ordinal) >= 0;
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
		RequireContains(source, "ClientUnit = Class(\"UnitBase\", ClientEntity", "function ClientUnit:SetUpEngineAudio()", "self.engineAudioLocalId = self:GetBoneId(\"EngineAudioEntity\")", "function ClientUnit:RenderUpdateEngineAudio()", "local _, currentSpeed = Engine.GetMovementCurrentSpeed(self.id)", "Engine.SetAudioSourceRTPC(self.engineAudioLocalId");
	}

	private static void ValidatePatchedSource(string source)
	{
		ValidateStockSource(source);
		RequireExactly(source, "-- Supreme Commander Overhaul UEF ACU Engine Audio 1.0.0", 1, "UEF ACU engine-audio marker");
		RequireExactly(source, "local SCO_UefAcuAudioStockSetUpEngineAudio = ClientUnit.SetUpEngineAudio", 1, "UEF ACU setup wrapper");
		RequireExactly(source, "SCO_UefAcuAudioStockSetUpEngineAudio(self)", 1, "UEF ACU base setup call");
		RequireExactly(source, "local SCO_UefAcuAudioStockRenderUpdateEngineAudio = ClientUnit.RenderUpdateEngineAudio", 1, "UEF ACU render wrapper");
		RequireExactly(source, "SCO_UefAcuAudioStockRenderUpdateEngineAudio(self)", 1, "UEF ACU base render call");
		RequireExactly(source, "if self.tpId == \"uel0000\" and self.engineAudioLocalId then", 1, "UEL0000 setup predicate");
		RequireExactly(source, "self.scoUefAcuEngineAudioMoving = false", 1, "UEL0000 initial idle-audio state");
		RequireExactly(source, "if self.tpId ~= \"uel0000\" or not self.engineAudioLocalId then", 1, "UEL0000 render predicate");
		RequireExactly(source, "local _, currentSpeed = Engine.GetMovementCurrentSpeed(self.id)", 2, "stock plus UEL0000 current-speed reads");
		Require(source.IndexOf("if self.tpId == \"uel0000\" and self.engineAudioLocalId then\n        self.scoUefAcuEngineAudioMoving = false\n        Engine.SetAudioSourceCanEmitPersistentSound(self.engineAudioLocalId, false)", StringComparison.Ordinal) >= 0, "The UEL0000 setup wrapper does not suppress its persistent source while idle.");
		RequireExactly(source, "local isMoving = currentSpeed > 0", 1, "UEL0000 actual movement predicate");
		RequireExactly(source, "if self.scoUefAcuEngineAudioMoving ~= isMoving then", 1, "UEL0000 movement-audio transition gate");
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

	private static void Require(bool condition, string message)
	{
		if (!condition)
		{
			throw new InvalidOperationException(message);
		}
	}

	private static void Log(string message)
	{
		string text = "[UEF ACU Engine Audio Cache Patcher] " + message;
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
