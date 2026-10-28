-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Tech Center Land",
        StrategyDescription = "Send engineers to build a tech center for land factories",
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
            { "MoreThanUnitsInArmy", { 0, Tags.LAND_FACTORY * Tags.TECH2, false} },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Tech Center Air",
        StrategyDescription = "Send engineers to build a tech center for air factories",
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
            { "MoreThanUnitsInArmy", { 0, Tags.AIR_FACTORY * Tags.TECH2, false} },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Tech Center Naval",
        StrategyDescription = "Send engineers to build a tech center for naval factories",
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
            { "MoreThanUnitsInArmy", { 0, Tags.NAVAL_FACTORY * Tags.TECH2, false} },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Tech Center Upgrade",
        StrategyDescription = "Upgrade tech center structures",
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
            { "MoreThanUpgradeableUnitsInArmy", { 0, Tags.STRUCTURE * Tags.TECH_CENTRE * Tags.TECH1 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Tech Center Assist",
        StrategyDescription = "Assist tech center structures",
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
            { "MoreThanAssistableUnitsInArmy", { 0, Tags.STRUCTURE * Tags.TECH_CENTRE * Tags.TECH1 } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

}
