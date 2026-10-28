using System;

namespace SupremeCommanderOverhaulIdleReset;

public sealed class WalkerGait
{
	public string UnitId { get; }

	public string ClipName { get; }

	public WalkerGait(string unitId, string clipName)
	{
		UnitId = unitId ?? throw new ArgumentNullException("unitId");
		ClipName = clipName ?? throw new ArgumentNullException("clipName");
	}
}
