-- uss2711: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultSeraphim.lua").HostSeraphimStructure
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uss2711_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
