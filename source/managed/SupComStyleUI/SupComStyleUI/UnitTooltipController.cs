using System;
using System.Collections.Generic;
using System.Globalization;
using BepInEx.Logging;
using SanctuaryUI;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

internal sealed class UnitTooltipController : MonoBehaviour
{
	private readonly LiveUnitTemplateReader templateReader = new LiveUnitTemplateReader();

	private readonly HashSet<string> loggedReadFailures = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

	private readonly List<CanvasGroup> ancestorGroups = new List<CanvasGroup>(4);

	private CanvasGroup canvasGroup;

	private RectTransform panel;

	private TextMeshProUGUI titleText;

	private TextMeshProUGUI bodyText;

	private Func<bool> featureEnabled;

	private Func<float> hoverDelay;

	private ManualLogSource logger;

	private UnitButtonElement hoveredButton;

	private TooltipTrigger suppressedNativeTooltip;

	private string displayedTemplateId;

	private float hoverStartedAt;

	private bool contentReady;

	private bool layoutAvailable = true;

	public static UnitTooltipController Create(RectTransform parent, TextMeshProUGUI fontSource, Func<bool> enabledProvider, Func<float> delayProvider, ManualLogSource log)
	{
		if (parent == null)
		{
			throw new ArgumentNullException("parent");
		}
		if (fontSource == null || fontSource.font == null)
		{
			throw new InvalidOperationException("The native information-panel font is unavailable for the unit tooltip.");
		}
		GameObject obj = new GameObject("Unit Tooltip Layer", typeof(RectTransform), typeof(Canvas), typeof(CanvasGroup), typeof(UnitTooltipController))
		{
			layer = parent.gameObject.layer
		};
		RectTransform component = obj.GetComponent<RectTransform>();
		component.SetParent(parent, worldPositionStays: false);
		Stretch(component);
		Canvas component2 = obj.GetComponent<Canvas>();
		Canvas componentInParent = parent.GetComponentInParent<Canvas>();
		if (componentInParent != null)
		{
			component2.sortingLayerID = componentInParent.sortingLayerID;
		}
		component2.overrideSorting = true;
		component2.sortingOrder = 30000;
		CanvasGroup component3 = obj.GetComponent<CanvasGroup>();
		component3.alpha = 0f;
		component3.interactable = false;
		component3.blocksRaycasts = false;
		RectTransform rectTransform = AddRect(component, "Detailed Unit Tooltip", new Vector2(1f, 0f), new Vector2(1f, 0f), new Vector2(1f, 0f), new Vector2(-24f, 432f), new Vector2(640f, 440f));
		ChamferPanelGraphic chamferPanelGraphic = rectTransform.gameObject.AddComponent<ChamferPanelGraphic>();
		chamferPanelGraphic.FillColor = new Color32(11, 20, 27, 248);
		chamferPanelGraphic.BorderColor = new Color32(224, 105, 48, 242);
		chamferPanelGraphic.BorderWidth = 3f;
		chamferPanelGraphic.Chamfer = 14f;
		chamferPanelGraphic.ChamferAllCorners = true;
		chamferPanelGraphic.AcceptRaycasts = false;
		TextMeshProUGUI textMeshProUGUI = AddText(rectTransform, "Unit Title", fontSource);
		RectTransform rectTransform2 = textMeshProUGUI.rectTransform;
		rectTransform2.anchorMin = new Vector2(0f, 1f);
		rectTransform2.anchorMax = new Vector2(1f, 1f);
		rectTransform2.pivot = new Vector2(0.5f, 1f);
		rectTransform2.anchoredPosition = Vector2.zero;
		rectTransform2.sizeDelta = new Vector2(0f, 58f);
		rectTransform2.offsetMin = new Vector2(22f, rectTransform2.offsetMin.y);
		rectTransform2.offsetMax = new Vector2(-22f, rectTransform2.offsetMax.y);
		textMeshProUGUI.fontSize = 20f;
		textMeshProUGUI.enableAutoSizing = true;
		textMeshProUGUI.fontSizeMin = 16f;
		textMeshProUGUI.fontSizeMax = 20f;
		textMeshProUGUI.fontStyle = FontStyles.Bold;
		textMeshProUGUI.alignment = TextAlignmentOptions.MidlineLeft;
		textMeshProUGUI.color = new Color32(244, 167, 62, byte.MaxValue);
		textMeshProUGUI.enableWordWrapping = false;
		textMeshProUGUI.overflowMode = TextOverflowModes.Ellipsis;
		textMeshProUGUI.richText = false;
		Image image = AddRect(rectTransform, "Title Separator", new Vector2(0f, 1f), new Vector2(1f, 1f), new Vector2(0.5f, 1f), new Vector2(0f, -58f), new Vector2(-36f, 2f)).gameObject.AddComponent<Image>();
		image.color = new Color32(224, 105, 48, 150);
		image.raycastTarget = false;
		TextMeshProUGUI textMeshProUGUI2 = AddText(rectTransform, "Unit Details", fontSource);
		RectTransform rectTransform3 = textMeshProUGUI2.rectTransform;
		rectTransform3.anchorMin = Vector2.zero;
		rectTransform3.anchorMax = Vector2.one;
		rectTransform3.pivot = new Vector2(0.5f, 0.5f);
		rectTransform3.offsetMin = new Vector2(22f, 18f);
		rectTransform3.offsetMax = new Vector2(-22f, -68f);
		textMeshProUGUI2.fontSize = 15.5f;
		textMeshProUGUI2.enableAutoSizing = true;
		textMeshProUGUI2.fontSizeMin = 13f;
		textMeshProUGUI2.fontSizeMax = 15.5f;
		textMeshProUGUI2.fontStyle = FontStyles.Normal;
		textMeshProUGUI2.alignment = TextAlignmentOptions.TopLeft;
		textMeshProUGUI2.color = new Color32(228, 240, 242, byte.MaxValue);
		textMeshProUGUI2.enableWordWrapping = true;
		textMeshProUGUI2.overflowMode = TextOverflowModes.Truncate;
		textMeshProUGUI2.richText = true;
		textMeshProUGUI2.lineSpacing = 2f;
		UnitTooltipController component4 = obj.GetComponent<UnitTooltipController>();
		component4.canvasGroup = component3;
		component4.panel = rectTransform;
		component4.titleText = textMeshProUGUI;
		component4.bodyText = textMeshProUGUI2;
		component4.featureEnabled = enabledProvider ?? throw new ArgumentNullException("enabledProvider");
		component4.hoverDelay = delayProvider ?? throw new ArgumentNullException("delayProvider");
		component4.logger = log;
		return component4;
	}

	public void BeginHover(UnitButtonElement button)
	{
		Button button2 = button?.GetComponent<Button>();
		if (!IsFeatureEnabled() || !layoutAvailable || !IsConstructionButton(button) || !button.emitHoverEvents || button2 == null || !button2.IsInteractable())
		{
			CancelHover();
			return;
		}
		RestoreNativeTooltip();
		hoveredButton = button;
		TooltipTrigger component = button.GetComponent<TooltipTrigger>();
		if (component != null && component.enabled)
		{
			suppressedNativeTooltip = component;
			component.enabled = false;
		}
		TooltipPanelUI.SetTooltip(enabled: false);
		hoverStartedAt = Time.unscaledTime;
		displayedTemplateId = null;
		contentReady = false;
		HideImmediate();
	}

	public void EndHover(UnitButtonElement button)
	{
		if (!(button == null) && !(hoveredButton != button))
		{
			RestoreNativeTooltip();
			hoveredButton = null;
			displayedTemplateId = null;
			contentReady = false;
			HideImmediate();
		}
	}

	public void CancelHover()
	{
		RestoreNativeTooltip();
		hoveredButton = null;
		displayedTemplateId = null;
		contentReady = false;
		HideImmediate();
	}

	public void Reflow(Rect safeRect, Rect rootRect, float fabricationTop, float economyHeight)
	{
		if (!(panel == null))
		{
			float num = Mathf.Min(640f, safeRect.width - 32f);
			float num2 = fabricationTop + 16f;
			float num3 = safeRect.yMax - economyHeight - 16f;
			float num4 = Mathf.Min(440f, num3 - num2);
			layoutAvailable = num >= 520f && num4 >= 320f;
			if (!layoutAvailable)
			{
				HideImmediate();
				return;
			}
			panel.sizeDelta = new Vector2(num, num4);
			panel.anchoredPosition = new Vector2(safeRect.xMax - rootRect.xMax - 16f, num2 - rootRect.yMin);
		}
	}

	public void RefreshFromInformationPanel(string templateId, InformationPanelUI informationPanel)
	{
		if (hoveredButton == null || !IsFeatureEnabled() || string.IsNullOrWhiteSpace(templateId))
		{
			return;
		}
		string text = templateId.Trim();
		if (contentReady && string.Equals(displayedTemplateId, text, StringComparison.OrdinalIgnoreCase))
		{
			return;
		}
		if (!templateReader.TryRead(text, out var data, out var error))
		{
			data = BuildFallback(text, informationPanel);
			if (loggedReadFailures.Add(text))
			{
				logger?.LogWarning("Detailed stats for " + text + " were unavailable; using the native information-card values. " + error);
			}
		}
		else
		{
			string value = informationPanel?.unitName?.text;
			string text2 = informationPanel?.unitDisplayName?.text;
			if (!string.IsNullOrWhiteSpace(value))
			{
				data.Name = value;
			}
			if (!string.IsNullOrWhiteSpace(text2))
			{
				data.DisplayName = text2;
			}
		}
		titleText.text = UnitTooltipFormatter.BuildTitle(data);
		bodyText.text = UnitTooltipFormatter.BuildBody(data);
		displayedTemplateId = text;
		contentReady = true;
	}

	public void HideImmediate()
	{
		if (canvasGroup != null)
		{
			canvasGroup.alpha = 0f;
		}
	}

	public void ResetForGameCleanup()
	{
		CancelHover();
		templateReader.Clear();
		loggedReadFailures.Clear();
	}

	private void LateUpdate()
	{
		if (!layoutAvailable || !IsFeatureEnabled() || !IsHoverStillValid())
		{
			CancelHover();
			return;
		}
		TooltipPanelUI.SetTooltip(enabled: false);
		float num = Mathf.Clamp(hoverDelay(), 0f, 1f);
		canvasGroup.alpha = ((contentReady && Time.unscaledTime - hoverStartedAt >= num) ? 1f : 0f);
	}

	private void RestoreNativeTooltip()
	{
		if (suppressedNativeTooltip != null)
		{
			if (!TooltipLifecycle.IsPooled(suppressedNativeTooltip))
			{
				suppressedNativeTooltip.enabled = true;
			}
			suppressedNativeTooltip = null;
		}
	}

	private void OnDisable()
	{
		CancelHover();
	}

	private bool IsFeatureEnabled()
	{
		try
		{
			return featureEnabled != null && featureEnabled();
		}
		catch
		{
			return false;
		}
	}

	private bool IsHoverStillValid()
	{
		if (!TooltipLifecycle.IsPointerOverVisibleTarget(hoveredButton))
		{
			return false;
		}
		if (!IsConstructionButton(hoveredButton) || !hoveredButton.emitHoverEvents || !hoveredButton.gameObject.activeInHierarchy)
		{
			return false;
		}
		Vector3 lossyScale = hoveredButton.transform.lossyScale;
		if (Mathf.Abs(lossyScale.x) <= 0.01f || Mathf.Abs(lossyScale.y) <= 0.01f)
		{
			return false;
		}
		Button component = hoveredButton.GetComponent<Button>();
		if (component == null || !component.IsInteractable())
		{
			return false;
		}
		Transform parent = hoveredButton.transform;
		bool flag = false;
		while (parent != null && !flag)
		{
			parent.GetComponents(ancestorGroups);
			for (int i = 0; i < ancestorGroups.Count; i++)
			{
				CanvasGroup canvasGroup = ancestorGroups[i];
				if (canvasGroup.alpha <= 0.01f || !canvasGroup.interactable || !canvasGroup.blocksRaycasts)
				{
					return false;
				}
				flag |= canvasGroup.ignoreParentGroups;
			}
			parent = parent.parent;
		}
		return true;
	}

	private static bool IsConstructionButton(UnitButtonElement button)
	{
		if (button != null)
		{
			return button.GetComponentInParent<ConstructionPanelUI>() != null;
		}
		return false;
	}

	private static UnitTooltipData BuildFallback(string templateId, InformationPanelUI panel)
	{
		return new UnitTooltipData
		{
			TemplateId = templateId,
			Name = (panel?.unitName?.text ?? string.Empty),
			DisplayName = (panel?.unitDisplayName?.text ?? string.Empty),
			Health = ReadSignedValue(panel?.healthMax),
			HealthRegen = ReadSignedValue(panel?.healthRegen),
			EnergyCost = ReadSignedValue(panel?.energyBuildCost),
			AlloyCost = ReadSignedValue(panel?.alloyBuildCost),
			BuildPower = ReadSignedValue(panel?.buildPower)
		};
	}

	private static float? ReadSignedValue(SignedTextElement element)
	{
		if (element == null || element.text == null)
		{
			return null;
		}
		string text = element.text.text?.Trim();
		if (string.IsNullOrEmpty(text))
		{
			return null;
		}
		float num = 1f;
		switch (text[text.Length - 1])
		{
		case 'K':
		case 'k':
			num = 1000f;
			text = text.Substring(0, text.Length - 1);
			break;
		case 'M':
		case 'm':
			num = 1000000f;
			text = text.Substring(0, text.Length - 1);
			break;
		case 'B':
		case 'b':
			num = 1E+09f;
			text = text.Substring(0, text.Length - 1);
			break;
		}
		if (!float.TryParse(text, NumberStyles.Float, CultureInfo.InvariantCulture, out var result))
		{
			return null;
		}
		if (element.sign != null && element.sign.text == "-")
		{
			result = 0f - result;
		}
		return result * num;
	}

	private static TextMeshProUGUI AddText(RectTransform parent, string name, TextMeshProUGUI fontSource)
	{
		GameObject obj = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer), typeof(TextMeshProUGUI));
		obj.layer = parent.gameObject.layer;
		obj.GetComponent<RectTransform>().SetParent(parent, worldPositionStays: false);
		TextMeshProUGUI component = obj.GetComponent<TextMeshProUGUI>();
		component.font = fontSource.font;
		component.fontSharedMaterial = fontSource.fontSharedMaterial;
		component.raycastTarget = false;
		component.text = string.Empty;
		return component;
	}

	private static RectTransform AddRect(RectTransform parent, string name, Vector2 anchorMin, Vector2 anchorMax, Vector2 pivot, Vector2 anchoredPosition, Vector2 sizeDelta)
	{
		RectTransform component = new GameObject(name, typeof(RectTransform))
		{
			layer = parent.gameObject.layer
		}.GetComponent<RectTransform>();
		component.SetParent(parent, worldPositionStays: false);
		component.anchorMin = anchorMin;
		component.anchorMax = anchorMax;
		component.pivot = pivot;
		component.anchoredPosition = anchoredPosition;
		component.sizeDelta = sizeDelta;
		component.localRotation = Quaternion.identity;
		component.localScale = Vector3.one;
		return component;
	}

	private static void Stretch(RectTransform rect)
	{
		rect.anchorMin = Vector2.zero;
		rect.anchorMax = Vector2.one;
		rect.pivot = new Vector2(0.5f, 0.5f);
		rect.anchoredPosition = Vector2.zero;
		rect.sizeDelta = Vector2.zero;
		rect.localRotation = Quaternion.identity;
		rect.localScale = Vector3.one;
	}
}
