using System.Collections.Generic;

namespace CommanderEnhancementsCachePatcher;

internal sealed class VisualSlotRule
{
	internal IReadOnlyList<string> Lch { get; }

	internal IReadOnlyList<string> Rch { get; }

	internal IReadOnlyList<string> Back { get; }

	internal VisualSlotRule(string[] lch, string[] rch, string[] back)
	{
		Lch = lch;
		Rch = rch;
		Back = back;
	}
}
