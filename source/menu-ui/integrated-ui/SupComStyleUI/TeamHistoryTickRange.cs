namespace SupComStyleUI;

internal readonly struct TeamHistoryTickRange
{
	internal int StartTick { get; }

	internal int EndTick { get; }

	internal int SpanTicks => EndTick - StartTick;

	internal TeamHistoryTickRange(int startTick, int endTick)
	{
		StartTick = startTick;
		EndTick = endTick;
	}
}
