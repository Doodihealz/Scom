using UnityEngine;

namespace SupComStyleUI;

internal readonly struct TeamHistoryInspectionEntry
{
	internal int TeamId { get; }

	internal string TeamName { get; }

	internal Color TeamColor { get; }

	internal float Strength { get; }

	internal float AttacksPerMinute { get; }

	internal bool HasStrength { get; }

	internal bool HasAttacksPerMinute { get; }

	internal TeamHistoryInspectionEntry(int teamId, string teamName, Color teamColor, TeamHistorySample sample, bool hasSample)
	{
		TeamId = teamId;
		TeamName = teamName ?? string.Empty;
		TeamColor = teamColor;
		Strength = (hasSample ? sample.Strength : 0f);
		AttacksPerMinute = (hasSample ? sample.AttacksPerMinute : 0f);
		HasStrength = hasSample && sample.HasStrength;
		HasAttacksPerMinute = hasSample && sample.HasAttacksPerMinute;
	}
}
