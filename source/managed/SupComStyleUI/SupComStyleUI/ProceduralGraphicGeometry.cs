using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

internal static class ProceduralGraphicGeometry
{
	internal const float MinimumDimension = 0.01f;

	internal static bool HasArea(Rect rect)
	{
		if (rect.width > 0.01f)
		{
			return rect.height > 0.01f;
		}
		return false;
	}

	internal static float NonNegative(float value)
	{
		if (float.IsNaN(value) || float.IsInfinity(value))
		{
			return 0f;
		}
		return Mathf.Max(0f, value);
	}

	internal static float Clamp01(float value)
	{
		if (float.IsNaN(value))
		{
			return 0f;
		}
		return Mathf.Clamp01(value);
	}

	internal static float ClampPanelChamfer(Rect rect, float value)
	{
		return Mathf.Min(NonNegative(value), Mathf.Min(rect.width, rect.height) * 0.5f);
	}

	internal static float ClampRailChamfer(Rect rect, float value)
	{
		return Mathf.Min(NonNegative(value), Mathf.Min(rect.width, rect.height * 0.5f));
	}

	internal static Rect Inset(Rect rect, float amount)
	{
		return Rect.MinMaxRect(rect.xMin + amount, rect.yMin + amount, rect.xMax - amount, rect.yMax - amount);
	}

	internal static Color32 Tint(Color layerColor, Color graphicColor)
	{
		return layerColor * graphicColor;
	}

	internal static void AddPanelVertices(VertexHelper vertices, Rect rect, float cornerChamfer, bool mirrored, bool allCorners, Color32 color)
	{
		float num = 0f;
		float num2 = 0f;
		float num3 = 0f;
		float num4 = 0f;
		if (allCorners)
		{
			num = cornerChamfer;
			num2 = cornerChamfer;
			num3 = cornerChamfer;
			num4 = cornerChamfer;
		}
		else if (mirrored)
		{
			num2 = cornerChamfer;
			num4 = cornerChamfer;
		}
		else
		{
			num = cornerChamfer;
			num3 = cornerChamfer;
		}
		AddVertex(vertices, rect.xMin + num, rect.yMin, color);
		AddVertex(vertices, rect.xMax - num2, rect.yMin, color);
		AddVertex(vertices, rect.xMax, rect.yMin + num2, color);
		AddVertex(vertices, rect.xMax, rect.yMax - num3, color);
		AddVertex(vertices, rect.xMax - num3, rect.yMax, color);
		AddVertex(vertices, rect.xMin + num4, rect.yMax, color);
		AddVertex(vertices, rect.xMin, rect.yMax - num4, color);
		AddVertex(vertices, rect.xMin, rect.yMin + num, color);
	}

	internal static void AddRailVertices(VertexHelper vertices, Rect rect, float endChamfer, bool mirrored, Color32 color)
	{
		if (mirrored)
		{
			AddVertex(vertices, rect.xMin + endChamfer, rect.yMin, color);
			AddVertex(vertices, rect.xMax, rect.yMin, color);
			AddVertex(vertices, rect.xMax, rect.yMax, color);
			AddVertex(vertices, rect.xMin + endChamfer, rect.yMax, color);
			AddVertex(vertices, rect.xMin, rect.yMax - endChamfer, color);
			AddVertex(vertices, rect.xMin, rect.yMin + endChamfer, color);
		}
		else
		{
			AddVertex(vertices, rect.xMin, rect.yMin, color);
			AddVertex(vertices, rect.xMax - endChamfer, rect.yMin, color);
			AddVertex(vertices, rect.xMax, rect.yMin + endChamfer, color);
			AddVertex(vertices, rect.xMax, rect.yMax - endChamfer, color);
			AddVertex(vertices, rect.xMax - endChamfer, rect.yMax, color);
			AddVertex(vertices, rect.xMin, rect.yMax, color);
		}
	}

	internal static void AddFan(VertexHelper vertices, int start, int vertexCount)
	{
		for (int i = 1; i < vertexCount - 1; i++)
		{
			vertices.AddTriangle(start, start + i, start + i + 1);
		}
	}

	internal static void AddRing(VertexHelper vertices, int outerStart, int innerStart, int vertexCount)
	{
		for (int i = 0; i < vertexCount; i++)
		{
			int num = (i + 1) % vertexCount;
			vertices.AddTriangle(outerStart + i, outerStart + num, innerStart + num);
			vertices.AddTriangle(outerStart + i, innerStart + num, innerStart + i);
		}
	}

	private static void AddVertex(VertexHelper vertices, float x, float y, Color32 color)
	{
		vertices.AddVert(new Vector3(x, y, 0f), color, Vector2.zero);
	}
}
