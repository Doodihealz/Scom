using System;
using System.Collections.Generic;
using System.Linq;

namespace SupremeCommanderOverhaulBuildBoxParity;

public static class BuildBoxManifest
{
	public const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	public static readonly BuildBoxSpec[] Specs;

	public static IReadOnlyList<string> ManagedPaths => Specs.Select((BuildBoxSpec spec) => spec.RelativePath).ToArray();

	static BuildBoxManifest()
	{
		Specs = new BuildBoxSpec[137]
		{
			new BuildBoxSpec("ugs1611", "URB1101", 2, 2),
			new BuildBoxSpec("ugs2611", "URB1201", 6, 6),
			new BuildBoxSpec("ugs3611", "URB1301", 8, 8),
			new BuildBoxSpec("ugs1511", "URB0101", 8, 8),
			new BuildBoxSpec("ugs2511", "URB0201", 8, 8),
			new BuildBoxSpec("ugs3511", "URB0301", 8, 8),
			new BuildBoxSpec("ues1511", "UEB0101", 8, 8),
			new BuildBoxSpec("ues2511", "UEB0201", 8, 8),
			new BuildBoxSpec("ues3511", "UEB0301", 8, 8),
			new BuildBoxSpec("ues1611", "UEB1101", 2, 2),
			new BuildBoxSpec("ues2611", "UEB1201", 6, 6),
			new BuildBoxSpec("ues3611", "UEB1301", 8, 8),
			new BuildBoxSpec("ugs1602", "URB1106", 2, 2),
			new BuildBoxSpec("ugs1612", "URB1105", 2, 2),
			new BuildBoxSpec("ugs2401", "URB4202", 6, 6),
			new BuildBoxSpec("ues1602", "UEB1106", 2, 2),
			new BuildBoxSpec("ues1612", "UEB1105", 2, 2),
			new BuildBoxSpec("ues2401", "UEB4202", 6, 6),
			new BuildBoxSpec("ues3401", "UEB4301", 6, 6),
			new BuildBoxSpec("ugs1601", "URB1103", 2, 2),
			new BuildBoxSpec("ugs2601", "URB1202", 2, 2),
			new BuildBoxSpec("ugs3601", "URB1302", 2, 2),
			new BuildBoxSpec("ues1601", "UEB1103", 2, 2),
			new BuildBoxSpec("ues2601", "UEB1202", 2, 2),
			new BuildBoxSpec("ues3601", "UEB1302", 2, 2),
			new BuildBoxSpec("ugs1701", "URB3101", 2, 2),
			new BuildBoxSpec("ugs2701", "URB3201", 2, 2),
			new BuildBoxSpec("ugs3701", "URB3104", 2, 2),
			new BuildBoxSpec("ues1701", "UEB3101", 2, 2),
			new BuildBoxSpec("ues2701", "UEB3201", 2, 2),
			new BuildBoxSpec("ues3701", "UEB3104", 2, 2),
			new BuildBoxSpec("ugs1001", "URB2101", 1, 1),
			new BuildBoxSpec("ugs2001", "URB2301", 2, 2),
			new BuildBoxSpec("ugs1201", "URB2104", 1, 1),
			new BuildBoxSpec("ugs2201", "URB2204", 2, 2),
			new BuildBoxSpec("ugs3201", "URB2304", 2, 2),
			new BuildBoxSpec("ues1001", "UEB2101", 1, 1),
			new BuildBoxSpec("ues2001", "UEB2301", 2, 2),
			new BuildBoxSpec("ues1201", "UEB2104", 1, 1),
			new BuildBoxSpec("ues2201", "UEB2204", 2, 2),
			new BuildBoxSpec("ues3201", "UEB2304", 2, 2),
			new BuildBoxSpec("ugs3101", "URB2302", 8, 8),
			new BuildBoxSpec("uss1511", "XSB0101", 8, 8),
			new BuildBoxSpec("uss2511", "XSB0201", 8, 8),
			new BuildBoxSpec("uss3511", "XSB0301", 8, 8),
			new BuildBoxSpec("uss1512", "XSB0102", 8, 8),
			new BuildBoxSpec("uss2512", "XSB0202", 8, 8),
			new BuildBoxSpec("uss3512", "XSB0302", 8, 8),
			new BuildBoxSpec("uss1513", "XSB0103", 12, 14),
			new BuildBoxSpec("uss2513", "XSB0203", 12, 14),
			new BuildBoxSpec("uss3513", "XSB0303", 12, 14),
			new BuildBoxSpec("uss2510", "XSB0304", 10, 10),
			new BuildBoxSpec("uss1601", "XSB1103", 2, 2),
			new BuildBoxSpec("uss2601", "XSB1202", 2, 2),
			new BuildBoxSpec("uss3601", "XSB1302", 2, 2),
			new BuildBoxSpec("uss1611", "XSB1101", 2, 2),
			new BuildBoxSpec("uss2611", "XSB1201", 6, 6),
			new BuildBoxSpec("uss3611", "XSB1301", 8, 8),
			new BuildBoxSpec("uss1614", "XSB1102", 6, 6),
			new BuildBoxSpec("uss1602", "XSB1106", 2, 2),
			new BuildBoxSpec("uss1612", "XSB1105", 2, 2),
			new BuildBoxSpec("uss2806", "XSB1104", 2, 2),
			new BuildBoxSpec("uss3603", "XSB1303", 6, 6),
			new BuildBoxSpec("uss3501", "XSB5202", 6, 6),
			new BuildBoxSpec("uss1001", "XSB2101", 1, 1),
			new BuildBoxSpec("uss1201", "XSB2104", 1, 1),
			new BuildBoxSpec("uss1301", "XSB2109", 1, 1),
			new BuildBoxSpec("uss2001", "XSB2301", 2, 2),
			new BuildBoxSpec("uss2101", "XSB2303", 2, 2),
			new BuildBoxSpec("uss2102", "XSB2108", 2, 2),
			new BuildBoxSpec("uss2201", "XSB2204", 2, 2),
			new BuildBoxSpec("uss2301", "XSB2205", 3, 3),
			new BuildBoxSpec("uss2401", "XSB4202", 6, 6),
			new BuildBoxSpec("uss2402", "XSB4201", 2, 2),
			new BuildBoxSpec("uss2711", "XSB4203", 6, 6),
			new BuildBoxSpec("uss3101", "XSB2302", 8, 8),
			new BuildBoxSpec("uss3102", "XSB2305", 6, 6),
			new BuildBoxSpec("uss3201", "XSB2304", 2, 2),
			new BuildBoxSpec("uss3401", "XSB4301", 6, 6),
			new BuildBoxSpec("uss3402", "XSB4302", 3, 3),
			new BuildBoxSpec("uss4102", "XSB2401", 8, 8),
			new BuildBoxSpec("uss1701", "XSB3101", 2, 2),
			new BuildBoxSpec("uss2701", "XSB3201", 2, 2),
			new BuildBoxSpec("uss1702", "XSB3102", 1, 1),
			new BuildBoxSpec("uss2702", "XSB3202", 1, 1),
			new BuildBoxSpec("uss3701", "XSB3104", 2, 2),
			new BuildBoxSpec("uss1804", "XSB5101", 1, 1),
			new BuildBoxSpec("ucs1511", "UAB0101", 8, 8, isAeon: true),
			new BuildBoxSpec("ucs1512", "UAB0102", 8, 8, isAeon: true),
			new BuildBoxSpec("ucs1513", "UAB0103", 12, 14, isAeon: true),
			new BuildBoxSpec("ucs2511", "UAB0201", 8, 8, isAeon: true),
			new BuildBoxSpec("ucs2512", "UAB0202", 8, 8, isAeon: true),
			new BuildBoxSpec("ucs2513", "UAB0203", 12, 14, isAeon: true),
			new BuildBoxSpec("ucs3511", "UAB0301", 8, 8, isAeon: true),
			new BuildBoxSpec("ucs3512", "UAB0302", 8, 8, isAeon: true),
			new BuildBoxSpec("ucs3513", "UAB0303", 12, 14, isAeon: true),
			new BuildBoxSpec("ucs2510", "UAB0304", 10, 10, isAeon: true),
			new BuildBoxSpec("ucs1611", "UAB1101", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs1614", "UAB1102", 6, 6, isAeon: true),
			new BuildBoxSpec("ucs1601", "UAB1103", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs2806", "UAB1104", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs1612", "UAB1105", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs1602", "UAB1106", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs2611", "UAB1201", 6, 6, isAeon: true),
			new BuildBoxSpec("ucs2601", "UAB1202", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs3611", "UAB1301", 8, 8, isAeon: true),
			new BuildBoxSpec("ucs3601", "UAB1302", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs3603", "UAB1303", 6, 6, isAeon: true),
			new BuildBoxSpec("ucs1001", "UAB2101", 1, 1, isAeon: true),
			new BuildBoxSpec("ucs1201", "UAB2104", 1, 1, isAeon: true),
			new BuildBoxSpec("ucs2102", "UAB2108", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs1301", "UAB2109", 1, 1, isAeon: true),
			new BuildBoxSpec("ucs2201", "UAB2204", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs2301", "UAB2205", 3, 3, isAeon: true),
			new BuildBoxSpec("ucs2001", "UAB2301", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs3101", "UAB2302", 8, 8, isAeon: true),
			new BuildBoxSpec("ucs2101", "UAB2303", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs3201", "UAB2304", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs3102", "UAB2305", 6, 6, isAeon: true),
			new BuildBoxSpec("ucs1701", "UAB3101", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs1702", "UAB3102", 1, 1, isAeon: true),
			new BuildBoxSpec("ucs3701", "UAB3104", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs2701", "UAB3201", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs2702", "UAB3202", 1, 1, isAeon: true),
			new BuildBoxSpec("ucs2402", "UAB4201", 2, 2, isAeon: true),
			new BuildBoxSpec("ucs2401", "UAB4202", 6, 6, isAeon: true),
			new BuildBoxSpec("ucs2711", "UAB4203", 6, 6, isAeon: true),
			new BuildBoxSpec("ucs3401", "UAB4301", 6, 6, isAeon: true),
			new BuildBoxSpec("ucs3402", "UAB4302", 3, 3, isAeon: true),
			new BuildBoxSpec("ucs1804", "UAB5101", 1, 1, isAeon: true),
			new BuildBoxSpec("ucs2802", "UAB5102", 1, 1, isAeon: true),
			new BuildBoxSpec("ucs2801", "UAB5103", 1, 1, isAeon: true),
			new BuildBoxSpec("ucs3501", "UAB5202", 6, 6, isAeon: true),
			new BuildBoxSpec("ucs1501", "UAB5204", 1, 1, isAeon: true),
			new BuildBoxSpec("ucs4102", "XAB1401", 10, 10, isAeon: true),
			new BuildBoxSpec("ucs3001", "XAB2307", 10, 10, isAeon: true),
			new BuildBoxSpec("ucs3702", "XAB3301", 10, 10, isAeon: true)
		};
		if (Specs.Length != 137)
		{
			throw new InvalidOperationException($"Expected 137 FA structure specs, found {Specs.Length}.");
		}
		if (Specs.Count((BuildBoxSpec spec) => spec.IsAeon) != 50 || Specs.Count((BuildBoxSpec spec) => !spec.IsAeon) != 87)
		{
			throw new InvalidOperationException("Build-box manifest must contain 87 non-Aeon and 50 Aeon structures.");
		}
		IGrouping<string, BuildBoxSpec> grouping = Specs.GroupBy<BuildBoxSpec, string>((BuildBoxSpec spec) => spec.TargetId, StringComparer.Ordinal).FirstOrDefault((IGrouping<string, BuildBoxSpec> group) => group.Count() != 1);
		if (grouping != null)
		{
			throw new InvalidOperationException("Build-box manifest duplicates target '" + grouping.Key + "'.");
		}
		IGrouping<string, BuildBoxSpec> grouping2 = Specs.GroupBy<BuildBoxSpec, string>((BuildBoxSpec spec) => spec.SourceId, StringComparer.Ordinal).FirstOrDefault((IGrouping<string, BuildBoxSpec> group) => group.Count() != 1);
		if (grouping2 != null)
		{
			throw new InvalidOperationException("Build-box manifest duplicates source '" + grouping2.Key + "'.");
		}
		BuildBoxSpec[] specs = Specs;
		foreach (BuildBoxSpec buildBoxSpec in specs)
		{
			if (string.IsNullOrWhiteSpace(buildBoxSpec.TargetId) || string.IsNullOrWhiteSpace(buildBoxSpec.SourceId) || buildBoxSpec.SizeX <= 0 || buildBoxSpec.SizeZ <= 0)
			{
				throw new InvalidOperationException("Build-box spec '" + buildBoxSpec.TargetId + "' is incomplete.");
			}
		}
	}
}
