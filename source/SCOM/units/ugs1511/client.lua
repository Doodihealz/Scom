-- ugs1511: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultGuard.lua").ClientGuardCybranAnimatedLandFactory
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugs1511_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
