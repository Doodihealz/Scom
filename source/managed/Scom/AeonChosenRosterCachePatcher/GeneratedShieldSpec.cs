namespace AeonChosenRosterCachePatcher;

internal sealed class GeneratedShieldSpec
{
	internal bool Enabled { get; }

	internal bool? Personal { get; }

	internal double MaxHealth { get; }

	internal double RechargeTime { get; }

	internal double RegenRate { get; }

	internal double RegenStartTime { get; }

	internal double Size { get; }

	internal double RuntimeRadius { get; }

	internal double VerticalOffset { get; }

	internal double EnergyDrainRechargeTime { get; }

	internal GeneratedShieldSpec(bool enabled, bool? personal, double maxHealth, double rechargeTime, double regenRate, double regenStartTime, double size, double runtimeRadius, double verticalOffset, double energyDrainRechargeTime)
	{
		Enabled = enabled;
		Personal = personal;
		MaxHealth = maxHealth;
		RechargeTime = rechargeTime;
		RegenRate = regenRate;
		RegenStartTime = regenStartTime;
		Size = size;
		RuntimeRadius = runtimeRadius;
		VerticalOffset = verticalOffset;
		EnergyDrainRechargeTime = energyDrainRechargeTime;
	}
}
