-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Factory Air Structures",
        StrategyDescription = "Send engineers to build more air factories",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = false,
            air = true,
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

    {
        StrategyName = "Factory Air Fighter - HARD",
        StrategyDescription = "Build air factories for a fighter deficit up to half the land factory count",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        AIlayer = {
            land = false,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "unitCountBelowCap" } },
            { "UnitRatioAtBase", { 0.5, Tags.AIR_FACTORY, "<", Tags.LAND_FACTORY } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Air Upgrade",
        StrategyDescription = "Upgrade air factories",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = false,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanUpgradeableUnitsInArmy", { 0, Tags.AIR_FACTORY - Tags.TECH3 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Air Assist",
        StrategyDescription = "Assist air factory upgrades",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        AIlayer = {
            land = false,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanAssistableUnitsInArmy", { 0, Tags.AIR_FACTORY - Tags.TECH3 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },


}
