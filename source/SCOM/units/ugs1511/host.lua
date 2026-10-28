-- ugs1511: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardCybranAnimatedLandFactory
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugs1511_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
