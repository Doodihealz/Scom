
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F123 Air Primary",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Air Primary Platoon"] = true,
        },
        Priority = 9630,
        FormNumInstances = 1, -- don't use more than one platoon here!
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planAirAttackPrimary",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.AIR * Tags.ANTI_AIR - Tags.SCOUT - Tags.TECH4, 6, 1000, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
        },
        AIPlanData = {
            -- TargetSearchRadius for new targets.
            TargetSearchRadius = 2048,
            -- get targets from base position (true) or platoon position (false)
            GetTargetsFromBase = true,
            -- if true, the unit will attack everything while moving to the target.
            -- Todo
            AggressiveMove = false, -- Keep route changes under platoon control; air micro selects engagements.
            -- compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AttackEnemyStrength = 70,
            MinimumEmergencyTargetPriority = 60,
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
        FormerName = "F123 Air Sup ratio",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Attack Air Primary Platoon"] = true,
        },
        Priority = 9530,
        FormNumInstances = 20,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planSupportAirPrimaryPlatoon",
        AIPlanData = {
            MaximumPrimaryPlatoonUnitRatio = 0.5,
            JoinPrimaryOnAirEmergency = true,
        },
        NeedUnits = {
            -- What units do we need to form this platoon ?
            { Tags.MOBILE * Tags.AIR * Tags.ANTI_AIR - Tags.SCOUT - Tags.TECH4, 1, 500, 0 }
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "AtLeastPrimaryPlatoonUnitRatioAtBase", { 0.25, Tags.MOBILE * Tags.AIR * Tags.ANTI_AIR - Tags.SCOUT - Tags.TECH4, false, "PrimaryAirPlatoon" } },
            { "LessThanSupportPlatoonUnitRatioToPrimaryPlatoon", { 1.0, "F123 Air Sup ratio", "PrimaryAirPlatoon" } },
        },
    },
}
