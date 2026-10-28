-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")

AIStrategies = {
    {
        StrategyName = "Factory Naval Naval Panic",
        StrategyDescription = "Use every idle naval factory for immediate local naval counters",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = false,
            air = false,
            water = true,
        },
        StrategyConditions = {
            { "IsStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Naval Structures",
        StrategyDescription = "Build one naval factory for every reachable water graph area",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = false,
            air = false,
            water = true,
        },
        StrategyConditions = {
            { "MoreThanGameTimeSeconds", { 1 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },
    {
        StrategyName = "Factory Naval Mobile",
        StrategyDescription = "Build naval combat units for each operational water graph area",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = false,
            air = false,
            water = true,
        },
        StrategyConditions = {
            { "MoreThanUnitsInArmy", { 0, Tags.NAVAL_FACTORY, true } },
            { "IsStrategyActive", { "unitCountBelowCap" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },
    {
        StrategyName = "Factory Naval Upgrade",
        StrategyDescription = "Upgrade naval factories independently in every water graph area",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = false,
            air = false,
            water = true,
        },
        StrategyConditions = {
            { "MoreThanUpgradeableUnitsInArmy", { 0, Tags.NAVAL_FACTORY - Tags.TECH3 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },
}
