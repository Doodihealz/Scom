-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Artillery Structures Tech2",
        StrategyDescription = "Send engineers to build more T2 artillery structures",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanGameTimeSeconds", { 1 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Artillery Structures Tech3",
        StrategyDescription = "Send engineers to build more T3 artillery structures",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanGameTimeSeconds", { 1 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Artillery Assist",
        StrategyDescription = "Assist artillery structures",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanUnitsBeingBuilt", { 0, Tags.STRUCTURE * Tags.ARTILLERY } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

}
