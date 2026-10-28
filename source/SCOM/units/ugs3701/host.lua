-- ugs3701: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardStructure
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ugs3701_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
