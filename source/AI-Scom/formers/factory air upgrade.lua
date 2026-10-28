
local ANTI_NAVAL_AIR = Tags.TORPEDO_BOMBER + Tags.ANTI_NAVAL + Tags.ANTI_NAVY + Tags.SCFA_ANTINAVY
local LAND_BOMBERS = Tags.BOMBER - ANTI_NAVAL_AIR

AIFormers = {

    -- ============= --
    --    TECH 1     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Factory Air Upgrade 1->2 1st Enemy",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Upgrade"] = true,
        },
        Priority = 9950,
        FormNumInstances = 1,
        InvestmentType = "EnemyAirFactoryUpgrade",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- Matching enemy technology takes precedence over economy and other construction.
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.AIR_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.AIR_FACTORY } },
            { "MoreThanEnemyUnits", { 0 , Tags.AIR_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Factory Air Upgrade 1->2 Transition Start",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Upgrade"] = true,
        },
        Priority = 8490,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2, false } },
            { "ThreatRatioVersusEnemy", { 1, Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, ">=", Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, "Land" } },
            { "LessThanUnitsInArmy", { 1, Tags.AIR_FACTORY * (Tags.TECH2 + Tags.TECH3), false } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.AIR_FACTORY } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.AIR_FACTORY } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Factory Air Upgrade 1->2 Naval Response",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Upgrade"] = true,
        },
        Priority = 8500,
        FormNumInstances = 1,
        InvestmentType = "EnemyNavalAirFactoryUpgrade",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            { "IsStrategyActive", { "EnemyHasNavalAttackUnits" } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "LessThanUnitsInArmy", { 1, Tags.AIR_FACTORY * (Tags.TECH2 + Tags.TECH3), false } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.AIR_FACTORY } },
        },
        AllowEcoStorageDrain = false,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Factory Air Upgrade 1->2 Bomber 4+",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Upgrade"] = true,
        },
        Priority = 8490,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 3, Tags.MOBILE * Tags.AIR * Tags.TECH1 * LAND_BOMBERS, false} },
            { "MoreThanUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2, false} },
            { "MoreThanUnitsInArmy", { 0, Tags.AIR_FACTORY * Tags.TECH1, false} },
            { "LessThanUnitsInArmy", { 1, Tags.AIR_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.AIR_FACTORY } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.AIR_FACTORY } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Factory Air Upgrade 1->2 E > 1200",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Upgrade"] = true,
        },
        Priority = 3310,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            { "MoreThanEcoIncome", { 001, 1200 } },
            -- When do we want to build this ?
            { "LessThanUnitsBeingBuilt", { 1, Tags.AIR_FACTORY } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.AIR_FACTORY } },
            { "MoreThanUnitsInArmy", { 3, Tags.AIR_FACTORY, false} },
        },
        AllowEcoStorageDrain = false,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Factory Air Upgrade 1->2 M2 > 1",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Upgrade"] = true,
        },
        Priority = 3310,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION * Tags.TECH2, false} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.AIR_FACTORY } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.AIR_FACTORY } },
            { "MoreThanUnitsInArmy", { 3, Tags.AIR_FACTORY, false} },
        },
        AllowEcoStorageDrain = false,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Factory Air Upgrade 1->2 Always",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Upgrade"] = true,
        },
        Priority = 8490,
        FormNumInstances = 3,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            -- When do we want to build this ?
            { "IsStrategyActive", { "BaseInvestmentOpportunity" } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.AIR_FACTORY } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.AIR_FACTORY } },
            { "MoreThanUnitsInArmy", { 5, Tags.STRUCTURE * Tags.FACTORY, false} },
            { "LessThanUnitsInArmyAtBase", { 2, Tags.AIR_FACTORY * Tags.TECH2, false} },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Factory Air Upgrade ECO full",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Upgrade"] = true,
        },
        Priority = 3310,
        FormNumInstances = 3,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 100, 100 } },
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = false,
    },

    -- ============= --
    --    TECH 2     --
    -- ============= --
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Factory Air Upgrade 2->3 1st Enemy",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air Upgrade"] = true,
        },
        Priority = 3320,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.AIR_FACTORY * Tags.TECH3, false} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.AIR_FACTORY } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.AIR_FACTORY } },
            { "MoreThanEnemyUnits", { 0 , Tags.STRUCTURE * Tags.FACTORY * Tags.TECH3 } },
        },
        AllowEcoStorageDrain = false,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Factory Air Upgrade 2->3 M3 > 1",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air Upgrade"] = true,
        },
        Priority = 3220,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.AIR_FACTORY * Tags.TECH3, false} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.AIR_FACTORY } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.AIR_FACTORY } },
            { "MoreThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION * Tags.TECH3, false} },
        },
        AllowEcoStorageDrain = false,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Factory Air Upgrade 2->3 Always",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air Upgrade"] = true,
        },
        Priority = 3320,
        FormNumInstances = 3,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoIncome", { 35, 350 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            -- When do we want to build this ?
            { "IsStrategyActive", { "BaseInvestmentOpportunity" } },
            { "MoreThanUnitsInArmy", { 1, Tags.AIR_FACTORY * Tags.TECH2, false} },
            { "LessThanUnitsInArmy", { 1, Tags.AIR_FACTORY * Tags.TECH3, false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.STRUCTURE * Tags.FACTORY } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Factory Air Upgrade ECO full",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air Upgrade"] = true,
        },
        Priority = 3320,
        FormNumInstances = 3,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 100, 100 } },
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = false,
    },

}
