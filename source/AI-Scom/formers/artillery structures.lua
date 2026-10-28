
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Artillery",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Artillery Structures Tech2"] = true,
        },
        Priority = 520,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 60, 100 } },
            { "LessThanUnitsInArmyAtBase", { 2, Tags.STRUCTURE * Tags.ARTILLERY * Tags.TECH2, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ARTILLERY * Tags.TECH2,
        },
        WantStructuresSpacing = 2,
        AllowEcoStorageDrain = false,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T3 Artillery",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Artillery Structures Tech3"] = true,
        },
        Priority = 520,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 80, 100 } },
            { "LessThanUnitsInArmyAtBase", { 3, Tags.STRUCTURE * Tags.ARTILLERY * Tags.TECH3, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ARTILLERY * Tags.TECH3,
        },
        WantStructuresSpacing = 4,
        AllowEcoStorageDrain = false,
    },

}
