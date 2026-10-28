
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "A12 Extractor Upgrade Assist",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
             ["Alloy assist"] = true,
       },
        Priority = 5050,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planAssistBuilding",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "MoreThanEcoStorageLevel", { 0,20 } },
            { "MoreThanUnitsBeingUpgradedAtBase", { 0, Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION } },
        },
        AssistUpgradeUnits = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        -- AssistUpgradeUnits and the assist plan check the actual construction; no separate build list is required.
        MaintainAssistSurplus = true,
    },

}
