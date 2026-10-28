
AIFormers = {

    {
        FormerName = "T1 Alloy Furnace Build Assist",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Alloy-Furnace Assist"] = true,
        },
        Priority = 3000,
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
            { "MoreThanEcoStorageLevel", { 060, 100 } },
        },
        AssistBuildUnits = {
            Tags.STRUCTURE * Tags.ALLOYS_PRODUCTION,
        },
        AllowEcoStorageDrain = false,
    },

}
