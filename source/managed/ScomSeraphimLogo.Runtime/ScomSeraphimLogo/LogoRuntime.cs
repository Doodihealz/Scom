using System;
using System.IO;
using Michsky.UI.Beam;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace ScomSeraphimLogo;

public static class LogoRuntime
{
	private const string ImageResource = "ScomSeraphimLogo.ClassicGold.png";

	private static Sprite sprite;

	public static object LoadSprite()
	{
		if (sprite != null)
		{
			return sprite;
		}
		Texture2D texture2D = null;
		try
		{
			using (Stream stream = typeof(LogoRuntime).Assembly.GetManifestResourceStream("ScomSeraphimLogo.ClassicGold.png"))
			{
				if (stream == null)
				{
					throw new FileNotFoundException("The embedded Seraphim emblem is missing.", "ScomSeraphimLogo.ClassicGold.png");
				}
				byte[] array = new byte[checked((int)stream.Length)];
				int num;
				for (int i = 0; i < array.Length; i += num)
				{
					num = stream.Read(array, i, array.Length - i);
					if (num == 0)
					{
						throw new EndOfStreamException("The embedded Seraphim emblem was truncated.");
					}
				}
				texture2D = new Texture2D(2, 2, TextureFormat.RGBA32, mipChain: true);
				if (!texture2D.LoadImage(array, markNonReadable: true))
				{
					throw new InvalidDataException("The embedded Seraphim emblem is not a supported PNG.");
				}
			}
			if (texture2D.width != 256 || texture2D.height != 256)
			{
				throw new InvalidDataException("The Seraphim emblem must use its reviewed 256 x 256 canvas.");
			}
			texture2D.name = "SCOM Seraphim classic gold";
			texture2D.wrapMode = TextureWrapMode.Clamp;
			texture2D.filterMode = FilterMode.Trilinear;
			texture2D.hideFlags = HideFlags.HideAndDontSave;
			sprite = Sprite.Create(texture2D, new Rect(0f, 0f, 256f, 256f), new Vector2(0.5f, 0.5f), 100f, 0u, SpriteMeshType.FullRect);
			if (sprite == null)
			{
				throw new InvalidDataException("The Seraphim emblem sprite could not be created.");
			}
			sprite.name = texture2D.name;
			sprite.hideFlags = HideFlags.HideAndDontSave;
			return sprite;
		}
		catch
		{
			if (texture2D != null)
			{
				UnityEngine.Object.Destroy(texture2D);
			}
			throw;
		}
	}

	public static void Configure(object dropdownObject)
	{
		Michsky.UI.Beam.Dropdown dropdown = dropdownObject as Michsky.UI.Beam.Dropdown;
		if (dropdown == null || dropdown.items.Count < 4 || dropdown.items[3].itemName != "Seraphim")
		{
			throw new InvalidOperationException("The Seraphim logo received an unsupported faction dropdown.");
		}
		Sprite sprite = (Sprite)LoadSprite();
		if (dropdown.items[3].itemIcon != sprite)
		{
			throw new InvalidOperationException("The Seraphim option does not own the reviewed emblem.");
		}
		if (dropdown.headerImage == null || dropdown.headerText == null)
		{
			throw new InvalidOperationException("The faction caption has not been initialized.");
		}
		foreach (Michsky.UI.Beam.Dropdown.Item item in dropdown.items)
		{
			ButtonManager itemButton = item.itemButton;
			if (itemButton == null || itemButton.normalImageObj == null || itemButton.highlightImageObj == null || itemButton.normalTextObj == null)
			{
				throw new InvalidOperationException("A faction option has not been initialized.");
			}
		}
		Attach(dropdown.headerImage, sprite);
		ResizeLabel(dropdown.headerText);
		foreach (Michsky.UI.Beam.Dropdown.Item item2 in dropdown.items)
		{
			ButtonManager itemButton2 = item2.itemButton;
			Attach(itemButton2.normalImageObj, sprite);
			Attach(itemButton2.highlightImageObj, sprite);
			Attach(itemButton2.disabledImageObj, sprite);
			ResizeLabel(itemButton2.normalTextObj);
			ResizeLabel(itemButton2.highlightTextObj);
			ResizeLabel(itemButton2.disabledTextObj);
			itemButton2.textSize = itemButton2.normalTextObj.fontSizeMax;
		}
	}

	private static void ResizeLabel(TextMeshProUGUI text)
	{
		if (!(text == null))
		{
			FactionLabelSize factionLabelSize = text.GetComponent<FactionLabelSize>();
			if (factionLabelSize == null)
			{
				factionLabelSize = text.gameObject.AddComponent<FactionLabelSize>();
			}
			factionLabelSize.Apply(text);
		}
	}

	private static void Attach(Image image, Sprite expected)
	{
		if (!(image == null))
		{
			image.preserveAspect = true;
			GoldLogoMeshEffect goldLogoMeshEffect = image.GetComponent<GoldLogoMeshEffect>();
			if (goldLogoMeshEffect == null)
			{
				goldLogoMeshEffect = image.gameObject.AddComponent<GoldLogoMeshEffect>();
			}
			goldLogoMeshEffect.Bind(expected);
		}
	}
}
