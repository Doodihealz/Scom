
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Stealth Field",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Stealthfield Structures"] = true,
        },
        Priority = 1400,
        FormNumInstances = 0,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "CanBuildTag", { Tags.STRUCTURE * Tags.STEALTH_FIELD * Tags.TECH2 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 060, 0 } },
            { "LessThanUnitsInArmyAtBase", { 4, Tags.STRUCTURE * Tags.STEALTH_FIELD, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.STEALTH_FIELD * Tags.TECH2,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.STEALTH_FIELD, 20},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = false,
    },

}
