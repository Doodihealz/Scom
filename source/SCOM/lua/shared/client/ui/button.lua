local EngineUIEventManager = Import("client/ui/engineUIEventManager.lua")

---@class Button
---@field private buttonID UIElementID
---@field private panelType UIPanelType
---@field private leftClickFunction fun(data: UIElementClickEventCallback, payload: any)
---@field private rightClickFunction fun(data: UIElementClickEventCallback, payload: any)
---@field private hoverEnterFunction fun(data: UIElementHoverEventCallback, payload: any)
---@field private hoverExitFunction fun(data: UIElementHoverEventCallback, payload: any)
---@field private payload any
---@field private isDisabled boolean
---@field private isActive boolean
Button = Class("Button")

--- Create a new button on a panel.
---@param panelType UIPanelType
---@param buttonData UIButtonData
---@param leftClickFunction fun(data: UIElementClickEventCallback, payload: any)
---@param rightClickFunction fun(data: UIElementClickEventCallback, payload: any)
---@param hoverEnterFunction fun(data: UIElementHoverEventCallback, payload: any)
---@param hoverExitFunction fun(data: UIElementHoverEventCallback, payload: any)
---@param payload any
function Button:__init(panelType, buttonData, leftClickFunction, rightClickFunction, hoverEnterFunction, hoverExitFunction, payload)
    self.buttonID = Engine.UI_AddButton(panelType, buttonData)
    self.panelType = panelType
    self.leftClickFunction = leftClickFunction
    self.rightClickFunction = rightClickFunction
    self.hoverEnterFunction = hoverEnterFunction
    self.hoverExitFunction = hoverExitFunction
    self.payload = payload

    self.isDisabled = false
    self.isActive = false

    EngineUIEventManager.OnButtonLeftClick[self.buttonID.id] = function(data) self:OnLeftClick(data) end
    EngineUIEventManager.OnButtonRightClick[self.buttonID.id] = function(data) self:OnRightClick(data) end
    EngineUIEventManager.OnButtonHoverEnter[self.buttonID.id] = function(data) self:OnHoverEnter(data) end
    EngineUIEventManager.OnButtonHoverExit[self.buttonID.id] = function(data) self:OnHoverExit(data) end
end

function Button:Clear()
    EngineUIEventManager.OnButtonLeftClick[self.buttonID.id] = nil
    EngineUIEventManager.OnButtonRightClick[self.buttonID.id] = nil
    EngineUIEventManager.OnButtonHoverEnter[self.buttonID.id] = nil
    EngineUIEventManager.OnButtonHoverExit[self.buttonID.id] = nil
end

function Button:SetActive(active)
    self.isActive = active
    Engine.UI_SetButtonActive(self.buttonID, active)
end

function Button:GetActive()
    return self.isActive
end

function Button:SetDisabled(disabled)
    self.isDisabled = disabled
    Engine.UI_SetButtonDisabled(self.buttonID, disabled)
end

function Button:GetDisabled()
    return self.isDisabled
end

function Button:OnLeftClick(data)
    if self.leftClickFunction then
        self.leftClickFunction(data, self.payload)
    end
end

function Button:OnRightClick(data)
    if self.rightClickFunction then
        self.rightClickFunction(data, self.payload)
    end
end

function Button:OnHoverEnter(data)
    if self.hoverEnterFunction then
        self.hoverEnterFunction(data, self.payload)
    end
end

function Button:OnHoverExit(data)
    if self.hoverExitFunction then
        self.hoverExitFunction(data, self.payload)
    end
end

-- Supreme Commander Overhaul commander enhancements 1.0.0
-- Sanctuary pools construction-button GameObjects, but UnitButtonElement's
-- InitializeDefaultValues does not restore Button.interactable. Reset the
-- transient disabled state before a Lua Button is returned to that pool.
local SCOCommanderEnhancementButtonPoolEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderEnhancementButtonPoolMarker = rawget(
    SCOCommanderEnhancementButtonPoolEnvironment,
    "SCO_CommanderEnhancementButtonPoolInstalled")
if SCOCommanderEnhancementButtonPoolMarker ~= nil
    and SCOCommanderEnhancementButtonPoolMarker ~= "1.0.0"
then
    error("Unsupported SCOM commander-enhancement button-pool marker "
        .. tostring(SCOCommanderEnhancementButtonPoolMarker))
end
if SCOCommanderEnhancementButtonPoolMarker == nil then
    if type(Button) ~= "table"
        or type(Button.Clear) ~= "function"
        or type(Button.GetDisabled) ~= "function"
        or type(Button.SetDisabled) ~= "function"
    then
        error("SCOM commander enhancements could not resolve the native Button lifecycle")
    end

    local SCOPreviousButtonClear = Button.Clear
    function Button:Clear(...)
        if self:GetDisabled() == true then
            self:SetDisabled(false)
        end
        return SCOPreviousButtonClear(self, ...)
    end

    rawset(
        SCOCommanderEnhancementButtonPoolEnvironment,
        "SCO_CommanderEnhancementButtonPoolInstalled",
        "1.0.0")
end
