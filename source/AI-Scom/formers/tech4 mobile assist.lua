
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Assist T4 mobile",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Tech4 Mobile Assist"] = true,
        },
        Priority = 1400,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planAssistBuilding",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 2 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoStorageLevel", { 060,100 } },
        },
        AssistBuildUnits = {
            Tags.MOBILE * Tags.TECH4,
        },
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T123 Assist T4 mobile Alloy Overflow",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Tech4 Mobile Assist"] = true,
        },
        Priority = 1400,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planAssistBuilding",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER, 1, 1000, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanGameTimeSeconds", { 1200 } },
            { "MoreThanEcoStorageLevel", { 30, 0 } },
        },
        AssistBuildUnits = {
            Tags.MOBILE * Tags.TECH4,
        },
        AllowEcoStorageDrain = true,
        MinimumAlloyStorageLevelForAssist = 20,
        MinimumAlloyTrendForAssist = 0,
    },

}
