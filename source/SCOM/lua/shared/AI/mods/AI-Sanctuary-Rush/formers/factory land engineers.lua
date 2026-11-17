
-- Share regular Tech 1 production; forecast overflow can use a second factory.
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Alloy Overflow Base Reserve",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8148,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            -- Fund one local builder from the stored bank while pending power blocks the normal trend check.
            { "MoreThanEcoStorageLevel", { 50, 0 } },
            { "AlloyOverflowImminent", { 50, 60 } },
            -- Unit limits
            { "LessThanUnitsInArmy", { 50, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
            -- Tactical requirements
            { "LessThanIdleUnitsAssignedToBase", { 3, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY * Tags.TECH1, false } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        UseStoredSurplusBuildBudget = true,
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    Recover    --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Recover",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
        },
        Priority = 8020,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LessThanUnitsInArmyAtBase", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    TECH 1     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Tank Opening Queue",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
            ["Factory Land Engineers"] = true,
        },
        Priority = 8150,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LayerSettingMatches", { "land", true } },
            { "LessThanGameTimeSeconds", { 120 } },
            { "LessThanUnitsInArmy", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        WantUnits = {
            -- Keep the first factory on the proven two-engineer, four-tank, one-engineer sequence.
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
            Tags.MOBILE * Tags.LAND * Tags.TANK * Tags.TECH1,
            Tags.MOBILE * Tags.LAND * Tags.TANK * Tags.TECH1,
            Tags.MOBILE * Tags.LAND * Tags.TANK * Tags.TECH1,
            Tags.MOBILE * Tags.LAND * Tags.TANK * Tags.TECH1,
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        SequentialTemplateBuild = true,
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Opening Alloy Overflow",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8149,
        FormNumInstances = 1,
        InvestmentType = "OpeningOverflowEngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 40, 0 } },
            { "AlloyOverflowImminent", { 50, 60 } },
            -- Unit limits
            { "LessThanUnitsInArmy", { 8, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
            -- Tactical requirements
            { "LessThanGameTimeSeconds", { 360 } },
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY * Tags.TECH1, false } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        UseStoredSurplusBuildBudget = true,
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Opening Minimum 2",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
            ["Factory Land Engineers"] = true,
        },
        Priority = 8149,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LayerSettingMatches", { "land", true } },
            { "MoreThanGameTimeSeconds", { 360 } },
            -- Supply the factory and power builders before the first tank production.
            { "LessThanUnitsInArmy", { 2, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Non-Land Opening Minimum 2",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
            ["Factory Land Engineers"] = true,
        },
        Priority = 8149,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LayerSettingMatches", { "land", false } },
            -- Supply the factory and power builders before the first tank production.
            { "LessThanUnitsInArmy", { 2, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Opening Combat Minimum 3",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8149,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "MoreThanGameTimeSeconds", { 360 } },
            { "LayerSettingMatches", { "land", true } },
            { "MoreThanUnitsInArmy", { 7, Tags.MOBILE * Tags.LAND * Tags.TANK, true } },
            { "LessThanUnitsInArmy", { 3, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Opening Recovery Minimum 3",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8149,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "MoreThanGameTimeSeconds", { 360 } },
            { "LayerSettingMatches", { "land", true } },
            -- Keep expansion viable if early tank losses postpone the combat minimum.
            { "MoreThanGameTimeSeconds", { 180 } },
            { "LessThanUnitsInArmy", { 3, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Opening Factory Builder 4",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8149,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LayerSettingMatches", { "land", true } },
            -- Keep factory growth staffed while the first engineers handle power and expansion.
            { "MoreThanUnitsInArmyAtBase", { 2, Tags.LAND_FACTORY * Tags.TECH1, false } },
            { "LessThanUnitsInArmy", { 4, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Combat Expansion Reserve",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8145,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "MoreThanGameTimeSeconds", { 360 } },
            -- Restore expansion builders after the opening combat force is established.
            { "MoreThanUnitsInArmy", { 11, Tags.MOBILE * Tags.LAND * Tags.TANK * Tags.TECH1, false } },
            { "LessThanUnitsInArmy", { 5, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
            { "LessThanUnitsInArmy", { 1, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), true } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Hard Minimum 8",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8149,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        -- Replenish the builder minimum on one line, leaving other factories available for combat.
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LayerSettingMatches", { "land", true } },
            { "MoreThanGameTimeSeconds", { 360 } },
            -- Keep the Hard combat economy supplied without reserving factories for ten builders.
            { "LessThanUnitsInArmy", { 8, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Non-Land Hard Minimum 6",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8142,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        -- Replenish the builder minimum on one line, leaving other factories available for combat.
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LayerSettingMatches", { "land", false } },
            -- Keep the Hard combat economy supplied without reserving factories for ten builders.
            { "LessThanUnitsInArmy", { 6, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer emergency minimum 10",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8140,
        FormNumInstances = 2,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 2, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 10, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer minimum 12",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7110,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 10, 10 } },
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 12, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Alloy Capture",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8139,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            -- Keep optional capture recruitment behind combat during observed base attacks.
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            -- Keep an additional Tech 1 engineer available for Alloy capture while the map share is incomplete.
            -- Extend this reserve to ordinary maps without accumulating idle builders.
            { "MoreThanAlloyExtractorFairShareCount", { 10 } },
            { "LessThanAlloyExtractorFairSharePercent", { 75 } },
            { "CanBuildOnAlloySpotInRange", { 30, 1500 } },
            -- Capture keeps one engineer at the base and needs another for reinforcement.
            -- Distant idle engineers cannot reinforce capture from the base pool.
            { "LessThanUnitsInArmyPoolAtBase", { 2, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, false } },
            { "LessThanUnitsInArmy", { 14, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
            { "LessThanUnitsInPlatoonAtBase", { 8, "B1 Cap Alloys Range 30-1500", Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "LessThanUnitsInPlatoonAtBase", { 8, "B1 Cap Alloys Early Parallel Range 30-1500", Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Rich Map Capture Reinforcement",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8138,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 20, 10 } },
            -- Tactical requirements
            -- Keep optional capture recruitment behind combat during observed base attacks.
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            -- Reinforce one capture coordinator on resource-rich maps after the opening combat force.
            { "MoreThanAlloyExtractorFairShareCount", { 40 } },
            { "LessThanAlloyExtractorFairSharePercent", { 75 } },
            { "MoreThanUnitsInArmy", { 11, Tags.MOBILE * Tags.LAND * Tags.TANK * Tags.TECH1, false } },
            { "CanBuildOnAlloySpotInRange", { 30, 1500 } },
            { "LessThanUnitsInArmyPoolAtBase", { 2, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, false } },
            { "LessThanUnitsInArmy", { 24, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
            { "LessThanUnitsInPlatoonAtBase", { 16, "B1 Cap Alloys Range 30-1500", Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "LessThanUnitsInPlatoonAtBase", { 16, "B1 Cap Alloys Early Parallel Range 30-1500", Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        SequentialTemplateBuild = false,
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer pool <3",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7123,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- Tactical requirements
            { "LessThanIdleUnitsAssignedToBase", { 3, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmy", { 50, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer pool <2",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7122,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- Tactical requirements
            { "LessThanIdleUnitsAssignedToBase", { 2, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "MoreThanUnitsInArmy", { 4, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmy", { 50, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer pool <1",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7121,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- Tactical requirements
            { "LessThanIdleUnitsAssignedToBase", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "MoreThanUnitsInArmy", { 8, Tags.LAND_FACTORY } },
            { "LessThanUnitsInArmy", { 50, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer ArmyRatio 1:10",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7130,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- Tactical requirements
            { "UnitRatio", { 0.1, Tags.MOBILE * Tags.ENGINEER, "<=", Tags.MOBILE * Tags.LAND - Tags.ENGINEER } },
            { "LessThanUnitsInArmy", { 20, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "LessThanUnitsBeingBuiltAtBase", { 2, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Engineer Alloy Surplus Base Reserve",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8146,
        FormNumInstances = 1,
        InvestmentType = "Tech1EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 70, 10 } },
            { "MoreThanEcoStorageAmount", { 100, 1000 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- Tactical requirements
            -- Keep one base builder available for surplus investment after the opening combat force.
            { "MoreThanUnitsInArmy", { 7, Tags.MOBILE * Tags.LAND * Tags.TANK * Tags.TECH1, false } },
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY, false } },
            { "LessThanIdleUnitsAssignedToBase", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1 } },
            { "LessThanUnitsInArmy", { 14, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    TECH 2     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Engineer minimum 1",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8110,
        FormNumInstances = 1,
        InvestmentType = "Tech2EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 1, (Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            (Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Engineer noPool <3",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7120,
        FormNumInstances = 1,
        InvestmentType = "Tech2EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH3, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- Tactical requirements
            { "MoreThanUnitsAssignedToBase", { 0, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
            { "LessThanIdleUnitsAssignedToBase", { 3, (Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER } },
            { "LessThanUnitsInArmy", { 20, (Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            (Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Engineer Alloy Overflow Base Reserve",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8111,
        FormNumInstances = 1,
        InvestmentType = "Tech2EngineerProduction",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH3, 1, 1, 0 },
            -- alternative builder in case the upper one is not available
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            -- Use near-full Alloy storage to supply a free advanced builder, not a large idle pool.
            { "MoreThanEcoStorageLevel", { 90, 10 } },
            { "MoreThanEcoStorageAmount", { 200, 2000 } },
            -- Tactical requirements
            { "MoreThanUnitsAssignedToBase", { 0, Tags.LAND_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
            { "LessThanUnitsInArmyPoolAtBase", { 1, (Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER, false } },
            { "LessThanUnitsInArmy", { 3, (Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER, true } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            (Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH2) - Tags.SCFA_FIELDENGINEER,
        },
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    TECH 3     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Engineer minimum",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8150,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "LessThanUnitsInArmy", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Engineer Transition Second",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8445,
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
            { Tags.LAND_FACTORY * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Tactical requirements
            { "MoreThanUnitsAssignedToMainBase", { 1, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "MoreThanUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3, false } },
            { "MoreThanUnitsInArmy", { 0, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3, false } },
            { "LessThanUnitsInArmy", { 2, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3, true } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Engineer noPool",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7130,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- Tactical requirements
            { "MoreThanUnitsAssignedToMainBase", { 1, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "LessThanIdleUnitsAssignedToBase", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
            { "LessThanUnitsInArmy", { 20, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Engineer Alloy Overflow pool <10",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 7143,
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
            { Tags.LAND_FACTORY * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 60, 0 } },
            -- Tactical requirements
            { "MoreThanUnitsAssignedToMainBase", { 1, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "LessThanIdleUnitsAssignedToBase", { 10, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
            { "LessThanUnitsInArmy", { 30, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Engineer Experimental Builder Minimum",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8151,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageAmount", { 300, 3000 } },
            -- Tactical requirements
            { "MoreThanUnitsInArmy", { 0, Tags.LAND_FACTORY * Tags.TECH3, false } },
            { "LessThanUnitsInArmy", { 5, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3, true } },
            { "LessThanUnitsBeingBuiltInFactories", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3,
        },
        SequentialTemplateBuild = false,
        -- Supply three experimental builders plus power and shield capacity, one funded factory at a time.
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Engineer Experimental Surplus Workforce",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Engineers"] = true,
        },
        Priority = 8152,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 20, 20 } },
            -- Tactical requirements
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "MoreThanUnitsInArmy", { 1, Tags.LAND_FACTORY * Tags.TECH3, false } },
            { "MoreThanUnitsBeingBuiltInFactories", { 0, Tags.MOBILE * Tags.LAND * Tags.TANK * Tags.TECH3 } },
            {
                "GetUnitsThatDesiresBuildAssistAtBase",
                {
                    {
                        AssistBuildUnits = {
                            Tags.MOBILE * Tags.LAND * Tags.TECH4,
                        },
                    },
                }
            },
            { "LessThanIdleUnitsAssignedToBase", { 2, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3 } },
            -- Five base engineers plus 106 helpers cover the measured 521 Alloy/s surplus.
            { "LessThanUnitsInArmy", { 111, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3, true } },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3,
        },
        SequentialTemplateBuild = false,
        AllowEcoStorageDrain = false,
    },

    -- ============================ --
    --    TECH 3 COMBAT ENGINEER    --
    -- ============================ --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Combat Engineer noPool",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Combat Engi"] = true,
        },
        Priority = 7130,
        FormNumInstances = 0, --ToDo: set to 1 when we know how to use this unit
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH3, 1, 1, 0 },
        },
        FormerConditions = {
            -- Economy checks
            { "MoreThanEcoStorageLevel", { 10, 10 } },
            -- Tactical requirements
            { "CanBuildTag", { Tags.MOBILE * Tags.LAND * Tags.COMBAT_ENGINEER * Tags.TECH3 } },
            { "LessThanIdleUnitsAssignedToBase", { 3, Tags.MOBILE * Tags.LAND * Tags.COMBAT_ENGINEER * Tags.TECH3 * ( Tags.GUARD ), } },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.COMBAT_ENGINEER * Tags.TECH3,
        },
        AllowEcoStorageDrain = true,
    },

}
