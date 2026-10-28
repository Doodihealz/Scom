
AIFormers = {

    {
        FormerName = "T1 Factory Air Build Assist",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Assist"] = true,
        },
        Priority = 3210,
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
            { "MoreThanEcoStorageLevel", { 050,100 } },
        },
        AssistBuildUnits = {
            Tags.AIR_FACTORY,
        },
        AllowEcoStorageDrain = false,
    },
    {
        FormerName = "T1 Factory Air Upgrade Assist",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Assist"] = true,
        },
        Priority = 3210,
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
            { "MoreThanEcoStorageLevel", { 040, 100 } },
        },
        AssistUpgradeUnits = {
            Tags.AIR_FACTORY,
        },
        AllowEcoStorageDrain = false,
    },

}
