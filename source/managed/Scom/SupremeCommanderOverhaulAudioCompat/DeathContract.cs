namespace SupremeCommanderOverhaulAudioCompat;

internal sealed class DeathContract
{
	public string Id { get; }

	public string ClassName { get; }

	public DeathClip[] Clips { get; }

	public DeathContract(string id, string className, params DeathClip[] clips)
	{
		Id = id;
		ClassName = className;
		Clips = clips;
	}
}
