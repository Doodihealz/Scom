-- ugl1701: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultGuard.lua").ClientGuardLandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugl1701_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
