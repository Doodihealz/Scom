local function scoTractorIsEligible(weapon, target, claimed)
    if not scoTractorIsCurrent(target)
        or (not claimed and target.isTargetable ~= true)
        or target.canTakeDamage == false or target.canBeKilled == false
        or not weapon.unit.army:IsEnemy(target.army)
        or not target:IsCompleted() or not scoTractorHasCategory(target, 'MOBILE')
        or not (scoTractorHasCategory(target, 'TECH1') or scoTractorHasCategory(target, 'TECH2')
            or scoTractorHasCategory(target, 'TECH3'))
        or target.scoCargoCarrier or target.scoCargoReleasing or target.scoCargoPendingCarrier
        or target.scoFactoryColliderPinOwner
        or (not claimed and target:IsBeingTransported()) then return false end
    for _, excluded in ipairs({'STRUCTURE','COMMAND','COMMANDER','SUBCOMMANDER','SUPPORTCOMMANDER','EXPERIMENTAL','TECH4','TECH5'}) do
        if scoTractorHasCategory(target, excluded) then return false end
    end
    return true
end

local function scoTractorRelease(weapon, restoreTarget)
    local target, key = weapon.scoTractorTarget, weapon.scoTractorTargetKey
    local claim = key and scoTractorClaims[key]
    local owns = claim and claim.weapon == weapon and claim.target == target
    local adapter = weapon.scoNativeTractorTransport
    if owns then
        scoTractorClaims[key] = nil
        if target.scoTractorTargetKey == key then target.scoTractorTargetKey = nil end
    end
    if target and weapon.scoNativeTractorDestroyed then
        target:RemoveCallback(weapon.scoNativeTractorDestroyed, 'OnDestroyed')
    end
    weapon.scoNativeTractorDestroyed, weapon.scoNativeTractorTransport = nil, nil
    weapon.scoNativeTractorPoint = nil
    weapon.scoTractorTarget, weapon.scoTractorTargetKey, weapon.scoTractorCaptureBone = nil, nil, nil
    weapon.scoTractorReleasing = true
    scoTractorStockSetAimTarget(weapon, nil)
    weapon.scoTractorReleasing = nil
    weapon:SetMuzzlesFiring(false)
    if owns and target and target.transport == adapter then
        if restoreTarget and scoTractorIsCurrent(target) then
            target:BeginDrop(_G.defaultGravityAcceleration, function(unit)
                unit:Land(unit:WaitForDropContact(scoTractorHasCategory(unit, 'NAVAL') or scoTractorHasCategory(unit, 'AIR')))
            end)
        else
            target:Destroyed()
        end
    end
end

local function scoTractorTryClaim(weapon)
    local config, target = weapon.tp and weapon.tp.scoTractor, weapon.targetUnit
    if not config or not weapon.enabled or not scoTractorIsCurrent(weapon.unit)
        or weapon.scoTractorTarget or weapon.currentState ~= WeaponState.WaitingPersistentBeamLifetime
        or weapon.beamPendingEnable or not scoTractorIsEligible(weapon, target)
        or scoTractorIsAlreadyUsed(weapon, target) then return end
    local key = scoTractorTargetKey(target)
    local bone = weapon.unit:GetBoneId(config.captureBone)
    if not key or not bone or scoTractorClaims[key] then return end
    local point = {boneId=bone, unit=target, attached=false}
    local adapter = {
        id=weapon.unit.id,
        tp={transport={liftSpeed=config.pullSpeed, liftRotationSpeed=180, attachRadius=0.6}},
        GetOrientation=function() return weapon.unit:GetOrientation() end,
        ReleaseAttachPoint=function(_, released) released.unit=nil; released.attached=false end,
    }
    scoTractorClaims[key] = {weapon=weapon, target=target}
    weapon.scoTractorTarget, weapon.scoTractorTargetKey, weapon.scoTractorCaptureBone = target, key, bone
    weapon.scoNativeTractorTransport, weapon.scoNativeTractorPoint = adapter, point
    target.scoTractorTargetKey = key
    weapon.scoNativeTractorDestroyed = function() scoTractorRelease(weapon, false) end
    target:AddCallback(weapon.scoNativeTractorDestroyed, 'OnDestroyed')
    target:BeginLoading(adapter, point)
    for _, eye in ipairs(weapon.unit.weapons or {}) do
        if eye.tp and eye.tp.scoSourceLabel == 'EyeWeapon' and eye.targetUnit == target then
            eye:SetAimTarget(nil); eye:SetMuzzlesFiring(false); eye:RequestRetarget()
        end
    end
end

local function scoTractorPull(weapon)
    local target, point = weapon.scoTractorTarget, weapon.scoNativeTractorPoint
    if not scoTractorIsCurrent(weapon.unit) or not weapon.enabled
        or not scoTractorIsEligible(weapon, target, true)
        or not point or point.unit ~= target or target.transport ~= weapon.scoNativeTractorTransport then
        scoTractorRelease(weapon, true)
        return
    end
    if type(Engine.IsValidGlobalID) == 'function' and not Engine.IsValidGlobalID(point.boneId) then
        scoTractorRelease(weapon, true)
        return
    end
    if point.attached then
        local result, position = Engine.GetGlobalEntityWorldPosition(point.boneId)
        if result ~= EngineErrorCode.Success then scoTractorRelease(weapon, true); return end
        scoTractorRelease(weapon, false)
        scoTractorCrush(weapon, target, position)
    end
end
