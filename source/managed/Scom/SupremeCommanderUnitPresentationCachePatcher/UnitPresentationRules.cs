using System;
using System.Collections.Generic;
using System.Linq;
using SeraphimFourthFactionCachePatcher;

namespace SupremeCommanderUnitPresentationCachePatcher;

internal static class UnitPresentationRules
{
	internal const int ExpectedActiveUnitCount = 145;

	internal static readonly UnitPresentationRule[] All = CreateAll();

	private static UnitPresentationRule[] CreateAll()
	{
		List<UnitPresentationRule> list = new List<UnitPresentationRule>
		{
			new UnitPresentationRule("uel0000", "UEL0001", "Armored Command Unit"),
			new UnitPresentationRule("uel1001", "UEL0201", "MA12 Striker"),
			new UnitPresentationRule("uel1002", "UEL0106", "Mech Marine"),
			new UnitPresentationRule("uel1101", "UEL0103", "Lobo"),
			new UnitPresentationRule("uel1201", "UEL0104", "Archer"),
			new UnitPresentationRule("uel1501", "UEL0105", "Engineer"),
			new UnitPresentationRule("uel1701", "UEL0101", "Snoop"),
			new UnitPresentationRule("uel2201", "UEL0111", "Flapjack"),
			new UnitPresentationRule("uel2501", "UEL0208", "Engineer"),
			new UnitPresentationRule("uel3002", "UEL0202", "Pillar"),
			new UnitPresentationRule("uel3101", "UEL0304", "Demolisher"),
			new UnitPresentationRule("uel3501", "UEL0309", "Engineer"),
			new UnitPresentationRule("uel4511", "UEL0401", "Fatboy"),
			new UnitPresentationRule("ues1001", "UEB2101", "DM1 Plasma Cannon"),
			new UnitPresentationRule("ues1201", "UEB2104", "DA1 Railgun"),
			new UnitPresentationRule("ues1511", "UEB0101", "Land Factory"),
			new UnitPresentationRule("ues1601", "UEB1103", "Mass Pump 1"),
			new UnitPresentationRule("ues1602", "UEB1106", "Mass Storage"),
			new UnitPresentationRule("ues1611", "UEB1101", "Power Generator"),
			new UnitPresentationRule("ues1612", "UEB1105", "Energy Storage"),
			new UnitPresentationRule("ues1701", "UEB3101", "SA1 - 1000"),
			new UnitPresentationRule("ues2001", "UEB2301", "Triad"),
			new UnitPresentationRule("ues2201", "UEB2204", "Air Cleaner"),
			new UnitPresentationRule("ues2401", "UEB4202", "SD - Pulse"),
			new UnitPresentationRule("ues2511", "UEB0201", "Land Factory"),
			new UnitPresentationRule("ues2601", "UEB1202", "Mass Pump 2"),
			new UnitPresentationRule("ues2611", "UEB1201", "EG - 200 Fusion Reactor"),
			new UnitPresentationRule("ues2701", "UEB3201", "SA2 - 2000"),
			new UnitPresentationRule("ues3201", "UEB2304", "Flayer"),
			new UnitPresentationRule("ues3401", "UEB4301", "HSD Pulse"),
			new UnitPresentationRule("ues3511", "UEB0301", "Land Factory"),
			new UnitPresentationRule("ues3601", "UEB1302", "Mass Pump 3"),
			new UnitPresentationRule("ues3611", "UEB1301", "EG 900 Fusion Reactor"),
			new UnitPresentationRule("ues3701", "UEB3104", "SA3 - Omni"),
			new UnitPresentationRule("ucl0000", "UAL0001", "Armored Command Unit"),
			new UnitPresentationRule("ugl0000", "URL0001", "Armored Command Unit"),
			new UnitPresentationRule("ugl1002", "URL0107", "Mantis"),
			new UnitPresentationRule("ugl2101", "DRL0204", "Hoplite"),
			new UnitPresentationRule("ugl1501", "URL0105", "Engineer"),
			new UnitPresentationRule("ugl2501", "URL0208", "Engineer"),
			new UnitPresentationRule("ugl3501", "URL0309", "Engineer"),
			new UnitPresentationRule("ugl4001", "URL0402", "Monkeylord"),
			new UnitPresentationRule("ugs1001", "URB2101", "Auto Gun"),
			new UnitPresentationRule("ugs1201", "URB2104", "Tracer"),
			new UnitPresentationRule("ugs1511", "URB0101", "Land Factory"),
			new UnitPresentationRule("ugs1601", "URB1103", "Mass Extractor"),
			new UnitPresentationRule("ugs1602", "URB1106", "Mass Storage"),
			new UnitPresentationRule("ugs1611", "URB1101", "Power Generator"),
			new UnitPresentationRule("ugs1612", "URB1105", "Energy Storage"),
			new UnitPresentationRule("ugs1701", "URB3101", "Magno"),
			new UnitPresentationRule("ugs2001", "URB2301", "Cerberus"),
			new UnitPresentationRule("ugs2201", "URB2204", "Burst Master"),
			new UnitPresentationRule("ugs2401", "URB4202", "ED1"),
			new UnitPresentationRule("ugs2511", "URB0201", "Land Factory"),
			new UnitPresentationRule("ugs2601", "URB1202", "Mass Extractor"),
			new UnitPresentationRule("ugs2611", "URB1201", "Power Generator"),
			new UnitPresentationRule("ugs2701", "URB3201", "Magno XR"),
			new UnitPresentationRule("ugs3101", "URB2302", "Disruptor"),
			new UnitPresentationRule("ugs3201", "URB2304", "Myrmidon"),
			new UnitPresentationRule("ugs3511", "URB0301", "Land Factory"),
			new UnitPresentationRule("ugs3601", "URB1302", "Mass Extractor"),
			new UnitPresentationRule("ugs3611", "URB1301", "Ion Reactor"),
			new UnitPresentationRule("ugs3701", "URB3104", "Olympus")
		};
		list.AddRange(GeneratedPortSpecs.All.Select((GeneratedPortSpec port) => new UnitPresentationRule(port.TargetId, port.SourceId, port.DisplayName)));
		IGrouping<string, UnitPresentationRule> grouping = list.GroupBy<UnitPresentationRule, string>((UnitPresentationRule rule) => rule.TargetId, StringComparer.Ordinal).FirstOrDefault((IGrouping<string, UnitPresentationRule> group) => group.Count() > 1);
		if (grouping != null)
		{
			throw new InvalidOperationException("The unit presentation roster duplicates '" + grouping.Key + "'.");
		}
		if (list.Count != 145)
		{
			throw new InvalidOperationException($"The unit presentation roster must cover {145} active FA ports, found {list.Count}.");
		}
		return list.OrderBy<UnitPresentationRule, string>((UnitPresentationRule rule) => rule.TargetId, StringComparer.Ordinal).ToArray();
	}
}
