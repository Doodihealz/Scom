-- ugn5002: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardNavalUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugn5002_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
