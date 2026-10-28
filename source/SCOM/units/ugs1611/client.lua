-- ugs1611: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultGuard.lua").ClientGuardEnergyGenerator
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugs1611_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
