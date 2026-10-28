-- ugs1513: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardFaCybranNavalFactory
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugs1513_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
