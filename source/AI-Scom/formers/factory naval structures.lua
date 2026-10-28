AIFormers = {
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Naval Area",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Naval Structures"] = true,
        },
        Priority = 6680,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3) - Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 10, 10 } },
            { "NavalAreaNeedsFactory", {} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.NAVAL_FACTORY } },
        },
        WantStructures = {
            Tags.NAVAL_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 0,
        BuildNavalFactory = true,
        AllowEcoStorageDrain = true,
    },
    {
        FormerName = "Factory Naval Production Capacity",
        DebugPlatoon = false,
        AIdifficulty = {easy = true, medium = true, hard = true},
        RunWithStrategyName = {},
        RushDevelopment = true,
        RushNavalCapacity = true,
        RushCapacityDomain = "naval",
        Priority = 7750,
        FormNumInstances = 3,
        RunOnBaseType = {MAIN = true, EXPANSION = true, OUTPOST = true, NAVAL = true},
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            {Tags.MOBILE * Tags.ENGINEER * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3) - Tags.COMMAND, 1, 1, 0},
        },
        FormerConditions = {
            {"MoreThanUnitsInArmy", {0, Tags.NAVAL_FACTORY, true}},
            {Import("AI/mods/AI-Scom/RushDevelopment.lua").Check, {"capacity", 1, "naval"}},
        },
        WantStructures = {Tags.NAVAL_FACTORY * Tags.TECH1},
        WantStructuresSpacing = 0,
        BuildNavalFactory = true,
        AllowEcoStorageDrain = true,
    },
}
