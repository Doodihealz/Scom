using System;

namespace SupremeCommanderOverhaulUpgradeAnimationFix;

internal sealed class ProgressAnimationSpec
{
	public string UnitId { get; }

	public string TemplatePath { get; }

	public string BindingKey { get; }

	public string SourceClip { get; }

	public string SourceAssetPath { get; }

	public long SourceAssetBytes { get; }

	public string SourceAssetSha256 { get; }

	public double SourceDurationSeconds { get; }

	public int SourceFrameCount { get; }

	public ProgressAnimationSpec(string unitId, string templatePath, string bindingKey, string sourceClip, string sourceAssetPath, long sourceAssetBytes, string sourceAssetSha256, double sourceDurationSeconds, int sourceFrameCount)
	{
		UnitId = unitId ?? throw new ArgumentNullException("unitId");
		TemplatePath = templatePath ?? throw new ArgumentNullException("templatePath");
		BindingKey = bindingKey ?? throw new ArgumentNullException("bindingKey");
		SourceClip = sourceClip ?? throw new ArgumentNullException("sourceClip");
		SourceAssetPath = sourceAssetPath ?? throw new ArgumentNullException("sourceAssetPath");
		SourceAssetBytes = sourceAssetBytes;
		SourceAssetSha256 = sourceAssetSha256 ?? throw new ArgumentNullException("sourceAssetSha256");
		SourceDurationSeconds = sourceDurationSeconds;
		SourceFrameCount = sourceFrameCount;
	}
}
