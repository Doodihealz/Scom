
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Transmitter Upgrade",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Transmitter Upgrade"] = true,
        },
        Priority = 3010,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planUpgradeStructure",
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.STRUCTURE * Tags.TRANSMITTER * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoTrend", { 0, 0 } },
            { "MoreThanEcoStorageLevel", { 040, 0 } },
            { "LessThanUnitsInArmyAtBase", { 0, Tags.LAND_FACTORY * Tags.TECH2, false} },
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = false,
    },

}
