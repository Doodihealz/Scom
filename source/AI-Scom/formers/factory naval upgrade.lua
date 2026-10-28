AIFormers = {
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Factory Naval Upgrade 1->2 Area",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Naval Upgrade"] = true,
        },
        Priority = 6720,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = true,
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            { Tags.NAVAL_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            { "MoreThanGameTimeSeconds", { 360 } },
            { "MoreThanEcoStorageLevel", { 20, 30 } },
            { "NavalAreaShouldUpgradeFactory", { 1 } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.NAVAL_FACTORY } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U2 Factory Naval Upgrade 2->3 Area",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Naval Upgrade"] = true,
        },
        Priority = 6710,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = true,
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            { Tags.NAVAL_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            { "MoreThanGameTimeSeconds", { 720 } },
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            { "NavalAreaShouldUpgradeFactory", { 2 } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.NAVAL_FACTORY } },
        },
        AllowEcoStorageDrain = true,
    },
}
