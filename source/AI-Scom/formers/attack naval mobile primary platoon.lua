AIFormers = {
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F123 Naval Primary",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Naval Primary Platoon"] = true,
        },
        Priority = 9630,
        FormNumInstances = 100,
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = true,
        },
        AIPlan = "planNavalAttackPrimary",
        UseNavalAreaUnits = true,
        NeedUnits = {
            { Tags.MOBILE * Tags.NAVAL - Tags.TECH4, 6, 12, 0 },
        },
        FormerConditions = {
            { "NavalAreaHasNoPrimaryPlatoon", {} },
        },
        AIPlanData = {
            TargetSearchRadius = 2048,
            GetTargetsFromBase = true,
            AggressiveMove = true,
            AttackEnemyStrength = 70,
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
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F123 Naval Support Area",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Naval Primary Platoon"] = true,
        },
        Priority = 9530,
        FormNumInstances = 100,
        RunOnBaseType = {
            ["MAIN"] = false,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = true,
        },
        AIPlan = "planSupportNavalPrimaryPlatoon",
        UseNavalAreaUnits = true,
        NeedUnits = {
            { Tags.MOBILE * Tags.NAVAL - Tags.TECH4, 1, 6, 0 },
        },
        FormerConditions = {
            { "NavalAreaHasPrimaryPlatoon", {} },
            { "LessThanNavalSupportPlatoonUnitRatioToPrimaryPlatoon", { 0.5, "F123 Naval Support Area" } },
        },
        AIPlanData = {
            MaximumPrimaryPlatoonUnitRatio = 0.5,
        },
    },
}
