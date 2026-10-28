-- ucs1614: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultChosen.lua").HostAeonPortEnergyGenerator
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucs1614_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
