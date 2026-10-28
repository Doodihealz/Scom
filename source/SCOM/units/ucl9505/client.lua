-- ucl9505: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultChosen.lua").ClientChosenLandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucl9505_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
