
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Transmitter",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Transmitter Structures"] = true,
        },
        Priority = 1400,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "CanBuildTag", { Tags.STRUCTURE * Tags.TRANSMITTER * Tags.TECH1 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 060, 0 } },
            { "LessThanUnitsInArmyAtBase", { 4, Tags.STRUCTURE * Tags.TRANSMITTER, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.TRANSMITTER * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.TRANSMITTER, 15},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = false,
    },

}
