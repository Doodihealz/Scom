using System;
using System.Text;
using EM.Engine;
using EM.Lua;
using HarmonyLib;
using UnityEngine;

namespace ScomShatter;

// Host contact, native host-to-client command, and client discovery share one
// immutable identity. Neither emission nor receipt consults local intel/camera.
internal static class ChasmEvents
{
    private static readonly LuaJIT.lua_CFunction HostCallback = state => Receive(state, true);
    private static readonly LuaJIT.lua_CFunction ClientCallback = state => Receive(state, false);
    private static volatile bool active;

    internal static void Install(Harmony harmony)
    {
        // This managed boundary is reached before every native/Burst movement
        // update. No Unity render callback controls authoritative collapse time.
        harmony.Patch(AccessTools.Method(typeof(GlobalEngineData), "ScheduleUpdate"),
            prefix: new HarmonyMethod(typeof(ChasmEvents), nameof(BeforeSimulation)) { priority = Priority.First });
        foreach (string method in new[] { "Initialize", "Dispose" })
        {
            harmony.Patch(AccessTools.Method(typeof(HostEngine), method),
                prefix: new HarmonyMethod(typeof(ChasmEvents), nameof(ResetHost)));
            harmony.Patch(AccessTools.Method(typeof(ClientEngine), method),
                prefix: new HarmonyMethod(typeof(ChasmEvents), nameof(ResetClient)));
        }
    }

    private static void BeforeSimulation(ref GlobalEngineData globalEngineData, bool isHost)
        => ChasmWorld.Advance(isHost, globalEngineData.globalTime.simTick);
    private static void ResetHost() => ChasmWorld.Reset(true);
    private static void ResetClient() => ChasmWorld.Reset(false);

    internal static void Register(lua_State state, bool isClient)
    {
        int top = LuaJIT.lua_gettop(state);
        try
        {
            LuaJIT.lua_getglobal(state, "Engine");
            if (LuaJIT.lua_istable(state, -1) == 0) throw new InvalidOperationException("Engine table unavailable");
            LuaJIT.lua_pushcclosure(state, isClient ? ClientCallback : HostCallback, 0);
            LuaJIT.lua_setfield(state, -2, "SCOChasmImpact");
            if (!isClient)
            {
                LuaJIT.lua_pushcclosure(state, ChasmMassPoints.LossTick, 0);
                LuaJIT.lua_setfield(state, -2, "SCOChasmMassLossTick");
            }
            active = true;
        }
        finally { LuaJIT.lua_settop(state, top); }
    }

    internal static void Stop() => active = false;

    private static int Receive(lua_State state, bool host)
    {
        bool accepted = false;
        try
        {
            if (active && LuaJIT.lua_gettop(state) == 6)
            {
                bool numeric = true;
                for (int i = 1; i <= 6; i++) numeric &= LuaJIT.lua_type(state, i) == LuaJIT.LUA_TNUMBER;
                if (numeric)
                {
                    double index = LuaJIT.lua_tonumber(state, 1), version = LuaJIT.lua_tonumber(state, 2);
                    double tick = LuaJIT.lua_tonumber(state, 3);
                    var position = new Vector3((float)LuaJIT.lua_tonumber(state, 4),
                        (float)LuaJIT.lua_tonumber(state, 5), (float)LuaJIT.lua_tonumber(state, 6));
                    if (Unsigned(index) && index > 0 && Unsigned(version) && tick >= 0 && tick <= int.MaxValue
                        && tick == Math.Floor(tick) && Finite(position.x) && Finite(position.y) && Finite(position.z))
                    {
                        accepted = ChasmWorld.Register(host, position, (uint)index, (uint)version, (int)tick);
                    }
                }
            }
        }
        catch (Exception error)
        {
            // Preserve the native ABI while making a gameplay-state failure visible.
            Debug.LogError("SCOM authoritative chasm impact failed: " + error);
        }
        LuaJIT.lua_pushboolean(state, accepted ? 1 : 0);
        return 1;
    }

    private static bool Unsigned(double value) => value >= 0 && value <= uint.MaxValue && value == Math.Floor(value);
    private static bool Finite(float value) => !float.IsNaN(value) && !float.IsInfinity(value);

    private const string HostAnchor = "function HostProjectile:Destroy(tickImpactTime, hitGlobalID)\n";
    private const string HostAddition = @"
    -- SCOM authoritative Yolona chasm 1
    local source = self.tp and self.tp.additions and self.tp.additions.scoSourceProjectile
    local position = self.scoImpactPosition
    if self.tp and self.tp.general and self.tp.general.tpId == 'psf0136'
        and source and type(source.sourceId) == 'string'
        and source.sourceId:lower() == 'sifexperimentalstrategicmissile01'
        and hitGlobalID and (hitGlobalID.index == 0 or (_G.WaterGlobalID
            and hitGlobalID.index == _G.WaterGlobalID.index and hitGlobalID.version == _G.WaterGlobalID.version)
            or (self.scoChasmSurfaceContact and hitGlobalID.index == self.scoChasmSurfaceContact.index
                and hitGlobalID.version == self.scoChasmSurfaceContact.version))
        and position and not self.scoChasmEmitted and not Engine.SCOChasmContains(position.x, position.z) then
        local tick = Engine.GetSimulationTick()
        -- Host acceptance precedes replication, so no client creates an unowned blocker.
        if Engine.SCOChasmImpact(self.id.index, self.id.version, tick, position.x, position.y, position.z) then
            self.scoChasmEmitted = true
            ProjectileCommands.SCOMChasmImpact.Send(self.id, tick, position)
            NewThread(scoRemoveUnsupportedMass, self.id.index, self.id.version)
        end
    end
";
    private const string ContactAnchor = "    local function withContact(callback, event, projectile)\n";
    private const string ContactCall = "        local ok, result = pcall(callback, event)\n";
    private const string ContactReplacement = @"
        local previousChasmSurface = projectile.scoChasmSurfaceContact
        -- Damage may delete the hit entity before the projectile's Destroy call.
        -- Snapshot its live grounded state without changing damage dispatch.
        local classified, grounded = pcall(SCOMChasmSurfaceContact, event.otherGlobalID, projectile)
        projectile.scoChasmSurfaceContact = classified and grounded and event.otherGlobalID or nil
        local ok, result = pcall(callback, event)
        projectile.scoChasmSurfaceContact = previousChasmSurface
";
    private const string ContactClassifier = @"
    -- SCOM Yolona grounded contact classification 1
    local function SCOMChasmSurfaceContact(hit, projectile)
        local tp = projectile.tp
        local source = tp and tp.additions and tp.additions.scoSourceProjectile
        if not tp or not tp.general or tp.general.tpId ~= 'psf0136'
            or not source or type(source.sourceId) ~= 'string'
            or source.sourceId:lower() ~= 'sifexperimentalstrategicmissile01'
            or not hit or hit.index == 0 then return false end
        -- A shield can be attached beneath a unit root. Resolve it first.
        if ResolveCollisionEntity(Shields, hit) or ResolveCollisionEntity(Projectiles, hit) then return false end
        local unit = ResolveCollisionEntity(Units, hit)
        if unit then
            local tags = unit.tp and unit.tp.hasTags or {}
            if unit.isAirborne == true or tags.ORBITAL then return false end
            if not unit.tp or not unit.tp.movement then return tags.STRUCTURE and not tags.AIR or false end
            local status, layer = Engine.GetMovementNavigationLayer(unit.id)
            local nav = Layers.NavigationLayers
            if status == EngineErrorCode.Success and nav.Air ~= nil and layer == nav.Air then return false end
            if unit.isAirborne == false then return true end
            if tags.AIR then return false end
            if status == EngineErrorCode.Success and ((nav.Land ~= nil and layer == nav.Land)
                or (nav.Amphibious ~= nil and layer == nav.Amphibious)
                or (nav.Hover ~= nil and layer == nav.Hover) or (nav.Sea ~= nil and layer == nav.Sea)) then
                return true
            end
            return false
        end
        local prop = ResolveCollisionEntity(Props, hit)
        if not prop then return false end
        local status, anchor = Engine.GetGlobalEntityWorldPosition(prop.id)
        if status ~= EngineErrorCode.Success or not anchor then return false end
        -- Prop pivots can sit slightly above/below the rendered terrain. Checking
        -- their root admits tall grounded trees/buildings, not falling wrecks.
        local sampled, height = Engine.SampleTerrainHeight(anchor)
        if sampled == EngineErrorCode.Success and math.abs(anchor.y - height) <= 1 then return true end
        local hasStatus, hasWater = Engine.HasWater()
        if hasStatus == EngineErrorCode.Success and hasWater then
            local waterStatus, level = Engine.GetWaterLevel()
            return waterStatus == EngineErrorCode.Success and math.abs(anchor.y - level) <= 1
        end
        return false
    end
";
    private const string CommandAddition = @"

-- SCOM authoritative Yolona chasm command 1
SCOMChasmImpact = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = 'projectileID', type = Layouts.GlobalID },
    { key = 'tick', type = 'int' },
    { key = 'position', type = Layouts.Float3 },
})
function SCOMChasmImpact.Send(projectileID, tick, position)
    return { projectileID = projectileID, tick = tick, position = position }
end
function SCOMChasmImpact.Receive(data)
    local id, p = data.projectileID, data.position
    -- This is persistent gameplay discovery, including impacts outside local intel.
    assert(Engine.SCOChasmImpact(id.index, id.version, data.tick, p.x, p.y, p.z),
        'SCOM chasm event rejected; authoritative terrain cannot be reconstructed')
end
";

    internal static string ReadHookScript()
    {
        var script = new StringBuilder(@"
if not Engine.SCOChasmReadHookInstalled then
    local read = Engine.GetFileContent
    local function once(source, fragment)
        local first, last = source:find(fragment, 1, true)
        assert(first and not source:find(fragment, last + 1, true), 'SCOM chasm source contract changed')
        return first, last
    end
    Engine.GetFileContent = function(path)
        local source = read(path)
        if type(source) ~= 'string' or type(path) ~= 'string' then return source end
        local normalizedPath = path:gsub('\\', '/'):lower()
        local host = '/host/projectiles/projectilesclasses/projectilesbaseclass.lua'
        local commands = '/common/commands/definitions/projectiles.lua'
        local collision = '/host/collisionupdate.lua'
        if normalizedPath:sub(-#host) ~= host and normalizedPath:sub(-#commands) ~= commands
            and normalizedPath:sub(-#collision) ~= collision then return source end
        local normalized = source:gsub('\r\n', '\n')
");
        script.Append("        local massPrelude = ").Append(Quote(ChasmMassPoints.HostPrelude)).Append("\n");
        script.Append("        local hostAnchor, hostAddition, commandAddition = ").Append(Quote(HostAnchor))
            .Append(", ").Append(Quote(HostAddition)).Append(", ").Append(Quote(CommandAddition)).Append("\n")
            .Append("        local contactAnchor, contactCall, contactReplacement, contactClassifier = ")
            .Append(Quote(ContactAnchor)).Append(", ").Append(Quote(ContactCall)).Append(", ")
            .Append(Quote(ContactReplacement)).Append(", ").Append(Quote(ContactClassifier)).Append(@"
        if normalizedPath:sub(-#host) == host then
            if normalized:find('-- SCOM authoritative Yolona chasm 1', 1, true) then
                once(normalized, massPrelude .. hostAnchor .. hostAddition)
            else
                -- The exact collision contact was added by the current SCOM source owner.
                once(normalized, 'self.intelLayer.detectionMask.value, self.scoImpactPosition, self.scoImpactBone, self.scoImpactBonePosition)')
                local first, last = once(normalized, hostAnchor)
                normalized = normalized:sub(1, first - 1) .. massPrelude .. hostAnchor .. hostAddition .. normalized:sub(last + 1)
            end
        elseif normalizedPath:sub(-#collision) == collision then
            if normalized:find('-- SCOM Yolona grounded contact classification 1', 1, true) then
                once(normalized, contactClassifier .. contactAnchor)
                once(normalized, contactReplacement)
            else
                -- Bind to the current generation-safe, pre-damage contact owner.
                once(normalized, 'local function ResolveCollisionEntity(entities, id)')
                once(normalized, '        event = SCOM_MeshContact.Refine(event)')
                local first, last = once(normalized, contactAnchor)
                local callFirst, callLast = once(normalized, contactCall)
                assert(callFirst > last, 'SCOM chasm contact order changed')
                normalized = normalized:sub(1, callFirst - 1) .. contactReplacement .. normalized:sub(callLast + 1)
                normalized = normalized:sub(1, first - 1) .. contactClassifier .. normalized:sub(first)
            end
        else
            if normalized:find('-- SCOM authoritative Yolona chasm command 1', 1, true) then
                once(normalized, commandAddition)
            else
                once(normalized, 'local Registry = Import(""common/commands/registry.lua"")')
                once(normalized, 'local Layouts  = Import(""common/commands/layouts.lua"")')
                normalized = normalized .. commandAddition
            end
        end
        if source:find('\r\n', 1, true) then normalized = normalized:gsub('\n', '\r\n') end
        return normalized
    end
    Engine.SCOChasmReadHookInstalled = true
end
");
        return script.ToString();
    }

    private static string Quote(string value) => "\"" + value.Replace("\\", "\\\\").Replace("\"", "\\\"")
        .Replace("\r", "\\r").Replace("\n", "\\n") + "\"";
}
