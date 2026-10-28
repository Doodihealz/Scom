local ProfileAI = Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")

AIFormers = {
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T4 Mobile Naval First Buildable",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Tech4 Mobile Naval"] = true,
        },
        Priority = 8480,
        FormNumInstances = 1,
        InvestmentType = "ExperimentalDevelopment",
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = true,
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 2, 0 },
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 30, 65 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.TECH4 } },
            { ProfileAI.CanStartLoadedTech4Build, { "NAVAL", 0, 1 } },
        },
        WantStructuresSpacing = 3,
        LoadedTech4Domain = "NAVAL",
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T4 Mobile Naval Sustained Buildable",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Tech4 Mobile Naval"] = true,
        },
        Priority = 5080,
        FormNumInstances = 2,
        InvestmentType = "ExperimentalDevelopment",
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = true,
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 2, 0 },
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 45, 80 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.TECH4 } },
            { ProfileAI.CanStartLoadedTech4Build, { "NAVAL", 1, 4 } },
        },
        WantStructuresSpacing = 3,
        LoadedTech4Domain = "NAVAL",
    },
}
