using EM.Engine;
using HarmonyLib;

namespace ScomLandMotion;

[HarmonyPatch(typeof(ClientEngine), "Dispose")]
internal static class ResetOnDispose
{
	private static void Prefix()
	{
		LandMotionPlugin.Runtime?.Clear(ref ClientEngine.Data.localEngineData, restore: true);
	}
}
