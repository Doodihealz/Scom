-- ucs3601: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultChosen.lua").ClientAeonPortAlloyExtractor
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucs3601_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
