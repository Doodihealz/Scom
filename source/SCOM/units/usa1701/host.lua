-- usa1701: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultSeraphim.lua").HostSeraphimAirUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_usa1701_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
