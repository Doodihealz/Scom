
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Assist First T2 Energy Rich Map",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 8104,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planAssistBuilding",
        NeedMobileBuilder = {
            -- Up to double the first Tech 2 energy producer's build power while keeping two Tech 1 Engineers available.
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 2, 2 },
        },
        FormerConditions = {
            { "MoreThanAlloyExtractorFairShareCount", { 40 } },
            { "MoreThanUnitsBeingBuiltAtBase", { 0, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
            { "LessThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2, false} },
        },
        AssistBuildUnits = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "A123 Energy Build Assist",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy assist"] = true,
        },
        Priority = 6010,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 2, 2 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 1 },
        },
        FormerConditions = {
            { "MoreThanFactoryCombatAlloyUsage", { 70 } },
            -- When do we want to build this ?
        },
        AssistBuildUnits = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION - Tags.TECH1,
        },
        AllowEcoStorageDrain = false,
    },

}
