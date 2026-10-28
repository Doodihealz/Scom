local ProfileAI = Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")

AIFormers = {
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T4 Mobile Air First Buildable",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Tech4 Mobile Air"] = true,
        },
        Priority = 8490,
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
            { ProfileAI.CanStartLoadedTech4Build, { "AIR", 0, 1 } },
        },
        WantStructuresSpacing = 3,
        BuildBehindBase = 25,
        LoadedTech4Domain = "AIR",
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T4 Mobile Air Sustained Buildable",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Tech4 Mobile Air"] = true,
        },
        Priority = 5090,
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
            { ProfileAI.CanStartLoadedTech4Build, { "AIR", 1, 4 } },
        },
        WantStructuresSpacing = 3,
        BuildBehindBase = 25,
        LoadedTech4Domain = "AIR",
    },
}
