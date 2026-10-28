-- ucl3501: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultChosen.lua").ClientAeonPortEngineer
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucl3501_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
