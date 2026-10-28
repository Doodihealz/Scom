
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Structure Anti Ground",
        RushGroundDefense = 1,
        RushDevelopment = true,
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Structure Defence Ground"] = true,
        },
        Priority = 9000,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3) - Tags.COMMAND - Tags.TECH4, 1, 1, 0 },
        },
        FormerConditions = {
            { "CanBuildTag", { Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE * Tags.TECH1 - Tags.ANTI_AIR - Tags.ARTILLERY - Tags.SCFA_ARTILLERY } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE * Tags.TECH1 - Tags.ANTI_AIR - Tags.ARTILLERY - Tags.SCFA_ARTILLERY,
        },
        WantStructuresSpacing = 1,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE, 10},
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Structure Anti Ground",
        RushGroundDefense = 2,
        RushDevelopment = true,
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Structure Defence Ground"] = true,
        },
        Priority = 9000,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH2 + Tags.TECH3) - Tags.COMMAND - Tags.TECH4, 1, 1, 0 },
        },
        FormerConditions = {
            { "CanBuildTag", { Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE * Tags.TECH2 - Tags.ANTI_AIR - Tags.ARTILLERY - Tags.SCFA_ARTILLERY } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE * Tags.TECH2 - Tags.ANTI_AIR - Tags.ARTILLERY - Tags.SCFA_ARTILLERY,
        },
        WantStructuresSpacing = 1,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T3 Structure Anti Ground",
        RushBaseDefense = "ground",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Structure Defence Ground"] = true,
        },
        Priority = 5230,
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
            -- When do we want to build this ?
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "CanBuildTag", { Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE * Tags.TECH3 } },
            { "MoreThanEcoStorageLevel", { 50, 50 } },
            { "UnitRatioAtBase", { 0.2, Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE * Tags.TECH3, "<=", Tags.STRUCTURE * (Tags.FACTORY + (Tags.ENERGY_PRODUCTION + Tags.ALLOYS_EXTRACTION) * (Tags.TECH2 + Tags.TECH3 + Tags.TECH4)) } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE * Tags.TECH3,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.DIRECT_FIRE, 10},
            {Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_AIR, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = false,
    },

}
