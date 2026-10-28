
AIFormers = {
    -- ============= --
    --    Recover    --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Recover",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
        },
        Priority = 8020,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmyAtBase", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    TECH 1     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer emergency minimum 3",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8140,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1 , 1, 2, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 3, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        AllowEcoStorageDrain = false,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer minimum 12",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7110,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 10, 10 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 12, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Rich Map Alloy Capture",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8139,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        FormerConditions = {
            -- Keep an additional Tech 1 engineer available for Alloy capture while the rich-map share is incomplete.
            { "MoreThanAlloyExtractorFairShareCount", { 40 } },
            { "LessThanAlloyExtractorFairSharePercent", { 75 } },
            { "CanBuildOnAlloyFieldInRange", { 30 , 1500 } },
            { "LessThanUnitsInArmy", { 14, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer pool <3",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7123,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- When do we want to build this ?
            { "LessThanIdleUnitsAssignedToBase", { 3, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmy", { 50, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer pool <2",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7122,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- When do we want to build this ?
            { "LessThanIdleUnitsAssignedToBase", { 2, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "MoreThanUnitsInArmy", { 4, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmy", { 50, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer pool <1",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7121,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- When do we want to build this ?
            { "LessThanIdleUnitsAssignedToBase", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "MoreThanUnitsInArmy", { 8, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmy", { 50, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer ArmyRatio 1:10",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7130,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- When do we want to build this ?
            { "UnitRatio", { 0.1, Tags.MOBILE * Tags.ENGINEER, "<=", Tags.MOBILE * Tags.LAND - Tags.ENGINEER } },
            { "LessThanUnitsInArmy", { 20, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "LessThanUnitsBeingBuiltAtBase", { 2, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Alloy Overflow pool <10",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7141,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 40, 0 } },
            -- When do we want to build this ?
            { "LessThanIdleUnitsAssignedToBase", { 10, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "LessThanUnitsInArmy", { 30, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    TECH 2     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Engineer minimum 1",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8110,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2 } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Engineer noPool <3",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7120,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH3 , 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.LAND_FACTORY * Tags.TECH2 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- When do we want to build this ?
            { "MoreThanUnitsAssignedToBase", { 1, Tags.LAND_FACTORY * Tags.TECH2 } },
            { "MoreThanUnitsAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "LessThanIdleUnitsAssignedToBase", { 3, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2 } },
            { "LessThanUnitsInArmy", { 20, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2 } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Engineer Alloy Overflow pool <10",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7142,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH3 , 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.LAND_FACTORY * Tags.TECH2 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 40, 0 } },
            -- When do we want to build this ?
            { "MoreThanUnitsAssignedToBase", { 1, Tags.LAND_FACTORY * Tags.TECH2 } },
            { "MoreThanUnitsAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "LessThanIdleUnitsAssignedToBase", { 10, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2 } },
            { "LessThanUnitsInArmy", { 30, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2 } },
        },
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    TECH 3     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Engineer minimum",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8150,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH3 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3,
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Engineer Transition Second",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8445,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH3 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3,
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanUnitsAssignedToMainBase", { 1, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "MoreThanUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3, false } },
            { "MoreThanUnitsInArmy", { 0, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3, false } },
            { "LessThanUnitsInArmy", { 2, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3, true } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Engineer noPool",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7130,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH3 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
           -- When do we want to build this ?
            { "MoreThanUnitsAssignedToMainBase", { 1, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "LessThanIdleUnitsAssignedToBase", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
            { "LessThanUnitsInArmy", { 20, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Engineer Alloy Overflow pool <10",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7143,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH3 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 60, 0 } },
            -- When do we want to build this ?
            { "MoreThanUnitsAssignedToMainBase", { 1, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "LessThanIdleUnitsAssignedToBase", { 10, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
            { "LessThanUnitsInArmy", { 30, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
        },
        AllowEcoStorageDrain = true,
    },

    -- ============================ --
    --    TECH 3 COMBAT ENGINEER    --
    -- ============================ --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Combat Engineer noPool",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Combat Engi"] = true,
        },
        Priority = 7130,
        FormNumInstances = 0, --ToDo: set to 1 when we know how to use this unit
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH3 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.COMBAT_ENGINEER * Tags.TECH3,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 10, 10 } },
            -- When do we want to build this ?
            { "CanBuildTag", { Tags.MOBILE * Tags.LAND * Tags.COMBAT_ENGINEER * Tags.TECH3 } },
            { "LessThanIdleUnitsAssignedToBase", { 3, Tags.MOBILE * Tags.LAND * Tags.COMBAT_ENGINEER * Tags.TECH3 * ( Tags.GUARD ), } },
        },
        AllowEcoStorageDrain = true,
    },

}
