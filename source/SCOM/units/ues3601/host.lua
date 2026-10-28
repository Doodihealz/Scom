-- ues3601: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultEDA.lua").HostEDAImportedAnimatedAlloyExtractor
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ues3601_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
