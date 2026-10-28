using EM.Engine;
using HarmonyLib;

namespace ScomLandMotion;

[HarmonyPatch(typeof(ClientEngine), "Initialize")]
internal static class ResetOnInitialize
{
	private static void Postfix()
	{
		LandMotionPlugin.Runtime?.Clear(ref ClientEngine.Data.localEngineData, restore: false);
	}
}
