using System;
using BepInEx.Configuration;

namespace SupComStyleUI;

internal enum MainMenuBackground
{
    Slideshow,
    Commander,
    Battleship,
    CityCommander
}

// Fixed artwork layers, with Commander always opaque below the other photos.
internal static class MainMenuBackgroundPlayback
{
    public const int SlideCount = 3;
    public const float HoldSeconds = 12f;
    public const float FadeSeconds = 1f;
    public const float LegSeconds = HoldSeconds + FadeSeconds;

    public static int StaticSlide(MainMenuBackground choice) => (int)choice - 1;

    public static float Alpha(int layer, int slide, float blend)
    {
        if (layer == 0) return 1;
        int next = (slide + 1) % SlideCount;
        if (layer == next) return blend;
        if (layer == slide) return next == 0 ? 1 - blend : 1;
        return 0;
    }

    public static float TargetAlpha(int layer, MainMenuBackground choice, int slideshowSlide, float slideshowBlend)
    {
        if (layer == 0) return 1;
        if (choice == MainMenuBackground.Slideshow)
            return Alpha(layer, slideshowSlide, slideshowBlend);
        return layer == StaticSlide(choice) ? 1 : 0;
    }

    public static void VisibleWeights(float battleshipAlpha, float cityAlpha, float[] weights)
    {
        weights[0] = (1 - battleshipAlpha) * (1 - cityAlpha);
        weights[1] = battleshipAlpha * (1 - cityAlpha);
        weights[2] = cityAlpha;
    }

    public static void LayerAlphas(float[] weights, out float battleshipAlpha, out float cityAlpha)
    {
        cityAlpha = weights[2];
        float belowCity = 1 - cityAlpha;
        battleshipAlpha = belowCity > .00001f ? weights[1] / belowCity : 0;
    }
}

internal sealed class MainMenuBackgroundPreferences : IDisposable
{
    // BepInEx's generic list requires IEquatable<T>, which CLR enums lack.
    private sealed class BackgroundChoices : AcceptableValueBase
    {
        public BackgroundChoices() : base(typeof(MainMenuBackground)) { }
        public override bool IsValid(object value)
            => value is MainMenuBackground && Enum.IsDefined(typeof(MainMenuBackground), value);
        public override object Clamp(object value) => IsValid(value) ? value : MainMenuBackground.Slideshow;
        public override string ToDescriptionString()
            => "# Acceptable values: " + string.Join(", ", Enum.GetNames(typeof(MainMenuBackground)));
    }

    private readonly ConfigFile config;
    private readonly ConfigEntry<MainMenuBackground> choice;
    private bool saving;
    public event Action Changed;
    public MainMenuBackground Choice => choice.Value;

    public MainMenuBackgroundPreferences(ConfigFile config)
    {
        this.config = config;
        choice = config.Bind("SCOM UI", "MainMenuBackground", MainMenuBackground.Slideshow,
            new ConfigDescription("Main-menu and match-loading background. Slideshow holds each photo for 12 seconds and fades for 1 second; choosing it resumes from the selected photo.",
                new BackgroundChoices()));
        choice.SettingChanged += OnChanged;
    }

    public void SetSaved(MainMenuBackground value)
    {
        if (!Enum.IsDefined(typeof(MainMenuBackground), value)) throw new ArgumentOutOfRangeException(nameof(value));
        if (Choice == value) return;
        var previous = Choice;
        bool autoSave = config.SaveOnConfigSet;
        saving = true;
        config.SaveOnConfigSet = false;
        try
        {
            choice.Value = value;
            config.Save();
        }
        catch
        {
            // No playback/UI event is published until persistence succeeds.
            choice.Value = previous;
            throw;
        }
        finally
        {
            config.SaveOnConfigSet = autoSave;
            saving = false;
        }
        Changed?.Invoke();
    }

    private void OnChanged(object sender, EventArgs args)
    {
        if (!saving) Changed?.Invoke();
    }

    public void Dispose()
    {
        choice.SettingChanged -= OnChanged;
        Changed = null;
    }
}
