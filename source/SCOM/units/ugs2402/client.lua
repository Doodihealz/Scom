-- ugs2402: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultGuard.lua").ClientGuardStructure
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugs2402_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
