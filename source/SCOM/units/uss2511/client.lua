-- uss2511: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultSeraphim.lua").ClientSeraphimLandFactory
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uss2511_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
