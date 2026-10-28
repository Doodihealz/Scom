-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")

AIStrategies = {
    {
        StrategyName = "Attack Air Experimentals",
        StrategyDescription = "Attack ground targets with mobile air experimental units.",
        AIdifficulty = {
            easy = false,
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
        },
    },
}
