local libPath = libPath
local loadedModules = package.loaded

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- import.lua
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- This function is a replacement for require. Always use import instead of require.
-- This function finds the file, applies mod support for it, and then returns a table that the file operated on.
-- 
-- Here is how it works:
-- 1. The specified file is found
-- 2. Enabled mods are traversed and the last replaced file is used
-- 3. Next any mods that append the file with additional modifications have their patches applied to the file
-- 4. The modified code is loaded and executed. This is done in a separate environment. The file makes changes to the environment table.
-- 5. The environment table is returned.
-- 
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- What this means for code using import:
-- 
-- 1.return statements in the file are not supported - the return value is not collected.
-- 2.Global variables are saved into the environment table. All global variables in a file are returned, all local variables are not returned.
--   This way the global table is kept clean.
-- 3.This means that if you want a value returned, save it as a global variable. Otherwise save it as a local variable.
-- 4.To write to the actual global table you can use _G.VariableName, but this should be avoided unless absolutely necessary.
-- 
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- typical uses of import are:
-- 
-- local EDAUnits = Import("units/unitsClasses/unitsDefaultEDA.lua")
-- 
-- local Unit = Import("units/unitsClasses/unitsBaseClass.lua").Unit
-- 
-- unitsDefaultEDA.lua saves multiple variables to the global table. This table is then returned into EDAUnits
-- Unit inside unitsBaseClass.lua is a global variable and is therefore returned.
-- We do not want other values in the table so we select just Unit to be set as the variable.
-- 
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Mod support:
-- 
-- Whenever a file is imported, it checks in the list of enabled mods for corresponding file paths, then applies changes before loading the file.
-- This means that mods should replicate the file structure of the base game.
-- 
-- There are two types of modifications that can happen to a file:close
-- 
-- Replace - The file is replaced entirely by the file in the mod. 
--         - When multiple mods replace the same file, the last one in the mod load order is used.
-- 
-- Append  - The file from the mod is appended on to the end of the original. Then the combined file is executed in a single lua chunk
--         - This allows you to write as if you are in the original file itself. You can modify global variables, changing what is returned.
--         - Since the file is executed in the same chunk, you can also refer to local variables defined above.
--         - When multiple mods append the same file, the file is appended in order of the mod load order. With good code, many mods can be mutually compatible.
-- 
------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Each mod contains an Append and a Replace folder.
--Inside those folders the equivalent of the games filestructure is placed.
--When a mod is enabled, a mod-order-resolver should add it to the Mods_Active list in the correct position
--Then the import function will load the file whenever it is needed by the game.
--This allows mods to be enabled and disabled even at runtime.

--[[
function ResolveModOrder()
    Each mod has a v4 uuid for the purpose of being unique.
    
    Each mod has a Load_Before, Load_After, Requires, specifying other mod IDs
    
    The resolver must sort the Mods_Active list such that:
        Each mod is after any mod it requires
        Each mod is after any mod it is after
        Each mod is before any mod it is before
    
    Why does Requires exist? so that when you enable a mod it auto enables any requirements.
    This is different from After, where the After item is optional.
    
    Note how these three different criteria can all be resolved into just After:
        After = After
        Requires = After (but higher priority in case of circular depedency, see below)
        Before = not(After)
        
    This is a totally wild issue since you could have circular dependencies/relations i.e.
    A requires B; B requires C; C requires A
    In this case it should try its best but not loop forever

    The output should be a list of paths ordered in the best load order that satisfies the most criteria
    
    Good luck to whoevers gonna write this i suppose!
end

--]]


-- a list containing all active mod paths
-- this list is ordered in the mod load order
Mods_Active = {
    "/", -- base game directory, allowing some mods to be loaded before the base game for whatever reason
}

---@alias FilePath string Relative path to the file

---@class Module
---@field ImportedFileInfo FileInfo
local enrivonmentMt = {
    __index = _G,
}

---@class FileInfo
---@field FileName FilePath
---@field ImportDependencies table<FilePath, true>
---@field RegisterNewDependencies boolean

---@type {[FilePath]: Module} All imported modules, indexed by name. This is to avoid importing already imported files.
Imported_Modules = {}

---Custom file loading function that keeps track of loaded files and their modules.
---@param filePath FilePath Relative path to the file
---@return Module module #Imported module
function Import(filePath)
    if string.sub(filePath, -4) ~= ".lua" and string.sub(filePath, -6) ~= ".santp" then
        Warn("Import: File: '" .. filePath .. "' doesnt have '.lua' or '.santp' file extension.")
        filePath = filePath..".lua"
    end

    if loadedModules[filePath] then
        return loadedModules[filePath]
    end

    Log("Import: Loading file: "..filePath)

    -- mods can replace game files. we need to find the last file in a "replace-stack" and use that one
    -- we loop through the list in reverse order to find this file.

    local ModdedFilePath = libPath.."/"..filePath
    local lastReplaceModIndex = 1

    for i=#Mods_Active, 1, -1 do
        local modPath = Mods_Active[i]..filePath

        if Engine.FileExists(modPath) then
            ModdedFilePath = modPath
            lastReplaceModIndex = i
            break
        end
    end

    if not Engine.FileExists(ModdedFilePath) then
        Error("Import: Error loading up module: '"..filePath.."'. File doesn't exist.", 2)
    end
    local fileToImport = Engine.GetFileContent(ModdedFilePath)

    -- loop through the mod list again starting with the last replaced mod file, inclusively (mods can append themselves if they want)
    -- if there is a file in the same path then append the file onto the end of the file string

    for i=lastReplaceModIndex, #Mods_Active do
        local modPath = Mods_Active[i].."append/"..filePath --search for an append folder

        if Engine.FileExists(modPath) then
            --append all files in order starting from the last replace file
            fileToImport = fileToImport..Engine.GetFileContent(modPath)
        end
    end

    -- create a table for the environment of the file
    -- it contains entries for support of file dependencies, which are used to reload files during runtime
    -- the file imported will modify this table which we then return

    ---@type Module
    local envTable --need to declare table first otherwise inner import function will freak out

    ---@type FileInfo
    local fileInfo = {
        FileName = filePath,
        ImportDependencies = {},
        RegisterNewDependencies = true,
    }

    local innerImport = function(innerFilePath)
        --wrap the global import inside this function
        local innerEnvTable = Import(innerFilePath)
        --register the _outer_ file as a dependency inside the _inner_ file
        if envTable.ImportedFileInfo.RegisterNewDependencies then
            innerEnvTable.ImportedFileInfo.ImportDependencies[filePath] = true
        end
        return innerEnvTable
    end

    envTable = {
        ImportedFileInfo = fileInfo,
        -- Replaces the global Import with wrapped version that keep tracks of dependencies inside the modul
        Import = innerImport,
    }

    setmetatable(envTable, enrivonmentMt) --allow looking up global variables if they arent in the environment table

    ---@cast fileToImport -nil
    local chunk, errorMessage = load(fileToImport, "@"..filePath, 'bt', envTable) --run the file in that environment

    if not chunk then
        -- file did not compile
        Warn("import: failed to compile modded version of file at: "..filePath.." Perhaps check loaded mods for syntax errors.")
        error("import: "..errorMessage)
    end

    local ok, errorMessage = xpcall(chunk, function(err)
        return debug.traceback(err, 2)
    end)
    if not ok then
        -- file compiled but didnt execute correctly
        Warn("import: compiled but failed to execute modded version of file at: "..filePath.. " Perhaps check for nil values and other typical errors")
        error("import: "..errorMessage)
    end
    --what is the difference between these two errors anyway? someone who knows comment here

    --disable registration of new dependencies once the initial file has been run.
    --this means that functions calling Import() from that file will not register the file as a dependency
    --this is intended as the function would call a fresh copy of the file and so doesnt need reloading itself.
    envTable.ImportedFileInfo.RegisterNewDependencies = false

    loadedModules[filePath] = envTable

    return envTable --return the environment table where all the "global" variables in that file end up
end


--As part of support for hotloading files during runtime, we need to be able to mark files for reload
--This way the next time they are imported they will be imported fully instead of returning the cached version
function OnFileChange(filePath, eventType)
    if eventType == FileEventType.Deleted then
        return
    end

    local fileToReload = loadedModules[filePath]
    if not fileToReload or type(fileToReload) == 'boolean' then
        -- If fileToReload is a boolean it means it was loaded by require() rather than our import function.
        -- Therefore we can't hot reload it
        return
    end

    --clear the entry in the imported modules table. the next time the file is imported it will be fresh again
    loadedModules[filePath] = nil
    Log("Marking "..filePath.." for reload.")

    local dependencies = fileToReload.ImportedFileInfo.ImportDependencies
    if not dependencies then return end

    --recursively mark dependencies for reload as well
    for dep_filePath,_ in pairs(dependencies) do OnFileChange(dep_filePath) end

    if string.find(filePath, ".santp") then
        --Import("common/systems/templateLoader.lua").ReloadTemplate(filePath)
    end
end

function ProcessFileEvents()
    local fileEvents = Engine.GetFileEvents()
    for _, fileEvent in ipairs(fileEvents) do
        OnFileChange(fileEvent.filePath, fileEvent.eventType)
    end
end

function ScanDir(directory)
    local folders = { }
    Engine.GetFoldersInsideDirectory(directory, folders)
    for i, fileName in ipairs(folders) do
        folders[i] = directory..fileName
    end
    return folders
end

function _G.Log(text)
    Engine.Log(tostring(text))
end

function _G.Log2(prefix, text)
    Log(debug.traceback(prefix .. " : " .. tostring(text)))
end

function _G.Warn(text, level)
    if not level then
        level = 2
    else
        level = level + 1
    end

    text = debug.traceback("Warning: "..tostring(text), level)

    Engine.Warn(text)
end

-- For naming consistency
Error = error

-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0
-- Chain every prior loader and register only the six EDA UEF source routes.
local SCO_EdaLandPowerScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_EdaLandPowerScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end
    local routes = {
        directory .. "peu201g", directory .. "peu106m",
        directory .. "peu103f", directory .. "peu104a",
        directory .. "peu111m", directory .. "peu304a",
    }
    local known = {}
    for _, folder in ipairs(folders) do known[folder] = true end
    for _, folder in ipairs(routes) do
        if not known[folder] then
            table.insert(folders, folder)
            known[folder] = true
        end
    end
    return folders
end

-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0
-- FilesCache owns these virtual projectile templates, while the stock scanner
-- sees physical folders only. Chain whichever scanner a prior patcher supplied.
local SCO_FatboyScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_FatboyScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end

    local knownFolders = {}
    for _, folder in ipairs(folders) do
        knownFolders[folder] = true
    end

    local fatboyProjectiles = {
        "psf401",
        "psf402",
        "psf403",
        "psf404",
    }
    for _, templateId in ipairs(fatboyProjectiles) do
        local folder = directory .. templateId
        if not knownFolders[folder] then
            table.insert(folders, folder)
        end
    end
    return folders
end
-- Guard Cybran Monkeylord Cache Patcher 1.4.0
local SCO_MonkeylordScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_MonkeylordScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end
    local monkeylordFolders = {
        directory .. "pgr402b",
        directory .. "pgr402a",
        directory .. "pgr402t",
    }
    for _, monkeylordFolder in ipairs(monkeylordFolders) do
        local found = false
        for _, folder in ipairs(folders) do
            if folder == monkeylordFolder then
                found = true
                break
            end
        end
        if not found then table.insert(folders, monkeylordFolder) end
    end
    return folders
end


-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0
-- These two virtual projectile templates exist only in FilesCache.
-- Chain every earlier scanner and publish their logical folders once.
local SCO_FaAirFighterScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_FaAirFighterScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end

    local fighterFolders = {
        directory .. "pef102",
        directory .. "pgf102",
    }
    for _, fighterFolder in ipairs(fighterFolders) do
        local found = false
        for _, folder in ipairs(folders) do
            if folder == fighterFolder then
                found = true
                break
            end
        end
        if not found then
            table.insert(folders, fighterFolder)
        end
    end
    return folders
end

-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0
-- FilesCache owns these source-specific virtual projectile templates.  Chain
-- the scanner installed by any earlier module instead of replacing it.
local SCO_CybranDefenseScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_CybranDefenseScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end

    local knownFolders = {}
    for _, folder in ipairs(folders) do
        knownFolders[folder] = true
    end

    local cybranDefenseProjectiles = {
        "psu101",
        "psu121",
        "psu221",
        "psu321",
        "psu201",
        "pcg101",
        "pcg201",
        "pcg121",
        "pcg221",
        "pcg321",
        "pcg312",
    }
    for _, templateId in ipairs(cybranDefenseProjectiles) do
        local folder = directory .. templateId
        if not knownFolders[folder] then
            table.insert(folders, folder)
            knownFolders[folder] = true
        end
    end
    return folders
end


-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0
-- The virtual DRL0204 projectile lives in FilesCache rather than a physical
-- source folder.  Chain the scanner installed by other SCO modules and expose
-- its logical folder exactly once to Sanctuary's projectile loader.
local SCO_HopliteScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_HopliteScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end

    local hopliteFolder = directory .. "pgh204"
    for _, folder in ipairs(folders) do
        if folder == hopliteFolder then
            return folders
        end
    end
    table.insert(folders, hopliteFolder)
    return folders
end


-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0
-- Register only this module's two source-identified virtual projectile roots.
local SCO_ArtilleryPairScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_ArtilleryPairScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end

    local artilleryFolders = {
        directory .. "pcg103",
        directory .. "pcg203",
    }
    for _, artilleryFolder in ipairs(artilleryFolders) do
        local found = false
        for _, folder in ipairs(folders) do
            if folder == artilleryFolder then
                found = true
                break
            end
        end
        if not found then
            table.insert(folders, artilleryFolder)
        end
    end
    return folders
end
-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0
-- These four isolated projectile templates live only in FilesCache.
local SCO_FaRoleScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_FaRoleScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end
    local roleFolders = {
        directory .. "per303",
        directory .. "pgr203r",
        directory .. "pgr203b",
        directory .. "pgr203t",
    }
    for _, roleFolder in ipairs(roleFolders) do
        local found = false
        for _, folder in ipairs(folders) do
            if folder == roleFolder then found = true break end
        end
        if not found then table.insert(folders, roleFolder) end
    end
    return folders
end
-- Supreme Commander Overhaul UEF Percival 1.0.0
-- pep305 exists only in FilesCache; chain all earlier virtual scanners.
local SCO_PercivalScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_PercivalScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then return folders end
    local candidate = directory .. "pep305"
    for _, folder in ipairs(folders) do
        if folder == candidate then return folders end
    end
    table.insert(folders, candidate)
    return folders
end
-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0
-- The isolated pgr106 projectile exists only in FilesCache.
local SCO_FaHunterScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_FaHunterScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end
    local hunterFolder = directory .. "pgr106"
    for _, folder in ipairs(folders) do
        if folder == hunterFolder then return folders end
    end
    table.insert(folders, hunterFolder)
    return folders
end
-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0
-- These four isolated projectile templates exist only in FilesCache.
local SCO_FaCybranT3ScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_FaCybranT3ScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then return folders end
    local owned = {
        directory .. "pgr305h", directory .. "pgr305t",
        directory .. "pgr303d", directory .. "pgr303b",
    }
    for _, candidate in ipairs(owned) do
        local found = false
        for _, folder in ipairs(folders) do
            if folder == candidate then found = true break end
        end
        if not found then table.insert(folders, candidate) end
    end
    return folders
end
-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0
-- The dedicated egg-product projectiles exist only in FilesCache.
local SCO_EggProductsScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_EggProductsScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end
    local routes = {
        directory .. "pgr205b",
        directory .. "pgr304t",
    }
    local known = {}
    for _, folder in ipairs(folders) do known[folder] = true end
    for _, folder in ipairs(routes) do
        if not known[folder] then
            table.insert(folders, folder)
            known[folder] = true
        end
    end
    return folders
end
-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0

local SCO_MegalithScanDir = ScanDir
local SCO_MegalithScanRoutes = {
    ["common/units/unitsTemplates/"] = {
        "ugl4002", "ugs4902", "ugs4903", "ugs4904", "ugs4905",
    },
    ["common/projectiles/projectilesTemplates/"] = {
        "pmg401", "pmg402", "pmg403",
    },
}

function ScanDir(directory)
    local folders = SCO_MegalithScanDir(directory)
    local ids = SCO_MegalithScanRoutes[directory]
    if not ids then
        return folders
    end

    local known = {}
    for _, folder in ipairs(folders) do
        known[folder] = true
    end
    for _, id in ipairs(ids) do
        local folder = directory .. id
        if not known[folder] then
            table.insert(folders, folder)
            known[folder] = true
        end
    end
    return folders
end
-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0
local SCO_ScathisScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_ScathisScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then return folders end
    local candidate = directory .. "pgr401s"
    for _, folder in ipairs(folders) do
        if folder == candidate then return folders end
    end
    table.insert(folders, candidate)
    return folders
end

-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0
-- The FilesCache owns virtual us*.santp resources, but Engine.GetFoldersInsideDirectory
-- only reports physical folders. Add these resources exactly once to the unit scan.
local SCO_ScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_ScanDir(directory)
    if directory ~= "common/units/unitsTemplates/" then
        return folders
    end
    local knownFolders = {}
    for _, folder in ipairs(folders) do
        knownFolders[folder] = true
    end
    local seraphimFolders = {
        "usa1001",
        "usa1201",
        "usa1502",
        "usa1701",
        "usa2011",
        "usa2101",
        "usa2301",
        "usa2502",
        "usa3001",
        "usa3201",
        "usa3701",
        "usa4011",
        "usl0000",
        "usl1001",
        "usl1101",
        "usl1201",
        "usl1501",
        "usl1701",
        "usl2002",
        "usl2101",
        "usl2201",
        "usl2501",
        "usl2806",
        "usl3001",
        "usl3101",
        "usl3501",
        "usl3801",
        "usl4002",
        "usl4004",
        "usl4401",
        "usn1001",
        "usn1002",
        "usn2001",
        "usn2002",
        "usn3001",
        "usn3003",
        "usn3004",
        "uss1001",
        "uss1201",
        "uss1301",
        "uss1511",
        "uss1512",
        "uss1513",
        "uss1601",
        "uss1602",
        "uss1611",
        "uss1612",
        "uss1614",
        "uss1701",
        "uss1702",
        "uss1804",
        "uss2001",
        "uss2101",
        "uss2102",
        "uss2201",
        "uss2301",
        "uss2401",
        "uss2402",
        "uss2510",
        "uss2511",
        "uss2512",
        "uss2513",
        "uss2601",
        "uss2611",
        "uss2701",
        "uss2702",
        "uss2711",
        "uss2806",
        "uss3101",
        "uss3102",
        "uss3201",
        "uss3401",
        "uss3402",
        "uss3501",
        "uss3511",
        "uss3512",
        "uss3513",
        "uss3601",
        "uss3603",
        "uss3611",
        "uss3701",
        "uss4102",
    }
    for _, templateId in ipairs(seraphimFolders) do
        local folder = directory .. templateId
        if not knownFolders[folder] then
            table.insert(folders, folder)
        end
    end
    return folders
end


-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0
-- Chain the existing source-projectile scanner and expose the one cache-owned
-- UAL0001 projectile folder exactly once to Sanctuary's projectile loader.
local SCO_AeonAcuScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_AeonAcuScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end

    local aeonAcuFolder = directory .. "pcl001"
    for _, folder in ipairs(folders) do
        if folder == aeonAcuFolder then
            return folders
        end
    end
    table.insert(folders, aeonAcuFolder)
    return folders
end


-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0
-- Chain every prior scanner and add the exact cache-owned Aeon projectile folders.
local SCO_AeonProjectileVisualScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_AeonProjectileVisualScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end

    local aeonProjectileFolders = {
        directory .. "paa111",
        directory .. "paa211",
        directory .. "paa311",
        directory .. "paa341",
        directory .. "pad111",
        directory .. "pad131",
        directory .. "pad171",
        directory .. "pad311",
        directory .. "pad312",
        directory .. "pad411",
        directory .. "pad412",
        directory .. "pai111",
        directory .. "pai211",
        directory .. "pai311",
        directory .. "pad002",
        directory .. "pad004",
    }
    for _, aeonProjectileFolder in ipairs(aeonProjectileFolders) do
        local found = false
        for _, folder in ipairs(folders) do
            if folder == aeonProjectileFolder then
                found = true
                break
            end
        end
        if not found then
            table.insert(folders, aeonProjectileFolder)
        end
    end
    return folders
end

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0
-- These private projectile templates exist only in FilesCache. Chain the
-- earlier scanner and publish each reviewed logical folder once.
local SCO_FaAirBomberScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_FaAirBomberScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end

    local bomberFolders = {
        directory .. "pab101",
        directory .. "pab301",
        directory .. "peb101",
        directory .. "peb231",
        directory .. "peb301",
        directory .. "pgb101",
        directory .. "pgb231",
        directory .. "pgb301",
        directory .. "pgb302",
        directory .. "psb101",
        directory .. "psb202",
        directory .. "psb301",
        directory .. "psb402",
    }
    for _, bomberFolder in ipairs(bomberFolders) do
        local found = false
        for _, folder in ipairs(folders) do
            if folder == bomberFolder then
                found = true
                break
            end
        end
        if not found then
            table.insert(folders, bomberFolder)
        end
    end
    return folders
end


-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0
-- Chain the completed visual scanner and expose the one cache-owned Cybran ACU projectile.
local SCO_CybranAcuProjectileScanDir = ScanDir
function ScanDir(directory)
    local folders = SCO_CybranAcuProjectileScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end

    local cybranAcuProjectileFolder = directory .. "pcya01"
    for _, folder in ipairs(folders) do
        if folder == cybranAcuProjectileFolder then
            return folders
        end
    end
    table.insert(folders, cybranAcuProjectileFolder)
    return folders
end

-- Supreme Commander Overhaul commander enhancements 1.0.0
-- The UEA0001 template is cache-owned, so expose its logical folder to the
-- stock unit-template scanner while preserving every earlier scanner wrapper.
local SCOCommanderEnhancementScanDir = ScanDir
function ScanDir(directory)
    local folders = SCOCommanderEnhancementScanDir(directory)
    if directory ~= "common/units/unitsTemplates/" then
        return folders
    end

    local podFolder = directory .. "uea0001"
    for _, folder in ipairs(folders) do
        if folder == podFolder then
            return folders
        end
    end
    table.insert(folders, podFolder)
    return folders
end

-- Dedicated commander Overcharge prefabs are cache-owned.
local SCOMOverchargeScanDir = ScanDir
function ScanDir(directory)
    local folders = SCOMOverchargeScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then return folders end
    for _, id in ipairs({"pocuef", "pocaeon", "poccybran", "pocsera"}) do
        local path, found = directory .. id, false
        for _, folder in ipairs(folders) do
            if folder == path then found = true; break end
        end
        if not found then table.insert(folders, path) end
    end
    return folders
end
