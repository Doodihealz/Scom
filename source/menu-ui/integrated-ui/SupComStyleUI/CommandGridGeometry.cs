using System;

namespace SupComStyleUI;

internal static class CommandGridGeometry
{
	public const int Columns = 7;

	public const float CellSize = 72f;

	public const float HorizontalSpacing = 2f;

	public const float VerticalSpacing = 8f;

	public const float HorizontalPadding = 6f;

	public const float VerticalPadding = 8f;

	public static float Height(int count)
	{
		if (count < 0)
		{
			throw new ArgumentOutOfRangeException("count");
		}
		int num = (count + 7 - 1) / 7;
		return 16f + (float)num * 72f + (float)Math.Max(0, num - 1) * 8f;
	}
}
