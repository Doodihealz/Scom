
AIFormers = {

    -- ============= --
    --    TECH 1     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Factory Land Upgrade 1->2 Transition Start",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 8500,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanUnitsAssignedToBase", { 2, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "ThreatRatioVersusEnemy", { 1, Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, ">=", Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, "Land" } },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "LessThanUnitsAssignedToBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Factory Land Upgrade 1->2 Economic Start",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 8499,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- Upgrade one idle factory without reducing the current production budget.
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            { "MoreThanUnitsAssignedToBase", { 2, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "LessThanUnitsAssignedToBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        -- Require uncommitted Alloy and Energy income to cover the actual upgrade cost.
        AllowEcoStorageDrain = false,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Factory Land Upgrade 1->2 Stored Start",
        AIdifficulty = { easy = false, medium = false, hard = true },
        RunWithStrategyName = { ["Factory Land Upgrade"] = true },
        Priority = 8498,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = { ["MAIN"] = true, ["EXPANSION"] = false, ["OUTPOST"] = false, ["NAVAL"] = false },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- Use one idle opening factory when the complete upgrade cost is already stored.
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            { "MoreThanUnitsAssignedToBase", { 2, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "LessThanUnitsAssignedToBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
            { "MoreThanEcoStorageAmount", { 500, 5000 } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Factory Land Upgrade 1->2 1st Enemy",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 9950,
        FormNumInstances = 1,
        InvestmentType = "EnemyLandFactoryUpgrade",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- Matching enemy technology takes precedence over economy and other construction.
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
            { "MoreThanEnemyUnits", { 0 , Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Factory Land Upgrade 1->2 Time",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 6335,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 20, 30 } },
            -- When do we want to build this ?
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "MoreThanGameTimeSeconds", { 360 } },
            { "MoreThanUnitsAssignedToBase", { 3, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "LessThanUnitsAssignedToBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Factory Land Upgrade 1->2 Forced Time",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 8500,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            -- When do we want to build this ?
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "MoreThanGameTimeSeconds", { 540 } },
            { "MoreThanUnitsAssignedToBase", { 3, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "LessThanUnitsAssignedToBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Factory Land Upgrade 1->2 M2 > 0",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 6330,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- When do we want to build this ?
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "MoreThanUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION * Tags.TECH2, false} },
            { "LessThanUnitsAssignedToBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Factory Land Upgrade 1->2 A > 20",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 6330,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoIncome", { 20, -1 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            -- When do we want to build this ?
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "LessThanUnitsAssignedToBase", { 1, Tags.STRUCTURE * Tags.FACTORY * Tags.TECH2 } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Factory Land Upgrade 1->2 E > 300",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 6330,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoIncome", { -1, 300 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            -- When do we want to build this ?
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "LessThanUnitsAssignedToBase", { 1, Tags.STRUCTURE * Tags.FACTORY * Tags.TECH2 } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Factory Land Upgrade 1->2 2nd",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
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
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LandFactoryTechnologyTwoTransitionAllowedAtBase", {} },
            { "MoreThanUnitsAssignedToBase", { 1, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "TechnologyOneLandFactoryReserveMaintainedOnRichMap", { 40, 3 } },
            { "TechnologyTwoEnergyEstablishedOnRichMap", { 40 } },
            { "MoreThanUnitsAssignedToBase", { 0, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
            { "LessThanUnitsAssignedToBase", { 2, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
            { "MoreThanUnitsBeingBuiltInFactoriesAtBase", { 0, Tags.MOBILE * Tags.LAND * Tags.TECH2 - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        AllowEcoStorageDrain = false,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Factory Land Upgrade 1->2 Transition",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 8480,
        FormNumInstances = 3,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "ThreatRatioVersusEnemyOnRichMap", { 40, 1, Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, ">=", Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, "Land" } },
            { "MoreThanUnitsAssignedToBase", { 1, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "TechnologyOneLandFactoryReserveMaintainedOnRichMap", { 40, 3 } },
            { "MoreThanUnitsAssignedToMainBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
            { "FactoryUpgradeConcurrencyAllowed", { 30, 50, Tags.STRUCTURE * Tags.FACTORY } },
        },
        AllowEcoStorageDrain = false,
    },

    -- ============= --
    --    TECH 2     --
    -- ============= --
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U2 Factory Land Upgrade 2->3 1st Enemy",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 6380,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            -- When do we want to build this ?
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * Tags.TECH3, true} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.LAND_FACTORY } },
            { "MoreThanEnemyUnits", { 0 , Tags.STRUCTURE * Tags.FACTORY * Tags.TECH3 } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U2 Factory Land Upgrade 2->3 Rich Map Transition Start",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 8486,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- One Tech 2 land factory is enough to begin the Tech 3 transition.
            { "MoreThanAlloyExtractorFairShareCount", { 40 } },
            { "MoreThanEcoIncome", { 30, -1 } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * Tags.TECH3, true} },
            { "MoreThanUnitsAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH2 } },
            { "ThreatRatioVersusEnemy", { 1, Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, ">=", Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, "Land" } },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH2 } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U2 Factory Land Upgrade 2->3 Transition Start",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 8485,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoIncome", { 30, -1 } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * Tags.TECH3, true} },
            { "MoreThanUnitsAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH2 } },
            { "ThreatRatioVersusEnemy", { 1, Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, ">=", Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, "Land" } },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH2 } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U2 Factory Land Upgrade 2->3 M3 > 1",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 6370,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            -- When do we want to build this ?
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * Tags.TECH3, true} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY * Tags.TECH2 } },
            { "MoreThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION * Tags.TECH3, false} },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U2 Factory Land Upgrade 2->3 2nd",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 8460,
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
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoIncome", { 30, -1 } },
            { "MoreThanUnitsAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "LessThanUnitsAssignedToBase", { 2, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "MoreThanUnitsBeingBuiltInFactoriesAtBase", { 0, Tags.MOBILE * Tags.LAND * Tags.TECH3 - Tags.ENGINEER } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U2 Factory Land Upgrade 2->3 Transition",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Upgrade"] = true,
        },
        Priority = 8450,
        FormNumInstances = 3,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoIncome", { 30, -1 } },
            { "MoreThanUnitsAssignedToMainBase", { 1, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "MoreThanUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3, false } },
            { "FactoryUpgradeConcurrencyAllowed", { 10, 30, Tags.STRUCTURE * Tags.FACTORY } },
        },
        AllowEcoStorageDrain = true,
    },

}
