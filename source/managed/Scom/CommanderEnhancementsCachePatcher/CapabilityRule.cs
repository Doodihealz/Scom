using System.Collections.Generic;

namespace CommanderEnhancementsCachePatcher;

internal sealed class CapabilityRule
{
	internal IReadOnlyList<string> Add { get; }

	internal IReadOnlyList<string> Remove { get; }

	internal IReadOnlyList<string> Toggles { get; }

	internal CapabilityRule(string[] add, string[] remove, string[] toggles)
	{
		Add = add;
		Remove = remove;
		Toggles = toggles;
	}
}
