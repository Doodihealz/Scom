
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "A12 Extractor Upgrade",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Alloy upgrade"] = true,
       },
        Priority = 3350,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planAlloyExtractorUpgrade",
        PrioritizeHomeExtractorUpgrades = true,
        HomeExtractorUpgradeCount = 4,
        NeedUpgradeableUnit = {
            -- What units do we need for this platoon ?
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION * ( Tags.TECH1 + Tags.TECH2 ), 1, 1, 0 },
        },
        ExtractorUpgradeMinimumTrend = {
            0,
            0,
        },
        ExtractorUpgradeMinimumStorageLevel = {
            0,
            20,
        },
        AllowEcoStorageDrain = true,
    },

}
