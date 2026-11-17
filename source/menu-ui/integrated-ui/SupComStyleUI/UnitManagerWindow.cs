using System;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using EM.Network;
using Object = UnityEngine.Object;

namespace SupComStyleUI;

internal sealed class UnitManagerWindow : IDisposable
{
    private readonly UnitCatalog catalog;
    private readonly LobbyControls ui;
    private readonly Action close;
    private readonly RectTransform overlay, panel, rows, groupsViewport, groupsContent, groupsTrack, headerRule, footerRule;
    private readonly Canvas modalCanvas;
    private readonly TextMeshProUGUI title, subtitle, groupsHeading, terrainHint, summary, pageLabel, status;
    private readonly TextMeshProUGUI[] columnHeaders;
    private readonly TMP_InputField search;
    private readonly Button terrainButton, view, apply, previous, next, allowAll, loadSaved, restrictMatches, allowMatches, cancel;
    private readonly Dictionary<string, TextMeshProUGUI> groupLabels = new Dictionary<string, TextMeshProUGUI>();
    private readonly Dictionary<string, Button> groupButtons = new Dictionary<string, Button>();
    private readonly List<GroupEntry> groupEntries = new List<GroupEntry>();
    private readonly List<UnitRow> unitRows = new List<UnitRow>();
    private readonly List<Button> editingButtons = new List<Button>();
    private readonly bool editable;
    private readonly GameObject previousSelection;
    private readonly bool openedInLobby;
    private HashSet<string> groups = new HashSet<string>(StringComparer.Ordinal);
    private HashSet<string> individuals;
    private HashSet<string> effective;
    private string query = "";
    private bool blockedOnly;
    private int page, pageSize = 1;
    private bool terrainEnabled, disposed;
    private UnitManagerLayout layout;
    private Vector2 previousSize, previousCenter;
    private float previousFont;

    private sealed class UnitRow
    {
        public RectTransform Root;
        public TextMeshProUGUI Name, Id, Faction, Tier, State;
        public Button Toggle;
        public string UnitId;
    }

    private sealed class GroupEntry
    {
        public RectTransform Root;
        public TextMeshProUGUI Label;
        public bool Section;
    }

    public UnitManagerWindow(Transform parent, LobbyControls ui, UnitCatalog catalog, Action close)
    {
        this.ui = ui = ui.ForUnitManager();
        this.catalog = catalog;
        this.close = close;
        editable = BuildRestrictionBackend.CanEdit;
        openedInLobby = LobbyManager.IsInLobby;
        previousSelection = EventSystem.current != null ? EventSystem.current.currentSelectedGameObject : null;
        if (EventSystem.current != null) EventSystem.current.SetSelectedGameObject(null);
        individuals = new HashSet<string>(BuildRestrictionBackend.DisabledIds, StringComparer.Ordinal);
        ui.Theme.LoadSaved(out var savedGroups, out var savedIds);
        if (editable && SavedRulesAvailable(savedGroups, savedIds) && catalog.Resolve(savedGroups, savedIds).SetEquals(individuals))
        { groups = savedGroups; individuals = savedIds; }

        overlay = LobbyControls.Rect("SupCom Unit Manager", parent, 0, 0, 0, 0);
        // Retain the lobby page's native visibility/input gate, but draw the
        // modal over the whole root canvas, including its order-300 sidebar.
        modalCanvas = overlay.gameObject.AddComponent<Canvas>();
        modalCanvas.overrideSorting = true;
        modalCanvas.sortingOrder = 400;
        overlay.gameObject.AddComponent<GraphicRaycaster>();
        var blocker = overlay.gameObject.AddComponent<Image>();
        blocker.color = Color.clear;
        blocker.canvasRenderer.cullTransparentMesh = false;
        blocker.raycastTarget = true;
        panel = LobbyControls.Rect("Unit Manager", overlay, 0, 0, 1, 1);
        panel.anchorMin = panel.anchorMax = panel.pivot = new Vector2(.5f, .5f);
        ui.Panel(panel, true);
        title = ui.Label(panel, "UNIT MANAGER", 0, 0, 1, 1, 26);
        title.fontStyle = FontStyles.Bold;
        title.characterSpacing = 1.2f;
        subtitle = ui.Label(panel, "SCOM  /  Build restrictions for every player and AI", 0, 0, 1, 1, 15);
        subtitle.color = ui.Theme.MutedText;
        terrainEnabled = ScomTerrainOption.IsEnabled;
        terrainButton = ui.Button(panel, "Terrain deformation: " + (terrainEnabled ? "ON" : "OFF"), 0, 0, 320, 32, () =>
        {
            if (!terrainEnabled && !ScomTerrainOption.IsLocalLobby)
            {
                status.text = "Terrain deformation is available for a local host with AI; remote participants are unsupported.";
                return;
            }
            terrainEnabled = !terrainEnabled;
            terrainButton.GetComponentInChildren<TextMeshProUGUI>().text = "Terrain deformation: " + (terrainEnabled ? "ON" : "OFF");
        });
        terrainButton.interactable = editable && ScomTerrainOption.IsAvailable;
        terrainHint = ui.Label(panel, ScomTerrainOption.IsAvailable ? "LOCAL MATCH OPTION  /  Defaults to off each lobby" : "Requires embedded SCOM terrain support", 0, 0, 1, 1, 12);
        terrainHint.color = ui.Theme.MutedText;
        status = ui.Label(panel, editable ? "Apply commits all changes. Units that produce a banned unit are also restricted. Starting commanders are unaffected." : "Host-controlled rules. This lobby is read-only for you.", 0, 0, 1, 1, 13);
        status.color = ui.Theme.MutedText;
        status.textWrappingMode = TextWrappingModes.Normal;
        headerRule = Rule("Header rule");
        footerRule = Rule("Footer rule");
        groupsHeading = ui.Label(panel, "RESTRICTION GROUPS", 0, 0, 1, 1, 13);
        groupsHeading.color = ui.Theme.Accent;
        groupsHeading.fontStyle = FontStyles.Bold;
        groupsHeading.characterSpacing = 1;
        groupsViewport = LobbyControls.Rect("Groups viewport", panel, 0, 0, 1, 1);
        ui.Panel(groupsViewport, true).FillColor = ui.Theme.Control;
        groupsViewport.gameObject.AddComponent<RectMask2D>();
        var scroll = groupsViewport.gameObject.AddComponent<ScrollRect>();
        scroll.viewport = groupsViewport;
        scroll.horizontal = false;
        scroll.scrollSensitivity = 34;
        scroll.movementType = ScrollRect.MovementType.Clamped;
        groupsContent = LobbyControls.Rect("Groups", groupsViewport, 0, 0, 1, 1);
        scroll.content = groupsContent;
        BuildGroups();
        groupsTrack = LobbyControls.Rect("Scroll track", groupsViewport, 0, 0, 6, 1);
        groupsTrack.gameObject.AddComponent<Image>().color = Color.Lerp(ui.Theme.Control, ui.Theme.Accent, .16f);
        var handle = LobbyControls.Rect("Handle", groupsTrack, 0, 0, 6, 60);
        var handleImage = handle.gameObject.AddComponent<Image>();
        handleImage.color = ui.Theme.Accent;
        var scrollbar = groupsTrack.gameObject.AddComponent<Scrollbar>();
        scrollbar.navigation = new Navigation { mode = Navigation.Mode.None };
        scrollbar.handleRect = handle;
        scrollbar.targetGraphic = handleImage;
        scrollbar.direction = Scrollbar.Direction.BottomToTop;
        scroll.verticalScrollbar = scrollbar;
        search = ui.Search(panel, 0, 0, 400, 34, text => { query = text.Trim().ToLowerInvariant(); page = 0; RefreshRows(); });
        view = ui.Button(panel, "Show: all", 0, 0, 170, 34, () =>
        {
            blockedOnly = !blockedOnly;
            view.GetComponentInChildren<TextMeshProUGUI>().text = blockedOnly ? "Show: restricted" : "Show: all";
            page = 0;
            RefreshRows();
        });
        columnHeaders = new[] { "UNIT", "ID", "FACTION", "TIER", "BUILDABLE" }.Select(text =>
        {
            var label = ui.Label(panel, text, 0, 0, 1, 1, 13);
            label.color = ui.Theme.Accent;
            label.fontStyle = FontStyles.Bold;
            label.characterSpacing = .6f;
            return label;
        }).ToArray();
        rows = LobbyControls.Rect("Unit rows", panel, 0, 0, 1, 1);
        rows.gameObject.AddComponent<RectMask2D>();
        summary = ui.Label(panel, "", 0, 0, 1, 1, 15);
        previous = ui.Button(panel, "<", 0, 0, 40, 30, () => { page--; RefreshRows(); });
        pageLabel = ui.Label(panel, "", 0, 0, 120, 30, 14);
        pageLabel.alignment = TextAlignmentOptions.Center;
        next = ui.Button(panel, ">", 0, 0, 40, 30, () => { page++; RefreshRows(); });
        allowAll = ui.Button(panel, "Allow all", 0, 0, 108, 32, () => { groups.Clear(); individuals.Clear(); Refresh(); });
        loadSaved = ui.Button(panel, "Load saved", 0, 0, 120, 32, LoadSaved);
        restrictMatches = ui.Button(panel, "Restrict matches", 0, 0, 146, 32, () =>
        {
            foreach (var unit in Filtered()) if (!effective.Contains(unit.Id)) individuals.Add(unit.Id);
            Refresh();
        });
        allowMatches = ui.Button(panel, "Allow matches", 0, 0, 134, 32, () =>
        {
            foreach (var unit in Filtered().ToArray()) individuals.Remove(unit.Id);
            Refresh();
            status.text = "Individual bans cleared for all search matches. Active restriction groups still apply.";
        });
        cancel = ui.Button(panel, editable ? "Cancel" : "Close", 0, 0, 120, 32, () => close());
        apply = ui.Button(panel, "Apply", 0, 0, 132, 32, Apply);
        editingButtons.AddRange(new[] { allowAll, loadSaved, restrictMatches, allowMatches, apply });
        foreach (var button in editingButtons) button.interactable = editable;
        Resize();
        Refresh();
        BuildRestrictionBackend.Changed += OnHostRulesChanged;
    }

    private RectTransform Rule(string name)
    {
        var rect = LobbyControls.Rect(name, panel, 0, 0, 1, 1);
        var image = rect.gameObject.AddComponent<Image>();
        var color = ui.Theme.Accent; color.a = .25f;
        image.color = color;
        image.raycastTarget = false;
        return rect;
    }

    private void BuildGroups()
    {
        string section = null;
        foreach (var group in catalog.Groups)
        {
            if (section != group.Section)
            {
                section = group.Section;
                var label = ui.Label(groupsContent, section, 0, 0, 1, 1, 12);
                label.color = ui.Theme.Accent;
                label.fontStyle = FontStyles.Bold;
                label.characterSpacing = .8f;
                groupEntries.Add(new GroupEntry { Root = label.rectTransform, Label = label, Section = true });
            }
            var captured = group;
            var button = ui.Button(groupsContent, "", 0, 0, 1, 30, () =>
            {
                if (!groups.Remove(captured.Key)) groups.Add(captured.Key);
                Refresh();
            });
            button.interactable = editable && group.UnitIds.Count > 0;
            var text = button.GetComponentInChildren<TextMeshProUGUI>();
            groupButtons[group.Key] = button;
            groupLabels[group.Key] = text;
            groupEntries.Add(new GroupEntry { Root = (RectTransform)button.transform, Label = text });
        }
    }

    private IEnumerable<CatalogUnit> Filtered()
    {
        var words = query.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
        return catalog.Units.Where(u => (!blockedOnly || effective.Contains(u.Id)) && words.All(w => u.SearchText.Contains(w)));
    }

    private void Refresh()
    {
        effective = catalog.Resolve(groups, individuals);
        foreach (var group in catalog.Groups)
        {
            groupLabels[group.Key].text = (groups.Contains(group.Key) ? "[x] " : "[  ] ") + group.Label + "  (" + group.UnitIds.Count + ")";
            ui.StyleButton(groupButtons[group.Key], groups.Contains(group.Key));
            FormatGroupLabel(groupLabels[group.Key]);
        }
        RefreshRows();
    }

    private void FormatGroupLabel(TextMeshProUGUI label)
    {
        label.alignment = TextAlignmentOptions.MidlineLeft;
        label.fontSize = Math.Min(15f, ui.Theme.FontSize.Value);
        label.fontStyle = FontStyles.Normal;
        label.characterSpacing = 0;
    }

    private void EnsureRows(int count)
    {
        while (unitRows.Count < count)
        {
            int index = unitRows.Count;
            var row = new UnitRow { Root = LobbyControls.Rect("Unit row", rows, 0, 0, 1, 1) };
            var background = row.Root.gameObject.AddComponent<Image>();
            background.color = Color.Lerp(ui.Theme.Panel, ui.Theme.Text, index % 2 == 0 ? .025f : .065f);
            background.raycastTarget = false;
            row.Name = ui.Label(row.Root, "", 0, 0, 1, 1);
            row.Id = ui.Label(row.Root, "", 0, 0, 1, 1, 15);
            row.Id.color = ui.Theme.MutedText;
            row.Faction = ui.Label(row.Root, "", 0, 0, 1, 1, 16);
            row.Tier = ui.Label(row.Root, "", 0, 0, 1, 1, 16);
            row.Toggle = ui.Button(row.Root, "", 0, 0, 120, 26, () =>
            {
                if (!BuildRestrictionBackend.CanEdit || string.IsNullOrEmpty(row.UnitId)) return;
                if (!individuals.Remove(row.UnitId)) individuals.Add(row.UnitId);
                Refresh();
            });
            row.State = row.Toggle.GetComponentInChildren<TextMeshProUGUI>();
            unitRows.Add(row);
        }
    }

    private void RefreshRows()
    {
        if (rows == null || effective == null) return;
        var filtered = Filtered().ToList();
        int pages = UnitManagerLayout.PageCount(filtered.Count, pageSize);
        page = UnitManagerLayout.ClampPage(page, filtered.Count, pageSize);
        for (int i = 0; i < unitRows.Count; i++)
        {
            var row = unitRows[i];
            int index = page * pageSize + i;
            bool visible = i < pageSize && index < filtered.Count;
            row.Root.gameObject.SetActive(visible);
            if (!visible) { row.UnitId = null; continue; }
            var unit = filtered[index];
            bool blocked = effective.Contains(unit.Id);
            bool byGroup = catalog.Groups.Any(g => groups.Contains(g.Key) && g.UnitIds.Contains(unit.Id));
            bool byProduct = blocked && !byGroup && !individuals.Contains(unit.Id);
            row.UnitId = unit.Id;
            row.Name.text = unit.Name;
            row.Id.text = unit.Id;
            row.Faction.text = unit.Faction;
            row.Tier.text = unit.Tier;
            row.State.text = byGroup ? "Group ban" : byProduct ? "Linked ban" : blocked ? "Disabled" : "Enabled";
            row.Toggle.interactable = editable && !byGroup && !byProduct;
            ui.StyleStateButton(row.Toggle, blocked, byGroup || byProduct);
            row.State.fontSize = 13;
            row.State.characterSpacing = 0;
        }
        summary.text = effective.Count + " / " + catalog.Units.Count + " restricted  ·  " + filtered.Count + " shown  ·  " + groups.Count + " groups";
        pageLabel.text = (page + 1) + " / " + pages;
        previous.interactable = page > 0;
        next.interactable = page + 1 < pages;
        if (!string.IsNullOrEmpty(BuildRestrictionBackend.StatusError)) status.text = BuildRestrictionBackend.StatusError;
    }

    private void Apply()
    {
        if (!BuildRestrictionBackend.CanEdit) { status.text = "Only the current lobby host can change these rules."; return; }
        bool previousTerrain = ScomTerrainOption.IsEnabled;
        if (!ScomTerrainOption.TrySet(terrainEnabled, out string error)) { status.text = error; return; }
        if (!BuildRestrictionBackend.TrySetDisabled(effective, out error))
        {
            if (!ScomTerrainOption.TrySet(previousTerrain, out string rollbackError)) error += " " + rollbackError;
            status.text = error;
            return;
        }
        try { ui.Theme.Save(groups, individuals); }
        catch (Exception ex) { status.text = "Lobby rules applied, but saving defaults failed: " + ex.Message; return; }
        close();
    }

    private void LoadSaved()
    {
        ui.Theme.LoadSaved(out var savedGroups, out var savedIds);
        if (!SavedRulesAvailable(savedGroups, savedIds))
        {
            status.text = "Saved rules refer to missing groups or units. Fix custom edits before loading them; current edits are unchanged.";
            return;
        }
        groups = savedGroups;
        individuals = savedIds;
        Refresh();
    }

    private bool SavedRulesAvailable(HashSet<string> savedGroups, HashSet<string> savedIds) =>
        savedGroups.All(key => catalog.Groups.Any(g => g.Key == key)) && savedIds.All(catalog.Ids.Contains);

    private void OnHostRulesChanged()
    {
        if (editable)
        {
            if (!BuildRestrictionBackend.CanEdit) { foreach (var button in editingButtons) button.interactable = false; status.text = "Host changed. Reopen the Unit Manager to edit the current lobby."; }
            return;
        }
        groups.Clear();
        individuals = new HashSet<string>(BuildRestrictionBackend.DisabledIds, StringComparer.Ordinal);
        status.text = "Host-controlled rules. This lobby is read-only for you.";
        Refresh();
    }

    public bool AuthorityUnchanged => editable == BuildRestrictionBackend.CanEdit && openedInLobby == LobbyManager.IsInLobby;
    public void ShowStatus(string message) => status.text = message;

    private static void Place(RectTransform rect, float x, float y, float width, float height)
    {
        rect.anchorMin = rect.anchorMax = rect.pivot = new Vector2(0, 1);
        rect.anchoredPosition = new Vector2(x, -y);
        rect.sizeDelta = new Vector2(Mathf.Max(1, width), Mathf.Max(1, height));
        rect.localScale = Vector3.one;
    }

    private static void Place(Component component, float x, float y, float width, float height)
        => Place((RectTransform)component.transform, x, y, width, height);

    private Rect FitOverlayToRootCanvas()
    {
        var parent = (RectTransform)overlay.parent;
        var rootCanvas = parent.GetComponentInParent<Canvas>()?.rootCanvas;
        var rootRect = rootCanvas != null ? rootCanvas.transform as RectTransform : parent;
        if (rootCanvas != null) modalCanvas.additionalShaderChannels = rootCanvas.additionalShaderChannels;
        Vector3[] corners = new Vector3[4];
        rootRect.GetWorldCorners(corners);
        Vector3 min = parent.InverseTransformPoint(corners[0]);
        Vector3 max = parent.InverseTransformPoint(corners[2]);
        overlay.anchorMin = overlay.anchorMax = overlay.pivot = new Vector2(.5f, .5f);
        overlay.anchoredPosition = new Vector2((min.x + max.x) * .5f - parent.rect.center.x, (min.y + max.y) * .5f - parent.rect.center.y);
        overlay.sizeDelta = new Vector2(max.x - min.x, max.y - min.y);
        overlay.localScale = Vector3.one;
        var area = overlay.rect;
        Camera camera = rootCanvas != null && rootCanvas.renderMode != RenderMode.ScreenSpaceOverlay ? rootCanvas.worldCamera : null;
        if (RectTransformUtility.ScreenPointToLocalPointInRectangle(overlay, Screen.safeArea.min, camera, out var safeMin) &&
            RectTransformUtility.ScreenPointToLocalPointInRectangle(overlay, Screen.safeArea.max, camera, out var safeMax))
        {
            float xMin = Mathf.Max(area.xMin, safeMin.x), yMin = Mathf.Max(area.yMin, safeMin.y);
            float xMax = Mathf.Min(area.xMax, safeMax.x), yMax = Mathf.Min(area.yMax, safeMax.y);
            if (xMax - xMin >= 700f && yMax - yMin >= 400f) area = Rect.MinMaxRect(xMin, yMin, xMax, yMax);
        }
        return area;
    }

    public void Resize()
    {
        if (disposed || overlay == null) return;
        Rect area = FitOverlayToRootCanvas();
        if ((previousSize - area.size).sqrMagnitude < .1f && (previousCenter - area.center).sqrMagnitude < .1f && Math.Abs(previousFont - ui.Theme.FontSize.Value) < .01f) return;
        previousSize = area.size;
        previousCenter = area.center;
        previousFont = ui.Theme.FontSize.Value;
        layout = UnitManagerLayout.Calculate(area.width, area.height, previousFont);
        page = UnitManagerLayout.PreserveFirstItemPage(page, pageSize, layout.RowsPerPage);
        pageSize = layout.RowsPerPage;
        panel.localScale = Vector3.one;
        panel.anchoredPosition = area.center - overlay.rect.center;
        panel.sizeDelta = new Vector2(layout.Width, layout.Height);
        float p = layout.Padding, w = layout.Width, h = layout.Height;
        float terrainWidth = Math.Min(330f, w * .35f);
        Place(title, p, 16, w - terrainWidth - p * 3, 32);
        Place(subtitle, p, 48, w - terrainWidth - p * 3, 22);
        Place(terrainButton, w - p - terrainWidth, 18, terrainWidth, 32);
        Place(terrainHint, w - p - terrainWidth, 52, terrainWidth, 22);
        Place(status, p, 76, w - p * 2, 28);
        Place(headerRule, p, 102, w - p * 2, 1);
        Place(groupsHeading, p, 110, layout.SidebarWidth, 26);
        Place(groupsViewport, p, 142, layout.SidebarWidth, layout.SummaryY - 152);
        float contentWidth = layout.SidebarWidth - 16f;
        float groupY = 4;
        foreach (var entry in groupEntries)
        {
            float height = entry.Section ? 26f : 30f;
            Place(entry.Root, 8, groupY, contentWidth - 16f, height);
            groupY += entry.Section ? 30f : 34f;
            if (!entry.Section) FormatGroupLabel(entry.Label);
        }
        groupsContent.sizeDelta = new Vector2(contentWidth, groupY + 6f);
        Place(groupsTrack, layout.SidebarWidth - 9, 4, 5, groupsViewport.rect.height - 8);
        Place(search, layout.CatalogX, 110, layout.CatalogWidth - 180, 34);
        Place(view, w - p - 170, 110, 170, 34);
        float[] xs = { layout.NameX, layout.IdX, layout.FactionX, layout.TierX, layout.StateX };
        float[] widths = { layout.NameWidth, layout.IdWidth, layout.FactionWidth, layout.TierWidth, layout.StateWidth };
        for (int i = 0; i < columnHeaders.Length; i++)
            Place(columnHeaders[i], layout.CatalogX + xs[i], 148, widths[i], 24);
        Place(rows, layout.CatalogX, layout.RowsY, layout.CatalogWidth, layout.RowsPerPage * layout.RowHeight);
        EnsureRows(pageSize);
        for (int i = 0; i < unitRows.Count; i++)
        {
            var row = unitRows[i];
            Place(row.Root, 0, i * layout.RowHeight, layout.CatalogWidth, layout.RowHeight - 2);
            TextMeshProUGUI[] labels = { row.Name, row.Id, row.Faction, row.Tier };
            for (int j = 0; j < labels.Length; j++) Place(labels[j], xs[j], 0, widths[j], layout.RowHeight - 2);
            row.Name.fontSize = previousFont;
            row.Id.fontSize = Math.Max(13, previousFont - 2);
            row.Faction.fontSize = row.Tier.fontSize = Math.Max(14, previousFont - 1);
            Place(row.Toggle, layout.StateX, 3, layout.StateWidth, layout.RowHeight - 8);
        }
        Place(footerRule, p, layout.SummaryY - 7, w - p * 2, 1);
        Place(summary, p, layout.SummaryY, w - p * 2 - 250, 28);
        Place(previous, w - p - 230, layout.SummaryY, 40, 30);
        Place(pageLabel, w - p - 180, layout.SummaryY, 130, 30);
        Place(next, w - p - 40, layout.SummaryY, 40, 30);
        Place(allowAll, p, layout.EditActionsY, 108, 32);
        Place(loadSaved, p + 120, layout.EditActionsY, 120, 32);
        float bulkX = w < 1100 ? p + 252 : layout.CatalogX;
        Place(restrictMatches, bulkX, layout.EditActionsY, 146, 32);
        Place(allowMatches, bulkX + 158, layout.EditActionsY, 134, 32);
        Place(cancel, w - p - 264, layout.CloseActionsY, 120, 32);
        Place(apply, w - p - 132, layout.CloseActionsY, 132, 32);
        RefreshRows();
    }

    public void Dispose()
    {
        if (disposed) return;
        disposed = true;
        BuildRestrictionBackend.Changed -= OnHostRulesChanged;
        if (overlay != null) { overlay.gameObject.SetActive(false); Object.Destroy(overlay.gameObject); }
        if (EventSystem.current != null)
            EventSystem.current.SetSelectedGameObject(previousSelection != null && previousSelection.activeInHierarchy ? previousSelection : null);
    }
}
