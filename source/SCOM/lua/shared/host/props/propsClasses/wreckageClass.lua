-- SCOM naval wreck reclaim and lifetime 1.0.0
local HostProp = Import("host/props/propsClasses/propBaseClass.lua").HostProp
local ResourceEntity = Import("host/systems/resourceEntity.lua").ResourceEntity
local PropCommands = Import("common/commands/definitions/props.lua")
local WorkCommands = Import("common/commands/definitions/work.lua")

-- TODO: Can all props be reclaimed? If so then the follow should be on the prop class.
local Reclaimable = Import("host/interfaces/work/tasks/reclaimable.lua").Reclaimable

---@class HostWreckage: HostProp, Reclaimable
---@field isWreckage boolean Marks this prop as a wreckage
---@field unitTpId TemplateId Template ID of the original unit
---@overload fun(id: globalId, template: table): HostWreckage
HostWreckage = Class("Wreckage", HostProp, Reclaimable)

---Initializes a new wreckage class
---@param id globalId Global ID of the wreck
---@param template table Template of the wreck
---@protected
function HostWreckage:__init(id, template)
    HostProp.__init(self, id, template)
    Reclaimable.__init(self)

    self.id = id
    self.tp = template
    self.entityType = "prop"
    self.isWreckage = true
    self.unitTpId = self.tp.general.unitTpId

    self.maxHealth = template.general.maxHealth or 100
    self.health = self.maxHealth

    self.resourceEntities = {}

    -- create resource entity for harvesting
    local armyId
    for id in pairs(Armies) do
        if not armyId or id < armyId then
            armyId = id
        end
    end

    self.resourceEntities["harvest"] = ResourceEntity(
        armyId,
        self.id,
        "harvest",
        nil,
        nil,
        true
    )
    self.resourceEntities["harvest"]:SetCost(self.tp.economy.harvest)
    self.resourceEntities["harvest"]:SetBuildTime(self.tp.economy.harvestTime)

    -- Experimental wrecks remain until reclaimed or destroyed; tech level alone
    -- does not identify experimentals (some ordinary units also use TECH4).
    if (Tags.EXPERIMENTAL and Tags.EXPERIMENTAL[self.unitTpId])
        or (Tags.SCFA_EXPERIMENTAL and Tags.SCFA_EXPERIMENTAL[self.unitTpId]) then
        return
    end

    -- auto-delete ordinary wrecks after timeout
    self:NewThread(function(self)
        -- Creation returns before the crash owner can mark the naval wreck.
        WaitTicks(1)
        local naval = self.scoNavalSinking == true
        local elapsed = Constants.TickTimeStep
        -- Keep the original expiry as a fallback if terrain queries never recover.
        while self.scoNavalSinking or (self.scoWaterWreckSettling and elapsed < 180) do
            WaitTicks(1)
            elapsed = elapsed + Constants.TickTimeStep
        end
        local settledInWater = naval or (self.scoWaterWreckEnteredWater and not self.scoWaterWreckSettling)
        WaitSeconds(settledInWater and 180 or math.max(0, 180 - elapsed))
        self:Delete()
    end)
end

---@protected Even called when this wreckage is destroyed.
function HostWreckage:OnDestroy()
    if self:IsReclaimProcessEnabled() then
        self:EndReclaimProcess()
    end
    self.resourceEntities.harvest:SetEnabled(false)
end

---------- Reclaim Process -------------=

---@protected Checked each tick to decide if the process has completed.
---@return boolean isComplete `true` if the process is complete.
function HostWreckage:IsReclaimProcessComplete()
    return self.reclaimProgress >= self.tp.economy.harvestTime
end

---@protected Main loop body of the Reclaim process thread.
function HostWreckage:ReclaimProcessThread()

    while self:CanContinueReclaimProcess() do

        -- compute effective aggregated reclaim power for this simulation tick
        local aggregatedReclaimPowerPerTick = math.abs(self.resourceEntities.harvest.buildPower)
        if aggregatedReclaimPowerPerTick > 0 then
            -- integrate reclaim progress
            self.reclaimProgress = self.reclaimProgress + aggregatedReclaimPowerPerTick
            -- synchronize progress state with clients      
            PropCommands.SetReclaimProgress.Send(self.id, self.reclaimProgress)

            -- compute income distribution per tick
            local income = {}
            for resourceName, refundTotal in pairs(self.tp.economy.harvest or {}) do
                income[resourceName] = (refundTotal / self.tp.economy.harvestTime) * aggregatedReclaimPowerPerTick * Constants.TickRate
            end

            self.harvestIncomeEntity:SetResources(income, nil)


            -- finalize reclaim when required reclaim work is reached
            if self:IsReclaimProcessComplete() then
                -- Completed.
                self:EndReclaimProcess()
                return
            end
        end

        WaitTicks(1)
    end

    -- Canceled.
    self:EndReclaimProcess()
end

---------- Reclaim Process Callbacks -------------
-- Extension hooks for mods/subclasses. Empty by default.

---@protected Called after the Reclaim process thread has been spawned.
function HostWreckage:OnReclaimProcessStarted()
    
    -- acquire army id of the first active reclaimer
    local army = self.reclaimers[1].army

    -- create income entity for tracking refund flow
    self.harvestIncomeEntity = ResourceEntity(
        army.id,
        self.id,
        "harvest",
        nil,
        nil,
        true
    )
end

---@protected Called after the Reclaim process thread has been killed and cleanup has run.
---@param reclaimers HostUnit[] All reclaimers for this process.
function HostWreckage:OnReclaimProcessEnded(reclaimers)
    
    self.harvestIncomeEntity:SetEnabled(false)
    self.harvestIncomeEntity = nil

    if self:IsReclaimProcessComplete() then
        WorkCommands.OnUnitReclaimed.Send(self.id)
        self:Delete()
    end
end

function HostWreckage:CanStartReclaimProcess()
    return not self.scoNavalSinking and Reclaimable.CanStartReclaimProcess(self)
end

function HostWreckage:CanContinueReclaimProcess()
    return not self.scoNavalSinking and Reclaimable.CanContinueReclaimProcess(self)
end
