-- uss2611: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultSeraphim.lua").HostSeraphimEnergyGenerator
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uss2611_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
