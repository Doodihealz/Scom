using System.Collections.Generic;

namespace CommanderEnhancementsCachePatcher;

internal sealed class EnhancementRule
{
	internal string Id { get; }

	internal string Name { get; }

	internal string NameLocKey { get; }

	internal string Description { get; }

	internal string Icon { get; }

	internal string Slot { get; }

	internal string? Prerequisite { get; }

	internal IReadOnlyList<string> Conflicts { get; }

	internal IReadOnlyList<string> Remove { get; }

	internal EnhancementCost Cost { get; }

	internal IReadOnlyDictionary<string, string> Effects { get; }

	internal CapabilityRule Capabilities { get; }

	internal RemovalRule Removal { get; }

	internal EnhancementRule(string id, string name, string nameLocKey, string description, string icon, string slot, string? prerequisite, string[] conflicts, string[] remove, EnhancementCost cost, IReadOnlyDictionary<string, string> effects, CapabilityRule capabilities, RemovalRule removal)
	{
		Id = id;
		Name = name;
		NameLocKey = nameLocKey;
		Description = description;
		Icon = icon;
		Slot = slot;
		Prerequisite = prerequisite;
		Conflicts = conflicts;
		Remove = remove;
		Cost = cost;
		Effects = effects;
		Capabilities = capabilities;
		Removal = removal;
	}
}
