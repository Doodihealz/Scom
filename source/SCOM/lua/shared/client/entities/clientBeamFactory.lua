local ClientPulseBeam = Import("client/entities/clientPulseBeam.lua").ClientPulseBeam
local ClientContinuousBeam = Import("client/entities/clientContinuousBeam.lua").ClientContinuousBeam

---@param submeshes LocalID[] LocalIDs of the beam sub-meshes.
---@param muzzle ClientMuzzle Parent muzzle of the beam entity.
---@return ClientBeam beam Created instance
function CreateBeam(submeshes, muzzle)
    local beamLifetime = muzzle.weapon.tp.beamLifetime or -1
    if beamLifetime > 0 and not muzzle.weapon.tp.scoSpecialOrbital then
        return ClientPulseBeam(submeshes, muzzle)
    end

    return ClientContinuousBeam(submeshes, muzzle)
end

return {
    CreateBeam = CreateBeam
}