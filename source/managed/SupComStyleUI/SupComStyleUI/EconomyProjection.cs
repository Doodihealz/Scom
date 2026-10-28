using System;
using SanctuaryUI;

namespace SupComStyleUI;

internal static class EconomyProjection
{
	private const float RateEpsilon = 0.01f;

	internal static ResourceProjection ForEnergy(in UIEconomyValues values)
	{
		return Create(values.energyStorageCurrent, values.energyStorageLimit, values.energyGeneratedIncome, values.energyRequestedTotal, values.energyRequestedStalled);
	}

	internal static ResourceProjection ForAlloy(in UIEconomyValues values)
	{
		return Create(values.alloyStorageCurrent, values.alloyStorageLimit, values.alloyGeneratedIncome, values.alloyRequestedTotal, values.alloyRequestedStalled);
	}

	private static ResourceProjection Create(float current, float capacity, float generated, float requestedTotal, float requestedStalled)
	{
		if (!IsFinite(current) || !IsFinite(capacity) || !IsFinite(generated) || !IsFinite(requestedTotal) || !IsFinite(requestedStalled) || capacity <= 0f)
		{
			return new ResourceProjection(0f, 0f, 0f, EconomyRunwayState.Unavailable, 0.0);
		}
		current = Math.Max(0f, Math.Min(current, capacity));
		float num = ((current < 0.5f) ? requestedTotal : requestedStalled);
		float num2 = generated + num;
		if (!IsFinite(num2))
		{
			return new ResourceProjection(current, capacity, 0f, EconomyRunwayState.Unavailable, 0.0);
		}
		if (current <= 0.001f && num2 <= 0.01f)
		{
			return new ResourceProjection(current, capacity, num2, EconomyRunwayState.Empty, 0.0);
		}
		if (num2 < -0.01f)
		{
			return new ResourceProjection(current, capacity, num2, EconomyRunwayState.Draining, (double)current / (0.0 - (double)num2));
		}
		if (current >= capacity - 0.001f)
		{
			return new ResourceProjection(current, capacity, num2, EconomyRunwayState.Full, 0.0);
		}
		if (num2 > 0.01f)
		{
			return new ResourceProjection(current, capacity, num2, EconomyRunwayState.Filling, (capacity - current) / num2);
		}
		return new ResourceProjection(current, capacity, num2, EconomyRunwayState.Stable, 0.0);
	}

	private static bool IsFinite(float value)
	{
		if (!float.IsNaN(value))
		{
			return !float.IsInfinity(value);
		}
		return false;
	}
}
