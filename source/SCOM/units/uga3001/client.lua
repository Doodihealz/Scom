-- uga3001: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultGuard.lua").ClientGuardAirUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uga3001_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
