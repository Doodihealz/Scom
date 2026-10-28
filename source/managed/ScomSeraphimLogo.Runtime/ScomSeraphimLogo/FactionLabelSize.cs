using System;
using TMPro;
using UnityEngine;

namespace ScomSeraphimLogo;

public sealed class FactionLabelSize : MonoBehaviour
{
	private float targetSize;

	public void Apply(TextMeshProUGUI text)
	{
		if (targetSize == 0f)
		{
			targetSize = (text.enableAutoSizing ? text.fontSizeMax : text.fontSize) * 0.85f;
		}
		text.fontSizeMax = targetSize;
		text.fontSizeMin = Math.Min(text.fontSizeMin, targetSize);
		text.fontSize = targetSize;
	}
}
