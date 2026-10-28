-- Virtual unitsDefaultSeraphim module for the true fourth faction.
-- It subclasses the stock Chosen behavior classes without modifying them.
local chosenDefaults = Import("client/units/unitsClasses/unitsDefaultChosen.lua")
local ChosenStructure = chosenDefaults.ClientChosenStructure
local ChosenNavalStructure = chosenDefaults.ClientChosenNavalStructure
local ChosenTechCentre = chosenDefaults.ClientChosenTechCentre
local ChosenEngineeringStation = chosenDefaults.ClientChosenEngineeringStation
local ChosenStorage = chosenDefaults.ClientChosenStorage
local ChosenAirFactory = chosenDefaults.ClientChosenAirFactory
local ChosenLandFactory = chosenDefaults.ClientChosenLandFactory
local ChosenNavalFactory = chosenDefaults.ClientChosenNavalFactory
local ChosenAlloyExtractor = chosenDefaults.ClientChosenAlloyExtractor
local ChosenEnergyGenerator = chosenDefaults.ClientChosenEnergyGenerator
local ChosenAirUnit = chosenDefaults.ClientChosenAirUnit
local ChosenLandUnit = chosenDefaults.ClientChosenLandUnit
local ChosenNavalUnit = chosenDefaults.ClientChosenNavalUnit
local ChosenEngineer = chosenDefaults.ClientChosenEngineer
local ChosenCommander = chosenDefaults.ClientChosenCommander

ClientSeraphimStructure = Class("SeraphimStructure", ChosenStructure)
local SeraphimStructure = ClientSeraphimStructure
ClientSeraphimNavalStructure = Class("SeraphimNavalStructure", ChosenNavalStructure)
local SeraphimNavalStructure = ClientSeraphimNavalStructure
ClientSeraphimTechCentre = Class("SeraphimTechCentre", ChosenTechCentre)
local SeraphimTechCentre = ClientSeraphimTechCentre
ClientSeraphimEngineeringStation = Class("SeraphimEngineeringStation", ChosenEngineeringStation)
local SeraphimEngineeringStation = ClientSeraphimEngineeringStation
ClientSeraphimStorage = Class("SeraphimStorage", ChosenStorage)
local SeraphimStorage = ClientSeraphimStorage
ClientSeraphimAirFactory = Class("SeraphimAirFactory", ChosenAirFactory)
local SeraphimAirFactory = ClientSeraphimAirFactory
ClientSeraphimLandFactory = Class("SeraphimLandFactory", ChosenLandFactory)
local SeraphimLandFactory = ClientSeraphimLandFactory
ClientSeraphimNavalFactory = Class("SeraphimNavalFactory", ChosenNavalFactory)
local SeraphimNavalFactory = ClientSeraphimNavalFactory
ClientSeraphimAlloyExtractor = Class("SeraphimAlloyExtractor", ChosenAlloyExtractor)
local SeraphimAlloyExtractor = ClientSeraphimAlloyExtractor
ClientSeraphimEnergyGenerator = Class("SeraphimEnergyGenerator", ChosenEnergyGenerator)
local SeraphimEnergyGenerator = ClientSeraphimEnergyGenerator
ClientSeraphimAirUnit = Class("SeraphimAirUnit", ChosenAirUnit)
local SeraphimAirUnit = ClientSeraphimAirUnit
ClientSeraphimLandUnit = Class("SeraphimLandUnit", ChosenLandUnit)
local SeraphimLandUnit = ClientSeraphimLandUnit
ClientSeraphimNavalUnit = Class("SeraphimNavalUnit", ChosenNavalUnit)
local SeraphimNavalUnit = ClientSeraphimNavalUnit
ClientSeraphimEngineer = Class("SeraphimEngineer", ChosenEngineer)
local SeraphimEngineer = ClientSeraphimEngineer
ClientSeraphimCommander = Class("SeraphimCommander", ChosenCommander)
local SeraphimCommander = ClientSeraphimCommander


-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0
-- SCOM Field Fixes 1.0.0 - reviewed true-fourth Seraphim client boundary.
local SCO_FieldFixSeraphimClientVersion = "1.0.0"
local SCO_FieldFixSeraphimClientInstalled =
    _G.SCO_FieldFixSeraphimClientInstalled
if SCO_FieldFixSeraphimClientInstalled ~= nil
    and SCO_FieldFixSeraphimClientInstalled
        ~= SCO_FieldFixSeraphimClientVersion
then
    error("SCOM Field Fixes found an unsupported Seraphim client appendix")
end
if SCO_FieldFixSeraphimClientInstalled == nil then

    -- Shield transitions, exact-time storage samples, and Ythotha claw rotators
    -- are host-owned simulation components and replicate through stock engine
    -- state. The T3 naval Attachpoint correction is baked into its skeleton and
    -- every animation clip, so host construction and client rendering resolve the
    -- same bone. No parallel client state machine or transform writer is needed.
    _G.SCO_FieldFixSeraphimClientInstalled =
        SCO_FieldFixSeraphimClientVersion
end

-- Append after ClientSeraphimNavalUnit is defined. Host owns dive state.
local SCO_StockClientSubmarine = assert(
    Import("client/units/unitsClasses/unitsDefault.lua").ClientSubmarineUnit)

ClientSeraphimSubmarineUnit = Class("SeraphimSubmarineUnit", SeraphimNavalUnit)
ClientSeraphimSubmarineUnit.CanSubmerge = assert(
    SCO_StockClientSubmarine.CanSubmerge)

-- Seraphim naval build pods: render-only clearance and exact animated muzzles.
-- Native animation/rotators retain all rotations. Production still uses Attachpoint.
local NavalPodBounds = {}
local function NavalPodConfig(unit)
    return unit.tp.additions and unit.tp.additions.seraphimNavalBuildPods
end
local function NavalPodValid(id)
    return id ~= nil and Engine.IsValidLocalID(id)
end
local function NavalPodFinite(value)
    return type(value) == 'number' and value == value and math.abs(value) < math.huge
end
local function NavalPodTop(target)
    local general = target.tp.general
    local model = general.modelTpId or general.tpId
    if not model then return nil end
    local top = NavalPodBounds[model]
    if top == nil then
        local result, center, size = Engine.GetMeshBounds(
            'Units/' .. model .. '/LOD0/' .. model .. '_lod0.sanmodel')
        top = false
        if result == EngineErrorCode.Success and center and size
            and NavalPodFinite(center.y) and NavalPodFinite(size.y) and size.y > 0
        then
            top = center.y + size.y * .5
        end
        NavalPodBounds[model] = top
    end
    return top or nil
end
local function NavalPodRestore(unit)
    local parts = unit.scoNavalPodParts
    unit.scoNavalPodParts = nil
    for _, part in ipairs(parts or {}) do
        if Engine.IsValidGlobalID(part.globalId) and NavalPodValid(part.id) then
            local result, basis = Engine.GetGlobalEntityLocalPosition(part.globalId)
            if result == EngineErrorCode.Success then
                Engine.SetLocalEntityLocalPosition(part.id, basis)
            end
        end
    end
end
local function NavalPodPose(unit, target)
    local config = NavalPodConfig(unit)
    local tags = target and target.tp.hasTags
    if not config or unit.dead or not unit:IsCompleted()
        or not unit:IsIntelVisionVisible() or not target or target.dead
        or not NavalPodValid(target.localId)
    then
        NavalPodRestore(unit)
        return nil
    end
    local root = unit:GetBoneId('Root')
    if not NavalPodValid(root) then NavalPodRestore(unit); return nil end
    local positionResult, position = Engine.GetLocalEntityWorldPosition(root)
    local rotationResult, rotation = Engine.GetLocalEntityWorldRotation(root)
    if positionResult ~= EngineErrorCode.Success or rotationResult ~= EngineErrorCode.Success then
        NavalPodRestore(unit); return nil
    end
    if not tags or not tags.MOBILE or not tags.NAVAL then
        -- Upgrades retain their animation-owned positions and ordinary beams.
        NavalPodRestore(unit)
        local parts = {}
        for index = 1, config.count do
            local id = unit:GetBoneId('Pod0' .. index)
            if not NavalPodValid(id) then return nil end
            local result, localPosition = Engine.GetLocalEntityLocalPosition(id)
            if result ~= EngineErrorCode.Success then return nil end
            parts[index] = {id = id, position = localPosition}
        end
        return {parts = parts, position = position, rotation = rotation}
    end
    local top = NavalPodTop(target)
    if not top then NavalPodRestore(unit); return nil end
    local rise = math.max(0, target:GetPosition().y + top + config.clearance
        - unit:GetPosition().y - config.lowestPodY)
    local offset = Engine.QuaternionRotateVector(math3D.invert(rotation),
        EngineClasses.float3(0, rise, 0))
    local parts = unit.scoNavalPodParts
    if not parts then
        parts = {}
        for index = 1, config.count do
            local name = 'Pod0' .. index
            local globalId = EngineClasses.GlobalID()
            local result = Engine.GetGlobalBone(unit.id, name, globalId)
            local id = unit:GetBoneId(name)
            if result ~= EngineErrorCode.Success or not NavalPodValid(id) then return nil end
            parts[index] = {id = id, globalId = globalId}
        end
        unit.scoNavalPodParts = parts
    end
    for _, part in ipairs(parts) do
        if not Engine.IsValidGlobalID(part.globalId) then NavalPodRestore(unit); return nil end
        local result, basis = Engine.GetGlobalEntityLocalPosition(part.globalId)
        if result ~= EngineErrorCode.Success or not NavalPodValid(part.id) then
            NavalPodRestore(unit); return nil
        end
        -- Read the current simulation basis, never the previously shifted frame.
        part.position = EngineClasses.float3(basis.x + offset.x,
            basis.y + offset.y, basis.z + offset.z)
        Engine.SetLocalEntityLocalPosition(part.id, part.position)
    end
    return {parts = parts, position = position, rotation = rotation}
end
local function NavalPodMuzzle(pose, index, muzzleId)
    local part = pose.parts[index]
    if not part or not NavalPodValid(muzzleId) then return nil end
    local pResult, muzzle = Engine.GetLocalEntityLocalPosition(muzzleId)
    local rResult, rotation = Engine.GetLocalEntityLocalRotation(part.id)
    if pResult ~= EngineErrorCode.Success or rResult ~= EngineErrorCode.Success then return nil end
    -- Both transforms are current local poses. Cached descendant LocalToWorld
    -- still describes the previous pose until Unity's next transform pass.
    local point = Engine.QuaternionRotateVector(rotation, muzzle)
    point = EngineClasses.float3(point.x + part.position.x,
        point.y + part.position.y, point.z + part.position.z)
    point = Engine.QuaternionRotateVector(pose.rotation, point)
    return EngineClasses.float3(point.x + pose.position.x,
        point.y + pose.position.y, point.z + pose.position.z)
end
local NavalPodSetup = SeraphimNavalFactory.SetUpConstructionBeam
function SeraphimNavalFactory:SetUpConstructionBeam()
    NavalPodRestore(self)
    local result = NavalPodSetup(self)
    local config, group = NavalPodConfig(self), self.constructionBeam
    if not config or not group or not group.scoMultiConstructionBeam then return result end
    local factory = self
    -- Reuse the shared group's allocation, target, visibility and disposal owners.
    -- Only this three-template group replaces endpoint sampling.
    for _, state in ipairs(group.beams) do
        local originalPosition = state.beam.GetPosition
        state.beam.GetPosition = function(beam)
            return beam.scoNavalOrigin or originalPosition(beam)
        end
    end
    function group:RenderUpdate()
        if self.deleted or not self.enabled then return end
        local target = self.beams[1] and self.beams[1].beam.targetUnit
        local pose = NavalPodPose(factory, target)
        for index, state in ipairs(self.beams) do
            local origin = pose and NavalPodMuzzle(pose, index, state.muzzleId)
            if origin and NavalPodValid(state.rootId) and NavalPodValid(state.beam.localId)
                and state.beam.targetUnit and NavalPodValid(state.beam.targetUnit.localId)
            then
                Engine.SetLocalEntityLocalPosition(state.rootId, origin)
                -- Native Update and the shared surface-target helper use the same
                -- fresh origin as the rendered loose root, with no stale cache read.
                state.beam.scoNavalOrigin = origin
                if state.scoNavalSuppressed then
                    state.beam:SetEnabled(true)
                    state.scoNavalSuppressed = nil
                end
                state.beam:Update()
            else
                state.beam.scoNavalOrigin = nil
                state.scoNavalSuppressed = true
                state.beam:SetEnabled(false)
            end
        end
    end
    return result
end
local NavalPodRender = SeraphimNavalFactory.RenderUpdateBeams
function SeraphimNavalFactory:RenderUpdateBeams(...)
    NavalPodPose(self, self.buildTarget)
    return NavalPodRender(self, ...)
end
local NavalPodStop = SeraphimNavalFactory.ClientOnStopBuilding
function SeraphimNavalFactory:ClientOnStopBuilding(...)
    local result = NavalPodStop(self, ...)
    NavalPodRestore(self)
    return result
end
local NavalPodDestroy = SeraphimNavalFactory.OnDestroy
function SeraphimNavalFactory:OnDestroy(...)
    NavalPodRestore(self)
    return NavalPodDestroy(self, ...)
end
local NavalPodDelete = SeraphimNavalFactory.OnDelete
function SeraphimNavalFactory:OnDelete(...)
    NavalPodRestore(self)
    return NavalPodDelete(self, ...)
end

local combat = Import('common/systems/scoSeraphimCombat.lua')
combat.InstallClient(ClientSeraphimLandUnit)
