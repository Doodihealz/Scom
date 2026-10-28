namespace SupremeCommanderOverhaulAudioCompat;

internal sealed class LandFactoryContract
{
	public string Id { get; }

	public double RollOffZ { get; }

	public (string Bone, double Speed)[] Rotators { get; }

	public LandFactoryContract(string id, double rollOffZ, params (string Bone, double Speed)[] rotators)
	{
		Id = id;
		RollOffZ = rollOffZ;
		Rotators = rotators;
	}
}
