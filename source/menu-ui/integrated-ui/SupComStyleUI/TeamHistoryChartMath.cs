using System;

namespace SupComStyleUI;

internal static class TeamHistoryChartMath
{
	internal static TeamHistoryTickRange GetVisibleTickRange(int currentSimulationTick)
	{
		int num = Math.Max(0, currentSimulationTick);
		return new TeamHistoryTickRange((num > 3000) ? (num - 3000) : 0, num);
	}

	internal static float NormalizeTick(int simulationTick, TeamHistoryTickRange range)
	{
		if (range.SpanTicks <= 0)
		{
			return 1f;
		}
		double val = (double)((long)simulationTick - (long)range.StartTick) / (double)range.SpanTicks;
		return (float)Math.Max(0.0, Math.Min(1.0, val));
	}

	internal static int TickAtNormalizedPosition(float normalizedPosition, TeamHistoryTickRange range)
	{
		if (range.SpanTicks <= 0)
		{
			return range.EndTick;
		}
		long num = (long)Math.Round(((float.IsNaN(normalizedPosition) || float.IsInfinity(normalizedPosition)) ? 0.0 : Math.Max(0.0, Math.Min(1.0, normalizedPosition))) * (double)range.SpanTicks, MidpointRounding.AwayFromZero);
		return (int)Math.Max(range.StartTick, Math.Min(range.EndTick, range.StartTick + num));
	}

	internal static int FindNearestTick(int[] sortedTicks, int count, int targetTick, int maximumDistance)
	{
		if (sortedTicks == null || count <= 0 || maximumDistance < 0)
		{
			return -1;
		}
		int num = 0;
		int num2 = Math.Min(count, sortedTicks.Length) - 1;
		while (num <= num2)
		{
			int num3 = num + (num2 - num) / 2;
			int num4 = sortedTicks[num3];
			if (num4 < targetTick)
			{
				num = num3 + 1;
				continue;
			}
			if (num4 > targetTick)
			{
				num2 = num3 - 1;
				continue;
			}
			return num4;
		}
		int num5 = ((num2 >= 0) ? sortedTicks[num2] : (-1));
		int num6 = ((num < count && num < sortedTicks.Length) ? sortedTicks[num] : (-1));
		long num7 = ((num5 >= 0) ? ((long)targetTick - (long)num5) : long.MaxValue);
		long num8 = ((num6 >= 0) ? ((long)num6 - (long)targetTick) : long.MaxValue);
		int num9 = ((num8 <= num7) ? num6 : num5);
		long num10 = Math.Min(num7, num8);
		if (num9 < 0 || num10 > maximumDistance)
		{
			return -1;
		}
		return num9;
	}

	internal static float NiceUpperBound(float maximum, int divisions)
	{
		if (float.IsNaN(maximum) || float.IsInfinity(maximum) || maximum <= 0f || divisions <= 0)
		{
			return 0f;
		}
		double num = maximum / (float)divisions;
		double num2 = Math.Pow(10.0, Math.Floor(Math.Log10(num)));
		double num3 = num / num2;
		double num4 = ((num3 <= 1.0) ? 1.0 : ((num3 <= 2.0) ? 2.0 : ((num3 <= 2.5) ? 2.5 : ((num3 <= 5.0) ? 5.0 : 10.0)))) * num2;
		double num5 = Math.Ceiling((double)maximum / num4) * num4;
		if (!(num5 > 0.0) || !(num5 <= 3.4028234663852886E+38))
		{
			return maximum;
		}
		return (float)num5;
	}
}
