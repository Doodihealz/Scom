-- ucs3611: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultChosen.lua").ClientAeonPortEnergyGenerator
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucs3611_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
