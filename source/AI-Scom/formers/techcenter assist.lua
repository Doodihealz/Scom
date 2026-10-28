
AIFormers = {

    {
        FormerName = "T1 TechCenter Build Assist",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Tech Center Assist"] = true,
        },
        Priority = 3710,
        FormNumInstances = 0,
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
            { "MoreThanEcoStorageLevel", { 050, 100 } },
        },
        AssistBuildUnits = {
            Tags.STRUCTURE * Tags.TECH_CENTRE,
        },
        AllowEcoStorageDrain = false,
    },

    {
        FormerName = "T1 TechCenter Land Upgrade Assist",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Tech Center Assist"] = true,
        },
        Priority = 3710,
        FormNumInstances = 0,
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
            { "MoreThanEcoStorageLevel", { 040, 100 } },
        },
        AssistUpgradeUnits = {
            Tags.STRUCTURE * Tags.TECH_CENTRE,
        },
        AllowEcoStorageDrain = false,
    },

}
