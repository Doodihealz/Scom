-- ucl4003: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultChosen.lua").HostAeonPortNavalUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucl4003_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
