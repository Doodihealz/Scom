using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace ScomNavalSurfaceFoamRuntime;

[Serializable]
public sealed class CoveragePass : CustomPass
{
	[NonSerialized]
	internal FoamOwner Owner;

	private bool drawReported;

	private static readonly ShaderTagId[] Tags = new ShaderTagId[3]
	{
		new ShaderTagId("ForwardOnly"),
		new ShaderTagId("Forward"),
		new ShaderTagId("SRPDefaultUnlit")
	};

	protected override void AggregateCullingParameters(ref ScriptableCullingParameters parameters, HDCamera camera)
	{
		parameters.cullingMask |= 1073741824u;
	}

	protected override void Execute(CustomPassContext ctx)
	{
		if (Owner == null || !Owner.Eligible(ctx))
		{
			return;
		}
		try
		{
			FoamOwner.MaskFrame maskFrame = Owner.Prepare(ctx);
			CoreUtils.SetRenderTarget(ctx.cmd, maskFrame.Buffer, ctx.cameraDepthBuffer, ClearFlag.Color, new Color(1f, 1f, 1f, 0f), 0, CubemapFace.Unknown, 0);
			ctx.cmd.SetViewport(new Rect(0f, 0f, maskFrame.Width, maskFrame.Height));
			BlendState blendState = new BlendState
			{
				blendState0 = new RenderTargetBlendState(ColorWriteMask.Alpha, BlendMode.One, BlendMode.OneMinusSrcAlpha, BlendMode.One, BlendMode.OneMinusSrcAlpha)
			};
			RenderStateBlock renderStateBlock = new RenderStateBlock(RenderStateMask.Blend | RenderStateMask.Depth | RenderStateMask.Stencil);
			renderStateBlock.depthState = new DepthState(writeEnabled: false, CompareFunction.LessEqual);
			renderStateBlock.blendState = blendState;
			renderStateBlock.stencilState = new StencilState(enabled: false);
			RenderStateBlock overrideRenderState = renderStateBlock;
			CustomPassUtils.DrawRenderers(in ctx, Tags, 1073741824, RenderQueueType.AllTransparent, Owner.MaskMaterial, Owner.MaskMaterial.FindPass("ForwardOnly"), overrideRenderState, SortingCriteria.BackToFront);
			maskFrame.Frame = Time.frameCount;
			if (!drawReported)
			{
				drawReported = true;
				RenderTexture rt = ctx.cameraDepthBuffer.rt;
				Debug.LogWarning("[SCOM naval foam] coverage draw queued camera=" + ctx.hdCamera.camera.name + " depth=" + rt.dimension.ToString() + " slices=" + rt.volumeDepth + " samples=" + rt.antiAliasing + " selectedSlice=0 viewport=" + maskFrame.Width + "x" + maskFrame.Height + "; pixel visibility unverified.");
			}
		}
		catch (Exception error)
		{
			Owner.Fail(error);
		}
		finally
		{
			CoreUtils.SetRenderTarget(ctx.cmd, ctx.cameraColorBuffer, ctx.cameraDepthBuffer, ClearFlag.None);
		}
	}
}
