-- usl5002: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultSeraphim.lua").ClientSeraphimLandUnit
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_usl5002_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.

local AudioManager = Import("client/audio/audioManager.lua")
local spawnAudioPrefab

-- Hover supplies the target for both right-click and explicit attack orders.
function UnitClass:IsHighlightable()
    return false
end

function UnitClass:SCOSpecialEvent(name, boneOverride)
    local result = Base.SCOSpecialEvent(self, name, boneOverride)
    if name ~= "spawn" or self.scoOthuySpawnAudioConsumed then return result end
    -- Consume the actual spawn even when hidden; visibility must not replay it.
    self.scoOthuySpawnAudioConsumed = true
    if self.dead or self.deleted or self:IsPlacementGhost()
        or not self:IsIntelVisionVisible() then return result end
    if not spawnAudioPrefab then
        spawnAudioPrefab = Import("common/loading/audioPrefabLoader.lua").CreateOneShotAudioPrefab(
            "SCOM_OthuySpawnAudio", "acom2143", "weapons")
    end
    if spawnAudioPrefab then
        AudioManager.PlayOneShot(spawnAudioPrefab, self:GetPosition(), self:GetOrientation())
    end
    return result
end
