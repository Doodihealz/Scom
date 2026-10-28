using System;
using System.Collections;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace UefAcuEdaCachePatcher;

public static class CachePatcherRuntime
{
	private const string TargetTemplateRelativePath = "LJ/lua/common/units/unitsTemplates/uel0000/uel0000.santp";

	private const string TargetTemplatePathSuffix = "/LJ/lua/common/units/unitsTemplates/uel0000/uel0000.santp";

	private const string OverrideMarker = "-- UEF ACU EDA Cache Patcher 2.4.2";

	private const string TemplateOverride = "\n-- UEF ACU EDA Cache Patcher 2.4.2\n-- The pack supplies the original UEF skeleton, walk animation, mesh, and material.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.buildBeamBones = {\n    \"Left_Arm_Muzzle\",\n}\nUnitTemplate.construction.beam = {\n    boneName = \"Left_Arm_Muzzle\",\n    offset = { x = 0, y = 0, z = 0 },\n    shrink = 1,\n}\n\n-- UEL0001's imported biped mesh is shifted slightly forward/right.\n-- These values follow its measured AABB with a restrained movement\n-- clearance instead of the former tall, narrow stock box.\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = -0.09, y = 0.97, z = 0.43 },\n    collisionSize = { x = 2.2, y = 2.2, z = 2.1 },\n}\nUnitTemplate.footprint = { x = 2.6, y = 2.5 }\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.audio.engine = {\n    looping = true,\n    name = \"aclu1305\",\n}\n\nUnitTemplate.movement.type = \"LegsLand\"\nUnitTemplate.movement.speed = 1.7\nUnitTemplate.movement.acceleration = 1.7\nUnitTemplate.movement.rotationSpeed = 90\n-- UEL0001 has MaxSpeed=1.7 and AnimationWalkRate=1.7. Sanctuary's\n-- velocity / authoredSpeed convention therefore requires 1.0 here.\nUnitTemplate.movement.walkAnimation = { authoredSpeed = 1 }\nfor index = #UnitTemplate.tags, 1, -1 do\n    if UnitTemplate.tags[index] == \"HOVER\" then\n        table.remove(UnitTemplate.tags, index)\n    end\nend\n\nUnitTemplate.visuals.animations = {\n    walk = {\n        authoredSpeed = 1,\n        clipName = \"AnimWalk01\",\n        sanAnimationPath = \"Units/uel0000/LOD0/uel0000.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 2.4, y = 2.3 }\nUnitTemplate.visuals.selection.offset = { x = -0.09, y = 0.97, z = 0.43 }\n-- unitTemplateLoader consumes this opt-in box instead of inflating the\n-- visible bracket by 30 percent for click/selection collision.\nUnitTemplate.additions.selectionHit = {\n    size = { x = 2.4, y = 2.3 },\n    offset = { x = -0.09, y = 0.97, z = 0.43 },\n}\n\n-- The stock EDA turret controller references bones that do not exist\n-- on the native UEF rig. Restore UEL0001's verified main-gun chain:\n-- Right_Arm_Muzzle <- Right_Arm_Barrel <- Torso. This is intentionally\n-- one weapon muzzle; Left_Arm_Muzzle remains dedicated to construction.\n-- Sanctuary exposes the rigid Right_Arm_Barrel owner at the full normal-gun\n-- pitch extrema. Clamp this shared forearm chain to FA OverCharge's verified\n-- +/-60-degree envelope while retaining the normal gun's firing contract.\nUnitTemplate.weapons[1].aimControllers = {\n    {\n        aimBone = \"Right_Arm_Muzzle\",\n        aimTolerance = 2,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = \"Right_Arm_Barrel\",\n        pitchMax = 60,\n        pitchMin = -60,\n        pitchSpeed = 90,\n        poseResetTime = 3,\n        projectileSpeed = 35,\n        solverType = \"LowArc\",\n        yawBone = \"Torso\",\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 90,\n    },\n}\nUnitTemplate.weapons[1].muzzleGroups = {\n    { muzzles = { \"Right_Arm_Muzzle\" } },\n}\nUnitTemplate.weapons[1].muzzles = {\n    [\"Right_Arm_Muzzle\"] = { aimController = \"Right_Arm_Muzzle\" },\n}\nUnitTemplate.weapons[1].muzzleSalvoDelay = 0\nUnitTemplate.weapons[1].muzzleSalvoSize = 1\nUnitTemplate.weapons[1].firingRandomness = 0\n\n-- Keep the compatible muzzle layers while removing the donor's rear-offset\n-- Focus_Loop_3 emitter from this native UEF arm socket. UEL0000 retains its\n-- damage, range, reload, targeting layers, projectile, and firing audio.\nUnitTemplate.weapons[1].projectileTemplate = \"pcd121\"\nUnitTemplate.weapons[1].effects = UnitTemplate.weapons[1].effects or {}\nUnitTemplate.weapons[1].effects.onFire = \"VFX/SCOM/FieldFixes/UEFAcu/uef_acu_clean_muzzle.sanvfx\"\nUnitTemplate.weapons[1].audio = UnitTemplate.weapons[1].audio or {}\nUnitTemplate.weapons[1].audio.onFire = {\n    looping = false,\n    name = \"aeom1130\",\n}";

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
				throw new FileNotFoundException("The stock UEL template was not present in Sanctuary's Lua file cache.", "LJ/lua/common/units/unitsTemplates/uel0000/uel0000.santp");
			}
			if (ContainsOverride(stockTemplate))
			{
				Log("The cached UEL template already contains the native UEF override.");
				return;
			}
			Type type2 = stockTemplate.GetType();
			byte[] nativeArrayBytes = GetNativeArrayBytes(type2, stockTemplate);
			byte[] bytes = Encoding.UTF8.GetBytes("\n-- UEF ACU EDA Cache Patcher 2.4.2\n-- The pack supplies the original UEF skeleton, walk animation, mesh, and material.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.buildBeamBones = {\n    \"Left_Arm_Muzzle\",\n}\nUnitTemplate.construction.beam = {\n    boneName = \"Left_Arm_Muzzle\",\n    offset = { x = 0, y = 0, z = 0 },\n    shrink = 1,\n}\n\n-- UEL0001's imported biped mesh is shifted slightly forward/right.\n-- These values follow its measured AABB with a restrained movement\n-- clearance instead of the former tall, narrow stock box.\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = -0.09, y = 0.97, z = 0.43 },\n    collisionSize = { x = 2.2, y = 2.2, z = 2.1 },\n}\nUnitTemplate.footprint = { x = 2.6, y = 2.5 }\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.audio.engine = {\n    looping = true,\n    name = \"aclu1305\",\n}\n\nUnitTemplate.movement.type = \"LegsLand\"\nUnitTemplate.movement.speed = 1.7\nUnitTemplate.movement.acceleration = 1.7\nUnitTemplate.movement.rotationSpeed = 90\n-- UEL0001 has MaxSpeed=1.7 and AnimationWalkRate=1.7. Sanctuary's\n-- velocity / authoredSpeed convention therefore requires 1.0 here.\nUnitTemplate.movement.walkAnimation = { authoredSpeed = 1 }\nfor index = #UnitTemplate.tags, 1, -1 do\n    if UnitTemplate.tags[index] == \"HOVER\" then\n        table.remove(UnitTemplate.tags, index)\n    end\nend\n\nUnitTemplate.visuals.animations = {\n    walk = {\n        authoredSpeed = 1,\n        clipName = \"AnimWalk01\",\n        sanAnimationPath = \"Units/uel0000/LOD0/uel0000.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 2.4, y = 2.3 }\nUnitTemplate.visuals.selection.offset = { x = -0.09, y = 0.97, z = 0.43 }\n-- unitTemplateLoader consumes this opt-in box instead of inflating the\n-- visible bracket by 30 percent for click/selection collision.\nUnitTemplate.additions.selectionHit = {\n    size = { x = 2.4, y = 2.3 },\n    offset = { x = -0.09, y = 0.97, z = 0.43 },\n}\n\n-- The stock EDA turret controller references bones that do not exist\n-- on the native UEF rig. Restore UEL0001's verified main-gun chain:\n-- Right_Arm_Muzzle <- Right_Arm_Barrel <- Torso. This is intentionally\n-- one weapon muzzle; Left_Arm_Muzzle remains dedicated to construction.\n-- Sanctuary exposes the rigid Right_Arm_Barrel owner at the full normal-gun\n-- pitch extrema. Clamp this shared forearm chain to FA OverCharge's verified\n-- +/-60-degree envelope while retaining the normal gun's firing contract.\nUnitTemplate.weapons[1].aimControllers = {\n    {\n        aimBone = \"Right_Arm_Muzzle\",\n        aimTolerance = 2,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = \"Right_Arm_Barrel\",\n        pitchMax = 60,\n        pitchMin = -60,\n        pitchSpeed = 90,\n        poseResetTime = 3,\n        projectileSpeed = 35,\n        solverType = \"LowArc\",\n        yawBone = \"Torso\",\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 90,\n    },\n}\nUnitTemplate.weapons[1].muzzleGroups = {\n    { muzzles = { \"Right_Arm_Muzzle\" } },\n}\nUnitTemplate.weapons[1].muzzles = {\n    [\"Right_Arm_Muzzle\"] = { aimController = \"Right_Arm_Muzzle\" },\n}\nUnitTemplate.weapons[1].muzzleSalvoDelay = 0\nUnitTemplate.weapons[1].muzzleSalvoSize = 1\nUnitTemplate.weapons[1].firingRandomness = 0\n\n-- Keep the compatible muzzle layers while removing the donor's rear-offset\n-- Focus_Loop_3 emitter from this native UEF arm socket. UEL0000 retains its\n-- damage, range, reload, targeting layers, projectile, and firing audio.\nUnitTemplate.weapons[1].projectileTemplate = \"pcd121\"\nUnitTemplate.weapons[1].effects = UnitTemplate.weapons[1].effects or {}\nUnitTemplate.weapons[1].effects.onFire = \"VFX/SCOM/FieldFixes/UEFAcu/uef_acu_clean_muzzle.sanvfx\"\nUnitTemplate.weapons[1].audio = UnitTemplate.weapons[1].audio or {}\nUnitTemplate.weapons[1].audio.onFire = {\n    looping = false,\n    name = \"aeom1130\",\n}");
			obj = NativeArrayByteFactory.CreatePersistent(type2, nativeArrayBytes, bytes);
			if (!ContainsOverride(obj))
			{
				throw new InvalidOperationException("The replacement UEL template did not retain its override marker.");
			}
			(obj2.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(obj2.GetType().FullName, "Item")).SetValue(obj2, obj, new object[1] { templatePath });
			flag = true;
			DisposeNativeArray(type2, stockTemplate);
			Log("Replaced the cached UEL template before Host/Client Lua startup. The normal gun uses the stock Chosen commander projectile while UEF commander balance remains unchanged.");
		}
		catch (Exception arg)
		{
			if (obj != null && IsNativeArrayCreated(obj) && !flag)
			{
				DisposeNativeArray(obj.GetType(), obj);
			}
			Log($"Failed to replace the cached UEL template: {arg}");
			throw;
		}
	}

	private static bool TryGetTemplate(object cache, out string templatePath, out object stockTemplate)
	{
		templatePath = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), "LJ/lua/common/units/unitsTemplates/uel0000/uel0000.santp"));
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
			if (text.Replace('\\', '/').EndsWith("/LJ/lua/common/units/unitsTemplates/uel0000/uel0000.santp", StringComparison.OrdinalIgnoreCase))
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
			return Encoding.UTF8.GetString(GetNativeArrayBytes(template.GetType(), template)).IndexOf("-- UEF ACU EDA Cache Patcher 2.4.2", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	private static void Log(string message)
	{
		string text = "[UEF ACU EDA Cache Patcher] " + message;
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
