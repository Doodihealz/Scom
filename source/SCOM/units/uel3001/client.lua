-- uel3001: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultEDA.lua").ClientEDALandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uel3001_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
