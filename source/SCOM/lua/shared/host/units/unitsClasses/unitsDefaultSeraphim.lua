-- Virtual unitsDefaultSeraphim module for the true fourth faction.
-- It subclasses the stock Chosen behavior classes without modifying them.
local chosenDefaults = Import("host/units/unitsClasses/unitsDefaultChosen.lua")
local ChosenStructure = chosenDefaults.HostChosenStructure
local ChosenNavalStructure = chosenDefaults.HostChosenNavalStructure
local ChosenTechCentre = chosenDefaults.HostChosenTechCentre
local ChosenEngineeringStation = chosenDefaults.HostChosenEngineeringStation
local ChosenStorage = chosenDefaults.HostChosenStorage
local ChosenAirFactory = chosenDefaults.HostChosenAirFactory
local ChosenLandFactory = chosenDefaults.HostChosenLandFactory
local ChosenNavalFactory = chosenDefaults.HostChosenNavalFactory
local ChosenAlloyExtractor = chosenDefaults.HostChosenAlloyExtractor
local ChosenEnergyGenerator = chosenDefaults.HostChosenEnergyGenerator
local ChosenAirUnit = chosenDefaults.HostChosenAirUnit
local ChosenLandUnit = chosenDefaults.HostChosenLandUnit
local ChosenNavalUnit = chosenDefaults.HostChosenNavalUnit
local ChosenEngineer = chosenDefaults.HostChosenEngineer
local ChosenCommander = chosenDefaults.HostChosenCommander

HostSeraphimStructure = Class("SeraphimStructure", ChosenStructure)
local SeraphimStructure = HostSeraphimStructure
HostSeraphimNavalStructure = Class("SeraphimNavalStructure", ChosenNavalStructure)
local SeraphimNavalStructure = HostSeraphimNavalStructure
HostSeraphimTechCentre = Class("SeraphimTechCentre", ChosenTechCentre)
local SeraphimTechCentre = HostSeraphimTechCentre
HostSeraphimEngineeringStation = Class("SeraphimEngineeringStation", ChosenEngineeringStation)
local SeraphimEngineeringStation = HostSeraphimEngineeringStation
HostSeraphimStorage = Class("SeraphimStorage", ChosenStorage)
local SeraphimStorage = HostSeraphimStorage
HostSeraphimAirFactory = Class("SeraphimAirFactory", ChosenAirFactory)
local SeraphimAirFactory = HostSeraphimAirFactory
HostSeraphimLandFactory = Class("SeraphimLandFactory", ChosenLandFactory)
local SeraphimLandFactory = HostSeraphimLandFactory
HostSeraphimNavalFactory = Class("SeraphimNavalFactory", ChosenNavalFactory)
local SeraphimNavalFactory = HostSeraphimNavalFactory
HostSeraphimAlloyExtractor = Class("SeraphimAlloyExtractor", ChosenAlloyExtractor)
local SeraphimAlloyExtractor = HostSeraphimAlloyExtractor
HostSeraphimEnergyGenerator = Class("SeraphimEnergyGenerator", ChosenEnergyGenerator)
local SeraphimEnergyGenerator = HostSeraphimEnergyGenerator
HostSeraphimAirUnit = Class("SeraphimAirUnit", ChosenAirUnit)
local SeraphimAirUnit = HostSeraphimAirUnit
HostSeraphimLandUnit = Class("SeraphimLandUnit", ChosenLandUnit)
local SeraphimLandUnit = HostSeraphimLandUnit
HostSeraphimNavalUnit = Class("SeraphimNavalUnit", ChosenNavalUnit)
local SeraphimNavalUnit = HostSeraphimNavalUnit
HostSeraphimEngineer = Class("SeraphimEngineer", ChosenEngineer)
local SeraphimEngineer = HostSeraphimEngineer
HostSeraphimCommander = Class("SeraphimCommander", ChosenCommander)
local SeraphimCommander = HostSeraphimCommander

local SeraphimOrderTasks = Import("common/commonOrders.lua").OrderTasks
local SeraphimHostOrderManager = Import("host/managers/orders/hostOrderManager.lua")

local function PlaySeraphimAnimation(unit, animationKey, blendTime)
    local animations = unit.tp.visuals and unit.tp.visuals.animations
    local animation = animations and animations[animationKey]
    if animation and animation.id then
        Engine.PlayAnimation(unit.id, animation.id, blendTime or 0.1)
    end
end

function SeraphimNavalUnit:OnStopBeingBuilt()
    ChosenNavalUnit.OnStopBeingBuilt(self)
    PlaySeraphimAnimation(self, "open", 0)
end

function SeraphimLandFactory:OnStartBuildRoutine(targetUnit)
    ChosenLandFactory.OnStartBuildRoutine(self, targetUnit)
end

function SeraphimLandFactory:OnStopBuildRoutine(targetUnit)
    ChosenLandFactory.OnStopBuildRoutine(self, targetUnit)
end

function SeraphimAirFactory:OnStartBuildRoutine(targetUnit)
    ChosenAirFactory.OnStartBuildRoutine(self, targetUnit)
end

function SeraphimAirFactory:OnStopBuildRoutine(targetUnit)
    ChosenAirFactory.OnStopBuildRoutine(self, targetUnit)
end

function SeraphimNavalFactory:OnStartBuildRoutine(targetUnit)
    ChosenNavalFactory.OnStartBuildRoutine(self, targetUnit)
end

function SeraphimNavalFactory:OnStopBuildRoutine(targetUnit)
    ChosenNavalFactory.OnStopBuildRoutine(self, targetUnit)
end

-- Keep naval factory rollout on submerged cells.  The stock Factory class
-- always chooses rollOffPoints[1], which can point onto a shoreline.
local SeraphimNavalWaterMargin = 0.05

local function IsSeraphimNavalWaterPoint(position, waterLevel)
    local _, terrainHeight = Engine.SampleTerrainHeight(position)
    return terrainHeight < waterLevel - SeraphimNavalWaterMargin
end

local function GetSeraphimNavalRollOffPoints(factory)
    local _, hasWater = Engine.HasWater()
    if not hasWater then
        return nil, nil
    end

    local _, waterLevel = Engine.GetWaterLevel()
    local factoryPosition = factory:GetPosition()
    local construction = factory.tp and factory.tp.construction
    for _, rollOff in ipairs((construction and construction.rollOffPoints) or {}) do
        local offset = rollOff.offset
        if offset then
            local spawnPoint = EngineClasses.float3(
                factoryPosition.x + offset.x,
                waterLevel,
                factoryPosition.z + offset.z
            )
            local rallyPoint = EngineClasses.float3(
                factoryPosition.x + offset.x * 2,
                waterLevel,
                factoryPosition.z + offset.z * 2
            )
            if IsSeraphimNavalWaterPoint(spawnPoint, waterLevel)
                and IsSeraphimNavalWaterPoint(rallyPoint, waterLevel) then
                return spawnPoint, rallyPoint
            end
        end
    end

    return nil, nil
end

function SeraphimNavalFactory:GetConstructionSpawnPoint()
    local rollOffPoint = GetSeraphimNavalRollOffPoints(self)
    if rollOffPoint then
        return rollOffPoint
    end
    return ChosenNavalFactory.GetConstructionSpawnPoint(self)
end

function SeraphimNavalFactory:RollOffUnit(targetUnit)
    local source = self.unitBeingBuiltSource or self
    local _, fallbackRallyPoint = GetSeraphimNavalRollOffPoints(source)
    local rallyPoint = source.rallyPoint

    if rallyPoint then
        local _, hasWater = Engine.HasWater()
        if hasWater then
            local _, waterLevel = Engine.GetWaterLevel()
            if IsSeraphimNavalWaterPoint(rallyPoint, waterLevel) then
                rallyPoint = EngineClasses.float3(rallyPoint.x, waterLevel, rallyPoint.z)
            else
                rallyPoint = nil
            end
        else
            rallyPoint = nil
        end
    end

    rallyPoint = rallyPoint or fallbackRallyPoint
    if rallyPoint then
        SeraphimHostOrderManager.HostIssueOrder(SeraphimOrderTasks.MOVE, { targetUnit }, false, rallyPoint, nil)
    end
end


-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0


-- Supreme Commander Overhaul FA animation closure 1.0.1
local SCO_AnimationClosureLayers = Import("common/layers.lua")
local SCO_AnimationClosureTargetingLayer =
    SCO_AnimationClosureLayers.TargetingLayer
local SCO_AnimationClosureSentinelBase = -10000

local function SCO_AnimationClosureAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function SCO_AnimationClosureSample(unit, key, seconds)
    local animations = unit.tp.visuals and unit.tp.visuals.animations
    local animation = animations and animations[key]
    if not animation or not animation.id then
        error(unit.tpId .. " requires source animation " .. tostring(key))
    end
    Engine.PlayAnimation(
        unit.id,
        animation.id,
        SCO_AnimationClosureSentinelBase + seconds)
end

local function SCO_AnimationClosurePlayPacked(unit, config)
    local animations = unit.tp.visuals and unit.tp.visuals.animations
    local animation = animations and animations[config.packedAnimationKey]
    if not animation or not animation.id then
        error(unit.tpId .. " requires its source packed pose")
    end
    Engine.PlayAnimation(unit.id, animation.id, 0.1)
end

local function SCO_AnimationClosureSubmarineThread(unit, generation, opening)
    local config = unit.tp.additions and unit.tp.additions.faSubmarineHatch
    if not config then return end
    local elapsed = unit.scoFaSubmarineHatchSample
        or (opening and 0 or config.authoredDurationSeconds)
    if not opening then
        unit.scoFaSubmarineCannonReady = false
    end
    while SCO_AnimationClosureAlive(unit)
        and unit.scoFaSubmarineHatchGeneration == generation
        and ((opening and elapsed < config.authoredDurationSeconds)
            or (not opening and elapsed > 0))
    do
        SCO_AnimationClosureSample(unit, config.animationKey, elapsed)
        unit.scoFaSubmarineHatchSample = elapsed
        WaitTicks(1)
        local delta = Constants.TickTimeStep * config.authoredRate
        if opening then
            elapsed = math.min(config.authoredDurationSeconds, elapsed + delta)
        else
            elapsed = math.max(0, elapsed - delta)
        end
    end
    if not SCO_AnimationClosureAlive(unit)
        or unit.scoFaSubmarineHatchGeneration ~= generation
    then return end
    unit.scoFaSubmarineHatchSample = elapsed
    if opening then
        SCO_AnimationClosureSample(unit, config.animationKey, elapsed)
        unit.scoFaSubmarineCannonReady = true
    else
        SCO_AnimationClosurePlayPacked(unit, config)
    end
end

function SeraphimNavalUnit:SCO_SetSubmarineSurfaceState(surface)
    local config = self.tp.additions and self.tp.additions.faSubmarineHatch
    if not config or self.scoFaSubmarineSurface == surface then return end
    self.scoFaSubmarineSurface = surface
    self.scoFaSubmarineHatchGeneration =
        (self.scoFaSubmarineHatchGeneration or 0) + 1
    self:NewThread(
        SCO_AnimationClosureSubmarineThread,
        self.scoFaSubmarineHatchGeneration,
        surface)
end

function SeraphimNavalUnit:OnStopBeingBuilt()
    -- Bypass the earlier true-fourth unconditional-open shim. The FA
    -- source branches on Water versus Sub; this is the sole writer.
    ChosenNavalUnit.OnStopBeingBuilt(self)
    local config = self.tp.additions and self.tp.additions.faSubmarineHatch
    if not config then return end
    self.scoFaSubmarineHatchSample = 0
    self.scoFaSubmarineCannonReady = false
    self:SCO_SetSubmarineSurfaceState(
        self.targetingLayer
            == SCO_AnimationClosureTargetingLayer.WaterSurface)
end

function SeraphimNavalUnit:SetTargetingLayer(layer)
    local previous = self.targetingLayer
    ChosenNavalUnit.SetTargetingLayer(self, layer)
    local config = self.tp.additions and self.tp.additions.faSubmarineHatch
    if not config or previous == layer then return end
    if layer == SCO_AnimationClosureTargetingLayer.WaterSurface then
        self:SCO_SetSubmarineSurfaceState(true)
    elseif layer == SCO_AnimationClosureTargetingLayer.Water then
        self:SCO_SetSubmarineSurfaceState(false)
    end
end

-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0
local function SCO_SeraphimFactoryAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function SCO_SeraphimFactoryTargetKey(target)
    return target and target.id
        and (tostring(target.id.index) .. ":" .. tostring(target.id.version))
end

local function SCO_SeraphimFactoryRamps(factory)
    local additions = factory.tp and factory.tp.additions
    return additions and additions.seraphimLandFactoryRamps or {}
end

local function SCO_SeraphimFactoryPosition(factory, offset)
    local position = factory:GetPosition()
    return EngineClasses.float3(
        position.x + (offset.x or 0),
        position.y + (offset.y or 0),
        position.z + (offset.z or 0))
end

local function SCO_SeraphimSelectRamp(factory, target)
    local ramps = SCO_SeraphimFactoryRamps(factory)
    if #ramps == 0 then return nil end
    local key = SCO_SeraphimFactoryTargetKey(target)
    factory.scoSeraphimRampByTarget = factory.scoSeraphimRampByTarget or {}
    local index = key and factory.scoSeraphimRampByTarget[key]
    if not index then
        local source = factory.unitBeingBuiltSource or factory
        if source.rallyPoint then
            local bestDistance = nil
            for candidateIndex, ramp in ipairs(ramps) do
                local point = SCO_SeraphimFactoryPosition(factory, ramp.clearanceOffset)
                local dx = point.x - source.rallyPoint.x
                local dz = point.z - source.rallyPoint.z
                local distance = dx * dx + dz * dz
                if not bestDistance or distance < bestDistance then
                    bestDistance = distance
                    index = candidateIndex
                end
            end
        else index = 1 end
        if key then factory.scoSeraphimRampByTarget[key] = index end
    end
    return ramps[index]
end

local function SCO_SeraphimFaceRamp(target, ramp)
    if not SCO_SeraphimFactoryAlive(target) or not target:HasTags(Tags.MOBILE) or not ramp then return end
    Engine.SetGlobalEntityLocalRotation(target.id, Engine.EulerToQuaternion(
        EngineClasses.float3(0, math.rad(ramp.headingDegrees), 0),
        RotationOrder.Default))
end

function SeraphimLandFactory:RotatorsEnabledOnConstruction()
    return true
end

function SeraphimLandFactory:OnStartBuildRoutine(target)
    if SCO_SeraphimFactoryAlive(target)
        and target:HasTags(Tags.MOBILE)
        and not target:IsCompleted()
    then
        self.scoSeraphimPinnedTarget = target
        target.scoFactoryColliderPinOwner = self
        Engine.SetVolumeColliderEnabled(target.id, false)
    end
    ChosenLandFactory.OnStartBuildRoutine(self, target)
    SCO_SeraphimFaceRamp(target, SCO_SeraphimSelectRamp(self, target))
    if SCO_SeraphimFactoryAlive(target) and target:HasTags(Tags.MOBILE) then
        Engine.SetVolumeColliderEnabled(target.id, false)
    end
end

function SeraphimLandFactory:OnStopBuildRoutine(target)
    local completed = SCO_SeraphimFactoryAlive(target)
        and target:HasTags(Tags.MOBILE)
        and target:IsCompleted()
    local ramp = completed and SCO_SeraphimSelectRamp(self, target)
    if completed and ramp then
        SCO_SeraphimFaceRamp(target, ramp)
        local point = SCO_SeraphimFactoryPosition(self, ramp.clearanceOffset)
        local _, terrainHeight = Engine.SampleTerrainHeight(point)
        point.y = terrainHeight
        target:SetPosition(point)
        target.scoFactoryColliderPinOwner = nil
        self.scoSeraphimPinnedTarget = nil
        Engine.SetVolumeColliderEnabled(target.id, true)
    end
    ChosenLandFactory.OnStopBuildRoutine(self, target)
end

function SeraphimLandFactory:RollOffUnit(target)
    local ramp = SCO_SeraphimSelectRamp(self, target)
    if not ramp then
        return ChosenLandFactory.RollOffUnit(self, target)
    end
    if SCO_SeraphimFactoryAlive(target) and target.scoFactoryColliderPinOwner == self then
        local point = SCO_SeraphimFactoryPosition(self, ramp.clearanceOffset)
        local _, terrainHeight = Engine.SampleTerrainHeight(point)
        point.y = terrainHeight
        SCO_SeraphimFaceRamp(target, ramp)
        target:SetPosition(point)
        target.scoFactoryColliderPinOwner = nil
        self.scoSeraphimPinnedTarget = nil
        Engine.SetVolumeColliderEnabled(target.id, true)
    end
    local source = self.unitBeingBuiltSource or self
    if source.rallyPoint then
        SeraphimHostOrderManager.HostIssueOrder(
            SeraphimOrderTasks.MOVE, { target }, false, source.rallyPoint, nil)
    end
    local key = SCO_SeraphimFactoryTargetKey(target)
    if key and self.scoSeraphimRampByTarget then
        self.scoSeraphimRampByTarget[key] = nil
    end
end

function SeraphimLandFactory:ProductionBehaviorStop()
    local target = self.scoSeraphimPinnedTarget
    if SCO_SeraphimFactoryAlive(target) and target.scoFactoryColliderPinOwner == self then
        target.scoFactoryColliderPinOwner = nil
    end
    self.scoSeraphimPinnedTarget = nil
    ChosenLandFactory.ProductionBehaviorStop(self)
    if not self.dead and not self.deleted then self:SetRotatorsEnabled(true) end
end

-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0
local SCO_SeraphimDeathSentinel = -10000

local function SCO_SeraphimSelectDeath(configs)
    local total = 0
    for _, config in ipairs(configs) do total = total + config.weight end
    local selected = math.random(0, total)
    local accumulated = 1
    for _, config in ipairs(configs) do
        accumulated = accumulated + config.weight
        if selected < accumulated then return config end
    end
    return nil
end

local function SCO_SeraphimDeathThread(unit, inherited, overkillRatio)
    local configs = unit.tp.additions and unit.tp.additions.seraphimDeathAnimations
    if not configs or #configs == 0 or not unit:IsCompleted() then
        return inherited(unit, overkillRatio)
    end
    local config = SCO_SeraphimSelectDeath(configs)
    local animations = unit.tp.visuals and unit.tp.visuals.animations
    local animation = config and animations and animations[config.key]
    if not animation or not animation.id then
        return inherited(unit, overkillRatio)
    end
    local rateMin = config.rateMinTenths or 10
    local rateMax = config.rateMaxTenths or 10
    local rate = math.random(rateMin, rateMax) / 10
    local elapsed = 0
    while not unit.deleted and elapsed < config.durationSeconds do
        Engine.PlayAnimation(unit.id, animation.id, SCO_SeraphimDeathSentinel + elapsed)
        local wallStep = math.min(0.1, (config.durationSeconds - elapsed) / rate)
        if wallStep <= 0 then break end
        WaitSeconds(wallStep)
        elapsed = math.min(config.durationSeconds, elapsed + wallStep * rate)
    end
    if not unit.deleted then
        Engine.PlayAnimation(unit.id, animation.id,
            SCO_SeraphimDeathSentinel + config.durationSeconds)
        return inherited(unit, overkillRatio)
    end
end

local function SCO_SeraphimInstallDeathThread(class, name)
    local inherited = class.DeathThread
    if type(inherited) ~= "function" then
        error("Seraphim death compatibility has no inherited DeathThread for " .. name)
    end
    function class:DeathThread(overkillRatio)
        return SCO_SeraphimDeathThread(self, inherited, overkillRatio)
    end
end

SCO_SeraphimInstallDeathThread(SeraphimAirFactory, "SeraphimAirFactory")
SCO_SeraphimInstallDeathThread(SeraphimAlloyExtractor, "SeraphimAlloyExtractor")
SCO_SeraphimInstallDeathThread(SeraphimEnergyGenerator, "SeraphimEnergyGenerator")
SCO_SeraphimInstallDeathThread(SeraphimEngineeringStation, "SeraphimEngineeringStation")
SCO_SeraphimInstallDeathThread(SeraphimLandFactory, "SeraphimLandFactory")
SCO_SeraphimInstallDeathThread(SeraphimLandUnit, "SeraphimLandUnit")
SCO_SeraphimInstallDeathThread(SeraphimNavalFactory, "SeraphimNavalFactory")
SCO_SeraphimInstallDeathThread(SeraphimNavalUnit, "SeraphimNavalUnit")
SCO_SeraphimInstallDeathThread(SeraphimStructure, "SeraphimStructure")

-- Supreme Commander Overhaul factory staging hook 1.0.2

-- Supreme Commander Overhaul Seraphim factory orientation correction 1.1.0
-- SCOM Field Fixes 1.0.1 - grounded true-fourth Seraphim host consumers.
local SCO_FieldFixSeraphimHostVersion = "1.0.1"
local SCO_FieldFixSeraphimHostInstalled =
    _G.SCO_FieldFixSeraphimHostInstalled
if SCO_FieldFixSeraphimHostInstalled ~= nil
    and SCO_FieldFixSeraphimHostInstalled
        ~= SCO_FieldFixSeraphimHostVersion
then
    error("SCOM Field Fixes found an unsupported Seraphim host appendix")
end
if SCO_FieldFixSeraphimHostInstalled == nil then

    local HostWeapon = Import(
        "host/units/weaponsClasses/weaponsBaseClass.lua").HostWeapon
    local SCO_FieldFixExactAnimationSentinel = -10000
    local SCO_FieldFixYthothaChargeState = -4004

    local function SCO_FieldFixSeraphimContract(unit, name)
        local additions = unit.tp and unit.tp.additions
        if not additions
            or additions.scoFieldFixAeonSeraphim ~= "1.0.0"
        then
            return nil
        end
        local contract = additions[name]
        if type(contract) == "table" and contract.version == "1.0.0" then
            return contract
        end
        return nil
    end

    local function SCO_FieldFixSeraphimPlay(unit, key, blendTime)
        local animations = unit.tp
            and unit.tp.visuals
            and unit.tp.visuals.animations
        local animation = animations and animations[key]
        if not animation or not animation.id then
            error(unit.tpId .. " requires field-fix animation " .. tostring(key))
        end
        Engine.PlayAnimation(unit.id, animation.id, blendTime or 0.1)
    end

    local function SCO_FieldFixSeraphimSample(unit, key, seconds)
        local animations = unit.tp
            and unit.tp.visuals
            and unit.tp.visuals.animations
        local animation = animations and animations[key]
        if not animation or not animation.id then
            error(unit.tpId .. " requires field-fix animation " .. tostring(key))
        end
        Engine.PlayAnimation(
            unit.id,
            animation.id,
            SCO_FieldFixExactAnimationSentinel + seconds)
    end

    local function SCO_FieldFixSeraphimAlive(unit)
        return unit ~= nil and not unit.dead and not unit.deleted
    end

    local function SCO_FieldFixSeraphimStorageCleanup(unit)
        unit.scoFieldFixStorageGeneration =
            (unit.scoFieldFixStorageGeneration or 0) + 1
        if unit.scoFieldFixStorageThread then
            KillThread(unit.scoFieldFixStorageThread)
            unit.scoFieldFixStorageThread = nil
        end
        unit.scoFieldFixStorageRatio = nil
    end

    local function SCO_FieldFixSeraphimStorageThread(unit, generation)
        local contract = SCO_FieldFixSeraphimContract(
            unit,
            "scoFieldFixStorageRatio")
        if not contract then return end
        while SCO_FieldFixSeraphimAlive(unit)
            and unit.scoFieldFixStorageGeneration == generation
        do
            local economy = unit:GetEconomy()
            if not economy or type(economy.GetResourceStoredRatio) ~= "function" then
                error(unit.tpId .. " requires an economy storage-ratio provider")
            end
            local ratio = economy:GetResourceStoredRatio(contract.resource)
            if type(ratio) ~= "number" or ratio ~= ratio
                or ratio == math.huge or ratio == -math.huge
            then
                error(unit.tpId .. " received an invalid "
                    .. tostring(contract.resource) .. " storage ratio")
            end
            ratio = math.max(0, math.min(1, ratio))
            if unit.scoFieldFixStorageRatio ~= ratio then
                SCO_FieldFixSeraphimSample(
                    unit,
                    contract.animationKey,
                    ratio * contract.durationSeconds)
                unit.scoFieldFixStorageRatio = ratio
            end
            WaitTicks(1)
        end
        if unit.scoFieldFixStorageGeneration == generation then
            unit.scoFieldFixStorageThread = nil
        end
    end

    local function SCO_FieldFixSeraphimStorageStart(unit)
        local contract = SCO_FieldFixSeraphimContract(
            unit,
            "scoFieldFixStorageRatio")
        if not contract then return end
        if contract.animationKey ~= "source_animstoragelevel"
            or contract.durationSeconds ~= 1
            or (contract.resource ~= "alloys" and contract.resource ~= "energy")
        then
            error(unit.tpId .. " has an invalid storage-ratio contract")
        end
        SCO_FieldFixSeraphimStorageCleanup(unit)
        local generation = unit.scoFieldFixStorageGeneration
        unit.scoFieldFixStorageThread = unit:NewThread(
            SCO_FieldFixSeraphimStorageThread,
            generation)
    end

    local function SCO_FieldFixYthothaWeaponContract(weapon)
        local contract = weapon
            and weapon.tp
            and weapon.tp.scoFieldFixYthothaCharge
        if type(contract) ~= "table" or contract.version ~= "1.0.0" then
            return nil
        end
        local unitContract = weapon.unit
            and SCO_FieldFixSeraphimContract(
                weapon.unit,
                "scoFieldFixYthothaClaw")
        if not unitContract
            or unitContract.weaponIndex ~= 3
            or unitContract.upperBone ~= contract.upperBone
            or unitContract.lowerBone ~= contract.lowerBone
            or unitContract.projectileTemplate ~= "psu404s"
            or weapon.tp.projectileTemplate ~= "psu404s"
            or contract.openSpeed ~= 10
            or contract.closeSpeed ~= 50
            or contract.chargeTicks ~= 25
            or contract.closeTicks ~= 5
        then
            error("usl4004 has a corrupt Ythotha claw/weapon contract")
        end
        return contract
    end

    local function SCO_FieldFixYthothaResolveClaws(weapon, contract)
        if weapon.scoFieldFixYthothaUpperId
            and weapon.scoFieldFixYthothaLowerId
        then
            return weapon.scoFieldFixYthothaUpperId,
                weapon.scoFieldFixYthothaLowerId
        end
        local upperId = weapon.unit:GetBoneId(contract.upperBone)
        local lowerId = weapon.unit:GetBoneId(contract.lowerBone)
        if not upperId or not lowerId then
            error("usl4004 lost a required Ythotha claw rotator bone")
        end
        Engine.SetRotatorIsVelocityScalingEnabled(upperId, false)
        Engine.SetRotatorIsVelocityScalingEnabled(lowerId, false)
        weapon.scoFieldFixYthothaUpperId = upperId
        weapon.scoFieldFixYthothaLowerId = lowerId
        return upperId, lowerId
    end

    local function SCO_FieldFixYthothaSetSpeeds(
        weapon,
        contract,
        upperSpeed,
        lowerSpeed)
        local upperId, lowerId = SCO_FieldFixYthothaResolveClaws(
            weapon,
            contract)
        Engine.SetRotatorEnabled(upperId, true)
        Engine.SetRotatorEnabled(lowerId, true)
        Engine.SetRotatorSpeed(
            upperId,
            EngineClasses.float3(upperSpeed, 0, 0))
        Engine.SetRotatorSpeed(
            lowerId,
            EngineClasses.float3(lowerSpeed, 0, 0))
    end

    local function SCO_FieldFixYthothaStopClaws(weapon)
        local upperId = weapon.scoFieldFixYthothaUpperId
        local lowerId = weapon.scoFieldFixYthothaLowerId
        if upperId then
            Engine.SetRotatorSpeed(upperId, EngineClasses.float3(0, 0, 0))
            Engine.SetRotatorEnabled(upperId, false)
        end
        if lowerId then
            Engine.SetRotatorSpeed(lowerId, EngineClasses.float3(0, 0, 0))
            Engine.SetRotatorEnabled(lowerId, false)
        end
        weapon.scoFieldFixYthothaChargeTicks = nil
        weapon.scoFieldFixYthothaCloseTicks = nil
        weapon.scoFieldFixYthothaCancelled = nil
        if weapon.currentState == SCO_FieldFixYthothaChargeState then
            weapon.currentState = 4
        end
    end

    local function SCO_FieldFixYthothaAdvanceClose(weapon)
        local ticks = weapon.scoFieldFixYthothaCloseTicks
        if not ticks then return end
        ticks = ticks - 1
        if ticks <= 0 then
            weapon.scoFieldFixYthothaCloseTicks = nil
            SCO_FieldFixYthothaStopClaws(weapon)
        else
            weapon.scoFieldFixYthothaCloseTicks = ticks
        end
    end

    if type(HostWeapon) ~= "table"
        or type(HostWeapon.UpdateProjectile) ~= "function"
        or type(HostWeapon.SetEnabled) ~= "function"
        or type(HostWeapon.Delete) ~= "function"
    then
        error("SCOM Field Fixes could not resolve HostWeapon Ythotha lifecycle")
    end
    if type(SeraphimStructure) ~= "table"
        or type(SeraphimStructure.CheckShieldState) ~= "function"
        or type(SeraphimStructure.OnStopBeingBuilt) ~= "function"
        or type(SeraphimStructure.OnDestroy) ~= "function"
        or type(SeraphimStructure.Delete) ~= "function"
        or type(SeraphimStructure.DeathThread) ~= "function"
    then
        error("SCOM Field Fixes could not resolve SeraphimStructure lifecycle")
    end
    if type(SeraphimNavalFactory) ~= "table"
        or type(SeraphimNavalFactory.RotatorsEnabledOnConstruction)
            ~= "function"
        or type(SeraphimNavalFactory.ProductionBehaviorStop) ~= "function"
        or type(SeraphimNavalFactory.OnDestroy) ~= "function"
    then
        error("SCOM Field Fixes could not resolve SeraphimNavalFactory lifecycle")
    end

    local SCO_FieldFixYthothaPreviousUpdateProjectile =
        HostWeapon.UpdateProjectile
    local SCO_FieldFixYthothaPreviousSetEnabled = HostWeapon.SetEnabled
    local SCO_FieldFixYthothaPreviousDelete = HostWeapon.Delete

    function HostWeapon:UpdateProjectile(isOnTarget)
        local contract = SCO_FieldFixYthothaWeaponContract(self)
        if not contract then
            return SCO_FieldFixYthothaPreviousUpdateProjectile(self, isOnTarget)
        end

        SCO_FieldFixYthothaAdvanceClose(self)
        if self.currentState == SCO_FieldFixYthothaChargeState then
            local ticks = self.scoFieldFixYthothaChargeTicks - 1
            self.scoFieldFixYthothaChargeTicks = ticks
            if ticks > 0 then return end

            self.scoFieldFixYthothaChargeTicks = nil
            SCO_FieldFixYthothaSetSpeeds(
                self,
                contract,
                contract.closeSpeed,
                -contract.closeSpeed)
            self.scoFieldFixYthothaCloseTicks = contract.closeTicks
            self.currentState = self.scoFieldFixYthothaCancelled and 4 or 2
            self.scoFieldFixYthothaCancelled = nil
            return SCO_FieldFixYthothaPreviousUpdateProjectile(self, isOnTarget)
        end

        if self.currentState == 2 then
            self.scoFieldFixYthothaCancelled = false
            self.scoFieldFixYthothaChargeTicks = contract.chargeTicks
            self.currentState = SCO_FieldFixYthothaChargeState
            SCO_FieldFixYthothaSetSpeeds(
                self,
                contract,
                -contract.openSpeed,
                contract.openSpeed)
            return
        end
        return SCO_FieldFixYthothaPreviousUpdateProjectile(self, isOnTarget)
    end

    function HostWeapon:SetEnabled(enabled)
        local contract = SCO_FieldFixYthothaWeaponContract(self)
        if contract and not enabled
            and self.currentState == SCO_FieldFixYthothaChargeState
        then
            self.scoFieldFixYthothaCancelled = true
            if self.unit.dead or self.unit.deleted then
                SCO_FieldFixYthothaStopClaws(self)
            end
        end
        return SCO_FieldFixYthothaPreviousSetEnabled(self, enabled)
    end

    function HostWeapon:Delete()
        if SCO_FieldFixYthothaWeaponContract(self) then
            SCO_FieldFixYthothaStopClaws(self)
        end
        return SCO_FieldFixYthothaPreviousDelete(self)
    end

    local function SCO_FieldFixSeraphimShieldIsUp(unit)
        return unit:IsCompleted()
            and unit:GetShieldToggle()
            and unit.army ~= nil
            and unit.army.economy ~= nil
            and not unit.army.economy.isEnergyDown
    end

    local function SCO_FieldFixSeraphimUpdateShieldAnimation(unit)
        local contract = SCO_FieldFixSeraphimContract(
            unit,
            "scoFieldFixShieldLifecycle")
        if not contract then return end
        local isUp = SCO_FieldFixSeraphimShieldIsUp(unit)
        if unit.scoFieldFixShieldAnimationIsUp == isUp then return end
        unit.scoFieldFixShieldAnimationIsUp = isUp
        SCO_FieldFixSeraphimPlay(
            unit,
            isUp and contract.activationAnimationKey
                or contract.restAnimationKey,
            0.1)
    end

    local SCO_FieldFixSeraphimStructureCheckShield =
        SeraphimStructure.CheckShieldState
    local SCO_FieldFixSeraphimStructureStopBeingBuilt =
        SeraphimStructure.OnStopBeingBuilt
    local SCO_FieldFixSeraphimStructureDestroy = SeraphimStructure.OnDestroy
    local SCO_FieldFixSeraphimStructureDelete = SeraphimStructure.Delete
    local SCO_FieldFixSeraphimStructureDeath = SeraphimStructure.DeathThread

    function SeraphimStructure:CheckShieldState(skipRecharge)
        local result = SCO_FieldFixSeraphimStructureCheckShield(
            self,
            skipRecharge)
        SCO_FieldFixSeraphimUpdateShieldAnimation(self)
        return result
    end

    function SeraphimStructure:OnStopBeingBuilt()
        local result = SCO_FieldFixSeraphimStructureStopBeingBuilt(self)
        if self.tpId == "uss2711" and not self.scoFieldFixPermanentOpened
            and SCO_FieldFixSeraphimAlive(self) and self:IsCompleted()
        then
            -- XSB4203 AnimationPermOpen activates once, after construction.
            local animation = self.tp.visuals.animations.source_animactivate
            assert(animation and animation.clipName == "AnimActivate"
                and animation.playbackMode == AnimationPlaybackMode.Clamp,
                "uss2711 requires its clamped source activation")
            SCO_FieldFixSeraphimPlay(self, "source_animactivate", 0.1)
            self.scoFieldFixPermanentOpened = true
        end
        if SCO_FieldFixSeraphimContract(self, "scoFieldFixShieldLifecycle") then
            -- HostUnit enables the animator near the end of its completion path;
            -- replay once afterward so the clamped activation owns the final pose.
            self.scoFieldFixShieldAnimationIsUp = nil
            SCO_FieldFixSeraphimUpdateShieldAnimation(self)
        end
        if SCO_FieldFixSeraphimContract(self, "scoFieldFixStorageRatio") then
            SCO_FieldFixSeraphimStorageStart(self)
        end
        return result
    end

    function SeraphimStructure:OnDestroy(destroyType)
        if SCO_FieldFixSeraphimContract(self, "scoFieldFixStorageRatio") then
            SCO_FieldFixSeraphimStorageCleanup(self)
        end
        return SCO_FieldFixSeraphimStructureDestroy(self, destroyType)
    end

    function SeraphimStructure:Delete()
        if SCO_FieldFixSeraphimContract(self, "scoFieldFixStorageRatio") then
            SCO_FieldFixSeraphimStorageCleanup(self)
        end
        return SCO_FieldFixSeraphimStructureDelete(self)
    end

    function SeraphimStructure:DeathThread(overkillRatio)
        if SCO_FieldFixSeraphimContract(self, "scoFieldFixStorageRatio") then
            SCO_FieldFixSeraphimStorageCleanup(self)
        end
        return SCO_FieldFixSeraphimStructureDeath(self, overkillRatio)
    end

    local SCO_FieldFixSeraphimNavalRotatorsOnConstruction =
        SeraphimNavalFactory.RotatorsEnabledOnConstruction
    local SCO_FieldFixSeraphimNavalProductionStop =
        SeraphimNavalFactory.ProductionBehaviorStop
    local SCO_FieldFixSeraphimNavalDestroy = SeraphimNavalFactory.OnDestroy

    function SeraphimNavalFactory:RotatorsEnabledOnConstruction()
        if SCO_FieldFixSeraphimContract(
            self,
            "scoFieldFixSeraphimNavalFactory")
        then
            return true
        end
        return SCO_FieldFixSeraphimNavalRotatorsOnConstruction(self)
    end

    function SeraphimNavalFactory:ProductionBehaviorStop()
        local result = SCO_FieldFixSeraphimNavalProductionStop(self)
        if not self.scoFieldFixNavalDestroying
            and not self.dead
            and not self.deleted
            and self:IsCompleted()
            and SCO_FieldFixSeraphimContract(
                self,
                "scoFieldFixSeraphimNavalFactory")
        then
            self:SetRotatorsEnabled(true)
        end
        return result
    end

    function SeraphimNavalFactory:OnDestroy(destroyType)
        self.scoFieldFixNavalDestroying = true
        return SCO_FieldFixSeraphimNavalDestroy(self, destroyType)
    end

    -- The T3 Attachpoint correction is asset-owned because the FA slider is a
    -- static OnCreate offset. construction.platformBoneName routes stock spawn
    -- and beam ownership through that corrected bone without a runtime slider.
    _G.SCO_FieldFixSeraphimHostInstalled =
        SCO_FieldFixSeraphimHostVersion
end

-- Append after the existing Seraphim naval and hatch methods.
-- Only templates that select SeraphimSubmarineUnit acquire dive controls.
local SCO_StockSubmarine = assert(
    Import("host/units/unitsClasses/unitsDefault.lua").HostSubmarineUnit)

HostSeraphimSubmarineUnit = Class("SeraphimSubmarineUnit", SeraphimNavalUnit)
local SeraphimSubmarineUnit = HostSeraphimSubmarineUnit
SeraphimSubmarineUnit.GroundedNavigationLayerName =
    SCO_StockSubmarine.GroundedNavigationLayerName

function SeraphimSubmarineUnit:__init(id, army, template, progress, builder)
    SeraphimNavalUnit.__init(self, id, army, template, progress, builder)
    self.isSurfaced = true
end

-- Keep SeraphimNavalUnit:SetTargetingLayer and OnStopBeingBuilt in the MRO:
-- they drive the source hatch when the hull enters or leaves the water.
for _, method in ipairs({
    "SetSurfacedLayers",
    "SetSubmergedLayers",
    "OnHullCrossedWaterline",
    "DiveBehaviorIsValidFor",
    "SurfaceBehaviorIsValidFor",
    "SetSubmerged",
    "DiveBehaviorStart",
    "DiveBehaviorStop",
    "SurfaceBehaviorStart",
    "SurfaceBehaviorStop",
    "OnAltitudeReached",
}) do
    SeraphimSubmarineUnit[method] = assert(SCO_StockSubmarine[method],
        "Missing stock submarine method " .. method)
end
-- SCOM factory egress Seraphim installation 1.0.0
local factoryEgress = Import("common/systems/scoFactoryEgress.lua")
factoryEgress.Install(HostSeraphimLandFactory, ChosenLandFactory.OnStopBuildRoutine)
factoryEgress.Install(HostSeraphimAirFactory)
factoryEgress.Install(HostSeraphimNavalFactory)

local combat = Import('common/systems/scoSeraphimCombat.lua')
local weapon = Import('host/units/weaponsClasses/weaponsBaseClass.lua')
combat.InstallHost(weapon.HostWeapon, weapon.WeaponState)
