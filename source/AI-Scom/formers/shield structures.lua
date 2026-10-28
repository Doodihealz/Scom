
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Shield Commander Retreat",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Commander Emergency Shield"] = true,
        },
        Priority = 9999,
        FormNumInstances = 1,
        InvestmentType = "ShieldConstruction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        FormerConditions = {
            { "MoreThanEcoStorageAmount", { 150,1500 } },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.STRUCTURE * Tags.SHIELD * (Tags.TECH2 + Tags.TECH3 + Tags.TECH4) } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.SHIELD * (Tags.TECH2 + Tags.TECH3 + Tags.TECH4), true } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.SHIELD * Tags.TECH2,
        },
        WantStructuresSpacing = 1,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.SHIELD, 24},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Shield First",
        RushBaseDefense = "shield",
        RushDevelopment = true,
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Shield Structures MEDIUM"] = true,
            ["Shield Structures HARD"] = true,
        },
        Priority = 8445,
        FormNumInstances = 1,
        InvestmentType = "ShieldConstruction",
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
            { "MoreThanEcoStorageLevel", { 050,050 } },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.STRUCTURE * Tags.SHIELD } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.SHIELD, true } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.SHIELD * Tags.TECH2,
        },
        WantStructuresSpacing = 1,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.SHIELD, 24},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Shield Coverage",
        RushBaseDefense = "shield",
        RushDevelopment = true,
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Shield Structures MEDIUM"] = true,
            ["Shield Structures HARD"] = true,
        },
        Priority = 8420,
        FormNumInstances = 1,
        InvestmentType = "ShieldConstruction",
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
            { "MoreThanEcoStorageLevel", { 020,0 } },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.STRUCTURE * Tags.SHIELD } },
            { "LessThanUnitsInArmyAtBase", { 8, Tags.STRUCTURE * Tags.SHIELD, true } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.SHIELD * Tags.TECH2,
        },
        WantStructuresSpacing = 1,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.SHIELD, 24},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = false,
    },

}
