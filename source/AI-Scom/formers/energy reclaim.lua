
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "K1 Energy Reclaim",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy reclaim"] = true,
        },
        Priority = 6050,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planReclaimBuilding",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 1 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoTrend", { 0, 20 } },
            { "MoreThanUnitsInArmyAtBase", { 3, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), false} },
        },
        ReclaimUnits = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "K2 Energy Reclaim",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy reclaim"] = true,
        },
        Priority = 6060,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planReclaimBuilding",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 1 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoTrend", { 0, 300 } },
            { "MoreThanUnitsInArmyAtBase", { 3, Tags.ENERGY_PRODUCTION * Tags.TECH3, false} },
        },
        ReclaimUnits = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        AllowEcoStorageDrain = true,
    },

}
