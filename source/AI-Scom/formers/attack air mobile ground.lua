
local ANTI_NAVAL_AIR = Tags.TORPEDO_BOMBER + Tags.ANTI_NAVAL + Tags.ANTI_NAVY + Tags.SCFA_ANTINAVY
local LAND_BOMBERS = Tags.BOMBER - ANTI_NAVAL_AIR
local LAND_GUNSHIPS = Tags.GUNSHIP * Tags.ANTI_SURFACE - ANTI_NAVAL_AIR

AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F123 Air Bomber Combat Attack",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = false,
        },
        RunWithStrategyName = {
            ["Attack Air Ground Combat Platoons"] = true,
            ["Attack Air Small Platoons"] = true,
        },
        Priority = 9518,
        FormNumInstances = 100,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBomberAttack",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.AIR * LAND_BOMBERS * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 3, 1000, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEnemyUnits", { 0, Tags.ALL_UNITS - Tags.AIR } },
        },
        AIPlanData = {
            -- TargetSearchRadius for new targets.
            TargetSearchRadius = 2048,
            -- get targets from base position (true) or platoon position (false)
            GetTargetsFromBase = false,
            -- if true, the unit will attack everything while moving to the target.
            AggressiveMove = true,
            -- compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AttackEnemyStrength = 70,
            IgnoreLandEmergencyTargets = false,
            SelectFarthestTargetFromEnemyBase = false,
            AvoidDuplicateTargets = false,
            -- only find targets matching these Tags.
            TargetSearchCategory = Tags.ALL_UNITS - Tags.AIR,
            -- override weapon target priorities
            WeaponTargetPriority = {
                Tags.COMMAND,
                Tags.ANTI_AIR,
                Tags.ALL_UNITS,
            }
        }
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F123 Air Gunship Combat Attack",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Air Ground Combat Platoons"] = true,
            ["Attack Air Small Platoons"] = true,
        },
        Priority = 9505,
        FormNumInstances = 100,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBomberAttack",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.AIR * LAND_GUNSHIPS * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 2, 5, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEnemyUnits", { 0, Tags.ALL_UNITS - Tags.AIR } },
        },
        AIPlanData = {
            -- TargetSearchRadius for new targets.
            TargetSearchRadius = 2048,
            -- get targets from base position (true) or platoon position (false)
            GetTargetsFromBase = false,
            -- if true, the unit will attack everything while moving to the target.
            AggressiveMove = true,
            -- compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AttackEnemyStrength = 70,
            IgnoreLandEmergencyTargets = false,
            SelectFarthestTargetFromEnemyBase = false,
            AvoidDuplicateTargets = false,
            -- only find targets matching these Tags.
            TargetSearchCategory = Tags.ALL_UNITS - Tags.AIR,
            -- override weapon target priorities
            WeaponTargetPriority = {
                Tags.COMMAND,
                Tags.ANTI_AIR,
                Tags.ALL_UNITS,
            }
        }
    },

}
