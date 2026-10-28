-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Engineering-Station Structures",
        StrategyDescription = "Send engineers to build more engineer-stations",
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
        StrategyName = "Engineering-Station Upgrade",
        StrategyDescription = "Upgrade engineer-stations",
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
            { "MoreThanUpgradeableUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ENGINEERING_STATION - Tags.TECH3 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Engineering-Station Assist",
        StrategyDescription = "Assist engineer-stations",
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
            { "MoreThanAssistableUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ENGINEERING_STATION - Tags.TECH3 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

}
