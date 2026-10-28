
AIFormers = {

    -- ============ --
    --    TECH 1    --
    -- ============ --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Scouts Air min",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Scouts"] = true,
        },
        Priority = 7070,
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
            { Tags.AIR_FACTORY * Tags.TECH1 , 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.AIR_FACTORY * Tags.TECH2 , 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.AIR_FACTORY * Tags.TECH3 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.SCOUT * Tags.TECH1,
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.MOBILE * Tags.AIR * Tags.SCOUT } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Scouts Air Factory > 1",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Scouts"] = true,
        },
        Priority = 5940,
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
            { Tags.AIR_FACTORY * Tags.TECH1 , 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.AIR_FACTORY * Tags.TECH2 , 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.AIR_FACTORY * Tags.TECH3 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.SCOUT * Tags.TECH1,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 10, 10 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 1, Tags.AIR_FACTORY, false} },
            { "LessThanUnitsInArmy", { 4, Tags.MOBILE * Tags.AIR * Tags.SCOUT } },
            { "LessThanUnitsInArmy", { 1, Tags.MOBILE * Tags.AIR * Tags.SCOUT - Tags.TECH1 } },
        },
        AllowEcoStorageDrain = true,
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Scouts Air",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Scouts"] = true,
        },
        Priority = 5950,
        FormNumInstances = 0,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH2 , 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.AIR_FACTORY * Tags.TECH3 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.SCOUT * Tags.TECH2,
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 4, Tags.MOBILE * Tags.AIR * Tags.SCOUT } },
            { "LessThanUnitsInArmy", { 1, Tags.MOBILE * Tags.AIR * Tags.SCOUT - ( Tags.TECH1 + Tags.TECH2 ) } },
        },
        AllowEcoStorageDrain = true,
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Scouts Air",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Scouts"] = true,
        },
        Priority = 5960,
        FormNumInstances = 0,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH3 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.SCOUT * Tags.TECH3,
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 6, Tags.MOBILE * Tags.AIR * Tags.SCOUT } },
        },
        AllowEcoStorageDrain = true,
    },


}
