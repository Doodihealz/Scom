-- uss2001: client behavior. Shared base methods are also editable in SCOM/lua/shared.
local Base = Import("client/units/unitsClasses/unitsDefaultSeraphim.lua").ClientSeraphimStructure
UnitClass = Import("scom/units/behavior.lua").Derive("SCOM_uss2001_client", Base)
-- Add or replace methods with function UnitClass:MethodName(...) ... end.

local ContinuousBeam = Import("client/entities/beams/beamWeaponContinuous.lua").ClientBeamWeaponContinuous

local VFXLoader = Import("common/loading/vfxTemplateLoader.lua")
local impactPrefabID

local function ConfigureTrackingPulse(beam)
    -- Keep the native pulse prefab, manager registration, expiry and fade. Its
    -- default one-shot raycast otherwise freezes a sustained FA beam in space.
    if impactPrefabID == nil then
        local path = beam.muzzle.weapon.tp.beam.impactEffect
        assert(Engine.LoadEffect(path) == true, "SCOM uss2001 impact effect failed to load: " .. path)
        impactPrefabID = VFXLoader.GetOrCreateVFXPrefab(path)
    end
    -- Keep this impact private to the client beam; pbf0008 is shared by other weapons.
    beam.projectileTemplate = {
        visuals = {
            onImpactEffects = {{effects = {{particlePrefabID = impactPrefabID}}}},
        },
    }
    beam.impactEffectCreated = false
    beam.impactEffectId = nil
    beam.OnImpactUpdated = ContinuousBeam.OnImpactUpdated

    function beam:OnRaycastImpact(origin, collisionEvent)
        self:SetBeamEndpoints(origin, collisionEvent.hitPosition)
        ContinuousBeam.OnRaycastImpact(self, origin, collisionEvent)
    end

    function beam:OnImpactLost(origin, rangeMax)
        if origin ~= nil and rangeMax ~= nil then
            self:SetBeamEndpoints(origin,
                math3D.add(origin, math3D.scale(self.lastForward, rangeMax)))
        end
        ContinuousBeam.OnImpactLost(self)
    end

    beam.OnIntelVisibilityChanged = ContinuousBeam.OnIntelVisibilityChanged

    function beam:OnUpdateStart(lifetime)
        local muzzle = self.muzzle
        if muzzle.weapon.unit.dead or not Engine.IsValidLocalID(muzzle.localId) then
            self:Delete()
            return
        end
        if not self.enabled or lifetime >= self.lifetime then
            self:OnImpactLost()
            return
        end
        self.raycastPending = false
        local collisionEvent = self:Raycast()
        if self.hasImpact and collisionEvent then
            self:OnImpactUpdated(collisionEvent)
        end
    end

end

function UnitClass:SetUpWeapons()
    Base.SetUpWeapons(self)
    for _, weapon in ipairs(self.weapons or {}) do
        for _, muzzle in ipairs(weapon.muzzles) do
            local createBeam = muzzle.CreateBeam
            function muzzle:CreateBeam()
                createBeam(self)
                ConfigureTrackingPulse(self.beam)
            end
        end
    end
end
