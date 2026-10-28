-- Persistent spatial variation, independent of build priorities and unit stats.
-- Integer arithmetic stays exact in double-precision Lua. No wall clock, global
-- random seed, unordered iteration, enemy information, or native API extensions.
Version = "9.0.11-rc12"
local styles = {"staggered", "terraces", "crescent", "twin-wing", "fan", "spine"}
local function Hash(text, seed)
    local value = seed or 5381
    for i = 1, #text do value = (value * 131 + string.byte(text, i)) % 2147483647 end
    return value
end
local function Number(n, fallback)
    return type(n) == "number" and n == n and math.abs(n) < math.huge and n or fallback
end
function Create(armyId, faction, name, center, area)
    area = type(area) == "table" and area or {}
    local mapKey = table.concat({Number(area.x,0),Number(area.y,0),
        Number(area.width,512),Number(area.height,512)}, ":")
    name = tostring(name or "MAIN")
    local id = math.floor(Number(tonumber(armyId), 0))
    local seed = Hash(mapKey .. ":" .. name .. ":" .. id .. ":" .. tostring(faction)
        .. ":" .. math.floor(center.x*2) .. ":" .. math.floor(center.z*2))
    local state = math.max(1, seed)
    local function Pick(low, high)
        state = (state * 16807) % 2147483647
        return low + state % (high - low + 1)
    end
    -- Consecutive army slots receive different shapes at the same named base;
    -- the full seed then varies proportions, spacing and banks independently.
    local style = (Hash(mapKey .. ":" .. name) + id) % #styles + 1
    local profile = {
        version=Version, seed=seed, name=styles[style], style=style,
        home={x=center.x,y=center.y or 0,z=center.z},
        turn=Pick(0,3), mirror=Pick(0,1)==0 and -1 or 1,
        scale=Pick(92,100)/100, width=Pick(95,105)/100, depth=Pick(95,105)/100,
        shear=Pick(-25,25)/100, bias=Pick(-30,30)/100,
        offsetX=Pick(-3,3), offsetZ=Pick(-3,3),
        gapX=Pick(3,6), gapZ=Pick(5,8),
        radiusScale=Pick(128,156)/100,
        bankStart=Pick(0,3), bankDirection=Pick(0,1)==0 and -1 or 1,
        bankRows=Pick(3,4), bankColumns=Pick(4,6), bankGap=Pick(15,20)/10,
        reserveWidth=Pick(3,5),
    }
    return profile
end
-- Rotate the site pattern only, not the buildings: native build yaw remains 0.
function Transform(profile, x, z)
    x = x * profile.mirror
    if profile.turn == 1 then return -z,x end
    if profile.turn == 2 then return -x,-z end
    if profile.turn == 3 then return z,-x end
    return x,z
end
function FactorySites(profile, footprint)
    local sites = {}
    local span = math.max(footprint.x, footprint.y)
    local sx = (span + profile.gapX) * profile.scale * profile.width
    local sz = (span + profile.gapZ) * profile.scale * profile.depth
    local function add(u,v,priority)
        local x,z = Transform(profile, u*sx + profile.offsetX, v*sz + profile.offsetZ)
        sites[#sites+1] = {x=profile.home.x+x,z=profile.home.z+z,
            priority=priority + (u*u+v*v)*2 + profile.bias*u}
    end
    local style=profile.style
    if style==1 or style==2 then
        for row=-4,4 do for column=-4,4 do
            local u,v=column,row
            if style==1 then u=u+(row%2)*0.5;v=v*0.90
            else u=(u+row*profile.shear)*1.25;v=v*0.82 end
            add(u,v,(column*column+row*row)*12)
        end end
    elseif style==3 then
        -- An open arc, not a closed ring that cages the commander. Ring spacing
        -- and arc skew vary while the open sector remains available for transit.
        for ring=1,4 do for j=0,8 do
            local angle=(0.22+j*0.195+profile.shear*0.2)*math.pi
            local r=0.95+(ring-1)*1.0
            add(math.cos(angle)*r,math.sin(angle)*r,
                (ring-1)*80+math.abs(j-4)*3)
        end end
    elseif style==4 then
        -- Two unequal districts. Grow a small first wing, then start the second
        -- instead of filling one universal square around the oldest factory.
        local cells={{0,0},{0,-1},{0,1},{1,0},{1,-1},{1,1},{2,0},{2,-1},{2,1}}
        for wing=1,2 do for i,c in ipairs(cells) do
            local side=wing==1 and -1 or 1
            local u=side*(0.9+c[1]*1.05)
            local v=c[2]*(wing==1 and 0.95 or 1.12)+(wing==2 and 0.35 or 0)
            add(u,v,(i-1)*16+(wing-1)*24)
        end end
    elseif style==5 then
        -- Three spreading industrial arms with small side pockets on each arm.
        for ring=1,4 do for arm=0,2 do for pocket=0,1 do
            local angle=(arm*2/3+profile.shear*0.25)*math.pi
            local r=0.95+(ring-1)*1.12
            local cross=pocket*0.85
            add(math.cos(angle)*r-math.sin(angle)*cross,
                math.sin(angle)*r+math.cos(angle)*cross,
                (ring-1)*75+arm*7+pocket*26)
        end end end
    else
        local sequence={0,1,-1,2,-2,3,-3,4,-4}
        for i,row in ipairs(sequence) do for side=-1,1,2 do
            add(side*(0.82+math.abs(row)*0.06), row*0.90+(side>0 and 0.42 or 0),
                (i-1)*20+(side>0 and 9 or 0))
        end end
    end
    table.sort(sites,function(a,b)
        if a.priority~=b.priority then return a.priority<b.priority end
        if a.x~=b.x then return a.x<b.x end
        return a.z<b.z
    end)
    return sites
end
