-- usl0000: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultSeraphim.lua").ClientSeraphimCommander
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_usl0000_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
