-- Recheck source torpedo launch eligibility after every delayed salvo.
local M = {}

local function WagnerMuzzlesSubmerged(weapon)
    local id = weapon.unit.tpId or weapon.unit.tp.general.tpId
    if id ~= 'ugl2002' then return true end

    -- Wagner's native seabed layer can lead the muzzle across a shoreline.
    -- Query its actual launch points; naval tubes and air drops keep their
    -- authored above-water launch behavior.
    local result, hasWater = Engine.HasWater()
    if result ~= EngineErrorCode.Success or not hasWater then return false end
    local levelResult, level = Engine.GetWaterLevel()
    if levelResult ~= EngineErrorCode.Success or level == nil then return false end
    local group = weapon.muzzleGroups[weapon.currentMuzzleGroupIndex]
    if not group or #group == 0 then return false end
    for _, muzzle in ipairs(group) do
        local positionResult, position = Engine.GetGlobalEntityWorldPosition(muzzle.id)
        if positionResult ~= EngineErrorCode.Success or not position
            or not (position.y < level) then return false end
        local terrainResult, terrain = Engine.SampleTerrainHeight(position)
        if terrainResult ~= EngineErrorCode.Success or terrain == nil
            or not (terrain < level) then return false end
    end
    return true
end

function M.InstallWeapon(HostWeapon, WeaponState)
    if rawget(HostWeapon, 'scoTorpedoWeaponsInstalled') then return end
    HostWeapon.scoTorpedoWeaponsInstalled = true
    local canShootAt = HostWeapon.CanShootAt
    local updateProjectile = HostWeapon.UpdateProjectile

    function HostWeapon:CanShootAt(target)
        if not canShootAt(self, target) then return false end
        return self.tp.scoTorpedoWeapon ~= true or WagnerMuzzlesSubmerged(self)
    end

    function HostWeapon:UpdateProjectile(isOnTarget, ...)
        if self.tp.scoTorpedoWeapon == true and
            (not self.enabled or self.unit.dead or self.unit.deleted
                or not self:CanFireFromCurrentLayer()
                or not WagnerMuzzlesSubmerged(self)) then
            self:SetMuzzlesFiring(false)
            self.salvosRemaining = 0
            self.waitBetweenSalvosCountdown = 0
            self.currentState = WeaponState.WaitingForReload
            -- Keep the native reload clock: a canceled volley grants no
            -- free reload and cannot resume its old delayed shots on reentry.
            return
        end
        return updateProjectile(self, isOnTarget, ...)
    end
end

local environment = getfenv(1)
for name, value in pairs(M) do environment[name] = value end
return M
