using System;

namespace SupremeCommanderOverhaulIdleReset;

public sealed class TurretRestAdjustment
{
	public string UnitId { get; }

	public int WeaponIndex { get; }

	public int ControllerIndex { get; }

	public string ExpectedAimBone { get; }

	public string ExpectedYawBone { get; }

	public string ExpectedPitchBone { get; }

	public double ExpectedDefaultPitch { get; }

	public double RestDefaultPitch { get; }

	public TurretRestAdjustment(string unitId, int weaponIndex, int controllerIndex, string expectedAimBone, string expectedYawBone, string expectedPitchBone, double expectedDefaultPitch, double restDefaultPitch)
	{
		UnitId = unitId ?? throw new ArgumentNullException("unitId");
		WeaponIndex = weaponIndex;
		ControllerIndex = controllerIndex;
		ExpectedAimBone = expectedAimBone ?? throw new ArgumentNullException("expectedAimBone");
		ExpectedYawBone = expectedYawBone ?? throw new ArgumentNullException("expectedYawBone");
		ExpectedPitchBone = expectedPitchBone ?? throw new ArgumentNullException("expectedPitchBone");
		ExpectedDefaultPitch = expectedDefaultPitch;
		RestDefaultPitch = restDefaultPitch;
	}
}
