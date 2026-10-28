using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace CybranAcuProjectileVisualsCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class CacheResource
	{
		public string Path { get; }

		public object Stock { get; }

		public CacheResource(string path, object stock)
		{
			Path = path;
			Stock = stock;
		}
	}

	private sealed class CacheMutation
	{
		public string Path { get; }

		public object? Stock { get; }

		public object Replacement { get; }

		public bool Added { get; }

		public string Description { get; }

		public bool Assigned { get; set; }

		public CacheMutation(string path, object? stock, object replacement, bool added, string description)
		{
			Path = path;
			Stock = stock;
			Replacement = replacement;
			Added = added;
			Description = description;
		}
	}

	internal const string OverrideMarker = "-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.0.0";

	private const string GuardAcuMarker = "-- Guard Cybran ACU Cache Patcher 1.1.0";

	private const string AeonProjectileVisualsMarker = "-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0";

	private const string TargetTemplateRelativePath = "LJ/lua/common/units/unitsTemplates/ugl0000/ugl0000.santp";

	private const string ImportRelativePath = "LJ/lua/common/systems/import.lua";

	private const string ProjectileRootRelativePath = "LJ/lua/common/projectiles/projectilesTemplates";

	private const string SourceProjectileId = "pcd121";

	private const string TargetProjectileId = "pcy001";

	private const string SourceMuzzlePath = "VFX/Muzzle/vcm1203_cannon_plasma_medium_muzzle.sanvfx";

	private const string TargetMuzzlePath = "VFX/CybranAcuProjectiles/Muzzle/vcm1203_cannon_plasma_medium_muzzle.sanvfx";

	private const string SourceImpactPath = "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx";

	private const string TargetImpactPath = "VFX/CybranAcuProjectiles/Impact/vci1301_cannon_plasma_large_impact.sanvfx";

	private const string SourceTrailPath = "VFX/Trails/vct2101_rocket_antitank_small_trail.sanvfx";

	private const string TargetTrailPath = "VFX/CybranAcuProjectiles/Trails/vct2101_rocket_antitank_small_trail.sanvfx";

	private static readonly string TemplateAppendix = BuildTemplateAppendix();

	private static readonly string ImportScannerAppendix = BuildImportScannerAppendix();

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			QueueTemplateAppend(obj, list);
			QueueImportScannerAppend(obj, list);
			QueueVirtualProjectile(obj, list);
			if (list.Count == 0)
			{
				Log("The Cybran ACU red projectile route is already active.");
				return;
			}
			Commit(obj, list);
			Log("Routed the Cybran ACU alone through the red clone of the stock Chosen commander projectile.");
		}
		catch (Exception arg)
		{
			if (obj != null)
			{
				RollBack(obj, list);
			}
			else
			{
				DisposeUncommitted(list);
			}
			Log($"Failed to apply the Cybran ACU red projectile route: {arg}");
			throw;
		}
	}

	private static void QueueTemplateAppend(object cache, List<CacheMutation> mutations)
	{
		CacheResource cachedResource = GetCachedResource(cache, "LJ/lua/common/units/unitsTemplates/ugl0000/ugl0000.santp", "Cybran ACU weapon template");
		string resourceText = GetResourceText(cachedResource.Stock);
		if (ContainsMarker(resourceText))
		{
			ValidateVisualTemplate(resourceText);
			return;
		}
		ValidateSourceTemplate(resourceText);
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), AppendOverride(resourceText, TemplateAppendix));
		try
		{
			ValidateVisualTemplate(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, "Cybran ACU weapon template"));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted Cybran ACU weapon template replacement");
			throw;
		}
	}

	private static void QueueImportScannerAppend(object cache, List<CacheMutation> mutations)
	{
		CacheResource cachedResource = GetCachedResource(cache, "LJ/lua/common/systems/import.lua", "Cybran ACU red virtual-projectile directory scanner");
		string resourceText = GetResourceText(cachedResource.Stock);
		if (ContainsMarker(resourceText))
		{
			string text = UpgradeImportScanner(resourceText);
			if (string.Equals(text, resourceText, StringComparison.Ordinal))
			{
				ValidateImportScanner(resourceText);
				return;
			}
			object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), text);
			try
			{
				ValidateImportScanner(GetResourceText(obj));
				mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, "Cybran ACU red virtual-projectile directory scanner"));
				return;
			}
			catch
			{
				TryDisposeNativeArray(obj.GetType(), obj, "uncommitted Cybran ACU red virtual-projectile directory scanner upgrade");
				throw;
			}
		}
		ValidateSourceImportScanner(resourceText);
		object obj3 = CreateNativeArrayFromText(cachedResource.Stock.GetType(), AppendOverride(resourceText, ImportScannerAppendix));
		try
		{
			ValidateImportScanner(GetResourceText(obj3));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj3, added: false, "Cybran ACU red virtual-projectile directory scanner"));
		}
		catch
		{
			TryDisposeNativeArray(obj3.GetType(), obj3, "uncommitted Cybran ACU red virtual-projectile directory scanner replacement");
			throw;
		}
	}

	private static void QueueVirtualProjectile(object cache, List<CacheMutation> mutations)
	{
		string relativePath = ProjectileRelativePath("pcya01");
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, "Cybran red projectile pcya01 cloned from stock Chosen pcd121");
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (!ContainsMarker(resourceText))
			{
				throw new InvalidOperationException("The reserved Cybran ACU projectile ID pcya01 already exists without the Cybran visual marker.");
			}
			ValidateVirtualProjectile(resourceText);
			return;
		}
		string resourceText2 = GetResourceText(GetCachedResource(cache, ProjectileRelativePath("pcd121"), "stock Chosen commander projectile pcd121").Stock);
		ValidateSourceProjectile(resourceText2);
		string source = BuildVirtualProjectile(resourceText2);
		ValidateVirtualProjectile(source);
		object obj = CreateNativeArrayFromText(GetNativeArrayType(cache), source);
		try
		{
			ValidateVirtualProjectile(GetResourceText(obj));
			mutations.Add(new CacheMutation(ResolvePath(relativePath), null, obj, added: true, "Cybran red projectile pcya01 cloned from stock Chosen pcd121"));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted Cybran red projectile pcya01 cloned from stock Chosen pcd121");
			throw;
		}
	}

	private static void ValidateSourceTemplate(string source)
	{
		RequireTokens(source, "-- Guard Cybran ACU Cache Patcher 1.1.0", "tpId = \"ugl0000\"", "projectileTemplate = \"pgd211\"", "VFX/Muzzle/vgm1121_autocannon_plasma_small_muzzle.sanvfx");
		RequireNotContains(source, "-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0");
	}

	private static void ValidateVisualTemplate(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0", 1, "Cybran ACU red projectile marker");
		RequireTokens(source, "tpId = \"ugl0000\"", "local cybranAcuPrimaryWeapon = UnitTemplate.weapons and UnitTemplate.weapons[1]", "projectileTemplate = \"pcya01\"", "VFX/CybranAcuProjectiles/Muzzle/vcm1203_cannon_plasma_medium_muzzle.sanvfx");
		int num = source.IndexOf("-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0", StringComparison.Ordinal);
		Require(num >= 0, "Cybran ACU visual marker is absent from its template.");
		RequireNotContains(GetOwnedImportScannerAppendix(source), "projectileTemplate = \"pgd211\"", "VFX/Muzzle/vgm1121_autocannon_plasma_small_muzzle.sanvfx");
	}

	private static void ValidateSourceImportScanner(string source)
	{
		RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory", "-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0", "local SCO_AeonProjectileVisualScanDir = ScanDir");
		RequireNotContains(source, "-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0");
	}

	private static void ValidateImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0", 1, "Cybran ACU projectile scanner marker");
		string ownedImportScannerAppendix = GetOwnedImportScannerAppendix(source);
		RequireTokens(ownedImportScannerAppendix, "local SCO_CybranAcuProjectileScanDir = ScanDir", "function ScanDir(directory)", "local folders = SCO_CybranAcuProjectileScanDir(directory)", "common/projectiles/projectilesTemplates/", "directory .. \"pcya01\"");
		RequireExactly(ownedImportScannerAppendix, "function ScanDir(directory)", 1, "Cybran ACU scanner wrapper function");
		RequireExactly(ownedImportScannerAppendix, "local folders = SCO_CybranAcuProjectileScanDir(directory)", 1, "Cybran ACU prior-scanner call-through");
		RequireNotContains(ownedImportScannerAppendix, "scanRoot");
	}

	private static void ValidateSourceProjectile(string source)
	{
		if (ContainsMarker(source))
		{
			throw new InvalidOperationException("Stock Chosen commander projectile pcd121 already carries the Cybran visual marker.");
		}
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"pcd121\"", "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx", "VFX/Trails/vct2101_rocket_antitank_small_trail.sanvfx");
	}

	private static void ValidateVirtualProjectile(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0", 1, "Cybran red virtual projectile marker");
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"pcya01\"", "VFX/CybranAcuProjectiles/Impact/vci1301_cannon_plasma_large_impact.sanvfx", "VFX/CybranAcuProjectiles/Trails/vct2101_rocket_antitank_small_trail.sanvfx");
		RequireNotContains(source, "tpId = \"pcd121\"", "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx", "VFX/Trails/vct2101_rocket_antitank_small_trail.sanvfx");
	}

	private static string BuildVirtualProjectile(string source)
	{
		return AppendOverride(ReplaceExactlyOnce(ReplaceExactlyOnce(ReplaceExactlyOnce(source, "tpId = \"pcd121\"", "tpId = \"pcya01\"", "projectile ID for pcd121"), "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx", "VFX/CybranAcuProjectiles/Impact/vci1301_cannon_plasma_large_impact.sanvfx", "impact VFX for pcd121"), "VFX/Trails/vct2101_rocket_antitank_small_trail.sanvfx", "VFX/CybranAcuProjectiles/Trails/vct2101_rocket_antitank_small_trail.sanvfx", "trail VFX for pcd121"), "\n-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0\n");
	}

	private static string BuildTemplateAppendix()
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0");
		stringBuilder.AppendLine("-- Keep the native Cybran gun contract intact while changing only its private visual route.");
		stringBuilder.AppendLine("local cybranAcuPrimaryWeapon = UnitTemplate.weapons and UnitTemplate.weapons[1]");
		stringBuilder.AppendLine("if not cybranAcuPrimaryWeapon then");
		stringBuilder.AppendLine("    error(\"UGL0000 Cybran red projectile override requires the primary weapon\")");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine("cybranAcuPrimaryWeapon.effects = cybranAcuPrimaryWeapon.effects or {}");
		stringBuilder.AppendLine("cybranAcuPrimaryWeapon.effects.onFire = \"VFX/CybranAcuProjectiles/Muzzle/vcm1203_cannon_plasma_medium_muzzle.sanvfx\"");
		stringBuilder.AppendLine("cybranAcuPrimaryWeapon.projectileTemplate = \"pcya01\"");
		return stringBuilder.ToString();
	}

	private static string BuildImportScannerAppendix()
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0");
		stringBuilder.AppendLine("-- Chain the completed visual scanner and expose the one cache-owned Cybran ACU projectile.");
		stringBuilder.AppendLine("local SCO_CybranAcuProjectileScanDir = ScanDir");
		stringBuilder.AppendLine("function ScanDir(directory)");
		stringBuilder.AppendLine("    local folders = SCO_CybranAcuProjectileScanDir(directory)");
		stringBuilder.AppendLine("    if directory ~= \"common/projectiles/projectilesTemplates/\" then");
		stringBuilder.AppendLine("        return folders");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("    local cybranAcuProjectileFolder = directory .. \"pcya01\"");
		stringBuilder.AppendLine("    for _, folder in ipairs(folders) do");
		stringBuilder.AppendLine("        if folder == cybranAcuProjectileFolder then");
		stringBuilder.AppendLine("            return folders");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    table.insert(folders, cybranAcuProjectileFolder)");
		stringBuilder.AppendLine("    return folders");
		stringBuilder.AppendLine("end");
		return stringBuilder.ToString();
	}

	private static string UpgradeImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0", 1, "Cybran ACU projectile scanner marker");
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0", StringComparison.Ordinal);
		string ownedImportScannerAppendix = GetOwnedImportScannerAppendix(source);
		string text = UpgradeScanDirWrapper(ownedImportScannerAppendix, "SCO_CybranAcuProjectileScanDir");
		if (!string.Equals(ownedImportScannerAppendix, text, StringComparison.Ordinal))
		{
			return source.Substring(0, num) + text + source.Substring(num + ownedImportScannerAppendix.Length);
		}
		return source;
	}

	private static string GetOwnedImportScannerAppendix(string source)
	{
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Cybran ACU projectile scanner marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0".Length, StringComparison.Ordinal);
		if (num2 >= 0)
		{
			return source.Substring(num, num2 - num);
		}
		return source.Substring(num);
	}

	private static string UpgradeScanDirWrapper(string appendix, string priorScanner)
	{
		if (appendix.IndexOf("scanRoot", StringComparison.Ordinal) < 0)
		{
			return appendix;
		}
		string newValue = "local folders = " + priorScanner + "(directory)";
		string text = ((appendix.IndexOf("function ScanDir(scanRoot, directory)", StringComparison.Ordinal) >= 0) ? "function ScanDir(scanRoot, directory)" : "function ScanDir(scanRoot,directory)");
		string text2 = ((appendix.IndexOf("local folders = " + priorScanner + "(scanRoot, directory)", StringComparison.Ordinal) >= 0) ? ("local folders = " + priorScanner + "(scanRoot, directory)") : ("local folders = " + priorScanner + "(scanRoot,directory)"));
		RequireExactly(appendix, text, 1, "legacy Cybran ACU scanner wrapper function");
		RequireExactly(appendix, text2, 1, "legacy Cybran ACU prior-scanner call-through");
		return appendix.Replace(text, "function ScanDir(directory)").Replace(text2, newValue);
	}

	private static string ReplaceExactlyOnce(string source, string oldValue, string newValue, string description)
	{
		int num = source.IndexOf(oldValue, StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Expected " + description + " to contain '" + oldValue + "'.");
		}
		if (source.IndexOf(oldValue, num + oldValue.Length, StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("Expected exactly one " + description + " token '" + oldValue + "'.");
		}
		return source.Substring(0, num) + newValue + source.Substring(num + oldValue.Length);
	}

	private static void Commit(object cache, IReadOnlyList<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			mutation.Assigned = true;
			SetCachedResource(cache, mutation.Path, mutation.Replacement);
		}
		foreach (CacheMutation mutation2 in mutations)
		{
			if (mutation2.Stock != null)
			{
				TryDisposeNativeArray(mutation2.Stock.GetType(), mutation2.Stock, "stock " + mutation2.Description);
			}
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
					if (item.Added)
					{
						RemoveCachedResource(cache, item.Path);
					}
					else
					{
						SetCachedResource(cache, item.Path, item.Stock ?? throw new InvalidOperationException(item.Description + " has no stock cache resource."));
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
				TryDisposeNativeArray(item.Replacement.GetType(), item.Replacement, "replacement " + item.Description);
			}
		}
	}

	private static void DisposeUncommitted(IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			TryDisposeNativeArray(mutation.Replacement.GetType(), mutation.Replacement, "uncommitted " + mutation.Description);
		}
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CacheResource GetCachedResource(object cache, string relativePath, string description)
	{
		return TryGetCachedResource(cache, relativePath, description) ?? throw new FileNotFoundException("The required " + description + " was not present in Sanctuary's Lua file cache.", relativePath);
	}

	private static CacheResource? TryGetCachedResource(object cache, string relativePath, string description)
	{
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string text = ResolvePath(relativePath);
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
			object obj3 = propertyInfo.GetValue(cache, new object[1] { text }) ?? throw new InvalidOperationException("The cached " + description + " has no value.");
			EnsureNativeArray(obj3, description);
			return new CacheResource(text, obj3);
		}
		string value = "/" + relativePath.Replace('\\', '/');
		CacheResource cacheResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text2 && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cacheResource != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + relativePath + ".");
				}
				object obj4 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("The cached " + description + " has no value.");
				EnsureNativeArray(obj4, description);
				cacheResource = new CacheResource(text2, obj4);
			}
		}
		return cacheResource;
	}

	private static Type GetNativeArrayType(object cache)
	{
		foreach (object item in (IEnumerable)cache)
		{
			object obj = item.GetType().GetProperty("Value")?.GetValue(item);
			if (obj != null)
			{
				EnsureNativeArray(obj, "Lua cache resource");
				return obj.GetType();
			}
		}
		throw new InvalidOperationException("Sanctuary's Lua file cache contains no NativeArray resource type.");
	}

	private static string ResolvePath(string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, Encoding.UTF8.GetBytes(source));
	}

	private static string GetResourceText(object resource)
	{
		EnsureNativeArray(resource, "Lua cache resource");
		Type type = resource.GetType();
		byte[] bytes = (byte[])((type.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, "ToArray")).Invoke(resource, null) ?? throw new InvalidOperationException(type.FullName + ".ToArray returned null."));
		return Encoding.UTF8.GetString(bytes);
	}

	private static void EnsureNativeArray(object value, string description)
	{
		object value2 = (value.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(value.GetType().FullName, "IsCreated")).GetValue(value);
		if (!(value2 is bool) || !(bool)value2)
		{
			throw new InvalidOperationException("The cached " + description + " is not an initialized NativeArray.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void RemoveCachedResource(object cache, string path)
	{
		(cache.GetType().GetMethod("Remove", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "Remove")).Invoke(cache, new object[1] { path });
	}

	private static void TryDisposeNativeArray(Type nativeArrayType, object nativeArray, string description)
	{
		try
		{
			object value = (nativeArrayType.GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(nativeArrayType.FullName, "IsCreated")).GetValue(nativeArray);
			if (value is bool && (bool)value)
			{
				(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
			}
		}
		catch (Exception arg)
		{
			Log($"Could not dispose {description}: {arg}");
		}
	}

	private static string AppendOverride(string source, string appendix)
	{
		if (!source.EndsWith("\n", StringComparison.Ordinal))
		{
			return source + "\n" + appendix;
		}
		return source + appendix;
	}

	private static string ProjectileRelativePath(string projectileId)
	{
		return "LJ/lua/common/projectiles/projectilesTemplates/" + projectileId + "/" + projectileId + ".santp";
	}

	private static bool ContainsMarker(string source)
	{
		return source.IndexOf("-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0", StringComparison.Ordinal) >= 0;
	}

	private static void Require(bool condition, string message)
	{
		if (!condition)
		{
			throw new InvalidOperationException(message);
		}
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
				throw new InvalidOperationException("The Cybran ACU projectile override must not retain '" + text + "'.");
			}
		}
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = 0;
		int startIndex = 0;
		while (true)
		{
			int num2 = source.IndexOf(token, startIndex, StringComparison.Ordinal);
			if (num2 < 0)
			{
				break;
			}
			num++;
			startIndex = num2 + token.Length;
		}
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {description}, found {num}.");
		}
	}

	private static void Log(string message)
	{
		string text = "[Cybran ACU Projectile Visuals Cache Patcher] " + message;
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
