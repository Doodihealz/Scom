namespace SupremeCommanderOverhaulAudioCompat;

internal sealed class DeathClip
{
	public string Key { get; }

	public int Weight { get; }

	public double Duration { get; }

	public double? RateMin { get; }

	public double? RateMax { get; }

	public DeathClip(string key, int weight, double duration, double? rateMin, double? rateMax)
	{
		Key = key;
		Weight = weight;
		Duration = duration;
		RateMin = rateMin;
		RateMax = rateMax;
	}
}
