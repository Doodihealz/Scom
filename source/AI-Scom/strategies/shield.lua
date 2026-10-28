-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Commander Emergency Shield",
        StrategyDescription = "Build the first home shield while the commander is retreating",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = false,
        },
        StrategyConditions = {
            { "CommanderIsRetreating", {} },
        },
    },

    {
        StrategyName = "Shield Structures MEDIUM",
        StrategyDescription = "Send engineers to build more shield structures on medium difficulty",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = false,
        },
        AIlayer = {
            land = true,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanGameTimeSeconds", { 1 } },
        },
    },

    {
        StrategyName = "Shield Structures HARD",
        StrategyDescription = "Send engineers to build more shield structures during a base defence investment opportunity",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanGameTimeSeconds", { 1 } },
            { "IsStrategyActive", { "BaseInvestmentOpportunity" } },
        },
    },

    {
        StrategyName = "Shield Upgrade",
        StrategyDescription = "Upgrade shield structures",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        AIlayer = {
            land = true,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanUpgradeableUnitsInArmy", { 0, Tags.STRUCTURE * Tags.SHIELD - Tags.TECH3 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Shield Assist",
        StrategyDescription = "Assist shield structures",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = false,
        },
        AIlayer = {
            land = true,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanAssistableUnitsInArmy", { 0, Tags.STRUCTURE * Tags.SHIELD - Tags.TECH3 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Shield Recharge",
        StrategyDescription = "Recharge shield structures",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = false,
        },
        AIlayer = {
            land = true,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "MoreThanShieldsNeedRechargeInArmyAtBase", { 0, Tags.STRUCTURE * Tags.SHIELD } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

}
