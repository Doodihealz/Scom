
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Engineering-Station Upgrade",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Engineering-Station Upgrade"] = true,
        },
        Priority = 3010,
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
            { Tags.STRUCTURE * Tags.ENGINEERING_STATION * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 050,100 } },
            { "MoreThanUnitsInArmyAtBase", { 0, Tags.LAND_FACTORY - Tags.TECH1, false} },
        },
        AllowEcoStorageDrain = false,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Engineering-Station Upgrade",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Engineering-Station Upgrade"] = true,
        },
        Priority = 3010,
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
            { Tags.STRUCTURE * Tags.ENGINEERING_STATION * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 040, 100 } },
            { "MoreThanUnitsInArmyAtBase", { 0, Tags.LAND_FACTORY * Tags.TECH3, false} },
        },
        AllowEcoStorageDrain = false,
    },

}
