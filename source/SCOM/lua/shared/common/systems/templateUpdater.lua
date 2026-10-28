---@alias TemplateType
---| "projectile"
---| "prop"
---| "unit"

local tpType = {
    unit = {
        pathString = "units",
        tpTableString = "UnitTemplate",
        cleanUpFn = function(tp)
            -- Delete stuff that got added when importing the templates the first time
            tp.id = nil
            tp.ranges = nil
            tp.general.engineId = nil
            tp.general.prefabID = nil
            tp.general.placementGhostPrefabID = nil
            if tp.movement then
                tp.movement.patternIDs = nil
            end
        end,
    },
    projectile = {
        pathString = "projectiles",
        tpTableString = "ProjectileTemplate",
        cleanUpFn = function(tp)
            tp.general.engineId = nil
            tp.general.prefabID = nil
        end,
    },
    prop = {
        pathString = "props",
        tpTableString = "PropsTemplate",
        cleanUpFn = function(tp)
            tp.general.engineId = nil
            tp.general.prefabID = nil
        end,
    },
}

---Updates templates of given `templateType` using `updateFn`.
---@param updateFn function Function that manipulates the templates, it's given two args `tp` and  `tpId`.<br>
---If the tp got updated, it needs to return `true`.
---@param templateType TemplateType Type of the template to udpate.
function UpdateTemplates(updateFn, templateType)
    Log("Updating " .. templateType .. " templates...")
    local typeData = tpType[templateType]
    if not typeData then
        Warn("UpdateTemplates: Invalid template type: " .. tostring(templateType))
        return
    end

    local t = ScanDir(string.format("common/%s/%sTemplates/", typeData.pathString, typeData.pathString))
    local result = {
        Updated = {},
        NotUpdated = {},
    }
    for _, fileLocation in pairs(t) do
        
        -- Take the name of the template folder found removing the trailing forward slashes
        local tpId = string.match(fileLocation, '[^/]+$')

        -- load the template and get the table it contains with the given name depending on the type of template (first line on the template)
        local tp = Import(fileLocation .. "/" .. tpId .. ".santp")[typeData.tpTableString]
        
        -- Delete some fields that appear after import (find out why they show up even though they are not in the template file originally)
        typeData.cleanUpFn(tp)

        if updateFn(tp, tpId) then

            Log("UpdateTemplates: Template data updated successfully. " .. tpId .. " Writing to file...")

            -- save the template
            local tpTableString = typeData.tpTableString
            local saveResult = table.save(tp, libPath ..fileLocation.."/"..tpId..".santp", tpTableString .. " = ", "---@type " .. tpTableString)
            if (saveResult ~= nil) then
                Error("UpdateTemplates: Could not save the new template file correctly!. Result: " .. saveResult)
            else
                Log("UpdateTemplates: Updated template file " .. tpId)
            end

            table.insert(result.Updated, tpId)
        else
            table.insert(result.NotUpdated, tpId)
        end
    end
    Log("UpdateTemplates done:\n"..repr(result))
end

---Updates the template audio table, adding new events, updating values and removing deleted ones.
---@param tp UnitTemplate|ProjectileTemplate|WeaponTemplate
---@param newData AudioData
---@return boolean
local function updateAudioTable(tp, newData)
    if not tp.audio then
        tp.audio = newData
        return true
    end

    local updated = false
    -- Save all event names for later deleting check
    local newEventNames = {}
    for eventName, audioData in pairs(newData) do
        newEventNames[eventName] = true

        tp.audio[eventName] = audioData
        updated = true
    end

    -- Delete old events that are not in the new data.
    for eventName, _ in pairs(tp.audio) do
        if not newEventNames[eventName] then
            tp.audio[eventName] = nil
            updated = true
        end
    end

    -- If all audio events got deleted, remove the whole audio table.
    if not next(tp.audio) then
        tp.audio = nil
        updated = true
    end

    return updated
end

local projectileAudioData = nil
local function updateProjectileAudio(tp, tpId)
    if not (projectileAudioData and projectileAudioData[tpId]) then
        return false
    end

    return updateAudioTable(tp, projectileAudioData[tpId])
end

local audioData = nil
---Template update function that sets a new audio table for the unit and first weapon.<br>
---Sets data for updating projectiles if needed.
---@param tp UnitTemplate
---@param tpId TemplateId
---@return boolean
local function updateUnitAudio(tp, tpId)
    if not (audioData and audioData[tpId]) then
        return false
    end
    local updated = false
    local data = audioData[tpId]

    if data.unit then
        updated = updateAudioTable(tp, data.unit)
    end

    if data.weapon then
        local wep = tp.weapons and tp.weapons[1]
        if wep then
            updated = updateAudioTable(wep, data.weapon)

            if data.projectile then
                if wep.projectileTemplate then
                    projectileAudioData[wep.projectileTemplate] = data.projectile
                end
            end
        end
    end

    return updated
end

local LODs = {
    -- structures
    ["2x2"] = {lod0distance = 60},
    ["4x4"] = {lod0distance = 100},
    ["6x6"] = {lod0distance = 140},
    ["8x8"] = {lod0distance = 180},
    ["8x12"] = {lod0distance = 200},
    -- mobile units
    ["TECH1"] = {lod0distance = 60},
    ["TECH2"] = {lod0distance = 80},
    ["TECH3"] = {lod0distance = 100},
}

function UpdateFootprints(tp, tpId)
    local tpData = GetTpDataFromTpId(tpId)
    if tpData.unitType ~= "Structure" then
        local hitbox = tp.collisionInfo and tp.collisionInfo.collisionSize
        local updated = false

        local newX = hitbox.x + 0.4
        local newY = hitbox.z + 0.4

        if tp.footprint.x ~= newX then
            tp.footprint.x = newX
            updated = true
        end

        if tp.footprint.y ~= newY then
            tp.footprint.y = newY
            updated = true
        end

        return updated
    end
end

---Updates the LOD (Level of Detail) cutoff distances for a unit based on its blueprint data and tags.
---The function calculates and updates the distances at which the detailed and simplified models are shown or hidden.
---@param tp table The blueprint data for the unit or building, containing fields such as `visuals.selection.size` and `visuals.mesh`.
---@param tpId string The identifier for the unit's type, used to apply specific LOD adjustments.
---@return boolean updated Returns true if the LOD distances were modified, false otherwise.
function UpdateLOD(tp, tpId)
    local updated = false
    -- Minimum zoom level where strategic icons are displayed
    local strategicIconFadeInZoom = 160
    -- Maximum zoom level where units should be hidden
    local maxUnitlod1Cutoff = 900
    -- Get the unit's area size
    local unitSizeArea = tp.visuals.selection.size.x * tp.visuals.selection.size.y
    -- Get the maximum unit LOD size in the game
    local maxUnitSizeArea = 121 -- (ucl4004 - ChosenT4BotBig has visuals.selection.size x = 11, y = 11 -> 121)
    -- Calculate the size ratio of the unit compared to the largest unit
    local sizeRatio = unitSizeArea / maxUnitSizeArea
    -- Calculate the maximum additional distance beyond the strategic icon fade-in zoom
    local maxAdditionalDistance = maxUnitlod1Cutoff - strategicIconFadeInZoom  -- 900 - 160 = 740
    -- Calculate the LOD cutoff distance
    local lod1Cutoff = strategicIconFadeInZoom + (sizeRatio * maxAdditionalDistance)
    -- Adjustments for air units and experimentals
    if Tags["EXPERIMENTAL"][tpId] then
        -- Experimentals stay visible longer
        lod1Cutoff = lod1Cutoff + 150
    elseif Tags["AIR"][tpId] then
        -- Air units stay visible a bit longer
        lod1Cutoff = lod1Cutoff + 100
    end
    -- Calculate lod0Cutoff as approximately 38% of lod1Cutoff
    local lod0Cutoff = lod1Cutoff / 2.6
    -- Ensure that the LOD cutoff does not exceed the maximum allowed after adjustments
    lod0Cutoff = math.floor(math.min(lod0Cutoff, maxUnitlod1Cutoff))
    lod1Cutoff = math.min(lod1Cutoff, maxUnitlod1Cutoff)
    -- Ensure that the LOD cutoff is not less than the strategic icon fade-in zoom
    lod1Cutoff = math.floor(math.max(lod1Cutoff, strategicIconFadeInZoom))
    -- Ensure that the LOD distances are applied to the mesh data if available
    if tp.visuals and tp.visuals.mesh then
        -- Check if lod0distance needs updating
        if tp.visuals.mesh.lod0distance ~= lod0Cutoff then
            tp.visuals.mesh.lod0distance = lod0Cutoff  -- Set lod0 cutoff distance
            updated = true  -- Mark as updated
        end
        -- Check if lod1distance needs updating
        if tp.visuals.mesh.lod1distance ~= lod1Cutoff then
            tp.visuals.mesh.lod1distance = lod1Cutoff  -- Set lod1 cutoff distance
            updated = true  -- Mark as updated
        end
    -- If mesh data is missing, initialize with calculated LOD values
    elseif tp.visuals then
        tp.visuals.mesh = {lod0distance = lod0Cutoff, lod1distance = lod1Cutoff}  -- Create mesh data with LOD distances
        updated = true  -- Mark as updated
    end
    return updated
end

function UpdateMuzzleSpeed(tp, tpId)
    local updated = false
    if tp and tp.weapons then
        for _, weapon in pairs(tp.weapons) do
            if weapon.aimControllers then
                for _, aimController in pairs(weapon.aimControllers) do
                    if aimController.ballisticArc and aimController.ballisticArc == "highArc" then
                        local range = weapon.rangeMax
                        aimController.projectileSpeed = math.floor((1.6 * range) ^ 0.5)
                        updated = true
                    end
                end
            end
        end
    end
    
    return updated
end

function UpdateFiringTolerance(tp, tpId)
    local updated = false
    if tp and tp.weapons then
        for _, weapon in pairs(tp.weapons) do
            if weapon.aimControllers then
                for _, aimController in pairs(weapon.aimControllers) do
                
                    if aimController.aimTolerance then
                        aimController.aimTolerance = 2
                        updated = true
                    end
                end
            end
        end
    end
    
    return updated
end

local skirtSizeToFootprint = {
    [2] = 1,
    [4] = 2,
    [6] = 4,
    [8] = 5,
    [12] = 9,
}

function GenerateSkirtSize(tp, tpId)
    if string.sub(tpId, 3, 3) ~= "s" then
        return
    end

    if not table.find(tp.tags, "STRUCTURE") then
        Warn("tp: " .. tpId .. " is missing STRUCTURE tag.")
    end

    if not tp.footprint then
        Warn("tp: " .. tpId .. " doesnt have footprint set!")
        return
    end

    local oldFootprint = table.shallowCopy(tp.footprint)

    for side, value in pairs(tp.footprint) do
        if skirtSizeToFootprint[value] then
            tp.footprint[side] = skirtSizeToFootprint[value]
        else
            Warn("GenerateSkirtSize: tp: " .. tpId .. " is missing value for conversion: " .. value)
            return false
        end
    end

    tp.skirtSize = oldFootprint

    return true
end

local explosions = {
    s1601 = {2, 400}, -- T1 pgen
    s2601 = {3, 800}, -- T2 pgen
    s3601 = {4, 1600}, -- T3 pgen

    s1612 = {2, 1000}, -- T1 E storage
    s1611 = {2, 500}, -- T1 pgen
    s2611 = {5, 1000}, -- T2 pgen
    s3611 = {10, 5000}, -- T3 pgen
    s3603 = {10, 5000}, -- T3 alloy furnace

    l0000 = {15, 5000}, -- commander
}

function UpdateDeathExplosions(tp, tpId)
    local explosionData = nil

    for partialId, data in pairs(explosions) do
        if string.find(tpId, partialId) then
            explosionData = data
            break
        end
    end

    if not explosionData then
        return false
    end

    local deathWep = {
        damage = explosionData[2],
        damageRadius = explosionData[1],
        damageFriendly = true,
        damageType = "Normal",
        category = "DeathExplosion",
    }


    if not tp.weapons then
        tp.weapons = {}
    end

    local wepId = nil
    for i, wep in ipairs(tp.weapons) do
        if wep.category == "DeathExplosion" then
            wepId = i
            break
        end
    end

    if wepId then
        tp.weapons[wepId] = deathWep
    else
        table.insert(tp.weapons, deathWep)
    end

    return true
end

local holes = {
	ugs1001 = { --ugs1001 - GUARD Structure T1 Anti Land Defence
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 0.92, y = 0.92, }, },
	}, 

	ugs1201 = { --ugs1201 - GUARD Structure T1 Anti Air Defence
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 0.92, y = 0.92, }, },
	}, 

	ugs1501 = { --ugs1501 - GUARD Structure T1 Engineering Station
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 2.13, y = 2.13, }, },
	}, 

	ugs1511 = { --ugs1511 - GUARD Structure T1 Land Factory
		{holeOffset = {x = 0, y = 0, }, holeSize = {x = 4.3, y = 4.3, }, },
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 6, y = 6, }, },
	}, 

	ugs1512 = { --ugs1512 - GUARD Structure T1 Air Factory
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 5.8, y = 5.8, }, },
	}, 

	ugs1601 = { --ugs1601 - GUARD Structure T1 Alloy Generator
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.18, y = 1.18, }, },
	}, 

	ugs1611 = { --ugs1611 - GUARD Structure T1 Power Generator
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.38, y = 1.38, }, },
	}, 

	ugs1612 = { --ugs1612 - GUARD Structure T1 Energy Storage
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.38, y = 1.38, }, },
	}, 

	ugs1701 = { --ugs1701 - GUARD Structure T1 Radar
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.72, y = 1.72, }, },
	}, 

	ugs1801 = { --ugs1801 - GUARD Structure T1 Land Tech Centre
		{holeOffset = {x = 1, y = 0, }, holeSize = {x = 3, y = 2.4, }, },
	}, 

	ugs1802 = { --ugs1802 - GUARD Structure T1 Air Tech Centre
		{holeOffset = {x = 1, y = 0, }, holeSize = {x = 3, y = 2.4, }, },
	}, 

	ugs1806 = { --ugs1806 - GUARD Structure T1 Transmitter Tower
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.16, y = 1.16, }, },
	}, 

	ugs2001 = { --ugs2001 - GUARD Structure T2 Anti Land Defence
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.44, y = 1.44, }, },
	}, 

	ugs2201 = { --ugs2201 - GUARD Structure T2 Anti Air Defence
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.44, y = 1.44, }, },
	}, 

	ugs2101 = { --ugs2101 - GUARD Structure T2 Artillery
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.44, y = 1.44, }, },
	}, 

	ugs2401 = { --ugs2401 - GUARD Structure T2 Shield
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 2.05, y = 2.05, }, },
	}, 

	ugs2501 = { --ugs2501 - GUARD Structure T2 Engineering Station
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 2.13, y = 2.13, }, },
	}, 

	ugs2511 = { --ugs2511 - GUARD Structure T2 Land Factory
		{holeOffset = {x = 0, y = 0, }, holeSize = {x = 4.3, y = 5.8, }, },
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 6, y = 6, }, },
	}, 

	ugs2512 = { --ugs2512 - GUARD Structure T2 Air Factory
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 5.8, y = 5.8, }, },
	}, 

	ugs2601 = { --ugs2601 - GUARD Structure T2 Alloy Generator
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.18, y = 1.18, }, },
	}, 

	ugs2611 = { --ugs2611 - GUARD Structure T2 Power Generator
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 3.36, y = 3.36, }, },
	}, 

	ugs2701 = { --ugs2701 - GUARD Structure T2 Radar
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.72, y = 1.72, }, },
	}, 

	ugs2801 = { --ugs2801 - GUARD Structure T2 Land Tech Centre
		{holeOffset = {x = 1, y = 0, }, holeSize = {x = 3, y = 2.4, }, },
	}, 

	ugs2802 = { --ugs2802 - GUARD Structure T2 Air Tech Centre
		{holeOffset = {x = 1, y = 0, }, holeSize = {x = 3, y = 2.4, }, },
	}, 

	ugs2806 = { --ugs2806 - GUARD Structure T2 Transmitter Tower
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.16, y = 1.16, }, },
	}, 

	ugs3401 = { --ugs3401 - GUARD Structure T3 Shield
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 2.05, y = 2.05, }, },
	}, 

	ugs3501 = { --ugs3501 - GUARD Structure T3 Engineering Station
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 2.13, y = 2.13, }, },
	}, 

	ugs3511 = { --ugs3511 - GUARD Structure T3 Land Factory
		{holeOffset = {x = 0, y = 0, }, holeSize = {x = 4.3, y = 6.5, }, },
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 6, y = 6, }, },
	}, 

	ugs3512 = { --ugs3512 - GUARD Structure T3 Air Factory
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 5.8, y = 5.8, }, },
	}, 

	ugs3601 = { --ugs3601 - GUARD Structure T3 Alloy Generator
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.18, y = 1.18, }, },
	}, 

	ugs3611 = { --ugs3611 - GUARD Structure T3 Power Generator
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 5.65, y = 5.65, }, },
	}, 

	ugs3701 = { --ugs3701 - GUARD Structure T3 Radar
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 1.72, y = 1.72, }, },
	}, 

	ugs4012 = { --ugs4012 - GUARD Structure T4 Laser
		{holeOffset = {x = 0, y = 0, }, holeRadius = {x = 2.4, y = 2.4, }, },
	}, 
}

function UpdateTemplatesHoles(tp, tpId)
    if not holes[tpId] then
        return false
    end

    if not tp.visuals then
        tp.visuals = {}
    end

    local data = holes[tpId]
    tp.visuals.holes = {}

    for i, holeData in ipairs(data) do
        local new = {}
        if holeData.holeRadius then
            new.holeSize = holeData.holeRadius
            new.circle = true
        elseif holeData.holeSize then
            new.holeSize = holeData.holeSize
        else
            Warn("Failed to update hole for: " .. tpId)
        end
        if holeData.holeOffset.y ~= 0 or holeData.holeOffset.x ~= 0 then
            new.holeOffset = holeData.holeOffset
        end

        table.insert(tp.visuals.holes, new)
    end

    return true
end

function UpdateRollOffPoints(tp, tpId)
    if tp.construction and tp.construction.rollOffPoints then
        for _, v in ipairs(tp.construction.rollOffPoints) do
            v.offset = {x = v.x, y = v.y, z = v.z}
            v.x = nil
            v.y = nil
            v.z = nil
        end

        return true
    end

    return false
end

function UpdateIconType(tp, tpId)
    local icon
    local tpData = GetTpDataFromTpId(tpId)

    if tpData.unitType == "Air" then
        icon = "air"
    elseif tpData.unitType == "Land" then
        if tp.movement.type == "LegsLand" or tp.movement.type == "TracksLand" then
            icon = "land"
        else
            icon = "amphibious"
        end
    elseif tpData.unitType == "Naval" then
        icon = "water"
    elseif tpData.unitType == "Structure" then
        local tpEnd = string.sub(tpId, 5, 7)
        -- factories and tech centres
        if tpEnd == "511" or tpEnd == "801" then
            icon = "land"
        elseif tpEnd == "512" or tpEnd == "802" then
            icon = "air"
        elseif tpEnd == "513" or tpEnd == "803" then
            icon = "water"
        -- eco structures
        elseif tpEnd == "601" or tpEnd == "602" or tpEnd == "611" or tpEnd == "612" then
            icon = "amphibious"
        -- aa def
        elseif tpEnd == "201" then
            icon = "amphibious"
        -- torp def
        elseif tpEnd == "301" then
            icon = "water"
        else
            icon = "land"
        end
    end

    tp.general.iconUIType = icon

    return true
end

--local VFXData = Import("common/effects/effectsData.lua").VFXData

function UpdateTemplatesVFX(tp, tpId)
    local basicData = GetTpDataFromTpId(tpId)

    if not (basicData.unitType == "Structure" or string.find(tpId, "l0000")) then
        return false
    end

    local size = tp.skirtSize or tp.footprint
    local max = math.max(size.x, size.y)

    if max <= 2 then
        basicData.techNum = 1
        basicData.size = "small"
    elseif max <= 6 then
        basicData.techNum = 2
        basicData.size = "medium"
    else
        basicData.techNum = 3
        basicData.size = "large"
    end

    local newName = string.format("VFX/Death/v%sd2%d01_death_building_%s.sanvfx", basicData.factionLetter, basicData.techNum, basicData.size)
    if string.find(tpId, "l0000") then
        newName = string.format("VFX/Death/v%sd0301_death_rdu.sanvfx", basicData.factionLetter)
    end


    local updated = false

    if tp.visuals and tp.visuals.onExplosionEffects then
        for _, vfx in pairs(tp.visuals.onExplosionEffects) do
            if vfx.effects then
                for _, effect in pairs(vfx.effects) do
                    if effect.particleName and effect.particleName ~= newName then
                        effect.particleName = newName
                        return true
                    end
                end
            end
        end
    end

    return updated
end

-- Learn to read with speed! Secret code explained right here:
-- (numbered keys are saved as strings here, since tpId is also a treated as a string)
local tpIdData = {
    {
        e = "PropTemplate",
        p = "ProjectileTemplate",
        u = "UnitTemplate",
    },
    {
        c = "Chosen",
        e = "EDA",
        g = "Guard",
    },
    {
        a = "Air",
        l = "Land",
        n = "Naval",
        o = "Orbit",
        s = "Structure",
    },
    {
        ["1"] = "Tech1",
        ["2"] = "Tech2",
        ["3"] = "Tech3",
        ["4"] = "Tech4",
        ["5"] = "Tech5",
    },
    {
        ["0"] = "Direct_Fire",
        ["1"] = "Indirect_Fire",
        ["2"] = "Anti_Air",
        ["3"] = "Anti_Naval",
        ["4"] = "Defence",
        ["5"] = "Construction",
        ["6"] = "Economy",
        ["7"] = "Intel",
        ["8"] = "Special",
        ["9"] = "Civilian",
    },
}

function GetTpDataFromTpId(tpId)
    tpId = string.lower(tpId)

    local data = {
        tpType = tpIdData[1][string.sub(tpId, 1, 1)],
        faction = tpIdData[2][string.sub(tpId, 2, 2)],
        factionLetter = string.sub(tpId, 2, 2),
        unitType = tpIdData[3][string.sub(tpId, 3, 3)],
        tech = tpIdData[4][string.sub(tpId, 4, 4)],
        techNum = tonumber(string.sub(tpId, 4, 4)),
        weaponType = tpIdData[5][string.sub(tpId, 5, 6)],
    }

    return data
end

function GenerateBasicTempalte(tpId)
    local tpData = GetTpDataFromTpId(tpId)
end

function SetUpOrdersData(tp)
    if not tp.general.orders then
        tp.general.orders = {}
    end

    if tp.weapons and tp.weapons[1] then
        tp.general.orders.Attack = true
        tp.general.orders.Stop = true
        if tp.movement then
            tp.general.orders.AttackMove = true
        end
    end

    if tp.movement then
        tp.general.orders.Move = true
        tp.general.orders.Stop = true
        tp.general.orders.Assist = true
        tp.general.orders.Patrol = true
    end

    if tp.construction then
        if tp.movement then
            tp.general.orders.AttackMove = true
            tp.general.orders.Capture = true
            tp.general.orders.Harvest = true
            tp.general.orders.Repair = true
        end
        tp.general.orders.Stop = true
        tp.general.orders.Assist = true
        tp.general.orders.Pause = true
    end

    if not next(tp.general.orders) then
        tp.general.orders = nil
        return false
    end
    return true
end

---Sets up unit toggles
---@param tp UnitTemplate
---@param tpId TemplateId
---@return boolean
function SetUpToggles(tp, tpId)
    --[[
        RepeatBuild = true,
        Pause = true,
        Shield = true,
        Production = true,
        Intel = true,
        CounterIntel = true,
    --]]
    if not tp.general.toggles then
        tp.general.toggles = {}
    end
    local toggles = tp.general.toggles

    if tp.construction then
        toggles.Pause = true
    end
    if tp.defence.shields then
        toggles.Shield = true
    end
    if Tags.FACTORY[tpId] then
        toggles.RepeatBuild = true
    end
    local IntelTags = Tags.INTEL * (Tags.RADAR + Tags.SONAR) * Tags.STRUCTURE
    if IntelTags[tpId] then
        toggles.Intel = true
    end

    -- EDA shields
    local EDAShields = Tags.EDA * Tags.SHIELD * Tags.STRUCTURE
    if EDAShields[tpId] then
        toggles.CounterIntel = true
    end

    if not next(tp.general.toggles) then
        tp.general.toggles = nil
        return false
    end
    return true
end

function UpdateSelectionInfo(tp, tpId)
    local updated = false
    local x = math.round((tp.collisionInfo.collisionSize.x * 1.1) + 0.7, 3)
    local y = math.round((tp.collisionInfo.collisionSize.z * 1.1) + 0.7, 3)

    if not tp.visuals.selection then
        tp.visuals.selection = {
            size = {
                x = x,
                y = y,
            },
        }

        updated = true
    else
        local tpSelectionSize = tp.visuals.selection.size
        if tpSelectionSize.x ~= x then
            tpSelectionSize.x = x
            updated = true
        end

        if tpSelectionSize.y ~= y then
            tpSelectionSize.y = y
            updated = true
        end
    end

    return updated
end

function UpdateUnitName(tp, tpId)
    local techToTier = {
        T1 = "Tier 1",
        T2 = "Tier 2",
        T3 = "Tier 3",
        T4 = "Tier 4",
        T5 = "Tier 5",
    }
    local general = tp.general
    if general.name then
        local name = general.name
        local tpData = GetTpDataFromTpId(tpId)
        -- Remove the faction from the start of the name
        local nameWithoutFaction = string.gsub(name, tpData.faction, "")
        
        -- Prepare tier part of the string, "T1" to "Tier 1"
        local tierString = techToTier[string.sub(nameWithoutFaction, 1, 2)]
        -- Get the rest of the name like "Tank", some names mighth be without tech
        local nameWithoutTech = nameWithoutFaction
        if tierString then
            nameWithoutTech = string.sub(nameWithoutFaction, 3, #nameWithoutFaction)
        end
        -- Create the new name "Tier 1: Tank"
        local newName
        if tierString then
            newName = string.format("%s: %s", tierString, nameWithoutTech)
        else
            newName = nameWithoutTech
        end

        local newNameWithSpaces = ""
        local isFirstChar = true
        for char in newName:gmatch(".") do
            if not isFirstChar and char:match("%u") then
                newNameWithSpaces = newNameWithSpaces .. " " .. char
            else
                newNameWithSpaces = newNameWithSpaces .. char
            end
            isFirstChar = false
        end
        newNameWithSpaces = string.gsub(newNameWithSpaces, "M A A", "Mobile Anti-Air")
        newNameWithSpaces = string.gsub(newNameWithSpaces, "A A", "Anti-Air")
        newNameWithSpaces = string.gsub(newNameWithSpaces, "Arty", "Artillery")

        general.displayName = newNameWithSpaces
        return true
    end

    return false
end

---@param tp UnitTemplate
---@param tpId TemplateId
---@return boolean
function UpdateWeaponsFiringRandomness(tp, tpId)
    if not tp.weapons then
        return false
    end

    for i, wep in ipairs(tp.weapons) do
        if wep.aimControllers then
            for _, controller in ipairs(wep.aimControllers) do
                if controller.solverType == "HighArc" then
                    wep.firingRandomness = 5
                    return true
                end
            end
        end
    end

    return false
end

---@param tp UnitTemplate
---@param tpId TemplateId
---@return boolean
function UpdateWeaponsPitch(tp, tpId)
    if not tp.weapons then
        return false
    end

    if table.find(tp.tags, "AIR") then
        return false
    end

    local max = 45
    if table.find(tp.tags, "ANTIAIR") then
        max = 90
    end

    for i, wep in ipairs(tp.weapons) do
        if wep.aimControllers then
            for _, controller in ipairs(wep.aimControllers) do
                if controller.solverType == "HighArc" then
                    controller.pitchMin = -25
                    controller.pitchMax = 80
                elseif controller.solverType == "NoArc" then
                    controller.pitchMin = -25
                    controller.pitchMax = max
                else
                    controller.pitchMin = -25
                    controller.pitchMax = max
                end
            end

            return true
        end
    end

    return false
end

function UpdateEffectsFormat(tp, tpId)
    if not tp.visuals or not tp.visuals.onExplosionEffects then
        return false
    end

    local newEffectsInstant = {}
    newEffectsInstant.onDeath = {}
    newEffectsInstant.onImpact = {}
    local isAirUnit = tp.movement and tp.movement.air

    for i, vfx in ipairs(tp.visuals.onExplosionEffects) do
        if vfx.effects then
            for j, effect in ipairs(vfx.effects) do
                table.insert(newEffectsInstant.onDeath, {
                    particleName = effect.particleName,
                    boneName = effect.boneName,
                })

                if isAirUnit then
                    table.insert(newEffectsInstant.onImpact, {
                        particleName = effect.particleName,
                        boneName = effect.boneName,
                    })
                end
            end

            if not isAirUnit then
                newEffectsInstant.onImpact = nil
            end
        else
            return false
        end
    end

    tp.visuals.onExplosionEffects = nil
    tp.visuals.effectsInstant = newEffectsInstant
    
    return true
end

function UpdatePersistantEffectsFormat(tp, tpId)
    if not tp.visuals or not tp.visuals.persistantEffects then
        return false
    end

    tp.visuals.effectsPersistent = {}
    for i, vfx in ipairs(tp.visuals.persistantEffects) do
        if vfx.effects then
            for j, effect in ipairs(vfx.effects) do
                table.insert(tp.visuals.effectsPersistent, {
                    particleName = effect.particleName,
                    boneName = effect.boneName,
                })
            end
        else
            return false
        end
    end

    return true
end

---Adds `DEMO_UI_ONLY` tag into the template if its not there already
---@param tp UnitTemplate
---@return boolean updated True if the tag was added, false if it was already there
local function addDemoTag(tp)
    for _, tag in pairs(tp.tags) do
        if tag == "DEMO_UI_ONLY" then
            return false
        end
    end

    table.insert(tp.tags, "DEMO_UI_ONLY")
    return true
end

---Adds `DEMO_UI_ONLY` tag to the templates baseed on the conditions in this function
---@param tp UnitTemplate
---@param tpId TemplateId
---@return boolean
function SlingRestrictUnits(tp, tpId)
    if Tags.TECH_CENTRE[tpId] or Tags.TRANSMITTER[tpId] or Tags.STEALTH_FIELD[tpId] or string.sub(tpId, 3, 7) == "s3102" or string.sub(tpId, 3, 7) == "s3402" then
        return addDemoTag(tp)
    end
    return false
end

--------------
-- Projectiles
--------------
local unitToProjectile = {
    -- unitTpId = {projTpId, vfxID, VFX_Name}

    -- EDA
    -- land
    ["uel1001"] = {"ped111", "1101", "Cannon_Small"},
    ["uel1002"] = {"ped131", "1121", "Autocannon_Small"},
    ["uel1101"] = {"pei121", "2141", "Rocket_Artillery_Small"},
    ["uel1201"] = {"pea131", "3121", "Autocannon_AntiAir_Small"},
    ["uel2201"] = {"pea271", "7601", "Railgun_Flak_Medium"},
    ["uel3001"] = {"ped311", "1301", "Cannon_Large"},
    ["uel3002"] = {"ped331", "1321", "Autocannon_Large"},
    ["uel3101"] = {"ped221", "2241", "Rocket_Artillery_Medium"},
    ["uel3801"] = {"ped271", "7201", "Railgun_AntiTank_Medium"},
    ["uel4001"] = {"ped471", "7401", "Railgun_AntiTank_Huge"},
    -- air
    ["uea1201"] = {"pea131", "3121", "Autocannon_AntiAir_Small"},
    ["uea2011"] = {"ped131", "1121", "Autocannon_Small"},
    ["uea3011"] = {"ped271", "7201", "Railgun_AntiTank_Medium"},
    ["uea3201"] = {"pea342", "3301", "Missile_AntiAir_Large_Fighter"},
    --naval
    --["uen3001"] = {"ped311", "1301", "Cannon_Large"},
    -- structure
    ["ues1001"] = {"ped121", "2101", "Rocket_AntiTank_Small"},
    ["ues1201"] = {"pea131", "3121", "Autocannon_AntiAir_Small"},
    ["ues2001"] = {"ped271", "7201", "Railgun_AntiTank_Medium"},
    ["ues2201"] = {"pea271", "7601", "Railgun_Flak_Medium"},
    ["ues3101"] = {"pei321", "2341", "Rocket_Artillery_Large"},
    ["ues3201"] = {"pea341", "3301", "Missile_AntiAir_Large"},

    -- Chosen
    -- land
    ["ucl1001"] = {"pcd111", "1101", "Cannon_Plasma_Small"},
    ["ucl1002"] = {"pcd131", "1121", "Autocannon_Plasma_Small"},
    ["ucl1101"] = {"pci111", "1141", "Cannon_Artillery_Small"},
    ["ucl1201"] = {"pca111", "3121", "Cannon_AntiAir_Small"},
    ["ucl2201"] = {"pci211", "3221", "Cannon_AntiAir_Medium"},
    ["ucl3001"] = {"pcd211", "1201", "Cannon_Plasma_Medium"},
    ["ucl3101"] = {"pci211", "1241", "Cannon_Artillery_Medium"},
    ["ucl3801"] = {"pcd311", "1361", "Cannon_Sniper_Large"},
    -- air
    ["uca1201"] = {"pca111", "4101", "Cannon_Air_Small"},
    ["uca2011"] = {"pcd131", "1121", "Autocannon_Plasma_Small"},
    ["uca3011"] = {"pcd211", "1201", "Cannon_Plasma_Medium"},
    ["uca3201"] = {"pca311", "4301", "Cannon_Air_Large"},
    ["uca4011"] = {"pcd311", "4401", "Cannon_Air_Huge"},
    -- structure
    ["ucs1001"] = {"pcd171", "7101", "Beam_AntiTank_Small"},
    ["ucs1201"] = {"pca111", "3121", "Cannon_AntiAir_Small"},
    ["ucs2001"] = {"pcd211", "1201", "Cannon_Plasma_Medium"},
    ["ucs2101"] = {"pci211", "1241", "Cannon_Artillery_Medium"},
    ["ucs2201"] = {"pca211", "3221", "Cannon_AntiAir_Medium"},
    ["ucs3001"] = {"pcd311", "1301", "Cannon_Plasma_Large"},
    ["ucs3101"] = {"pci311", "1341", "Cannon_Artillery_Large"},
    ["ucs3201"] = {"pca341", "3301", "Missile_AntiAir_Large"},

    -- Guard
    -- land
    ["ugl1001"] = {"pgd111", "1101", "Cannon_Small"},
    ["ugl1002"] = {"pgd131", "1121", "Autocannon_Plasma_Small"},
    ["ugl1101"] = {"pgi111", "1141", "Cannon_Artillery_Small"},
    ["ugl1201"] = {"pga171", "7121", "Beam_AntiAir_Small"},
    ["ugl2201"] = {"pga211", "3221", "Cannon_AntiAir_Medium"},
    ["ugl3001"] = {"pgd371", "7301", "Beam_Plasma_Large"},
    ["ugl3002"] = {"pgd311", "1301", "Cannon_Large"},
    -- structure
    ["ugs1001"] = {"pgd311", "1301", "Cannon_Large"},
    ["ugs1201"] = {"pga171", "7121", "Beam_AntiAir_Small"},
    ["ugs2001"] = {"pgd211", "1281", "Cannon_Plasma_Medium"},
    ["ugs2101"] = {"pgi211", "1241", "Cannon_Artillery_Medium"},
    ["ugs2201"] = {"pga211", "3221", "Cannon_AntiAir_Medium"},
    ["ugs3101"] = {"pgi311", "1341", "Cannon_Artillery_Large"},
    ["ugs3201"] = {"pga371", "7321", "Beam_Plasma_Continuous_Large"},
}

local projectileTp = {
    collisionInfo = {
        centerOffset = {
            x = 0,
            y = 0.5,
            z = 0,
        },
        collisionSize = {
            x = 1,
            y = 1,
            z = 1,
        }
    },
    general = {
        name = "Cannon_Small",
        tpId = "ped101",
    },
    nonUniformScale = {
        x = 1,
        y = 1,
        z = 1,
    },
    visuals = {
        mesh = {
            lod0distance = 60,
        },
    },
}

function ConstructVFXDataFromID(factionLetter, id, name)
    local data = {
        impact = string.format("VFX/Impact/v%si%s_%s_impact.sanvfx", factionLetter, id, string.lower(name)),
        muzzle = string.format("VFX/Muzzle/v%sm%s_%s_muzzle.sanvfx", factionLetter, id, string.lower(name)),
        trail = string.format("VFX/Trails/v%st%s_%s_trail.sanvfx", factionLetter, id, string.lower(name)),
    }


    if string.find(name, "Beam") or string.find(name, "Railgun") then
        data.beam = string.format("VFX/Beams/v%st%s_%s_beam.sanvfx", factionLetter, id, string.lower(name))
        data.trail = nil
    end

    return data
end

function GenerateProjectileTemplate(tpId, name, vfxData)
    local tp = table.deepCopy(projectileTp)

    tp.general.name = name
    tp.general.tpId = tpId

    -- Impact effect
    if vfxData.impact then
        tp.visuals.onImpactEffects = {
            {
                effects = {
                    {
                        particleName = vfxData.impact,
                    },
                }, 
            },
        }
    end

    -- trail or beam
    if vfxData.trail or vfxData.beam then
        tp.visuals.persistantEffects = {
            {
                effects = {
                    {
                        particleName = vfxData.trail or vfxData.beam,
                    },
                }, 
            },
        }
    end

    return tp
end

local unitProjectileVFXData = {
    -- unitTpId = {projTpId, muzzleFlashPath}
}

function GenerateProjectileTemplates()

    for unitTpId, projData in pairs(unitToProjectile) do
        local projTpId = projData[1]
        local projName = projData[3]

        local factionLetter = string.sub(projTpId, 2, 2)
        local vfxData = ConstructVFXDataFromID(factionLetter, projData[2], projData[3])

        if factionLetter == "e" then
            projName = "EDA_" .. projName
        elseif factionLetter == "c" then
            projName = "Chosen_" .. projName
        elseif factionLetter == "g" then
            projName = "Guard_" .. projName
        end
        
        local tp = GenerateProjectileTemplate(projTpId, projName, vfxData)
        local projFolderPath = libPath .. "\\common\\projectiles\\projectilesTemplates\\" .. projTpId
        local projFilePath = libPath .. "\\common\\projectiles\\projectilesTemplates\\" .. projTpId .. "\\" .. projTpId .. ".santp"

        if not Engine.FileExists(projFilePath) then
            os.execute("mkdir " .. projFolderPath)
        end
        table.save(tp, projFilePath, "projectileTemplate = ")

        unitProjectileVFXData[unitTpId] = {projTpId, vfxData.muzzle}
    end

    UpdateTemplates(UpdateUnitsProjectiles, "unit")

    unitProjectileVFXData = nil
end

function UpdateUnitsProjectiles(tp, tpId)
    if not unitProjectileVFXData[tpId] then
        return false
    end

    if tp and tp.weapons then
        local wep = tp.weapons[1]
        if wep then
            if wep.effects then
                wep.effects[1].onFire = unitProjectileVFXData[tpId][2]
            else
                wep.effects = {
                    onFire = unitProjectileVFXData[tpId][2],
                }
            end

            wep.projectileTemplate = unitProjectileVFXData[tpId][1]

            return true
        end
    end
end


-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0
if tpIdData[2].s ~= nil then
    error("Seraphim fourth-faction patch expected template faction letter s to be unused.")
end
tpIdData[2].s = "Seraphim"
-- Only for annotations
return {
    UpdateTemplates = UpdateTemplates,
    UpdateFootprints = UpdateFootprints,
    UpdateLOD = UpdateLOD,
    UpdateMuzzleSpeed = UpdateMuzzleSpeed,
    UpdateFiringTolerance = UpdateFiringTolerance,
    GenerateSkirtSize = GenerateSkirtSize,
    UpdateDeathExplosions = UpdateDeathExplosions,
    UpdateTemplatesHoles = UpdateTemplatesHoles,
    UpdateRollOffPoints = UpdateRollOffPoints,
    UpdateIconType = UpdateIconType,
    UpdateTemplatesVFX = UpdateTemplatesVFX,
    GetTpDataFromTpId = GetTpDataFromTpId,
    GenerateBasicTempalte = GenerateBasicTempalte,
    SetUpOrdersData = SetUpOrdersData,
    SetUpToggles = SetUpToggles,
    UpdateSelectionInfo = UpdateSelectionInfo,
    UpdateUnitName = UpdateUnitName,
    UpdateWeaponsFiringRandomness = UpdateWeaponsFiringRandomness,
    UpdateWeaponsPitch = UpdateWeaponsPitch,
    ConstructVFXDataFromID = ConstructVFXDataFromID,
    GenerateProjectileTemplate = GenerateProjectileTemplate,
    GenerateProjectileTemplates = GenerateProjectileTemplates,
    UpdateUnitsProjectiles = UpdateUnitsProjectiles,
    SlingRestrictUnits = SlingRestrictUnits,
    UpdateEffectsFormat = UpdateEffectsFormat,
    UpdatePersistantEffectsFormat = UpdatePersistantEffectsFormat,
}
