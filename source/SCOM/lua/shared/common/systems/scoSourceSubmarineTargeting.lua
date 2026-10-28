-- Source submarine weapon layers and manual dive state.
local M = {}
local sources = {
    uen1002 = 'UES0203', uen3004 = 'UES0304', uen4001 = 'UES0401',
    ugn1002 = 'URS0203', ugn3004 = 'URS0304', ugn5001 = 'XRS0204',
}
local manualDeckGuns = {
    uen1002 = {
        class = 'EDANavalUnit', label = 'PlasmaGun',
        projectile = 'psf0157',
        sha = 'cd2fa28e058af6a39e8ca4ef7e440b5c655fad3f899cf06cea0eb20d70586103',
    },
    ugn1002 = {
        class = 'GuardNavalUnit', label = 'MainGun',
        projectile = 'psf0017',
        sha = 'af6d6d5a993f916fce71159d06b894d8e1269fe8621913b4064fc668f402ac6b',
    },
}
-- Existing ports prove exact source weapon and projectile identities.
-- Each audited firing layer permits all three source water target domains.
local torpedoes = {
    uca2301 = {
        {label="Bomb", projectile="psf0052", index=1,
            sha="900b6cbe51295692f2864998328b78784a784e2fed05168ee93115a147e50b39"},
    },
    uca2701 = {
        {label="Bomb", projectile="psf0055", index=1,
            sha="cc6baf4b45f59f320ad1c5d98ceaefc5d680385097756209d1213a03362acbb8"},
    },
    uca4011 = {
        {label="DepthCharge01", projectile="psf0051", index=6,
            sha="8b9f2200f7ee4eb51d412c316216d4d340b0e41e0392b91af53ca523e9e12736"},
        {label="DepthCharge02", projectile="psf0051", index=7,
            sha="8b9f2200f7ee4eb51d412c316216d4d340b0e41e0392b91af53ca523e9e12736"},
    },
    ucl4003 = {
        {label="Torpedo01", projectile="psf0053", index=2,
            sha="16ff14ee2eb91421198b500169247792ebd48a503ce40357baf915d35bc9934b"},
    },
    ucs1301 = {
        {label="Turret01", projectile="psf0053", index=1,
            sha="16ff14ee2eb91421198b500169247792ebd48a503ce40357baf915d35bc9934b"},
    },
    ucs1801 = {
        {label="Torpedo01", projectile="psf0053", index=1,
            sha="16ff14ee2eb91421198b500169247792ebd48a503ce40357baf915d35bc9934b"},
    },
    ucs1803 = {
        {label="Torpedo1", projectile="psf0053", index=3,
            sha="16ff14ee2eb91421198b500169247792ebd48a503ce40357baf915d35bc9934b"},
    },
    ucs2301 = {
        {label="Turret01", projectile="psf0054", index=1,
            sha="4e0fa8b97f5b156fbf6b14556351d3e57a9eef984371cfe2653f314ea51d2702"},
    },
    ucs2501 = {
        {label="Torpedo01", projectile="psf0053", index=1,
            sha="16ff14ee2eb91421198b500169247792ebd48a503ce40357baf915d35bc9934b"},
    },
    uen1002 = {
        {label="Torpedo01", projectile="psf0027", index=1,
            sha="52b4e6515073cf6952c5c24c5f118e899bca346163dbde448aa1232090524b56"},
    },
    uen2001 = {
        {label="Torpedo01", projectile="psf0148", index=4,
            sha="d8cb5a9770d37bb15ccbfd71b12a682760433f1d44da21740759b882a6a26bf7"},
    },
    uen3005 = {
        {label="Torpedo01", projectile="psf0149", index=1,
            sha="787fda8530cbcc36e4077cd1f065f5ca11cf18312a1c327f5b1c8fdcff66d1c6"},
    },
    uen4001 = {
        {label="Torpedo01", projectile="psf0027", index=1,
            sha="52b4e6515073cf6952c5c24c5f118e899bca346163dbde448aa1232090524b56"},
    },
    ugl2002 = {
        {label="Torpedo", projectile="psf0084", index=3,
            sha="62fa521286123ca9dc8f8da1a9b7bf60cdcb15ee421b5ca05880c2c48d9045a8"},
    },
    ugl3001 = {
        {label="Torpedo", projectile="psf0012", index=2,
            sha="90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f"},
    },
    ugl4001 = {
        {label="Torpedo", projectile="psf0084", index=6,
            sha="62fa521286123ca9dc8f8da1a9b7bf60cdcb15ee421b5ca05880c2c48d9045a8"},
    },
    ugn1002 = {
        {label="Torpedo01", projectile="psf0012", index=1,
            sha="90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f"},
    },
    ugn2001 = {
        {label="TorpedoL", projectile="psf0085", index=3,
            sha="057ed883894736a59210e14e3832b38265a99407c7a91a82a0f023ecdac917bd"},
    },
    ugn3001 = {
        {label="Torpedo01", projectile="psf0012", index=5,
            sha="90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f"},
    },
    ugn3004 = {
        {label="Torpedo01", projectile="psf0012", index=2,
            sha="90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f"},
    },
    usa2301 = {
        {label="Bomb", projectile="psf0116", index=1,
            sha="ba28e90078408797f6ad6b35bbbeaaa45234665cc52350d5fcad7348d0f1b5c7"},
    },
    usl3001 = {
        {label="Torpedo01", projectile="psf0118", index=2,
            sha="200b882a8eb86a1201167c89f1c9b8481bd290fcf734e738c7b7e4c2ba843730"},
    },
    usn1002 = {
        {label="Torpedo01", projectile="psf0119", index=1,
            sha="ffc6e98ab95647265f33b2790a67a486d1edd8d492a7826034697456600f270e"},
    },
    usn2001 = {
        {label="Torpedo1", projectile="psf0115", index=3,
            sha="9033bef38336f557add4ad4480857ce87c02e3020f57f83369d0131098003009"},
    },
    usn3004 = {
        {label="TorpedoFront", projectile="psf0121", index=1,
            sha="e37503af7db8fe36a1815d059f994533af6a51ecbd29679e737a18288ff125d9"},
    },
    uss1301 = {
        {label="Turret01", projectile="psf0120", index=1,
            sha="66ab89d85182d90bd64e9c47796a38e6fd73d2d798ce9137723137c37a99c207"},
    },
    uss2301 = {
        {label="TorpedoTurrets", projectile="psf0117", index=1,
            sha="5ba9eecbde5e838b724cabd2c0cb774e554b853355722c20bba7fbb6a489de42"},
    },
}

local function IsSourceSubmarine(tp)
    local id = tp and tp.general and tp.general.tpId
    local sourceId = id and sources[id]
    if not sourceId then return false end
    local source = tp.additions and tp.additions.faSourceContract
    assert(source and source.sourceId == sourceId,
        'Source submarine identity drift for ' .. id)
    assert(tp.movement and tp.movement.type == 'UnderWater',
        'Source submarine movement drift for ' .. id)
    return true
end

local function Vector(value, positive)
    local result = {}
    for _, axis in ipairs({'x', 'y', 'z'}) do
        local number = value and value[axis]
        assert(type(number) == 'number' and number == number
            and math.abs(number) < math.huge and (not positive or number > 0),
            'Invalid source submarine hull bounds')
        result[axis] = number
    end
    return result
end

local function PrepareSeraphimAttackSubmarine(tp)
    if not tp.general or tp.general.tpId ~= 'usn1002' then return end
    local hatch = tp.additions and tp.additions.faSubmarineHatch
    local class = tp.general.class
    local movement = tp.movement
    local gun = tp.weapons and tp.weapons[2]
    local identity = gun and gun.scoFaProjectileIdentity
    assert(hatch and hatch.mapping == 'XSS0203 -> usn1002'
        and hatch.gatedWeaponIndex == 3
        and class and class[1] == 'unitsDefaultSeraphim'
        and class[2] == 'SeraphimNavalUnit'
        and movement and movement.type == 'WaterSurface'
        and movement.preferredAltitude == 0
        and movement.referenceAltitude == 'GroundOrWater'
        and movement.collisionMaskDefault[1] == 'Sea'
        and movement.collisionMaskSpawn[1] == 'Sea'
        and #tp.weapons == 3 and identity
        and identity.sourceIndex == 3
        and identity.sourceLabel == 'Cannon'
        and identity.sourceBlueprintSha256
            == '70b19395fa61c22d82efdd55c5bc9817c41feafe6b808207db830f3f2ffca598'
        and gun.projectileTemplate == 'psf0130'
        and gun.scoFaAnimationClosureSurfaceWeapon == true
        and gun.muzzles and gun.muzzles.Turret_Muzzle,
        'Seraphim attack submarine contract drift')
    -- The Seraphim subclass retains the source hatch's animation owner.
    class[2] = 'SeraphimSubmarineUnit'
    hatch.gatedWeaponIndex = 2
    tp.general.toggles = tp.general.toggles or {}
    assert(tp.general.toggles.Submerge == nil,
        'Seraphim attack submarine toggle drift')
    tp.general.toggles.Submerge = false
    movement.type = 'UnderWater'
    movement.collisionMaskDefault = {'Submarine'}
    movement.collisionMaskSpawn = {'Sea'}
    movement.submergedAltitude = -1.5
    movement.altitudeChangeRate = 1.67
    local collision = tp.collisionInfo
    local offset = Vector(collision and collision.centerOffset, false)
    offset.y = 0.62
    local size = Vector(collision and collision.collisionSize, true)
    size.y = 0.5
    movement.hullWaterSensor = {size = size, offset = offset}
    gun.layerWeaponLimits = {'WaterSurface'}
    gun.waterSensor = {
        bone = 'Turret_Muzzle',
        size = {x = 0.25, y = 0.25, z = 0.25},
        offset = {x = 0, y = 0, z = 0},
    }
end

local function PrepareSeraphimSubmersibleDestroyer(tp)
    if not tp.general or tp.general.tpId ~= 'usn2001' then return end
    local class = tp.general.class
    local movement = tp.movement
    local tags = {}
    for _, tag in ipairs(tp.tags or {}) do tags[tag] = true end
    assert(class and class[1] == 'unitsDefaultSeraphim'
        and class[2] == 'SeraphimNavalUnit'
        and tags.SCFA_SUBMERSIBLE and tags.DESTROYER
        and movement and movement.type == 'WaterSurface'
        and movement.preferredAltitude == 0
        and movement.referenceAltitude == 'GroundOrWater'
        and movement.collisionMaskDefault[1] == 'Sea'
        and movement.collisionMaskSpawn[1] == 'Sea'
        and #tp.weapons >= 3,
        'Seraphim submersible destroyer contract drift')
    local guns = {
        {weapon = tp.weapons[1], bone = 'Front_Turret_Muzzle'},
        {weapon = tp.weapons[2], bone = 'Back_Turret_Muzzle'},
    }
    for _, spec in ipairs(guns) do
        local gun = spec.weapon
        assert(gun and gun.projectileTemplate == 'pbf0009'
            and gun.muzzles and gun.muzzles[spec.bone]
            and gun.layerWeaponLimits and #gun.layerWeaponLimits == 1
            and gun.layerWeaponLimits[1] == 'WaterSurface',
            'Seraphim destroyer deck gun drift: ' .. spec.bone)
        gun.waterSensor = {
            bone = spec.bone,
            size = {x = 0.25, y = 0.25, z = 0.25},
            offset = {x = 0, y = 0, z = 0},
        }
    end
    class[2] = 'SeraphimSubmarineUnit'
    tp.general.toggles = tp.general.toggles or {}
    assert(tp.general.toggles.Submerge == nil,
        'Seraphim destroyer toggle drift')
    tp.general.toggles.Submerge = false
    movement.type = 'UnderWater'
    movement.collisionMaskDefault = {'Submarine'}
    movement.collisionMaskSpawn = {'Sea'}
    movement.submergedAltitude = -2
    movement.altitudeChangeRate = 1.67
    local collision = tp.collisionInfo
    local offset = Vector(collision and collision.centerOffset, false)
    offset.y = 0.62
    local size = Vector(collision and collision.collisionSize, true)
    size.y = 0.5
    movement.hullWaterSensor = {size = size, offset = offset}
end

function M.PrepareTemplate(tp)
    local id = tp and tp.general and tp.general.tpId
    for _, expected in ipairs(id and torpedoes[id] or {}) do
        local found
        for _, weapon in ipairs(tp.weapons or {}) do
            local identity = weapon.scoFaProjectileIdentity
            if identity and identity.sourceLabel == expected.label then
                assert(not found and identity.sourceIndex == expected.index
                    and identity.sourceBlueprintSha256 == expected.sha
                    and weapon.projectileTemplate == expected.projectile,
                    'Source torpedo identity drift for ' .. id)
                found = weapon
            end
        end
        assert(found, 'Missing source torpedo for ' .. id)
        found.layerTargetLimits = {'WaterSurface', 'Water', 'Seabed'}
    end
    PrepareSeraphimAttackSubmarine(tp)
    PrepareSeraphimSubmersibleDestroyer(tp)
    if not IsSourceSubmarine(tp) then return end
    -- The native probe is a root-owned box, independent of collisionInfo after
    -- creation. Copy the final collision bounds so neither table aliases it.
    local collision = tp.collisionInfo
    tp.movement.hullWaterSensor = {
        size = Vector(collision and collision.collisionSize, true),
        offset = Vector(collision and collision.centerOffset, false),
    }
    local deckGun = manualDeckGuns[id]
    if deckGun then
        local class = assert(tp.general.class)
        local movement = tp.movement
        local toggles = tp.general.toggles or {}
        assert(class[2] == deckGun.class
            and movement.preferredAltitude == -1.5
            and movement.referenceAltitude == 'Water'
            and movement.collisionMaskDefault[1] == 'Submarine'
            and movement.collisionMaskSpawn[1] == 'Submarine'
            and toggles.Submerge == nil
            and #tp.weapons == 2,
            'Manual submarine movement contract drift for ' .. id)
        local gun = tp.weapons[2]
        local identity = gun.scoFaProjectileIdentity
        assert(identity and identity.sourceIndex == 2
            and identity.sourceLabel == deckGun.label
            and identity.sourceBlueprintSha256 == deckGun.sha
            and gun.projectileTemplate == deckGun.projectile
            and gun.muzzles and gun.muzzles.Turret_Muzzle,
            'Source deck gun identity drift for ' .. id)
        -- Class tables are already indexed by the template loader. Mutate the
        -- existing table so both host and client resolve the native dive class.
        class[1], class[2] = 'unitsDefault', 'SubmarineUnit'
        toggles.Submerge = true
        tp.general.toggles = toggles
        movement.submergedAltitude = movement.preferredAltitude
        -- A root-centred box stays wet when the ship reaches the water line.
        -- Match the native surfaced-submarine probe's dry vertical window.
        assert(tp.movement.hullWaterSensor.size.y == 0.5
            and tp.movement.hullWaterSensor.offset.y == 0,
            'Source deck-gun submarine hull probe drift for ' .. id)
        tp.movement.hullWaterSensor.offset.y = 0.62
        gun.layerWeaponLimits = {'WaterSurface'}
        gun.waterSensor = {
            bone = 'Turret_Muzzle',
            size = {x = 0.25, y = 0.25, z = 0.25},
            offset = {x = 0, y = 0, z = 0},
        }
    end
    if id == 'uen4001' then
        -- Atlantis's torpedoes fire at both depths; its four source AA racks
        -- fire only after the hull and each missile muzzle have cleared water.
        assert(#tp.weapons == 5, 'Atlantis weapon inventory drift')
        for index = 2, 5 do
            local weapon = tp.weapons[index]
            local identity = weapon.scoFaProjectileIdentity
            local rack = index - 1
            local bone = 'Upgrade_Weapon_Point0' .. rack
            local label = 'MissileRack0' .. math.min(rack, 3)
            assert(identity and identity.sourceIndex == index
                and identity.sourceLabel == label
                and identity.sourceBlueprintSha256 == '8b0ec153e08f756d7623a671a2dcc2852bd3b54ca1e2a23af4cf83e81f5d6fc9'
                and weapon.projectileTemplate == 'psf0024'
                and weapon.muzzles and weapon.muzzles[bone],
                'Atlantis anti-air identity drift at weapon ' .. index)
            weapon.layerWeaponLimits = {'WaterSurface'}
            weapon.waterSensor = {
                bone = bone,
                size = {x = 0.25, y = 0.25, z = 0.25},
                offset = {x = 0, y = 0, z = 0},
            }
        end
    end
end

function M.InstallNavalUnit(HostNavalUnit)
    if rawget(HostNavalUnit, 'scoSourceSubmarineTargetingInstalled') then return end
    HostNavalUnit.scoSourceSubmarineTargetingInstalled = true
    local previous = HostNavalUnit.OnHullCrossedWaterline
    local layers = Import('common/layers.lua').TargetingLayer
    function HostNavalUnit:OnHullCrossedWaterline(isSubmerged)
        if IsSourceSubmarine(self.tp) then
            self:SetTargetingLayer(isSubmerged and layers.Water or layers.WaterSurface)
            return
        end
        return previous(self, isSubmerged)
    end
    -- The imported T1 subs already spawn at cruise depth. The stock submarine
    -- constructor assumes a surfaced spawn, so synchronize its state before
    -- the newly created unit can receive a command or acquire a target.
    local HostSubmarineUnit = assert(getfenv(2).HostSubmarineUnit,
        'Native submarine class unavailable at SCOM installation point')
    local previousSubmarineInit = HostSubmarineUnit.__init
    function HostSubmarineUnit:__init(id, army, template, progress, builder)
        previousSubmarineInit(self, id, army, template, progress, builder)
        local tpId = template and template.general and template.general.tpId
        if not manualDeckGuns[tpId] then return end
        assert(template.general.class[2] == 'SubmarineUnit'
            and template.general.toggles.Submerge == true
            and template.movement.submergedAltitude == -1.5,
            'Manual submarine boot state drift for ' .. tpId)
        self.isSurfaced = false
        self.diveBehaviorIsActive = false
        self.surfaceBehaviorIsActive = false
        self:SetSubmergedLayers()
        self:SetTargetingLayer(layers.Water)
        Engine.SetMovementReferenceAltitude(self.id, ReferenceAltitude.Water)
        Engine.SetMovementPreferredAltitude(self.id, template.movement.submergedAltitude)
    end
end

local environment = getfenv(1)
for name, value in pairs(M) do environment[name] = value end
return M
