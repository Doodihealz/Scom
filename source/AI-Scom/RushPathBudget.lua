-- RC16: deterministic admission for costly native ground-path requests.
-- This limits simultaneous searches, not unit count or tactical sensing. A
-- deferred request is NOT an unreachable objective. No os.clock / wall time.
Version="9.0.15-rc16"
Config={Window=0.25,Global=8,PerArmy=6,TicketSeconds=5,MaxQueue=1024,Recovery=8}
local epoch,used,byArmy=-1,0,{}
local queue={}
local tickets=setmetatable({},{__mode="k"})
local stats={granted=0,deferred=0,optionalSkipped=0,recoveries=0}
local lastTime=-1;local recoveryUsed=0;local sweptEpoch=-1
local function Now() return GetGameTimeSeconds() end
local function Operation(ai) return ai and (ai.rushOperation or ai.rushFleet) end
local function Current(p)
    return p and not p.dead and not p.deleted and p.ai and p.army and p.army.ai
        and p.army.ai.isAlive~=false and p.army:PlatoonExists(p)
end
local function Valid(t)
    local p=t.platoon
    return Current(p) and p.army==t.army and p.army.ai==t.armyAI and p.ai==t.ai
        and p.ai.rushOperation==t.operation and p.ai.rushFleet==t.fleet
end
local function Urgent(t)
    local op=Operation(t.ai);local policy=op and op.policy
    return t.ai.withdraw==true or policy and policy.phase=="Retreat" or false
end
local function Insert(t)
    if t.urgent then
        local at=1
        while at<=#queue and queue[at].urgent do at=at+1 end
        table.insert(queue,at,t)
    else queue[#queue+1]=t end
end
local function Refresh()
    local now=Now()
    if now<lastTime then queue={};tickets=setmetatable({},{__mode="k"});sweptEpoch=-1 end
    local key=math.floor(now/Config.Window+1e-7)
    if key~=epoch or now<lastTime then epoch,used,byArmy,recoveryUsed=key,0,{},0 end
    lastTime=now
    if sweptEpoch~=key then
        sweptEpoch=key
        for i=#queue,1,-1 do
            local t=queue[i]
            if not Valid(t) or now-t.seen>Config.TicketSeconds then tickets[t.platoon]=nil;table.remove(queue,i) end
        end
    end
    return now
end
function Cancel(platoon)
    local t=tickets[platoon]
    if not t then return end
    tickets[platoon]=nil
    for i=#queue,1,-1 do if queue[i]==t then table.remove(queue,i);break end end
end
function Acquire(platoon)
    local now=Refresh();local t=tickets[platoon]
    if t and not Valid(t) then Cancel(platoon);t=nil end
    if not Current(platoon) or not Operation(platoon.ai) then return false end
    if not t then
        if #queue>=Config.MaxQueue then stats.deferred=stats.deferred+1;return false end
        t={platoon=platoon,army=platoon.army,armyAI=platoon.army.ai,ai=platoon.ai,
            operation=platoon.ai.rushOperation,fleet=platoon.ai.rushFleet,seen=now}
        t.urgent=Urgent(t);tickets[platoon]=t;Insert(t)
    else
        local urgent=Urgent(t)
        if urgent~=t.urgent then
            for i=#queue,1,-1 do if queue[i]==t then table.remove(queue,i);break end end
            t.urgent=urgent;Insert(t)
        end
    end
    t.seen=now
    if used<Config.Global then
        local i=1
        while i<=#queue do
            local entry=queue[i]
            if not Valid(entry) then
                tickets[entry.platoon]=nil;table.remove(queue,i)
            elseif now-entry.seen>Config.Window then
                i=i+1 -- a suspended controller must not hold the queue for five seconds
            elseif (byArmy[entry.army] or 0)<Config.PerArmy then
                if entry==t then
                    table.remove(queue,i);tickets[platoon]=nil
                    used=used+1;byArmy[t.army]=(byArmy[t.army] or 0)+1;stats.granted=stats.granted+1
                    return true
                end
                break -- older, eligible requests have priority
            else i=i+1 end
        end
    end
    stats.deferred=stats.deferred+1
    return false
end
function Extra(platoon,n)
    local now=Refresh();n=n or 1
    local waiting=false
    for _,entry in ipairs(queue) do
        if now-entry.seen<=Config.Window and Valid(entry) then waiting=true;break end
    end
    if not Current(platoon) or type(n)~="number" or n<1 or n~=math.floor(n) or n>Config.Global
        or waiting or used+n>Config.Global or (byArmy[platoon.army] or 0)+n>Config.PerArmy then
        stats.optionalSkipped=stats.optionalSkipped+1;return false
    end
    used=used+n;byArmy[platoon.army]=(byArmy[platoon.army] or 0)+n
    stats.granted=stats.granted+n;return true
end
function Recovery(unit)
    local now=Refresh();local p=unit and unit.platoon
    if not unit or unit.dead or unit.deleted or not Current(p) or unit.army~=p.army
        or not unit.ai or unit.CaptureInProgress or unit.ReclaimInProgress then return false end
    local op=Operation(p.ai) or p.ai
    if recoveryUsed>=Config.Recovery or now<(op.nextUnitRecovery or 0) then return false end
    recoveryUsed=recoveryUsed+1;op.nextUnitRecovery=now+Config.Window;stats.recoveries=stats.recoveries+1
    return true
end
function Summary()
    Refresh()
    return {queued=#queue,granted=stats.granted,deferred=stats.deferred,
        optionalSkipped=stats.optionalSkipped,recoveries=stats.recoveries}
end
