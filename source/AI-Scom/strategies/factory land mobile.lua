-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Factory Land Ground Panic",
        StrategyDescription = "Build as many units as possible",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = false,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Land Air Panic",
        StrategyDescription = "Build as many units as possible",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = false,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "EnemyInAirPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Land Mobile",
        StrategyDescription = "Build more mobile land units",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = false,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "EnemyHasLandAttackUnits" } },
            { "IsStrategyActive", { "unitCountBelowCap" } },
            { "BlockIfStrategyActive", { "OpeningEconomyFocus" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },

}
