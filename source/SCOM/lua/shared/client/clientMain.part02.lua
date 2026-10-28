
-- Sanctuary Construction Plans 2.1.0
local SCO_StockOnRenderUpdate = _G.OnRenderUpdate

function _G.OnRenderUpdate()
    local stockSucceeded, stockError = pcall(SCO_StockOnRenderUpdate)
    local scoBlueprintPlacement = Import("client/input/scoBlueprintPlacement.lua")
    scoBlueprintPlacement.UpdatePreview()
    local arrival = _G.SCO_CommanderArrivalVisuals
    if stockSucceeded and arrival then arrival.Update() end
    if not stockSucceeded then
        error(stockError)
    end
end
-- SCO_CommanderArrivalClientReset_v1
local SCOArrivalStockClientInit = Init
function Init()
    local arrival = _G.SCO_CommanderArrivalVisuals
    if arrival then arrival.Reset() end
    return SCOArrivalStockClientInit()
end
