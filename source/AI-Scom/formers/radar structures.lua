
AIFormers = {


    -- ============= --
    --    TECH 1     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Radar",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Radar Structures"] = true,
        },
        Priority = 1900,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.RADAR, false} },
            { "MoreThanUnitsInArmyAtBase", { 2, Tags.STRUCTURE * Tags.FACTORY, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.RADAR * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.SHIELD,
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    TECH 3     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B2 Radar",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Radar Structures"] = true,
        },
        Priority = 1900,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.RADAR * Tags.TECH2, false} },
            { "MoreThanUnitsInArmyAtBase", { 2, Tags.STRUCTURE * Tags.FACTORY * Tags.TECH2, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.RADAR * Tags.TECH2,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.SHIELD,
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = false,
    },

    -- ============= --
    --    TECH 3     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B3 Radar",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Radar Structures"] = true,
        },
        Priority = 1900,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.RADAR * Tags.TECH3, false} },
            { "MoreThanUnitsInArmyAtBase", { 2, Tags.STRUCTURE * Tags.FACTORY * Tags.TECH3, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.RADAR * Tags.TECH3,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.SHIELD,
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = false,
    },

}
