local NAVAL_COMBAT = Tags.MOBILE * Tags.NAVAL * (Tags.ANTI_SURFACE + Tags.ANTI_AIR + Tags.ANTI_NAVAL + Tags.ANTI_NAVY + Tags.SCFA_ANTINAVY + Tags.DIRECT_FIRE + Tags.ARTILLERY) - Tags.ENGINEER - Tags.SCOUT

AIFormers = {
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Naval Panic Counter",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Naval Naval Panic"] = true,
        },
        Priority = 9320,
        FormNumInstances = 100,
        PanicProduction = true,
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = true,
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.NAVAL_FACTORY * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        WantUnits = {
            NAVAL_COMBAT * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3),
        },
        FormerConditions = {
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.NAVAL_FACTORY } },
        },
        SelectHighestTechBuildable = true,
        AllowEcoStorageDrain = true,
        SequentialTemplateBuild = false,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B123 Factory Naval Mobile Area Deficit",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Naval Mobile"] = true,
        },
        Priority = 6700,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = true,
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.NAVAL_FACTORY * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 1, 0 },
        },
        WantUnits = {
            NAVAL_COMBAT * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3),
        },
        FormerConditions = {
            { "NavalAreaNeedsMobileUnits", {} },
            { "NavalAreaWithLeastUnits", {} },
            { "MoreThanIdleFactoriesAssignedToBase", { 0, Tags.NAVAL_FACTORY } },
        },
        SelectHighestTechBuildable = true,
        AllowEcoStorageDrain = true,
        SequentialTemplateBuild = false,
    },
}
