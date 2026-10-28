using System;
using System.Collections;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace GuardCybranT3ArtilleryCachePatcher;

public static class CachePatcherRuntime
{
	private const string TargetTemplateRelativePath = "LJ/lua/common/units/unitsTemplates/ugs3101/ugs3101.santp";

	private const string TargetTemplatePathSuffix = "/LJ/lua/common/units/unitsTemplates/ugs3101/ugs3101.santp";

	private const string OverrideMarker = "-- Guard Cybran T3 Artillery Cache Patcher 1.2.0";

	private const string TemplateOverride = "\n-- Guard Cybran T3 Artillery Cache Patcher 1.2.0\n-- The local personal pack supplies URB2302 Disruptor's native seven-bone\n-- rig with one baked root/model-space yaw so the complete structure rests\n-- facing Sanctuary south. Its turret remains runtime-driven:\n-- yaw=Turret, pitch=Turret_Barrel, muzzle=Turret_Muzzle, rack=Barrel_B01.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.rotators = nil\n-- A 360-degree turret needs a circular horizontal envelope, not the old\n-- tiny collider or the ten-cell square left by the replaced Guard asset.\nUnitTemplate.additions.tarmacSize = {\n    x = 5.4,\n    y = 6.5,\n}\nUnitTemplate.additions.selectionHit = {\n    size = {\n        x = 6.5,\n        y = 6.5,\n    },\n    offset = {\n        x = 0,\n        y = 1.78,\n        z = 0,\n    },\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = {\n        x = 0,\n        y = 1.78,\n        z = 0,\n    },\n    collisionSize = {\n        x = 6.4,\n        y = 3.8,\n        z = 6.4,\n    },\n}\nUnitTemplate.visuals.selection = {\n    offset = {\n        x = 0,\n        y = 1.78,\n        z = 0,\n    },\n    size = {\n        x = 6.5,\n        y = 6.5,\n    },\n}\nUnitTemplate.footprint = {\n    x = 6.5,\n    y = 6.5,\n}\nUnitTemplate.skirtSize = {\n    x = 8,\n    y = 8,\n}\n-- The recessed Guard structure needs a terrain cutout; the Disruptor does not.\nUnitTemplate.visuals.holes = nil\n\nUnitTemplate.weapons[1].aimControllers = {\n    {\n        aimBone = \"Turret_Muzzle\",\n        aimTolerance = 2,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = \"Turret_Barrel\",\n        pitchMax = 80,\n        pitchMin = -25,\n        pitchSpeed = 5,\n        poseResetTime = -1,\n        projectileSpeed = 30,\n        reduceMuzzleVelocityToTarget = true,\n        solverType = \"HighArc\",\n        yawBone = \"Turret\",\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 5,\n    },\n}\nUnitTemplate.weapons[1].muzzleGroups = {\n    { muzzles = { \"Turret_Muzzle\" } },\n}";

	public static void Apply()
	{
		object obj = null;
		bool flag = false;
		try
		{
			Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
			object obj2 = (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
			if (!TryGetTemplate(obj2, out string templatePath, out object stockTemplate))
			{
				throw new FileNotFoundException("The Guard T3 artillery template was not present in Sanctuary's Lua file cache.", "LJ/lua/common/units/unitsTemplates/ugs3101/ugs3101.santp");
			}
			if (ContainsOverride(stockTemplate))
			{
				Log("The cached Guard T3 artillery template already contains the Disruptor override.");
				return;
			}
			Type type2 = stockTemplate.GetType();
			byte[] nativeArrayBytes = GetNativeArrayBytes(type2, stockTemplate);
			byte[] bytes = Encoding.UTF8.GetBytes("\n-- Guard Cybran T3 Artillery Cache Patcher 1.2.0\n-- The local personal pack supplies URB2302 Disruptor's native seven-bone\n-- rig with one baked root/model-space yaw so the complete structure rests\n-- facing Sanctuary south. Its turret remains runtime-driven:\n-- yaw=Turret, pitch=Turret_Barrel, muzzle=Turret_Muzzle, rack=Barrel_B01.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.rotators = nil\n-- A 360-degree turret needs a circular horizontal envelope, not the old\n-- tiny collider or the ten-cell square left by the replaced Guard asset.\nUnitTemplate.additions.tarmacSize = {\n    x = 5.4,\n    y = 6.5,\n}\nUnitTemplate.additions.selectionHit = {\n    size = {\n        x = 6.5,\n        y = 6.5,\n    },\n    offset = {\n        x = 0,\n        y = 1.78,\n        z = 0,\n    },\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = {\n        x = 0,\n        y = 1.78,\n        z = 0,\n    },\n    collisionSize = {\n        x = 6.4,\n        y = 3.8,\n        z = 6.4,\n    },\n}\nUnitTemplate.visuals.selection = {\n    offset = {\n        x = 0,\n        y = 1.78,\n        z = 0,\n    },\n    size = {\n        x = 6.5,\n        y = 6.5,\n    },\n}\nUnitTemplate.footprint = {\n    x = 6.5,\n    y = 6.5,\n}\nUnitTemplate.skirtSize = {\n    x = 8,\n    y = 8,\n}\n-- The recessed Guard structure needs a terrain cutout; the Disruptor does not.\nUnitTemplate.visuals.holes = nil\n\nUnitTemplate.weapons[1].aimControllers = {\n    {\n        aimBone = \"Turret_Muzzle\",\n        aimTolerance = 2,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = \"Turret_Barrel\",\n        pitchMax = 80,\n        pitchMin = -25,\n        pitchSpeed = 5,\n        poseResetTime = -1,\n        projectileSpeed = 30,\n        reduceMuzzleVelocityToTarget = true,\n        solverType = \"HighArc\",\n        yawBone = \"Turret\",\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 5,\n    },\n}\nUnitTemplate.weapons[1].muzzleGroups = {\n    { muzzles = { \"Turret_Muzzle\" } },\n}");
			obj = NativeArrayByteFactory.CreatePersistent(type2, nativeArrayBytes, bytes);
			if (!ContainsOverride(obj))
			{
				throw new InvalidOperationException("The replacement Guard T3 artillery template did not retain its override marker.");
			}
			(obj2.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(obj2.GetType().FullName, "Item")).SetValue(obj2, obj, new object[1] { templatePath });
			flag = true;
			DisposeNativeArray(type2, stockTemplate);
			Log("Replaced cached UGS3101 template before Lua startup. South-facing Disruptor yaw=Turret, pitch=Turret_Barrel, muzzle=Turret_Muzzle.");
		}
		catch (Exception arg)
		{
			if (obj != null && IsNativeArrayCreated(obj) && !flag)
			{
				DisposeNativeArray(obj.GetType(), obj);
			}
			Log($"Failed to replace the cached Guard T3 artillery template: {arg}");
			throw;
		}
	}

	private static bool TryGetTemplate(object cache, out string templatePath, out object stockTemplate)
	{
		templatePath = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), "LJ/lua/common/units/unitsTemplates/ugs3101/ugs3101.santp"));
		stockTemplate = null;
		Type type = cache.GetType();
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		if ((bool)obj.Invoke(cache, new object[1] { templatePath }))
		{
			stockTemplate = propertyInfo.GetValue(cache, new object[1] { templatePath });
			return IsNativeArrayCreated(stockTemplate);
		}
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			string text = (string)type2.GetProperty("Key").GetValue(item);
			if (text.Replace('\\', '/').EndsWith("/LJ/lua/common/units/unitsTemplates/ugs3101/ugs3101.santp", StringComparison.OrdinalIgnoreCase))
			{
				object value = type2.GetProperty("Value").GetValue(item);
				if (IsNativeArrayCreated(value))
				{
					templatePath = text;
					stockTemplate = value;
					return true;
				}
			}
		}
		return false;
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

	private static bool ContainsOverride(object template)
	{
		if (IsNativeArrayCreated(template))
		{
			return Encoding.UTF8.GetString(GetNativeArrayBytes(template.GetType(), template)).IndexOf("-- Guard Cybran T3 Artillery Cache Patcher 1.2.0", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	private static void Log(string message)
	{
		string text = "[Guard Cybran T3 Artillery Cache Patcher] " + message;
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
