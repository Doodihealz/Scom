-- usl4401: XSL0307 source shield timing and paid-power lifecycle.
local Base = Import("host/units/unitsClasses/unitsDefaultSeraphim.lua").HostSeraphimLandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_usl4401_host", Base)

local function EnergySatisfaction(shield)
    local economy = shield.owner.army.economy
    if not economy.isEnergyDown then return 1 end
    local energy = economy.resources.energy
    return math.max(0, math.min(energy.satisfaction or 0, 1))
end

local function CancelThread(shield, key)
    if shield[key] then
        KillThread(shield[key])
        shield[key] = nil
    end
end

local StartPowerWatch

local function RestoreShield(shield, health)
    shield:SetHealth(health)
    shield:SetEnabled(true)
    shield:SetRecharging(false)
    if health >= shield:GetMaxHealth() then
        shield:SetRegenEnabled(true)
    else
        shield:SetRegenEnabled(false)
        shield.regenTimeOutTick = Tick + shield.regenDelay
        shield.regenAfterDelayThread = shield:NewThread(shield.RegenAfterDelayThread)
    end
    StartPowerWatch(shield)
end

local function BeginEnergyRecharge(shield)
    shield.scoAthanahRechargeKind = "Energy"
    shield.scoAthanahRechargeProgress = 0
    shield.scoAthanahOffHealth = shield:GetHealth()
    CancelThread(shield, "regenAfterDelayThread")
    shield:SetEnabled(false)
    shield:SetRegenEnabled(false)
    shield:SetRechargeTime(shield.tp.scoEnergyDrainRechargeTime)
    shield.rechargeThread = shield:NewThread(shield.RechargeThread)
    shield:SetRecharging(true)
end

local function PowerWatch(shield)
    -- FA OnState owns one second of grace, then two consecutive unpaid ticks.
    WaitTicks(Constants.TickRate)
    local unpaidTicks = 0
    while shield.isEnableable and shield:IsEnabled() do
        WaitTicks(1)
        if not shield.isEnableable or not shield:IsEnabled() then break end
        local economy = shield.owner.army.economy
        local energy = economy.resources.energy
        if economy.isEnergyDown and (energy.current or 0) <= 0
            and EnergySatisfaction(shield) < 1 then
            unpaidTicks = unpaidTicks + 1
        else
            unpaidTicks = 0
        end
        if unpaidTicks >= 2 then
            shield.scoAthanahPowerWatch = nil
            BeginEnergyRecharge(shield)
            return
        end
    end
    shield.scoAthanahPowerWatch = nil
end

StartPowerWatch = function(shield)
    if not shield.scoAthanahPowerWatch and shield.isEnableable
        and shield:IsEnabled() then
        shield.scoAthanahPowerWatch = shield:NewThread(PowerWatch)
    end
end

function UnitClass:SetUpShields()
    Base.SetUpShields(self)
    local shield = assert(self.shields and self.shields[1],
        "Athanah shield is missing")
    assert(#self.shields == 1 and shield.tp.scoFaAthanahShield == true
        and shield.tp.max == 10000 and shield.tp.rechargeHPRatio == 1
        and shield.tp.scoDamageRechargeTime == 45
        and shield.tp.scoEnergyDrainRechargeTime == 5,
        "Athanah source shield contract drifted")

    local previousTakeDamage = shield.TakeDamage
    function shield:TakeDamage(damage)
        if self.canTakeDamage and not self.rechargeThread
            and damage >= self:GetHealth() then
            CancelThread(self, "scoAthanahPowerWatch")
            self.scoAthanahRechargeKind = "Damage"
            self.scoAthanahRechargeProgress = 0
            self.scoAthanahOffHealth = nil
            self:SetRechargeTime(self.tp.scoDamageRechargeTime)
        end
        return previousTakeDamage(self, damage)
    end

    function shield:RechargeThread()
        local damageRecharge = self.scoAthanahRechargeKind == "Damage"
        local seconds = damageRecharge and self.tp.scoDamageRechargeTime
            or self.tp.scoEnergyDrainRechargeTime
        local required = seconds * Constants.TickRate
        local progress = self.scoAthanahRechargeProgress or 0
        while self.isEnableable and progress < required do
            progress = math.min(required, progress + EnergySatisfaction(self))
            self.scoAthanahRechargeProgress = progress
            WaitTicks(1)
        end
        if not self.isEnableable then
            self.rechargeThread = nil
            return
        end
        local health = damageRecharge and self:GetMaxHealth()
            or math.min(self.scoAthanahOffHealth or self:GetMaxHealth(),
                self:GetMaxHealth())
        self.scoAthanahRechargeKind = nil
        self.scoAthanahRechargeProgress = 0
        self.scoAthanahOffHealth = nil
        self.rechargeThread = nil
        RestoreShield(self, health)
    end

    function shield:SetEnableable(value, skipRecharge)
        if value == self.isEnableable then return end
        self.isEnableable = value
        if value then
            if skipRecharge then
                CancelThread(self, "rechargeThread")
                CancelThread(self, "regenAfterDelayThread")
                self.scoAthanahRechargeKind = nil
                self.scoAthanahRechargeProgress = 0
                self.scoAthanahOffHealth = nil
                RestoreShield(self, self:GetMaxHealth())
            else
                self.scoAthanahRechargeKind = self.scoAthanahRechargeKind or "Energy"
                self:SetRechargeTime(self.scoAthanahRechargeKind == "Damage"
                    and self.tp.scoDamageRechargeTime
                    or self.tp.scoEnergyDrainRechargeTime)
                self.rechargeThread = self:NewThread(self.RechargeThread)
                self:SetRecharging(true)
            end
            return
        end
        if self.scoAthanahRechargeKind ~= "Damage" then
            self.scoAthanahRechargeKind = "Energy"
            self.scoAthanahRechargeProgress = 0
            self.scoAthanahOffHealth = self:GetHealth()
        end
        CancelThread(self, "rechargeThread")
        CancelThread(self, "regenAfterDelayThread")
        CancelThread(self, "scoAthanahPowerWatch")
        self:SetEnabled(false)
        self:SetRegenEnabled(false)
        self:SetRecharging(false)
    end

    local previousDelete = shield.Delete
    function shield:Delete()
        CancelThread(self, "scoAthanahPowerWatch")
        return previousDelete(self)
    end
end

function UnitClass:CheckShieldState(skipRecharge)
    local shield = self.shields and self.shields[1]
    if not shield then return end
    local wanted = self:IsCompleted() and self:GetShieldToggle()
    if self.resourceEntities.consumption then
        self.resourceEntities.consumption:SetEnabled(wanted)
    end
    -- Paid-power progress and the source grace window belong to the shield.
    -- A global economy deficit alone does not prove this upkeep was unpaid.
    shield:SetEnableable(wanted, skipRecharge)
    self:SetRotatorsEnabled(wanted and shield:IsEnabled())
end
