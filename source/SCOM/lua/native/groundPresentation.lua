-- Current native decal ABI. Contact geometry and lifetime stay with their owners.
local Hierarchy = Import('common/loading/hierarchyTemplateLoader.lua')

function CreateDecalPrefab(path)
    local data = Engine.GetFileContent(path)
    assert(data, 'SCOM decal definition unavailable: '..path)
    local definition = json.decode(data)
    local code, material = Engine.LoadAsset(definition.material)
    assert(code == EngineErrorCode.Success, 'SCOM decal material unavailable: '..definition.material)
    local decal = EngineClasses.DecalTemplate(TemplateHeadEntityName, material,
        EngineClasses.float3(1, 1, 1), definition.fadeFactor, true,
        definition.drawDistance, definition.fadeStart)
    local localTemplate = EngineClasses.LocalTemplate()
    localTemplate.decalTemplates = {decal}
    local template = EngineClasses.PrefabTemplate('SCOM_'..path,
        EngineClasses.HierarchyTemplate(Hierarchy.GetHierarchyEntities()),
        EngineClasses.GlobalTemplate(), localTemplate)
    local result, prefab = Engine.CreatePrefab(template)
    assert(result == EngineErrorCode.Success and prefab and prefab.Value ~= 65535,
        'SCOM decal prefab unavailable: '..path)
    return prefab
end

-- These legacy placeholders have no media in the current bank. Working and
-- custom event names remain untouched, including all existing engine/beam loops.
local ActiveFallback = {
    aclu2520 = 'aclu2310', aelu2520 = 'aelu2310', aglu2520 = 'aglu2310',
    aclu2220 = 'aclu2310', aclu2620 = 'aclu2330',
}

-- Audited current roster: private source definitions lacking every unit-level
-- audio field. Keep an explicit set so newly authored/custom units choose theirs.
local MissingDeath = {
    uca5001 = 'acod5110',
    ucs5001 = 'acod2110',
    ucs5002 = 'acod2110',
    ucs5003 = 'acod2110',
    ucs5004 = 'acod2110',
    ucs5005 = 'acod2110',
    ucs5006 = 'acod2120',
    ucs5007 = 'acod2110',
    ucs5008 = 'acod2110',
    uea5009 = 'aeod5110',
    uel5002 = 'aeod1110',
    uel5003 = 'aeod1110',
    uel5004 = 'aeod1110',
    uel5009 = 'aeod1110',
    ues1512 = 'aeod2110',
    ues1513 = 'aeod2120',
    ues2513 = 'aeod2120',
    ues3102 = 'aeod2110',
    ues3513 = 'aeod2120',
    ues5001 = 'aeod2120',
    ues5002 = 'aeod2120',
    ues5003 = 'aeod2120',
    ues5004 = 'aeod2120',
    ues5005 = 'aeod2120',
    ues5006 = 'aeod2120',
    ues5007 = 'aeod2110',
    ues5008 = 'aeod2120',
    ues5009 = 'aeod2110',
    ues5010 = 'aeod2110',
    ues5011 = 'aeod2110',
    ues5012 = 'aeod2120',
    ues5013 = 'aeod2120',
    ues5014 = 'aeod2120',
    ues5015 = 'aeod2110',
    ues5016 = 'aeod2110',
    ues5017 = 'aeod2110',
    ues5018 = 'aeod2110',
    ues5019 = 'aeod2120',
    ues5020 = 'aeod2110',
    ues5021 = 'aeod2110',
    ues5022 = 'aeod2110',
    ues5023 = 'aeod2110',
    ues5024 = 'aeod2110',
    ues5025 = 'aeod2110',
    ues5026 = 'aeod2110',
    ues5027 = 'aeod2110',
    ues5028 = 'aeod2110',
    ues5029 = 'aeod2120',
    ues5030 = 'aeod2110',
    ues5031 = 'aeod2120',
    ues5032 = 'aeod2110',
    ues5033 = 'aeod2120',
    ues5034 = 'aeod2120',
    ues5035 = 'aeod2110',
    ues5036 = 'aeod2110',
    ues5037 = 'aeod2110',
    ues5038 = 'aeod2120',
    ues5039 = 'aeod2110',
    ues5040 = 'aeod2110',
    ues5042 = 'aeod2110',
    ues5043 = 'aeod2120',
    ues5044 = 'aeod2110',
    ues5045 = 'aeod2110',
    ues5046 = 'aeod2110',
    ues5049 = 'aeod2110',
    ues5050 = 'aeod2110',
    ues5051 = 'aeod2110',
    ues5052 = 'aeod2110',
    ues5053 = 'aeod2110',
    ues5054 = 'aeod2110',
    ues5055 = 'aeod2110',
    ues5056 = 'aeod2110',
    ues5057 = 'aeod2110',
    ues5058 = 'aeod2110',
    ues5059 = 'aeod2110',
    ues5060 = 'aeod2110',
    ues5061 = 'aeod2110',
    ues5062 = 'aeod2110',
    ues5063 = 'aeod2110',
    ues5064 = 'aeod2110',
    ues5065 = 'aeod2110',
    ues5066 = 'aeod2110',
    ues5067 = 'aeod2110',
    ues5068 = 'aeod2110',
    ues5069 = 'aeod2110',
    ues5070 = 'aeod2110',
    ues5071 = 'aeod2110',
    ues5072 = 'aeod2110',
    ues5073 = 'aeod2110',
    ues5074 = 'aeod2110',
    ues5075 = 'aeod2110',
    ues5076 = 'aeod2110',
    ues5077 = 'aeod2110',
    ues5078 = 'aeod2110',
    ues5079 = 'aeod2110',
    ues5080 = 'aeod2110',
    ues5082 = 'aeod2110',
    ues5085 = 'aeod2110',
    ues5086 = 'aeod2110',
    ues5087 = 'aeod2110',
    ues5088 = 'aeod2110',
    ues5090 = 'aeod2110',
    ues5093 = 'aeod2110',
    ues5094 = 'aeod2110',
    ugl5006 = 'agod1110',
    ugs1512 = 'agod2110',
    ugs1513 = 'agod2120',
    ugs2513 = 'agod2120',
    ugs3513 = 'agod2120',
    ugs4902 = 'agod2110',
    ugs4903 = 'agod2110',
    ugs4904 = 'agod2110',
    ugs4905 = 'agod2110',
    ugs5001 = 'agod2110',
    ugs5002 = 'agod2120',
    ugs5003 = 'agod2110',
    ugs5004 = 'agod2110',
    ugs5005 = 'agod2110',
    ugs5006 = 'agod2110',
    ugs5007 = 'agod2110',
    ugs5008 = 'agod2110',
    ugs5009 = 'agod2110',
    ugs5010 = 'agod2110',
    ugs5011 = 'agod2110',
    ugs5012 = 'agod2110',
    ugs5013 = 'agod2110',
    ugs5014 = 'agod2110',
    ugs5015 = 'agod2110',
    ugs5016 = 'agod2110',
    ugs5017 = 'agod2110',
    ugs5018 = 'agod2110',
    ugs5019 = 'agod2110',
    ugs5020 = 'agod2110',
    ugs5021 = 'agod2110',
    ugs5022 = 'agod2120',
    ugs5023 = 'agod2110',
    ugs5024 = 'agod2120',
    ugs5025 = 'agod2110',
    ugs5026 = 'agod2110',
    ugs5027 = 'agod2110',
    ugs5028 = 'agod2120',
    ugs5029 = 'agod2110',
    ugs5030 = 'agod2110',
    ugs5031 = 'agod2110',
    ugs5032 = 'agod2110',
    ugs5033 = 'agod2110',
    ugs5034 = 'agod2110',
    ugs5035 = 'agod2110',
    ugs5036 = 'agod2110',
    ugs5037 = 'agod2110',
    ugs5038 = 'agod2110',
    ugs5039 = 'agod2110',
    ugs5040 = 'agod2110',
    ugs5041 = 'agod2110',
    ugs5042 = 'agod2110',
    ugs5043 = 'agod2110',
    ugs5044 = 'agod2110',
    ugs5045 = 'agod2110',
    ugs5046 = 'agod2110',
    ugs5047 = 'agod2110',
    ugs5048 = 'agod2110',
    ugs5049 = 'agod2110',
    ugs5050 = 'agod2110',
    ugs5051 = 'agod2110',
    ugs5052 = 'agod2110',
    ugs5053 = 'agod2110',
    ugs5054 = 'agod2110',
    ugs5055 = 'agod2110',
    ugs5056 = 'agod2110',
    ugs5057 = 'agod2110',
    ugs5058 = 'agod2110',
    ugs5059 = 'agod2110',
    ugs5060 = 'agod2110',
    ugs5061 = 'agod2110',
    ugs5062 = 'agod2110',
    ugs5063 = 'agod2110',
    ugs5064 = 'agod2110',
    ugs5065 = 'agod2110',
    ugs5066 = 'agod2110',
    ugs5067 = 'agod2110',
    ugs5068 = 'agod2110',
    uss4102 = 'acod2110',
    uss5002 = 'acod2110',
    uss5003 = 'acod2110',
    uss5004 = 'acod2110',
    uss5005 = 'acod2110',
    uss5006 = 'acod2110',
    uss5007 = 'acod2110',
    uss5008 = 'acod2110',
    uss5009 = 'acod2110',
    uss5010 = 'acod2110',
    uss5011 = 'acod2110',
    uss5012 = 'acod2110',
    uss5013 = 'acod2110',
    uss5014 = 'acod2110',
    uss5015 = 'acod2110',
    uss5016 = 'acod2110',
    uss5017 = 'acod2110',
    uss5018 = 'acod2110',
    uss5019 = 'acod2110',
    uss5020 = 'acod2110',
    uss5021 = 'acod2110',
    uss5022 = 'acod2110',
    uss5023 = 'acod2110',
}
local MissingMotor = {
    uel5002 = 'aelu1111', -- Hovering civilian technology transport.
    uel5003 = 'aelu1110', uel5004 = 'aelu1110', uel5009 = 'aelu1110',
    ues5007 = 'aelu1110', ugs5001 = 'aglu1110', ugl5006 = 'aglu1310',
}
local MissingFactoryActive = {
    ues1512 = 'aelu2310', ues1513 = 'aelu2310', ues2513 = 'aelu2310', ues3513 = 'aelu2310',
    ugs1512 = 'aglu2310', ugs1513 = 'aglu2310', ugs2513 = 'aglu2310', ugs3513 = 'aglu2310',
}

-- Missing measured wheel contacts: these civilian bodies share the same
-- packed mesh. The ten tire bottoms, not chassis bounds, define the trails.
local CivilianWheels = {}
for _, x in ipairs({-0.184553, 0.183869}) do
    for _, z in ipairs({-0.418750, -0.247815, 0.095250, 0.267235, 0.438090}) do
        CivilianWheels[#CivilianWheels + 1] = {pattern = 'wheel', width = 0.069913,
            positionOffset = {x = x, y = 0.000943, z = z}}
    end
end
-- The six real toe tips were sampled through the embedded AnimWalk clip,
-- including wrap. Each crosses its measured plant plane once per 4-second loop.
local SalemFeet = {{boneName = 'Leg_L03_B02', contactOffset = {x = -1.9887394561472982e-07, y = -0.15369082146185792, z = 0.7061204394044088}, forward = {x = -5.551115123125783e-17, y = 0.9561634087261915, z = 0.29283363162914067}, right = {x = 0.9989978695199845, y = 0.013106576142690285, z = -0.042795728248848364}, width = 0.11729557158471426, length = 0.04481287124078559, minimumHeight = -0.025104022694903062, plantHeight = 0.03489597730509694, liftHeight = 0.16670896434049856, decalPath = 'Environment/SCOM/Footsteps/contact.sandecal'},
    {boneName = 'Leg_L02_B02', contactOffset = {x = 5.7873002018992436e-08, y = -0.15369095016854534, z = 0.706120315827296}, forward = {x = 5.551115123125783e-17, y = 0.9231467281402654, z = 0.3844478096230024}, right = {x = 0.9980984775940163, y = 0.023697174080165556, z = -0.05690231071865709}, width = 0.11857070935149505, length = 0.0433838720707137, minimumHeight = -0.033868423540160154, plantHeight = 0.02613157645983985, liftHeight = 0.16315700075142808, decalPath = 'Environment/SCOM/Footsteps/contact.sandecal'},
    {boneName = 'Leg_L01_B02', contactOffset = {x = -1.1565648837818254e-07, y = -0.15369074568942453, z = 0.7061204297640833}, forward = {x = -8.326672684688674e-17, y = 0.7614564420077028, z = 0.6482160804276382}, right = {x = 0.9984106919545989, y = 0.036531391388602494, z = -0.042913257088600276}, width = 0.11844792838473273, length = 0.03617053313893992, minimumHeight = -0.022883658359760785, plantHeight = 0.03711634164023922, liftHeight = 0.16754513095730705, decalPath = 'Environment/SCOM/Footsteps/contact.sandecal'},
    {boneName = 'Leg_R03_B02', contactOffset = {x = -1.6600379816172015e-07, y = -0.15369094836873576, z = 0.7061202868677816}, forward = {x = 5.551115123125783e-17, y = 0.9752526879855745, z = 0.22109318075624002}, right = {x = 0.951129524125655, y = -0.06827185167962671, z = 0.3011504318521556}, width = 0.132320302787581, length = 0.04561724032274461, minimumHeight = -0.03614176943144529, plantHeight = 0.02385823056855471, liftHeight = 0.1540652197443582, decalPath = 'Environment/SCOM/Footsteps/contact.sandecal'},
    {boneName = 'Leg_R02_B02', contactOffset = {x = -1.7768255363603517e-07, y = -0.15369052992304827, z = 0.7061204194888537}, forward = {x = 0.0, y = 0.8616061816012974, z = 0.507577371271052}, right = {x = 0.899662876386183, y = 0.22160081000194531, z = -0.37616457815565346}, width = 0.13824945986280057, length = 0.04066485617736748, minimumHeight = -0.025114677867817826, plantHeight = 0.03488532213218218, liftHeight = 0.16678403600123343, decalPath = 'Environment/SCOM/Footsteps/contact.sandecal'},
    {boneName = 'Leg_R01_B02', contactOffset = {x = -2.2300561896772384e-08, y = -0.15369091921870182, z = 0.7061201528378629}, forward = {x = 5.551115123125783e-17, y = 0.9989203811694527, z = 0.046455054453474254}, right = {x = 0.9287620087884779, y = 0.01721980096360759, z = -0.3702763960691594}, width = 0.13371147465659322, length = 0.05262534300749411, minimumHeight = -0.025301135910972473, plantHeight = 0.03469886408902753, liftHeight = 0.16901702864232943, decalPath = 'Environment/SCOM/Footsteps/contact.sandecal'}}

local function PrepareGround(tp)
    local id = tp.general.tpId
    if id ~= 'ues5007' and id ~= 'ugs5001' and id ~= 'ugn2001' then return end
    tp.additions = tp.additions or {}
    if id == 'ugn2001' then
        tp.additions.scoGroundFootfalls = tp.additions.scoGroundFootfalls or {
            unit = id, modelPath = 'Units/ugn2001/LOD0/ugn2001_lod0.sanmodel',
            groundOffset = 0, referenceAltitude = 'GroundOrWater', landOnly = true, feet = SalemFeet}
    else
        tp.additions.scoGroundTracks = tp.additions.scoGroundTracks or {
            unit = id, modelPath = 'Units/'..id..'/LOD0/'..id..'_lod0.sanmodel',
            boneName = 'Root', trails = CivilianWheels}
    end
end

function IsDryLand(unit)
    local waterCode, hasWater = Engine.HasWater()
    if waterCode ~= EngineErrorCode.Success then return false end
    if not hasWater then return true end
    local levelCode, level = Engine.GetWaterLevel()
    local positionCode, position = Engine.GetLocalEntityWorldPosition(unit.localId)
    if levelCode ~= EngineErrorCode.Success or positionCode ~= EngineErrorCode.Success then return false end
    local terrainCode, terrain = Engine.SampleTerrainHeight(position)
    if terrainCode ~= EngineErrorCode.Success then return false end
    -- Match the owning Salem medium probe, including an elevated dry hull.
    return position.y > level + 0.05 or terrain >= level - 0.01
end

function Prepare(tp)
    PrepareGround(tp)
    local id = tp.general.tpId
    if MissingDeath[id] then
        tp.audio = tp.audio or {}
        if not tp.audio.onDestroyed then
            tp.audio.onDestroyed = {name = MissingDeath[id], looping = false}
        end
        if MissingMotor[id] and not tp.audio.engine then
            tp.audio.engine = {name = MissingMotor[id], looping = true}
        end
        if MissingFactoryActive[id] and not tp.audio.active then
            tp.audio.active = {name = MissingFactoryActive[id], looping = true}
        end
    end
    local audio = tp.audio
    if audio then
        local active = audio.active
        if active and ActiveFallback[active.name] then
            active.name = ActiveFallback[active.name]
        end
        if tp.general.tpId == 'ucl9505' and audio.onDestroyed
            and audio.onDestroyed.name == 'acod1042' then
            audio.onDestroyed.name = 'acod1142'
        end
    end
    for _, weapon in ipairs(tp.weapons or {}) do
        local firing = weapon.audio and weapon.audio.onFire
        if tp.general.tpId == 'ucl9505' and firing
            and firing.name == 'chosen_cannon_plasma_fire_small' then
            firing.name, firing.looping = 'acom1112', false
        elseif tp.general.tpId == 'ucl4004' and weapon.projectileTemplate == 'pad171'
            and (not firing or not firing.name) then
            weapon.audio = weapon.audio or {}
            weapon.audio.onFire = {name = 'acom2143', looping = false}
        end
    end
end

return {CreateDecalPrefab = CreateDecalPrefab, Prepare = Prepare, IsDryLand = IsDryLand}
