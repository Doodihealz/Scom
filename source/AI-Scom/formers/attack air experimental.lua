AIFormers = {
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F4 Air Experimental Attack",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Air Experimentals"] = true,
        },
        Priority = 9650,
        FormNumInstances = 100,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planBomberAttack",
        NeedUnits = {
            { Tags.MOBILE * Tags.AIR * Tags.TECH4, 1, 1, 0 }
        },
        FormerConditions = {
            { "MoreThanEnemyUnits", { 0, Tags.ALL_UNITS - Tags.AIR } },
        },
        AIPlanData = {
            TargetSearchRadius = 2048,
            GetTargetsFromBase = false,
            AggressiveMove = true,
            AttackEnemyStrength = 70,
            IgnoreLandEmergencyTargets = false,
            SelectFarthestTargetFromEnemyBase = false,
            AvoidDuplicateTargets = true,
            TargetSearchCategory = Tags.STRUCTURE,
            TargetPriority = {
                Tags.STRUCTURE * Tags.TECH4 * Tags.ECONOMIC,
                Tags.STRUCTURE * Tags.TECH4 * Tags.SHIELD,
                Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH3,
                Tags.STRUCTURE * Tags.TECH4,
                Tags.FACTORY * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION * Tags.TECH3,
                Tags.STRUCTURE,
                Tags.ALL_UNITS,
            },
        }
    },
}
