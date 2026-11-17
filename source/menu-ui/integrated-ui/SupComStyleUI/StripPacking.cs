using System;

namespace SupComStyleUI;

internal sealed class StripPacking
{
	private readonly float width;

	private readonly float rowHeight;

	private float x = 8f;

	private int row;

	private bool hasItems;

	public float Height
	{
		get
		{
			if (!hasItems)
			{
				return 0f;
			}
			return 16f + (float)(row + 1) * rowHeight + (float)row * 8f;
		}
	}

	public StripPacking(float width, float rowHeight)
	{
		if (float.IsNaN(width) || float.IsInfinity(width) || width < 32f || rowHeight <= 0f)
		{
			throw new ArgumentOutOfRangeException("width", "Invalid build strip dimensions.");
		}
		this.width = width;
		this.rowHeight = rowHeight;
	}

	public StripCell Place(float itemWidth)
	{
		if (float.IsNaN(itemWidth) || itemWidth <= 0f || itemWidth > width - 16f)
		{
			throw new ArgumentOutOfRangeException("itemWidth", "A build button does not fit the strip.");
		}
		if (x > 8f && x + itemWidth > width - 8f)
		{
			row++;
			x = 8f;
		}
		StripCell result = new StripCell(x, 8f + (float)row * (rowHeight + 8f));
		x += itemWidth + 8f;
		hasItems = true;
		return result;
	}
}
