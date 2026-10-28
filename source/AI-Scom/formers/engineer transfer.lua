
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Engi Trans to MainBase > 3",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Engineer Transfer MAIN"] = true,
       },
        Priority = 9010,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = true
        },
        AIPlan = "planEngineerTransfer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 3, 4 },
        },
        FormerConditions = {
            -- NeedMobileBuilder has the condition to get one engineer and left 3 at base
        },
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Engi Trans to MainBase > 3",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Engineer Transfer MAIN"] = true,
       },
        Priority = 9020,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = true
        },
        AIPlan = "planEngineerTransfer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 3, 4 },
        },
        FormerConditions = {
            -- NeedMobileBuilder has the condition to get one engineer and left 3 at base
        },
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T3 Engi Trans to MainBase > 3",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Engineer Transfer MAIN"] = true,
       },
        Priority = 9030,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = true
        },
        AIPlan = "planEngineerTransfer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 3, 4 },
        },
        FormerConditions = {
            -- NeedMobileBuilder has the condition to get one engineer and left 3 at base
        },
    },

}
