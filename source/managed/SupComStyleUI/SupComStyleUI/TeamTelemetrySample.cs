namespace SupComStyleUI;

internal sealed class TeamTelemetrySample
{
	public string TeamKey { get; }

	public string TeamName { get; }

	public double Strength { get; }

	public long CumulativeFires { get; }

	public TeamTelemetrySample(string teamKey, string teamName, double strength, long cumulativeFires)
	{
		TeamKey = teamKey;
		TeamName = teamName;
		Strength = strength;
		CumulativeFires = cumulativeFires;
	}
}
