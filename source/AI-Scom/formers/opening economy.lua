AIFormers = {

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "P1 Opening Engineer minimum 4",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Opening Economy Focus"] = true,
        },
        Priority = 8890,
        FormNumInstances = 2,
        OpeningEconomyProduction = true,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildInFactory",
        NeedFactory = {
            { Tags.LAND_FACTORY * Tags.TECH1, 1, 2, 0 },
        },
        WantUnits = {
            Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1,
        },
        FormerConditions = {
            { "IsStrategyActive", { "OpeningEconomyFocus" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
            { "LessThanUnitsInArmy", { 4, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, true } },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Opening Alloy Expansion",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Opening Economy Focus"] = true,
        },
        Priority = 8880,
        FormNumInstances = 1,
        InvestmentType = "OpeningAlloyBuilding",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planEngineerCapAlloySpot",
        AIPlanData = {
            SearchInnerRing = 0,
            SearchOuterRing = 1500,
            MaxCap = 6,
        },
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 2, 1 },
        },
        FormerConditions = {
            { "IsStrategyActive", { "OpeningEconomyFocus" } },
            { "IsStrategyActive", { "MarkerNavigationGridPresent" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
            { "MoreThanUnitsInArmy", { 2, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, false } },
            { "CanBuildOnAlloySpotInRange", { 0, 1500 } },
        },
        WantStructures = {
            Tags.ALLOYS_EXTRACTION * Tags.TECH1,
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "B1 Opening Organic Energy",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Opening Economy Focus"] = true,
        },
        Priority = 8870,
        FormNumInstances = 1,
        InvestmentType = "OpeningEnergyBuild",
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planBuildWithEngineer",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 0 },
        },
        FormerConditions = {
            { "IsStrategyActive", { "OpeningEconomyFocus" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
            { "MoreThanUnitsInArmy", { 1, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, false } },
            { "LessThanUnitsInArmy", { 4, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1, true } },
            { "LessThanUnitsBeingBuilt", { 1, Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1 } },
        },
        WantStructures = {
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
            Tags.STRUCTURE * Tags.ENERGY_PRODUCTION * Tags.TECH1,
        },
        WantStructuresSpacing = 2,
        AdjacentToStructure = {
            Tags.LAND_FACTORY,
        },
        AvoidStructureWithinDistance = {
            { Tags.STRUCTURE * Tags.ENERGY_PRODUCTION, 2 },
            { Tags.STRUCTURE * Tags.ALLOYS_EXTRACTION, 2 },
        },
        AllowEcoStorageDrain = true,
    },

    {
        DebugPlatoon = false,
        DebugManager = false,
        FormerName = "K1 Opening Reclaim Resources",
        AIdifficulty = {
            easy = false,
            medium = false,
            hard = true,
        },
        RunWithStrategyName = {
            ["Opening Economy Focus"] = true,
        },
        Priority = 8860,
        FormNumInstances = 1,
        RunOnBaseType = {
            ["MAIN"] = true,
            ["EXPANSION"] = false,
            ["OUTPOST"] = false,
            ["NAVAL"] = false,
        },
        AIPlan = "planReclaimMap",
        NeedMobileBuilder = {
            { Tags.MOBILE * Tags.ENGINEER * Tags.TECH1, 1, 1, 1 },
        },
        FormerConditions = {
            { "IsStrategyActive", { "OpeningEconomyFocus" } },
            { "BlockIfStrategyActive", { "EnemyInLandPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInAirPanicZone" } },
            { "BlockIfStrategyActive", { "EnemyInNavalPanicZone" } },
            { "MoreThanUnitsInArmy", { 3, Tags.MOBILE * Tags.LAND * Tags.ENGINEER * Tags.TECH1, false } },
            { "HasReclaimablePropsOnMap", {} },
        },
        AllowEcoStorageDrain = true,
    },

}
