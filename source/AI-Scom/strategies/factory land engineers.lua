-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Factory Land Engineers",
        StrategyDescription = "Building engineers in land factories",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = true,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanGameTimeSeconds", { 1 } },
            { "BlockIfStrategyActive", { "OpeningEconomyFocus" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Land Combat Engi",
        StrategyDescription = "Building combat engineers in land factories",
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
            { "MoreThanGameTimeSeconds", { 1 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },

}
