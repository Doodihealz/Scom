-- ugl2002: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardLandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugl2002_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
