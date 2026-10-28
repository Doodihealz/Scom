local HostBeam = Import("host/units/weaponsClasses/beam.lua")
local IsBeamWeapon = Import("common/utilities/beams.lua").IsBeamWeapon
local ProjectileCommands = Import("common/commands/definitions/projectiles.lua")

---@param muzzleBoneID GlobalID
---@param boneName string
---@param weapon HostWeapon
---@return HostMuzzle
function RegisterHostMuzzle(muzzleBoneID, boneName, weapon)
    local muzzle = HostMuzzle(muzzleBoneID, boneName, weapon)
    __Muzzles[muzzleBoneID.index] = muzzle
    return muzzle
end

---@class HostMuzzle
---@field id GlobalID
---@field boneName string Bone name of this muzzle
---@field weapon HostWeapon
---@field beam HostBeam?
HostMuzzle = Class("HostMuzzle")

---@param muzzleBoneID GlobalID
---@param boneName string
---@param weapon HostWeapon
function HostMuzzle:__init(muzzleBoneID, boneName, weapon)
    self.id = muzzleBoneID
    self.boneName = boneName
    self.weapon = weapon

    local isBeamWeapon = IsBeamWeapon(weapon.tp)

    if isBeamWeapon then
        self.beam = HostBeam.CreateHostBeam(muzzleBoneID, self)
    end
end

function HostMuzzle:Delete()
    if self.beam then
        self.beam:Delete()
    end
    self.beam = nil
    if __Muzzles[self.id.index] == self then
        __Muzzles[self.id.index] = nil
    end
end

--- Starts or stops the muzzle's firing effects.
---@param enabled boolean
function HostMuzzle:SetFiring(enabled)
    if self.isFiring == enabled then return end
    self.isFiring = enabled

    if self.beam then
        self.beam:SetBeamEnabled(enabled)
    end

    ProjectileCommands.SetMuzzleFiring.Send(self.id, enabled)
end

function HostMuzzle:Update()
    if self.beam then
        self.beam:Update()
    end
end

return {
    RegisterHostMuzzle = RegisterHostMuzzle,
    HostMuzzle = HostMuzzle,
}