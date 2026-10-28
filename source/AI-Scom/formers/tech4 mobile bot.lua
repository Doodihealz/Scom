local ProfileAI = Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")

AIFormers = {
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T4 Mobile Land First Buildable",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Sanctuary Rush Tech4 Mobile Land"] = true,
        },
        Priority = 8500,
        FormNumInstances = 1,
        InvestmentType = "ExperimentalDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 2, 0 },
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 25, 60 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.TECH4 } },
            { ProfileAI.CanStartLoadedTech4Build, { "LAND", 0, 1 } },
        },
        WantStructuresSpacing = 3,
        BuildBehindBase = 25,
        LoadedTech4Domain = "LAND",
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T4 Mobile Land Sustained Buildable",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Sanctuary Rush Tech4 Mobile Land"] = true,
        },
        Priority = 5100,
        FormNumInstances = 2,
        InvestmentType = "ExperimentalDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 2, 0 },
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 40, 75 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.TECH4 } },
            { ProfileAI.CanStartLoadedTech4Build, { "LAND", 1, 4 } },
        },
        WantStructuresSpacing = 3,
        BuildBehindBase = 25,
        LoadedTech4Domain = "LAND",
    },
}
