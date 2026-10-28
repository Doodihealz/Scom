-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Radar Structures",
        StrategyDescription = "Send engineers to build more radar structures",
        AIdifficulty = {
            easy = true,
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
        StrategyName = "Radar Upgrade",
        StrategyDescription = "Upgrade radar structures",
        AIdifficulty = {
            easy = true,
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
            { "MoreThanUpgradeableUnitsInArmy", { 0, Tags.STRUCTURE * Tags.RADAR - Tags.TECH3 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Radar Assist",
        StrategyDescription = "Assist radar structures",
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
            { "MoreThanAssistableUnitsInArmy", { 0, Tags.STRUCTURE * Tags.RADAR - Tags.TECH3 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Radar reclaim",
        StrategyDescription = "Send engineers to reclaim Radar buildings",
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
            { "MoreThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.RADAR * (Tags.TECH1 + Tags.TECH2), false} },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

}
