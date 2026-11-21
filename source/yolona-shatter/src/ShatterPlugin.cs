using System;
using System.Text;
using BepInEx;
using EM.Lua;
using EM.Map;
using HarmonyLib;
using UnityEngine;

namespace ScomShatter
{
    [BepInPlugin("local.scom.yolona-shatter", "SCOM Yolona Shatter", "3.4.12")]
    public sealed class ShatterPlugin : BaseUnityPlugin
    {
        private const string HarmonyId = "local.scom.yolona-shatter";
        private static readonly LuaJIT.lua_CFunction NativeImpact = ReceiveImpact;
        private static ShatterPlugin instance;
        private enum Initializing { None, Host, Client }
        [ThreadStatic] private static Initializing initializing;
        private Harmony harmony;
        private int preparedSession = int.MinValue;
        private bool prepared;
        private static volatile bool acceptingImpacts;
        private ChasmWorld.Site pendingTerrain;
        private float nextTerrainTry;

        private void Awake()
        {
            instance = this;
            harmony = new Harmony(HarmonyId + "." + typeof(ShatterPlugin).Assembly.GetName().Name);
            try
            {
                harmony.Patch(AccessTools.Method(typeof(LuaInterface), "InitLuaState"),
                    prefix: new HarmonyMethod(typeof(ShatterPlugin), nameof(BeforeLuaInit)),
                    finalizer: new HarmonyMethod(typeof(ShatterPlugin), nameof(AfterLuaInit)));
                harmony.Patch(AccessTools.Method(typeof(LuaInterface), "RunProtectedCall"),
                    prefix: new HarmonyMethod(typeof(ShatterPlugin), nameof(BeforeProtectedCall)));
                ChasmEvents.Install(harmony);
                ChasmNavigation.Install(harmony);
                FractureProps.Install(harmony);
                harmony.Patch(AccessTools.DeclaredMethod(typeof(RangesRenderer), "CalculateBoundSize",
                    new[] { typeof(Vector3), typeof(Vector3), typeof(Plane), typeof(Rect), typeof(float) }),
                    postfix: new HarmonyMethod(typeof(ShatterEffect), nameof(ShatterEffect.CoverVisibleOpenings)));
                MapManager.OnMapUnloaded.Register(Clear);
                Logger.LogInfo("Yolona shatter registered; Lua-owned read strings preserve the native file cache.");
            }
            catch
            {
                ChasmEvents.Stop();
                harmony.UnpatchSelf();
                harmony = null;
                instance = null;
                throw;
            }
        }

        private static void BeforeLuaInit(bool isClient, out Initializing __state)
        {
            __state = initializing;
            initializing = isClient ? Initializing.Client : Initializing.Host;
        }

        private static void AfterLuaInit(Initializing __state)
        {
            initializing = __state;
        }

        private static void BeforeProtectedCall(lua_State luaState, int parameterCount, int returnValueCount)
        {
            // InitLuaState calls SecureInit with three parameters, executes the
            // script chunk with none, then calls init(libPath,isClient). This last
            // boundary follows sandbox/FFI setup and precedes every normal import.
            if (initializing == Initializing.None || parameterCount != 2 || returnValueCount != 0
                || ReferenceEquals(instance, null)) return;
            int top = LuaJIT.lua_gettop(luaState);
            try
            {
                LuaJIT.lua_getglobal(luaState, "init");
                bool callingInit = LuaJIT.lua_isfunction(luaState, -1) != 0
                    && LuaJIT.lua_rawequal(luaState, -1, -parameterCount - 2) != 0;
                LuaJIT.lua_settop(luaState, top);
                if (!callingInit) return;
                bool client = initializing == Initializing.Client;
                ChasmEvents.Register(luaState, client);
                if (client)
                {
                    LuaJIT.lua_getglobal(luaState, "Engine");
                    LuaJIT.lua_pushcclosure(luaState, NativeImpact, 0);
                    LuaJIT.lua_setfield(luaState, -2, "SCOShatter");
                    LuaJIT.lua_settop(luaState, top);
                }
                else ChasmProjectiles.InstallLua(luaState);
                byte[] script = Encoding.UTF8.GetBytes(ChasmEvents.ReadHookScript() + "\n" +
                    (client ? ImpactHook.ReadHookScript() + "\n" + ChasmMassPointView.ReadHookScript()
                        : ChasmProjectiles.ReadHookScript()));
                int status = LuaJIT.luaL_loadbuffer(luaState, script, (ulong)script.Length, "@SCOM/YolonaShatterReadHook");
                if (status == 0) status = LuaJIT.lua_pcall(luaState, 0, 0, 0);
                if (status != 0)
                    instance.Logger.LogWarning("Yolona shatter read hook failed: " + LuaJIT.lua_tostring(luaState, -1));
                else
                    instance.Logger.LogInfo("Yolona shatter registered in " + (client ? "client" : "host") + " simulation.");
            }
            catch (Exception error)
            {
                instance?.Logger.LogWarning("Yolona shatter read hook was skipped: " + error.Message);
            }
            finally { LuaJIT.lua_settop(luaState, top); }
        }

        private static int ReceiveImpact(lua_State state)
        {
            bool accepted = false;
            try
            {
                if (acceptingImpacts && LuaJIT.lua_gettop(state) == 5
                    && LuaJIT.lua_type(state, 4) == LuaJIT.LUA_TNUMBER && LuaJIT.lua_type(state, 5) == LuaJIT.LUA_TNUMBER)
                {
                    double index = LuaJIT.lua_tonumber(state, 4), generation = LuaJIT.lua_tonumber(state, 5);
                    if (index > 0 && index <= uint.MaxValue && index == Math.Floor(index)
                        && generation >= 0 && generation <= uint.MaxValue && generation == Math.Floor(generation))
                        accepted = ChasmWorld.MarkVisibleImpact((uint)index, (uint)generation);
                }
            }
            catch { /* An optional visual cannot throw through a native callback. */ }
            LuaJIT.lua_pushboolean(state, accepted ? 1 : 0);
            return 1;
        }

        private void Update()
        {
            if (!Surface.TryGetBounds(out _))
            {
                acceptingImpacts = false;
                preparedSession = int.MinValue;
                prepared = false;
                return;
            }
            // The collider is independent of camera visibility and albedo readiness.
            if (Time.unscaledTime >= nextTerrainTry &&
                (pendingTerrain != null || ChasmWorld.TryDequeue(true, out pendingTerrain)))
            {
                try
                {
                    ChasmTerrain.Commit(MapManager.Terrain, pendingTerrain);
                    pendingTerrain.SettledRuns = null;
                    pendingTerrain = null;
                    nextTerrainTry = 0;
                }
                catch (Exception error)
                {
                    if (nextTerrainTry == 0) Logger.LogWarning("Terrain collider rebuild delayed: " + error.Message);
                    nextTerrainTry = Time.unscaledTime + 1f;
                }
            }
            int currentSession = Surface.SessionId;
            if (preparedSession != currentSession)
            {
                preparedSession = currentSession;
                prepared = false;
                try { prepared = ShatterEffect.Prepare(); }
                catch (Exception error) { Logger.LogWarning("Campaign shatter presentation unavailable: " + error.Message); }
            }
            acceptingImpacts = prepared && SurfaceOpening.CanDraw();
            if (acceptingImpacts && ChasmWorld.TryDequeue(false, out var site)) ShatterEffect.Play(site);
        }

        private static void Clear()
        {
            acceptingImpacts = false;
            if (!ReferenceEquals(instance, null))
            {
                instance.preparedSession = int.MinValue;
                instance.prepared = false;
                instance.pendingTerrain = null;
                instance.nextTerrainTry = 0;
            }
            ChasmTerrain.Clear();
            ShatterEffect.Clear();
        }

        private void OnDestroy()
        {
            if (instance != this) return;
            MapManager.OnMapUnloaded.Unregister(Clear);
            ChasmEvents.Stop();
            harmony?.UnpatchSelf();
            Clear();
            ChasmWorld.Reset(true);
            ChasmWorld.Reset(false);
            instance = null;
        }
    }
}
