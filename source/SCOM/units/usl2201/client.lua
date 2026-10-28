-- usl2201: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultSeraphim.lua").ClientSeraphimLandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_usl2201_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
