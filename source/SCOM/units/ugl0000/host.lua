-- ugl0000: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardCommander
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugl0000_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
