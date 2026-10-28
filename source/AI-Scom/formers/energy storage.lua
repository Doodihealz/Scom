
AIFormers = {

    {
        FormerName = "T1 Energy Storage Recover",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
             ["Base Recover"] = true,
        },
        Priority = 8110,
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
            { Tags.MOBILE * Tags.ENGINEER, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanEnergyStorageCapacity", { 100 } },
            { "LessThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ENERGY_STORAGE, false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_STORAGE * Tags.ECONOMIC * Tags.TECH1,
        },
        WantStructuresSpacing = 0,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION,
        },
        AllowEcoStorageDrain = false,
    },

    {
        FormerName = "T1 Energy Storage Generator Adjacency",
        RushAdjacencyStorage = "energy",
        RushDevelopment = true,
        AIdifficulty = { easy = true, medium = true, hard = true },
        RunWithStrategyName = {},
        Priority = 9500,
        FormNumInstances = 2,
        RunOnBaseType = { MAIN = true, EXPANSION = true, OUTPOST = true, NAVAL = false },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3) - Tags.COMMAND - Tags.TECH4, 1, 1, 0 },
        },
        FormerConditions = {
            { "CanBuildTag", { Tags.STRUCTURE * Tags.ENERGY_STORAGE * Tags.TECH1 } },
        },
        WantStructures = { Tags.STRUCTURE * Tags.ENERGY_STORAGE * Tags.TECH1 },
        WantStructuresSpacing = 0,
        AdjacentToStructure = { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3) },
        AllowEcoStorageDrain = true,
        DebugPlatoon = false,
    },
}
