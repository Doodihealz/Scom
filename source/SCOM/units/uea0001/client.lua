-- uea0001: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultEDA.lua").ClientEDAAirUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uea0001_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
