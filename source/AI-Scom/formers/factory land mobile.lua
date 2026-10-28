
AIFormers = {

    -- ================== --
    --    TECH 1 Panic    --
    -- ================== --
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Land Mobile Artillery PANIC",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Ground Panic"] = true,
        },
        Priority = 9301,
        FormNumInstances = 100,
        PanicProduction = true,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ARTILLERY - Tags.TECH4,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.LAND * Tags.ARTILLERY, "<=", Tags.MOBILE * Tags.LAND * Tags.TANK } },
        },
        AllowEcoStorageDrain = true,
        SelectHighestTechBuildable = true,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Land Mobile Anti-Air GROUND PANIC 30%",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Ground Panic"] = true,
        },
        Priority = 9302,
        FormNumInstances = 100,
        PanicProduction = true,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ANTI_AIR - Tags.TECH4,
        },
        FormerConditions = {
            -- Keep only 30% of the normal land anti-air ratio while under land pressure.
            { "UnitRatio", { 0.03, Tags.MOBILE * Tags.LAND * Tags.ANTI_AIR, "<=", Tags.MOBILE * Tags.LAND - Tags.ANTI_AIR } },
        },
        AllowEcoStorageDrain = true,
        SelectHighestTechBuildable = true,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Land Mobile Anti-Ground PANIC",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Ground Panic"] = true,
        },
        Priority = 9300,
        FormNumInstances = 100,
        PanicProduction = true,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.TANK - Tags.TECH4,
            Tags.MOBILE * Tags.LAND * Tags.BOT - Tags.TECH4,
            Tags.MOBILE * Tags.LAND * Tags.DIRECT_FIRE - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT - Tags.TECH4,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "CanGraphToCurrentEnemy", {"Land"} },
        },
        AllowEcoStorageDrain = true,
        SelectHighestTechBuildable = true,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Land Mobile Anti-Air PANIC",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Air Panic"] = true,
        },
        Priority = 9303,
        FormNumInstances = 100,
        PanicProduction = true,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.ANTI_AIR - Tags.TECH4,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "LessThanUnitsInArmyAtBase", { 4, Tags.LAND * Tags.ANTI_AIR, false} },
        },
        AllowEcoStorageDrain = true,
        SelectHighestTechBuildable = true,
        SequentialTemplateBuild = false
    },

    -- ============= --
    --    TECH 1     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Land Mobile Anti-Air 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5053,
        FormNumInstances = 5,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.LAND * Tags.ANTI_AIR, "<=", Tags.MOBILE * Tags.LAND - Tags.ANTI_AIR } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Land Mobile Anti-Air 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5052,
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
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.LAND * Tags.ANTI_AIR, "<=", Tags.MOBILE * Tags.LAND - Tags.ANTI_AIR } },
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Land Mobile Anti-Air 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5051,
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
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.LAND * Tags.ANTI_AIR, "<=", Tags.MOBILE * Tags.LAND - Tags.ANTI_AIR } },
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Mobile Bots 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5043,
        FormNumInstances = 5,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.BOT * Tags.TECH1,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 1.0, Tags.MOBILE * Tags.BOT, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Mobile Bots 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5042,
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
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.BOT * Tags.TECH1,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 1.0, Tags.MOBILE * Tags.BOT, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Mobile Bots 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5041,
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
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.BOT * Tags.TECH1,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 1.0, Tags.MOBILE * Tags.BOT, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Mobile Bots Tanks 70%+",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5014,
        FormNumInstances = 50,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * (Tags.BOT + Tags.TANK) * Tags.TECH1,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "LessThanFactoryCombatAlloyUsage", { 70 } },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH1 } },
        },
        AllowEcoStorageDrain = true,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Mobile Bots Tanks Rich Map Threat Recovery",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5015,
        FormNumInstances = 50,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * (Tags.BOT + Tags.TANK) * Tags.TECH1,
        },
        FormerConditions = {
            -- Use idle Tech 1 production capacity while land threat trails on resource-rich maps.
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanAlloyExtractorFairShareCount", { 40 } },
            { "ThreatRatioVersusEnemy", { 1, Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, "<", Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT, "Land" } },
            { "LessThanFactoryCombatAlloyUsage", { 100 } },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH1 } },
        },
        AllowEcoStorageDrain = true,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Mobile Artillery 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 8470,
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
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.ARTILLERY * Tags.TECH1,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanUnitsInArmy", { 29, Tags.MOBILE * Tags.TANK * Tags.TECH1, true } },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH1 } },
            { "LessThanUnitsAssignedToBase", { 1, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatio", { 1 / 30, Tags.MOBILE * Tags.ARTILLERY * Tags.TECH1, "<", Tags.MOBILE * Tags.TANK * Tags.TECH1 } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Mobile Artillery 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5032,
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
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.ARTILLERY * Tags.TECH1,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 0.25, Tags.MOBILE * Tags.ARTILLERY, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Mobile Artillery 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5031,
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
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.ARTILLERY * Tags.TECH1,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 0.25, Tags.MOBILE * Tags.ARTILLERY, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Mobile Tanks 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5023,
        FormNumInstances = 5,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.TANK * Tags.TECH1,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Mobile Tanks 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5022,
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
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.TANK * Tags.TECH1,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Mobile Tanks 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5021,
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
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.TANK * Tags.TECH1,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Mobile Tanks Overflow 100% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5013,
        FormNumInstances = 50,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 100, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.TANK * Tags.TECH1,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanEcoStorageLevel", { 20, 60 } },
            { "MoreThanEnergyTrend", { 0 } },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH1 } },
        },
        AllowEcoStorageDrain = 100,
        SequentialTemplateBuild = false
    },

    -- ============= --
    --    TECH 2     --
    -- ============= --
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Land Mobile Anti-Air 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5453,
        FormNumInstances = 5,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.TECH2 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.LAND * Tags.ANTI_AIR, "<=", Tags.MOBILE * Tags.LAND - Tags.ANTI_AIR } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Land Mobile Anti-Air 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5452,
        FormNumInstances = 5,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.TECH2 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.LAND * Tags.ANTI_AIR, "<=", Tags.MOBILE * Tags.LAND - Tags.ANTI_AIR } },
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Land Mobile Anti-Air 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5451,
        FormNumInstances = 5,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.TECH2 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.LAND * Tags.ANTI_AIR, "<=", Tags.MOBILE * Tags.LAND - Tags.ANTI_AIR } },
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Mobile Bots 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5443,
        FormNumInstances = 5,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.BOT * Tags.TECH2,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 0.4, Tags.MOBILE * Tags.BOT, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Mobile Bots 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5442,
        FormNumInstances = 1, --ToDo: set to 1 when unit is finished
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.BOT * Tags.TECH2,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 0.4, Tags.MOBILE * Tags.BOT, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Mobile Bots 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5441,
        FormNumInstances = 1, --ToDo: set to 1 when unit is finished
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.BOT * Tags.TECH2,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            { "UnitRatioAtBase", { 0.4, Tags.MOBILE * Tags.BOT, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Mobile Bots Overflow 100% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5434,
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
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 100, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.BOT * Tags.TECH2,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanEcoStorageLevel", { 20, 60 } },
            { "MoreThanEnergyTrend", { 0 } },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH2 } },
        },
        AllowEcoStorageDrain = 100,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Mobile Bots Fallback 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5433,
        FormNumInstances = 50,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.BOT * Tags.TECH2,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH2 } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Mobile Tank 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5432,
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
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.TANK * Tags.TECH2,
        },
        FormerConditions = {
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Mobile Tank 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5431,
        FormNumInstances = 1, --ToDo: set to 1 when unit is finished
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.LAND_FACTORY * Tags.TECH2, 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.TANK * Tags.TECH2,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 1, Tags.LAND_FACTORY } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
       },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },

    -- ============= --
    --    TECH 3     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Tanks Transition",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 8140,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.TANK * Tags.TECH3,
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanUnitsInArmy", { 0, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH3, false } },
            { "LessThanUnitsInArmy", { 1, Tags.MOBILE * Tags.LAND * Tags.TECH3 - Tags.ENGINEER, true } },
        },
        AllowEcoStorageDrain = true,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Tanks Transition Sustain",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 8130,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.TANK * Tags.TECH3,
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanUnitsBeingUpgradedAtBase", { 0, Tags.LAND_FACTORY * Tags.TECH2 } },
        },
        AllowEcoStorageDrain = true,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Land Mobile Anti-Air 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5663,
        FormNumInstances = 5,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.TECH3 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.LAND * Tags.ANTI_AIR, "<=", Tags.MOBILE * Tags.LAND - Tags.ANTI_AIR } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Land Mobile Anti-Air 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5662,
        FormNumInstances = 5,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.TECH3 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.LAND * Tags.ANTI_AIR, "<=", Tags.MOBILE * Tags.LAND - Tags.ANTI_AIR } },
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Land Mobile Anti-Air 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5661,
        FormNumInstances = 5,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.LAND * Tags.TECH3 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.LAND * Tags.ANTI_AIR, "<=", Tags.MOBILE * Tags.LAND - Tags.ANTI_AIR } },
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Bots 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5653,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.BOT * Tags.TECH3,
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatioAtBase", { 0.4, Tags.MOBILE * Tags.BOT, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Bots 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5652,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.BOT * Tags.TECH3,
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatioAtBase", { 0.4, Tags.MOBILE * Tags.BOT, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Bots 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5651,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.BOT * Tags.TECH3,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatioAtBase", { 0.4, Tags.MOBILE * Tags.BOT, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Artillery 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5646,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.ARTILLERY * Tags.TECH3,
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanUnitsInArmy", { 29, Tags.MOBILE * Tags.TANK, true } },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatio", { 1 / 30, Tags.MOBILE * Tags.ARTILLERY, "<", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Artillery 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5645,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.ARTILLERY * Tags.TECH3,
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.ARTILLERY, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Artillery 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5644,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.ARTILLERY * Tags.TECH3,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.ARTILLERY, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Sniper 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5645,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.SNIPER * Tags.TECH3,
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.SNIPER, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Sniper 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5644,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.SNIPER * Tags.TECH3,
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.SNIPER, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Sniper 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5643,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.SNIPER * Tags.TECH3,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            { "UnitRatioAtBase", { 0.1, Tags.MOBILE * Tags.SNIPER, "<=", Tags.MOBILE * Tags.TANK } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Tanks 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5644,
        FormNumInstances = 100,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.TANK * Tags.TECH3,
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Tanks 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5643,
        FormNumInstances = 100,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.TANK * Tags.TECH3,
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Mobile Tanks 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Land Mobile"] = true,
        },
        Priority = 5642,
        FormNumInstances = 100,
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
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.TANK * Tags.TECH3,
        },
        FormerConditions = {
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.LAND_FACTORY * Tags.TECH3 } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },

}
