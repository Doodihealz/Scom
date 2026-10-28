-- ugs4903: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultGuard.lua").ClientGuardMegalithEgg
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugs4903_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
