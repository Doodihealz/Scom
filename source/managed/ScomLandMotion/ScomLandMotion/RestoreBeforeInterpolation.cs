using EM.Engine;
using HarmonyLib;

namespace ScomLandMotion;

[HarmonyPatch(typeof(LocalEngineData), "ScheduleBeforeRenderUpdate")]
internal static class RestoreBeforeInterpolation
{
	private static void Prefix(ref LocalEngineData localEngineData)
	{
		LandMotionPlugin.Runtime?.BeforeInterpolation(ref localEngineData);
	}
}
