-- ucl4004: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultChosen.lua").HostAeonPortLandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucl4004_host", Base)
local TreeKnockdown = Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown
local treeFootprint = {left = -3, right = 3, rear = -3, front = 3, bottom = 0, top = 6.8, rootHeight = 4.410456237792968}

function UnitClass:UpdateAnimations(...)
    local result = Base.UpdateAnimations(self, ...)
    TreeKnockdown.Update(self, treeFootprint)
    return result
end
