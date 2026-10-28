
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Engineering-Station MAIN",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Engineering-Station Structures"] = true,
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
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.COMMAND, 1, 1, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 070, 100 } },
            { "LessThanUnitsInArmyAtBase", { 4, Tags.STRUCTURE * Tags.ENGINEERING_STATION, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENGINEERING_STATION * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * (Tags.SHIELD + Tags.ENGINEERING_STATION), 24},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = false,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Engineering-Station Expansion",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Engineering-Station Structures"] = true,
        },
        Priority = 1400,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 080, 100 } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.ENGINEERING_STATION, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENGINEERING_STATION * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.SHIELD, 24},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = false,
    },

}
