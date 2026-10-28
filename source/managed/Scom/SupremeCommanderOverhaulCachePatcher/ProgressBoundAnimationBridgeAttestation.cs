using System;

namespace SupremeCommanderOverhaulCachePatcher;

internal static class ProgressBoundAnimationBridgeAttestation
{
	private const int Verifying = 1;

	private const int Verified = 2;

	private static volatile int state;

	internal static bool IsVerified => state == 2;

	internal static void BeginVerification()
	{
		state = 1;
	}

	internal static void RecordVerified()
	{
		state = 2;
	}

	internal static void RequireVerified()
	{
		if (!IsVerified)
		{
			throw new InvalidOperationException("The coordinator exact-time animation bridge is not completely attested.");
		}
	}
}
