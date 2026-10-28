-- ues1601: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultEDA.lua").ClientEDAImportedAnimatedAlloyExtractor
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ues1601_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
