-- ucs1612: host behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("host/units/unitsClasses/unitsDefaultChosen.lua").HostAeonPortStorage
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_ucs1612_host", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.
