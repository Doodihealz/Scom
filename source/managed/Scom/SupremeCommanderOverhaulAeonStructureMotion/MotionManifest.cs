using System;
using System.Collections.Generic;
using System.Linq;

namespace SupremeCommanderOverhaulAeonStructureMotion;

public static class MotionManifest
{
	public const string Version = "1.0.2";

	public const string SourceUnitsSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	public const string SourceLuaSha256 = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb";

	public const string TargetPackSha256 = "8f53fb2b88bfacad95e07d6f8925cd2c7cb60f40be5d39e3b77b94a93ee8462b";

	public const long StorageAssetPackBytes = 9166L;

	public const string StorageAssetPackSha256 = "1c343fb3c33848d3e16e546edbee827f66b4a8f25fe4324c302829eef979c297";

	public const long ExtractorAssetPackBytes = 296150L;

	public const string ExtractorAssetPackSha256 = "8699116f6c8603842d8366b92f61a1ce1d2c4b44a769dd379f37eccf506e1b92";

	public const string UpstreamPatcherSha256 = "3eed7306200d5910786221547ff0fb959fa8cf92c85c99d62b98a12175c28b76";

	public const string UpgradeOwnerSha256 = "17da3a108f2610c0734f1bbdb164f1f04335835add2f6a9f70bb4b43d15703b0";

	public const string HydroDisableSha256 = "ce6d3a51954ed37c1909f2314f3b006b52d5c2ab0413ffda365e330446c61981";

	public const string GameplayCorrectionsSha256 = "8dcae5456e370f928db9a6d44f3448cbaa637dd2fc13efebd6af7b4ce18896a9";

	public const long GameplayCorrectionsBytes = 102912L;

	public const string GameplayCorrectionsMvid = "a902d100-d199-4124-96d1-48a92de713d5";

	public const long EconomyLuaBytes = 18406L;

	public const string EconomyLuaSha256 = "92872df06372d3d705388a038d09457a72dcb4c090b65dc3a2a7ce95ddba162f";

	public static readonly IReadOnlyList<string> PreservedOwnerTargets = new string[9] { "ucs2102", "ucs2402:deploy", "ucs3102", "ucs1511", "ucs2511", "ucs1512", "ucs2512", "ucs1513", "ucs2513" };

	public static readonly IReadOnlyList<AssetPin> ExtractorAnimationOverrides = new AssetPin[3]
	{
		new AssetPin("Units/ucs1601/LOD0/ucs1601.sananimation", 1063968L, "1e619db040eba68cc459a6bbd105fa5b5f94fae2d7c1fcb7291d2028bdcf4b45"),
		new AssetPin("Units/ucs2601/LOD0/ucs2601.sananimation", 1053188L, "fe9e317d557496766de314ec014aa6664e3ae5acc96ec5821dffc3f868f58f09"),
		new AssetPin("Units/ucs3601/LOD0/ucs3601.sananimation", 832202L, "1a4babd08cff018faa0ccb14eef46785b2f3340e34f1431270a444fd4c565deb")
	};

	public static readonly IReadOnlyList<MotionContract> All = new MotionContract[25]
	{
		Ready("ucs1601", "UAB1103", "AeonPortAlloyExtractor", "rotating extractor shaft + upgrade", "pump_loop_upgrade", "a689422b2297f98499348c07ad287c27814ca9c136c92043e055e16f82e3989f", "9a14e34fa9fe6bccacb3e1e1ad60ed7333344460e93570086f2a14d94559be65", "6183974a52f300f90d01bffa0771715cefee5f90157fe598438932b9ef48097e", 281193L, "cd477dfeac0483498cc984a681c333ff2786998b666a94922ebd2b1aae5b5007", 12387L, "1bdefc098412170de5244cc264cec521f8befa1b8fdf505dfca9aa4e67da995f", 1063968L, "1e619db040eba68cc459a6bbd105fa5b5f94fae2d7c1fcb7291d2028bdcf4b45", 3, Array.Empty<string>(), "Original AnimPump preserves the authored 12.666667-second Shaft rotation and 0.75-unit vertical pump stroke; continuous pump clocks let native Loop playback cross the cycle seam, production pause freezes the exact source time, upgrade yields ownership, and AnimUpgrade remains progress-bound.", Clip("AnimPump", "source_animpump", "pump", "UAB1103_Apump.sca", 120626L, "75d3f6b37d616d7fbc20519425ec5173e1dfda10cd6ab71fd752530ecaf3cb6d", 381, 12.666667), Clip("AnimUpgrade", "source_animupgrade", "upgrade", "UAB1103_Aupgrade.sca", 33726L, "40192f14f26e517abf9d579880cbd8c14cf33507ea17b1e154bc9d245b68d2fc", 106, 3.5)),
		Ready("ucs2806", "UAB1104", "AeonPortStructure", "mass fabricator open + alternating rotor", "alternating_fabricator", "3c4eb4cef01985a92ce78af0b587346f9df08d3fc471cb52f22b307e3e47ff5f", "ee15feaca98ab858f2e658a77d565b47daf8584dd55c865d34ae88b689dbf295", "db853eca1d39f76b69609027f38efaa06d94e9dc04803ea086980591233baee9", 120889L, "44d077b4526e16c17a178f2285f1ec595e0fc66a509533de91895500dc0a8247", 16141L, "96a83e40cef3dc85f32271d9e5666ca8912ea929f6dbc932e3c31c84cbaa2839", 146611L, "f274c2dd5aaf0e9ef91331ab8e00898a8b77354cb841aaf428dedda01cfb848a", 2, new string[1] { "Axis" }, "Open at rate 1; Axis/z accelerates at 50 through deterministic 120..300 alternating goals; pause stops and reverses open.", Clip("AnimAopen01", "source_animaopen01", "open", "UAB1104_Aopen01.sca", 19582L, "7e0405219700d0b225dab5a0c6eeb97496a5025185f187a16356011f2196a21f", 45, 4.4)),
		Ready("ucs2601", "UAB1202", "AeonPortAlloyExtractor", "rotating extractor shaft + upgrade", "pump_loop_upgrade", "79b006969a88b2e16acebe9cfd234890397b5fcd77a7e9c9f9e783efef0725d7", "cbfdc5ac0e8edb9492732f6287c5239040dc0ec245f2cbfc9b074a114f2baff0", "144a8173aa783c831e0a011f4c5df1155e85e0c9170af911fd7de4fc65f8637a", 281193L, "e194722699f20145d90ea0445001971160e05ec6f5427c37d59f4613af88cff3", 12385L, "6a0a6136cce5b980f58a3410ddf995342e8d58f6ade7ebbb3791ffab52c9f30b", 1053188L, "fe9e317d557496766de314ec014aa6664e3ae5acc96ec5821dffc3f868f58f09", 3, Array.Empty<string>(), "Original AnimPump preserves the authored 12.666667-second Shaft rotation and 0.75-unit vertical pump stroke; continuous pump clocks let native Loop playback cross the cycle seam, production pause freezes the exact source time, upgrade yields ownership, and AnimUpgrade remains progress-bound.", Clip("AnimPump", "source_animpump", "pump", "UAB1202_Apump.sca", 120626L, "16730915e7144d84b8a6cd2a94048750a97ad4a3f27ab5376016d248814d96a0", 381, 12.666667), Clip("AnimUpgrade", "source_animupgrade", "upgrade", "UAB1202_Aupgrade.sca", 32146L, "375f2db7f465afdbe60640d0ca641e22d6f5b98740b489f99cdb060e6fd8bf17", 101, 3.3333333)),
		Ready("ucs2611", "UAB1201", "AeonPortEnergyGenerator", "authored death", "death_only", "780b0749722ac6c56861949cd03a8a40de76a3b0c1e026d07ea861460b99fc9f", "ade62eb69fb40c93d9e22c99d7dad7e740a931f5c52e57502bce3c709544f66a", "4c26db9546cb91349058e9138292e9b23bad07b5534b33c31d42d08c2da428d1", 584097L, "529dbdd369ba0f1868388b9a9e5c39e28d5db38b339de3fad82262c70837470a", 2133L, "b01a4d500de2fefbb2f76650b8d27db8f1866f952165042cf3c25ef71e33d726", 15152L, "ac29a716b4e9b2344076260182fc9f2c5878f5288b9456e496e34495fb419925", 2, Array.Empty<string>(), "Completed-unit DeathThread samples AnimAdeath for one authored second, then delegates to the captured owner.", Clip("AnimAdeath", "source_animadeath", "death", "UAB1201_Adeath.sca", 2107L, "54d9d1293e0edb9764d4ce58c730820f353262484fce0c7dfab97f367e1ed944", 31, 1.0)),
		Ready("ucs3611", "UAB1301", "AeonPortEnergyGenerator", "quantum sphere + authored death", "rotating_power_death", "96e85f646efd233848af22f3cd6c6bfc74afde1f5dd27e5d2975f1b0fd11dfcf", "9454c4e6406fb61e7fa8134cbb26f5c77e256fd1e57ecfbc2f932f143cea1c6a", "282dbdc030fd20b5cceb158431ac769d57435a31024dabb04738c459d602ac96", 626937L, "da68c98a8c7f52f570c4a2921ebe36c22b896d29c9448c33124d04e09757148f", 1976L, "51352f9a61fde2be842b5a745e97d1ab89fa874499cb5b1dadbfac231c4d8f10", 15152L, "c71850bb609479462b523af38f1095da26e153627d2d614080c7843b1418dc9d", 2, new string[1] { "Sphere" }, "Sphere x/y/z accelerates at 15 to deterministic source-range 80..100 continuously, independent of production Pause; death owns the one-second authored clip before stock wreck/delete.", Clip("AnimAdeath", "source_animadeath", "death", "UAB1301_Adeath.sca", 2107L, "790a01b07fbb6fc1f1f254a19e2a96ef4dcdfabe6cc66dbce37335d2c2a5b672", 31, 1.0)),
		Ready("ucs3601", "UAB1302", "AeonPortAlloyExtractor", "repeating extractor pump", "pump_state_machine", "18a5d6b6e2a027d0d599dc47177e48883190de7fadc97e3da3eab25a0010ad83", "82adc4592cd340e43abe1be841c797bbbcf3b8a67bb31055286bafc1a34a2a49", "3546d16d728faf30adf4235aae50ac2df481eb23f599c72e7cfd985acaa47c53", 281193L, "fc1b574dcaa18a134426d840859d715a06501dc322b811b3e805880ee197e76d", 12380L, "de71eaae8673da8c90ff36818191880b18a21b182761e5092dc0e476aaa840e4", 832202L, "1a4babd08cff018faa0ccb14eef46785b2f3340e34f1431270a444fd4c565deb", 2, Array.Empty<string>(), "Original AnimPump preserves the authored 12.666667-second Shaft rotation and 0.75-unit vertical pump stroke; continuous pump clocks let native Loop playback cross the cycle seam, pause finishes the current source cycle and holds its endpoint, and resume starts the next cycle without a second owner.", Clip("AnimPump", "source_animpump", "pump", "UAB1302_Apump.sca", 120626L, "537d1d819f5748328656e6e5c60832844c996a13a7921be7c6d488da4807101f", 381, 12.666667)),
		Ready("ucs3603", "UAB1303", "AeonPortStructure", "T3 fabrication rings and core", "fabricator_rotators", "dfc725ed7309bf0bb00f1bd07b83cd25d356413cc9783cee81be55463f237be1", "92f909396efb0438cf29af3316b394746a24e6efbc769566433cb34460fb3f79", "4a42b7acc86c3f52f89b8bcea260654156cb33c9c6fd298d34d0c2ae8e20f040", 399249L, "a069a0660e28b3d9310c263b7aa641f6e069f2246f857e90d4ea6720f389b52d", 4951L, "1afc8f0ae1372353634b280df30b338d6568e412b8315235cc3f1e99fa3f1422", 3763L, "3bb785db258beda23e2d5a68f5cf2e0b48b045fb16fd74ab5d3692be4f149200", 1, new string[4] { "B01", "B02", "B03", "B04" }, "All axes accelerate at 15: B01/x=45, B02/x=-45, while B03/y and B04/x/y/z use one deterministic source sign with 80 +/- 0..20. Production toggle-off spins down at 15 and selects the next deterministic source-range goals; toggle-on accelerates to them. Generic Pause does not own these rotators."),
		PermanentOpen("ucs2201", "UAB2204", "Marr perm-open", "AnimActivate", "source_animactivate", "UAB2204_Aactivate.sca", 34096L, "803184f19f766857c9f42fd748a018aa62a1a7a26a0ff9f6fcf3d0b71216552d", 66, 2.1666667, "ed67446216872bcd5678c401c84b0087b238d02dc5301ada7515296edaaa9458", "702d02a4491b47dab2a61bdf8a5beb199ed3eb2ebf19b1f7915022b976ff5131", "01d519a47935ef64c0c59786e9eb07334d52b472a8e6a7e53c71f8ecadb97f5b", 235625L, "e5d3035891f047b712edd31a4dc03cf543dbc7d5b0e06959156ed6cfbe41fcc8", 19958L, "e361f9fb56e57f3b4fac6ce30cfdceb844fa41370f166242382359ea619f9068", 251300L, "dda69f905d19f60cb0780aa230a1af798e5376f9766020bd99e8b7a3c763c268"),
		PermanentOpen("ucs2001", "UAB2301", "Oblivion perm-open", "AnimOpen", "source_animopen", "UAB2301_Aopen.sca", 22159L, "81c202a71afaa35e10b71e165fb24ad74b5eddc48851e4b2e912eae64bae2dab", 51, 1.6666666, "26f1431c63b23a3d3f414331db4c1824d171527e1f59c7f637ec100b4f197f49", "1c9bb44b14af7f18048c0afa25eee2ecae2787e6f353faa21d91e51920eda894", "a3f230b7c07c746de2681bf49d1e6c7553905d1b6dacedefb58aa02544522a15", 265429L, "7e4c9666528bb1bf621753d4e995ce536dc58ab207c65de9a3ef6da24fcaf393", 14889L, "fc89b00a00b23dd9b63e2595bb5e9615960ec414e738ed3cf89ec1b1f60bb8ab", 164786L, "e6e027194bb9cfc5f9d033af875ed2c3caa0ad23701907bd6f965788c94bd643"),
		PermanentOpen("ucs2101", "UAB2303", "Miasma perm-open", "AnimOpen", "source_animopen", "UAB2303_Aopen.sca", 24657L, "d66b774506a644d2b496586471e72a0cf135cc2069e672e883b4a3580f84a41d", 71, 2.3333333, "f056166ac1588ee419d833f890aefbf3db56798f05bfc914925c44a8dfc98bac", "b73d3b44b2882ba5d190a392ae82639a5ff46580294d33ff566eaafb00ee5833", "052fceab0740a7f523166cc8500195fd7e2b89b24d06adb772ac2e9b63f7b4eb", 254977L, "2c96d2a103a9b55fce4e680cd7e83c14e8970d1d82c942c90315509ed11dd207", 11854L, "d7647025ab8da8f42400b8d002e64d048fc7f9f3e606c7502f1565a5133a3b85", 178922L, "2fcc2b2e73215b86ddcf4a5c03c9dc8fd88558b78f8be379c8d13fbc754ffc4e"),
		PermanentOpen("ucs3201", "UAB2304", "Transcender perm-open", "AnimOpen", "source_animopen", "UAB2304_Aopen.sca", 34976L, "171ed6314bd460d00c8cc2344d683745b473951eff0335a42a5c45cb0a0379eb", 81, 2.6666667, "66bec16f278856954b999095ca49e2a1eb5133b4efccb21756fdebd21218ccd7", "b025eef07cbc3550c0b71c785fa24c0bd314f8dd3a02495ce4eb4b6e1f20a2b8", "6cd6aa94bd3ae6a6c15fc691b8172ce76dd80fa1ba44d9a4d9e5092468dbcde1", 335089L, "feba9df46e49f13e90dab58147b8a5998ad822f4143d8e53ac0ffe54f799c771", 15297L, "c986def175940182a4e70aab188146c8c3125f5028ac855560e2f71d44cf52a9", 252706L, "1f7811263908a44825e13bf7bdfddc69e49afefec9fbd16a8b903d1f5db580b0"),
		Ready("ucs1701", "UAB3101", "AeonPortStructure", "T1 radar rotor + upgrade", "intel_rotor_upgrade", "2e13daff88938b7da55e308ee696a4abcc2be3d01cd5023ecd32b79a4ae14262", "5ffb03c438f321daf46930a184989d6fa18d6121d50a5a103b4731051bf104e9", "86c9b17c95e3c24595bb447b783c0cb14c1bdfa075c68c2254e6d44b2f918a9f", 252073L, "85bb6e169bf2b3cb026d6d0d78af13e14d1cd559eb8e717b235af02e2401e670", 6256L, "170aa863bead9aea62fc50112799ed33f35421cb36a093963ca5bfcbd29ba510", 43269L, "2d8f1094d84dc0f5f6c578401c1106c5b9f1c26a74702e4d03f5716d78602f66", 2, new string[1] { "B01" }, "Effective radarDetector enabled: B01/y accelerates at 20 to 30; player toggle or energy outage spins down at 20. AnimUpgrade is progress-bound and aim bones remain unowned.", Clip("AnimUpgrade", "source_animupgrade", "upgrade", "UAB3101_Aupgrade.sca", 5656L, "2f0451c62a0a6d7b1ff2e280221317b8b33c45b8ee8efc5f0eb45689de623d4a", 46, 4.5)),
		Ready("ucs1702", "UAB3102", "AeonPortStructure", "T1 sonar upgrade", "upgrade_only", "cb7096bdf0dbbfd477ae6ec7625a37f339e3a6fb2f36b2b283f9d78af5cecb09", "6b536566d83e728ab8750a1d7a66888db4d6c5f2ecfe979a115edd77ba30ff9b", "86848e54027b429076d24652e9cd28f4b8c198085533398b4014f0a34a01836a", 304913L, "52c143256ad1d007315b68b2dda33fe3288e8aa29c83ef6cf0a69744b914b6b8", 17859L, "7c13d8f4ef5c8515568b82143c93c01efe69f2591549892c34f63e43e2afc466", 175206L, "32698b12313e14ea00727696c2c2e1e931cf7883ed57236902b79bc577cca5c7", 2, Array.Empty<string>(), "No invented idle motion; AnimOpen is owned only by upgrade progress.", Clip("AnimOpen", "source_animopen", "upgrade", "UAB3102_Aopen.sca", 23572L, "de0a52eeb0aede5d65092335d2411c1f60b7eab6aa7f627320240e113a0d3cfc", 51, 1.6666666)),
		Ready("ucs3701", "UAB3104", "AeonPortStructure", "omni rotors", "intel_rotor_triple", "8516e303d6a5eebc125dff13ec3ab8d11f036d44c46c5b565f56ddd47daea626", "7e977e976318a472f9891d1887128118a7b2fbe1cfc2f31943f2f61c17011e66", "5e2d3e6a20232a4fe9d1dc7ee0a4ed8e7de33713b1c72b443e1cdee6c9f7da59", 317593L, "77ad5065b7f6fd89636198014e6f015f86139f2f5555c52f58e33a93a9277e87", 5989L, "b858779b442c3f00cbcdafa571157e04f014dba750f595088c8ae08fa82344f1", 4385L, "2b543294b5bbc631b428caee4804e79bdfebc90516fe1cdd707e37dd37b106b3", 1, new string[3] { "B03", "B02", "B01" }, "Effective radarDetector enabled y-speeds accelerate at 20 to 30/60/120 in source creation order; player toggle or energy outage spins all three down at 20."),
		Ready("ucs2701", "UAB3201", "AeonPortStructure", "T2 radar rotors + upgrade", "intel_rotor_pair_upgrade", "1e03af433f4bdd50b7de22a2f4c53053c8b3551eb85b542336f4d3ce74611ea3", "43c3ee2e7594ed1013945c96c281a0c608a4a7254e7c281089d0b2a9560b3513", "a7e5c3ab944175b5540d1f16a291f474d199ac3a2f177f1c5598de2ce9344fdd", 324137L, "3b511e61ab942fb059b8ce36b35dd57960fc800913902c6734635c3d4ca2cc38", 7182L, "8f7aad8c73858a0881913aaf889b6cdb928f8713b46c39f22a9f918684e8e0c3", 53135L, "6067de22f05acda7607db8c0a2ce5617557630d3e6182b463b7cfca8104951b2", 2, new string[2] { "B02", "B01" }, "Effective radarDetector enabled y-speeds accelerate at 20 to 30/60; player toggle or energy outage spins both down at 60. AnimUpgrade is progress-bound.", Clip("AnimUpgrade", "source_animupgrade", "upgrade", "UAB3201_Aupgrade.sca", 6952L, "c76fac253a891aca0b1656af1c96968badace7995b2209496a1f4487d1acf207", 46, 4.5)),
		Ready("ucs2702", "UAB3202", "AeonPortStructure", "T2 sonar upgrade", "upgrade_only", "d2ec861ba7994346569793b39236cfc8c4447adf80f3cdfc2cb8770511c2baa5", "721e8c0b54a7e60d0aac00cb6f96f4ce841a484875a16336920c925f1edeef06", "e0dee3f0eaa163721e96fae62d8fae44318333c20e8be7c4741b2e963a593955", 304913L, "740cee74f51c28f113fbea2160d4aabd9d14255cce1e050269ccb02ebb650688", 17847L, "fe557c78b29d7a5d138ef622efd67a0bb07131e0b8bd8654b5a3c7a2cc3575ab", 253606L, "25599a63bbe1ec4c4d751bfe6fc90fe97f32b16bf69703e8c755298aaefe4d78", 2, Array.Empty<string>(), "No invented idle motion; AnimOpen is owned only by upgrade progress.", Clip("AnimOpen", "source_animopen", "upgrade", "UAB3202_Aopen.sca", 34972L, "fae36b9e142d17e43ccbdb226f784217dd88639495650e6722fb5b145d3cee70", 76, 2.5)),
		Ready("ucs2402", "UAB4201", "AeonPortStructure", "anti-missile Dome recoil only", "dome_recoil", "96d6ae783a48f8c18d929e707a710e0d0a54fa9df16fed6d27c3f986d764533a", "f6b6092a57a2baff5a0634233ab9651286c91c3c7cc9c02edbae6c473e054459", "27846a1b56f710d9b7c7d9a89004f4b6a1efa62771c2bb82286cbbd497e6ba35", 284177L, "e626eb99c192c70943892d1d40d9015a7fe77e4e2c3be0006b6a4a47918db8e5", 8048L, "b7902cff74373d4afb48fda17717ee6bdfe40fbbb2ef8ca23173c9eadaad8a35", 114730L, "3cd77eb2a9586fdb85018422c83516e8f486a787e0d1f2f9f98e0ebcd3545847", 2, new string[1] { "Dome" }, "Preserve FA Animation Closure deploy/repack owner. Each actual projectile advances Dome/z exactly 45 degrees; step 8 reaches 360 and clears the counter.", Clip("AnimOpen", "source_animopen", "preserved_deploy", "UAB4201_Aopen.sca", 16181L, "93379bccb9b67a40ca862bb4d7171fa178fea3c25ae2722164650259d7582828", 91, 3.0, 10.0)),
		Ready("ucs2711", "UAB4203", "AeonPortStructure", "radar jammer open + rotor", "jammer", "4e6fc2e1040b81a2683494f85bfbadab1205f664f3d4a337a095ea236017a9b8", "0861390a66c4182a12a39d08a2c358ddbc22eb00d7473a1a4d02d0c480388c4f", "bc0af136e56e3a726d7c17631ef0a576d0f3c75198b35bf4db1933f6e5d5f042", 214593L, "7e292a3d11f5a655fb414a66346b9b2a3c0f6779d5022a651ff7728cf82891f5", 11168L, "72432de6977fe91d13ef7636aded50cecb4c4a42ad77f8eb88818c9f3517ddbc", 228578L, "e15196830680348b10ff08ed8bfd8f1721343a0e9abe733ac1cc62669066ab1b", 2, new string[1] { "B02" }, "Because Sanctuary does not implement FA radar-stealth fields, completed operational intent drives AnimOpen while B02/z concurrently accelerates at 50 to 60: optional Intel toggle and army energy gate start/reverse the clamped timeline and spin B02 down at 50. This is visual parity only; RadarStealthFieldRadius remains provenance-only.", Clip("AnimOpen", "source_animopen", "intel_open", "UAB4203_Aopen.sca", 32126L, "dbf1f85a05305367c1f093b66fb2043d183ac717e11682afa311ff68a45f81e6", 101, 3.3333333)),
		PermanentOpen("ucs3402", "UAB4302", "Patron perm-open", "AnimOpen", "source_animopen", "UAB4302_Aopen.sca", 10024L, "ebf785420e89f22c6ceee428b2bf984ab5ad78a6bceabd6360ce4c0683ca03de", 31, 3.0, "d72db5e3fc2233509f6de9b3cc3351b8c4e053351fd4c14b5be4aa9cea23ed5a", "80aeb59d0226392ee9f8aacfa7d9e450774a758f27b2f10a89d170699f128a16", "376ba255fbe230e6998cc241e68e4152e1c4202017dbbf164de285eb8cc5cbd1", 241477L, "2ab419dec4193d4b56528c528ea562e21ffdfebd0ca0ce3773085bcdf8511bda", 11982L, "57031aa0094ecbc73ad131892ca7870411e3faecd5c273781cd1edbd3ac6d3d8", 78834L, "3bf545828aae952c1af6476d7679d2216703fe85c0c7c8cd4af3c7fa4652f5d6"),
		Ready("ucs4102", "XAB1401", "AeonPortStructure", "Paragon Orb + authored death", "paragon_rotor_death", "8002739b4c792f498d8dc4ed779f26bfdffe2c748e629163170158d0a66222b9", "e0cc2ad914d66ef43330a1536d0220066eafd382f775eb5e00d36aad041ab855", "6eac84a1404e73ce1d56ce802865499f6e15d0febfa9a11296442eff2241bcb4", 254157L, "86308b50e880b3c1b537bdb9d3bc50e216c3c8ed29ba2f7c54a89a554492b03c", 1966L, "67c5ce6e621918873e416dfb6908bc77c53b26c471175c42bf6ec5446c613cd8", 15146L, "dd91105c12a86947fe7a8cceff74cbe7c977f2ed04ee2fd3cfe39e0ea14fd8d8", 2, new string[1] { "Orb" }, "Orb/y accelerates at 15 to deterministic source expression 80 +/- 0..20 continuously, independent of production Pause; death owns the one-second authored clip before stock wreck/delete.", Clip("AnimAdeath", "source_animadeath", "death", "XAB1401_Adeath.sca", 2104L, "aea31fdc1a6f905aafc3d60524cfa55276f04e727514d8dd3a813b7a53b4cff9", 31, 1.0)),
		Shield("ucs2401", "UAB4202", "T2 shield Rest baseline + Pod/Orb rotators + authored death", "shield_rotators_t2", "c39cfe68ae22bc35afc3b0ad385f2c10cc9cc6d2c13c5150dab76a74bea5219a", "22742862d8595e5c3655aa0fd840c741a88786823ca0e02d0d4ab8c3b83ab398", "1a4cd6057ca40bfe5f70c59429bc4c41b0e3674d7014b42ecfa2049928a080bb", 222721L, "0a30075fac1ee2f41c36aa41691e9f7051d20d0eed3591d365b69f65d9debe93", 2920L, "ad36f60ec26e59878e00f9f47dfe97e7dd9000f203d6a2f2f78ae485012e10f0", 21484L, "096fb8f0a2df5ef68e27a36ecadc423fe18d8d92f78a9abe026932c1ba93d13e", 2, new string[2] { "Pod", "Orb" }, "Rest remains the stable open baseline. Effective shield-up accelerates Pod/z to +60 at 50 deg/s^2 and Orb/x,z to -45,+45 at 45 deg/s^2; shield-down decelerates all to zero. AnimAdeath samples at source rate 0.5 before stock wreck/delete.", "Retail UAB4202 references shared UAB4202_Aopen.sca, but that clip is absent from every installed FA gamedata archive; no AnimOpen is required or invented.", Clip("AnimAdeath", "source_animadeath", "death", "UAB4202_Adeath.sca", 2888L, "b04902b9622b41419e417417888375018b3cc8c7c2fa6b0c35c3f12b0bef09ed", 30, 2.9, 0.5)),
		Shield("ucs3401", "UAB4301", "T3 shield Rest baseline + Pod/Orb rotators + authored death", "shield_rotators_t3", "10a69396b3f055763593e01f361fd6fd53b804707e92fc745607aa02e0122f0a", "1316a0c2e7a41408e681d3eff2a3be96794395132798e47d40a77e80f4367f41", "4bc07a7ab33d9924dc8f5f8cd7c35e8d5918e48c7999fb651ce703f5e7b6b584", 376801L, "6c3d9fab3912c82b0ad0a537209089846a740d50030f150f86060199dbc389d6", 2956L, "cb8056848ae2b221b6d3791fc8cb0f9d85588ce2ba7b1aecf121558182708066", 20896L, "c3a652b21a968437ecc3ff793087edd62c67bb2b31782fdc3510990fd1ca07c7", 2, new string[2] { "Pod", "Orb" }, "Rest remains the stable open baseline. Effective shield-up accelerates Pod/z to +60 at 50 deg/s^2 and Orb/y,z to -45,+45 at 45 deg/s^2; shield-down decelerates all to zero. AnimAdeath samples at source rate 0.5 before stock wreck/delete.", "Retail UAB4301 shares UAB4202_Aopen.sca, but that clip is absent from every installed FA gamedata archive; no AnimOpen is required or invented.", Clip("AnimAdeath", "source_animadeath", "death", "UAB4301_Adeath.sca", 2796L, "44a21eabe955c1c078777d1886937648ca1608627412f79006eb23a8ac009d59", 29, 2.8, 0.5)),
		Storage("ucs1612", "UAB1105", "energy storage fill animation", "energy", "a956cc05ab2d449c1252d0d2e088f55347da95b85f91428c4dde955dbcd2bd7b", "a5f7ba8a89f0c0077998e6c61227cd76ec80e82e3805946248d06b0c09df349c", "11b2a7fff14eec1065af230bd146239f7f60409cf94f9d8a55c6a81bb6980360", 144961L, "39f5cef40dae51fc9e37980e3334d4d4c6e73cf472f8819b3f9c7733fb30be3e", 2767L, "ca9428bf647e5370ebc1c04f436ded7b85aa8b38c42f4d25de61760e739ca43d", 5052L, "53b939b0d3dd705549cdc2d6d8aae839c5eee0ea21c3fe92d9c222b68bcd5710", 2, new string[2] { "Side_Pods", "Center_Pod" }, 0.045, 2522L, "aacbe385d003d3ad746ffb1f00ad868fb9e48943de7e1345eb57e3df53d5fde5", "AnimStorageLevel samples the army energy storage ratio at exact clip time; Side_Pods and Center_Pod travel +0.045 target-local Z from Rest."),
		Storage("ucs1602", "UAB1106", "alloy storage fill animation", "alloys", "67fa5432484ba5a246f0ed1920b3de446472d3d424d06547bdae20977b38776d", "457a7b3caff209098b4c15cf6c40e55c979d255bd33ab5509ce13ceed9e750b8", "c48e19b72b6498fded1b3ca8cb154b21316c1e66c41a528b962c22f1524b17c7", 80097L, "c95b0335578c28a8a9a3a2dba87feea0de95b2e81233ff4a867c2e1eaa6b8786", 1972L, "f4189318f001749dc350420c5e1ce0c9d24d8fb90c0ca68166ebc65f34d01bf1", 3784L, "df18bf803e7b60b51e24ad3cf560f357902213ee10413ab0ea78e28dcd4ca544", 2, new string[1] { "B01" }, 0.0615, 1888L, "edf1e4492856403d1726ddf26f148aca4c27d464d97e512122705ee4cee7bddd", "AnimStorageLevel samples the army alloys storage ratio at exact clip time; B01 travels +0.0615 target-local Z from Rest."),
		Blocked("ucs1614", "UAB1102", "AeonPortEnergyGenerator", "hydrocarbon perm-open", MotionStatus.Inactive, "226e38c51f687f906d0d30ba449d032223b40eed65aaff7bb8c0607b021f25b6", "2f154a0ac97bbbce7193a468cb2eae0fb676480cffcde2071690912f0f91247a", "3ac8c4c3413a668699a9ebbbae2451ac63d127bc8f276bcc19873fddf0e1aed1", 308201L, "9e765a7efbedea82de1a7d3e37b46ca0c066cc0cea7d23e5c1186b7aa377f69a", 31210L, "83b8176ccdce9f182230509002679a1206338dc2da710b926c3ec6279c8d9902", 163284L, "21da17cabb69f2f4584c7597239914d24b122309c5b6b74be3d21eeda4900575", 2, Array.Empty<string>(), "The separately installed HydroDisable owner removes availability and engineer build tags.", "Keep inactive until HydroDisable is deliberately retired and hydrocarbon-deposit placement is approved; then bind the existing AnimOpen 25-frame/2.4-second clip.")
	};

	public static readonly IReadOnlyList<StructureDisposition> StructureLedger = new StructureDisposition[50]
	{
		Disposition("ucs1601", "UAB1103", "closure", rosterVisible: true, "pump + upgrade"),
		Disposition("ucs2806", "UAB1104", "closure", rosterVisible: true, "fabricator open + rotor"),
		Disposition("ucs2601", "UAB1202", "closure", rosterVisible: true, "pump + upgrade"),
		Disposition("ucs2611", "UAB1201", "closure", rosterVisible: true, "authored death"),
		Disposition("ucs3611", "UAB1301", "closure", rosterVisible: true, "rotor + authored death"),
		Disposition("ucs3601", "UAB1302", "closure", rosterVisible: true, "pump state machine"),
		Disposition("ucs3603", "UAB1303", "closure", rosterVisible: true, "fabricator rotators"),
		Disposition("ucs2201", "UAB2204", "closure", rosterVisible: true, "permanent open"),
		Disposition("ucs2001", "UAB2301", "closure", rosterVisible: true, "permanent open"),
		Disposition("ucs2101", "UAB2303", "closure", rosterVisible: true, "permanent open"),
		Disposition("ucs3201", "UAB2304", "closure", rosterVisible: true, "permanent open"),
		Disposition("ucs1701", "UAB3101", "closure", rosterVisible: true, "effective-radar rotor + upgrade"),
		Disposition("ucs1702", "UAB3102", "closure", rosterVisible: true, "upgrade only"),
		Disposition("ucs3701", "UAB3104", "closure", rosterVisible: true, "effective-radar rotors"),
		Disposition("ucs2701", "UAB3201", "closure", rosterVisible: true, "effective-radar rotors + upgrade"),
		Disposition("ucs2702", "UAB3202", "closure", rosterVisible: true, "upgrade only"),
		Disposition("ucs2402", "UAB4201", "closure", rosterVisible: true, "Dome recoil; deploy remains externally owned"),
		Disposition("ucs2711", "UAB4203", "closure", rosterVisible: true, "detector-free visual jammer lifecycle; radar-stealth field remains unsupported provenance"),
		Disposition("ucs3402", "UAB4302", "closure", rosterVisible: true, "permanent open"),
		Disposition("ucs4102", "XAB1401", "closure", rosterVisible: true, "rotor + authored death"),
		Disposition("ucs2401", "UAB4202", "closure", rosterVisible: true, "shield rotators + authored death"),
		Disposition("ucs3401", "UAB4301", "closure", rosterVisible: true, "shield rotators + authored death"),
		Disposition("ucs1612", "UAB1105", "closure", rosterVisible: true, "energy storage-level clip"),
		Disposition("ucs1602", "UAB1106", "closure", rosterVisible: true, "alloys storage-level clip"),
		Disposition("ucs1614", "UAB1102", "inactive", rosterVisible: true, "HydroDisable owns availability"),
		Disposition("ucs2102", "UAB2108", "existing_owner", rosterVisible: true, "source weapon deploy/repack owner"),
		Disposition("ucs3102", "UAB2305", "existing_owner", rosterVisible: true, "source strategic animation owner"),
		Disposition("ucs1511", "UAB0101", "existing_owner", rosterVisible: true, "factory upgrade owner"),
		Disposition("ucs2511", "UAB0201", "existing_owner", rosterVisible: true, "factory upgrade owner"),
		Disposition("ucs1512", "UAB0102", "existing_owner", rosterVisible: true, "factory upgrade owner"),
		Disposition("ucs2512", "UAB0202", "existing_owner", rosterVisible: true, "factory upgrade owner"),
		Disposition("ucs1513", "UAB0103", "existing_owner", rosterVisible: true, "factory upgrade owner"),
		Disposition("ucs2513", "UAB0203", "existing_owner", rosterVisible: true, "factory upgrade owner"),
		Disposition("ucs3511", "UAB0301", "factory_runtime", rosterVisible: true, "stock land-factory lifecycle"),
		Disposition("ucs3512", "UAB0302", "factory_runtime", rosterVisible: true, "stock air-factory lifecycle"),
		Disposition("ucs3513", "UAB0303", "factory_runtime", rosterVisible: true, "stock naval-factory lifecycle"),
		Disposition("ucs2510", "UAB0304", "factory_runtime", rosterVisible: true, "stock quantum-gate lifecycle"),
		Disposition("ucs1611", "UAB1101", "source_static", rosterVisible: true, "no source non-death motion"),
		Disposition("ucs1804", "UAB5101", "source_static", rosterVisible: true, "wall is source-static"),
		Disposition("ucs3501", "UAB5202", "source_static", rosterVisible: true, "air staging is source-static"),
		Disposition("ucs3702", "XAB3301", "source_static", rosterVisible: true, "intel structure has no source motion"),
		Disposition("ucs1001", "UAB2101", "aim_only", rosterVisible: true, "weapon aim owns visible motion"),
		Disposition("ucs1201", "UAB2104", "aim_only", rosterVisible: true, "weapon aim owns visible motion"),
		Disposition("ucs1301", "UAB2109", "aim_only", rosterVisible: true, "weapon aim owns visible motion"),
		Disposition("ucs2301", "UAB2205", "aim_only", rosterVisible: true, "weapon aim owns visible motion"),
		Disposition("ucs3101", "UAB2302", "aim_only", rosterVisible: true, "weapon aim owns visible motion"),
		Disposition("ucs3001", "XAB2307", "aim_only", rosterVisible: true, "weapon aim owns visible motion"),
		Disposition("ucs2802", "UAB5102", "hidden", rosterVisible: false, "transport beacon helper"),
		Disposition("ucs2801", "UAB5103", "hidden", rosterVisible: false, "quantum-gate beacon helper"),
		Disposition("ucs1501", "UAB5204", "hidden", rosterVisible: false, "decal helper without a visual asset")
	};

	public static IReadOnlyList<MotionContract> ReadyContracts => All.Where((MotionContract contract) => contract.Status == MotionStatus.Ready).ToArray();

	public static IReadOnlyList<MotionContract> QuarantinedContracts => All.Where((MotionContract contract) => contract.Status == MotionStatus.Quarantined).ToArray();

	public static IReadOnlyList<MotionContract> InactiveContracts => All.Where((MotionContract contract) => contract.Status == MotionStatus.Inactive).ToArray();

	private static MotionContract PermanentOpen(string targetId, string sourceId, string role, string clipName, string key, string sourceFile, long clipBytes, string clipHash, int frames, double duration, string blueprintHash, string scriptHash, string sourceModelHash, long modelBytes, string modelHash, long skeletonBytes, string skeletonHash, long animationBytes, string animationHash)
	{
		return Ready(targetId, sourceId, "AeonPortStructure", role, "permanent_open", blueprintHash, scriptHash, sourceModelHash, modelBytes, modelHash, skeletonBytes, skeletonHash, animationBytes, animationHash, 2, Array.Empty<string>(), "OnStopBeingBuilt plays " + clipName + " once at source rate 1 with Clamp playback and retains its endpoint.", Clip(clipName, key, "permanent_open", sourceFile, clipBytes, clipHash, frames, duration));
	}

	private static MotionContract Ready(string targetId, string sourceId, string className, string role, string kind, string blueprintHash, string scriptHash, string sourceModelHash, long modelBytes, string modelHash, long skeletonBytes, string skeletonHash, long animationBytes, string animationHash, int clipCount, IEnumerable<string> bones, string state, params ClipPin[] clips)
	{
		return new MotionContract(targetId, sourceId, className, role, kind, MotionStatus.Ready, blueprintHash, scriptHash, sourceModelHash, Model(targetId, modelBytes, modelHash), Skeleton(targetId, skeletonBytes, skeletonHash), Animation(targetId, animationBytes, animationHash), clipCount, bones, clips, state);
	}

	private static MotionContract Shield(string targetId, string sourceId, string role, string kind, string blueprintHash, string scriptHash, string sourceModelHash, long modelBytes, string modelHash, long skeletonBytes, string skeletonHash, long animationBytes, string animationHash, int clipCount, IEnumerable<string> bones, string state, string auditedLimitation, ClipPin death)
	{
		return new MotionContract(targetId, sourceId, "AeonPortStructure", role, kind, MotionStatus.Ready, blueprintHash, scriptHash, sourceModelHash, Model(targetId, modelBytes, modelHash), Skeleton(targetId, skeletonBytes, skeletonHash), Animation(targetId, animationBytes, animationHash), clipCount, bones, new ClipPin[1] { death }, state, "", "", auditedLimitation);
	}

	private static MotionContract Storage(string targetId, string sourceId, string role, string resourceName, string blueprintHash, string scriptHash, string sourceModelHash, long modelBytes, string modelHash, long skeletonBytes, string skeletonHash, long animationBytes, string animationHash, int clipCount, IEnumerable<string> bones, double localZDelta, long stockAnimationBytes, string stockAnimationHash, string state)
	{
		return new MotionContract(targetId, sourceId, "AeonPortStorage", role, "storage_level", MotionStatus.Ready, blueprintHash, scriptHash, sourceModelHash, Model(targetId, modelBytes, modelHash), Skeleton(targetId, skeletonBytes, skeletonHash), Animation(targetId, animationBytes, animationHash), clipCount, bones, Array.Empty<ClipPin>(), state, "", "", "", Array.Empty<string>(), new StorageClipPin("AnimStorageLevel", "source_animstoragelevel", resourceName, 1.0, localZDelta, stockAnimationBytes, stockAnimationHash));
	}

	private static MotionContract Blocked(string targetId, string sourceId, string className, string role, MotionStatus status, string blueprintHash, string scriptHash, string sourceModelHash, long modelBytes, string modelHash, long skeletonBytes, string skeletonHash, long animationBytes, string animationHash, int clipCount, IEnumerable<string> bones, string blocker, string requirement)
	{
		return new MotionContract(targetId, sourceId, className, role, (status == MotionStatus.Inactive) ? "inactive" : "quarantined", status, blueprintHash, scriptHash, sourceModelHash, Model(targetId, modelBytes, modelHash), Skeleton(targetId, skeletonBytes, skeletonHash), Animation(targetId, animationBytes, animationHash), clipCount, bones, Array.Empty<ClipPin>(), blocker, blocker, requirement);
	}

	private static ClipPin Clip(string name, string key, string role, string file, long bytes, string hash, int frames, double duration, double rate = 1.0)
	{
		string text = file.Substring(0, file.IndexOf('_'));
		return new ClipPin(name, key, role, "units/" + text + "/" + file, bytes, hash, frames, duration, rate);
	}

	private static AssetPin Model(string id, long bytes, string hash)
	{
		return new AssetPin("Units/" + id + "/LOD0/" + id + "_lod0.sanmodel", bytes, hash);
	}

	private static AssetPin Skeleton(string id, long bytes, string hash)
	{
		return new AssetPin("Units/" + id + "/LOD0/" + id + ".sanskeleton", bytes, hash);
	}

	private static AssetPin Animation(string id, long bytes, string hash)
	{
		return new AssetPin("Units/" + id + "/LOD0/" + id + ".sananimation", bytes, hash);
	}

	private static StructureDisposition Disposition(string targetId, string sourceId, string owner, bool rosterVisible, string rationale)
	{
		return new StructureDisposition(targetId, sourceId, owner, rosterVisible, rationale);
	}
}
