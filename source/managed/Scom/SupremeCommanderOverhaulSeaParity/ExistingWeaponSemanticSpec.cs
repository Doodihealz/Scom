using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;

namespace SupremeCommanderOverhaulSeaParity;

public sealed class ExistingWeaponSemanticSpec
{
	public string TargetId { get; }

	public string SourceId { get; }

	public string SourceWeaponLabel { get; }

	public int UpstreamCombatIndex { get; }

	public string AimBone { get; }

	public string YawBone { get; }

	public string PitchBone { get; }

	public int MuzzleSalvoSize { get; }

	public double MuzzleSalvoDelay { get; }

	public IReadOnlyList<IReadOnlyList<string>> MuzzleGroups { get; }

	public ExistingWeaponSemanticSpec(string targetId, string sourceId, string sourceWeaponLabel, int upstreamCombatIndex, string aimBone, string yawBone, string pitchBone, int muzzleSalvoSize, double muzzleSalvoDelay, params string[][] muzzleGroups)
	{
		if (upstreamCombatIndex < 1)
		{
			throw new ArgumentOutOfRangeException("upstreamCombatIndex");
		}
		if (muzzleSalvoSize < 1)
		{
			throw new ArgumentOutOfRangeException("muzzleSalvoSize");
		}
		if (muzzleSalvoDelay < 0.0)
		{
			throw new ArgumentOutOfRangeException("muzzleSalvoDelay");
		}
		if (muzzleGroups == null || muzzleGroups.Length == 0)
		{
			throw new ArgumentException("At least one muzzle group is required.", "muzzleGroups");
		}
		List<IReadOnlyList<string>> list = new List<IReadOnlyList<string>>(muzzleGroups.Length);
		foreach (string[] array in muzzleGroups)
		{
			if (array == null || array.Length == 0)
			{
				throw new ArgumentException("Muzzle groups cannot be empty.", "muzzleGroups");
			}
			list.Add(Array.AsReadOnly((string[])array.Clone()));
		}
		TargetId = targetId;
		SourceId = sourceId;
		SourceWeaponLabel = sourceWeaponLabel;
		UpstreamCombatIndex = upstreamCombatIndex;
		AimBone = aimBone;
		YawBone = yawBone;
		PitchBone = pitchBone;
		MuzzleSalvoSize = muzzleSalvoSize;
		MuzzleSalvoDelay = muzzleSalvoDelay;
		MuzzleGroups = new ReadOnlyCollection<IReadOnlyList<string>>(list);
	}
}
