-- ues3511: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultEDA.lua").HostEDAUefLandFactory
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ues3511_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
