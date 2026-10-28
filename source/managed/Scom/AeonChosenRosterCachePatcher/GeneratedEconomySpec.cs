namespace AeonChosenRosterCachePatcher;

internal sealed class GeneratedEconomySpec
{
	internal double BuildTime { get; }

	internal double MassCost { get; }

	internal double EnergyCost { get; }

	internal double BuildRate { get; }

	internal double MassProduction { get; }

	internal double EnergyProduction { get; }

	internal double MassMaintenance { get; }

	internal double EnergyMaintenance { get; }

	internal double MassStorage { get; }

	internal double EnergyStorage { get; }

	internal GeneratedEconomySpec(double buildTime, double massCost, double energyCost, double buildRate, double massProduction, double energyProduction, double massMaintenance, double energyMaintenance, double massStorage, double energyStorage)
	{
		BuildTime = buildTime;
		MassCost = massCost;
		EnergyCost = energyCost;
		BuildRate = buildRate;
		MassProduction = massProduction;
		EnergyProduction = energyProduction;
		MassMaintenance = massMaintenance;
		EnergyMaintenance = energyMaintenance;
		MassStorage = massStorage;
		EnergyStorage = energyStorage;
	}
}
