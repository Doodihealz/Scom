
AIFormers = {

    {
        FormerName = "T1 Artillery Build Assist",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
             ["Artillery Assist"] = true,
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
            { "MoreThanEcoStorageLevel", { 060, 100 } },
        },
        AssistBuildUnits = {
            Tags.STRUCTURE * Tags.ARTILLERY,
        },
        AllowEcoStorageDrain = false,
    },

}
