AIFormers = {
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F4 Land Experimental Attack",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Land Experimentals"] = true,
        },
        Priority = 9650,
        FormNumInstances = 100,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planLandAttack",
        SkipBusyProductionUnits = true,
        NeedUnits = {
            { Tags.MOBILE * Tags.LAND * Tags.TECH4, 1, 1, 0 }
        },
        FormerConditions = {
            { "MoreThanEnemyUnits", { 0, Tags.ALL_UNITS - Tags.AIR } },
        },
        AIPlanData = {
            TargetSearchRadius = 2048,
            GetTargetsFromBase = false,
            AggressiveMove = true,
            AttackEnemyStrength = 80,
            IgnoreLandEmergencyTargets = true,
            SelectFarthestTargetFromEnemyBase = false,
            AvoidDuplicateTargets = true,
            TargetSearchCategory = Tags.ALL_UNITS - Tags.AIR,
            TargetPriority = {
                Tags.STRUCTURE * Tags.TECH4 * Tags.ECONOMIC,
                Tags.STRUCTURE * Tags.TECH4 * Tags.SHIELD,
                Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION * Tags.TECH3,
                Tags.FACTORY * Tags.TECH3,
                Tags.STRUCTURE * Tags.TECH4,
                Tags.ALL_UNITS - Tags.AIR,
            },
        }
    },
}
