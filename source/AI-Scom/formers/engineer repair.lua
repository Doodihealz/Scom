
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "R123 Engineer Repair ECO",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Sanctuary Rush Engineer Repair"] = true,
       },
        Priority = 8030,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = true
        },
        AIPlan = "planRepairBuilding",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 2, 0 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        RepairStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION,
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "R123 Engineer Repair noECODrain",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Sanctuary Rush Engineer Repair"] = true,
       },
        Priority = 8020,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = true
        },
        AIPlan = "planRepairBuilding",
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * (Tags.TECH1 + Tags.TECH2 + Tags.TECH3), 1, 2, 1 },
        },
        FormerConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
        },
        RepairStructures = {
            Tags.STRUCTURE,
        },
        ResumeConstructionWithoutEconomyCheck = true,
        AllowEcoStorageDrain = false,
    },

}
