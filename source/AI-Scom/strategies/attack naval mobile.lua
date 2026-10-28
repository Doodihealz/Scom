-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")

AIStrategies = {
    {
        StrategyName = "Attack Naval Primary Platoon",
        StrategyDescription = "Attack with one primary naval platoon in every water graph area",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = false,
            air = false,
            water = true,
        },
        StrategyConditions = {
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
        },
    },
    {
        StrategyName = "Attack Naval Small Platoons",
        StrategyDescription = "Attack reachable naval and coastal targets with normal naval platoons",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = false,
            air = false,
            water = true,
        },
        StrategyConditions = {
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
        },
    },
}
