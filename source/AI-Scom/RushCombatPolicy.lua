-- RC10 land-operation policy. Pure decisions: no engine calls, wall-clock time,
-- random choices, hidden-enemy access, or changes to unit/weapon templates.
Version = "9.3.0"
Config = {
    PrimaryLimit = 64, WaveLimit = 48, SupportLimit = 12, SupportInstances = 3,
    WaveInstances = 48, GroupSeconds = 4, CommitSeconds = 12,
    RetreatMinimum = 6, RetreatMaximum = 24, RetreatDistance = 72,
    ObjectiveCooldown = 60, ObjectiveRetry = 8, ContactGrace = 3,
    RepathSeconds = 20, AbandonSeconds = 45, MaximumRepaths = 2,
    NoContactSeconds = 24, SnapshotSeconds = 0.5, CoreRadiusLimit = 64,
    ContactSenseSeconds = 0.3, MovingSenseSeconds = 0.5, IdleSenseSeconds = 1,
    OpportunitySeconds = 8, ForwardProbeMinimum = 4, ForwardProbeSeconds = 30,
}

-- Fast local reassessment shares the army's spatial snapshot; it never starts
-- another full-map sensor thread or shortens retreat/commitment hysteresis.
function SenseSeconds(s, underFire, exposed)
    if s.phase == "Acquire" then return 0.1 end
    if s.phase == "Engage" or s.phase == "Retreat" or underFire or exposed then
        return Config.ContactSenseSeconds
    end
    if s.phase == "Advance" or s.phase == "Group" then return Config.MovingSenseSeconds end
    return Config.IdleSenseSeconds
end

function New(now)
    return { phase = "Group", phaseAt = now, lastProgressAt = now,
        nextAcquire = now, repaths = 0, retreats = 0, goalChanges = 0,
        retreatCooldownUntil = 0 }
end

local function Change(s, phase, now)
    if s.phase ~= phase then s.phase, s.phaseAt = phase, now end
end

function GoalStarted(s, now)
    Change(s, "Advance", now)
    s.lastProgressAt, s.repaths, s.nextRepath = now, 0, nil
    s.goalChanges = s.goalChanges + 1
    s.unfavourableAt, s.noContactAt = nil, nil
    s.nextOpportunity = now + Config.OpportunitySeconds
end

function Hold(s, now, reason)
    Change(s, "Hold", now)
    s.nextAcquire, s.holdReason = now + Config.ObjectiveRetry, reason
    s.unfavourableAt, s.noContactAt = nil, nil
end

function Acquire(s, now)
    Change(s, "Acquire", now)
    s.nextAcquire, s.unfavourableAt = now, nil
end

function Progress(s, now)
    s.lastProgressAt = now
end

-- Only actual reinforcements wake a force waiting for more strength. Existing
-- attacks, committed retreats and path-failure cooldowns keep their ownership.
function Reinforced(s, now)
    if s.phase ~= "Hold" or now < (s.nextReinforcementCheck or 0) then return false end
    local reason = s.holdReason
    if reason ~= "no-safe-objective" and reason ~= "assembling-front"
        and reason ~= "containment" and reason ~= "retreat-reassess" then return false end
    s.nextReinforcementCheck = now + 2
    s.nextAcquire = math.min(s.nextAcquire or now, now)
    return true
end

-- Reconsider exploration orders on a bounded cadence. Actual attack, defense,
-- siege, contact, deferred paths and withdrawal missions are never interrupted.
function OpportunityDue(s, i, kind)
    if s.phase ~= "Advance" or (kind ~= "alloy-patrol" and kind ~= "probe")
        or i.nearTarget or i.underFire or i.pathPending or not i.goalValid or i.goalExpired
        or not CanEngage(s, i, false) or i.now < (s.nextOpportunity or 0) then return false end
    s.nextOpportunity = i.now + Config.OpportunitySeconds
    return true
end

local function EnterCombat(s, i)
    Change(s, "Engage", i.now)
    s.commitUntil, s.commitThreat = i.now + Config.CommitSeconds, i.own
    s.lastTargetAt = i.now
    if i.contact then s.noContactAt = nil else s.noContactAt = i.now end
    s.approachTarget, s.closestTargetDistance, s.lastApproachAt = i.target, i.targetDistance, i.now
    s.unfavourableAt = nil
    return "micro", "contact"
end

function Retreat(s, i, reason)
    Change(s, "Retreat", i.now)
    s.retreats, s.retreatThreat = s.retreats + 1, i.enemy
    s.retreatCooldownUntil = i.now + Config.RetreatMaximum + Config.ObjectiveRetry
    s.unfavourableAt, s.noContactAt = nil, nil
    return "retreat", reason
end

-- Do not let a weak nearby target pull an otherwise safe group into a defended
-- position. Only observed, predominantly static resistance asks for assembly;
-- ordinary mobile contacts retain the existing engagement/retreat policy.
function NeedsAssaultAssembly(own, friendly, assessment, ratio)
    local total=assessment and assessment.total or 0
    local fixed=assessment and assessment.static or 0
    return own>0 and fixed>0 and fixed>=total*0.60
        and total>math.max(0,own+(friendly or 0))*(ratio or 0.80)
end

-- Entry and exit thresholds differ. Merely seeing a distant enemy is not a
-- committed engagement; the adapter supplies actual weapon-range contact.
function CanEngage(s, i, retaining)
    if i.own <= 0 then return false end
    local effective = math.max(0, i.own + (i.friendly or 0))
    if i.enemy <= effective * (i.attackRatio or 1.05) then return true end
    if not retaining then return false end
    if i.primary then
        -- Retention follows entry caution monotonically, with the established
        -- 0.80 entry / 1.25 retention baseline as its upper ceiling.
        local entry=i.attackRatio or 0.80
        local retention=math.max(entry,math.min(1.25,entry+0.45))
        return i.nearTarget==true and i.enemy<=effective*retention
    end
    if i.raider then return false end
    if i.enemy > effective * 1.8 then return false end
    if s.commitThreat and i.own < s.commitThreat * 0.60 and i.enemy > effective then return false end
    if i.enemy <= effective * 1.25 then return true end
    return i.now < (s.commitUntil or 0) and i.enemy <= effective * 1.40
        and i.own >= (s.commitThreat or i.own) * 0.72
end

-- Returns one action. The adapter performs it, then records acceptance/failure.
-- Retreat time cannot be reset by a new target, reinforcement, or another call.
function Step(s, i)
    if i.count <= 0 then return "finish", "empty" end
    if i.now < s.phaseAt then
        -- A rewound test/save clock must not create an effectively infinite timer.
        s.phaseAt, s.lastProgressAt, s.nextAcquire = i.now, i.now, i.now
        s.commitUntil, s.retreatCooldownUntil = i.now, i.now
    end
    local effective = math.max(0, i.own + (i.friendly or 0))
    local hardDanger = i.enemy > math.max(1, effective) * 1.8
    local entry = CanEngage(s, i, false)

    if s.phase == "Retreat" then
        local elapsed = i.now - s.phaseAt
        if elapsed >= Config.RetreatMinimum and
            (i.arrived or i.enemy <= effective * 0.60 or elapsed >= Config.RetreatMaximum) then
            if not entry and i.enemy > 0 then Hold(s, i.now, "retreat-reassess")
            else Acquire(s, i.now) end
            return "retreat-finished", elapsed >= Config.RetreatMaximum and "deadline" or "regrouped"
        end
        return "move", "retreat"
    end

    if s.phase == "Group" then
        if i.nearTarget and entry then return EnterCombat(s, i) end
        if hardDanger then return Retreat(s, i, "opening-contact") end
        if i.arrived or i.now - s.phaseAt >= Config.GroupSeconds then
            Acquire(s, i.now)
            return "acquire", "formed-core"
        end
        return "move", "group"
    end

    if s.phase == "Hold" then
        if i.nearTarget and entry then return EnterCombat(s, i) end
        -- Do not keep issuing the same home order under unchanged distant
        -- artillery. Only newly closing, immediate danger can start another leg.
        if hardDanger and (i.contact or i.underFire) and i.now >= s.retreatCooldownUntil then
            return Retreat(s, i, "pursued")
        end
        if i.now >= s.nextAcquire then
            Acquire(s, i.now)
            return "acquire", "reassess"
        end
        return "hold", s.holdReason
    end

    if s.phase == "Acquire" then
        if i.nearTarget and entry then return EnterCombat(s, i) end
        if i.now >= s.nextAcquire then return "acquire", "objective" end
        return "hold", "selection-budget"
    end

    if s.phase == "Engage" then
        if not CanEngage(s, i, true) then
            s.unfavourableAt = s.unfavourableAt or i.now
            if hardDanger or i.primary or i.now - s.unfavourableAt >= 2 then
                return Retreat(s, i, hardDanger and "overwhelmed" or "losing-engagement")
            end
        else s.unfavourableAt = nil end
        if i.nearTarget then
            s.lastTargetAt = i.now
            if i.contact then
                s.noContactAt = nil
                s.approachTarget, s.closestTargetDistance, s.lastApproachAt = i.target, i.targetDistance, i.now
            elseif not s.noContactAt or s.approachTarget ~= i.target then
                s.noContactAt = i.now
                s.approachTarget, s.closestTargetDistance, s.lastApproachAt = i.target, i.targetDistance, i.now
            elseif i.targetDistance and (not s.closestTargetDistance or i.targetDistance <= s.closestTargetDistance - 4) then
                s.closestTargetDistance, s.lastApproachAt = i.targetDistance, i.now
            end
            -- Circling or formation shuffling is movement, but does not close
            -- an unreachable target. Only improved approach or weapon contact
            -- keeps this engagement alive; ordinary route progress is separate.
            if s.noContactAt and i.now - s.noContactAt >= Config.NoContactSeconds
                and i.now - (s.lastApproachAt or s.noContactAt) >= 12 then
                Acquire(s, i.now)
                return "reject", "no-weapon-contact"
            end
            return "micro", "engaging"
        end
        if i.now - (s.lastTargetAt or s.phaseAt) >= Config.ContactGrace then
            Acquire(s, i.now)
            return "acquire", "contact-lost"
        end
        return "hold", "contact-grace"
    end

    if s.phase == "Advance" then
        if not entry and i.enemy > 0 then
            s.unfavourableAt = s.unfavourableAt or i.now
            if hardDanger or i.now - s.unfavourableAt >= 3 then
                return Retreat(s, i, "route-contested")
            end
        else s.unfavourableAt = nil end
        if i.nearTarget and entry then return EnterCombat(s, i) end
        if not i.goalValid then
            Acquire(s, i.now)
            return "acquire", "goal-invalid"
        end
        if i.goalExpired then
            Acquire(s, i.now)
            return "reject", "objective-time-limit"
        end
        -- Admission to the shared path lane is not a path failure. Continue
        -- sensing threats, but never blacklist a goal merely for awaiting a slot.
        if i.pathPending then return "move", "path-budget" end
        if i.goalMoved and i.now>=(s.nextTargetPath or 0) then
            s.nextTargetPath=i.now+8
            return "repath", "target-moved"
        end
        if i.arrived then
            Acquire(s, i.now)
            return "acquire", "objective-reached"
        end
        local stalled = i.now - s.lastProgressAt
        if stalled >= Config.AbandonSeconds then
            Acquire(s, i.now)
            return "reject", "no-progress"
        end
        if stalled >= Config.RepathSeconds and s.repaths < Config.MaximumRepaths
            and i.now >= (s.nextRepath or 0) then
            s.repaths, s.nextRepath = s.repaths + 1, i.now + 10
            return "repath", "no-progress"
        end
        return "move", "advance"
    end
    Acquire(s, i.now)
    return "acquire", "state-recovery"
end
