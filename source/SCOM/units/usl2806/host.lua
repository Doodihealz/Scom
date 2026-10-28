-- usl2806: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultSeraphim.lua").HostSeraphimLandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_usl2806_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
