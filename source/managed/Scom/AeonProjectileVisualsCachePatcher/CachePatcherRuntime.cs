using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using SupremeCommanderOverhaul.Shared;

namespace AeonProjectileVisualsCachePatcher;

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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0";

	private const string ImportRelativePath = "LJ/lua/common/systems/import.lua";

	private const string ProjectileRootRelativePath = "LJ/lua/common/projectiles/projectilesTemplates";

	private const string AeonAcuMarker = "-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0";

	private const string StockProjectileColor = "color = {\n        x = 1,\n        y = 1,\n        z = 1,\n    }";

	private const string MintProjectileColor = "color = {\n        x = 0.5372549,\n        y = 0.972549,\n        z = 0.892659247,\n    }";

	private static readonly string TemplateAppendix = BuildTemplateAppendix();

	private static readonly string ImportScannerAppendix = BuildImportScannerAppendix();

	private static readonly Regex ProjectileTemplatePattern = new Regex("projectileTemplate\\s*=\\s*\\\"(?<id>[^\\\"]+)\\\"", RegexOptions.Compiled | RegexOptions.CultureInvariant);

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			string[] weaponTemplateIds = AeonProjectileVisualRules.WeaponTemplateIds;
			foreach (string templateId in weaponTemplateIds)
			{
				QueueTemplateAppend(obj, list, templateId);
			}
			QueueImportScannerAppend(obj, list);
			ProjectileRule[] projectileRules = AeonProjectileVisualRules.ProjectileRules;
			foreach (ProjectileRule rule in projectileRules)
			{
				QueueVirtualProjectile(obj, list, rule);
			}
			if (list.Count == 0)
			{
				Log("The cached Aeon mint projectile visual split is already active.");
				return;
			}
			Commit(obj, list);
			Log($"Routed {AeonProjectileVisualRules.WeaponTemplateIds.Length} Aeon weapon templates " + $"through {AeonProjectileVisualRules.ProjectileRules.Length} isolated mint projectile copies.");
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
			Log($"Failed to apply the Aeon mint projectile visual split: {arg}");
			throw;
		}
	}

	private static void QueueTemplateAppend(object cache, List<CacheMutation> mutations, string templateId)
	{
		string relativePath = "LJ/lua/common/units/unitsTemplates/" + templateId + "/" + templateId + ".santp";
		string text = "Aeon weapon template " + templateId;
		CacheResource cachedResource = GetCachedResource(cache, relativePath, text);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (ContainsMarker(resourceText))
		{
			ValidateVisualTemplate(resourceText, templateId);
			return;
		}
		ValidateSourceTemplate(resourceText, templateId);
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), AppendOverride(resourceText, TemplateAppendix));
		try
		{
			ValidateVisualTemplate(GetResourceText(obj), templateId);
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, text));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + text + " replacement");
			throw;
		}
	}

	private static void QueueImportScannerAppend(object cache, List<CacheMutation> mutations)
	{
		CacheResource cachedResource = GetCachedResource(cache, "LJ/lua/common/systems/import.lua", "Aeon mint virtual-projectile directory scanner");
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
				mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, "Aeon mint virtual-projectile directory scanner"));
				return;
			}
			catch
			{
				TryDisposeNativeArray(obj.GetType(), obj, "uncommitted Aeon mint virtual-projectile directory scanner upgrade");
				throw;
			}
		}
		ValidateSourceImportScanner(resourceText);
		object obj3 = CreateNativeArrayFromText(cachedResource.Stock.GetType(), AppendOverride(resourceText, ImportScannerAppendix));
		try
		{
			ValidateImportScanner(GetResourceText(obj3));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj3, added: false, "Aeon mint virtual-projectile directory scanner"));
		}
		catch
		{
			TryDisposeNativeArray(obj3.GetType(), obj3, "uncommitted Aeon mint virtual-projectile directory scanner replacement");
			throw;
		}
	}

	private static void QueueVirtualProjectile(object cache, List<CacheMutation> mutations, ProjectileRule rule)
	{
		string relativePath = ProjectileRelativePath(rule.TargetId);
		string text = "Aeon mint projectile " + rule.TargetId + " cloned from " + rule.SourceId;
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, text);
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (!ContainsMarker(resourceText))
			{
				throw new InvalidOperationException("The reserved Aeon projectile ID " + rule.TargetId + " already exists without the Aeon visual marker.");
			}
			ValidateVirtualProjectile(resourceText, rule);
			return;
		}
		string resourceText2 = GetResourceText(GetCachedResource(cache, ProjectileRelativePath(rule.SourceId), "stock Chosen projectile " + rule.SourceId).Stock);
		ValidateSourceProjectile(resourceText2, rule);
		string source = BuildVirtualProjectile(resourceText2, rule);
		ValidateVirtualProjectile(source, rule);
		object obj = CreateNativeArrayFromText(GetNativeArrayType(cache), source);
		try
		{
			ValidateVirtualProjectile(GetResourceText(obj), rule);
			mutations.Add(new CacheMutation(ResolvePath(relativePath), null, obj, added: true, text));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + text);
			throw;
		}
	}

	private static void ValidateSourceTemplate(string source, string templateId)
	{
		RequireTokens(source, "UnitTemplate =", "tpId = \"" + templateId + "\"");
		if (string.Equals(templateId, "ucl0000", StringComparison.Ordinal))
		{
			RequireTokens(source, "-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0", "projectileTemplate = \"pcl001\"", "VFX/AeonProjectiles/Muzzle/vcm1203_aeon_acu_clean_muzzle.sanvfx", "VFX/AeonProjectiles/Death/vcd0301_death_rdu.sanvfx");
			return;
		}
		string[] array = (from Match match in ProjectileTemplatePattern.Matches(source)
			select match.Groups["id"].Value).Distinct(StringComparer.Ordinal).ToArray();
		if (array.Length == 0)
		{
			throw new InvalidOperationException("The expected Chosen combat projectile route was absent from " + templateId + "; refusing a partial Aeon visual split.");
		}
		string[] array2 = array;
		foreach (string text in array2)
		{
			if (!AeonProjectileVisualRules.ProjectileMap.ContainsKey(text))
			{
				throw new InvalidOperationException("Aeon weapon template " + templateId + " references unmapped projectile " + text + "; refusing to leave a shared Chosen visual route behind.");
			}
		}
	}

	private static void ValidateVisualTemplate(string source, string templateId)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0", 1, "Aeon mint marker on " + templateId);
		RequireTokens(source, "tpId = \"" + templateId + "\"", "local SCO_AeonProjectileMap = {", "local SCO_AeonMuzzleVfxMap = {", "local SCO_AeonBeamMaterialMap = {", "for _, weapon in pairs(UnitTemplate.weapons or {}) do");
		foreach (KeyValuePair<string, string> item in AeonProjectileVisualRules.ProjectileMap)
		{
			RequireTokens(source, "[\"" + item.Key + "\"] = \"" + item.Value + "\"");
		}
	}

	private static void ValidateSourceImportScanner(string source)
	{
		RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory", "-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0", "directory .. \"pcl001\"");
	}

	private static void ValidateImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0", 1, "Aeon mint projectile scanner marker");
		string ownedImportScannerAppendix = GetOwnedImportScannerAppendix(source);
		RequireTokens(ownedImportScannerAppendix, "local SCO_AeonProjectileVisualScanDir = ScanDir", "function ScanDir(directory)", "local folders = SCO_AeonProjectileVisualScanDir(directory)", "common/projectiles/projectilesTemplates/");
		RequireExactly(ownedImportScannerAppendix, "function ScanDir(directory)", 1, "Aeon mint scanner wrapper function");
		RequireExactly(ownedImportScannerAppendix, "local folders = SCO_AeonProjectileVisualScanDir(directory)", 1, "Aeon mint prior-scanner call-through");
		RequireNotContains(ownedImportScannerAppendix, "scanRoot");
		ProjectileRule[] projectileRules = AeonProjectileVisualRules.ProjectileRules;
		foreach (ProjectileRule projectileRule in projectileRules)
		{
			RequireTokens(ownedImportScannerAppendix, "directory .. \"" + projectileRule.TargetId + "\"");
		}
	}

	private static void ValidateSourceProjectile(string source, ProjectileRule rule)
	{
		if (ContainsMarker(source))
		{
			throw new InvalidOperationException("Stock Chosen projectile " + rule.SourceId + " already carries the Aeon mint visual marker.");
		}
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"" + rule.SourceId + "\"");
	}

	private static void ValidateVirtualProjectile(string source, ProjectileRule rule)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0", 1, "Aeon virtual projectile marker for " + rule.TargetId);
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"" + rule.TargetId + "\"");
		RequireNotContains(source, "tpId = \"" + rule.SourceId + "\"");
		foreach (string key in AeonProjectileVisualRules.VisualEffectMap.Keys)
		{
			RequireNotContains(source, key);
		}
		if (string.Equals(rule.SourceId, "pxd002", StringComparison.Ordinal) || string.Equals(rule.SourceId, "pxd004", StringComparison.Ordinal))
		{
			RequireTokens(source, "color = {", "x = 0.5372549", "y = 0.972549", "z = 0.892659247");
			RequireNotContains(source, "color = {\n        x = 1,\n        y = 1,\n        z = 1,\n    }", "color = {\n        x = 1,\n        y = 1,\n        z = 1,\n    }".Replace("\n", "\r\n"));
		}
	}

	private static string BuildVirtualProjectile(string source, ProjectileRule rule)
	{
		string source2 = ReplaceExactlyOnce(source, "tpId = \"" + rule.SourceId + "\"", "tpId = \"" + rule.TargetId + "\"", "projectile ID for " + rule.SourceId);
		foreach (KeyValuePair<string, string> item in AeonProjectileVisualRules.VisualEffectMap)
		{
			source2 = ReplaceOrdinal(source2, item.Key, item.Value);
		}
		if (string.Equals(rule.SourceId, "pxd002", StringComparison.Ordinal) || string.Equals(rule.SourceId, "pxd004", StringComparison.Ordinal))
		{
			source2 = ReplaceProjectileColor(source2, rule.SourceId);
		}
		return AppendOverride(source2, "\n-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0\n");
	}

	private static string BuildTemplateAppendix()
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0");
		stringBuilder.AppendLine("-- The Aeon faction is the renamed Chosen roster.  Keep its projectile physics");
		stringBuilder.AppendLine("-- untouched while selecting only cache-owned mint visual resources.");
		AppendLuaMap(stringBuilder, "SCO_AeonProjectileMap", AeonProjectileVisualRules.ProjectileMap);
		AppendLuaMap(stringBuilder, "SCO_AeonMuzzleVfxMap", AeonProjectileVisualRules.MuzzleVisualEffectMap);
		AppendLuaMap(stringBuilder, "SCO_AeonBeamMaterialMap", AeonProjectileVisualRules.BeamMaterialMap);
		stringBuilder.AppendLine("for _, weapon in pairs(UnitTemplate.weapons or {}) do");
		stringBuilder.AppendLine("    local sourceProjectile = weapon.projectileTemplate");
		stringBuilder.AppendLine("    if sourceProjectile and SCO_AeonProjectileMap[sourceProjectile] then");
		stringBuilder.AppendLine("        weapon.projectileTemplate = SCO_AeonProjectileMap[sourceProjectile]");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if weapon.effects and weapon.effects.onFire and SCO_AeonMuzzleVfxMap[weapon.effects.onFire] then");
		stringBuilder.AppendLine("        weapon.effects.onFire = SCO_AeonMuzzleVfxMap[weapon.effects.onFire]");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    -- pcd171/pad171's available visible beam is the weapon sub-mesh route. Its");
		stringBuilder.AppendLine("    -- stock projectile beam graph references missing base material paths,");
		stringBuilder.AppendLine("    -- so this retints the real compatible path without inventing physics.");
		stringBuilder.AppendLine("    if SCO_AeonProjectileMap[sourceProjectile] == \"pad171\" and weapon.beam and weapon.beam.subMesh then");
		stringBuilder.AppendLine("        for _, subMesh in pairs(weapon.beam.subMesh) do");
		stringBuilder.AppendLine("            if subMesh.material and SCO_AeonBeamMaterialMap[subMesh.material] then");
		stringBuilder.AppendLine("                subMesh.material = SCO_AeonBeamMaterialMap[subMesh.material]");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("end");
		return stringBuilder.ToString();
	}

	private static string BuildImportScannerAppendix()
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0");
		stringBuilder.AppendLine("-- Chain every prior scanner and add the exact cache-owned Aeon projectile folders.");
		stringBuilder.AppendLine("local SCO_AeonProjectileVisualScanDir = ScanDir");
		stringBuilder.AppendLine("function ScanDir(directory)");
		stringBuilder.AppendLine("    local folders = SCO_AeonProjectileVisualScanDir(directory)");
		stringBuilder.AppendLine("    if directory ~= \"common/projectiles/projectilesTemplates/\" then");
		stringBuilder.AppendLine("        return folders");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("    local aeonProjectileFolders = {");
		ProjectileRule[] projectileRules = AeonProjectileVisualRules.ProjectileRules;
		foreach (ProjectileRule projectileRule in projectileRules)
		{
			stringBuilder.AppendLine("        directory .. \"" + projectileRule.TargetId + "\",");
		}
		stringBuilder.AppendLine("    }");
		stringBuilder.AppendLine("    for _, aeonProjectileFolder in ipairs(aeonProjectileFolders) do");
		stringBuilder.AppendLine("        local found = false");
		stringBuilder.AppendLine("        for _, folder in ipairs(folders) do");
		stringBuilder.AppendLine("            if folder == aeonProjectileFolder then");
		stringBuilder.AppendLine("                found = true");
		stringBuilder.AppendLine("                break");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        if not found then");
		stringBuilder.AppendLine("            table.insert(folders, aeonProjectileFolder)");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    return folders");
		stringBuilder.AppendLine("end");
		return stringBuilder.ToString();
	}

	private static string UpgradeImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0", 1, "Aeon mint projectile scanner marker");
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0", StringComparison.Ordinal);
		string ownedImportScannerAppendix = GetOwnedImportScannerAppendix(source);
		string text = UpgradeScanDirWrapper(ownedImportScannerAppendix, "SCO_AeonProjectileVisualScanDir");
		if (!string.Equals(ownedImportScannerAppendix, text, StringComparison.Ordinal))
		{
			return source.Substring(0, num) + text + source.Substring(num + ownedImportScannerAppendix.Length);
		}
		return source;
	}

	private static string GetOwnedImportScannerAppendix(string source)
	{
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Aeon mint projectile scanner marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0".Length, StringComparison.Ordinal);
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
		RequireExactly(appendix, text, 1, "legacy Aeon mint scanner wrapper function");
		RequireExactly(appendix, text2, 1, "legacy Aeon mint prior-scanner call-through");
		return appendix.Replace(text, "function ScanDir(directory)").Replace(text2, newValue);
	}

	private static void AppendLuaMap(StringBuilder source, string variableName, IReadOnlyDictionary<string, string> mapping)
	{
		source.AppendLine("local " + variableName + " = {");
		foreach (KeyValuePair<string, string> item in mapping.OrderBy<KeyValuePair<string, string>, string>((KeyValuePair<string, string> pair) => pair.Key, StringComparer.Ordinal))
		{
			source.AppendLine("    [\"" + item.Key + "\"] = \"" + item.Value + "\",");
		}
		source.AppendLine("}");
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

	private static string ReplaceOrdinal(string source, string oldValue, string newValue)
	{
		int num = source.IndexOf(oldValue, StringComparison.Ordinal);
		if (num < 0)
		{
			return source;
		}
		StringBuilder stringBuilder = new StringBuilder(source.Length + Math.Max(0, newValue.Length - oldValue.Length));
		int num2 = 0;
		while (num >= 0)
		{
			stringBuilder.Append(source, num2, num - num2);
			stringBuilder.Append(newValue);
			num2 = num + oldValue.Length;
			num = source.IndexOf(oldValue, num2, StringComparison.Ordinal);
		}
		stringBuilder.Append(source, num2, source.Length - num2);
		return stringBuilder.ToString();
	}

	private static string ReplaceProjectileColor(string source, string projectileId)
	{
		if (source.IndexOf("color = {\n        x = 1,\n        y = 1,\n        z = 1,\n    }", StringComparison.Ordinal) >= 0)
		{
			return ReplaceExactlyOnce(source, "color = {\n        x = 1,\n        y = 1,\n        z = 1,\n    }", "color = {\n        x = 0.5372549,\n        y = 0.972549,\n        z = 0.892659247,\n    }", "explicit projectile color for " + projectileId);
		}
		string oldValue = "color = {\n        x = 1,\n        y = 1,\n        z = 1,\n    }".Replace("\n", "\r\n");
		string newValue = "color = {\n        x = 0.5372549,\n        y = 0.972549,\n        z = 0.892659247,\n    }".Replace("\n", "\r\n");
		return ReplaceExactlyOnce(source, oldValue, newValue, "explicit projectile color for " + projectileId);
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
		return source.IndexOf("-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0", StringComparison.Ordinal) >= 0;
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
				throw new InvalidOperationException("The Aeon projectile visual override must not retain '" + text + "'.");
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
		string text = "[Aeon Projectile Visuals Cache Patcher] " + message;
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
