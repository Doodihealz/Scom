using System;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace SupComStyleUI;

[AddComponentMenu("UI/SupCom/Team History Hover Graphic")]
internal sealed class TeamHistoryHoverGraphic : MaskableGraphic, IPointerEnterHandler, IEventSystemHandler, IPointerMoveHandler, IPointerExitHandler
{
	private const float CrosshairThickness = 1.25f;

	private static readonly Color32 CrosshairColor = new Color32(210, 238, 241, 150);

	private static readonly Color32 MarkerBackingColor = new Color32(3, 10, 15, 235);

	private readonly TeamHistoryInspection inspection = new TeamHistoryInspection();

	private TeamHistoryGraphic historyGraphic;

	private Action<TeamHistoryInspection> inspectionChanged;

	private Action inspectionEnded;

	private Vector2 lastLocalPoint;

	private Vector2 lastScreenPoint;

	private Camera lastEventCamera;

	private bool pointerInside;

	private bool hasLocalPoint;

	private bool inspectionVisible;

	internal void Initialize(TeamHistoryGraphic source, Action<TeamHistoryInspection> onInspectionChanged, Action onInspectionEnded)
	{
		historyGraphic = source ?? throw new ArgumentNullException("source");
		inspectionChanged = onInspectionChanged ?? throw new ArgumentNullException("onInspectionChanged");
		inspectionEnded = onInspectionEnded ?? throw new ArgumentNullException("onInspectionEnded");
		raycastTarget = true;
	}

	internal bool RefreshSnapshot()
	{
		if (!pointerInside || !hasLocalPoint || historyGraphic == null)
		{
			return false;
		}
		if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(historyGraphic.rectTransform, lastScreenPoint, lastEventCamera, out lastLocalPoint))
		{
			ClearHover();
			return false;
		}
		UpdateInspection(lastLocalPoint, forceNotify: true);
		return inspectionVisible;
	}

	internal void ClearHover()
	{
		pointerInside = false;
		hasLocalPoint = false;
		lastLocalPoint = default(Vector2);
		lastScreenPoint = default(Vector2);
		lastEventCamera = null;
		HideInspection();
	}

	public void OnPointerEnter(PointerEventData eventData)
	{
		UpdatePointer(eventData);
	}

	public void OnPointerMove(PointerEventData eventData)
	{
		UpdatePointer(eventData);
	}

	public void OnPointerExit(PointerEventData eventData)
	{
		ClearHover();
	}

	protected override void Awake()
	{
		base.Awake();
		raycastTarget = true;
	}

	protected override void OnDisable()
	{
		ClearHover();
		base.OnDisable();
	}

	private void OnApplicationFocus(bool focused)
	{
		if (!focused)
		{
			ClearHover();
		}
	}

	protected override void OnPopulateMesh(VertexHelper vertices)
	{
		vertices.Clear();
		if (!inspectionVisible || historyGraphic == null || !historyGraphic.TryGetInspectionLines(inspection, out var strengthStart, out var strengthEnd, out var attacksStart, out var attacksEnd))
		{
			return;
		}
		AddLineQuad(vertices, strengthStart, strengthEnd, 1.25f, CrosshairColor);
		AddLineQuad(vertices, attacksStart, attacksEnd, 1.25f, CrosshairColor);
		for (int i = 0; i < inspection.EntryCount; i++)
		{
			TeamHistoryInspectionEntry entry = inspection.GetEntry(i);
			if (historyGraphic.TryGetInspectionPoint(inspection, i, attacksPerMinute: false, out var point))
			{
				AddMarker(vertices, point, entry.TeamColor, strengthStart.y, strengthEnd.y);
			}
			if (historyGraphic.TryGetInspectionPoint(inspection, i, attacksPerMinute: true, out var point2))
			{
				AddMarker(vertices, point2, entry.TeamColor, attacksStart.y, attacksEnd.y);
			}
		}
	}

	private void UpdatePointer(PointerEventData eventData)
	{
		if (eventData == null || historyGraphic == null || !RectTransformUtility.ScreenPointToLocalPointInRectangle(historyGraphic.rectTransform, eventData.position, eventData.enterEventCamera, out var localPoint))
		{
			ClearHover();
			return;
		}
		pointerInside = true;
		hasLocalPoint = true;
		lastScreenPoint = eventData.position;
		lastEventCamera = eventData.enterEventCamera;
		lastLocalPoint = localPoint;
		UpdateInspection(localPoint, forceNotify: false);
	}

	private void UpdateInspection(Vector2 localPoint, bool forceNotify)
	{
		int num = (inspectionVisible ? inspection.SimulationTick : (-1));
		if (!historyGraphic.TryInspect(localPoint, inspection))
		{
			HideInspection();
			return;
		}
		bool num2 = !inspectionVisible || inspection.SimulationTick != num;
		inspectionVisible = true;
		if (num2 || forceNotify)
		{
			SetVerticesDirty();
			inspectionChanged(inspection);
		}
	}

	private void HideInspection()
	{
		if (inspectionVisible)
		{
			inspectionVisible = false;
			SetVerticesDirty();
			inspectionEnded();
		}
	}

	private static void AddMarker(VertexHelper vertices, Vector2 point, Color color, float minimumY, float maximumY)
	{
		AddDiamond(vertices, point, 8f, MarkerBackingColor, minimumY, maximumY);
		AddDiamond(vertices, point, 5f, color, minimumY, maximumY);
	}

	private static void AddDiamond(VertexHelper vertices, Vector2 center, float diameter, Color color, float minimumY, float maximumY)
	{
		float num = diameter * 0.5f;
		float y = Mathf.Min(center.y + num, maximumY);
		float y2 = Mathf.Max(center.y - num, minimumY);
		int currentVertCount = vertices.currentVertCount;
		vertices.AddVert(new Vector3(center.x, y), color, Vector2.zero);
		vertices.AddVert(new Vector3(center.x + num, center.y), color, Vector2.zero);
		vertices.AddVert(new Vector3(center.x, y2), color, Vector2.zero);
		vertices.AddVert(new Vector3(center.x - num, center.y), color, Vector2.zero);
		vertices.AddTriangle(currentVertCount, currentVertCount + 1, currentVertCount + 2);
		vertices.AddTriangle(currentVertCount, currentVertCount + 2, currentVertCount + 3);
	}

	private static void AddLineQuad(VertexHelper vertices, Vector2 start, Vector2 end, float thickness, Color color)
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
}
