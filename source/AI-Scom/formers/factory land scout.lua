
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Scouts Land min",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Scouts"] = true,
        },
        Priority = 5910,
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
            -- alternative builder in case the upper one is not available
            { Tags.LAND_FACTORY * Tags.TECH2 , 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.LAND_FACTORY * Tags.TECH3 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.SCOUT * Tags.TECH1,
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.MOBILE * Tags.LAND * Tags.SCOUT } },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Scouts Land Factory > 4",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Scouts"] = true,
        },
        Priority = 5910,
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
            -- alternative builder in case the upper one is not available
            { Tags.LAND_FACTORY * Tags.TECH2 , 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.LAND_FACTORY * Tags.TECH3 , 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.SCOUT * Tags.TECH1,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 10, 10 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 2, Tags.LAND_FACTORY, false} },
            { "LessThanUnitsInArmy", { 3, Tags.MOBILE * Tags.LAND * Tags.SCOUT } },
        },
        AllowEcoStorageDrain = true,
    },

}
