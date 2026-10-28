namespace AeonChosenRosterCachePatcher;

internal sealed class GeneratedPlacementSpec
{
	internal string FootprintSource { get; }

	internal double FootprintX { get; }

	internal double FootprintZ { get; }

	internal bool HasSourceSkirt { get; }

	internal double SkirtX { get; }

	internal double SkirtZ { get; }

	internal double SkirtOffsetX { get; }

	internal double SkirtOffsetZ { get; }

	internal GeneratedPlacementSpec(string footprintSource, double footprintX, double footprintZ, bool hasSourceSkirt, double skirtX, double skirtZ, double skirtOffsetX, double skirtOffsetZ)
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
