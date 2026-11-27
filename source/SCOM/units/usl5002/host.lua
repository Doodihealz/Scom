-- usl5002: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultSeraphim.lua").HostSeraphimLandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_usl5002_host", Base)

function UnitClass:SetUpTarget()
    Base.SetUpTarget(self)
    self:SetCanTakeDamage(false)
    self:SetCanBeKilled(false)
end

function UnitClass:SetTargetable()
    Base.SetTargetable(self, false)
end

function UnitClass:SetCanTakeDamage()
    Base.SetCanTakeDamage(self, false)
end
