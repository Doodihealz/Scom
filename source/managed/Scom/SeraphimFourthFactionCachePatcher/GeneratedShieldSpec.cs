namespace SeraphimFourthFactionCachePatcher;

internal sealed class GeneratedShieldSpec
{
	public double MaxHealth { get; }

	public double RegenRate { get; }

	public double RegenStartTime { get; }

	public double RechargeTime { get; }

	public double Size { get; }

	public double VerticalOffset { get; }

	public double EnergyDrainRechargeTime { get; }

	public GeneratedShieldSpec(double maxHealth, double regenRate, double regenStartTime, double rechargeTime, double size, double verticalOffset, double energyDrainRechargeTime)
	{
		MaxHealth = maxHealth;
		RegenRate = regenRate;
		RegenStartTime = regenStartTime;
		RechargeTime = rechargeTime;
		Size = size;
		VerticalOffset = verticalOffset;
		EnergyDrainRechargeTime = energyDrainRechargeTime;
	}
}
