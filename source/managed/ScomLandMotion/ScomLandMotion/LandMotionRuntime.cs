using System;
using System.Collections.Generic;
using BepInEx.Logging;
using EM.Components;
using EM.Core;
using EM.Engine;
using EM.Entities;
using EM.Pathfinding;
using Unity.Collections;
using Unity.Mathematics;

namespace ScomLandMotion;

internal sealed class LandMotionRuntime
{
	private sealed class Entry
	{
		public LandPoseFilter.State Filter;

		public LocalID LocalId;

		public uint Frame;

		public bool HasSampledUp;

		public float2 SamplePosition;

		public float2 SampleHeading;

		public int SampleTick;

		public float SampleAlignment;

		public float3 SampledUp;
	}

	private struct OriginalPose
	{
		public LocalID Id;

		public LocalTransform Raw;

		public LocalTransform Filtered;
	}

	private readonly ManualLogSource log;

	private readonly Dictionary<GlobalID, Entry> states = new Dictionary<GlobalID, Entry>();

	private readonly Dictionary<ushort, bool> defaultEligibility = new Dictionary<ushort, bool>();

	private readonly List<OriginalPose> originals = new List<OriginalPose>();

	private readonly List<GlobalID> stale = new List<GlobalID>();

	private bool enabled = true;

	private double previousSimTime = double.NaN;

	private uint frame;

	internal LandMotionRuntime(ManualLogSource logSource)
	{
		log = logSource;
	}

	internal void BeforeInterpolation(ref LocalEngineData data)
	{
		if (!enabled)
		{
			return;
		}
		try
		{
			data.localDependency.Complete();
			Restore(ref data.localWorld);
		}
		catch (Exception exception)
		{
			Disable(exception);
		}
	}

	internal void AfterInterpolation(ref LocalEngineData data)
	{
		if (!enabled || !data.localWorld.IsCreated || !data.bufferedWorld.IsCreated)
		{
			return;
		}
		try
		{
			data.localDependency.Complete();
			data.bufferedDependency.Complete();
			double simTime = data.localTime.simTime;
			float num = (double.IsNaN(previousSimTime) ? 0f : ((float)(simTime - previousSimTime)));
			if (!double.IsNaN(previousSimTime) && (num < 0f || num > 0.25f))
			{
				states.Clear();
			}
			previousSimTime = simTime;
			frame++;
			ref World localWorld = ref data.localWorld;
			ref World bufferedWorld = ref data.bufferedWorld;
			InstanceEnumerator enumerator = localWorld.QueryInstances(EntityQuery.Of<LocalPairedGlobalIDComponent>().With<LocalTransform>()).GetEnumerator();
			while (enumerator.MoveNext())
			{
				Instance current = enumerator.Current;
				if (!current.HasComponent<InstanceParent>(0) || current.GetComponent<InstanceParent>(0).parentID.IsValid)
				{
					continue;
				}
				GlobalID value = current.GetComponent<LocalPairedGlobalIDComponent>(0).Value;
				if (!value.IsValid || !bufferedWorld.Exists(value))
				{
					continue;
				}
				Instance instance = bufferedWorld.GetInstance(value);
				if (!instance.HasComponent<MovementComponent>(0) || !instance.HasComponent<HealthComponent>(0) || !instance.HasComponent<InstanceParent>(0) || instance.GetComponent<InstanceParent>(0).parentID.IsValid)
				{
					continue;
				}
				MovementComponent component = instance.GetComponent<MovementComponent>(0);
				float health = instance.GetComponent<HealthComponent>(0).Health;
				if (!component.flags.IsEnabled() || !math.isfinite(health) || health <= 0f || (component.referenceAltitude != ReferenceAltitude.Ground && component.referenceAltitude != ReferenceAltitude.GroundOrWater) || !IsLandLayer(component.navigationLayer) || !IsDefaultLandMover(ref bufferedWorld, in instance))
				{
					continue;
				}
				LocalTransform component2 = current.GetComponent<LocalTransform>(0);
				ref TerrainSingleton terrainSingleton = ref ClientEngine.Data.terrainManager.terrainSingleton;
				if (!math.all(math.isfinite(component2.position)) || !math.all(math.isfinite(component2.rotation.value)) || !math.all(math.isfinite(component2.scale)) || !terrainSingleton.terrainHeightMap.IsCreated || terrainSingleton.heightmapSize.x < 2 || terrainSingleton.heightmapSize.y < 2 || (long)terrainSingleton.heightmapSize.x * (long)terrainSingleton.heightmapSize.y > terrainSingleton.terrainHeightMap.Length || !InBounds(maximum: new float2((float)terrainSingleton.heightmapSize.x - 1.001f, (float)terrainSingleton.heightmapSize.y - 1.001f), position: component2.position.xz))
				{
					continue;
				}
				float num2 = terrainSingleton.SampleHeight(component2.position.xz);
				if (math.isfinite(num2) && (!terrainSingleton.hasWater || !(num2 < terrainSingleton.waterLevel)))
				{
					LocalID entityID = current.GetEntityID<LocalID>(0);
					if (!states.TryGetValue(value, out var value2) || !value2.LocalId.Equals(entityID))
					{
						value2 = new Entry
						{
							LocalId = entityID
						};
						states[value] = value2;
					}
					value2.Frame = frame;
					bool flag = component.maxBankDegrees != 0f || component.rollDegrees != 0f;
					quaternion quaternion = component2.rotation;
					float num3 = math.cmax(math.abs(component2.scale.xz));
					float num4 = math.max(0.35f, component.collisionCapsuleBaseRadius * num3);
					float num5 = math.max(num4, (component.collisionCapsuleBaseRadius + component.collisionCapsuleLength * 0.5f) * num3);
					float2 @float = math.normalizesafe(math.mul(quaternion, math.forward()).xz, new float2(0f, 1f));
					int simTick = data.localTime.globalTime.simTick;
					if (!flag && (!value2.HasSampledUp || !math.all(value2.SamplePosition == component2.position.xz) || !math.all(value2.SampleHeading == @float) || value2.SampleTick != simTick || value2.SampleAlignment != component.terrainAlignmentFactor))
					{
						value2.SampledUp = SampleFootprintUp(in terrainSingleton, component2.position.xz, num2, @float, num4, num5, component.terrainAlignmentFactor, math.mul(quaternion, math.up()));
						value2.HasSampledUp = true;
						value2.SamplePosition = component2.position.xz;
						value2.SampleHeading = @float;
						value2.SampleTick = simTick;
						value2.SampleAlignment = component.terrainAlignmentFactor;
					}
					if (!flag)
					{
						quaternion = LandPoseFilter.WithUp(quaternion, value2.SampledUp);
					}
					float maximumTiltLagDegrees = ((component.terrainAlignmentFactor <= 0f || flag) ? 0f : math.min(3f, math.degrees(math.atan(0.04f / num5))));
					LandPoseFilter.Pose pose = LandPoseFilter.Update(ref value2.Filter, component2.position, quaternion, num, maximumTiltLagDegrees);
					LocalTransform component3 = component2;
					component3.position = pose.Position;
					component3.rotation = (flag ? component2.rotation : pose.Rotation);
					originals.Add(new OriginalPose
					{
						Id = entityID,
						Raw = component2,
						Filtered = component3
					});
					current.SetComponent(0, in component3);
				}
			}
			stale.Clear();
			foreach (KeyValuePair<GlobalID, Entry> state in states)
			{
				if (state.Value.Frame != frame)
				{
					stale.Add(state.Key);
				}
			}
			foreach (GlobalID item in stale)
			{
				states.Remove(item);
			}
		}
		catch (Exception ex)
		{
			try
			{
				Restore(ref data.localWorld);
			}
			catch (Exception ex2)
			{
				originals.Clear();
				ex = new AggregateException(ex, ex2);
			}
			Disable(ex);
		}
	}

	private unsafe bool IsDefaultLandMover(ref World world, in Instance instance)
	{
		PrefabID prefabID = instance.GetPrefabID(in world);
		if (defaultEligibility.TryGetValue(prefabID.Value, out var value))
		{
			return value;
		}
		InstanceArchetype archetype = world.GetArchetype(prefabID);
		int templateOffset = archetype.GetEntityComponentInfo(0, ComponentRegistry.IndexOf<MovementComponent>()).templateOffset;
		int num = sizeof(MovementComponent);
		if (archetype.instanceTemplate == null || templateOffset < 0 || num > archetype.instanceTemplateSize || templateOffset > archetype.instanceTemplateSize - num)
		{
			throw new InvalidOperationException("Movement template layout is outside its native allocation.");
		}
		MovementComponent movementComponent = *(MovementComponent*)(archetype.instanceTemplate + templateOffset);
		value = movementComponent.maxSpeed > 0f && IsLandLayer(movementComponent.navigationLayer);
		defaultEligibility[prefabID.Value] = value;
		return value;
	}

	private static bool IsLandLayer(int index)
	{
		NativeList<NavmapLayerConfig> layerConfiguration = ClientEngine.Data.globalEngineData.globalNavmapManager.layerConfiguration;
		if (!layerConfiguration.IsCreated || index < 0 || index >= layerConfiguration.Length)
		{
			return false;
		}
		FixedString64Bytes name = layerConfiguration[index].name;
		if (!name.Equals(new FixedString64Bytes("Land")) && !name.Equals(new FixedString64Bytes("Amphibious")))
		{
			return name.Equals(new FixedString64Bytes("Hover"));
		}
		return true;
	}

	private static float3 SampleFootprintUp(in TerrainSingleton terrain, float2 position, float centerHeight, float2 heading, float halfWidth, float halfLength, float alignment, float3 fallback)
	{
		if (alignment <= 0f)
		{
			return math.up();
		}
		float2 @float = new float2(heading.y, 0f - heading.x);
		float2 float2 = position - @float * halfWidth;
		float2 float3 = position + @float * halfWidth;
		float2 float4 = position - heading * halfLength;
		float2 float5 = position + heading * halfLength;
		float2 upperBound = new float2((float)terrain.heightmapSize.x - 1.001f, (float)terrain.heightmapSize.y - 1.001f);
		float2 float6 = math.clamp(float2, float2.zero, upperBound);
		float2 float7 = math.clamp(float3, float2.zero, upperBound);
		float2 float8 = math.clamp(float4, float2.zero, upperBound);
		float2 float9 = math.clamp(float5, float2.zero, upperBound);
		if (!math.all(float2 == float6) || !math.all(float3 == float7) || !math.all(float4 == float8) || !math.all(float5 == float9))
		{
			return fallback;
		}
		float num = terrain.SampleHeight(float2);
		float num2 = terrain.SampleHeight(float3);
		float num3 = terrain.SampleHeight(float4);
		float num4 = terrain.SampleHeight(float5);
		if (!math.all(math.isfinite(new float4(num, num2, num3, num4))))
		{
			return fallback;
		}
		float3 end = LandPoseFilter.SampledUp(num, num2, num3, num4, halfWidth, halfLength, heading);
		float3 sampledUp = math.normalizesafe(math.lerp(math.up(), end, math.saturate(alignment)), fallback);
		float deviation = LandPoseFilter.FootprintDeviation(centerHeight, num, num2, num3, num4);
		return LandPoseFilter.BlendTerrainUp(sampledUp, fallback, deviation);
	}

	private static bool InBounds(float2 position, float2 maximum)
	{
		if (math.all(position >= 0f))
		{
			return math.all(position <= maximum);
		}
		return false;
	}

	private void Restore(ref World world)
	{
		if (world.IsCreated)
		{
			foreach (OriginalPose original in originals)
			{
				OriginalPose current = original;
				if (world.TryGetComponent<LocalTransform, LocalID>(current.Id, out var component) && (!world.TryGetComponent<InstanceParent, LocalID>(current.Id, out var component2) || !component2.parentID.IsValid) && math.all(component.position == current.Filtered.position) && math.all(component.rotation.value == current.Filtered.rotation.value) && math.all(component.scale == current.Filtered.scale))
				{
					world.SetComponent(current.Id, in current.Raw);
				}
			}
		}
		originals.Clear();
	}

	internal void Clear(ref LocalEngineData data, bool restore)
	{
		try
		{
			if (restore && data.localWorld.IsCreated)
			{
				data.localDependency.Complete();
				Restore(ref data.localWorld);
			}
		}
		catch (Exception exception)
		{
			Disable(exception);
		}
		originals.Clear();
		states.Clear();
		defaultEligibility.Clear();
		stale.Clear();
		previousSimTime = double.NaN;
		frame = 0u;
	}

	internal void Disable(Exception exception)
	{
		if (enabled)
		{
			enabled = false;
			states.Clear();
			log.LogWarning("Land motion disabled after " + exception.GetType().Name + ": " + exception.Message + "; native movement remains active.");
		}
	}
}
