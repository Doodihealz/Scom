
-- SCOM factions expose anti-naval aircraft through different native and
-- compatibility tags. Keep every variant out of land-bomber production.
local ANTI_NAVAL_AIR = Tags.TORPEDO_BOMBER + Tags.ANTI_NAVAL + Tags.ANTI_NAVY + Tags.SCFA_ANTINAVY
local LAND_BOMBERS = Tags.BOMBER - ANTI_NAVAL_AIR

AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P23 Air Mobile Anti-Naval PANIC",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Naval Panic"] = true,
        },
        Priority = 9312,
        FormNumInstances = 100,
        PanicProduction = true,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.AIR_FACTORY * (Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        WantUnits = {
            Tags.MOBILE * Tags.AIR * ANTI_NAVAL_AIR * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3) - Tags.TECH4,
        },
        FormerConditions = {
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.AIR_FACTORY * (Tags.TECH2 + Tags.TECH3) } },
        },
        AllowEcoStorageDrain = true,
        SelectHighestTechBuildable = true,
        SequentialTemplateBuild = false,
    },

    -- ================== --
    --    TECH 1 Panic    --
    -- ================== --
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Air Mobile Anti-Ground PANIC",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Ground Panic"] = true,
        },
        Priority = 9310,
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
            { Tags.AIR_FACTORY * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.GUNSHIP * Tags.ANTI_SURFACE - Tags.TECH4,
            Tags.MOBILE * Tags.AIR * LAND_BOMBERS - Tags.TECH4,
            Tags.MOBILE * Tags.AIR * Tags.ANTI_SURFACE - ANTI_NAVAL_AIR - Tags.TECH4,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "CanGraphToCurrentEnemy", {"Land"} },
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * (LAND_BOMBERS + Tags.GUNSHIP * Tags.ANTI_SURFACE), "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = true,
        SelectHighestTechBuildable = true,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Air Mobile Anti-Air PANIC",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air Air Panic"] = true,
        },
        Priority = 9311,
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
            { Tags.AIR_FACTORY * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.ANTI_AIR - Tags.TECH4,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
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
        FormerName = "P1 Air Mobile Bomber First",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand EASY"] = true,
            ["Factory Air AntiLand MEDIUM"] = true,
            ["Factory Air AntiLand HARD"] = true,
        },
        Priority = 7061,
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
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 1, Tags.MOBILE * Tags.AIR * Tags.TECH1 * LAND_BOMBERS, true } },
        },
        AllowEcoStorageDrain = true,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Air Mobile Bomber Minimum 5",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand EASY"] = true,
            ["Factory Air AntiLand MEDIUM"] = true,
            ["Factory Air AntiLand HARD"] = true,
        },
        Priority = 7048,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 5, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, true } },
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Air Mobile Anti-Air Minimum",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir Minimum"] = true,
        },
        Priority = 7060,
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
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 4, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            -- Prepare enough fighters for the existing six-unit air primary before enemy aircraft arrive.
            { "LessThanUnitsInArmy", { 6, Tags.AIR * Tags.MOBILE * Tags.FIGHTER, true} },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Air Mobile Gunship Minimum 5",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand EASY"] = true,
            ["Factory Air AntiLand MEDIUM"] = true,
            ["Factory Air AntiLand HARD"] = true,
        },
        Priority = 7047,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.GUNSHIP * Tags.ANTI_SURFACE,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.GUNSHIP * Tags.ANTI_SURFACE } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 5, Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.GUNSHIP * Tags.ANTI_SURFACE, true } },
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Air Mobile Bomber 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand HARD"] = true,
        },
        Priority = 5033,
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
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 50 } },
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
            { "LessThanUnitsInArmy", { 10, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, true } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Air Mobile Bomber 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand MEDIUM"] = true,
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
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
            { "LessThanUnitsInArmy", { 10, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, true } },
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Air Mobile Bomber 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand EASY"] = true,
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
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
            { "LessThanUnitsInArmy", { 10, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, true } },
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Air Mobile Anti-Air 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir HARD"] = true,
        },
        Priority = 7055,
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
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 50 } },
            -- When do we want to build this ?
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, "<", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Air Mobile Anti-Air 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir MEDIUM"] = true,
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
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, "<", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Air Mobile Anti-Air 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir EASY"] = true,
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
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, "<", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Air Mobile Anti-Air ECO Overflow",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir Minimum"] = true,
        },
        Priority = 5013,
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
            { Tags.AIR_FACTORY * Tags.TECH1, 1, 100, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { "MoreThanEnemyUnits", { 0, Tags.MOBILE * Tags.AIR } },
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, ">=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = false,
        SequentialTemplateBuild = false
    },
    -- ============= --
    --    TECH 2     --
    -- ============= --
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Air Mobile Anti-Air Minimum",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir Minimum"] = true,
        },
        Priority = 7060,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 4, 0 },
        },
        WantUnits = {
            -- Non-sequential production uses the first available tier for this faction.
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "LessThanUnitsInArmy", { 6, Tags.AIR * Tags.MOBILE * Tags.FIGHTER, true} },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Air Mobile Anti-Naval Aircraft Response",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiNaval"] = true,
        },
        Priority = 7058,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.AIR_FACTORY * (Tags.TECH2 + Tags.TECH3), 1, 50, 0 },
        },
        WantUnits = {
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * ANTI_NAVAL_AIR,
        },
        FormerConditions = {
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * Tags.TECH2 * ANTI_NAVAL_AIR } },
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            { "LessThanUnitsInArmy", { 8, Tags.MOBILE * Tags.AIR * ANTI_NAVAL_AIR, true } },
            { "UnitRatioVersusEnemy", { 0.5, Tags.MOBILE * Tags.AIR * ANTI_NAVAL_AIR, "<", Tags.MOBILE * Tags.NAVAL } },
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Air Mobile Bomber Minimum 5",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand EASY"] = true,
            ["Factory Air AntiLand MEDIUM"] = true,
            ["Factory Air AntiLand HARD"] = true,
        },
        Priority = 7048,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * LAND_BOMBERS,
            -- SCOM has no true T2 land bomber; upgraded factories can still build T1 bombers.
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * (Tags.TECH1 + Tags.TECH2) * LAND_BOMBERS } },
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 5, Tags.MOBILE * Tags.AIR * (Tags.TECH1 + Tags.TECH2) * LAND_BOMBERS, true } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Air Mobile Gunship Minimum 5",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand EASY"] = true,
            ["Factory Air AntiLand MEDIUM"] = true,
            ["Factory Air AntiLand HARD"] = true,
        },
        Priority = 7047,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.GUNSHIP * Tags.ANTI_SURFACE,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.GUNSHIP * Tags.ANTI_SURFACE } },
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 5, Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.GUNSHIP * Tags.ANTI_SURFACE, true } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Air Mobile Gunship 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand HARD"] = true,
        },
        Priority = 5334,
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
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.GUNSHIP * Tags.ANTI_SURFACE,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.GUNSHIP * Tags.ANTI_SURFACE } },
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * Tags.GUNSHIP * Tags.ANTI_SURFACE, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Air Mobile Bomber 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand HARD"] = true,
        },
        Priority = 5333,
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
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * LAND_BOMBERS,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * (Tags.TECH1 + Tags.TECH2) * LAND_BOMBERS } },
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Air Mobile Bomber 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand MEDIUM"] = true,
        },
        Priority = 5332,
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
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * LAND_BOMBERS,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * (Tags.TECH1 + Tags.TECH2) * LAND_BOMBERS } },
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Air Mobile Bomber 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand EASY"] = true,
        },
        Priority = 5331,
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
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * LAND_BOMBERS,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * (Tags.TECH1 + Tags.TECH2) * LAND_BOMBERS } },
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },

	{
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Air Mobile Anti-Air 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir HARD"] = true,
        },
        Priority = 7055,
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
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, "<", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Air Mobile Anti-Air 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir MEDIUM"] = true,
        },
        Priority = 5323,
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
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, "<", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Air Mobile Anti-Air 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir EASY"] = true,
        },
        Priority = 5323,
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
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, "<", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P2 Air Mobile Anti-Air ECO Overflow",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir Minimum"] = true,
        },
        Priority = 5313,
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
            { Tags.AIR_FACTORY * Tags.TECH2, 1, 100, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, ">=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = false,
        SequentialTemplateBuild = false
    },

    -- ============= --
    --    TECH 3     --
    -- ============= --
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Anti-Air Minimum",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir Minimum"] = true,
        },
        Priority = 7060,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 4, 0 },
        },
        WantUnits = {
            -- Non-sequential production uses the first available tier for this faction.
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            { "MoreThanEcoStorageLevel", { 0, 30 } },
            { "LessThanUnitsInArmy", { 6, Tags.AIR * Tags.MOBILE * Tags.FIGHTER, true} },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Bomber Minimum 3",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand EASY"] = true,
            ["Factory Air AntiLand MEDIUM"] = true,
            ["Factory Air AntiLand HARD"] = true,
        },
        Priority = 7047,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * Tags.TECH3 * LAND_BOMBERS } },
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 3, Tags.MOBILE * Tags.AIR * Tags.TECH3 * LAND_BOMBERS, true } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Gunship Minimum 3",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand EASY"] = true,
            ["Factory Air AntiLand MEDIUM"] = true,
            ["Factory Air AntiLand HARD"] = true,
        },
        Priority = 7048,
        FormNumInstances = 2,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            -- What factories do we need for this platoon ?
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.GUNSHIP * Tags.ANTI_SURFACE,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.GUNSHIP * Tags.ANTI_SURFACE } },
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "LessThanUnitsInArmy", { 3, Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.GUNSHIP * Tags.ANTI_SURFACE, true } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Bomber 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand HARD"] = true,
        },
        Priority = 5632,
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
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * Tags.TECH3 * LAND_BOMBERS } },
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Gunship 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand HARD"] = true,
        },
        Priority = 5633,
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
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.GUNSHIP * Tags.ANTI_SURFACE,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.GUNSHIP * Tags.ANTI_SURFACE } },
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * Tags.GUNSHIP * Tags.ANTI_SURFACE, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Bomber 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand MEDIUM"] = true,
        },
        Priority = 5631,
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
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * Tags.TECH3 * LAND_BOMBERS } },
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Gunship 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand MEDIUM"] = true,
        },
        Priority = 5632,
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
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.GUNSHIP * Tags.ANTI_SURFACE,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.GUNSHIP * Tags.ANTI_SURFACE } },
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * Tags.GUNSHIP * Tags.ANTI_SURFACE, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Bomber 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand EASY"] = true,
        },
        Priority = 5630,
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
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * LAND_BOMBERS,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * Tags.TECH3 * LAND_BOMBERS } },
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * LAND_BOMBERS, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Gunship 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiLand EASY"] = true,
        },
        Priority = 5631,
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
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.GUNSHIP * Tags.ANTI_SURFACE,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "CanBuildTag", { Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.GUNSHIP * Tags.ANTI_SURFACE } },
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatio", { 0.2, Tags.MOBILE * Tags.AIR * Tags.GUNSHIP * Tags.ANTI_SURFACE, "<=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },

	{
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Anti-Air 75% ECO",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir HARD"] = true,
        },
        Priority = 7055,
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
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, "<", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 75,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Anti-Air 65% ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir MEDIUM"] = true,
        },
        Priority = 5623,
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
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, "<", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 65,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Anti-Air 50% ECO",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir EASY"] = true,
        },
        Priority = 5623,
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
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 50, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, "<", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = 50,
        SequentialTemplateBuild = false
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P3 Air Mobile Anti-Air ECO Overflow",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Air AntiAir Minimum"] = true,
        },
        Priority = 5613,
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
            { Tags.AIR_FACTORY * Tags.TECH3, 1, 100, 0 },
        },
        WantUnits = {
            -- What units do we want to build for this platoon ?
            Tags.MOBILE * Tags.AIR * Tags.TECH3 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH2 * Tags.ANTI_AIR,
            Tags.MOBILE * Tags.AIR * Tags.TECH1 * Tags.ANTI_AIR,
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            { "MoreThanEcoStorageLevel", { 0, 40 } },
            { "MoreThanEcoTrend", { 0, 0 } },
            -- When do we want to build this ?
            { "UnitRatioVersusEnemy", { 1.4, Tags.MOBILE * Tags.AIR * Tags.FIGHTER, ">=", Tags.MOBILE * Tags.AIR * Tags.FIGHTER } },
        },
        AllowEcoStorageDrain = false,
        SequentialTemplateBuild = false
    },


}
