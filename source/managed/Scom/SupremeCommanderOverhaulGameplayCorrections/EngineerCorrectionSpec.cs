namespace SupremeCommanderOverhaulGameplayCorrections;

public sealed class EngineerCorrectionSpec
{
	public string TargetId { get; }

	public string SourceId { get; }

	public bool DisableMalformedWaterAnimation { get; }

	public EngineerCorrectionSpec(string targetId, string sourceId, bool disableMalformedWaterAnimation)
	{
		TargetId = targetId;
		SourceId = sourceId;
		DisableMalformedWaterAnimation = disableMalformedWaterAnimation;
	}
}
