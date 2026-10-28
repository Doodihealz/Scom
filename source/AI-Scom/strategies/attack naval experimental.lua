-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")

AIStrategies = {
    {
        StrategyName = "Attack Naval Experimentals",
        StrategyDescription = "Attack reachable naval and coastal targets with mobile naval experimental units.",
        AIdifficulty = {
            easy = false,
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
