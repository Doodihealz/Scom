using System;
using System.Collections;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace GuardCybranAcuCachePatcher;

public static class CachePatcherRuntime
{
	private const string TargetTemplateRelativePath = "LJ/lua/common/units/unitsTemplates/ugl0000/ugl0000.santp";

	private const string TargetTemplatePathSuffix = "/LJ/lua/common/units/unitsTemplates/ugl0000/ugl0000.santp";

	private const string OverrideMarker = "-- Guard Cybran ACU Cache Patcher 1.1.0";

	private const string TemplateOverride = "\n-- Guard Cybran ACU Cache Patcher 1.1.0\n-- The local personal pack supplies URL0001's native 24-bone rig,\n-- original rigid mesh skinning, and its own 21-key Awalk02 clip.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.buildBeamBones = {\n    \"Turret_Muzzle_01\",\n}\nUnitTemplate.additions.rotators = nil\nUnitTemplate.construction.beam = {\n    boneName = \"Turret_Muzzle_01\",\n    offset = { x = 0, y = 0, z = 0 },\n    shrink = 1,\n}\n\nUnitTemplate.movement.type = \"LegsLand\"\nUnitTemplate.movement.speed = 1.7\nUnitTemplate.movement.acceleration = 1.7\n-- URL0001 has MaxSpeed=1.7 and AnimationWalkRate=1.7. Sanctuary's\n-- velocity / authoredSpeed convention therefore requires 1.0 here.\nUnitTemplate.movement.walkAnimation = { authoredSpeed = 1 }\nfor index = #UnitTemplate.tags, 1, -1 do\n    if UnitTemplate.tags[index] == \"HOVER\" then\n        table.remove(UnitTemplate.tags, index)\n    end\nend\n\nUnitTemplate.visuals.animations = {\n    walk = {\n        authoredSpeed = 1,\n        clipName = \"AnimWalk01\",\n        sanAnimationPath = \"Units/ugl0000/LOD0/ugl0000.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\n\n-- URL0001's imported mesh is a compact, forward-offset biped.  Keep\n-- gameplay values intact while aligning collision, selection, and\n-- pathing to the authored model AABB plus a small movement margin.\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 1.2, z = 0.19 },\n    collisionSize = { x = 1.6, y = 2.6, z = 1.7 },\n}\nUnitTemplate.footprint = { x = 2.0, y = 2.1 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.8, y = 1.9 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 1.2, z = 0.19 }\n-- unitTemplateLoader consumes this opt-in box instead of inflating the\n-- visible bracket by 30 percent for click/selection collision.\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.8, y = 1.9 },\n    offset = { x = 0, y = 1.2, z = 0.19 },\n}\n\n-- Ring_Outside aim/muzzle bones do not exist on the native Cybran rig.\n-- FA's URL0001 blueprint verifies Muzzle_01 for construction and\n-- Muzzle_02 / Right_Turret for its normal primary fire. A zero-length\n-- controller list makes Sanctuary reject the weapon before it can\n-- create a projectile, so preserve the source yaw/pitch hierarchy.\nif not UnitTemplate.weapons or not UnitTemplate.weapons[1] then\n    error(\"UGL0000 Cybran ACU override requires the stock primary weapon\")\nend\nlocal primaryWeapon = UnitTemplate.weapons[1]\nprimaryWeapon.aimControllers = {\n    {\n        aimBone = \"Turret_Muzzle_02\",\n        aimTolerance = 2,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = \"Right_Turret\",\n        pitchMax = 90,\n        pitchMin = -90,\n        pitchSpeed = 90,\n        poseResetTime = 3,\n        projectileSpeed = 35,\n        solverType = \"LowArc\",\n        yawBone = \"Torso\",\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 90,\n    },\n}\nprimaryWeapon.muzzleGroups = {\n    { muzzles = { \"Turret_Muzzle_02\" } },\n}\nprimaryWeapon.muzzles = {\n    [\"Turret_Muzzle_02\"] = {\n        aimController = \"Turret_Muzzle_02\",\n    },\n}\n\n-- URL0001's Molecular Ripper is one direct ballistic shot per second,\n-- not the Guard commander's three-missile salvo. ``pgd211`` is the\n-- currently available direct-fire medium-plasma compatibility visual;\n-- the source-specific projectile remains explicitly tracked as a\n-- visual fallback rather than keeping the incorrect guided-missile\n-- fire type.\nprimaryWeapon.damage = 100\nprimaryWeapon.damageRadius = 0\nprimaryWeapon.effects = {\n    onFire = \"VFX/Muzzle/vgm1121_autocannon_plasma_small_muzzle.sanvfx\",\n}\nprimaryWeapon.firingRandomness = 0\nprimaryWeapon.muzzleGroupChargeDelay = 0\nprimaryWeapon.muzzleGroupTimeOut = -1\nprimaryWeapon.muzzleSalvoSize = 1\nprimaryWeapon.projectileLifetime = 3\nprimaryWeapon.projectileTemplate = \"pgd211\"\nprimaryWeapon.rangeMax = 22\nprimaryWeapon.rangeMin = 1\nprimaryWeapon.rangeRingType = \"DirectFire\"\nprimaryWeapon.rangeTracking = 1.1\nprimaryWeapon.reloadTime = 1\nprimaryWeapon.targetWaterLimits = \"Above\"";

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
				throw new FileNotFoundException("The Guard template was not present in Sanctuary's Lua file cache.", "LJ/lua/common/units/unitsTemplates/ugl0000/ugl0000.santp");
			}
			if (ContainsOverride(stockTemplate))
			{
				Log("The cached Guard template already contains the Cybran ACU override.");
				return;
			}
			Type type2 = stockTemplate.GetType();
			byte[] nativeArrayBytes = GetNativeArrayBytes(type2, stockTemplate);
			byte[] bytes = Encoding.UTF8.GetBytes("\n-- Guard Cybran ACU Cache Patcher 1.1.0\n-- The local personal pack supplies URL0001's native 24-bone rig,\n-- original rigid mesh skinning, and its own 21-key Awalk02 clip.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.buildBeamBones = {\n    \"Turret_Muzzle_01\",\n}\nUnitTemplate.additions.rotators = nil\nUnitTemplate.construction.beam = {\n    boneName = \"Turret_Muzzle_01\",\n    offset = { x = 0, y = 0, z = 0 },\n    shrink = 1,\n}\n\nUnitTemplate.movement.type = \"LegsLand\"\nUnitTemplate.movement.speed = 1.7\nUnitTemplate.movement.acceleration = 1.7\n-- URL0001 has MaxSpeed=1.7 and AnimationWalkRate=1.7. Sanctuary's\n-- velocity / authoredSpeed convention therefore requires 1.0 here.\nUnitTemplate.movement.walkAnimation = { authoredSpeed = 1 }\nfor index = #UnitTemplate.tags, 1, -1 do\n    if UnitTemplate.tags[index] == \"HOVER\" then\n        table.remove(UnitTemplate.tags, index)\n    end\nend\n\nUnitTemplate.visuals.animations = {\n    walk = {\n        authoredSpeed = 1,\n        clipName = \"AnimWalk01\",\n        sanAnimationPath = \"Units/ugl0000/LOD0/ugl0000.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\n\n-- URL0001's imported mesh is a compact, forward-offset biped.  Keep\n-- gameplay values intact while aligning collision, selection, and\n-- pathing to the authored model AABB plus a small movement margin.\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 1.2, z = 0.19 },\n    collisionSize = { x = 1.6, y = 2.6, z = 1.7 },\n}\nUnitTemplate.footprint = { x = 2.0, y = 2.1 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.8, y = 1.9 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 1.2, z = 0.19 }\n-- unitTemplateLoader consumes this opt-in box instead of inflating the\n-- visible bracket by 30 percent for click/selection collision.\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.8, y = 1.9 },\n    offset = { x = 0, y = 1.2, z = 0.19 },\n}\n\n-- Ring_Outside aim/muzzle bones do not exist on the native Cybran rig.\n-- FA's URL0001 blueprint verifies Muzzle_01 for construction and\n-- Muzzle_02 / Right_Turret for its normal primary fire. A zero-length\n-- controller list makes Sanctuary reject the weapon before it can\n-- create a projectile, so preserve the source yaw/pitch hierarchy.\nif not UnitTemplate.weapons or not UnitTemplate.weapons[1] then\n    error(\"UGL0000 Cybran ACU override requires the stock primary weapon\")\nend\nlocal primaryWeapon = UnitTemplate.weapons[1]\nprimaryWeapon.aimControllers = {\n    {\n        aimBone = \"Turret_Muzzle_02\",\n        aimTolerance = 2,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = \"Right_Turret\",\n        pitchMax = 90,\n        pitchMin = -90,\n        pitchSpeed = 90,\n        poseResetTime = 3,\n        projectileSpeed = 35,\n        solverType = \"LowArc\",\n        yawBone = \"Torso\",\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 90,\n    },\n}\nprimaryWeapon.muzzleGroups = {\n    { muzzles = { \"Turret_Muzzle_02\" } },\n}\nprimaryWeapon.muzzles = {\n    [\"Turret_Muzzle_02\"] = {\n        aimController = \"Turret_Muzzle_02\",\n    },\n}\n\n-- URL0001's Molecular Ripper is one direct ballistic shot per second,\n-- not the Guard commander's three-missile salvo. ``pgd211`` is the\n-- currently available direct-fire medium-plasma compatibility visual;\n-- the source-specific projectile remains explicitly tracked as a\n-- visual fallback rather than keeping the incorrect guided-missile\n-- fire type.\nprimaryWeapon.damage = 100\nprimaryWeapon.damageRadius = 0\nprimaryWeapon.effects = {\n    onFire = \"VFX/Muzzle/vgm1121_autocannon_plasma_small_muzzle.sanvfx\",\n}\nprimaryWeapon.firingRandomness = 0\nprimaryWeapon.muzzleGroupChargeDelay = 0\nprimaryWeapon.muzzleGroupTimeOut = -1\nprimaryWeapon.muzzleSalvoSize = 1\nprimaryWeapon.projectileLifetime = 3\nprimaryWeapon.projectileTemplate = \"pgd211\"\nprimaryWeapon.rangeMax = 22\nprimaryWeapon.rangeMin = 1\nprimaryWeapon.rangeRingType = \"DirectFire\"\nprimaryWeapon.rangeTracking = 1.1\nprimaryWeapon.reloadTime = 1\nprimaryWeapon.targetWaterLimits = \"Above\"");
			obj = NativeArrayByteFactory.CreatePersistent(type2, nativeArrayBytes, bytes);
			if (!ContainsOverride(obj))
			{
				throw new InvalidOperationException("The replacement Guard template did not retain its override marker.");
			}
			(obj2.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(obj2.GetType().FullName, "Item")).SetValue(obj2, obj, new object[1] { templatePath });
			flag = true;
			DisposeNativeArray(type2, stockTemplate);
			Log("Replaced cached UGL template before Lua startup. Native Cybran build beam is Turret_Muzzle_01; primary fire is Turret_Muzzle_02.");
		}
		catch (Exception arg)
		{
			if (obj != null && IsNativeArrayCreated(obj) && !flag)
			{
				DisposeNativeArray(obj.GetType(), obj);
			}
			Log($"Failed to replace the cached UGL template: {arg}");
			throw;
		}
	}

	private static bool TryGetTemplate(object cache, out string templatePath, out object stockTemplate)
	{
		templatePath = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), "LJ/lua/common/units/unitsTemplates/ugl0000/ugl0000.santp"));
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
			if (text.Replace('\\', '/').EndsWith("/LJ/lua/common/units/unitsTemplates/ugl0000/ugl0000.santp", StringComparison.OrdinalIgnoreCase))
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
			return Encoding.UTF8.GetString(GetNativeArrayBytes(template.GetType(), template)).IndexOf("-- Guard Cybran ACU Cache Patcher 1.1.0", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	private static void Log(string message)
	{
		string text = "[Guard Cybran ACU Cache Patcher] " + message;
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
