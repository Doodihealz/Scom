local SCO_ConstructionContact = Import("client/entities/scoConstructionContact.lua")
local ClientEntity = Import("client/entities/entity.lua").ClientEntity

---@param unitLocalId localId Local ID of the parent entity to attach the beam to
---@return ConstructionBeam beam Created instance
function CreateConstructionBeam(unitLocalId)
    local beamLocalId = {}
    Engine.GetLocalBone(unitLocalId, "Construction Beam", beamLocalId)
    return ConstructionBeam(beamLocalId)
end

---@class ConstructionBeam : ClientEntity
---@field targetUnit ClientUnit|nil The target Unit assigned to build or nil if nothing assigned
---@field targetUnitHeight number The height of the object to be built in order to do the animation of the process
---@field targetUnitOffset float3 The position offset of the unit to be built in order to correctly position the animation of the process
---@field shrink number How much shrinking was originally applied in the X axis of the beam 
---@overload fun(localId: localId): ConstructionBeam
ConstructionBeam = Class("ConstructionBeam", ClientEntity)

---Initializes a new construction beam given the local id 
---@param beamLocalId localId Local id of the beam entity
---@protected
function ConstructionBeam:__init(beamLocalId)
    ClientEntity.__init(self, nil, beamLocalId)
    local initialScale = {}
    Engine.GetMeshRendererScale(beamLocalId, initialScale)
    self.shrink = initialScale.x
    self:SetEnabled(false)
end

function ConstructionBeam:SetEnabled(enabled)
    Engine.SetRendererEnabled(self.localId, enabled)
end

---@param targetUnit ClientUnit target unit to build
function ConstructionBeam:SetTarget(targetUnit)
    if targetUnit ~= nil then
        self.targetUnit = targetUnit
        self.targetUnitHeight = targetUnit.tp.collisionInfo.collisionSize.y
        self.targetUnitOffset = table.deepCopy(targetUnit.tp.collisionInfo.centerOffset)
        Log(self.targetUnitHeight .. " Offset " .. tostring(self.targetUnitOffset))
    else
        Error("ConstructionBeam:SetTarget: TargetUnit entity is nil")
        self.targetUnit = nil
    end 
end

function ConstructionBeam:RemoveTarget()
    self.targetUnit = nil
end

---Update the look of the beam if a target is set. If no target is set it does nothing
function ConstructionBeam:Update()
    
    if self.targetUnit == nil then 
        Error("Construction Beam must have a target set before updating")
        return 
    end

    -- Origin And Target positions
    local originPosition = self:GetPosition()
    local targetPosition = math3D.add(self.targetUnit:GetPosition(), self.targetUnitOffset)
    local extents = EngineClasses.float3(0, self.targetUnitHeight * 0.5, 0)
    local bottomPosition = math3D.sub(targetPosition, extents)
    local topPosition = math3D.add(targetPosition, extents)
    
    if self.targetUnit.GetFractionComplete then
        targetPosition = math3D.lerp(bottomPosition, topPosition, self.targetUnit:GetFractionComplete())
    else
        targetPosition = math3D.lerp(bottomPosition, topPosition, 0.5)
    end

    -- DEBUG DRAW ORIGIN TO TARGET LINES
    --Engine.DrawLine(bottomPosition, topPosition, Engine.Types.float4(0, 1, 0, 1))
    --Engine.DrawLine(originPosition, targetPosition, Engine.Types.float4(1, 0, 0, 1))
    
    -- Origin to Target
    local originToTargetVector = math3D.sub(targetPosition, originPosition)
    local originToTargetDistance = math3D.length(originToTargetVector)
    originToTargetVector = math3D.divide(originToTargetVector, originToTargetDistance + 0.000001) -- To avoid NaN

    Engine.SetMeshRendererScale(self.localId, EngineClasses.float3(self.shrink, 1, originToTargetDistance))

    -- Find Parent
    local parentLocalID = {}
    Engine.GetLocalEntityParent(self.localId, parentLocalID)
    if not Engine.IsValidLocalID(parentLocalID) then
        Error("Construction Beam does not have a parent LocalID")
        return
    end

    -- World rotation of the unit
    local unitWorldToLocalRotation = { value = {} }
    Engine.GetLocalEntityWorldRotation(parentLocalID, unitWorldToLocalRotation)
    unitWorldToLocalRotation = math3D.invert(unitWorldToLocalRotation)

    -- World rotation of the origin to target
    local originToTargetWorldRotation = { value = {} }
    Engine.QuaternionLookRotation(originToTargetVector, EngineClasses.float3(0, 1, 0), originToTargetWorldRotation) -- Assuming unit will never look completely up

    -- Apply both rotations to get the world rotation for the beam
    local resultRotation = { value = {} }
    Engine.QuaternionMultiply(unitWorldToLocalRotation, originToTargetWorldRotation, resultRotation)

    self:SetOrientation(resultRotation)

end


-- Only for annotations
-- SCOM Field Fix: construction-beam lifecycle guard 1.0.0
local SCO_FieldFixStockConstructionBeamSetEnabled = ConstructionBeam.SetEnabled
local SCO_FieldFixStockConstructionBeamSetTarget = ConstructionBeam.SetTarget
local SCO_FieldFixStockConstructionBeamRemoveTarget = ConstructionBeam.RemoveTarget
local SCO_FieldFixStockConstructionBeamUpdate = ConstructionBeam.Update

local function SCO_FieldFixConstructionBeamValidLocalID(localId)
    return localId ~= nil and Engine.IsValidLocalID(localId)
end

local function SCO_FieldFixConstructionBeamClear(beam)
    SCO_ConstructionContact.Clear(beam)
    beam.scoConstructionHop = nil
    beam.scoConstructionHopEnabled = false
    if SCO_FieldFixConstructionBeamValidLocalID(beam.localId) then
        SCO_FieldFixStockConstructionBeamSetEnabled(beam, false)
    end
    beam.targetUnit = nil
    beam.targetUnitHeight = nil
    beam.targetUnitOffset = nil
end

function ConstructionBeam:SetEnabled(enabled)
    self.scoConstructionHopEnabled = enabled == true
    if not enabled then
        self.scoConstructionHop = nil
        SCO_ConstructionContact.Clear(self)
    end
    if not SCO_FieldFixConstructionBeamValidLocalID(self.localId) then
        SCO_ConstructionContact.Clear(self)
        self.targetUnit = nil
        self.scoConstructionHop = nil
        self.scoConstructionHopEnabled = false
        return
    end
    local target = self.targetUnit
    if enabled and (target == nil
        or not SCO_FieldFixConstructionBeamValidLocalID(target.localId))
    then
        SCO_FieldFixConstructionBeamClear(self)
        return
    end
    return SCO_FieldFixStockConstructionBeamSetEnabled(self, enabled)
end

function ConstructionBeam:SetTarget(targetUnit)
    if self.targetUnit ~= targetUnit then
        self.scoConstructionHop = nil
        SCO_ConstructionContact.Clear(self)
    end
    if not SCO_FieldFixConstructionBeamValidLocalID(self.localId)
        or targetUnit == nil
        or not SCO_FieldFixConstructionBeamValidLocalID(targetUnit.localId)
    then
        SCO_FieldFixConstructionBeamClear(self)
        return
    end
    return SCO_FieldFixStockConstructionBeamSetTarget(self, targetUnit)
end

function ConstructionBeam:RemoveTarget()
    SCO_ConstructionContact.Clear(self)
    self.scoConstructionHop = nil
    self.scoConstructionHopEnabled = false
    if SCO_FieldFixConstructionBeamValidLocalID(self.localId) then
        SCO_FieldFixStockConstructionBeamSetEnabled(self, false)
    end
    return SCO_FieldFixStockConstructionBeamRemoveTarget(self)
end

function ConstructionBeam:Update()
    if not SCO_FieldFixConstructionBeamValidLocalID(self.localId) then
        SCO_ConstructionContact.Clear(self)
        self.targetUnit = nil
        self.scoConstructionHop = nil
        self.scoConstructionHopEnabled = false
        return
    end
    local target = self.targetUnit
    if target == nil
        or not SCO_FieldFixConstructionBeamValidLocalID(target.localId)
    then
        SCO_FieldFixConstructionBeamClear(self)
        return
    end
    local parentLocalId = {}
    Engine.GetLocalEntityParent(self.localId, parentLocalId)
    if not SCO_FieldFixConstructionBeamValidLocalID(parentLocalId) then
        SCO_FieldFixConstructionBeamClear(self)
        return
    end
    local hopState
    if self.scoConstructionHopEnabled and self.scoConstructionBuilder then
        hopState = self.scoConstructionHop
        if not hopState then
            hopState = {emitterId = self.localId, uefSliceIndex = self.scoUefSliceIndex}
            self.scoConstructionHop = hopState
        end
    end
    local origin = self:GetPosition()
    local point = target.SCO_GetConstructionTargetPosition
        and target:SCO_GetConstructionTargetPosition(origin, hopState, self.scoConstructionBuilder)
    local height, offset = self.targetUnitHeight, self.targetUnitOffset
    if point then
        local root = target:GetPosition()
        self.targetUnitHeight = 0
        self.targetUnitOffset = EngineClasses.float3(point.x - root.x, point.y - root.y, point.z - root.z)
    end
    local result = SCO_FieldFixStockConstructionBeamUpdate(self)
    self.targetUnitHeight, self.targetUnitOffset = height, offset
    SCO_ConstructionContact.Update(self, self.scoConstructionBuilder, target, point, origin,
        self.scoConstructionHopEnabled)
    return result
end

return {
    CreateConstructionBeam = CreateConstructionBeam
}