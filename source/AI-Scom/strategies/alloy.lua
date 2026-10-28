
-- Load the active profile before former expressions are evaluated.  The
-- profile's bridge is Seraphim-only; other factions retain their baseline
-- roster and former tables.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")

AIStrategies = {

    {
        StrategyName = "Alloy capture EASY",
        StrategyDescription = "Send engineers to cap alloy spots",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = true,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
            { "CanBuildOnAlloySpotInRange", { 0 , 1000 } },
        },
    },
    {
        StrategyName = "Alloy capture MEDIUM",
        StrategyDescription = "Send engineers to cap alloy spots",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = true,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
            { "CanBuildOnAlloySpotInRange", { 0 , 1000 } },
        },
    },
    {
        StrategyName = "Alloy capture HARD",
        StrategyDescription = "Send engineers to cap alloy spots",
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
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
            { "CanBuildOnAlloySpotInRange", { 0 , 1000 } },
        },
    },

    {
        StrategyName = "Alloy upgrade",
        StrategyDescription = "Upgrade alloy extractors",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = true,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanUpgradeableUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION - Tags.TECH3 } },
        },
    },

    {
        StrategyName = "Alloy storage",
        StrategyDescription = "Send engineers to build alloy storage",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = true,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanGameTimeSeconds", { 1 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Alloy assist",
        StrategyDescription = "Send engineers to assist alloy extractor build and upgrade",
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
            -- When do we want to execute this strategy?
            { "MoreThanAssistableUnitsInArmyAtBase", { 0, Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

}
