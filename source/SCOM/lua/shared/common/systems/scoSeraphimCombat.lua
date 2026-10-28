local M = {}

local function eye(weapon)
    return weapon.unit.tpId == 'usl4004' and weapon.tp.scoSeraphimHeadChargeTicks == 25
end

function M.InstallHost(class, states)
    if class.scoSeraphimCombatInstalled then return end
    class.scoSeraphimCombatInstalled = true
    local commands = Import('common/commands/definitions/units.lua')
    local function stopCharge(weapon)
        if weapon.scoSeraphimHeadChargeRemaining then
            weapon.scoSeraphimHeadChargeRemaining = nil
            commands.SCOSourceSpecialEvent.Send(weapon.unit.id, 'headChargeStop', '')
        end
    end
    local update = class.Update
    class.Update = function(self, ...)
        -- The deploy owner returns before native UpdateTargeting while packed.
        -- Refresh acquisition first so a unit can open without a preassigned target.
        if self.unit.tpId == 'usl3101' and self.tp.scoFaAnimationClosureDeploy
            and self.scoFaAnimationDeployState ~= 'deployed'
            and self.enabled and not self.unit.dead then
            self:UpdateTargeting()
        end
        return update(self, ...)
    end
    local projectile = class.UpdateProjectile
    class.UpdateProjectile = function(self, isOnTarget, ...)
        if not eye(self) then return projectile(self, isOnTarget, ...) end
        if self.scoSeraphimHeadChargeRemaining then
            if not isOnTarget or not self.enabled or self.unit.dead then
                stopCharge(self)
                self.currentState = states.WaitingForTarget
                self.reloadTimer = 0
                return
            end
            self.scoSeraphimHeadChargeRemaining = self.scoSeraphimHeadChargeRemaining - 1
            if self.scoSeraphimHeadChargeRemaining > 0 then return end
            stopCharge(self)
        elseif self.currentState == states.ShootSalvo
            and self.salvosRemaining == (self.tp.muzzleSalvoSize or 1) then
            if not isOnTarget then return end
            self.scoSeraphimHeadChargeRemaining = self.tp.scoSeraphimHeadChargeTicks
            commands.SCOSourceSpecialEvent.Send(self.unit.id, 'headCharge', 'Head')
            return
        end
        return projectile(self, isOnTarget, ...)
    end
    local target = class.SetAimTarget
    class.SetAimTarget = function(self, value, ...)
        if eye(self) and self.targetUnit ~= value and self.scoSeraphimHeadChargeRemaining then
            stopCharge(self)
            self.currentState = states.WaitingForTarget
            self.reloadTimer = 0
        end
        return target(self, value, ...)
    end
    local enabled = class.SetEnabled
    class.SetEnabled = function(self, value, ...)
        if eye(self) and not value then
            stopCharge(self)
            if self.currentState == states.ShootSalvo then
                self.currentState = states.WaitingForTarget
                self.reloadTimer = 0
            end
        end
        return enabled(self, value, ...)
    end
    local refresh = class.RefreshEnabled
    if refresh then
        class.RefreshEnabled = function(self, ...)
            local result = refresh(self, ...)
            -- Water sensors disable through RefreshEnabled directly. Disabled
            -- weapons no longer tick, so stop the owned loop at this boundary.
            if eye(self) and not self.enabled and self.scoSeraphimHeadChargeRemaining then
                stopCharge(self)
                self.currentState = states.WaitingForTarget
                self.reloadTimer = 0
            end
            return result
        end
    end
    local delete = class.Delete
    class.Delete = function(self, ...)
        if eye(self) then stopCharge(self) end
        return delete(self, ...)
    end
end

function M.InstallClient(class)
    if class.scoSeraphimCombatInstalled then return end
    class.scoSeraphimCombatInstalled = true
    local event = class.SCOSpecialEvent
    class.SCOSpecialEvent = function(self, name, bone)
        if self.tpId ~= 'usl4004' then return event(self, name, bone) end
        if name == 'headCharge' or name == 'headChargeStop' then
            local previous = self.scoSeraphimHeadChargeEffect
            if previous and Engine.IsValidLocalID(previous) then Engine.DeletePrefabInstance(previous) end
            self.scoSeraphimHeadChargeEffect = nil
            if name == 'headChargeStop' then return end
            local count = #(self.scoSpecialEffects or {})
            local result = event(self, name, bone)
            if #(self.scoSpecialEffects or {}) > count then
                self.scoSeraphimHeadChargeEffect = self.scoSpecialEffects[#self.scoSpecialEffects].id
            end
            return result
        end
        return event(self, name, bone)
    end
end

for name, value in pairs(M) do getfenv(1)[name] = value end
return M
