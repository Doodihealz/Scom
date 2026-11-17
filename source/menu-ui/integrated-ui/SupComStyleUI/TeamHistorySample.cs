namespace SupComStyleUI;

public readonly struct TeamHistorySample
{
	public int SimulationTick { get; }

	public float Strength { get; }

	public float AttacksPerMinute { get; }

	public bool HasStrength { get; }

	public bool HasAttacksPerMinute { get; }

	public TeamHistorySample(int simulationTick, float strength, float attacksPerMinute)
		: this(simulationTick, strength, attacksPerMinute, hasStrength: true, hasAttacksPerMinute: true)
	{
	}

	public TeamHistorySample(int simulationTick, float strength, float attacksPerMinute, bool hasStrength, bool hasAttacksPerMinute)
	{
		SimulationTick = simulationTick;
		Strength = strength;
		AttacksPerMinute = attacksPerMinute;
		HasStrength = hasStrength;
		HasAttacksPerMinute = hasAttacksPerMinute;
	}

	public static TeamHistorySample Gap(int simulationTick)
	{
		return new TeamHistorySample(simulationTick, 0f, 0f, hasStrength: false, hasAttacksPerMinute: false);
	}
}
