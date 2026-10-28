using System;

namespace SupComStyleUI;

internal sealed class TeamHistoryInspection
{
	private readonly TeamHistoryInspectionEntry[] entries = new TeamHistoryInspectionEntry[8];

	internal int SimulationTick { get; private set; }

	internal int CurrentSimulationTick { get; private set; }

	internal int EntryCount { get; private set; }

	internal TeamHistoryInspectionEntry GetEntry(int index)
	{
		if (index < 0 || index >= EntryCount)
		{
			throw new ArgumentOutOfRangeException("index");
		}
		return entries[index];
	}

	internal void Reset(int simulationTick, int currentSimulationTick)
	{
		SimulationTick = simulationTick;
		CurrentSimulationTick = currentSimulationTick;
		EntryCount = 0;
	}

	internal void Add(TeamHistoryInspectionEntry entry)
	{
		if (EntryCount < entries.Length)
		{
			entries[EntryCount++] = entry;
		}
	}
}
