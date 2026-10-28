-- ugl4001: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardMonkeylord
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugl4001_host", Base)
local TreeKnockdown = Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown
local treeFootprint = {left = -3, right = 3, rear = -2.74, front = 4.06, bottom = 0, top = 4.35, rootHeight = 2.060880007743835}

function UnitClass:UpdateAnimations(...)
    local result = Base.UpdateAnimations(self, ...)
    TreeKnockdown.Update(self, treeFootprint)
    return result
end
