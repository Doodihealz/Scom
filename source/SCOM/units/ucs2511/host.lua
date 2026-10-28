-- ucs2511: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultChosen.lua").HostAeonPortLandFactory
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucs2511_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
