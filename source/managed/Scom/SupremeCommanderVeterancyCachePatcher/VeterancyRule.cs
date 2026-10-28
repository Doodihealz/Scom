using System;
using System.Linq;

namespace SupremeCommanderVeterancyCachePatcher;

internal sealed class VeterancyRule
{
	public int[] Kills { get; }

	public float[] Regen { get; }

	public VeterancyRule(int[] kills, float[] regen)
	{
		if (kills == null || regen == null || kills.Length != 5 || regen.Length != 5)
		{
			throw new ArgumentException("A Supreme Commander veterancy rule requires five kill and regen values.");
		}
		if (kills.Any((int value) => value <= 0) || kills.Zip(kills.Skip(1), (int left, int right) => left >= right).Any((bool value) => value))
		{
			throw new ArgumentException("Veterancy kill thresholds must be strictly increasing positive values.", "kills");
		}
		if (regen.Any((float value) => value < 0f || float.IsNaN(value) || float.IsInfinity(value)))
		{
			throw new ArgumentException("Veterancy regeneration values must be finite and non-negative.", "regen");
		}
		Kills = (int[])kills.Clone();
		Regen = (float[])regen.Clone();
	}

	public int GetLevel(int kills)
	{
		int i;
		for (i = 0; i < Kills.Length && kills >= Kills[i]; i++)
		{
		}
		return i;
	}
}
