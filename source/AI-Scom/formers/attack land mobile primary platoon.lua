
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F123 Land Primary",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Land Primary Platoon"] = true,
        },
        Priority = 9630,
        FormNumInstances = 1, -- don't use more than one platoon here!
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planLandAttackPrimary",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT - Tags.TECH4, 6, 1000, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
        },
        AIPlanData = {
            -- TargetSearchRadius for new targets.
            TargetSearchRadius = 2048,
            -- Target categories for new targets.
            TargetSearchCategory = Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.SCOUT,
            -- get targets from base position (true) or platoon position (false)
            GetTargetsFromBase = true,
            -- Keep attacking a closer reachable commander instead of returning toward a base-selected target.
            PreferCommanderWhenCloserToPlatoon = true,
            -- if true, the unit will attack everything while moving to the target.
            -- Todo
            AggressiveMove = false,
            -- compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AttackEnemyStrength = 80,
            MinimumEmergencyTargetPriority = 50,
            IgnoreLandEmergencyTargets = true,
            -- override weapon target priorities
            -- Todo
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
        FormerName = "F123 Land Sup ratio",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Land Primary Platoon"] = true,
        },
        Priority = 9530,
        FormNumInstances = 20,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planSupportLandPrimaryPlatoon",
        AIPlanData = {
            JoinPrimaryOnLandEmergency = true,
        },
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT - Tags.TECH4, 1, 500, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "AtLeastPrimaryPlatoonUnitRatioAtBase", { 0.5, Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT - Tags.TECH4, false, "PrimaryLandPlatoon", 30 } },
        },
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F123 Land Panic Response",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Land Primary Platoon"] = true,
        },
        Priority = 9640,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planSupportLandPrimaryPlatoon",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.LAND - Tags.ENGINEER - Tags.COMMAND - Tags.SCOUT - Tags.TECH4, 1, 500, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LandBasePanicResponseRequired", {} },
        },
        AIPlanData = {
            DefendBase = true,
            RespondToAlliedBasePanic = true,
            ReturnToBaseDisbandDistance = 60,
            MinimumEmergencyTargetPriority = 50,
        },
    },

}
