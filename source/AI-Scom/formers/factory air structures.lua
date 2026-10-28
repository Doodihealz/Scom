
AIFormers = {

    -- =================== --
    --    Air factories    --
    -- =================== --
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Factory Air 1st without Land Layer",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
             ["Factory Air Structures"] = true,
        },
        Priority = 8400,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * (Tags.ENGINEER + Tags.COMMAND) * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            -- When do we want to build this ?
            { "LayerSettingMatches", { "land", false } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.AIR_FACTORY, false} },
            { "LessThanUnitsBeingBuiltAtBase", { 2, Tags.AIR_FACTORY } },
        },
        WantStructures = {
            Tags.AIR_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Factory Air 1st",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
             ["Factory Air Structures"] = true,
        },
        Priority = 8400,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * (Tags.ENGINEER + Tags.COMMAND) * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            -- When do we want to build this ?
            { "LayerSettingMatches", { "land", true } },
            { "MoreThanUnitsInArmyAtBase", { 0, Tags.LAND_FACTORY * Tags.TECH2, false} },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.AIR_FACTORY, false} },
            { "LessThanUnitsBeingBuiltAtBase", { 2, Tags.AIR_FACTORY } },
        },
        WantStructures = {
            Tags.AIR_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Factory Air Fighter Deficit",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir EASY"] = true,
            ["Factory Air AntiAir MEDIUM"] = true,
            ["Factory Air Fighter - HARD"] = true,
        },
        Priority = 8420,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * (Tags.ENGINEER + Tags.COMMAND) * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 75 } },
            -- When do we want to build this ?
            { "LayerSettingMatches", { "land", true } },
            { "LandFactoryCountSupportsAirExpansion", { 8, 6 } },
            { "LessThanIdleFactoriesAssignedToBase", { 1, Tags.AIR_FACTORY } },
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, "<", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.AIR_FACTORY } },
        },
        WantStructures = {
            Tags.AIR_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Factory Air 1:2 Ratio Land",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
             ["Factory Air Structures"] = true,
        },
        Priority = 6600,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * (Tags.ENGINEER + Tags.COMMAND) * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            -- When do we want to build this ?
            { "LayerSettingMatches", { "land", true } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.AIR_FACTORY, false} },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.AIR_FACTORY } },
            { "UnitRatio", { 0.5, Tags.AIR_FACTORY, "<=", Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.AIR_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Air no Idle <1",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
             ["Factory Air Structures"] = true,
        },
        Priority = 6600,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * (Tags.ENGINEER + Tags.COMMAND) * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- When do we want to build this ?
            { "LayerSettingMatches", { "land", true } },
            { "LessThanIdleFactoriesAssignedToBase", { 1, Tags.AIR_FACTORY } },
            { "MoreThanUnitsInArmy", { 0, Tags.AIR_FACTORY, false} },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.AIR_FACTORY } },
            { "UnitRatio", { 0.5, Tags.AIR_FACTORY, "<", Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.AIR_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Air no Idle <1 no Land",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
             ["Factory Air Structures"] = true,
        },
        Priority = 6600,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * (Tags.ENGINEER + Tags.COMMAND) * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- When do we want to build this ?
            { "LayerSettingMatches", { "land", false } },
            { "LessThanIdleFactoriesAssignedToBase", { 1, Tags.AIR_FACTORY } },
            { "MoreThanUnitsInArmy", { 0, Tags.AIR_FACTORY, false} },
        },
        WantStructures = {
            Tags.AIR_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 1,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

}
