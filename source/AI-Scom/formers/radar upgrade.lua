
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U1 Radar Upgrade",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Radar Upgrade"] = true,
        },
        Priority = 3710,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.STRUCTURE * Tags.RADAR * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.RADAR * Tags.TECH2, false} },
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "U2 Radar Upgrade",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Radar Upgrade"] = true,
        },
        Priority = 3720,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.STRUCTURE * Tags.RADAR * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.RADAR * Tags.TECH3, false} },
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = true,
    },

}
