-- ucs4102: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultChosen.lua").ClientAeonPortStructure
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucs4102_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
