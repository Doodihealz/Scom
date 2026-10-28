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
		float val = Math.Max(commandRight + 336f, canvasWidth * 0.82f);
		val = Math.Min(val, canvasWidth - 24f);
		return new ClassicStripGeometry(commandRight, val - commandRight);
	}
}
