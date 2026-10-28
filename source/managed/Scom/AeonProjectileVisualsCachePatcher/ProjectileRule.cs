namespace AeonProjectileVisualsCachePatcher;

internal sealed class ProjectileRule
{
	internal string SourceId { get; }

	internal string TargetId { get; }

	internal ProjectileRule(string sourceId, string targetId)
	{
		SourceId = sourceId;
		TargetId = targetId;
	}
}
