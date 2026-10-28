-- ucs2803: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultChosen.lua").ClientAeonPortNavalUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucs2803_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
