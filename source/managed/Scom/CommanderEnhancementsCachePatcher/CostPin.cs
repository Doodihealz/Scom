namespace CommanderEnhancementsCachePatcher;

internal sealed class CostPin
{
	internal string TemplateId { get; }

	internal string Id { get; }

	internal double Mass { get; }

	internal double Energy { get; }

	internal double BuildTime { get; }

	internal double RemovalBuildTime { get; }

	internal CostPin(string templateId, string id, double mass, double energy, double buildTime, double removalBuildTime)
	{
		TemplateId = templateId;
		Id = id;
		Mass = mass;
		Energy = energy;
		BuildTime = buildTime;
		RemovalBuildTime = removalBuildTime;
	}
}
