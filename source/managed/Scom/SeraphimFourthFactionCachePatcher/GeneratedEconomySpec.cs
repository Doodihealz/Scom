namespace SeraphimFourthFactionCachePatcher;

internal sealed class GeneratedEconomySpec
{
	public double BuildCostMass { get; }

	public double BuildCostEnergy { get; }

	public double BuildTime { get; }

	public double BuildRate { get; }

	public double ProductionMass { get; }

	public double ProductionEnergy { get; }

	public double MaintenanceMass { get; }

	public double MaintenanceEnergy { get; }

	public double StorageMass { get; }

	public double StorageEnergy { get; }

	public GeneratedEconomySpec(double buildCostMass, double buildCostEnergy, double buildTime, double buildRate, double productionMass, double productionEnergy, double maintenanceMass, double maintenanceEnergy, double storageMass, double storageEnergy)
	{
		BuildCostMass = buildCostMass;
		BuildCostEnergy = buildCostEnergy;
		BuildTime = buildTime;
		BuildRate = buildRate;
		ProductionMass = productionMass;
		ProductionEnergy = productionEnergy;
		MaintenanceMass = maintenanceMass;
		MaintenanceEnergy = maintenanceEnergy;
		StorageMass = storageMass;
		StorageEnergy = storageEnergy;
	}
}
