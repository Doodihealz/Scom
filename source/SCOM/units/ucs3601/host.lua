-- ucs3601: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultChosen.lua").HostAeonPortAlloyExtractor
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucs3601_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
