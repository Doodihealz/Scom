
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "K1 Radar Reclaim",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Radar reclaim"] = true,
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
            { "MoreThanUnitsInArmyAtBase", { 0, Tags.Radar * (Tags.TECH2 + Tags.TECH3), false} },
        },
        ReclaimUnits = {
            Tags.STRUCTURE * Tags.Radar * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "K2 Radar Reclaim",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Radar reclaim"] = true,
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
            { "MoreThanUnitsInArmyAtBase", { 0, Tags.Radar * Tags.TECH3, false} },
        },
        ReclaimUnits = {
            Tags.STRUCTURE * Tags.Radar * Tags.TECH2,
        },
        AllowEcoStorageDrain = true,
    },

}
