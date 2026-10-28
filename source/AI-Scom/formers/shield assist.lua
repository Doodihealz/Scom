
AIFormers = {

    {
        FormerName = "T1 Shield Build Assist",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
             ["Shield Assist"] = true,
        },
        Priority = 3600,
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
            Tags.STRUCTURE * Tags.SHIELD,
        },
        AllowEcoStorageDrain = false,
    },

    {
        FormerName = "T1 Shield Upgrade Assist",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
             ["Shield Assist"] = true,
        },
        Priority = 3600,
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
            { "MoreThanEcoStorageLevel", { 040,100 } },
        },
        AssistUpgradeUnits = {
            Tags.STRUCTURE * Tags.SHIELD,
        },
        AllowEcoStorageDrain = false,
    },

}
