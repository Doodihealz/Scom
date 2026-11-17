using System;

namespace SupComStyleUI;

internal sealed class UpgradeStripPacking
{
	private readonly StripPacking[] columns;

	public float Height => GroupHeight(0) + GroupHeight(1) + GroupHeight(2);

	private float GroupHeight(int slot)
	{
		if (!(columns[slot].Height > 0f))
		{
			return 0f;
		}
		return columns[slot].Height + 36f;
	}

	public UpgradeStripPacking(float width, float rowHeight)
	{
		columns = new StripPacking[3]
		{
			new StripPacking(width, rowHeight),
			new StripPacking(width, rowHeight),
			new StripPacking(width, rowHeight)
		};
	}

	public StripCell Place(int slot, float itemWidth)
	{
		if (slot < 0 || slot >= columns.Length)
		{
			throw new ArgumentOutOfRangeException("slot", "Unknown commander enhancement slot.");
		}
		StripCell stripCell = columns[slot].Place(itemWidth);
		float num = 0f;
		for (int i = 0; i < slot; i++)
		{
			num += GroupHeight(i);
		}
		return new StripCell(stripCell.X, num + 36f + stripCell.Y);
	}
}
