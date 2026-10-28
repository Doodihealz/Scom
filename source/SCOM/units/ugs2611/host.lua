-- ugs2611: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardEnergyGenerator
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugs2611_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
