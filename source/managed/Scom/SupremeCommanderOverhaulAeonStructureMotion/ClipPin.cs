namespace SupremeCommanderOverhaulAeonStructureMotion;

public sealed class ClipPin
{
	public string ClipName { get; }

	public string TemplateKey { get; }

	public string Role { get; }

	public string SourcePath { get; }

	public long SourceBytes { get; }

	public string SourceSha256 { get; }

	public int SourceFrames { get; }

	public double SourceDurationSeconds { get; }

	public double SourceRate { get; }

	public ClipPin(string clipName, string templateKey, string role, string sourcePath, long sourceBytes, string sourceSha256, int sourceFrames, double sourceDurationSeconds, double sourceRate = 1.0)
	{
		ClipName = clipName;
		TemplateKey = templateKey;
		Role = role;
		SourcePath = sourcePath;
		SourceBytes = sourceBytes;
		SourceSha256 = sourceSha256;
		SourceFrames = sourceFrames;
		SourceDurationSeconds = sourceDurationSeconds;
		SourceRate = sourceRate;
	}
}
