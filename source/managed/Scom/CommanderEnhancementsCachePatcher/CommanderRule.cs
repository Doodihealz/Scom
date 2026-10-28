using System.Collections.Generic;

namespace CommanderEnhancementsCachePatcher;

internal sealed class CommanderRule
{
	internal string TemplateId { get; }

	internal string SourceId { get; }

	internal string Faction { get; }

	internal CommanderBaseStats Base { get; }

	internal VisualSlotRule VisualSlots { get; }

	internal IReadOnlyDictionary<string, EnhancementRule> Enhancements { get; }

	internal CommanderRule(string templateId, string sourceId, string faction, CommanderBaseStats baseStats, VisualSlotRule visualSlots, IReadOnlyDictionary<string, EnhancementRule> enhancements)
	{
		TemplateId = templateId;
		SourceId = sourceId;
		Faction = faction;
		Base = baseStats;
		VisualSlots = visualSlots;
		Enhancements = enhancements;
	}
}
