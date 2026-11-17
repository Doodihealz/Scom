using EM.Network;
using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

// Visual only: the native lobby selects the checked Ready button. This helper
// never changes readiness, interactivity, listeners or the native state groups.
internal sealed class ClassicReadyButtonGlow : MonoBehaviour
{
    private ClassicLobbyGraphic glow;
    private bool ready;
    private float selectedAt;

    public void SetReady(bool value)
    {
        if (value && glow == null)
        {
            var rect = LobbyControls.Rect("SCOM Classic Ready Glow", transform, 0, 0, 0, 0);
            rect.gameObject.layer = gameObject.layer;
            LobbyControls.Stretch(rect, -8f);
            rect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
            rect.SetAsFirstSibling();
            glow = rect.gameObject.AddComponent<ClassicLobbyGraphic>();
            glow.Configure(ClassicLobbyGraphic.Surface.ReadyGlow);
            glow.raycastTarget = false;
        }
        if (value && !ready) selectedAt = Time.unscaledTime;
        ready = value;
        enabled = value;
        Refresh();
    }

    private void Refresh()
    {
        if (glow == null) return;
        bool visible = ready && isActiveAndEnabled && LobbyManager.IsInLobby && LobbyManager.lobbyGameStatus == LobbyManager.LobbyGameStatus.lobby;
        glow.gameObject.SetActive(visible);
        if (!visible) return;
        // Only the halo moves, by +/-6.5% around its base intensity. The gold
        // button face and text stay steady throughout the 2.6-second cycle.
        float pulse = 1f + .065f * Mathf.Sin((Time.unscaledTime - selectedAt) * (2f * Mathf.PI / 2.6f));
        glow.color = new Color(1, 1, 1, .84f * pulse);
    }

    private void Update()
    {
        if (!LobbyManager.IsInLobby || LobbyManager.lobbyGameStatus != LobbyManager.LobbyGameStatus.lobby) { SetReady(false); return; }
        Refresh();
    }
    private void OnEnable() { Refresh(); }
    private void OnDisable() { if (glow != null) glow.gameObject.SetActive(false); }
    public void Dispose() { SetReady(false); if (glow != null) { Destroy(glow.gameObject); glow = null; } }
}
