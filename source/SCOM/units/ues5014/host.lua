-- ues5014: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultEDA.lua").HostEDALandFactory
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ues5014_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.

-- The gateway uses the plain faction factory base.
Import("common/systems/scoFactoryEgress.lua").Install(UnitClass)
