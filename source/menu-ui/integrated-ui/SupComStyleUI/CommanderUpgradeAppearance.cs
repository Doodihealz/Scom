using System;
using System.Collections.Generic;
using SanctuaryUI;
using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

internal static class CommanderUpgradeAppearance
{
	private static readonly Dictionary<Image, Color> originalColors = new Dictionary<Image, Color>();

	internal static bool IsInstalled(string description)
	{
		if (description != null && (description.StartsWith("Slot: Left Arm.", StringComparison.Ordinal) || description.StartsWith("Slot: Back.", StringComparison.Ordinal) || description.StartsWith("Slot: Right Arm.", StringComparison.Ordinal)))
		{
			return description.IndexOf("\nInstalled.", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	internal static void Apply(Element element, string description)
	{
		Image image = (element as UnitButtonElement)?.portraitImage;
		if (image == null)
		{
			return;
		}
		if (!IsInstalled(description))
		{
			Restore(element);
			return;
		}
		if (!originalColors.TryGetValue(image, out var value))
		{
			value = image.color;
			originalColors.Add(image, value);
		}
		image.color = new Color(value.r * 0.45f, value.g * 0.45f, value.b * 0.45f, value.a * 0.75f);
	}

	internal static void Restore(Element element)
	{
		Image image = (element as UnitButtonElement)?.portraitImage;
		if (image != null && originalColors.TryGetValue(image, out var value))
		{
			image.color = value;
			originalColors.Remove(image);
		}
	}

	internal static void BeforeClear(SanctuaryPanelUI panel)
	{
		if (panel?.itemContainer == null)
		{
			return;
		}
		foreach (Transform item in panel.itemContainer)
		{
			Restore(item.GetComponent<UnitButtonElement>());
		}
	}

	internal static void RestoreAll()
	{
		foreach (KeyValuePair<Image, Color> originalColor in originalColors)
		{
			if (originalColor.Key != null)
			{
				originalColor.Key.color = originalColor.Value;
			}
		}
		originalColors.Clear();
	}
}
