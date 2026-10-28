using System;
using System.Collections.Generic;
using EM.Components;
using EM.Core;
using EM.DOTS.Engine.Loader;
using EM.Engine;
using EM.Engine.Rendering;
using EM.Entities;
using ScomGroundMotion;
using Unity.Mathematics;
using UnityEngine;

namespace ScomFatboyTracks;

public static class TrackRuntime
{
	private sealed class Source
	{
		internal RenderingGroupsLoader.SkinnedMeshRenderGroup Group;

		internal RenderGroupID Id;

		internal int Index;

		internal Profile Profile;

		internal Vector2[] RestUV;

		internal readonly Stack<Slot> Free = new Stack<Slot>();

		internal bool Failed;
	}

	private sealed class Slot
	{
		internal Source Source;

		internal LocalID Entity;

		internal Mesh Mesh;

		internal RenderGroupID Group;

		internal Vector2[] UV;

		internal float[] Phase;

		internal float3 Position;

		internal float Heading;

		internal float NextUpdate;

		internal int Ordinal;

		internal bool Sampled;
	}

	private const float Interval = 0.05f;

	private static TxRenderSystem_SkinnedMeshRenderingSystem owner;

	private static EntityQuery query;

	private static readonly Dictionary<RenderGroupID, Source> sources = new Dictionary<RenderGroupID, Source>();

	private static readonly Dictionary<LocalID, Slot> assigned = new Dictionary<LocalID, Slot>();

	private static readonly List<Slot> owned = new List<Slot>();

	private static readonly List<Slot> releases = new List<Slot>();

	private static int scannedGroups;

	private static bool failed;

	private static bool limitReported;

	public static void Update(object system)
	{
		try
		{
			UpdateCore((TxRenderSystem_SkinnedMeshRenderingSystem)system);
		}
		catch (Exception ex)
		{
			if (!failed)
			{
				Debug.LogError("[SCOM ground motion] Bridge disabled: " + ex);
			}
			failed = true;
			try
			{
				RestoreOriginalGroups();
			}
			catch (Exception ex2)
			{
				Debug.LogError("[SCOM ground motion] Restore failed: " + ex2);
			}
		}
	}

	private static void UpdateCore(TxRenderSystem_SkinnedMeshRenderingSystem system)
	{
		if (owner == null)
		{
			owner = system;
			query = EntityQuery.Of<RendererComponent>().With<LocalToWorld>().With<SkinnedMeshEntityBoneOffsetComponent>();
		}
		if (owner != system || failed)
		{
			return;
		}
		World localWorld = ClientEngine.Data.localEngineData.localWorld;
		if (!localWorld.IsCreated)
		{
			return;
		}
		ClientEngine.Data.localEngineData.localDependency.Complete();
		DiscoverSources();
		if (sources.Count == 0)
		{
			return;
		}
		releases.Clear();
		foreach (Slot value3 in assigned.Values)
		{
			if (!localWorld.Exists(value3.Entity) || !localWorld.HasComponent<RendererComponent, LocalID>(value3.Entity))
			{
				releases.Add(value3);
				continue;
			}
			RendererComponent component = localWorld.GetComponent<RendererComponent, LocalID>(value3.Entity);
			if (value3.Source.Failed || component.Culled || (component.RenderGroupID != value3.Group && component.RenderGroupID != value3.Source.Id) || !localWorld.HasComponent<LocalToWorld, LocalID>(value3.Entity) || !localWorld.HasComponent<SkinnedMeshEntityBoneOffsetComponent, LocalID>(value3.Entity))
			{
				releases.Add(value3);
			}
		}
		foreach (Slot release in releases)
		{
			Release(release, localWorld);
		}
		releases.Clear();
		InstanceEnumerator enumerator3 = localWorld.QueryInstances(in query).GetEnumerator();
		while (enumerator3.MoveNext())
		{
			Instance current2 = enumerator3.Current;
			for (int i = 0; i < current2.GetEntities<RendererComponent>().Length; i++)
			{
				EntityIndex entity = current2.GetEntities<RendererComponent>()[i];
				if (!current2.HasComponent<LocalToWorld>(entity) || !current2.HasComponent<SkinnedMeshEntityBoneOffsetComponent>(entity))
				{
					continue;
				}
				LocalID entityID = current2.GetEntityID<LocalID>(entity);
				RendererComponent component2 = localWorld.GetComponent<RendererComponent, LocalID>(entityID);
				if (component2.Culled)
				{
					continue;
				}
				Source value2;
				if (assigned.TryGetValue(entityID, out var value))
				{
					value2 = value.Source;
				}
				else if (!sources.TryGetValue(component2.RenderGroupID, out value2))
				{
					continue;
				}
				if (value2.Failed)
				{
					continue;
				}
				try
				{
					if (value != null)
					{
						goto IL_02d7;
					}
					value = AcquireSlot(value2);
					if (value == null)
					{
						continue;
					}
					value.Entity = entityID;
					value.Sampled = false;
					Array.Clear(value.Phase, 0, value.Phase.Length);
					Array.Copy(value2.RestUV, value.UV, value2.RestUV.Length);
					value.Mesh.uv = value.UV;
					assigned.Add(entityID, value);
					goto IL_02d7;
					IL_02d7:
					if (component2.RenderGroupID != value.Group)
					{
						component2.RenderGroupID = value.Group;
						localWorld.SetComponent(entityID, in component2);
					}
					if (!value.Sampled)
					{
						Advance(value, localWorld.GetComponent<LocalToWorld, LocalID>(entityID));
						value.NextUpdate = Time.unscaledTime + 0.05f * (float)(1 + value.Ordinal % 4) * 0.25f;
					}
					else if (Time.unscaledTime >= value.NextUpdate)
					{
						Advance(value, localWorld.GetComponent<LocalToWorld, LocalID>(entityID));
						value.NextUpdate = Time.unscaledTime + 0.05f;
					}
				}
				catch (Exception error)
				{
					DisableSource(value2, localWorld, error);
				}
			}
		}
	}

	private static void DiscoverSources()
	{
		List<RenderingGroupsLoader.SkinnedMeshRenderGroup> skinnedMeshRenderGroups = RenderingGroupsLoader.skinnedMeshRenderGroups;
		for (int i = scannedGroups; i < skinnedMeshRenderGroups.Count; i++)
		{
			RenderingGroupsLoader.SkinnedMeshRenderGroup skinnedMeshRenderGroup = skinnedMeshRenderGroups[i];
			if (skinnedMeshRenderGroup.mesh == null)
			{
				continue;
			}
			Profile profile = FindProfile(skinnedMeshRenderGroup.mesh.name);
			if (profile != null)
			{
				try
				{
					Source source = new Source
					{
						Group = skinnedMeshRenderGroup,
						Id = new RenderGroupID((ushort)i),
						Index = i,
						Profile = profile
					};
					ValidateSource(source);
					ConfigureTextures(source);
					sources.Add(source.Id, source);
					Debug.Log("[SCOM ground motion] Ready: " + profile.MeshName + " group " + i + ", " + profile.Bands.Length + " bands.");
				}
				catch (Exception ex)
				{
					Debug.LogWarning("[SCOM ground motion] Skipped " + profile.MeshName + " group " + i + ": " + ex.Message);
				}
			}
		}
		scannedGroups = skinnedMeshRenderGroups.Count;
	}

	private static Profile FindProfile(string name)
	{
		Profile[] all = GroundProfiles.All;
		foreach (Profile profile in all)
		{
			if (profile.MeshName == name)
			{
				return profile;
			}
		}
		return null;
	}

	private static bool Finite(float value)
	{
		if (!float.IsNaN(value))
		{
			return !float.IsInfinity(value);
		}
		return false;
	}

	private static void ValidateSource(Source source)
	{
		Profile profile = source.Profile;
		Mesh mesh = source.Group.mesh;
		if (!mesh.isReadable || mesh.vertexCount != profile.VertexCount || source.Group.model == null || source.Group.model.bindposes.Length != profile.BindPoseCount || source.Group.skeleton == null)
		{
			throw new InvalidOperationException("Mesh or skeleton identity changed.");
		}
		source.RestUV = mesh.uv;
		if (source.RestUV.Length != profile.VertexCount || profile.Bands == null || profile.Bands.Length == 0)
		{
			throw new InvalidOperationException("UV profile is incomplete.");
		}
		HashSet<int> hashSet = new HashSet<int>();
		Band[] bands = profile.Bands;
		foreach (Band band in bands)
		{
			if (band.Axis < 0 || band.Axis > 1 || !Finite(band.UVPerMetre) || band.UVPerMetre == 0f || !Finite(band.CenterX) || !Finite(band.Period) || band.Period <= 0f || band.Vertices == null || band.Vertices.Length == 0)
			{
				throw new InvalidOperationException("Band profile is invalid.");
			}
			int[] vertices = band.Vertices;
			foreach (int num in vertices)
			{
				if (num < 0 || num >= profile.VertexCount || !hashSet.Add(num))
				{
					throw new InvalidOperationException("Band indices are invalid or overlap.");
				}
				Vector2 vector = source.RestUV[num];
				if (!Finite(vector.x) || !Finite(vector.y))
				{
					throw new InvalidOperationException("Non-finite tread UV.");
				}
			}
		}
	}

	private static Slot AcquireSlot(Source source)
	{
		if (source.Free.Count != 0)
		{
			return source.Free.Pop();
		}
		if (RenderingGroupsLoader.skinnedMeshRenderGroups.Count >= 65535)
		{
			if (!limitReported)
			{
				Debug.LogWarning("[SCOM ground motion] Native 16-bit render-group capacity reached; unassigned units retain native rendering.");
			}
			limitReported = true;
			return null;
		}
		RenderingGroupsLoader.SkinnedMeshRenderGroup skinnedMeshRenderGroup = source.Group;
		Slot slot = new Slot
		{
			Source = source,
			Entity = LocalID.Null,
			Ordinal = owned.Count,
			UV = (Vector2[])source.RestUV.Clone(),
			Phase = new float[source.Profile.Bands.Length]
		};
		Mesh mesh = UnityEngine.Object.Instantiate(skinnedMeshRenderGroup.mesh);
		try
		{
			mesh.name = "SCOM animated ground instance";
			mesh.MarkDynamic();
			slot.Group = RenderingGroupsLoader.CreateSkinnedRenderingGroup(mesh, skinnedMeshRenderGroup.material, skinnedMeshRenderGroup.model, skinnedMeshRenderGroup.skeleton, skinnedMeshRenderGroup.shadowCastingMode);
			slot.Mesh = mesh;
			owned.Add(slot);
			return slot;
		}
		catch
		{
			UnityEngine.Object.Destroy(mesh);
			throw;
		}
	}

	private static void Advance(Slot slot, LocalToWorld transform)
	{
		float3 xyz = transform.value.c3.xyz;
		float3 xyz2 = transform.value.c2.xyz;
		float num = (float)Math.Atan2(xyz2.x, xyz2.z);
		if (!Finite(xyz.x) || !Finite(xyz.y) || !Finite(xyz.z) || !Finite(num))
		{
			slot.Sampled = false;
			return;
		}
		if (!slot.Sampled)
		{
			slot.Position = xyz;
			slot.Heading = num;
			slot.Sampled = true;
			return;
		}
		float num2 = WrapAngle(num - slot.Heading);
		float num3 = slot.Heading + num2 * 0.5f;
		float3 x = xyz - slot.Position;
		float num4 = x.x * (float)Math.Sin(num3) + x.z * (float)Math.Cos(num3);
		slot.Position = xyz;
		slot.Heading = num;
		if (math.lengthsq(x) > 16f || Math.Abs(num2) > 1f || (Math.Abs(num4) < 1E-05f && Math.Abs(num2) < 1E-05f))
		{
			return;
		}
		Band[] bands = slot.Source.Profile.Bands;
		for (int i = 0; i < bands.Length; i++)
		{
			Band band = bands[i];
			float num5 = AdvancePhase(slot.Phase[i], num4, num2, band.CenterX, band.UVPerMetre, band.Period);
			slot.Phase[i] = num5;
			int[] vertices = band.Vertices;
			foreach (int num6 in vertices)
			{
				if (band.Axis == 0)
				{
					slot.UV[num6].x = slot.Source.RestUV[num6].x + num5;
				}
				else
				{
					slot.UV[num6].y = slot.Source.RestUV[num6].y + num5;
				}
			}
		}
		slot.Mesh.uv = slot.UV;
	}

	public static float AdvancePhase(float phase, float forward, float yaw, float trackX, float uvPerMetre, float period)
	{
		float num = phase + (forward - yaw * trackX) * uvPerMetre;
		return num - (float)Math.Floor(num / period) * period;
	}

	public static float WrapAngle(float angle)
	{
		return (float)Math.Atan2(Math.Sin(angle), Math.Cos(angle));
	}

	private static void ConfigureTextures(Source source)
	{
		bool flag = false;
		bool flag2 = false;
		Band[] bands = source.Profile.Bands;
		foreach (Band band in bands)
		{
			flag |= band.Axis == 0;
			flag2 |= band.Axis == 1;
		}
		string[] textureProperties = source.Profile.TextureProperties;
		Texture[] array = new Texture[textureProperties.Length];
		for (int j = 0; j < textureProperties.Length; j++)
		{
			array[j] = source.Group.material.GetTexture(textureProperties[j]);
			if (array[j] == null)
			{
				throw new InvalidOperationException("Texture missing: " + textureProperties[j]);
			}
		}
		TextureQuality[] textureQuality = source.Profile.TextureQuality;
		foreach (TextureQuality textureQuality2 in textureQuality)
		{
			if (!source.Group.material.HasProperty(textureQuality2.Property))
			{
				throw new InvalidOperationException("Texture property missing: " + textureQuality2.Property);
			}
			Texture texture = source.Group.material.GetTexture(textureQuality2.Property);
			if (texture == null || (!string.Equals(texture.name, textureQuality2.ExpectedName, StringComparison.OrdinalIgnoreCase) && !string.Equals(texture.name, textureQuality2.ExpectedName + ".dds", StringComparison.OrdinalIgnoreCase)))
			{
				throw new InvalidOperationException("Texture identity changed: " + textureQuality2.Property);
			}
		}
		textureQuality = source.Profile.TextureQuality;
		foreach (TextureQuality textureQuality3 in textureQuality)
		{
			Texture texture2 = source.Group.material.GetTexture(textureQuality3.Property);
			texture2.anisoLevel = textureQuality3.AnisoLevel;
			texture2.filterMode = (FilterMode)textureQuality3.FilterMode;
			texture2.mipMapBias = textureQuality3.MipMapBias;
		}
		Texture[] array2 = array;
		foreach (Texture texture3 in array2)
		{
			if (flag)
			{
				texture3.wrapModeU = TextureWrapMode.Repeat;
			}
			if (flag2)
			{
				texture3.wrapModeV = TextureWrapMode.Repeat;
			}
		}
	}

	private static void Release(Slot slot, World manager)
	{
		if (manager.Exists(slot.Entity) && manager.HasComponent<RendererComponent, LocalID>(slot.Entity))
		{
			RendererComponent component = manager.GetComponent<RendererComponent, LocalID>(slot.Entity);
			if (component.RenderGroupID == slot.Group)
			{
				component.RenderGroupID = slot.Source.Id;
				manager.SetComponent(slot.Entity, in component);
			}
		}
		assigned.Remove(slot.Entity);
		slot.Entity = LocalID.Null;
		slot.Sampled = false;
		slot.Source.Free.Push(slot);
	}

	private static void DisableSource(Source source, World manager, Exception error)
	{
		if (!source.Failed)
		{
			Debug.LogWarning("[SCOM ground motion] Disabled source " + source.Profile.MeshName + " group " + source.Index + ": " + error.Message);
		}
		source.Failed = true;
		releases.Clear();
		foreach (Slot value in assigned.Values)
		{
			if (value.Source == source)
			{
				releases.Add(value);
			}
		}
		foreach (Slot release in releases)
		{
			Release(release, manager);
		}
		releases.Clear();
	}

	private static void RestoreOriginalGroups()
	{
		if (owner == null || !ClientEngine.Data.localEngineData.localWorld.IsCreated)
		{
			return;
		}
		World localWorld = ClientEngine.Data.localEngineData.localWorld;
		if (!localWorld.IsCreated)
		{
			return;
		}
		ClientEngine.Data.localEngineData.localDependency.Complete();
		releases.Clear();
		releases.AddRange(assigned.Values);
		foreach (Slot release in releases)
		{
			Release(release, localWorld);
		}
		releases.Clear();
	}

	public static void Destroy(object system)
	{
		if (owner != system)
		{
			return;
		}
		query = default(EntityQuery);
		foreach (Slot item in owned)
		{
			UnityEngine.Object.Destroy(item.Mesh);
		}
		assigned.Clear();
		owned.Clear();
		sources.Clear();
		releases.Clear();
		owner = null;
		scannedGroups = 0;
		failed = false;
		limitReported = false;
	}
}
