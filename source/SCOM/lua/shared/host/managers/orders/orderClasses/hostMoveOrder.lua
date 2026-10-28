local HostBaseOrder = Import("host/managers/orders/orderClasses/hostBaseOrder.lua").HostBaseOrder
local OrderTasks = Import("common/commonOrders.lua").OrderTasks
local MapUtils = Import("common/mapUtils.lua")
local FormationUtils = Import("common/formationUtils.lua")

---@class HostMoveOrder: HostBaseOrder
---@field range number
---@field parkingSpots table<number, float2>
---@field parkingSpacing integer
---@field alignDirection float2? Direction to face on arrival, or nil to not align
HostMoveOrder = Class("HostMoveOrder", HostBaseOrder)

function HostMoveOrder:__init(orderId, position, payload)
    HostBaseOrder.__init(self, orderId, OrderTasks.MOVE, position)
    self.range = 0.3
    self.parkingSpots = {}
    self.parkingSpacing = 0.5
    self.issuedBrake = {}
    self.alignDirection = payload and payload.alignDirection and EngineClasses.float2(payload.alignDirection.x, payload.alignDirection.y) or nil
end

function HostMoveOrder:ValidateOrder()
    if self.positionFloat3 and self.positionFloat3.x and self.positionFloat3.z then
        return MapUtils.IsPositionOnMap(self.positionFloat3)        
    end

    return false
end

function HostMoveOrder:ValidateUnitAssignment(unit)
    if not HostBaseOrder:ValidateUnitAssignment(unit) then return false end

    return unit:MoveIntoRangeBehaviorIsValidFor(self.positionFloat2, self.range)
end

function HostMoveOrder:OnQueuedUnitsAssigned()
    local unitsArray = self.queuedUnitsArray or {}
    self.parkingSpots = FormationUtils.CreateSquareSpiralFormationParkingSpots(unitsArray, self.positionFloat2, self.parkingSpacing)
end

function HostMoveOrder:UnitStart(unit)
    -- # start unit movement
    local spot = FormationUtils.GetFormationParkingSpot(self.parkingSpots, unit.id.index) or self.positionFloat2
    local brakeOnApproach = #unit.orders.queuedOrders == 0
    self.issuedBrake[unit.id.index] = brakeOnApproach
    unit:MoveIntoRangeBehaviorStart(spot, self.range, self.alignDirection, brakeOnApproach)
end

function HostMoveOrder:OnUnitQueueChanged(unit)
    if not unit.moveIntoRangeBehaviorIsActive then return end

    local brakeOnApproach = #unit.orders.queuedOrders == 0
    if self.issuedBrake[unit.id.index] ~= brakeOnApproach then
        self.issuedBrake[unit.id.index] = brakeOnApproach
        unit:SetMoveIntoRangeBrakeOnApproach(brakeOnApproach)
    end
end

function HostMoveOrder:UnitUpdate(unit)
    -- # order stays until we finished moving
    return not unit.moveIntoRangeBehaviorIsActive
end

function HostMoveOrder:UnitStop(unit)
    -- # stop unit movement
    -- todo: hmm, this happenings whenever a unit is unassigned from the order
    -- todo: which happens when you issue a new move order, and when unit dies
    -- todo: when the previous move order was complete
    -- todo: so it might be doing some strange stuff
    unit:MoveIntoRangeBehaviorStop()
end
-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0
-- Clear the artillery deploy lock before native MOVE starts its path.
local SCO_EggStockMoveUnitStart = HostMoveOrder.UnitStart
function HostMoveOrder:UnitStart(unit)
    if unit.tpId == "ugl3101" and unit.weapons then
        for _, weapon in ipairs(unit.weapons) do
            if weapon.tp and weapon.tp.scoFaEggTrebuchet == true then
                weapon:SCO_ReleaseEggTrebuchetForMove()
            end
        end
    end
    return SCO_EggStockMoveUnitStart(self, unit)
end
