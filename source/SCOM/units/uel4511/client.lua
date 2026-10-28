-- Fatboy (uel4511): complete client implementation.
local EDA = Import("client/units/unitsClasses/unitsDefaultEDA.lua")
local EDALandUnit = EDA.ClientEDALandUnit
local EDALandFactory = EDA.ClientEDALandFactory
local EDAUefLandFactory = EDA.ClientEDAUefLandFactory
-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0
-- Reuse the imported UEF endpoint-beam implementation when the structure
-- module precedes this one. Mobile overrides below still suppress tarmac,
-- permanent-grid, structure selection, and structure intel behavior.
local FatboyClientFactoryBase = EDAUefLandFactory or EDALandFactory

local function FatboySetLocalVolumeColliderEnabled(globalId, enabled)
    local localId = EngineClasses.LocalID()
    local errorCode = Engine.GetGlobalEntityPairedLocalID(globalId, localId)
    if errorCode == EngineErrorCode.Success and Engine.IsValidLocalID(localId) then
        Engine.SetVolumeColliderEnabled(localId, enabled)
    end
end

local ClientEDAFatboyMobileFactory = Class("EDAFatboyMobileFactory", FatboyClientFactoryBase)
local EDAFatboyMobileFactory = ClientEDAFatboyMobileFactory

function EDAFatboyMobileFactory:CreateTarmac()
end

function EDAFatboyMobileFactory:OnPromoteToUnit()
    EDALandUnit.OnPromoteToUnit(self)
end

function EDAFatboyMobileFactory:OnCompleted()
    EDALandUnit.OnCompleted(self)
end

function EDAFatboyMobileFactory:IsHighlightable()
    return EDALandUnit.IsHighlightable(self)
end

function EDAFatboyMobileFactory:IsSelectable()
    return EDALandUnit.IsSelectable(self)
end

function EDAFatboyMobileFactory:OnIntelHidden()
    EDALandUnit.OnIntelHidden(self)
end

function EDAFatboyMobileFactory:OnIntelVision()
    EDALandUnit.OnIntelVision(self)
end

function EDAFatboyMobileFactory:OnIntelRadar()
    EDALandUnit.OnIntelRadar(self)
    self:RecalculateConstructionBeamState()
end

function EDAFatboyMobileFactory:ClientOnStopBuilding()
    local targetUnit = self.buildTarget
    FatboyClientFactoryBase.ClientOnStopBuilding(self)
    if targetUnit and not targetUnit:IsCompleted() then
        -- Host construction ownership persists across a production pause.
        targetUnit:SetSelectionEnabled(false)
        FatboySetLocalVolumeColliderEnabled(targetUnit.id, false)
    end
end

function EDAFatboyMobileFactory:OnDestroy(isDelete)
    -- This parent call owns endpoint-beam disposal. CreateTarmac and the intel
    -- overrides above keep its structure-only presentation inert.
    FatboyClientFactoryBase.OnDestroy(self, isDelete)
end

function EDAFatboyMobileFactory:OnDelete()
    FatboyClientFactoryBase.OnDelete(self)
end

local Base = ClientEDAFatboyMobileFactory
UnitClass = Import("scom/units/behavior.lua").Derive("SCOMUel4511client", Base)
local Library = {Engine = Engine, EngineClasses = EngineClasses, EngineErrorCode = EngineErrorCode,
    TreeKnockdown = Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown}
function UnitClass:OnCompleted(...)
    return Base.OnCompleted(self, ...)
end

function UnitClass:GetFactoryRallyDisplayPoint(state)
    if state.fatboyMovementLocked ~= true then
        return nil
    end

    -- Match the factory library's rear clearance move, relative to this hull.
    local engine = Library.Engine
    local vector = Library.EngineClasses.float3
    local rear = engine.QuaternionRotateVector(self:GetOrientation(), vector(0, 0, -15))
    local origin = self:GetPosition()
    local point = vector(origin.x + rear.x, origin.y + rear.y, origin.z + rear.z)
    local errorCode, height = engine.SampleTerrainHeight(vector(point.x, 0, point.z))
    if errorCode == Library.EngineErrorCode.Success then
        point.y = height
    end
    return point, state.hasExplicit and state.point or nil
end
