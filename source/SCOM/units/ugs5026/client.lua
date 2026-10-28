-- ugs5026: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultGuard.lua").ClientGuardEngineeringStation
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugs5026_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
