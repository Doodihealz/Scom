-- uca2101: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultChosen.lua").ClientAeonPortAirUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uca2101_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
