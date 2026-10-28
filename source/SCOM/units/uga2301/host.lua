-- uga2301: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardAirUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uga2301_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
