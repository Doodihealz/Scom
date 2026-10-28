AIFormers = {
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F123 Naval Attack",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Naval Small Platoons"] = true,
        },
        Priority = 9520,
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
            { Tags.MOBILE * Tags.NAVAL - Tags.TECH4, 3, 5, 0 },
        },
        FormerConditions = {
            { "AtLeastNavalSupportPlatoonUnitRatioToPrimaryPlatoon", { 0.5, "F123 Naval Support Area" } },
        },
        AIPlanData = {
            TargetSearchRadius = 2048,
            GetTargetsFromBase = false,
            AggressiveMove = true,
            AttackEnemyStrength = 70,
            AvoidDuplicateTargets = true,
            TargetSearchCategory = Tags.ALL_UNITS - Tags.AIR,
            TargetPriority = {
                Tags.MOBILE * Tags.NAVAL,
                Tags.NAVAL_FACTORY,
                Tags.ALLOYS_EXTRACTION,
                Tags.ALL_UNITS,
            },
            WeaponTargetPriority = {
                Tags.COMMAND,
                Tags.NAVAL,
                Tags.ALL_UNITS,
            },
        },
    },
}
