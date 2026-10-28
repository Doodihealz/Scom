
AIFormers = {

    -- ============= --
    --    Recover    --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B01 Cap Alloys Recover",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Base Recover"] = true,
        },
        Priority = 8416,
        FormNumInstances = 1,
        InvestmentType = "AlloyBuilding",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planEngineerCapAlloySpot",
        AIPlanData = {
            SearchInnerRing = 0,
            SearchOuterRing = 30,
            MaxCap = 1
        },
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * (Tags.ENGINEER + Tags.COMMAND), 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "LessThanUnitsInArmyAtBase", { 1, Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, false} },
            { "LessThanUnitsBeingBuiltAtBase", { 1, Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION} },
            { "CanBuildOnAlloySpotInRange", { 0 , 30 } },
        },
        WantStructures = {
            Tags.ALLOYS_EXTRACTION * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    -- ============= --
    --    TECH 1     --
    -- ============= --

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B0123 Cap Alloys Range 30",
        AIdifficulty = {
            easy = true,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Alloy capture EASY"] = true,
        },
        Priority = 8511,
        FormNumInstances = 1,
        InvestmentType = "AlloyBuilding",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = true,
            ["OUTPOST"] = true,
            ["NAVAL"] = false
        },
        AIPlan = "planEngineerCapAlloySpot",
        AIPlanData = {
            SearchInnerRing = 0,
            SearchOuterRing = 30,
            MaxCap = 4
        },
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH2, 1, 1, 0 },
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH3, 1, 1, 0 },
            { Tags.MOBILE * Tags.COMMAND, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "CanBuildOnAlloySpotInRange", { 0 , 30 } },
            { "MoreThanUnitsInArmy", { 0, Tags.STRUCTURE * Tags.FACTORY, false } },
        },
        WantStructures = {
            Tags.ALLOYS_EXTRACTION * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Cap Alloys Early Parallel Range 30-1500",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Alloy capture HARD"] = true,
        },
        Priority = 8014,
        FormNumInstances = 1,
        InvestmentType = "RichMapAlloyBuilding",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planEngineerCapAlloySpot",
        AIPlanData = {
            SearchInnerRing = 30,
            SearchOuterRing = 1500,
            MaxCap = 4,
        },
        NeedMobileBuilder = {
            -- Use one free engineer; the remaining engineers may already be working at the base.
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- Start outside expansion before the last local spot is finished, without duplicating the rich-map helper.
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
            { "MoreThanUnitsInArmy", { 1, Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, false } },
            { "MoreThanUnitsInArmy", { 0, Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, false } },
            { "LessThanAlloyExtractorFairSharePercent", { 75 } },
            { Import("AI/mods/AI-Scom/RushBalance.lua").EarlyExpansionRequired, {} },
            { "CanBuildOnAlloySpotInRange", { 30, 1500 } },
        },
        WantStructures = {
            Tags.ALLOYS_EXTRACTION * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },
    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Cap Alloys Rich Map Range 30-1500",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Alloy capture MEDIUM"] = true,
            ["Alloy capture HARD"] = true,
        },
        Priority = 8013,
        FormNumInstances = 1,
        InvestmentType = "RichMapAlloyBuilding",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planEngineerCapAlloySpot",
        AIPlanData = {
            SearchInnerRing = 30,
            SearchOuterRing = 1500,
        },
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
            { "MoreThanAlloyExtractorFairShareCount", { 40 } },
            { "LessThanAlloyExtractorFairSharePercent", { 75 } },
            { "CanNotBuildOnAlloySpotInRange", { 0 , 30 } },
            { "CanBuildOnAlloySpotInRange", { 30 , 1500 } },
        },
        WantStructures = {
            Tags.ALLOYS_EXTRACTION * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Cap Alloys Range 30-1500",
        AIdifficulty = {
            easy = false,
            medium = true,
            hard = true,
        },
        RunWithStrategyName = {
            ["Alloy capture MEDIUM"] = true,
            ["Alloy capture HARD"] = true,
        },
        Priority = 8012,
        FormNumInstances = 1,
        InvestmentType = "AlloyBuilding",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false
        },
        AIPlan = "planEngineerCapAlloySpot",
        AIPlanData = {
            SearchInnerRing = 30,
            SearchOuterRing = 1500,
        },
        NeedMobileBuilder = {
            -- What units do we need for this platoon ?
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 6, 1 },
        },
        FormerConditions = {
            -- When do we want to build this ?
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
            { "CanNotBuildOnAlloySpotInRange", { 0 , 30 } },
            { "CanBuildOnAlloySpotInRange", { 30 , 1500 } },
        },
        WantStructures = {
            Tags.ALLOYS_EXTRACTION * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },



}
