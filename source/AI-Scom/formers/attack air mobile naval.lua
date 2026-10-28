local ANTI_NAVAL_AIR = Tags.TORPEDO_BOMBER + Tags.ANTI_NAVAL + Tags.ANTI_NAVY + Tags.SCFA_ANTINAVY

AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F123 Air Anti-Naval Aircraft Attack",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Air Naval Platoons"] = true,
        },
        Priority = 9519,
        FormNumInstances = 20,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planBomberAttack",
        NeedUnits = {
            { Tags.MOBILE * Tags.AIR * ANTI_NAVAL_AIR * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 5, 0 },
        },
        FormerConditions = {
            { "MoreThanEnemyUnits", { 0, Tags.MOBILE * Tags.NAVAL } },
        },
        AIPlanData = {
            TargetSearchRadius = 2048,
            GetTargetsFromBase = false,
            AggressiveMove = false,
            AttackEnemyStrength = 100,
            PathEnemyStrength = 0,
            IgnoreLandEmergencyTargets = true,
            TargetLayer = "WaterSurface",
            RequireMatchingTarget = true,
            RequireShootableTarget = true,
            SelectFarthestTargetFromEnemyBase = false,
            AvoidDuplicateTargets = true,
            TargetSearchCategory = Tags.NAVAL,
            TargetPriority = {
                Tags.BATTLESHIP,
                Tags.DESTROYER,
                Tags.SUBMARINE,
                Tags.NAVAL_FACTORY,
                Tags.NAVAL,
            },
            WeaponTargetPriority = {
                Tags.BATTLESHIP,
                Tags.DESTROYER,
                Tags.SUBMARINE,
                Tags.NAVAL_FACTORY,
                Tags.NAVAL,
            },
        },
    },

}
