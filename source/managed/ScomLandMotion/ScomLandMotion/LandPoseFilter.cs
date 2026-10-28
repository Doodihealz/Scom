using Unity.Mathematics;

namespace ScomLandMotion;

public static class LandPoseFilter
{
	public struct State
	{
		public bool Initialized;

		public float3 PreviousRawPosition;

		public float Height;

		public float3 Up;
	}

	public struct Pose
	{
		public float3 Position;

		public quaternion Rotation;
	}

	public const float HalfLife = 0.08f;

	public const float MaximumSink = 0.015f;

	public const float MaximumHover = 0.12f;

	public const float MaximumTiltLagDegrees = 3f;

	public const float MaximumFrameSeconds = 0.25f;

	public const float TeleportDistance = 8f;

	public const float TeleportHeight = 3f;

	public const float NativeBlendStart = 0.06f;

	public const float NativeBlendEnd = 0.18f;

	public static float3 SampledUp(float leftHeight, float rightHeight, float backHeight, float frontHeight, float halfWidth, float halfLength, float2 heading)
	{
		heading = math.normalizesafe(heading, new float2(0f, 1f));
		float2 @float = new float2(heading.y, 0f - heading.x);
		float num = (rightHeight - leftHeight) / (2f * math.max(halfWidth, 0.001f));
		float num2 = (frontHeight - backHeight) / (2f * math.max(halfLength, 0.001f));
		float2 float2 = @float * num + heading * num2;
		return math.normalizesafe(new float3(0f - float2.x, 1f, 0f - float2.y), math.up());
	}

	public static quaternion WithUp(quaternion rawRotation, float3 up)
	{
		float2 y = math.normalizesafe(math.mul(rawRotation, math.forward()).xz, new float2(0f, 1f));
		float y2 = (0f - math.dot(up.xz, y)) / math.max(up.y, 0.2f);
		return quaternion.LookRotationSafe(math.normalize(new float3(y.x, y2, y.y)), up);
	}

	public static float FootprintDeviation(float centerHeight, float leftHeight, float rightHeight, float backHeight, float frontHeight)
	{
		return math.max(math.abs((leftHeight + rightHeight) * 0.5f - centerHeight), math.abs((backHeight + frontHeight) * 0.5f - centerHeight));
	}

	public static float3 BlendTerrainUp(float3 sampledUp, float3 nativeUp, float deviation)
	{
		float t = math.smoothstep(0.06f, 0.18f, deviation);
		return math.normalizesafe(math.lerp(sampledUp, nativeUp, t), nativeUp);
	}

	public static Pose Update(ref State state, float3 rawPosition, quaternion rawRotation, float deltaTime, float maximumTiltLagDegrees = 3f)
	{
		float3 @float = math.normalizesafe(math.mul(rawRotation, math.up()), math.up());
		bool flag = !math.all(math.isfinite(rawPosition)) || !math.all(math.isfinite(rawRotation.value)) || !math.isfinite(deltaTime) || @float.y < 0.2f;
		bool flag2 = !state.Initialized || deltaTime < 0f || deltaTime > 0.25f || math.lengthsq(rawPosition.xz - state.PreviousRawPosition.xz) > 64f || math.abs(rawPosition.y - state.PreviousRawPosition.y) > 3f;
		if (flag || flag2)
		{
			state = new State
			{
				Initialized = !flag,
				PreviousRawPosition = rawPosition,
				Height = rawPosition.y,
				Up = @float
			};
			return new Pose
			{
				Position = rawPosition,
				Rotation = rawRotation
			};
		}
		float t = 1f - math.pow(0.5f, deltaTime / 0.08f);
		float2 y = rawPosition.xz - state.PreviousRawPosition.xz;
		float start = state.Height - math.dot(state.Up.xz, y) / math.max(state.Up.y, 0.2f);
		state.Height = math.clamp(math.lerp(start, rawPosition.y, t), rawPosition.y - 0.015f, rawPosition.y + 0.12f);
		state.Up = math.normalizesafe(math.lerp(state.Up, @float, t), @float);
		float num = math.atan2(math.length(math.cross(state.Up, @float)), math.clamp(math.dot(state.Up, @float), -1f, 1f));
		float num2 = math.radians(math.clamp(maximumTiltLagDegrees, 0f, 3f));
		if (num > num2)
		{
			state.Up = math.normalizesafe(math.lerp(@float, state.Up, num2 / num), @float);
		}
		state.PreviousRawPosition = rawPosition;
		return new Pose
		{
			Position = new float3(rawPosition.x, state.Height, rawPosition.z),
			Rotation = WithUp(rawRotation, state.Up)
		};
	}
}
