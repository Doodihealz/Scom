-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Structure Defence Ground",
        StrategyDescription = "Send engineers to build more anti ground defence",
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
        },
    },

    {
        StrategyName = "Structure Defence Air",
        StrategyDescription = "Send engineers to build more anti air defence",
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
        },
    },

    {
        StrategyName = "Structure Defence Assist",
        StrategyDescription = "Assist defence structures",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = true,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanUnitsBeingBuilt", { 0, Tags.STRUCTURE * Tags.DEFENCE } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

}
