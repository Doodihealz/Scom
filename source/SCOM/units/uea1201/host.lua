-- uea1201: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultEDA.lua").HostEDAAirUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uea1201_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
