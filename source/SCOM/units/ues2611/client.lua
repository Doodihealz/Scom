-- ues2611: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultEDA.lua").ClientEDAEnergyGenerator
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ues2611_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
