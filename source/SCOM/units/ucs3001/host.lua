-- ucs3001: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultChosen.lua").HostAeonPortStructure
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucs3001_host", Base)
-- Native acquisition filters layers/intel but ignores the artillery minimum
-- range, repeatedly preferring nearby enemies that lie outside the source arc.
function UnitClass:__init(...)
    Base.__init(self, ...)
    local weapon = self:GetWeapon(1)
    local previous = weapon.CanShootAt
    function weapon:CanShootAt(target)
        if not previous(self, target) then return false end
        local origin, destination = self.unit:GetPosition(), target:GetPosition()
        local x, z = destination.x - origin.x, destination.z - origin.z
        local distanceSquared = x * x + z * z
        return distanceSquared >= self.tp.rangeMin * self.tp.rangeMin
            and distanceSquared <= self.tp.rangeMax * self.tp.rangeMax
    end
end
