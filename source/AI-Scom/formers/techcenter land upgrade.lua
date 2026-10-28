
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 TechCenter Land Upgrade",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
             ["Tech Center Upgrade"] = true,
        },
        Priority = 3610,
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
            { Tags.LAND_TECH_CENTRE * Tags.TECH1, 1, 1, 0 },
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
