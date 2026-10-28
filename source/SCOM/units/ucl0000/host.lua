-- ucl0000: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultChosen.lua").HostChosenCommander
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucl0000_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
