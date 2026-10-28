using System.Collections.Generic;
using System.Runtime.CompilerServices;
using SanctuaryUI;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

namespace SupComStyleUI;

internal static class TooltipLifecycle
{
	private sealed class Settings
	{
		public bool Enabled;

		public bool DictionaryTitle;

		public bool DictionaryDescription;

		public string Title;

		public string Description;

		public string TitleKey;

		public string DescriptionKey;

		public Settings(TooltipTrigger trigger)
		{
			Enabled = trigger.enabled;
			DictionaryTitle = trigger.usesDictionaryTitle;
			DictionaryDescription = trigger.usesDictionaryDescription;
			Title = trigger.title;
			Description = trigger.description;
			TitleKey = trigger.dictionaryKeyTitle;
			DescriptionKey = trigger.dictionaryKeyDescription;
		}

		public void Restore(TooltipTrigger trigger)
		{
			trigger.title = Title;
			trigger.description = Description;
			trigger.usesDictionaryTitle = DictionaryTitle;
			trigger.usesDictionaryDescription = DictionaryDescription;
			trigger.dictionaryKeyTitle = TitleKey;
			trigger.dictionaryKeyDescription = DescriptionKey;
			trigger.enabled = Enabled;
		}
	}

	private sealed class ElementState
	{
		public Settings Original;

		public bool Dynamic;

		public bool Pooled;
	}

	private static readonly ConditionalWeakTable<Element, ElementState> elements = new ConditionalWeakTable<Element, ElementState>();

	private static readonly List<CanvasGroup> groups = new List<CanvasGroup>();

	private static readonly List<RaycastResult> hits = new List<RaycastResult>();

	private static EventSystem pointerSystem;

	private static PointerEventData pointer;

	private static TooltipTrigger hovering;

	private static TooltipTrigger displayed;

	public static void BeforeSetTooltip(Element element)
	{
		if (!(element == null))
		{
			elements.GetValue(element, delegate(Element owner)
			{
				TooltipTrigger component = owner.GetComponent<TooltipTrigger>();
				return new ElementState
				{
					Original = ((component == null) ? null : new Settings(component))
				};
			});
		}
	}

	public static void AfterSetTooltip(Element element, string title, string description)
	{
		if (element == null || !elements.TryGetValue(element, out var value))
		{
			return;
		}
		TooltipTrigger component = element.GetComponent<TooltipTrigger>();
		value.Dynamic = !string.IsNullOrEmpty(title);
		if (!value.Dynamic)
		{
			Cancel(component);
			return;
		}
		if (component != null && value.Pooled)
		{
			component.enabled = value.Original?.Enabled ?? true;
		}
		value.Pooled = false;
	}

	public static bool IsPooled(TooltipTrigger trigger)
	{
		Element element = ((trigger == null) ? null : trigger.GetComponent<Element>());
		if (element != null && elements.TryGetValue(element, out var value) && value.Pooled)
		{
			return value.Original == null;
		}
		return false;
	}

	public static void BeforeClear(SanctuaryPanelUI panel)
	{
		if (panel == null || panel.itemContainer == null)
		{
			return;
		}
		TooltipTrigger[] componentsInChildren = panel.itemContainer.GetComponentsInChildren<TooltipTrigger>(includeInactive: true);
		foreach (TooltipTrigger tooltipTrigger in componentsInChildren)
		{
			Cancel(tooltipTrigger);
			Element component = tooltipTrigger.GetComponent<Element>();
			if (!(component == null) && elements.TryGetValue(component, out var value) && value.Dynamic)
			{
				if (value.Original != null)
				{
					value.Original.Restore(tooltipTrigger);
				}
				else
				{
					tooltipTrigger.title = string.Empty;
					tooltipTrigger.description = string.Empty;
					tooltipTrigger.usesDictionaryTitle = false;
					tooltipTrigger.usesDictionaryDescription = false;
					tooltipTrigger.enabled = false;
				}
				value.Dynamic = false;
				value.Pooled = true;
			}
		}
	}

	public static void BeforeVisibility(SanctuaryPanelUI panel, bool visible)
	{
		if (!visible && !(panel == null) && !(panel.itemContainer == null))
		{
			TooltipTrigger[] componentsInChildren = panel.itemContainer.GetComponentsInChildren<TooltipTrigger>(includeInactive: true);
			for (int i = 0; i < componentsInChildren.Length; i++)
			{
				Cancel(componentsInChildren[i]);
			}
		}
	}

	public static void BeginHover(TooltipTrigger trigger)
	{
		if (hovering != null && hovering != trigger)
		{
			Cancel(hovering);
		}
		hovering = trigger;
	}

	public static void EndHover(TooltipTrigger trigger)
	{
		if (hovering == trigger)
		{
			hovering = null;
		}
	}

	public static bool BeforeUpdate(TooltipTrigger trigger, ref bool isHovering, ref float hoverTimer, ref Vector2 mousePreviousPosition)
	{
		if (!isHovering)
		{
			return true;
		}
		if (IsPointerOverVisibleTarget(trigger))
		{
			if (trigger.GetComponent<OrderButtonElement>() != null)
			{
				mousePreviousPosition = Mouse.current.position.ReadValue();
			}
			return true;
		}
		isHovering = false;
		hoverTimer = 0f;
		Cancel(trigger);
		return false;
	}

	public static bool BeforeShow(TooltipTrigger trigger)
	{
		if (!IsPointerOverVisibleTarget(trigger))
		{
			Cancel(trigger);
			return false;
		}
		displayed = trigger;
		return true;
	}

	public static bool BeforeHide(TooltipTrigger trigger)
	{
		if (displayed != trigger)
		{
			return false;
		}
		displayed = null;
		return true;
	}

	public static bool BeforePanelUpdate()
	{
		if (displayed != null && IsPointerOverVisibleTarget(displayed))
		{
			return true;
		}
		CancelAll();
		return false;
	}

	public static void CancelAll()
	{
		TooltipTrigger tooltipTrigger = hovering;
		TooltipTrigger tooltipTrigger2 = displayed;
		hovering = null;
		displayed = null;
		if (tooltipTrigger != null)
		{
			tooltipTrigger.OnPointerExit(null);
		}
		if (tooltipTrigger2 != null && tooltipTrigger2 != tooltipTrigger)
		{
			tooltipTrigger2.OnPointerExit(null);
		}
		TooltipPanelUI.SetTooltip(enabled: false);
	}

	private static void Cancel(TooltipTrigger trigger)
	{
		if (!(trigger == null))
		{
			trigger.OnPointerExit(null);
			if (hovering == trigger)
			{
				hovering = null;
			}
		}
	}

	public static bool IsPointerOverVisibleTarget(Component target)
	{
		Mouse current = Mouse.current;
		Keyboard current2 = Keyboard.current;
		if (target == null || !Application.isFocused || current == null || current.rightButton.wasPressedThisFrame || (current2 != null && current2.escapeKey.wasPressedThisFrame) || !target.gameObject.activeInHierarchy)
		{
			return false;
		}
		if (target is Behaviour { isActiveAndEnabled: false })
		{
			return false;
		}
		RectTransform rectTransform = target.transform as RectTransform;
		if (rectTransform == null)
		{
			return false;
		}
		Vector3 lossyScale = rectTransform.lossyScale;
		if (Mathf.Abs(lossyScale.x) <= 0.01f || Mathf.Abs(lossyScale.y) <= 0.01f)
		{
			return false;
		}
		bool flag = false;
		Transform transform = rectTransform;
		while (transform != null)
		{
			transform.GetComponents(groups);
			bool flag2 = false;
			foreach (CanvasGroup group in groups)
			{
				if (group.isActiveAndEnabled)
				{
					if (group.alpha <= 0.01f || (!flag && !group.blocksRaycasts))
					{
						return false;
					}
					flag2 |= group.ignoreParentGroups;
				}
			}
			flag = flag || flag2;
			transform = transform.parent;
		}
		Canvas componentInParent = target.GetComponentInParent<Canvas>();
		Camera cam = ((componentInParent == null || componentInParent.renderMode == RenderMode.ScreenSpaceOverlay) ? null : componentInParent.worldCamera);
		Vector2 vector = current.position.ReadValue();
		if (!RectTransformUtility.RectangleContainsScreenPoint(rectTransform, vector, cam))
		{
			return false;
		}
		EventSystem current4 = EventSystem.current;
		if (current4 == null)
		{
			return false;
		}
		if (pointer == null || pointerSystem != current4)
		{
			pointerSystem = current4;
			pointer = new PointerEventData(current4);
		}
		pointer.Reset();
		pointer.position = vector;
		pointer.pointerId = -1;
		hits.Clear();
		current4.RaycastAll(pointer, hits);
		foreach (RaycastResult hit in hits)
		{
			if (!(hit.gameObject == null))
			{
				Transform transform2 = hit.gameObject.transform;
				return transform2 == target.transform || transform2.IsChildOf(target.transform);
			}
		}
		return false;
	}
}
