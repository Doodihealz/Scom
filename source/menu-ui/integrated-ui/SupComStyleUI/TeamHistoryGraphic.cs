using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

[AddComponentMenu("UI/SupCom/Team History Graphic")]
public sealed class TeamHistoryGraphic : MaskableGraphic
{
	private enum Metric
	{
		Strength,
		AttacksPerMinute
	}

	private sealed class StoredTeam
	{
		public readonly TeamHistorySample[] Samples = new TeamHistorySample[151];

		public int TeamId;

		public string TeamName = string.Empty;

		public Color TeamColor;

		public int SampleCount;
	}

	public const int MaxTeamCount = 8;

	public const int MaxSamplesPerTeam = 151;

	public const int SimulationTicksPerSecond = 10;

	public const int HistoryWindowSeconds = 300;

	public const int HistoryWindowTicks = 3000;

	public const int ExpectedSampleIntervalTicks = 20;

	public const int MaximumConnectedGapTicks = 30;

	private const float OuterPadding = 8f;

	private const float PlotGap = 8f;

	private const float PlotTitleBandHeight = 15f;

	private const float GridThickness = 1f;

	private const float LineThickness = 2.25f;

	private const int TimeGridDivisions = 5;

	private const int ValueGridDivisions = 4;

	private static readonly Color GridColor = new Color32(102, 151, 160, 30);

	private readonly StoredTeam[] teams = CreateTeamStorage();

	private readonly int[] sampleTicks = new int[151];

	private int currentSimulationTick;

	private int teamCount;

	private int sampleTickCount;

	private float strengthScale;

	private float attacksPerMinuteScale;

	internal int CurrentSimulationTick => currentSimulationTick;

	internal TeamHistoryTickRange VisibleTickRange => TeamHistoryChartMath.GetVisibleTickRange(currentSimulationTick);

	internal float StrengthScale => strengthScale;

	internal float AttacksPerMinuteScale => attacksPerMinuteScale;

	public void SetSnapshot(TeamHistorySnapshot snapshot)
	{
		CopySnapshot(snapshot);
		SetVerticesDirty();
	}

	protected override void Awake()
	{
		base.Awake();
		raycastTarget = false;
	}

	public override bool Raycast(Vector2 screenPoint, Camera eventCamera)
	{
		return false;
	}

	protected override void OnPopulateMesh(VertexHelper vertices)
	{
		vertices.Clear();
		if (TryGetPlotRects(ProceduralGraphicGeometry.Inset(GetPixelAdjustedRect(), 8f), out var strengthRect, out var attacksRect))
		{
			Color32 gridColor = ProceduralGraphicGeometry.Tint(GridColor, color);
			AddGrid(vertices, strengthRect, gridColor);
			AddGrid(vertices, attacksRect, gridColor);
			DrawMetric(vertices, strengthRect, Metric.Strength, strengthScale);
			DrawMetric(vertices, attacksRect, Metric.AttacksPerMinute, attacksPerMinuteScale);
		}
	}

	private void CopySnapshot(TeamHistorySnapshot snapshot)
	{
		teamCount = 0;
		sampleTickCount = 0;
		currentSimulationTick = 0;
		strengthScale = 0f;
		attacksPerMinuteScale = 0f;
		ClearStoredCounts();
		if (snapshot == null)
		{
			return;
		}
		currentSimulationTick = Math.Max(0, snapshot.CurrentSimulationTick);
		IReadOnlyList<TeamHistoryTeamSnapshot> readOnlyList = snapshot.Teams;
		if (readOnlyList == null)
		{
			return;
		}
		int num = Math.Min(readOnlyList.Count, 8);
		for (int i = 0; i < num; i++)
		{
			TeamHistoryTeamSnapshot teamHistoryTeamSnapshot = readOnlyList[i];
			if (teamHistoryTeamSnapshot != null)
			{
				StoredTeam storedTeam = teams[teamCount++];
				storedTeam.TeamId = teamHistoryTeamSnapshot.TeamId;
				storedTeam.TeamName = teamHistoryTeamSnapshot.TeamName ?? string.Empty;
				storedTeam.TeamColor = SanitizeColor(teamHistoryTeamSnapshot.TeamColor);
				CopySamples(teamHistoryTeamSnapshot.Samples, storedTeam);
			}
		}
		BuildSampleTickIndex();
		strengthScale = CalculateScale(Metric.Strength);
		attacksPerMinuteScale = CalculateScale(Metric.AttacksPerMinute);
	}

	private static void CopySamples(IReadOnlyList<TeamHistorySample> sourceSamples, StoredTeam targetTeam)
	{
		targetTeam.SampleCount = 0;
		if (sourceSamples != null && sourceSamples.Count != 0)
		{
			int num = Math.Min(sourceSamples.Count, 151);
			int num2 = sourceSamples.Count - num;
			for (int i = 0; i < num; i++)
			{
				targetTeam.Samples[i] = sourceSamples[num2 + i];
			}
			targetTeam.SampleCount = num;
			SortSamplesByTick(targetTeam.Samples, num);
		}
	}

	private static void SortSamplesByTick(TeamHistorySample[] samples, int count)
	{
		for (int i = 1; i < count; i++)
		{
			TeamHistorySample teamHistorySample = samples[i];
			int num = i - 1;
			while (num >= 0 && samples[num].SimulationTick > teamHistorySample.SimulationTick)
			{
				samples[num + 1] = samples[num];
				num--;
			}
			samples[num + 1] = teamHistorySample;
		}
	}

	private float CalculateScale(Metric metric)
	{
		float num = 0f;
		TeamHistoryTickRange visibleTickRange = VisibleTickRange;
		for (int i = 0; i < teamCount; i++)
		{
			StoredTeam storedTeam = teams[i];
			for (int j = 0; j < storedTeam.SampleCount; j++)
			{
				TeamHistorySample sample = storedTeam.Samples[j];
				int simulationTick = sample.SimulationTick;
				if (simulationTick >= visibleTickRange.StartTick && simulationTick <= visibleTickRange.EndTick && TryGetMetricValue(sample, metric, out var value))
				{
					num = Mathf.Max(num, value);
				}
			}
		}
		return TeamHistoryChartMath.NiceUpperBound(num, 4);
	}

	private void DrawMetric(VertexHelper vertices, Rect plotRect, Metric metric, float scale)
	{
		if (!(scale > 0f))
		{
			return;
		}
		TeamHistoryTickRange visibleTickRange = VisibleTickRange;
		for (int i = 0; i < teamCount; i++)
		{
			StoredTeam storedTeam = teams[i];
			if (!HasPositiveMetricInRange(storedTeam, metric, visibleTickRange))
			{
				continue;
			}
			Color32 color = ProceduralGraphicGeometry.Tint(storedTeam.TeamColor, this.color);
			bool flag = false;
			int num = 0;
			float num2 = 0f;
			Vector2 vector = default(Vector2);
			for (int j = 0; j < storedTeam.SampleCount; j++)
			{
				TeamHistorySample sample = storedTeam.Samples[j];
				int simulationTick = sample.SimulationTick;
				if (simulationTick < visibleTickRange.StartTick)
				{
					continue;
				}
				if (simulationTick > visibleTickRange.EndTick)
				{
					break;
				}
				if (!TryGetMetricValue(sample, metric, out var value))
				{
					flag = false;
					continue;
				}
				float t = TeamHistoryChartMath.NormalizeTick(sample.SimulationTick, visibleTickRange);
				float t2 = Mathf.Clamp01(value / scale);
				Vector2 vector2 = new Vector2(Mathf.Lerp(plotRect.xMin, plotRect.xMax, t), Mathf.Lerp(plotRect.yMin, plotRect.yMax, t2));
				int num3 = sample.SimulationTick - num;
				bool flag2 = metric == Metric.AttacksPerMinute && num2 <= 0f && value <= 0f;
				if (flag && num3 > 0 && num3 <= 30 && !flag2)
				{
					if (metric == Metric.Strength && num2 != value)
					{
						Vector2 vector3 = new Vector2(vector2.x, vector.y);
						AddLineQuad(vertices, vector, vector3, 2.25f, color);
						AddLineQuad(vertices, vector3, vector2, 2.25f, color);
					}
					else
					{
						AddLineQuad(vertices, vector, vector2, 2.25f, color);
					}
				}
				flag = true;
				num = sample.SimulationTick;
				num2 = value;
				vector = vector2;
			}
			if (flag && (metric == Metric.Strength || num2 > 0f))
			{
				AddDiamond(vertices, vector, 4.5f, color);
			}
		}
	}

	private static bool HasPositiveMetricInRange(StoredTeam team, Metric metric, TeamHistoryTickRange range)
	{
		for (int i = 0; i < team.SampleCount; i++)
		{
			TeamHistorySample sample = team.Samples[i];
			if (sample.SimulationTick >= range.StartTick)
			{
				if (sample.SimulationTick > range.EndTick)
				{
					break;
				}
				if (TryGetMetricValue(sample, metric, out var value) && value > 0f)
				{
					return true;
				}
			}
		}
		return false;
	}

	internal bool TryInspect(Vector2 localPoint, TeamHistoryInspection inspection)
	{
		if (inspection == null || sampleTickCount == 0 || !TryGetPlotRects(out var strengthRect, out var attacksRect))
		{
			return false;
		}
		if ((!strengthRect.Contains(localPoint) && !attacksRect.Contains(localPoint)) || strengthRect.width <= 0.01f)
		{
			return false;
		}
		TeamHistoryTickRange visibleTickRange = VisibleTickRange;
		int targetTick = TeamHistoryChartMath.TickAtNormalizedPosition((localPoint.x - strengthRect.xMin) / strengthRect.width, visibleTickRange);
		int num = TeamHistoryChartMath.FindNearestTick(sampleTicks, sampleTickCount, targetTick, 15);
		if (num < visibleTickRange.StartTick || num > visibleTickRange.EndTick)
		{
			return false;
		}
		inspection.Reset(num, currentSimulationTick);
		for (int i = 0; i < teamCount; i++)
		{
			StoredTeam storedTeam = teams[i];
			TeamHistorySample sample;
			bool hasSample = TryFindSampleAtTick(storedTeam, num, out sample);
			inspection.Add(new TeamHistoryInspectionEntry(storedTeam.TeamId, storedTeam.TeamName, storedTeam.TeamColor, sample, hasSample));
		}
		return inspection.EntryCount > 0;
	}

	internal bool TryGetInspectionLines(TeamHistoryInspection inspection, out Vector2 strengthStart, out Vector2 strengthEnd, out Vector2 attacksStart, out Vector2 attacksEnd)
	{
		strengthStart = default(Vector2);
		strengthEnd = default(Vector2);
		attacksStart = default(Vector2);
		attacksEnd = default(Vector2);
		if (inspection == null || !TryGetPlotRects(out var strengthRect, out var attacksRect))
		{
			return false;
		}
		float x = Mathf.Lerp(strengthRect.xMin, strengthRect.xMax, TeamHistoryChartMath.NormalizeTick(inspection.SimulationTick, VisibleTickRange));
		strengthStart = new Vector2(x, strengthRect.yMin);
		strengthEnd = new Vector2(x, strengthRect.yMax);
		attacksStart = new Vector2(x, attacksRect.yMin);
		attacksEnd = new Vector2(x, attacksRect.yMax);
		return true;
	}

	internal bool TryGetInspectionPoint(TeamHistoryInspection inspection, int entryIndex, bool attacksPerMinute, out Vector2 point)
	{
		point = default(Vector2);
		if (inspection == null || entryIndex < 0 || entryIndex >= inspection.EntryCount || !TryGetPlotRects(out var strengthRect, out var attacksRect))
		{
			return false;
		}
		TeamHistoryInspectionEntry entry = inspection.GetEntry(entryIndex);
		float num = (attacksPerMinute ? entry.AttacksPerMinute : entry.Strength);
		bool num2 = (attacksPerMinute ? entry.HasAttacksPerMinute : entry.HasStrength);
		float num3 = (attacksPerMinute ? attacksPerMinuteScale : strengthScale);
		if (!num2 || !IsFinite(num) || num < 0f || (attacksPerMinute && !(num > 0f)) || !(num3 > 0f))
		{
			return false;
		}
		Rect rect = (attacksPerMinute ? attacksRect : strengthRect);
		float t = TeamHistoryChartMath.NormalizeTick(inspection.SimulationTick, VisibleTickRange);
		point = new Vector2(Mathf.Lerp(rect.xMin, rect.xMax, t), Mathf.Lerp(rect.yMin, rect.yMax, Mathf.Clamp01(num / num3)));
		return true;
	}

	internal bool TryGetPlotRects(out Rect strengthRect, out Rect attacksRect)
	{
		return TryGetPlotRects(ProceduralGraphicGeometry.Inset(GetPixelAdjustedRect(), 8f), out strengthRect, out attacksRect);
	}

	private static bool TryGetPlotRects(Rect contentRect, out Rect strengthRect, out Rect attacksRect)
	{
		strengthRect = default(Rect);
		attacksRect = default(Rect);
		if (!ProceduralGraphicGeometry.HasArea(contentRect))
		{
			return false;
		}
		float num = (contentRect.height - 8f) * 0.5f;
		float num2 = num - 15f;
		if (num2 <= 0.01f)
		{
			return false;
		}
		attacksRect = Rect.MinMaxRect(contentRect.xMin, contentRect.yMin, contentRect.xMax, contentRect.yMin + num2);
		float ymin = contentRect.yMin + num + 8f;
		strengthRect = Rect.MinMaxRect(contentRect.xMin, ymin, contentRect.xMax, contentRect.yMax - 15f);
		if (ProceduralGraphicGeometry.HasArea(strengthRect))
		{
			return ProceduralGraphicGeometry.HasArea(attacksRect);
		}
		return false;
	}

	private void BuildSampleTickIndex()
	{
		sampleTickCount = 0;
		TeamHistoryTickRange visibleTickRange = VisibleTickRange;
		for (int i = 0; i < teamCount; i++)
		{
			StoredTeam storedTeam = teams[i];
			for (int j = 0; j < storedTeam.SampleCount; j++)
			{
				int simulationTick = storedTeam.Samples[j].SimulationTick;
				if (simulationTick >= visibleTickRange.StartTick && simulationTick <= visibleTickRange.EndTick)
				{
					InsertSampleTick(simulationTick);
				}
			}
		}
	}

	private void InsertSampleTick(int tick)
	{
		int num = Array.BinarySearch(sampleTicks, 0, sampleTickCount, tick);
		if (num >= 0)
		{
			return;
		}
		num = ~num;
		if (sampleTickCount < sampleTicks.Length)
		{
			for (int num2 = sampleTickCount; num2 > num; num2--)
			{
				sampleTicks[num2] = sampleTicks[num2 - 1];
			}
			sampleTicks[num] = tick;
			sampleTickCount++;
		}
		else if (num != 0)
		{
			for (int i = 0; i < num - 1; i++)
			{
				sampleTicks[i] = sampleTicks[i + 1];
			}
			sampleTicks[num - 1] = tick;
		}
	}

	private static bool TryFindSampleAtTick(StoredTeam team, int tick, out TeamHistorySample sample)
	{
		int num = 0;
		int num2 = team.SampleCount - 1;
		while (num <= num2)
		{
			int num3 = num + (num2 - num) / 2;
			TeamHistorySample teamHistorySample = team.Samples[num3];
			if (teamHistorySample.SimulationTick < tick)
			{
				num = num3 + 1;
				continue;
			}
			if (teamHistorySample.SimulationTick > tick)
			{
				num2 = num3 - 1;
				continue;
			}
			sample = teamHistorySample;
			return true;
		}
		sample = default(TeamHistorySample);
		return false;
	}

	private static void AddGrid(VertexHelper vertices, Rect plotRect, Color32 gridColor)
	{
		for (int i = 0; i <= 5; i++)
		{
			float num = Mathf.Lerp(plotRect.xMin, plotRect.xMax, (float)i / 5f);
			AddAxisAlignedQuad(vertices, Rect.MinMaxRect(num - 0.5f, plotRect.yMin, num + 0.5f, plotRect.yMax), gridColor);
		}
		for (int j = 0; j <= 4; j++)
		{
			float num2 = Mathf.Lerp(plotRect.yMin, plotRect.yMax, (float)j / 4f);
			AddAxisAlignedQuad(vertices, Rect.MinMaxRect(plotRect.xMin, num2 - 0.5f, plotRect.xMax, num2 + 0.5f), gridColor);
		}
	}

	private static void AddLineQuad(VertexHelper vertices, Vector2 start, Vector2 end, float thickness, Color32 color)
	{
		Vector2 vector = end - start;
		float magnitude = vector.magnitude;
		if (!(magnitude <= 0.01f))
		{
			Vector2 vector2 = new Vector2(0f - vector.y, vector.x) * (thickness * 0.5f / magnitude);
			int currentVertCount = vertices.currentVertCount;
			vertices.AddVert(new Vector3(start.x - vector2.x, start.y - vector2.y), color, Vector2.zero);
			vertices.AddVert(new Vector3(end.x - vector2.x, end.y - vector2.y), color, Vector2.zero);
			vertices.AddVert(new Vector3(end.x + vector2.x, end.y + vector2.y), color, Vector2.zero);
			vertices.AddVert(new Vector3(start.x + vector2.x, start.y + vector2.y), color, Vector2.zero);
			vertices.AddTriangle(currentVertCount, currentVertCount + 1, currentVertCount + 2);
			vertices.AddTriangle(currentVertCount, currentVertCount + 2, currentVertCount + 3);
		}
	}

	private static void AddDiamond(VertexHelper vertices, Vector2 center, float diameter, Color32 color)
	{
		float num = diameter * 0.5f;
		int currentVertCount = vertices.currentVertCount;
		vertices.AddVert(new Vector3(center.x, center.y + num), color, Vector2.zero);
		vertices.AddVert(new Vector3(center.x + num, center.y), color, Vector2.zero);
		vertices.AddVert(new Vector3(center.x, center.y - num), color, Vector2.zero);
		vertices.AddVert(new Vector3(center.x - num, center.y), color, Vector2.zero);
		vertices.AddTriangle(currentVertCount, currentVertCount + 1, currentVertCount + 2);
		vertices.AddTriangle(currentVertCount, currentVertCount + 2, currentVertCount + 3);
	}

	private static void AddAxisAlignedQuad(VertexHelper vertices, Rect rect, Color32 color)
	{
		int currentVertCount = vertices.currentVertCount;
		vertices.AddVert(new Vector3(rect.xMin, rect.yMin), color, Vector2.zero);
		vertices.AddVert(new Vector3(rect.xMax, rect.yMin), color, Vector2.zero);
		vertices.AddVert(new Vector3(rect.xMax, rect.yMax), color, Vector2.zero);
		vertices.AddVert(new Vector3(rect.xMin, rect.yMax), color, Vector2.zero);
		vertices.AddTriangle(currentVertCount, currentVertCount + 1, currentVertCount + 2);
		vertices.AddTriangle(currentVertCount, currentVertCount + 2, currentVertCount + 3);
	}

	private static bool TryGetMetricValue(TeamHistorySample sample, Metric metric, out float value)
	{
		bool flag;
		if (metric == Metric.Strength)
		{
			value = sample.Strength;
			flag = sample.HasStrength;
		}
		else
		{
			value = sample.AttacksPerMinute;
			flag = sample.HasAttacksPerMinute;
		}
		if (flag && IsFinite(value))
		{
			return value >= 0f;
		}
		return false;
	}

	private static Color SanitizeColor(Color value)
	{
		return new Color(SanitizeColorComponent(value.r, 1f), SanitizeColorComponent(value.g, 1f), SanitizeColorComponent(value.b, 1f), SanitizeColorComponent(value.a, 1f));
	}

	private static float SanitizeColorComponent(float value, float fallback)
	{
		if (!IsFinite(value))
		{
			return fallback;
		}
		return Mathf.Clamp01(value);
	}

	private static bool IsFinite(float value)
	{
		if (!float.IsNaN(value))
		{
			return !float.IsInfinity(value);
		}
		return false;
	}

	private void ClearStoredCounts()
	{
		for (int i = 0; i < teams.Length; i++)
		{
			teams[i].SampleCount = 0;
		}
	}

	private static StoredTeam[] CreateTeamStorage()
	{
		StoredTeam[] array = new StoredTeam[8];
		for (int i = 0; i < array.Length; i++)
		{
			array[i] = new StoredTeam();
		}
		return array;
	}
}
