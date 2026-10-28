local GarbageBag = Import("common/systems/garbageBag.lua").GarbageBag
local Callbackable = Import("common/systems/callbacks.lua").Callbackable

local Engine = Engine
local NewThread = NewThread
local mathMax = math.max

---@class HostEntity: Callbackable
---@field id GlobalID
---@field garbage GarbageBag
HostEntity = Class("Entity", Callbackable)

---@param id globalId Global ID set by the engine.
---@protected
function HostEntity:__init(id)
    Callbackable.__init(self)
    self.garbage = GarbageBag()
    self.id = id
    --Log("New Host Entity created: " .. id)
end

function HostEntity:Delete()
    self.garbage:Delete()
    self.garbage = nil

    self.deleted = true
end

---Creates a new thread that will run on the entity.
---This thread will be destroyed with the entity.  
---**The entity class is passed as the first argument into the function.**
---@param fn function Function to run
---@param ... any Parameters to pass into the function, **after** the entity class.
---@return thread thread Newly created thread.
function HostEntity:NewThread(fn, ...)
    local thread = NewThread(fn, self, ...)
    self.garbage:Add(thread)
    return thread
end



---Returns entity world position
---@return float3 position
function HostEntity:GetPosition()
    local _, position = Engine.GetGlobalEntityWorldPosition(self.id)
    return position
end

---Sets entity world position
---@param position float3
function HostEntity:SetPosition(position)
    Engine.SetGlobalEntityPosition(self.id, position)
end

---Returns entity world orientation
---@return quaternion orientation
function HostEntity:GetOrientation()
    local orientation = EngineClasses.quaternion()
    Engine.GetGlobalEntityWorldRotation(self.id, orientation)
    return orientation
end

---Set entity world orientation
---@param orientation quaternion
function HostEntity:SetOrientation(orientation)
    Engine.SetGlobalEntityLocalRotation(self.id, orientation)
end



-- Health

function HostEntity:GetHealth()
    --Log("GetUnitCurrentHealth with ID: " .. self.id)
    local _, health = Engine.GetHealth(self.id)
    return health
end

function HostEntity:SetHealth(newHp)
    Engine.SetHealth(self.id, mathMax(newHp, 1))
end

function HostEntity:GetMaxHealth()
    --Log("GetUnitMaxHealth with ID: " .. self.id)
    local _, maxHealth = Engine.GetMaxHealth(self.id)
    return maxHealth
end

function HostEntity:SetMaxHealth(newMaxHP)
    Engine.SetMaxHealth(self.id, mathMax(newMaxHP, 1))
end

-- @return regen In HP/s.
function HostEntity:GetHealthRegen()
    --Log("GetUnitRegenRate with ID: " .. self.id)
    local _, healthRegen = Engine.GetHealthRegen(self.id)
    return healthRegen
end

-- @param newRegen In HP/s.
function HostEntity:SetHealthRegen(newRegen)
    Engine.SetHealthRegen(self.id, mathMax(newRegen, 0))
end

function HostEntity:SetRegenEnabled(bool)
    Engine.SetHealthRegenEnabled(self.id, bool)
end

function HostEntity:IsRegenEnabled()
    local _, healthRegenEnabled = Engine.GetHealthRegenEnabled(self.id)
    return healthRegenEnabled
end

function HostEntity:AdjustHealth(delta)
    local maxHP = self:GetMaxHealth()
    local newHP = self:GetHealth() + delta
    if newHP > maxHP then
        newHP = maxHP
    end
    self:SetHealth(newHP)
end

-- Supreme Commander Overhaul host orientation API correction 1.2.0
