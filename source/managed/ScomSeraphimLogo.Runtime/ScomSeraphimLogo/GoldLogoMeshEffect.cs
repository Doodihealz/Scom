using UnityEngine;
using UnityEngine.UI;

namespace ScomSeraphimLogo;

public sealed class GoldLogoMeshEffect : BaseMeshEffect
{
	private const float DisplayScale = 1.85f;

	private Sprite targetSprite;

	public void Bind(Sprite expected)
	{
		if (!(targetSprite == expected))
		{
			targetSprite = expected;
			base.graphic.SetVerticesDirty();
		}
	}

	public override void ModifyMesh(VertexHelper vertices)
	{
		Image image = base.graphic as Image;
		if (!IsActive() || image == null || targetSprite == null || image.overrideSprite == null)
		{
			return;
		}
		Vector2 center = image.rectTransform.rect.center;
		UIVertex vertex = default(UIVertex);
		for (int i = 0; i < vertices.currentVertCount; i++)
		{
			vertices.PopulateUIVertex(ref vertex, i);
			vertex.position.x = center.x + (vertex.position.x - center.x) * 1.85f;
			vertex.position.y = center.y + (vertex.position.y - center.y) * 1.85f;
			if (image.overrideSprite == targetSprite)
			{
				vertex.color = new Color32(byte.MaxValue, byte.MaxValue, byte.MaxValue, vertex.color.a);
			}
			vertices.SetUIVertex(vertex, i);
		}
	}
}
