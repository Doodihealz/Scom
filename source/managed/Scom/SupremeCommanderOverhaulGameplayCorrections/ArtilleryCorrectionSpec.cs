namespace SupremeCommanderOverhaulGameplayCorrections;

public sealed class ArtilleryCorrectionSpec
{
	public string TargetId { get; }

	public string ProjectileId { get; }

	public double RangeMin { get; }

	public double ReloadTime { get; }

	public bool ReduceVelocity { get; }

	public double ProjectileLifetime { get; }

	public string? AimBone { get; }

	public string? OldYawBone { get; }

	public string? YawBone { get; }

	public string? PitchBone { get; }

	public string? OldPitchBone { get; }

	public double? DefaultPitchAdjustment { get; }

	public ArtilleryCorrectionSpec(string targetId, string projectileId, double rangeMin, double reloadTime, bool reduceVelocity, double projectileLifetime, string? aimBone = null, string? oldYawBone = null, string? yawBone = null, string? pitchBone = null, double? defaultPitchAdjustment = null, string? oldPitchBone = null)
	{
		TargetId = targetId;
		ProjectileId = projectileId;
		RangeMin = rangeMin;
		ReloadTime = reloadTime;
		ReduceVelocity = reduceVelocity;
		ProjectileLifetime = projectileLifetime;
		AimBone = aimBone;
		OldYawBone = oldYawBone;
		YawBone = yawBone;
		PitchBone = pitchBone;
		OldPitchBone = oldPitchBone ?? pitchBone;
		DefaultPitchAdjustment = defaultPitchAdjustment;
	}
}
