using System;
using BepInEx.Configuration;
using EM.UI;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using Object = UnityEngine.Object;

namespace SupComStyleUI;

internal sealed class MainMenuBackgroundSelector : IDisposable
{
    private static readonly string[] Titles = { "Slideshow", "Commander", "Battleship", "City commander" };
    private readonly MainMenuBackgroundPreferences preferences;
    private readonly LobbyPreferences theme;
    private readonly Action<string> warning;
    private readonly Button[] options = new Button[Titles.Length];
    private GameObject root;
    private GameObject popup;
    private GameObject dismiss;
    private LobbyControls controls;

    public MainMenuBackgroundSelector(ConfigFile config, MainMenuBackgroundPreferences preferences, Action<string> warning)
    {
        this.preferences = preferences;
        this.warning = warning;
        theme = new LobbyPreferences(config);
        preferences.Changed += RefreshSelection;
    }

    public void SetVisible(GameObject windows, bool visible)
    {
        if (!visible)
        {
            Close();
            if (root != null) root.SetActive(false);
            return;
        }
        if (root == null) Create(windows);
        if (root != null) root.SetActive(true);
    }

    private void Create(GameObject windows)
    {
        var canvas = windows != null ? windows.GetComponentInParent<Canvas>() : null;
        var font = HomeInterface.Instance != null ? HomeInterface.Instance.GetComponentInChildren<TMP_Text>(true)?.font : null;
        if (canvas == null || font == null) return;
        controls = new LobbyControls(theme, font, true);
        // Windows render above the native background and below native modals.
        var rect = LobbyControls.Rect("SCOM Background Selector", windows.transform, 0, 0, 0, 0);
        LobbyControls.Stretch(rect);
        rect.gameObject.layer = canvas.gameObject.layer;
        rect.SetAsLastSibling();
        rect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
        root = rect.gameObject;

        var dismissRect = LobbyControls.Rect("Close background choices", rect, 0, 0, 0, 0);
        LobbyControls.Stretch(dismissRect);
        var dismissImage = dismissRect.gameObject.AddComponent<Image>();
        dismissImage.color = Color.clear;
        dismissImage.raycastTarget = true;
        var dismissButton = dismissRect.gameObject.AddComponent<Button>();
        dismissButton.targetGraphic = dismissImage;
        dismissButton.transition = Selectable.Transition.None;
        dismissButton.navigation = new Navigation { mode = Navigation.Mode.None };
        dismissButton.onClick.AddListener(Close);
        dismiss = dismissRect.gameObject;

        var button = controls.Button(rect, "Background", 0, 0, 180, 36, Toggle);
        AnchorBottomRight((RectTransform)button.transform, 125);
        var popupRect = LobbyControls.Rect("Background choices", rect, 0, 0, 240, 15 + options.Length * 35);
        AnchorBottomRight(popupRect, 169);
        controls.Panel(popupRect, true);
        popup = popupRect.gameObject;
        for (int index = 0; index < options.Length; index++)
        {
            var choice = (MainMenuBackground)index;
            options[index] = controls.Button(popupRect, Titles[index], 8, 8 + index * 35, 224, 34, () => Select(choice));
        }
        RefreshSelection();
        Close();
    }

    private static void AnchorBottomRight(RectTransform rect, float bottom)
    {
        rect.anchorMin = rect.anchorMax = new Vector2(1, 0);
        rect.pivot = new Vector2(1, 0);
        rect.anchoredPosition = new Vector2(-32, bottom);
    }

    private void Toggle()
    {
        bool open = popup != null && !popup.activeSelf;
        if (popup != null) popup.SetActive(open);
        if (dismiss != null) dismiss.SetActive(open);
    }

    private void Close()
    {
        if (popup != null) popup.SetActive(false);
        if (dismiss != null) dismiss.SetActive(false);
    }

    private void Select(MainMenuBackground choice)
    {
        try
        {
            preferences.SetSaved(choice);
            Close();
        }
        catch (Exception error)
        {
            warning?.Invoke("The background choice could not be saved; the previous photo is unchanged. " + error.Message);
        }
    }

    private void RefreshSelection()
    {
        for (int index = 0; index < options.Length; index++)
            if (options[index] != null) controls.StyleButton(options[index], (int)preferences.Choice == index);
    }

    public void Dispose()
    {
        preferences.Changed -= RefreshSelection;
        if (root != null)
        {
            root.SetActive(false);
            root.transform.SetParent(null, false);
            Object.Destroy(root);
        }
        root = popup = dismiss = null;
        controls = null;
        Array.Clear(options, 0, options.Length);
    }
}
