
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "Defence build assist",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Structure Defence Assist"] = true,
        },
        Priority = 4100,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 10, 1 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.COMMAND, 1, 1, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoStorageLevel", { 030, 100 } },
        },
        AssistBuildUnits = {
            Tags.STRUCTURE * Tags.DEFENCE * ( Tags.DIRECT_FIRE + Tags.ANTI_AIR ),
        },
        AllowEcoStorageDrain = false,
    },

}
