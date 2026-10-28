-- ugn1002: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefault.lua").ClientSubmarineUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugn1002_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
