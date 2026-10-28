using System;
using System.Collections.Generic;
using System.Linq;

namespace AeonProjectileVisualsCachePatcher;

internal static class AeonProjectileVisualRules
{
	internal static readonly ProjectileRule[] ProjectileRules = new ProjectileRule[16]
	{
		new ProjectileRule("pca111", "paa111"),
		new ProjectileRule("pca211", "paa211"),
		new ProjectileRule("pca311", "paa311"),
		new ProjectileRule("pca341", "paa341"),
		new ProjectileRule("pcd111", "pad111"),
		new ProjectileRule("pcd131", "pad131"),
		new ProjectileRule("pcd171", "pad171"),
		new ProjectileRule("pcd311", "pad311"),
		new ProjectileRule("pcd312", "pad312"),
		new ProjectileRule("pcd411", "pad411"),
		new ProjectileRule("pcd412", "pad412"),
		new ProjectileRule("pci111", "pai111"),
		new ProjectileRule("pci211", "pai211"),
		new ProjectileRule("pci311", "pai311"),
		new ProjectileRule("pxd002", "pad002"),
		new ProjectileRule("pxd004", "pad004")
	};

	internal static readonly string[] GeneratedProjectileIds = new string[14]
	{
		"paa111", "paa211", "paa311", "paa341", "pad002", "pad004", "pad111", "pad131", "pad171", "pad311",
		"pad411", "pai111", "pai211", "pai311"
	};

	internal static readonly string[] WeaponTemplateIds = new string[32]
	{
		"uca1001", "uca1201", "uca2011", "uca3001", "uca3011", "uca3201", "uca4011", "ucl0000", "ucl1001", "ucl1002",
		"ucl1101", "ucl1201", "ucl2002", "ucl2201", "ucl3001", "ucl3101", "ucl3801", "ucl4001", "ucl4002", "ucl4003",
		"ucl4004", "ucl4005", "ucn1001", "ucn3001", "ucs1001", "ucs1201", "ucs2001", "ucs2101", "ucs2201", "ucs3001",
		"ucs3101", "ucs3201"
	};

	internal static readonly string[] VisualEffectPaths = new string[48]
	{
		"VFX/Death/vcd0301_death_rdu.sanvfx", "VFX/Impact/vci1101_cannon_plasma_small_impact.sanvfx", "VFX/Impact/vci1141_cannon_artillery_small_impact.sanvfx", "VFX/Impact/vci1201_cannon_plasma_medium_impact.sanvfx", "VFX/Impact/vci1241_cannon_artillery_medium_impact.sanvfx", "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx", "VFX/Impact/vci1341_cannon_artillery_large_impact.sanvfx", "VFX/Impact/vci1361_cannon_sniper_large_impact.sanvfx", "VFX/Impact/vci1441_cannon_artillery_huge_impact.sanvfx", "VFX/Impact/vci3121_cannon_antiair_small_impact.sanvfx",
		"VFX/Impact/vci3221_cannon_antiair_medium_impact.sanvfx", "VFX/Impact/vci3301_missile_antiair_large_impact.sanvfx", "VFX/Impact/vci4301_cannon_air_large_impact.sanvfx", "VFX/Impact/vci4401_cannon_air_huge_impact.sanvfx", "VFX/Impact/vci7101_antitank_small_impact.sanvfx", "VFX/Muzzle/vcm1101_cannon_plasma_small_muzzle.sanvfx", "VFX/Muzzle/vcm1141_cannon_artillery_small_muzzle.sanvfx", "VFX/Muzzle/vcm1201_cannon_plasma_medium_muzzle.sanvfx", "VFX/Muzzle/vcm1202_cannon_plasma_medium_muzzle.sanvfx", "VFX/Muzzle/vcm1203_cannon_plasma_medium_muzzle.sanvfx",
		"VFX/Muzzle/vcm1241_cannon_artillery_medium_muzzle.sanvfx", "VFX/Muzzle/vcm1242_cannon_artillery_medium_muzzle.sanvfx", "VFX/Muzzle/vcm1301_cannon_plasma_large_muzzle.sanvfx", "VFX/Muzzle/vcm1302_cannon_plasma_large_muzzle.sanvfx", "VFX/Muzzle/vcm1303_cannon_plasma_large_muzzle.sanvfx", "VFX/Muzzle/vcm1341_cannon_artillery_large_muzzle.sanvfx", "VFX/Muzzle/vcm1361_cannon_sniper_large_muzzle.sanvfx", "VFX/Muzzle/vcm1401_cannon_plasma_huge_muzzle.sanvfx", "VFX/Muzzle/vcm3121_cannon_antiair_small_muzzle.sanvfx", "VFX/Muzzle/vcm3221_cannon_antiair_medium_muzzle.sanvfx",
		"VFX/Muzzle/vcm3301_missile_antiair_large_muzzle.sanvfx", "VFX/Muzzle/vcm4101_cannon_air_small_muzzle.sanvfx", "VFX/Muzzle/vcm4301_cannon_air_large_muzzle.sanvfx", "VFX/Muzzle/vcm4401_cannon_air_huge_muzzle.sanvfx", "VFX/Muzzle/vcm7101_beam_antitank_small_muzzle.sanvfx", "VFX/Trails/vct1101_cannon_plasma_small_trail.sanvfx", "VFX/Trails/vct1141_cannon_artillery_small_trail.sanvfx", "VFX/Trails/vct1201_cannon_plasma_medium_trail.sanvfx", "VFX/Trails/vct1241_cannon_artillery_medium_trail.sanvfx", "VFX/Trails/vct1301_cannon_plasma_large_trail.sanvfx",
		"VFX/Trails/vct1341_cannon_artillery_large_trail.sanvfx", "VFX/Trails/vct1361_cannon_sniper_large_trail.sanvfx", "VFX/Trails/vct2101_rocket_antitank_small_trail.sanvfx", "VFX/Trails/vct3121_cannon_antiair_small_trail.sanvfx", "VFX/Trails/vct3221_cannon_antiair_medium_trail.sanvfx", "VFX/Trails/vct3301_missile_antiair_large_trail.sanvfx", "VFX/Trails/vct4301_cannon_air_large_trail.sanvfx", "VFX/Trails/vct4401_cannon_air_huge_trail.sanvfx"
	};

	internal static readonly string[] BeamMaterialPaths = new string[2] { "VFX/Materials/Beam/Beam ucs1001_01.sanmaterial", "VFX/Materials/Beam/Beam ucs1001_02.sanmaterial" };

	internal static readonly IReadOnlyDictionary<string, string> ProjectileMap = BuildProjectileMap();

	internal static readonly IReadOnlyDictionary<string, string> VisualEffectMap = BuildMappedPaths(VisualEffectPaths);

	internal static readonly IReadOnlyDictionary<string, string> MuzzleVisualEffectMap = BuildMappedPaths(VisualEffectPaths.Where((string path) => path.StartsWith("VFX/Muzzle/", StringComparison.Ordinal)));

	internal static readonly IReadOnlyDictionary<string, string> BeamMaterialMap = BuildMappedPaths(BeamMaterialPaths);

	internal static string AeonAssetPath(string sourcePath)
	{
		if (!sourcePath.StartsWith("VFX/", StringComparison.Ordinal))
		{
			throw new ArgumentOutOfRangeException("sourcePath", sourcePath, "Expected a VFX resource path.");
		}
		return "VFX/AeonProjectiles/" + sourcePath.Substring("VFX/".Length);
	}

	private static IReadOnlyDictionary<string, string> BuildProjectileMap()
	{
		Dictionary<string, string> dictionary = new Dictionary<string, string>(StringComparer.Ordinal);
		HashSet<string> hashSet = new HashSet<string>(StringComparer.Ordinal);
		ProjectileRule[] projectileRules = ProjectileRules;
		foreach (ProjectileRule projectileRule in projectileRules)
		{
			if (dictionary.ContainsKey(projectileRule.SourceId))
			{
				throw new InvalidOperationException("Duplicate Aeon projectile source ID '" + projectileRule.SourceId + "'.");
			}
			if (!hashSet.Add(projectileRule.TargetId))
			{
				throw new InvalidOperationException("Duplicate Aeon projectile target ID '" + projectileRule.TargetId + "'.");
			}
			dictionary.Add(projectileRule.SourceId, projectileRule.TargetId);
		}
		string text = null;
		string[] generatedProjectileIds = GeneratedProjectileIds;
		foreach (string text2 in generatedProjectileIds)
		{
			if (text != null && StringComparer.Ordinal.Compare(text, text2) >= 0)
			{
				throw new InvalidOperationException("Generated Aeon projectile IDs must be unique and ordinally sorted.");
			}
			if (!hashSet.Contains(text2))
			{
				throw new InvalidOperationException("Generated Aeon projectile '" + text2 + "' has no isolated clone rule.");
			}
			if (dictionary.TryGetValue(text2, out var value))
			{
				if (!string.Equals(value, text2, StringComparison.Ordinal))
				{
					throw new InvalidOperationException("Generated Aeon projectile '" + text2 + "' conflicts with source route '" + value + "'.");
				}
			}
			else
			{
				dictionary.Add(text2, text2);
			}
			text = text2;
		}
		return dictionary;
	}

	private static IReadOnlyDictionary<string, string> BuildMappedPaths(IEnumerable<string> paths)
	{
		Dictionary<string, string> dictionary = new Dictionary<string, string>(StringComparer.Ordinal);
		foreach (string path in paths)
		{
			if (dictionary.ContainsKey(path))
			{
				throw new InvalidOperationException("Duplicate Aeon projectile visual path '" + path + "'.");
			}
			dictionary.Add(path, AeonAssetPath(path));
		}
		return dictionary;
	}
}
