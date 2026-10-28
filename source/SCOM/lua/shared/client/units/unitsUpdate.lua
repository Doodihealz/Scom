local xpcall = xpcall
local ErrorHandler = ErrorHandler

local GetTemplateId = GetTemplateId
local GetClass = GetClass
local GetTemplate = GetTemplate
local Units = __Entities.Units
local Shields = __Entities.Shields

---Registers a new client unit from the host
---@param globalId globalId Global ID of the unit
---@param localId localId Local ID of the unit
---@param armyId ArmyId Index of the army this unit belongs to
---@param prefabId PrefabID Engine ID of the template for this unit
local function registerUnit(globalId, localId, armyId, prefabId, progress)
    local tpId = GetTemplateId(prefabId)
    ---@type ClientUnit
    local unitClass = GetClass(tpId, "Units")
    local unitTemplate = GetTemplate(tpId, "Units")

    local unit = unitClass(globalId, localId, armyId, unitTemplate, progress)
    -- Save the unit into the global table
    Units[globalId.index] = unit
    Armies[armyId].units[globalId.index] = unit

    --Warn(string.format("Client: RegisterUnit: globalId: %d, localId: %d, armyId: %d, tpId: %s", globalId, localId, armyId, tpId))
end

---Registers a new client unit from the host
---@param globalId globalId Global ID of the unit
---@param localId localId Local ID of the unit
---@param armyId ArmyId Index of the army this unit belongs to
---@param prefabID PrefabID Engine ID of the template for this unit
---@param progress number Build progress of this unit
function RegisterUnit(globalId, localId, armyId, prefabID, progress)
    xpcall(registerUnit, ErrorHandler, globalId, localId, armyId, prefabID, progress)
end

---Destroys the client unit. Calls `Destroy` method on the unit.
---@param id globalId Global ID of the unit
---@param destroyType DestroyType
local function destroyUnit(id, destroyType)
    local unit = GetUnitById(id)
    if not unit then
        Warn("Client Destroy unit: Trying to destroy non existant unit: "..id)
        return
    end

    unit:Destroy(destroyType)
end

---Destroys the client unit. Calls `Destroy` method on the unit.
---@param id GlobalID
---@param destroyType DestroyType
function DestroyUnit(id, destroyType)
    xpcall(destroyUnit, ErrorHandler, id, destroyType)
end

---Removes the client unit. Calls `Delete` method on the unit.<br>
---Removes it from global and army table.
---@param id any
local function removeUnit(id)
    local unit = GetUnitById(id)
    if not unit then
        Warn("Client Remove unit: Trying to remove non existant unit: "..id)
        return
    end

    unit:Delete()

    --Log(string.format("Client: RemoveUnit: id: %d, army: %d, tpId: %s", unit.id, unit.armyId, unit.tpId))

    Units[id.index] = nil
    Armies[unit.armyId].units[id.index] = nil
end

---Destroys the client unit. Calls `Destroy` method on the unit.
function DeleteUnit(id)
    xpcall(removeUnit, ErrorHandler, id)
end

---Triggers the fire function in the muzzle class.
---@param id globalId Global ID of the muzzlee.
function FireMuzzle(id)
    local muzzle = __Muzzles[id.index]
    if not muzzle then
        Warn("Muzzle not found: " .. id.index)
        return
    end

    muzzle:RunFireMuzzle()
end

function EnableShield(globalID, enabled)
    local shield = Shields[globalID.index]
    if not shield then
        Warn("Shield not found: " .. globalID.index)
        return
    end

    if enabled then
        if shield:IsEnabled() then
            Warn("Shield is already enabled!"..globalID.index)
        else
            shield:Enable()
        end
    else
        if shield:IsEnabled() then
            shield:Disable()
        else
            Warn("Shield is already disabled!"..globalID.index)
        end
    end
end

---Sets the recharging state of the shield.
---@param globalID GlobalID
---@param isRecharging boolean
---@param rechargeTime number
function SetShieldRecharging(globalID, isRecharging, rechargeTime)
    local shield = Shields[globalID.index]
    if not shield then
        Warn("Shield not found: " .. globalID.index)
        return
    end

    shield:SetRecharging(isRecharging, rechargeTime)
end

---SimTick update of units. Dictates order in which unit related things will be update.<br>
---Processes the data in the global tables populated by the engine for this tick.
function UpdateUnits()
    for _, unit in pairs(Units) do
        local health = unit:GetHealth()
        local maxHealth = unit:GetMaxHealth()
        unit:UpdateProgressBars(health, maxHealth)
        unit:UpdateAudio(health, maxHealth)
    end
end

function RenderUpdateUnits()
end

-- Supreme Commander Overhaul commander enhancements 1.0.0
-- Render retiring imported commanders once more after the stock live-unit
-- pass. Their ClientUnit deletion is delayed until tick end even though
-- DeleteUnit has already removed them from __Entities.Units.
local SCORetirementRenderEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCORetirementRenderMarker = rawget(
    SCORetirementRenderEnvironment,
    "SCO_CommanderEnhancementRetirementRenderInstalled")
if SCORetirementRenderMarker ~= nil
    and SCORetirementRenderMarker ~= "1.0.0"
then
    error("Unsupported SCOM commander retirement-render marker "
        .. tostring(SCORetirementRenderMarker))
end
if SCORetirementRenderMarker == nil then
    if type(RenderUpdateUnits) ~= "function" then
        error("SCOM commander retirement render could not resolve RenderUpdateUnits")
    end

    -- The new stock renderer updates beam instances without visiting units.
    -- Restore the per-unit SCOM callbacks before retiring commanders refresh.
    if not _G.SCO_PerUnitRenderCompatInstalled then
        _G.SCO_PerUnitRenderCompatInstalled = true
        local previousRenderUpdateUnits = RenderUpdateUnits
        function RenderUpdateUnits(...)
            local result = previousRenderUpdateUnits(...)
            for _, unit in pairs(__Entities.Units) do
                local render = unit.RenderUpdateBeams
                if type(render) == "function" then
                    render(unit)
                end
            end
            return result
        end
    end

    local SCOStockRenderUpdateUnits = RenderUpdateUnits
    function RenderUpdateUnits(...)
        local result = SCOStockRenderUpdateUnits(...)
        local refresh = rawget(
            _G, "SCO_RefreshRetiringCommanderEnhancementVisuals")
        if type(refresh) == "function" then refresh() end
        return result
    end

    rawset(
        SCORetirementRenderEnvironment,
        "SCO_CommanderEnhancementRetirementRenderInstalled",
        "1.0.0")
end
-- Append to client unitsUpdate.lua, after native animation and previous owners.
do
    if not _G.SCO_SupportCommanderRenderInstalled then
        _G.SCO_SupportCommanderRenderInstalled = true
        local retiring = {}
        local delete = DeleteUnit
        function DeleteUnit(id)
            local unit = __Entities.Units[id.index]
            if unit and unit.id.version == id.version and unit.tp and unit.tp.additions
                and unit.tp.additions.scoSupportCommanderEnhancements then
                retiring[unit] = true
            end
            return delete(id)
        end
        local previous = RenderUpdateUnits
        function RenderUpdateUnits(...)
            local result = previous(...)
            local refresh = _G.SCO_RefreshCommanderEnhancementVisuals
            if refresh then
                for _, unit in pairs(__Entities.Units) do
                    if unit.tp and unit.tp.additions and unit.tp.additions.scoSupportCommanderEnhancements then refresh(unit) end
                end
                for unit in pairs(retiring) do
                    if unit.deleted or not Engine.IsValidLocalID(unit.localId) then retiring[unit] = nil
                    else refresh(unit) end
                end
            end
            return result
        end
    end
end

-- Append this whole file to ScomFieldFixes.Roster.source_support_commander_render.lua.
local Route = (function()
-- Pure planar adjacency route geometry. Skirts use inclusive placement cells;
-- body rectangles and explicit anchors use continuous world coordinates.
local Route = {}

local EPSILON = 0.000001

local function Finite(value)
    return type(value) == "number" and value == value
        and value ~= math.huge and value ~= -math.huge
end

local function Rectangle(rect)
    return rect and Finite(rect.x0) and Finite(rect.x1)
        and Finite(rect.z0) and Finite(rect.z1)
        and rect.x0 <= rect.x1 and rect.z0 <= rect.z1
end

local function Skirt(rect)
    return Rectangle(rect) and rect.x0 == math.floor(rect.x0)
        and rect.x1 == math.floor(rect.x1)
        and rect.z0 == math.floor(rect.z0)
        and rect.z1 == math.floor(rect.z1)
end

local function Contact(a, b)
    local z0, z1 = math.max(a.z0, b.z0), math.min(a.z1, b.z1)
    if z0 <= z1 then
        if a.x1 + 1 == b.x0 then return b.x0, z0, z1 + 1, 1, 0 end
        if b.x1 + 1 == a.x0 then return a.x0, z0, z1 + 1, -1, 0 end
    end
    local x0, x1 = math.max(a.x0, b.x0), math.min(a.x1, b.x1)
    if x0 <= x1 then
        if a.z1 + 1 == b.z0 then return b.z0, x0, x1 + 1, 0, 1 end
        if b.z1 + 1 == a.z0 then return a.z0, x0, x1 + 1, 0, -1 end
    end
end

local function Clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

local function Body(unit)
    if unit.body then return unit.body end
    local position, size = unit.position, unit.collisionSize
    if not position or not size or not Finite(position.x)
        or not Finite(position.z) or not Finite(size.x)
        or not Finite(size.z) or size.x <= 0 or size.z <= 0 then return nil end
    local turns = unit.quarterTurns or 0
    if type(turns) ~= "number" or turns ~= math.floor(turns) then return nil end
    local width, depth = size.x, size.z
    if turns % 2 == 1 then width, depth = depth, width end
    return {x0 = position.x - width * 0.5,
        x1 = position.x + width * 0.5,
        z0 = position.z - depth * 0.5,
        z1 = position.z + depth * 0.5}
end

local function Anchor(unit, towardX, towardZ, contactMid)
    if unit.anchor then
        if not Finite(unit.anchor.x) or not Finite(unit.anchor.z) then return nil end
        return {x = unit.anchor.x, z = unit.anchor.z}
    end
    local body = Body(unit)
    if not Rectangle(body) then return nil end
    local skirt = unit.skirt
    -- Allocate the contacted skirt slot on the visible body edge, including
    -- unequal and staggered structures, without attaching outside that body.
    if towardX ~= 0 then
        local fraction = Clamp((contactMid - skirt.z0) / (skirt.z1 - skirt.z0 + 1), 0, 1)
        return {x = towardX == 1 and body.x1 or body.x0,
            z = body.z0 + (body.z1 - body.z0) * fraction}
    end
    local fraction = Clamp((contactMid - skirt.x0) / (skirt.x1 - skirt.x0 + 1), 0, 1)
    return {x = body.x0 + (body.x1 - body.x0) * fraction,
        z = towardZ == 1 and body.z1 or body.z0}
end

local function Hash(pairKey)
    local value = 5381
    for index = 1, #pairKey do
        value = (value * 33 + pairKey:byte(index)) % 2147483647
    end
    return value
end

-- Local visual variation is stable across scans and never consumes simulation RNG.
local function PairRandom(pairKey)
    local state = Hash(pairKey) % 2147483646 + 1
    return function()
        state = (state * 16807) % 2147483647
        return (state - 1) / 2147483646
    end
end

function Route.Plan(first, second, faction)
    if not first or not second or first.id == nil or second.id == nil
        or tostring(first.id) == tostring(second.id) then
        return nil, "distinct unit IDs required"
    end
    if not Skirt(first.skirt) or not Skirt(second.skirt) then
        return nil, "valid skirt rectangles required"
    end
    if faction ~= "uef" and faction ~= "aeon" and faction ~= "cybran"
        and faction ~= "seraphim" then return nil, "unknown faction" end

    local a, b = first, second
    if tostring(a.id) > tostring(b.id) then a, b = b, a end
    local border, contactLow, contactHigh, nx, nz = Contact(a.skirt, b.skirt)
    if not border then return nil, "no cardinal skirt contact" end
    local tx, tz = -nz, nx
    local mid = (contactLow + contactHigh) * 0.5
    local originX = nx ~= 0 and border or mid
    local originZ = nx ~= 0 and mid or border
    local function Local(point)
        local dx, dz = point.x - originX, point.z - originZ
        return dx * nx + dz * nz, dx * tx + dz * tz
    end
    local function World(u, v)
        return {x = originX + u * nx + v * tx,
            z = originZ + u * nz + v * tz}
    end
    local bodyA, bodyB = Body(a), Body(b)
    if not Rectangle(bodyA) or not Rectangle(bodyB) then
        return nil, "visible body bounds required"
    end
    local function TangentLimits(body)
        local low = math.max(contactLow, nx ~= 0 and body.z0 or body.x0)
        local high = math.min(contactHigh, nx ~= 0 and body.z1 or body.x1)
        if low > high then return nil end
        local direction = nx ~= 0 and tz or tx
        local firstLimit, secondLimit = (low - mid) * direction, (high - mid) * direction
        return math.min(firstLimit, secondLimit), math.max(firstLimit, secondLimit)
    end
    local aLow, aHigh = TangentLimits(bodyA)
    local bLow, bHigh = TangentLimits(bodyB)
    if not aLow or not bLow then return nil, "body misses shared contact" end
    local start, finish = Anchor(a, nx, nz, mid), Anchor(b, -nx, -nz, mid)
    if not start or not finish then return nil, "visible body anchors required" end
    local ua, va = Local(start)
    local ub, vb = Local(finish)
    va, vb = Clamp(va, aLow, aHigh), Clamp(vb, bLow, bHigh)
    if ua > EPSILON or ub < -EPSILON or ub - ua <= EPSILON then
        return nil, "no visible span between body anchors"
    end
    local halfWidth = (contactHigh - contactLow) * 0.5
    local centerA = a.position or {x = (bodyA.x0 + bodyA.x1) * 0.5,
        z = (bodyA.z0 + bodyA.z1) * 0.5}
    local centerB = b.position or {x = (bodyB.x0 + bodyB.x1) * 0.5,
        z = (bodyB.z0 + bodyB.z1) * 0.5}
    local aligned = math.abs(centerA.x - centerB.x) <= EPSILON
        or math.abs(centerA.z - centerB.z) <= EPSILON
    local random = PairRandom(tostring(a.id) .. ":" .. tostring(b.id) .. ":" .. faction)
    local sign = random() < 0.5 and -1 or 1
    local points = {}
    local function Push(u, v)
        points[#points + 1] = World(Clamp(u, ua, ub), Clamp(v, -halfWidth, halfWidth))
    end
    local variant = faction == "aeon" and (1 + math.floor(random() * 3)) or 1
    if faction == "uef" then
        if aligned then
            -- FA shifts both hubs and the two middle stations in opposite
            -- directions; the resulting three spans stay orthogonal.
            va = Clamp(va + sign * 0.1225, aLow, aHigh)
            vb = Clamp(vb - sign * 0.1225, bLow, bHigh)
        end
        Push(ua, va)
        Push((ua + ub) * 0.5, va)
        Push((ua + ub) * 0.5, vb)
    elseif faction == "cybran" then
        local firstU, secondU
        if aligned then
            local upper = (ub - ua) * 0.48
            local lower = math.min(0.35, upper)
            local distance = lower + (upper - lower) * random()
            local lateral = distance * (0.2 + 0.15 * random()) * sign
            va, vb = Clamp(va + lateral, aLow, aHigh), Clamp(vb - lateral, bLow, bHigh)
            firstU, secondU = ua + distance, ub - distance
        else
            local halfSpan = (ub - ua) * 0.5
            firstU = (ua + ub) * 0.5 - math.min(random(), halfSpan * 0.9)
            secondU = (ua + ub) * 0.5 + math.min(random(), halfSpan * 0.9)
        end
        Push(ua, va)
        Push(firstU, va)
        Push(secondU, vb)
    else
        local dx, dz = centerB.x - centerA.x, centerB.z - centerA.z
        local dy = (centerB.y or 0) - (centerA.y or 0)
        local count = faction == "seraphim" and dx * dx + dy * dy + dz * dz < 6.25 and 1 or 3
        Push(ua, va)
        for index = 1, count do
            local t = index / (count + 1)
            local multiplier = count == 1 and 0.27 or (index == 2 and 0.39 or 0.27)
            -- FA: cross(first-minus-second, (0,.35,0)), with a pair-seeded side.
            Push(ua + (ub - ua) * t - (vb - va) * 0.35 * multiplier * sign,
                va + (vb - va) * t + (ub - ua) * 0.35 * multiplier * sign)
        end
    end
    Push(ub, vb)
    for index = 1, #points - 1 do
        local dx = points[index + 1].x - points[index].x
        local dz = points[index + 1].z - points[index].z
        if dx * dx + dz * dz <= EPSILON * EPSILON then return nil, "degenerate node span" end
    end
    return {points = points, firstId = a.id, secondId = b.id,
        contact = {x = originX, z = originZ, width = contactHigh - contactLow},
        renderMode = faction == "seraphim" and "nodes" or "beam", variant = variant,
        phase = random() * math.pi * 2}
end

return Route
end)()
-- That resource already runs inside client/units/unitsUpdate.lua. No new Lua
-- resource path or host state is required.
local ROUTE_STYLES = {E = "uef", A = "aeon", R = "cybran", S = "seraphim"}
local ASSET_ROOT = "VFX/SCOM/FAAdjacency/"
-- These ground-plane ribbons need more width than FA's camera-facing beams.
local VISUAL_STYLES = {
    uef = {node = "UEF", beams = {{material = "UEF", width = 0.03}}},
    cybran = {node = "Cybran", beams = {{material = "Cybran", width = 0.05}}},
    aeon = {node = "Aeon", beams = {
        {material = "Aeon01", width = 0.10},
        {material = "Aeon02", width = 0.07},
        {material = "Aeon03", width = 0.16},
    }},
    seraphim = {node = "Seraphim"},
}
-- Slightly larger source ring/arc silhouettes keep Seraphim equally readable.
-- Only the arc has a nonzero source rotation rate.
local SERAPHIM_AMBIENT = {
    {name = "Ring", size = 0.4284, rate = 0, lift = 0.01},
    {name = "Arc", size = 0.70, rate = math.pi / 60, lift = 0.02},
}
local connectorPrefabs = {}
local connectorFailureWarned = false
local modelBoundsCache = {}
-- Exact providers from fa_adjacency_manifest.lua: target ID, FA source ID,
-- and source blueprint digest. The code suffix determines the FA buff table.
local PROVIDERS = {
    ucs1601 = {"UAB1103", "a689422b2297f98499348c07ad287c27814ca9c136c92043e055e16f82e3989f"},
    ucs1602 = {"UAB1106", "67fa5432484ba5a246f0ed1920b3de446472d3d424d06547bdae20977b38776d"},
    ucs1611 = {"UAB1101", "ee45b4f2d63480574a0d370ae2372cd5d44b20e88869cac5003b2500d479094d"},
    ucs1612 = {"UAB1105", "a956cc05ab2d449c1252d0d2e088f55347da95b85f91428c4dde955dbcd2bd7b"},
    ucs1614 = {"UAB1102", "226e38c51f687f906d0d30ba449d032223b40eed65aaff7bb8c0607b021f25b6"},
    ucs2601 = {"UAB1202", "79b006969a88b2e16acebe9cfd234890397b5fcd77a7e9c9f9e783efef0725d7"},
    ucs2611 = {"UAB1201", "780b0749722ac6c56861949cd03a8a40de76a3b0c1e026d07ea861460b99fc9f"},
    ucs2806 = {"UAB1104", "3c4eb4cef01985a92ce78af0b587346f9df08d3fc471cb52f22b307e3e47ff5f"},
    ucs3601 = {"UAB1302", "18a5d6b6e2a027d0d599dc47177e48883190de7fadc97e3da3eab25a0010ad83"},
    ucs3603 = {"UAB1303", "dfc725ed7309bf0bb00f1bd07b83cd25d356413cc9783cee81be55463f237be1"},
    ucs3611 = {"UAB1301", "96e85f646efd233848af22f3cd6c6bfc74afde1f5dd27e5d2975f1b0fd11dfcf"},
    ues1601 = {"UEB1103", "86c7f83bd2c803cd1640e9a88785bf847aff377287ceabedbe7d7735083e55bf"},
    ues1602 = {"UEB1106", "3c728933dfe3567a969b4ee8a6663fac7e600dca163873e4eba6374fa0d549a7"},
    ues1611 = {"UEB1101", "0382700aa10d13a2ef2e02e5fd95e42baf51962f51268c61c929324860ca23ec"},
    ues1612 = {"UEB1105", "c034747eef467a9ce0895dcc670384b6ef404b2427e3fffa7ad0c3a6d4200384"},
    ues2601 = {"UEB1202", "a9cd0868668e03102cfa642387727daacb22fc6b1816c857ad1d95cd3efe02a2"},
    ues2611 = {"UEB1201", "49ea20d181b052fabd2563a799c87dadb89a71025233210ef59a944e34c95e17"},
    ues3601 = {"UEB1302", "4f488f277b85b44ea8d422228e936d2933e8e667b690e633e89a13e6560558ef"},
    ues3603 = {"UEB1303", "fbb11aa62f87e520fea91e63f7f7f9bedb83fb1f2f59f7e78bd031522496ba4b"},
    ues3611 = {"UEB1301", "71e92d602bed2a04916c020662df4f1ac74030cd7de70eff0f962aa760cd57af"},
    ues5015 = {"UEB1102", "c881c49165ff33b9644eb62910fad3ed2075fdf732f1fc5dceb028b673f710fc"},
    ues5016 = {"UEB1104", "c4ae102f6ed87c4e5c04b2ae019b16b5cf53244dc95ab865e3fc0d12286bdd52"},
    ugs1601 = {"URB1103", "e723b2d7f3b916bd24f46587a9ef7c3691b60265830553bb234505cd162db1ef"},
    ugs1602 = {"URB1106", "323ac892e188940daad815df6ee42ffe2f75585376591ede1965706ca51055f7"},
    ugs1611 = {"URB1101", "734334190aa6eef78ac93913147b0849c9add39f9850e983cc79641a5bb601ba"},
    ugs1612 = {"URB1105", "5f7f46eea3ee0e1ddd37db354fb54ff30fe197aa5b2c45e04ab21706f0427e59"},
    ugs2601 = {"URB1202", "b89469f2fa005d292b134e78aa46bf36d3ba3693085bf4b2a991d84635924a9c"},
    ugs2611 = {"URB1201", "19cef2bfff64f1dd4f859db54272fbfd5753912baadefc8db898f6b31fc4c0cb"},
    ugs3601 = {"URB1302", "8e6c44d30877de9829061ac604f160ed81797698d6bed13c3580dc98ea5baf8c"},
    ugs3603 = {"URB1303", "bf7930986d1b416fc4db68e070f4b1249d2edce04c82415c03791f62ab79ae75"},
    ugs3611 = {"URB1301", "e1d59ee7ded7cae10c69bfde8fe4a76927de45449b35dd951de2ae3be9947439"},
    ugs5003 = {"URB1102", "5d744a449a2f1c66a8523324b5f37581b2bea656169fc6c260b7d096316bcd99"},
    ugs5004 = {"URB1104", "8adf72c514ddbeade7f7b08a150f3dd9a894ad1459a0ff30f5efbb1651431f50"},
    uss1601 = {"XSB1103", "159d28c3cba3926678b7a63172fc1e6bcc0119da4252b873033a0b4c3270f0c4"},
    uss1602 = {"XSB1106", "bf41d3107fb3a1cd6bcee688306fe496e7a07a87cac8e2a729f64108f5fc4336"},
    uss1611 = {"XSB1101", "ba1ca690e52e57843cb4304a14e4e4bc361fbfb2018b6882d2b6d31da922027d"},
    uss1612 = {"XSB1105", "c6aa766013df3f1d51c81d16a0d4662a317cd068cc026d73c9e9316762be3070"},
    uss1614 = {"XSB1102", "3c83b8f1ac1224e0d65768164ff3e9b791e22ca81fa4a3d17a214a2130692473"},
    uss2601 = {"XSB1202", "91ad0dfaddeda2ff4ce374093402c9f49c7a3cd6942ad8336e32f24bdbb72787"},
    uss2611 = {"XSB1201", "98233f21427098d2c34a7ef8334068200bf4da361a46a26feaf391384bd162ea"},
    uss2806 = {"XSB1104", "06804bda7421af1fbb486f8da89c561c423e2951631d93dbf4e3915b64929514"},
    uss3601 = {"XSB1302", "6d4c49eac21e412bb284a515850a52f60a69c1c1cefc35a1bbf0cc83c72fd3c8"},
    uss3603 = {"XSB1303", "009adb261deefbb544dba5abb8785da2bcf1c1e84ec6abcc12a314228755bf75"},
    uss3611 = {"XSB1301", "d3e64b6276d7da2404226e898e335bf91221602f27d46d7e2c78afdf8c6e6090"},
}

-- Exact recipients from fa_adjacency_recipients.lua: source ID, FA size,
-- and static check flags (build, silo, maintenance, energy/mass production,
-- energy weapon, any source weapon). A live contract ID is checked below.
local RECIPIENTS = {
    ucs1001 = {"UAB2101", 4, 64},
    ucs1201 = {"UAB2104", 4, 64},
    ucs1301 = {"UAB2109", 4, 64},
    ucs1511 = {"UAB0101", 16, 1},
    ucs1512 = {"UAB0102", 16, 1},
    ucs1513 = {"UAB0103", 16, 1},
    ucs1601 = {"UAB1103", 4, 21},
    ucs1602 = {"UAB1106", 4, 0},
    ucs1611 = {"UAB1101", 4, 72},
    ucs1612 = {"UAB1105", 4, 64},
    ucs1614 = {"UAB1102", 12, 8},
    ucs1701 = {"UAB3101", 4, 5},
    ucs1702 = {"UAB3102", 4, 5},
    ucs2001 = {"UAB2301", 4, 64},
    ucs2101 = {"UAB2303", 4, 96},
    ucs2102 = {"UAB2108", 4, 66},
    ucs2201 = {"UAB2204", 4, 64},
    ucs2301 = {"UAB2205", 4, 64},
    ucs2401 = {"UAB4202", 12, 4},
    ucs2402 = {"UAB4201", 4, 64},
    ucs2510 = {"UAB0304", 20, 1},
    ucs2511 = {"UAB0201", 16, 1},
    ucs2512 = {"UAB0202", 16, 1},
    ucs2513 = {"UAB0203", 16, 1},
    ucs2601 = {"UAB1202", 4, 21},
    ucs2611 = {"UAB1201", 12, 72},
    ucs2701 = {"UAB3201", 4, 5},
    ucs2702 = {"UAB3202", 4, 5},
    ucs2711 = {"UAB4203", 12, 4},
    ucs2801 = {"UAB5103", 4, 0},
    ucs2806 = {"UAB1104", 4, 84},
    ucs3001 = {"XAB2307", 4, 96},
    ucs3101 = {"UAB2302", 16, 96},
    ucs3102 = {"UAB2305", 12, 66},
    ucs3201 = {"UAB2304", 4, 64},
    ucs3401 = {"UAB4301", 12, 4},
    ucs3402 = {"UAB4302", 8, 66},
    ucs3501 = {"UAB5202", 12, 0},
    ucs3511 = {"UAB0301", 16, 1},
    ucs3512 = {"UAB0302", 16, 1},
    ucs3513 = {"UAB0303", 16, 1},
    ucs3601 = {"UAB1302", 4, 20},
    ucs3603 = {"UAB1303", 12, 84},
    ucs3611 = {"UAB1301", 16, 72},
    ucs3701 = {"UAB3104", 4, 4},
    ucs3702 = {"XAB3301", 4, 4},
    ucs4102 = {"XAB1401", 12, 64},
    ues1001 = {"UEB2101", 4, 64},
    ues1201 = {"UEB2104", 4, 64},
    ues1511 = {"UEB0101", 16, 1},
    ues1512 = {"UEB0102", 16, 1},
    ues1513 = {"UEB0103", 16, 1},
    ues1601 = {"UEB1103", 4, 21},
    ues1602 = {"UEB1106", 4, 0},
    ues1611 = {"UEB1101", 4, 72},
    ues1612 = {"UEB1105", 4, 64},
    ues1701 = {"UEB3101", 4, 5},
    ues2001 = {"UEB2301", 4, 64},
    ues2101 = {"UEB2303", 4, 96},
    ues2102 = {"UEB2108", 4, 66},
    ues2201 = {"UEB2204", 4, 64},
    ues2401 = {"UEB4202", 12, 5},
    ues2402 = {"UEB4201", 4, 64},
    ues2511 = {"UEB0201", 16, 1},
    ues2512 = {"UEB0202", 16, 1},
    ues2513 = {"UEB0203", 16, 1},
    ues2601 = {"UEB1202", 4, 21},
    ues2611 = {"UEB1201", 12, 72},
    ues2701 = {"UEB3201", 4, 5},
    ues3102 = {"UEB2305", 12, 66},
    ues3201 = {"UEB2304", 4, 64},
    ues3401 = {"UEB4301", 12, 4},
    ues3511 = {"UEB0301", 16, 1},
    ues3512 = {"UEB0302", 16, 1},
    ues3513 = {"UEB0303", 16, 1},
    ues3601 = {"UEB1302", 4, 20},
    ues3603 = {"UEB1303", 12, 84},
    ues3611 = {"UEB1301", 16, 72},
    ues3701 = {"UEB3104", 4, 4},
    ues4101 = {"UEB2401", 16, 96},
    ugs1001 = {"URB2101", 4, 64},
    ugs1201 = {"URB2104", 4, 64},
    ugs1511 = {"URB0101", 16, 1},
    ugs1512 = {"URB0102", 16, 1},
    ugs1513 = {"URB0103", 16, 1},
    ugs1601 = {"URB1103", 4, 21},
    ugs1602 = {"URB1106", 4, 0},
    ugs1611 = {"URB1101", 4, 72},
    ugs1612 = {"URB1105", 4, 64},
    ugs1701 = {"URB3101", 4, 5},
    ugs2001 = {"URB2301", 4, 64},
    ugs2101 = {"URB2303", 4, 96},
    ugs2102 = {"URB2108", 4, 66},
    ugs2201 = {"URB2204", 4, 64},
    ugs2401 = {"URB4202", 12, 5},
    ugs2402 = {"URB4201", 4, 64},
    ugs2511 = {"URB0201", 16, 1},
    ugs2512 = {"URB0202", 16, 1},
    ugs2513 = {"URB0203", 16, 1},
    ugs2601 = {"URB1202", 4, 21},
    ugs2611 = {"URB1201", 12, 72},
    ugs2701 = {"URB3201", 4, 5},
    ugs3101 = {"URB2302", 16, 96},
    ugs3201 = {"URB2304", 4, 64},
    ugs3401 = {"URB4207", 12, 4},
    ugs3511 = {"URB0301", 16, 1},
    ugs3512 = {"URB0302", 16, 1},
    ugs3513 = {"URB0303", 16, 1},
    ugs3601 = {"URB1302", 4, 20},
    ugs3603 = {"URB1303", 12, 84},
    ugs3611 = {"URB1301", 16, 72},
    ugs3701 = {"URB3104", 4, 4},
    uss1001 = {"XSB2101", 4, 64},
    uss1201 = {"XSB2104", 4, 64},
    uss1301 = {"XSB2109", 4, 64},
    uss1511 = {"XSB0101", 16, 1},
    uss1512 = {"XSB0102", 16, 1},
    uss1513 = {"XSB0103", 16, 1},
    uss1601 = {"XSB1103", 4, 21},
    uss1602 = {"XSB1106", 4, 0},
    uss1611 = {"XSB1101", 4, 72},
    uss1612 = {"XSB1105", 4, 64},
    uss1614 = {"XSB1102", 12, 8},
    uss1701 = {"XSB3101", 4, 5},
    uss1702 = {"XSB3102", 4, 5},
    uss2001 = {"XSB2301", 4, 64},
    uss2101 = {"XSB2303", 4, 96},
    uss2102 = {"XSB2108", 4, 66},
    uss2201 = {"XSB2204", 4, 64},
    uss2301 = {"XSB2205", 4, 64},
    uss2401 = {"XSB4202", 12, 5},
    uss2402 = {"XSB4201", 4, 64},
    uss2510 = {"XSB0304", 20, 1},
    uss2511 = {"XSB0201", 16, 1},
    uss2512 = {"XSB0202", 16, 1},
    uss2513 = {"XSB0203", 16, 1},
    uss2601 = {"XSB1202", 4, 21},
    uss2611 = {"XSB1201", 12, 72},
    uss2701 = {"XSB3201", 4, 5},
    uss2702 = {"XSB3202", 4, 4},
    uss2711 = {"XSB4203", 12, 4},
    uss2806 = {"XSB1104", 4, 84},
    uss3101 = {"XSB2302", 16, 96},
    uss3102 = {"XSB2305", 12, 66},
    uss3201 = {"XSB2304", 4, 64},
    uss3401 = {"XSB4301", 12, 4},
    uss3402 = {"XSB4302", 8, 66},
    uss3501 = {"XSB5202", 12, 0},
    uss3511 = {"XSB0301", 16, 1},
    uss3512 = {"XSB0302", 16, 1},
    uss3513 = {"XSB0303", 16, 1},
    uss3601 = {"XSB1302", 4, 20},
    uss3603 = {"XSB1303", 12, 84},
    uss3611 = {"XSB1301", 16, 72},
    uss3701 = {"XSB3104", 4, 4},
    uss4102 = {"XSB2401", 12, 66},
    wab1302 = {"XSB1303", 12, 84},
    wab2303 = {"XSB4302", 8, 66},
    wrb0304 = {"URB0301", 16, 1},
    wsb4205 = {"XSB4201", 4, 64},
    ues5014 = {"UEB0304", 20, 1},
    ues5015 = {"UEB1102", 12, 8},
    ues5016 = {"UEB1104", 4, 84},
    ues5017 = {"UEB2109", 4, 64},
    ues5018 = {"UEB2205", 4, 64},
    ues5019 = {"UEB2302", 16, 96},
    ues5020 = {"UEB3102", 4, 5},
    ues5021 = {"UEB3202", 4, 5},
    ues5022 = {"UEB4203", 12, 4},
    ues5023 = {"UEB4302", 8, 66},
    ues5025 = {"UEB5202", 12, 0},
    ues5042 = {"XEB2306", 12, 96},
    ugs5002 = {"URB0304", 20, 1},
    ugs5003 = {"URB1102", 12, 8},
    ugs5004 = {"URB1104", 4, 84},
    ugs5005 = {"URB2109", 4, 64},
    ugs5006 = {"URB2205", 4, 64},
    ugs5007 = {"URB2305", 12, 66},
    ugs5008 = {"URB3102", 4, 5},
    ugs5009 = {"URB3103", 4, 4},
    ugs5010 = {"URB3202", 4, 5},
    ugs5011 = {"URB4203", 12, 4},
    ugs5012 = {"URB4204", 12, 5},
    ugs5013 = {"URB4205", 12, 5},
    ugs5014 = {"URB4206", 12, 5},
    ugs5015 = {"URB4302", 8, 66},
    ugs5017 = {"URB5202", 12, 0},
    ugs5027 = {"XRB2308", 4, 64},
    ugs5028 = {"XRB3301", 12, 4},
}
local KIND_BY_CODE = {
    ["1101"] = "power", ["1201"] = "power", ["1301"] = "power",
    ["1102"] = "power", -- Hydrocarbon source.
    ["1103"] = "massBuild", ["1202"] = "massBuild",
    ["1302"] = "massBuild", ["1104"] = "massBuild",
    ["1303"] = "massBuild",
    ["1106"] = "massProduction", ["1105"] = "energyProduction",
}
local CAMERA_CUTOFF = 200 -- Height above the linked structures, not world elevation.
local BUCKET_SIZE = 8
local MAX_BUCKET_CELLS = 64
local UP = EngineClasses.float3(0, 1, 0)

local links = {}
-- Bounded diagnostics for the unresolved all-faction visibility report.
-- Each scan milestone and each faction's pair outcome is emitted once.
local adjacencyDiagnostics = {}
local adjacencyDiagnosticCount = 0

local function DiagnosticPosition(position)
    return string.format("(%.3f,%.3f,%.3f)", position.x, position.y, position.z)
end

local function DiagnosticUnit(unit)
    if not unit then return "none" end
    local skirt = unit.tp.skirtSize
    local tags = {}
    for _, tag in ipairs(unit.tp.tags or {}) do
        if tag:sub(1, 5) == "SCFA_" then tags[#tags + 1] = tag end
    end
    local position = Engine.IsValidLocalID(unit.localId)
        and DiagnosticPosition(unit:GetPosition()) or "invalid-local-id"
    return string.format("%s#%s:%s army=%s position=%s skirt=%s,%s completed=%s vision=%s tags=%s",
        tostring(unit.tpId), tostring(unit.id.index), tostring(unit.id.version),
        tostring(unit.armyId), position,
        tostring(skirt and skirt.x), tostring(skirt and skirt.y),
        tostring(unit:IsCompleted()), tostring(unit:IsIntelVisionVisible()), table.concat(tags, ","))
end

local function TraceAdjacencyPair(stage, link, detail)
    local key = stage .. ":" .. link.style
    if adjacencyDiagnostics[key] then return end
    adjacencyDiagnostics[key] = true
    if adjacencyDiagnosticCount >= 8 then return end
    adjacencyDiagnosticCount = adjacencyDiagnosticCount + 1
    Engine.Warn("[SCOM adjacency diagnostic] " .. key .. " " .. detail
        .. " source={" .. DiagnosticUnit(link.source) .. "} neighbor={"
        .. DiagnosticUnit(link.neighbor) .. "}")
end

local function Key(a, b)
    local first = tostring(a.id.index) .. ":" .. tostring(a.id.version)
    local second = tostring(b.id.index) .. ":" .. tostring(b.id.version)
    if first > second then first, second = second, first end
    return first .. ":" .. second
end

local function HasTag(unit, name)
    for _, value in ipairs(unit.tp.tags or {}) do
        if value == name then return true end
    end
    return false
end

local function Eligible(unit)
    if not unit or not unit.id or unit.dead or unit.deleted
        or not unit:IsCompleted() or not unit.tp.skirtSize
        or not HasTag(unit, "SCFA_STRUCTURE") then return false end
    local facts = RECIPIENTS[unit.tpId]
    if not facts or not HasTag(unit, "SCFA_SIZE" .. facts[2]) then return false end
    local contract = unit.tp.additions and unit.tp.additions.faSourceContract
    return not contract or not contract.sourceId
        or contract.sourceId:upper() == facts[1]
end

local function IsProvider(unit)
    local expected = PROVIDERS[unit.tpId]
    if not expected then return false end
    local contract = unit.tp.additions and unit.tp.additions.faSourceContract
    return (not contract or not contract.sourceId
            or contract.sourceId:upper() == expected[1])
        and (not contract or not contract.sourceBlueprintSha256
            or contract.sourceBlueprintSha256:lower() == expected[2])
end

local function HasFlag(flags, flag)
    return flags % (flag * 2) >= flag
end

-- Mirror the host's FA row category and check-function gates using the
-- immutable recipient facts. Dynamic maintenance overrides are checked when
-- the client exposes one; energy weapons also need a live template weapon.
local function HasApplicableRow(source, target)
    local provider = PROVIDERS[source.tpId]
    local facts = RECIPIENTS[target.tpId]
    if not provider or not facts then return false end
    local kind = KIND_BY_CODE[provider[1]:sub(4)]
    local flags, size = facts[3], facts[2]
    local canBuild = HasFlag(flags, 1) or HasFlag(flags, 2)
    if kind == "massBuild" then return canBuild end
    if kind == "massProduction" then return HasFlag(flags, 16) end
    if kind == "energyProduction" then return HasFlag(flags, 8) end
    if kind == "power" then
        if canBuild or HasFlag(flags, 4)
            or target.EnergyMaintenanceConsumptionOverride then return true end
        local hasWeapon = target.tp.weapons and #target.tp.weapons > 0
        if hasWeapon and HasFlag(flags, 32) then return true end
        return size == 4 and hasWeapon and HasFlag(flags, 64)
            and HasTag(target, "SCFA_ARTILLERY")
    end
    return false
end

local function Bounds(unit)
    local skirt = unit.tp and unit.tp.skirtSize
    if not skirt or not skirt.x or not skirt.y then return nil end
    local position = unit:GetPosition()
    if not position then return nil end
    local x = math.floor(position.x - skirt.x * 0.5)
    local z = math.floor(position.z - skirt.y * 0.5)
    return {x0 = x, x1 = x + skirt.x - 1, z0 = z, z1 = z + skirt.y - 1}
end

-- Match scom_fa_core.lua edgeContact's inclusive cardinal-cell test.
-- The visual spans the contacted cells' common world-space border.
local function SharedEdge(a, b)
    local aa, bb = Bounds(a), Bounds(b)
    if not aa or not bb then return nil end
    local x0, x1 = math.max(aa.x0, bb.x0), math.min(aa.x1, bb.x1)
    local z0, z1 = math.max(aa.z0, bb.z0), math.min(aa.z1, bb.z1)
    if z0 <= z1 and aa.x1 + 1 == bb.x0 then
        return {x = bb.x0, z = z0}, {x = bb.x0, z = z1 + 1}
    elseif z0 <= z1 and bb.x1 + 1 == aa.x0 then
        return {x = aa.x0, z = z0}, {x = aa.x0, z = z1 + 1}
    end
    if x0 <= x1 and aa.z1 + 1 == bb.z0 then
        return {x = x0, z = bb.z0}, {x = x1 + 1, z = bb.z0}
    elseif x0 <= x1 and bb.z1 + 1 == aa.z0 then
        return {x = x0, z = aa.z0}, {x = x1 + 1, z = aa.z0}
    end
    return nil
end

local function UnitId(unit)
    return tostring(unit.id.index) .. ":" .. tostring(unit.id.version)
end

local function FiniteNumber(value)
    return type(value) == "number" and value == value
        and value ~= math.huge and value ~= -math.huge
end

-- Use an upright quaternion only when its components are readable and sane.
-- Otherwise an enclosing square is safer than guessing a quarter-turn.
local function Yaw(unit)
    if type(unit.GetOrientation) ~= "function" then return nil end
    local ok, orientation = pcall(unit.GetOrientation, unit)
    if not ok or not orientation then return nil end
    local q = orientation.value or orientation
    if not FiniteNumber(q.x) or not FiniteNumber(q.y)
        or not FiniteNumber(q.z) or not FiniteNumber(q.w) then return nil end
    local norm = q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w
    if math.abs(norm - 1) > 0.05 or math.abs(q.x) > 0.02
        or math.abs(q.z) > 0.02 then return nil end
    return 1 - 2 * (q.y * q.y + q.z * q.z),
        2 * (q.w * q.y + q.x * q.z)
end

local function ModelBounds(unit)
    local general = unit.tp.general
    local modelId = general and (general.modelTpId or general.tpId)
    if type(modelId) ~= "string" or modelId == "" then return nil end
    local cached = modelBoundsCache[modelId]
    if cached ~= nil then return cached or nil end
    local path = "Units/" .. modelId .. "/LOD0/" .. modelId .. "_lod0.sanmodel"
    local ok, status, center, size = pcall(Engine.GetMeshBounds, path)
    if ok and status == EngineErrorCode.Success and center and size
        and FiniteNumber(center.x) and FiniteNumber(center.z)
        and FiniteNumber(size.x) and FiniteNumber(size.z)
        and size.x > 0 and size.z > 0 then
        cached = {center = center, size = size}
    else
        cached = false
    end
    modelBoundsCache[modelId] = cached
    return cached or nil
end

local function BodyBounds(unit, skirt)
    local info = unit.tp.collisionInfo
    local model = ModelBounds(unit)
    local size = model and model.size or info and info.collisionSize
    if not size or not FiniteNumber(size.x) or not FiniteNumber(size.z)
        or size.x <= 0 or size.z <= 0 then
        -- Keep the visual available for older templates without collision data.
        size = {x = (skirt.x1 - skirt.x0 + 1) * 0.75,
                z = (skirt.z1 - skirt.z0 + 1) * 0.75}
    end
    local position = unit:GetPosition()
    local centerX, centerZ = position.x, position.z
    local cosYaw, sinYaw = Yaw(unit)
    local offset = model and model.center or info and info.centerOffset
    local offsetX = offset and FiniteNumber(offset.x) and offset.x or 0
    local offsetZ = offset and FiniteNumber(offset.z) and offset.z or 0
    local width, depth
    if cosYaw then
        width = math.abs(cosYaw) * size.x + math.abs(sinYaw) * size.z
        depth = math.abs(sinYaw) * size.x + math.abs(cosYaw) * size.z
        centerX = centerX + cosYaw * offsetX + sinYaw * offsetZ
        centerZ = centerZ - sinYaw * offsetX + cosYaw * offsetZ
    else
        local enclosing = math.max(size.x, size.z)
        local offsetRadius = math.sqrt(offsetX^2 + offsetZ^2)
        width, depth = enclosing + 2 * offsetRadius,
            enclosing + 2 * offsetRadius
    end
    local x0 = math.max(skirt.x0, centerX - width * 0.5)
    local x1 = math.min(skirt.x1 + 1, centerX + width * 0.5)
    local z0 = math.max(skirt.z0, centerZ - depth * 0.5)
    local z1 = math.min(skirt.z1 + 1, centerZ + depth * 0.5)
    if x0 > x1 or z0 > z1 then return nil end
    return {x0 = x0, x1 = x1, z0 = z0, z1 = z1}
end

local function PlanRoute(source, neighbor, style)
    local aBounds, bBounds = Bounds(source), Bounds(neighbor)
    if not aBounds or not bBounds then return nil, "missing skirt bounds" end
    local aBody = BodyBounds(source, aBounds)
    local bBody = BodyBounds(neighbor, bBounds)
    if not aBody or not bBody then return nil, "missing visible body bounds" end
    return Route.Plan(
        {id = UnitId(source), skirt = aBounds, body = aBody, position = source:GetPosition()},
        {id = UnitId(neighbor), skirt = bBounds, body = bBody, position = neighbor:GetPosition()}, style)
end

local function SameRoute(a, b)
    if not a or not b or a.renderMode ~= b.renderMode or a.variant ~= b.variant
        or #a.points ~= #b.points then return false end
    for index, point in ipairs(a.points) do
        local other = b.points[index]
        if math.abs(point.x - other.x) > 0.00001
            or math.abs(point.z - other.z) > 0.00001 then return false end
    end
    return true
end

local function DeleteVisual(link)
    for _, localId in ipairs(link.handles or {}) do
        if Engine.IsValidLocalID(localId) then
            Engine.DeletePrefabInstance(localId)
        end
    end
    link.handles = nil
    link.rotating = nil
    link.rotationTime = nil
end

local function CanShow(link, cameraHeight)
    local a, b = link.source, link.neighbor
    return not a.dead and not b.dead and not a.deleted and not b.deleted
        and a:IsCompleted() and b:IsCompleted()
        and a:IsIntelVisionVisible() and b:IsIntelVisionVisible()
        and cameraHeight - math.max(a:GetPosition().y, b:GetPosition().y) <= CAMERA_CUTOFF
end

local function WarnConnectorFailure(message)
    if connectorFailureWarned then return end
    connectorFailureWarned = true
    Warn("SCOM adjacency connector: " .. message)
end

local function YawRotation(angle)
    return EngineClasses.quaternion(EngineClasses.float4(0, math.sin(angle * 0.5), 0, math.cos(angle * 0.5)))
end

local function VisualPrefab(key, meshPath, materialPath)
    local cached = connectorPrefabs[key]
    if cached == false then error("unavailable prefab " .. key) end
    if cached then return cached end
    local head = EngineClasses.EntityTemplate(TemplateHeadEntityName,
        nil, EngineClasses.float3(0, 0, 0), 1, GetIdentityQuaternion(), false)
    local mesh = EngineClasses.MeshTemplate(TemplateHeadEntityName,
        meshPath, materialPath, EngineClasses.float3(1, 1, 1),
        ShadowCastingMode.Off, EngineClasses.float4(), EngineClasses.float4(), false)
    local template = EngineClasses.PrefabTemplate("SCOM_FAAdjacency_" .. key,
        EngineClasses.HierarchyTemplate({head}),
        EngineClasses.GlobalTemplate(), EngineClasses.LocalTemplate({mesh}))
    local prefab = {}
    local status = Engine.CreatePrefab(template, prefab)
    if status ~= EngineErrorCode.Success or prefab.Value == nil then
        connectorPrefabs[key] = false
        error("failed to create " .. key .. " prefab (status " .. tostring(status) .. ")")
    end
    connectorPrefabs[key] = prefab
    return prefab
end

local function CreateVisual(link)
    if link.failed then return end
    local handles, rotating = {}, {}
    local ok, failure = pcall(function()
        local style = VISUAL_STYLES[link.style]
        local route = link.route
        local positions = {}
        local waterStatus, waterHeight
        local hasWaterStatus, hasWater = Engine.HasWater()
        if hasWaterStatus == EngineErrorCode.Success and hasWater then
            waterStatus, waterHeight = Engine.GetWaterLevel()
        end
        for index, point in ipairs(route.points) do
            local status, height = Engine.SampleTerrainHeight(EngineClasses.float3(point.x, 0, point.z))
            if status ~= EngineErrorCode.Success or not FiniteNumber(height) then
                error("terrain sample failed (status " .. tostring(status) .. ")")
            end
            if waterStatus == EngineErrorCode.Success and FiniteNumber(waterHeight) then
                height = math.max(height, waterHeight)
            end
            positions[index] = EngineClasses.float3(point.x, height + 0.05, point.z)
        end
        local function Instantiate(prefab, position, scale, rotation)
            local status, localId = Engine.InstantiatePrefab(prefab, position, scale, rotation)
            if localId and Engine.IsValidLocalID(localId) then
                handles[#handles + 1] = localId
            else
                error("invalid local instance (status " .. tostring(status) .. ")")
            end
            if status ~= EngineErrorCode.Success then
                error("failed to instantiate visual (status " .. tostring(status) .. ")")
            end
            return localId
        end
        local nodePrefab = VisualPrefab(style.node .. "Node",
            ASSET_ROOT .. "Nodes/" .. style.node .. ".sanmodel", ASSET_ROOT .. "Nodes/" .. style.node .. ".sanmaterial")
        for index = 2, #positions - 1 do
            local current, following = positions[index], positions[index + 1]
            local dx, dz = current.x - following.x, current.z - following.z
            local length = math.sqrt(dx * dx + dz * dz)
            if length <= 0.000001 then error("degenerate node direction") end
            local rotation = Engine.QuaternionLookRotation(EngineClasses.float3(dx / length, 0, dz / length), UP)
            Instantiate(nodePrefab, current, EngineClasses.float3(1, 1, 1), rotation)
            if link.style == "seraphim" then
                local phase = route.phase + (index - 2) * math.pi * 2 / 3
                for _, layer in ipairs(SERAPHIM_AMBIENT) do
                    local ambientPrefab = VisualPrefab("Seraphim" .. layer.name,
                        ASSET_ROOT .. "Ambient.sanmodel",
                        ASSET_ROOT .. "Seraphim/" .. layer.name .. ".sanmaterial")
                    local localId = Instantiate(ambientPrefab,
                        EngineClasses.float3(current.x, current.y + layer.lift, current.z),
                        EngineClasses.float3(layer.size, 1, layer.size),
                        YawRotation(phase + Time * layer.rate))
                    if layer.rate ~= 0 then
                        rotating[#rotating + 1] = {id = localId, phase = phase, rate = layer.rate}
                    end
                end
            end
        end
        if style.beams then
            local beam = style.beams[route.variant]
            local beamPrefab = VisualPrefab(beam.material .. "Beam", ASSET_ROOT .. "Beam.sanmodel",
                ASSET_ROOT .. "Beams/" .. beam.material .. ".sanmaterial")
            for index = 1, #positions - 1 do
                local current, following = positions[index], positions[index + 1]
                local dx, dy, dz = following.x - current.x, following.y - current.y, following.z - current.z
                local length = math.sqrt(dx * dx + dy * dy + dz * dz)
                if length > 0.000001 then
                    local rotation = Engine.QuaternionLookRotation(
                        EngineClasses.float3(dx / length, dy / length, dz / length), UP)
                    Instantiate(beamPrefab, current, EngineClasses.float3(beam.width, 1, length), rotation)
                end
            end
        end
    end)
    if not ok then
        for _, localId in ipairs(handles) do
            if Engine.IsValidLocalID(localId) then Engine.DeletePrefabInstance(localId) end
        end
        link.failed = true
        WarnConnectorFailure(tostring(failure))
    else
        link.handles = handles
        link.rotating = rotating
        link.rotationTime = Time
        if adjacencyDiagnosticCount < 8 and not adjacencyDiagnostics["created:" .. link.style] then
            local first = handles[1]
            local positionStatus, position = Engine.GetLocalEntityWorldPosition(first)
            local enabledStatus, enabled = Engine.GetRendererEnabled(first)
            TraceAdjacencyPair("created", link, string.format(
                "handles=%d first=%s:%s nativePositionStatus=%s nativePosition=%s rendererStatus=%s enabled=%s cameraHeight=%.3f",
                #handles, tostring(first.index), tostring(first.version), tostring(positionStatus),
                position and DiagnosticPosition(position) or "nil", tostring(enabledStatus),
                tostring(enabled), Engine.GetCameraWorldSpaceHeight()))
        end
    end
end

local function Sync(link, cameraHeight)
    if CanShow(link, cameraHeight) then
        if not link.handles then CreateVisual(link) end
    else
        if adjacencyDiagnosticCount < 8 and not adjacencyDiagnostics["hidden:" .. link.style] then
            TraceAdjacencyPair("hidden", link,
                string.format("cameraHeight=%.3f cutoff=%d dead=%s,%s deleted=%s,%s",
                    cameraHeight, CAMERA_CUTOFF, tostring(link.source.dead), tostring(link.neighbor.dead),
                    tostring(link.source.deleted), tostring(link.neighbor.deleted)))
        end
        DeleteVisual(link)
    end
end

local function AddLink(source, neighbor)
    if not source or not neighbor or not source.id or not neighbor.id then return false end
    if source == neighbor or source.armyId ~= neighbor.armyId then return false end
    if not HasApplicableRow(source, neighbor) then return false end
    -- FA chooses the buff recipient's faction, including captured mixed-faction pairs.
    local recipient = RECIPIENTS[neighbor.tpId]
    local factionCode = recipient and string.sub(recipient[1], 2, 2)
    local style = ROUTE_STYLES[factionCode]
    if not style then return false end
    local key = Key(source, neighbor)
    local current = links[key]
    local route, reason = PlanRoute(source, neighbor, style)
    if not route then
        TraceAdjacencyPair("route-rejected", {source = source, neighbor = neighbor, style = style},
            "reason=" .. tostring(reason))
        if current then DeleteVisual(current); links[key] = nil end
        return false
    end
    if current and current.source == source and current.neighbor == neighbor
        and current.style == style
        and SameRoute(current.route, route) then return true end
    if current then DeleteVisual(current) end
    local link = {source = source, neighbor = neighbor, route = route,
                  style = style}
    links[key] = link
    Sync(link, Engine.GetCameraWorldSpaceHeight())
    return true
end

local function Update()
    local cameraHeight = Engine.GetCameraWorldSpaceHeight()
    for _, link in pairs(links) do
        Sync(link, cameraHeight)
        if link.rotating and link.rotationTime ~= Time then
            link.rotationTime = Time
            for _, layer in ipairs(link.rotating) do
                local ok, status = pcall(Engine.SetLocalEntityLocalRotation, layer.id,
                    YawRotation(layer.phase + Time * layer.rate))
                if not ok or status ~= EngineErrorCode.Success then
                    DeleteVisual(link)
                    link.failed = true
                    WarnConnectorFailure("failed to rotate ambient node: " .. tostring(status))
                    break
                end
            end
        end
    end
end

-- The stock client has no call site for ClientStructure:OnAdjacentTo. This
-- visual-only scanner infers touching same-army structures from their skirts.
-- It must run sparingly; the owning integration should call it about once/sec.
local function ReconcileFromUnits(units)
    local buckets, sources = {}, {}
    local total, known, eligible, sample = 0, 0, 0, nil
    for _, unit in pairs(units) do
        total = total + 1
        if RECIPIENTS[unit.tpId] then
            known = known + 1
            sample = sample or unit
        end
        if Eligible(unit) then
            eligible = eligible + 1
            local bounds = Bounds(unit)
            if bounds then
                if IsProvider(unit) then sources[#sources + 1] = unit end
                local x0 = math.floor((bounds.x0 - 1) / BUCKET_SIZE)
                local x1 = math.floor((bounds.x1 + 1) / BUCKET_SIZE)
                local z0 = math.floor((bounds.z0 - 1) / BUCKET_SIZE)
                local z1 = math.floor((bounds.z1 + 1) / BUCKET_SIZE)
                if (x1 - x0 + 1) * (z1 - z0 + 1) <= MAX_BUCKET_CELLS then
                    for x = x0, x1 do
                        for z = z0, z1 do
                            local key = x .. ":" .. z
                            buckets[key] = buckets[key] or {}
                            buckets[key][#buckets[key] + 1] = unit
                        end
                    end
                end
            end
        end
    end

    local desired = {}
    local touching, pairCount = false, 0
    table.sort(sources, function(a, b) return a.id.index < b.id.index end)
    for _, source in ipairs(sources) do
        local bounds = Bounds(source)
        local x0 = math.floor((bounds.x0 - 1) / BUCKET_SIZE)
        local x1 = math.floor((bounds.x1 + 1) / BUCKET_SIZE)
        local z0 = math.floor((bounds.z0 - 1) / BUCKET_SIZE)
        local z1 = math.floor((bounds.z1 + 1) / BUCKET_SIZE)
        if (x1 - x0 + 1) * (z1 - z0 + 1) <= MAX_BUCKET_CELLS then
            for x = x0, x1 do
                for z = z0, z1 do
                    for _, neighbor in ipairs(buckets[x .. ":" .. z] or {}) do
                        if neighbor ~= source and neighbor.armyId == source.armyId then
                            local key = Key(source, neighbor)
                            if not desired[key] then
                                local edge = SharedEdge(source, neighbor)
                                touching = touching or edge ~= nil
                                if edge and HasApplicableRow(source, neighbor) then
                                    desired[key] = {source, neighbor}
                                    pairCount = pairCount + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local stage = pairCount > 0 and "scan-pairs"
        or touching and "scan-contact-without-row"
        or #sources > 0 and "scan-providers-without-contact"
        or eligible > 0 and "scan-eligible-without-provider"
        or known > 0 and "scan-known-rejected" or "scan-no-known-units"
    if adjacencyDiagnosticCount < 8 and not adjacencyDiagnostics[stage] then
        adjacencyDiagnostics[stage] = true
        adjacencyDiagnosticCount = adjacencyDiagnosticCount + 1
        Engine.Warn(string.format(
            "[SCOM adjacency diagnostic] %s total=%d known=%d eligible=%d providers=%d touching=%s applicablePairs=%d sample={%s}",
            stage, total, known, eligible, #sources, tostring(touching), pairCount,
            DiagnosticUnit(sources[1] or sample)))
    end

    for key, link in pairs(links) do
        local pair = desired[key]
        if not pair or pair[1] ~= link.source or pair[2] ~= link.neighbor then
            DeleteVisual(link)
            links[key] = nil
        end
    end
    for _, pair in pairs(desired) do AddLink(pair[1], pair[2]) end
end

-- Keep the edge scan off the per-frame render path. Native client adjacency
-- callbacks currently have no Lua call site, so discovery is visual only.
local lastScanTime = -math.huge
local previousSCOMAdjacencyUpdateUnits = UpdateUnits
function UpdateUnits()
    local result = previousSCOMAdjacencyUpdateUnits()
    if Time - lastScanTime >= 1 then
        lastScanTime = Time
        ReconcileFromUnits(__Entities.Units)
    end
    return result
end

local previousSCOMAdjacencyRenderUpdateUnits = RenderUpdateUnits
function RenderUpdateUnits()
    local result = previousSCOMAdjacencyRenderUpdateUnits()
    Update()
    return result
end
