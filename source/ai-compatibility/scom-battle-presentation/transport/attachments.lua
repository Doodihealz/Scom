-- Source slot footprints preserve the port's mixed-size capacity on native transport machinery.
local NativeBuild, NativeReserve = BuildAttachPoints, Reserve
function BuildAttachPoints(unit)
    local groups = NativeBuild(unit)
    local slots = unit.tp.scomNativeTransportSlots
    if not slots then return groups end
    local byName = {}
    for _, slot in ipairs(slots) do byName[slot.name] = slot end
    for _, group in ipairs(groups) do
        for _, point in ipairs(group) do
            local slot = assert(byName[point.boneName], 'Unexpected SCOM transport attachment '..point.boneName)
            point.scomOccupies = slot.occupies
        end
    end
    return groups
end
local function Overlap(a, b)
    for _, token in ipairs(a) do
        for _, other in ipairs(b) do if token == other then return true end end
    end
    return false
end
function Reserve(groups, tech, unit)
    if not groups[1] or not groups[1][1] or type(groups[1][1].scomOccupies) ~= 'table' then
        return NativeReserve(groups, tech, unit)
    end
    for _, group in ipairs(groups) do
        for _, point in ipairs(group) do
            if point.tech == tech then
                if type(point.scomOccupies) ~= 'table' then return NativeReserve(groups, tech, unit) end
                local free = true
                for _, otherGroup in ipairs(groups) do
                    for _, other in ipairs(otherGroup) do
                        if other.unit then
                            if type(other.scomOccupies) ~= 'table' then return NativeReserve(groups, tech, unit) end
                            if Overlap(point.scomOccupies, other.scomOccupies) then free = false end
                        end
                    end
                end
                if free then point.unit = unit; return point end
            end
        end
    end
end
