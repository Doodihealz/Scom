using System;
using System.Collections.Generic;
using UnityEngine;

namespace SupComStyleUI;

internal sealed class TeamHistorySession
{
	private readonly struct RawPoint
	{
		internal int Tick { get; }

		internal long CumulativeFires { get; }

		internal RawPoint(int tick, long cumulativeFires)
		{
			Tick = tick;
			CumulativeFires = cumulativeFires;
		}
	}

	private sealed class Series
	{
		internal readonly string Key;

		internal readonly List<TeamHistorySample> Samples = new List<TeamHistorySample>(151);

		internal readonly List<RawPoint> FirePoints = new List<RawPoint>(32);

		internal string Name;

		internal readonly Color Color;

		internal float CurrentStrength;

		internal float CurrentAttacksPerMinute;

		internal bool Seen;

		internal Series(string key, string name, Color color)
		{
			Key = key;
			Name = name;
			Color = color;
		}
	}

	private static readonly Color[] TeamPalette = new Color[8]
	{
		new Color32(byte.MaxValue, 92, 168, byte.MaxValue),
		new Color32(byte.MaxValue, 158, 61, byte.MaxValue),
		new Color32(86, 214, byte.MaxValue, byte.MaxValue),
		new Color32(141, 223, 98, byte.MaxValue),
		new Color32(185, 134, byte.MaxValue, byte.MaxValue),
		new Color32(244, 211, 94, byte.MaxValue),
		new Color32(53, 208, 186, byte.MaxValue),
		new Color32(byte.MaxValue, 107, 107, byte.MaxValue)
	};

	private readonly Dictionary<string, Series> seriesByKey = new Dictionary<string, Series>(StringComparer.Ordinal);

	private readonly List<Series> orderedSeries = new List<Series>(8);

	private readonly HashSet<string> keysSeenThisSample = new HashSet<string>(StringComparer.Ordinal);

	private int lastSampleTick = -1;

	private int nextPaletteSlot;

	internal int LastSampleTick => lastSampleTick;

	internal void Reset()
	{
		seriesByKey.Clear();
		orderedSeries.Clear();
		keysSeenThisSample.Clear();
		lastSampleTick = -1;
		nextPaletteSlot = 0;
	}

	internal bool TryAddSample(int simulationTick, IReadOnlyList<TeamTelemetrySample> telemetry)
	{
		if (simulationTick < 0 || telemetry == null)
		{
			return false;
		}
		if (lastSampleTick >= 0 && simulationTick < lastSampleTick)
		{
			Reset();
		}
		if (lastSampleTick >= 0 && simulationTick - lastSampleTick < 20)
		{
			return false;
		}
		keysSeenThisSample.Clear();
		for (int i = 0; i < orderedSeries.Count; i++)
		{
			orderedSeries[i].Seen = false;
		}
		int num = 0;
		for (int j = 0; j < telemetry.Count && num < 8; j++)
		{
			TeamTelemetrySample teamTelemetrySample = telemetry[j];
			if (teamTelemetrySample == null || string.IsNullOrWhiteSpace(teamTelemetrySample.TeamKey) || !IsFinite(teamTelemetrySample.Strength) || teamTelemetrySample.Strength < 0.0 || teamTelemetrySample.CumulativeFires < 0 || !keysSeenThisSample.Add(teamTelemetrySample.TeamKey))
			{
				continue;
			}
			if (!seriesByKey.TryGetValue(teamTelemetrySample.TeamKey, out var value))
			{
				if ((!(teamTelemetrySample.Strength > 0.0) && teamTelemetrySample.CumulativeFires == 0L) || orderedSeries.Count >= 8)
				{
					continue;
				}
				value = new Series(teamTelemetrySample.TeamKey, NormalizeName(teamTelemetrySample.TeamName, teamTelemetrySample.TeamKey), TeamPalette[nextPaletteSlot % TeamPalette.Length]);
				nextPaletteSlot++;
				seriesByKey.Add(teamTelemetrySample.TeamKey, value);
				orderedSeries.Add(value);
			}
			value.Name = NormalizeName(teamTelemetrySample.TeamName, value.Key);
			value.Seen = true;
			value.CurrentStrength = ClampToFloat(teamTelemetrySample.Strength);
			value.CurrentAttacksPerMinute = CalculateAttacksPerMinute(value, simulationTick, teamTelemetrySample.CumulativeFires);
			AppendBounded(value.Samples, new TeamHistorySample(simulationTick, value.CurrentStrength, value.CurrentAttacksPerMinute));
			num++;
		}
		for (int k = 0; k < orderedSeries.Count; k++)
		{
			Series series = orderedSeries[k];
			if (!series.Seen)
			{
				series.CurrentStrength = 0f;
				series.CurrentAttacksPerMinute = 0f;
				AppendBounded(series.Samples, TeamHistorySample.Gap(simulationTick));
			}
			PruneBefore(series.Samples, simulationTick - 3000);
			PruneFirePoints(series.FirePoints, simulationTick - 600 - 20);
		}
		orderedSeries.Sort((Series left, Series right) => string.CompareOrdinal(left.Key, right.Key));
		lastSampleTick = simulationTick;
		return true;
	}

	internal TeamHistorySnapshot CreateSnapshot()
	{
		List<TeamHistoryTeamSnapshot> list = new List<TeamHistoryTeamSnapshot>(orderedSeries.Count);
		for (int i = 0; i < orderedSeries.Count && i < 8; i++)
		{
			Series series = orderedSeries[i];
			list.Add(new TeamHistoryTeamSnapshot(StableTeamId(series.Key), series.Name, series.Color, series.Samples));
		}
		return new TeamHistorySnapshot(Math.Max(0, lastSampleTick), list);
	}

	internal IReadOnlyList<TeamHistoryLegendEntry> CreateLegend()
	{
		List<TeamHistoryLegendEntry> list = new List<TeamHistoryLegendEntry>(orderedSeries.Count);
		for (int i = 0; i < orderedSeries.Count && i < 8; i++)
		{
			Series series = orderedSeries[i];
			list.Add(new TeamHistoryLegendEntry(StableTeamId(series.Key), series.Name, series.Color, series.CurrentStrength, series.CurrentAttacksPerMinute));
		}
		return list;
	}

	private static float CalculateAttacksPerMinute(Series series, int tick, long cumulativeFires)
	{
		List<RawPoint> firePoints = series.FirePoints;
		if (firePoints.Count > 0 && cumulativeFires < firePoints[firePoints.Count - 1].CumulativeFires)
		{
			firePoints.Clear();
		}
		firePoints.Add(new RawPoint(tick, cumulativeFires));
		if (firePoints.Count < 2)
		{
			return 0f;
		}
		int num = tick - 600;
		RawPoint rawPoint = firePoints[0];
		for (int i = 1; i < firePoints.Count && firePoints[i].Tick <= num; i++)
		{
			rawPoint = firePoints[i];
		}
		int num2 = tick - rawPoint.Tick;
		long num3 = cumulativeFires - rawPoint.CumulativeFires;
		if (num2 <= 0 || num3 <= 0)
		{
			return 0f;
		}
		return ClampToFloat((double)num3 * 600.0 / (double)num2);
	}

	private static void AppendBounded(List<TeamHistorySample> samples, TeamHistorySample sample)
	{
		if (samples.Count == 151)
		{
			samples.RemoveAt(0);
		}
		samples.Add(sample);
	}

	private static void PruneBefore(List<TeamHistorySample> samples, int minimumTick)
	{
		int i;
		for (i = 0; i < samples.Count && samples[i].SimulationTick < minimumTick; i++)
		{
		}
		if (i > 0)
		{
			samples.RemoveRange(0, i);
		}
	}

	private static void PruneFirePoints(List<RawPoint> points, int minimumTick)
	{
		int i;
		for (i = 0; i + 1 < points.Count && points[i + 1].Tick < minimumTick; i++)
		{
		}
		if (i > 0)
		{
			points.RemoveRange(0, i);
		}
	}

	private static string NormalizeName(string value, string fallback)
	{
		string text = (string.IsNullOrWhiteSpace(value) ? ("TEAM " + fallback) : value.Trim());
		if (text.StartsWith("Army_", StringComparison.OrdinalIgnoreCase))
		{
			text = text.Replace('_', ' ');
		}
		if (text.Length > 22)
		{
			return text.Substring(0, 21) + ".";
		}
		return text;
	}

	private static int StableTeamId(string key)
	{
		int num = -2128831035;
		for (int i = 0; i < key.Length; i++)
		{
			num = (num ^ key[i]) * 16777619;
		}
		return num;
	}

	private static float ClampToFloat(double value)
	{
		if (!IsFinite(value) || value <= 0.0)
		{
			return 0f;
		}
		if (!(value >= 3.4028234663852886E+38))
		{
			return (float)value;
		}
		return float.MaxValue;
	}

	private static bool IsFinite(double value)
	{
		if (!double.IsNaN(value))
		{
			return !double.IsInfinity(value);
		}
		return false;
	}
}
