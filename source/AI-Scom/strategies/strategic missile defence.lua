-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Strategic Missile Defence Structures",
        StrategyDescription = "Send engineers to build more strategic missile defence",
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
        StrategyName = "Strategic Missile Defence Assist",
        StrategyDescription = "Assist strategic missile defence",
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
            { "MoreThanUnitsBeingBuilt", { 0, Tags.STRUCTURE * Tags.DEFENCE * Tags.ANTI_PROJECTILE * Tags.TECH3 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

}
