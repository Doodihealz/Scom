using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using EM.DOTS.Engine.Loader;
using EM.Lua;
using EM.Network;
using EM.Network.Lobby;
using EM.UI;
using HarmonyLib;
using Unity.Collections;

namespace SupComStyleUI;

internal static class BuildRestrictionBackend
{
    private const uint TrailerMarker = 0x52554353; // SCUR
    private const byte TrailerVersion = 1;
    private const int HeaderLength = 9;
    private const int MaximumPayload = 32768;
    private const int MaximumIdLength = 96;
    private static readonly HashSet<string> allowedIds = new HashSet<string>(StringComparer.Ordinal);
    private static string[] hostIds = Array.Empty<string>();
    private static string[] guestIds = Array.Empty<string>();
    private static byte[] hostPayload = Array.Empty<byte>();
    private static MethodInfo broadcastState;
    private static string luaSource;
    private static string hostStartupError;
    private static Action<string> warning;
    private static bool installed;

    internal static event Action Changed;

    internal static string[] DisabledIds => (string[])(LobbyManager.isHostRunning ? hostIds : guestIds).Clone();
    internal static string StatusError { get; private set; } = string.Empty;
    internal static bool CanEdit => installed && LobbyManager.IsInLobby && LobbyManager.isHostRunning &&
        LobbyManager.hostState != null && !LobbyManager.isLocked &&
        LobbyManager.lobbyGameStatus == LobbyManager.LobbyGameStatus.lobby;

    internal static void ConfigureAllowedIds(IEnumerable<string> ids)
    {
        allowedIds.Clear();
        foreach (string id in ids)
        {
            if (IsSafeId(id))
                allowedIds.Add(id);
        }
    }

    internal static void Install(Harmony harmony, Action<string> logWarning)
    {
        if (installed)
            return;

        warning = logWarning;
        var hooks = new List<Tuple<MethodInfo, MethodInfo>>();
        try
        {
            Assembly assembly = typeof(BuildRestrictionBackend).Assembly;
            string resourceName = assembly.GetManifestResourceNames().Single(name =>
                name == "BuildRestrictions.lua" || name.EndsWith(".BuildRestrictions.lua", StringComparison.Ordinal));
            using (var stream = assembly.GetManifestResourceStream(resourceName))
            using (var reader = new StreamReader(stream))
                luaSource = reader.ReadToEnd();

            broadcastState = AccessTools.DeclaredMethod(typeof(LobbyManager), "BroadcastState", Type.EmptyTypes)
                ?? throw new MissingMethodException(typeof(LobbyManager).FullName, "BroadcastState");
            hooks.Add(ResolveHook(typeof(LobbyState), nameof(LobbyState.Serialize), nameof(SerializePostfix)));
            hooks.Add(ResolveHook(typeof(LobbyState), nameof(LobbyState.Deserialize), nameof(DeserializePostfix)));
            hooks.Add(ResolveHook(typeof(LobbyManager), nameof(LobbyManager.StartHosting), nameof(ResetPostfix)));
            hooks.Add(ResolveHook(typeof(LobbyManager), nameof(LobbyManager.LeaveLobby), nameof(ResetPostfix)));
            hooks.Add(ResolveHook(typeof(LuaInterface), nameof(LuaInterface.InitLuaState), nameof(InitLuaStatePostfix)));
            hooks.Add(ResolveHook(typeof(EngineLoader), "DoHostStartup", nameof(HostStartupPostfix)));
            foreach (var hook in hooks)
                harmony.Patch(hook.Item1, postfix: new HarmonyMethod(hook.Item2));
            installed = true;
            StatusError = string.Empty;
        }
        catch (Exception exception)
        {
            foreach (var hook in hooks)
            {
                try { harmony.Unpatch(hook.Item1, hook.Item2); }
                catch (Exception cleanupError) { warning?.Invoke("Could not remove an inactive restriction hook: " + cleanupError.Message); }
            }
            SetError("Build restrictions are unavailable: " + exception.GetBaseException().Message);
        }
    }

    internal static bool TrySetDisabled(IEnumerable<string> ids, out string error)
    {
        if (!CanEdit)
        {
            error = !installed && StatusError.Length != 0 ? StatusError : "Only the host can change restrictions before the match starts.";
            return false;
        }

        var unique = new SortedSet<string>(StringComparer.Ordinal);
        int payloadLength = 0;
        foreach (string id in ids)
        {
            if (id == null || !allowedIds.Contains(id))
            {
                error = "A restriction refers to a unit outside the SCOM catalog: " + id;
                return false;
            }
            if (unique.Add(id))
            {
                payloadLength += id.Length + 1;
                if (payloadLength > MaximumPayload)
                {
                    error = "The restriction list is too large to send to the lobby.";
                    return false;
                }
            }
        }

        string[] updated = unique.ToArray();
        error = string.Empty;
        if (hostIds.SequenceEqual(updated))
            return true;

        string[] previousIds = hostIds;
        byte[] previousPayload = hostPayload;
        hostIds = updated;
        hostPayload = Encoding.ASCII.GetBytes(string.Join("\n", updated));
        try
        {
            broadcastState.Invoke(null, null);
        }
        catch (Exception exception)
        {
            hostIds = previousIds;
            hostPayload = previousPayload;
            error = "Could not send the restrictions: " + exception.GetBaseException().Message;
            SetError(error);
            return false;
        }

        StatusError = string.Empty;
        NotifyChanged();
        return true;
    }

    private static Tuple<MethodInfo, MethodInfo> ResolveHook(Type type, string originalName, string postfixName)
    {
        MethodInfo original = AccessTools.DeclaredMethod(type, originalName)
            ?? throw new MissingMethodException(type.FullName, originalName);
        MethodInfo postfix = AccessTools.DeclaredMethod(typeof(BuildRestrictionBackend), postfixName);
        return Tuple.Create(original, postfix);
    }

    private static void SerializePostfix(LobbyState __instance, NativeList<byte> data)
    {
        if (!installed || hostPayload.Length == 0 || !ReferenceEquals(__instance, LobbyManager.hostState))
            return;

        // The stock FullState reader stops after the roster. Append only to the host's live state.
        AppendUInt32(data, TrailerMarker);
        data.Add(TrailerVersion);
        AppendUInt32(data, (uint)hostPayload.Length);
        foreach (byte value in hostPayload)
            data.Add(value);
    }

    private static void DeserializePostfix(NativeArray<byte> data, ref int bytesRead, bool __result)
    {
        if (!installed || !__result || LobbyManager.isHostRunning || !LobbyManager.IsInLobby ||
            bytesRead < 0 || bytesRead > data.Length)
            return;

        int remaining = data.Length - bytesRead;
        if (remaining < 4 || ReadUInt32(data, bytesRead) != TrailerMarker)
        {
            SetGuestIds(Array.Empty<string>(), string.Empty);
            return;
        }
        if (remaining < HeaderLength || data[bytesRead + 4] != TrailerVersion)
        {
            SetGuestIds(Array.Empty<string>(), "The host uses an unsupported unit restriction format.");
            return;
        }

        uint length = ReadUInt32(data, bytesRead + 5);
        if (length == 0 || length > MaximumPayload || length != remaining - HeaderLength)
        {
            SetGuestIds(Array.Empty<string>(), "The host sent an invalid unit restriction list.");
            return;
        }

        var chars = new char[(int)length];
        for (int i = 0; i < chars.Length; i++)
            chars[i] = (char)data[bytesRead + HeaderLength + i];
        string[] ids = new string(chars).Split('\n');
        if (!ids.All(IsSafeId) || ids.Distinct(StringComparer.Ordinal).Count() != ids.Length)
        {
            SetGuestIds(Array.Empty<string>(), "The host sent an invalid unit restriction list.");
            return;
        }

        bytesRead += HeaderLength + chars.Length;
        SetGuestIds(ids, string.Empty);
    }

    private static void InitLuaStatePostfix(bool isClient, ref lua_State __result)
    {
        if (!installed || !LobbyManager.IsInLobby || NetworkManager.IsReplayPlayback ||
            (isClient ? LobbyManager.lobbyGameStatus != LobbyManager.LobbyGameStatus.loading : !LobbyManager.isLocked))
            return;

        string[] ids = LobbyManager.isHostRunning ? hostIds : guestIds;
        if (ids.Length == 0)
            return;

        try
        {
            if (__result.IsNull)
                throw new InvalidOperationException("The game did not initialize the Lua state.");
            var source = new StringBuilder("local disabled = {\n");
            foreach (string id in ids)
                source.Append("['").Append(id).Append("']=true,\n");
            source.Append("}\n").Append(luaSource);
            byte[] bytes = Encoding.UTF8.GetBytes(source.ToString());
            int top = LuaJIT.lua_gettop(__result);
            try
            {
                if (LuaJIT.luaL_loadbuffer(__result, bytes, (ulong)bytes.Length, "@SupComStyleUI/BuildRestrictions.lua") != 0 ||
                    LuaJIT.lua_pcall(__result, 0, 0, 0) != 0)
                    throw new InvalidOperationException(LuaJIT.lua_tostring(__result, -1) ?? "Unknown Lua error.");
            }
            finally
            {
                LuaJIT.lua_settop(__result, top);
            }
        }
        catch (Exception exception)
        {
            string world = isClient ? "client" : "host";
            string error = "Could not apply unit restrictions to the " + world + ": " + exception.GetBaseException().Message;
            SetError(error);
            if (!isClient)
                hostStartupError = error;
        }
    }

    private static void HostStartupPostfix(ref IEnumerator __result)
    {
        if (installed && LobbyManager.IsInLobby && hostIds.Length != 0)
            __result = GuardHostStartup(__result);
    }

    private static IEnumerator GuardHostStartup(IEnumerator startup)
    {
        hostStartupError = null;
        try
        {
            while (startup.MoveNext())
            {
                if (hostStartupError != null)
                {
                    // The game yields after host Lua setup, before notifying clients or starting simulation.
                    try
                    {
                        EngineLoader.Instance.CleanUpGame();
                        InterfaceManager.Instance?.TransitionTo(InterfaceManager.Window.Home);
                    }
                    catch (Exception exception)
                    {
                        warning?.Invoke("Could not clean up the stopped match: " + exception.GetBaseException().Message);
                    }
                    yield break;
                }
                yield return startup.Current;
            }
        }
        finally
        {
            (startup as IDisposable)?.Dispose();
        }
    }

    private static void ResetPostfix()
    {
        ScomTerrainOption.Reset();
        hostIds = Array.Empty<string>();
        guestIds = Array.Empty<string>();
        hostPayload = Array.Empty<byte>();
        hostStartupError = null;
        if (installed)
            StatusError = string.Empty;
        NotifyChanged();
    }

    private static void SetGuestIds(string[] ids, string error)
    {
        if (guestIds.SequenceEqual(ids) && StatusError == error)
            return;
        guestIds = ids;
        StatusError = error;
        if (error.Length != 0)
            warning?.Invoke(error);
        NotifyChanged();
    }

    private static void SetError(string error)
    {
        StatusError = error;
        warning?.Invoke(error);
        NotifyChanged();
    }

    private static void NotifyChanged()
    {
        try { Changed?.Invoke(); }
        catch (Exception exception) { warning?.Invoke("Unit Manager refresh failed: " + exception.Message); }
    }

    private static bool IsSafeId(string id)
    {
        if (string.IsNullOrEmpty(id) || id.Length > MaximumIdLength)
            return false;
        foreach (char c in id)
        {
            if (!(c >= 'a' && c <= 'z') && !(c >= 'A' && c <= 'Z') &&
                !(c >= '0' && c <= '9') && c != '_' && c != '-')
                return false;
        }
        return true;
    }

    private static void AppendUInt32(NativeList<byte> data, uint value)
    {
        for (int i = 0; i < 4; i++)
            data.Add((byte)(value >> (8 * i)));
    }

    private static uint ReadUInt32(NativeArray<byte> data, int offset) =>
        (uint)data[offset] | ((uint)data[offset + 1] << 8) |
        ((uint)data[offset + 2] << 16) | ((uint)data[offset + 3] << 24);
}
