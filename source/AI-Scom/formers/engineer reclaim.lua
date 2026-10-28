AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "K1 Reclaim Map Resources",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Reclaim Map Resources"] = true,
        },
        Priority = 6050,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planReclaimMap",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 2, 1 },
        },
        FormerConditions = {
            { "HasReclaimablePropsOnMap", {} },
        },
        AllowEcoStorageDrain = true,
    },

}
