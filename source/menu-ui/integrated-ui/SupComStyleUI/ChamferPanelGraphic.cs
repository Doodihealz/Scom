using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

[AddComponentMenu("UI/SupCom/Chamfer Panel Graphic")]
public sealed class ChamferPanelGraphic : MaskableGraphic
{
	[SerializeField]
	[Min(0f)]
	private float chamfer = 14f;

	[SerializeField]
	[Min(0f)]
	private float borderWidth = 2f;

	[SerializeField]
	private Color fillColor = new Color32(5, 13, 20, 235);

	[SerializeField]
	private Color borderColor = new Color32(92, 156, 166, 220);

	[SerializeField]
	private bool mirrored;

	[SerializeField]
	private bool chamferAllCorners;

	[SerializeField]
	private bool acceptRaycasts;

	private bool goldButtonTheme = true;
	private bool steelHudTheme;

	// Opted into only by in-match chrome. Menu/lobby buttons retain their gold skin.
	public bool SteelHudTheme
	{
		get => steelHudTheme;
		set { if (steelHudTheme != value) { steelHudTheme = value; SetVerticesDirty(); } }
	}

	public bool GoldButtonTheme
	{
		get => goldButtonTheme;
		set { if (goldButtonTheme != value) { goldButtonTheme = value; SetVerticesDirty(); } }
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

	public bool ChamferAllCorners
	{
		get
		{
			return chamferAllCorners;
		}
		set
		{
			if (chamferAllCorners != value)
			{
				chamferAllCorners = value;
				SetVerticesDirty();
			}
		}
	}

	public bool AcceptRaycasts
	{
		get
		{
			return acceptRaycasts;
		}
		set
		{
			acceptRaycasts = value;
			raycastTarget = value;
		}
	}

	protected override void Awake()
	{
		base.Awake();
		raycastTarget = acceptRaycasts;
	}

	public override bool Raycast(Vector2 screenPoint, Camera eventCamera)
	{
		if (acceptRaycasts)
		{
			return base.Raycast(screenPoint, eventCamera);
		}
		return false;
	}

	protected override void OnPopulateMesh(VertexHelper vertices)
	{
		vertices.Clear();
		Rect pixelAdjustedRect = GetPixelAdjustedRect();
		if (!ProceduralGraphicGeometry.HasArea(pixelAdjustedRect))
		{
			return;
		}
		if (fillColor.a <= .001f && borderColor.a <= .001f) return;
		// Shared fixed SCOM button theme. Non-interactive panels and information
		// portraits retain their darker fill; only actual selectable skins use it.
		bool buttonSurface = GetComponent<Button>() != null || GetComponent<Toggle>() != null ||
			(name == "SupComStyleUI.Skin" && transform.parent != null &&
				(transform.parent.GetComponent<Button>() != null || transform.parent.GetComponent<Toggle>() != null));
		if (steelHudTheme && borderWidth > .01f && borderColor.a > .001f)
		{
			ForgedAllianceHudGraphic.Populate(vertices, pixelAdjustedRect, fillColor, borderColor,
				chamfer, buttonSurface, borderWidth > 2.5f, this.color);
			return;
		}
		if (buttonSurface && goldButtonTheme)
		{
			ClassicLobbyGraphic.PopulateGoldButton(vertices, pixelAdjustedRect, this.color, borderWidth > 2.5f);
			return;
		}
		float num = ProceduralGraphicGeometry.ClampPanelChamfer(pixelAdjustedRect, chamfer);
		float num2 = Mathf.Min(ProceduralGraphicGeometry.NonNegative(borderWidth), Mathf.Min(pixelAdjustedRect.width, pixelAdjustedRect.height) * 0.5f);
		Color32 color = ProceduralGraphicGeometry.Tint(fillColor, this.color);
		if (num2 <= 0.01f)
		{
			int currentVertCount = vertices.currentVertCount;
			ProceduralGraphicGeometry.AddPanelVertices(vertices, pixelAdjustedRect, num, mirrored, chamferAllCorners, color);
			ProceduralGraphicGeometry.AddFan(vertices, currentVertCount, 8);
			return;
		}
		int currentVertCount2 = vertices.currentVertCount;
		ProceduralGraphicGeometry.AddPanelVertices(vertices, pixelAdjustedRect, num, mirrored, chamferAllCorners, ProceduralGraphicGeometry.Tint(borderColor, this.color));
		Rect rect = ProceduralGraphicGeometry.Inset(pixelAdjustedRect, num2);
		if (!ProceduralGraphicGeometry.HasArea(rect))
		{
			ProceduralGraphicGeometry.AddFan(vertices, currentVertCount2, 8);
			return;
		}
		int currentVertCount3 = vertices.currentVertCount;
		ProceduralGraphicGeometry.AddPanelVertices(vertices, rect, ProceduralGraphicGeometry.ClampPanelChamfer(rect, num), mirrored, chamferAllCorners, color);
		ProceduralGraphicGeometry.AddRing(vertices, currentVertCount2, currentVertCount3, 8);
		ProceduralGraphicGeometry.AddFan(vertices, currentVertCount3, 8);
	}
}
