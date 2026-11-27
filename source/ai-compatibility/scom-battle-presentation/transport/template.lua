function Prepare(tp)
    local cargo = tp.additions and tp.additions.scoCargo
    if cargo and cargo.portable then
        local exists = false
        for _, tag in ipairs(tp.tags) do if tag == 'TRANSPORTABLE' then exists = true end end
        if not exists then tp.tags[#tp.tags+1] = 'TRANSPORTABLE' end
    end
    if tp.general.orders and tp.general.orders.Transport and not (cargo and cargo.airStorage) then
        assert(cargo and #cargo.slots > 0, 'SCOM transport has no source attachment slots')
        tp.scomNativeTransport = true
        tp.transport = {
            attachRadius = 0.6, dropDelay = 0.1, liftRotationSpeed = 180, liftSpeed = 4,
            loadAltitude = 3, loadAltitudeChangeRate = 4, loadRange = 3,
            stayInLowAltitudeRange = 24, unloadRange = 2,
        }
        tp.general.orders.Transport, tp.general.orders.Unload = nil, true
        local counts, slots = {}, {}
        for _, slot in ipairs(cargo.slots) do
            local tech = slot.cargoClass
            if tech >= 1 and tech <= 3 then
                counts[tech] = (counts[tech] or 0)+1
                slots[#slots+1] = {
                    name = 'M1_T'..tech..'_AttachPoint'..counts[tech],
                    bone = slot.bone, occupies = slot.occupies,
                }
            end
        end
        tp.scomNativeTransportSlots = slots
        local exists = false
        for _, tag in ipairs(tp.tags) do if tag == 'TRANSPORT' then exists = true end end
        if not exists then tp.tags[#tp.tags+1] = 'TRANSPORT' end
    end
    if tp.general.tpId == 'ucl4004' then
        for _, weapon in ipairs(tp.weapons) do
            if weapon.scoTractor then
                weapon.layerTargetLimits = {'Land','WaterSurface','Water','Seabed','Air','LandedAir'}
                weapon.scoAboveWaterTargetsOnly = false
                weapon.targetWaterLimits = nil
            end
        end
    end
end

return {Prepare = Prepare}
