namespace SupremeCommanderOverhaulAeonStructureMotion;

public sealed class StructureDisposition
{
	public string TargetId { get; }

	public string SourceId { get; }

	public string Owner { get; }

	public bool RosterVisible { get; }

	public string Rationale { get; }

	public StructureDisposition(string targetId, string sourceId, string owner, bool rosterVisible, string rationale)
	{
		TargetId = targetId;
		SourceId = sourceId;
		Owner = owner;
		RosterVisible = rosterVisible;
		Rationale = rationale;
	}
}
