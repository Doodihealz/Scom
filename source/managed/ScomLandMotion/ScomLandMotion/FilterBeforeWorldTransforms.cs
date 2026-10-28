using EM.Engine;
using HarmonyLib;

namespace ScomLandMotion;

[HarmonyPatch(typeof(LocalEngineData), "ScheduleAfterRenderUpdate")]
internal static class FilterBeforeWorldTransforms
{
	private static void Prefix(ref LocalEngineData localEngineData)
	{
		LandMotionPlugin.Runtime?.AfterInterpolation(ref localEngineData);
	}
}
