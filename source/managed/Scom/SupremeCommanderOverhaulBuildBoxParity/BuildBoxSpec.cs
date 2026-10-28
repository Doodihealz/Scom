namespace SupremeCommanderOverhaulBuildBoxParity;

public sealed class BuildBoxSpec
{
	public string TargetId { get; }

	public string SourceId { get; }

	public int SizeX { get; }

	public int SizeZ { get; }

	public bool IsAeon { get; }

	public string RelativePath => "LJ/lua/common/units/unitsTemplates/" + TargetId + "/" + TargetId + ".santp";

	public BuildBoxSpec(string targetId, string sourceId, int sizeX, int sizeZ, bool isAeon = false)
	{
		TargetId = targetId;
		SourceId = sourceId;
		SizeX = sizeX;
		SizeZ = sizeZ;
		IsAeon = isAeon;
	}
}
