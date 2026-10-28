
AIFormers = {

    -- ============= --
    --    TECH 1     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Structure Anti Air PANIC",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Structure Defence Air"] = true,
        },
        Priority = 9000,
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
            { "CanBuildTag", { Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR * Tags.TECH1 } },
            { "MoreThanEcoStorageLevel", { 50, 50 } },
            -- When do we want to build this ?
            { "MoreThanEnemyUnitsAtBase", { 0, Tags.MOBILE * Tags.AIR } },
            { "LessThanUnitsInArmyAtBase", { 2, Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR, true} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR, 10},
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = false,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Structure Anti Air",
        RushBaseDefense = "air",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Structure Defence Air"] = true,
        },
        Priority = 8440,
        FormNumInstances = 1,
        InvestmentType = "BaseDefence",
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
            { "CanBuildTag", { Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR * Tags.TECH1 } },
            -- When do we want to build this ?
            { "MoreThanEcoStorageLevel", { 50, 50 } },
            { "UnitRatioAtBase", { 0.2, Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR, "<=", Tags.STRUCTURE * (Tags.FACTORY + (Tags.ENERGY_PRODUCTION + Tags.ALLOYS_EXTRACTION) * (Tags.TECH2 + Tags.TECH3 + Tags.TECH4)) } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR, 10},
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = false,
    },

    -- ============= --
    --    TECH 2     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Structure Anti Air PANIC",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Structure Defence Air"] = true,
        },
        Priority = 9010,
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
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        FormerConditions = {
            { "CanBuildTag", { Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR * Tags.TECH2 } },
            { "MoreThanEcoStorageLevel", { 50, 50 } },
            -- When do we want to build this ?
            { "MoreThanEnemyUnitsAtBase", { 0, Tags.MOBILE * Tags.AIR } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR * (Tags.TECH2 + Tags.TECH3), true} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR * Tags.TECH2,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR, 10},
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = false,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Structure Anti Air",
        RushBaseDefense = "air",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Structure Defence Air"] = true,
        },
        Priority = 8430,
        FormNumInstances = 1,
        InvestmentType = "BaseDefence",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoStorageLevel", { 50, 50 } },
            { "UnitRatioAtBase", { 0.2, Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR * (Tags.TECH2 + Tags.TECH3), "<=", Tags.STRUCTURE * (Tags.FACTORY + (Tags.ENERGY_PRODUCTION + Tags.ALLOYS_EXTRACTION) * (Tags.TECH2 + Tags.TECH3 + Tags.TECH4)) } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR * Tags.TECH2,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR, 10},
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = false,
    },

    -- ============= --
    --    TECH 3     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T3 Structure Anti Air",
        RushBaseDefense = "air",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Structure Defence Air"] = true,
        },
        Priority = 5235,
        FormNumInstances = 1,
        InvestmentType = "BaseDefence",
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
            { "CanBuildTag", { Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR * Tags.TECH3 } },
            -- When do we want to build this ?
            { "MoreThanEcoStorageLevel", { 50, 50 } },
            { "UnitRatioAtBase", { 0.2, Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR * Tags.TECH3, "<=", Tags.STRUCTURE * (Tags.FACTORY + (Tags.ENERGY_PRODUCTION + Tags.ALLOYS_EXTRACTION) * (Tags.TECH2 + Tags.TECH3 + Tags.TECH4)) } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR * Tags.TECH3,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR, 10},
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = false,
    },

}
