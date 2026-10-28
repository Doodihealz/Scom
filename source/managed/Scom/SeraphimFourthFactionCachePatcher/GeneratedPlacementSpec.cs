namespace SeraphimFourthFactionCachePatcher;

internal sealed class GeneratedPlacementSpec
{
	public string FootprintSource { get; }

	public double FootprintX { get; }

	public double FootprintZ { get; }

	public bool HasSourceSkirt { get; }

	public double SkirtX { get; }

	public double SkirtZ { get; }

	public double SkirtOffsetX { get; }

	public double SkirtOffsetZ { get; }

	public GeneratedPlacementSpec(string footprintSource, double footprintX, double footprintZ, bool hasSourceSkirt, double skirtX, double skirtZ, double skirtOffsetX, double skirtOffsetZ)
	{
		FootprintSource = footprintSource;
		FootprintX = footprintX;
		FootprintZ = footprintZ;
		HasSourceSkirt = hasSourceSkirt;
		SkirtX = skirtX;
		SkirtZ = skirtZ;
		SkirtOffsetX = skirtOffsetX;
		SkirtOffsetZ = skirtOffsetZ;
	}
}
