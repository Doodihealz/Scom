-- AI-only adapter for the installed SCOM 1.0.0 enhancement state contract.
-- Paid resource/progress/effect implementation retained from the user-supplied
-- SCOM host appendix; public network handlers and HostCommander are not replaced.
-- Native sandbox restrictions remain intact. No debug/upvalue APIs are used.
Version = "9.0.11-rc12"
local SCOCommanderEnhancementHostVersion = "1.0.0"
do
    local SCOResourceEntity =
        Import("host/systems/resourceEntity.lua").ResourceEntity
    local SCOLobby = Import("common/lobby.lua")
    local SCOLayers = Import("common/layers.lua")
    local SCOTickRate = Constants.TickRate
    local SCOCommanderIds = {
        uel0000 = true,
        ucl0000 = true,
        ugl0000 = true,
        usl0000 = true,
    }
    local SCOPrimaryWeaponLabels = {
        uel0000 = { RightZephyr = true },
        ucl0000 = { RightDisruptor = true },
        ugl0000 = { RightRipper = true },
        usl0000 = { ChronotronCannon = true },
    }
    local SCOShieldIdByEnhancement = {
        uel0000 = {
            Shield = "uefPersonal",
            ShieldGeneratorField = "uefField",
        },
        ucl0000 = {
            Shield = "aeonPersonal",
            ShieldHeavy = "aeonPersonal",
        },
    }
    local SCOUnsupportedGlobalCapabilities = {
        chronoStun = false,
        cloak = false,
        manualMissiles = false,
        omni = false,
        serialization = false,
        sonar = false,
        spawnPods = false,
        stealth = false,
        teleport = false,
    }

    local function SCOFinite(value)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    local function SCOInteger(value, minimum, maximum)
        return SCOFinite(value)
            and value == math.floor(value)
            and value >= minimum
            and value <= maximum
    end

    local function SCOCopy(value, seen)
        if type(value) ~= "table" then return value end
        seen = seen or {}
        if seen[value] then return seen[value] end
        local result = {}
        seen[value] = result
        for key, item in pairs(value) do
            result[SCOCopy(key, seen)] = SCOCopy(item, seen)
        end
        return result
    end

    local function SCOSortedKeys(value)
        local result = {}
        for key in pairs(value or {}) do result[#result + 1] = key end
        table.sort(result, function(a, b) return tostring(a) < tostring(b) end)
        return result
    end

    local function SCOContract()
        local contract = rawget(_G, "SCO_CommanderEnhancementContract")
        if type(contract) ~= "table" then
            local ok, imported = pcall(
                Import,
                "common/systems/scoCommanderEnhancements.lua")
            if ok and type(imported) == "table" then
                contract = imported.SCO_CommanderEnhancementContract or imported
            end
        end
        if type(contract) ~= "table"
            or contract.version ~= SCOCommanderEnhancementHostVersion
            or type(contract.commanders) ~= "table"
        then
            error("SCOM commander enhancement contract is unavailable or incompatible")
        end
        return contract
    end

    local function SCOCommanderContract(unit)
        if type(unit) ~= "table" or not SCOCommanderIds[unit.tpId] then
            return nil
        end
        local commander = SCOContract().commanders[unit.tpId]
        local marker = unit.tp
            and unit.tp.additions
            and unit.tp.additions.scoCommanderEnhancements
        if type(commander) ~= "table"
            or type(commander.base) ~= "table"
            or type(commander.enhancements) ~= "table"
            or type(marker) ~= "table"
            or marker.version ~= SCOCommanderEnhancementHostVersion
            or marker.sourceId ~= commander.sourceId
            or marker.faction ~= commander.faction
        then
            error("SCOM commander enhancement template/contract drift on "
                .. tostring(unit.tpId))
        end
        return commander
    end

    local function SCOUnitIsCompleted(unit)
        return type(unit.IsCompleted) == "function" and unit:IsCompleted()
    end

    local function SCORequirementDepth(commander, enhancementId)
        local depth = 0
        local seen = {}
        local current = enhancementId
        while current do
            if seen[current] then return 1000000 end
            seen[current] = true
            local rule = commander.enhancements[current]
            if type(rule) ~= "table" then return 1000000 end
            current = rule.prerequisite
            depth = depth + 1
        end
        return depth
    end

    local function SCOInstalledIds(state, commander)
        local ids = {}
        for enhancementId, installed in pairs(state.installed or {}) do
            if installed == true and commander.enhancements[enhancementId] then
                ids[#ids + 1] = enhancementId
            end
        end
        table.sort(ids, function(a, b)
            local da = SCORequirementDepth(commander, a)
            local db = SCORequirementDepth(commander, b)
            if da == db then return a < b end
            return da < db
        end)
        return ids
    end

    local function SCOActiveDomainRules(state, commander, domain)
        local ids = SCOInstalledIds(state, commander)
        local suppressed = {}
        for _, enhancementId in ipairs(ids) do
            local rule = commander.enhancements[enhancementId]
            local effect = rule.effects and rule.effects[domain]
            if type(effect) == "table" and effect.replacesPrerequisiteEffect then
                local prerequisite = rule.prerequisite
                while prerequisite do
                    suppressed[prerequisite] = true
                    local parent = commander.enhancements[prerequisite]
                    prerequisite = parent and parent.prerequisite
                end
            end
        end
        local result = {}
        for _, enhancementId in ipairs(ids) do
            local rule = commander.enhancements[enhancementId]
            local effect = rule.effects and rule.effects[domain]
            if type(effect) == "table" and not suppressed[enhancementId] then
                result[#result + 1] = {
                    id = enhancementId,
                    rule = rule,
                    effect = effect,
                }
            end
        end
        return result
    end

    local function SCOAddReason(reasons, reason)
        if reason then reasons[reason] = true end
    end

    local function SCOEnhancementCapability(unit, rule)
        local result = {
            install = true,
            partial = false,
            domains = {},
        }
        local reasons = {}
        local domainCount = 0
        local supportedCount = 0
        local hardUnsupported = false

        for domain, effect in pairs(rule.effects or {}) do
            domainCount = domainCount + 1
            local supported = false
            local partial = false

            if type(effect) ~= "table" then
                hardUnsupported = true
                SCOAddReason(reasons, "invalid-effect-domain")
            elseif domain == "engineering" then
                supported = true
            elseif domain == "economy" then
                supported = type(effect) == "table"
            elseif domain == "shield" then
                local map = SCOShieldIdByEnhancement[unit.tpId]
                supported = type(effect) == "table"
                    and map ~= nil
                    and map[rule.id] ~= nil
                if not supported then SCOAddReason(reasons, "shield-runtime-unavailable") end
                -- FA's basic UEF/Aeon shield blueprints expose
                -- RegenAssistMult=10. Sanctuary has no shield-assist callback
                -- or repair-cost API, so the shield itself remains available
                -- while that one auxiliary behavior is declared partial.
                if supported and effect.regenAssistMultiplier ~= nil then
                    partial = true
                    SCOAddReason(reasons, "shield-regen-assist-runtime-unavailable")
                end
            elseif domain == "aura" then
                supported = unit.tpId == "usl0000"
                    and type(effect) == "table"
                    and SCOFinite(effect.radius)
                    and SCOFinite(effect.regenPerSecond)
                -- Sanctuary has no FA category-expression evaluator.  The
                -- runtime uses the safe same-army mobile subset explicitly.
                partial = supported and effect.sourceCategoryExpression ~= nil
                if partial then SCOAddReason(reasons, "aura-category-adapted") end
            elseif domain == "intel" then
                local hasVision = SCOFinite(effect.visionRadiusSet)
                local hasUnsupported = effect.omniRadiusSet ~= nil
                    or effect.sonarRadiusSet ~= nil
                    or effect.radarStealth == true
                    or effect.sonarStealth == true
                    or effect.cloak == true
                    or effect.radarStealthFromPrerequisite == true
                    or effect.sonarStealthFromPrerequisite == true
                supported = hasVision
                partial = hasVision and hasUnsupported
                if effect.cloak == true
                    or effect.radarStealth == true
                    or effect.sonarStealth == true
                    or effect.radarStealthFromPrerequisite == true
                    or effect.sonarStealthFromPrerequisite == true
                then
                    hardUnsupported = true
                    SCOAddReason(reasons, "stealth-cloak-runtime-unavailable")
                elseif effect.omniRadiusSet ~= nil then
                    SCOAddReason(reasons, "omni-runtime-unavailable")
                elseif effect.sonarRadiusSet ~= nil then
                    SCOAddReason(reasons, "sonar-runtime-unavailable")
                end
            elseif domain == "weapon" then
                local supportedWeapons = 0
                local unsupportedWeapons = 0
                for _, weaponSpec in ipairs(effect.weapons or {}) do
                    local label = weaponSpec.label
                    local isPrimary = SCOPrimaryWeaponLabels[unit.tpId]
                        and SCOPrimaryWeaponLabels[unit.tpId][label]
                    local customIndex = unit.tp.additions
                        and unit.tp.additions.scoCommanderEnhancementWeapons
                        and unit.tp.additions.scoCommanderEnhancementWeapons[label]
                    if isPrimary or customIndex then
                        supportedWeapons = supportedWeapons + 1
                    else
                        unsupportedWeapons = unsupportedWeapons + 1
                        SCOAddReason(
                            reasons,
                            label == "OverCharge"
                                and "overcharge-runtime-unavailable"
                                or "weapon-runtime-unavailable")
                    end
                end
                supported = supportedWeapons > 0
                partial = supportedWeapons > 0 and unsupportedWeapons > 0
            elseif domain == "spawn" then
                hardUnsupported = true
                SCOAddReason(reasons, "spawn-runtime-unavailable")
            elseif domain == "teleport" then
                hardUnsupported = true
                SCOAddReason(reasons, "teleport-runtime-unavailable")
            else
                hardUnsupported = true
                SCOAddReason(reasons, "unknown-effect-domain")
            end

            result.domains[domain] = supported
            if supported then supportedCount = supportedCount + 1 end
            if partial then result.partial = true end
        end

        if domainCount == 0 or supportedCount == 0 or hardUnsupported then
            result.install = false
        elseif supportedCount < domainCount then
            result.partial = true
        end

        local reasonList = SCOSortedKeys(reasons)
        if #reasonList > 0 then result.reason = table.concat(reasonList, ",") end
        return result
    end

    local function SCOCapabilities(unit, commander)
        local capabilities = SCOCopy(SCOUnsupportedGlobalCapabilities)
        capabilities.engineeringTier = 1
        capabilities.enhancements = {}
        for _, enhancementId in ipairs(SCOSortedKeys(commander.enhancements)) do
            local rule = commander.enhancements[enhancementId]
            capabilities.enhancements[enhancementId] =
                SCOEnhancementCapability(unit, rule)
        end
        return capabilities
    end

    local function SCORebuildSlotsAndTier(state, commander)
        state.slots = {}
        local tier = 1
        for _, enhancementId in ipairs(SCOInstalledIds(state, commander)) do
            local rule = commander.enhancements[enhancementId]
            state.slots[rule.slot] = enhancementId
            local engineering = rule.effects and rule.effects.engineering
            if type(engineering) == "table"
                and SCOInteger(engineering.tier or 0, 1, 3)
            then
                tier = math.max(tier, engineering.tier)
            end
        end
        state.capabilities.engineeringTier = tier
    end

    local SCOIsIdle

    local function SCOStateSnapshot(unit)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" then return nil end
        local idle = state.active == nil and SCOIsIdle(unit)
        if state._lastPublishedIdle == nil then
            state._lastPublishedIdle = idle
        elseif state._lastPublishedIdle ~= idle then
            state._lastPublishedIdle = idle
            state.revision = (state.revision + 1) % 2147483648
        end
        local active = nil
        if type(state.active) == "table" then
            local progress = math.max(0, state.active.progress or 0)
            local buildTime = state.active.buildTime
            active = {
                id = state.active.id,
                kind = state.active.kind,
                progress = progress,
                buildTime = buildTime,
                fraction = buildTime > 0
                    and math.min(1, progress / buildTime)
                    or 0,
                paused = unit:GetPause() == true,
                buildPower = state.active.buildPower,
                estimatedSeconds = state.active.estimatedSeconds,
            }
        end
        return {
            version = SCOCommanderEnhancementHostVersion,
            tpId = unit.tpId,
            unitId = { index = unit.id.index, version = unit.id.version },
            revision = state.revision,
            idle = idle,
            installed = SCOCopy(state.installed),
            slots = SCOCopy(state.slots),
            visualHidden = SCOCopy(state._visualHidden),
            active = active,
            capabilities = SCOCopy(state.capabilities),
        }
    end

    local function SCOVisualSnapshot(unit)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" then return nil end
        return {
            version = SCOCommanderEnhancementHostVersion,
            tpId = unit.tpId,
            unitId = { index = unit.id.index, version = unit.id.version },
            revision = state.revision,
            installed = SCOCopy(state.installed),
            slots = SCOCopy(state.slots),
            visualHidden = SCOCopy(state._visualHidden),
        }
    end

    local function SCOOwnerClientId(unit)
        local player = type(SCOLobby) == "table"
            and type(SCOLobby.ArmyToPlayer) == "table"
            and unit.army
            and SCOLobby.ArmyToPlayer[unit.army.id]
        local clientID = player and player.clientID
        if SCOInteger(clientID, 0, 2147483647) then return clientID end
        return nil
    end

    local function SCOEmitState(unit)
        local emitter = rawget(_G, "SCO_CommanderEnhancementEmitState")
        local snapshot = SCOStateSnapshot(unit)
        local ownerClientID = SCOOwnerClientId(unit)
        local ownerSent = false
        if type(emitter) == "function"
            and snapshot
            and ownerClientID ~= nil
        then
            local ok, sent = pcall(emitter, ownerClientID, snapshot)
            ownerSent = ok and sent == true
        end

        -- Upgrade geometry is observable gameplay state, but economy,
        -- progress, and capabilities remain owner-only. Replicate only the
        -- minimal visual projection to peers and observers.
        local visualEmitter =
            rawget(_G, "SCO_CommanderEnhancementEmitVisualState")
        local visualSnapshot = SCOVisualSnapshot(unit)
        for _, clientID in ipairs(SCOSortedKeys(SCOLobby.Players or {})) do
            if type(visualEmitter) == "function"
                and visualSnapshot
                and SCOInteger(clientID, 0, 2147483647)
            then
                pcall(visualEmitter, clientID, visualSnapshot)
            end
        end
        return ownerSent
    end

    local function SCOBumpRevision(unit)
        local state = unit.scoCommanderEnhancements
        state.revision = (state.revision + 1) % 2147483648
        SCOEmitState(unit)
    end

    local function SCOSetDetectorRadius(detector, radius)
        if detector and detector.id and SCOFinite(radius) and radius > 0
            and EngineClasses and EngineClasses.float3
            and Engine and type(Engine.SetVolumeColliderSize) == "function"
        then
            pcall(
                Engine.SetVolumeColliderSize,
                detector.id,
                EngineClasses.float3(radius, 0, 0))
        end
    end

    local function SCOSetWeaponRange(weapon)
        local rangeMin = weapon.tp.rangeMin or 0
        local rangeMax = weapon.tp.rangeMax or 0
        if Engine then
            for index, aimControllerId in ipairs(weapon.aimControllerIds or {}) do
                if type(Engine.SetAimControllerMinRange) == "function" then
                    pcall(Engine.SetAimControllerMinRange, aimControllerId, rangeMin)
                end
                if type(Engine.SetAimControllerMaxRange) == "function" then
                    pcall(Engine.SetAimControllerMaxRange, aimControllerId, rangeMax)
                end
                local aim = weapon.tp.aimControllers
                    and weapon.tp.aimControllers[index]
                if type(aim) == "table"
                    and SCOFinite(aim.projectileSpeed)
                    and type(Engine.SetAimControllerProjectileSpeed) == "function"
                then
                    pcall(
                        Engine.SetAimControllerProjectileSpeed,
                        aimControllerId,
                        aim.projectileSpeed)
                end
            end
            if weapon.targeterCollider
                and weapon.targeterCollider.id
                and type(Engine.SetVolumeColliderSize) == "function"
            then
                pcall(
                    Engine.SetVolumeColliderSize,
                    weapon.targeterCollider.id,
                    EngineClasses.float3(rangeMax, 0, 0))
            end
        end
        -- HostBeam snapshots damage/range when its muzzle is constructed.
        -- Enhancement recomputes mutate the weapon template later, so keep the
        -- proven native beam object synchronized as well.
        if type(__Muzzles) == "table" then
            for _, muzzleGroup in ipairs(weapon.muzzleGroups or {}) do
                for _, muzzle in ipairs(muzzleGroup) do
                    local hostMuzzle = muzzle.id and __Muzzles[muzzle.id.index]
                    if hostMuzzle and hostMuzzle.beam then
                        hostMuzzle.beam.damage = weapon.tp.damage
                        hostMuzzle.beam.rangeMax = rangeMax
                    end
                end
            end
        end
    end

    local function SCOWeaponForLabel(unit, label)
        if SCOPrimaryWeaponLabels[unit.tpId]
            and SCOPrimaryWeaponLabels[unit.tpId][label]
        then
            return unit.weapons and unit.weapons[1]
        end
        local index = unit.tp.additions
            and unit.tp.additions.scoCommanderEnhancementWeapons
            and unit.tp.additions.scoCommanderEnhancementWeapons[label]
        return index and unit.weapons and unit.weapons[index] or nil
    end

    local function SCOApplyWeaponSpec(weapon, spec, modifiersOnly)
        if not weapon or type(spec) ~= "table" then return end
        local tp = weapon.tp
        if not modifiersOnly then
            if SCOFinite(spec.damage) then tp.damage = spec.damage end
            if SCOFinite(spec.damageRadius) then tp.damageRadius = spec.damageRadius end
            if type(spec.damageType) == "string" then tp.damageType = spec.damageType end
            if SCOFinite(spec.minRadius) then tp.rangeMin = spec.minRadius end
            if SCOFinite(spec.maxRadius) then tp.rangeMax = spec.maxRadius end
            if SCOFinite(spec.rateOfFire) and spec.rateOfFire > 0 then
                tp.reloadTime = 1 / spec.rateOfFire
            end
            if SCOFinite(spec.muzzleSalvoSize) then
                tp.muzzleSalvoSize = spec.muzzleSalvoSize
            end
            if SCOFinite(spec.muzzleSalvoDelay) then
                tp.muzzleSalvoDelay = spec.muzzleSalvoDelay
            end
            if SCOFinite(spec.projectileLifetime) then
                tp.projectileLifetime = spec.projectileLifetime
            end
            if SCOFinite(spec.muzzleVelocity) and spec.muzzleVelocity > 0 then
                for _, aim in ipairs(tp.aimControllers or {}) do
                    aim.projectileSpeed = spec.muzzleVelocity
                end
            end
            return
        end
        if SCOFinite(spec.damageAdd) then
            tp.damage = (tp.damage or 0) + spec.damageAdd
        end
        if SCOFinite(spec.damageRadiusAdd) then
            tp.damageRadius = (tp.damageRadius or 0) + spec.damageRadiusAdd
        end
        if SCOFinite(spec.maxRadiusSet) then tp.rangeMax = spec.maxRadiusSet end
        if SCOFinite(spec.rateOfFireSet) and spec.rateOfFireSet > 0 then
            tp.reloadTime = 1 / spec.rateOfFireSet
        end
    end

    local function SCOApplyWeapons(unit, state, commander)
        for index, weapon in ipairs(unit.weapons or {}) do
            weapon.tp = SCOCopy(state._base.weaponTemplates[index])
        end

        local weaponRules = SCOActiveDomainRules(state, commander, "weapon")
        -- Establish enhancement-owned weapons before applying cross-enhancement
        -- modifiers such as CoolingUpgrade's conditional MLG range change.
        for _, item in ipairs(weaponRules) do
            for _, spec in ipairs(item.effect.weapons or {}) do
                if spec.conditionalOnEnhancement == nil then
                    SCOApplyWeaponSpec(SCOWeaponForLabel(unit, spec.label), spec, false)
                end
            end
        end
        for _, item in ipairs(weaponRules) do
            for _, spec in ipairs(item.effect.weapons or {}) do
                if spec.conditionalOnEnhancement == nil
                    or state.installed[spec.conditionalOnEnhancement] == true
                then
                    SCOApplyWeaponSpec(SCOWeaponForLabel(unit, spec.label), spec, true)
                end
            end
        end

        if unit.tpId == "usl0000"
            and SCOFinite(state._seraphimChronotronRadiusAdd)
            and state._seraphimChronotronRadiusAdd ~= 0
        then
            local chronotron = SCOWeaponForLabel(unit, "ChronotronCannon")
            if chronotron then
                chronotron.tp.damageRadius =
                    (chronotron.tp.damageRadius or 0)
                    + state._seraphimChronotronRadiusAdd
            end
        end

        local attackRange = 0
        for _, weapon in ipairs(unit.weapons or {}) do
            local tp = weapon.tp
            local required = tp.scoCommanderEnhancementRequired
            local enabled = SCOUnitIsCompleted(unit)
                and not unit.dead
                and state.active == nil
            if tp.scoCommanderEnhancementUnsupported == true then
                enabled = false
            elseif required ~= nil then
                enabled = enabled and state.installed[required] == true
            end
            if type(weapon.SetEnabled) == "function" then
                weapon:SetEnabled(enabled)
            end
            SCOSetWeaponRange(weapon)
            if enabled and not weapon.isDeathExplosion then
                attackRange = math.max(attackRange, tp.rangeMax or 0)
            end
        end
        unit.attackRange = attackRange
        unit.canAttack = attackRange > 0
    end

    local function SCOSetMovementLock(unit, locked)
        if Engine and type(Engine.SetMovementEnabled) == "function"
            and unit.id
        then
            pcall(Engine.SetMovementEnabled, unit.id, not locked)
        end
    end

    local function SCOApplyHealthAndEngineering(unit, state, commander)
        local maximum = state._base.maxHealth
        local regen = state._base.regenRate
        local buildPower = state._base.buildRate
        local regenSet = nil
        for _, item in ipairs(SCOActiveDomainRules(state, commander, "engineering")) do
            local effect = item.effect
            local suppressed = unit.tpId == "usl0000"
                and item.id == "DamageStabilization"
                and state._suppressSeraphimBaseDamageStabilization == true
            if not suppressed then
                if SCOFinite(effect.maxHealthAdd) then maximum = maximum + effect.maxHealthAdd end
                if SCOFinite(effect.regenRateAdd) then regen = regen + effect.regenRateAdd end
                if SCOFinite(effect.regenRateSet) then regenSet = effect.regenRateSet end
                if SCOFinite(effect.buildRateSet) then buildPower = effect.buildRateSet end
            end
        end
        if regenSet ~= nil then regen = regenSet end

        local oldMaximum = unit:GetMaxHealth()
        local oldHealth = unit:GetHealth()
        local missing = math.max(0, oldMaximum - oldHealth)
        unit:SetMaxHealth(maximum)
        unit:SetHealthRegen(regen)
        -- The mandatory FA veterancy layer owns the final ranked values. Its
        -- base anchors must follow the enhancement-derived values or a rank
        -- change and an enhancement recompute will overwrite one another.
        if type(unit.SCOApplyVeterancyLevel) == "function" then
            unit.scoVeterancyBaseMaxHealth = maximum
            unit.scoVeterancyBaseRegen = regen
            unit:SCOApplyVeterancyLevel(unit.scoVeterancyLevel or 0)
        end
        -- Veterancy may change maximum health and may itself grant the max-HP
        -- delta. Override only the final current HP so enhancement changes
        -- preserve the exact pre-change missing-health amount at every rank.
        unit:SetHealth(math.max(1, unit:GetMaxHealth() - missing))
        if unit.construction and type(unit.SetBuildPower) == "function" then
            unit:SetBuildPower(buildPower)
        end
    end

    local function SCOApplyEconomy(unit, state, commander)
        local energy = state._base.energyProduction
        local mass = state._base.massProduction
        for _, item in ipairs(SCOActiveDomainRules(state, commander, "economy")) do
            local effect = item.effect
            if SCOFinite(effect.energyProductionAdd) then
                energy = energy + effect.energyProductionAdd
            end
            if SCOFinite(effect.massProductionAdd) then
                mass = mass + effect.massProductionAdd
            end
        end
        local generation = unit.resourceEntities
            and unit.resourceEntities.generation
        if generation then
            local shouldEnable = SCOUnitIsCompleted(unit) and not unit.dead
            -- SetResources asks the economy to update immediately and warns
            -- for an unregistered entity. Commanders recompute once during
            -- construction, while their stock generation entity is disabled.
            if not generation.enabled then generation:SetEnabled(true) end
            generation:SetResources({ alloys = mass, energy = energy }, nil)
            generation:SetEnabled(shouldEnable)
        end
    end

    local function SCOApplyIntel(unit, state, commander)
        local vision = state._base.visionRadius
        for _, item in ipairs(SCOActiveDomainRules(state, commander, "intel")) do
            if SCOFinite(item.effect.visionRadiusSet) then
                vision = item.effect.visionRadiusSet
            end
        end
        SCOSetDetectorRadius(unit.visionDetector, vision)
    end

    local function SCOSelectedShield(state, commander, tpId)
        local selectedId = nil
        local selectedEffect = nil
        local selectedEnhancementId = nil
        local map = SCOShieldIdByEnhancement[tpId]
        if not map then return nil, nil, nil end
        for _, item in ipairs(SCOActiveDomainRules(state, commander, "shield")) do
            local shieldId = map[item.id]
            if shieldId then
                selectedId = shieldId
                selectedEffect = item.effect
                selectedEnhancementId = item.id
            end
        end
        return selectedId, selectedEffect, selectedEnhancementId
    end

    local function SCOShieldObjectById(unit, shieldId)
        for _, shield in ipairs(unit.shields or {}) do
            if shield.tp
                and shield.tp.scoCommanderEnhancementShieldId == shieldId
            then
                return shield
            end
        end
        return nil
    end

    local function SCOSetResourceUserMultiplier(entity, value)
        if not entity then return end
        value = math.max(0, math.min(value or 1, 1))
        if type(entity.SetUserMultiplier) == "function" then
            entity:SetUserMultiplier(value)
        else
            entity.userMultiplier = value
        end
    end

    local function SCOSetResourceEntityActive(entity, enabled, outcome, recalculate)
        if not entity then return end
        if enabled then
            entity:SetEnabled(true)
            if outcome then entity:SetResources(nil, outcome) end
            if recalculate and type(entity.RecalculateBuildDrain) == "function" then
                entity:RecalculateBuildDrain()
            end
        else
            entity:SetEnabled(false)
            -- ResourceEntity:SetEnabled(false) unregisters the entity but keeps
            -- its last UI drain and satisfaction multiplier. Clear both just as
            -- Sanctuary's proven strategic-silo lifecycle does.
            entity.outcome = {}
            entity.prevOutcome = {}
            entity.productionMultiplier = 0
            SCOSetResourceUserMultiplier(entity, 1)
        end
    end

    local function SCOConfigureShieldConsumption(unit, energy)
        local key = "scoCommanderShieldConsumption"
        local entity = unit.resourceEntities[key]
        if energy and energy > 0 and not entity then
            entity = SCOResourceEntity(
                unit.army.id,
                unit.id,
                "consumption",
                nil,
                nil,
                false)
            unit.resourceEntities[key] = entity
        end
        return entity
    end

    local function SCOApplyShieldState(unit, skipRecharge)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" or not unit.shields then return end
        local wantsShield = state._activeShieldId ~= nil
            and SCOUnitIsCompleted(unit)
            and not unit.dead
            and unit:GetShieldToggle() == true
        local consumption = SCOConfigureShieldConsumption(
            unit,
            state._shieldMaintenance)
        SCOSetResourceEntityActive(
            consumption,
            wantsShield,
            wantsShield and { energy = state._shieldMaintenance } or nil,
            false)
        for _, shield in ipairs(unit.shields) do
            local shieldId = shield.tp
                and shield.tp.scoCommanderEnhancementShieldId
            local desired = wantsShield and shieldId == state._activeShieldId
            shield:SetEnableable(
                desired,
                desired and skipRecharge or false)
            if desired
                and type(shield.SCOSetCommanderEnergyDown) == "function"
            then
                shield:SCOSetCommanderEnergyDown(
                    unit.army.economy.isEnergyDown == true)
            end
        end
        unit:UpdateUIValues()
    end

    local function SCOApplyShields(unit, state, commander)
        local previousShieldId = state._activeShieldId
        local previousEnhancementId = state._activeShieldEnhancementId
        local shieldId, effect, enhancementId =
            SCOSelectedShield(state, commander, unit.tpId)
        state._activeShieldId = shieldId
        state._activeShieldEnhancementId = enhancementId
        state._shieldMaintenance = effect and effect.maintenanceEnergy or nil
        for _, shield in ipairs(unit.shields or {}) do
            local id = shield.tp and shield.tp.scoCommanderEnhancementShieldId
            if id and id == shieldId then
                if enhancementId ~= previousEnhancementId
                    and shield.isEnableable == true
                then
                    shield:SetEnableable(false)
                end
                shield.tp = SCOCopy(shield.tp)
                local oldMaximum = shield:GetMaxHealth()
                local oldHealth = shield:GetHealth()
                local missing = math.max(0, oldMaximum - oldHealth)
                shield:SetMaxHealth(effect.maxHealth)
                shield:SetHealth(math.max(1, effect.maxHealth - missing))
                shield:SetHealthRegen(effect.regenRate)
                shield:SetRegenDelay(effect.regenStartTime or 1)
                shield:SetRechargeTime(effect.rechargeTime or 5)
                shield.tp.scoDamageRechargeTime = effect.rechargeTime or 5
                shield.tp.scoEnergyDrainRechargeTime =
                    effect.energyDrainRechargeTime or 5
            end
        end
        SCOApplyShieldState(
            unit,
            shieldId ~= nil
                and (previousShieldId ~= shieldId
                    or previousEnhancementId ~= enhancementId))
    end

    local function SCOCaptureShieldTransferState(unit, state, commander)
        local shieldId = SCOSelectedShield(state, commander, unit.tpId)
        if shieldId == nil then return nil, true end
        if state._activeShieldId ~= shieldId
            or type(unit.GetShieldToggle) ~= "function"
        then
            return nil, false
        end

        local shield = SCOShieldObjectById(unit, shieldId)
        if not shield
            or type(shield.GetHealth) ~= "function"
            or type(shield.GetMaxHealth) ~= "function"
            or type(shield.SetHealth) ~= "function"
            or type(shield.SetEnableable) ~= "function"
        then
            return nil, false
        end
        local toggle = unit:GetShieldToggle()
        local health = shield:GetHealth()
        local maximum = shield:GetMaxHealth()
        local enabled = shield.enabled
        local enableable = shield.isEnableable
        local recharging = shield.rechargeThread ~= nil
        if type(toggle) ~= "boolean"
            or not SCOFinite(health) or health < 0
            or not SCOFinite(maximum) or maximum <= 0
            or health > maximum + 0.000001
            or type(enabled) ~= "boolean"
            or type(enableable) ~= "boolean"
            or enableable ~= toggle
            or (enabled and (not enableable or recharging))
            or (enableable and not enabled and not recharging)
        then
            return nil, false
        end
        return {
            shieldId = shieldId,
            -- Forged Alliance capture transfers ShieldIsOn and current health,
            -- not an in-flight recharge coroutine. A popped shield therefore
            -- arrives OFF and must be explicitly enabled by its new owner.
            enabled = toggle and enabled,
            health = health,
        }, true
    end

    local function SCORestoreShieldTransferState(unit, snapshot)
        if type(snapshot) ~= "table"
            or type(unit.SetToggle) ~= "function"
            or type(unit.GetShieldToggle) ~= "function"
        then
            return false
        end
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table"
            or state._activeShieldId ~= snapshot.shieldId
        then
            return false
        end
        local shield = SCOShieldObjectById(unit, snapshot.shieldId)
        if not shield
            or type(snapshot.enabled) ~= "boolean"
            or not SCOFinite(snapshot.health)
            or snapshot.health < 0
            or type(shield.GetMaxHealth) ~= "function"
            or type(shield.SetHealth) ~= "function"
        then
            return false
        end

        -- Use Sanctuary's public host toggle route so the new owner's client
        -- receives the same authoritative Shield state as the simulation.
        local maximum = shield:GetMaxHealth()
        if not SCOFinite(maximum) or maximum <= 0 then return false end
        local health = math.max(0, math.min(maximum, snapshot.health))
        if snapshot.enabled then
            unit:SetToggle("Shield", true)
            if unit:GetShieldToggle() ~= true
                or shield.isEnableable ~= true
                or shield.enabled ~= true
            then
                return false
            end
            shield:SetHealth(health)
        else
            -- Set health first so the shield wrapper records this amount as
            -- the manual-OFF recovery target instead of the fresh full value.
            shield:SetHealth(health)
            unit:SetToggle("Shield", false)
            if unit:GetShieldToggle() ~= false
                or shield.isEnableable ~= false
                or shield.enabled ~= false
            then
                return false
            end
        end
        unit:UpdateUIValues()
        return true
    end

    local function SCOAuraTargetAllowed(source, target)
        local army = source.army
        if target == source or target.dead or target.deleted or not army
            or target.army ~= army or not target.id or not army.units
            or army.units[target.id.index] ~= target
            or target.CaptureInProgress or target.ReclaimInProgress
        then
            return false
        end
        if type(target.HasTags) == "function" and Tags then
            if Tags.COMMAND and target:HasTags(Tags.COMMAND) then return false end
            if Tags.MOBILE and not target:HasTags(Tags.MOBILE) then return false end
            -- FA targets BUILTBYTIER3FACTORY + BUILTBYQUANTUMGATE +
            -- NEEDMOBILEBUILD. Sanctuary exposes no quantum-gate or
            -- NEEDMOBILEBUILD tags; BUILDABLE_BY_T3_FACTORY is the exact
            -- available member and is substantially safer than every MOBILE.
            if Tags.BUILDABLE_BY_T3_FACTORY
                and not target:HasTags(Tags.BUILDABLE_BY_T3_FACTORY)
            then
                return false
            end
        end
        return true
    end

    local function SCOAuraThread(unit, signature, effect)
        local waitTicks = math.max(1, SCOTickRate)
        local pulseTicks = math.max(waitTicks, SCOTickRate * 5)
        local ticksUntilPulse = 0
        local activeTargets = {}
        local owner, sourceState = unit.army, unit.scoCommanderEnhancements
        while not unit.dead do
            local state = unit.scoCommanderEnhancements
            if unit.deleted or unit.army ~= owner or not unit.id or not owner
                or not owner.units or owner.units[unit.id.index] ~= unit
                or state ~= sourceState or type(state) ~= "table" or state._auraSignature ~= signature
            then
                return
            end
            if ticksUntilPulse <= 0 then
                local position = unit:GetPosition()
                local origin = { x = position.x, y = position.y, z = position.z }
                local radiusSquared = effect.radius * effect.radius
                for _, target in pairs(owner.units) do
                    if SCOAuraTargetAllowed(unit, target) then
                        local position = target:GetPosition()
                        local dx = origin.x - position.x
                        local dy = origin.y - position.y
                        local dz = origin.z - position.z
                        if dx * dx + dy * dy + dz * dz <= radiusSquared then
                            -- FA reapplies a five-second REPLACE buff every
                            -- five seconds. Track that lifetime explicitly so
                            -- a unit that leaves the radius keeps the paid-for
                            -- regeneration until its current pulse expires.
                            activeTargets[target] = pulseTicks
                        end
                    end
                end
                ticksUntilPulse = pulseTicks
            end
            for target, remainingTicks in pairs(activeTargets) do
                if not SCOAuraTargetAllowed(unit, target) then
                    activeTargets[target] = nil
                else
                    local rate = target:GetMaxHealth()
                        * effect.regenPerSecond
                        * (effect.maxHealthFactor or 1)
                    rate = math.max(effect.regenFloor or 0, rate)
                    rate = math.min(effect.regenCeiling or rate, rate)
                    if rate > 0 then target:AdjustHealth(rate) end
                    remainingTicks = remainingTicks - waitTicks
                    activeTargets[target] = remainingTicks > 0
                        and remainingTicks or nil
                end
            end
            ticksUntilPulse = ticksUntilPulse - waitTicks
            WaitTicks(waitTicks)
        end
    end

    local function SCOApplyAura(unit, state, commander)
        local selected = nil
        for _, item in ipairs(SCOActiveDomainRules(state, commander, "aura")) do
            selected = item
        end
        if selected
            and selected.id == "RegenAura"
            and state._suppressBaseRegenAura == true
        then
            selected = nil
        end
        local signature = selected and selected.id or nil
        if state._auraSignature == signature then return end
        if state._auraThread then
            KillThread(state._auraThread)
            state._auraThread = nil
        end
        state._auraSignature = signature
        if selected then
            state._auraThread = unit:NewThread(
                SCOAuraThread,
                signature,
                SCOCopy(selected.effect))
        end
    end

    local SCORecompute
    SCORecompute = function(unit)
        local state = unit.scoCommanderEnhancements
        local commander = SCOCommanderContract(unit)
        SCORebuildSlotsAndTier(state, commander)
        SCOApplyHealthAndEngineering(unit, state, commander)
        SCOApplyEconomy(unit, state, commander)
        SCOApplyIntel(unit, state, commander)
        SCOApplyWeapons(unit, state, commander)
        SCOApplyShields(unit, state, commander)
        SCOApplyAura(unit, state, commander)
        SCOSetMovementLock(unit, state.active ~= nil)
    end

    local function SCOEnsureState(unit)
        local commander = SCOCommanderContract(unit)
        local state = unit.scoCommanderEnhancements
        if state ~= nil then
            if type(state) ~= "table"
                or state.version ~= SCOCommanderEnhancementHostVersion
            then
                error("SCOM commander enhancement state marker is incompatible")
            end
            return state, commander
        end

        local base = commander.base
        if not SCOFinite(base.maxHealth)
            or not SCOFinite(base.regenRate)
            or not SCOFinite(base.buildRate)
            or not SCOFinite(base.energyProduction)
            or not SCOFinite(base.massProduction)
            or not SCOFinite(base.visionRadius)
        then
            error("SCOM commander enhancement base contract is invalid for "
                .. unit.tpId)
        end

        local weaponTemplates = {}
        for index, weapon in ipairs(unit.weapons or {}) do
            weapon.tp = SCOCopy(weapon.tp)
            weaponTemplates[index] = SCOCopy(weapon.tp)
        end
        state = {
            version = SCOCommanderEnhancementHostVersion,
            revision = 0,
            installed = {},
            slots = {},
            active = nil,
            capabilities = SCOCapabilities(unit, commander),
            _base = {
                maxHealth = base.maxHealth,
                regenRate = base.regenRate,
                buildRate = base.buildRate,
                energyProduction = base.energyProduction,
                massProduction = base.massProduction,
                visionRadius = base.visionRadius,
                weaponTemplates = weaponTemplates,
            },
            _activeShieldId = nil,
            _activeShieldEnhancementId = nil,
            _shieldMaintenance = nil,
            _auraSignature = nil,
            _auraThread = nil,
            _lastPublishedIdle = nil,
            _visualHidden = {},
            _seraphimChronotronRadiusAdd = 0,
            _suppressBaseRegenAura = false,
            _suppressSeraphimBaseDamageStabilization = false,
        }
        unit.scoCommanderEnhancements = state
        SCORecompute(unit)
        return state, commander
    end

    local function SCOValidateRule(rule, removal)
        if type(rule) ~= "table"
            or type(rule.id) ~= "string"
            or type(rule.slot) ~= "string"
            or type(rule.effects) ~= "table"
        then
            return nil, "invalid-rule"
        end
        local cost = removal and rule.removal and rule.removal.cost or rule.cost
        if type(cost) ~= "table"
            or not SCOFinite(cost.mass) or cost.mass < 0
            or not SCOFinite(cost.energy) or cost.energy < 0
            or not SCOFinite(cost.buildTime) or cost.buildTime <= 0
        then
            return nil, "invalid-cost"
        end
        return cost
    end

    local function SCOValidateOwner(clientID, unitId)
        if not SCOInteger(clientID, 0, 2147483647)
            or type(unitId) ~= "table"
            or not SCOInteger(unitId.index, 1, 2147483647)
            or not SCOInteger(unitId.version, 0, 2147483647)
        then
            return nil, "invalid-request"
        end
        local unit = GetUnitById(unitId)
        if not unit or not SCOCommanderIds[unit.tpId] then
            return nil, "unit-not-found"
        end
        if unit.dead then return nil, "unit-dead" end
        if SCOOwnerClientId(unit) ~= clientID then return nil, "not-owner" end
        local ok, state, commander = pcall(SCOEnsureState, unit)
        if not ok then return nil, "runtime-unavailable" end
        return unit, state, commander
    end

    SCOIsIdle = function(unit)
        local orders = unit.orders
        if orders and (orders.activeOrder ~= nil
            or (orders.queuedOrders and #orders.queuedOrders > 0))
        then
            return false
        end
        local busyFields = {
            "unitBeingBuilt",
            "unitBeingCaptured",
            "unitBeingReclaimed",
            "unitBeingRepaired",
            "dashBehaviorIsActive",
        }
        for _, field in ipairs(busyFields) do
            if unit[field] then return false end
        end
        return true
    end

    local function SCOInstallAllowed(state, commander, enhancementId)
        local rule = commander.enhancements[enhancementId]
        if type(rule) ~= "table" or rule.id ~= enhancementId then
            return nil, "unknown-enhancement"
        end
        local capability = state.capabilities.enhancements[enhancementId]
        if type(capability) ~= "table" or capability.install ~= true then
            return nil, capability and capability.reason or "unsupported"
        end
        if state.installed[enhancementId] then return nil, "already-installed" end
        if rule.prerequisite and not state.installed[rule.prerequisite] then
            return nil, "missing-prerequisite"
        end
        for _, conflict in ipairs(rule.conflicts or {}) do
            if state.installed[conflict] then return nil, "conflict" end
        end
        local occupant = state.slots[rule.slot]
        if occupant and occupant ~= rule.prerequisite then
            return nil, "slot-occupied"
        end
        return rule
    end

    local function SCORemovalSet(state, commander, enhancementId)
        local rule = commander.enhancements[enhancementId]
        if type(rule) ~= "table" or not state.installed[enhancementId] then
            return nil, nil, "not-installed"
        end
        local removeSet = {}
        for _, id in ipairs(rule.remove or {}) do
            if commander.enhancements[id] and state.installed[id] then
                removeSet[id] = true
            end
        end
        removeSet[enhancementId] = true
        for installedId in pairs(state.installed) do
            local current = commander.enhancements[installedId]
            local prerequisite = current and current.prerequisite
            while prerequisite do
                if removeSet[prerequisite] and not removeSet[installedId] then
                    return nil, nil, "dependent-installed"
                end
                current = commander.enhancements[prerequisite]
                prerequisite = current and current.prerequisite
            end
        end
        return rule, removeSet
    end

    local function SCONextConstructionSatisfaction(entity)
        local economy = entity and entity.economy
        local resources = economy and economy.resources
        local names = entity and entity.satisfactionTable
        if type(resources) == "table" and type(names) == "table" then
            local lowest = 1
            local found = false
            for _, name in ipairs(names) do
                local resource = resources[name]
                local satisfaction = resource and resource.satisfaction
                if SCOFinite(satisfaction) then
                    lowest = math.min(lowest, math.max(0, satisfaction))
                    found = true
                end
            end
            if found then return math.min(lowest, 1) end
        end

        -- Verifier doubles and older Sanctuary builds may not expose the
        -- economy table. Their current multiplier is the safest fallback.
        return math.max(0, math.min(
            entity and entity.productionMultiplier or 0,
            1))
    end

    local function SCOAssistOrderMatches(builder, unit)
        return (builder.assistBehaviorIsActive
                and builder.assistBehaviorAssistedUnit == unit)
            or (builder.repairBehaviorIsActive
                and builder.repairBehaviorTarget == unit)
    end

    local function SCOAssistCanWork(builder, unit)
        return builder and unit and builder ~= unit
            and not builder.dead and not builder.deleted
            and not unit.dead and not unit.deleted
            and builder:IsCompleted() and unit:IsCompleted()
            and builder:CanConstructOthers()
            and builder.army:IsAlly(unit.army)
            and unit.army:IsAlly(builder.army)
            and builder.construction
            and SCOFinite(builder.construction.buildPower)
            and builder.construction.buildPower > 0
            and not builder:GetPause() and not unit:GetPause()
            and SCOAssistOrderMatches(builder, unit)
            and builder.constructionDetectorCollider
            and builder.constructionDetectorCollider:IsOverlappingUnit(unit)
    end

    local function SCOAssistStop(builder, unit)
        local state = unit and unit.scoCommanderEnhancements
        local active = state and state.active
        if active and active.assistants then
            active.assistants[builder.id] = nil
        end
        if builder.scoCommanderEnhancementAssistTarget == unit then
            builder.scoCommanderEnhancementAssistTarget = nil
        end
        -- Contribution entities describe work already paid for this tick.
        -- Only the commander's progress thread may retire them.
    end

    local function SCOAssistStart(builder, unit)
        local state = unit and unit.scoCommanderEnhancements
        local active = state and state.active
        if not active or not SCOAssistCanWork(builder, unit) then return false end
        local previous = builder.scoCommanderEnhancementAssistTarget
        if previous and previous ~= unit then SCOAssistStop(builder, previous) end
        builder.scoCommanderEnhancementAssistTarget = unit
        active.assistants[builder.id] = builder
        return true
    end

    local function SCORetireAssistEntity(unit, active, id)
        local contribution = active.assistEntities[id]
        local builder, entity = contribution.builder, contribution.entity
        entity:SetEnabled(true)
        entity:RemoveBuilder(builder)
        SCOSetResourceEntityActive(entity, false, nil, false)
        if builder.resourceEntities.scoCommanderEnhancementAssist == entity then
            builder.resourceEntities.scoCommanderEnhancementAssist = nil
        end
        active.assistEntities[id] = nil
        if not builder.dead and not builder.deleted then builder:UpdateUIValues() end
    end

    local function SCOClearAssistants(unit, active)
        for id in pairs(active.assistEntities) do
            SCORetireAssistEntity(unit, active, id)
        end
        for _, builder in pairs(active.assistants) do
            if builder.scoCommanderEnhancementAssistTarget == unit then
                builder.scoCommanderEnhancementAssistTarget = nil
            end
        end
        active.assistants = {}
    end

    local function SCOReconcileAssistants(unit, active)
        for id, contribution in pairs(active.assistEntities) do
            local builder = active.assistants[id]
            if builder ~= contribution.builder
                or builder.scoCommanderEnhancementAssistTarget ~= unit
                or not SCOAssistCanWork(builder, unit)
                or builder.army.id ~= contribution.entity.armyId
            then
                SCORetireAssistEntity(unit, active, id)
            end
        end
        for id, builder in pairs(active.assistants) do
            if builder.scoCommanderEnhancementAssistTarget ~= unit
                or not SCOAssistCanWork(builder, unit)
            then
                SCOAssistStop(builder, unit)
            else
                local contribution = active.assistEntities[id]
                if not contribution then
                    -- FA charges each assisting builder's army. A separate
                    -- native entity also preserves independent economy stalls.
                    local entity = SCOResourceEntity(
                        builder.army.id, builder.id, "construction", nil, nil, false)
                    entity:SetCost({ alloys = active.cost.mass, energy = active.cost.energy })
                    entity:SetBuildTime(active.buildTime)
                    entity:SetEnabled(true)
                    entity:AddBuilder(builder)
                    contribution = { builder = builder, entity = entity,
                        buildPower = builder.construction.buildPower }
                    active.assistEntities[id] = contribution
                    builder.resourceEntities.scoCommanderEnhancementAssist = entity
                    builder:UpdateUIValues()
                elseif contribution.buildPower ~= builder.construction.buildPower then
                    contribution.entity:UpdateBuilder(builder)
                    contribution.buildPower = builder.construction.buildPower
                    builder:UpdateUIValues()
                end
            end
        end
        local buildPower = unit.construction.buildPower
        for _, contribution in pairs(active.assistEntities) do
            buildPower = buildPower + contribution.buildPower
        end
        if active.buildPower ~= buildPower then
            active.buildPower = buildPower
            active.estimatedSeconds = buildPower > 0 and active.buildTime / buildPower or nil
            SCOBumpRevision(unit)
        end
    end

    local RushPressure = Import("AI/mods/AI-Scom/RushPressure.lua")
    local function SCOPlanNextProgressTick(unit)
        local state = unit.scoCommanderEnhancements
        local active = state and state.active
        local entity = unit.resourceEntities.scoCommanderEnhancement
        if not active or not entity then return end
        local remaining = math.max(0, active.buildTime - active.progress)
        local fullWork = math.max(0, entity.buildPower or 0)
            * SCONextConstructionSatisfaction(entity)
        for _, contribution in pairs(active.assistEntities) do
            local helper = contribution.entity
            fullWork = fullWork + math.max(0, helper.buildPower or 0)
                * SCONextConstructionSatisfaction(helper)
        end
        local userMultiplier = RushPressure.EnhancementMultiplier(unit,active,entity)
        if fullWork > 0 and remaining < fullWork * userMultiplier then
            userMultiplier = remaining / fullWork
        end
        SCOSetResourceUserMultiplier(entity, userMultiplier)
        for _, contribution in pairs(active.assistEntities) do
            SCOSetResourceUserMultiplier(contribution.entity, userMultiplier)
        end
    end

    local function SCOSetProgressEntityEnabled(unit, enabled)
        local entity = unit.resourceEntities.scoCommanderEnhancement
        SCOSetResourceEntityActive(entity, enabled, nil, enabled)
        if enabled then SCOPlanNextProgressTick(unit) end
        unit:UpdateUIValues()
    end

    local function SCOReleaseActive(unit, killThread)
        local state = unit.scoCommanderEnhancements
        local active = state and state.active
        if not active then return end
        if killThread and active.thread then KillThread(active.thread) end
        active.thread = nil
        SCOClearAssistants(unit, active)
        local entity = unit.resourceEntities.scoCommanderEnhancement
        if entity then
            entity:SetEnabled(true)
            entity:RemoveBuilder(unit)
            SCOSetResourceEntityActive(entity, false, nil, false)
        end
        state.active = nil
        SCOSetMovementLock(unit, false)
        SCORecompute(unit)
        unit:UpdateUIValues()
    end

    local function SCOCompleteActive(unit, active)
        local state = unit.scoCommanderEnhancements
        if not state or state.active ~= active or unit.dead then return end
        local previous = SCOCopy(state.installed)
        local previousVisualHidden = SCOCopy(state._visualHidden)
        local previousRadiusAdd = state._seraphimChronotronRadiusAdd
        local previousAuraSuppression = state._suppressBaseRegenAura
        local previousDamageSuppression =
            state._suppressSeraphimBaseDamageStabilization
        active.thread = nil
        SCOClearAssistants(unit, active)
        local entity = unit.resourceEntities.scoCommanderEnhancement
        if entity then
            entity:SetEnabled(true)
            entity:RemoveBuilder(unit)
            SCOSetResourceEntityActive(entity, false, nil, false)
        end
        state.active = nil
        -- Release this job's lock even if one optional effect later fails.
        SCOSetMovementLock(unit, false)
        if active.kind == "install" then
            state.installed[active.id] = true
            local commander = SCOCommanderContract(unit)
            local rule = commander and commander.enhancements[active.id]
            if unit.tpId == "ugl0000" and rule and rule.slot == "Back" then
                state._visualHidden.Back_Upgrade = nil
            end
            if unit.tpId == "usl0000"
                and (active.id == "RegenAura"
                    or active.id == "AdvancedRegenAura")
            then
                state._suppressBaseRegenAura = false
            elseif unit.tpId == "usl0000"
                and active.id == "DamageStabilization"
            then
                -- A fresh base installation recreates the stock base buff.
                state._suppressSeraphimBaseDamageStabilization = false
            end
        else
            for enhancementId in pairs(active.removeSet or {}) do
                state.installed[enhancementId] = nil
            end
            if unit.tpId == "ugl0000"
                and active.id == "MicrowaveLaserGenerator"
            then
                -- URL0001's stock remover also hides Back_Upgrade.
                state._visualHidden.Back_Upgrade = true
            elseif unit.tpId == "usl0000" and active.id == "BlastAttack" then
                -- XSL0001 adds +2 on install, then its remover's absent
                -- NewDamageRadius falls back to +5 instead of subtracting.
                state._seraphimChronotronRadiusAdd =
                    state._seraphimChronotronRadiusAdd + 7
            elseif unit.tpId == "usl0000"
                and active.id == "AdvancedRegenAura"
            then
                state._suppressBaseRegenAura = true
            elseif unit.tpId == "usl0000" and active.id == "RegenAura" then
                state._suppressBaseRegenAura = false
            elseif unit.tpId == "usl0000"
                and active.id == "DamageStabilizationAdvanced"
            then
                -- XSL0001 removes both buff objects while retaining the base
                -- enhancement flag. Persist that discrepancy so reinstalling
                -- Advanced stacks only its +20000/+150 until the base stage is
                -- explicitly removed and installed again.
                state._suppressSeraphimBaseDamageStabilization = true
            elseif unit.tpId == "usl0000"
                and active.id == "DamageStabilization"
            then
                state._suppressSeraphimBaseDamageStabilization = false
            end
        end
        local ok, reason = pcall(SCORecompute, unit)
        if not ok then
            -- Retain the first exact state failure for diagnosis without a
            -- recurring warning on each retry. Native payment and effect rollback are unchanged.
            if not state._aiCompletionFailureWarned then
                state._aiCompletionFailureWarned = true
                local logger = type(Warn) == "function" and Warn or type(Log) == "function" and Log
                if logger then
                    pcall(logger, "[RushV9] commander=" .. tostring(unit.tpId)
                        .. " enhancement=" .. tostring(active.id)
                        .. " completion effect failed: " .. tostring(reason))
                end
            end
            state.installed = previous
            state._visualHidden = previousVisualHidden
            state._seraphimChronotronRadiusAdd = previousRadiusAdd
            state._suppressBaseRegenAura = previousAuraSuppression
            state._suppressSeraphimBaseDamageStabilization =
                previousDamageSuppression
            pcall(SCORecompute, unit)
        end
        unit:UpdateUIValues()
        SCOBumpRevision(unit)
    end

    local function SCOProgressThread(unit, active)
        while not unit.dead do
            local state = unit.scoCommanderEnhancements
            if not state or state.active ~= active then return end
            -- Economy.Update runs before client commands and Lua threads. The
            -- entity's current multiplier is therefore payment already made
            -- for this tick. Consume it before observing a new pause toggle;
            -- otherwise pausing between those phases would charge resources
            -- without granting the matching work.
            if not active.paused then
                local entity = unit.resourceEntities.scoCommanderEnhancement
                local currentBuildPower = unit.construction.buildPower
                local multiplier = entity.productionMultiplier or 0
                local userMultiplier = entity.userMultiplier or 1
                local paidWork = entity.buildPower * multiplier * userMultiplier
                for _, contribution in pairs(active.assistEntities) do
                    local helper = contribution.entity
                    paidWork = paidWork + helper.buildPower
                        * (helper.productionMultiplier or 0) * (helper.userMultiplier or 1)
                end
                active.progress = math.min(
                    active.buildTime,
                    active.progress + paidWork)
                local bucket = math.floor(math.min(1,
                    active.progress / active.buildTime) * 100)
                if bucket > active.lastPublishedBucket then
                    active.lastPublishedBucket = bucket
                    SCOBumpRevision(unit)
                end
                if active.progress + 0.000001 >= active.buildTime then
                    SCOCompleteActive(unit, active)
                    return
                end
                -- Economy.Update has already charged this tick using the
                -- entity's old builder contribution. Apply a build-power
                -- change only after consuming that paid work, so the next
                -- economy tick and the next progress tick stay identical.
                if currentBuildPower ~= active.sourceBuildPower then
                    entity:UpdateBuilder(unit)
                    active.sourceBuildPower = currentBuildPower
                end
            end
            SCOReconcileAssistants(unit, active)
            local paused = unit:GetPause() == true
            if paused ~= active.paused then
                active.paused = paused
                SCOSetProgressEntityEnabled(unit, not paused)
                SCOBumpRevision(unit)
            elseif not paused then
                -- Resource satisfactions describe the next economy tick.
                -- Clamp that tick to the remaining work so it cannot charge
                -- past the authored FA cost.
                SCOPlanNextProgressTick(unit)
            end
            WaitTicks(1)
        end
    end

    local function SCOStartWork(unit, state, enhancementId, kind, cost, removeSet)
        local entity = unit.resourceEntities.scoCommanderEnhancement
        if not entity then
            entity = SCOResourceEntity(
                unit.army.id,
                unit.id,
                "construction",
                nil,
                nil,
                false)
            unit.resourceEntities.scoCommanderEnhancement = entity
        end
        SCOSetResourceEntityActive(entity, false, nil, false)
        entity:SetCost({ alloys = cost.mass, energy = cost.energy })
        entity:SetBuildTime(cost.buildTime)
        -- ResourceEntity:AddBuilder calls RecalculateBuildDrain, whose economy
        -- update requires the entity to be registered first.
        entity:SetEnabled(true)
        entity:AddBuilder(unit)
        local buildPower = unit.construction.buildPower
        local active = {
            id = enhancementId,
            kind = kind,
            progress = 0,
            buildTime = cost.buildTime,
            buildPower = buildPower,
            sourceBuildPower = buildPower,
            cost = { mass = cost.mass, energy = cost.energy },
            assistants = {},
            assistEntities = {},
            estimatedSeconds = buildPower > 0 and cost.buildTime / buildPower or nil,
            paused = unit:GetPause() == true,
            lastPublishedBucket = 0,
            removeSet = removeSet,
            thread = nil,
        }
        state.active = active
        SCOApplyWeapons(unit, state, SCOCommanderContract(unit))
        SCOSetMovementLock(unit, true)
        SCOSetProgressEntityEnabled(unit, not active.paused)
        active.thread = unit:NewThread(SCOProgressThread, active)
        SCOBumpRevision(unit)
        return true
    end


    local function TrustedOwner(unit)
        if IsHost~=true or type(unit)~="table" or unit.dead or unit.deleted or not unit.id or not unit.army
            or unit.CaptureInProgress or unit.ReclaimInProgress or not SCOCommanderIds[unit.tpId] then return false end
        local army=unit.army
        if not army.ai or army.ai.isAlive~=true or not army.units
            or army.units[unit.id.index]~=unit or GetUnitById(unit.id)~=unit then return false end
        if SCOLobby.ArmyToPlayer and SCOLobby.ArmyToPlayer[army.id] then return false end
        local settings=army.ai.settings or {}
        local directory=tostring(settings.modDirectory or ""):gsub("\\","/"):gsub("/+$","")
        return directory=="AI/mods/AI-Scom" or directory:sub(-#"/AI-Scom")=="/AI-Scom"
            or directory=="" and settings.modName=="AI-Scom"
    end
    local function CompatibleState(state)
        return type(state)=="table" and state.version==SCOCommanderEnhancementHostVersion
            and type(state.capabilities)=="table" and type(state.capabilities.enhancements)=="table"
            and type(state.installed)=="table" and type(state.slots)=="table"
            and type(state._base)=="table" and type(state._base.weaponTemplates)=="table"
            and SCOFinite(state.revision) and (state.active==nil or type(state.active)=="table")
    end
    local function Trusted(unit)
        if not TrustedOwner(unit) or not CompatibleState(unit.scoCommanderEnhancements) then return false end
        local failed=unit.scoAIEnhancementBootstrapFailure
        return not failed or failed.state~=unit.scoCommanderEnhancements
    end
    local function RuntimeWarning(unit,reason)
        if unit.scoAIEnhancementRuntimeWarning then return end
        unit.scoAIEnhancementRuntimeWarning=true
        local logger=type(Warn)=="function" and Warn or type(Log)=="function" and Log
        if logger then
            pcall(logger,"[RushV9] commander="..tostring(unit.tpId)
                .." enhancement runtime unavailable: "..tostring(reason))
        end
    end
    -- Native capabilities describe the core. This paid adapter must also be
    -- able to apply every required behavior before it accepts an AI purchase.
    local function Supports(unit, rule)
        if type(rule) ~= "table" or type(rule.id) ~= "string" then
            return false, "invalid-enhancement"
        end
        local commander = SCOCommanderContract(unit)
        if not commander or commander.enhancements[rule.id] ~= rule then
            return false, "contract-mismatch"
        end
        local capability = SCOEnhancementCapability(unit, rule)
        if capability.install ~= true then
            return false, capability.reason or "adapter-effect-unavailable"
        end
        local weapons = rule.effects and rule.effects.weapon
        for _, spec in ipairs(weapons and weapons.weapons or {}) do
            local primary = SCOPrimaryWeaponLabels[unit.tpId]
                and SCOPrimaryWeaponLabels[unit.tpId][spec.label]
            -- Primary gun modifiers and the supplied Cybran beam are automatic
            -- weapons. Other added weapons need their own native activation /
            -- ammunition contract; a template index alone cannot establish it.
            if not primary and spec.label ~= "OverCharge"
                and rule.id ~= "MicrowaveLaserGenerator"
                and spec.conditionalOnEnhancement ~= "MicrowaveLaserGenerator"
            then
                return false, "adapter-weapon-activation-unavailable"
            end
        end
        return true
    end

    local function Begin(unit,state,id,kind,cost,removeSet)
        if not Trusted(unit) or kind~="install" or removeSet~=nil
            or unit.scoCommanderEnhancements~=state or state.active then return false,"not-ai-owner" end
        if not SCOUnitIsCompleted(unit) or not SCOIsIdle(unit) then return false,"unit-busy" end
        local commander=SCOCommanderContract(unit)
        local rule,reason=SCOInstallAllowed(state,commander,id)
        if not rule then return false,reason end
        local supported,unsupportedReason=Supports(unit,rule)
        if not supported then return false,unsupportedReason end
        local actual,why=SCOValidateRule(rule,false)
        if not actual or cost~=actual then return false,why or "cost-mismatch" end
        local ability=unit.scoCommanderAbilities
        if ability and (ability.teleport or ability.missileLaunch
            or (ability.missileBuild and ability.missileBuild.autoBuild~=true)) then return false,"ability-busy" end
        return SCOStartWork(unit,state,id,kind,actual,nil)
    end
    local function Stop(unit,kill)
        if not Trusted(unit) then return false end
        SCOReleaseActive(unit,kill)
        return true
    end
    function APIFor(unit)
        if not TrustedOwner(unit) then return nil end
        -- AI commanders may never visit the human request path that lazily
        -- initializes the host state. Validate the loaded contract/template
        -- first, then use the same initializer only for genuinely absent state.
        local valid,commander=pcall(SCOCommanderContract,unit)
        if not valid or not commander then
            RuntimeWarning(unit,valid and "commander contract missing" or commander);return nil
        end
        local failed=unit.scoAIEnhancementBootstrapFailure
        if failed and failed.state==unit.scoCommanderEnhancements then return nil end
        if unit.scoCommanderEnhancements==nil then
            if not SCOUnitIsCompleted(unit) then return nil end
            if type(unit.construction)~="table" or not SCOFinite(unit.construction.buildPower)
                or unit.construction.buildPower<=0 or type(unit.resourceEntities)~="table"
                or type(unit.weapons)~="table" then
                RuntimeWarning(unit,"completed commander has no native construction/weapon state");return nil
            end
            local ok,reason=pcall(function()
                SCOEnsureState(unit)
                unit:UpdateUIValues()
                SCOBumpRevision(unit)
            end)
            if not ok then
                -- Do not overwrite or trust a state left partway through a
                -- failed native recompute. A later distinct host state may recover.
                unit.scoAIEnhancementBootstrapFailure={state=unit.scoCommanderEnhancements}
                RuntimeWarning(unit,reason);return nil
            end
        end
        if not Trusted(unit) then
            RuntimeWarning(unit,"existing enhancement state is incompatible");return nil
        end
        return {ensure=SCOEnsureState,idle=SCOIsIdle,complete=SCOUnitIsCompleted,
            allowed=SCOInstallAllowed,validate=SCOValidateRule,begin=Begin,
            stop=Stop,publish=SCOBumpRevision,
            supports=function(rule) return Supports(unit,rule) end}
    end
end
