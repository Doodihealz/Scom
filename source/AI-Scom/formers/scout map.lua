
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "F123 Scout Map",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Factory Land Scouts"] = true,
            ["Factory Air Scouts"] = true,
        },
        Priority = 9800,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planScoutMap",
        NeedUnits = {
            -- What units do we need to form this platoon ?
            --{ Tags.MOBILE * (Tags.LAND + Tags.AIR) * Tags.SCOUT, 1, 4, 0}
            { Tags.MOBILE * (Tags.AIR + Tags.LAND) * Tags.SCOUT, 1, 6, 0}
        },
        FormerConditions = {
            -- When do we want to build this ?
            -- we scout always
        },
    },

}
