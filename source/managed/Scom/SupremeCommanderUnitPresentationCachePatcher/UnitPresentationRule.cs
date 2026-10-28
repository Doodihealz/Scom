using System;

namespace SupremeCommanderUnitPresentationCachePatcher;

internal sealed class UnitPresentationRule
{
	public string TargetId { get; }

	public string SourceId { get; }

	public string DisplayName { get; }

	public UnitPresentationRule(string targetId, string sourceId, string displayName)
	{
		TargetId = targetId ?? throw new ArgumentNullException("targetId");
		SourceId = sourceId ?? throw new ArgumentNullException("sourceId");
		DisplayName = displayName ?? throw new ArgumentNullException("displayName");
	}
}
