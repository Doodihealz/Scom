using System.Collections.Generic;

namespace SupComStyleUI;

public sealed class TeamHistorySnapshot
{
	public int CurrentSimulationTick { get; }

	public IReadOnlyList<TeamHistoryTeamSnapshot> Teams { get; }

	public TeamHistorySnapshot(int currentSimulationTick, IReadOnlyList<TeamHistoryTeamSnapshot> teams)
	{
		CurrentSimulationTick = currentSimulationTick;
		Teams = teams;
	}
}
