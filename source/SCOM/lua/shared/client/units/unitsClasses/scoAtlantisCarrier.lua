-- Mobile submarine presentation; the generic factory HUD uses the FACTORY tag.
local Submarine = Import("client/units/unitsClasses/unitsDefault.lua").ClientSubmarineUnit
ClientSCOMAtlantisCarrier = Class("SCOMAtlantisCarrier", Submarine)
function ClientSCOMAtlantisCarrier:CanShowIdleAdornment() return true end

-- SCOM source surface-carrier production 1.0.0.
-- The existing source naval classes retain every visual and weapon hook.
ClientSCOMAeonCarrier = Class("SCOMAeonCarrier",
    Import("client/units/unitsClasses/unitsDefaultChosen.lua").ClientAeonPortNavalUnit)
ClientSCOMSeraphimCarrier = Class("SCOMSeraphimCarrier",
    Import("client/units/unitsClasses/unitsDefaultSeraphim.lua").ClientSeraphimNavalUnit)
function ClientSCOMAeonCarrier:CanShowIdleAdornment() return true end
function ClientSCOMSeraphimCarrier:CanShowIdleAdornment() return true end

ClientSCOMCybranCarrier = Class("SCOMCybranCarrier",
    Import("client/units/unitsClasses/unitsDefaultGuard.lua").ClientGuardNavalUnit)
function ClientSCOMCybranCarrier:CanShowIdleAdornment() return true end
