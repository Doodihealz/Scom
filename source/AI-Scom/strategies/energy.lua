-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Energy build LowPrio",
        StrategyDescription = "Send engineers to build energy until trend is positive",
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
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Energy build HighPrio",
        StrategyDescription = "Send engineers to build energy in advance",
        AIdifficulty = {
            easy = false,
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
        StrategyName = "Energy build Emergency",
        StrategyDescription = "Send engineers to build energy in case of low on energy storage and income",
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
            { "MoreThanGameTimeSeconds", { 1 } },
        },
    },

    {
        StrategyName = "Energy storage",
        StrategyDescription = "Send engineers to build energy storage",
        AIdifficulty = {
            easy = false,
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
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Energy assist",
        StrategyDescription = "Send engineers to assist energy generator build",
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
            { "MoreThanAssistableUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Energy reclaim",
        StrategyDescription = "Send engineers to reclaim energy buildings",
        AIdifficulty = {
            easy = false,
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
            { "MoreThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1, false} },
        },
    },

}
