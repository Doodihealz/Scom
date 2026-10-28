-- uel2201: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultEDA.lua").ClientEDAImportedFaLandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uel2201_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
