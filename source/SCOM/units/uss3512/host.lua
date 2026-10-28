-- uss3512: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultSeraphim.lua").HostSeraphimAirFactory
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uss3512_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
