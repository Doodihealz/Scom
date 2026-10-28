-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Attack Air Small Platoons",
        StrategyDescription = "Attack on Air, using many small groups of mobie units.",
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
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
        },
    },

    {
        StrategyName = "Attack Air Ground Combat Platoons",
        StrategyDescription = "Attack ground targets with combat groups of bombers and gunships.",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        AIlayer = {
            land = false,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
        },
    },

    {
        StrategyName = "Attack Air Primary Platoon",
        StrategyDescription = "Attack on Air with a single large group of mobile units.",
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
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
        },
    },

    {
        StrategyName = "Attack Air Naval Platoons",
        StrategyDescription = "Attack naval targets with dedicated torpedo-bomber groups",
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
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
            { "IsStrategyActive", { "EnemyHasNavalAttackUnits" } },
        },
    },


}
