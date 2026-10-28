-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Factory Land Scouts",
        StrategyDescription = "Build land scouts and scout the map",
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
            -- only use land scouts if we don't have air scouts
            { "LessThanUnitsInArmy", { 1, Tags.MOBILE * Tags.AIR * Tags.SCOUT, true} },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Air Scouts",
        StrategyDescription = "Build air scouts and scout the map",
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
            -- we scout always
        },
    },

}
