-- ugl4002: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardFaCybranMegalith
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugl4002_host", Base)

local TreeKnockdown = Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown
local treeFootprint = {left = -4.35, right = 4.35, rear = -4.25, front = 3.87, bottom = 0, top = 4.05, rootHeight = -0.07806315612792969}

local function HoldConstructionPose(unit)
    local animation = unit.tp.visuals.animations.awake
    assert(animation and animation.id and animation.clipName == "Awake",
        "Megalith construction pose requires its source Awake clip")
    -- The existing exact-time bridge freezes both native animation clocks.
    local result = Engine.PlayAnimation(unit.id, animation.id, -10000)
    assert(result == EngineErrorCode.Success,
        "Megalith construction pose sampling failed")
end

function UnitClass:SetupAnimations()
    Base.SetupAnimations(self)
    if not self:IsCompleted() then HoldConstructionPose(self) end
end

function UnitClass:UpdateAnimations()
    if self.dead or self.scoMegalithTerminal then return end
    if not self:IsCompleted() then
        HoldConstructionPose(self)
        return
    end
    local result = Base.UpdateAnimations(self)
    TreeKnockdown.Update(self, treeFootprint)
    return result
end
