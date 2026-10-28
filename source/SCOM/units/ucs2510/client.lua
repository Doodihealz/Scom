-- ucs2510: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultChosen.lua").ClientAeonPortLandFactory
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucs2510_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
