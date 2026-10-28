-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Attack Land Commander",
        StrategyDescription = "Attack and defend base with Commander unit",
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
            -- The first power generator can still be unfinished when the ACU can help build it.
            { "MoreThanUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, true} },
            { "MoreThanUnitsInArmy", { 0, Tags.LAND_FACTORY, true} },
            { "MoreThanUnitsInArmy", { 0, Tags.MOBILE * Tags.ENGINEER, true} },
        },
    },

    {
        StrategyName = "Attack Land Small Platoons",
        StrategyDescription = "Attack on land, using many small groups of mobie units.",
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
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
        },
    },

    {
        StrategyName = "Attack Land Primary Platoon",
        StrategyDescription = "Attack on land with a single large group of mobile units.",
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
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
        },
    },


}
