
local ANTI_NAVAL_AIR = Tags.TORPEDO_BOMBER + Tags.ANTI_NAVAL + Tags.ANTI_NAVY + Tags.SCFA_ANTINAVY
local LAND_BOMBERS = Tags.BOMBER - ANTI_NAVAL_AIR
local LAND_GUNSHIPS = Tags.GUNSHIP * Tags.ANTI_SURFACE - ANTI_NAVAL_AIR
local ECO_TARGETS = Tags.ALLOYS_EXTRACTION + Tags.ENERGY_PRODUCTION + Tags.FACTORY + Tags.ENGINEER

AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F123 Air Bomber Eco Attack Alloy",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Air Small Platoons"] = true,
        },
        Priority = 9517,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBomberAttack",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.AIR * LAND_BOMBERS * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 5, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEnemyUnits", { 0, ECO_TARGETS } },
        },
        AIPlanData = {
            -- TargetSearchRadius for new targets.
            TargetSearchRadius = 2048,
            -- get targets from base position (true) or platoon position (false)
            GetTargetsFromBase = false,
            -- if true, the unit will attack everything while moving to the target.
            AggressiveMove = false,
            -- compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AttackEnemyStrength = 200,
            -- prefer paths without enemy threat while moving to the target.
            PathEnemyStrength = 0,
            IgnoreLandEmergencyTargets = true,
            SelectFarthestTargetFromEnemyBase = true,
            AvoidDuplicateTargets = true,
            RequireMatchingTarget = true,
            -- only find targets matching these Tags.
            TargetSearchCategory = ECO_TARGETS,
            -- move to these targets first
            TargetPriority = {
                Tags.ENERGY_PRODUCTION * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION * Tags.TECH3,
                Tags.FACTORY * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION,
                Tags.ENERGY_PRODUCTION,
                Tags.FACTORY,
                Tags.ENGINEER,
            },
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
        FormerName = "F3 Air Gunship Economy Attack",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Air Small Platoons"] = true,
        },
        Priority = 9515,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBomberAttack",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.AIR * LAND_GUNSHIPS * Tags.TECH3, 2, 3, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEnemyUnits", { 0, ECO_TARGETS } },
        },
        AIPlanData = {
            -- TargetSearchRadius for new targets.
            TargetSearchRadius = 2048,
            -- get targets from base position (true) or platoon position (false)
            GetTargetsFromBase = false,
            -- if true, the unit will attack everything while moving to the target.
            AggressiveMove = true,
            -- compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AttackEnemyStrength = 200,
            IgnoreLandEmergencyTargets = false,
            SelectFarthestTargetFromEnemyBase = true,
            AvoidDuplicateTargets = true,
            RequireMatchingTarget = true,
            -- only find targets matching these Tags.
            TargetSearchCategory = ECO_TARGETS,
            -- move to these targets first
            TargetPriority = {
                Tags.ENERGY_PRODUCTION * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION * Tags.TECH3,
                Tags.FACTORY * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION,
                Tags.ENERGY_PRODUCTION,
                Tags.FACTORY,
                Tags.ENGINEER,
            },
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
        FormerName = "F123 Air Bomber Eco Attack Equal",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Air Small Platoons"] = true,
        },
        Priority = 9516,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBomberAttack",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.AIR * LAND_BOMBERS * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 5, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEnemyUnits", { 0, ECO_TARGETS } },
        },
        AIPlanData = {
            -- TargetSearchRadius for new targets.
            TargetSearchRadius = 2048,
            -- get targets from base position (true) or platoon position (false)
            GetTargetsFromBase = false,
            -- if true, the unit will attack everything while moving to the target.
            AggressiveMove = false,
            -- compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AttackEnemyStrength = 200,
            -- prefer paths without enemy threat while moving to the target.
            PathEnemyStrength = 0,
            IgnoreLandEmergencyTargets = true,
            SelectFarthestTargetFromEnemyBase = true,
            AvoidDuplicateTargets = true,
            RequireMatchingTarget = true,
            -- only find targets matching these Tags.
            TargetSearchCategory = ECO_TARGETS,
            -- move to these targets first
            TargetPriority = {
                Tags.ENERGY_PRODUCTION * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION * Tags.TECH3,
                Tags.FACTORY * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION + Tags.ENERGY_PRODUCTION + Tags.FACTORY + Tags.ENGINEER,
            },
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
        FormerName = "F2 Air Gunship Economy Attack",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Air Small Platoons"] = true,
        },
        Priority = 9513,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBomberAttack",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.AIR * LAND_GUNSHIPS * Tags.TECH2, 2, 5, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEnemyUnits", { 0, ECO_TARGETS } },
        },
        AIPlanData = {
            -- TargetSearchRadius for new targets.
            TargetSearchRadius = 2048,
            -- get targets from base position (true) or platoon position (false)
            GetTargetsFromBase = false,
            -- if true, the unit will attack everything while moving to the target.
            AggressiveMove = true,
            -- compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AttackEnemyStrength = 200,
            IgnoreLandEmergencyTargets = false,
            PreferCommanderInEngagementRange = true,
            SelectFarthestTargetFromEnemyBase = true,
            AvoidDuplicateTargets = true,
            RequireMatchingTarget = true,
            -- only find targets matching these Tags.
            TargetSearchCategory = ECO_TARGETS,
            -- move to these targets first
            TargetPriority = {
                Tags.ENERGY_PRODUCTION * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION * Tags.TECH3,
                Tags.FACTORY * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION,
                Tags.ENERGY_PRODUCTION,
                Tags.FACTORY,
                Tags.ENGINEER,
            },
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
        FormerName = "F1 Air Gunship Economy Attack",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Air Small Platoons"] = true,
        },
        Priority = 9511,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planBomberAttack",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.AIR * LAND_GUNSHIPS * Tags.TECH1, 2, 5, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEnemyUnits", { 0, ECO_TARGETS } },
        },
        AIPlanData = {
            -- TargetSearchRadius for new targets.
            TargetSearchRadius = 2048,
            -- get targets from base position (true) or platoon position (false)
            GetTargetsFromBase = false,
            -- if true, the unit will attack everything while moving to the target.
            AggressiveMove = true,
            -- compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AttackEnemyStrength = 200,
            IgnoreLandEmergencyTargets = false,
            SelectFarthestTargetFromEnemyBase = true,
            AvoidDuplicateTargets = true,
            RequireMatchingTarget = true,
            -- only find targets matching these Tags.
            TargetSearchCategory = ECO_TARGETS,
            -- move to these targets first
            TargetPriority = {
                Tags.ENERGY_PRODUCTION * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION * Tags.TECH3,
                Tags.FACTORY * Tags.TECH3,
                Tags.ALLOYS_EXTRACTION,
                Tags.ENERGY_PRODUCTION,
                Tags.FACTORY,
                Tags.ENGINEER,
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
