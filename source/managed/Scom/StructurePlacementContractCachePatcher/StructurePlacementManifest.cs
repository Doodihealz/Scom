using System;
using System.Collections.Generic;
using System.Linq;
using SeraphimFourthFactionCachePatcher;

namespace StructurePlacementContractCachePatcher;

internal static class StructurePlacementManifest
{
	internal const int ExpectedStaticStructureCount = 87;

	internal static readonly PlacementSpec[] Specs = new PlacementSpec[87]
	{
		new PlacementSpec(PlacementFamily.Core, "ugs1611", "URB1101", 1, 1, PlacementPolicy.SourcePhysicalSkirt, 2, 2),
		new PlacementSpec(PlacementFamily.Core, "ugs2611", "URB1201", 3, 3, PlacementPolicy.SourcePhysicalSkirt, 6, 6),
		new PlacementSpec(PlacementFamily.Core, "ugs3611", "URB1301", 5, 5, PlacementPolicy.SourcePhysicalSkirt, 8, 8),
		new PlacementSpec(PlacementFamily.Core, "ugs1511", "URB0101", 5, 5, PlacementPolicy.ModelSafeCollision, 6, 5),
		new PlacementSpec(PlacementFamily.Core, "ugs2511", "URB0201", 5, 5, PlacementPolicy.ModelSafeCollision, 6, 5),
		new PlacementSpec(PlacementFamily.Core, "ugs3511", "URB0301", 5, 5, PlacementPolicy.ModelSafeCollision, 6, 5),
		new PlacementSpec(PlacementFamily.Core, "ues1511", "UEB0101", 5, 5, PlacementPolicy.ModelSafeCollision, 6, 6),
		new PlacementSpec(PlacementFamily.Core, "ues2511", "UEB0201", 5, 5, PlacementPolicy.ModelSafeCollision, 6, 6),
		new PlacementSpec(PlacementFamily.Core, "ues3511", "UEB0301", 5, 5, PlacementPolicy.ModelSafeCollision, 6, 6),
		new PlacementSpec(PlacementFamily.Core, "ues1611", "UEB1101", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Core, "ues2611", "UEB1201", 3, 3, PlacementPolicy.SourceLogicalFootprint, 3, 3),
		new PlacementSpec(PlacementFamily.Core, "ues3611", "UEB1301", 5, 5, PlacementPolicy.SourceLogicalFootprint, 5, 5),
		new PlacementSpec(PlacementFamily.Support, "ugs1602", "URB1106", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Support, "ugs1612", "URB1105", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Support, "ugs2401", "URB4202", 1, 1, PlacementPolicy.ModelSafeCollision, 5, 5),
		new PlacementSpec(PlacementFamily.Support, "ues1602", "UEB1106", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Support, "ues1612", "UEB1105", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Support, "ues2401", "UEB4202", 3, 3, PlacementPolicy.ModelSafeCollision, 4, 4),
		new PlacementSpec(PlacementFamily.Support, "ues3401", "UEB4301", 3, 3, PlacementPolicy.ModelSafeCollision, 5, 5),
		new PlacementSpec(PlacementFamily.Combat, "ugs1601", "URB1103", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ugs2601", "URB1202", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ugs3601", "URB1302", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ues1601", "UEB1103", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ues2601", "UEB1202", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ues3601", "UEB1302", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ugs1701", "URB3101", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ugs2701", "URB3201", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ugs3701", "URB3104", 1, 1, PlacementPolicy.ModelSafeCollision, 3, 2),
		new PlacementSpec(PlacementFamily.Combat, "ues1701", "UEB3101", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ues2701", "UEB3201", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ues3701", "UEB3104", 1, 1, PlacementPolicy.ModelSafeCollision, 3, 3),
		new PlacementSpec(PlacementFamily.Combat, "ugs1001", "URB2101", 1, 1, PlacementPolicy.ModelSafeCollision, 1, 2),
		new PlacementSpec(PlacementFamily.Combat, "ugs2001", "URB2301", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ugs1201", "URB2104", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 1),
		new PlacementSpec(PlacementFamily.Combat, "ugs2201", "URB2204", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ugs3201", "URB2304", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ues1001", "UEB2101", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ues2001", "UEB2301", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ues1201", "UEB2104", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ues2201", "UEB2204", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Combat, "ues3201", "UEB2304", 1, 1, PlacementPolicy.ModelSafeCollision, 2, 2),
		new PlacementSpec(PlacementFamily.Artillery, "ugs3101", "URB2302", 5, 5, PlacementPolicy.ModelSafeCollision, 7, 7),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1511", "XSB0101", 5, 5, PlacementPolicy.SourceLogicalFootprint, 5, 5),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2511", "XSB0201", 5, 5, PlacementPolicy.SourceLogicalFootprint, 5, 5),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3511", "XSB0301", 5, 5, PlacementPolicy.SourceLogicalFootprint, 5, 5),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1512", "XSB0102", 5, 5, PlacementPolicy.SourceLogicalFootprint, 5, 5),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2512", "XSB0202", 5, 5, PlacementPolicy.SourceLogicalFootprint, 5, 5),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3512", "XSB0302", 5, 5, PlacementPolicy.SourceLogicalFootprint, 5, 5),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1513", "XSB0103", 8, 10, PlacementPolicy.SourceLogicalFootprint, 8, 10),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2513", "XSB0203", 8, 10, PlacementPolicy.SourceLogicalFootprint, 8, 10),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3513", "XSB0303", 8, 10, PlacementPolicy.SourceLogicalFootprint, 8, 10),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2510", "XSB0304", 7, 7, PlacementPolicy.SourceLogicalFootprint, 7, 7),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1601", "XSB1103", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2601", "XSB1202", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3601", "XSB1302", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1611", "XSB1101", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2611", "XSB1201", 3, 3, PlacementPolicy.SourceLogicalFootprint, 3, 3),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3611", "XSB1301", 5, 5, PlacementPolicy.SourceLogicalFootprint, 5, 5),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1614", "XSB1102", 3, 3, PlacementPolicy.SourceLogicalFootprint, 3, 3),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1602", "XSB1106", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1612", "XSB1105", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2806", "XSB1104", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3603", "XSB1303", 3, 3, PlacementPolicy.SourceLogicalFootprint, 3, 3),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3501", "XSB5202", 3, 3, PlacementPolicy.SourceLogicalFootprint, 3, 3),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1001", "XSB2101", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1201", "XSB2104", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1301", "XSB2109", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2001", "XSB2301", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2101", "XSB2303", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2102", "XSB2108", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2201", "XSB2204", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2301", "XSB2205", 2, 2, PlacementPolicy.SourceLogicalFootprint, 2, 2),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2401", "XSB4202", 3, 3, PlacementPolicy.SourceLogicalFootprint, 3, 3),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2402", "XSB4201", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2711", "XSB4203", 3, 3, PlacementPolicy.SourceLogicalFootprint, 3, 3),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3101", "XSB2302", 5, 5, PlacementPolicy.SourceLogicalFootprint, 5, 5),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3102", "XSB2305", 3, 3, PlacementPolicy.SourceLogicalFootprint, 3, 3),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3201", "XSB2304", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3401", "XSB4301", 3, 3, PlacementPolicy.SourceLogicalFootprint, 3, 3),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3402", "XSB4302", 2, 2, PlacementPolicy.SourceLogicalFootprint, 2, 2),
		new PlacementSpec(PlacementFamily.Seraphim, "uss4102", "XSB2401", 5, 5, PlacementPolicy.SourceLogicalFootprint, 5, 5),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1701", "XSB3101", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2701", "XSB3201", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1702", "XSB3102", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss2702", "XSB3202", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss3701", "XSB3104", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1),
		new PlacementSpec(PlacementFamily.Seraphim, "uss1804", "XSB5101", 1, 1, PlacementPolicy.SourceLogicalFootprint, 1, 1)
	};

	internal static void Validate()
	{
		if (Specs.Length != 87)
		{
			throw new InvalidOperationException($"Expected {87} static placement specs, found {Specs.Length}.");
		}
		IGrouping<string, PlacementSpec> grouping = Specs.GroupBy<PlacementSpec, string>((PlacementSpec spec) => spec.TargetId, StringComparer.Ordinal).FirstOrDefault((IGrouping<string, PlacementSpec> group) => group.Count() != 1);
		if (grouping != null)
		{
			throw new InvalidOperationException("Placement manifest duplicates target '" + grouping.Key + "'.");
		}
		foreach (KeyValuePair<PlacementFamily, int> family in new Dictionary<PlacementFamily, int>
		{
			[PlacementFamily.Core] = 12,
			[PlacementFamily.Support] = 7,
			[PlacementFamily.Combat] = 22,
			[PlacementFamily.Artillery] = 1,
			[PlacementFamily.Seraphim] = 45
		})
		{
			int num = Specs.Count((PlacementSpec spec) => spec.Family == family.Key);
			if (num != family.Value)
			{
				throw new InvalidOperationException($"Placement manifest expected {family.Value} {family.Key} specs, found {num}.");
			}
		}
		PlacementSpec[] specs = Specs;
		foreach (PlacementSpec placementSpec in specs)
		{
			if (string.IsNullOrWhiteSpace(placementSpec.TargetId) || string.IsNullOrWhiteSpace(placementSpec.SourceUnitId) || placementSpec.SourceGridX <= 0 || placementSpec.SourceGridZ <= 0 || placementSpec.GridX <= 0 || placementSpec.GridZ <= 0)
			{
				throw new InvalidOperationException("Placement spec '" + placementSpec.TargetId + "' has a non-positive or missing contract value.");
			}
			if (placementSpec.Policy == PlacementPolicy.SourceLogicalFootprint && (placementSpec.GridX != placementSpec.SourceGridX || placementSpec.GridZ != placementSpec.SourceGridZ))
			{
				throw new InvalidOperationException("Source-logical placement spec '" + placementSpec.TargetId + "' does not retain its authored FA grid.");
			}
			if (placementSpec.Policy == PlacementPolicy.ModelSafeCollision && (placementSpec.GridX < placementSpec.SourceGridX || placementSpec.GridZ < placementSpec.SourceGridZ))
			{
				throw new InvalidOperationException("Model-safe placement spec '" + placementSpec.TargetId + "' is smaller than its source logical grid.");
			}
			bool flag = placementSpec.TargetId.StartsWith("uss", StringComparison.Ordinal);
			if (placementSpec.Family == PlacementFamily.Seraphim != flag)
			{
				throw new InvalidOperationException("Placement spec '" + placementSpec.TargetId + "' has an invalid Seraphim/static family boundary.");
			}
		}
		Dictionary<string, PlacementSpec> dictionary = Specs.Where((PlacementSpec spec) => spec.Family == PlacementFamily.Seraphim).ToDictionary<PlacementSpec, string, PlacementSpec>((PlacementSpec spec) => spec.TargetId, (PlacementSpec spec) => spec, StringComparer.Ordinal);
		Dictionary<string, GeneratedPortSpec> dictionary2 = GeneratedPortSpecs.All.Where((GeneratedPortSpec spec) => spec.Structure).ToDictionary<GeneratedPortSpec, string, GeneratedPortSpec>((GeneratedPortSpec spec) => spec.TargetId, (GeneratedPortSpec spec) => spec, StringComparer.Ordinal);
		if (dictionary.Count != dictionary2.Count || dictionary.Keys.Except(dictionary2.Keys, StringComparer.Ordinal).Any() || dictionary2.Keys.Except(dictionary.Keys, StringComparer.Ordinal).Any())
		{
			throw new InvalidOperationException("Placement manifest no longer matches the generated static Seraphim port set.");
		}
		foreach (KeyValuePair<string, GeneratedPortSpec> item in dictionary2)
		{
			if (!string.Equals(dictionary[item.Key].SourceUnitId, item.Value.SourceId, StringComparison.Ordinal))
			{
				throw new InvalidOperationException("Placement manifest source mismatch for Seraphim template '" + item.Key + "'.");
			}
		}
	}
}
