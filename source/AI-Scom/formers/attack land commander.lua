
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F0 Commander Attack",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Land Commander"] = true,
        },
        Priority = 9900,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planLandSingleAttack",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.COMMAND - Tags.TECH4, 1, 1, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanUnitsInArmyAtBase", { 0, Tags.MOBILE * Tags.LAND * Tags.ENGINEER - Tags.COMMAND } },
        },
        AIPlanData = {
            AssistProductionWhenIdle = true,
            -- TargetSearchRadius for new targets.
            TargetSearchRadius = 1024,
            -- get targets from base position (true) or platoon position (false)
            GetTargetsFromBase = true,
            -- if true, the unit will attack everything while moving to the target.
            AggressiveMove = true,
            -- compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AttackEnemyStrength = 85,
            ContinueEnemyStrength = 100,
            -- only find targets matching these Tags.
            TargetSearchCategory = (Tags.MOBILE + Tags.ALLOYS_EXTRACTION + Tags.ENERGY_PRODUCTION + Tags.FACTORY) - Tags.AIR - Tags.SCOUT,
            -- move to these targets first
            TargetPriority = {
                Tags.ALL_UNITS,
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
