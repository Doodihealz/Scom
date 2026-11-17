using System;
using System.Collections.Generic;
using System.Linq;
using BepInEx.Configuration;
using UnityEngine;

namespace SupComStyleUI;

internal sealed class LobbyPreferences
{
    private readonly ConfigFile config;
    public readonly ConfigEntry<bool> Enabled;
    public readonly ConfigEntry<bool> HudEnabled;
    public readonly ConfigEntry<float> FontSize;
    public readonly ConfigEntry<string> CustomGroups;
    private readonly ConfigEntry<string> selectedGroups;
    private readonly ConfigEntry<string> individualIds;
    // There is one authored SCOM appearance. Disabling it restores the native
    // blue palette for mod-owned controls too; this is not a theme selection.
    // Old color configuration keys remain unbound and cannot override either.
    public Color Accent => Enabled.Value ? new Color32(215, 187, 112, 255) : new Color32(50, 174, 255, 255);
    public Color Panel => Enabled.Value ? new Color32(28, 27, 23, 255) : new Color32(22, 35, 45, 255);
    public Color Text => Enabled.Value ? new Color32(255, 249, 232, 255) : new Color32(235, 238, 240, 255);
    public Color MutedText => Enabled.Value ? new Color32(220, 208, 172, 255) : Color.Lerp(Text, Panel, .3f);
    public Color Control => Enabled.Value ? new Color32(21, 21, 18, 255) : Color.Lerp(Panel, Color.black, .12f);

    public LobbyPreferences(ConfigFile config)
    {
        this.config = config;
        Enabled = BindLobbyEnabled(config);
        HudEnabled = BindHudEnabled(config);
        FontSize = config.Bind("Lobby", "UnitManagerFontSize", 17f, new ConfigDescription("Unit Manager body font size.", new AcceptableValueRange<float>(14f, 20f)));
        CustomGroups = config.Bind("UnitManager", "CustomGroups", "", "Optional additional groups: No air or scouts:AIR|SCOUT;No Shimmer:uca1001. Selectors are exact installed SCOM tags or unit IDs joined by | (OR). Labels are separated by semicolons. Up to 32 groups. The catalog search also searches tags. Reopen Unit Manager, then choose groups and Apply.");
        selectedGroups = config.Bind("UnitManager", "SavedGroups", "", "Remembered group keys, separated by semicolons. Load saved in the Unit Manager to apply them to a lobby.");
        individualIds = config.Bind("UnitManager", "SavedDisabledUnits", "", "Remembered individually disabled SCOM IDs, separated by commas. Load saved then Apply. Group bans also apply; clearing a group does not clear individual bans.");
    }

    public void LoadSaved(out HashSet<string> groups, out HashSet<string> ids)
    {
        groups = new HashSet<string>(selectedGroups.Value.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries), StringComparer.Ordinal);
        ids = new HashSet<string>(individualIds.Value.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries), StringComparer.Ordinal);
    }

    public void Save(IEnumerable<string> groups, IEnumerable<string> ids)
    {
        selectedGroups.Value = string.Join(";", groups.OrderBy(v => v, StringComparer.Ordinal));
        individualIds.Value = string.Join(",", ids.OrderBy(v => v, StringComparer.Ordinal));
        config.Save();
    }

    public void Reload() => config.Reload();

    public static ConfigEntry<bool> BindLobbyEnabled(ConfigFile config)
        => config.Bind("SCOM UI", "Enabled", false, "Use SCOM's optional front-end, loading-screen, and lobby appearance and layout. Off restores the original interface, colors, and background while retaining the small SCOM logo subtitle. This local choice is saved for this player; new installations start with it off.");

    public static ConfigEntry<bool> BindHudEnabled(ConfigFile config)
    {
        // Preserve a previously saved shared UI choice on the first upgrade.
        // Once written, the two entries are independent. A new installation's
        // lobby entry defaults to false, so its HUD also starts disabled.
        var lobby = BindLobbyEnabled(config);
        return config.Bind("SCOM UI", "InGameEnabled", lobby.Value, "Use SCOM's optional in-game HUD. This local choice is saved independently of the SCOM front-end UI.");
    }

    public void SetEnabled(bool enabled) => SetSaved(Enabled, enabled);
    public void SetHudEnabled(bool enabled) => SetSaved(HudEnabled, enabled);

    private void SetSaved(ConfigEntry<bool> entry, bool enabled)
    {
        bool previous = entry.Value;
        try
        {
            entry.Value = enabled;
            config.Save();
        }
        catch
        {
            // A failed save must not leave the current screen showing a choice
            // that will disappear on the next launch.
            entry.Value = previous;
            throw;
        }
    }

}
