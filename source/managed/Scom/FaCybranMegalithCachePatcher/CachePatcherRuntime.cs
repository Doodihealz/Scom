using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Resources;
using System.Text;
using ScomRepair20260913;
using SupremeCommanderOverhaul.Shared;

namespace FaCybranMegalithCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class ExistingSpec
	{
		public string Path { get; }

		public string Description { get; }

		public string AppendixResource { get; }

		public Action<string> ValidateStock { get; }

		public Action<string> ValidatePatched { get; }

		public ExistingSpec(string path, string description, string appendixResource, Action<string> validateStock, Action<string> validatePatched)
		{
			Path = path;
			Description = description;
			AppendixResource = appendixResource;
			ValidateStock = validateStock;
			ValidatePatched = validatePatched;
		}
	}

	private sealed class PhysicalSpec
	{
		public string Id { get; }

		public string Path { get; }

		public string Description { get; }

		public string ResourceName { get; }

		public bool IsUnit { get; }

		public PhysicalSpec(string id, string path, string description, bool isUnit)
		{
			Id = id;
			Path = path;
			Description = description;
			ResourceName = "FaCybranMegalithCachePatcher.physical." + id + ".santp";
			IsUnit = isUnit;
		}
	}

	private sealed class Cached
	{
		public string Path { get; }

		public object Value { get; }

		public Cached(string path, object value)
		{
			Path = path;
			Value = value;
		}
	}

	private sealed class Mutation
	{
		public string Path { get; }

		public object? Stock { get; }

		public object Replacement { get; }

		public string Description { get; }

		public bool Added { get; }

		public bool Assigned { get; set; }

		public Mutation(string path, object? stock, object replacement, string description, bool added)
		{
			Path = path;
			Stock = stock;
			Replacement = replacement;
			Description = description;
			Added = added;
		}
	}

	private const string Marker = "-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0";

	private const string HostGuardPath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	private const string ClientGuardPath = "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua";

	private const string HostWeaponPath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string AvailableUnitsPath = "LJ/lua/common/units/availableUnits.lua";

	private const string ImportPath = "LJ/lua/common/systems/import.lua";

	private static readonly string[] UnitIds = new string[5] { "ugl4002", "ugs4902", "ugs4903", "ugs4904", "ugs4905" };

	private static readonly string[] ProjectileIds = new string[3] { "pmg401", "pmg402", "pmg403" };

	private static readonly ExistingSpec[] Existing = new ExistingSpec[5]
	{
		new ExistingSpec("LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Megalith/egg host classes", "FaCybranMegalithCachePatcher.guard_host_appendix.lua", delegate(string source)
		{
			RequireTokens(source, "HostGuardLandUnit = Class(\"GuardLandUnit\", LandUnit)", "HostGuardStructure", "HostGuardEngineer");
		}, ValidateHostGuard),
		new ExistingSpec("LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua", "Megalith/egg client identities", "FaCybranMegalithCachePatcher.guard_client_appendix.lua", delegate(string source)
		{
			RequireTokens(source, "ClientGuardLandUnit = Class(\"GuardLandUnit\", LandUnit)", "ClientGuardStructure", "ClientGuardEngineer");
		}, ValidateClientGuard),
		new ExistingSpec("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Megalith source water gates", "FaCybranMegalithCachePatcher.host_weapon_appendix.lua", delegate(string source)
		{
			RequireTokens(source, "function HostWeapon:CanShootAt(targetUnit)", "self.layerWeaponLimitsMask", "self.layerTargetLimitsMask");
		}, ValidateHostWeapon),
		new ExistingSpec("LJ/lua/common/units/availableUnits.lua", "Megalith closed available-unit roster", "FaCybranMegalithCachePatcher.available_units_appendix.lua", delegate(string source)
		{
			RequireTokens(source, "AvailableUnits =");
		}, ValidateAvailableUnits),
		new ExistingSpec("LJ/lua/common/systems/import.lua", "Megalith template-directory scanner routes", "FaCybranMegalithCachePatcher.import_scanner_appendix.lua", delegate(string source)
		{
			RequireTokens(source, "function ScanDir(directory)", "Engine.GetFoldersInsideDirectory");
		}, ValidateImportScanner)
	};

	private static readonly PhysicalSpec[] Physical = UnitIds.Select((string id) => new PhysicalSpec(id, "LJ/lua/common/units/unitsTemplates/" + id + "/" + id + ".santp", "physical unit template " + id, isUnit: true)).Concat(ProjectileIds.Select((string id) => new PhysicalSpec(id, "LJ/lua/common/projectiles/projectilesTemplates/" + id + "/" + id + ".santp", "physical projectile template " + id, isUnit: false))).ToArray();

	public static void Apply()
	{
		ApplyCore(GetLuaFileCache());
	}

	public static void ApplyForTests(object cache)
	{
		if (cache == null)
		{
			throw new ArgumentNullException("cache");
		}
		ApplyCore(cache);
	}

	private static void ApplyCore(object cache)
	{
		ValidateTransactionState(cache);
		List<Mutation> list = new List<Mutation>(Physical.Length + Existing.Length);
		try
		{
			QueuePhysicalTemplates(cache, list);
			ExistingSpec[] existing = Existing;
			foreach (ExistingSpec spec in existing)
			{
				QueueAppend(cache, list, spec);
			}
			if (list.Count == 0)
			{
				Log("FA Megalith/egg cache transaction is already current.");
				return;
			}
			int num = list.Count((Mutation mutation) => mutation.Added);
			Commit(cache, list);
			Log("Applied atomic FA Megalith physical/cache transaction; " + $"synthesized {num}/{Physical.Length} physical resources.");
		}
		catch
		{
			RollBack(cache, list);
			throw;
		}
	}

	private static void QueuePhysicalTemplates(object cache, ICollection<Mutation> mutations)
	{
		Type type = Get(cache, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Megalith host resource type oracle").Value.GetType();
		PhysicalSpec[] physical = Physical;
		foreach (PhysicalSpec physicalSpec in physical)
		{
			Cached cached = TryGet(cache, physicalSpec.Path, physicalSpec.Description);
			if (cached != null)
			{
				string source = Text(cached.Value);
				if (!IsLegacyPhysicalTemplate(physicalSpec, source))
				{
					ValidatePhysical(physicalSpec, source);
					continue;
				}
				string source2 = ReadEmbedded(physicalSpec.ResourceName);
				ValidatePhysical(physicalSpec, source2);
				object obj = Create(type, source2);
				try
				{
					ValidatePhysical(physicalSpec, Text(obj));
					mutations.Add(new Mutation(cached.Path, cached.Value, obj, physicalSpec.Description, added: false));
				}
				catch
				{
					TryDispose(obj, "uncommitted " + physicalSpec.Description);
					throw;
				}
			}
			else
			{
				string source3 = ReadEmbedded(physicalSpec.ResourceName);
				ValidatePhysical(physicalSpec, source3);
				object obj3 = Create(type, source3);
				try
				{
					ValidatePhysical(physicalSpec, Text(obj3));
					mutations.Add(new Mutation(Resolve(physicalSpec.Path), null, obj3, physicalSpec.Description, added: true));
				}
				catch
				{
					TryDispose(obj3, "uncommitted " + physicalSpec.Description);
					throw;
				}
			}
		}
	}

	private static bool IsLegacyPhysicalTemplate(PhysicalSpec spec, string source)
	{
		string text = ReadEmbedded(spec.ResourceName);
		if (!(source == text))
		{
			CacheCompatibilityRepair.RequireMegalithInput(source, spec.Id, spec.IsUnit, text);
			return true;
		}
		return false;
	}

	private static bool IsLegacyMegalithTemplate(PhysicalSpec spec, string source)
	{
		if (spec.Id != "ugl4002")
		{
			return false;
		}
		bool flag = source.IndexOf("toggles = { Pause = false }", StringComparison.Ordinal) < 0;
		bool num = source.IndexOf("VFX/Muzzle/vcm3121_cannon_antiair_small_muzzle.sanvfx", StringComparison.Ordinal) >= 0;
		bool flag2 = source.IndexOf("VFX/Muzzle/vgm1121_autocannon_plasma_small_muzzle.sanvfx", StringComparison.Ordinal) >= 0;
		if (!num && !flag2)
		{
			return false;
		}
		try
		{
			RequireTokens(source, "FA Cybran Megalith Physical Port 1.0.0", "UnitTemplate =", "tpId = \"ugl4002\"");
			ValidateMegalithTemplate(source, !flag, flag2, requireCurrentAudio: false);
			return true;
		}
		catch (InvalidOperationException)
		{
			return false;
		}
	}

	private static bool IsLegacyMegalithFlakProjectile(PhysicalSpec spec, string source)
	{
		if (spec.Id != "pmg403" || source.IndexOf("VFX/Trails/vgt1121_autocannon_plasma_small_trail.sanvfx", StringComparison.Ordinal) >= 0)
		{
			return false;
		}
		try
		{
			RequireTokens(source, "FA Cybran Megalith Physical Port 1.0.0", "ProjectileTemplate =", "tpId = \"pmg403\"", "sourceId = \"CAABurstCloud01\"", "VFX/Trails/vct3121_cannon_antiair_small_trail.sanvfx", "VFX/Impact/vci3121_cannon_antiair_small_impact.sanvfx");
			return true;
		}
		catch (InvalidOperationException)
		{
			return false;
		}
	}

	private static void ValidatePhysical(PhysicalSpec spec, string source)
	{
		RequireTokens(source, "FA Cybran Megalith Physical Port 1.0.1", spec.IsUnit ? "UnitTemplate =" : "ProjectileTemplate =", "tpId = \"" + spec.Id + "\"");
		if (!spec.IsUnit)
		{
			if (spec.Id == "pmg403")
			{
				ValidateMegalithFlakProjectile(source);
			}
		}
		else if (spec.Id == "ugl4002")
		{
			ValidateMegalithTemplate(source, requirePauseToggle: true, requireCurrentFlakVisual: true, requireCurrentAudio: true);
		}
		else
		{
			RequireTokens(source, "\"unitsDefaultGuard\", \"GuardMegalithEgg\"", "hostOwnsSpawnAndDelete = true", "clientSpawnBehavior = false");
		}
	}

	private static void ValidateMegalithTemplate(string source, bool requirePauseToggle, bool requireCurrentFlakVisual, bool requireCurrentAudio)
	{
		RequireTokens(source, "\"unitsDefaultGuard\", \"GuardFaCybranMegalith\"", "canBuild = \"Tags.ugs4902 + Tags.ugs4903 + Tags.ugs4904 + Tags.ugs4905\"", "\"BUILDABLE_BY_T3_ENGINEER\"", "\"ENGINEER\"", "destinationFactoryTagForbidden = true", "symbol = \"direct\"", "buildPower = 180", "range = 1", "authoredSpeed = 0.5555555555555556", "scoMegalithWaterGate = \"Above\"", "scoMegalithWaterGate = \"Below\"", "rangeRingType = \"AntiNaval\"", "Megalith invalid range-ring type at weapon");
		if (requirePauseToggle)
		{
			RequireTokens(source, "toggles = { Pause = false }");
		}
		if (requireCurrentFlakVisual)
		{
			RequireTokens(source, "VFX/Muzzle/vgm1121_autocannon_plasma_small_muzzle.sanvfx", "aimGravity = { x = 0, y = 0, z = 0 }", "projectileLifetime = 2.5", "projectileTemplate = \"pmg403\"", "rangeMax = 40", "rangeTracking = 1.4", "reloadTime = 0.625", "muzzles = { \"AA_Muzzle\", \"AA_Muzzle\" }");
			RequireNotContains(source, "VFX/Muzzle/vcm3121_cannon_antiair_small_muzzle.sanvfx");
		}
		if (requireCurrentAudio)
		{
			RequireTokens(source, "onFire = { looping = false, name = \"agom1130\" }", "donor = \"ugl3002 Guard Nitro large cannon\"", "sourceParity = false");
			RequireNotContains(source, "name = \"aglm");
			RequireExactly(source, "name = \"agom1130\"", 1, "Megalith Guard large-cannon fire audio");
		}
		RequireNotContains(source, "rangeRingType = \"AntiNavy\"");
		RequireNotContains(source, "\"FACTORY\"");
	}

	private static void ValidateMegalithFlakProjectile(string source)
	{
		RequireTokens(source, "sourceId = \"CAABurstCloud01\"", "sourceBlueprintSha256 = \"a67bd4f98381453ecd65897dc7d40feb7f8c1005f669b67e3f20e2162362bff4\"", "sourceScriptSha256 = \"c40d3c20d99e4bf9380bb68009558bf0da7f3a516e327305cbd41e6f3fa314bc\"", "destinationVisualRevision = \"red-fast-fallback-1.0.0\"", "sourceDamage = 18", "sourceDamageRadius = 2", "sourceInitialSpeed = 20", "sourceLifetime = 5", "sourceUseGravity = false", "sourceVelocityAlign = true", "sourceDestroyOnWater = true", "sourceDetonateAboveHeight = 10", "sourceTrailSize = 0.025", "movement = {", "gravityMultiplier = 0", "VFX/Trails/vgt1121_autocannon_plasma_small_trail.sanvfx", "VFX/Impact/vgi1121_autocannon_plasma_small_impact.sanvfx");
		RequireNotContains(source, "VFX/Trails/vct3121_cannon_antiair_small_trail.sanvfx", "VFX/Impact/vci3121_cannon_antiair_small_impact.sanvfx", "type =", "speedMax =", "acceleration =");
	}

	private static void ValidateTransactionState(object cache)
	{
		int num = Existing.Count((ExistingSpec spec) => Text(Get(cache, spec.Path, spec.Description).Value).IndexOf("-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0", StringComparison.Ordinal) >= 0);
		if (num != 0 && num != Existing.Length)
		{
			throw new InvalidOperationException($"A partial FA Megalith cache transaction exists ({num}/{Existing.Length}).");
		}
	}

	private static void QueueAppend(object cache, ICollection<Mutation> mutations, ExistingSpec spec)
	{
		Cached cached = Get(cache, spec.Path, spec.Description);
		string text = Text(cached.Value);
		if (text.IndexOf("-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0", StringComparison.Ordinal) >= 0)
		{
			spec.ValidatePatched(text);
			return;
		}
		spec.ValidateStock(text);
		string appendix = ReadEmbedded(spec.AppendixResource);
		string text2 = Append(text, appendix);
		spec.ValidatePatched(text2);
		object obj = Create(cached.Value.GetType(), text2);
		try
		{
			spec.ValidatePatched(Text(obj));
			mutations.Add(new Mutation(cached.Path, cached.Value, obj, spec.Description, added: false));
		}
		catch
		{
			TryDispose(obj, "uncommitted " + spec.Description);
			throw;
		}
	}

	private static void ValidateHostGuard(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0", 1, "host marker");
		string source2 = Owned(source);
		RequireTokens(source2, "HostGuardFaCybranMegalith = Class(", "\"GuardFaCybranMegalith\"", "SCO_MegalithEngineer.OnStopBeingBuilt(self, ...)", "Engine.SetMovementMaxSpeed(self.id, speed)", "local speed = isSeabed and 2.5 or 2", "Engine.GetMovementCurrentSpeed(self.id)", "Engine.GetMovementChassisYawDegrees(self.id)", "local SCO_MegalithWalkBlendSeconds = 0.35", "local SCO_MegalithRestBlendSeconds = 0.5", "local SCO_MegalithWalkStartSpeed = 0.05", "local SCO_MegalithWalkStopSpeed = 0.02", "local SCO_MegalithWalkStartYaw = 0.1", "local SCO_MegalithWalkStopYaw = 0.05", "A failed movement sample must not tear down an active gait", "SCO_MegalithAnimation(self, \"awake\")", "self, \"walk\", SCO_MegalithWalkBlendSeconds", "self, \"rest\", SCO_MegalithRestBlendSeconds", "SCO_MegalithAnimation(self, \"death\")", "WaitSeconds(3.2)", "HostGuardMegalithEgg = Class(\"GuardMegalithEgg\"", "ugs4902 = \"ugl3501\"", "ugs4903 = \"ugl3001\"", "ugs4904 = \"ugl2201\"", "ugs4905 = \"ugl3101\"", "if self.scoMegalithEggSpawned then", "self.scoMegalithEggSpawned = true", "CreateUnit(self.army.id, product, self:GetPosition());", "WaitSeconds(6.666666865348816)", "for _ = 1, 40 do", "position.y - 0.5", "self:Destroy(0, DestroyType.Kinetic)");
		RequireExactly(source2, "CreateUnit(self.army.id, product, self:GetPosition());", 1, "host-owned child creation site");
		RequireNotContains(source2, "ScanDir(", "ClientGuardMegalithEgg", "SCO_MegalithAnimation(self, \"idle\"");
	}

	private static void ValidateClientGuard(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0", 1, "client marker");
		string source2 = Owned(source);
		RequireTokens(source2, "ClientGuardFaCybranMegalith = Class(", "ClientGuardMegalithEgg = Class(", "function ClientGuardMegalithEgg:IsSelectable()", "if self.scoMegalithEggVisualShell then", "return SCO_MegalithClientStructure.IsSelectable(self)", "function ClientGuardMegalithEgg:SetSelectionEnabled(enabled)", "function ClientGuardMegalithEgg:CreateTarmac()", "function ClientGuardMegalithEgg:OnCompleted()", "SCO_MegalithClampVisualShell(self)", "Engine.SetLocalGridModifierEnabled(egg.localId, false)", "function ClientGuardFaCybranMegalith:ClientOnStopBuilding()", "SCO_MegalithClientEngineer.ClientOnStopBuilding(self)", "SCO_MegalithClampVisualShell(targetUnit)", "Engine.GetGlobalEntityPairedLocalID(globalId, localId)", "Engine.SetVolumeColliderEnabled(localId, enabled)");
		RequireNotContains(source2, "CreateUnit(", "NewThread(", "SetPosition(", "Destroy(", "PlayAnimation(");
	}

	private static void ValidateHostWeapon(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0", 1, "weapon marker");
		string source2 = Owned(source);
		RequireTokens(source2, "local SCO_MegalithStockCanShootAt = HostWeapon.CanShootAt", "weapon.unit.tpId ~= \"ugl4002\"", "gate ~= \"Above\" and gate ~= \"Below\"", "Engine.HasWater()", "Engine.GetWaterLevel()", "return ownerAbove and targetAbove", "weapon.unit.targetingLayer == SCO_MegalithTargetingLayer.Seabed", "layer == SCO_MegalithTargetingLayer.Water", "layer == SCO_MegalithTargetingLayer.WaterSurface", "and SCO_MegalithIsTorpedoTarget(target)", "return SCO_MegalithStockCanShootAt(self, targetUnit)");
		RequireNotContains(source2, "CIMAntiTorpedo02", "RULEWTT_Projectile", "return not ownerAbove and not targetAbove");
	}

	private static void ValidateAvailableUnits(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0", 1, "available-unit marker");
		string source2 = Owned(source);
		string[] unitIds = UnitIds;
		foreach (string text in unitIds)
		{
			RequireExactly(source2, "AvailableUnits[\"" + text + "\"] = true", 1, text + " availability assignment");
		}
		RequireNotContains(source2, "ScanDir(", "AvailableUnits = {");
	}

	private static void ValidateImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0", 1, "template scanner marker");
		string source2 = Owned(source);
		RequireTokens(source2, "local SCO_MegalithScanDir = ScanDir", "local SCO_MegalithScanRoutes =", "[\"common/units/unitsTemplates/\"]", "[\"common/projectiles/projectilesTemplates/\"]", "\"ugl4002\"", "\"ugs4902\"", "\"ugs4903\"", "\"ugs4904\"", "\"ugs4905\"", "\"pmg401\"", "\"pmg402\"", "\"pmg403\"", "local folders = SCO_MegalithScanDir(directory)", "local folder = directory .. id", "if not known[folder] then", "table.insert(folders, folder)");
		RequireNotContains(source2, "Engine.GetFoldersInsideDirectory");
	}

	private static void Commit(object cache, IEnumerable<Mutation> mutations)
	{
		foreach (Mutation mutation in mutations)
		{
			Set(cache, mutation.Path, mutation.Replacement);
			mutation.Assigned = true;
		}
		foreach (Mutation mutation2 in mutations)
		{
			if (mutation2.Stock != null)
			{
				TryDispose(mutation2.Stock, "stock " + mutation2.Description);
			}
		}
	}

	private static void RollBack(object cache, IEnumerable<Mutation> mutations)
	{
		foreach (Mutation item in mutations.Reverse())
		{
			if (item.Assigned)
			{
				try
				{
					if (item.Added)
					{
						Remove(cache, item.Path);
					}
					else
					{
						Set(cache, item.Path, item.Stock ?? throw new InvalidOperationException(item.Description + " has no stock resource."));
					}
					item.Assigned = false;
				}
				catch (Exception arg)
				{
					Log($"Rollback failed for {item.Description}: {arg}");
				}
			}
			if (!item.Assigned)
			{
				TryDispose(item.Replacement, "replacement " + item.Description);
			}
		}
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static Cached Get(object cache, string relativePath, string description)
	{
		return TryGet(cache, relativePath, description) ?? throw new FileNotFoundException("Required " + description + " was not present in Sanctuary's Lua cache.", relativePath);
	}

	private static Cached? TryGet(object cache, string relativePath, string description)
	{
		Type type = cache.GetType();
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		string text = Resolve(relativePath);
		object obj2 = obj.Invoke(cache, new object[1] { text });
		bool flag = false;
		int num;
		if (obj2 is bool)
		{
			flag = (bool)obj2;
			num = 1;
		}
		else
		{
			num = 0;
		}
		if (((uint)num & (flag ? 1u : 0u)) != 0)
		{
			object obj3 = propertyInfo.GetValue(cache, new object[1] { text }) ?? throw new InvalidOperationException("Cached " + description + " has no value.");
			EnsureCreated(obj3, description);
			return new Cached(text, obj3);
		}
		string value = "/" + relativePath.Replace('\\', '/');
		Cached cached = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text2 && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cached != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + relativePath + ".");
				}
				object obj4 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("Cached " + description + " has no value.");
				EnsureCreated(obj4, description);
				cached = new Cached(text2, obj4);
			}
		}
		return cached;
	}

	private static string Resolve(string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static object Create(Type nativeArrayType, string source)
	{
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, Encoding.UTF8.GetBytes(source));
	}

	private static string Text(object resource)
	{
		EnsureCreated(resource, "Lua cache resource");
		MethodInfo methodInfo = resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray");
		return Encoding.UTF8.GetString((byte[])methodInfo.Invoke(resource, null));
	}

	private static void EnsureCreated(object resource, string description)
	{
		object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource);
		if (!(value is bool) || !(bool)value)
		{
			throw new InvalidOperationException("Cached " + description + " is not an initialized NativeArray.");
		}
	}

	private static void Set(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void Remove(object cache, string path)
	{
		object obj = (cache.GetType().GetMethod("Remove", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "Remove")).Invoke(cache, new object[1] { path });
		if (!(obj is bool) || !(bool)obj)
		{
			throw new InvalidOperationException("Could not remove added Megalith cache resource: " + path);
		}
	}

	private static void TryDispose(object? resource, string description)
	{
		if (resource == null)
		{
			return;
		}
		try
		{
			object value = (resource.GetType().GetProperty("IsCreated") ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource);
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
				(resource.GetType().GetMethod("Dispose", Type.EmptyTypes) ?? throw new MissingMethodException(resource.GetType().FullName, "Dispose")).Invoke(resource, null);
			}
		}
		catch (Exception arg)
		{
			Log($"Could not dispose {description}: {arg}");
		}
	}

	private static string ReadEmbedded(string name)
	{
		using Stream stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(name) ?? throw new MissingManifestResourceException("Embedded Megalith appendix is missing: " + name);
		using StreamReader streamReader = new StreamReader(stream, Encoding.UTF8, detectEncodingFromByteOrderMarks: true);
		return streamReader.ReadToEnd();
	}

	private static string Append(string source, string appendix)
	{
		return Normalize(source).TrimEnd(new char[1] { '\n' }) + "\n" + Normalize(appendix).TrimStart(new char[1] { '\n' }).TrimEnd(new char[1] { '\n' }) + "\n";
	}

	private static string Normalize(string value)
	{
		return value.Replace("\r\n", "\n").Replace('\r', '\n');
	}

	private static string Owned(string source)
	{
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Megalith marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0".Length, StringComparison.Ordinal);
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

	private static void RequireNotContains(string source, params string[] tokens)
	{
		foreach (string text in tokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) >= 0)
			{
				throw new InvalidOperationException("Megalith-owned Lua must not contain '" + text + "'.");
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

	private static void Log(string message)
	{
		string text = "[FA Cybran Megalith Cache Patcher] " + message;
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
