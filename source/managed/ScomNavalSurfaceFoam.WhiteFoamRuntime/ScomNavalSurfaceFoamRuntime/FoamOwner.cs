using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace ScomNavalSurfaceFoamRuntime;

public sealed class FoamOwner : MonoBehaviour
{
	internal sealed class MaskFrame
	{
		internal Camera Camera;

		internal RTHandle Buffer;

		internal int Frame = -1;

		internal int Width;

		internal int Height;

		internal Vector2 UvScale;

		internal Vector2 UvBias;
	}

	internal const int Layer = 30;

	internal Material MaskMaterial;

	internal Material CompositeMaterial;

	internal Texture2DArray NeutralOcclusion;

	private readonly Dictionary<int, MaskFrame> masks = new Dictionary<int, MaskFrame>();

	private readonly List<int> stale = new List<int>();

	private bool reportedFailure;

	internal void Initialize(Material source)
	{
		Shader shader = Shader.Find("Hidden/HDRP/LensFlareDataDriven");
		if (shader == null || !shader.isSupported)
		{
			throw new InvalidOperationException("Native foam composition shader unavailable.");
		}
		MaskMaterial = new Material(source)
		{
			name = "SCOM Foam Coverage",
			enableInstancing = false
		};
		if (MaskMaterial.FindPass("ForwardOnly") < 0)
		{
			throw new InvalidOperationException("Native foam ForwardOnly pass unavailable.");
		}
		UpdateMaterial(source);
		CompositeMaterial = new Material(shader)
		{
			name = "SCOM White Foam Composition",
			enableInstancing = false
		};
		CompositeMaterial.shaderKeywords = new string[0];
		if (CompositeMaterial.FindPass("LensFlareLerp") < 0)
		{
			throw new InvalidOperationException("Native foam composition pass unavailable.");
		}
		NeutralOcclusion = new Texture2DArray(1, 1, 1, TextureFormat.RGBA32, mipChain: false, linear: true)
		{
			name = "SCOM Foam Neutral Occlusion",
			hideFlags = HideFlags.HideAndDontSave
		};
		NeutralOcclusion.SetPixels(new Color[1] { Color.white }, 0);
		NeutralOcclusion.Apply(updateMipmaps: false, makeNoLongerReadable: true);
		AddVolume("Coverage", CustomPassInjectionPoint.BeforePostProcess, new CoveragePass
		{
			Owner = this
		});
		AddVolume("Composition", CustomPassInjectionPoint.AfterPostProcess, new CompositionPass
		{
			Owner = this
		});
		Debug.LogWarning("[SCOM naval foam] registered depth-tested alpha coverage BeforePostProcess; white alpha-over AfterPostProcess. Pixel execution has not yet been observed.");
	}

	internal void UpdateMaterial(Material source)
	{
		MaskMaterial.CopyPropertiesFromMaterial(source);
		MaskMaterial.name = "SCOM Foam Coverage";
		MaskMaterial.enableInstancing = false;
		MaskMaterial.shaderKeywords = new string[2] { "_BILLBOARD_NONE", "_SURFACE_TYPE_TRANSPARENT" };
		MaskMaterial.SetFloat("_AlphaSrcBlend", 1f);
		MaskMaterial.SetFloat("_AlphaDstBlend", 10f);
		MaskMaterial.SetFloat("_EnableFogOnTransparent", 0f);
	}

	private void AddVolume(string suffix, CustomPassInjectionPoint point, CustomPass pass)
	{
		GameObject gameObject = new GameObject("SCOM Naval Foam " + suffix);
		gameObject.transform.SetParent(base.transform, worldPositionStays: false);
		gameObject.layer = 0;
		CustomPassVolume customPassVolume = gameObject.AddComponent<CustomPassVolume>();
		customPassVolume.isGlobal = true;
		customPassVolume.priority = 0f;
		customPassVolume.injectionPoint = point;
		pass.name = gameObject.name;
		pass.targetColorBuffer = CustomPass.TargetBuffer.Camera;
		pass.targetDepthBuffer = ((point != CustomPassInjectionPoint.BeforePostProcess) ? CustomPass.TargetBuffer.None : CustomPass.TargetBuffer.Camera);
		pass.clearFlags = ClearFlag.None;
		customPassVolume.customPasses.Add(pass);
	}

	internal bool Eligible(CustomPassContext ctx)
	{
		if (ctx.hdCamera != null && ctx.hdCamera.camera != null && ctx.hdCamera.camera.cameraType == CameraType.Game)
		{
			return !ctx.hdCamera.camera.stereoEnabled;
		}
		return false;
	}

	internal MaskFrame Prepare(CustomPassContext ctx)
	{
		Camera camera = ctx.hdCamera.camera;
		int instanceID = camera.GetInstanceID();
		if (masks.TryGetValue(instanceID, out var value))
		{
			value.Frame = -1;
		}
		RenderTexture renderTexture = ((ctx.cameraDepthBuffer == null) ? null : ctx.cameraDepthBuffer.rt);
		if (renderTexture == null || (renderTexture.dimension != TextureDimension.Tex2D && renderTexture.dimension != TextureDimension.Tex2DArray) || renderTexture.antiAliasing != 1 || renderTexture.volumeDepth < 1)
		{
			throw new InvalidOperationException("Foam camera depth unavailable or unsupported: " + ((renderTexture == null) ? "<null>" : (renderTexture.dimension.ToString() + " slices=" + renderTexture.volumeDepth + " samples=" + renderTexture.antiAliasing)));
		}
		int actualWidth = ctx.hdCamera.actualWidth;
		int actualHeight = ctx.hdCamera.actualHeight;
		if (actualWidth <= 0 || actualHeight <= 0 || actualWidth > renderTexture.width || actualHeight > renderTexture.height)
		{
			throw new InvalidOperationException("Foam camera/depth viewport dimensions disagree.");
		}
		if (value == null)
		{
			value = new MaskFrame
			{
				Camera = camera
			};
			masks.Add(instanceID, value);
		}
		value.Frame = -1;
		if (value.Buffer == null || value.Buffer.rt.width != renderTexture.width || value.Buffer.rt.height != renderTexture.height || value.Buffer.rt.useDynamicScale != renderTexture.useDynamicScale)
		{
			if (value.Buffer != null)
			{
				value.Buffer.Release();
			}
			value.Buffer = RTHandles.Alloc(renderTexture.width, renderTexture.height, 1, DepthBits.None, GraphicsFormat.R8G8B8A8_UNorm, FilterMode.Bilinear, TextureWrapMode.Clamp, TextureDimension.Tex2D, enableRandomWrite: false, useMipMap: false, autoGenerateMips: true, isShadowMap: false, 1, 0f, MSAASamples.None, bindTextureMS: false, renderTexture.useDynamicScale, useDynamicScaleExplicit: false, RenderTextureMemoryless.None, VRTextureUsage.None, "SCOM Foam Coverage " + instanceID);
		}
		value.Width = actualWidth;
		value.Height = actualHeight;
		Vector2Int size = new Vector2Int(renderTexture.width, renderTexture.height);
		if (renderTexture.useDynamicScale && DynamicResolutionHandler.instance.HardwareDynamicResIsEnabled())
		{
			size = DynamicResolutionHandler.instance.ApplyScalesOnSize(size);
		}
		if (actualWidth > size.x || actualHeight > size.y)
		{
			throw new InvalidOperationException("Foam viewport exceeds the physical depth attachment.");
		}
		value.UvScale = new Vector2((float)actualWidth / (float)size.x, (float)actualHeight / (float)size.y);
		Vector4 vector = new Vector4(0f, 0f, -1f, 1f);
		Vector4 vector2 = ctx.hdCamera.mainViewConstants.projMatrix * vector;
		Vector4 vector3 = ctx.hdCamera.mainViewConstants.nonJitteredProjMatrix * vector;
		if (Mathf.Abs(vector2.w) < 1E-06f || Mathf.Abs(vector3.w) < 1E-06f)
		{
			throw new InvalidOperationException("Foam camera projection cannot be aligned.");
		}
		value.UvBias = new Vector2((vector2.x / vector2.w - vector3.x / vector3.w) * 0.5f * value.UvScale.x, (0f - (vector2.y / vector2.w - vector3.y / vector3.w)) * 0.5f * value.UvScale.y);
		return value;
	}

	internal MaskFrame Current(Camera camera)
	{
		if (!masks.TryGetValue(camera.GetInstanceID(), out var value) || value.Frame != Time.frameCount)
		{
			return null;
		}
		return value;
	}

	internal void Fail(Exception error)
	{
		if (!reportedFailure)
		{
			reportedFailure = true;
			Debug.LogError("[SCOM naval foam] rendering skipped: " + error.Message);
		}
	}

	private void LateUpdate()
	{
		stale.Clear();
		foreach (KeyValuePair<int, MaskFrame> mask in masks)
		{
			if (mask.Value.Camera == null)
			{
				stale.Add(mask.Key);
			}
		}
		foreach (int item in stale)
		{
			masks[item].Buffer?.Release();
			masks.Remove(item);
		}
	}

	private void OnDestroy()
	{
		foreach (MaskFrame value in masks.Values)
		{
			value.Buffer?.Release();
		}
		masks.Clear();
		if (MaskMaterial != null)
		{
			UnityEngine.Object.Destroy(MaskMaterial);
		}
		if (CompositeMaterial != null)
		{
			UnityEngine.Object.Destroy(CompositeMaterial);
		}
		if (NeutralOcclusion != null)
		{
			UnityEngine.Object.Destroy(NeutralOcclusion);
		}
	}
}
