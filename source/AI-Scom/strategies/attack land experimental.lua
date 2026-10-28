-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")

AIStrategies = {
    {
        StrategyName = "Attack Land Experimentals",
        StrategyDescription = "Attack with mobile land experimental units.",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = false,
            water = false,
        },
        StrategyConditions = {
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
        },
    },
}
