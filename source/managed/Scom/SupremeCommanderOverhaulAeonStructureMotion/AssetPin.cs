namespace SupremeCommanderOverhaulAeonStructureMotion;

public sealed class AssetPin
{
	public string Path { get; }

	public long Bytes { get; }

	public string Sha256 { get; }

	public AssetPin(string path, long bytes, string sha256)
	{
		Path = path;
		Bytes = bytes;
		Sha256 = sha256;
	}
}
