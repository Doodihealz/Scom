-- uel3001: FA UnitShield protects its owner through the owner's damage path.
local Base = Import("host/units/unitsClasses/unitsDefaultEDA.lua").HostEDALandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uel3001_host", Base)

local function CancelThread(shield, key)
    if shield[key] then
        KillThread(shield[key])
        shield[key] = nil
    end
end

local function EnergySatisfaction(shield)
    local economy = shield.owner.army.economy
    if not economy.isEnergyDown then return 1 end
    local energy = economy.resources.energy
    return math.max(0, math.min(energy.satisfaction or 0, 1))
end

local StartPowerWatch

local function RestoreShield(shield, health)
    shield:SetHealth(health)
    shield:SetEnabled(true)
    shield:SetRecharging(false)
    if health >= shield:GetMaxHealth() or shield.regenDelay <= 0 then
        shield:SetRegenEnabled(true)
    else
        shield:SetRegenEnabled(false)
        shield.regenTimeOutTick = Tick + shield.regenDelay
        shield.regenAfterDelayThread = shield:NewThread(shield.RegenAfterDelayThread)
    end
    StartPowerWatch(shield)
end

local function PowerWatch(shield)
    -- FA OnState grants one second, then requires two consecutive unpaid ticks.
    WaitTicks(Constants.TickRate)
    local unpaidTicks = 0
    while shield.isEnableable and shield:IsEnabled() do
        WaitTicks(1)
        if not shield.isEnableable or not shield:IsEnabled() then break end
        local economy = shield.owner.army.economy
        if economy.isEnergyDown and (economy.resources.energy.current or 0) <= 0
            and EnergySatisfaction(shield) < 1 then
            unpaidTicks = unpaidTicks + 1
        else
            unpaidTicks = 0
        end
        if unpaidTicks >= 2 then
            shield.scoFaTitanPowerWatch = nil
            shield.scoFaTitanRechargeKind = "Energy"
            shield.scoFaTitanRechargeProgress = 0
            shield.scoFaTitanOffHealth = shield:GetHealth()
            CancelThread(shield, "regenAfterDelayThread")
            shield:SetEnabled(false)
            shield:SetRegenEnabled(false)
            shield:SetRechargeTime(shield.tp.scoEnergyDrainRechargeTime)
            shield.rechargeThread = shield:NewThread(shield.RechargeThread)
            shield:SetRecharging(true)
            return
        end
    end
    shield.scoFaTitanPowerWatch = nil
end

StartPowerWatch = function(shield)
    if not shield.scoFaTitanPowerWatch and shield.isEnableable and shield:IsEnabled() then
        shield.scoFaTitanPowerWatch = shield:NewThread(PowerWatch)
    end
end

function UnitClass:SetUpShields()
    Base.SetUpShields(self)
    local shield = assert(self.shields and self.shields[1],
        "Titan personal shield is missing")
    local tp = shield.tp
    assert(#self.shields == 1 and tp.scoFaTitanPersonalShield == true
        and tp.scoPersonalDamageOwner == true and tp.max == 2200
        and tp.rechargeHPRatio == 1 and tp.scoDamageRechargeTime == 60
        and tp.scoEnergyDrainRechargeTime == 5 and tp.scoManualRechargeTime == 5,
        "Titan personal damage owner contract drifted")

    local previousTakeDamage = shield.TakeDamage
    function shield:TakeDamage(damage)
        if self.canTakeDamage and not self.rechargeThread and damage >= self:GetHealth() then
            CancelThread(self, "scoFaTitanPowerWatch")
            self:SetRechargeTime(tp.scoDamageRechargeTime)
        end
        return previousTakeDamage(self, damage)
    end

    function shield:RechargeThread()
        local damageRecharge = self.scoFaTitanRechargeKind == "Damage"
        local seconds = damageRecharge and tp.scoDamageRechargeTime
            or tp.scoEnergyDrainRechargeTime
        local required = seconds * Constants.TickRate
        local progress = self.scoFaTitanRechargeProgress or 0
        while self.isEnableable and progress < required do
            progress = math.min(required, progress + EnergySatisfaction(self))
            self.scoFaTitanRechargeProgress = progress
            WaitTicks(1)
        end
        self.rechargeThread = nil
        if not self.isEnableable then return end
        local health = damageRecharge and self:GetMaxHealth()
            or math.min(self.scoFaTitanOffHealth or self:GetMaxHealth(), self:GetMaxHealth())
        self.scoFaTitanRechargeKind = nil
        self.scoFaTitanRechargeProgress = 0
        self.scoFaTitanOffHealth = nil
        RestoreShield(self, health)
    end

    function shield:SetEnableable(value, skipRecharge)
        if value == self.isEnableable then return end
        self.isEnableable = value
        if value then
            if skipRecharge then
                CancelThread(self, "rechargeThread")
                CancelThread(self, "regenAfterDelayThread")
                self.scoFaTitanRechargeKind = nil
                self.scoFaTitanRechargeProgress = 0
                self.scoFaTitanOffHealth = nil
                RestoreShield(self, self:GetMaxHealth())
            else
                self.scoFaTitanRechargeKind = self.scoFaTitanRechargeKind or "Energy"
                self:SetRechargeTime(self.scoFaTitanRechargeKind == "Damage"
                    and tp.scoDamageRechargeTime or tp.scoManualRechargeTime)
                self.rechargeThread = self:NewThread(self.RechargeThread)
                self:SetRecharging(true)
            end
            return
        end
        if self.scoFaTitanRechargeKind ~= "Damage" then
            self.scoFaTitanRechargeKind = "Energy"
            self.scoFaTitanRechargeProgress = 0
            self.scoFaTitanOffHealth = self:GetHealth()
        end
        CancelThread(self, "rechargeThread")
        CancelThread(self, "regenAfterDelayThread")
        CancelThread(self, "scoFaTitanPowerWatch")
        self:SetEnabled(false)
        self:SetRegenEnabled(false)
        self:SetRecharging(false)
    end

    local previousDelete = shield.Delete
    function shield:Delete()
        CancelThread(self, "scoFaTitanPowerWatch")
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
    shield:SetEnableable(wanted, skipRecharge)
    self:SetRotatorsEnabled(wanted and shield:IsEnabled())
end

function UnitClass:TakeDamage(amount, destroyType, instigator)
    if not self.canTakeDamage or self.dead then return end

    local shield = self.shields and self.shields[1]
    if amount > 0 and shield and shield:IsEnabled() then
        amount = shield:TakeDamage(amount)
        if amount <= 0 then return end
    end
    -- The visual sphere has no collision layer, so damage reaches this owner once.
    return Base.TakeDamage(self, amount, destroyType, instigator)
end
