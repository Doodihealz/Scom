using System.Collections.Generic;
using UnityEngine;

namespace SupComStyleUI;

public sealed class TeamHistoryTeamSnapshot
{
	public int TeamId { get; }

	public string TeamName { get; }

	public Color TeamColor { get; }

	public IReadOnlyList<TeamHistorySample> Samples { get; }

	public TeamHistoryTeamSnapshot(int teamId, string teamName, Color teamColor, IReadOnlyList<TeamHistorySample> samples)
	{
		TeamId = teamId;
		TeamName = teamName ?? string.Empty;
		TeamColor = teamColor;
		Samples = samples;
	}
}
