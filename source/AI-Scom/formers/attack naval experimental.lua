AIFormers = {
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F4 Naval Experimental Attack",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Naval Experimentals"] = true,
        },
        Priority = 9650,
        FormNumInstances = 100,
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = true,
        },
        AIPlan = "planNavalAttack",
        UseNavalAreaUnits = true,
        NeedUnits = {
            { Tags.MOBILE * Tags.NAVAL * Tags.TECH4, 1, 1, 0 },
        },
        FormerConditions = {
            { "MoreThanEnemyUnits", { 0, Tags.ALL_UNITS - Tags.AIR } },
        },
        AIPlanData = {
            TargetSearchRadius = 2048,
            GetTargetsFromBase = false,
            AggressiveMove = true,
            AttackEnemyStrength = 70,
            AvoidDuplicateTargets = true,
            TargetSearchCategory = Tags.NAVAL,
            TargetPriority = {
                Tags.TECH4,
                Tags.TECH3,
                Tags.ALL_UNITS,
            },
        },
    },
}
