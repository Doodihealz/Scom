
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Alloy Furnace",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Alloy-Furnace Structures"] = true,
        },
        Priority = 1400,
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
            { "CanBuildTag", { Tags.STRUCTURE * Tags.ALLOYS_PRODUCTION * Tags.TECH3 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 060, 100 } },
            { "LessThanUnitsInArmyAtBase", { 4, Tags.STRUCTURE * Tags.ALLOYS_PRODUCTION * Tags.TECH3, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ALLOYS_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ALLOYS_PRODUCTION, 15},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = false,
    },

}
