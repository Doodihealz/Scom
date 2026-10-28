
-- Supreme Commander Overhaul sea parity 1.0.0
-- Register cache-only UEF/Cybran unit and projectile folders after SCOM's scanner.
local SCOSeaParityPreviousScanDir = ScanDir
function ScanDir(directory)
    local folders = SCOSeaParityPreviousScanDir(directory)
    local generated
    if directory == "common/units/unitsTemplates/" then
        generated = {
            "uen1001",
            "uen1002",
            "uen2001",
            "uen2002",
            "uen3001",
            "uen3004",
            "uen3005",
            "uen4001",
            "ugn1001",
            "ugn1002",
            "ugn2001",
            "ugn2002",
            "ugn3001",
            "ugn3003",
            "ugn3004",
            "ugn3005",
            "ues1513",
            "ues2513",
            "ues3513",
            "ugs1513",
            "ugs2513",
            "ugs3513",
            "ues1512",
            "ugs1512",
        }
    elseif directory == "common/projectiles/projectilesTemplates/" then
        generated = {
            "psu302g",
            "psu302a",
        }
    else
        return folders
    end
    local known = {}
    for _, folder in ipairs(folders) do known[folder] = true end
    for _, templateId in ipairs(generated) do
        local folder = directory .. templateId
        if not known[folder] then
            table.insert(folders, folder)
            known[folder] = true
        end
    end
    return folders
end
