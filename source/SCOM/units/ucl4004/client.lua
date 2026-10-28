-- ucl4004: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultChosen.lua").ClientAeonPortLandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucl4004_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
