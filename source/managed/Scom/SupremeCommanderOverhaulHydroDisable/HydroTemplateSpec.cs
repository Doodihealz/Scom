namespace SupremeCommanderOverhaulHydroDisable;

public sealed class HydroTemplateSpec
{
	public string TargetId { get; }

	public string FactionTag { get; }

	public string RelativePath => "LJ/lua/common/units/unitsTemplates/" + TargetId + "/" + TargetId + ".santp";

	public HydroTemplateSpec(string targetId, string factionTag)
	{
		TargetId = targetId;
		FactionTag = factionTag;
	}
}
