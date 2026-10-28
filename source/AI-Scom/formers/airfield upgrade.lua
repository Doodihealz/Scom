
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Air Field Upgrade",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Airfield Upgrade"] = true,
        },
        Priority = 3010,
        FormNumInstances = 0,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.STRUCTURE * Tags.AIRFIELD * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 050,050 } },
            { "MoreThanUnitsInArmyAtBase", { 0, Tags.AIR_FACTORY * Tags.TECH2, false} },
        },
        AllowEcoStorageDrain = false,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Air Field Upgrade",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Airfield Upgrade"] = true,
        },
        Priority = 3010,
        FormNumInstances = 0,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.STRUCTURE * Tags.AIRFIELD * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 040, 100 } },
            { "MoreThanUnitsInArmyAtBase", { 0, Tags.AIR_FACTORY * Tags.TECH3, false} },
        },
        AllowEcoStorageDrain = false,
    },

}
