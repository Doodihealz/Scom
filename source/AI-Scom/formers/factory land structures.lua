
AIFormers = {

    -- ============= --
    --    Recover    --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "BC123 Factory Land Recover good ECO",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
        },
        Priority = 8510,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * (Tags.ENGINEER + Tags.COMMAND) * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 10, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageAmount", { 150, 1500 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "BC123 Factory Land Recover 2nd good ECO",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
        },
        Priority = 8510,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * (Tags.ENGINEER + Tags.COMMAND) * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 10, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageAmount", { 150, 1500 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 0, Tags.LAND_FACTORY, false} },
            { "LessThanUnitsInArmy", { 2, Tags.LAND_FACTORY, false} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "BC123 Factory Land Recover 1st",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
        },
        Priority = 8405,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * (Tags.ENGINEER + Tags.COMMAND) * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 10, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanUnitsBeingBuilt", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },

    -- ==================== --
    --    Land factories    --
    -- ==================== --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "BC123 Factory Land 2nd",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
        },
        Priority = 6640,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
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
            { "MoreThanEcoIncome", { 4, 69 } },
            { "MoreThanEcoStorageLevel", { 30, 30 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmyAtBase", { 2, Tags.LAND_FACTORY, false} },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Factory Land Before T2",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
        },
        Priority = 6670,
        FormNumInstances = 2,
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
            -- When do we want to build this ?
            { "MoreThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY, false} },
            -- Let existing energy construction recover before adding more opening production demand.
            { "MoreThanEcoStorageLevel", { 0, 20 } },
            { "LessThanUnitsInArmyAtBase", { 5, Tags.LAND_FACTORY, true} },
            { "LessThanUnitsBeingBuiltAtBase", { 2, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Factory Land Sixth Before T2",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
        },
        Priority = 6670,
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
            -- When do we want to build this ?
            { "MoreThanUnitsInArmyAtBase", { 4, Tags.LAND_FACTORY * Tags.TECH1, false} },
            { "ThreatRatioVersusEnemy", { 1, Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, ">=", Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, "Land" } },
            { "LessThanUnitsInArmyAtBase", { 6, Tags.LAND_FACTORY, true} },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Factory Land Sixth Economic Start",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
        },
        Priority = 6774,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Reach the six-factory transition minimum without requiring military parity first.
            { "MoreThanEcoStorageAmount", { 150, 1500 } },
            { "MoreThanEcoIncome", { 25, 250 } },
            { "MoreThanUnitsInArmyAtBase", { 4, Tags.LAND_FACTORY * Tags.TECH1, false} },
            { "LessThanUnitsInArmyAtBase", { 6, Tags.LAND_FACTORY, true} },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        -- Fund one factory from stored resources without cancelling when income changes during travel.
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Land no Idle <1",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
        },
        Priority = 6650,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 10, 10 } },
            -- When do we want to build this ?
            { "LessThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanUnitsInArmyAtBase", { 5, Tags.LAND_FACTORY, true} },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Land Transition Replenishment",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
        },
        Priority = 8495,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Keep the factory transition supplied with a new Tech 1 factory.
            { "MoreThanUnitsInArmyAtBase", { 0, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * Tags.TECH1, true} },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Land Enemy Production Response",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
        },
        Priority = 8020,
        FormNumInstances = 3,
        InvestmentType = "FactoryOverflowDevelopmentHigh",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 3, 0 },
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 3, 0 },
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 3, 0 },
        },
        FormerConditions = {
            -- Convert sufficient income into production capacity until enemy factory count is matched.
            { "MoreThanEcoIncome", { 30, -1 } },
            { "MoreThanUnitsInArmyAtBase", { 0, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingBuiltAtBase", { 3, Tags.LAND_FACTORY } },
            { "FactoryRatioVersusEnemyByAlloyFairShare", { 40, 1.1, 1, Tags.LAND_FACTORY, "<", Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Land Rich Map Production Reinforcement",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
        },
        Priority = 8019,
        FormNumInstances = 2,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 2, 0 },
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 2, 0 },
        },
        FormerConditions = {
            -- Maintain two new factory constructions during factory upgrades while production capacity trails on resource-rich maps.
            { "MoreThanAlloyExtractorFairShareCount", { 40 } },
            { "MoreThanUnitsInArmyAtBase", { 0, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingBuiltAtBase", { 2, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "FactoryRatioVersusEnemyByAlloyFairShare", { 40, 1.1, 1, Tags.LAND_FACTORY, "<", Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Land no Idle <2",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
        },
        Priority = 6660,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- When do we want to build this ?
            { "LessThanIdleFactoriesAssignedToBase", { 2, Tags.LAND_FACTORY } },
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanUnitsInArmyAtBase", { 5, Tags.LAND_FACTORY, true} },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Land EX no Idle",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
        },
        Priority = 2210,
        FormNumInstances = 1,
        InvestmentType = "FactoryDevelopment",
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 20, 100 } },
            { "LessThanIdleUnitsAssignedToBase", { 1, Tags.LAND_FACTORY } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanUnitsInArmy", { 2, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsInArmyAtBase", { 6, Tags.LAND_FACTORY, false} },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Land alloy > 50%",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
        },
        Priority = 6390,
        FormNumInstances = 1,
        InvestmentType = "FactoryOverflowDevelopment",
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 2, 0 },
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 2, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 50, 60 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanUnitsInArmyAtBase", { 5, Tags.LAND_FACTORY, true} },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmy", { 2, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), false} },
            { "LessThanUnitsBeingUpgrade", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Land alloy > 75%",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
        },
        Priority = 6721,
        FormNumInstances = 1,
        InvestmentType = "FactoryOverflowDevelopmentHigh",
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 2, 0 },
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 2, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 75, 80 } },
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false} },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.LAND_FACTORY } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = true,
    },

}
