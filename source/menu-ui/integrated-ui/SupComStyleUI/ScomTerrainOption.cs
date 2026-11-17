using System;
using System.Linq;
using EM.Network;

namespace SupComStyleUI;

internal static class ScomTerrainOption
{
    private static Type module;
    private static Type Module => module ?? (module = AppDomain.CurrentDomain.GetAssemblies()
        .Select(a => a.GetType("ScomTerrainDeformation.EmbeddedModule", false)).FirstOrDefault(t => t != null));

    public static bool IsAvailable => ReadFlag("IsAvailable");
    public static bool IsEnabled => ReadFlag("IsEnabled");
    public static bool IsLocalLobby => LobbyManager.IsInLobby && LobbyManager.IsCurrentUserHost() &&
        LobbyManager.hostState != null && LobbyManager.hostState.GetPlayers(includeAIs: false, includeObservers: true).Count(p => p.IsHumanPlayer) == 1;

    private static bool ReadFlag(string name)
    {
        try { return Module != null && (bool)Module.GetProperty(name).GetValue(null, null); }
        catch { return false; }
    }

    public static bool TrySet(bool enabled, out string error)
    {
        error = "";
        if (enabled && !IsLocalLobby)
        {
            error = "Terrain deformation supports a local host with AI only. Remote players and observers are unsupported.";
            return false;
        }
        try
        {
            if (Module == null)
            {
                if (!enabled) return true;
                error = "The installed SCOM build does not include terrain deformation.";
                return false;
            }
            if (enabled && !IsAvailable)
            {
                error = (string)Module.GetProperty("LastError").GetValue(null, null);
                if (string.IsNullOrEmpty(error)) error = "SCOM terrain support is not ready.";
                return false;
            }
            Module.GetMethod("SetEnabled").Invoke(null, new object[] { enabled });
            if (IsEnabled != enabled) throw new InvalidOperationException("The terrain option could not be applied.");
            return true;
        }
        catch (Exception ex) { error = "Terrain option: " + ex.GetBaseException().Message; return false; }
    }

    public static void Reset()
    {
        if (IsEnabled && !TrySet(false, out string error)) UnityEngine.Debug.LogWarning(error);
    }
}
