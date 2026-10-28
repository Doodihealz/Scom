using System.Collections.Generic;

namespace SupremeCommanderOverhaulGameplayCorrections;

public sealed class EngineerBeamCorrectionSpec
{
	public string TargetId { get; }

	public string FactionTag { get; }

	public double OldShrink { get; }

	public string OldBoneName { get; }

	public IReadOnlyList<string> OldBuildBeamBones { get; }

	public string BoneName { get; }

	public IReadOnlyList<string> BuildBeamBones { get; }

	public EngineerBeamCorrectionSpec(string targetId, string factionTag, double oldShrink, string boneName, params string[] buildBeamBones)
		: this(targetId, factionTag, oldShrink, boneName, buildBeamBones, boneName, buildBeamBones)
	{
	}

	public EngineerBeamCorrectionSpec(string targetId, string factionTag, double oldShrink, string oldBoneName, string[] oldBuildBeamBones, string boneName, params string[] buildBeamBones)
	{
		TargetId = targetId;
		FactionTag = factionTag;
		OldShrink = oldShrink;
		OldBoneName = oldBoneName;
		OldBuildBeamBones = oldBuildBeamBones;
		BoneName = boneName;
		BuildBeamBones = buildBeamBones;
	}
}
