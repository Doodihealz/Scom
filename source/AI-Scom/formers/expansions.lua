
AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Expansion close",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
             ["Expansions close"] = true,
        },
        Priority = 6130,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planEstablishBaseExpansion",
        AIPlanData = {
            SearchInnerRing = 100,
            SearchOuterRing = 250,
            MinimumAlloy = 4,
            MaximumAlloy = false,
            MaximumEnemyThreat = 0,
        },
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "CanBuildExpansionInRange", { 100 , 250, 4, false } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = false,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Expansion far",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
             ["Expansions far"] = true,
        },
        Priority = 6120,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planEstablishBaseExpansion",
        AIPlanData = {
            SearchInnerRing = 250,
            SearchOuterRing = 500,
            MinimumAlloy = 4,
            MaximumAlloy = false,
            MaximumEnemyThreat = 0,
        },
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "CanNotBuildExpansionInRange", { 100 , 250, 4, false } },
            { "CanBuildExpansionInRange", { 250 , 500, 4, false } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = false,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "T1 Outpost",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
             ["Outposts"] = true,
        },
        Priority = 6110,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planEstablishBaseExpansion",
        AIPlanData = {
            SearchInnerRing = 100,
            SearchOuterRing = 500,
            MinimumAlloy = 2,
            MaximumAlloy = 3,
            MaximumEnemyThreat = 0,
        },
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 1 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "CanBuildExpansionInRange", { 100 , 500, 2, 3 } },
        },
        WantStructures = {
            Tags.LAND_FACTORY * Tags.TECH1,
        },
        WantStructuresSpacing = 3,
        AdjacentToStructure = {
            Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION,
        },
        AvoidStructureWithinDistance = {
            {Tags.STRUCTURE * Tags.FACTORY, 15}
        },
        AllowEcoStorageDrain = false,
    },


}
