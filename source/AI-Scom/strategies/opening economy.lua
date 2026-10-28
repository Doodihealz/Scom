-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")

AIStrategies = {

    {
        StrategyName = "Opening Economy Focus",
        StrategyDescription = "Prioritize earned resource generation during the bounded hard-mode opening",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = true,
        },
        StrategyConditions = {
            { "IsStrategyActive", { "OpeningEconomyFocus" } },
        },
    },

}
