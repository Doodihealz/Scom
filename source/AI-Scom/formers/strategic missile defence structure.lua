
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T3 Strategic Missile Defence emergency",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Strategic Missile Defence Structures"] = true,
        },
        Priority = 4630,
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
            { "IsStrategyActive", { "EnemyHasNuke" } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_PROJECTILE * Tags.TECH3, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_PROJECTILE * Tags.TECH3,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.SHIELD,
        },
        AllowEcoStorageDrain = false,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T3 Strategic Missile Defence",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Strategic Missile Defence Structures"] = true,
        },
        Priority = 4630,
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
            { "MoreThanEcoStorageLevel", { 080, 100 } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_PROJECTILE * Tags.TECH3, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_PROJECTILE * Tags.TECH3,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.SHIELD,
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = false,
    },

}
