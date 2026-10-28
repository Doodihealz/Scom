using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;

namespace SupremeCommanderOverhaulSeaParity;

public static class SeaParityManifest
{
	public const string FaUnitsArchiveSha256 = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26";

	public const string AssetPackSha256 = "E77BE74B92D5C8FF333EF086BAF7A7DF4C22D37EB6BE62E2D91C6C65D451C099";

	public const long AssetPackBytes = 124238877L;

	public const string SalemAnimationResourceName = "SupremeCommanderOverhaulSeaParity.Assets.SalemAmphibiousAnimationAssets.sanpack";

	public const string SalemAnimationCachePath = "Units/ugn2001/LOD0/ugn2001_amphibious.sananimation";

	public const long SalemAnimationPackBytes = 4056791L;

	public const string SalemAnimationPackSha256 = "2CD8C37D44957AAB36154A0C3E58F68F6547A05329B7CFD927E903C579F62AF1";

	public const long SalemAnimationBytes = 34235641L;

	public const string SalemAnimationSha256 = "8026850836A1778313425BE6FFB20E3B0722319FC28B43EA4599866D37248BFF";

	public static readonly IReadOnlyList<SeaTemplateSpec> GeneratedTemplates = Array.AsReadOnly(new SeaTemplateSpec[24]
	{
		Unit("uen1001", "UES0103", "EDA", 1),
		Unit("uen1002", "UES0203", "EDA", 1),
		Unit("uen2001", "UES0201", "EDA", 2),
		Unit("uen2002", "UES0202", "EDA", 2),
		Unit("uen3001", "UES0302", "EDA", 3),
		Unit("uen3004", "UES0304", "EDA", 3),
		Unit("uen3005", "UES0305", "EDA", 3),
		new SeaTemplateSpec("uen4001", "UES0401", "EDA", 4, SeaTemplateKind.NavalUnit, "scoAtlantisCarrier", "SCOMAtlantisCarrier", null, null),
		Unit("ugn1001", "URS0103", "GUARD", 1),
		Unit("ugn1002", "URS0203", "GUARD", 1),
		Unit("ugn2001", "URS0201", "GUARD", 2, "GuardFaCybranSalem"),
		Unit("ugn2002", "URS0202", "GUARD", 2),
		Unit("ugn3001", "URS0302", "GUARD", 3),
		Unit("ugn3003", "URS0303", "GUARD", 3),
		Unit("ugn3004", "URS0304", "GUARD", 3),
		Unit("ugn3005", "URS0305", "GUARD", 3),
		NavalFactory("ues1513", "UEB0103", "EDA", 1, "ues2513", "Attachpoint01", "Right_Exhaust"),
		NavalFactory("ues2513", "UEB0203", "EDA", 2, "ues3513", "Attachpoint01", "Right_Exhaust", "Center_Exhaust"),
		NavalFactory("ues3513", "UEB0303", "EDA", 3, null, "Attachpoint01", "Right_Exhaust", "Center_Exhaust", "Left_Exhaust"),
		NavalFactory("ugs1513", "URB0103", "GUARD", 1, "ugs2513", "Attachpoint", "Right_Exhaust03"),
		NavalFactory("ugs2513", "URB0203", "GUARD", 2, "ugs3513", "Attachpoint", "Right_Exhaust03", "Right_Exhaust02"),
		NavalFactory("ugs3513", "URB0303", "GUARD", 3, null, "Attachpoint", "Right_Exhaust01", "Right_Exhaust02", "Right_Exhaust03"),
		AirFactory("ues1512", "UEB0102", "EDA", "ues2512", "Attachpoint", "Muzzle01"),
		AirFactory("ugs1512", "URB0102", "GUARD", "ugs2512", "Build_Point", "Arm02_Muzzle", "Arm01_Muzzle")
	});

	public static readonly IReadOnlyDictionary<string, string> PinnedLooseGeneratedTemplateSha256 = new ReadOnlyDictionary<string, string>(new Dictionary<string, string>(StringComparer.Ordinal)
	{
		["uen1001"] = "C3202B51B403BBE0C88FA3A049B317503EF5067431EC67BB064435620CCED631",
		["uen2001"] = "2FD3E542D7A87C8AC594CD1EF139C15B9D43903F5453E237E4A422E8B303E259",
		["uen3001"] = "354BF1003C59FA2EA175BAB6A6265A4FD7D81E9D65089FA6900C10AF4353E591",
		["uen4001"] = "32A0758B47B66A500B65F4F9D47F977BDEC98507422B8D5EEBAE6440D154B477",
		["ugn1001"] = "3C0D26A29A307D79C9DBAB9624B254CF487DE50162E61A7921FE5D0366F627E1",
		["ugn2001"] = "6A4A7CAA882BB14010A2795823845671E261EBF529D6D0B5ED0C82B68DF1E529",
		["ugn3001"] = "B05E8C604178753E99A648E70E72213DACE1E28F4B94C10E6804EBD2523C7FEC",
		["ues1512"] = "DA53B5C9C341146698F548DF2863A221CADC0ADAB4DC4DB17E492BCBC606B28E",
		["ugs1512"] = "FFFFAE5ED25C296033E240E836D4CE7022C915FF4BE0A9086956D201E0FEFF94",
		["ues1513"] = "2630D460E4B86AFF7EB3EBFD1467E421A9FB861E6B3B08BBE41D86369D9AE1E6",
		["ues2513"] = "5CDE8CD64CEA338B95D228134EF0947A546019DF79B9FF2177AC75CFBD423370",
		["ues3513"] = "3125B02CF10FC995565985B3464F9483B31F22A652C2AD3F051DCDAA23616D00",
		["ugs1513"] = "48872199049A6770F2639E12506E85148593FCEDBA142234A2B586C76E6A6ECC",
		["ugs2513"] = "D97261870465EE16C7C908F67364583297F6BF377FF48CA57A55552BDB1734F9",
		["ugs3513"] = "94C3D2217402A751F43768F5AE9FA9181A00339CB31FC772292A8ABD86E3B6B3"
	});

	public static readonly IReadOnlyList<string> WaterFactoryIds = Array.AsReadOnly(new string[12]
	{
		"ucs1513", "ucs2513", "ucs3513", "uss1513", "uss2513", "uss3513", "ues1513", "ues2513", "ues3513", "ugs1513",
		"ugs2513", "ugs3513"
	});

	public static readonly IReadOnlyList<string> WaterMobileIds = Array.AsReadOnly(new string[5] { "uen3005", "uen4001", "ugn3005", "ucl3701", "ucl4003" });

	public static readonly IReadOnlyList<string> ExistingAirFactoryVisibilityIds = Array.AsReadOnly(new string[4] { "ues2512", "ues3512", "ugs2512", "ugs3512" });

	public static readonly IReadOnlyList<string> GeneratedProjectileIds = Array.AsReadOnly(new string[2] { "psu302g", "psu302a" });

	public static readonly IReadOnlyList<string> QuickLaunchOnlyRegistrationIds = Array.AsReadOnly(new string[5] { "ugs1511", "ues2512", "ues3512", "ugs2512", "ugs3512" });

	public static readonly IReadOnlyDictionary<string, int> ExistingWeaponCounts = new ReadOnlyDictionary<string, int>(new Dictionary<string, int>(StringComparer.Ordinal)
	{
		["ucs1802"] = 1,
		["ucn1001"] = 3,
		["ucs1803"] = 4,
		["ucs1801"] = 1,
		["ucn3001"] = 4,
		["ucs2803"] = 2,
		["ucl4001"] = 2,
		["ucl3701"] = 1,
		["ucs2501"] = 2,
		["ucl4005"] = 6,
		["uca2806"] = 4,
		["ucl4003"] = 3,
		["usn1001"] = 2,
		["usn2001"] = 4,
		["usn2002"] = 4,
		["usn1002"] = 3,
		["usn3001"] = 8,
		["usn3003"] = 3,
		["usn3004"] = 4
	});

	public static readonly IReadOnlyDictionary<string, string> UnsupportedRuntimeContracts = new ReadOnlyDictionary<string, string>(new Dictionary<string, string>(StringComparer.Ordinal)
	{
		["ucl4003"] = "moving naval factory: no attached-product lifecycle or converted Tempest skeleton",
		["ucs2803"] = "carrier staging: no deck-relative landing/storage lifecycle",
		["usn3003"] = "carrier staging: no deck-relative landing/storage lifecycle",
		["usn1002/AntiTorpedo"] = "projectile interception is absent from HostWeapon target acquisition",
		["usn3001/InainoMissiles"] = "nuke silo ammo, build, manual-fire, and order lifecycles are absent",
		["usn3001/AntiMissile"] = "projectile interception is absent from HostWeapon target acquisition",
		["usn2001/AntiTorpedo"] = "projectile interception is absent from HostWeapon target acquisition",
		["usn2002/AntiMissile"] = "projectile interception is absent from HostWeapon target acquisition",
		["usn3004/AntiTorpedoLeft"] = "projectile interception is absent from HostWeapon target acquisition",
		["usn3004/AntiTorpedoRight"] = "projectile interception is absent from HostWeapon target acquisition",
		["ucn1001/AntiTorpedo01"] = "projectile interception is absent from HostWeapon target acquisition",
		["ucs1803/AntiTorpedo"] = "projectile interception is absent from HostWeapon target acquisition",
		["uca2806/AntiMissile"] = "projectile interception is absent from HostWeapon target acquisition",
		["ucn3001/AntiMissile1"] = "projectile interception is absent from HostWeapon target acquisition",
		["ucl3701/AntiTorpedo01"] = "projectile interception is absent from HostWeapon target acquisition",
		["ucl4003/AntiTorpedo01"] = "projectile interception is absent from HostWeapon target acquisition",
		["ucs2501/AntiTorpedo01"] = "projectile interception is absent from HostWeapon target acquisition",
		["ucl4005/AntiTorpedoLeft1"] = "projectile interception is absent from HostWeapon target acquisition",
		["ucl4005/AntiTorpedoLeft2"] = "projectile interception is absent from HostWeapon target acquisition",
		["ucl4005/AntiTorpedoRight1"] = "projectile interception is absent from HostWeapon target acquisition",
		["ucl4005/AntiTorpedoRight2"] = "projectile interception is absent from HostWeapon target acquisition",
		["ucl4001/NukeMissiles"] = "nuke silo ammo, build, manual-fire, and order lifecycles are absent",
		["uen3001/RightPhalanxGun01"] = "projectile interception and the Phalanx spin/unpack lifecycle are absent from HostWeapon target acquisition",
		["uen3001/LeftPhalanxGun01"] = "projectile interception and the Phalanx spin/unpack lifecycle are absent from HostWeapon target acquisition",
		["uen3001/Sonar"] = "source SonarRadius 20 is authored, but FA submerged-intel category and cloak semantics have no distinct Sanctuary template contract",
		["uen3001/WaterVision"] = "source WaterVisionRadius 50 has no distinct Sanctuary template contract",
		["uen3001/DeathLifecycle"] = "A002 and all three source death clips are intentionally omitted because the generic naval class has no verified dispatcher for them; immediate large UEF death and water-splash VFX are used instead",
		["uen3001/Veterancy"] = "source veterancy thresholds 32/64/96/128/160 are not mapped by the generated Sanctuary template",
		["ugn2001/AntiTorpedo"] = "source anti-torpedo projectile interception is absent from HostWeapon target acquisition",
		["ugn2001/AudioEffects"] = "source transform/death audio and transition/destruction effects have no verified Sanctuary runtime bridge",
		["ugn2001/WaterVision"] = "source WaterVisionRadius 45 has no distinct Sanctuary template contract"
	});

	public static readonly IReadOnlyDictionary<string, IReadOnlyList<string>> UnsupportedGeneratedWeaponLabels = new ReadOnlyDictionary<string, IReadOnlyList<string>>(new Dictionary<string, IReadOnlyList<string>>(StringComparer.Ordinal) { ["uen3001"] = Array.AsReadOnly(new string[2] { "RightPhalanxGun01", "LeftPhalanxGun01" }) });

	public static readonly IReadOnlyDictionary<string, IReadOnlyList<string>> UnsupportedSeraphimWeaponLabels = new ReadOnlyDictionary<string, IReadOnlyList<string>>(new Dictionary<string, IReadOnlyList<string>>(StringComparer.Ordinal)
	{
		["usn2001"] = Array.AsReadOnly(new string[1] { "AntiTorpedo" }),
		["usn2002"] = Array.AsReadOnly(new string[1] { "AntiMissile" }),
		["usn3004"] = Array.AsReadOnly(new string[2] { "AntiTorpedoLeft", "AntiTorpedoRight" })
	});

	public static readonly IReadOnlyDictionary<string, IReadOnlyList<string>> UnsupportedAeonWeaponLabels = new ReadOnlyDictionary<string, IReadOnlyList<string>>(new Dictionary<string, IReadOnlyList<string>>(StringComparer.Ordinal)
	{
		["ucn1001"] = Array.AsReadOnly(new string[1] { "AntiTorpedo01" }),
		["ucs1803"] = Array.AsReadOnly(new string[1] { "AntiTorpedo" }),
		["uca2806"] = Array.AsReadOnly(new string[1] { "AntiMissile" }),
		["ucn3001"] = Array.AsReadOnly(new string[1] { "AntiMissile1" }),
		["ucl3701"] = Array.AsReadOnly(new string[1] { "AntiTorpedo01" }),
		["ucl4003"] = Array.AsReadOnly(new string[1] { "AntiTorpedo01" }),
		["ucs2501"] = Array.AsReadOnly(new string[1] { "AntiTorpedo01" }),
		["ucl4005"] = Array.AsReadOnly(new string[4] { "AntiTorpedoLeft1", "AntiTorpedoLeft2", "AntiTorpedoRight1", "AntiTorpedoRight2" }),
		["ucl4001"] = Array.AsReadOnly(new string[1] { "NukeMissiles" })
	});

	public static IReadOnlyList<string> WaterPlacementIds => WaterFactoryIds.Concat<string>(WaterMobileIds).Distinct(StringComparer.Ordinal).OrderBy<string, string>((string id) => id, StringComparer.Ordinal)
		.ToArray();

	public static IReadOnlyList<string> RegistrationIds => GeneratedTemplates.Select((SeaTemplateSpec spec) => spec.TargetId).Concat<string>(WaterPlacementIds).Distinct(StringComparer.Ordinal)
		.OrderBy<string, string>((string id) => id, StringComparer.Ordinal)
		.ToArray();

	private static SeaTemplateSpec Unit(string targetId, string sourceId, string faction, int tier, string? runtimeClass = null)
	{
		return new SeaTemplateSpec(targetId, sourceId, faction, tier, SeaTemplateKind.NavalUnit, (faction == "EDA") ? "unitsDefaultEDA" : "unitsDefaultGuard", runtimeClass ?? ((faction == "EDA") ? "EDANavalUnit" : "GuardNavalUnit"), null, null);
	}

	private static SeaTemplateSpec NavalFactory(string targetId, string sourceId, string faction, int tier, string? upgradeTo, string platformBone, params string[] buildBones)
	{
		return new SeaTemplateSpec(targetId, sourceId, faction, tier, SeaTemplateKind.NavalFactory, (faction == "EDA") ? "unitsDefaultEDA" : "unitsDefaultGuard", (faction == "EDA") ? "EDAFaUefNavalFactory" : "GuardFaCybranNavalFactory", upgradeTo, platformBone, buildBones);
	}

	private static SeaTemplateSpec AirFactory(string targetId, string sourceId, string faction, string upgradeTo, string platformBone, params string[] buildBones)
	{
		return new SeaTemplateSpec(targetId, sourceId, faction, 1, SeaTemplateKind.AirFactory, (faction == "EDA") ? "unitsDefaultEDA" : "unitsDefaultGuard", (faction == "EDA") ? "EDAFaUefAirFactory" : "GuardFaCybranAirFactory", upgradeTo, platformBone, buildBones);
	}
}
