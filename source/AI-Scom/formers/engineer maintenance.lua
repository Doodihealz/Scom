AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "Z1 Engineer Maintenance Repair",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Engineer Maintenance"] = true,
        },
        Priority = 55,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = true,
        },
        AIPlan = "planRepairBuilding",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 2, 0 },
        },
        RepairStructures = {
            Tags.STRUCTURE,
        },
        ResumeConstructionWithoutEconomyCheck = true,
        AllowEcoStorageDrain = false,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "Z2 Engineer Maintenance Assist",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Engineer Maintenance"] = true,
        },
        Priority = 50,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = true,
        },
        AIPlan = "planAssistBuilding",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 2, 0 },
        },
        AssistBuildUnits = {
            Tags.STRUCTURE,
        },
        AllowEcoStorageDrain = false,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "Z3 Engineer Maintenance Map Reclaim",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Engineer Maintenance"] = true,
        },
        Priority = 40,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = true,
        },
        AIPlan = "planReclaimMap",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 2, 0 },
        },
        FormerConditions = {
            { "HasReclaimablePropsOnMap", {} },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "Z9 Engineer Maintenance Position",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Engineer Maintenance"] = true,
        },
        Priority = 10,
        FormNumInstances = 0,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = true,
        },
        AIPlan = "planEngineerMaintenance",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
    },

}
