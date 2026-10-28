namespace SupComStyleUI;

internal sealed class UnitWeaponStats
{
	public string Label = string.Empty;

	public string Category = string.Empty;

	public string DamageType = string.Empty;

	public string TargetLayers = string.Empty;

	public float Damage;

	public float DamageRadius;

	public float RangeMin;

	public float RangeMax;

	public float ReloadTime = 1f;

	public int SalvoSize = 1;

	public float SalvoDelay;

	public int MuzzleCount = 1;

	public float BeamLifetime;

	public float DamageOverTime;

	public float? Dps;
}
