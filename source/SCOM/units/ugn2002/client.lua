-- ugn2002: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultGuard.lua").ClientGuardNavalUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugn2002_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
