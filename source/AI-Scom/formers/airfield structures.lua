
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Air Field",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Airfield Structures"] = true,
        },
        Priority = 1400,
        FormNumInstances = 0,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "CanBuildTag", { Tags.STRUCTURE * Tags.AIRFIELD * Tags.TECH1 } },
--            { "MoreThanUnitsInArmy", { 1, Tags.AIR_FACTORY, false} },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 060, 100 } },
            { "LessThanUnitsInArmyAtBase", { 4, Tags.STRUCTURE * Tags.AIRFIELD, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.AIRFIELD * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AllowEcoStorageDrain = false,
    },

}
