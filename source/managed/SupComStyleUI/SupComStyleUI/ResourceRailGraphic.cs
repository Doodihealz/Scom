using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

[AddComponentMenu("UI/SupCom/Resource Rail Graphic")]
public sealed class ResourceRailGraphic : MaskableGraphic
{
	public enum FillPresentation
	{
		Full,
		TopBand,
		BottomBand
	}

	[SerializeField]
	[Range(0f, 1f)]
	private float fill = 1f;

	[SerializeField]
	private bool mirrored;

	[SerializeField]
	private FillPresentation fillPresentation = FillPresentation.TopBand;

	[SerializeField]
	[Min(0f)]
	private float chamfer = 7f;

	[SerializeField]
	[Min(0f)]
	private float borderWidth = 1.5f;

	[SerializeField]
	[Min(0f)]
	private float inset = 3f;

	[SerializeField]
	[Min(0f)]
	private float fillBandHeight = 8f;

	[SerializeField]
	private Color trackColor = new Color32(3, 10, 15, 235);

	[SerializeField]
	private Color borderColor = new Color32(74, 119, 128, 230);

	[SerializeField]
	private Color fillColor = new Color32(70, 205, 232, byte.MaxValue);

	public float Fill
	{
		get
		{
			return fill;
		}
		set
		{
			float num = ProceduralGraphicGeometry.Clamp01(value);
			if (fill != num)
			{
				fill = num;
				SetVerticesDirty();
			}
		}
	}

	public bool Mirrored
	{
		get
		{
			return mirrored;
		}
		set
		{
			if (mirrored != value)
			{
				mirrored = value;
				SetVerticesDirty();
			}
		}
	}

	public bool FillBandAtBottom
	{
		get
		{
			return fillPresentation == FillPresentation.BottomBand;
		}
		set
		{
			FillMode = ((!value) ? FillPresentation.TopBand : FillPresentation.BottomBand);
		}
	}

	public FillPresentation FillMode
	{
		get
		{
			return fillPresentation;
		}
		set
		{
			if (fillPresentation != value)
			{
				fillPresentation = value;
				SetVerticesDirty();
			}
		}
	}

	public float Chamfer
	{
		get
		{
			return chamfer;
		}
		set
		{
			float num = ProceduralGraphicGeometry.NonNegative(value);
			if (chamfer != num)
			{
				chamfer = num;
				SetVerticesDirty();
			}
		}
	}

	public float BorderWidth
	{
		get
		{
			return borderWidth;
		}
		set
		{
			float num = ProceduralGraphicGeometry.NonNegative(value);
			if (borderWidth != num)
			{
				borderWidth = num;
				SetVerticesDirty();
			}
		}
	}

	public float Inset
	{
		get
		{
			return inset;
		}
		set
		{
			float num = ProceduralGraphicGeometry.NonNegative(value);
			if (inset != num)
			{
				inset = num;
				SetVerticesDirty();
			}
		}
	}

	public float FillBandHeight
	{
		get
		{
			return fillBandHeight;
		}
		set
		{
			float num = ProceduralGraphicGeometry.NonNegative(value);
			if (fillBandHeight != num)
			{
				fillBandHeight = num;
				SetVerticesDirty();
			}
		}
	}

	public Color TrackColor
	{
		get
		{
			return trackColor;
		}
		set
		{
			if (!trackColor.Equals(value))
			{
				trackColor = value;
				SetVerticesDirty();
			}
		}
	}

	public Color BorderColor
	{
		get
		{
			return borderColor;
		}
		set
		{
			if (!borderColor.Equals(value))
			{
				borderColor = value;
				SetVerticesDirty();
			}
		}
	}

	public Color FillColor
	{
		get
		{
			return fillColor;
		}
		set
		{
			if (!fillColor.Equals(value))
			{
				fillColor = value;
				SetVerticesDirty();
			}
		}
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

	public bool TryGetVisibleFillRect(out Rect anchoredRect)
	{
		anchoredRect = default(Rect);
		Rect rect = base.rectTransform.rect;
		Rect pixelAdjustedRect = GetPixelAdjustedRect();
		if (!TryGetFillBounds(pixelAdjustedRect, out var fillBounds))
		{
			return false;
		}
		float num = ProceduralGraphicGeometry.Clamp01(fill);
		float num2 = fillBounds.width * num;
		if (num2 <= 0.01f)
		{
			return false;
		}
		Rect rect2 = (mirrored ? Rect.MinMaxRect(fillBounds.xMax - num2, fillBounds.yMin, fillBounds.xMax, fillBounds.yMax) : Rect.MinMaxRect(fillBounds.xMin, fillBounds.yMin, fillBounds.xMin + num2, fillBounds.yMax));
		anchoredRect = new Rect(rect2.x - rect.xMin, rect2.y - rect.yMin, rect2.width, rect2.height);
		return true;
	}

	public bool TryGetFillEndpoint(out Vector2 anchoredPoint)
	{
		anchoredPoint = default(Vector2);
		Rect rect = base.rectTransform.rect;
		Rect pixelAdjustedRect = GetPixelAdjustedRect();
		if (!TryGetFillBounds(pixelAdjustedRect, out var fillBounds))
		{
			return false;
		}
		float num = ProceduralGraphicGeometry.Clamp01(fill);
		float num2 = (mirrored ? (fillBounds.xMax - fillBounds.width * num) : (fillBounds.xMin + fillBounds.width * num));
		anchoredPoint = new Vector2(num2 - rect.xMin, fillBounds.center.y - rect.yMin);
		return true;
	}

	protected override void OnPopulateMesh(VertexHelper vertices)
	{
		vertices.Clear();
		Rect pixelAdjustedRect = GetPixelAdjustedRect();
		if (!ProceduralGraphicGeometry.HasArea(pixelAdjustedRect))
		{
			return;
		}
		float num = ProceduralGraphicGeometry.ClampRailChamfer(pixelAdjustedRect, chamfer);
		float num2 = Mathf.Min(ProceduralGraphicGeometry.NonNegative(borderWidth), Mathf.Min(pixelAdjustedRect.width, pixelAdjustedRect.height) * 0.5f);
		Color32 color = ProceduralGraphicGeometry.Tint(trackColor, this.color);
		Rect rect = pixelAdjustedRect;
		if (num2 > 0.01f)
		{
			int currentVertCount = vertices.currentVertCount;
			ProceduralGraphicGeometry.AddRailVertices(vertices, pixelAdjustedRect, num, mirrored, ProceduralGraphicGeometry.Tint(borderColor, this.color));
			rect = ProceduralGraphicGeometry.Inset(pixelAdjustedRect, num2);
			if (!ProceduralGraphicGeometry.HasArea(rect))
			{
				ProceduralGraphicGeometry.AddFan(vertices, currentVertCount, 6);
				return;
			}
			int currentVertCount2 = vertices.currentVertCount;
			ProceduralGraphicGeometry.AddRailVertices(vertices, rect, ProceduralGraphicGeometry.ClampRailChamfer(rect, num), mirrored, color);
			ProceduralGraphicGeometry.AddRing(vertices, currentVertCount, currentVertCount2, 6);
			ProceduralGraphicGeometry.AddFan(vertices, currentVertCount2, 6);
		}
		else
		{
			int currentVertCount3 = vertices.currentVertCount;
			ProceduralGraphicGeometry.AddRailVertices(vertices, rect, num, mirrored, color);
			ProceduralGraphicGeometry.AddFan(vertices, currentVertCount3, 6);
		}
		float num3 = ProceduralGraphicGeometry.Clamp01(fill);
		if (!(num3 <= 0f) && TryGetFillBounds(pixelAdjustedRect, out var fillBounds))
		{
			float num4 = fillBounds.width * num3;
			if (!(num4 <= 0.01f))
			{
				Rect rect2 = (mirrored ? Rect.MinMaxRect(fillBounds.xMax - num4, fillBounds.yMin, fillBounds.xMax, fillBounds.yMax) : Rect.MinMaxRect(fillBounds.xMin, fillBounds.yMin, fillBounds.xMin + num4, fillBounds.yMax));
				int currentVertCount4 = vertices.currentVertCount;
				ProceduralGraphicGeometry.AddRailVertices(vertices, rect2, ProceduralGraphicGeometry.ClampRailChamfer(rect2, chamfer), mirrored, ProceduralGraphicGeometry.Tint(fillColor, this.color));
				ProceduralGraphicGeometry.AddFan(vertices, currentVertCount4, 6);
			}
		}
	}

	private bool TryGetFillBounds(Rect outerRect, out Rect fillBounds)
	{
		float amount = Mathf.Min(ProceduralGraphicGeometry.NonNegative(borderWidth), Mathf.Min(outerRect.width, outerRect.height) * 0.5f);
		Rect rect = ProceduralGraphicGeometry.Inset(outerRect, amount);
		float amount2 = Mathf.Min(ProceduralGraphicGeometry.NonNegative(inset), Mathf.Min(rect.width, rect.height) * 0.5f);
		fillBounds = ProceduralGraphicGeometry.Inset(rect, amount2);
		if (!ProceduralGraphicGeometry.HasArea(fillBounds))
		{
			return false;
		}
		if (fillPresentation == FillPresentation.Full)
		{
			return true;
		}
		float num = Mathf.Min(fillBandHeight, fillBounds.height);
		if (num <= 0.01f)
		{
			return false;
		}
		fillBounds = Rect.MinMaxRect(fillBounds.xMin, (fillPresentation == FillPresentation.BottomBand) ? fillBounds.yMin : (fillBounds.yMax - num), fillBounds.xMax, (fillPresentation == FillPresentation.BottomBand) ? (fillBounds.yMin + num) : fillBounds.yMax);
		return true;
	}
}
