-- Register native Seraphim categories and the former policy before AIInit builds its pools.
Import("AI/mods/AI-Scom/AIPlatoonFunctions.lua")


AIStrategies = {

    {
        StrategyName = "Factory Air Naval Panic",
        StrategyDescription = "Use idle air factories for dedicated anti-naval aircraft",
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
            { "IsStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Air Ground Panic",
        StrategyDescription = "Build as many units as possible",
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
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "EnemyInLandPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Air Air Panic",
        StrategyDescription = "Build as many units as possible",
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
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "EnemyInAirPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Air AntiAir Minimum",
        StrategyDescription = "Build a minimum amount of mobile air units",
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
            { "IsStrategyActive", { "unitCountBelowCap" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },



    {
        StrategyName = "Factory Air AntiAir EASY",
        StrategyDescription = "Build more antiair Air units",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        AIlayer = {
            land = false,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "EnemyHasAirAttackUnits" } },
            { "IsStrategyActive", { "unitCountBelowCap" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },
    {
        StrategyName = "Factory Air AntiLand EASY",
        StrategyDescription = "Build more mobile Air bombers",
        AIdifficulty = {
            easy = true,
            medium = false,
            hard = false,
        },
        AIlayer = {
            land = false,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "unitCountBelowCap" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Air AntiAir MEDIUM",
        StrategyDescription = "Build more antiair Air units",
        AIdifficulty = {
            easy = false,
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
            { "IsStrategyActive", { "EnemyHasAirAttackUnits" } },
            { "IsStrategyActive", { "unitCountBelowCap" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },
    {
        StrategyName = "Factory Air AntiLand MEDIUM",
        StrategyDescription = "Build more mobile Air bombers",
        AIdifficulty = {
            easy = false,
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
            { "IsStrategyActive", { "unitCountBelowCap" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Air AntiAir HARD",
        StrategyDescription = "Build more antiair Air units",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        AIlayer = {
            land = false,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "EnemyHasAirAttackUnits" } },
            { "IsStrategyActive", { "unitCountBelowCap" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },
    {
        StrategyName = "Factory Air AntiLand HARD",
        StrategyDescription = "Build more mobile Air bombers",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        AIlayer = {
            land = false,
            air = true,
            water = false,
        },
        StrategyConditions = {
            -- When do we want to execute this strategy?
            { "IsStrategyActive", { "unitCountBelowCap" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },

    {
        StrategyName = "Factory Air AntiNaval",
        StrategyDescription = "Build torpedo bombers only in response to enemy naval forces",
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
            { "IsStrategyActive", { "EnemyHasNavalAttackUnits" } },
            { "IsStrategyActive", { "unitCountBelowCap" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
        },
    },

}
