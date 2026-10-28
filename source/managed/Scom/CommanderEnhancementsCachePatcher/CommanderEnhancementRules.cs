using System;
using System.Collections.Generic;
using System.Linq;

namespace CommanderEnhancementsCachePatcher;

internal static class CommanderEnhancementRules
{
	internal const string ContractVersion = "1.0.0";

	internal const string BaselineCaveat = "No local Supreme Commander app 9350 baseline was available; this contract asserts stock Forged Alliance only.";

	internal const string DescriptionPolicy = "Stock blueprints/localization provide names but no separate enhancement descriptions; descriptions faithfully render the encoded gameplay fields.";

	internal const string UnitsArchivePath = "D:\\Steam\\steamapps\\common\\Supreme Commander Forged Alliance\\gamedata\\units.scd";

	internal const string UnitsArchiveSha256 = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26";

	internal const string LuaArchivePath = "D:\\Steam\\steamapps\\common\\Supreme Commander Forged Alliance\\gamedata\\lua.scd";

	internal const string LuaArchiveSha256 = "3632A3294FC01A07EBE017DFD12CE4FF655C2D019934F1D7A784FBC1D4F314BB";

	internal const string MohodataArchivePath = "D:\\Steam\\steamapps\\common\\Supreme Commander Forged Alliance\\gamedata\\mohodata.scd";

	internal const string MohodataArchiveSha256 = "F57A18A1756632D6C125F806F50DBE28A6D7ADBDD85D2FC8AE99E23000253B04";

	internal const string LocalizationArchivePath = "D:\\Steam\\steamapps\\common\\Supreme Commander Forged Alliance\\gamedata\\loc_US.scd";

	internal const string LocalizationArchiveSha256 = "791733A0AF82446F0134BD52F20EF201F1084B6CA4FFAE8C87D0E62436411D7E";

	internal const string TexturesArchivePath = "D:\\Steam\\steamapps\\common\\Supreme Commander Forged Alliance\\gamedata\\textures.scd";

	internal const string TexturesArchiveSha256 = "5F48E3E283759CB71B65E6501063D0D4BD586FE67FC1CFA27672250D1A4F8FFD";

	internal static readonly IReadOnlyDictionary<string, CommanderRule> Commanders;

	private static readonly string[] AllowedEffectDomains;

	static CommanderEnhancementRules()
	{
		Commanders = BuildCommanders();
		AllowedEffectDomains = new string[9] { "engineering", "weapon", "shield", "economy", "intel", "spawn", "aura", "teleport", "visual" };
		Validate();
	}

	private static IReadOnlyDictionary<string, CommanderRule> BuildCommanders()
	{
		Dictionary<string, CommanderRule> dictionary = new Dictionary<string, CommanderRule>(StringComparer.Ordinal);
		dictionary["uel0000"] = Commander("uel0000", "UEL0001", "UEF", new CommanderBaseStats(12000.0, 10.0, 10.0, 20.0, 1.0, 26.0, 26.0, null, 18000.0, 5000000.0, 60000.0, 1.0, 2.0, 0.7), new VisualSlotRule(A("Left_Upgrade"), A("Right_Upgrade"), A("Back_Upgrade_B01")), BuildUef());
		dictionary["ucl0000"] = Commander("ucl0000", "UAL0001", "Aeon", new CommanderBaseStats(11000.0, 10.0, 10.0, 20.0, 1.0, 26.0, 26.0, null, 18000.0, 5000000.0, 60000.0, 1.0, 2.0, 0.7), new VisualSlotRule(A("Left_Upgrade"), A("Right_Upgrade"), A("Back_Upgrade")), BuildAeon());
		dictionary["ugl0000"] = Commander("ugl0000", "URL0001", "Cybran", new CommanderBaseStats(10000.0, 15.0, 10.0, 20.0, 1.0, 26.0, 26.0, 60.0, 18000.0, 5000000.0, 60000.0, 1.0, 2.2, 0.7), new VisualSlotRule(A("Right_Upgrade"), A("Chest_Right", "Chest_Left"), A("Back_Upgrade")), BuildCybran());
		dictionary["usl0000"] = Commander("usl0000", "XSL0001", "Seraphim", new CommanderBaseStats(11500.0, 10.0, 10.0, 20.0, 1.0, 26.0, 26.0, null, 18000.0, 5000000.0, 60000.0, 1.0, 2.2, 0.7), new VisualSlotRule(A("Left_Upgrade"), A("Right_Upgrade"), A("Back_Upgrade")), BuildSeraphim());
		return dictionary;
	}

	private static EnhancementRule[] BuildUef()
	{
		return new EnhancementRule[12]
		{
			R("AdvancedEngineering", "Tech 2 Engineering Suite", "enhancements_0037", "Sets build rate to 30, grants the UEF Tech 2 commander build category, and adds 3000 maximum health and 20 regeneration.", "aes", "LCH", null, A("DamageStablization"), A("AdvancedEngineering", "AdvancedEngineeringRemove"), 720.0, 18000.0, 900.0, "Remove Tech 2 Engineering Suite", "enhancements_0038", 0.1, Fx("engineering", "tier=2;buildRateSet=30;maxHealthAdd=3000;regenRateAdd=20;finalMaxHealth=15000;finalRegenRate=30;buffStacking=REPLACE;sourceBuildCategories=BUILTBYTIER2COMMANDER UEF;sanctuaryBuildTag=BUILDABLE_BY_T2_ENGINEER")),
			R("T3Engineering", "Tech 3 Engineering Suite", "enhancements_0053", "Replaces the Tech 2 engineering buff, sets build rate to 90, grants the UEF Tech 3 commander build category, and leaves 18000 health and 25 regeneration.", "ees", "LCH", "AdvancedEngineering", A("DamageStablization"), A("AdvancedEngineering", "T3Engineering", "T3EngineeringRemove"), 2400.0, 50000.0, 6000.0, "Remove Engineering Suites", "enhancements_0054", 0.1, Fx("engineering", "tier=3;buildRateSet=90;maxHealthAdd=6000;regenRateAdd=15;finalMaxHealth=18000;finalRegenRate=25;buffStacking=REPLACE;replacesPrerequisiteEffect=true;sourceBuildCategories=BUILTBYTIER3COMMANDER UEF;sanctuaryBuildTag=BUILDABLE_BY_T3_ENGINEER")),
			R("DamageStablization", "Nano-Repair System", "enhancements_0039", "Sets commander regeneration to exactly 200 health per second; the stock identifier intentionally retains its misspelling.", "dsu", "LCH", null, A("AdvancedEngineering", "T3Engineering"), A("DamageStablization", "DamageStablizationRemove"), 3000.0, 225000.0, 2000.0, "Remove Nano-Repair System", "enhancements_0040", 0.1, Fx("engineering", "regenRateSet=200;finalMaxHealth=12000;finalRegenRate=200")),
			R("HeavyAntiMatterCannon", "Zephyr Amplifier", "enhancements_0041", "Adds 100 damage to RightZephyr and extends RightZephyr and OverCharge maximum range from 22 to 30.", "hamc", "RCH", null, A("ResourceAllocation"), A("HeavyAntiMatterCannon", "HeavyAntiMatterCannonRemove"), 800.0, 24000.0, 800.0, "Remove Zephyr Amplifier", "enhancements_0042", 0.1, Fx("weapon", "RightZephyr{sourceDamage=100,damageAdd=100,finalDamage=200,sourceMaxRadius=22,maxRadiusSet=30,finalMaxRadius=30}|OverCharge{sourceMaxRadius=22,maxRadiusSet=30,finalMaxRadius=30}")),
			R("ResourceAllocation", "Resource Allocation System", "enhancements_0045", "Adds 3300 energy and 14 mass production per second, for final production 3320/15.", "isb", "RCH", null, A("HeavyAntiMatterCannon"), A("ResourceAllocation", "ResourceAllocationRemove"), 5000.0, 150000.0, 1000.0, "Remove Resource Allocation System", "enhancements_0046", 0.1, Fx("economy", "energyProductionAdd=3300;massProductionAdd=14;finalEnergyProduction=3320;finalMassProduction=15;buffStacking=REPLACE")),
			R("LeftPod", "C-D1 Shoulder Drone", "enhancements_0043", "Creates one UEA0001 shoulder engineering pod with build rate 5, health 6, vision 12, and commander build access.", "led", "Back", null, A("Shield", "ShieldGeneratorField", "TacticalMissile", "TacticalNukeMissile", "Teleporter"), A("LeftPod", "LeftPodRemove"), 120.0, 2400.0, 400.0, "Remove C-D1 Shoulder Drone", "enhancements_0044", 0.1, Fx("spawn", "sourceUnitId=UEA0001;count=1;resultingCount=1;spawnBone=AttachSpecial02;spawnOrigin=left shoulder;dockRotationDegrees=0,180,0;docksWhenIdle=true;freeFlyingWhenWorking=true;autoAssistsCreator=true;destroyOnRemoval=true;unit.buildRate=5;unit.maxHealth=6;unit.visionRadius=12;unit.sourceBuildCategories=BUILTBYCOMMANDER UEF;unit.categories=AIR,POD,ENGINEER,REPAIR,RECLAIM,CAPTURE", "visual", "show=Back_Upgrade_B01;hide="), null, null, "Destroy both runtime pod references if present."),
			R("RightPod", "C-D2 Shoulder Drone", "enhancements_0047", "Creates the second UEA0001 shoulder engineering pod after C-D1.", "red", "Back", "LeftPod", A("Shield", "ShieldGeneratorField", "TacticalMissile", "TacticalNukeMissile", "Teleporter"), A("LeftPod", "RightPod", "RightPodRemove"), 120.0, 2400.0, 400.0, "Remove C-D2 Shoulder Drone", "enhancements_0048", 0.1, Fx("spawn", "sourceUnitId=UEA0001;count=1;resultingCount=2;spawnBone=AttachSpecial01;spawnOrigin=right shoulder;dockRotationDegrees=0,180,0;docksWhenIdle=true;freeFlyingWhenWorking=true;autoAssistsCreator=true;stacksWithPrerequisite=true;destroyOnRemoval=true;unit.buildRate=5;unit.maxHealth=6;unit.visionRadius=12;unit.sourceBuildCategories=BUILTBYCOMMANDER UEF;unit.categories=AIR,POD,ENGINEER,REPAIR,RECLAIM,CAPTURE"), null, null, "Destroy both runtime pod references if present."),
			R("Shield", "Personal Shield Generator", "enhancements_0049", "Adds the stock 24000-health UEF personal shield; Sanctuary's radius-1.5 bubble conservatively encloses the stock UnitShield collision extents.", "psg", "Back", null, A("LeftPod", "RightPod", "TacticalMissile", "TacticalNukeMissile", "Teleporter"), A("Shield", "ShieldRemove"), 1500.0, 112500.0, 1500.0, "Remove Personal Shield Generator", "enhancements_0052", 0.1, Fx("shield", "personal=true;protectsNearbyUnits=false;maxHealth=24000;regenRate=35;rechargeTime=140;energyDrainRechargeTime=5;regenStartTime=1;maintenanceEnergy=250;regenAssistMultiplier=10;sourceShieldSize=3;sourceShieldSizeIgnoredByUnitShield=true;sourceUnitShieldCollision=0.75x1.5x0.525;sanctuaryRadius=1.5;radiusAdaptation=Stock CreatePersonalShield uses unit bounds times 0.75, radius 1.5 encloses the largest UnitShield extent;verticalOffset=0;ownerShieldMesh=/units/uel0001/UEL0001_PhaseShield_mesh;impactEffects=UEFShieldHit01"), Caps(null, null, A("RULEUTC_ShieldToggle")), Caps(null, A("RULEUTC_ShieldToggle"))),
			R("ShieldGeneratorField", "Shield Generator Field", "enhancements_0050", "Replaces the personal shield with the 36000-health field shield; Sanctuary radius 8 is half FA ShieldSize 16.", "sgf", "Back", "Shield", A("LeftPod", "RightPod", "TacticalMissile", "TacticalNukeMissile", "Teleporter"), A("Shield", "ShieldGeneratorField", "ShieldGeneratorFieldRemove"), 3000.0, 450000.0, 2000.0, "Remove Shields", "enhancements_0051", 0.1, Fx("shield", "personal=false;protectsNearbyUnits=true;replacesPrerequisiteEffect=true;maxHealth=36000;regenRate=42;rechargeTime=175;energyDrainRechargeTime=5;regenStartTime=1;maintenanceEnergy=500;sourceShieldSize=16;sanctuaryRadius=8;verticalOffset=-3;shieldEnhancementNumber=5;mesh=/effects/entities/Shield01/Shield01_mesh;meshZ=/effects/entities/Shield01/Shield01z_mesh;impactMesh=/effects/entities/ShieldSection01/ShieldSection01_mesh;impactEffects=UEFShieldHit01"), Caps(null, null, A("RULEUTC_ShieldToggle")), Caps(null, A("RULEUTC_ShieldToggle"))),
			R("TacticalMissile", "Tactical Missile Launcher", "enhancements_0055", "Enables the UEF ACU single-storage tactical missile silo and its manually fired 6000-damage missile.", "tm", "Back", null, A("LeftPod", "RightPod", "Shield", "ShieldGeneratorField", "Teleporter"), A("TacticalMissile", "TacticalMissileRemove"), 1000.0, 50000.0, 1000.0, "Remove Tactical Missile Launcher", "enhancements_0056", 0.1, Fx("weapon", "TacMissile{enabled=true,damage=6000,damageRadius=2,damageType=Normal,minRadius=5,maxRadius=256,rateOfFire=5,muzzleSalvoSize=1,muzzleSalvoDelay=0,projectileLifetime=80,projectileId=/projectiles/TIFMissileCruiseCDR/TIFMissileCruiseCDR_proj.bp,maxProjectileStorage=1,manualFire=true,countedProjectile=true,weaponCategory=Missile,targetRestrictDisallow=UNTARGETABLE}"), Caps(A("RULEUCC_Tactical", "RULEUCC_SiloBuildTactical")), Caps(null, A("RULEUCC_Tactical", "RULEUCC_SiloBuildTactical")), "Clear stored tactical ammunition."),
			R("TacticalNukeMissile", "The 'Billy': Advanced Tactical Missile Launcher", "enhancements_0057", "Replaces the tactical silo command with the single-storage Billy nuke and its exact inner/outer ring damage.", "srtn", "Back", "TacticalMissile", A("LeftPod", "RightPod", "Shield", "ShieldGeneratorField", "Teleporter"), A("TacticalMissile", "TacticalNukeMissile", "TacticalNukeMissileRemove"), 10800.0, 630000.0, 3600.0, "Remove Missile Launcher", "enhancements_0058", 0.1, Fx("weapon", "replacesPrerequisiteEffect=true;TacNukeMissile{enabled=true,damage=0,damageRadius=0,damageType=Normal,minRadius=5,maxRadius=256,rateOfFire=1,muzzleSalvoSize=1,muzzleSalvoDelay=0,projectileLifetime=80,projectileId=/projectiles/TIFMissileNukeCDR/TIFMissileNukeCDR_proj.bp,maxProjectileStorage=1,manualFire=true,countedProjectile=true,nukeWeapon=true,damageFriendly=true,innerDamage=12000,innerRadius=15,innerTicks=24,innerTotalTime=0,outerDamage=250,outerRadius=25,outerTicks=20,outerTotalTime=0,weaponCategory=Missile,targetRestrictDisallow=UNTARGETABLE}"), Caps(A("RULEUCC_Nuke", "RULEUCC_SiloBuildNuke"), A("RULEUCC_Tactical", "RULEUCC_SiloBuildTactical")), Caps(null, A("RULEUCC_Nuke", "RULEUCC_SiloBuildNuke")), "Clear stored tactical and nuke ammunition."),
			R("Teleporter", "Personal Teleporter", "enhancements_0059", "Enables personal teleport for 150000 energy over 15 seconds and no mass cost.", "pqt", "Back", null, A("LeftPod", "RightPod", "Shield", "ShieldGeneratorField", "TacticalMissile", "TacticalNukeMissile"), A("Teleporter", "TeleporterRemove"), 15000.0, 1500000.0, 3000.0, "Remove Personal Teleporter", "enhancements_0060", 0.1, Fx("teleport", "enabled=true;energyModifier=0.03;massModifier=0;timeModifier=0.0001;activationEnergy=150000;activationMass=0;activationTime=15;activationEnergyPerSecond=10000"), Caps(A("RULEUCC_Teleport")), Caps(null, A("RULEUCC_Teleport")))
		};
	}

	private static EnhancementRule[] BuildAeon()
	{
		return new EnhancementRule[11]
		{
			R("AdvancedEngineering", "Tech 2 Engineering Suite", "enhancements_0000", "Sets build rate to 30, grants the Aeon Tech 2 commander build category, and adds 3000 maximum health and 20 regeneration.", "aes", "LCH", null, A("CrysalisBeam"), A("AdvancedEngineering", "AdvancedEngineeringRemove"), 720.0, 18000.0, 900.0, "Remove Advanced Engineering Suite", "enhancements_0001", 0.1, Fx("engineering", "tier=2;buildRateSet=30;maxHealthAdd=3000;regenRateAdd=20;finalMaxHealth=14000;finalRegenRate=30;buffStacking=REPLACE;sourceBuildCategories=BUILTBYTIER2COMMANDER AEON;sanctuaryBuildTag=BUILDABLE_BY_T2_ENGINEER")),
			R("T3Engineering", "Tech 3 Engineering Suite", "enhancements_0018", "Replaces the Tech 2 engineering buff, sets build rate to 90, grants the Aeon Tech 3 commander build category, and leaves 17000 health and 25 regeneration.", "ees", "LCH", "AdvancedEngineering", A("CrysalisBeam"), A("AdvancedEngineering", "T3Engineering", "T3EngineeringRemove"), 2400.0, 50000.0, 6000.0, "Remove Engineering Suites", "enhancements_0019", 0.1, Fx("engineering", "tier=3;buildRateSet=90;maxHealthAdd=6000;regenRateAdd=15;finalMaxHealth=17000;finalRegenRate=25;buffStacking=REPLACE;replacesPrerequisiteEffect=true;sourceBuildCategories=BUILTBYTIER3COMMANDER AEON;sanctuaryBuildTag=BUILDABLE_BY_T3_ENGINEER")),
			R("CrysalisBeam", "Enhanced Quantum Disruptor", "enhancements_0004", "Extends RightDisruptor and OverCharge maximum range from 22 to 35.", "cba", "LCH", null, A("AdvancedEngineering", "T3Engineering"), A("CrysalisBeam", "CrysalisBeamRemove"), 500.0, 15000.0, 500.0, "Remove Enhanced Quantum Disruptor", "enhancements_0005", 0.1, Fx("weapon", "RightDisruptor{sourceMaxRadius=22,maxRadiusSet=35,finalMaxRadius=35}|OverCharge{sourceMaxRadius=22,maxRadiusSet=35,finalMaxRadius=35}")),
			R("EnhancedSensors", "Enhanced Sensor System", "enhancements_0006", "Sets vision radius to 50 and omni radius to 100.", "ess", "RCH", null, A("HeatSink"), A("EnhancedSensors", "EnhancedSensorsRemove"), 750.0, 12500.0, 625.0, "Remove Enhanced Sensor System", "enhancements_0007", 0.1, Fx("intel", "sourceVisionRadius=26;visionRadiusSet=50;sourceOmniRadius=26;omniRadiusSet=100")),
			R("HeatSink", "Quantum Accelerator", "enhancements_0008", "Doubles the RightDisruptor rate of fire from 1 to 2.", "hsa", "RCH", null, A("EnhancedSensors"), A("HeatSink", "HeatSinkRemove"), 500.0, 15000.0, 500.0, "Remove Quantum Accelerator", "enhancements_0009", 0.1, Fx("weapon", "RightDisruptor{sourceRateOfFire=1,rateOfFireSet=2,finalRateOfFire=2}")),
			R("ChronoDampener", "Chrono Dampener", "enhancements_0002", "Enables the range-22 pulse which stuns eligible mobile units for 3.5 seconds.", "cd", "Back", null, A("ResourceAllocation", "ResourceAllocationAdvanced", "Shield", "ShieldHeavy", "Teleporter"), A("ChronoDampener", "ChronoDampenerRemove"), 2500.0, 125000.0, 1250.0, "Remove Chrono Dampener", "enhancements_0003", 0.1, Fx("weapon", "ChronoDampener{enabled=true,damage=1,damageRadius=0,damageType=Normal,maxRadius=22,rateOfFire=0.2,energyRequired=200,energyDrainPerSecond=200,stunDuration=3.5,stunRadius=22,stunTargetAllow=MOBILE,stunTargetDisallow=EXPERIMENTAL,COMMAND,targetLayers=Land|Water|Seabed}")),
			R("ResourceAllocation", "Resource Allocation System", "enhancements_0010", "Adds 2700 energy and 18 mass production per second, for final production 2720/19.", "ras", "Back", null, A("ChronoDampener", "Shield", "ShieldHeavy", "Teleporter"), A("ResourceAllocation", "ResourceAllocationRemove"), 5000.0, 150000.0, 1000.0, "Remove Resource Allocation System", "enhancements_0013", 0.1, Fx("economy", "energyProductionAdd=2700;massProductionAdd=18;finalEnergyProduction=2720;finalMassProduction=19;buffStacking=REPLACE")),
			R("ResourceAllocationAdvanced", "Advanced Resource Allocation System", "enhancements_0011", "Replaces the basic allocation buff with 5400 energy and 36 mass production per second, for final production 5420/37.", "eras", "Back", "ResourceAllocation", A("ChronoDampener", "Shield", "ShieldHeavy", "Teleporter"), A("ResourceAllocation", "ResourceAllocationAdvanced", "ResourceAllocationAdvancedRemove"), 5000.0, 150000.0, 1000.0, "Remove Advanced Allocation System", "enhancements_0012", 0.1, Fx("economy", "energyProductionAdd=5400;massProductionAdd=36;finalEnergyProduction=5420;finalMassProduction=37;buffStacking=REPLACE;replacesPrerequisiteEffect=true")),
			R("Shield", "Personal Shield Generator", "enhancements_0014", "Adds the stock 29000-health Aeon unit shield; no ShieldSize is authored and Sanctuary radius 1.5 follows its largest collision extent.", "ptsg", "Back", null, A("ChronoDampener", "ResourceAllocation", "ResourceAllocationAdvanced", "Teleporter"), A("Shield", "ShieldRemove"), 1500.0, 93750.0, 1250.0, "Remove Personal Shield", "enhancements_0017", 0.1, Fx("shield", "personal=true;protectsNearbyUnits=false;maxHealth=29000;regenRate=37;rechargeTime=160;energyDrainRechargeTime=5;regenStartTime=1;maintenanceEnergy=250;regenAssistMultiplier=10;sourceShieldSize=absent;sourceUnitShieldCollision=0.75,1.5,0.525;sanctuaryRadius=1.5;ownerShieldMesh=/units/ual0001/ual0001_phaseshield_mesh;impactEffects=AeonShieldHit01"), Caps(null, null, A("RULEUTC_ShieldToggle")), Caps(null, A("RULEUTC_ShieldToggle"))),
			R("ShieldHeavy", "Heavy Personal Shield Generator", "enhancements_0015", "Replaces the personal shield with the stock 44000-health heavy unit shield; Sanctuary radius remains 1.5.", "phtsg", "Back", "Shield", A("ChronoDampener", "ResourceAllocation", "ResourceAllocationAdvanced", "Teleporter"), A("Shield", "ShieldHeavy", "ShieldHeavyRemove"), 4500.0, 1000000.0, 2500.0, "Remove Shields", "enhancements_0016", 0.1, Fx("shield", "personal=true;protectsNearbyUnits=false;replacesPrerequisiteEffect=true;maxHealth=44000;regenRate=44;rechargeTime=200;energyDrainRechargeTime=5;regenStartTime=1;maintenanceEnergy=500;sourceShieldSize=absent;sourceUnitShieldCollision=0.75,1.5,0.525;sanctuaryRadius=1.5;ownerShieldMesh=/units/ual0001/ual0001_phaseshield_mesh;impactEffects=AeonShieldHit01"), Caps(null, null, A("RULEUTC_ShieldToggle")), Caps(null, A("RULEUTC_ShieldToggle"))),
			R("Teleporter", "Personal Teleporter", "enhancements_0020", "Enables personal teleport for 150000 energy over 15 seconds and no mass cost.", "pqt", "Back", null, A("ChronoDampener", "ResourceAllocation", "ResourceAllocationAdvanced", "Shield", "ShieldHeavy"), A("Teleporter", "TeleporterRemove"), 15000.0, 1500000.0, 3000.0, "Remove Personal Teleporter", "enhancements_0021", 0.1, Fx("teleport", "enabled=true;energyModifier=0.03;massModifier=0;timeModifier=0.0001;activationEnergy=150000;activationMass=0;activationTime=15;activationEnergyPerSecond=10000"), Caps(A("RULEUCC_Teleport")), Caps(null, A("RULEUCC_Teleport")))
		};
	}

	private static EnhancementRule[] BuildCybran()
	{
		return new EnhancementRule[9]
		{
			R("AdvancedEngineering", "Tech 2 Engineering Suite", "enhancements_0077", "Sets build rate to 30, grants the Cybran Tech 2 commander build category, and adds 3500 maximum health and 20 regeneration.", "aes", "LCH", null, A("CoolingUpgrade"), A("AdvancedEngineering", "AdvancedEngineeringRemove"), 720.0, 18000.0, 900.0, "Remove Engineering Suite", "enhancements_0078", 0.1, Fx("engineering", "tier=2;buildRateSet=30;maxHealthAdd=3500;regenRateAdd=20;finalMaxHealth=13500;finalRegenRate=35;buffStacking=REPLACE;sourceBuildCategories=BUILTBYTIER2COMMANDER CYBRAN;sanctuaryBuildTag=BUILDABLE_BY_T2_ENGINEER")),
			R("T3Engineering", "Tech 3 Engineering Suite", "enhancements_0103", "Replaces the Tech 2 engineering buff, sets build rate to 90, grants the Cybran Tech 3 commander build category, and leaves 17000 health and 30 regeneration.", "ees", "LCH", "AdvancedEngineering", A("CoolingUpgrade"), A("AdvancedEngineering", "T3Engineering", "T3EngineeringRemove"), 2400.0, 50000.0, 6000.0, "Remove Tech 3 Engineering Suite", "enhancements_0104", 0.1, Fx("engineering", "tier=3;buildRateSet=90;maxHealthAdd=7000;regenRateAdd=15;finalMaxHealth=17000;finalRegenRate=30;buffStacking=REPLACE;replacesPrerequisiteEffect=true;sourceBuildCategories=BUILTBYTIER3COMMANDER CYBRAN;sanctuaryBuildTag=BUILDABLE_BY_T3_ENGINEER")),
			R("CoolingUpgrade", "Microwave Accelerator", "enhancements_0081", "Extends RightRipper and OverCharge to range 30, doubles RightRipper rate of fire, and extends an installed MLG to range 30.", "acu", "LCH", null, A("AdvancedEngineering", "T3Engineering"), A("CoolingUpgrade", "CoolingUpgradeRemove"), 800.0, 24000.0, 800.0, "Remove Microwave Accelerator", "enhancements_0082", 0.1, Fx("weapon", "RightRipper{sourceMaxRadius=22,maxRadiusSet=30,finalMaxRadius=30,sourceRateOfFire=1,rateOfFireSet=2,finalRateOfFire=2}|OverCharge{sourceMaxRadius=22,maxRadiusSet=30,finalMaxRadius=30}|MLG{conditionalOnEnhancement=MicrowaveLaserGenerator,sourceMaxRadius=22,maxRadiusSet=30,finalMaxRadius=30}")),
			R("MicrowaveLaserGenerator", "Microwave Laser Generator", "enhancements_0083", "Enables the continuous MLG chest beam at range 22 (30 with Microwave Accelerator), preserving the stock 4000 sustained DPS.", "mlg", "RCH", null, A("NaniteTorpedoTube"), A("MicrowaveLaserGenerator", "MicrowaveLaserGeneratorRemove"), 4000.0, 500000.0, 2000.0, "Remove Microwave Laser Generator", "enhancements_0084", 10.0, Fx("weapon", "MLG{enabled=true,sourceDamage=800,sourceBeamLifetime=0,sourceBeamCollisionDelay=0.1,effectiveCollisionInterval=0.2,damage=800,collisionTicks=2,damagePerSecond=4000,beamLifetime=-1,damageRadius=0.5,damageType=Normal,maxRadius=22,maxRadiusWithCoolingUpgrade=30,rateOfFire=3,headingArcCenter=0,headingArcRange=180,muzzleSalvoSize=1,muzzleSalvoDelay=0,weaponCategory=Direct Fire Experimental,targetRestrictDisallow=UNTARGETABLE}", "visual", "show=;hide=Chest_Right,Chest_Left")),
			R("NaniteTorpedoTube", "Nanite Torpedo Launcher", "enhancements_0085", "Enables the four-shot Nanite Torpedo salvo and sets sonar radius to 60.", "ntt", "RCH", null, A("MicrowaveLaserGenerator"), A("NaniteTorpedoTube", "NaniteTorpedoTubeRemove"), 1500.0, 37500.0, 1500.0, "Remove Nanite Torpedo Launcher", "enhancements_0086", 10.0, Fx("intel", "sonarRadiusSet=60", "weapon", "Torpedo{enabled=true,damage=250,damageType=Normal,maxRadius=60,rateOfFire=0.25,muzzleVelocity=5,muzzleSalvoSize=4,muzzleSalvoDelay=0.8,projectileLifetime=7,projectileId=/projectiles/CANTorpedoNanite01/CANTorpedoNanite01_proj.bp,projectileAdaptation=Uses exact pgr305t CANTorpedoNanite01-derived underwater TargetEntity movement/VFX with a scoped NAVAL MOBILE minus HOVER filter; StayUnderwater and the Nanite emitter graph are unavailable,targetLayers=Seabed|Sub|Water|WaterSurface,targetRestrictDisallow=UNTARGETABLE, HOVER,weaponCategory=Anti Navy}", "visual", "show=;hide=Chest_Right,Chest_Left")),
			R("StealthGenerator", "Personal Stealth Generator", "enhancements_0101", "Enables radar and sonar stealth at 50 energy per second and adds the cloak toggle.", "psg", "Back", null, A("ResourceAllocation", "Teleporter"), A("StealthGenerator", "StealthGeneratorRemove"), 350.0, 5250.0, 350.0, "Remove Personal Stealth Generator", "enhancements_0102", 10.0, Fx("intel", "radarStealth=true;sonarStealth=true;cloak=false;maintenanceEnergy=50"), Caps(null, null, A("RULEUTC_CloakToggle")), Caps(null, A("RULEUTC_CloakToggle")), "Disable radar and sonar stealth."),
			R("CloakingGenerator", "Personal Cloaking Generator", "enhancements_0079", "Adds personal cloak and 15000 maximum health while retaining prerequisite stealth, at 3000 energy per second.", "pcg", "Back", "StealthGenerator", A("ResourceAllocation", "Teleporter"), A("StealthGenerator", "CloakingGenerator", "CloakingGeneratorRemove"), 6000.0, 750000.0, 3000.0, "Remove Personal Cloaking Generator", "enhancements_0080", 1.0, Fx("intel", "cloak=true;radarStealthFromPrerequisite=true;sonarStealthFromPrerequisite=true;maintenanceEnergy=3000", "engineering", "maxHealthAdd=15000;finalMaxHealth=25000;buffStacking=ALWAYS"), Caps(null, null, A("RULEUTC_CloakToggle")), Caps(null, A("RULEUTC_CloakToggle")), "Disable cloak and remove 15000 health; stock quirk does not explicitly disable prerequisite radar/sonar stealth."),
			R("ResourceAllocation", "Resource Allocation System", "enhancements_0087", "Adds 3500 energy and 12 mass production per second, for final production 3520/13.", "ras", "Back", null, A("StealthGenerator", "CloakingGenerator", "Teleporter"), A("ResourceAllocation", "ResourceAllocationRemove"), 5000.0, 150000.0, 1000.0, "Remove Resource Allocation System", "enhancements_0088", 0.1, Fx("economy", "energyProductionAdd=3500;massProductionAdd=12;finalEnergyProduction=3520;finalMassProduction=13;buffStacking=REPLACE")),
			R("Teleporter", "Personal Teleporter", "enhancements_0105", "Enables personal teleport for 150000 energy over 15 seconds and no mass cost.", "pqt", "Back", null, A("StealthGenerator", "CloakingGenerator", "ResourceAllocation"), A("Teleporter", "TeleporterRemove"), 15000.0, 1500000.0, 3000.0, "Remove Personal Teleporter", "enhancements_0106", 0.1, Fx("teleport", "enabled=true;energyModifier=0.03;massModifier=0;timeModifier=0.0001;activationEnergy=150000;activationMass=0;activationTime=15;activationEnergyPerSecond=10000"), Caps(A("RULEUCC_Teleport")), Caps(null, A("RULEUCC_Teleport")))
		};
	}

	private static EnhancementRule[] BuildSeraphim()
	{
		return new EnhancementRule[12]
		{
			R("AdvancedEngineering", "Tech 2 Engineering Suite", "enhancements_0000", "Sets build rate to 30, grants the Seraphim Tech 2 commander build category, and adds 3000 maximum health and 20 regeneration.", "aes", "LCH", null, A("BlastAttack"), A("AdvancedEngineering", "AdvancedEngineeringRemove"), 720.0, 18000.0, 900.0, "Remove Advanced Engineering Suite", "enhancements_0001", 0.1, Fx("engineering", "tier=2;buildRateSet=30;maxHealthAdd=3000;regenRateAdd=20;finalMaxHealth=14500;finalRegenRate=30;buffStacking=REPLACE;sourceBuildCategories=BUILTBYTIER2COMMANDER SERAPHIM;sanctuaryBuildTag=BUILDABLE_BY_T2_ENGINEER")),
			R("T3Engineering", "Tech 3 Engineering Suite", "enhancements_0018", "Replaces the Tech 2 engineering buff, sets build rate to 90, grants the Seraphim Tech 3 commander build category, and leaves 15500 health and 25 regeneration.", "ees", "LCH", "AdvancedEngineering", A("BlastAttack"), A("AdvancedEngineering", "T3Engineering", "T3EngineeringRemove"), 2400.0, 50000.0, 6000.0, "Remove Engineering Suites", "enhancements_0019", 0.1, Fx("engineering", "tier=3;buildRateSet=90;maxHealthAdd=4000;regenRateAdd=15;finalMaxHealth=15500;finalRegenRate=25;buffStacking=REPLACE;replacesPrerequisiteEffect=true;sourceBuildCategories=BUILTBYTIER3COMMANDER SERAPHIM;sanctuaryBuildTag=BUILDABLE_BY_T3_ENGINEER")),
			R("BlastAttack", "Refracting Chronotron Amplifier", "enhancements_0129", "Adds 300 damage and 2 radius to ChronotronCannon; stock removal erroneously leaves an accumulated +7 radius modifier.", "cba", "LCH", null, A("AdvancedEngineering", "T3Engineering"), A("BlastAttack", "BlastAttackRemove"), 4500.0, 300000.0, 3000.0, "Remove Refracting Chronotron Amplifier", "enhancements_0130", 0.1, Fx("weapon", "ChronotronCannon{sourceDamage=100,damageAdd=300,finalDamage=400,damageRadiusAdd=2}"), null, null, "Source removal damage add -300; absent NewDamageRadius falls back to +5, leaving accumulated damageRadiusAdd=7."),
			R("RegenAura", "Restoration Field", "enhancements_0125", "Runs a radius-15 allied regeneration aura refreshed every 5 seconds, using factor 0.0055555555 and cap 75.", "nrf", "RCH", null, A("RateOfFire"), A("RegenAura", "RegenAuraRemove"), 600.0, 4500.0, 600.0, "Remove Restoration Field", "enhancements_0126", 0.1, Fx("aura", "radius=15;regenPerSecond=0.0055555555;regenFloor=0;regenCeiling=75;maxHealthFactor=1;duration=5;reapplyInterval=5;targetArmy=Own;sourceCategoryExpression=BUILTBYTIER3FACTORY + BUILTBYQUANTUMGATE + NEEDMOBILEBUILD"), null, null, "Stop the aura thread."),
			R("AdvancedRegenAura", "Rapid Restoration Field", "enhancements_0127", "Replaces the base aura thread with radius 25, factor 0.01111111111, cap 200, and no actual max-health increase.", "anrf", "RCH", "RegenAura", A("RateOfFire"), A("AdvancedRegenAura", "AdvancedRegenAuraRemove"), 1500.0, 31250.0, 1250.0, "Remove Rapid Restoration Field", "enhancements_0128", 0.1, Fx("aura", "replacesPrerequisiteEffect=true;radius=25;regenPerSecond=0.01111111111;regenFloor=0;regenCeiling=200;maxHealthFactor=1;actualMaxHealthIncrease=0;duration=5;reapplyInterval=5;targetArmy=Own;sourceCategoryExpression=BUILTBYTIER3FACTORY + BUILTBYQUANTUMGATE + NEEDMOBILEBUILD"), null, null, "Stop the advanced aura; stock remover lists only AdvancedRegenAura and does not restart the prerequisite aura."),
			R("RateOfFire", "Chronotron Accelerator", "enhancements_0137", "Extends ChronotronCannon and OverCharge range to 30 and doubles the primary cannon rate of fire to 2.", "hsa", "RCH", null, A("RegenAura", "AdvancedRegenAura"), A("RateOfFire", "RateOfFireRemove"), 800.0, 24000.0, 800.0, "Remove Chronotron Accelerator", "enhancements_0138", 0.1, Fx("weapon", "ChronotronCannon{sourceMaxRadius=22,maxRadiusSet=30,finalMaxRadius=30,sourceRateOfFire=1,rateOfFireSet=2,finalRateOfFire=2}|OverCharge{sourceMaxRadius=22,maxRadiusSet=30,finalMaxRadius=30}")),
			R("DamageStabilization", "Nano-Repair System", "enhancements_0131", "Adds 6000 maximum health and 75 regeneration per second, for 17500 health and 85 regeneration.", "dss", "Back", null, A("Missile", "ResourceAllocation", "ResourceAllocationAdvanced", "Teleporter"), A("DamageStabilization", "DamageStabilizationRemove"), 2000.0, 90000.0, 2000.0, "Remove Nano-Repair System", "enhancements_0132", 0.1, Fx("engineering", "maxHealthAdd=6000;regenRateAdd=75;finalMaxHealth=17500;finalRegenRate=85;buffStacking=ALWAYS")),
			R("DamageStabilizationAdvanced", "Enhanced Nano-Repair System", "enhancements_0133", "Stacks with the base repair buff, adding 20000 health and 150 regeneration for final 37500/235.", "adss", "Back", "DamageStabilization", A("Missile", "ResourceAllocation", "ResourceAllocationAdvanced", "Teleporter"), A("DamageStabilizationAdvanced", "DamageStabilizationAdvancedRemove"), 4500.0, 450000.0, 3000.0, "Remove Enhanced Nano-Repair System", "enhancements_0134", 0.1, Fx("engineering", "maxHealthAdd=20000;regenRateAdd=150;finalMaxHealth=37500;finalRegenRate=235;buffStacking=ALWAYS;stacksWithPrerequisiteEffect=true"), null, null, "Removal blueprint lists only the advanced enhancement, but the stock script removes both base and advanced buffs."),
			R("Missile", "Tactical Missile Launcher", "enhancements_0135", "Enables the Seraphim ACU single-storage tactical missile silo and its manually fired 6000-damage missile.", "tml", "Back", null, A("DamageStabilization", "DamageStabilizationAdvanced", "ResourceAllocation", "ResourceAllocationAdvanced", "Teleporter"), A("Missile", "MissileRemove"), 1000.0, 50000.0, 1000.0, "Remove Tactical Missile Launcher", "enhancements_0136", 0.1, Fx("weapon", "Missile{enabled=true,damage=6000,damageRadius=3,damageType=Normal,minRadius=5,maxRadius=256,rateOfFire=1,muzzleSalvoSize=1,muzzleSalvoDelay=0,projectileLifetime=80,projectileId=/projectiles/SIFLaanseTacticalMissileCDR/SIFLaanseTacticalMissileCDR_proj.bp,maxProjectileStorage=1,manualFire=true,countedProjectile=true,weaponCategory=Missile,targetRestrictDisallow=UNTARGETABLE}"), Caps(A("RULEUCC_Tactical", "RULEUCC_SiloBuildTactical")), Caps(null, A("RULEUCC_Tactical", "RULEUCC_SiloBuildTactical")), "Stock removal does not explicitly purge stored tactical ammunition."),
			R("ResourceAllocation", "Resource Allocation System", "enhancements_0010", "Adds 3000 energy and 16 mass production per second, for final production 3020/17.", "ras", "Back", null, A("DamageStabilization", "DamageStabilizationAdvanced", "Missile", "Teleporter"), A("ResourceAllocation", "ResourceAllocationRemove"), 5000.0, 150000.0, 1000.0, "Remove Resource Allocation System", "enhancements_0013", 0.1, Fx("economy", "energyProductionAdd=3000;massProductionAdd=16;finalEnergyProduction=3020;finalMassProduction=17;buffStacking=REPLACE")),
			R("ResourceAllocationAdvanced", "Advanced Resource Allocation System", "enhancements_0011", "Replaces the basic allocation buff with 6000 energy and 32 mass production per second, for final production 6020/33.", "eras", "Back", "ResourceAllocation", A("DamageStabilization", "DamageStabilizationAdvanced", "Missile", "Teleporter"), A("ResourceAllocation", "ResourceAllocationAdvanced", "ResourceAllocationAdvancedRemove"), 5000.0, 150000.0, 1000.0, "Remove Advanced Allocation System", "enhancements_0012", 0.1, Fx("economy", "energyProductionAdd=6000;massProductionAdd=32;finalEnergyProduction=6020;finalMassProduction=33;buffStacking=REPLACE;replacesPrerequisiteEffect=true")),
			R("Teleporter", "Personal Teleporter", "enhancements_0020", "Enables personal teleport for 150000 energy over 15 seconds and no mass cost.", "pqt", "Back", null, A("DamageStabilization", "DamageStabilizationAdvanced", "Missile", "ResourceAllocation", "ResourceAllocationAdvanced"), A("Teleporter", "TeleporterRemove"), 15000.0, 1500000.0, 3000.0, "Remove Personal Teleporter", "enhancements_0021", 0.1, Fx("teleport", "enabled=true;energyModifier=0.03;massModifier=0;timeModifier=0.0001;activationEnergy=150000;activationMass=0;activationTime=15;activationEnergyPerSecond=10000"), Caps(A("RULEUCC_Teleport")), Caps(null, A("RULEUCC_Teleport")))
		};
	}

	private static CommanderRule Commander(string templateId, string sourceId, string faction, CommanderBaseStats baseStats, VisualSlotRule visualSlots, EnhancementRule[] rules)
	{
		Dictionary<string, EnhancementRule> dictionary = new Dictionary<string, EnhancementRule>(StringComparer.Ordinal);
		foreach (EnhancementRule enhancementRule in rules)
		{
			if (dictionary.ContainsKey(enhancementRule.Id))
			{
				throw new InvalidOperationException("Commander '" + templateId + "' duplicates enhancement '" + enhancementRule.Id + "'.");
			}
			dictionary.Add(enhancementRule.Id, enhancementRule);
		}
		return new CommanderRule(templateId, sourceId, faction, baseStats, visualSlots, dictionary);
	}

	private static EnhancementRule R(string id, string name, string nameLocKey, string description, string icon, string slot, string? prerequisite, string[] conflicts, string[] remove, double mass, double energy, double buildTime, string removalName, string removalLocKey, double removalBuildTime, IReadOnlyDictionary<string, string> effects, CapabilityRule? capabilities = null, CapabilityRule? removalCapabilities = null, string removalRuntime = "")
	{
		return new EnhancementRule(id, name, nameLocKey, description, icon, slot, prerequisite, conflicts, remove, new EnhancementCost(mass, energy, buildTime), effects, capabilities ?? Caps(), new RemovalRule(id + "Remove", removalName, removalLocKey, new EnhancementCost(1.0, 1.0, removalBuildTime), removalCapabilities ?? Caps(), removalRuntime));
	}

	private static IReadOnlyDictionary<string, string> Fx(params string[] domainAndContract)
	{
		if (domainAndContract.Length == 0 || domainAndContract.Length % 2 != 0)
		{
			throw new InvalidOperationException("Effect contracts must contain domain/value pairs.");
		}
		Dictionary<string, string> dictionary = new Dictionary<string, string>(StringComparer.Ordinal);
		for (int i = 0; i < domainAndContract.Length; i += 2)
		{
			dictionary.Add(domainAndContract[i], domainAndContract[i + 1]);
		}
		return dictionary;
	}

	private static CapabilityRule Caps(string[]? add = null, string[]? remove = null, string[]? toggles = null)
	{
		return new CapabilityRule(add ?? Array.Empty<string>(), remove ?? Array.Empty<string>(), toggles ?? Array.Empty<string>());
	}

	private static string[] A(params string[] values)
	{
		return values;
	}

	internal static void Validate()
	{
		Dictionary<string, (string, string, int)> dictionary = new Dictionary<string, (string, string, int)>(StringComparer.Ordinal)
		{
			["uel0000"] = ("UEL0001", "UEF", 12),
			["ucl0000"] = ("UAL0001", "Aeon", 11),
			["ugl0000"] = ("URL0001", "Cybran", 9),
			["usl0000"] = ("XSL0001", "Seraphim", 12)
		};
		if (Commanders.Count != dictionary.Count || Commanders.Keys.Except<string>(dictionary.Keys, StringComparer.Ordinal).Any())
		{
			throw new InvalidOperationException("Commander enhancement contract must contain exactly uel0000, ucl0000, ugl0000, and usl0000.");
		}
		HashSet<string> hashSet = new HashSet<string>(StringComparer.Ordinal);
		foreach (KeyValuePair<string, CommanderRule> commander in Commanders)
		{
			string key = commander.Key;
			CommanderRule value = commander.Value;
			var (b, b2, num) = dictionary[key];
			if (!string.Equals(value.TemplateId, key, StringComparison.Ordinal) || !string.Equals(value.SourceId, b, StringComparison.Ordinal) || !string.Equals(value.Faction, b2, StringComparison.Ordinal) || value.Enhancements.Count != num)
			{
				throw new InvalidOperationException("Commander '" + key + "' identity or enhancement count drifted from stock FA.");
			}
			ValidateBase(value);
			HashSet<string> hashSet2 = new HashSet<string>(StringComparer.Ordinal);
			foreach (KeyValuePair<string, EnhancementRule> enhancement in value.Enhancements)
			{
				EnhancementRule value2 = enhancement.Value;
				string text = key + "/" + value2.Id;
				if (!hashSet.Add(text) || !string.Equals(enhancement.Key, value2.Id, StringComparison.Ordinal))
				{
					throw new InvalidOperationException("Enhancement '" + text + "' is duplicated or keyed incorrectly.");
				}
				if (string.IsNullOrWhiteSpace(value2.Id) || string.IsNullOrWhiteSpace(value2.Name) || string.IsNullOrWhiteSpace(value2.NameLocKey) || string.IsNullOrWhiteSpace(value2.Description) || string.IsNullOrWhiteSpace(value2.Icon) || !new string[3] { "LCH", "RCH", "Back" }.Contains<string>(value2.Slot, StringComparer.Ordinal))
				{
					throw new InvalidOperationException("Enhancement '" + text + "' has incomplete display or slot metadata.");
				}
				ValidatePositiveCost(text, value2.Cost);
				ValidatePositiveCost(text + "/removal", value2.Removal.Cost);
				if (!hashSet2.Add(value2.Removal.Id) || !string.Equals(value2.Removal.Id, value2.Id + "Remove", StringComparison.Ordinal))
				{
					throw new InvalidOperationException("Enhancement '" + text + "' has an invalid or duplicate remover ID.");
				}
				if (value2.Remove.Distinct<string>(StringComparer.Ordinal).Count() != value2.Remove.Count || !value2.Remove.Contains<string>(value2.Id, StringComparer.Ordinal) || !value2.Remove.Contains<string>(value2.Removal.Id, StringComparer.Ordinal))
				{
					throw new InvalidOperationException("Enhancement '" + text + "' does not encode the stock self/remover removal semantics.");
				}
				foreach (string item in value2.Remove)
				{
					if (!string.Equals(item, value2.Removal.Id, StringComparison.Ordinal) && !value.Enhancements.ContainsKey(item))
					{
						throw new InvalidOperationException("Enhancement '" + text + "' removes unknown ID '" + item + "'.");
					}
				}
				if (value2.Prerequisite != null)
				{
					if (!value.Enhancements.TryGetValue(value2.Prerequisite, out EnhancementRule value3) || !string.Equals(value3.Slot, value2.Slot, StringComparison.Ordinal))
					{
						throw new InvalidOperationException("Enhancement '" + text + "' has an absent or cross-slot prerequisite '" + value2.Prerequisite + "'.");
					}
					if ((!(key == "usl0000") || (!(value2.Id == "AdvancedRegenAura") && !(value2.Id == "DamageStabilizationAdvanced"))) && !value2.Remove.Contains<string>(value2.Prerequisite, StringComparer.Ordinal))
					{
						throw new InvalidOperationException("Enhancement '" + text + "' remover must also remove prerequisite '" + value2.Prerequisite + "'.");
					}
				}
				foreach (string conflict in value2.Conflicts)
				{
					if (!value.Enhancements.TryGetValue(conflict, out EnhancementRule value4) || !string.Equals(value4.Slot, value2.Slot, StringComparison.Ordinal) || !value4.Conflicts.Contains<string>(value2.Id, StringComparer.Ordinal))
					{
						throw new InvalidOperationException("Enhancement '" + text + "' has an absent, cross-slot, or asymmetric conflict '" + conflict + "'.");
					}
				}
				if (value2.Effects.Count == 0 || value2.Effects.Keys.Except<string>(AllowedEffectDomains, StringComparer.Ordinal).Any())
				{
					throw new InvalidOperationException("Enhancement '" + text + "' has an empty or unknown effect domain.");
				}
				ValidateCapabilities(text, value2.Capabilities);
				ValidateCapabilities(text + "/removal", value2.Removal.Capabilities);
			}
			ValidatePrerequisiteCycles(value);
		}
		if (hashSet.Count != 44)
		{
			throw new InvalidOperationException($"Expected 44 stock FA commander enhancements, found {hashSet.Count}.");
		}
		ValidateExactCosts(hashSet);
		ValidateHighRiskEffects();
	}

	private static void ValidateBase(CommanderRule commander)
	{
		CommanderBaseStats commanderBaseStats = commander.Base;
		if (commanderBaseStats.MaxHealth <= 0.0 || commanderBaseStats.RegenRate <= 0.0 || commanderBaseStats.BuildRate <= 0.0 || commanderBaseStats.EnergyProduction <= 0.0 || commanderBaseStats.MassProduction <= 0.0 || commanderBaseStats.VisionRadius <= 0.0 || commanderBaseStats.OmniRadius <= 0.0 || commanderBaseStats.BuildCostMass <= 0.0 || commanderBaseStats.BuildCostEnergy <= 0.0 || commanderBaseStats.BuildTime <= 0.0 || commanderBaseStats.SizeX <= 0.0 || commanderBaseStats.SizeY <= 0.0 || commanderBaseStats.SizeZ <= 0.0)
		{
			throw new InvalidOperationException("Commander '" + commander.TemplateId + "' has a missing or non-positive base stat.");
		}
		PinBase("uel0000", 12000.0, 10.0, 10.0, 20.0, 1.0, 26.0, 26.0, null, 1.0, 2.0, 0.7);
		PinBase("ucl0000", 11000.0, 10.0, 10.0, 20.0, 1.0, 26.0, 26.0, null, 1.0, 2.0, 0.7);
		PinBase("ugl0000", 10000.0, 15.0, 10.0, 20.0, 1.0, 26.0, 26.0, 60.0, 1.0, 2.2, 0.7);
		PinBase("usl0000", 11500.0, 10.0, 10.0, 20.0, 1.0, 26.0, 26.0, null, 1.0, 2.2, 0.7);
	}

	private static void PinBase(string templateId, double health, double regen, double buildRate, double energy, double mass, double vision, double omni, double? sonar, double sizeX, double sizeY, double sizeZ)
	{
		CommanderBaseStats commanderBaseStats = Commanders[templateId].Base;
		if (commanderBaseStats.MaxHealth != health || commanderBaseStats.RegenRate != regen || commanderBaseStats.BuildRate != buildRate || commanderBaseStats.EnergyProduction != energy || commanderBaseStats.MassProduction != mass || commanderBaseStats.VisionRadius != vision || commanderBaseStats.OmniRadius != omni || commanderBaseStats.SonarRadius != sonar || commanderBaseStats.BuildCostMass != 18000.0 || commanderBaseStats.BuildCostEnergy != 5000000.0 || commanderBaseStats.BuildTime != 60000.0 || commanderBaseStats.SizeX != sizeX || commanderBaseStats.SizeY != sizeY || commanderBaseStats.SizeZ != sizeZ)
		{
			throw new InvalidOperationException("Commander '" + templateId + "' base stats drifted from stock FA.");
		}
	}

	private static void ValidatePositiveCost(string id, EnhancementCost cost)
	{
		if (cost.Mass <= 0.0 || cost.Energy <= 0.0 || cost.BuildTime <= 0.0 || double.IsNaN(cost.Mass) || double.IsNaN(cost.Energy) || double.IsNaN(cost.BuildTime))
		{
			throw new InvalidOperationException("Contract '" + id + "' has a non-positive or invalid cost/time.");
		}
	}

	private static void ValidateCapabilities(string id, CapabilityRule capabilities)
	{
		IReadOnlyList<string>[] array = new IReadOnlyList<string>[3] { capabilities.Add, capabilities.Remove, capabilities.Toggles };
		foreach (IReadOnlyList<string> readOnlyList in array)
		{
			if (readOnlyList.Any(string.IsNullOrWhiteSpace) || readOnlyList.Distinct(StringComparer.Ordinal).Count() != readOnlyList.Count)
			{
				throw new InvalidOperationException("Contract '" + id + "' has an empty or duplicate capability.");
			}
		}
	}

	private static void ValidatePrerequisiteCycles(CommanderRule commander)
	{
		foreach (EnhancementRule value in commander.Enhancements.Values)
		{
			HashSet<string> hashSet = new HashSet<string>(StringComparer.Ordinal);
			EnhancementRule enhancementRule = value;
			while (enhancementRule != null && enhancementRule.Prerequisite != null)
			{
				if (!hashSet.Add(enhancementRule.Id))
				{
					throw new InvalidOperationException("Commander '" + commander.TemplateId + "' has an enhancement prerequisite cycle at '" + enhancementRule.Id + "'.");
				}
				enhancementRule = commander.Enhancements[enhancementRule.Prerequisite];
			}
		}
	}

	private static void ValidateExactCosts(HashSet<string> allRuleKeys)
	{
		CostPin[] array = new CostPin[44]
		{
			P("uel0000", "AdvancedEngineering", 720.0, 18000.0, 900.0, 0.1),
			P("uel0000", "T3Engineering", 2400.0, 50000.0, 6000.0, 0.1),
			P("uel0000", "DamageStablization", 3000.0, 225000.0, 2000.0, 0.1),
			P("uel0000", "HeavyAntiMatterCannon", 800.0, 24000.0, 800.0, 0.1),
			P("uel0000", "ResourceAllocation", 5000.0, 150000.0, 1000.0, 0.1),
			P("uel0000", "LeftPod", 120.0, 2400.0, 400.0, 0.1),
			P("uel0000", "RightPod", 120.0, 2400.0, 400.0, 0.1),
			P("uel0000", "Shield", 1500.0, 112500.0, 1500.0, 0.1),
			P("uel0000", "ShieldGeneratorField", 3000.0, 450000.0, 2000.0, 0.1),
			P("uel0000", "TacticalMissile", 1000.0, 50000.0, 1000.0, 0.1),
			P("uel0000", "TacticalNukeMissile", 10800.0, 630000.0, 3600.0, 0.1),
			P("uel0000", "Teleporter", 15000.0, 1500000.0, 3000.0, 0.1),
			P("ucl0000", "AdvancedEngineering", 720.0, 18000.0, 900.0, 0.1),
			P("ucl0000", "T3Engineering", 2400.0, 50000.0, 6000.0, 0.1),
			P("ucl0000", "CrysalisBeam", 500.0, 15000.0, 500.0, 0.1),
			P("ucl0000", "EnhancedSensors", 750.0, 12500.0, 625.0, 0.1),
			P("ucl0000", "HeatSink", 500.0, 15000.0, 500.0, 0.1),
			P("ucl0000", "ChronoDampener", 2500.0, 125000.0, 1250.0, 0.1),
			P("ucl0000", "ResourceAllocation", 5000.0, 150000.0, 1000.0, 0.1),
			P("ucl0000", "ResourceAllocationAdvanced", 5000.0, 150000.0, 1000.0, 0.1),
			P("ucl0000", "Shield", 1500.0, 93750.0, 1250.0, 0.1),
			P("ucl0000", "ShieldHeavy", 4500.0, 1000000.0, 2500.0, 0.1),
			P("ucl0000", "Teleporter", 15000.0, 1500000.0, 3000.0, 0.1),
			P("ugl0000", "AdvancedEngineering", 720.0, 18000.0, 900.0, 0.1),
			P("ugl0000", "T3Engineering", 2400.0, 50000.0, 6000.0, 0.1),
			P("ugl0000", "CoolingUpgrade", 800.0, 24000.0, 800.0, 0.1),
			P("ugl0000", "MicrowaveLaserGenerator", 4000.0, 500000.0, 2000.0, 10.0),
			P("ugl0000", "NaniteTorpedoTube", 1500.0, 37500.0, 1500.0, 10.0),
			P("ugl0000", "StealthGenerator", 350.0, 5250.0, 350.0, 10.0),
			P("ugl0000", "CloakingGenerator", 6000.0, 750000.0, 3000.0, 1.0),
			P("ugl0000", "ResourceAllocation", 5000.0, 150000.0, 1000.0, 0.1),
			P("ugl0000", "Teleporter", 15000.0, 1500000.0, 3000.0, 0.1),
			P("usl0000", "AdvancedEngineering", 720.0, 18000.0, 900.0, 0.1),
			P("usl0000", "T3Engineering", 2400.0, 50000.0, 6000.0, 0.1),
			P("usl0000", "BlastAttack", 4500.0, 300000.0, 3000.0, 0.1),
			P("usl0000", "RegenAura", 600.0, 4500.0, 600.0, 0.1),
			P("usl0000", "AdvancedRegenAura", 1500.0, 31250.0, 1250.0, 0.1),
			P("usl0000", "RateOfFire", 800.0, 24000.0, 800.0, 0.1),
			P("usl0000", "DamageStabilization", 2000.0, 90000.0, 2000.0, 0.1),
			P("usl0000", "DamageStabilizationAdvanced", 4500.0, 450000.0, 3000.0, 0.1),
			P("usl0000", "Missile", 1000.0, 50000.0, 1000.0, 0.1),
			P("usl0000", "ResourceAllocation", 5000.0, 150000.0, 1000.0, 0.1),
			P("usl0000", "ResourceAllocationAdvanced", 5000.0, 150000.0, 1000.0, 0.1),
			P("usl0000", "Teleporter", 15000.0, 1500000.0, 3000.0, 0.1)
		};
		if (array.Length != allRuleKeys.Count || array.Select((CostPin pin) => pin.TemplateId + "/" + pin.Id).Distinct(StringComparer.Ordinal).Count() != array.Length)
		{
			throw new InvalidOperationException("Exact cost pins do not cover the 44 unique enhancement contracts.");
		}
		CostPin[] array2 = array;
		foreach (CostPin costPin in array2)
		{
			EnhancementRule enhancementRule = Commanders[costPin.TemplateId].Enhancements[costPin.Id];
			if (enhancementRule.Cost.Mass != costPin.Mass || enhancementRule.Cost.Energy != costPin.Energy || enhancementRule.Cost.BuildTime != costPin.BuildTime || enhancementRule.Removal.Cost.Mass != 1.0 || enhancementRule.Removal.Cost.Energy != 1.0 || enhancementRule.Removal.Cost.BuildTime != costPin.RemovalBuildTime)
			{
				throw new InvalidOperationException("Enhancement '" + costPin.TemplateId + "/" + costPin.Id + "' cost or removal time drifted from stock FA.");
			}
		}
	}

	private static CostPin P(string templateId, string id, double mass, double energy, double buildTime, double removalBuildTime)
	{
		return new CostPin(templateId, id, mass, energy, buildTime, removalBuildTime);
	}

	private static void ValidateHighRiskEffects()
	{
		if (Commanders["uel0000"].Enhancements.ContainsKey("DamageStabilization") || !Commanders["uel0000"].Enhancements.ContainsKey("DamageStablization"))
		{
			throw new InvalidOperationException("The stock UEF DamageStablization identifier spelling must remain exact.");
		}
		PinEffect("uel0000", "Shield", "shield", "maxHealth=24000", "regenRate=35", "rechargeTime=140", "maintenanceEnergy=250", "sourceShieldSize=3", "sanctuaryRadius=1.5");
		PinEffect("uel0000", "ShieldGeneratorField", "shield", "maxHealth=36000", "regenRate=42", "rechargeTime=175", "maintenanceEnergy=500", "sourceShieldSize=16", "sanctuaryRadius=8");
		PinEffect("uel0000", "LeftPod", "visual", "show=Back_Upgrade_B01");
		PinEffect("uel0000", "LeftPod", "spawn", "spawnBone=AttachSpecial02", "spawnOrigin=left shoulder", "dockRotationDegrees=0,180,0", "docksWhenIdle=true", "freeFlyingWhenWorking=true", "autoAssistsCreator=true");
		PinEffect("uel0000", "RightPod", "spawn", "spawnBone=AttachSpecial01", "spawnOrigin=right shoulder", "dockRotationDegrees=0,180,0", "docksWhenIdle=true", "freeFlyingWhenWorking=true", "autoAssistsCreator=true");
		PinEffect("ucl0000", "Shield", "shield", "maxHealth=29000", "regenRate=37", "rechargeTime=160", "sourceShieldSize=absent", "sanctuaryRadius=1.5");
		PinEffect("ucl0000", "ShieldHeavy", "shield", "maxHealth=44000", "regenRate=44", "rechargeTime=200", "maintenanceEnergy=500", "sanctuaryRadius=1.5");
		PinEffect("uel0000", "TacticalNukeMissile", "weapon", "innerDamage=12000", "innerRadius=15", "innerTicks=24", "outerDamage=250", "outerRadius=25", "outerTicks=20");
		PinEffect("ucl0000", "ChronoDampener", "weapon", "energyRequired=200", "stunDuration=3.5", "stunRadius=22", "stunTargetDisallow=EXPERIMENTAL,COMMAND");
		PinEffect("ugl0000", "MicrowaveLaserGenerator", "weapon", "sourceDamage=800", "sourceBeamLifetime=0", "sourceBeamCollisionDelay=0.1", "effectiveCollisionInterval=0.2", "damage=800", "collisionTicks=2", "damagePerSecond=4000", "beamLifetime=-1", "damageRadius=0.5", "maxRadius=22", "rateOfFire=3");
		PinEffect("ugl0000", "NaniteTorpedoTube", "weapon", "damage=250", "maxRadius=60", "muzzleVelocity=5", "muzzleSalvoSize=4", "muzzleSalvoDelay=0.8", "projectileLifetime=7");
		PinEffect("ugl0000", "CloakingGenerator", "intel", "cloak=true", "maintenanceEnergy=3000");
		PinEffect("usl0000", "BlastAttack", "weapon", "damageAdd=300", "damageRadiusAdd=2");
		PinEffect("usl0000", "AdvancedRegenAura", "aura", "radius=25", "regenPerSecond=0.01111111111", "regenCeiling=200", "actualMaxHealthIncrease=0");
		PinEffect("usl0000", "DamageStabilizationAdvanced", "engineering", "maxHealthAdd=20000", "regenRateAdd=150", "finalMaxHealth=37500", "finalRegenRate=235");
		PinEffect("usl0000", "Missile", "weapon", "damage=6000", "damageRadius=3", "maxRadius=256", "rateOfFire=1");
		foreach (string key in Commanders.Keys)
		{
			PinEffect(key, "AdvancedEngineering", "engineering", "buildRateSet=30", "sanctuaryBuildTag=BUILDABLE_BY_T2_ENGINEER");
			PinEffect(key, "T3Engineering", "engineering", "buildRateSet=90", "sanctuaryBuildTag=BUILDABLE_BY_T3_ENGINEER");
			PinEffect(key, "Teleporter", "teleport", "activationEnergy=150000", "activationTime=15", "activationEnergyPerSecond=10000");
		}
		if (Commanders["usl0000"].Enhancements["BlastAttack"].Removal.Runtime.IndexOf("accumulated damageRadiusAdd=7", StringComparison.Ordinal) < 0 || Commanders["usl0000"].Enhancements["AdvancedRegenAura"].Removal.Runtime.IndexOf("does not restart", StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("Stock Seraphim removal quirks must remain explicit.");
		}
	}

	private static void PinEffect(string templateId, string id, string domain, params string[] requiredTokens)
	{
		if (!Commanders[templateId].Enhancements[id].Effects.TryGetValue(domain, out string contract) || requiredTokens.Any((string token) => contract.IndexOf(token, StringComparison.Ordinal) < 0))
		{
			throw new InvalidOperationException("High-risk effect '" + templateId + "/" + id + "/" + domain + "' drifted from stock FA.");
		}
	}
}
