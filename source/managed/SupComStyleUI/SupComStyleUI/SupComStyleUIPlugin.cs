using System;
using System.Collections.Generic;
using System.Globalization;
using System.Reflection;
using BepInEx;
using BepInEx.Configuration;
using EM.DOTS.Engine.Loader;
using EM.Engine;
using EM.Gamedata;
using EM.Lua.Client;
using EM.UI;
using HarmonyLib;
using SanctuaryUI;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

[BepInPlugin("ziggy.sanctuary.supcom-style-ui", "SupCom Style UI", "2.0.4")]
[BepInProcess("Sanctuary.exe")]
public sealed class SupComStyleUIPlugin : BaseUnityPlugin
{
	private sealed class RectTransformState
	{
		private readonly RectTransform rect;

		private readonly Transform parent;

		private readonly int rectInstanceId;

		private readonly int parentInstanceId;

		private readonly int siblingIndex;

		private readonly Vector2 anchorMin;

		private readonly Vector2 anchorMax;

		private readonly Vector2 anchoredPosition;

		private readonly Vector2 sizeDelta;

		private readonly Vector2 pivot;

		private readonly Quaternion localRotation;

		private readonly Vector3 localScale;

		public RectTransformState(RectTransform rect)
		{
			this.rect = rect;
			parent = rect.parent;
			rectInstanceId = rect.GetInstanceID();
			parentInstanceId = ((parent != null) ? parent.GetInstanceID() : 0);
			siblingIndex = rect.GetSiblingIndex();
			anchorMin = rect.anchorMin;
			anchorMax = rect.anchorMax;
			anchoredPosition = rect.anchoredPosition;
			sizeDelta = rect.sizeDelta;
			pivot = rect.pivot;
			localRotation = rect.localRotation;
			localScale = rect.localScale;
		}

		public static int CompareSiblingOrder(RectTransformState left, RectTransformState right)
		{
			if (left == right)
			{
				return 0;
			}
			int num = left.parentInstanceId;
			int num2 = num.CompareTo(right.parentInstanceId);
			if (num2 != 0)
			{
				return num2;
			}
			num = left.siblingIndex;
			int num3 = num.CompareTo(right.siblingIndex);
			if (num3 == 0)
			{
				num = left.rectInstanceId;
				return num.CompareTo(right.rectInstanceId);
			}
			return num3;
		}

		public void RestoreGeometry()
		{
			if (!(rect == null))
			{
				if (parent != null && rect.parent != parent)
				{
					rect.SetParent(parent, worldPositionStays: false);
				}
				rect.anchorMin = anchorMin;
				rect.anchorMax = anchorMax;
				rect.pivot = pivot;
				rect.anchoredPosition = anchoredPosition;
				rect.sizeDelta = sizeDelta;
				rect.localRotation = localRotation;
				rect.localScale = localScale;
			}
		}

		public void RestoreSiblingIndex()
		{
			if (rect != null && rect.parent != null)
			{
				rect.SetSiblingIndex(Mathf.Clamp(siblingIndex, 0, Math.Max(0, rect.parent.childCount - 1)));
			}
		}
	}

	private sealed class PooledRectTransformState
	{
		private readonly RectTransform rect;

		private readonly Vector2 anchorMin;

		private readonly Vector2 anchorMax;

		private readonly Vector2 anchoredPosition;

		private readonly Vector2 sizeDelta;

		private readonly Vector2 pivot;

		private readonly Quaternion localRotation;

		public PooledRectTransformState(RectTransform rect)
		{
			this.rect = rect;
			anchorMin = rect.anchorMin;
			anchorMax = rect.anchorMax;
			anchoredPosition = rect.anchoredPosition;
			sizeDelta = rect.sizeDelta;
			pivot = rect.pivot;
			localRotation = rect.localRotation;
		}

		public void Restore()
		{
			if (!(rect == null))
			{
				rect.anchorMin = anchorMin;
				rect.anchorMax = anchorMax;
				rect.pivot = pivot;
				rect.anchoredPosition = anchoredPosition;
				rect.sizeDelta = sizeDelta;
				rect.localRotation = localRotation;
			}
		}
	}

	private sealed class GridLayoutGroupState
	{
		private readonly GridLayoutGroup grid;

		private readonly RectOffset padding;

		private readonly TextAnchor childAlignment;

		private readonly GridLayoutGroup.Corner startCorner;

		private readonly GridLayoutGroup.Axis startAxis;

		private readonly Vector2 cellSize;

		private readonly Vector2 spacing;

		private readonly GridLayoutGroup.Constraint constraint;

		private readonly int constraintCount;

		public GridLayoutGroupState(GridLayoutGroup grid)
		{
			this.grid = grid;
			RectOffset rectOffset = grid.padding;
			padding = new RectOffset(rectOffset.left, rectOffset.right, rectOffset.top, rectOffset.bottom);
			childAlignment = grid.childAlignment;
			startCorner = grid.startCorner;
			startAxis = grid.startAxis;
			cellSize = grid.cellSize;
			spacing = grid.spacing;
			constraint = grid.constraint;
			constraintCount = grid.constraintCount;
		}

		public void Restore()
		{
			if (!(grid == null))
			{
				grid.padding = new RectOffset(padding.left, padding.right, padding.top, padding.bottom);
				grid.childAlignment = childAlignment;
				grid.startCorner = startCorner;
				grid.startAxis = startAxis;
				grid.cellSize = cellSize;
				grid.spacing = spacing;
				grid.constraint = constraint;
				grid.constraintCount = constraintCount;
			}
		}
	}

	private sealed class BehaviourState
	{
		private readonly Behaviour behaviour;

		private readonly bool enabled;

		public BehaviourState(Behaviour behaviour)
		{
			this.behaviour = behaviour;
			enabled = behaviour.enabled;
		}

		public void Restore()
		{
			if (behaviour != null)
			{
				behaviour.enabled = enabled;
			}
		}
	}

	private sealed class TextMeshProState
	{
		private readonly TMP_Text text;

		private readonly RectTransform rect;

		private readonly Vector2 anchorMin;

		private readonly Vector2 anchorMax;

		private readonly Vector2 anchoredPosition;

		private readonly Vector2 sizeDelta;

		private readonly Vector2 pivot;

		private readonly FontStyles fontStyle;

		private readonly TextAlignmentOptions alignment;

		private readonly float fontSize;

		private readonly bool enableAutoSizing;

		private readonly float fontSizeMin;

		private readonly float fontSizeMax;

		private readonly bool enableWordWrapping;

		private readonly TextOverflowModes overflowMode;

		public TextMeshProState(TMP_Text text)
		{
			this.text = text;
			rect = text.rectTransform;
			anchorMin = rect.anchorMin;
			anchorMax = rect.anchorMax;
			anchoredPosition = rect.anchoredPosition;
			sizeDelta = rect.sizeDelta;
			pivot = rect.pivot;
			fontStyle = text.fontStyle;
			alignment = text.alignment;
			fontSize = text.fontSize;
			enableAutoSizing = text.enableAutoSizing;
			fontSizeMin = text.fontSizeMin;
			fontSizeMax = text.fontSizeMax;
			enableWordWrapping = text.enableWordWrapping;
			overflowMode = text.overflowMode;
		}

		public void Restore()
		{
			if (!(text == null))
			{
				if (rect != null)
				{
					rect.anchorMin = anchorMin;
					rect.anchorMax = anchorMax;
					rect.anchoredPosition = anchoredPosition;
					rect.sizeDelta = sizeDelta;
					rect.pivot = pivot;
				}
				text.fontStyle = fontStyle;
				text.alignment = alignment;
				text.fontSize = fontSize;
				text.enableAutoSizing = enableAutoSizing;
				text.fontSizeMin = fontSizeMin;
				text.fontSizeMax = fontSizeMax;
				text.enableWordWrapping = enableWordWrapping;
				text.overflowMode = overflowMode;
			}
		}
	}

	private sealed class ResourceRailAccent
	{
		private static readonly Vector2 EndpointGlowSize = new Vector2(24f, 16f);

		private readonly ResourceRailGraphic rail;

		private readonly RectTransform root;

		private readonly RectTransform glow;

		private readonly RectTransform pointer;

		private readonly Image glowImage;

		public ResourceRailAccent(ResourceRailGraphic rail, RectTransform root, RectTransform glow, RectTransform pointer, Image glowImage)
		{
			this.rail = rail;
			this.root = root;
			this.glow = glow;
			this.pointer = pointer;
			this.glowImage = glowImage;
		}

		public void Sync(bool showEmptyEndpoint)
		{
			if (rail == null || root == null)
			{
				return;
			}
			if (rail.TryGetVisibleFillRect(out var anchoredRect))
			{
				root.gameObject.SetActive(value: true);
				root.anchoredPosition = anchoredRect.center;
				root.sizeDelta = anchoredRect.size;
				float x = (rail.Mirrored ? ((0f - anchoredRect.width) * 0.5f) : (anchoredRect.width * 0.5f));
				glow.anchoredPosition = new Vector2(x, 0f);
				pointer.anchoredPosition = new Vector2(x, 0f);
			}
			else
			{
				if (!showEmptyEndpoint || !rail.TryGetFillEndpoint(out var anchoredPoint))
				{
					root.gameObject.SetActive(value: false);
					return;
				}
				root.gameObject.SetActive(value: true);
				root.anchoredPosition = anchoredPoint;
				root.sizeDelta = Vector2.zero;
				glow.anchoredPosition = Vector2.zero;
				pointer.anchoredPosition = Vector2.zero;
			}
			glow.sizeDelta = EndpointGlowSize;
		}

		public void SetGlowColor(Color color)
		{
			if (glowImage != null && !glowImage.color.Equals(color))
			{
				glowImage.color = color;
			}
		}
	}

	private sealed class EconomyReadout
	{
		private readonly TextMeshProUGUI label;

		private readonly TextMeshProUGUI storage;

		private readonly TextMeshProUGUI generated;

		private readonly TextMeshProUGUI expense;

		private readonly TextMeshProUGUI net;

		private readonly TextMeshProUGUI runway;

		public EconomyReadout(TextMeshProUGUI label, TextMeshProUGUI storage, TextMeshProUGUI generated, TextMeshProUGUI expense, TextMeshProUGUI net, TextMeshProUGUI runway)
		{
			this.label = label;
			this.storage = storage;
			this.generated = generated;
			this.expense = expense;
			this.net = net;
			this.runway = runway;
		}

		public void Sync(SignedTextElement storageCurrent, SignedTextElement storageMaximum, SignedTextElement generatedIncome, SignedTextElement resourceExpense, SignedTextElement netIncome)
		{
			SetTextIfChanged(storage, FormatStorage(storageCurrent, storageMaximum));
			SyncRate(generated, generatedIncome, includePerSecondSuffix: false);
			SyncRate(expense, resourceExpense, includePerSecondSuffix: false);
			SyncRate(net, netIncome, includePerSecondSuffix: true);
		}

		public void SyncProjection(ResourceProjection projection)
		{
			SetTextIfChanged(runway, projection.FormatRunway());
			Color color;
			switch (projection.State)
			{
			case EconomyRunwayState.Empty:
			case EconomyRunwayState.Draining:
				color = EconomyNegativeColor;
				break;
			case EconomyRunwayState.Filling:
			case EconomyRunwayState.Full:
				color = EconomyPositiveColor;
				break;
			default:
				color = EconomyNeutralColor;
				break;
			}
			if (runway.color != color)
			{
				runway.color = color;
			}
		}

		public void SetResourceColor(Color color)
		{
			if (label != null && label.color != color)
			{
				label.color = color;
			}
		}
	}

	private sealed class GameObjectState
	{
		private readonly GameObject gameObject;

		private readonly bool active;

		public GameObjectState(GameObject gameObject)
		{
			this.gameObject = gameObject;
			active = gameObject.activeSelf;
		}

		public void Restore()
		{
			if (gameObject != null)
			{
				gameObject.SetActive(active);
			}
		}
	}

	private sealed class GraphicState
	{
		private readonly Graphic graphic;

		private readonly Image image;

		private bool enabled;

		private Color color;

		private readonly bool raycastTarget;

		private readonly Material material;

		private Sprite sprite;

		public GraphicState(Graphic graphic)
		{
			this.graphic = graphic;
			image = graphic as Image;
			enabled = graphic.enabled;
			color = graphic.color;
			raycastTarget = graphic.raycastTarget;
			material = graphic.material;
			sprite = image?.sprite;
		}

		public void RefreshNativeState()
		{
			if (graphic != null)
			{
				enabled = graphic.enabled;
				color = graphic.color;
				if (image != null)
				{
					sprite = image.sprite;
				}
			}
		}

		public void Restore()
		{
			if (!(graphic == null))
			{
				graphic.enabled = enabled;
				graphic.color = color;
				graphic.raycastTarget = raycastTarget;
				graphic.material = material;
				if (image != null)
				{
					image.sprite = sprite;
				}
			}
		}
	}

	private sealed class SelectableState
	{
		private readonly Selectable selectable;

		private readonly Graphic targetGraphic;

		private readonly Selectable.Transition transition;

		private ColorBlock colors;

		public Graphic NativeTargetGraphic => targetGraphic;

		public SelectableState(Selectable selectable)
		{
			this.selectable = selectable;
			targetGraphic = selectable.targetGraphic;
			transition = selectable.transition;
			colors = selectable.colors;
		}

		public void RefreshNativeState()
		{
			RefreshNativeColors();
		}

		public void RefreshNativeColors()
		{
			if (selectable != null)
			{
				colors = selectable.colors;
			}
		}

		public void RefreshNativeOrderColors()
		{
			if (!(selectable == null))
			{
				ColorBlock colorBlock = selectable.colors;
				colors.normalColor = colorBlock.normalColor;
				colors.highlightedColor = colorBlock.highlightedColor;
				colors.pressedColor = colorBlock.pressedColor;
				colors.disabledColor = colorBlock.disabledColor;
			}
		}

		public void Restore()
		{
			if (selectable != null)
			{
				selectable.targetGraphic = targetGraphic;
				selectable.colors = colors;
				selectable.transition = transition;
			}
		}
	}

	private sealed class HudGeometryObserver : MonoBehaviour
	{
		private SupComStyleUIPlugin owner;

		private RectTransform root;

		private Vector2 lastSize;

		private Rect lastSafeArea;

		private bool initialized;

		public void Initialize(SupComStyleUIPlugin plugin, RectTransform observedRoot)
		{
			owner = plugin;
			root = observedRoot;
			lastSize = ((root != null) ? root.rect.size : Vector2.zero);
			lastSafeArea = Screen.safeArea;
			initialized = true;
		}

		private void OnRectTransformDimensionsChange()
		{
			CheckForChanges();
		}

		private void LateUpdate()
		{
			owner?.UpdateMatchClock();
			owner?.UpdateResourceWarningPulse();
			if (owner != null && owner.deferredReflowNotBeforeFrame >= 0 && Time.frameCount >= owner.deferredReflowNotBeforeFrame)
			{
				owner.FlushDeferredPanelRefresh();
			}
			CheckForChanges();
		}

		private void CheckForChanges()
		{
			if (initialized && !(owner == null) && !(root == null))
			{
				Vector2 size = root.rect.size;
				Rect safeArea = Screen.safeArea;
				if (!(size == lastSize) || !(safeArea == lastSafeArea))
				{
					lastSize = size;
					lastSafeArea = safeArea;
					owner.HandleGeometryChanged();
				}
			}
		}
	}

	public const string PluginGuid = "ziggy.sanctuary.supcom-style-ui";

	public const string PluginName = "SupCom Style UI";

	public const string PluginVersion = "2.0.3";

	private const string EconomyMenuButtonName = "menu";

	private static readonly Guid SupportedTrebuchetMvid = new Guid("824eddf3-58d1-4a0a-824a-0153dcd374ee");

	private const string OwnedRootName = "SupComStyleUI.Runtime";

	private const string OwnedSkinName = "SupComStyleUI.Skin";

	private const string PendingDestroyName = "SupComStyleUI.PendingDestroy";

	private const string UnitPortraitPathPrefix = "UI/Sprites/Icons/Units/";

	private const string DefaultUnitPortraitPath = "UI/Sprites/Icons/Units/default.sansprite";

	private const string CommanderUpgradeFilterLabel = "UPGRADES";

	private const string CommanderUpgradeBackSectionHeadingLabel = "BACK";

	private const string CommanderUpgradeLeftArmSectionHeadingLabel = "LEFT ARM";

	private const string CommanderUpgradeRightArmSectionHeadingLabel = "RIGHT ARM";

	private const string CommanderUpgradeLeftArmTooltipPrefix = "Slot: Left Arm.";

	private const string CommanderUpgradeBackTooltipPrefix = "Slot: Back.";

	private const string CommanderUpgradeRightArmTooltipPrefix = "Slot: Right Arm.";

	private const string CommanderUpgradeHeadingsRootName = "SupComStyleUI.CommanderUpgradeHeadings";

	private const float CommanderUpgradeHeadingHeight = 24f;

	private const float CommanderUpgradeHeadingGap = 6f;

	private const float CommanderUpgradeHeadingHorizontalPadding = 12f;

	private const float CommanderUpgradeHeadingFontSize = 18f;

	private const float CommanderUpgradeHeadingPanelPadding = 4f;

	private const float CommanderUpgradeHeadingRowHeight = 36f;

	private const int ClassicPreset = 1;

	private const int CompactPreset = 2;

	private const float CompactEconomyWidth = 1120f;

	private const float CompactEconomyHeight = 112f;

	private const float ClassicEconomyHeight = 68f;

	private const float ClassicMatchClockHeight = 36f;

	private const float CompactMatchClockHeight = 52f;

	private const float MatchClockMinimumWidth = 280f;

	private const float MatchClockMaximumWidth = 400f;

	private const float EconomyControlDockWidth = 256f;

	private const float EconomyControlDockHeight = 56f;

	private const float TeamStatsPanelHeight = 320f;

	private const float TeamStatsPanelMinimumWidth = 520f;

	private const float TeamStatsPanelMaximumWidth = 640f;

	private const int TeamStatsFailureLimit = 3;

	private const float ClassicMatchClockY = 16f;

	private const float CompactMatchClockY = 120f;

	private const float LowResourceEnterThreshold = 0.15f;

	private const float LowResourceClearThreshold = 0.17f;

	private const float LowResourcePulseCyclesPerSecond = 0.8f;

	private const float LowResourceBlendRate = 5f;

	private const float LowResourcePulseUpdateInterval = 0.05f;

	private const float ClassicBottomScale = 0.9f;

	private const float ClassicRequiredCanvasWidth = 1828f;

	private const float CompactRequiredCanvasWidth = 1852f;

	private const float ClassicFabricationBaseInset = 32f;

	private const float ClassicFabricationContentShift = 44f;

	private const float CompactFabricationInset = 24f;

	private const float InformationWidth = 432f;

	private const float InformationHeight = 280f;

	private const float OrdersX = 440f;

	private const float OrdersWidth = 528f;

	private const float OrdersHeight = 280f;

	private const float CommandCoreWidth = 968f;

	private const float CommandCoreHeight = 280f;

	private const float EmbeddedSelectionWidth = 128f;

	private const float EmbeddedSelectionHeight = 84f;

	private const float SelectionStackGap = 8f;

	private const float SelectionCardWidth = 112f;

	private const float SelectionSeparatorWidth = 24f;

	private const float SelectionCardHeight = 72f;

	private const float SelectionRowPitch = 80f;

	private const float SelectionSpacing = 8f;

	private const float CommandPodPadding = 16f;

	private const float MinimumCommandPodHeight = 36f;

	private const float PodPadding = 16f;

	private const float MinimumPodHeight = 36f;

	private const float NativeConstructionPanelMinimumWidth = 708f;

	private const float NativeConstructionPanelHorizontalOverhead = 70f;

	private static readonly Color EnergyRailFillColor = new Color32(byte.MaxValue, 158, 0, byte.MaxValue);

	private static readonly Color AlloyRailFillColor = new Color32(79, 147, 250, byte.MaxValue);

	private static readonly Color EnergyRailGlowColor = new Color32(byte.MaxValue, 158, 0, 128);

	private static readonly Color AlloyRailGlowColor = new Color32(79, 147, 250, 128);

	private static readonly Color LowResourceWarningColor = new Color32(byte.MaxValue, 78, 66, byte.MaxValue);

	private static readonly Color EconomyStorageColor = new Color32(228, 238, 241, byte.MaxValue);

	private const string EconomyCapacityColorHex = "7D9197";

	private static readonly Color EconomyPositiveColor = new Color32(102, 224, 139, byte.MaxValue);

	private static readonly Color EconomyNegativeColor = new Color32(242, 118, 111, byte.MaxValue);

	private static readonly Color EconomyNeutralColor = new Color32(197, 215, 220, byte.MaxValue);

	private static readonly Color32 CommanderUpgradeBorderColor = new Color32(byte.MaxValue, 170, 57, 240);

	private static readonly Color32 CommanderUpgradeTextColor = new Color32(byte.MaxValue, 206, 112, byte.MaxValue);

	private static readonly Color32 CommanderUpgradeIdleColor = new Color32(35, 20, 5, 242);

	private static readonly Color32 CommanderUpgradeActiveColor = new Color32(82, 43, 6, 246);

	private static readonly Color32 CommanderUpgradeSectionHeadingTextColor = new Color32(byte.MaxValue, 220, 153, byte.MaxValue);

	private readonly List<RectTransformState> rectStates = new List<RectTransformState>();

	private readonly List<BehaviourState> behaviourStates = new List<BehaviourState>();

	private readonly List<TextMeshProState> textMeshProStates = new List<TextMeshProState>();

	private readonly List<GameObjectState> gameObjectStates = new List<GameObjectState>();

	private readonly List<GraphicState> graphicStates = new List<GraphicState>();

	private readonly List<SelectableState> selectableStates = new List<SelectableState>();

	private readonly List<PooledRectTransformState> pooledRectStates = new List<PooledRectTransformState>();

	private readonly List<GridLayoutGroupState> gridLayoutStates = new List<GridLayoutGroupState>();

	private readonly List<CanvasGroup> commandGroups = new List<CanvasGroup>();

	private readonly List<CanvasGroup> fabricationGroups = new List<CanvasGroup>();

	private readonly List<Behaviour> ownedBehaviours = new List<Behaviour>();

	private readonly List<ConstructionFilterToggleElement> commanderUpgradeMigratedHeadings = new List<ConstructionFilterToggleElement>();

	private readonly List<CanvasGroup> nativeEconomyControlCollapseGates = new List<CanvasGroup>();

	private readonly TeamHistorySession teamHistorySession = new TeamHistorySession();

	private readonly List<TextMeshProUGUI> teamStatsLegendTexts = new List<TextMeshProUGUI>(8);

	private readonly List<TextMeshProUGUI> teamStatsLegendValueTexts = new List<TextMeshProUGUI>(8);

	private readonly List<RectTransform> teamStatsLegendRows = new List<RectTransform>(8);

	private readonly List<ChamferPanelGraphic> teamStatsLegendSwatches = new List<ChamferPanelGraphic>(8);

	private readonly Dictionary<int, GraphicState> graphicStateById = new Dictionary<int, GraphicState>();

	private readonly Dictionary<int, SelectableState> selectableStateById = new Dictionary<int, SelectableState>();

	private readonly Dictionary<int, TextMeshProState> textMeshProStateById = new Dictionary<int, TextMeshProState>();

	private readonly HashSet<int> capturedRects = new HashSet<int>();

	private readonly HashSet<int> capturedBehaviours = new HashSet<int>();

	private readonly HashSet<int> capturedTextMeshPro = new HashSet<int>();

	private readonly HashSet<int> capturedGameObjects = new HashSet<int>();

	private readonly HashSet<int> capturedGraphics = new HashSet<int>();

	private readonly HashSet<int> capturedSelectables = new HashSet<int>();

	private readonly HashSet<int> capturedPooledRects = new HashSet<int>();

	private readonly HashSet<int> capturedGridLayouts = new HashSet<int>();

	private readonly HashSet<UIPanelType> deferredPanelStyles = new HashSet<UIPanelType>();

	private static SupComStyleUIPlugin activePlugin;

	private ConfigEntry<bool> modEnabled;

	private ConfigEntry<float> chromeOpacity;

	private ConfigEntry<int> layoutPreset;

	private ConfigEntry<bool> showUnitTooltips;

	private ConfigEntry<float> unitTooltipDelay;

	private Harmony harmony;

	private SanctuaryUIManager appliedManager;

	private EconomyPanelUI appliedEconomy;

	private UIEconomyValues latestEconomyValues;

	private bool hasLatestEconomyValues;

	private GameObject ownedRoot;

	private CanvasGroup economyGameplayGroup;

	private CanvasGroup economyChromeGroup;

	private CanvasGroup commandChromeGroup;

	private CanvasGroup fabricationChromeGroup;

	private CanvasGroup ownedHudCollapseGate;

	private CanvasGroup economyHudCollapseGate;

	private CanvasGroup leftHudCollapseGate;

	private CanvasGroup constructionHudCollapseGate;

	private ResourceRailGraphic energyRail;

	private ResourceRailGraphic alloyRail;

	private ResourceRailAccent energyRailAccent;

	private ResourceRailAccent alloyRailAccent;

	private EconomyReadout energyReadout;

	private EconomyReadout alloyReadout;

	private RectTransform uiRoot;

	private RectTransform economyRoot;

	private RectTransform resourceRailHost;

	private RectTransform economyCollapsibleRoot;

	private RectTransform leftPanelsRoot;

	private RectTransform constructionPanelsRoot;

	private RectTransform constructionPanelRoot;

	private float constructionPanelNativeHeight;

	private readonly Dictionary<int, PooledRectTransformState> commanderUpgradeProgressContainers = new Dictionary<int, PooledRectTransformState>();

	private RectTransform constructionButtonsRoot;

	private RectTransform constructionFilterButtonsRoot;

	private RectTransform commanderUpgradeHeadingsRoot;

	private TextMeshProUGUI commanderUpgradeLeftArmHeading;

	private TextMeshProUGUI commanderUpgradeBackHeading;

	private TextMeshProUGUI commanderUpgradeRightArmHeading;

	private RectTransform selectionPanelRoot;

	private RectTransform selectionButtonsRoot;

	private RectTransform informationPanelRoot;

	private Image informationPortrait;

	private RectTransform ordersPanelRoot;

	private RectTransform commandBay;

	private RectTransform commandDivider;

	private RectTransform fabricationBay;

	private RectTransform economyControlDock;

	private GameObject economyPauseControl;

	private GameObject economyMenuControl;

	private RectTransform matchClockPanel;

	private TextMeshProUGUI matchClockText;

	private Button layoutPresetButton;

	private Button hudCollapseButton;

	private RectTransform hudCollapseButtonRect;

	private ChamferPanelGraphic hudCollapseButtonSkin;

	private ChamferPanelGraphic hudRestoreGlyph;

	private Button teamStatsButton;

	private ChamferPanelGraphic teamStatsButtonSkin;

	private RectTransform teamStatsPanel;

	private TeamHistoryGraphic teamHistoryGraphic;

	private TeamHistoryHoverGraphic teamHistoryHoverGraphic;

	private TextMeshProUGUI teamStatsWindowText;

	private TextMeshProUGUI teamStatsStrengthScaleText;

	private TextMeshProUGUI teamStatsAttacksScaleText;

	private TextMeshProUGUI teamStatsHistoryStartText;

	private TextMeshProUGUI teamStatsHistoryMiddleText;

	private TextMeshProUGUI teamStatsStatusText;

	private TeamTelemetryBridge teamTelemetryBridge;

	private UnitTooltipController unitTooltipController;

	private ChamferPanelGraphic presetOneGlyph;

	private ChamferPanelGraphic presetTwoGlyph;

	private int appliedLayoutPreset;

	private bool presetSwitchInProgress;

	private bool contractValid;

	private bool layoutApplied;

	private bool hierarchyWarningLogged;

	private bool canvasGroupWarningLogged;

	private bool applyExceptionLogged;

	private bool runtimeExceptionLogged;

	private bool portraitLoadWarningLogged;

	private bool tooltipFailureLogged;

	private bool commanderUpgradeHeadingLayoutWarningLogged;

	private bool reflowInProgress;

	private bool restoreInProgress;

	private bool hudCallbacksSuspended;

	private bool hudCollapsed;

	private bool rollbackFailed;

	private bool teamStatsExpanded;

	private bool teamStatsFitsSafeArea = true;

	private bool teamStatsFaulted;

	private bool teamStatsWarningLogged;

	private bool energyLowResource;

	private bool alloyLowResource;

	private bool deferredChromeRefresh;

	private bool deferredEconomySync;

	private float energyLowResourceBlend;

	private float alloyLowResourceBlend;

	private float lastLowResourcePulseUpdateTime = -1f;

	private int lastMatchClockSecond = -1;

	private int deferredReflowNotBeforeFrame = -1;

	private int lastTeamStatsAttemptTick = -1;

	private int consecutiveTeamStatsFailures;

	private string lastInformationPortraitTemplateId;

	private string pendingTooltipTemplateId;

	private InformationPanelUI pendingTooltipInformationPanel;

	private void Awake()
	{
		hudCallbacksSuspended = !ClientEngine.Data.isInitialized;
		modEnabled = base.Config.Bind("General", "Enabled", defaultValue: true, "Apply the painted SupCom-inspired HUD while Sanctuary is running.");
		chromeOpacity = base.Config.Bind("Appearance", "ChromeOpacity", 0.88f, new ConfigDescription("Opacity of the replacement HUD chassis.", new AcceptableValueRange<float>(0.35f, 0.98f)));
		layoutPreset = base.Config.Bind("Layout", "Preset", 1, new ConfigDescription("HUD layout preset. 1 has corner resources and a centered build strip; 2 is Compact.", new AcceptableValueRange<int>(1, 2)));
		showUnitTooltips = base.Config.Bind("Tooltips", "ShowDetailedUnitTooltips", defaultValue: true, "Show a SupCom-style detailed stat card while hovering construction buttons.");
		unitTooltipDelay = base.Config.Bind("Tooltips", "HoverDelay", 0.3f, new ConfigDescription("Seconds to hover a construction button before its detailed unit card appears.", new AcceptableValueRange<float>(0f, 1f)));
		Guid moduleVersionId = typeof(SanctuaryUIManager).Assembly.ManifestModule.ModuleVersionId;
		contractValid = moduleVersionId == SupportedTrebuchetMvid;
		if (!contractValid)
		{
			base.Logger.LogError($"Unsupported Trebuchet.dll contract. Expected MVID {SupportedTrebuchetMvid}, " + $"found {moduleVersionId}. No UI changes were applied.");
			base.enabled = false;
			return;
		}
		activePlugin = this;
		try
		{
			InstallRuntimeHooks();
			base.Logger.LogInfo("Ready. Runtime HUD hooks and shared tooltip lifecycle protection installed.");
		}
		catch (Exception arg)
		{
			base.Logger.LogError($"Could not install runtime HUD hooks. No UI changes were applied. {arg}");
			harmony?.UnpatchSelf();
			harmony = null;
			activePlugin = null;
			base.enabled = false;
			return;
		}
		try
		{
			SanctuaryUIManager sanctuaryUIManager = FindHudManager();
			if (sanctuaryUIManager != null)
			{
				HandleManagerEvent(sanctuaryUIManager);
			}
			else
			{
				base.Logger.LogWarning("No live SanctuaryUIManager was found yet; waiting for the native HUD callback.");
			}
		}
		catch (Exception ex)
		{
			base.Logger.LogWarning("Initial HUD discovery was not ready; runtime hooks will retry. " + ex.Message);
		}
	}

	private void OnDestroy()
	{
		TooltipLifecycle.CancelAll();
		try
		{
			teamTelemetryBridge?.Dispose();
		}
		catch (Exception ex)
		{
			base.Logger.LogWarning("Team telemetry cleanup failed during plugin shutdown. " + ex.Message);
		}
		teamTelemetryBridge = null;
		teamHistorySession.Reset();
		if (activePlugin == this)
		{
			activePlugin = null;
		}
		try
		{
			RestoreLayoutSafely("plugin shutdown");
		}
		finally
		{
			harmony?.UnpatchSelf();
			harmony = null;
		}
	}

	private void OnApplicationFocus(bool focused)
	{
		if (!focused)
		{
			TooltipLifecycle.CancelAll();
			teamHistoryHoverGraphic?.ClearHover();
			pendingTooltipTemplateId = null;
			pendingTooltipInformationPanel = null;
			unitTooltipController?.CancelHover();
		}
	}

	private void OnApplicationPause(bool paused)
	{
		if (paused)
		{
			OnApplicationFocus(focused: false);
		}
	}

	private void InstallRuntimeHooks()
	{
		harmony = new Harmony("ziggy.sanctuary.supcom-style-ui");
		PatchPrefix(typeof(EngineLoader), "CleanUpGame", "EngineCleanupPrefix");
		PatchPostfix(typeof(InterfaceManager), "OnGameLoaded", "InterfaceManagerOnGameLoadedPostfix");
		PatchPostfix(typeof(SanctuaryUIManager), "Awake", "SanctuaryUIManagerAwakePostfix");
		PatchPostfix(typeof(SanctuaryUIManager), "SetPanelVisibility", "SetPanelVisibilityPostfix");
		PatchPostfix(typeof(SanctuaryUIManager), "AddButton", "AddButtonPostfix");
		PatchPostfix(typeof(SanctuaryUIManager), "SetButtonTooltip", "SetButtonTooltipPostfix");
		PatchPrefix(typeof(SanctuaryPanelUI), "Clear", "TooltipClearPrefix");
		PatchPrefix(typeof(SanctuaryPanelUI), "SetPanelVisibility", "TooltipVisibilityPrefix");
		PatchPrefix(typeof(Element), "SetTooltip", "TooltipSetPrefix");
		PatchPostfix(typeof(Element), "SetTooltip", "TooltipSetPostfix");
		PatchPrefix(typeof(TooltipTrigger), "Update", "TooltipUpdatePrefix");
		PatchPrefix(typeof(TooltipTrigger), "ShowTooltip", "TooltipShowPrefix");
		PatchPrefix(typeof(TooltipTrigger), "HideTooltip", "TooltipHidePrefix");
		PatchPostfix(typeof(TooltipTrigger), "OnPointerEnter", "TooltipEnterPostfix");
		PatchPostfix(typeof(TooltipTrigger), "OnPointerExit", "TooltipExitPostfix");
		PatchPostfix(typeof(TooltipTrigger), "OnDisable", "TooltipExitPostfix");
		PatchPrefix(typeof(TooltipPanelUI), "LateUpdate", "TooltipPanelUpdatePrefix");
		PatchPostfix(typeof(SanctuaryUIManager), "AddSeparator", "RefreshPanelPostfix");
		PatchPrefix(typeof(SanctuaryUIManager), "ClearElements", "ClearElementsPrefix");
		PatchPostfix(typeof(SanctuaryUIManager), "ClearElements", "ClearElementsPostfix");
		PatchPostfix(typeof(SanctuaryUIManager), "RemoveButton", "RemoveButtonPostfix");
		PatchPostfix(typeof(SanctuaryUIManager), "AdjustUIScale", "AdjustUIScalePostfix");
		PatchPrefix(typeof(SanctuaryUIDelegates), "UI_SetEconomyValues", "EconomyValuesPrefix");
		PatchPostfix(typeof(EconomyPanelUI), "SetValues", "EconomyPanelSetValuesPostfix");
		PatchPostfix(typeof(InformationPanelUI), "SetValues", "InformationPanelSetValuesPostfix");
		PatchPostfix(typeof(ClientLuaInterface), "RenderUpdate", "ClientLuaRenderUpdatePostfix");
		PatchPostfix(typeof(UnitButtonElement), "OnPointerEnter", "UnitButtonPointerEnterPostfix");
		PatchPostfix(typeof(UnitButtonElement), "OnPointerExit", "UnitButtonPointerExitPostfix");
		PatchPostfix(typeof(OrderButtonElement), "SetColorTint", "OrderButtonColorTintPostfix");
		PatchPostfix(typeof(OrderButtonElement), "SetActive", "OrderButtonActivePostfix");
		PatchPostfix(typeof(OrderButtonElement), "SetDisabled", "OrderButtonDisabledPostfix");
		PatchPostfix(typeof(ToggleElement), "ToggleValueChanged", "ToggleValueChangedPostfix");
		PatchPostfix(typeof(ToggleElement), "SetDisabled", "ToggleDisabledPostfix");
	}

	private void PatchPrefix(Type owner, string methodName, string prefixName)
	{
		MethodInfo methodInfo = AccessTools.Method(owner, methodName);
		MethodInfo methodInfo2 = AccessTools.Method(typeof(SupComStyleUIPlugin), prefixName);
		if (methodInfo == null || methodInfo2 == null)
		{
			throw new MissingMethodException("Missing supported HUD hook: " + owner.FullName + "." + methodName);
		}
		harmony.Patch(methodInfo, new HarmonyMethod(methodInfo2)
		{
			priority = 800
		});
	}

	private void PatchPostfix(Type owner, string methodName, string postfixName)
	{
		MethodInfo methodInfo = AccessTools.Method(owner, methodName);
		MethodInfo methodInfo2 = AccessTools.Method(typeof(SupComStyleUIPlugin), postfixName);
		if (methodInfo == null || methodInfo2 == null)
		{
			throw new MissingMethodException("Missing supported HUD hook: " + owner.FullName + "." + methodName);
		}
		harmony.Patch(methodInfo, null, new HarmonyMethod(methodInfo2)
		{
			priority = 0
		});
	}

	private static void SanctuaryUIManagerAwakePostfix(SanctuaryUIManager __instance)
	{
		DispatchManagerEvent(__instance);
	}

	private static void EngineCleanupPrefix()
	{
		TooltipLifecycle.CancelAll();
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin != null)
		{
			supComStyleUIPlugin.BeginGameCleanup();
		}
	}

	private static void InterfaceManagerOnGameLoadedPostfix()
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin == null)
		{
			return;
		}
		try
		{
			supComStyleUIPlugin.ResumeGameplayHud();
		}
		catch (Exception exception)
		{
			supComStyleUIPlugin.LogRuntimeFailure(exception);
		}
	}

	private static void SetPanelVisibilityPostfix(SanctuaryUIManager __instance)
	{
		DispatchPanelVisibilityEvent(__instance);
	}

	private static void AddButtonPostfix(SanctuaryUIManager __instance, UIPanelType panelType, UIElementID __result)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin == null || !supComStyleUIPlugin.layoutApplied || __instance != supComStyleUIPlugin.appliedManager)
		{
			return;
		}
		try
		{
			supComStyleUIPlugin.StyleElement(__result.id);
			supComStyleUIPlugin.QueuePanelRefresh(panelType, restylePanel: false, updateChrome: false);
		}
		catch (Exception exception)
		{
			supComStyleUIPlugin.LogRuntimeFailure(exception);
		}
	}

	private static void RefreshPanelPostfix(SanctuaryUIManager __instance, UIPanelType panelType)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin == null || !supComStyleUIPlugin.layoutApplied || __instance != supComStyleUIPlugin.appliedManager)
		{
			return;
		}
		try
		{
			supComStyleUIPlugin.QueuePanelRefresh(panelType, restylePanel: true, updateChrome: true);
		}
		catch (Exception exception)
		{
			supComStyleUIPlugin.LogRuntimeFailure(exception);
		}
	}

	private static void AdjustUIScalePostfix(SanctuaryUIManager __instance)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin == null || !supComStyleUIPlugin.layoutApplied || __instance != supComStyleUIPlugin.appliedManager)
		{
			return;
		}
		try
		{
			if (!supComStyleUIPlugin.ReflowBottomDeck())
			{
				throw new InvalidOperationException("The current HUD geometry is outside the safe replacement bounds.");
			}
		}
		catch (Exception exception)
		{
			supComStyleUIPlugin.LogRuntimeFailure(exception);
		}
	}

	private static void RemoveButtonPostfix(SanctuaryUIManager __instance, bool __result)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (__result && supComStyleUIPlugin != null && supComStyleUIPlugin.layoutApplied && __instance == supComStyleUIPlugin.appliedManager)
		{
			supComStyleUIPlugin.QueueBottomDeckReflow(Time.frameCount + 1, syncEconomy: true);
		}
	}

	private static void EconomyPanelSetValuesPostfix(EconomyPanelUI __instance)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin != null && supComStyleUIPlugin.layoutApplied && __instance == supComStyleUIPlugin.appliedEconomy)
		{
			try
			{
				supComStyleUIPlugin.SyncEconomyRails();
			}
			catch (Exception exception)
			{
				supComStyleUIPlugin.LogRuntimeFailure(exception);
			}
		}
	}

	private static void EconomyValuesPrefix(in UIEconomyValues values)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin == null || supComStyleUIPlugin.hudCallbacksSuspended)
		{
			return;
		}
		try
		{
			supComStyleUIPlugin.latestEconomyValues = values;
			supComStyleUIPlugin.hasLatestEconomyValues = true;
			supComStyleUIPlugin.SyncEconomyProjection();
		}
		catch (Exception exception)
		{
			supComStyleUIPlugin.LogRuntimeFailure(exception);
		}
	}

	private static void InformationPanelSetValuesPostfix(InformationPanelUI __instance)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (!(supComStyleUIPlugin == null) && supComStyleUIPlugin.layoutApplied && !(__instance == null) && !(supComStyleUIPlugin.informationPanelRoot == null) && !(__instance.transform != supComStyleUIPlugin.informationPanelRoot))
		{
			string templateId = __instance.unitTemplateId?.text;
			try
			{
				supComStyleUIPlugin.SyncInformationPortrait(templateId);
			}
			catch (Exception exception)
			{
				supComStyleUIPlugin.HandlePortraitBindingFailure(exception);
			}
			supComStyleUIPlugin.pendingTooltipTemplateId = templateId;
			supComStyleUIPlugin.pendingTooltipInformationPanel = __instance;
		}
	}

	private static void TooltipClearPrefix(SanctuaryPanelUI __instance)
	{
		CommanderUpgradeAppearance.BeforeClear(__instance);
		TooltipLifecycle.BeforeClear(__instance);
	}

	private static void TooltipVisibilityPrefix(SanctuaryPanelUI __instance, bool visible)
	{
		TooltipLifecycle.BeforeVisibility(__instance, visible);
	}

	private static void TooltipSetPrefix(Element __instance)
	{
		TooltipLifecycle.BeforeSetTooltip(__instance);
	}

	private static void TooltipSetPostfix(Element __instance, string title, string description)
	{
		TooltipLifecycle.AfterSetTooltip(__instance, title, description);
		if (activePlugin != null && activePlugin.layoutApplied)
		{
			CommanderUpgradeAppearance.Apply(__instance, description);
		}
	}

	private static bool TooltipUpdatePrefix(TooltipTrigger __instance, ref bool ___isHovering, ref float ___hoverTimer, ref Vector2 ___mousePreviousPosition)
	{
		return TooltipLifecycle.BeforeUpdate(__instance, ref ___isHovering, ref ___hoverTimer, ref ___mousePreviousPosition);
	}

	private static bool TooltipShowPrefix(TooltipTrigger __instance)
	{
		return TooltipLifecycle.BeforeShow(__instance);
	}

	private static bool TooltipHidePrefix(TooltipTrigger __instance, ref float ___hoverTimer)
	{
		___hoverTimer = 0f;
		return TooltipLifecycle.BeforeHide(__instance);
	}

	private static void TooltipEnterPostfix(TooltipTrigger __instance)
	{
		TooltipLifecycle.BeginHover(__instance);
	}

	private static void TooltipExitPostfix(TooltipTrigger __instance, ref float ___hoverTimer)
	{
		___hoverTimer = 0f;
		TooltipLifecycle.EndHover(__instance);
	}

	private static bool TooltipPanelUpdatePrefix()
	{
		return TooltipLifecycle.BeforePanelUpdate();
	}

	private static void SetButtonTooltipPostfix(SanctuaryUIManager __instance, string description)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin == null || !supComStyleUIPlugin.layoutApplied || __instance != supComStyleUIPlugin.appliedManager || GetCommanderUpgradeSlotIndex(description) < 0)
		{
			return;
		}
		try
		{
			supComStyleUIPlugin.QueueBottomDeckReflow(Time.frameCount + 1, syncEconomy: false);
		}
		catch (Exception exception)
		{
			supComStyleUIPlugin.LogRuntimeFailure(exception);
		}
	}

	private static void ClearElementsPostfix(SanctuaryUIManager __instance, UIPanelType panelType)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin == null || !supComStyleUIPlugin.layoutApplied || __instance != supComStyleUIPlugin.appliedManager)
		{
			return;
		}
		try
		{
			if (panelType == UIPanelType.Construction)
			{
				supComStyleUIPlugin.unitTooltipController?.CancelHover();
			}
			supComStyleUIPlugin.QueuePanelRefresh(panelType, restylePanel: true, updateChrome: true);
		}
		catch (Exception exception)
		{
			supComStyleUIPlugin.LogRuntimeFailure(exception);
		}
	}

	private static void ClearElementsPrefix(SanctuaryUIManager __instance, UIPanelType panelType)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin == null || !supComStyleUIPlugin.layoutApplied || __instance != supComStyleUIPlugin.appliedManager || panelType != UIPanelType.ConstructionFilter)
		{
			return;
		}
		try
		{
			supComStyleUIPlugin.RestoreNativeCommanderUpgradeHeadings();
		}
		catch (Exception exception)
		{
			supComStyleUIPlugin.LogRuntimeFailure(exception);
		}
	}

	private static void ClientLuaRenderUpdatePostfix()
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin == null || !supComStyleUIPlugin.layoutApplied || supComStyleUIPlugin.hudCallbacksSuspended)
		{
			return;
		}
		try
		{
			supComStyleUIPlugin.FlushPendingUnitTooltip();
		}
		catch (Exception exception)
		{
			supComStyleUIPlugin.LogTooltipFailure(exception);
		}
		try
		{
			supComStyleUIPlugin.UpdateTeamStats();
		}
		catch (Exception ex)
		{
			supComStyleUIPlugin.LogTeamStatsFailure(ex.Message);
		}
	}

	private static void UnitButtonPointerEnterPostfix(UnitButtonElement __instance)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin != null && supComStyleUIPlugin.layoutApplied && !supComStyleUIPlugin.hudCallbacksSuspended)
		{
			supComStyleUIPlugin.unitTooltipController?.BeginHover(__instance);
		}
	}

	private static void UnitButtonPointerExitPostfix(UnitButtonElement __instance)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin != null)
		{
			supComStyleUIPlugin.unitTooltipController?.EndHover(__instance);
		}
	}

	private static void OrderButtonColorTintPostfix(OrderButtonElement __instance, Color color)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (!(supComStyleUIPlugin == null) && supComStyleUIPlugin.layoutApplied && !(__instance == null))
		{
			supComStyleUIPlugin.RefreshNativeGraphicState(__instance.background);
			supComStyleUIPlugin.RefreshNativeOrderColors(__instance.GetComponent<Button>());
			supComStyleUIPlugin.RefreshOrderButtonSkin(__instance, color);
		}
	}

	private static void OrderButtonActivePostfix(OrderButtonElement __instance, bool active)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (!(supComStyleUIPlugin == null) && supComStyleUIPlugin.layoutApplied && !(__instance == null))
		{
			ChamferPanelGraphic chamferPanelGraphic = __instance.transform.Find("SupComStyleUI.Skin")?.GetComponent<ChamferPanelGraphic>();
			Button component = __instance.GetComponent<Button>();
			if (chamferPanelGraphic != null && component != null)
			{
				supComStyleUIPlugin.RefreshNativeOrderColors(component);
				chamferPanelGraphic.BorderWidth = (active ? 4f : 2f);
				chamferPanelGraphic.FillColor = (active ? new Color32(13, 34, 45, 244) : new Color32(5, 14, 21, 238));
				supComStyleUIPlugin.UseProceduralColorTint(component, chamferPanelGraphic, active);
			}
		}
	}

	private static void OrderButtonDisabledPostfix(OrderButtonElement __instance)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (!(supComStyleUIPlugin == null) && supComStyleUIPlugin.layoutApplied && !(__instance == null))
		{
			ChamferPanelGraphic chamferPanelGraphic = __instance.transform.Find("SupComStyleUI.Skin")?.GetComponent<ChamferPanelGraphic>();
			Button component = __instance.GetComponent<Button>();
			if (chamferPanelGraphic != null && component != null)
			{
				supComStyleUIPlugin.UseProceduralColorTint(component, chamferPanelGraphic, chamferPanelGraphic.BorderWidth > 3f);
			}
		}
	}

	private static void ToggleValueChangedPostfix(ToggleElement __instance, bool isOn)
	{
		RefreshToggleSkin(__instance, isOn, refreshNativeColors: true);
	}

	private static void ToggleDisabledPostfix(ToggleElement __instance)
	{
		RefreshToggleSkin(__instance, __instance != null && __instance.toggle != null && __instance.toggle.isOn, refreshNativeColors: false);
	}

	private static void RefreshToggleSkin(ToggleElement element, bool isOn, bool refreshNativeColors)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin == null || !supComStyleUIPlugin.layoutApplied || element == null || element.toggle == null || (element is ConstructionFilterToggleElement element2 && IsCommanderUpgradeSectionHeading(element2)))
		{
			return;
		}
		ChamferPanelGraphic chamferPanelGraphic = element.transform.Find("SupComStyleUI.Skin")?.GetComponent<ChamferPanelGraphic>();
		if (!(chamferPanelGraphic == null))
		{
			if (refreshNativeColors)
			{
				supComStyleUIPlugin.RefreshNativeColors(element.toggle);
			}
			bool flag = element is ConstructionFilterToggleElement element3 && IsCommanderUpgradeFilter(element3);
			chamferPanelGraphic.BorderWidth = (isOn ? 3f : 2f);
			chamferPanelGraphic.FillColor = (flag ? (isOn ? CommanderUpgradeActiveColor : CommanderUpgradeIdleColor) : (isOn ? new Color32(13, 34, 45, 244) : new Color32(5, 14, 21, 238)));
			supComStyleUIPlugin.UseProceduralColorTint(element.toggle, chamferPanelGraphic, isOn);
		}
	}

	private static bool IsCommanderUpgradeFilter(ConstructionFilterToggleElement element)
	{
		if (element != null && element.displayText != null)
		{
			return string.Equals(element.displayText.text, "UPG", StringComparison.Ordinal);
		}
		return false;
	}

	private static bool IsCommanderUpgradeSectionHeading(ConstructionFilterToggleElement element)
	{
		string a = element?.displayText?.text;
		if (!string.Equals(a, "BACK", StringComparison.Ordinal) && !string.Equals(a, "LEFT ARM", StringComparison.Ordinal))
		{
			return string.Equals(a, "RIGHT ARM", StringComparison.Ordinal);
		}
		return true;
	}

	private static float GetCommanderUpgradeSectionHeadingWidth(ConstructionFilterToggleElement element)
	{
		if (!string.Equals(element?.displayText?.text, "BACK", StringComparison.Ordinal))
		{
			return 84f;
		}
		return 68f;
	}

	private static void DispatchManagerEvent(SanctuaryUIManager manager)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin == null)
		{
			return;
		}
		try
		{
			supComStyleUIPlugin.HandleManagerEvent(manager);
		}
		catch (Exception exception)
		{
			supComStyleUIPlugin.LogRuntimeFailure(exception);
		}
	}

	private static void DispatchPanelVisibilityEvent(SanctuaryUIManager manager)
	{
		SupComStyleUIPlugin supComStyleUIPlugin = activePlugin;
		if (supComStyleUIPlugin == null)
		{
			return;
		}
		try
		{
			supComStyleUIPlugin.HandlePanelVisibilityEvent(manager);
		}
		catch (Exception exception)
		{
			supComStyleUIPlugin.LogRuntimeFailure(exception);
		}
	}

	private void HandlePanelVisibilityEvent(SanctuaryUIManager manager)
	{
		if (!contractValid || !IsCurrentHudManager(manager) || presetSwitchInProgress || hudCallbacksSuspended)
		{
			return;
		}
		unitTooltipController?.CancelHover();
		if (!modEnabled.Value)
		{
			StopTeamStatsForDisabledMod();
			if (layoutApplied)
			{
				RestoreLayout();
			}
		}
		else if (!layoutApplied || manager != appliedManager)
		{
			HandleManagerEvent(manager);
		}
		else
		{
			deferredChromeRefresh = true;
			QueueBottomDeckReflow(Time.frameCount, syncEconomy: false);
		}
	}

	private void HandleManagerEvent(SanctuaryUIManager manager)
	{
		if (!contractValid || !IsCurrentHudManager(manager) || presetSwitchInProgress || hudCallbacksSuspended)
		{
			return;
		}
		if (!modEnabled.Value)
		{
			StopTeamStatsForDisabledMod();
			if (layoutApplied)
			{
				RestoreLayout();
			}
			return;
		}
		if (layoutApplied && manager != appliedManager)
		{
			RestoreLayout();
		}
		if (!layoutApplied)
		{
			TryApplyLayout(manager, layoutPreset.Value);
		}
		if (layoutApplied)
		{
			if (!ReflowBottomDeck())
			{
				throw new InvalidOperationException("The current HUD geometry is outside the safe replacement bounds.");
			}
			UpdateChromeVisibility();
		}
	}

	private void LogRuntimeFailure(Exception exception)
	{
		if (!runtimeExceptionLogged)
		{
			base.Logger.LogError($"Runtime HUD callback failed. The stock HUD is being restored, and the custom HUD will remain paused until the next match. {exception}");
			runtimeExceptionLogged = true;
		}
		hudCallbacksSuspended = true;
		RestoreLayoutSafely("runtime callback failure");
	}

	private void FlushPendingUnitTooltip()
	{
		string text = pendingTooltipTemplateId;
		InformationPanelUI informationPanelUI = pendingTooltipInformationPanel;
		pendingTooltipTemplateId = null;
		pendingTooltipInformationPanel = null;
		if (!tooltipFailureLogged && unitTooltipController != null && informationPanelUI != null && !string.IsNullOrWhiteSpace(text))
		{
			unitTooltipController.RefreshFromInformationPanel(text, informationPanelUI);
		}
	}

	private void LogTooltipFailure(Exception exception)
	{
		pendingTooltipTemplateId = null;
		pendingTooltipInformationPanel = null;
		unitTooltipController?.HideImmediate();
		if (!tooltipFailureLogged)
		{
			base.Logger.LogWarning("Detailed unit tooltips were disabled for this HUD session after a read failure. The rest of the UI remains active. " + exception);
			tooltipFailureLogged = true;
		}
	}

	private void BeginGameCleanup()
	{
		hudCallbacksSuspended = true;
		teamHistoryHoverGraphic?.ClearHover();
		hasLatestEconomyValues = false;
		latestEconomyValues = default(UIEconomyValues);
		teamStatsExpanded = false;
		teamStatsFaulted = false;
		teamStatsWarningLogged = false;
		consecutiveTeamStatsFailures = 0;
		lastTeamStatsAttemptTick = -1;
		teamHistorySession.Reset();
		try
		{
			teamTelemetryBridge?.Cleanup();
		}
		catch (Exception ex)
		{
			base.Logger.LogWarning("Team telemetry cleanup failed at match exit. " + ex.Message);
		}
		pendingTooltipTemplateId = null;
		pendingTooltipInformationPanel = null;
		unitTooltipController?.ResetForGameCleanup();
		if (layoutApplied || appliedManager != null || ownedRoot != null || rectStates.Count > 0)
		{
			RestoreLayoutSafely("match cleanup");
		}
	}

	private void ResumeGameplayHud()
	{
		if (rollbackFailed)
		{
			hudCallbacksSuspended = true;
			return;
		}
		hudCallbacksSuspended = false;
		runtimeExceptionLogged = false;
		applyExceptionLogged = false;
		portraitLoadWarningLogged = false;
		tooltipFailureLogged = false;
		commanderUpgradeHeadingLayoutWarningLogged = false;
		teamStatsFaulted = false;
		teamStatsWarningLogged = false;
		consecutiveTeamStatsFailures = 0;
		lastTeamStatsAttemptTick = -1;
		SanctuaryUIManager sanctuaryUIManager = FindHudManager();
		if (sanctuaryUIManager != null)
		{
			HandleManagerEvent(sanctuaryUIManager);
		}
	}

	private bool RestoreLayoutSafely(string context)
	{
		try
		{
			RestoreLayout();
			rollbackFailed = false;
			return true;
		}
		catch (Exception arg)
		{
			hudCallbacksSuspended = true;
			rollbackFailed = true;
			base.Logger.LogError($"HUD rollback failed during {context}; callbacks remain suspended. {arg}");
			return false;
		}
	}

	private void TryApplyLayout(SanctuaryUIManager manager, int requestedPreset)
	{
		if (hudCallbacksSuspended)
		{
			return;
		}
		int num = Mathf.Clamp(requestedPreset, 1, 2);
		RectTransform rectTransform = manager.transform as RectTransform;
		RectTransform rectTransform2 = FindRect(rectTransform, "Economy Panel");
		RectTransform rectTransform3 = FindRect(rectTransform, "Left Panels");
		RectTransform rectTransform4 = FindRect(rectTransform, "Construction Panels");
		RectTransform rectTransform5 = FindRect(rectTransform3, "Selection Panel");
		RectTransform rectTransform6 = FindRect(rectTransform3, "Information Panel");
		RectTransform rectTransform7 = FindRect(rectTransform3, "Orders Panel");
		RectTransform rectTransform8 = FindRect(rectTransform4, "Construction Queue Panel");
		RectTransform rectTransform9 = FindRect(rectTransform4, "Construction Filter Panel");
		RectTransform rectTransform10 = FindRect(rectTransform4, "Construction Panel");
		RectTransform rectTransform11 = FindRect(rectTransform10, "Panel Dashed/Dashed Area/Panel Buttons");
		VerticalLayoutGroup verticalLayoutGroup = rectTransform3?.GetComponent<VerticalLayoutGroup>();
		ContentSizeFitter contentSizeFitter = rectTransform3?.GetComponent<ContentSizeFitter>();
		EconomyPanelUI panel = rectTransform2?.GetComponent<EconomyPanelUI>();
		RectTransform rectTransform12 = (rectTransform9?.GetComponent<ConstructionFilterPanelUI>())?.itemContainer as RectTransform;
		if (rectTransform == null || rectTransform2 == null || rectTransform3 == null || rectTransform4 == null || rectTransform5 == null || rectTransform6 == null || rectTransform7 == null || rectTransform8 == null || rectTransform9 == null || rectTransform10 == null || rectTransform11 == null || rectTransform12 == null || rectTransform11.GetComponent<HorizontalLayoutGroup>() == null || verticalLayoutGroup == null || contentSizeFitter == null || !ValidateEconomy(rectTransform2, panel) || !ValidateCommandLayoutPaths(rectTransform6, rectTransform7, rectTransform5) || !ValidateCosmeticPaths(rectTransform6, rectTransform7, rectTransform5, rectTransform8, rectTransform9, rectTransform10))
		{
			if (!hierarchyWarningLogged)
			{
				base.Logger.LogWarning("Live HUD hierarchy is not ready; retrying without changing it.");
				hierarchyWarningLogged = true;
			}
		}
		else
		{
			if (!TryCollectGameplayGroups(rectTransform2, rectTransform6, rectTransform7, rectTransform5, rectTransform10, rectTransform9, rectTransform8))
			{
				return;
			}
			float num2 = ((num == 1) ? 1828f : 1852f);
			if (!(rectTransform.rect.width > 1f) || !(rectTransform.rect.width < num2))
			{
				appliedManager = manager;
				appliedEconomy = panel;
				appliedLayoutPreset = num;
				try
				{
					Capture(rectTransform2);
					Capture(rectTransform3);
					Capture(rectTransform4);
					Capture(rectTransform5);
					Capture(rectTransform6);
					Capture(rectTransform7);
					Capture(rectTransform10);
					Capture(verticalLayoutGroup);
					Capture(contentSizeFitter);
					CaptureEconomyRectTransforms(rectTransform2, panel);
					verticalLayoutGroup.enabled = false;
					contentSizeFitter.enabled = false;
					SetRect(rectTransform3, Vector2.zero, Vector2.zero, Vector2.zero, new Vector2(24f, 24f), new Vector2(968f, 372f));
					SetRect(rectTransform5, Vector2.zero, Vector2.zero, Vector2.zero, new Vector2(0f, 288f), new Vector2(968f, 84f));
					SetRect(rectTransform6, Vector2.zero, Vector2.zero, Vector2.zero, Vector2.zero, new Vector2(432f, 280f));
					SetRect(rectTransform7, Vector2.zero, Vector2.zero, Vector2.zero, new Vector2(440f, 0f), new Vector2(528f, 280f));
					SetRect(rectTransform4, new Vector2(1f, 0f), new Vector2(1f, 0f), new Vector2(1f, 0f), new Vector2(-24f, 24f), rectTransform4.sizeDelta);
					SetRect(rectTransform2, new Vector2(0f, 1f), new Vector2(1f, 1f), new Vector2(0.5f, 1f), Vector2.zero, new Vector2(0f, (num == 1) ? 68f : 112f));
					ownedRoot = BuildReplacementChrome(rectTransform);
					ownedRoot.transform.SetAsFirstSibling();
					uiRoot = rectTransform;
					economyRoot = rectTransform2;
					leftPanelsRoot = rectTransform3;
					constructionPanelsRoot = rectTransform4;
					constructionPanelRoot = rectTransform10;
					constructionPanelNativeHeight = rectTransform10.rect.height;
					constructionButtonsRoot = rectTransform11;
					constructionFilterButtonsRoot = rectTransform12;
					selectionPanelRoot = rectTransform5;
					informationPanelRoot = rectTransform6;
					ordersPanelRoot = rectTransform7;
					ApplyEconomyReplacement(rectTransform2, panel);
					ConfigureInformationPanel(rectTransform6);
					InformationPanelUI component = rectTransform6.GetComponent<InformationPanelUI>();
					unitTooltipController = UnitTooltipController.Create(ownedRoot.GetComponent<RectTransform>(), component.unitName, () => showUnitTooltips.Value && !tooltipFailureLogged && !hudCollapsed, () => unitTooltipDelay.Value, base.Logger);
					ownedBehaviours.Add(unitTooltipController);
					ConfigureOrdersGrid(rectTransform7);
					ConfigureSelectionStrip(rectTransform5);
					rectTransform6.SetAsLastSibling();
					SuppressStockPanelChrome(rectTransform6, rectTransform7, rectTransform5, rectTransform8, rectTransform9, rectTransform10);
					BuildCommanderUpgradeHeadingOverlay(rectTransform4, component.unitName);
					StyleAllPanelElements();
					if (!ReflowBottomDeck())
					{
						throw new InvalidOperationException("The current HUD geometry is outside the safe replacement bounds.");
					}
					Canvas.ForceUpdateCanvases();
					LayoutRebuilder.ForceRebuildLayoutImmediate(rectTransform6);
					LayoutRebuilder.ForceRebuildLayoutImmediate(rectTransform7);
					LayoutRebuilder.ForceRebuildLayoutImmediate(rectTransform5);
					LayoutRebuilder.ForceRebuildLayoutImmediate(rectTransform4);
					layoutApplied = true;
					HudGeometryObserver hudGeometryObserver = ownedRoot.AddComponent<HudGeometryObserver>();
					hudGeometryObserver.Initialize(this, rectTransform);
					ownedBehaviours.Add(hudGeometryObserver);
					hierarchyWarningLogged = false;
					canvasGroupWarningLogged = false;
					applyExceptionLogged = false;
					SyncEconomyRails();
					UpdateChromeVisibility();
					string text = ((manager == SanctuaryUIManager.Instance) ? "active singleton" : "serialized-scene fallback");
					base.Logger.LogInfo($"Applied painted HUD replacement preset {appliedLayoutPreset}: cut-corner native controls " + "and reversible runtime chrome. Discovery: " + text + ".");
					return;
				}
				catch (Exception arg)
				{
					if (!applyExceptionLogged)
					{
						base.Logger.LogError($"Could not apply the HUD replacement. The stock HUD is being restored, and the custom HUD will remain paused until the next match. {arg}");
						applyExceptionLogged = true;
					}
					hudCallbacksSuspended = true;
					RestoreLayoutSafely("layout application failure");
					return;
				}
			}
			if (!hierarchyWarningLogged)
			{
				base.Logger.LogWarning($"HUD canvas is {rectTransform.rect.width:0} units wide; {num2:0} are required for the " + "non-overlapping painted layout. Stock layout was retained.");
				hierarchyWarningLogged = true;
			}
		}
	}

	private static bool ValidateEconomy(RectTransform economy, EconomyPanelUI panel)
	{
		if (panel == null || panel.energyBar == null || panel.alloyBar == null || panel.energyBar.images == null || panel.energyBar.images.Length != 2 || panel.alloyBar.images == null || panel.alloyBar.images.Length != 2)
		{
			return false;
		}
		SignedTextElement[] economyValues = GetEconomyValues(panel);
		foreach (SignedTextElement signedTextElement in economyValues)
		{
			if (signedTextElement == null || signedTextElement.sign == null || signedTextElement.text == null || signedTextElement.transform.childCount < 2 || signedTextElement.transform.GetChild(0) != signedTextElement.sign.transform || signedTextElement.transform.GetChild(1) != signedTextElement.text.transform)
			{
				return false;
			}
		}
		string[] array = new string[10] { "bg", "energy-bar", "energy-bar/fg", "alloy-bar", "alloy-bar/fg", "Build version", "Version Number", "pause", "help", "menu" };
		foreach (string text in array)
		{
			Transform transform = economy.Find(text);
			if (transform == null)
			{
				return false;
			}
			switch (text)
			{
			case "pause":
			case "help":
			case "menu":
				if (!(transform is RectTransform) || transform.GetComponent<Button>() == null || transform.GetComponent<Graphic>() == null || transform.Find("symbol")?.GetComponent<Graphic>() == null)
				{
					return false;
				}
				break;
			}
		}
		return true;
	}

	private static bool ValidateCosmeticPaths(RectTransform information, RectTransform orders, RectTransform selection, RectTransform queue, RectTransform filter, RectTransform construction)
	{
		if (information.Find("portrait")?.GetComponent<Image>() != null && information.Find("darkness") != null && orders.Find("cells") != null && orders.Find("bg") != null && selection.Find("Panel Dashed") != null && queue.Find("Panel Dashed") != null && construction.Find("Panel Dashed") != null && filter.Find("bg") != null)
		{
			return filter.Find("dashed_line") != null;
		}
		return false;
	}

	private static bool ValidateCommandLayoutPaths(RectTransform information, RectTransform orders, RectTransform selection)
	{
		string[] array = new string[22]
		{
			"unit-name", "unit-id", "unit-display-name", "health-regen", "health-info", "health-bar", "armour-shield-info", "armour-shield-bar", "armour-shield-regen", "bubble-shield-regen",
			"bubble-shield-info", "bubble-shield-bar", "construction-percent", "construction-bar", "current-order-icon", "current-order-name", "info-bar-bottom", "info-bar-bottom/content", "info-bar-bottom/content/constant-info", "info-bar-bottom/content/energy-info",
			"info-bar-bottom/content/alloy-info", "info-bar-bottom/content/capacity-info"
		};
		foreach (string n in array)
		{
			if (!(information.Find(n) is RectTransform))
			{
				return false;
			}
		}
		if (information.Find("info-bar-bottom/content")?.GetComponent<HorizontalLayoutGroup>() == null)
		{
			return false;
		}
		RectTransform rectTransform = orders.Find("content") as RectTransform;
		if (rectTransform != null && rectTransform.GetComponent<GridLayoutGroup>() != null)
		{
			return selection.Find("Panel Dashed/Dashed Area/Panel Buttons") is RectTransform;
		}
		return false;
	}

	private void CaptureEconomyRectTransforms(RectTransform economy, EconomyPanelUI panel)
	{
		Capture(economy.Find("pause") as RectTransform);
		Capture(economy.Find("help") as RectTransform);
		Capture(economy.Find("menu") as RectTransform);
		SignedTextElement[] economyValues = GetEconomyValues(panel);
		foreach (SignedTextElement signedTextElement in economyValues)
		{
			Capture(signedTextElement.transform as RectTransform);
		}
	}

	private bool TryCollectGameplayGroups(RectTransform economy, RectTransform information, RectTransform orders, RectTransform selection, RectTransform construction, RectTransform filter, RectTransform queue)
	{
		economyGameplayGroup = null;
		commandGroups.Clear();
		fabricationGroups.Clear();
		CanvasGroup component = economy.GetComponent<CanvasGroup>();
		CanvasGroup component2 = information.GetComponent<CanvasGroup>();
		CanvasGroup component3 = orders.GetComponent<CanvasGroup>();
		CanvasGroup component4 = selection.GetComponent<CanvasGroup>();
		CanvasGroup component5 = construction.GetComponent<CanvasGroup>();
		CanvasGroup component6 = filter.GetComponent<CanvasGroup>();
		CanvasGroup component7 = queue.GetComponent<CanvasGroup>();
		if (component == null || component2 == null || component3 == null || component4 == null || component5 == null || component6 == null || component7 == null)
		{
			if (!canvasGroupWarningLogged)
			{
				base.Logger.LogWarning("One or more native HUD CanvasGroups are missing; still retrying.");
				canvasGroupWarningLogged = true;
			}
			return false;
		}
		economyGameplayGroup = component;
		commandGroups.Add(component2);
		commandGroups.Add(component3);
		commandGroups.Add(component4);
		fabricationGroups.Add(component5);
		fabricationGroups.Add(component6);
		fabricationGroups.Add(component7);
		return true;
	}

	private GameObject BuildReplacementChrome(RectTransform root)
	{
		if (root.Find("SupComStyleUI.Runtime") != null)
		{
			throw new InvalidOperationException("A stale owned HUD root is still pending cleanup.");
		}
		GameObject obj = (ownedRoot = new GameObject("SupComStyleUI.Runtime", typeof(RectTransform)));
		obj.layer = root.gameObject.layer;
		RectTransform component = obj.GetComponent<RectTransform>();
		component.SetParent(root, worldPositionStays: false);
		Stretch(component);
		RectTransform parent = AddLayer(component, "Command Chrome", out commandChromeGroup);
		RectTransform parent2 = AddLayer(component, "Fabrication Chrome", out fabricationChromeGroup);
		RectTransform parent3 = AddLayer(component, "Economy Chrome", out economyChromeGroup);
		byte b = (byte)Mathf.RoundToInt(255f * chromeOpacity.Value);
		Color32 color = ((appliedLayoutPreset == 1) ? new Color32(10, 22, 30, (byte)Mathf.Min(b, 238)) : new Color32(7, 17, 24, (byte)Mathf.Max(b, 238)));
		Color32 color2 = new Color32(7, 17, 24, (byte)Mathf.Clamp(b, 224, 242));
		Color32 color3 = new Color32(90, 159, 171, 225);
		commandBay = AddChamferPanel(parent, "Command Bay", Vector2.zero, Vector2.zero, Vector2.zero, new Vector2(16f, 16f), new Vector2(984f, 296f), color2, color3, 14f, allCorners: false);
		commandDivider = AddRect(parent, "Command Divider", Vector2.zero, Vector2.zero, Vector2.zero, Vector2.zero, new Vector2(2f, 256f));
		Image image = commandDivider.gameObject.AddComponent<Image>();
		image.color = new Color32(90, 159, 171, 120);
		image.raycastTarget = false;
		fabricationBay = AddChamferPanel(parent2, "Fabrication Bay", Vector2.zero, Vector2.zero, Vector2.zero, new Vector2(1096f, 16f), new Vector2(728f, 392f), color, color3, 14f, allCorners: false);
		fabricationBay.GetComponent<ChamferPanelGraphic>().Mirrored = true;
		RectTransform rectTransform = (resourceRailHost = ((appliedLayoutPreset == 1) ? AddRect(parent3, "Resource Rails", new Vector2(0f, 1f), new Vector2(1f, 1f), new Vector2(0.5f, 1f), Vector2.zero, new Vector2(0f, 68f)) : AddRect(parent3, "Resource Rails", new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), Vector2.zero, new Vector2(1120f, 112f))));
		rectTransform.SetParent(root.Find("Economy Panel"), worldPositionStays: false);
		rectTransform.SetAsFirstSibling();
		economyCollapsibleRoot = AddRect(rectTransform, "Economy Collapsible Content", Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
		if (appliedLayoutPreset == 1)
		{
			RectTransform rectTransform2 = AddChamferPanel(economyCollapsibleRoot, "Compact Resources", new Vector2(0f, 1f), new Vector2(0f, 1f), new Vector2(0f, 1f), new Vector2(16f, -16f), new Vector2(560f, 224f), color2, color3, 10f, allCorners: true);
			rectTransform2.GetComponent<ChamferPanelGraphic>().AcceptRaycasts = false;
			alloyRail = AddResourceRail(rectTransform2, "Alloy Rail", new Vector2(0f, 0.5f), new Vector2(1f, 1f), new Vector2(10f, 4f), new Vector2(-10f, -8f), mirrored: false, fillBandAtBottom: true, AlloyRailFillColor);
			energyRail = AddResourceRail(rectTransform2, "Energy Rail", new Vector2(0f, 0f), new Vector2(1f, 0.5f), new Vector2(10f, 8f), new Vector2(-10f, -4f), mirrored: false, fillBandAtBottom: true, EnergyRailFillColor);
		}
		else
		{
			alloyRail = AddResourceRail(economyCollapsibleRoot, "Alloy Rail", new Vector2(0f, 0.5f), new Vector2(1f, 1f), new Vector2(16f, -2f), new Vector2(-16f, -8f), mirrored: false, fillBandAtBottom: true, AlloyRailFillColor);
			energyRail = AddResourceRail(economyCollapsibleRoot, "Energy Rail", new Vector2(0f, 0f), new Vector2(1f, 0.5f), new Vector2(16f, 8f), new Vector2(-16f, 2f), mirrored: false, fillBandAtBottom: false, EnergyRailFillColor);
		}
		BuildResourceRailAccents();
		BuildTopCenterCluster(rectTransform);
		return obj;
	}

	private void BuildTopCenterCluster(RectTransform railHost)
	{
		float num = ((appliedLayoutPreset == 1) ? 16f : 120f);
		float num2 = ((appliedLayoutPreset == 1) ? 36f : 52f);
		matchClockPanel = AddChamferPanel(railHost, "Match Clock", new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0f, 0f - num), new Vector2(280f, num2), new Color32(3, 10, 15, 242), new Color32(90, 159, 171, 230), 10f, allCorners: true);
		matchClockPanel.GetComponent<ChamferPanelGraphic>().AcceptRaycasts = false;
		GameObject gameObject = new GameObject("Elapsed Match Time", typeof(RectTransform), typeof(CanvasRenderer), typeof(TextMeshProUGUI));
		gameObject.layer = railHost.gameObject.layer;
		RectTransform component = gameObject.GetComponent<RectTransform>();
		component.SetParent(matchClockPanel, worldPositionStays: false);
		Stretch(component);
		float num3 = ((appliedLayoutPreset == 1) ? 2f : 4f);
		component.offsetMin = new Vector2(12f, num3);
		component.offsetMax = new Vector2(-12f, 0f - num3);
		matchClockText = gameObject.GetComponent<TextMeshProUGUI>();
		TextMeshProUGUI textMeshProUGUI = appliedEconomy?.energyNet?.text;
		if (textMeshProUGUI == null || textMeshProUGUI.font == null)
		{
			throw new InvalidOperationException("The native economy font is unavailable for the match clock.");
		}
		matchClockText.font = textMeshProUGUI.font;
		matchClockText.fontSharedMaterial = textMeshProUGUI.fontSharedMaterial;
		matchClockText.fontSize = ((appliedLayoutPreset == 1) ? 26f : 32f);
		matchClockText.fontStyle = FontStyles.Bold;
		matchClockText.alignment = TextAlignmentOptions.Center;
		matchClockText.color = new Color32(220, 238, 241, byte.MaxValue);
		matchClockText.raycastTarget = false;
		matchClockText.enableWordWrapping = false;
		matchClockText.overflowMode = TextOverflowModes.Overflow;
		matchClockText.text = "0:00";
		matchClockPanel.SetAsLastSibling();
		float y = 0f - (num + num2 + 28f);
		if (economyCollapsibleRoot == null)
		{
			throw new InvalidOperationException("The resource content root is unavailable for the economy controls.");
		}
		economyControlDock = AddChamferPanel(economyCollapsibleRoot, "Economy Control Dock", new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0.5f, 0.5f), new Vector2(0f, y), new Vector2(256f, 56f), new Color32(3, 10, 15, 238), new Color32(83, 140, 151, 230), 10f, allCorners: true);
		economyControlDock.GetComponent<ChamferPanelGraphic>().AcceptRaycasts = false;
		economyControlDock.SetAsLastSibling();
		BuildTeamStatsPanel(economyCollapsibleRoot, textMeshProUGUI);
	}

	private void BuildTeamStatsPanel(RectTransform railHost, TextMeshProUGUI template)
	{
		if (railHost == null || template == null || template.font == null)
		{
			throw new InvalidOperationException("The team stats panel prerequisites are unavailable.");
		}
		teamStatsPanel = AddChamferPanel(railHost, "Team Stats Panel", new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), Vector2.zero, new Vector2(600f, 320f), new Color32(3, 10, 15, 246), new Color32(90, 159, 171, 235), 12f, allCorners: true);
		teamStatsPanel.GetComponent<ChamferPanelGraphic>().AcceptRaycasts = false;
		AddEconomyText(teamStatsPanel, "Team Stats Title", "TEAM PERFORMANCE", template, new Vector2(0f, 1f), new Vector2(0f, 1f), new Vector2(16f, -10f), new Vector2(210f, 26f), new Color32(220, 238, 241, byte.MaxValue), 17f, FontStyles.Bold, TextAlignmentOptions.Left);
		teamStatsWindowText = AddEconomyText(teamStatsPanel, "Team Stats Window", "5 MIN WINDOW | 2 SEC SAMPLES", template, new Vector2(1f, 1f), new Vector2(1f, 1f), new Vector2(-16f, -12f), new Vector2(260f, 22f), new Color32(125, 161, 170, byte.MaxValue), 11.5f, FontStyles.Bold, TextAlignmentOptions.Right);
		RectTransform rectTransform = AddRect(teamStatsPanel, "Team History Plots", new Vector2(0f, 1f), new Vector2(1f, 1f), new Vector2(0.5f, 1f), new Vector2(0f, -42f), new Vector2(-24f, 190f));
		teamHistoryGraphic = rectTransform.gameObject.AddComponent<TeamHistoryGraphic>();
		teamHistoryGraphic.color = Color.white;
		teamHistoryGraphic.raycastTarget = false;
		RectTransform rectTransform2 = AddRect(rectTransform, "Team History Hover Surface", Vector2.zero, Vector2.one, new Vector2(0.5f, 1f), Vector2.zero, Vector2.zero);
		teamHistoryHoverGraphic = rectTransform2.gameObject.AddComponent<TeamHistoryHoverGraphic>();
		teamHistoryHoverGraphic.color = Color.white;
		teamHistoryHoverGraphic.Initialize(teamHistoryGraphic, ShowTeamStatsInspection, ClearTeamStatsInspection);
		AddEconomyText(teamStatsPanel, "Strength Plot Label", "TEAM STRENGTH", template, new Vector2(0f, 1f), new Vector2(0f, 1f), new Vector2(20f, -49f), new Vector2(180f, 15f), new Color32(181, 207, 213, byte.MaxValue), 11f, FontStyles.Bold, TextAlignmentOptions.Left);
		teamStatsStrengthScaleText = AddEconomyText(teamStatsPanel, "Strength Plot Scale", "MAX --", template, new Vector2(1f, 1f), new Vector2(1f, 1f), new Vector2(-20f, -49f), new Vector2(100f, 15f), new Color32(125, 161, 170, byte.MaxValue), 11f, FontStyles.Bold, TextAlignmentOptions.Right);
		AddEconomyText(teamStatsPanel, "Attacks Plot Label", "ATTACKS / MIN", template, new Vector2(0f, 1f), new Vector2(0f, 1f), new Vector2(20f, -140f), new Vector2(180f, 15f), new Color32(181, 207, 213, byte.MaxValue), 11f, FontStyles.Bold, TextAlignmentOptions.Left);
		teamStatsAttacksScaleText = AddEconomyText(teamStatsPanel, "Attacks Plot Scale", "MAX --", template, new Vector2(1f, 1f), new Vector2(1f, 1f), new Vector2(-20f, -140f), new Vector2(100f, 15f), new Color32(125, 161, 170, byte.MaxValue), 11f, FontStyles.Bold, TextAlignmentOptions.Right);
		teamStatsHistoryStartText = AddEconomyText(teamStatsPanel, "History Start Label", "START", template, new Vector2(0f, 1f), new Vector2(0f, 1f), new Vector2(16f, -230f), new Vector2(60f, 15f), new Color32(111, 145, 153, byte.MaxValue), 11f, FontStyles.Normal, TextAlignmentOptions.Left);
		teamStatsHistoryMiddleText = AddEconomyText(teamStatsPanel, "History Middle Label", string.Empty, template, new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0f, -230f), new Vector2(72f, 15f), new Color32(111, 145, 153, byte.MaxValue), 11f, FontStyles.Normal, TextAlignmentOptions.Center);
		AddEconomyText(teamStatsPanel, "History End Label", "NOW", template, new Vector2(1f, 1f), new Vector2(1f, 1f), new Vector2(-16f, -230f), new Vector2(48f, 15f), new Color32(111, 145, 153, byte.MaxValue), 11f, FontStyles.Normal, TextAlignmentOptions.Right);
		teamStatsLegendRows.Clear();
		teamStatsLegendSwatches.Clear();
		teamStatsLegendTexts.Clear();
		teamStatsLegendValueTexts.Clear();
		for (int i = 0; i < 8; i++)
		{
			int num = i % 2;
			int num2 = i / 2;
			RectTransform rectTransform3 = AddRect(teamStatsPanel, "Team Legend Row " + (i + 1), new Vector2((float)num * 0.5f, 1f), new Vector2((float)(num + 1) * 0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0f, -250f - (float)num2 * 17f), new Vector2(-28f, 15f));
			ChamferPanelGraphic component = AddChamferPanel(rectTransform3, "Team Legend Swatch", new Vector2(0f, 0.5f), new Vector2(0f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(5f, 0f), new Vector2(10f, 10f), new Color32(125, 161, 170, byte.MaxValue), new Color32(3, 10, 15, byte.MaxValue), 2f, allCorners: true).GetComponent<ChamferPanelGraphic>();
			component.BorderWidth = 1f;
			component.AcceptRaycasts = false;
			TextMeshProUGUI textMeshProUGUI = AddEconomyText(rectTransform3, "Team Legend Name", string.Empty, template, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), Vector2.zero, rectTransform3.rect.size, EconomyNeutralColor, 11.5f, FontStyles.Bold, TextAlignmentOptions.Left);
			TextMeshProUGUI textMeshProUGUI2 = AddEconomyText(rectTransform3, "Team Legend Values", string.Empty, template, new Vector2(1f, 0.5f), new Vector2(1f, 0.5f), Vector2.zero, new Vector2(112f, 15f), EconomyNeutralColor, 11.5f, FontStyles.Bold, TextAlignmentOptions.Right);
			textMeshProUGUI.richText = false;
			textMeshProUGUI2.richText = false;
			RectTransform rectTransform4 = textMeshProUGUI.rectTransform;
			rectTransform4.anchorMin = Vector2.zero;
			rectTransform4.anchorMax = Vector2.one;
			rectTransform4.offsetMin = new Vector2(18f, 0f);
			rectTransform4.offsetMax = new Vector2(-116f, 0f);
			rectTransform3.gameObject.SetActive(value: false);
			teamStatsLegendRows.Add(rectTransform3);
			teamStatsLegendSwatches.Add(component);
			teamStatsLegendTexts.Add(textMeshProUGUI);
			teamStatsLegendValueTexts.Add(textMeshProUGUI2);
		}
		teamStatsStatusText = AddEconomyText(teamStatsPanel, "Team Stats Status", "WAITING FOR ACTIVE TEAMS", template, new Vector2(0.5f, 1f), new Vector2(0.5f, 0.5f), new Vector2(0f, -130f), new Vector2(360f, 28f), new Color32(125, 161, 170, byte.MaxValue), 13f, FontStyles.Bold, TextAlignmentOptions.Center);
		RefreshTeamStatsView();
	}

	private void BuildResourceRailAccents()
	{
		try
		{
			Data.SanSprite sanSprite = Load.LoadGamedataSprite(Data.GetFileEntry("UI/Sprites/Bars/bar_glow.sansprite"));
			Data.SanMaterial sanMaterial = Load.LoadGamedataMaterial(Data.GetFileEntry("UI/Materials/UI_Additive.sanmaterial"));
			Sprite sprite = sanSprite?.GetSprite();
			Material material = sanMaterial?.GetMaterial();
			if (sprite == null || material == null)
			{
				base.Logger.LogWarning("The native resource glow could not be loaded; the slim procedural rails remain active.");
				return;
			}
			energyRailAccent = AddResourceRailAccent(energyRail, "Energy Rail Glow", sprite, material, EnergyRailGlowColor);
			alloyRailAccent = AddResourceRailAccent(alloyRail, "Alloy Rail Glow", sprite, material, AlloyRailGlowColor);
		}
		catch (Exception ex)
		{
			base.Logger.LogWarning("The native resource glow could not be loaded; the slim procedural rails remain active. " + ex.Message);
		}
	}

	private static ResourceRailAccent AddResourceRailAccent(ResourceRailGraphic rail, string name, Sprite glowSprite, Material additiveMaterial, Color glowColor)
	{
		RectTransform rectTransform = AddRect(rail.GetComponent<RectTransform>(), name, Vector2.zero, Vector2.zero, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
		RectTransform rectTransform2 = AddRect(rectTransform, "Native Additive Glow", new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
		Image image = rectTransform2.gameObject.AddComponent<Image>();
		image.sprite = glowSprite;
		image.material = additiveMaterial;
		image.type = Image.Type.Simple;
		image.preserveAspect = false;
		image.useSpriteMesh = false;
		image.color = glowColor;
		image.raycastTarget = false;
		RectTransform rectTransform3 = AddRect(rectTransform, "Fill Pointer", new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), Vector2.zero, new Vector2(2f, 10f));
		Image image2 = rectTransform3.gameObject.AddComponent<Image>();
		image2.color = Color.white;
		image2.raycastTarget = false;
		rectTransform.gameObject.SetActive(value: false);
		return new ResourceRailAccent(rail, rectTransform, rectTransform2, rectTransform3, image);
	}

	private void ApplyEconomyReplacement(RectTransform economy, EconomyPanelUI panel)
	{
		DisableGraphic(economy.Find("bg")?.GetComponent<Graphic>());
		Image[] images = panel.energyBar.images;
		foreach (Image graphic in images)
		{
			DisableGraphic(graphic);
		}
		images = panel.alloyBar.images;
		foreach (Image graphic2 in images)
		{
			DisableGraphic(graphic2);
		}
		SetActiveCaptured(economy.Find("Build version")?.gameObject, active: false);
		SetActiveCaptured(economy.Find("Version Number")?.gameObject, active: false);
		float y = economyControlDock.anchoredPosition.y;
		Transform transform = economy.Find("pause");
		Transform transform2 = economy.Find("help");
		Transform transform3 = economy.Find("menu");
		economyPauseControl = transform?.gameObject;
		economyMenuControl = transform3?.gameObject;
		CreateHudCollapseGates();
		StyleEconomyControl(transform, -96f, y);
		SetActiveCaptured(transform2?.gameObject, active: false);
		StyleEconomyControl(transform3, 0f, y);
		CreateHudCollapseButton(y);
		CreateLayoutPresetButton();
		CreateTeamStatsButton();
		Transform transform4 = economyCollapsibleRoot;
		if (transform4 == null)
		{
			throw new InvalidOperationException("The resource content root is unavailable for economy values.");
		}
		SignedTextElement[] values = new SignedTextElement[7] { panel.energyStorageValue, panel.energyStorageMax, panel.energyGeneneratedIncome, panel.energyExpense, panel.energyHarvestIncome, panel.energyHarvestTotal, panel.energyNet };
		SignedTextElement[] values2 = new SignedTextElement[7] { panel.alloyStorageValue, panel.alloyStorageMax, panel.alloyGeneratedIncome, panel.alloyExpense, panel.alloyHarvestIncome, panel.alloyHarvestTotal, panel.alloyNet };
		HideNativeEconomyValues(values);
		HideNativeEconomyValues(values2);
		if (appliedLayoutPreset == 1)
		{
			float[] anchors = new float[7] { 0.07f, 0.21f, 0.35f, 0.49f, 0.63f, 0.77f, 0.91f };
			float[] anchors2 = new float[7] { 0.93f, 0.79f, 0.65f, 0.51f, 0.37f, 0.23f, 0.09f };
			ReparentClassicEconomyValues(values, anchors, transform4, rightHalf: false);
			ReparentClassicEconomyValues(values2, anchors2, transform4, rightHalf: true);
		}
		else
		{
			float[] offsets = new float[7] { -458f, -318f, -162f, -22f, 134f, 274f, 444f };
			ReparentEconomyValues(values, offsets, transform4, upperRow: false);
			ReparentEconomyValues(values2, offsets, transform4, upperRow: true);
		}
		BuildEconomyReadouts(panel);
	}

	private void HideNativeEconomyValues(SignedTextElement[] values)
	{
		for (int i = 0; i < values.Length; i++)
		{
			SetActiveCaptured(values[i].gameObject, active: false);
		}
	}

	private void ReparentClassicEconomyValues(SignedTextElement[] values, float[] anchors, Transform railHost, bool rightHalf)
	{
		for (int i = 0; i < values.Length; i++)
		{
			RectTransform rectTransform = values[i].transform as RectTransform;
			Capture(rectTransform);
			rectTransform.SetParent(railHost, worldPositionStays: false);
			float x = (rightHalf ? (0.58f + anchors[i] * 0.42f) : (anchors[i] * 0.42f));
			rectTransform.anchorMin = new Vector2(x, 0.5f);
			rectTransform.anchorMax = rectTransform.anchorMin;
			rectTransform.pivot = new Vector2(0.5f, 0.5f);
			float y = ((i == 2 || i == 4) ? 5f : ((i == values.Length - 1) ? 0f : (-7f)));
			rectTransform.anchoredPosition = new Vector2(0f, y);
			rectTransform.sizeDelta = new Vector2(132f, (i == values.Length - 1) ? 44f : 36f);
			rectTransform.localRotation = Quaternion.identity;
			rectTransform.localScale = Vector3.one;
		}
	}

	private void ReparentEconomyValues(SignedTextElement[] values, float[] offsets, Transform railHost, bool upperRow)
	{
		for (int i = 0; i < values.Length; i++)
		{
			RectTransform rectTransform = values[i].transform as RectTransform;
			Capture(rectTransform);
			rectTransform.SetParent(railHost, worldPositionStays: false);
			rectTransform.anchorMin = new Vector2(0.5f, upperRow ? 0.75f : 0.25f);
			rectTransform.anchorMax = rectTransform.anchorMin;
			rectTransform.pivot = new Vector2(0.5f, 0.5f);
			rectTransform.anchoredPosition = new Vector2(offsets[i], 0f);
			rectTransform.sizeDelta = new Vector2((i == values.Length - 1) ? 160f : 132f, 36f);
			rectTransform.localRotation = Quaternion.identity;
			rectTransform.localScale = Vector3.one;
		}
	}

	private void BuildEconomyReadouts(EconomyPanelUI panel)
	{
		TextMeshProUGUI textMeshProUGUI = panel.energyNet?.text;
		TextMeshProUGUI textMeshProUGUI2 = panel.alloyNet?.text;
		if (textMeshProUGUI == null || textMeshProUGUI.font == null || textMeshProUGUI2 == null || textMeshProUGUI2.font == null)
		{
			throw new InvalidOperationException("The native economy font is unavailable for detailed resource readouts.");
		}
		if (appliedLayoutPreset == 1)
		{
			RectTransform parent = economyCollapsibleRoot.Find("Compact Resources") as RectTransform;
			energyReadout = CreateClassicEconomyReadout(parent, "Energy", EnergyRailFillColor, textMeshProUGUI, mirrored: false);
			alloyReadout = CreateClassicEconomyReadout(parent, "Alloy", AlloyRailFillColor, textMeshProUGUI2, mirrored: true);
		}
		else
		{
			energyReadout = CreateCompactEconomyReadout(economyCollapsibleRoot, "Energy", EnergyRailFillColor, textMeshProUGUI, 0.25f);
			alloyReadout = CreateCompactEconomyReadout(economyCollapsibleRoot, "Alloy", AlloyRailFillColor, textMeshProUGUI2, 0.75f);
		}
	}

	private static EconomyReadout CreateClassicEconomyReadout(RectTransform parent, string resourceName, Color resourceColor, TextMeshProUGUI template, bool mirrored)
	{
		Vector2 anchor = new Vector2(0f, mirrored ? 0.75f : 0.25f);
		Vector2 pivot = new Vector2(0f, 0.5f);
		TextMeshProUGUI label = AddEconomyText(parent, resourceName + " Label", resourceName.ToUpperInvariant(), template, anchor, pivot, new Vector2(24f, 25f), new Vector2(110f, 28f), resourceColor, 21f, FontStyles.Bold, TextAlignmentOptions.Left);
		TextMeshProUGUI storage = AddEconomyText(parent, resourceName + " Storage", "0 / 0", template, anchor, pivot, new Vector2(330f, 25f), new Vector2(206f, 28f), EconomyStorageColor, 22f, FontStyles.Normal, TextAlignmentOptions.Right);
		TextMeshProUGUI generated = AddEconomyText(parent, resourceName + " Generated", "+0", template, anchor, pivot, new Vector2(24f, -12f), new Vector2(140f, 28f), EconomyNeutralColor, 21f, FontStyles.Normal, TextAlignmentOptions.Left);
		TextMeshProUGUI expense = AddEconomyText(parent, resourceName + " Expense", "-0", template, anchor, pivot, new Vector2(194f, -12f), new Vector2(140f, 28f), EconomyNeutralColor, 21f, FontStyles.Normal, TextAlignmentOptions.Center);
		TextMeshProUGUI net = AddEconomyText(parent, resourceName + " Net", "+0/s", template, anchor, pivot, new Vector2(366f, -12f), new Vector2(170f, 28f), EconomyNeutralColor, 21f, FontStyles.Bold, TextAlignmentOptions.Right);
		TextMeshProUGUI runway = AddEconomyText(parent, resourceName + " Runway", "--", template, anchor, pivot, new Vector2(150f, 25f), new Vector2(160f, 24f), EconomyNeutralColor, 15f, FontStyles.Normal, TextAlignmentOptions.Center);
		return new EconomyReadout(label, storage, generated, expense, net, runway);
	}

	private static EconomyReadout CreateCompactEconomyReadout(RectTransform parent, string resourceName, Color resourceColor, TextMeshProUGUI template, float rowAnchor)
	{
		Vector2 anchor = new Vector2(0.5f, rowAnchor);
		TextMeshProUGUI label = AddEconomyText(parent, resourceName + " Label", resourceName.ToUpperInvariant(), template, anchor, new Vector2(0.5f, 0.5f), new Vector2(-500f, 0f), new Vector2(80f, 36f), resourceColor, 16f, FontStyles.Bold, TextAlignmentOptions.Center);
		TextMeshProUGUI storage = AddEconomyText(parent, resourceName + " Storage", "0 / 0", template, anchor, new Vector2(0.5f, 0.5f), new Vector2(-350f, 0f), new Vector2(170f, 36f), EconomyStorageColor, 20f, FontStyles.Normal, TextAlignmentOptions.Center);
		TextMeshProUGUI generated = AddEconomyText(parent, resourceName + " Generated", "+0", template, anchor, new Vector2(0.5f, 0.5f), new Vector2(-100f, 0f), new Vector2(100f, 36f), EconomyNeutralColor, 20f, FontStyles.Normal, TextAlignmentOptions.Center);
		TextMeshProUGUI expense = AddEconomyText(parent, resourceName + " Expense", "-0", template, anchor, new Vector2(0.5f, 0.5f), new Vector2(70f, 0f), new Vector2(90f, 36f), EconomyNeutralColor, 20f, FontStyles.Normal, TextAlignmentOptions.Center);
		TextMeshProUGUI net = AddEconomyText(parent, resourceName + " Net", "+0/s", template, anchor, new Vector2(0.5f, 0.5f), new Vector2(300f, 0f), new Vector2(130f, 36f), EconomyNeutralColor, 20f, FontStyles.Normal, TextAlignmentOptions.Center);
		TextMeshProUGUI runway = AddEconomyText(parent, resourceName + " Runway", "--", template, anchor, new Vector2(0.5f, 0.5f), new Vector2(480f, 0f), new Vector2(132f, 36f), EconomyNeutralColor, 15f, FontStyles.Bold, TextAlignmentOptions.Center);
		return new EconomyReadout(label, storage, generated, expense, net, runway);
	}

	private static TextMeshProUGUI AddEconomyText(RectTransform parent, string name, string initialText, TextMeshProUGUI template, Vector2 anchor, Vector2 pivot, Vector2 anchoredPosition, Vector2 size, Color color, float fontSize, FontStyles style, TextAlignmentOptions alignment)
	{
		GameObject obj = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer), typeof(TextMeshProUGUI))
		{
			layer = parent.gameObject.layer
		};
		RectTransform component = obj.GetComponent<RectTransform>();
		component.SetParent(parent, worldPositionStays: false);
		SetRect(component, anchor, anchor, pivot, anchoredPosition, size);
		TextMeshProUGUI component2 = obj.GetComponent<TextMeshProUGUI>();
		component2.font = template.font;
		component2.fontSharedMaterial = template.fontSharedMaterial;
		component2.fontSize = fontSize;
		component2.fontStyle = style;
		component2.alignment = alignment;
		component2.color = color;
		component2.enableAutoSizing = true;
		component2.fontSizeMin = 11f;
		component2.fontSizeMax = fontSize;
		component2.enableWordWrapping = false;
		component2.overflowMode = TextOverflowModes.Truncate;
		component2.richText = true;
		component2.raycastTarget = false;
		component2.text = initialText;
		return component2;
	}

	private static string FormatStorage(SignedTextElement current, SignedTextElement maximum)
	{
		return ReadAbsoluteValue(current) + " <color=#7D9197>/ " + ReadAbsoluteValue(maximum) + "</color>";
	}

	private static void SyncRate(TextMeshProUGUI target, SignedTextElement source, bool includePerSecondSuffix)
	{
		string text = source?.sign?.text?.Trim() ?? string.Empty;
		if (text == "−")
		{
			text = "-";
		}
		SetTextIfChanged(target, text + ReadAbsoluteValue(source) + (includePerSecondSuffix ? "/s" : string.Empty));
		Color color = ((text == "+") ? EconomyPositiveColor : ((text == "-") ? EconomyNegativeColor : EconomyNeutralColor));
		if (target.color != color)
		{
			target.color = color;
		}
	}

	private static void SetTextIfChanged(TextMeshProUGUI target, string value)
	{
		if (target != null && target.text != value)
		{
			target.text = value;
		}
	}

	private static string ReadAbsoluteValue(SignedTextElement source)
	{
		string text = source?.text?.text;
		if (!string.IsNullOrEmpty(text))
		{
			return text;
		}
		return "0";
	}

	private void CreateHudCollapseGates()
	{
		if (ownedRoot == null || economyCollapsibleRoot == null || leftPanelsRoot == null || constructionPanelsRoot == null || economyPauseControl == null || economyMenuControl == null)
		{
			throw new InvalidOperationException("The HUD collapse targets are unavailable.");
		}
		ownedHudCollapseGate = AddHudCollapseGate(ownedRoot);
		economyHudCollapseGate = AddHudCollapseGate(economyCollapsibleRoot.gameObject);
		leftHudCollapseGate = AddHudCollapseGate(leftPanelsRoot.gameObject);
		constructionHudCollapseGate = AddHudCollapseGate(constructionPanelsRoot.gameObject);
		nativeEconomyControlCollapseGates.Clear();
		nativeEconomyControlCollapseGates.Add(AddHudCollapseGate(economyPauseControl));
		nativeEconomyControlCollapseGates.Add(AddHudCollapseGate(economyMenuControl));
	}

	private CanvasGroup AddHudCollapseGate(GameObject target)
	{
		CanvasGroup canvasGroup = target.AddComponent<CanvasGroup>();
		canvasGroup.alpha = 1f;
		canvasGroup.interactable = true;
		canvasGroup.blocksRaycasts = true;
		canvasGroup.ignoreParentGroups = false;
		ownedBehaviours.Add(canvasGroup);
		return canvasGroup;
	}

	private void StyleEconomyControl(Transform control, float x, float y)
	{
		RectTransform rectTransform = control as RectTransform;
		Button button = control?.GetComponent<Button>();
		Graphic graphic = control?.GetComponent<Graphic>();
		if (rectTransform == null || button == null || graphic == null)
		{
			throw new InvalidOperationException("A native economy control is missing its supported UI contract.");
		}
		Capture(rectTransform);
		rectTransform.anchorMin = new Vector2(0.5f, 1f);
		rectTransform.anchorMax = rectTransform.anchorMin;
		rectTransform.pivot = new Vector2(0.5f, 0.5f);
		rectTransform.anchoredPosition = new Vector2(x, y);
		rectTransform.sizeDelta = new Vector2(36f, 36f);
		rectTransform.localRotation = Quaternion.identity;
		rectTransform.localScale = Vector3.one;
		rectTransform.SetAsLastSibling();
		RectTransform rectTransform2 = control.Find("symbol") as RectTransform;
		if (rectTransform2 == null)
		{
			throw new InvalidOperationException("A native economy control symbol is missing.");
		}
		Capture(rectTransform2);
		float num = Mathf.Max(rectTransform2.rect.width, rectTransform2.rect.height);
		float num2 = ((num > 0.01f) ? Mathf.Min(1f, 24f / num) : 1f);
		rectTransform2.anchorMin = new Vector2(0.5f, 0.5f);
		rectTransform2.anchorMax = rectTransform2.anchorMin;
		rectTransform2.pivot = new Vector2(0.5f, 0.5f);
		rectTransform2.anchoredPosition = Vector2.zero;
		rectTransform2.sizeDelta = rectTransform2.rect.size * num2;
		rectTransform2.localRotation = Quaternion.identity;
		rectTransform2.localScale = Vector3.one;
		DisableGraphic(graphic, keepRaycast: true);
		ChamferPanelGraphic chamferPanelGraphic = AddControlSkin(control, 6f, graphic.material);
		chamferPanelGraphic.rectTransform.offsetMin = Vector2.zero;
		chamferPanelGraphic.rectTransform.offsetMax = Vector2.zero;
		chamferPanelGraphic.Chamfer = 6f;
		chamferPanelGraphic.BorderColor = new Color32(90, 159, 171, 230);
		UseProceduralColorTint(button, chamferPanelGraphic, selected: false);
	}

	private void CreateHudCollapseButton(float y)
	{
		if (resourceRailHost == null)
		{
			throw new InvalidOperationException("The resource rail host is unavailable for the HUD collapse button.");
		}
		GameObject gameObject = new GameObject("HUD Collapse Button", typeof(RectTransform), typeof(ChamferPanelGraphic), typeof(Button))
		{
			layer = resourceRailHost.gameObject.layer
		};
		hudCollapseButtonRect = gameObject.GetComponent<RectTransform>();
		hudCollapseButtonRect.SetParent(resourceRailHost, worldPositionStays: false);
		SetRect(hudCollapseButtonRect, new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0.5f, 0.5f), new Vector2(-48f, y), new Vector2(36f, 36f));
		hudCollapseButtonRect.SetAsLastSibling();
		hudCollapseButtonSkin = gameObject.GetComponent<ChamferPanelGraphic>();
		hudCollapseButtonSkin.FillColor = new Color32(5, 14, 21, 238);
		hudCollapseButtonSkin.BorderColor = new Color32(90, 159, 171, 230);
		hudCollapseButtonSkin.BorderWidth = 2f;
		hudCollapseButtonSkin.Chamfer = 6f;
		hudCollapseButtonSkin.ChamferAllCorners = true;
		hudCollapseButtonSkin.AcceptRaycasts = true;
		hudCollapseButton = gameObject.GetComponent<Button>();
		hudCollapseButton.navigation = new Navigation
		{
			mode = Navigation.Mode.None
		};
		hudCollapseButton.targetGraphic = hudCollapseButtonSkin;
		UseProceduralColorTint(hudCollapseButton, hudCollapseButtonSkin, selected: false);
		hudCollapseButton.onClick.AddListener(ToggleHudCollapsed);
		AddHudCollapseGlyph(hudCollapseButtonRect, "Minimize Horizontal Glyph", new Vector2(14f, 2f));
		hudRestoreGlyph = AddHudCollapseGlyph(hudCollapseButtonRect, "Restore Vertical Glyph", new Vector2(2f, 14f));
		UpdateHudCollapseButtonVisuals();
	}

	private static ChamferPanelGraphic AddHudCollapseGlyph(RectTransform parent, string name, Vector2 size)
	{
		ChamferPanelGraphic chamferPanelGraphic = AddRect(parent, name, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), Vector2.zero, size).gameObject.AddComponent<ChamferPanelGraphic>();
		chamferPanelGraphic.FillColor = new Color32(205, 230, 235, byte.MaxValue);
		chamferPanelGraphic.BorderWidth = 0f;
		chamferPanelGraphic.Chamfer = 1f;
		chamferPanelGraphic.ChamferAllCorners = true;
		chamferPanelGraphic.AcceptRaycasts = false;
		return chamferPanelGraphic;
	}

	private void ToggleHudCollapsed()
	{
		if (!layoutApplied || hudCallbacksSuspended || restoreInProgress || !modEnabled.Value || hudCollapseButton == null)
		{
			return;
		}
		try
		{
			SetHudCollapsed(!hudCollapsed);
		}
		catch (Exception exception)
		{
			LogRuntimeFailure(exception);
		}
	}

	private void SetHudCollapsed(bool collapsed)
	{
		if (hudCollapsed != collapsed)
		{
			if (!HudCollapseControlsAvailable())
			{
				throw new InvalidOperationException("The HUD collapse controls are no longer available.");
			}
			if (collapsed)
			{
				TooltipLifecycle.CancelAll();
				unitTooltipController?.CancelHover();
				teamHistoryHoverGraphic?.ClearHover();
			}
			hudCollapsed = collapsed;
			ApplyHudCollapseState();
			RefreshTeamStatsView();
			UpdateHudCollapseButtonVisuals();
			if (!collapsed)
			{
				UpdateChromeVisibility();
				QueueBottomDeckReflow(Time.frameCount + 1, syncEconomy: true);
			}
		}
	}

	private bool HudCollapseControlsAvailable()
	{
		if (hudCollapseButton == null || hudCollapseButtonRect == null || hudCollapseButtonSkin == null || hudRestoreGlyph == null || matchClockPanel == null || ownedHudCollapseGate == null || economyHudCollapseGate == null || leftHudCollapseGate == null || constructionHudCollapseGate == null || nativeEconomyControlCollapseGates.Count != 2)
		{
			return false;
		}
		for (int i = 0; i < nativeEconomyControlCollapseGates.Count; i++)
		{
			if (nativeEconomyControlCollapseGates[i] == null)
			{
				return false;
			}
		}
		return true;
	}

	private void ApplyHudCollapseState()
	{
		bool visible = !hudCollapsed;
		SetHudCollapseGate(ownedHudCollapseGate, visible);
		SetHudCollapseGate(economyHudCollapseGate, visible);
		SetHudCollapseGate(leftHudCollapseGate, visible);
		SetHudCollapseGate(constructionHudCollapseGate, visible);
		for (int i = 0; i < nativeEconomyControlCollapseGates.Count; i++)
		{
			SetHudCollapseGate(nativeEconomyControlCollapseGates[i], visible);
		}
	}

	private static void SetHudCollapseGate(CanvasGroup gate, bool visible)
	{
		if (gate == null)
		{
			throw new InvalidOperationException("A HUD collapse visibility gate is unavailable.");
		}
		gate.alpha = (visible ? 1f : 0f);
		gate.interactable = visible;
		gate.blocksRaycasts = visible;
	}

	private void ResetHudCollapseForRestore()
	{
		hudCollapsed = false;
		OpenHudCollapseGate(ownedHudCollapseGate);
		OpenHudCollapseGate(economyHudCollapseGate);
		OpenHudCollapseGate(leftHudCollapseGate);
		OpenHudCollapseGate(constructionHudCollapseGate);
		for (int i = 0; i < nativeEconomyControlCollapseGates.Count; i++)
		{
			OpenHudCollapseGate(nativeEconomyControlCollapseGates[i]);
		}
	}

	private static void OpenHudCollapseGate(CanvasGroup gate)
	{
		if (gate != null)
		{
			gate.alpha = 1f;
			gate.interactable = true;
			gate.blocksRaycasts = true;
		}
	}

	private void UpdateHudCollapseButtonVisuals()
	{
		if (hudCollapseButtonRect != null)
		{
			Vector2 anchoredPosition = hudCollapseButtonRect.anchoredPosition;
			anchoredPosition.x = (hudCollapsed ? 0f : (-48f));
			hudCollapseButtonRect.anchoredPosition = anchoredPosition;
			hudCollapseButtonRect.SetAsLastSibling();
		}
		if (hudRestoreGlyph != null)
		{
			hudRestoreGlyph.gameObject.SetActive(hudCollapsed);
		}
		if (hudCollapseButtonSkin != null)
		{
			hudCollapseButtonSkin.FillColor = (hudCollapsed ? new Color32(15, 47, 56, 246) : new Color32(5, 14, 21, 238));
			hudCollapseButtonSkin.BorderColor = (hudCollapsed ? new Color32(82, 210, 230, byte.MaxValue) : new Color32(90, 159, 171, 230));
		}
	}

	private void CreateLayoutPresetButton()
	{
		if (economyControlDock == null)
		{
			throw new InvalidOperationException("The economy control dock is unavailable for the preset button.");
		}
		GameObject obj = new GameObject("Layout Preset Button", typeof(RectTransform), typeof(ChamferPanelGraphic), typeof(Button))
		{
			layer = economyControlDock.gameObject.layer
		};
		RectTransform component = obj.GetComponent<RectTransform>();
		component.SetParent(economyControlDock, worldPositionStays: false);
		SetRect(component, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(48f, 0f), new Vector2(36f, 36f));
		ChamferPanelGraphic component2 = obj.GetComponent<ChamferPanelGraphic>();
		component2.FillColor = new Color32(5, 14, 21, 238);
		component2.BorderColor = new Color32(90, 159, 171, 230);
		component2.BorderWidth = 2f;
		component2.Chamfer = 6f;
		component2.ChamferAllCorners = true;
		component2.AcceptRaycasts = true;
		Button component3 = obj.GetComponent<Button>();
		component3.navigation = new Navigation
		{
			mode = Navigation.Mode.None
		};
		component3.targetGraphic = component2;
		ColorBlock colors = component3.colors;
		colors.normalColor = Color.white;
		colors.highlightedColor = new Color(1.08f, 1.08f, 1.08f, 1f);
		colors.pressedColor = new Color(0.78f, 0.86f, 0.88f, 1f);
		colors.selectedColor = Color.white;
		colors.disabledColor = new Color(0.55f, 0.6f, 0.62f, 0.35f);
		colors.colorMultiplier = 1f;
		colors.fadeDuration = 0.08f;
		component3.colors = colors;
		component3.onClick.AddListener(ChangeLayoutPreset);
		layoutPresetButton = component3;
		presetOneGlyph = AddPresetGlyph(component, "Classic Glyph", new Vector2(-8f, 4f));
		presetTwoGlyph = AddPresetGlyph(component, "Compact Glyph", new Vector2(8f, -4f));
		UpdatePresetButtonVisuals();
	}

	private void CreateTeamStatsButton()
	{
		if (economyControlDock == null || appliedEconomy?.energyNet?.text == null)
		{
			throw new InvalidOperationException("The economy control dock is unavailable for the team stats button.");
		}
		GameObject gameObject = new GameObject("Team Stats Button", typeof(RectTransform), typeof(ChamferPanelGraphic), typeof(Button))
		{
			layer = economyControlDock.gameObject.layer
		};
		RectTransform component = gameObject.GetComponent<RectTransform>();
		component.SetParent(economyControlDock, worldPositionStays: false);
		SetRect(component, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(96f, 0f), new Vector2(44f, 36f));
		teamStatsButtonSkin = gameObject.GetComponent<ChamferPanelGraphic>();
		teamStatsButtonSkin.FillColor = new Color32(5, 14, 21, 238);
		teamStatsButtonSkin.BorderColor = new Color32(90, 159, 171, 230);
		teamStatsButtonSkin.BorderWidth = 2f;
		teamStatsButtonSkin.Chamfer = 6f;
		teamStatsButtonSkin.ChamferAllCorners = true;
		teamStatsButtonSkin.AcceptRaycasts = true;
		teamStatsButton = gameObject.GetComponent<Button>();
		teamStatsButton.navigation = new Navigation
		{
			mode = Navigation.Mode.None
		};
		teamStatsButton.targetGraphic = teamStatsButtonSkin;
		ColorBlock colors = teamStatsButton.colors;
		colors.normalColor = Color.white;
		colors.highlightedColor = new Color(1.08f, 1.08f, 1.08f, 1f);
		colors.pressedColor = new Color(0.78f, 0.86f, 0.88f, 1f);
		colors.selectedColor = Color.white;
		colors.disabledColor = new Color(0.55f, 0.6f, 0.62f, 0.35f);
		colors.colorMultiplier = 1f;
		colors.fadeDuration = 0.08f;
		teamStatsButton.colors = colors;
		teamStatsButton.onClick.AddListener(ToggleTeamStatsPanel);
		AddEconomyText(component, "Team Stats Button Label", "STATS", appliedEconomy.energyNet.text, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), Vector2.zero, new Vector2(40f, 24f), new Color32(205, 230, 235, byte.MaxValue), 11f, FontStyles.Bold, TextAlignmentOptions.Center);
		UpdateTeamStatsButtonVisuals();
	}

	private void ToggleTeamStatsPanel()
	{
		if (layoutApplied && !hudCollapsed && !teamStatsFaulted && !(teamStatsPanel == null))
		{
			teamStatsExpanded = !teamStatsExpanded;
			RefreshTeamStatsView();
			UpdateTeamStatsButtonVisuals();
		}
	}

	private void UpdateTeamStatsButtonVisuals()
	{
		if (!(teamStatsButton == null) && !(teamStatsButtonSkin == null))
		{
			teamStatsButton.interactable = !teamStatsFaulted && teamStatsFitsSafeArea;
			teamStatsButtonSkin.FillColor = ((teamStatsExpanded && !teamStatsFaulted) ? new Color32(15, 47, 56, 246) : new Color32(5, 14, 21, 238));
			teamStatsButtonSkin.BorderColor = (teamStatsFaulted ? new Color32(142, 72, 70, 220) : (teamStatsExpanded ? new Color32(82, 210, 230, byte.MaxValue) : new Color32(90, 159, 171, 230)));
		}
	}

	private static ChamferPanelGraphic AddPresetGlyph(RectTransform parent, string name, Vector2 position)
	{
		ChamferPanelGraphic chamferPanelGraphic = AddRect(parent, name, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), position, new Vector2(14f, 10f)).gameObject.AddComponent<ChamferPanelGraphic>();
		chamferPanelGraphic.FillColor = new Color32(5, 14, 21, byte.MaxValue);
		chamferPanelGraphic.BorderWidth = 2f;
		chamferPanelGraphic.Chamfer = 2f;
		chamferPanelGraphic.ChamferAllCorners = true;
		chamferPanelGraphic.AcceptRaycasts = false;
		return chamferPanelGraphic;
	}

	private void UpdatePresetButtonVisuals()
	{
		if (!(presetOneGlyph == null) && !(presetTwoGlyph == null))
		{
			Color32 color = new Color32(82, 210, 230, byte.MaxValue);
			Color32 color2 = new Color32(66, 89, 97, 210);
			presetOneGlyph.BorderColor = ((appliedLayoutPreset == 1) ? color : color2);
			presetTwoGlyph.BorderColor = ((appliedLayoutPreset == 2) ? color : color2);
		}
	}

	private void ChangeLayoutPreset()
	{
		if (presetSwitchInProgress || !layoutApplied || appliedManager == null)
		{
			return;
		}
		SanctuaryUIManager manager = appliedManager;
		int num = appliedLayoutPreset;
		int num2 = ((num != 1) ? 1 : 2);
		presetSwitchInProgress = true;
		try
		{
			RestoreLayout();
			TryApplyLayout(manager, num2);
			if (!layoutApplied || appliedLayoutPreset != num2)
			{
				TryApplyLayout(manager, num);
				return;
			}
			try
			{
				layoutPreset.Value = num2;
				if (!base.Config.SaveOnConfigSet)
				{
					base.Config.Save();
				}
			}
			catch (Exception ex)
			{
				base.Logger.LogWarning($"Layout changed to preset {num2}, but its persistence failed. {ex.Message}");
			}
		}
		finally
		{
			presetSwitchInProgress = false;
		}
	}

	private void SuppressStockPanelChrome(RectTransform information, RectTransform orders, RectTransform selection, RectTransform queue, RectTransform filter, RectTransform construction)
	{
		DisableGraphic(information.Find("darkness")?.GetComponent<Graphic>());
		DisableGraphicsUnder(orders.Find("cells"));
		DisableGraphic(orders.Find("bg")?.GetComponent<Graphic>());
		DisableDecorativeDashedPanel(selection.Find("Panel Dashed"));
		DisableDecorativeDashedPanel(queue.Find("Panel Dashed"));
		DisableDecorativeDashedPanel(construction.Find("Panel Dashed"));
		DisableGraphic(queue.GetComponent<Graphic>());
		DisableGraphic(filter.Find("bg")?.GetComponent<Graphic>());
		DisableGraphic(filter.Find("dashed_line")?.GetComponent<Graphic>());
	}

	private void ConfigureInformationPanel(RectTransform information)
	{
		SetInformationRect(information, "portrait", new Vector2(0.5f, 0.5f), new Vector2(64f, 238f), new Vector2(72f, 72f));
		informationPortrait = information.Find("portrait")?.GetComponent<Image>();
		if (informationPortrait == null)
		{
			throw new InvalidOperationException("Information portrait image contract is missing.");
		}
		Capture(informationPortrait);
		informationPortrait.color = Color.white;
		informationPortrait.raycastTarget = false;
		informationPortrait.sprite = null;
		informationPortrait.enabled = false;
		AddInformationPortraitPlate(information);
		SetInformationRect(information, "unit-name", new Vector2(0f, 0.5f), new Vector2(132f, 252f), new Vector2(238f, 26f));
		SetInformationRect(information, "unit-display-name", new Vector2(0f, 0.5f), new Vector2(132f, 224f), new Vector2(164f, 28f));
		SetInformationRect(information, "unit-id", new Vector2(0f, 0.5f), new Vector2(132f, 198f), new Vector2(112f, 20f));
		SetInformationRect(information, "health-regen", new Vector2(0.5f, 0.5f), new Vector2(54f, 76f), new Vector2(64.8f, 20f));
		SetInformationRect(information, "health-info", new Vector2(0.5f, 0.5f), new Vector2(54f, 108f), new Vector2(71.8f, 40f));
		SetInformationRect(information, "health-bar", new Vector2(0.5f, 0.5f), new Vector2(54f, 160f), new Vector2(56f, 56f));
		SetInformationRect(information, "armour-shield-info", new Vector2(0.5f, 0.5f), new Vector2(162f, 108f), new Vector2(71.8f, 40f));
		SetInformationRect(information, "armour-shield-regen", new Vector2(0.5f, 0.5f), new Vector2(162f, 76f), new Vector2(64.8f, 20f));
		SetInformationRect(information, "armour-shield-bar", new Vector2(0.5f, 0.5f), new Vector2(162f, 160f), new Vector2(56f, 56f));
		SetInformationRect(information, "current-order-icon", new Vector2(0.5f, 0.5f), new Vector2(402f, 236f), new Vector2(40f, 40f));
		SetInformationRect(information, "bubble-shield-regen", new Vector2(0.5f, 0.5f), new Vector2(270f, 76f), new Vector2(64.8f, 20f));
		SetInformationRect(information, "bubble-shield-info", new Vector2(0.5f, 0.5f), new Vector2(270f, 108f), new Vector2(71.8f, 40f));
		SetInformationRect(information, "bubble-shield-bar", new Vector2(0.5f, 0.5f), new Vector2(270f, 160f), new Vector2(56f, 56f));
		SetInformationRect(information, "construction-bar", new Vector2(0.5f, 0.5f), new Vector2(378f, 160f), new Vector2(56f, 56f));
		SetInformationRect(information, "construction-percent", new Vector2(0.5f, 0.5f), new Vector2(378f, 108f), new Vector2(54.8f, 22.5f));
		SetInformationRect(information, "current-order-name", new Vector2(0.5f, 0.5f), new Vector2(338f, 214f), new Vector2(76f, 24f));
		SetInformationRect(information, "info-bar-bottom", new Vector2(0.5f, 0.5f), new Vector2(216f, 32f), new Vector2(432f, 64f));
		ConfigureInformationMetrics(information);
		SyncInformationPortrait(information.GetComponent<InformationPanelUI>()?.unitTemplateId?.text);
	}

	private void AddInformationPortraitPlate(RectTransform information)
	{
		if (information.Find("SupComStyleUI.Skin") != null)
		{
			throw new InvalidOperationException("A stale owned information portrait plate is still present.");
		}
		GameObject obj = new GameObject("SupComStyleUI.Skin", typeof(RectTransform), typeof(ChamferPanelGraphic))
		{
			layer = information.gameObject.layer
		};
		RectTransform component = obj.GetComponent<RectTransform>();
		component.SetParent(information, worldPositionStays: false);
		SetRect(component, Vector2.zero, Vector2.zero, new Vector2(0.5f, 0.5f), new Vector2(64f, 238f), new Vector2(112f, 72f));
		component.SetAsFirstSibling();
		ChamferPanelGraphic component2 = obj.GetComponent<ChamferPanelGraphic>();
		component2.Chamfer = 8f;
		component2.BorderWidth = 2f;
		component2.FillColor = new Color32(5, 14, 21, byte.MaxValue);
		component2.BorderColor = new Color32(81, 165, 177, 230);
		component2.ChamferAllCorners = true;
		component2.AcceptRaycasts = false;
		component2.material = informationPortrait.material;
	}

	private void SyncInformationPortrait(string templateId)
	{
		if (informationPortrait == null)
		{
			return;
		}
		string text = templateId?.Trim();
		if (string.Equals(text, lastInformationPortraitTemplateId, StringComparison.Ordinal))
		{
			return;
		}
		lastInformationPortraitTemplateId = text;
		Sprite sprite = null;
		if (!string.IsNullOrEmpty(text))
		{
			string path = "UI/Sprites/Icons/Units/" + text + ".sansprite";
			sprite = TryLoadInformationPortrait(path);
			if (sprite == null)
			{
				sprite = TryLoadInformationPortrait("UI/Sprites/Icons/Units/default.sansprite");
			}
		}
		informationPortrait.sprite = sprite;
		informationPortrait.enabled = sprite != null;
	}

	private Sprite TryLoadInformationPortrait(string path)
	{
		try
		{
			return Load.LoadGamedataSprite(Data.GetFileEntry(path))?.GetSprite();
		}
		catch (Exception exception)
		{
			HandlePortraitBindingFailure(exception);
			return null;
		}
	}

	private void HandlePortraitBindingFailure(Exception exception)
	{
		if (!portraitLoadWarningLogged)
		{
			base.Logger.LogWarning("A unit portrait could not be displayed; the rest of the HUD remains active. " + exception.Message);
			portraitLoadWarningLogged = true;
		}
		if (informationPortrait != null)
		{
			informationPortrait.sprite = null;
			informationPortrait.enabled = false;
		}
	}

	private void ConfigureInformationMetrics(RectTransform information)
	{
		HorizontalLayoutGroup horizontalLayoutGroup = (information.Find("info-bar-bottom/content") as RectTransform)?.GetComponent<HorizontalLayoutGroup>();
		if (horizontalLayoutGroup == null)
		{
			throw new InvalidOperationException("Information metric-row layout contract is missing.");
		}
		Capture(horizontalLayoutGroup);
		horizontalLayoutGroup.enabled = false;
		SetInformationRect(information, "info-bar-bottom/content/constant-info", Vector2.zero, new Vector2(12f, 0f), new Vector2(64f, 58f));
		SetInformationRect(information, "info-bar-bottom/content/energy-info", Vector2.zero, new Vector2(88f, 0f), new Vector2(114f, 58f));
		SetInformationRect(information, "info-bar-bottom/content/alloy-info", Vector2.zero, new Vector2(214f, 0f), new Vector2(114f, 58f));
		SetInformationRect(information, "info-bar-bottom/content/capacity-info", Vector2.zero, new Vector2(340f, 0f), new Vector2(80f, 58f));
	}

	private void SetInformationRect(RectTransform information, string path, Vector2 pivot, Vector2 position, Vector2 size)
	{
		RectTransform rectTransform = information.Find(path) as RectTransform;
		if (rectTransform == null)
		{
			throw new InvalidOperationException("Information panel layout path is missing: " + path + ".");
		}
		Capture(rectTransform);
		SetRect(rectTransform, Vector2.zero, Vector2.zero, pivot, position, size);
	}

	private void ConfigureOrdersGrid(RectTransform orders)
	{
		GridLayoutGroup gridLayoutGroup = (orders.Find("content") as RectTransform)?.GetComponent<GridLayoutGroup>();
		if (gridLayoutGroup == null)
		{
			throw new InvalidOperationException("Orders grid layout contract is missing.");
		}
		CaptureGridLayout(gridLayoutGroup);
		RectTransform rectTransform = (RectTransform)gridLayoutGroup.transform;
		Capture(rectTransform);
		ContentSizeFitter component = rectTransform.GetComponent<ContentSizeFitter>();
		if (component != null)
		{
			Capture(component);
			component.enabled = false;
		}
		Stretch(rectTransform);
		rectTransform.offsetMin = new Vector2(6f, 8f);
		rectTransform.offsetMax = -rectTransform.offsetMin;
		gridLayoutGroup.padding = new RectOffset(0, 0, 0, 0);
		gridLayoutGroup.childAlignment = TextAnchor.UpperLeft;
		gridLayoutGroup.startCorner = GridLayoutGroup.Corner.UpperLeft;
		gridLayoutGroup.startAxis = GridLayoutGroup.Axis.Horizontal;
		gridLayoutGroup.cellSize = new Vector2(72f, 72f);
		gridLayoutGroup.spacing = new Vector2(2f, 8f);
		gridLayoutGroup.constraint = GridLayoutGroup.Constraint.FixedColumnCount;
		gridLayoutGroup.constraintCount = 7;
	}

	private void ResizeOrdersPanelToButtons()
	{
		Transform obj = ordersPanelRoot.Find("content");
		int num = 0;
		foreach (Transform item in obj)
		{
			LayoutElement component = item.GetComponent<LayoutElement>();
			if (item.gameObject.activeInHierarchy && (component == null || !component.ignoreLayout))
			{
				num++;
			}
		}
		ordersPanelRoot.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, Mathf.Max(280f, CommandGridGeometry.Height(num)));
	}

	private float GetCommandCoreHeight()
	{
		if (!IsVisible(ordersPanelRoot.GetComponent<CanvasGroup>()))
		{
			return 280f;
		}
		return Mathf.Max(280f, ordersPanelRoot.rect.height);
	}

	private void ConfigureSelectionStrip(RectTransform selection)
	{
		RectTransform rectTransform = FindRect(selection, "Panel Dashed");
		RectTransform rectTransform2 = FindRect(selection, "Panel Dashed/Dashed Area");
		RectTransform rectTransform3 = FindRect(selection, "Panel Dashed/Dashed Area/Panel Buttons");
		if (rectTransform == null || rectTransform2 == null || rectTransform3 == null)
		{
			throw new InvalidOperationException("Selection strip layout contract is missing.");
		}
		Capture(rectTransform);
		Capture(rectTransform2);
		Capture(rectTransform3);
		DisableLayouts(rectTransform);
		DisableLayouts(rectTransform2);
		DisableLayouts(rectTransform3);
		selectionButtonsRoot = rectTransform3;
		selection.SetAsLastSibling();
		Stretch(rectTransform);
		Stretch(rectTransform2);
		rectTransform3.anchorMin = Vector2.zero;
		rectTransform3.anchorMax = Vector2.one;
		rectTransform3.pivot = new Vector2(0.5f, 0.5f);
		rectTransform3.offsetMin = Vector2.zero;
		rectTransform3.offsetMax = Vector2.zero;
		rectTransform3.localRotation = Quaternion.identity;
		rectTransform3.localScale = Vector3.one;
	}

	private bool ReflowBottomDeck()
	{
		if (reflowInProgress)
		{
			return true;
		}
		if (uiRoot == null || leftPanelsRoot == null || constructionPanelsRoot == null || selectionPanelRoot == null || selectionButtonsRoot == null || commandBay == null || fabricationBay == null || economyRoot == null)
		{
			return false;
		}
		reflowInProgress = true;
		try
		{
			ResizeOrdersPanelToButtons();
			if (appliedLayoutPreset == 1)
			{
				Rect safeCanvasRect = GetSafeCanvasRect();
				return ReflowClassicBottomDeck(safeCanvasRect, safeCanvasRect.height, 0f, default(Bounds));
			}
			if (!ResizeConstructionPanelToActiveButtons())
			{
				return false;
			}
			float num = ((appliedLayoutPreset == 1) ? 0.9f : 1f);
			leftPanelsRoot.localScale = new Vector3(num, num, 1f);
			constructionPanelsRoot.localScale = new Vector3(num, num, 1f);
			LayoutRebuilder.ForceRebuildLayoutImmediate(constructionPanelsRoot);
			Canvas.ForceUpdateCanvases();
			Rect safeCanvasRect2 = GetSafeCanvasRect();
			float num2 = ((appliedLayoutPreset == 1) ? 1828f : 1852f);
			if (safeCanvasRect2.width < num2)
			{
				return false;
			}
			float height = safeCanvasRect2.height;
			float num3 = ((appliedLayoutPreset == 1) ? 44f : 0f);
			float num4 = ((appliedLayoutPreset == 1) ? (32f + num3) : 24f);
			float num5 = ((appliedLayoutPreset == 1) ? 32f : 24f);
			constructionPanelsRoot.anchoredPosition = new Vector2(0f - (uiRoot.rect.xMax - safeCanvasRect2.xMax + num4), safeCanvasRect2.yMin - uiRoot.rect.yMin + num5);
			LayoutRebuilder.ForceRebuildLayoutImmediate(constructionPanelsRoot);
			Canvas.ForceUpdateCanvases();
			LayoutCommanderUpgradeSectionHeadings();
			Bounds bounds = RectTransformUtility.CalculateRelativeRectTransformBounds(uiRoot, constructionPanelsRoot);
			Bounds constructionBounds = bounds;
			constructionBounds.center += new Vector3(num3, 0f, 0f);
			float num6 = Mathf.Min(safeCanvasRect2.xMax - 708f, constructionBounds.min.x) - safeCanvasRect2.xMin - 32f;
			if (appliedLayoutPreset == 1)
			{
				return ReflowClassicBottomDeck(safeCanvasRect2, height, num6, constructionBounds);
			}
			bool flag = ShouldEmbedSelection();
			float num7 = (flag ? 128f : 968f);
			float num8 = LayoutSelectionChildren(num7, flag ? 84f : 0f);
			float visibleCommandWidth = GetVisibleCommandWidth(flag);
			if (num6 < visibleCommandWidth + 24f)
			{
				return false;
			}
			float y = GetCommandCoreHeight() + ((!flag && num8 > 0f) ? (8f + num8) : 0f);
			float visibleLeftHeight = GetVisibleLeftHeight(num8, flag);
			float visibleFabricationHeight = GetVisibleFabricationHeight(safeCanvasRect2.yMin);
			float num9 = Mathf.Max(36f, visibleLeftHeight + 16f);
			float num10 = Mathf.Max(36f, visibleFabricationHeight);
			float num11 = Mathf.Max(36f, Mathf.Max(num9 + 16f, num10 + 16f));
			if (num11 > Mathf.Min(760f, height * 0.5f))
			{
				return false;
			}
			if (228f + num11 + 32f > height)
			{
				return false;
			}
			Vector2 vector = new Vector2(safeCanvasRect2.xMin + 24f, safeCanvasRect2.yMin + 24f);
			float x = safeCanvasRect2.center.x - uiRoot.rect.center.x;
			leftPanelsRoot.anchoredPosition = new Vector2(vector.x - uiRoot.rect.xMin, vector.y - uiRoot.rect.yMin);
			leftPanelsRoot.sizeDelta = new Vector2(968f, y);
			economyRoot.anchoredPosition = new Vector2(x, safeCanvasRect2.yMax - uiRoot.rect.yMax);
			economyRoot.sizeDelta = new Vector2(0f - Mathf.Max(0f, uiRoot.rect.width - safeCanvasRect2.width), 112f);
			ReflowTopCenterCluster(safeCanvasRect2);
			selectionPanelRoot.anchoredPosition = (flag ? new Vector2(0f, 196f) : new Vector2(0f, GetCommandCoreHeight() + 8f));
			selectionPanelRoot.sizeDelta = new Vector2(num7, num8);
			commandBay.anchoredPosition = new Vector2(safeCanvasRect2.xMin - uiRoot.rect.xMin + 16f, safeCanvasRect2.yMin - uiRoot.rect.yMin + 16f);
			commandBay.sizeDelta = new Vector2(visibleCommandWidth + 16f, num9);
			ReflowCommandDivider(1f);
			float num12 = bounds.min.x - uiRoot.rect.xMin - 16f;
			float num13 = Mathf.Min(safeCanvasRect2.xMax - uiRoot.rect.xMin - 8f, bounds.max.x - uiRoot.rect.xMin + 16f);
			float num14 = commandBay.anchoredPosition.x + commandBay.sizeDelta.x;
			if (num13 <= num12 || num12 < num14 + 8f)
			{
				return false;
			}
			fabricationBay.anchoredPosition = new Vector2(num12, safeCanvasRect2.yMin - uiRoot.rect.yMin + 16f);
			fabricationBay.sizeDelta = new Vector2(num13 - num12, num10);
			ReflowUnitTooltip(safeCanvasRect2, 112f);
			return true;
		}
		finally
		{
			reflowInProgress = false;
		}
	}

	private bool ResizeConstructionPanelToActiveButtons()
	{
		if (constructionPanelRoot == null || constructionButtonsRoot == null)
		{
			return false;
		}
		bool flag = false;
		foreach (Transform item in constructionButtonsRoot)
		{
			if (IsActivePooledItem(item))
			{
				UnitButtonElement component = item.GetComponent<UnitButtonElement>();
				bool flag2 = GetCommanderUpgradeSlotIndex(component) >= 0;
				flag = flag || flag2;
				StyleCommanderUpgradeProgressLabel(component, flag2);
			}
		}
		SetCommanderUpgradeHeaderSpace(flag);
		LayoutRebuilder.ForceRebuildLayoutImmediate(constructionButtonsRoot);
		float preferredWidth = LayoutUtility.GetPreferredWidth(constructionButtonsRoot);
		if (float.IsNaN(preferredWidth) || float.IsInfinity(preferredWidth) || preferredWidth < 0f)
		{
			return false;
		}
		float num = Mathf.Max(708f, preferredWidth + 70f);
		if (float.IsNaN(num) || float.IsInfinity(num))
		{
			return false;
		}
		constructionPanelRoot.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, num);
		LayoutRebuilder.ForceRebuildLayoutImmediate(constructionPanelRoot);
		if (!float.IsNaN(constructionPanelRoot.rect.width) && !float.IsInfinity(constructionPanelRoot.rect.width) && constructionPanelRoot.rect.width >= 708f)
		{
			return true;
		}
		return false;
	}

	private void SetCommanderUpgradeHeaderSpace(bool hasUpgradeButtons)
	{
		if (constructionPanelRoot != null && constructionPanelNativeHeight > 0f)
		{
			constructionPanelRoot.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, constructionPanelNativeHeight + (hasUpgradeButtons ? 36f : 0f));
		}
	}

	private void StyleCommanderUpgradeProgressLabel(UnitButtonElement button, bool isUpgrade)
	{
		TMP_Text tMP_Text = button?.textOverlayText;
		RectTransform rectTransform = button?.textOverlayContainer?.transform as RectTransform;
		if (tMP_Text == null || rectTransform == null)
		{
			return;
		}
		if (commanderUpgradeProgressContainers.TryGetValue(rectTransform.GetInstanceID(), out var value))
		{
			value.Restore();
			RestoreNativeTextState(tMP_Text);
		}
		if (isUpgrade)
		{
			if (value == null)
			{
				commanderUpgradeProgressContainers.Add(rectTransform.GetInstanceID(), new PooledRectTransformState(rectTransform));
				CapturePooled(rectTransform);
				Capture(tMP_Text);
			}
			rectTransform.anchorMin = Vector2.zero;
			rectTransform.anchorMax = new Vector2(1f, 0f);
			rectTransform.pivot = new Vector2(0.5f, 0f);
			rectTransform.anchoredPosition = new Vector2(0f, 4f);
			rectTransform.sizeDelta = new Vector2(-8f, 24f);
			tMP_Text.alignment = TextAlignmentOptions.Center;
			tMP_Text.fontStyle = FontStyles.Bold;
			tMP_Text.fontSize = 18f;
			tMP_Text.enableAutoSizing = false;
			tMP_Text.enableWordWrapping = false;
			tMP_Text.overflowMode = TextOverflowModes.Ellipsis;
		}
	}

	private void BuildCommanderUpgradeHeadingOverlay(RectTransform parent, TextMeshProUGUI fontSource)
	{
		if (parent == null || fontSource == null)
		{
			throw new InvalidOperationException("Commander upgrade heading overlay prerequisites are missing.");
		}
		if (parent.Find("SupComStyleUI.CommanderUpgradeHeadings") != null)
		{
			throw new InvalidOperationException("A stale commander upgrade heading overlay is still present.");
		}
		GameObject gameObject = new GameObject("SupComStyleUI.CommanderUpgradeHeadings", typeof(RectTransform), typeof(CanvasGroup), typeof(LayoutElement))
		{
			layer = parent.gameObject.layer
		};
		gameObject.GetComponent<LayoutElement>().ignoreLayout = true;
		commanderUpgradeHeadingsRoot = gameObject.GetComponent<RectTransform>();
		commanderUpgradeHeadingsRoot.SetParent(parent, worldPositionStays: false);
		Stretch(commanderUpgradeHeadingsRoot);
		commanderUpgradeHeadingsRoot.SetAsLastSibling();
		CanvasGroup component = gameObject.GetComponent<CanvasGroup>();
		component.alpha = 1f;
		component.interactable = false;
		component.blocksRaycasts = false;
		commanderUpgradeLeftArmHeading = CreateCommanderUpgradeHeading(commanderUpgradeHeadingsRoot, "Left Arm", "LEFT ARM", fontSource);
		commanderUpgradeBackHeading = CreateCommanderUpgradeHeading(commanderUpgradeHeadingsRoot, "Back", "BACK", fontSource);
		commanderUpgradeRightArmHeading = CreateCommanderUpgradeHeading(commanderUpgradeHeadingsRoot, "Right Arm", "RIGHT ARM", fontSource);
		commanderUpgradeHeadingsRoot.gameObject.SetActive(value: false);
	}

	private static TextMeshProUGUI CreateCommanderUpgradeHeading(RectTransform parent, string name, string label, TextMeshProUGUI fontSource)
	{
		GameObject obj = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer), typeof(TextMeshProUGUI))
		{
			layer = parent.gameObject.layer
		};
		RectTransform component = obj.GetComponent<RectTransform>();
		component.SetParent(parent, worldPositionStays: false);
		component.anchorMin = new Vector2(0.5f, 0.5f);
		component.anchorMax = new Vector2(0.5f, 0.5f);
		component.pivot = new Vector2(0.5f, 0.5f);
		component.localRotation = Quaternion.identity;
		component.localScale = Vector3.one;
		TextMeshProUGUI component2 = obj.GetComponent<TextMeshProUGUI>();
		component2.text = label;
		component2.font = fontSource.font;
		component2.fontSharedMaterial = fontSource.fontSharedMaterial;
		component2.color = CommanderUpgradeSectionHeadingTextColor;
		component2.fontStyle = FontStyles.Bold;
		component2.alignment = TextAlignmentOptions.Center;
		component2.fontSize = 18f;
		component2.enableAutoSizing = false;
		component2.enableWordWrapping = false;
		component2.overflowMode = TextOverflowModes.Ellipsis;
		component2.raycastTarget = false;
		component2.gameObject.SetActive(value: false);
		return component2;
	}

	private void LayoutCommanderUpgradeSectionHeadings()
	{
		if (constructionFilterButtonsRoot == null || constructionButtonsRoot == null || commanderUpgradeHeadingsRoot == null)
		{
			return;
		}
		ResetMigratedCommanderUpgradeHeadings();
		HideCommanderUpgradeHeadingOverlay();
		ConstructionFilterToggleElement[] array = new ConstructionFilterToggleElement[3];
		bool flag = false;
		foreach (Transform item in constructionFilterButtonsRoot)
		{
			if (!IsActivePooledItem(item))
			{
				continue;
			}
			ConstructionFilterToggleElement component = item.GetComponent<ConstructionFilterToggleElement>();
			int commanderUpgradeHeadingIndex = GetCommanderUpgradeHeadingIndex(component);
			if (commanderUpgradeHeadingIndex >= 0)
			{
				if (array[commanderUpgradeHeadingIndex] != null)
				{
					flag = true;
				}
				else
				{
					array[commanderUpgradeHeadingIndex] = component;
				}
			}
		}
		Bounds[] array2 = new Bounds[3];
		bool[] array3 = new bool[3];
		foreach (Transform item2 in constructionButtonsRoot)
		{
			if (IsActivePooledItem(item2))
			{
				int commanderUpgradeSlotIndex = GetCommanderUpgradeSlotIndex(item2.GetComponent<UnitButtonElement>());
				if (commanderUpgradeSlotIndex >= 0 && item2 is RectTransform child)
				{
					Bounds value = RectTransformUtility.CalculateRelativeRectTransformBounds(commanderUpgradeHeadingsRoot, child);
					IncludeBounds(ref array2[commanderUpgradeSlotIndex], ref array3[commanderUpgradeSlotIndex], value);
				}
			}
		}
		bool flag2 = false;
		bool flag3 = false;
		bool flag4 = !flag;
		for (int i = 0; i < array.Length; i++)
		{
			bool flag5 = array[i] != null;
			flag2 = flag2 || flag5;
			flag3 |= array3[i];
			flag4 &= flag5 == array3[i];
		}
		if (!flag2 || !flag4)
		{
			for (int j = 0; j < array.Length; j++)
			{
				SetNativeCommanderUpgradeHeadingMode(array[j], useOverlay: false);
			}
			LayoutRebuilder.ForceRebuildLayoutImmediate(constructionFilterButtonsRoot);
			if (flag3 && !commanderUpgradeHeadingLayoutWarningLogged)
			{
				base.Logger.LogWarning("Commander upgrade headings remain in the native filter row because the tooltip-to-heading mapping is incomplete.");
				commanderUpgradeHeadingLayoutWarningLogged = true;
			}
			return;
		}
		for (int k = 0; k < array.Length; k++)
		{
			SetNativeCommanderUpgradeHeadingMode(array[k], useOverlay: true);
		}
		LayoutRebuilder.ForceRebuildLayoutImmediate(constructionFilterButtonsRoot);
		commanderUpgradeHeadingsRoot.gameObject.SetActive(value: true);
		commanderUpgradeHeadingsRoot.SetAsLastSibling();
		if (array3[0])
		{
			PositionCommanderUpgradeHeading(commanderUpgradeLeftArmHeading, array2[0]);
		}
		if (array3[1])
		{
			PositionCommanderUpgradeHeading(commanderUpgradeBackHeading, array2[1]);
		}
		if (array3[2])
		{
			PositionCommanderUpgradeHeading(commanderUpgradeRightArmHeading, array2[2]);
		}
	}

	private static bool IsActivePooledItem(Transform item)
	{
		if (item == null || !item.gameObject.activeInHierarchy || item.localScale.sqrMagnitude < 0.01f)
		{
			return false;
		}
		LayoutElement component = item.GetComponent<LayoutElement>();
		if (component != null)
		{
			return !component.ignoreLayout;
		}
		return false;
	}

	private static int GetCommanderUpgradeHeadingIndex(ConstructionFilterToggleElement heading)
	{
		string a = heading?.displayText?.text;
		if (string.Equals(a, "LEFT ARM", StringComparison.Ordinal))
		{
			return 0;
		}
		if (string.Equals(a, "BACK", StringComparison.Ordinal))
		{
			return 1;
		}
		if (!string.Equals(a, "RIGHT ARM", StringComparison.Ordinal))
		{
			return -1;
		}
		return 2;
	}

	private static int GetCommanderUpgradeSlotIndex(UnitButtonElement button)
	{
		return GetCommanderUpgradeSlotIndex((button?.GetComponent<TooltipTrigger>())?.description);
	}

	private static int GetCommanderUpgradeSlotIndex(string description)
	{
		if (description != null && description.StartsWith("Slot: Left Arm.", StringComparison.Ordinal))
		{
			return 0;
		}
		if (description != null && description.StartsWith("Slot: Back.", StringComparison.Ordinal))
		{
			return 1;
		}
		if (description == null || !description.StartsWith("Slot: Right Arm.", StringComparison.Ordinal))
		{
			return -1;
		}
		return 2;
	}

	private static void IncludeBounds(ref Bounds combined, ref bool hasBounds, Bounds value)
	{
		if (hasBounds)
		{
			combined.Encapsulate(value);
			return;
		}
		combined = value;
		hasBounds = true;
	}

	private void SetNativeCommanderUpgradeHeadingMode(ConstructionFilterToggleElement heading, bool useOverlay)
	{
		if (!(heading == null))
		{
			LayoutElement component = heading.GetComponent<LayoutElement>();
			if (component != null)
			{
				component.ignoreLayout = useOverlay;
			}
			if (heading.displayText != null)
			{
				heading.displayText.enabled = !useOverlay;
			}
			if (useOverlay && !commanderUpgradeMigratedHeadings.Contains(heading))
			{
				commanderUpgradeMigratedHeadings.Add(heading);
			}
		}
	}

	private void ResetMigratedCommanderUpgradeHeadings()
	{
		for (int i = 0; i < commanderUpgradeMigratedHeadings.Count; i++)
		{
			ConstructionFilterToggleElement constructionFilterToggleElement = commanderUpgradeMigratedHeadings[i];
			if (!(constructionFilterToggleElement == null))
			{
				LayoutElement component = constructionFilterToggleElement.GetComponent<LayoutElement>();
				if (component != null)
				{
					component.ignoreLayout = false;
				}
				if (IsCommanderUpgradeSectionHeading(constructionFilterToggleElement) && constructionFilterToggleElement.displayText != null)
				{
					constructionFilterToggleElement.displayText.enabled = true;
				}
			}
		}
		commanderUpgradeMigratedHeadings.Clear();
	}

	private void RestoreNativeCommanderUpgradeHeadings()
	{
		ResetMigratedCommanderUpgradeHeadings();
		SetCommanderUpgradeHeaderSpace(hasUpgradeButtons: false);
		if (constructionFilterButtonsRoot != null)
		{
			foreach (Transform item in constructionFilterButtonsRoot)
			{
				if (IsActivePooledItem(item))
				{
					ConstructionFilterToggleElement component = item.GetComponent<ConstructionFilterToggleElement>();
					if (IsCommanderUpgradeSectionHeading(component))
					{
						SetNativeCommanderUpgradeHeadingMode(component, useOverlay: false);
					}
				}
			}
			LayoutRebuilder.ForceRebuildLayoutImmediate(constructionFilterButtonsRoot);
		}
		HideCommanderUpgradeHeadingOverlay();
	}

	private void PositionCommanderUpgradeHeading(TextMeshProUGUI heading, Bounds groupBounds)
	{
		if (!(heading == null) && !(commanderUpgradeHeadingsRoot == null))
		{
			Rect rect = commanderUpgradeHeadingsRoot.rect;
			float a = Mathf.Max(groupBounds.size.x, heading.GetPreferredValues(heading.text).x + 12f);
			a = Mathf.Min(a, Mathf.Max(1f, rect.width - 8f));
			float num = rect.xMin + 4f + a * 0.5f;
			float num2 = rect.xMax - 4f - a * 0.5f;
			float num3 = ((num <= num2) ? Mathf.Clamp(groupBounds.center.x, num, num2) : rect.center.x);
			float min = rect.yMin + 12f;
			float max = rect.yMax - 4f - 12f;
			float num4 = Mathf.Clamp(groupBounds.max.y + 6f + 12f, min, max);
			RectTransform rectTransform = heading.rectTransform;
			rectTransform.anchorMin = new Vector2(0.5f, 0.5f);
			rectTransform.anchorMax = new Vector2(0.5f, 0.5f);
			rectTransform.pivot = new Vector2(0.5f, 0.5f);
			rectTransform.anchoredPosition = new Vector2(num3 - rect.center.x, num4 - rect.center.y);
			rectTransform.sizeDelta = new Vector2(a, 24f);
			heading.gameObject.SetActive(value: true);
		}
	}

	private void HideCommanderUpgradeHeadingOverlay()
	{
		if (commanderUpgradeLeftArmHeading != null)
		{
			commanderUpgradeLeftArmHeading.gameObject.SetActive(value: false);
		}
		if (commanderUpgradeBackHeading != null)
		{
			commanderUpgradeBackHeading.gameObject.SetActive(value: false);
		}
		if (commanderUpgradeRightArmHeading != null)
		{
			commanderUpgradeRightArmHeading.gameObject.SetActive(value: false);
		}
		if (commanderUpgradeHeadingsRoot != null)
		{
			commanderUpgradeHeadingsRoot.gameObject.SetActive(value: false);
		}
	}

	private bool ReflowClassicBottomDeck(Rect safeRect, float canvasHeight, float availableLeftWidth, Bounds constructionBounds)
	{
		bool flag = ShouldEmbedSelection();
		float num = (flag ? 128f : 968f);
		float num2 = LayoutSelectionChildren(num, flag ? 84f : 0f);
		float visibleCommandWidth = GetVisibleCommandWidth(flag);
		float visibleLeftHeight = GetVisibleLeftHeight(num2, flag);
		leftPanelsRoot.localScale = new Vector3(0.9f, 0.9f, 1f);
		leftPanelsRoot.anchoredPosition = new Vector2(safeRect.xMin - uiRoot.rect.xMin + 24f, safeRect.yMin - uiRoot.rect.yMin + 24f);
		leftPanelsRoot.sizeDelta = new Vector2(968f, GetCommandCoreHeight() + ((!flag && num2 > 0f) ? (8f + num2) : 0f));
		selectionPanelRoot.anchoredPosition = (flag ? new Vector2(0f, 196f) : new Vector2(0f, GetCommandCoreHeight() + 8f));
		selectionPanelRoot.sizeDelta = new Vector2(num, num2);
		commandBay.anchoredPosition = new Vector2(safeRect.xMin - uiRoot.rect.xMin + 16f, safeRect.yMin - uiRoot.rect.yMin + 16f);
		commandBay.sizeDelta = new Vector2(visibleCommandWidth * 0.9f + 16f, Mathf.Max(36f, visibleLeftHeight * 0.9f + 16f));
		ReflowCommandDivider(0.9f);
		ClassicStripGeometry classicStripGeometry = ClassicStripGeometry.Calculate(safeRect.width, 919.19995f);
		float num3 = classicStripGeometry.Width / 0.9f;
		DisableLayouts(constructionPanelsRoot);
		SetRect(constructionPanelsRoot, Vector2.zero, Vector2.zero, Vector2.zero, new Vector2(safeRect.xMin - uiRoot.rect.xMin + classicStripGeometry.Left, safeRect.yMin - uiRoot.rect.yMin + 24f), new Vector2(num3, 1f));
		constructionPanelsRoot.localScale = new Vector3(0.9f, 0.9f, 1f);
		RestoreNativeCommanderUpgradeHeadings();
		bool flag2 = false;
		foreach (Transform item in constructionButtonsRoot)
		{
			if (IsActivePooledItem(item) && GetCommanderUpgradeSlotIndex(item.GetComponent<UnitButtonElement>()) >= 0)
			{
				flag2 = true;
			}
		}
		float num4 = Mathf.Min(760f, canvasHeight * (flag2 ? 0.6f : 0.5f));
		float num5 = 108f;
		float num6;
		while (true)
		{
			num6 = LayoutClassicStripPanel(UIPanelType.Construction, num3, 0f, num5);
			num6 += LayoutClassicStripPanel(UIPanelType.ConstructionFilter, num3, num6, 36f);
			num6 += LayoutClassicStripPanel(UIPanelType.ConstructionQueue, num3, num6, num5 * 8f / 9f);
			if (num6 * 0.9f + 16f <= num4 || num5 <= 72f)
			{
				break;
			}
			num5 -= 12f;
		}
		constructionPanelsRoot.sizeDelta = new Vector2(num3, Mathf.Max(1f, num6));
		Canvas.ForceUpdateCanvases();
		LayoutCommanderUpgradeSectionHeadings();
		float num7 = Mathf.Max(36f, num6 * 0.9f + 16f);
		if (Mathf.Max(num7, commandBay.sizeDelta.y) > num4)
		{
			return false;
		}
		fabricationBay.anchoredPosition = new Vector2(safeRect.xMin - uiRoot.rect.xMin + classicStripGeometry.Left - 8f, safeRect.yMin - uiRoot.rect.yMin + 16f);
		fabricationBay.sizeDelta = new Vector2(classicStripGeometry.Width + 16f, num7);
		economyRoot.anchoredPosition = new Vector2(safeRect.center.x - uiRoot.rect.center.x, safeRect.yMax - uiRoot.rect.yMax);
		economyRoot.sizeDelta = new Vector2(0f - Mathf.Max(0f, uiRoot.rect.width - safeRect.width), 68f);
		ReflowTopCenterCluster(safeRect);
		ReflowUnitTooltip(safeRect, 68f);
		return true;
	}

	private float LayoutClassicStripPanel(UIPanelType panelType, float width, float bottom, float buttonHeight)
	{
		if (!appliedManager.TryGetPanel(panelType, out var panel) || panel.itemContainer == null)
		{
			throw new InvalidOperationException("The build strip panel is unavailable: " + panelType);
		}
		RectTransform rectTransform = panel.transform as RectTransform;
		RectTransform rectTransform2 = panel.itemContainer as RectTransform;
		if (rectTransform == null || rectTransform2 == null)
		{
			throw new InvalidOperationException("The build strip requires native RectTransforms.");
		}
		Transform transform = rectTransform2;
		while (transform != constructionPanelsRoot)
		{
			if (transform == null)
			{
				throw new InvalidOperationException("The build strip hierarchy changed.");
			}
			RectTransform rect = transform as RectTransform;
			Capture(rect);
			DisableLayouts(transform);
			Stretch(rect);
			transform = transform.parent;
		}
		if (!IsVisible(panel.GetComponent<CanvasGroup>()))
		{
			SetRect(rectTransform, Vector2.zero, Vector2.zero, Vector2.zero, new Vector2(0f, bottom), new Vector2(width, 1f));
			return 0f;
		}
		bool flag = false;
		foreach (Transform item2 in rectTransform2)
		{
			if (IsActivePooledItem(item2) && GetCommanderUpgradeSlotIndex(item2.GetComponent<UnitButtonElement>()) >= 0)
			{
				flag = true;
			}
		}
		if (flag)
		{
			buttonHeight = 72f;
		}
		StripPacking stripPacking = new StripPacking(width, buttonHeight);
		UpgradeStripPacking upgradeStripPacking = (flag ? new UpgradeStripPacking(width, buttonHeight) : null);
		List<Transform> list = new List<Transform>();
		if (flag)
		{
			for (int i = -1; i < 3; i++)
			{
				foreach (Transform item3 in rectTransform2)
				{
					if (GetCommanderUpgradeSlotIndex(item3.GetComponent<UnitButtonElement>()) == i)
					{
						list.Add(item3);
					}
				}
			}
		}
		else
		{
			foreach (Transform item4 in rectTransform2)
			{
				list.Add(item4);
			}
		}
		foreach (Transform item5 in list)
		{
			if (!IsActivePooledItem(item5) || !(item5 is RectTransform rect2))
			{
				continue;
			}
			Element component = item5.GetComponent<Element>();
			if (flag && component == null)
			{
				CapturePooled(rect2);
				SetRect(rect2, Vector2.zero, Vector2.zero, Vector2.zero, Vector2.zero, Vector2.zero);
				continue;
			}
			float num = ((component == null) ? 24f : 112f);
			if (component is ConstructionFilterToggleElement element)
			{
				num = (IsCommanderUpgradeSectionHeading(element) ? GetCommanderUpgradeSectionHeadingWidth(element) : (IsCommanderUpgradeFilter(element) ? 112f : 56f));
			}
			int commanderUpgradeSlotIndex = GetCommanderUpgradeSlotIndex(component as UnitButtonElement);
			StripCell stripCell = ((flag && commanderUpgradeSlotIndex >= 0) ? upgradeStripPacking.Place(commanderUpgradeSlotIndex, num) : stripPacking.Place(num));
			float num2 = stripCell.Y + ((flag && commanderUpgradeSlotIndex >= 0) ? stripPacking.Height : 0f);
			CapturePooled(rect2);
			SetRect(rect2, new Vector2(0f, 1f), new Vector2(0f, 1f), new Vector2(0f, 1f), new Vector2(stripCell.X, 0f - num2), new Vector2(num, buttonHeight));
			if (component is UnitButtonElement button)
			{
				ResizeUnitPortrait(button, num, buttonHeight);
				StyleCommanderUpgradeProgressLabel(button, flag && GetCommanderUpgradeSlotIndex(button) >= 0);
			}
		}
		float num3 = stripPacking.Height + (flag ? upgradeStripPacking.Height : 0f);
		SetRect(rectTransform, Vector2.zero, Vector2.zero, Vector2.zero, new Vector2(0f, bottom), new Vector2(width, Mathf.Max(1f, num3)));
		return num3;
	}

	private void ResizeUnitPortrait(UnitButtonElement button, float width, float height)
	{
		RectTransform rectTransform = button.portraitImage?.rectTransform;
		if (!(rectTransform == null))
		{
			CapturePooled(rectTransform);
			float num = Mathf.Min(96f, Mathf.Min(width - 12f, height - 8f));
			SetRect(rectTransform, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), Vector2.zero, new Vector2(num, num));
		}
	}

	private void ReflowUnitTooltip(Rect safeRect, float economyHeight)
	{
		if (!(unitTooltipController == null) && !(fabricationBay == null) && !(uiRoot == null))
		{
			float fabricationTop = uiRoot.rect.yMin + fabricationBay.anchoredPosition.y + fabricationBay.sizeDelta.y;
			unitTooltipController.Reflow(safeRect, uiRoot.rect, fabricationTop, economyHeight);
		}
	}

	private void ReflowCommandDivider(float scale)
	{
		if (!(commandDivider == null))
		{
			commandDivider.anchoredPosition = new Vector2(leftPanelsRoot.anchoredPosition.x + 436f * scale - 1f, leftPanelsRoot.anchoredPosition.y + 12f * scale);
			commandDivider.sizeDelta = new Vector2(2f, (GetCommandCoreHeight() - 24f) * scale);
		}
	}

	private void ReflowTopCenterCluster(Rect safeRect)
	{
		if (matchClockPanel == null)
		{
			throw new InvalidOperationException("The match clock panel is unavailable during HUD reflow.");
		}
		float x = Mathf.Clamp((appliedLayoutPreset == 1) ? (safeRect.width * 0.16f - 8f) : 1088f, 280f, 400f);
		float y = ((appliedLayoutPreset == 1) ? 36f : 52f);
		matchClockPanel.sizeDelta = new Vector2(x, y);
		if (economyControlDock != null)
		{
			economyControlDock.sizeDelta = new Vector2(256f, 56f);
		}
		if (teamStatsPanel != null && economyControlDock != null)
		{
			float x2 = Mathf.Clamp(safeRect.width * 0.32f, 520f, 640f);
			float num = economyControlDock.anchoredPosition.y - 28f - 8f;
			teamStatsPanel.anchoredPosition = new Vector2(0f, num);
			teamStatsPanel.sizeDelta = new Vector2(x2, 320f);
			float num2 = ((appliedLayoutPreset == 1) ? 320f : 380f);
			teamStatsFitsSafeArea = safeRect.height >= 0f - num + 320f + num2;
			RefreshTeamStatsView();
			UpdateTeamStatsButtonVisuals();
		}
		UpdateHudCollapseButtonVisuals();
	}

	private void StopTeamStatsForDisabledMod()
	{
		teamHistoryHoverGraphic?.ClearHover();
		teamStatsExpanded = false;
		teamStatsFaulted = false;
		consecutiveTeamStatsFailures = 0;
		lastTeamStatsAttemptTick = -1;
		teamHistorySession.Reset();
		try
		{
			teamTelemetryBridge?.Cleanup();
		}
		catch (Exception ex)
		{
			if (!teamStatsWarningLogged)
			{
				base.Logger.LogWarning("Team telemetry cleanup failed while disabling the mod. " + ex.Message);
				teamStatsWarningLogged = true;
			}
		}
	}

	private void UpdateMatchClock()
	{
		if (layoutApplied && !(matchClockText == null) && ClientEngine.Data.isInitialized)
		{
			int num = Math.Max(0, ClientEngine.GetSimulationTick()) / 10;
			if (num != lastMatchClockSecond)
			{
				lastMatchClockSecond = num;
				int num2 = num / 60;
				int num3 = num % 60;
				matchClockText.text = $"{num2}:{num3:00}";
			}
		}
	}

	private void KeepClassicOuterValuesInsideSafeArea(float safeWidth)
	{
		if (!(appliedEconomy == null))
		{
			float num = Mathf.Max(0f, 66f - 0.029399998f * safeWidth);
			RectTransform rectTransform = appliedEconomy.energyStorageValue.transform as RectTransform;
			RectTransform rectTransform2 = appliedEconomy.alloyStorageValue.transform as RectTransform;
			if (rectTransform != null)
			{
				rectTransform.anchoredPosition = new Vector2(num, -7f);
			}
			if (rectTransform2 != null)
			{
				rectTransform2.anchoredPosition = new Vector2(0f - num, -7f);
			}
		}
	}

	private Rect GetSafeCanvasRect()
	{
		Rect rect = uiRoot.rect;
		Canvas component = uiRoot.GetComponent<Canvas>();
		Camera cam = ((component != null && component.renderMode != RenderMode.ScreenSpaceOverlay) ? component.worldCamera : null);
		if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(uiRoot, Screen.safeArea.min, cam, out var localPoint) || !RectTransformUtility.ScreenPointToLocalPointInRectangle(uiRoot, Screen.safeArea.max, cam, out var localPoint2))
		{
			return rect;
		}
		localPoint.x = Mathf.Clamp(localPoint.x, rect.xMin, rect.xMax);
		localPoint.y = Mathf.Clamp(localPoint.y, rect.yMin, rect.yMax);
		localPoint2.x = Mathf.Clamp(localPoint2.x, localPoint.x, rect.xMax);
		localPoint2.y = Mathf.Clamp(localPoint2.y, localPoint.y, rect.yMax);
		return Rect.MinMaxRect(localPoint.x, localPoint.y, localPoint2.x, localPoint2.y);
	}

	private float GetVisibleFabricationHeight(float safeBottom)
	{
		float num = safeBottom;
		foreach (CanvasGroup fabricationGroup in fabricationGroups)
		{
			if (IsVisible(fabricationGroup))
			{
				num = Mathf.Max(num, RectTransformUtility.CalculateRelativeRectTransformBounds(uiRoot, fabricationGroup.transform).max.y);
			}
		}
		return Mathf.Max(0f, num - safeBottom);
	}

	private float GetVisibleLeftHeight(float selectionHeight, bool selectionEmbedded)
	{
		float num = 0f;
		if (informationPanelRoot != null && IsVisible(informationPanelRoot.GetComponent<CanvasGroup>()))
		{
			num = Mathf.Max(num, informationPanelRoot.anchoredPosition.y + 280f);
		}
		if (ordersPanelRoot != null && IsVisible(ordersPanelRoot.GetComponent<CanvasGroup>()))
		{
			num = Mathf.Max(num, ordersPanelRoot.anchoredPosition.y + ordersPanelRoot.rect.height);
		}
		if (selectionPanelRoot != null && IsVisible(selectionPanelRoot.GetComponent<CanvasGroup>()))
		{
			num = Mathf.Max(num, selectionEmbedded ? 280f : (GetCommandCoreHeight() + 8f + selectionHeight));
		}
		return num;
	}

	private float GetVisibleCommandWidth(bool selectionEmbedded)
	{
		float num = 0f;
		if (informationPanelRoot != null && IsVisible(informationPanelRoot.GetComponent<CanvasGroup>()))
		{
			num = 432f;
		}
		if (ordersPanelRoot != null && IsVisible(ordersPanelRoot.GetComponent<CanvasGroup>()))
		{
			num = Mathf.Max(num, 968f);
		}
		if (selectionPanelRoot != null && IsVisible(selectionPanelRoot.GetComponent<CanvasGroup>()))
		{
			num = Mathf.Max(num, selectionEmbedded ? 128f : 968f);
		}
		return Mathf.Clamp(num, 0f, 968f);
	}

	private bool ShouldEmbedSelection()
	{
		int num = 0;
		bool flag = false;
		foreach (Transform item in selectionButtonsRoot)
		{
			LayoutElement component = item.GetComponent<LayoutElement>();
			if (item.gameObject.activeInHierarchy && !(component == null) && !component.ignoreLayout && !(item.localScale.sqrMagnitude < 0.01f))
			{
				num++;
				UnitButtonElement component2 = item.GetComponent<UnitButtonElement>();
				flag = component2 != null && component2.textOverlayText != null && string.Equals(component2.textOverlayText.text?.Trim(), "1", StringComparison.Ordinal);
				if (num > 1)
				{
					return false;
				}
			}
		}
		return num == 1 && flag;
	}

	private float LayoutSelectionChildren(float panelWidth, float minimumHeight = 0f)
	{
		float num = Mathf.Max(1f, panelWidth - 16f);
		float num2 = 8f;
		int num3 = 0;
		bool flag = false;
		foreach (Transform item in selectionButtonsRoot)
		{
			LayoutElement component = item.GetComponent<LayoutElement>();
			if (!item.gameObject.activeInHierarchy || component == null || component.ignoreLayout || item.localScale.sqrMagnitude < 0.01f)
			{
				continue;
			}
			RectTransform rectTransform = item as RectTransform;
			if (!(rectTransform == null))
			{
				float num4 = ((item.GetComponent<Element>() != null) ? 112f : 24f);
				if (flag && num2 + num4 > 8f + num)
				{
					num3++;
					num2 = 8f;
				}
				CapturePooled(rectTransform);
				rectTransform.anchorMin = new Vector2(0f, 1f);
				rectTransform.anchorMax = new Vector2(0f, 1f);
				rectTransform.pivot = new Vector2(0.5f, 0.5f);
				rectTransform.sizeDelta = new Vector2(num4, 72f);
				rectTransform.anchoredPosition = new Vector2(num2 + num4 * 0.5f, 0f - (6f + (float)num3 * 80f + 36f));
				rectTransform.localRotation = Quaternion.identity;
				num2 += num4 + 8f;
				flag = true;
			}
		}
		float b = (flag ? (12f + (float)num3 * 80f + 72f) : 0f);
		return Mathf.Max(minimumHeight, b);
	}

	private void DisableLayouts(Transform transform)
	{
		LayoutGroup[] components = transform.GetComponents<LayoutGroup>();
		foreach (LayoutGroup layoutGroup in components)
		{
			Capture(layoutGroup);
			layoutGroup.enabled = false;
		}
		ContentSizeFitter[] components2 = transform.GetComponents<ContentSizeFitter>();
		foreach (ContentSizeFitter contentSizeFitter in components2)
		{
			Capture(contentSizeFitter);
			contentSizeFitter.enabled = false;
		}
	}

	private void DisableDecorativeDashedPanel(Transform panelDashed)
	{
		if (panelDashed == null)
		{
			return;
		}
		Graphic[] componentsInChildren = panelDashed.GetComponentsInChildren<Graphic>(includeInactive: true);
		foreach (Graphic graphic in componentsInChildren)
		{
			string text = graphic.gameObject.name;
			switch (text)
			{
			case "portrait":
			case "strategicIcon":
			case "icon":
			case "text":
			case "text-bg":
			case "Image":
				continue;
			}
			if (!text.Contains("Hover") && !text.Contains("Progress") && !text.Contains("Glow") && !text.Contains("Border") && (text.Contains("Dash") || text.Contains("Separator") || text.Contains("Paging") || graphic.transform == panelDashed))
			{
				DisableGraphic(graphic);
			}
		}
	}

	private void DisableGraphicsUnder(Transform transform)
	{
		if (!(transform == null))
		{
			Graphic[] componentsInChildren = transform.GetComponentsInChildren<Graphic>(includeInactive: true);
			foreach (Graphic graphic in componentsInChildren)
			{
				DisableGraphic(graphic);
			}
		}
	}

	private void StyleAllPanelElements()
	{
		StylePanelElements(UIPanelType.Orders);
		StylePanelElements(UIPanelType.Selection);
		StylePanelElements(UIPanelType.Construction);
		StylePanelElements(UIPanelType.ConstructionQueue);
		StylePanelElements(UIPanelType.ConstructionFilter);
	}

	private void StylePanelElements(UIPanelType panelType)
	{
		if (appliedManager == null || !appliedManager.TryGetPanel(panelType, out var panel) || panel?.itemContainer == null)
		{
			return;
		}
		foreach (Transform item in panel.itemContainer)
		{
			Element component = item.GetComponent<Element>();
			if (component != null)
			{
				StyleElement(component);
			}
			else
			{
				StyleSeparator(item);
			}
		}
	}

	private void StyleElement(int instanceId)
	{
		if (instanceId != 0)
		{
			Element element = (Resources.InstanceIDToObject(instanceId) as GameObject)?.GetComponent<Element>();
			if (element != null)
			{
				StyleElement(element);
			}
		}
	}

	private void StyleElement(Element element)
	{
		Transform transform = element.transform.Find("SupComStyleUI.Skin");
		Color32 color = new Color32(81, 165, 177, 230);
		Graphic graphic = null;
		bool flag = false;
		bool flag2 = false;
		Selectable component = element.GetComponent<Selectable>();
		RefreshNativeElementState(element, component);
		if (element is OrderButtonElement orderButtonElement)
		{
			graphic = orderButtonElement.frame;
			if (orderButtonElement.background != null)
			{
				color = orderButtonElement.background.color;
				DisableGraphic(orderButtonElement.background, keepRaycast: true);
			}
			if (orderButtonElement.frame != null)
			{
				DisableGraphic(orderButtonElement.frame, keepRaycast: true);
			}
		}
		else if (element is UnitButtonElement unitButtonElement)
		{
			StyleCommanderUpgradeProgressLabel(unitButtonElement, unitButtonElement.transform.parent == constructionButtonsRoot && GetCommanderUpgradeSlotIndex(unitButtonElement) >= 0);
			string description = unitButtonElement.GetComponent<TooltipTrigger>()?.description;
			CommanderUpgradeAppearance.Apply(unitButtonElement, description);
			if (CommanderUpgradeAppearance.IsInstalled(description))
			{
				color = new Color32(95, 101, 105, 170);
			}
			graphic = unitButtonElement.background;
			if (unitButtonElement.background != null)
			{
				DisableGraphic(unitButtonElement.background, keepRaycast: true);
			}
			DisableGraphicsUnder(unitButtonElement.hoverOverlay?.transform);
			DisableGraphicsUnder(unitButtonElement.transform.Find("Unit Icon Border"));
			DisableGraphicsUnder(unitButtonElement.transform.Find("Dash Top Accent"));
			DisableGraphicsUnder(unitButtonElement.transform.Find("Dash Bottom Accent"));
		}
		else
		{
			if (!(element is ConstructionFilterToggleElement constructionFilterToggleElement))
			{
				return;
			}
			flag = IsCommanderUpgradeFilter(constructionFilterToggleElement);
			flag2 = IsCommanderUpgradeSectionHeading(constructionFilterToggleElement);
			if (flag)
			{
				color = CommanderUpgradeBorderColor;
			}
			graphic = constructionFilterToggleElement.toggle?.targetGraphic;
			DisableGraphicsUnder(constructionFilterToggleElement.transform.Find("icon/glow"));
			bool flag3 = flag || flag2;
			float num = (flag ? 112f : (flag2 ? GetCommanderUpgradeSectionHeadingWidth(constructionFilterToggleElement) : 56f));
			RectTransform rectTransform = constructionFilterToggleElement.transform as RectTransform;
			if (rectTransform != null)
			{
				CapturePooled(rectTransform);
				rectTransform.sizeDelta = new Vector2(num, 36f);
			}
			RectTransform rectTransform2 = constructionFilterToggleElement.transform.Find("icon") as RectTransform;
			if (rectTransform2 != null)
			{
				Capture(rectTransform2);
				SetActiveCaptured(rectTransform2.gameObject, !flag3);
				rectTransform2.anchorMin = new Vector2(0.5f, 0.5f);
				rectTransform2.anchorMax = new Vector2(0.5f, 0.5f);
				rectTransform2.pivot = new Vector2(0.5f, 0.5f);
				rectTransform2.anchoredPosition = Vector2.zero;
				rectTransform2.localScale = new Vector3(1.25f, 1.25f, 1f);
			}
			if (constructionFilterToggleElement.displayText != null)
			{
				Capture((Behaviour)constructionFilterToggleElement.displayText);
				Capture((Graphic)constructionFilterToggleElement.displayText);
				Capture(constructionFilterToggleElement.displayText);
				RestoreNativeTextState(constructionFilterToggleElement.displayText);
				constructionFilterToggleElement.displayText.enabled = flag3;
				constructionFilterToggleElement.displayText.raycastTarget = !flag2;
				if (flag3)
				{
					RectTransform rectTransform3 = constructionFilterToggleElement.displayText.rectTransform;
					rectTransform3.anchorMin = new Vector2(0.5f, 0.5f);
					rectTransform3.anchorMax = new Vector2(0.5f, 0.5f);
					rectTransform3.pivot = new Vector2(0.5f, 0.5f);
					rectTransform3.anchoredPosition = Vector2.zero;
					rectTransform3.sizeDelta = new Vector2(num - 8f, 28f);
					constructionFilterToggleElement.displayText.color = (flag ? CommanderUpgradeTextColor : CommanderUpgradeSectionHeadingTextColor);
					constructionFilterToggleElement.displayText.fontStyle = FontStyles.Bold;
					constructionFilterToggleElement.displayText.alignment = TextAlignmentOptions.Center;
					constructionFilterToggleElement.displayText.fontSize = (flag ? 16f : 14f);
					constructionFilterToggleElement.displayText.enableAutoSizing = false;
					constructionFilterToggleElement.displayText.enableWordWrapping = false;
					constructionFilterToggleElement.displayText.overflowMode = TextOverflowModes.Ellipsis;
				}
			}
			if (flag2)
			{
				Graphic graphic2 = graphic;
				if (component != null && selectableStateById.TryGetValue(component.GetInstanceID(), out var value))
				{
					graphic2 = value.NativeTargetGraphic;
				}
				if (graphic2 != constructionFilterToggleElement.displayText)
				{
					DisableGraphic(graphic2);
				}
				if (transform != null)
				{
					SetActiveCaptured(transform.gameObject, active: false);
				}
				return;
			}
		}
		ChamferPanelGraphic component2;
		if (transform != null)
		{
			SetActiveCaptured(transform.gameObject, active: true);
			component2 = transform.GetComponent<ChamferPanelGraphic>();
			if (component2 == null)
			{
				throw new InvalidOperationException("Owned button skin marker has an invalid component.");
			}
		}
		else
		{
			GameObject obj = new GameObject("SupComStyleUI.Skin", typeof(RectTransform), typeof(ChamferPanelGraphic))
			{
				layer = element.gameObject.layer
			};
			RectTransform component3 = obj.GetComponent<RectTransform>();
			component3.SetParent(element.transform, worldPositionStays: false);
			component3.anchorMin = Vector2.zero;
			component3.anchorMax = Vector2.one;
			component3.offsetMin = new Vector2(2f, 2f);
			component3.offsetMax = new Vector2(-2f, -2f);
			component3.SetAsFirstSibling();
			component2 = obj.GetComponent<ChamferPanelGraphic>();
		}
		component2.Chamfer = ((!(element is ConstructionFilterToggleElement)) ? 9f : (flag ? 8f : 5f));
		component2.BorderWidth = 2f;
		component2.FillColor = (flag ? CommanderUpgradeIdleColor : new Color32(5, 14, 21, 238));
		color.a = 230;
		component2.BorderColor = color;
		component2.ChamferAllCorners = true;
		component2.AcceptRaycasts = true;
		if (graphic != null)
		{
			component2.material = graphic.material;
		}
		if (component != null)
		{
			UseProceduralColorTint(component, component2, selected: false);
		}
	}

	private void RefreshOrderButtonSkin(OrderButtonElement order, Color color)
	{
		Transform transform = order.transform.Find("SupComStyleUI.Skin");
		if (!(transform == null))
		{
			if (order.background != null)
			{
				Color color2 = order.background.color;
				Color color3 = order.background.color;
				color3.a = 0f;
				order.background.color = color3;
				color.r = color2.r;
				color.g = color2.g;
				color.b = color2.b;
			}
			if (order.frame != null)
			{
				Color color4 = order.frame.color;
				color4.a = 0f;
				order.frame.color = color4;
			}
			ChamferPanelGraphic component = transform.GetComponent<ChamferPanelGraphic>();
			if (component != null)
			{
				color.a = 0.9f;
				component.BorderColor = color;
			}
			Button component2 = order.GetComponent<Button>();
			if (component2 != null)
			{
				UseProceduralColorTint(component2, component, component.BorderWidth > 3f);
			}
		}
	}

	private ChamferPanelGraphic AddControlSkin(Transform parent, float chamfer, Material material)
	{
		Transform transform = parent.Find("SupComStyleUI.Skin");
		if (transform != null)
		{
			ChamferPanelGraphic component = transform.GetComponent<ChamferPanelGraphic>();
			if (component == null)
			{
				throw new InvalidOperationException("Owned control skin marker has an invalid component.");
			}
			return component;
		}
		GameObject obj = new GameObject("SupComStyleUI.Skin", typeof(RectTransform), typeof(ChamferPanelGraphic))
		{
			layer = parent.gameObject.layer
		};
		RectTransform component2 = obj.GetComponent<RectTransform>();
		component2.SetParent(parent, worldPositionStays: false);
		component2.anchorMin = Vector2.zero;
		component2.anchorMax = Vector2.one;
		component2.offsetMin = new Vector2(2f, 2f);
		component2.offsetMax = new Vector2(-2f, -2f);
		component2.SetAsFirstSibling();
		ChamferPanelGraphic component3 = obj.GetComponent<ChamferPanelGraphic>();
		component3.Chamfer = chamfer;
		component3.BorderWidth = 2f;
		component3.FillColor = new Color32(5, 14, 21, 238);
		component3.BorderColor = new Color32(81, 165, 177, 230);
		component3.ChamferAllCorners = true;
		component3.AcceptRaycasts = true;
		component3.material = material;
		return component3;
	}

	private void UseProceduralColorTint(Selectable selectable, Graphic skin, bool selected)
	{
		if (!(selectable == null) && !(skin == null))
		{
			Capture(selectable);
			ColorBlock colors = selectable.colors;
			colors.normalColor = Color.white;
			colors.highlightedColor = new Color(1.08f, 1.08f, 1.08f, 1f);
			colors.pressedColor = new Color(0.78f, 0.86f, 0.88f, 1f);
			colors.selectedColor = (selected ? new Color(1.08f, 1.08f, 1.08f, 1f) : Color.white);
			colors.disabledColor = new Color(0.55f, 0.6f, 0.62f, 0.35f);
			colors.colorMultiplier = 1f;
			colors.fadeDuration = 0.08f;
			selectable.targetGraphic = skin;
			selectable.colors = colors;
			selectable.transition = Selectable.Transition.ColorTint;
		}
	}

	private void HandleGeometryChanged()
	{
		if (!layoutApplied)
		{
			return;
		}
		try
		{
			if (!ReflowBottomDeck())
			{
				throw new InvalidOperationException("The current HUD geometry is outside the safe replacement bounds.");
			}
			SyncEconomyRails();
		}
		catch (Exception exception)
		{
			LogRuntimeFailure(exception);
		}
	}

	private void QueuePanelRefresh(UIPanelType panelType, bool restylePanel, bool updateChrome)
	{
		if (layoutApplied)
		{
			if (restylePanel)
			{
				deferredPanelStyles.Add(panelType);
			}
			deferredChromeRefresh |= updateChrome;
			QueueBottomDeckReflow(Time.frameCount, syncEconomy: false);
		}
	}

	private void QueueBottomDeckReflow(int notBeforeFrame, bool syncEconomy)
	{
		if (layoutApplied)
		{
			deferredEconomySync |= syncEconomy;
			deferredReflowNotBeforeFrame = Mathf.Max(deferredReflowNotBeforeFrame, notBeforeFrame);
		}
	}

	private void FlushDeferredPanelRefresh()
	{
		deferredReflowNotBeforeFrame = -1;
		bool flag = deferredChromeRefresh;
		bool flag2 = deferredEconomySync;
		deferredChromeRefresh = false;
		deferredEconomySync = false;
		if (!layoutApplied)
		{
			deferredPanelStyles.Clear();
			return;
		}
		try
		{
			foreach (UIPanelType deferredPanelStyle in deferredPanelStyles)
			{
				StylePanelElements(deferredPanelStyle);
			}
			deferredPanelStyles.Clear();
			if (!ReflowBottomDeck())
			{
				throw new InvalidOperationException("The current HUD geometry is outside the safe replacement bounds.");
			}
			if (layoutApplied && flag2)
			{
				SyncEconomyRails();
			}
			if (layoutApplied && flag)
			{
				UpdateChromeVisibility();
			}
		}
		catch (Exception exception)
		{
			deferredPanelStyles.Clear();
			LogRuntimeFailure(exception);
		}
	}

	private static void QueueOwnedObjectForDestroy(GameObject gameObject)
	{
		if (!(gameObject == null))
		{
			gameObject.name = "SupComStyleUI.PendingDestroy";
			gameObject.SetActive(value: false);
			UnityEngine.Object.Destroy(gameObject);
		}
	}

	private void StyleSeparator(Transform separator)
	{
		if (separator == null || separator.GetComponent<LayoutElement>() == null)
		{
			return;
		}
		RectTransform rectTransform = separator as RectTransform;
		if (rectTransform != null && separator.name.Contains("Horizontal"))
		{
			CapturePooled(rectTransform);
			rectTransform.sizeDelta = new Vector2(24f, 72f);
		}
		Graphic[] componentsInChildren = separator.GetComponentsInChildren<Graphic>(includeInactive: true);
		foreach (Graphic graphic in componentsInChildren)
		{
			if (graphic.transform.gameObject.name != "SupComStyleUI.Skin")
			{
				DisableGraphic(graphic);
			}
		}
		if (!(separator.Find("SupComStyleUI.Skin") != null))
		{
			GameObject obj = new GameObject("SupComStyleUI.Skin", typeof(RectTransform), typeof(Image))
			{
				layer = separator.gameObject.layer
			};
			RectTransform component = obj.GetComponent<RectTransform>();
			component.SetParent(separator, worldPositionStays: false);
			component.anchorMin = new Vector2(0.5f, 0.5f);
			component.anchorMax = new Vector2(0.5f, 0.5f);
			component.pivot = new Vector2(0.5f, 0.5f);
			component.sizeDelta = new Vector2(2f, 56f);
			Image component2 = obj.GetComponent<Image>();
			component2.color = new Color32(91, 159, 171, 210);
			component2.raycastTarget = false;
		}
	}

	private void SyncEconomyRails()
	{
		if (!(appliedEconomy == null) && !(energyRail == null) && !(alloyRail == null))
		{
			energyRail.Fill = appliedEconomy.energyBar.percent;
			alloyRail.Fill = appliedEconomy.alloyBar.percent;
			energyReadout?.Sync(appliedEconomy.energyStorageValue, appliedEconomy.energyStorageMax, appliedEconomy.energyGeneneratedIncome, appliedEconomy.energyExpense, appliedEconomy.energyNet);
			alloyReadout?.Sync(appliedEconomy.alloyStorageValue, appliedEconomy.alloyStorageMax, appliedEconomy.alloyGeneratedIncome, appliedEconomy.alloyExpense, appliedEconomy.alloyNet);
			energyLowResource = ResolveLowResourceState(energyLowResource, energyRail.Fill);
			alloyLowResource = ResolveLowResourceState(alloyLowResource, alloyRail.Fill);
			energyRailAccent?.Sync(energyLowResource);
			alloyRailAccent?.Sync(alloyLowResource);
			SyncEconomyProjection();
		}
	}

	private void UpdateTeamStats()
	{
		if (teamStatsFaulted || !layoutApplied || hudCallbacksSuspended || !ClientEngine.Data.isInitialized)
		{
			return;
		}
		int num = Math.Max(0, ClientEngine.GetSimulationTick());
		if (lastTeamStatsAttemptTick >= 0 && num < lastTeamStatsAttemptTick)
		{
			teamHistorySession.Reset();
			lastTeamStatsAttemptTick = -1;
			if (teamTelemetryBridge != null && !teamTelemetryBridge.Reset(out var error))
			{
				RegisterTeamStatsFailure(error);
				return;
			}
		}
		if (lastTeamStatsAttemptTick >= 0 && num - lastTeamStatsAttemptTick < 20)
		{
			return;
		}
		lastTeamStatsAttemptTick = num;
		if (teamTelemetryBridge == null)
		{
			teamTelemetryBridge = new TeamTelemetryBridge();
		}
		if (!teamTelemetryBridge.Sample(out var teams, out var error2))
		{
			RegisterTeamStatsFailure(error2);
			return;
		}
		consecutiveTeamStatsFailures = 0;
		if (teamHistorySession.TryAddSample(num, teams) && teamStatsExpanded && teamStatsFitsSafeArea && !hudCollapsed)
		{
			RefreshTeamStatsView();
		}
	}

	private void RegisterTeamStatsFailure(string error)
	{
		consecutiveTeamStatsFailures++;
		if (consecutiveTeamStatsFailures >= 3)
		{
			LogTeamStatsFailure(error);
		}
	}

	private void LogTeamStatsFailure(string error)
	{
		teamHistoryHoverGraphic?.ClearHover();
		teamStatsFaulted = true;
		teamStatsExpanded = false;
		if (teamStatsPanel != null)
		{
			teamStatsPanel.gameObject.SetActive(value: false);
		}
		UpdateTeamStatsButtonVisuals();
		if (!teamStatsWarningLogged)
		{
			base.Logger.LogWarning("Team history was disabled for this match; the rest of the HUD remains active. " + (string.IsNullOrWhiteSpace(error) ? "Unknown telemetry error." : error));
			teamStatsWarningLogged = true;
		}
	}

	private void RefreshTeamStatsView()
	{
		if (teamStatsPanel == null)
		{
			return;
		}
		bool flag = teamStatsExpanded && teamStatsFitsSafeArea && !teamStatsFaulted && !hudCollapsed;
		teamStatsPanel.gameObject.SetActive(flag);
		if (!flag)
		{
			teamHistoryHoverGraphic?.ClearHover();
			return;
		}
		TeamHistorySnapshot snapshot = teamHistorySession.CreateSnapshot();
		teamHistoryGraphic?.SetSnapshot(snapshot);
		RefreshTeamStatsAxes();
		if (!(teamHistoryHoverGraphic != null) || !teamHistoryHoverGraphic.RefreshSnapshot())
		{
			RefreshLiveTeamStatsLegend();
		}
	}

	private void RefreshTeamStatsAxes()
	{
		if (!(teamHistoryGraphic == null))
		{
			SetTextIfChanged(teamStatsStrengthScaleText, (teamHistoryGraphic.StrengthScale > 0f) ? ("MAX " + FormatCompactStat(teamHistoryGraphic.StrengthScale)) : "NO ACTIVITY");
			SetTextIfChanged(teamStatsAttacksScaleText, (teamHistoryGraphic.AttacksPerMinuteScale > 0f) ? ("MAX " + FormatCompactStat(teamHistoryGraphic.AttacksPerMinuteScale)) : "NO ACTIVITY");
			TeamHistoryTickRange visibleTickRange = teamHistoryGraphic.VisibleTickRange;
			SetTextIfChanged(teamStatsHistoryStartText, (visibleTickRange.StartTick == 0) ? "START" : "-5:00");
			if (visibleTickRange.SpanTicks <= 0)
			{
				SetTextIfChanged(teamStatsHistoryMiddleText, string.Empty);
			}
			else
			{
				SetTextIfChanged(teamStatsHistoryMiddleText, (visibleTickRange.StartTick == 0) ? FormatSimulationTick(visibleTickRange.EndTick / 2) : "-2:30");
			}
		}
	}

	private void RefreshLiveTeamStatsLegend()
	{
		SetTextIfChanged(teamStatsWindowText, "5 MIN WINDOW | 2 SEC SAMPLES");
		IReadOnlyList<TeamHistoryLegendEntry> readOnlyList = teamHistorySession.CreateLegend();
		for (int i = 0; i < readOnlyList.Count && i < teamStatsLegendRows.Count; i++)
		{
			TeamHistoryLegendEntry teamHistoryLegendEntry = readOnlyList[i];
			SetTeamStatsLegendRow(i, teamHistoryLegendEntry.Name, teamHistoryLegendEntry.Color, FormatCompactStat(teamHistoryLegendEntry.Strength), FormatCompactStat(teamHistoryLegendEntry.AttacksPerMinute));
		}
		HideTeamStatsLegendRows(readOnlyList.Count);
		if (teamStatsStatusText != null)
		{
			teamStatsStatusText.gameObject.SetActive(readOnlyList.Count == 0);
		}
	}

	private void ShowTeamStatsInspection(TeamHistoryInspection inspection)
	{
		if (inspection != null && !(teamStatsPanel == null) && teamStatsPanel.gameObject.activeInHierarchy)
		{
			int simulationTick = Math.Max(0, inspection.CurrentSimulationTick - inspection.SimulationTick);
			SetTextIfChanged(teamStatsWindowText, FormatSimulationTick(inspection.SimulationTick) + " MATCH | " + FormatSimulationTick(simulationTick) + " AGO");
			for (int i = 0; i < inspection.EntryCount && i < teamStatsLegendRows.Count; i++)
			{
				TeamHistoryInspectionEntry entry = inspection.GetEntry(i);
				string strength = (entry.HasStrength ? FormatCompactStat(entry.Strength) : "--");
				string attacksPerMinute = (entry.HasAttacksPerMinute ? FormatCompactStat(entry.AttacksPerMinute) : "--");
				SetTeamStatsLegendRow(i, entry.TeamName, entry.TeamColor, strength, attacksPerMinute);
			}
			HideTeamStatsLegendRows(inspection.EntryCount);
			if (teamStatsStatusText != null)
			{
				teamStatsStatusText.gameObject.SetActive(inspection.EntryCount == 0);
			}
		}
	}

	private void ClearTeamStatsInspection()
	{
		if (teamStatsPanel != null && teamStatsPanel.gameObject.activeInHierarchy)
		{
			RefreshLiveTeamStatsLegend();
		}
	}

	private void SetTeamStatsLegendRow(int index, string name, Color color, string strength, string attacksPerMinute)
	{
		if (index >= 0 && index < teamStatsLegendRows.Count && index < teamStatsLegendSwatches.Count && index < teamStatsLegendTexts.Count && index < teamStatsLegendValueTexts.Count)
		{
			teamStatsLegendRows[index].gameObject.SetActive(value: true);
			teamStatsLegendSwatches[index].FillColor = color;
			teamStatsLegendSwatches[index].BorderColor = Color.Lerp(color, Color.white, 0.35f);
			SetTextIfChanged(teamStatsLegendTexts[index], name ?? string.Empty);
			SetTextIfChanged(teamStatsLegendValueTexts[index], strength + " STR | " + attacksPerMinute + " APM");
		}
	}

	private void HideTeamStatsLegendRows(int activeCount)
	{
		for (int i = Math.Max(0, activeCount); i < teamStatsLegendRows.Count; i++)
		{
			teamStatsLegendRows[i].gameObject.SetActive(value: false);
		}
	}

	private static string FormatSimulationTick(int simulationTick)
	{
		int num = Math.Max(0, simulationTick) / 10;
		return (num / 60).ToString(CultureInfo.InvariantCulture) + ":" + (num % 60).ToString("00", CultureInfo.InvariantCulture);
	}

	private static string FormatCompactStat(float value)
	{
		if (float.IsNaN(value) || float.IsInfinity(value) || value <= 0f)
		{
			return "0";
		}
		if (value >= 1000000f)
		{
			return (value / 1000000f).ToString("0.#", CultureInfo.InvariantCulture) + "M";
		}
		if (value >= 1000f)
		{
			return (value / 1000f).ToString("0.#", CultureInfo.InvariantCulture) + "K";
		}
		return value.ToString((value < 10f) ? "0.#" : "0", CultureInfo.InvariantCulture);
	}

	private void SyncEconomyProjection()
	{
		if (hasLatestEconomyValues)
		{
			energyReadout?.SyncProjection(EconomyProjection.ForEnergy(in latestEconomyValues));
			alloyReadout?.SyncProjection(EconomyProjection.ForAlloy(in latestEconomyValues));
		}
	}

	private static bool ResolveLowResourceState(bool active, float fill)
	{
		if (!active)
		{
			return fill <= 0.15f;
		}
		return fill < 0.17f;
	}

	private void UpdateResourceWarningPulse()
	{
		if (!layoutApplied || hudCollapsed || energyRail == null || alloyRail == null)
		{
			return;
		}
		if ((!energyLowResource && !alloyLowResource && !(energyLowResourceBlend > 0f) && !(alloyLowResourceBlend > 0f)) || !IsVisible(economyGameplayGroup))
		{
			lastLowResourcePulseUpdateTime = -1f;
			return;
		}
		float unscaledTime = Time.unscaledTime;
		if (lastLowResourcePulseUpdateTime < 0f)
		{
			lastLowResourcePulseUpdateTime = unscaledTime - 0.05f;
		}
		float num = unscaledTime - lastLowResourcePulseUpdateTime;
		if (!(num < 0.05f))
		{
			lastLowResourcePulseUpdateTime = unscaledTime;
			float maxDelta = num * 5f;
			energyLowResourceBlend = Mathf.MoveTowards(energyLowResourceBlend, energyLowResource ? 1f : 0f, maxDelta);
			alloyLowResourceBlend = Mathf.MoveTowards(alloyLowResourceBlend, alloyLowResource ? 1f : 0f, maxDelta);
			float pulse = 0.5f - 0.5f * Mathf.Cos(Time.unscaledTime * 2f * MathF.PI * 0.8f);
			Color resourceColor = ApplyResourceWarningStyle(energyRail, energyRailAccent, EnergyRailFillColor, EnergyRailGlowColor, energyLowResourceBlend, pulse);
			Color resourceColor2 = ApplyResourceWarningStyle(alloyRail, alloyRailAccent, AlloyRailFillColor, AlloyRailGlowColor, alloyLowResourceBlend, pulse);
			energyReadout?.SetResourceColor(resourceColor);
			alloyReadout?.SetResourceColor(resourceColor2);
		}
	}

	private static Color ApplyResourceWarningStyle(ResourceRailGraphic rail, ResourceRailAccent accent, Color normalFill, Color normalGlow, float warningBlend, float pulse)
	{
		Color lowResourceWarningColor = LowResourceWarningColor;
		lowResourceWarningColor.a = Mathf.Lerp(0.8f, 1f, pulse);
		Color result = (rail.FillColor = Color.Lerp(normalFill, lowResourceWarningColor, warningBlend));
		Color lowResourceWarningColor2 = LowResourceWarningColor;
		lowResourceWarningColor2.a = Mathf.Lerp(0.36078432f, 0.6784314f, pulse);
		accent?.SetGlowColor(Color.Lerp(normalGlow, lowResourceWarningColor2, warningBlend));
		return result;
	}

	private void UpdateChromeVisibility()
	{
		if (!(economyChromeGroup == null) && !(commandChromeGroup == null) && !(fabricationChromeGroup == null))
		{
			bool flag = AnyVisible(commandGroups);
			bool flag2 = AnyVisible(fabricationGroups);
			bool flag3 = IsVisible(economyGameplayGroup);
			economyChromeGroup.alpha = (flag3 ? 1f : 0f);
			economyChromeGroup.interactable = false;
			economyChromeGroup.blocksRaycasts = false;
			commandChromeGroup.alpha = (flag ? 1f : 0f);
			fabricationChromeGroup.alpha = (flag2 ? 1f : 0f);
			if (commandDivider != null)
			{
				bool flag4 = informationPanelRoot != null && IsVisible(informationPanelRoot.GetComponent<CanvasGroup>());
				bool flag5 = ordersPanelRoot != null && IsVisible(ordersPanelRoot.GetComponent<CanvasGroup>());
				commandDivider.gameObject.SetActive(flag4 && flag5);
			}
		}
	}

	private static bool AnyVisible(List<CanvasGroup> groups)
	{
		foreach (CanvasGroup group in groups)
		{
			if (IsVisible(group))
			{
				return true;
			}
		}
		return false;
	}

	private static bool IsVisible(CanvasGroup group)
	{
		if (group != null && group.enabled && group.gameObject.activeInHierarchy)
		{
			return group.alpha > 0.01f;
		}
		return false;
	}

	private void DisableGraphic(Graphic graphic, bool keepRaycast = false)
	{
		if (!(graphic == null))
		{
			Capture(graphic);
			if (keepRaycast)
			{
				Color color = graphic.color;
				color.a = 0f;
				graphic.color = color;
			}
			else
			{
				graphic.enabled = false;
			}
		}
	}

	private void SetActiveCaptured(GameObject gameObject, bool active)
	{
		if (!(gameObject == null))
		{
			Capture(gameObject);
			gameObject.SetActive(active);
		}
	}

	private void Capture(RectTransform rect)
	{
		if (rect != null && capturedRects.Add(rect.GetInstanceID()))
		{
			rectStates.Add(new RectTransformState(rect));
		}
	}

	private void CapturePooled(RectTransform rect)
	{
		if (rect != null && capturedPooledRects.Add(rect.GetInstanceID()))
		{
			pooledRectStates.Add(new PooledRectTransformState(rect));
		}
	}

	private void CaptureGridLayout(GridLayoutGroup grid)
	{
		if (grid != null && capturedGridLayouts.Add(grid.GetInstanceID()))
		{
			gridLayoutStates.Add(new GridLayoutGroupState(grid));
		}
	}

	private void Capture(Behaviour behaviour)
	{
		if (behaviour != null && capturedBehaviours.Add(behaviour.GetInstanceID()))
		{
			behaviourStates.Add(new BehaviourState(behaviour));
		}
	}

	private void Capture(TMP_Text text)
	{
		if (text != null && capturedTextMeshPro.Add(text.GetInstanceID()))
		{
			TextMeshProState textMeshProState = new TextMeshProState(text);
			textMeshProStates.Add(textMeshProState);
			textMeshProStateById.Add(text.GetInstanceID(), textMeshProState);
		}
	}

	private void RestoreNativeTextState(TMP_Text text)
	{
		if (text != null && textMeshProStateById.TryGetValue(text.GetInstanceID(), out var value))
		{
			value.Restore();
		}
	}

	private void Capture(GameObject gameObject)
	{
		if (gameObject != null && capturedGameObjects.Add(gameObject.GetInstanceID()))
		{
			gameObjectStates.Add(new GameObjectState(gameObject));
		}
	}

	private void Capture(Graphic graphic)
	{
		if (graphic != null && capturedGraphics.Add(graphic.GetInstanceID()))
		{
			GraphicState graphicState = new GraphicState(graphic);
			graphicStates.Add(graphicState);
			graphicStateById.Add(graphic.GetInstanceID(), graphicState);
		}
	}

	private void Capture(Selectable selectable)
	{
		if (selectable != null && capturedSelectables.Add(selectable.GetInstanceID()))
		{
			SelectableState selectableState = new SelectableState(selectable);
			selectableStates.Add(selectableState);
			selectableStateById.Add(selectable.GetInstanceID(), selectableState);
		}
	}

	private void RefreshNativeElementState(Element element, Selectable selectable)
	{
		if (element is OrderButtonElement orderButtonElement)
		{
			RefreshNativeStateIfVisible(orderButtonElement.background);
			RefreshNativeStateIfVisible(orderButtonElement.frame);
		}
		else if (element is UnitButtonElement unitButtonElement)
		{
			RefreshNativeStateIfVisible(unitButtonElement.background);
		}
		else if (element is ConstructionFilterToggleElement constructionFilterToggleElement)
		{
			RefreshNativeStateIfVisible(constructionFilterToggleElement.toggle?.targetGraphic);
		}
		if (selectable != null && selectable.targetGraphic != null && selectable.targetGraphic.transform.gameObject.name != "SupComStyleUI.Skin")
		{
			RefreshNativeSelectableState(selectable);
		}
	}

	private void RefreshNativeStateIfVisible(Graphic graphic)
	{
		if (graphic != null && graphic.enabled && graphic.color.a > 0.001f && graphicStateById.TryGetValue(graphic.GetInstanceID(), out var value))
		{
			value.RefreshNativeState();
		}
	}

	private void RefreshNativeGraphicState(Graphic graphic)
	{
		if (graphic != null && graphicStateById.TryGetValue(graphic.GetInstanceID(), out var value))
		{
			value.RefreshNativeState();
		}
	}

	private void RefreshNativeSelectableState(Selectable selectable)
	{
		if (selectable != null && selectableStateById.TryGetValue(selectable.GetInstanceID(), out var value))
		{
			value.RefreshNativeState();
		}
	}

	private void RefreshNativeColors(Selectable selectable)
	{
		if (selectable != null && selectableStateById.TryGetValue(selectable.GetInstanceID(), out var value))
		{
			value.RefreshNativeColors();
		}
	}

	private void RefreshNativeOrderColors(Selectable selectable)
	{
		if (selectable != null && selectableStateById.TryGetValue(selectable.GetInstanceID(), out var value))
		{
			value.RefreshNativeOrderColors();
		}
	}

	private void RestoreLayout()
	{
		if (restoreInProgress)
		{
			return;
		}
		restoreInProgress = true;
		try
		{
			RestoreLayoutCore();
		}
		finally
		{
			restoreInProgress = false;
		}
	}

	private void RestoreLayoutCore()
	{
		ResetHudCollapseForRestore();
		CommanderUpgradeAppearance.RestoreAll();
		layoutApplied = false;
		pendingTooltipTemplateId = null;
		pendingTooltipInformationPanel = null;
		unitTooltipController?.ResetForGameCleanup();
		if (layoutPresetButton != null)
		{
			layoutPresetButton.onClick.RemoveListener(ChangeLayoutPreset);
		}
		if (hudCollapseButton != null)
		{
			hudCollapseButton.onClick.RemoveListener(ToggleHudCollapsed);
		}
		if (teamStatsButton != null)
		{
			teamStatsButton.onClick.RemoveListener(ToggleTeamStatsPanel);
		}
		teamHistoryHoverGraphic?.ClearHover();
		RestoreNativeCommanderUpgradeHeadings();
		if (commanderUpgradeHeadingsRoot != null)
		{
			QueueOwnedObjectForDestroy(commanderUpgradeHeadingsRoot.gameObject);
		}
		if (ownedRoot != null)
		{
			ownedRoot.name = "SupComStyleUI.PendingDestroy";
			ownedRoot.SetActive(value: false);
			ownedRoot.transform.SetParent(null, worldPositionStays: false);
		}
		if (resourceRailHost != null)
		{
			resourceRailHost.gameObject.name = "SupComStyleUI.PendingDestroy";
			resourceRailHost.gameObject.SetActive(value: false);
		}
		Transform transform = ((ownedRoot != null) ? ownedRoot.transform : null);
		if (resourceRailHost != null && transform != null)
		{
			resourceRailHost.SetParent(transform, worldPositionStays: false);
		}
		else if (resourceRailHost != null)
		{
			resourceRailHost.SetParent(null, worldPositionStays: false);
		}
		if (appliedManager != null)
		{
			Transform[] componentsInChildren = appliedManager.GetComponentsInChildren<Transform>(includeInactive: true);
			foreach (Transform transform2 in componentsInChildren)
			{
				if (transform2 != null && transform2.gameObject.name == "SupComStyleUI.Skin")
				{
					transform2.gameObject.name = "SupComStyleUI.PendingDestroy";
					transform2.gameObject.SetActive(value: false);
					if (transform != null)
					{
						transform2.SetParent(transform, worldPositionStays: false);
						continue;
					}
					transform2.SetParent(null, worldPositionStays: false);
					UnityEngine.Object.Destroy(transform2.gameObject);
				}
			}
		}
		for (int j = 0; j < rectStates.Count; j++)
		{
			rectStates[j].RestoreGeometry();
		}
		rectStates.Sort(RectTransformState.CompareSiblingOrder);
		for (int k = 0; k < rectStates.Count; k++)
		{
			rectStates[k].RestoreSiblingIndex();
		}
		for (int num = pooledRectStates.Count - 1; num >= 0; num--)
		{
			pooledRectStates[num].Restore();
		}
		for (int num2 = gridLayoutStates.Count - 1; num2 >= 0; num2--)
		{
			gridLayoutStates[num2].Restore();
		}
		for (int num3 = selectableStates.Count - 1; num3 >= 0; num3--)
		{
			selectableStates[num3].Restore();
		}
		for (int num4 = graphicStates.Count - 1; num4 >= 0; num4--)
		{
			graphicStates[num4].Restore();
		}
		for (int num5 = textMeshProStates.Count - 1; num5 >= 0; num5--)
		{
			textMeshProStates[num5].Restore();
		}
		for (int num6 = gameObjectStates.Count - 1; num6 >= 0; num6--)
		{
			gameObjectStates[num6].Restore();
		}
		for (int num7 = behaviourStates.Count - 1; num7 >= 0; num7--)
		{
			behaviourStates[num7].Restore();
		}
		for (int num8 = ownedBehaviours.Count - 1; num8 >= 0; num8--)
		{
			if (ownedBehaviours[num8] != null)
			{
				ownedBehaviours[num8].enabled = false;
				UnityEngine.Object.Destroy(ownedBehaviours[num8]);
			}
		}
		if (ownedRoot != null)
		{
			UnityEngine.Object.Destroy(ownedRoot);
		}
		else if (resourceRailHost != null)
		{
			UnityEngine.Object.Destroy(resourceRailHost.gameObject);
		}
		if (appliedManager != null)
		{
			RectTransform parent = appliedManager.transform as RectTransform;
			RectTransform rectTransform = FindRect(parent, "Left Panels");
			RectTransform rectTransform2 = FindRect(parent, "Construction Panels");
			RectTransform rectTransform3 = FindRect(parent, "Economy Panel");
			if (rectTransform != null)
			{
				LayoutRebuilder.ForceRebuildLayoutImmediate(rectTransform);
			}
			if (rectTransform2 != null)
			{
				LayoutRebuilder.ForceRebuildLayoutImmediate(rectTransform2);
			}
			if (rectTransform3 != null)
			{
				LayoutRebuilder.ForceRebuildLayoutImmediate(rectTransform3);
			}
		}
		rectStates.Clear();
		behaviourStates.Clear();
		textMeshProStates.Clear();
		gameObjectStates.Clear();
		graphicStates.Clear();
		selectableStates.Clear();
		pooledRectStates.Clear();
		gridLayoutStates.Clear();
		commandGroups.Clear();
		fabricationGroups.Clear();
		nativeEconomyControlCollapseGates.Clear();
		commanderUpgradeMigratedHeadings.Clear();
		deferredPanelStyles.Clear();
		deferredChromeRefresh = false;
		deferredEconomySync = false;
		deferredReflowNotBeforeFrame = -1;
		lastInformationPortraitTemplateId = null;
		ownedBehaviours.Clear();
		capturedRects.Clear();
		capturedBehaviours.Clear();
		capturedTextMeshPro.Clear();
		capturedGameObjects.Clear();
		capturedGraphics.Clear();
		capturedSelectables.Clear();
		capturedGridLayouts.Clear();
		graphicStateById.Clear();
		selectableStateById.Clear();
		textMeshProStateById.Clear();
		capturedPooledRects.Clear();
		ownedRoot = null;
		appliedManager = null;
		appliedEconomy = null;
		economyGameplayGroup = null;
		economyChromeGroup = null;
		commandChromeGroup = null;
		fabricationChromeGroup = null;
		ownedHudCollapseGate = null;
		economyHudCollapseGate = null;
		leftHudCollapseGate = null;
		constructionHudCollapseGate = null;
		energyRail = null;
		alloyRail = null;
		energyRailAccent = null;
		alloyRailAccent = null;
		energyReadout = null;
		alloyReadout = null;
		economyControlDock = null;
		economyPauseControl = null;
		economyMenuControl = null;
		matchClockPanel = null;
		matchClockText = null;
		layoutPresetButton = null;
		hudCollapseButton = null;
		hudCollapseButtonRect = null;
		hudCollapseButtonSkin = null;
		hudRestoreGlyph = null;
		teamStatsButton = null;
		teamStatsButtonSkin = null;
		teamStatsPanel = null;
		teamHistoryGraphic = null;
		teamHistoryHoverGraphic = null;
		teamStatsWindowText = null;
		teamStatsStrengthScaleText = null;
		teamStatsAttacksScaleText = null;
		teamStatsHistoryStartText = null;
		teamStatsHistoryMiddleText = null;
		teamStatsStatusText = null;
		teamStatsLegendRows.Clear();
		teamStatsLegendSwatches.Clear();
		teamStatsLegendTexts.Clear();
		teamStatsLegendValueTexts.Clear();
		teamStatsFitsSafeArea = true;
		unitTooltipController = null;
		presetOneGlyph = null;
		presetTwoGlyph = null;
		appliedLayoutPreset = 0;
		uiRoot = null;
		economyRoot = null;
		resourceRailHost = null;
		economyCollapsibleRoot = null;
		leftPanelsRoot = null;
		constructionPanelsRoot = null;
		constructionPanelRoot = null;
		constructionPanelNativeHeight = 0f;
		commanderUpgradeProgressContainers.Clear();
		constructionButtonsRoot = null;
		constructionFilterButtonsRoot = null;
		commanderUpgradeHeadingsRoot = null;
		commanderUpgradeLeftArmHeading = null;
		commanderUpgradeBackHeading = null;
		commanderUpgradeRightArmHeading = null;
		selectionPanelRoot = null;
		selectionButtonsRoot = null;
		informationPanelRoot = null;
		informationPortrait = null;
		ordersPanelRoot = null;
		commandBay = null;
		commandDivider = null;
		fabricationBay = null;
		hudCollapsed = false;
		reflowInProgress = false;
		energyLowResource = false;
		alloyLowResource = false;
		energyLowResourceBlend = 0f;
		alloyLowResourceBlend = 0f;
		lastLowResourcePulseUpdateTime = -1f;
		lastMatchClockSecond = -1;
		portraitLoadWarningLogged = false;
		tooltipFailureLogged = false;
		commanderUpgradeHeadingLayoutWarningLogged = false;
		layoutApplied = false;
	}

	private static SignedTextElement[] GetEconomyValues(EconomyPanelUI panel)
	{
		return new SignedTextElement[14]
		{
			panel.energyNet, panel.energyStorageMax, panel.energyStorageValue, panel.energyGeneneratedIncome, panel.energyExpense, panel.energyHarvestIncome, panel.energyHarvestTotal, panel.alloyNet, panel.alloyStorageMax, panel.alloyStorageValue,
			panel.alloyGeneratedIncome, panel.alloyExpense, panel.alloyHarvestIncome, panel.alloyHarvestTotal
		};
	}

	private static RectTransform AddLayer(RectTransform parent, string name, out CanvasGroup canvasGroup)
	{
		GameObject gameObject = new GameObject(name, typeof(RectTransform), typeof(CanvasGroup));
		gameObject.layer = parent.gameObject.layer;
		RectTransform component = gameObject.GetComponent<RectTransform>();
		component.SetParent(parent, worldPositionStays: false);
		Stretch(component);
		canvasGroup = gameObject.GetComponent<CanvasGroup>();
		canvasGroup.alpha = 0f;
		canvasGroup.interactable = false;
		canvasGroup.blocksRaycasts = false;
		return component;
	}

	private static RectTransform AddRect(RectTransform parent, string name, Vector2 anchorMin, Vector2 anchorMax, Vector2 pivot, Vector2 anchoredPosition, Vector2 sizeDelta)
	{
		RectTransform component = new GameObject(name, typeof(RectTransform))
		{
			layer = parent.gameObject.layer
		}.GetComponent<RectTransform>();
		component.SetParent(parent, worldPositionStays: false);
		SetRect(component, anchorMin, anchorMax, pivot, anchoredPosition, sizeDelta);
		return component;
	}

	private static RectTransform AddChamferPanel(RectTransform parent, string name, Vector2 anchorMin, Vector2 anchorMax, Vector2 pivot, Vector2 anchoredPosition, Vector2 sizeDelta, Color fill, Color border, float chamfer, bool allCorners)
	{
		RectTransform rectTransform = AddRect(parent, name, anchorMin, anchorMax, pivot, anchoredPosition, sizeDelta);
		ChamferPanelGraphic chamferPanelGraphic = rectTransform.gameObject.AddComponent<ChamferPanelGraphic>();
		chamferPanelGraphic.FillColor = fill;
		chamferPanelGraphic.BorderColor = border;
		chamferPanelGraphic.BorderWidth = 2f;
		chamferPanelGraphic.Chamfer = chamfer;
		chamferPanelGraphic.ChamferAllCorners = allCorners;
		return rectTransform;
	}

	private static RectTransform AddStretchChamferPanel(RectTransform parent, string name, Vector2 anchorMin, Vector2 anchorMax, Vector2 offsetMin, Vector2 offsetMax, Color fill, Color border, float chamfer, bool mirrored)
	{
		RectTransform rectTransform = AddChamferPanel(parent, name, anchorMin, anchorMax, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero, fill, border, chamfer, allCorners: false);
		rectTransform.offsetMin = offsetMin;
		rectTransform.offsetMax = offsetMax;
		rectTransform.GetComponent<ChamferPanelGraphic>().Mirrored = mirrored;
		return rectTransform;
	}

	private static ResourceRailGraphic AddResourceRail(RectTransform parent, string name, Vector2 anchorMin, Vector2 anchorMax, Vector2 offsetMin, Vector2 offsetMax, bool mirrored, bool fillBandAtBottom, Color fillColor)
	{
		RectTransform rectTransform = AddRect(parent, name, anchorMin, anchorMax, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
		rectTransform.offsetMin = offsetMin;
		rectTransform.offsetMax = offsetMax;
		ResourceRailGraphic resourceRailGraphic = rectTransform.gameObject.AddComponent<ResourceRailGraphic>();
		resourceRailGraphic.Mirrored = mirrored;
		resourceRailGraphic.FillBandAtBottom = fillBandAtBottom;
		resourceRailGraphic.FillColor = fillColor;
		resourceRailGraphic.TrackColor = new Color32(3, 10, 15, 238);
		resourceRailGraphic.BorderColor = new Color32(83, 140, 151, 230);
		resourceRailGraphic.BorderWidth = 1.5f;
		resourceRailGraphic.Inset = 3f;
		resourceRailGraphic.FillBandHeight = 4f;
		resourceRailGraphic.Chamfer = 10f;
		return resourceRailGraphic;
	}

	private static RectTransform AddStretchImage(RectTransform parent, string name, Vector2 anchorMin, Vector2 anchorMax, Vector2 offsetMin, Vector2 offsetMax, Color color)
	{
		RectTransform rectTransform = AddRect(parent, name, anchorMin, anchorMax, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
		rectTransform.offsetMin = offsetMin;
		rectTransform.offsetMax = offsetMax;
		Image image = rectTransform.gameObject.AddComponent<Image>();
		image.color = color;
		image.raycastTarget = false;
		return rectTransform;
	}

	private static void Stretch(RectTransform rect)
	{
		rect.anchorMin = Vector2.zero;
		rect.anchorMax = Vector2.one;
		rect.pivot = new Vector2(0.5f, 0.5f);
		rect.offsetMin = Vector2.zero;
		rect.offsetMax = Vector2.zero;
	}

	private static RectTransform FindRect(Transform parent, string path)
	{
		return parent?.Find(path) as RectTransform;
	}

	private bool IsCurrentHudManager(SanctuaryUIManager manager)
	{
		SanctuaryUIManager instance = SanctuaryUIManager.Instance;
		if (instance != null)
		{
			if (manager == instance)
			{
				return IsUsableHudManagerCandidate(instance);
			}
			return false;
		}
		if (appliedManager != null && IsUsableHudManagerCandidate(appliedManager))
		{
			return manager == appliedManager;
		}
		if (manager != null)
		{
			return manager == FindHudManager();
		}
		return false;
	}

	private static SanctuaryUIManager FindHudManager()
	{
		SanctuaryUIManager instance = SanctuaryUIManager.Instance;
		if (instance != null)
		{
			if (!IsUsableHudManagerCandidate(instance))
			{
				return null;
			}
			return instance;
		}
		SanctuaryUIManager[] array = Resources.FindObjectsOfTypeAll<SanctuaryUIManager>();
		foreach (SanctuaryUIManager sanctuaryUIManager in array)
		{
			if (IsUsableHudManagerCandidate(sanctuaryUIManager))
			{
				return sanctuaryUIManager;
			}
		}
		return null;
	}

	private static bool IsUsableHudManagerCandidate(SanctuaryUIManager manager)
	{
		if (manager != null && manager.gameObject != null && manager.gameObject.activeInHierarchy && manager.gameObject.scene.IsValid() && manager.transform is RectTransform rectTransform)
		{
			return rectTransform.name == "SanctuaryUI";
		}
		return false;
	}

	private static void SetRect(RectTransform rect, Vector2 anchorMin, Vector2 anchorMax, Vector2 pivot, Vector2 anchoredPosition, Vector2 sizeDelta)
	{
		rect.anchorMin = anchorMin;
		rect.anchorMax = anchorMax;
		rect.pivot = pivot;
		rect.anchoredPosition = anchoredPosition;
		rect.sizeDelta = sizeDelta;
		rect.localRotation = Quaternion.identity;
		rect.localScale = Vector3.one;
	}
}
