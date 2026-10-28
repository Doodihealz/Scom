namespace SupremeCommanderOverhaulAeonStructureMotion;

public sealed class StorageClipPin
{
	public string ClipName { get; }

	public string TemplateKey { get; }

	public string ResourceName { get; }

	public double DurationSeconds { get; }

	public double LocalZDelta { get; }

	public long StockAnimationBytes { get; }

	public string StockAnimationSha256 { get; }

	public StorageClipPin(string clipName, string templateKey, string resourceName, double durationSeconds, double localZDelta, long stockAnimationBytes, string stockAnimationSha256)
	{
		ClipName = clipName;
		TemplateKey = templateKey;
		ResourceName = resourceName;
		DurationSeconds = durationSeconds;
		LocalZDelta = localZDelta;
		StockAnimationBytes = stockAnimationBytes;
		StockAnimationSha256 = stockAnimationSha256;
	}
}
