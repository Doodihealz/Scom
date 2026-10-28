using System;
using System.Collections.Generic;
using EM.Components;
using EM.Core;
using EM.DOTS.Engine.Loader;
using EM.Engine;
using EM.Engine.Rendering;
using EM.Entities;
using UnityEngine;

namespace ScomTreeDecay;

public static class TreeDecayRuntime
{
	private struct TreeLODs
	{
		public LODDataComponent Original;

		public RenderGroupID InitialRenderer;
	}

	public const float Marker = 58413f;

	public const int FadeBins = 32;

	public const int MaximumGroups = 2048;

	public const int MaximumActiveTrees = 4096;

	private const double DiscoveryInterval = 0.5;

	private static readonly List<LocalID> active = new List<LocalID>();

	private static readonly HashSet<LocalID> known = new HashSet<LocalID>();

	private static readonly Dictionary<RenderGroupID, RenderGroupID[]> families = new Dictionary<RenderGroupID, RenderGroupID[]>();

	private static readonly Dictionary<RenderGroupID, RenderGroupID> originals = new Dictionary<RenderGroupID, RenderGroupID>();

	private static readonly List<Material> materials = new List<Material>();

	private static readonly HashSet<RenderGroupID> rejected = new HashSet<RenderGroupID>();

	private static readonly Dictionary<LocalID, TreeLODs> treeLODs = new Dictionary<LocalID, TreeLODs>();

	private static EntityQuery query;

	private static bool queryReady;

	private static TxRenderSystem_MeshRenderingSystem owner;

	private static double lastDiscovery = double.NegativeInfinity;

	private static bool reported;

	public static int OpacityBin(float opacity)
	{
		if (float.IsNaN(opacity) || float.IsInfinity(opacity))
		{
			return 0;
		}
		return Math.Min(32, Math.Max(0, (int)Math.Ceiling((1f - opacity) * 32f)));
	}

	public static void Update(TxRenderSystem_MeshRenderingSystem system)
	{
		try
		{
			UpdateCore(system);
		}
		catch (Exception ex)
		{
			Report("Tree fade routing failed: " + ex.Message);
		}
	}

	private static void UpdateCore(TxRenderSystem_MeshRenderingSystem system)
	{
		if (owner == null)
		{
			owner = system;
		}
		if (owner != system)
		{
			return;
		}
		World world = ClientEngine.Data.localEngineData.localWorld;
		if (!world.IsCreated)
		{
			return;
		}
		if (!queryReady)
		{
			query = EntityQuery.Of<RendererComponent>().With<MeshScaleComponent>();
			queryReady = true;
		}
		double simTime = ClientEngine.Data.localEngineData.localTime.simTime;
		bool flag = simTime < lastDiscovery || simTime - lastDiscovery >= 0.5;
		if (!flag && active.Count == 0)
		{
			return;
		}
		ClientEngine.Data.localEngineData.localDependency.Complete();
		if (flag)
		{
			Discover(ref world);
			lastDiscovery = simTime;
		}
		for (int num = active.Count - 1; num >= 0; num--)
		{
			LocalID localID = active[num];
			if (!ClientEngine.TryGetLocalComponentRW(localID, out ComponentRefRW<RendererComponent> component))
			{
				Forget(num, localID);
			}
			else
			{
				ref RendererComponent valueRW = ref component.ValueRW;
				float w = valueRW.RenderInstanceData.instanceData1.w;
				if (valueRW.RenderInstanceData.instanceData1.z != 58413f || float.IsNaN(w) || float.IsInfinity(w))
				{
					RestoreTree(localID, ref valueRW);
					Forget(num, localID);
				}
				else
				{
					int num2 = OpacityBin(w);
					if (num2 == 0)
					{
						RestoreTree(localID, ref valueRW);
					}
					else if (!valueRW.Culled)
					{
						RouteTree(localID, ref valueRW, num2);
					}
				}
			}
		}
	}

	private static void Discover(ref World world)
	{
		InstanceEnumerator enumerator = world.QueryInstances(in query).GetEnumerator();
		while (enumerator.MoveNext())
		{
			Instance current = enumerator.Current;
			EntityIndexArray entities = current.GetEntities<RendererComponent>();
			for (int i = 0; i < entities.Length; i++)
			{
				EntityIndex entity = entities[i];
				if (current.GetComponent<RendererComponent>(entity).RenderInstanceData.instanceData1.z != 58413f)
				{
					continue;
				}
				LocalID entityID = current.GetEntityID<LocalID>(entity);
				if (!known.Contains(entityID))
				{
					if (active.Count >= 4096)
					{
						Report("Active tree fade limit reached; remaining trees retain native rendering.");
						return;
					}
					known.Add(entityID);
					active.Add(entityID);
				}
			}
		}
	}

	private static RenderGroupID Original(RenderGroupID group)
	{
		if (!originals.TryGetValue(group, out var value))
		{
			return group;
		}
		return value;
	}

	private static void RouteTree(LocalID id, ref RendererComponent render, int bin)
	{
		RenderGroupID renderGroupID = Original(render.RenderGroupID);
		RenderGroupID? foliage = null;
		if (ClientEngine.TryGetLocalComponentRW(id, out ComponentRefRW<LODDataComponent> component))
		{
			ref LODDataComponent valueRW = ref component.ValueRW;
			if (!treeLODs.TryGetValue(id, out var value))
			{
				value = new TreeLODs
				{
					Original = valueRW,
					InitialRenderer = renderGroupID
				};
				int num = Math.Max(0, Math.Min(6, valueRW.lodCount));
				for (int i = 0; i < num; i++)
				{
					value.Original.SetRenderGroupID(i, Original(valueRW.GetRenderGroupID(i)));
				}
				treeLODs.Add(id, value);
			}
			int num2 = Math.Max(0, Math.Min(6, Math.Min(valueRW.lodCount, value.Original.lodCount)));
			for (int j = 0; j < num2; j++)
			{
				RenderGroupID renderGroupID2 = value.Original.GetRenderGroupID(j);
				if (HasShader(renderGroupID2, "RTS/Props/Foliage"))
				{
					foliage = renderGroupID2;
					break;
				}
			}
			for (int k = 0; k < num2; k++)
			{
				RenderGroupID renderGroupID3 = value.Original.GetRenderGroupID(k);
				valueRW.SetRenderGroupID(k, FadeGroup(renderGroupID3, foliage, bin));
			}
		}
		render.RenderGroupID = FadeGroup(renderGroupID, foliage, bin);
	}

	private static RenderGroupID FadeGroup(RenderGroupID source, RenderGroupID? foliage, int bin)
	{
		RenderGroupID source2 = source;
		if (foliage.HasValue && HasShader(source, "Impostor/ImpostorOctahedronTranslusent"))
		{
			source2 = foliage.Value;
		}
		if (!TryGetGroup(source2, bin, out var target))
		{
			return source;
		}
		return target;
	}

	private static bool HasShader(RenderGroupID group, string shader)
	{
		if (group.Value >= RenderingGroupsLoader.meshRenderGroups.Count)
		{
			return false;
		}
		Material material = RenderingGroupsLoader.meshRenderGroups[group.Value].material;
		if (material != null && material.shader != null)
		{
			return material.shader.name == shader;
		}
		return false;
	}

	private static void RestoreTree(LocalID id, ref RendererComponent render)
	{
		if (!treeLODs.TryGetValue(id, out var value))
		{
			render.RenderGroupID = Original(render.RenderGroupID);
			return;
		}
		if (ClientEngine.TryGetLocalComponentRW(id, out ComponentRefRW<LODDataComponent> component))
		{
			ref LODDataComponent valueRW = ref component.ValueRW;
			int num = Math.Max(0, Math.Min(6, Math.Min(valueRW.lodCount, value.Original.lodCount)));
			for (int i = 0; i < num; i++)
			{
				valueRW.SetRenderGroupID(i, value.Original.GetRenderGroupID(i));
			}
		}
		render.RenderGroupID = value.InitialRenderer;
		treeLODs.Remove(id);
	}

	private static bool TryGetGroup(RenderGroupID source, int bin, out RenderGroupID target)
	{
		target = source;
		if (families.TryGetValue(source, out var value) && value[bin].Value != ushort.MaxValue)
		{
			target = value[bin];
			return true;
		}
		if (materials.Count >= 2048)
		{
			Report("Shared tree fade material limit reached; remaining trees retain native rendering.");
			return false;
		}
		if (rejected.Contains(source))
		{
			return false;
		}
		if (source.Value >= RenderingGroupsLoader.meshRenderGroups.Count)
		{
			return false;
		}
		RenderingGroupsLoader.MeshRenderGroup meshRenderGroup = RenderingGroupsLoader.meshRenderGroups[source.Value];
		Material material = meshRenderGroup.material;
		if (material == null || material.shader == null || material.shader.name != "RTS/Props/Foliage")
		{
			if (rejected.Count < 2048)
			{
				rejected.Add(source);
			}
			return false;
		}
		if (RenderingGroupsLoader.meshRenderGroups.Count >= 65535)
		{
			return false;
		}
		Material material2 = null;
		bool flag = false;
		try
		{
			material2 = new Material(material);
			material2.name = material.name + " (fallen tree " + bin + ")";
			float num = (float)bin / 32f;
			string[] array = new string[3] { "_Clip", "_ClippingShadow", "_ClippingImpostor" };
			foreach (string name in array)
			{
				if (material.HasProperty(name))
				{
					float num2 = material.GetFloat(name);
					material2.SetFloat(name, num2 + (1.001f - num2) * num);
				}
			}
			if (bin == 32 && material.HasProperty("_BaseColor"))
			{
				Color color = material.GetColor("_BaseColor");
				color.a = 0f;
				material2.SetColor("_BaseColor", color);
			}
			target = RenderingGroupsLoader.CreateMeshRenderGroup(meshRenderGroup.mesh, material2, meshRenderGroup.shadowCastingMode);
			flag = true;
			materials.Add(material2);
			if (value == null)
			{
				value = new RenderGroupID[33];
				for (int j = 0; j < value.Length; j++)
				{
					value[j] = new RenderGroupID(ushort.MaxValue);
				}
				value[0] = source;
				families.Add(source, value);
			}
			value[bin] = target;
			originals.Add(target, source);
			return true;
		}
		catch (Exception ex)
		{
			if (material2 != null && !flag)
			{
				UnityEngine.Object.Destroy(material2);
			}
			if (rejected.Count < 2048)
			{
				rejected.Add(source);
			}
			Report("Tree fade material retained native rendering: " + ex.Message);
			target = source;
			return false;
		}
	}

	private static void Forget(int index, LocalID id)
	{
		known.Remove(id);
		treeLODs.Remove(id);
		active.RemoveAt(index);
	}

	public static void Clear()
	{
		foreach (Material material in materials)
		{
			UnityEngine.Object.Destroy(material);
		}
		materials.Clear();
		active.Clear();
		known.Clear();
		families.Clear();
		originals.Clear();
		rejected.Clear();
		treeLODs.Clear();
		owner = null;
		query = default(EntityQuery);
		queryReady = false;
		lastDiscovery = double.NegativeInfinity;
		reported = false;
	}

	public static void Destroy(TxRenderSystem_MeshRenderingSystem system)
	{
		if (owner == system)
		{
			Clear();
		}
	}

	public static void Restore()
	{
		if (owner == null || !ClientEngine.Data.localEngineData.localWorld.IsCreated)
		{
			return;
		}
		ClientEngine.Data.localEngineData.localDependency.Complete();
		foreach (LocalID item in active)
		{
			if (ClientEngine.TryGetLocalComponentRW(item, out ComponentRefRW<RendererComponent> component))
			{
				RestoreTree(item, ref component.ValueRW);
			}
		}
	}

	private static void Report(string message)
	{
		if (!reported)
		{
			reported = true;
			Debug.LogError("[SCOM tree decay] " + message);
		}
	}
}
