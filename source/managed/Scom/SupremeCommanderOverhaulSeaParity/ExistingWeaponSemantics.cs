using System;
using System.Collections.Generic;

namespace SupremeCommanderOverhaulSeaParity;

public static class ExistingWeaponSemantics
{
	public static readonly IReadOnlyList<ExistingWeaponSemanticSpec> Corrections = Array.AsReadOnly(new ExistingWeaponSemanticSpec[22]
	{
		Spec("uca2806", "UAS0202", "FrontTurret", 1, "Turret_Front_Barrel", "Turret_Front", "Turret_Front_Barrel", 1, 0.0, Group("Muzzle_Front01", "Muzzle_Front02")),
		Spec("ucs1803", "UAS0201", "Torpedo1", 3, "Projectile01", "Projectile01", "Projectile01", 2, 1.0, Group("Projectile01"), Group("Projectile03")),
		Spec("ucs1801", "UAS0203", "Torpedo01", 1, "muzzle_01", "muzzle_01", "muzzle_01", 2, 0.8, Group("muzzle_01"), Group("Muzzle_02")),
		Spec("ucl4003", "UAS0401", "Torpedo01", 2, "Torpedo_Muzzle01", "Torpedo_Muzzle01", "Torpedo_Muzzle01", 6, 0.5, Group("Torpedo_Muzzle01"), Group("Torpedo_Muzzle02"), Group("Torpedo_Muzzle03"), Group("Torpedo_Muzzle04"), Group("Torpedo_Muzzle05"), Group("Torpedo_Muzzle06")),
		Spec("ucs2501", "XAS0204", "Torpedo01", 1, "Projectile_Front_Right", "Projectile_Front_Right", "Projectile_Front_Right", 4, 0.4, Group("Projectile_Front_Right"), Group("Projectile_Front_Left"), Group("Projectile_Front_Right"), Group("Projectile_Front_Left")),
		Spec("ucl4005", "XAS0306", "MissileRackFront", 1, "Turret_Front_Muzzle02", "Turret_Front", "Turret_Front_Barrel", 5, 1.0, Group("Turret_Front_Muzzle"), Group("Turret_Front_Muzzle01"), Group("Turret_Front_Muzzle02"), Group("Turret_Front_Muzzle03"), Group("Turret_Front_Muzzle04")),
		Spec("ucl4005", "XAS0306", "MissileRackBack", 2, "Turret_Back_Muzzle02", "Turret_Back", "Turret_Back_Barrel", 5, 1.0, Group("Turret_Back_Muzzle"), Group("Turret_Back_Muzzle01"), Group("Turret_Back_Muzzle02"), Group("Turret_Back_Muzzle03"), Group("Turret_Back_Muzzle04")),
		Spec("usn1001", "XSS0103", "MainGun", 1, "Back_Turret_Muzzle03", "Back_Turret", "Back_Turret_Barrel", 3, 0.25, Group("Back_Turret_Muzzle01"), Group("Back_Turret_Muzzle02"), Group("Back_Turret_Muzzle03")),
		Spec("usn1001", "XSS0103", "AntiAir", 2, "Front_Turret_Muzzle02", "Front_Turret", "Front_Turret_Barrel", 1, 0.0, Group("Front_Turret_Muzzle01", "Front_Turret_Muzzle02")),
		Spec("usn1002", "XSS0203", "Torpedo01", 1, "Projectile01", "Projectile01", "Projectile01", 2, 0.8, Group("Projectile01"), Group("Projectile02")),
		Spec("usn2001", "XSS0201", "Torpedo1", 3, "Projectile01", "Projectile01", "Projectile01", 2, 0.8, Group("Projectile01")),
		Spec("usn2002", "XSS0202", "LeftAAGun", 2, "Left_Turret01_Muzzle01", "Left_Turret01", "Left_Turret01_Barrel", 1, 0.0, Group("Left_Turret01_Muzzle01", "Left_Turret01_Muzzle02")),
		Spec("usn2002", "XSS0202", "RightAAGun", 3, "Right_Turret01_Muzzle01", "Right_Turret01", "Right_Turret01_Barrel01", 1, 0.0, Group("Right_Turret01_Muzzle01", "Right_Turret01_Muzzle02")),
		Spec("usn3001", "XSS0302", "FrontTurret", 1, "Front_Turret_Muzzle01", "Front_Turret01", "Front_Turret_Barrel01", 1, 0.0, Group("Front_Turret_Muzzle01")),
		Spec("usn3001", "XSS0302", "MidTurret", 2, "Front_Turret_Muzzle02", "Front_Turret02", "Front_Turret_Barrel02", 1, 0.0, Group("Front_Turret_Muzzle02")),
		Spec("usn3001", "XSS0302", "BackTurret", 3, "Back_Turret_Muzzle01", "Back_Turret01", "Back_Turret_Barrel01", 1, 0.0, Group("Back_Turret_Muzzle01")),
		Spec("usn3001", "XSS0302", "AntiAirLeft", 6, "Left_Turret_Muzzle03", "Left_Turret02", "Left_Turret_Barrel02", 1, 0.0, Group("Left_Turret_Muzzle02", "Left_Turret_Muzzle03")),
		Spec("usn3001", "XSS0302", "AntiAirRight", 7, "Right_Turret_Muzzle01", "Right_Turret01", "Right_Turret_Barrel01", 1, 0.0, Group("Right_Turret_Muzzle01", "Right_Turret_Muzzle02")),
		Spec("usn3003", "XSS0303", "AntiAirRight", 2, "Right_Turret_Muzzle01", "Right_Turret", "Right_Turret_Barrel", 1, 0.0, Group("Right_Turret_Muzzle01", "Right_Turret_Muzzle02")),
		Spec("usn3003", "XSS0303", "AntiAirLeft", 3, "Left_Turret_Muzzle01", "Left_Turret", "Left_Turret_Barrel", 1, 0.0, Group("Left_Turret_Muzzle01", "Left_Turret_Muzzle02")),
		Spec("usn3004", "XSS0304", "TorpedoFront", 1, "Projectile01", "Projectile01", "Projectile01", 4, 1.0, Group("Projectile01"), Group("Projectile02"), Group("Projectile03"), Group("Projectile01")),
		Spec("usn3004", "XSS0304", "AutoCannon", 4, "Front_Turret_Muzzle01", "Front_Turret", "Front_Turret_Barrel01", 1, 0.0, Group("Front_Turret_Muzzle01", "Front_Turret_Muzzle02"))
	});

	private static ExistingWeaponSemanticSpec Spec(string targetId, string sourceId, string sourceWeaponLabel, int upstreamCombatIndex, string aimBone, string yawBone, string pitchBone, int muzzleSalvoSize, double muzzleSalvoDelay, params string[][] muzzleGroups)
	{
		return new ExistingWeaponSemanticSpec(targetId, sourceId, sourceWeaponLabel, upstreamCombatIndex, aimBone, yawBone, pitchBone, muzzleSalvoSize, muzzleSalvoDelay, muzzleGroups);
	}

	private static string[] Group(params string[] muzzles)
	{
		return muzzles;
	}
}
