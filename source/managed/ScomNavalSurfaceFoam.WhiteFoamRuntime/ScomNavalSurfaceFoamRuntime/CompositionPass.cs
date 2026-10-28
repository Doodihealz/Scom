using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace ScomNavalSurfaceFoamRuntime;

[Serializable]
public sealed class CompositionPass : CustomPass
{
	[NonSerialized]
	internal FoamOwner Owner;

	private readonly MaterialPropertyBlock properties = new MaterialPropertyBlock();

	private bool drawReported;

	protected override void Execute(CustomPassContext ctx)
	{
		if (Owner == null || !Owner.Eligible(ctx))
		{
			return;
		}
		FoamOwner.MaskFrame maskFrame = Owner.Current(ctx.hdCamera.camera);
		if (maskFrame == null)
		{
			return;
		}
		Camera camera = ctx.hdCamera.camera;
		try
		{
			CoreUtils.SetRenderTarget(ctx.cmd, ctx.cameraColorBuffer, ClearFlag.None, 0, CubemapFace.Unknown, 0);
			properties.Clear();
			properties.SetTexture("_FlareTex", maskFrame.Buffer.rt);
			properties.SetTexture("_FlareOcclusionTex", Owner.NeutralOcclusion);
			properties.SetInteger("_ViewId", 0);
			properties.SetVector("_FlareOcclusionIndex", Vector4.zero);
			properties.SetColor("_FlareColorValue", Color.white);
			properties.SetVector("_FlareData0", new Vector4(-1f, 0f, 0f, 0f));
			properties.SetVector("_FlareData1", new Vector4(0f, 0f, 0f, 1f));
			float num = 1f / maskFrame.UvScale.x;
			float num2 = 1f / maskFrame.UvScale.y;
			properties.SetVector("_FlareData2", new Vector4((1f - maskFrame.UvScale.x - 2f * maskFrame.UvBias.x) * num, (maskFrame.UvScale.y + 2f * maskFrame.UvBias.y - 1f) * num2, num, num2));
			properties.SetVector("_FlareData3", Vector4.zero);
			properties.SetVector("_FlareData4", Vector4.zero);
			float num3 = num2 / num;
			properties.SetVector("_FlareData5", new Vector4(0f, 1f, 0f, Mathf.Sqrt(1f + num3 * num3) + 1f));
			properties.SetVector("_FlareData6", Vector4.zero);
			ctx.cmd.DrawProcedural(Matrix4x4.identity, Owner.CompositeMaterial, Owner.CompositeMaterial.FindPass("LensFlareLerp"), MeshTopology.Quads, 4, 1, properties);
			if (!drawReported)
			{
				drawReported = true;
				Debug.LogWarning("[SCOM naval foam] composition draw queued camera=" + camera.name + " selectedSlice=0 native procedural composition; pixel visibility unverified.");
			}
		}
		catch (Exception error)
		{
			Owner.Fail(error);
		}
		finally
		{
			maskFrame.Frame = -1;
		}
	}
}
