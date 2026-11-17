using UnityEngine;

namespace SupComStyleUI;

internal readonly struct TeamHistoryLegendEntry
{
	internal int TeamId { get; }

	internal string Name { get; }

	internal Color Color { get; }

	internal float Strength { get; }

	internal float AttacksPerMinute { get; }

	internal TeamHistoryLegendEntry(int teamId, string name, Color color, float strength, float attacksPerMinute)
	{
		TeamId = teamId;
		Name = name;
		Color = color;
		Strength = strength;
		AttacksPerMinute = attacksPerMinute;
	}
}
