namespace SupremeCommanderOverhaulGameplayCorrections;

public sealed class CommanderBeamCorrectionSpec
{
	public string TargetId { get; }

	public string FactionTag { get; }

	public string? OldBoneName { get; }

	public double? OldShrink { get; }

	public string BoneName { get; }

	public CommanderBeamCorrectionSpec(string targetId, string factionTag, string? oldBoneName, double? oldShrink, string boneName)
	{
		TargetId = targetId;
		FactionTag = factionTag;
		OldBoneName = oldBoneName;
		OldShrink = oldShrink;
		BoneName = boneName;
	}
}
