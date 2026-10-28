-- usn2002: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultSeraphim.lua").ClientSeraphimNavalUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_usn2002_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
