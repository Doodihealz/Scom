-- ugl4011: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardScathis
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugl4011_host", Base)
local TreeKnockdown = Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown
local treeFootprint = {left = -3.35, right = 3.35, rear = -3.5, front = 4.06, bottom = 0, top = 2, rootHeight = 0.01}

function UnitClass:UpdateAnimations(...)
    local result = Base.UpdateAnimations(self, ...)
    TreeKnockdown.Update(self, treeFootprint)
    return result
end
