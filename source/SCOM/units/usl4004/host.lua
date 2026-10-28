-- usl4004: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultSeraphim.lua").HostSeraphimLandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_usl4004_host", Base)
local TreeKnockdown = Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown
local treeFootprint = {left = -3, right = 3, rear = -3, front = 3, bottom = 0, top = 8.8, rootHeight = 0.01}

function UnitClass:UpdateAnimations(...)
    local result = Base.UpdateAnimations(self, ...)
    TreeKnockdown.Update(self, treeFootprint)
    return result
end
