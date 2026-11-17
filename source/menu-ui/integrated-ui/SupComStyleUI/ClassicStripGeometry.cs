using System;

namespace SupComStyleUI;

internal readonly struct ClassicStripGeometry
{
	public readonly float Left;

	public readonly float Width;

	private ClassicStripGeometry(float left, float width)
	{
		Left = left;
		Width = width;
	}

	public static ClassicStripGeometry Calculate(float canvasWidth, float commandRight)
	{
		if (float.IsNaN(canvasWidth) || float.IsInfinity(canvasWidth) || canvasWidth < commandRight + 360f)
		{
			throw new ArgumentOutOfRangeException("canvasWidth", "The HUD is too narrow for the command panel and build strip.");
		}
		return new ClassicStripGeometry(commandRight, canvasWidth - commandRight - 12f);
	}
}
