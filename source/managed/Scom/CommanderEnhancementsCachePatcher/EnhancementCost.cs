namespace CommanderEnhancementsCachePatcher;

internal sealed class EnhancementCost
{
	internal double Mass { get; }

	internal double Energy { get; }

	internal double BuildTime { get; }

	internal EnhancementCost(double mass, double energy, double buildTime)
	{
		Mass = mass;
		Energy = energy;
		BuildTime = buildTime;
	}
}
