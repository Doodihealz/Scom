
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T3 Strategic Missile Launcher",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Strategic Missile Launcher Structures"] = true,
        },
        Priority = 4530,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 080, 0 } },
            { "LessThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.STRATEGIC * Tags.TECH3, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.STRATEGIC * Tags.TECH3,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.SHIELD,
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = false,
    },

}
