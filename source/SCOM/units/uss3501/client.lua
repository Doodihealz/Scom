-- uss3501: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultSeraphim.lua").ClientSeraphimEngineeringStation
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uss3501_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
