namespace AeonChosenRosterCachePatcher;

internal sealed class GeneratedCzarBeamHook
{
	internal bool Enabled { get; }

	internal string CenterBone { get; }

	internal string ImpactEffect { get; }

	internal string BeamMaterial { get; }

	internal double DirectionX { get; }

	internal double DirectionY { get; }

	internal double DirectionZ { get; }

	internal double Damage { get; }

	internal double DamageInterval { get; }

	internal double DamageRadius { get; }

	internal double RayLength { get; }

	internal double AcquisitionRange { get; }

	internal double ReloadTime { get; }

	internal GeneratedCzarBeamHook(bool enabled, string centerBone, string impactEffect, string beamMaterial, double directionX, double directionY, double directionZ, double damage, double damageInterval, double damageRadius, double rayLength, double acquisitionRange, double reloadTime)
	{
		Enabled = enabled;
		CenterBone = centerBone;
		ImpactEffect = impactEffect;
		BeamMaterial = beamMaterial;
		DirectionX = directionX;
		DirectionY = directionY;
		DirectionZ = directionZ;
		Damage = damage;
		DamageInterval = damageInterval;
		DamageRadius = damageRadius;
		RayLength = rayLength;
		AcquisitionRange = acquisitionRange;
		ReloadTime = reloadTime;
	}
}
