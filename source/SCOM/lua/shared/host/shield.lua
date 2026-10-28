local HostEntity = Import("host/entity.lua").HostEntity
local IntelCommands  = Import("common/commands/definitions/intel.lua")
local ShieldCommands = Import("common/commands/definitions/shields.lua")
local HostCollider = Import("host/managers/colliders/collider.lua")
local IntelLayer = Import("host/managers/intel/intelLayer.lua").IntelLayer

---@class HostShield: HostEntity
---@field army HostArmy
---@field tp table
---@field owner HostUnit
---@field canTakeDamage boolean
---@field enabled boolean
---@field intelLayer IntelLayer Tracks which armies can see the shield.
---@field isEnableable boolean
---@field rechargeHPRatio number
---@field regenAfterDelayThread thread|nil after damage there is a wait, regen is disabled for a short time
---@field rechargeThread thread|nil shield pops there is a wait, then shield comes online at partial health and starts regen
HostShield = Class("Shield", HostEntity)

--[[
specs = {
    type = string,              -- "Bubble" - specified with size, has it's own hitbox (hitsphere)
                                -- "Personal" - uses unit's hitbox
    bone = string,              -- name of the bone to attach the shield to or root bone
    max = float,                -- maximum HP
    value = float,              -- starting HP, -1 to use the max value
    rechargeTime = float,       -- how many second it takes to get the shield back up after being knocked down
    rechargeHPRatio = float,    -- 0.0 - 1.0 Ratio from max HP the shiled will be enabled with when it's recharged.
    regen = number,             -- how much HP to restore per second
    regenDelay = float,         -- how many seconds after last hit to start regen
    size = number,              -- radius of the bubble shield
    offset = {x, y, z}          -- offset the centre of the shield from the owner position, Default is x = 0, y = 0, z = 0
}
--]]

---@param id GlobalID
---@param army HostArmy
---@param owner HostUnit
---@param tp ShieldInfo
function HostShield:__init(id, army, owner, tp)
    HostEntity.__init(self, id)

    self.tp = tp
    self.army = army
    self.owner = owner

    self:SetUpIntel()

    self:SetRegenDelay(tp.regenDelay or 1)
    self:SetRechargeTime(tp.rechargeTime or 5)
    self.rechargeHPRatio = tp.rechargeHPRatio or 0.5

    self.canTakeDamage = true
    self.enabled = false
    self.isEnableable = nil
    self.isRecharging = false
    self.regenAfterDelayThread = nil -- after damage there is a wait, regen is disabled for a short time
    self.rechargeThread = nil -- when shield pops there is a wait, then shield comes online at partial health and starts regen

    self:SetEnableable(false)
end

function HostShield:SetUpIntel()
    local signatureColliderName = self.tp.boneName.."ShieldEntityIntelVisionSignatureCollider"
    local signatureCollider = HostCollider.CreateHostCollider(self.owner:GetBoneId(signatureColliderName))

    self.intelLayer = IntelLayer.new(signatureCollider, CollisionWorld.IntelVision, function(mask)
        IntelCommands.SetShieldIntel.Send(self.id, mask)
    end)

    self.intelLayer:SetOwnerArmy(self.army.id)
end

function HostShield:Delete()
    --Log(string.format("Shield id: %d deleted.", self.id))

    self.intelLayer:Delete()

    RemoveShield(self)

    HostEntity.Delete(self)
end

function HostShield:SetEnableable(value, skipRecharge)
    if value == self.isEnableable then return end

    self.isEnableable = value

    if value then
        if skipRecharge then
            self:SetEnabled(true)
            self:SetRegenEnabled(true)
            self:SetHealth(self:GetMaxHealth())
        else
            self.rechargeThread = self:NewThread(self.RechargeThread)
            self:SetRecharging(true)
        end
    else
        if self.rechargeThread then 
            KillThread(self.rechargeThread)
            self.rechargeThread = nil
            self:SetRecharging(false)
        end
        if self.regenAfterDelayThread then 
            KillThread(self.regenAfterDelayThread)
            self.regenAfterDelayThread = nil
        end
        self:SetHealth(0)
        self:SetEnabled(false)
        self:SetRegenEnabled(false)
    end
end

---@private Turn on or off the shield.
---@param value any
function HostShield:SetEnabled(value)
    if value == self.enabled then return end
    --Log(string.format("Shield id: %d set enabled: %s.", self.id, tostring(bool)))
    self.enabled = value
    ShieldCommands.EnableShield.Send(self.id, value)
end

function HostShield:IsEnabled()
    return self.enabled
end

function HostShield:SetRecharging(value)
    if value == self.isRecharging then return end

    self.isRecharging = value
    ShieldCommands.SetShieldRecharging.Send(self.id, value, self.rechargeTime)
end

-----------
-- HP Regen
-----------
function HostShield:SetRegenDelay(newRegenDelay)
    self.regenDelay = math.floor(newRegenDelay * 10)
    --Log(string.format("Shield id: %d regen delay set to: %d ticks.", self.id, self.regenDelay))
end

function HostShield:GetRegenDelay()
    return self.regenDelay
end

function HostShield:RegenAfterDelayThread()
    self:SetRegenEnabled(false)
    --Log(string.format("Shield id: %d regen timeout.", self.id))

    local waitTime = self.regenTimeOutTick - Tick
    repeat
        --Log("Waiting ticks: " .. waitTime)
        WaitTicks(waitTime)

        waitTime = self.regenTimeOutTick - Tick
    until waitTime <= 0

    self.regenAfterDelayThread = nil

    if self.rechargeThread then
        --Log(string.format("Shield id: %d would re-enable regen after timeout, but it's recharging now.", self.id))
        return
    end

    self:SetRegenEnabled(true)
    --Log(string.format("Shield id: %d re-enabling regen after timeout.", self.id))
end

---------
-- Damage
---------
---@param damage number
---@return number overflow Damage the shield did not absorb because it went down.
function HostShield:TakeDamage(damage)
    if not self.canTakeDamage then
        return 0
    elseif self.rechargeThread then
        Warn(string.format("Shield id: %d can't take damage, because it's recharging.", self.id.index))
        return damage
    end

    local currentHP = self:GetHealth()
    local newHP = currentHP - damage

    if newHP > 0 then
        --Log(string.format("Shield id: %d taken damage. New HP: %f.", self.id, newHP))
        self:SetHealth(newHP)

        if self.regenDelay > 0 then
            self.regenTimeOutTick = Tick + self.regenDelay
            if not self.regenAfterDelayThread then
                self.regenAfterDelayThread = self:NewThread(self.RegenAfterDelayThread)
            end
        end
    else
        if not self.rechargeThread then
            self:SetHealth(0)

            self:SetEnabled(false)
            self:SetRegenEnabled(false)

            self.rechargeThread = self:NewThread(self.RechargeThread)
            self:SetRecharging(true)
        end
    end

    return math.max(-newHP, 0)
end

function HostShield:SetCanTakeDamage(bool)
    self.canTakeDamage = bool
end

-------------
-- Recharging
-------------
function HostShield:SetRechargeTime(newRechargeTime)
    self.rechargeTime = newRechargeTime
end

function HostShield:GetRechargeTime()
    return self.rechargeTime
end

function HostShield:RechargeThread()
    local rechargeTime = self.rechargeTime

    --Log(string.format("Shield id: %d is going to recharge for %d seconds.", self.id, rechargeTime))
    WaitSeconds(rechargeTime)

    --Log(string.format("Shield id: %d is recharged.", self.id))
    self:SetEnabled(true)
    self:SetRegenEnabled(true)

    self:SetHealth(math.floor(self:GetMaxHealth() * self.rechargeHPRatio))

    self.rechargeThread = nil
    self:SetRecharging(false)
end


-- Supreme Commander Overhaul FA Direct Structures 1.0.0
-- URB4207 drives its Shaft from actual shield transitions, matching the
-- source OnShieldDisabled/OnShieldEnabled lifecycle across damage recharge,
-- manual toggle, and power loss. Delegate every non-target shield unchanged.
local SCO_DirectStructureStockShieldSetEnabled = HostShield.SetEnabled
function HostShield:SetEnabled(value)
    local wasEnabled = self.enabled
    SCO_DirectStructureStockShieldSetEnabled(self, value)
    if self.enabled == wasEnabled then
        return
    end
    local owner = self.owner
    if owner
        and owner.tpId == "ugs3401"
        and owner.SCOOnDirectShieldEnabledChanged then
        owner:SCOOnDirectShieldEnabledChanged(self.enabled)
    end
end

-- FA Support Structures Cache Patcher 1.1.2
-- FA uses ShieldRechargeTime after damage and restores the bubble at full
-- health. Manual disable and an energy stall preserve current HP and use
-- the independent ShieldEnergyDrainRechargeTime (5 seconds).
local SCO_FaSupportStockShieldSetEnableable = HostShield.SetEnableable
local SCO_FaSupportStockShieldSetEnabled = HostShield.SetEnabled

local function SCO_FaSupportShieldContract(shield)
    local owner = shield.owner
    return owner
        and owner.tp
        and owner.tp.additions
        and owner.tp.additions.faSupportShield
end

function HostShield:SCOFaSupportEnergyRechargeThread()
    local contract = SCO_FaSupportShieldContract(self)
    if not contract then
        self.rechargeThread = nil
        return
    end
    WaitSeconds(contract.energyDrainRechargeTime)
    if not self.isEnableable then
        self.rechargeThread = nil
        return
    end
    local maximum = self:GetMaxHealth()
    local restored = self.scoFaSupportOffHealth or maximum
    if restored <= 0 then
        restored = maximum
    end
    self:SetEnabled(true)
    self:SetRegenEnabled(true)
    self:SetHealth(math.min(restored, maximum))
    self.scoFaSupportOffHealth = nil
    self.rechargeThread = nil
end

function HostShield:SetEnableable(value, skipRecharge)
    local contract = SCO_FaSupportShieldContract(self)
    if not contract then
        return SCO_FaSupportStockShieldSetEnableable(self, value, skipRecharge)
    end
    if value == self.isEnableable then
        return
    end
    self.isEnableable = value
    if value then
        if skipRecharge then
            self:SetEnabled(true)
            self:SetRegenEnabled(true)
            self:SetHealth(self:GetMaxHealth())
            self.scoFaSupportOffHealth = nil
        else
            self.rechargeThread = self:NewThread(self.SCOFaSupportEnergyRechargeThread)
        end
        return
    end
    if self.rechargeThread then
        KillThread(self.rechargeThread)
        self.rechargeThread = nil
    end
    if self.regenAfterDelayThread then
        KillThread(self.regenAfterDelayThread)
        self.regenAfterDelayThread = nil
    end
    self.scoFaSupportOffHealth = self:GetHealth()
    self:SetEnabled(false)
    self:SetRegenEnabled(false)
end

function HostShield:SetEnabled(value)
    local wasEnabled = self.enabled
    SCO_FaSupportStockShieldSetEnabled(self, value)
    if self.enabled == wasEnabled then
        return
    end
    local owner = self.owner
    local contract = SCO_FaSupportShieldContract(self)
    if owner and contract then
        local upgrading = owner.scoFaSupportShieldUpgrading == true
        owner:SCOApplySupportShieldRotators(self.enabled or upgrading, upgrading)
    end
end
-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0
-- Exact UEL0303 UnitShield timing: damage pops require 60 paid seconds and
-- restore full health; manual/power shutdowns preserve health and require five
-- paid seconds.  An explicit damage state is required because Sanctuary clamps
-- Entity health above zero and therefore cannot identify a pop from HP alone.
local SCO_FaRoleStockShieldSetEnableable = HostShield.SetEnableable
local SCO_FaRoleStockShieldTakeDamage = HostShield.TakeDamage
local SCO_FaRoleStockShieldRechargeThread = HostShield.RechargeThread

local function SCO_FaTitanShieldContract(shield)
    return shield.owner
        and shield.owner.tpId == "uel3001"
        and shield.tp
        and shield.tp.scoFaTitanPersonalShield == true
end

local function SCO_FaTitanEnergySatisfaction(shield)
    local economy = shield.owner
        and shield.owner.army
        and shield.owner.army.economy
    local energy = economy
        and economy.resources
        and economy.resources.energy
    if not economy or not energy then
        return 0
    end
    if not economy.isEnergyDown then
        return 1
    end
    return math.max(0, math.min(energy.satisfaction or 0, 1))
end

local function SCO_FaTitanCancelTimers(shield)
    if shield.rechargeThread then
        KillThread(shield.rechargeThread)
        shield.rechargeThread = nil
    end
    if shield.regenAfterDelayThread then
        KillThread(shield.regenAfterDelayThread)
        shield.regenAfterDelayThread = nil
    end
end

local function SCO_FaTitanEnableRegen(shield, restoredHealth)
    if restoredHealth >= shield:GetMaxHealth() or shield.regenDelay <= 0 then
        shield:SetRegenEnabled(true)
        return
    end
    shield:SetRegenEnabled(false)
    shield.regenTimeOutTick = Tick + shield.regenDelay
    shield.regenAfterDelayThread =
        shield:NewThread(shield.RegenAfterDelayThread)
end

function HostShield:TakeDamage(damage)
    if not SCO_FaTitanShieldContract(self) then
        return SCO_FaRoleStockShieldTakeDamage(self, damage)
    end
    if self.canTakeDamage
        and not self.rechargeThread
        and damage >= self:GetHealth()
    then
        self.scoFaTitanRechargeKind = "Damage"
        self.scoFaTitanRechargeProgress = 0
        self.scoFaTitanOffHealth = nil
    end
    return SCO_FaRoleStockShieldTakeDamage(self, damage)
end

function HostShield:RechargeThread()
    if not SCO_FaTitanShieldContract(self) then
        return SCO_FaRoleStockShieldRechargeThread(self)
    end

    local rechargeKind = self.scoFaTitanRechargeKind or "Energy"
    local rechargeSeconds = rechargeKind == "Damage"
        and self.tp.scoDamageRechargeTime
        or self.tp.scoEnergyDrainRechargeTime
    local requiredProgress = rechargeSeconds * Constants.TickRate
    local progress = self.scoFaTitanRechargeProgress or 0

    while self.isEnableable and progress < requiredProgress do
        progress = math.min(
            progress + SCO_FaTitanEnergySatisfaction(self),
            requiredProgress)
        self.scoFaTitanRechargeProgress = progress
        WaitTicks(1)
    end

    if not self.isEnableable then
        self.rechargeThread = nil
        return
    end

    local maximum = self:GetMaxHealth()
    local restoredHealth = rechargeKind == "Damage"
        and maximum
        or math.min(self.scoFaTitanOffHealth or maximum, maximum)
    if restoredHealth <= 0 then
        restoredHealth = maximum
    end
    self:SetHealth(restoredHealth)
    self:SetEnabled(true)
    SCO_FaTitanEnableRegen(self, restoredHealth)
    self.scoFaTitanRechargeKind = nil
    self.scoFaTitanRechargeProgress = 0
    self.scoFaTitanOffHealth = nil
    self.rechargeThread = nil
end

function HostShield:SetEnableable(value, skipRecharge)
    if not SCO_FaTitanShieldContract(self) then
        return SCO_FaRoleStockShieldSetEnableable(self, value, skipRecharge)
    end
    if value == self.isEnableable then
        return
    end
    self.isEnableable = value

    if value then
        if skipRecharge then
            SCO_FaTitanCancelTimers(self)
            self:SetHealth(self:GetMaxHealth())
            self:SetEnabled(true)
            self:SetRegenEnabled(true)
            self.scoFaTitanRechargeKind = nil
            self.scoFaTitanRechargeProgress = 0
            self.scoFaTitanOffHealth = nil
        else
            self.scoFaTitanRechargeKind =
                self.scoFaTitanRechargeKind or "Energy"
            self.rechargeThread = self:NewThread(self.RechargeThread)
        end
        return
    end

    local damageRechargePending =
        self.scoFaTitanRechargeKind == "Damage"
    SCO_FaTitanCancelTimers(self)
    if not damageRechargePending then
        self.scoFaTitanRechargeKind = "Energy"
        self.scoFaTitanRechargeProgress = 0
        self.scoFaTitanOffHealth = math.min(
            self:GetHealth(), self:GetMaxHealth())
    end
    self:SetEnabled(false)
    self:SetRegenEnabled(false)
end

-- Supreme Commander Overhaul commander enhancements 1.0.0
-- FA commander shields distinguish damage-pop recharge from operational
-- (manual-toggle / power-loss) recovery. Sanctuary's stock HostShield uses one
-- timer and discards health when disabled, so this wrapper is strictly scoped
-- to the predeclared commander-enhancement shield entities.

local SCOCommanderShieldVersion = "1.0.1"
local SCOCommanderShieldEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderShieldMarker = rawget(
    SCOCommanderShieldEnvironment,
    "SCO_CommanderEnhancementShieldInstalled")
if SCOCommanderShieldMarker ~= nil
    and SCOCommanderShieldMarker ~= SCOCommanderShieldVersion
then
    error("Unsupported SCOM commander-enhancement shield marker "
        .. tostring(SCOCommanderShieldMarker))
end

if SCOCommanderShieldMarker == nil then
    if type(HostShield) ~= "table"
        or type(HostShield.SetUpIntel) ~= "function"
        or type(HostShield.SetEnableable) ~= "function"
        or type(HostShield.TakeDamage) ~= "function"
        or type(HostShield.RechargeThread) ~= "function"
    then
        error("SCOM commander enhancements could not resolve HostShield")
    end

    local SCOCommanderShieldPreviousSetUpIntel = HostShield.SetUpIntel
    local SCOCommanderShieldPreviousSetEnableable = HostShield.SetEnableable
    local SCOCommanderShieldPreviousTakeDamage = HostShield.TakeDamage
    local SCOCommanderShieldPreviousRechargeThread = HostShield.RechargeThread

    function HostShield:SetUpIntel()
        if not self.tp.entityName then
            return SCOCommanderShieldPreviousSetUpIntel(self)
        end

        -- Match the prefab loader's explicit name for distinct shields on one bone.
        local signatureName = self.tp.entityName.."IntelVisionSignatureCollider"
        local collider = HostCollider.CreateHostCollider(self.owner:GetBoneId(signatureName))
        self.intelLayer = IntelLayer.new(collider, CollisionWorld.IntelVision, function(mask)
            IntelCommands.SetShieldIntel.Send(self.id, mask)
        end)
        self.intelLayer:SetOwnerArmy(self.army.id)
    end

    local function SCOCommanderShieldContract(shield)
        return shield.tp
            and type(shield.tp.scoCommanderEnhancementShieldId) == "string"
    end

    local function SCOCommanderShieldEnergySatisfaction(shield)
        local economy = shield.owner
            and shield.owner.army
            and shield.owner.army.economy
        local energy = economy
            and economy.resources
            and economy.resources.energy
        if not economy or not energy then return 0 end
        if not economy.isEnergyDown then return 1 end
        return math.max(0, math.min(energy.satisfaction or 0, 1))
    end

    local function SCOCommanderShieldCancelTimers(shield)
        if shield.rechargeThread then
            KillThread(shield.rechargeThread)
            shield.rechargeThread = nil
        end
        if shield.regenAfterDelayThread then
            KillThread(shield.regenAfterDelayThread)
            shield.regenAfterDelayThread = nil
        end
        if shield.scoCommanderPowerWatchThread then
            KillThread(shield.scoCommanderPowerWatchThread)
            shield.scoCommanderPowerWatchThread = nil
        end
    end

    local function SCOCommanderShieldStartRecharge(shield, kind, health)
        if shield.rechargeThread then return end
        shield.scoCommanderRechargeKind = kind or "Energy"
        shield.scoCommanderRechargeProgress = 0
        shield.scoCommanderOffHealth = math.min(
            health or shield:GetHealth(),
            shield:GetMaxHealth())
        shield:SetEnabled(false)
        shield:SetRegenEnabled(false)
        shield.rechargeThread = shield:NewThread(shield.RechargeThread)
    end

    local function SCOCommanderShieldPowerWatch(shield, initialGrace)
        -- FA's OnState grants one second before beginning its continuous
        -- two-sample power monitor. The grace belongs to this shield-on
        -- transition; later EnergyDown events must not restart it.
        if initialGrace then WaitTicks(Constants.TickRate) end
        local badTicks = 0
        while shield.isEnableable and shield.enabled do
            -- Stock samples one tick after the OnState grace (and one tick
            -- between every later sample), not on the grace boundary itself.
            WaitTicks(1)
            if not shield.isEnableable or not shield.enabled then break end
            local economy = shield.owner
                and shield.owner.army
                and shield.owner.army.economy
            local energy = economy
                and economy.resources
                and economy.resources.energy
            local storageEmpty = energy == nil
                or type(energy.current) ~= "number"
                or energy.current <= 0
            if economy
                and economy.isEnergyDown
                and storageEmpty
                and SCOCommanderShieldEnergySatisfaction(shield) < 1
            then
                badTicks = badTicks + 1
            else
                badTicks = 0
            end
            if badTicks >= 2 then
                local health = shield:GetHealth()
                shield.scoCommanderPowerWatchThread = nil
                if shield.regenAfterDelayThread then
                    KillThread(shield.regenAfterDelayThread)
                    shield.regenAfterDelayThread = nil
                end
                SCOCommanderShieldStartRecharge(shield, "Energy", health)
                return
            end
        end
        shield.scoCommanderPowerWatchThread = nil
    end

    local function SCOCommanderShieldStartPowerWatch(shield, initialGrace)
        if shield.scoCommanderPowerWatchThread
            or not shield.isEnableable
            or not shield.enabled
        then
            return
        end
        shield.scoCommanderPowerWatchThread =
            shield:NewThread(
                SCOCommanderShieldPowerWatch,
                initialGrace == true)
    end

    local function SCOCommanderShieldEnableRegen(shield, restoredHealth)
        if restoredHealth >= shield:GetMaxHealth() or shield.regenDelay <= 0 then
            shield:SetRegenEnabled(true)
            return
        end
        shield:SetRegenEnabled(false)
        shield.regenTimeOutTick = Tick + shield.regenDelay
        shield.regenAfterDelayThread =
            shield:NewThread(shield.RegenAfterDelayThread)
    end

    function HostShield:TakeDamage(damage)
        if not SCOCommanderShieldContract(self) then
            return SCOCommanderShieldPreviousTakeDamage(self, damage)
        end
        -- Sanctuary clamps health above zero, so mark a pop before delegating.
        if self.canTakeDamage
            and not self.rechargeThread
            and damage >= self:GetHealth()
        then
            if self.scoCommanderPowerWatchThread then
                KillThread(self.scoCommanderPowerWatchThread)
                self.scoCommanderPowerWatchThread = nil
            end
            self.scoCommanderRechargeKind = "Damage"
            self.scoCommanderRechargeProgress = 0
            self.scoCommanderOffHealth = nil
        end
        return SCOCommanderShieldPreviousTakeDamage(self, damage)
    end

    function HostShield:RechargeThread()
        if not SCOCommanderShieldContract(self) then
            return SCOCommanderShieldPreviousRechargeThread(self)
        end
        local kind = self.scoCommanderRechargeKind or "Energy"
        local seconds = kind == "Damage"
            and self.tp.scoDamageRechargeTime
            or self.tp.scoEnergyDrainRechargeTime
        if type(seconds) ~= "number" or seconds <= 0 then
            error("Commander shield recharge time is invalid")
        end
        local required = seconds * Constants.TickRate
        local progress = self.scoCommanderRechargeProgress or 0
        while self.isEnableable and progress < required do
            progress = math.min(
                required,
                progress + SCOCommanderShieldEnergySatisfaction(self))
            self.scoCommanderRechargeProgress = progress
            WaitTicks(1)
        end
        if not self.isEnableable then
            self.rechargeThread = nil
            return
        end
        local maximum = self:GetMaxHealth()
        local restoredHealth = kind == "Damage"
            and maximum
            or math.min(self.scoCommanderOffHealth or maximum, maximum)
        if restoredHealth <= 0 then restoredHealth = maximum end
        self:SetHealth(restoredHealth)
        self:SetEnabled(true)
        SCOCommanderShieldEnableRegen(self, restoredHealth)
        self.scoCommanderRechargeKind = nil
        self.scoCommanderRechargeProgress = 0
        self.scoCommanderOffHealth = nil
        self.rechargeThread = nil
        SCOCommanderShieldStartPowerWatch(self, true)
    end

    function HostShield:SetEnableable(value, skipRecharge)
        if not SCOCommanderShieldContract(self) then
            return SCOCommanderShieldPreviousSetEnableable(
                self,
                value,
                skipRecharge)
        end
        if value == self.isEnableable then return end
        self.isEnableable = value
        if value then
            if skipRecharge then
                SCOCommanderShieldCancelTimers(self)
                self:SetHealth(self:GetMaxHealth())
                self:SetEnabled(true)
                self:SetRegenEnabled(true)
                self.scoCommanderRechargeKind = nil
                self.scoCommanderRechargeProgress = 0
                self.scoCommanderOffHealth = nil
                SCOCommanderShieldStartPowerWatch(self, true)
            else
                self.scoCommanderRechargeKind =
                    self.scoCommanderRechargeKind or "Energy"
                self.rechargeThread = self:NewThread(self.RechargeThread)
            end
            return
        end

        local damageRechargePending =
            self.scoCommanderRechargeKind == "Damage"
        SCOCommanderShieldCancelTimers(self)
        if not damageRechargePending then
            self.scoCommanderRechargeKind = "Energy"
            self.scoCommanderRechargeProgress = 0
            self.scoCommanderOffHealth = math.min(
                self:GetHealth(),
                self:GetMaxHealth())
        end
        self:SetEnabled(false)
        self:SetRegenEnabled(false)
    end

    function HostShield:SCOSetCommanderEnergyDown(isDown)
        if not SCOCommanderShieldContract(self) or not self.isEnableable then
            return
        end
        if isDown then
            if self.enabled then
                -- Normally the continuous watcher already exists. This
                -- fail-safe path intentionally grants no new OnState grace.
                SCOCommanderShieldStartPowerWatch(self, false)
            elseif not self.rechargeThread then
                SCOCommanderShieldStartRecharge(
                    self,
                    self.scoCommanderRechargeKind or "Energy",
                    self.scoCommanderOffHealth or self:GetHealth())
            end
        elseif self.enabled then
            -- Keep the watcher alive across EnergyUp. FA monitors for the
            -- shield's entire OnState instead of recreating it per event.
            SCOCommanderShieldStartPowerWatch(self, false)
        end
    end

    rawset(
        SCOCommanderShieldEnvironment,
        "SCO_CommanderEnhancementShieldInstalled",
        SCOCommanderShieldVersion)
end

-- Append to host/shield.lua after SCOM's existing Titan override.
-- Both imported T3 assault bots retain stock damage and recharge handling.
local SCOFaT3Contracts = {
    uel3001 = { marker = "scoFaTitanPersonalShield", max = 2200, ratio = 1 },
    ucl3001 = { marker = "scoFaHarbingerPersonalShield", max = 1300, ratio = 0.5 },
}

local function SCOFaT3HasShieldPower(unit)
    local economy = unit.army and unit.army.economy
    if not economy then return false end
    if not economy.isEnergyDown then return true end
    local energy = economy.resources and economy.resources.energy
    return energy ~= nil and (energy.satisfaction or 0) >= 1
end

local function SCOFaT3OperationalRestart(shield)
    WaitSeconds(shield:GetRechargeTime())
    shield:SetEnabled(true)
    shield:SetRegenEnabled(true)
    shield.rechargeThread = nil
    shield:SetRecharging(false)
    shield:SetRechargeTime(shield.tp.scoDamageRechargeTime)
    shield.scoFaT3OperationalRestart = false
end

function SCOFaT3InstallShield(unit)
    local contract = SCOFaT3Contracts[unit.tpId]
    if not contract then return end
    local shield = assert(unit.shields and unit.shields[1],
        unit.tpId .. " personal shield is missing")
    local tp = shield.tp
    assert(#unit.shields == 1 and tp[contract.marker] == true
        and tp.max == contract.max
        and tp.rechargeHPRatio == contract.ratio
        and tp.scoDamageRechargeTime == 60
        and tp.scoManualRechargeTime == 5
        and tp.scoEnergyDrainRechargeTime == 5,
        unit.tpId .. " personal shield source contract drifted")

    local inheritedRechargeThread = shield.RechargeThread
    function shield:RechargeThread()
        inheritedRechargeThread(self)
        -- The preceding Titan FA wrapper clears rechargeThread but leaves
        -- Sanctuary's UI recharge flag set after a damage pop.
        if self.rechargeThread == nil then self:SetRecharging(false) end
    end

    function shield:SetEnableable(value, skipRecharge)
        if value == self.isEnableable then return end
        self.isEnableable = value

        if not value then
            local damagePending = self.rechargeThread ~= nil
                and not self.scoFaT3OperationalRestart
            self.scoFaT3RestartTime = self.owner:GetShieldToggle()
                and tp.scoEnergyDrainRechargeTime or tp.scoManualRechargeTime
            if self.rechargeThread then
                KillThread(self.rechargeThread)
                self.rechargeThread = nil
            end
            if self.regenAfterDelayThread then
                KillThread(self.regenAfterDelayThread)
                self.regenAfterDelayThread = nil
            end
            self:SetRecharging(false)
            self:SetEnabled(false)
            self:SetRegenEnabled(false)
            self:SetRechargeTime(tp.scoDamageRechargeTime)
            self.scoFaT3OperationalRestart = false
            self.scoFaT3DamagePending = damagePending
            return
        end

        if skipRecharge then
            self.scoFaT3OperationalRestart = false
            self.scoFaT3DamagePending = false
            self:SetRechargeTime(tp.scoDamageRechargeTime)
            self:SetEnabled(true)
            self:SetRegenEnabled(true)
            self:SetHealth(self:GetMaxHealth())
            return
        end

        self.scoFaT3OperationalRestart = not self.scoFaT3DamagePending
        self:SetRechargeTime(self.scoFaT3OperationalRestart
            and (self.scoFaT3RestartTime or tp.scoEnergyDrainRechargeTime)
            or tp.scoDamageRechargeTime)
        self.scoFaT3DamagePending = false
        self.rechargeThread = self:NewThread(self.scoFaT3OperationalRestart
            and SCOFaT3OperationalRestart or self.RechargeThread)
        self:SetRecharging(true)
    end
end

local function SCOFaT3MonitorShieldPower(unit)
    while not unit.dead
        and unit:IsCompleted()
        and unit:GetShieldToggle()
        and unit.army
        and unit.army.economy
        and unit.army.economy.isEnergyDown
    do
        local hasPower = SCOFaT3HasShieldPower(unit)
        local shield = unit.shields and unit.shields[1]
        if not shield then break end
        shield:SetEnableable(hasPower)
        unit:SetRotatorsEnabled(hasPower)
        WaitTicks(1)
    end
    unit.scoFaT3ShieldPowerThread = nil
end

function SCOFaT3CheckShieldState(unit, skipRecharge)
    local shield = unit.shields and unit.shields[1]
    if not shield then return end
    if skipRecharge and unit:IsCompleted() and not unit.scoFaT3ShieldInitialized then
        -- HostShield.__init disables the shield and can leave its HP at 1.
        -- OnStopBeingBuilt is the one-time point at which a new unit starts full.
        shield:SetHealth(shield:GetMaxHealth())
        unit.scoFaT3ShieldInitialized = true
    end
    local wantsShield = unit:IsCompleted() and unit:GetShieldToggle()
    if unit.resourceEntities.consumption then
        unit.resourceEntities.consumption:SetEnabled(wantsShield)
    end

    local canEnable = wantsShield and SCOFaT3HasShieldPower(unit)
    shield:SetEnableable(canEnable, skipRecharge)
    unit:SetRotatorsEnabled(canEnable)

    local economy = unit.army and unit.army.economy
    if wantsShield and economy and economy.isEnergyDown then
        if not unit.scoFaT3ShieldPowerThread then
            unit.scoFaT3ShieldPowerThread = unit:NewThread(SCOFaT3MonitorShieldPower)
        end
    elseif unit.scoFaT3ShieldPowerThread then
        KillThread(unit.scoFaT3ShieldPowerThread)
        unit.scoFaT3ShieldPowerThread = nil
    end
end
