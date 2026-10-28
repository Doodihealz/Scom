local ClientEntity = Import("client/entities/entity.lua").ClientEntity
local IsBeamWeapon = Import("common/utilities/beams.lua").IsBeamWeapon
local AudioManager = Import("client/audio/audioManager.lua")
local ClientBeamManager = Import("client/entities/beams/clientBeamManager.lua")

---Registers a new muzzle of a weapon
---@param localId localId Local ID of the muzzlee
---@param globalId globalId Global ID of the muzzlee
---@param boneName string Bone name of this muzzle
---@param parentWeapon ClientWeapon Weapon class of the parent
---@return ClientMuzzle muzzle New client muzzle class
function RegisterClientMuzzle(localId, globalId, boneName, parentWeapon)
    local muzzle = ClientMuzzle(localId, globalId, boneName, parentWeapon)
    __Muzzles[globalId.index] = muzzle
    return muzzle
end

---@class ClientMuzzle: ClientEntity
---@field localId localId Local ID of the muzzlee
---@field globalId globalId Global ID of the muzzlee
---@field boneName string Bone name of this muzzle
---@field weapon ClientWeapon Weapon class of the parent
---@field beam ClientBeamWeapon? Beam used for the weapon.
---@field beamVisibilityMask IntelBitMask? Last visibility mask received from the host.
---@overload fun(localId: localId, globalId: globalId, boneName: string, weapon: ClientWeapon): ClientMuzzle
ClientMuzzle = Class("ClientMuzzle", ClientEntity)

---Initializes a new client muzzle class
---@param localId localId Local ID of the muzzlee
---@param globalId globalId Global ID of the muzzle
---@param boneName string Bone name of this muzzle
---@param parentWeapon ClientWeapon Weapon class of the parent
---@param tp table Muzzle's template
---@protected
function ClientMuzzle:__init(localId, globalId, boneName, parentWeapon)
    ClientEntity.__init(self, globalId, localId)
    self.boneName = boneName
    self.weapon = parentWeapon

    local onFireAudio = self.weapon.tp.audio and self.weapon.tp.audio.onFire
    if onFireAudio and onFireAudio.looping and onFireAudio.muzzleBoneName == boneName then
        self.fireAudioLocalId = localId
        self.fireAudioStopEventID = onFireAudio.stopEventID
    end

    local isBeamWeapon = IsBeamWeapon(self.weapon.tp)

    if isBeamWeapon and (self.weapon.tp.beamLifetime or -1) <= 0 then
        self:CreateBeam()
    end
end

function ClientMuzzle:CreateBeam()
    self.beam = ClientBeamManager.CreateBeamWeapon(self)
end

function ClientMuzzle:RunFireMuzzle()
    self:NewThread(self.FireMuzzleThread)
end

function ClientMuzzle:FireMuzzleThread()
    -- Wait till end of tick for rendering to move to sim positions.
    WaitTickEnd()
    if self.weapon.unit.dead or self.weapon.unit.deleted then return end
    self:FireMuzzle()
end

---@param enabled boolean
function ClientMuzzle:SetFiring(enabled)
    if enabled and (self.weapon.tp.beamLifetime or -1) > 0 then
        self:CreateBeam()
    elseif enabled and self.beam and self.beam.deleted then
        self:CreateBeam()
    end

    if self.beam and (enabled or self.weapon.tp.scoSpecialOrbital or (self.weapon.tp.beamLifetime or -1) < 0) then
        self.beam:SetBeamEnabled(enabled)
    end

    if self.fireAudioLocalId then
        if not enabled and self.fireAudioStopEventID then
            Engine.StopAudioSourceSound(self.fireAudioLocalId, self.fireAudioStopEventID)
        else
            Engine.SetAudioSourceCanEmitPersistentSound(self.fireAudioLocalId, enabled)
        end
    end
end

---@param visionDetectionMask IntelBitMask
function ClientMuzzle:UpdateBeamIntel(visionDetectionMask)
    self.beamVisibilityMask = visionDetectionMask
    if self.beam then
        self.beam:UpdateIntelVisionDetection(visionDetectionMask)
    end
end

---Plays muzzle effects. Gets the effect to play from the parent weapon
function ClientMuzzle:FireMuzzle()
    
    if self.weapon.unit:IsIntelVisionVisible() then
        AudioManager.NotifyCombatActivity()

        if self.weapon.tp.effects and self.weapon.tp.effects.onFire then
            --Log(string.format("Firing muzzle: localId: %d, globalId: %d, boneName: %s, effect: %s", self.localId, self.globalId, self.boneName, effect))
            Engine.InstantiatePrefab(self.weapon.tp.effects.onFirePrefabID, self:GetPosition(), EngineClasses.float3(1.0, 1.0, 1.0), self:GetOrientation())
        end

        if self.weapon.tp.audio and self.weapon.tp.audio.onFire and self.weapon.tp.audio.onFire.prefabID then
            AudioManager.PlayOneShot(self.weapon.tp.audio.onFire.prefabID, self:GetPosition(), self:GetOrientation())
        end
    end
end

function ClientMuzzle:Cleanup()
    if self.beam then
        self.beam:Delete()
        self.beam = nil
    end
    if __Muzzles[self.id.index] == self then
        __Muzzles[self.id.index] = nil
    end
    if self.fireAudioLocalId then
        Engine.SetAudioSourceCanEmitPersistentSound(self.fireAudioLocalId, false)
    end
end

-- Only for annotations
-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0
local SCO_ScathisStockFireMuzzle = ClientMuzzle.FireMuzzle
local SCO_ScathisStockCleanupMuzzle = ClientMuzzle.Cleanup

local function SCO_IsScathisClientMuzzle(self)
    return self.weapon and self.weapon.unit
        and self.weapon.unit.tpId == "ugl4011"
        and self.weapon.tp and self.weapon.tp.scoFaScathis == true
end

local function SCO_ScathisRecoilReturn(self, generation, boneId, basePosition)
    WaitTicks(1)
    local duration = 2 / 1.325
    local elapsed = 0
    while elapsed < duration do
        if self.deleted or self.scoScathisRecoilGeneration ~= generation then return end
        elapsed = math.min(duration, elapsed + Constants.TickTimeStep)
        local ratio = elapsed / duration
        Engine.SetLocalEntityLocalPosition(
            boneId,
            EngineClasses.float3(
                basePosition.x,
                basePosition.y,
                basePosition.z - 2 * (1 - ratio)))
        if elapsed < duration then WaitTicks(1) end
    end
end

local function SCO_StartScathisRecoil(self, boneName)
    local boneId = self.weapon.unit:GetBoneId(boneName)
    if not boneId then error("Scathis recoil bone is absent: " .. tostring(boneName)) end
    local result, current = Engine.GetLocalEntityLocalPosition(boneId)
    if result ~= EngineErrorCode.Success or current == nil then
        error("Scathis could not read recoil bone " .. tostring(boneName))
    end
    local base = EngineClasses.float3(current.x, current.y, current.z)
    self.scoScathisRecoilGeneration = (self.scoScathisRecoilGeneration or 0) + 1
    self.scoScathisRecoilBoneId = boneId
    self.scoScathisRecoilBase = base
    Engine.SetLocalEntityLocalPosition(
        boneId,
        EngineClasses.float3(base.x, base.y, base.z - 2))
    self:NewThread(
        SCO_ScathisRecoilReturn,
        self.scoScathisRecoilGeneration,
        boneId,
        base)
end

function ClientMuzzle:FireMuzzle()
    if not SCO_IsScathisClientMuzzle(self) then
        return SCO_ScathisStockFireMuzzle(self)
    end
    if self.boneName == "Turret_Aim_Barrel_Muzzle" then
        -- SCOM Field Fix: Scathis visible muzzle parity 1.0.0
        -- FA launches the projectile from this hidden aim muzzle, but its
        -- visible flash and fire audio belong to the selected outer barrel.
        SCO_StartScathisRecoil(self, "Turret_Aim_Barrel")
        return
    end
    local recoilBone = string.gsub(self.boneName, "_Muzzle$", "_B02")
    if recoilBone == self.boneName then
        error("Unexpected Scathis visual muzzle " .. tostring(self.boneName))
    end
    -- The host emits exactly one selected outer-barrel event per real shot.
    -- Run stock effects here so the flash and audio follow F,E,D,C,B,A.
    local result = SCO_ScathisStockFireMuzzle(self)
    SCO_StartScathisRecoil(self, recoilBone)
    return result
end

function ClientMuzzle:Cleanup()
    if SCO_IsScathisClientMuzzle(self) then
        self.scoScathisRecoilGeneration =
            (self.scoScathisRecoilGeneration or 0) + 1
        if self.scoScathisRecoilBoneId and self.scoScathisRecoilBase then
            Engine.SetLocalEntityLocalPosition(
                self.scoScathisRecoilBoneId,
                self.scoScathisRecoilBase)
        end
    end
    return SCO_ScathisStockCleanupMuzzle(self)
end

-- SCOM Field Fix: Supreme Commander UEF artillery client recoil dispatch 1.1.0
local SCOFaArtilleryStockFireMuzzle = ClientMuzzle.FireMuzzle

local function SCOFaArtilleryClientContract(muzzle)
    local unit = muzzle and muzzle.weapon and muzzle.weapon.unit
    local additions = unit and unit.tp and unit.tp.additions
    local contract = additions and additions.scoFaArtillery
    if contract == nil then
        return nil
    end
    if type(contract) ~= "table" or contract.version ~= "1.0.0"
        or contract.targetId ~= unit.tpId
        or type(contract.muzzle) ~= "string"
        or type(contract.recoil) ~= "table"
    then
        error("Invalid SCOM FA artillery recoil contract for "
            .. tostring(unit and unit.tpId), 2)
    end
    return contract
end

function ClientMuzzle:FireMuzzle()
    local result = SCOFaArtilleryStockFireMuzzle(self)
    local contract = SCOFaArtilleryClientContract(self)
    if not contract then
        return result
    end
    if self.boneName ~= contract.muzzle then
        error("Unexpected SCOM FA artillery muzzle "
            .. tostring(self.boneName), 2)
    end
    local startRecoil = _G.SCO_FieldFixStartFaArtilleryRecoil
    if type(startRecoil) ~= "function" then
        error("SCOM FA artillery render recoil bridge is unavailable.", 2)
    end
    startRecoil(self.weapon.unit, contract)
    return result
end

-- Source beam start loops are spawned by their tracked beam lifecycle. Keep
-- native onFire fields for prefab loading and keep the original muzzle audio.
local SCOM_PreviousSourceBeamFire = ClientMuzzle.FireMuzzle
function ClientMuzzle:FireMuzzle()
    local tp = self.weapon.tp
    local source = tp.scoFaBeam or tp.scoFaContinuousBeam
    if not (source and source.endpointEffects
        and type(tp.projectileTemplate) == "string"
        and string.sub(tp.projectileTemplate, 1, 3) == "pbf") then
        return SCOM_PreviousSourceBeamFire(self)
    end
    if self.weapon.unit:IsIntelVisionVisible() then
        AudioManager.NotifyCombatActivity()
        if tp.audio and tp.audio.onFire and tp.audio.onFire.prefabID then
            AudioManager.PlayOneShot(tp.audio.onFire.prefabID, self:GetPosition(), self:GetOrientation())
        end
    end
end

return {
    RegisterClientMuzzle = RegisterClientMuzzle,
    ClientMuzzle = ClientMuzzle,
}
