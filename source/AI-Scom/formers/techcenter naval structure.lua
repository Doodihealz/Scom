
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 TechCenter Naval",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Tech Center Naval"] = true,
        },
        Priority = 3710,
        FormNumInstances = 0, --ToDo: set to 1 when unit is finished
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
            { "CanBuildTag", { Tags.NAVAL_TECH_CENTRE * Tags.TECH1 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 050, 100 } },
            { "LessThanUnitsInArmy", { 1, Tags.NAVAL_TECH_CENTRE, false} },
            { "MoreThanUnitsInArmy", { 0, Tags.NAVAL_FACTORY * Tags.TECH2, false} },
        },
        WantStructures = {
            Tags.NAVAL_TECH_CENTRE * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AllowEcoStorageDrain = false,
    },

}
