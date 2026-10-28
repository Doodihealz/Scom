-- ucn5001: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultChosen.lua").ClientChosenNavalUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucn5001_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
