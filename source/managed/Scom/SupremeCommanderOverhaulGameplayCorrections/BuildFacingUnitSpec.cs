using System.Collections.Generic;

namespace SupremeCommanderOverhaulGameplayCorrections;

public sealed class BuildFacingUnitSpec
{
	public string TargetId { get; }

	public bool FaceWholeUnit { get; }

	public bool TorsoYawOnly
	{
		get
		{
			if (!(TargetId == "uel0000") && !(TargetId == "ugl0000") && !(TargetId == "ucl0000"))
			{
				return TargetId == "usl0000";
			}
			return true;
		}
	}

	public IReadOnlyList<BuildFacingControllerSpec> Controllers { get; }

	public BuildFacingUnitSpec(string targetId, bool faceWholeUnit, params BuildFacingControllerSpec[] controllers)
	{
		TargetId = targetId;
		FaceWholeUnit = faceWholeUnit;
		Controllers = controllers;
	}
}
