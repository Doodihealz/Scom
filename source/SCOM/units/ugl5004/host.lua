-- ugl5004: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardEngineer
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugl5004_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
