    if tp.scomNativeTransportSlots then
        for _, slot in ipairs(tp.scomNativeTransportSlots) do
            assert(entityNameToHierarchyIndex[slot.bone], 'Missing SCOM transport bone '..slot.bone)
            assert(not entityNameToHierarchyIndex[slot.name], 'Duplicate SCOM transport point '..slot.name)
            local entity = EngineClasses.EntityTemplate(slot.name, slot.bone,
                EngineClasses.float3(), 1, EngineClasses.quaternion(), true)
            hierarchyEntities[#hierarchyEntities+1] = entity
            entityNameToHierarchyIndex[slot.name] = #hierarchyEntities
            hierarchyEntities[entityNameToHierarchyIndex[slot.bone]].forceSimulated = true
        end
    end
    for _, weapon in ipairs(tp.weapons or {}) do
        local tractor = weapon.scoTractor
        if tractor then
            local index = assert(entityNameToHierarchyIndex[tractor.captureBone], 'Missing SCOM tractor capture bone '..tractor.captureBone)
            hierarchyEntities[index].forceSimulated = true
        end
    end
