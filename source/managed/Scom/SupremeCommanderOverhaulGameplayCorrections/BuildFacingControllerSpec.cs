namespace SupremeCommanderOverhaulGameplayCorrections;

public sealed class BuildFacingControllerSpec
{
	public int Ordinal { get; }

	public string AimBone { get; }

	public string YawBone { get; }

	public string PitchBone { get; }

	public string YawEntity => "SCOBuildFacingYaw" + Ordinal;

	public string PitchEntity => "SCOBuildFacingPitch" + Ordinal;

	public BuildFacingControllerSpec(int ordinal, string aimBone, string yawBone, string pitchBone)
	{
		Ordinal = ordinal;
		AimBone = aimBone;
		YawBone = yawBone;
		PitchBone = pitchBone;
	}
}
