AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Half Bank Production Supply",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
            ["Energy build LowPrio"] = true,
            ["Energy build HighPrio"] = true,
            ["Energy build Emergency"] = true,
        },
        Priority = 8516,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1 - Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 50, 0 } },
            { "AlloyOverflowNeedsEnergy", {} },
            -- Tactical requirements
            { "LayerSettingMatches", { "land", true } },
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false } },
            { "LessThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), false } },
            { "LessThanUnitsBeingBuilt", { 2, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
        },
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Opening Grid",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
            ["Factory Land Structures"] = true,
            ["Energy build LowPrio"] = true,
            ["Energy build HighPrio"] = true,
            ["Energy build Emergency"] = true,
        },
        Priority = 8516,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1 - Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LayerSettingMatches", { "land", true } },
            { "LessThanGameTimeSeconds", { 600 } },
            -- The first engineer starts factory two; the next engineers fund both tank lines.
            { "MoreThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY, true } },
            { "LessThanUnitsInArmyAtBase", { 3, Tags.LAND_FACTORY, true } },
            { "LessThanUnitsInArmyAtBase", { 7, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1, true } },
            { "LessThanUnitsBeingBuilt", { 2, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
        },
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Opening Power Bridge",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
            ["Factory Land Structures"] = true,
            ["Energy build LowPrio"] = true,
            ["Energy build HighPrio"] = true,
            ["Energy build Emergency"] = true,
        },
        Priority = 8516,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1 - Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "LessThanEnergyTrend", { 0.1 } },
            -- Tactical requirements
            { "LayerSettingMatches", { "land", true } },
            { "LessThanGameTimeSeconds", { 600 } },
            -- Restore the energy trend before factory three can start.
            { "MoreThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY, true } },
            { "LessThanUnitsInArmyAtBase", { 3, Tags.LAND_FACTORY, true } },
            { "MoreThanUnitsInArmyAtBase", { 6, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1, true } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
        },
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Opening Factory Supply",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
            ["Energy build LowPrio"] = true,
            ["Energy build HighPrio"] = true,
            ["Energy build Emergency"] = true,
        },
        Priority = 8516,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1 - Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LayerSettingMatches", { "land", true } },
            { "LessThanGameTimeSeconds", { 600 } },
            { "MoreThanUnitsInArmyAtBase", { 2, Tags.LAND_FACTORY, true } },
            -- Power for additional factories uses a simple count ratio.
            { "UnitRatioAtBase", { 1 / 3, Tags.LAND_FACTORY, ">", Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1 } },
            { "LessThanUnitsBeingBuilt", { 2, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
        },
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B2 Energy Alloy Overflow Recovery",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 8515,
        FormNumInstances = 1,
        InvestmentType = "AlloyOverflowEnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { (Tags.MOBILE * Tags.ENGINEER * (Tags.TECH2 + Tags.TECH3)) - Tags.SCFA_FIELDENGINEER, 1, 2, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "RushNeedsPlannedEnergy", { 2 } },
            -- Tactical requirements
            { "LessThanUnitsBeingBuilt", { 2, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 3 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Alloy Overflow Recovery",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 8514,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        -- Keep one power builder working while the next engineer can capture Alloy.
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1 - Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "RushNeedsPlannedEnergy", { 1 } },
            -- Tactical requirements
            { "LayerSettingMatches", { "land", true } },
            { "LessThanUnitsBeingBuilt", { 3, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        -- Keep Tech 1 power beside factories for the future adjacency bonus.
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    Recover    --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Opening Engineer",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
        },
        Priority = 8513,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        -- Give the first engineer power construction before more captures, without claiming the commander.
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1 - Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "MoreThanUnitsInArmyAtBase", { 0, Tags.LAND_FACTORY + Tags.AIR_FACTORY, false } },
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, true } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION } },
        },
        -- Front-load a second generator before the first engineer returns to the capture/build pool.
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
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        AllowEcoStorageDrain = true,
    },
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
            -- Tactical requirements
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, false } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION } },
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
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
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
            -- Economy checks
            -- Old maintenance failures must not keep filling an already full Energy store.
            { "LessThanEcoStorageLevel", { 100, 75 } },
            { "IsStrategyActive", { "NeedMoreEnergyForMaintenance" } },
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), true } },
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
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
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
            -- Economy checks
            -- Leave high-storage builders available for production while existing power work finishes.
            { "LessThanEcoStorageLevel", { 100, 75 } },
            { "LessThanEnergyTrend", { 0 } },
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), true } },
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
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
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
            -- Economy checks
            { "LessThanEcoStorageLevel", { 100, 80 } },
            { "LessThanEnergyTrend", { 0 } },
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), true } },
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
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
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
            -- Economy checks
            { "LessThanEcoStorageLevel", { 100, 60 } },
            { "LessThanEnergyTrend", { 0 } },
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), true } },
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
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
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
            -- Economy checks
            { "LessThanEcoStorageLevel", { 100, 40 } },
            { "LessThanEnergyTrend", { 0 } },
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), false } },
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
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "LessThanEcoStorageLevel", { 100, 20 } },
            -- A larger, refilling store must not keep builders on unnecessary power construction.
            { "LessThanEnergyTrend", { 0 } },
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), false } },
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
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
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
        -- Supply power before optional storage, surplus factories or distant capture take every free builder.
        Priority = 8310,
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
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 2, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 10, 0 } },
            { "LessThanEcoStorageLevel", { 100, 75 } },
            { "LessThanEnergyToResourceRatioIncome", { 20 } }, -- True if we have less income for energy than resource * 20 ( energy <= resource * x = true )
            { "AlloyOverflowNeedsEnergy", {} }, -- Keep the ratio buffer from delaying capture while existing power covers demand.
            -- Tactical requirements
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false } },
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), true } },
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
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
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
            -- Economy checks
            { "MoreThanFactoryCombatAlloyUsage", { 70 } },
            { "CannotCompleteFactoryUpgradeWithPositiveEnergyStorage", { Tags.LAND_FACTORY * Tags.TECH1 } },
            -- Tactical requirements
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
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
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
        -- Bridge the transition before surplus factories claim the remaining Tech 1 builders.
        Priority = 8309,
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
            -- Economy checks
            { "LessThanEcoStorageLevel", { 100, 75 } },
            -- Tactical requirements
            { "TechnologyTwoEnergyConstructionBridgeRequired", { 40 } },
            { "LessThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * (Tags.TECH2 + Tags.TECH3), false } },
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
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
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
        -- The first T2 generator must not wait for an active T1 power job.
        InvestmentType = "FirstTech2EnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            -- One builder starts immediately; one additional free engineer can shorten the transition.
            { (Tags.MOBILE * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER, 1, 2, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            -- Build the first Tech 2 energy producer immediately on resource-rich maps.
            { "MoreThanAlloyExtractorFairShareCount", { 40 } },
            { "LessThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2, true } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
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
            { (Tags.MOBILE * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 10, 20 } },
            { "LessThanEnergyToResourceRatioIncome", { 15 } },
            -- Tactical requirements
            -- Scale Tech 2 energy beside factories on resource-rich maps where shield adjacency can become unavailable.
            { "MoreThanAlloyExtractorFairShareCount", { 40 } },
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false } },
            { "MoreThanUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2, false } },
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * Tags.TECH3, true } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
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
        -- Finish the first large power source before surplus upgrades and optional construction claim its engineers.
        Priority = 8516,
        FormNumInstances = 1,
        -- The first T2 generator must not wait for an active T1 power job.
        InvestmentType = "FirstTech2EnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            -- One builder starts immediately; one additional free engineer can shorten the transition.
            { (Tags.MOBILE * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER, 1, 2, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2, true } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
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
            { (Tags.MOBILE * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER, 1, 2, 1 },
        },
        FormerConditions = {
            -- Economy checks
            { "IsStrategyActive", { "NeedMoreEnergyForMaintenance" } },
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * Tags.TECH3, true } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 2,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
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
            { (Tags.MOBILE * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "LessThanEcoStorageLevel", { 100, 100 } },
            { "LessThanEnergyTrend", { 0 } },
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * Tags.TECH3, true } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
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
            { (Tags.MOBILE * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            { "LessThanEnergyToResourceRatioIncome", { 15 } }, -- True if we have less income for energy than resource * 15 ( energy <= resource * x = true )
            -- Tactical requirements
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false } },
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * Tags.TECH3, true } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
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
            { (Tags.MOBILE * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            { "LessThanEnergyToResourceRatioIncome", { 14 } }, -- True if we have less income for energy than resource * 14 ( energy <= resource * x = true )
            -- Tactical requirements
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false } },
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * Tags.TECH3, true } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
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
            { (Tags.MOBILE * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            { "LessThanEnergyToResourceRatioIncome", { 13 } }, -- True if we have less income for energy than resource * 13 ( energy <= resource * x = true )
            -- Tactical requirements
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false } },
            { "LessThanUnitsInArmy", { 1, Tags.ENERGY_PRODUCTION * Tags.TECH3, true } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH2,
        },
        WantStructuresSpacing = 3,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    TECH 3     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B3 Experimental Construction Supply",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 8514,
        FormNumInstances = 1,
        InvestmentType = "EnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "RushNeedsPlannedEnergy", { 3 } },
            { "MoreThanEcoStorageLevel", { 20, 0 } },
            -- Tactical requirements
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY * Tags.TECH3, false } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 3,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
        -- Restore power before assigning optional experimental builders and assistants.
        AllowEcoStorageDrain = true,
    },
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
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3, true } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 3,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
        AllowEcoStorageDrain = false,
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
            -- Economy checks
            { "IsStrategyActive", { "NeedMoreEnergyForMaintenance" } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 2,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
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
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 20, 0 } },
            { "LessThanEnergyTrend", { 000 } },
            -- Tactical requirements
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 4,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
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
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            { "LessThanEnergyToResourceRatioIncome", { 15 } }, -- True if we have less income for energy than resource * 15 ( energy <= resource * x = true )
            -- Tactical requirements
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 4,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
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
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            { "LessThanEnergyToResourceRatioIncome", { 14 } }, -- True if we have less income for energy than resource * 14 ( energy <= resource * x = true )
            -- Tactical requirements
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 4,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
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
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 10, 100 } },
            { "LessThanEnergyToResourceRatioIncome", { 13 } }, -- True if we have less income for energy than resource * 13 ( energy <= resource * x = true )
            -- Tactical requirements
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
        },
        WantStructuresSpacing = 4,
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 10 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        BuildBehindBase = 60,
        AllowEcoStorageDrain = true,
    },


    -- Keep the original non-land power forecast outside the land opening.
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Non-Land Forecast Recovery",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Energy build Emergency"] = true,
        },
        Priority = 8514,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        -- Keep one power builder working while the next engineer can capture Alloy.
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1 - Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "RushNeedsPlannedEnergy", { 1 } },
            -- Tactical requirements
            { "LayerSettingMatches", { "land", false } },
            { "LessThanUnitsBeingBuilt", { 3, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        -- Keep Tech 1 power beside factories for the future adjacency bonus.
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
            Tags.AIR_FACTORY,
        },
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        AllowEcoStorageDrain = true,
    },

    -- Fund construction demand in addition to the opening factory power ratio.
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Energy Opening Construction Supply",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Structures"] = true,
            ["Energy build LowPrio"] = true,
            ["Energy build HighPrio"] = true,
            ["Energy build Emergency"] = true,
        },
        Priority = 8516,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1 - Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            -- Energy trends and pending reservations use per-second values; retain a 50 Energy construction buffer.
            { "LessThanEnergyTrend", { 50 } },
            -- Tactical requirements
            { "LayerSettingMatches", { "land", true } },
            { "LessThanGameTimeSeconds", { 600 } },
            { "MoreThanUnitsInArmyAtBase", { 1, Tags.LAND_FACTORY, true } },
            { "LessThanUnitsBeingBuilt", { 2, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
        },
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        AllowEcoStorageDrain = true,
    },

}
