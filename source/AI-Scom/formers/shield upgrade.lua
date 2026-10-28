
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T2 Shield Upgrade T2->T3",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
             ["Shield Upgrade"] = true,
        },
        Priority = 3600,
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
            { Tags.STRUCTURE * Tags.SHIELD * Tags.TECH2, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoStorageLevel", { 040,0 } },
            { "MoreThanUnitsInArmy", { 0, Tags.LAND_FACTORY * Tags.TECH3, false} },
        },
        EnergyTrendCanCoverMaintenanceConsumption = true,
        AllowEcoStorageDrain = false,
    },

}
