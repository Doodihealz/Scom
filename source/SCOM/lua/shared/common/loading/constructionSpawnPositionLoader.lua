
---Finds the first skeleton bone whose name contains the given substring.
---@return string|nil boneName Name of first skeleton bone containing the substring, or nil if none.
local function FindFirstBoneContaining(skeletonBones, substring)
    for _, bone in ipairs(skeletonBones) do
        if string.find(bone.boneName, substring, 1, true) then
            return bone.boneName
        end
    end
    return nil
end

---Finds the bone on a constructor's skeleton that units being constructed should spawn on.
---@param tp table Unit template (must have tp.construction).
---@param skeletonBones table[] Bones from Engine.GetSkeletonBones().
function GetConstructorSpawnBones(tp, skeletonBones)
    -- Supreme Commander Overhaul FA Air Factories 1.0.0
    -- An imported factory can name its exact FA build attachment. Validate it
    -- instead of replacing it with a faction substring heuristic.
    local explicitBoneName = tp.construction and tp.construction.platformBoneName
    if explicitBoneName then
        for _, bone in ipairs(skeletonBones) do
            if bone.boneName == explicitBoneName then
                return
            end
        end
        error("Explicit factory platform bone is absent: " .. explicitBoneName)
    end

    local prefix = tp.general.tpId:sub(1, 3)

    if prefix == "ues" then
        -- EDA spawn point is the bone with the highest "PlatformT<n>" number.
        local highestValue = 0
        for _, bone in ipairs(skeletonBones) do
            local _, matchEnd = string.find(bone.boneName, "PlatformT", 1, true)
            if matchEnd then
                local tNumber = tonumber(bone.boneName:sub(matchEnd + 1, matchEnd + 1))
                if tNumber and tNumber > highestValue then
                    highestValue = tNumber
                    tp.construction.platformBoneName = bone.boneName
                end
            end
        end
    elseif prefix == "ugs" then
        -- Guard spawn points can be include "Body_Platforms" or "Platform_Stand" in their name.
        tp.construction.platformBoneName = FindFirstBoneContaining(skeletonBones, "Body_Platforms") or FindFirstBoneContaining(skeletonBones, "Platform_Stand")
    elseif prefix == "ucs" then
        -- Chosen spawn points include "Spawner" in their name.
        tp.construction.platformBoneName = FindFirstBoneContaining(skeletonBones, "Spawner")
    end
end

return {
    GetConstructorSpawnBones = GetConstructorSpawnBones
}