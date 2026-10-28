-- usa4011: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultSeraphim.lua").HostSeraphimAirUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_usa4011_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.

-- The current native Strafe goal owns overflight, runout and reentry, including
-- passes where the source release gate rejects the bomb or it is still reloading.
-- Pattern None stops on engagement in this build and cannot own a bomber run.
local HostUnit = Import("host/units/unitsClasses/unitsBaseClass.lua").HostUnit

function UnitClass:GetPatternID(situation)
    if situation == "attack" and self.isAirborne then
        return HostUnit.GetPatternID(self, situation)
    end
    return Base.GetPatternID(self, situation)
end

function UnitClass:GetAttackRadius(patternID, range)
    if self:GetPatternMode(patternID) == "Strafe" then
        return self.tp.additions.scoFaBomberAttackRun.sourceBreakOffTrigger
    end
    return Base.GetAttackRadius(self, patternID, range)
end

function UnitClass:SCO_FaBomberOnBombReleased(projectileID)
    -- Keep the native pursuit target. The previous release waypoint cleared it
    -- and competed with the Strafe state machine. Weapon release is unchanged.
    return false
end
