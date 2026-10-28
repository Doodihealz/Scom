using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using ScomDeterministicLua;
using SupremeCommanderOverhaul.Shared;

namespace FaAirScoutCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class PatchSpec
	{
		internal string TargetId { get; }

		internal string SourceId { get; }

		internal string SourceBlueprintPath { get; }

		internal string SourceBlueprintSha256 { get; }

		internal string SourceFactionCategory { get; }

		internal string FactionTag { get; }

		internal string ExpectedClassOwner { get; }

		internal string ExpectedUnitClass { get; }

		internal double Health { get; }

		internal double Elevation { get; }

		internal double SelectionX { get; }

		internal double SelectionZ { get; }

		internal double SelectionThickness { get; }

		internal string RelativePath => "LJ/lua/common/units/unitsTemplates/" + TargetId + "/" + TargetId + ".santp";

		internal string Description => TargetId + " <- " + SourceId + " air-scout template";

		internal PatchSpec(string targetId, string sourceId, string sourceBlueprintPath, string sourceBlueprintSha256, string sourceFactionCategory, string factionTag, string expectedClassOwner, string expectedUnitClass, double health, double elevation, double selectionX, double selectionZ, double selectionThickness)
		{
			TargetId = targetId;
			SourceId = sourceId;
			SourceBlueprintPath = sourceBlueprintPath;
			SourceBlueprintSha256 = sourceBlueprintSha256;
			SourceFactionCategory = sourceFactionCategory;
			FactionTag = factionTag;
			ExpectedClassOwner = expectedClassOwner;
			ExpectedUnitClass = expectedUnitClass;
			Health = health;
			Elevation = elevation;
			SelectionX = selectionX;
			SelectionZ = selectionZ;
			SelectionThickness = selectionThickness;
		}
	}

	private sealed class CachedResource
	{
		internal PatchSpec Spec { get; }

		internal string Path { get; }

		internal object Stock { get; }

		internal object? Replacement { get; set; }

		internal bool ReplacementWasAssigned { get; set; }

		internal CachedResource(PatchSpec spec, string path, object stock)
		{
			Spec = spec;
			Path = path;
			Stock = stock;
		}
	}

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Air Scout Gameplay 1.0.0";

	internal const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	private const string NativeOrbitRange = "9.740282517223996";

	private static readonly string[] SourceCategories = new string[13]
	{
		"PRODUCTSC1", "SELECTABLE", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", "MOBILE", "AIR", "HIGHALTAIR", "TECH1", "INTELLIGENCE",
		"SCOUT", "VISIBLETORECON", "RECLAIMABLE"
	};

	private static readonly PatchSpec[] PatchSpecs = new PatchSpec[2]
	{
		new PatchSpec("uea1701", "UEA0101", "units/UEA0101/UEA0101_unit.bp", "39b9fbfadab9d5aefcb1e624e69a0fa71b806f887576145198b6971fc1976824", "UEF", "EDA", "unitsDefaultEDA", "EDAAirUnit", 35.0, 18.0, 0.36, 0.5, 0.8),
		new PatchSpec("uga1701", "URA0101", "units/URA0101/URA0101_unit.bp", "b0855327822e770fff89d3ff7f5ac123247d0821dea7a824499ade446d872b9b", "CYBRAN", "GUARD", "unitsDefaultGuard", "GuardAirUnit", 26.0, 20.0, 0.5, 0.45, 0.85)
	};

	public static void Apply()
	{
		ValidatePinnedScope();
		List<CachedResource> list = new List<CachedResource>(PatchSpecs.Length);
		object obj = null;
		bool flag = false;
		try
		{
			obj = GetLuaFileCache();
			PatchSpec[] patchSpecs = PatchSpecs;
			foreach (PatchSpec patchSpec in patchSpecs)
			{
				if (!TryGetCachedResource(obj, patchSpec, out CachedResource resource))
				{
					throw new FileNotFoundException("The required " + patchSpec.Description + " was not present in Sanctuary's Lua file cache.", patchSpec.RelativePath);
				}
				ValidateStockClass(resource);
				list.Add(resource);
			}
			int num = list.Count((CachedResource cachedResource) => ContainsOverride(cachedResource.Stock));
			if (num == list.Count)
			{
				foreach (CachedResource item in list)
				{
					ValidateExistingOverride(item);
				}
				Log("Both FA air-scout gameplay templates are already current.");
				return;
			}
			if (num != 0)
			{
				throw new InvalidOperationException("A partial FA air-scout gameplay override was found. Refusing to mix stock and imported scout contracts.");
			}
			foreach (CachedResource item2 in list)
			{
				string text = BuildOverride(item2.Spec);
				item2.Replacement = AppendOverride(item2.Stock, text);
				string nativeArrayText = GetNativeArrayText(item2.Replacement);
				if (CountOccurrences(nativeArrayText, "-- Supreme Commander Overhaul FA Air Scout Gameplay 1.0.0") != 1 || nativeArrayText.IndexOf(text, StringComparison.Ordinal) < 0)
				{
					throw new InvalidOperationException("The replacement " + item2.Spec.Description + " lost or duplicated its exact override.");
				}
			}
			foreach (CachedResource item3 in list)
			{
				item3.ReplacementWasAssigned = true;
				SetCachedResource(obj, item3.Path, item3.Replacement);
			}
			flag = true;
			foreach (CachedResource item4 in list)
			{
				TryDisposeNativeArray(item4.Stock.GetType(), item4.Stock, "stock " + item4.Spec.Description);
			}
			Log("Applied the exact UEA0101/URA0101 source gameplay contracts to uea1701/uga1701; EDA and Guard classes remain unchanged.");
		}
		catch (Exception arg)
		{
			if (!flag && obj != null)
			{
				RollBackAndDispose(obj, list);
			}
			Log($"Failed to apply the FA air-scout gameplay transaction: {arg}");
			throw;
		}
	}

	private static void ValidatePinnedScope()
	{
		if (PatchSpecs.Length != 2 || PatchSpecs[0].TargetId != "uea1701" || PatchSpecs[0].SourceId != "UEA0101" || PatchSpecs[0].SourceFactionCategory != "UEF" || PatchSpecs[1].TargetId != "uga1701" || PatchSpecs[1].SourceId != "URA0101" || PatchSpecs[1].SourceFactionCategory != "CYBRAN" || PatchSpecs.Select((PatchSpec spec) => spec.TargetId).Distinct<string>(StringComparer.Ordinal).Count() != 2 || PatchSpecs.Select((PatchSpec spec) => spec.SourceId).Distinct<string>(StringComparer.Ordinal).Count() != 2)
		{
			throw new InvalidOperationException("The FA air-scout patch scope changed from its two reviewed mappings.");
		}
		PatchSpec[] patchSpecs = PatchSpecs;
		foreach (PatchSpec patchSpec in patchSpecs)
		{
			if (patchSpec.SourceBlueprintSha256.Length != 64 || patchSpec.SourceBlueprintSha256.Any((char character) => !Uri.IsHexDigit(character)))
			{
				throw new InvalidOperationException(patchSpec.SourceId + " has an invalid pinned blueprint SHA-256.");
			}
		}
	}

	private static void ValidateStockClass(CachedResource resource)
	{
		string nativeArrayText = GetNativeArrayText(resource.Stock);
		string pattern = "class\\s*=\\s*\\{\\s*\"" + Regex.Escape(resource.Spec.ExpectedClassOwner) + "\"\\s*,\\s*\"" + Regex.Escape(resource.Spec.ExpectedUnitClass) + "\"\\s*,?\\s*\\}";
		if (!Regex.IsMatch(nativeArrayText, pattern, RegexOptions.CultureInvariant) || nativeArrayText.IndexOf("tpId = \"" + resource.Spec.TargetId + "\"", StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException(resource.Spec.Description + " no longer exposes its reviewed Sanctuary class/ID contract.");
		}
	}

	private static void ValidateExistingOverride(CachedResource resource)
	{
		string nativeArrayText = GetNativeArrayText(resource.Stock);
		if (CountOccurrences(nativeArrayText, "-- Supreme Commander Overhaul FA Air Scout Gameplay 1.0.0") != 1 || nativeArrayText.IndexOf(BuildOverride(resource.Spec), StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException(resource.Spec.Description + " has a stale, duplicated, or modified FA air-scout override.");
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

	private static string BuildOverride(PatchSpec spec)
	{
		string text = Lua(spec.Health);
		string text2 = Lua(spec.Elevation);
		string text3 = Lua(spec.SelectionX);
		string text4 = Lua(spec.SelectionZ);
		string text5 = Lua(spec.SelectionThickness);
		string text6 = string.Join("\n", from category in SourceCategories.Concat<string>(new string[1] { spec.SourceFactionCategory })
			select "        \"" + category + "\",");
		return ("\n-- Supreme Commander Overhaul FA Air Scout Gameplay 1.0.0\n-- Runtime values come only from the two hash-pinned FA blueprints\n-- below. Sanctuary's native Plane controller has no direct KLift,\n-- KLiftDamping, LiftFactor, KMove, or KTurn fields; those exact\n-- values remain explicit provenance while preferredAltitude and the\n-- speed/turn-derived orbit fields drive the supported controller.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = " + text3 + ", y = " + text4 + " },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.additions.faSourceContract = {\n    sourceId = \"" + spec.SourceId + "\",\n    targetId = \"" + spec.TargetId + "\",\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"" + spec.SourceBlueprintPath + "\",\n    sourceBlueprintSha256 = \"" + spec.SourceBlueprintSha256 + "\",\n    sourceCategories = {\n" + text6 + "\n    },\n    collision = {\n        centerOffset = { x = 0, y = 0, z = 0 },\n        size = { x = 0.4, y = 0.15, z = 0.6 },\n    },\n    selection = {\n        size = { x = " + text3 + ", y = " + text4 + " },\n        thickness = " + text5 + ",\n    },\n    footprint = { x = 1, y = 1, sourceMaxSlope = 0.25 },\n    sourceSizeSphere = 1.6,\n    movement = {\n        sourceMotionType = \"RULEUMT_Air\",\n        sourceElevation = " + text2 + ",\n        sourcePhysicsMaxSpeed = 10,\n        sourceMinSpeedPercent = 0.85,\n        sourceMaxAirspeed = 20,\n        sourceMinAirspeed = 17,\n        sourceMaxAcceleration = 10,\n        sourceMaxSteerForce = 100,\n        sourceTurnRadius = 100,\n        sourceTurnRate = 100,\n        sourceBankingSlope = 0.5,\n        sourceGroundCollisionOffset = 1.6,\n        sourceAutoLandTime = 1,\n        sourceBankFactor = 2,\n        sourceBankForward = false,\n        sourceCanFly = true,\n        sourceCombatTurnSpeed = 1,\n        sourceEngageDistance = 50,\n        sourceKLift = 3,\n        sourceKLiftDamping = 2.5,\n        sourceLiftFactor = 7,\n        sourceKMove = 1,\n        sourceKMoveDamping = 1,\n        sourceKRoll = 2,\n        sourceKRollDamping = 1,\n        sourceKTurn = 1,\n        sourceKTurnDamping = 1.5,\n        sourceStartTurnDistance = 5,\n        sourceTightTurnMultiplier = 1.1,\n        sourceTurnSpeed = 0.8,\n        sourceWinged = true,\n        sourceFuelRechargeRate = 5,\n        sourceFuelUseTime = 500,\n        nativeBankFactor = 1,\n        nativeOrbitRange = 9.740282517223996,\n        nativeOrbitSpeed = 17,\n    },\n    deathImpact = {\n        label = \"DeathImpact\",\n        weaponCategory = \"Death\",\n        aboveWaterTargetsOnly = true,\n        damage = 10,\n        damageRadius = 1,\n        damageFriendly = true,\n        damageType = \"Normal\",\n        firingTolerance = 2,\n    },\n}\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0, z = 0 },\n    collisionSize = { x = 0.4, y = 0.15, z = 0.6 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = " + text3 + ", y = " + text4 + " }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0, z = 0 }\n\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = {\n    max = " + text + ",\n    regen = 0,\n    value = " + text + ",\n}\nUnitTemplate.intel = { visionRadius = 42 }\nUnitTemplate.economy = {\n    buildTime = 400,\n    cost = { alloys = 40, energy = 1600 },\n}\n\nUnitTemplate.movement = UnitTemplate.movement or {}\nUnitTemplate.movement.type = \"Plane\"\nUnitTemplate.movement.speed = 20\nUnitTemplate.movement.minSpeed = 17\nUnitTemplate.movement.acceleration = 10\nUnitTemplate.movement.deceleration = nil\nUnitTemplate.movement.rotationSpeed = 100\nUnitTemplate.movement.air = true\nUnitTemplate.movement.airHover = false\nUnitTemplate.movement.landWhenIdleSeconds = 1\nUnitTemplate.movement.altitudeJitterFactor = 1\nUnitTemplate.movement.bankFactor = 1\nUnitTemplate.movement.orbitRange = 9.740282517223996\nUnitTemplate.movement.orbitSpeed = 17\nUnitTemplate.movement.collisionMaskDefault = { \"Air\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"LandSmall\" }\nUnitTemplate.movement.referenceAltitude = \"GroundOrWater\"\nUnitTemplate.movement.preferredAltitude = " + text2 + "\nUnitTemplate.movement.terrainAlignmentFactor = 0\nUnitTemplate.movement.sortOrder = 2\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil\nUnitTemplate.movement.targetCirclingRadius = nil\nUnitTemplate.movement.targetCirclingSpeed = nil\nUnitTemplate.movement.targetCirclingTime = nil\nUnitTemplate.movement.walkAnimation = nil\n\nUnitTemplate.tags = {\n    \"AIR\",\n    \"BUILDABLE_BY_T1_FACTORY\",\n    \"BUILDABLE_BY_T2_FACTORY\",\n    \"BUILDABLE_BY_T3_FACTORY\",\n    \"" + spec.FactionTag + "\",\n    \"INTEL\",\n    \"MOBILE\",\n    \"SCOUT\",\n    \"TECH1\",\n}\n\n-- No FA combat weapon exists. Replace every donor weapon route with\n-- the source's non-visual air-crash damage contract.\nUnitTemplate.weapons = {\n    {\n        category = \"DeathExplosion\",\n        damage = 10,\n        damageRadius = 1,\n        damageFriendly = true,\n        damageType = \"Normal\",\n    },\n}\n\n-- The visual pack has no animation payload. Keep only effects that\n-- can bind to the converter's verified Root bone; remove every\n-- donor exhaust/animation reference to nonexistent stock bones.\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do\n            effect.boneName = \"Root\"\n        end\n    end\nend").Replace("\r\n", "\n");
	}

	private static string Lua(double value)
	{
		return StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture);
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static bool TryGetCachedResource(object cache, PatchSpec spec, out CachedResource resource)
	{
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string fullPath = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), spec.RelativePath));
		if ((bool)obj.Invoke(cache, new object[1] { fullPath }))
		{
			object obj2 = propertyInfo.GetValue(cache, new object[1] { fullPath }) ?? throw new InvalidOperationException("The cached " + spec.Description + " has no value.");
			RequireCreated(obj2, spec.Description);
			resource = new CachedResource(spec, fullPath, obj2);
			return true;
		}
		string value = "/" + spec.RelativePath.Replace('\\', '/');
		string text = null;
		object obj3 = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			string text2 = (string)type2.GetProperty("Key")?.GetValue(item);
			if (text2 != null && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (text != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + spec.RelativePath + ".");
				}
				text = text2;
				obj3 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("The cached " + spec.Description + " has no value.");
				RequireCreated(obj3, spec.Description);
			}
		}
		if (text == null || obj3 == null)
		{
			resource = null;
			return false;
		}
		resource = new CachedResource(spec, text, obj3);
		return true;
	}

	private static void RequireCreated(object resource, string description)
	{
		if (!IsNativeArrayCreated(resource))
		{
			throw new InvalidOperationException("The cached " + description + " is not an initialized NativeArray.");
		}
	}

	private static object AppendOverride(object stockResource, string appendix)
	{
		return NativeArrayByteFactory.CreatePersistent(stockResource.GetType(), GetNativeArrayBytes(stockResource.GetType(), stockResource), Encoding.UTF8.GetBytes(appendix));
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void RollBackAndDispose(object cache, IEnumerable<CachedResource> resources)
	{
		foreach (CachedResource item in resources.Reverse())
		{
			bool flag = !item.ReplacementWasAssigned;
			if (item.ReplacementWasAssigned)
			{
				try
				{
					SetCachedResource(cache, item.Path, item.Stock);
					flag = true;
				}
				catch (Exception arg)
				{
					Log($"Rollback failed for {item.Spec.Description}: {arg}");
				}
			}
			if (flag && item.Replacement != null && IsNativeArrayCreated(item.Replacement))
			{
				TryDisposeNativeArray(item.Replacement.GetType(), item.Replacement, "replacement " + item.Spec.Description);
			}
		}
	}

	private static byte[] GetNativeArrayBytes(Type nativeArrayType, object nativeArray)
	{
		return (byte[])(nativeArrayType.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "ToArray")).Invoke(nativeArray, null);
	}

	private static string GetNativeArrayText(object nativeArray)
	{
		return Encoding.UTF8.GetString(GetNativeArrayBytes(nativeArray.GetType(), nativeArray));
	}

	private static bool IsNativeArrayCreated(object nativeArray)
	{
		return (bool)(nativeArray.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(nativeArray.GetType().FullName, "IsCreated")).GetValue(nativeArray);
	}

	private static void TryDisposeNativeArray(Type nativeArrayType, object nativeArray, string description)
	{
		try
		{
			(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
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
			return GetNativeArrayText(resource).IndexOf("-- Supreme Commander Overhaul FA Air Scout Gameplay 1.0.0", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	private static void Log(string message)
	{
		string text = "[FA Air Scout Gameplay] " + message;
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
