using System;
using EM.Lua;

namespace ScomShatter
{
    internal static class ChasmProjectiles
    {
        private static readonly LuaJIT.lua_CFunction Contains = ReceiveContains;
        private static readonly LuaJIT.lua_CFunction BelowDepth = ReceiveBelowDepth;
        private static readonly LuaJIT.lua_CFunction DepthLimit = ReceiveDepthLimit;

        internal static void InstallLua(lua_State state)
        {
            int top = LuaJIT.lua_gettop(state);
            try
            {
                LuaJIT.lua_getglobal(state, "Engine");
                if (LuaJIT.lua_istable(state, -1) == 0)
                    throw new InvalidOperationException("Missing host Engine table for chasm projectiles.");
                LuaJIT.lua_pushcclosure(state, Contains, 0);
                LuaJIT.lua_setfield(state, -2, "SCOChasmContains");
                LuaJIT.lua_pushcclosure(state, BelowDepth, 0);
                LuaJIT.lua_setfield(state, -2, "SCOChasmBelowDepth");
                LuaJIT.lua_pushcclosure(state, DepthLimit, 0);
                LuaJIT.lua_setfield(state, -2, "SCOChasmProjectileDepthLimit");
            }
            finally { LuaJIT.lua_settop(state, top); }
        }

        private static int ReceiveContains(lua_State state)
        {
            bool contains = false;
            try
            {
                if (LuaJIT.lua_gettop(state) == 2 && Number(state, 1, out float x)
                    && Number(state, 2, out float z)) contains = ChasmWorld.Contains(x, z);
            }
            catch { /* Do not unwind a managed exception across LuaJIT. */ }
            LuaJIT.lua_pushboolean(state, contains ? 1 : 0);
            return 1;
        }

        private static int ReceiveBelowDepth(lua_State state)
        {
            bool remove = false;
            try
            {
                if (LuaJIT.lua_gettop(state) == 3 && Number(state, 1, out float x)
                    && Number(state, 2, out float y) && Number(state, 3, out float z))
                    remove = ChasmWorld.ShouldRemoveProjectile(x, y, z);
            }
            catch { /* Do not unwind a managed exception across LuaJIT. */ }
            LuaJIT.lua_pushboolean(state, remove ? 1 : 0);
            return 1;
        }

        private static int ReceiveDepthLimit(lua_State state)
        {
            float limit = float.NegativeInfinity;
            try
            {
                if (LuaJIT.lua_gettop(state) == 0) limit = ChasmWorld.ProjectileDepthLimit;
            }
            catch { /* No active aperture means the stock lifetime owns cleanup. */ }
            if (float.IsNaN(limit) || float.IsInfinity(limit)) LuaJIT.lua_pushnil(state);
            else LuaJIT.lua_pushnumber(state, limit);
            return 1;
        }

        private static bool Number(lua_State state, int index, out float value)
        {
            value = 0;
            if (LuaJIT.lua_type(state, index) != LuaJIT.LUA_TNUMBER) return false;
            value = (float)LuaJIT.lua_tonumber(state, index);
            return !float.IsNaN(value) && !float.IsInfinity(value);
        }

        // Keep the native ballistic/homing simulation and entity hit records. Only
        // the host's removed-surface impact branches need to be bypassed; silent
        // DeleteProjectile commands already replicate cleanup to every client.
        internal static string ReadHookScript()
        {
            return @"
if not Engine.SCOChasmProjectileReadHookInstalled then
    local read = Engine.GetFileContent
    local warned = {}
    local marker = '-- SCOM chasm projectile surfaces 1'
    local function once(source, fragment)
        local first, last = source:find(fragment, 1, true)
        if not first or source:find(fragment, last + 1, true) then
            error('Chasm projectile source contract changed at ' .. fragment)
        end
        return first, last
    end
    local function replace(source, original, replacement)
        local first, last = once(source, original)
        return source:sub(1, first - 1) .. replacement .. source:sub(last + 1)
    end
    local pointPrelude = [[
-- SCOM chasm projectile surfaces 1
local function scoChasmPoint(x, z)
    return type(Engine.SCOChasmContains) == 'function'
        and Engine.SCOChasmContains(x, z) == true
end
]]
    local collisionPrelude = pointPrelude .. [[
local function scoChasmSkipProjectile(projectile, x, z)
    if not scoChasmPoint(x, z) then return false end
    projectile.scoChasmSurfaceSkipped = true
    return true
end
local function scoChasmSurfaceHit(event)
    local origin, direction, distance = event.rayOrigin, event.rayDirection, event.hitDistance
    -- Test the exact native intersection, before the stock 0.01 m impact bias.
    local x, z = origin.x + direction.x * distance, origin.z + direction.z * distance
    if not scoChasmPoint(x, z) then return false end
    local id = event.rayGlobalID
    local projectiles = __Entities.Projectiles
    local projectile = projectiles[id.index]
    if not projectile or projectile.id.index ~= id.index or projectile.id.version ~= id.version then
        -- Water rays can belong to a projectile's child sensor collider.
        local status, root = Engine.GetGlobalEntityRoot(id)
        projectile = status == EngineErrorCode.Success and root and projectiles[root.index] or nil
        if projectile and (projectile.id.index ~= root.index or projectile.id.version ~= root.version) then
            projectile = nil
        end
    end
    if projectile then projectile.scoChasmSurfaceSkipped = true end
    return true
end
]]
    local collisionReturn = [[return {
    CollisionUpdate = CollisionUpdate,
    ProcessAreaDamage = ProcessAreaDamage,
}]]
    local collisionWrapper = [[
-- Wrap the final SCOM handlers, including tactical, nuclear and source-motion owners.
do
    local previousRay, previousWater = ProcessRayCollisionEvent, ProcessWaterCollisionEvent
    function ProcessRayCollisionEvent(event)
        if event.otherGlobalID.index == 0 and scoChasmSurfaceHit(event) then return end
        return previousRay(event)
    end
    function ProcessWaterCollisionEvent(event)
        if scoChasmSurfaceHit(event) then return end
        return previousWater(event)
    end
end
]]
    local specialWaterHeader = 'local function SCOProcessSpecialWaterImpact(rayCollisionEvent)'
    local specialWaterGuard = [[local function SCOProcessSpecialWaterImpact(rayCollisionEvent)
        if _G.WaterGlobalID
            and rayCollisionEvent.otherGlobalID.index == _G.WaterGlobalID.index
            and scoChasmSurfaceHit(rayCollisionEvent) then return end
]]
    local cullOriginal = [[Engine.GetGlobalEntityWorldPosition(projectile.id)
                if position ~= nil and position.y <= waterLevel then]]
    local cullGuard = [[Engine.GetGlobalEntityWorldPosition(projectile.id)
                if position ~= nil and position.y <= waterLevel and not scoChasmSkipProjectile(projectile, position.x, position.z) then]]
    local recoverOriginal = 'and type(height) == ""number"" and position.y <= height'
    local recoverGuard = recoverOriginal .. '\n                        and not scoChasmSkipProjectile(projectile, position.x, position.z)'
    local fireOriginal = 'for _ = 1, contract.pulseCount do'
    local fireGuard = fireOriginal .. '\n            if scoChasmPoint(position.x, position.z) then return end'
    local pulseHeader = 'local function damagePulse(job)'
    local pulseGuard = [[local function damagePulse(job)
    if job.scoChasmSurface and scoChasmPoint(job.position.x, job.position.z) then return end
]]
    local pulseOriginal = '\n        damagePulse(job)\n'
    local pulseTag = '\n' .. [[        job.scoChasmSurface = hitID and (hitID.index == 0 or (_G.WaterGlobalID
            and hitID.index == _G.WaterGlobalID.index and hitID.version == _G.WaterGlobalID.version)) or false
        damagePulse(job)]] .. '\n'
    local updateHeader = 'function ProjectilesUpdate()'
    local updateHeaderReplacement = [[
function ProjectilesUpdate()
    local depthLimit = type(Engine.SCOChasmProjectileDepthLimit) == 'function'
        and Engine.SCOChasmProjectileDepthLimit() or nil
]]
    local updateOriginal = '        projectile:Update()'
    local updateReplacement = [[
        -- SCOM chasm projectile surfaces 1
        local remove = false
        if projectile.scoChasmSurfaceSkipped and depthLimit then
            local errorCode, position = Engine.GetGlobalEntityWorldPosition(projectile.id)
            if errorCode == EngineErrorCode.Success and position.y <= depthLimit then
                remove = Engine.SCOChasmBelowDepth(position.x, position.y, position.z) == true
            end
        end
        if remove then
            -- Delete sends no impact command, damage, flash, decal or impact audio.
            projectile:Delete()
        else
            projectile:Update()
        end]]
    local function transform(source, mode)
        local normalized = source:gsub('\r\n', '\n')
        if normalized:find(marker, 1, true) then
            if mode == 'collision' then
                once(normalized, collisionPrelude)
                once(normalized, collisionWrapper)
                if normalized:find(specialWaterHeader, 1, true) then once(normalized, specialWaterGuard) end
                if normalized:find('SCO_FaBomberCullWaterProjectiles', 1, true) then once(normalized, cullGuard) end
                if normalized:find('SCO_FaBomberRecoverScorcherTerrainImpacts', 1, true) then once(normalized, recoverGuard) end
                if normalized:find(fireOriginal, 1, true) then once(normalized, fireGuard) end
            elseif mode == 'motion' then
                once(normalized, pointPrelude)
                once(normalized, pulseGuard)
                once(normalized, pulseTag)
            else
                once(normalized, updateHeaderReplacement)
                once(normalized, updateReplacement)
            end
            return source
        end
        if mode == 'collision' then
            -- Guard direct special-water dispatch and fallbacks before they can
            -- move a bomb back onto the removed surface or schedule damage.
            if normalized:find(specialWaterHeader, 1, true) then
                normalized = replace(normalized, specialWaterHeader, specialWaterGuard)
            end
            if normalized:find('SCO_FaBomberCullWaterProjectiles', 1, true) then
                normalized = replace(normalized, cullOriginal, cullGuard)
            end
            if normalized:find('SCO_FaBomberRecoverScorcherTerrainImpacts', 1, true) then
                normalized = replace(normalized, recoverOriginal, recoverGuard)
            end
            if normalized:find(fireOriginal, 1, true) then
                normalized = replace(normalized, fireOriginal, fireGuard)
            end
            normalized = collisionPrelude .. normalized
            normalized = replace(normalized, collisionReturn, collisionWrapper .. collisionReturn)
        elseif mode == 'motion' then
            normalized = pointPrelude .. replace(normalized, pulseHeader, pulseGuard)
            normalized = replace(normalized, pulseOriginal, pulseTag)
        else
            once(normalized, 'for _, projectile in pairs(Projectiles) do')
            normalized = replace(normalized, updateOriginal, updateReplacement)
            normalized = replace(normalized, updateHeader, updateHeaderReplacement)
        end
        if source:find('\r\n', 1, true) then normalized = normalized:gsub('\n', '\r\n') end
        return normalized
    end
    Engine.GetFileContent = function(path)
        local source = read(path)
        if type(source) ~= 'string' or type(path) ~= 'string' then return source end
        local normalizedPath = path:gsub('\\', '/'):lower()
        local collisionPath = '/host/collisionupdate.lua'
        local updatePath = '/host/projectiles/projectilesupdate.lua'
        local motionPath = '/common/systems/scosourceprojectilemotion.lua'
        local mode
        if normalizedPath:sub(-#collisionPath) == collisionPath then mode = 'collision'
        elseif normalizedPath:sub(-#updatePath) == updatePath then mode = 'update'
        elseif normalizedPath:sub(-#motionPath) == motionPath then mode = 'motion'
        else return source end
        local ok, changed = pcall(transform, source, mode)
        if ok then return changed end
        if not warned[normalizedPath] then
            warned[normalizedPath] = true
            Engine.Warn('[SCOM chasm] Projectile source changed; removed-surface guard was skipped for ' .. path .. ': ' .. tostring(changed))
        end
        return source
    end
    Engine.SCOChasmProjectileReadHookInstalled = true
end
";
        }
    }
}
