using System;
using System.Collections.Generic;
using EM.Components;
using EM.Core;
using EM.DOTS.Engine.Loader;
using EM.Engine;
using EM.Engine.Rendering;
using EM.Entities;
using UnityEngine;

namespace ScomCybranConstruction;

public static class ConstructionRuntime
{
	private const string ShaderName = "SCOM/CybranConstruction";

	private const string UefShaderName = "SCOM/UEFConstruction";

	private const string PoolShaderName = "SCOM/AeonConstructionPool";

	private const string SeraphimShaderName = "SCOM/SeraphimConstruction";

	private static Shader seraphimShader;

	private static bool seraphimShaderFailed;

	private static Shader poolShader;

	private static bool poolShaderFailed;

	private static readonly Dictionary<RenderGroupID, RenderGroupID> uefConstructionGroups = new Dictionary<RenderGroupID, RenderGroupID>();

	private static readonly HashSet<RenderGroupID> uefRejectedGroups = new HashSet<RenderGroupID>();

	private static readonly Dictionary<RenderGroupID, RenderGroupID> constructionGroups = new Dictionary<RenderGroupID, RenderGroupID>();

	private static readonly Dictionary<RenderGroupID, RenderGroupID> originalGroups = new Dictionary<RenderGroupID, RenderGroupID>();

	private static readonly List<Material> ownedMaterials = new List<Material>();

	private static readonly HashSet<RenderGroupID> rejectedGroups = new HashSet<RenderGroupID>();

	private static TxRenderSystem_SkinnedMeshRenderingSystem owner;

	private static EntityQuery query;

	private static AssetBundle bundle;

	private static Shader shader;

	private static Shader uefShader;

	private static bool uefShaderFailed;

	private static byte[] bundleBytes;

	private static bool shaderFailed;

	private static bool failureReported;

	private static ushort firstConstructionGroup = ushort.MaxValue;

	public static void Initialize(byte[] bytes)
	{
		if (bytes == null || bytes.Length == 0)
		{
			throw new ArgumentException("Construction shader bundle is missing.", "bytes");
		}
		bundleBytes = bytes;
	}

	public static object ResolvePoolShader(object fallback)
	{
		Shader shader = fallback as Shader;
		if (shader == null || shader.name != "RTS/Props/Default" || poolShaderFailed)
		{
			return fallback;
		}
		if (poolShader != null)
		{
			return poolShader;
		}
		try
		{
			if (bundle == null)
			{
				bundle = AssetBundle.LoadFromMemory(bundleBytes);
			}
			if (bundle == null)
			{
				throw new InvalidOperationException("Unity rejected the embedded construction shader bundle.");
			}
			Shader shader2 = null;
			Shader[] array = bundle.LoadAllAssets<Shader>();
			foreach (Shader shader3 in array)
			{
				if (!(shader3 == null) && !(shader3.name != "SCOM/AeonConstructionPool"))
				{
					if (shader2 != null)
					{
						throw new InvalidOperationException("Duplicate embedded Aeon pool shader.");
					}
					shader2 = shader3;
				}
			}
			if (shader2 == null || !shader2.isSupported)
			{
				throw new InvalidOperationException("Embedded Aeon pool shader is missing or unsupported.");
			}
			poolShader = shader2;
			return poolShader;
		}
		catch (Exception ex)
		{
			poolShaderFailed = true;
			Debug.LogError("[SCOM Aeon construction] Using native silver pool: " + ex.Message);
			return fallback;
		}
	}

	public static object ResolveSeraphimShader(object fallback)
	{
		Shader shader = fallback as Shader;
		if (shader == null || shader.name != "RTS/Props/Default" || seraphimShaderFailed)
		{
			return fallback;
		}
		if (seraphimShader != null)
		{
			return seraphimShader;
		}
		try
		{
			if (bundle == null)
			{
				bundle = AssetBundle.LoadFromMemory(bundleBytes);
			}
			if (bundle == null)
			{
				throw new InvalidOperationException("Unity rejected the embedded construction shader bundle.");
			}
			Shader shader2 = null;
			Shader[] array = bundle.LoadAllAssets<Shader>();
			foreach (Shader shader3 in array)
			{
				if (!(shader3 == null) && !(shader3.name != "SCOM/SeraphimConstruction"))
				{
					if (shader2 != null)
					{
						throw new InvalidOperationException("Duplicate embedded Seraphim construction shader.");
					}
					shader2 = shader3;
				}
			}
			if (shader2 == null || !shader2.isSupported)
			{
				throw new InvalidOperationException("Embedded Seraphim construction shader is missing or unsupported.");
			}
			seraphimShader = shader2;
			return seraphimShader;
		}
		catch (Exception ex)
		{
			seraphimShaderFailed = true;
			Debug.LogError("[SCOM Seraphim construction] Using native construction body: " + ex.Message);
			return fallback;
		}
	}

	public static bool IsConstructionMarker(float value)
	{
		if (value >= 2f)
		{
			return value <= 3f;
		}
		return false;
	}

	public static bool IsUefConstructionMarker(float value)
	{
		if (value >= 4f)
		{
			return value <= 5f;
		}
		return false;
	}

	public static void Update(object system)
	{
		try
		{
			UpdateCore((TxRenderSystem_SkinnedMeshRenderingSystem)system);
		}
		catch (Exception error)
		{
			ReportFailure("Renderer routing failed", error);
		}
	}

	private static void UpdateCore(TxRenderSystem_SkinnedMeshRenderingSystem system)
	{
		if (owner == null)
		{
			owner = system;
			query = EntityQuery.Of<RendererComponent>().With<SkinnedMeshEntityBoneOffsetComponent>();
		}
		if (owner != system)
		{
			return;
		}
		World localWorld = ClientEngine.Data.localEngineData.localWorld;
		if (!localWorld.IsCreated)
		{
			return;
		}
		ClientEngine.Data.localEngineData.localDependency.Complete();
		InstanceEnumerator enumerator = localWorld.QueryInstances(in query).GetEnumerator();
		while (enumerator.MoveNext())
		{
			Instance current = enumerator.Current;
			EntityIndexArray entities = current.GetEntities<RendererComponent>();
			for (int i = 0; i < entities.Length; i++)
			{
				EntityIndex entity = entities[i];
				if (!current.HasComponent<SkinnedMeshEntityBoneOffsetComponent>(entity))
				{
					continue;
				}
				ref RendererComponent valueRW = ref current.GetComponentRW<RendererComponent>(entity).ValueRW;
				RenderGroupID value = valueRW.RenderGroupID;
				bool flag = value.Value >= firstConstructionGroup && originalGroups.TryGetValue(value, out value);
				if (!flag)
				{
					value = valueRW.RenderGroupID;
				}
				bool flag2 = IsUefConstructionMarker(valueRW.RenderInstanceData.instanceData1.x);
				if (!flag2 && !IsConstructionMarker(valueRW.RenderInstanceData.instanceData1.x))
				{
					if (flag)
					{
						valueRW.RenderGroupID = value;
					}
				}
				else if (!valueRW.Culled)
				{
					if (TryGetConstructionGroup(value, flag2, out var target))
					{
						valueRW.RenderGroupID = target;
						continue;
					}
					valueRW.RenderGroupID = value;
					valueRW.RenderInstanceData.instanceData1.x = 0f;
				}
			}
		}
	}

	private static bool TryGetConstructionGroup(RenderGroupID source, bool uef, out RenderGroupID target)
	{
		Dictionary<RenderGroupID, RenderGroupID> dictionary = (uef ? uefConstructionGroups : constructionGroups);
		HashSet<RenderGroupID> hashSet = (uef ? uefRejectedGroups : rejectedGroups);
		if (dictionary.TryGetValue(source, out target))
		{
			return true;
		}
		if ((uef ? uefShaderFailed : shaderFailed) || hashSet.Contains(source))
		{
			return false;
		}
		Material material = null;
		bool flag = false;
		try
		{
			EnsureShader(uef);
			if (source.Value >= RenderingGroupsLoader.skinnedMeshRenderGroups.Count)
			{
				throw new InvalidOperationException("Construction source render group is invalid.");
			}
			RenderingGroupsLoader.SkinnedMeshRenderGroup skinnedMeshRenderGroup = RenderingGroupsLoader.skinnedMeshRenderGroups[source.Value];
			if (skinnedMeshRenderGroup.material == null || skinnedMeshRenderGroup.material.shader == null || skinnedMeshRenderGroup.material.shader.name != "RTS/Unit")
			{
				throw new InvalidOperationException("Construction source is not an RTS/Unit material.");
			}
			if (RenderingGroupsLoader.skinnedMeshRenderGroups.Count >= 65535)
			{
				throw new InvalidOperationException("Native skinned render group capacity reached.");
			}
			material = new Material(skinnedMeshRenderGroup.material);
			material.name = skinnedMeshRenderGroup.material.name + (uef ? " (SCOM UEF construction)" : " (SCOM construction)");
			material.shader = (uef ? uefShader : shader);
			if (material.FindPass("Forward") < 0 || material.FindPass("TransparentDepthPrepass") < 0)
			{
				throw new InvalidOperationException("Construction shader is missing its color or depth pass.");
			}
			target = RenderingGroupsLoader.CreateSkinnedRenderingGroup(skinnedMeshRenderGroup.mesh, material, skinnedMeshRenderGroup.model, skinnedMeshRenderGroup.skeleton);
			flag = true;
			ownedMaterials.Add(material);
			ConfigureTransparentMaterial(material);
			dictionary.Add(source, target);
			originalGroups.Add(target, source);
			firstConstructionGroup = Math.Min(firstConstructionGroup, target.Value);
			return true;
		}
		catch (Exception error)
		{
			if (material != null && !flag)
			{
				UnityEngine.Object.Destroy(material);
			}
			hashSet.Add(source);
			ReportFailure("Using visible native body after construction material failure", error);
			return false;
		}
	}

	private static void EnsureShader(bool uef)
	{
		if ((uef ? uefShader : ConstructionRuntime.shader) != null)
		{
			return;
		}
		try
		{
			if (bundle == null)
			{
				bundle = AssetBundle.LoadFromMemory(bundleBytes);
			}
			if (bundle == null)
			{
				throw new InvalidOperationException("Unity rejected the embedded construction shader bundle.");
			}
			Shader shader = null;
			Shader[] array = bundle.LoadAllAssets<Shader>();
			foreach (Shader shader2 in array)
			{
				if (!(shader2 == null) && !(shader2.name != (uef ? "SCOM/UEFConstruction" : "SCOM/CybranConstruction")))
				{
					if (shader != null)
					{
						throw new InvalidOperationException("Duplicate embedded construction shader.");
					}
					shader = shader2;
				}
			}
			if (shader == null || !shader.isSupported)
			{
				throw new InvalidOperationException("Embedded construction shader identity or graphics support differs.");
			}
			if (uef)
			{
				uefShader = shader;
			}
			else
			{
				ConstructionRuntime.shader = shader;
			}
		}
		catch
		{
			if (uef)
			{
				uefShaderFailed = true;
			}
			else
			{
				shaderFailed = true;
			}
			throw;
		}
	}

	private static void ConfigureTransparentMaterial(Material material)
	{
		material.renderQueue = 3000;
		material.SetOverrideTag("RenderType", "Transparent");
		material.SetShaderPassEnabled("Forward", enabled: true);
		material.SetShaderPassEnabled("GBuffer", enabled: false);
		material.SetShaderPassEnabled("DepthOnly", enabled: false);
		material.SetShaderPassEnabled("MotionVectors", enabled: false);
		material.SetShaderPassEnabled("ShadowCaster", enabled: false);
		material.SetShaderPassEnabled("TransparentDepthPrepass", enabled: true);
		material.SetFloat("_TransparentDepthPrepassEnable", 1f);
		material.SetShaderPassEnabled("TransparentDepthPostpass", enabled: false);
		material.SetFloat("_AlphaCutoffEnable", 0f);
		material.SetFloat("_ZWrite", 0f);
		material.SetFloat("_TransparentZWrite", 0f);
		material.SetFloat("_SrcBlend", 5f);
		material.SetFloat("_DstBlend", 10f);
		material.enableInstancing = true;
	}

	private static void ReportFailure(string message, Exception error)
	{
		if (!failureReported)
		{
			failureReported = true;
			Debug.LogError("[SCOM Cybran construction] " + message + ": " + error.Message);
		}
	}

	public static void Destroy(object system)
	{
		if (owner != system)
		{
			return;
		}
		foreach (Material ownedMaterial in ownedMaterials)
		{
			UnityEngine.Object.Destroy(ownedMaterial);
		}
		ownedMaterials.Clear();
		constructionGroups.Clear();
		uefConstructionGroups.Clear();
		uefRejectedGroups.Clear();
		originalGroups.Clear();
		rejectedGroups.Clear();
		if (poolShader == null && seraphimShader == null)
		{
			if (bundle != null)
			{
				bundle.Unload(unloadAllLoadedObjects: true);
			}
			bundle = null;
			shader = null;
			uefShader = null;
		}
		poolShaderFailed = false;
		seraphimShaderFailed = false;
		uefShaderFailed = false;
		owner = null;
		query = default(EntityQuery);
		firstConstructionGroup = ushort.MaxValue;
		shaderFailed = false;
		failureReported = false;
	}
}
