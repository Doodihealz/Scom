
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F123 Land Alloy Hunter",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Land Small Platoons"] = true,
        },
        Priority = 9621,
        FormNumInstances = 6,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planLandAttack",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT - Tags.TECH4, 3, 3, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEnemyUnits", { 0 , Tags.ALLOYS_EXTRACTION + Tags.ENERGY_PRODUCTION + Tags.FACTORY } },
            { "MoreThanUnitsInArmy", { 20, Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT - Tags.TECH4, false } },
            { "AtLeastSupportPlatoonUnitRatioToPrimaryPlatoon", { 0.5, "F123 Land Sup ratio" } },
            { "LessThanSupportPlatoonUnitRatioToPrimaryPlatoon", { 0.5, "F123 Land Alloy Hunter" } },
        },
        AIPlanData = {
            -- TargetSearchRadius for new targets.
            TargetSearchRadius = 1024,
            -- get targets from base position (true) or platoon position (false)
            GetTargetsFromBase = false,
            -- if true, the unit will attack everything while moving to the target.
            AggressiveMove = false,
            -- compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AttackEnemyStrength = 70,
            -- prefer paths without enemy threat while moving to the target.
            PathEnemyStrength = 0,
            -- Defend nearby friendly extractors without responding to commander or base emergencies.
            IgnoreLandEmergencyTargets = false,
            DefendNearbyAlloyExtractors = true,
            AvoidDuplicateTargets = true,
            SelectFarthestTargetFromEnemyBase = false,
            RequireMatchingTarget = true,
            -- only find targets matching these Tags.
            TargetSearchCategory = Tags.ALLOYS_EXTRACTION + Tags.ENERGY_PRODUCTION + Tags.FACTORY + Tags.ENGINEER,
            -- move to these targets first
            TargetPriority = {
                Tags.ENERGY_PRODUCTION * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION * Tags.TECH3,
                Tags.FACTORY * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION,
                Tags.ENERGY_PRODUCTION,
                Tags.ENGINEER,
                Tags.FACTORY,
            },
            -- override weapon target priorities
            WeaponTargetPriority = {
                Tags.COMMAND,
                Tags.ANTI_AIR,
                Tags.ALL_UNITS,
            }
        }
    },

}
