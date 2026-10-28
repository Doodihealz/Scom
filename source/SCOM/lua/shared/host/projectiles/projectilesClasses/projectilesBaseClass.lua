local HostEntity = Import("host/entity.lua").HostEntity
local HostCollider = Import("host/managers/colliders/collider.lua")
local IntelLayer = Import("host/managers/intel/intelLayer.lua").IntelLayer
local IntelCommands      = Import("common/commands/definitions/intel.lua")
local ProjectileCommands = Import("common/commands/definitions/projectiles.lua")
local CollisionUpdate = Import("host/collisionUpdate.lua")

local Projectiles = __Entities.Projectiles

---@class HostProjectile: HostEntity
---@field tp table Template
---@field armyId ArmyId Template
HostProjectile = Class("Projectile", HostEntity)

---@protected Initializes a new Projectile class.
---@param globalId GlobalID
---@param armyId ArmyId
---@param template ProjectileTemplate
---@param damage number
---@param damageRadius number
---@param lifetime number
---@param muzzleId? GlobalID
function HostProjectile:__init(globalId, armyId, template, damage, damageRadius, lifetime, muzzleId, sourceUnit)
    HostEntity.__init(self, globalId)

    self.tp = template
    self.armyId = armyId
    self.damage = damage
    self.damageRadius = damageRadius
    self.lifetime = lifetime
    self.spawnTime = _G.Time
    self.currentStageIndex = 1
    self.currentStageStartTime = _G.Time
    self.muzzleId = muzzleId or EngineClasses.GlobalID()
    self.sourceUnit = sourceUnit

    local _, intelColliderId = Engine.GetGlobalBone(self.id, IntelVisionSignatureColliderName)
    self.intelLayer = IntelLayer.new(HostCollider.CreateHostCollider(intelColliderId), CollisionWorld.IntelVision, function(mask)
        IntelCommands.SetProjectileIntel.Send(self.id, mask)
    end)
    self.intelLayer:SetOwnerArmy(armyId)
end

function HostProjectile:Delete()
    ProjectileCommands.DeleteProjectile.Send(self.id)

    self.intelLayer:Delete()
    Engine.DeletePrefabInstance(self.id, false)
    HostEntity.Delete(self)
    Projectiles[self.id.index] = nil
end

---Destroys the projectile on impact, telling the client to play impact effects first.
---@param tickImpactTime number Time from the start of this tick that the impact happened.
---@param hitGlobalID GlobalID? The entity that was hit, so the client knows what to play the impact effects of. Defaults to an invalid GlobalID, which is what the terrain uses.
function HostProjectile:Destroy(tickImpactTime, hitGlobalID)
    ProjectileCommands.DestroyProjectile.Send(self.id, tickImpactTime, hitGlobalID or EngineClasses.GlobalID(),
        self.intelLayer.detectionMask.value)

    -- TODO: Combine the destroy and delete commands. Deleting the projectile sends the delete
    -- command, so the two are always sent right after each other.
    self:Delete()
end

---Called when the projectile crosses the water surface, from ProcessWaterCollisionEvent.
---Projectiles detonate on water by default. Anything that must survive entry (torpedoes, depth
---charges) overrides this in its own projectile class.
---@param hitPosition float3 Where the projectile crossed the surface.
---@param tickImpactTime number Time from the start of this tick that the crossing happened.
---@param waterGlobalID GlobalID The water entity the projectile crossed into.
function HostProjectile:OnCrossedWaterline(hitPosition, tickImpactTime, waterGlobalID)
    if self.damageRadius > 0 then
        CollisionUpdate.ProcessAreaDamage(hitPosition, self.damageRadius, self.damage, Armies[self.armyId], self.damageFriendly == true, self.sourceUnit)
    end

    self:Destroy(tickImpactTime, waterGlobalID)
end

function HostProjectile:Update()
    if self.spawnTime + self.lifetime < _G.Time then
        self:Delete()
        return
    end

    if self.tp.extraStages then
        local currentStage = self.tp.extraStages[self.currentStageIndex]
        if currentStage then
            if self.currentStageStartTime + currentStage.delay < _G.Time then
                Engine.SetHomingProjectileAcceleration(self.id, currentStage.acceleration or 0)
                Engine.SetHomingProjectileMaxSpeed(self.id, currentStage.speedMax or 0)
                Engine.SetHomingProjectileRotationSpeed(self.id, currentStage.rotationSpeed or 0)
                local gravity = EngineClasses.float3(0, -1.0, 0)
                math3D.scale(gravity, currentStage.gravityMultiplier or 1.0, _G.defaultGravityAcceleration)
                Engine.SetProjectileGravity(self.id, gravity)

                self.currentStageIndex = self.currentStageIndex + 1
                self.currentStageStartTime = _G.Time
            end
        end
    end
end

-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0
-- SCOM source projectile physics lifecycle 1.0.0
do
    local previousInit = HostProjectile.__init
    local previousWater = HostProjectile.OnCrossedWaterline
    function HostProjectile:__init(...)
        previousInit(self, ...)
        local contract = self.tp and self.tp.additions and self.tp.additions.scoSourceProjectile
        if not contract then return end
        local created = _G.SCO_SourceProjectileCreated
        if created then created(self) end
        local physics = contract.physics or {}
        if physics.UseGravity == false then
            Engine.SetProjectileGravity(self.id, EngineClasses.float3(0, 0, 0))
        end
    end
    function HostProjectile:OnCrossedWaterline(hitPosition, tickImpactTime, waterGlobalID)
        local contract = self.tp and self.tp.additions and self.tp.additions.scoSourceProjectile
        if contract and contract.physics and contract.physics.DestroyOnWater == false then
            return
        end
        return previousWater(self, hitPosition, tickImpactTime, waterGlobalID)
    end
end

-- Snapshot the firing weapon's source buff at creation, including shots in flight.
do
    local previousInit = HostProjectile.__init
    function HostProjectile:__init(...)
        previousInit(self, ...)
        local source = self.sourceUnit
        if not source then return end
        local id = self.tp.general and self.tp.general.tpId
        if source.tpId == "ugl1101" and id == "psf0097" then
            self.scoSourceStunSpec = { kind = "medusa", duration = 3, radius = 2 }
        elseif source.tpId == "ugl5004" and source.weapons and source.weapons[1]
            and source.weapons[1].tp.projectileTemplate == id then
            local state = source.scoCommanderEnhancements
            if state and state.installed and state.installed.EMPCharge then
                self.scoSourceStunSpec = { kind = "sacu", duration = 6, radius = 3 }
            end
        end
    end
end
-- SCOM source projectile motion installation 1.0.0
local sourceMotion = Import('common/systems/scoSourceProjectileMotion.lua')
sourceMotion.Configure(Import('common/systems/scoSourceProjectileMotionContract.lua'))
sourceMotion.InstallProjectile(HostProjectile)
_G.SCO_SourceProjectileIntercepted = sourceMotion.Intercepted
