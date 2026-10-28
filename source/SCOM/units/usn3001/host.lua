-- usn3001: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultSeraphim.lua").HostSeraphimNavalUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_usn3001_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
