
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T123 Shield Recharge",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = false,
        },
        RunWithStrategyName = {
             ["Shield Recharge"] = true,
        },
        Priority = 3800,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planRechargeShieldStructures",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER, 1, 10, 1 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoStorageLevel", { 001,080 } },
        },
        --AssistBuildUnits
        --AssistUpgradeUnits
        RechargeShields = {
            Tags.STRUCTURE * Tags.SHIELD * Tags.TECH3,
            Tags.STRUCTURE * Tags.SHIELD,
        },
        AllowEcoStorageDrain = false,
    },

}
