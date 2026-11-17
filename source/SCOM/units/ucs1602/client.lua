-- ucs1602: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultChosen.lua").ClientAeonPortStorage
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucs1602_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.

-- AnimStorageLevel authored its stroke in parent Z. The imported Root has
-- only a yaw, so parent Y is vertical; the bone's own -90-degree rotation
-- does not rotate its localPosition. Keep the exact native fill-clock owner.
local restY = -0.41268001556397954
local restZ = -1.7591923071908357e-08
local stroke = 0.0615
function UnitClass:RenderUpdateBeams(...)
    local result = Base.RenderUpdateBeams(self, ...)
    if self.dead or self.deleted or self:IsPlacementGhost() or not self:IsCompleted() then
        return result
    end
    local bone = self:GetBoneId("B01")
    if not Engine.IsValidLocalID(bone) then return result end
    local code, position = Engine.GetLocalEntityLocalPosition(bone)
    if code ~= EngineErrorCode.Success then
        error("Aeon mass storage: cannot read B01 position: " .. tostring(code))
    end
    local lift = position.z - restZ
    -- Native animation may leave an already-corrected pose between samples.
    -- A zero horizontal stroke needs no second write or accumulated offset.
    if math.abs(lift) > 0.0000001 then
        lift = math.max(0, math.min(stroke, lift))
        code = Engine.SetLocalEntityLocalPosition(bone,
            EngineClasses.float3(position.x, restY + lift, restZ))
        if code ~= EngineErrorCode.Success then
            error("Aeon mass storage: cannot raise B01: " .. tostring(code))
        end
    end
    return result
end
