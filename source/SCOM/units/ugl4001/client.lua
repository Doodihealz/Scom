-- ugl4001: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultGuard.lua").ClientGuardMonkeylord
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugl4001_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
