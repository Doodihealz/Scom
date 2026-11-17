using System.Collections.Generic;

namespace SupComStyleUI;

internal sealed class UnitTooltipData
{
	public string TemplateId = string.Empty;

	public string Name = string.Empty;

	public string DisplayName = string.Empty;

	public string UnitTypeName = string.Empty;

	public string Tech = string.Empty;

	public float? Threat;

	public float? Health;

	public float? HealthRegen;

	public float? Shield;

	public float? ShieldRegen;

	public float? EnergyCost;

	public float? AlloyCost;

	public float? BuildTime;

	public float? EnergyProduction;

	public float? AlloyProduction;

	public float? EnergyMaintenance;

	public float? AlloyMaintenance;

	public float? EnergyStorage;

	public float? AlloyStorage;

	public string MovementType = string.Empty;

	public float? Speed;

	public float? Acceleration;

	public float? VisionRadius;

	public float? RadarRadius;

	public float? SonarRadius;

	public float? BuildPower;

	public float? BuildRange;

	public readonly List<string> Tags = new List<string>();

	public readonly List<UnitWeaponStats> Weapons = new List<UnitWeaponStats>();
}
