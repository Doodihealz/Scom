-- uen5001: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultEDA.lua").HostEDANavalUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uen5001_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
