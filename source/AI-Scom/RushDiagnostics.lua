-- Bounded observational diagnostics. Native resources, orders and AI policy are
-- never changed here. One sink is shared by every AI-Scom army in this session.
-- Detailed file diagnostics are opt-in; the controller still reports errors.
Version="9.2.9"
Config={Enabled=false,MaxFileBytes=4*1024*1024}
local DIRECTORY="AI/mods/AI-Scom"
local BUFFER_BYTES,BUFFER_LINES,MAX_KEYS=64*1024,256,64
local FILE_BYTES,FILE_COUNT,LINE_BYTES=4*1024*1024,3,2048
local armies=setmetatable({},{__mode="k"})
local globalOwner={}
local queue,queueBytes={},0
local endings={}
local sequence,lastTime,lastFlush=0,nil,nil
local session,segment,path,fileBytes,pendingPath=nil,0,nil,0,nil
local pendingHeader,rewind=nil,nil
local sessionQueued=false
local lostLines,lostBytes,sinkFailures,counterOverflow=0,0,0,0
local reportedLines,reportedBytes,reportedFailures,reportedOverflow=0,0,0,0
local warningAt,warningLog=nil,nil

local function Finite(value)
    return type(value)=="number" and value==value and math.abs(value)<math.huge
end
local function Primitive(value)
    local kind=type(value)
    return kind=="string" or kind=="boolean" or kind=="number" and Finite(value)
end
local function Short(value,limit)
    if not Primitive(value) then return nil end
    local text=tostring(value)
    if #text>limit then return text:sub(1,limit-3).."..." end
    return text
end
local function Escaped(value)
    if type(value)=="number" or type(value)=="boolean" then return tostring(value) end
    return '"'..value:gsub("\\","\\\\"):gsub('"','\\"')
        :gsub("\r","\\r"):gsub("\n","\\n"):gsub("\t","\\t"):gsub("%c","?")..'"'
end
local function Fields(fields,limit)
    local result,keys={},{}
    for key,value in pairs(type(fields)=="table" and fields or {}) do
        if type(key)=="string" and #key<=48 and key:match("^[%w_.%-]+$") and Primitive(value) then
            keys[#keys+1]=key
        end
    end
    table.sort(keys)
    for i=1,math.min(limit or 64,#keys) do
        local key=keys[i];local value=fields[key]
        result[#result+1]=key.."="..Escaped(type(value)=="string" and Short(value,384) or value)
    end
    return result
end
local function Line(army,event,fields,now)
    local row,keys={},{}
    for key,value in pairs(type(fields)=="table" and fields or {}) do
        if type(key)=="string" and #key<=48 and key:match("^[%w_.%-]+$") and Primitive(value) then keys[#keys+1]=key end
    end
    table.sort(keys)
    for i=1,math.min(64,#keys) do row[keys[i]]=fields[keys[i]] end
    local omitted=math.max(0,#keys-64)
    if omitted>0 then row.fields_dropped=omitted end
    sequence=sequence+1
    row.event=Short(event,64) or "invalid-event"
    row.seq=sequence;row.sim=now;row.session=session
    if army and Primitive(army.id) then row.army=army.id end
    local parts=Fields(row,70)
    -- Keep each record parseable: omit whole trailing fields, never cut quotes.
    local reserved={army=true,event=true,seq=true,sim=true,session=true,fields_dropped=true}
    while #parts>1 and #table.concat(parts," ")+2>LINE_BYTES do
        local removed=false
        for i=#parts,1,-1 do
            if not reserved[parts[i]:match("^([^=]+)=")] then table.remove(parts,i);removed=true;omitted=omitted+1;break end
        end
        if not removed then break end
        local found=false
        for i,part in ipairs(parts) do
            if part:match("^fields_dropped=") then parts[i]="fields_dropped="..omitted;found=true;break end
        end
        if not found then parts[#parts+1]="fields_dropped="..omitted end
        table.sort(parts)
    end
    return table.concat(parts," ").."\r\n"
end
local function Warn(message,now)
    if warningAt and now>=warningAt and now-warningAt<30 then return end
    warningAt=now
    if not warningLog then
        if type(AILogRAW)=="function" then warningLog=AILogRAW
        elseif type(Import)=="function" then
            local ok,module=pcall(Import,"AI/debugUtilities.lua")
            if ok and type(module)=="table" and type(module.AILogRAW)=="function" then warningLog=module.AILogRAW end
        end
    end
    if warningLog then pcall(warningLog,"[AI-Scom diagnostics] "..(Short(message,256) or "logging failure")) end
end
local function Clock()
    local now=0
    if type(GetGameTimeSeconds)=="function" then
        local ok,value=pcall(GetGameTimeSeconds);if ok and Finite(value) then now=value end
    end
    if lastTime and now<lastTime then
        rewind={from=lastTime,to=now}
        for _,state in pairs(armies) do state.throttle={};state.throttleKeys=0;state.nextCounters=now+10 end
        warningAt,lastFlush=nil,nil
    end
    lastTime=now
    return now
end
local function Push(line,loss)
    if #queue>=BUFFER_LINES or queueBytes+#line>BUFFER_BYTES then
        if loss then lostLines=lostLines+1;lostBytes=lostBytes+#line end
        return false
    end
    queue[#queue+1]=line;queueBytes=queueBytes+#line
    return true
end
local function Session(now)
    if not session then
        local ok,value=pcall(os.date,"%Y%m%d-%H%M%S")
        session=ok and type(value)=="string" and value:match("^%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d$") and value or "00000000-000000"
    end
    if not sessionQueued then
        local info=GameInfo and GameInfo.MapInfo
        sessionQueued=Push(Line(nil,"session",{build=Version,profile="AI-Scom",
            map=info and (info.dataName or info.name)},now),false)
    end
    if rewind and Push(Line(nil,"clock_rewind",rewind,now),false) then rewind=nil end
end
local function Army(army,now)
    local owner=army or globalOwner
    local state=armies[owner]
    if state and state.ended and army and state.ownerAI~=army.ai then state=nil end
    if not state then
        state={ownerAI=army and army.ai,counters={},counterKeys=0,throttle={},throttleKeys=0,nextCounters=now+10}
        armies[owner]=state
    end
    if not state.started then
        local lobby=army and army.lobbyOptions
        local settings=army and army.ai and army.ai.settings or lobby and lobby.aiSettings
        local spawn=GameInfo and GameInfo.MapData and GameInfo.MapData.markers
            and GameInfo.MapData.markers.Spawn
        local marker=spawn and spawn.transforms and army and spawn.transforms[army.name]
        local position=marker and marker.position
        state.started=Push(Line(army,"army_start",{name=army and army.name,
            faction=army and army.faction,team=lobby and lobby.team,
            profile=settings and settings.modName,directory=settings and settings.modDirectory,
            difficulty=settings and settings.difficulty,x=position and position.x,z=position and position.z},now),false)
    end
    return state
end
local function Detail(value)
    if type(value)=="table" then return Short(table.concat(Fields(value,8)," "),384) end
    return Short(value,384)
end
local function Aggregate(army,state,now)
    local keys={};for key in pairs(state.counters) do keys[#keys+1]=key end;table.sort(keys)
    for _,key in ipairs(keys) do
        local item=state.counters[key]
        if Push(Line(army,"counter",{category=item.category,reason=item.reason,count=item.count,detail=item.detail},now),false) then
            state.counters[key]=nil;state.counterKeys=state.counterKeys-1
        end
    end
    if state.counterKeys==0 then state.nextCounters=now+10 end
end
local function Losses(now)
    if lostLines==reportedLines and lostBytes==reportedBytes and sinkFailures==reportedFailures and counterOverflow==reportedOverflow then return end
    if Push(Line(nil,"diagnostics_loss",{dropped_lines=lostLines,dropped_bytes=lostBytes,
        sink_failures=sinkFailures,counter_overflow=counterOverflow},now),false) then
        reportedLines,reportedBytes,reportedFailures,reportedOverflow=lostLines,lostBytes,sinkFailures,counterOverflow
    end
end
local function Native(name,...)
    local fn=Engine and Engine[name]
    if type(fn)~="function" then return false,"missing native "..name end
    local ok,result=pcall(fn,...)
    return ok and result==true,ok and "native "..name.." refused" or Short(result,256)
end
local function Open(now)
    if not pendingPath then
        local fn=Engine and Engine.GetFilesInsideDirectory
        if type(fn)~="function" then return false,"missing native directory listing" end
        local ok,files=pcall(fn,DIRECTORY)
        if not ok or type(files)~="table" then return false,"native directory listing failed" end
        local known={};local nextSegment=segment+1
        for _,name in pairs(files) do
            if type(name)=="string" then
                local stamp,index=name:match("^AI%-Scom%-(%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d)%-(%d%d%d%d%d%d)%.log$")
                if stamp then
                    known[#known+1]=name
                    if stamp==session then nextSegment=math.max(nextSegment,tonumber(index)+1) end
                end
            end
        end
        table.sort(known)
        while #known>=FILE_COUNT do
            local removed,reason=Native("RemoveFile",DIRECTORY.."/"..known[1])
            if not removed then return false,reason end
            table.remove(known,1)
        end
        if nextSegment>999999 then return false,"diagnostic segment limit" end
        segment=nextSegment
        pendingPath=DIRECTORY.."/AI-Scom-"..session..("-%06d.log"):format(segment)
        pendingHeader=Line(nil,"segment",{build=Version,segment=segment,previous=path},now)
    end
    local ok,reason=Native("WriteStringToFile",pendingPath,pendingHeader)
    if not ok then return false,reason end
    path,fileBytes=pendingPath,#pendingHeader
    pendingPath,pendingHeader=nil,nil
    return true
end
local function FlushBuffer()
    local now=Clock();Session(now);Losses(now)
    if #queue==0 then return true end
    local maximum=Finite(Config.MaxFileBytes) and math.max(4096,math.min(FILE_BYTES,Config.MaxFileBytes)) or FILE_BYTES
    local first=1
    while first<=#queue do
        if not path or fileBytes+#queue[first]>maximum then
            local opened,reason=Open(now)
            if not opened then sinkFailures=sinkFailures+1;Warn(reason,now);break end
        end
        local last,bytes=first-1,0
        while last+1<=#queue and fileBytes+bytes+#queue[last+1]<=maximum do
            last=last+1;bytes=bytes+#queue[last]
        end
        if last<first then sinkFailures=sinkFailures+1;Warn("record exceeds file capacity",now);break end
        local payload=table.concat(queue,"",first,last)
        local ok,reason=Native("AppendStringToFile",path,payload)
        -- A false/throwing native append may have written a partial payload.
        -- Charge its full size conservatively; retries may repeat sequence IDs.
        fileBytes=fileBytes+bytes
        if not ok then sinkFailures=sinkFailures+1;Warn(reason,now);break end
        first=last+1
    end
    if first>1 then
        local remaining={};local bytes=0
        for i=first,#queue do remaining[#remaining+1]=queue[i];bytes=bytes+#queue[i] end
        queue,queueBytes=remaining,bytes
    end
    lastFlush=now
    return #queue==0
end
local function FlushCore()
    -- Terminal counters can exceed the remaining queue space. Retain their
    -- bounded per-army state and drain before queuing the end marker.
    for _=1,4 do
        local now=Clock();Session(now)
        for i=#endings,1,-1 do
            local ending=endings[i];local state=ending.state
            Aggregate(ending.army,state,now)
            if state.counterKeys==0 and Push(Line(ending.army,"army_end",{reason=ending.reason},now),false) then
                state.ended=true;state.ending=nil;table.remove(endings,i)
            end
        end
        if not FlushBuffer() then return false end
        if #endings==0 then return true end
    end
    return false
end
local function EventCore(army,event,fields,key,interval)
    local now=Clock();Session(now);local state=Army(army,now)
    if state.ended or state.ending then return false end
    key=Short(key,96)
    if key and Finite(interval) and interval>0 then
        if not state.throttle[key] and state.throttleKeys>=MAX_KEYS-1 then key="\0overflow" end
        local last=state.throttle[key]
        if last and now>=last and now-last<interval then return false end
    else key=nil end
    local line=Line(army,event,fields,now)
    if not Push(line,true) then Warn("diagnostic buffer full; loss counted",now);return false end
    if key then
        if not state.throttle[key] then state.throttleKeys=state.throttleKeys+1 end
        state.throttle[key]=now
    end
    return true
end
local function CountCore(army,category,reason,detail)
    local now=Clock();Session(now);local state=Army(army,now)
    if state.ended or state.ending then return false end
    category,reason=Short(category,48) or "unknown",Short(reason,96) or "unknown"
    local key=category.."\31"..reason
    if not state.counters[key] and state.counterKeys>=MAX_KEYS-1 then
        category,reason,key="diagnostics","counter-overflow","\0overflow";counterOverflow=counterOverflow+1
    end
    local item=state.counters[key]
    if not item then item={category=category,reason=reason,count=0};state.counters[key]=item;state.counterKeys=state.counterKeys+1 end
    item.count=item.count+1;item.detail=Detail(detail)
    return true
end
local function TickCore(army)
    local now=Clock();Session(now);local state=Army(army,now)
    if now>=state.nextCounters then Aggregate(army,state,now) end
    if not lastFlush or now-lastFlush>=2 then return FlushCore() end
    return true
end
local function EndCore(army,reason)
    local now=Clock();Session(now);local state=Army(army,now)
    if not state.ended and not state.ending then
        state.ending=true
        endings[#endings+1]={army=army,state=state,reason=Short(reason,192) or "ended"}
    end
    return FlushCore()
end
local function Safe(fn,...)
    if type(Config)~="table" or Config.Enabled~=true then return false end
    local ok,result=pcall(fn,...)
    if ok then return result end
    sinkFailures=sinkFailures+1
    pcall(Warn,Short(result,256) or "diagnostic exception",lastTime or 0)
    return false
end
function Event(...) return Safe(EventCore,...) end
function Count(...) return Safe(CountCore,...) end
function Flush(...) return Safe(FlushCore,...) end
function Tick(...) return Safe(TickCore,...) end
function End(...) return Safe(EndCore,...) end
