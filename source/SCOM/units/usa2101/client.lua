-- usa2101: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultSeraphim.lua").ClientSeraphimAirUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_usa2101_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
