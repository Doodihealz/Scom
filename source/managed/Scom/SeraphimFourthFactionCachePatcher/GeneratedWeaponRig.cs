namespace SeraphimFourthFactionCachePatcher;

internal sealed class GeneratedWeaponRig
{
	public string AimBone { get; }

	public string YawBone { get; }

	public string PitchBone { get; }

	public string[] Muzzles { get; }

	public string ProjectileTemplate { get; }

	public string RangeRingType { get; }

	public string[] TargetLayers { get; }

	public string TargetWaterLimits { get; }

	public string SolverType { get; }

	public double Damage { get; }

	public double DamageRadius { get; }

	public double RangeMin { get; }

	public double RangeMax { get; }

	public double ReloadTime { get; }

	public double ProjectileSpeed { get; }

	public GeneratedWeaponRig(string aimBone, string yawBone, string pitchBone, string[] muzzles, string projectileTemplate, string rangeRingType, string[] targetLayers, string targetWaterLimits, string solverType, double damage, double damageRadius, double rangeMin, double rangeMax, double reloadTime, double projectileSpeed)
	{
		AimBone = aimBone;
		YawBone = yawBone;
		PitchBone = pitchBone;
		Muzzles = muzzles;
		ProjectileTemplate = projectileTemplate;
		RangeRingType = rangeRingType;
		TargetLayers = targetLayers;
		TargetWaterLimits = targetWaterLimits;
		SolverType = solverType;
		Damage = damage;
		DamageRadius = damageRadius;
		RangeMin = rangeMin;
		RangeMax = rangeMax;
		ReloadTime = reloadTime;
		ProjectileSpeed = projectileSpeed;
	}
}
