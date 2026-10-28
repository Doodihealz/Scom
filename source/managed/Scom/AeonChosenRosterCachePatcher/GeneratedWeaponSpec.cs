namespace AeonChosenRosterCachePatcher;

internal sealed class GeneratedWeaponSpec
{
	internal string Label { get; }

	internal string SourceCategory { get; }

	internal bool IsDeath { get; }

	internal bool IsBeam { get; }

	internal string AimBone { get; }

	internal string YawBone { get; }

	internal string PitchBone { get; }

	internal string SpecialMuzzleBone { get; }

	internal GeneratedRackSpec[] Racks { get; }

	internal bool RackFireTogether { get; }

	internal int RackSalvoSize { get; }

	internal int MuzzleSalvoSize { get; }

	internal double MuzzleSalvoDelay { get; }

	internal double RackChargeDelay { get; }

	internal double RackTimeout { get; }

	internal int ProjectilesPerFire { get; }

	internal double Damage { get; }

	internal double DamageRadius { get; }

	internal double RangeMin { get; }

	internal double RangeMax { get; }

	internal double RateOfFire { get; }

	internal double ReloadTime { get; }

	internal double ProjectileSpeed { get; }

	internal double ProjectileLifetime { get; }

	internal string SourceProjectile { get; }

	internal string ProjectileTemplate { get; }

	internal string RangeRingType { get; }

	internal string[] TargetLayers { get; }

	internal string TargetWaterLimits { get; }

	internal string SolverType { get; }

	internal double YawRange { get; }

	internal double YawSpeed { get; }

	internal bool HasHeadingArc { get; }

	internal double HeadingArcCenter { get; }

	internal double HeadingArcRange { get; }

	internal double PitchRange { get; }

	internal double PitchSpeed { get; }

	internal double FiringTolerance { get; }

	internal double DefaultYaw { get; }

	internal double DefaultPitch { get; }

	internal double BeamLifetime { get; }

	internal GeneratedWeaponSpec(string label, string sourceCategory, bool isDeath, bool isBeam, string aimBone, string yawBone, string pitchBone, string specialMuzzleBone, GeneratedRackSpec[] racks, bool rackFireTogether, int rackSalvoSize, int muzzleSalvoSize, double muzzleSalvoDelay, double rackChargeDelay, double rackTimeout, int projectilesPerFire, double damage, double damageRadius, double rangeMin, double rangeMax, double rateOfFire, double reloadTime, double projectileSpeed, double projectileLifetime, string sourceProjectile, string projectileTemplate, string rangeRingType, string[] targetLayers, string targetWaterLimits, string solverType, double yawRange, double yawSpeed, bool hasHeadingArc, double headingArcCenter, double headingArcRange, double pitchRange, double pitchSpeed, double firingTolerance, double defaultYaw, double defaultPitch, double beamLifetime)
	{
		Label = label;
		SourceCategory = sourceCategory;
		IsDeath = isDeath;
		IsBeam = isBeam;
		AimBone = aimBone;
		YawBone = yawBone;
		PitchBone = pitchBone;
		SpecialMuzzleBone = specialMuzzleBone;
		Racks = racks;
		RackFireTogether = rackFireTogether;
		RackSalvoSize = rackSalvoSize;
		MuzzleSalvoSize = muzzleSalvoSize;
		MuzzleSalvoDelay = muzzleSalvoDelay;
		RackChargeDelay = rackChargeDelay;
		RackTimeout = rackTimeout;
		ProjectilesPerFire = projectilesPerFire;
		Damage = damage;
		DamageRadius = damageRadius;
		RangeMin = rangeMin;
		RangeMax = rangeMax;
		RateOfFire = rateOfFire;
		ReloadTime = reloadTime;
		ProjectileSpeed = projectileSpeed;
		ProjectileLifetime = projectileLifetime;
		SourceProjectile = sourceProjectile;
		ProjectileTemplate = projectileTemplate;
		RangeRingType = rangeRingType;
		TargetLayers = targetLayers;
		TargetWaterLimits = targetWaterLimits;
		SolverType = solverType;
		YawRange = yawRange;
		YawSpeed = yawSpeed;
		HasHeadingArc = hasHeadingArc;
		HeadingArcCenter = headingArcCenter;
		HeadingArcRange = headingArcRange;
		PitchRange = pitchRange;
		PitchSpeed = pitchSpeed;
		FiringTolerance = firingTolerance;
		DefaultYaw = defaultYaw;
		DefaultPitch = defaultPitch;
		BeamLifetime = beamLifetime;
	}
}
