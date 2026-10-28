
AIFormers = {

    -- ============= --
    --    Recover    --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Recover",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
        },
        Priority = 8410,
        FormNumInstances = 1,
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
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, false} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    TECH 1     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Maintenance",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6705,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 2, 1 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "IsStrategyActive", { "NeedMoreEnergyForMaintenance" } },
            -- Old maintenance failures must not keep filling an already full Energy store.
            { "LessThanEcoStorageLevel", { 100, 75 } },
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), true} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Generator <-100% Urgent",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6710,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 2, 1 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "LessThanEcoStorageLevel", { 100, 100 } },
            { "LessThanEnergyTrend", { 0 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), true} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Generator <-80% Emergency",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6710,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 1 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "LessThanEcoStorageLevel", { 100, 80 } },
            { "LessThanEnergyTrend", { 0 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), true} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Generator <-60% Apocalypse",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6740,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 1 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "LessThanEcoStorageLevel", { 100, 60 } },
            { "LessThanEnergyTrend", { 0 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), true} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Generator <-40% Armageddon",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6750,
        FormNumInstances = 1,
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
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "LessThanEcoStorageLevel", { 100, 40 } },
            { "LessThanEnergyTrend", { 0 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Generator <-20% Ragnarok",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6760,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.COMMAND, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "LessThanEcoStorageLevel", { 100, 20 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy To Alloy Ratio 20 HighPrio",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build HighPrio"] = true,
        },
        Priority = 6775,
        FormNumInstances = 1,
        InvestmentType = "EnergyBuild",
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
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 10, 0 } },
            { "LessThanEcoStorageLevel", { 100, 75 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanEnergyToResourceRatioIncome", { 20 } },  -- True if we have less income for energy than resource * 20 ( energy <= resource * x = true )
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), true} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy T2 Transition",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6770,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 2, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanFactoryCombatAlloyUsage", { 70 } },
            { "CannotCompleteFactoryUpgradeWithPositiveEnergyStorage", { Tags.LAND_FACTORY * Tags.TECH1 } },
            -- When do we want to build this ?
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsAssignedToBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy T2 Construction Bridge",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6765,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 2, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "TechnologyTwoEnergyConstructionBridgeRequired", { 40 } },
            { "LessThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), false} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    TECH 2     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B2 Energy First Rich Map",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 8105,
        FormNumInstances = 1,
        InvestmentType = "EnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- Build the first Tech 2 energy producer immediately on resource-rich maps.
            { "MoreThanAlloyExtractorFairShareCount", { 40 } },
            { "LessThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2, true} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B2 Energy To Alloy Ratio 15 Rich Map",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build LowPrio"] = true,
        },
        Priority = 6565,
        FormNumInstances = 1,
        InvestmentType = "EnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Scale Tech 2 energy beside factories on resource-rich maps where shield adjacency can become unavailable.
            { "MoreThanAlloyExtractorFairShareCount", { 40 } },
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "MoreThanUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2, false} },
            { "LessThanEnergyToResourceRatioIncome", { 15 } },
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * Tags.TECH3, true} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B2 Energy First",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        -- Assign the first Tech 2 energy order before additional factory construction can claim its engineer.
        Priority = 8104,
        FormNumInstances = 1,
        InvestmentType = "EnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2, true} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B2 Energy Maintenance",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6705,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 2, 1 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "IsStrategyActive", { "NeedMoreEnergyForMaintenance" } },
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * Tags.TECH3, true} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 2,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B2 Energy Generator <-100% Urgent",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6720,
        FormNumInstances = 1,
        InvestmentType = "EnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "LessThanEcoStorageLevel", { 100, 100 } },
            { "LessThanEnergyTrend", { 0 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * Tags.TECH3, true} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B2 Energy To Alloy Ratio 15 HighPrio",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build HighPrio"] = true,
        },
        Priority = 6540,
        FormNumInstances = 1,
        InvestmentType = "EnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanEnergyToResourceRatioIncome", { 15 } },  -- True if we have less income for energy than resource * 15 ( energy <= resource * x = true )
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * Tags.TECH3, true} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B2 Energy To Alloy Ratio 14 HighPrio",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build LowPrio"] = true,
        },
        Priority = 6550,
        FormNumInstances = 1,
        InvestmentType = "EnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanEnergyToResourceRatioIncome", { 14 } },  -- True if we have less income for energy than resource * 14 ( energy <= resource * x = true )
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * Tags.TECH3, true} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B2 Energy To Alloy Ratio 13 HighPrio",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build LowPrio"] = true,
        },
        Priority = 6560,
        FormNumInstances = 1,
        InvestmentType = "EnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanEnergyToResourceRatioIncome", { 13 } },  -- True if we have less income for energy than resource * 13 ( energy <= resource * x = true )
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * Tags.TECH3, true} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    TECH 3     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B3 Energy First",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6730,
        FormNumInstances = 1,
        InvestmentType = "EnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3, true} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 3,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B3 Energy Maintenance",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6705,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 2, 1 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "IsStrategyActive", { "NeedMoreEnergyForMaintenance" } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 2,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B3 Energy Trend <-0 Emergency",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 6730,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 20, 0 } },
            -- When do we want to build this ?
            { "LessThanEnergyTrend", { 000 } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 4,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B3 Energy To Alloy Ratio 15 HighPrio",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build HighPrio"] = true,
        },
        Priority = 6570,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanEnergyToResourceRatioIncome", { 15 } },  -- True if we have less income for energy than resource * 15 ( energy <= resource * x = true )
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 4,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B3 Energy To Alloy Ratio 14 HighPrio",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build LowPrio"] = true,
        },
        Priority = 6580,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanEnergyToResourceRatioIncome", { 14 } },  -- True if we have less income for energy than resource * 14 ( energy <= resource * x = true )
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 4,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B3 Energy To Alloy Ratio 13 HighPrio",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build LowPrio"] = true,
        },
        Priority = 6590,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanEnergyToResourceRatioIncome", { 13 } },  -- True if we have less income for energy than resource * 13 ( energy <= resource * x = true )
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION} },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 4,
        BuildBehindBase = 60,
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10},
            {Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2},
        },
        AllowEcoStorageDrain = true,
    },


}
