namespace StructurePlacementContractCachePatcher;

internal sealed class PlacementSpec
{
	public PlacementFamily Family { get; }

	public string TargetId { get; }

	public string SourceUnitId { get; }

	public int SourceGridX { get; }

	public int SourceGridZ { get; }

	public PlacementPolicy Policy { get; }

	public int GridX { get; }

	public int GridZ { get; }

	public string RelativePath => "LJ/lua/common/units/unitsTemplates/" + TargetId + "/" + TargetId + ".santp";

	public PlacementSpec(PlacementFamily family, string targetId, string sourceUnitId, int sourceGridX, int sourceGridZ, PlacementPolicy policy, int gridX, int gridZ)
	{
		Family = family;
		TargetId = targetId;
		SourceUnitId = sourceUnitId;
		SourceGridX = sourceGridX;
		SourceGridZ = sourceGridZ;
		Policy = policy;
		GridX = gridX;
		GridZ = gridZ;
	}
}
