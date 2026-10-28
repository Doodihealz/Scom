namespace CommanderEnhancementsCachePatcher;

internal sealed class CommanderBaseStats
{
	internal double MaxHealth { get; }

	internal double RegenRate { get; }

	internal double BuildRate { get; }

	internal double EnergyProduction { get; }

	internal double MassProduction { get; }

	internal double VisionRadius { get; }

	internal double OmniRadius { get; }

	internal double? SonarRadius { get; }

	internal double BuildCostMass { get; }

	internal double BuildCostEnergy { get; }

	internal double BuildTime { get; }

	internal double SizeX { get; }

	internal double SizeY { get; }

	internal double SizeZ { get; }

	internal CommanderBaseStats(double maxHealth, double regenRate, double buildRate, double energyProduction, double massProduction, double visionRadius, double omniRadius, double? sonarRadius, double buildCostMass, double buildCostEnergy, double buildTime, double sizeX, double sizeY, double sizeZ)
	{
		MaxHealth = maxHealth;
		RegenRate = regenRate;
		BuildRate = buildRate;
		EnergyProduction = energyProduction;
		MassProduction = massProduction;
		VisionRadius = visionRadius;
		OmniRadius = omniRadius;
		SonarRadius = sonarRadius;
		BuildCostMass = buildCostMass;
		BuildCostEnergy = buildCostEnergy;
		BuildTime = buildTime;
		SizeX = sizeX;
		SizeY = sizeY;
		SizeZ = sizeZ;
	}
}
