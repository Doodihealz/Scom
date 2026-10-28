using System;
using System.Reflection;
using BepInEx;
using EM.Engine;
using HarmonyLib;

namespace ScomLandMotion;

[BepInPlugin("local.scom.land-motion", "SCOM Land Motion", "1.0.0")]
public sealed class LandMotionPlugin : BaseUnityPlugin
{
	internal static readonly Guid SupportedMvid = new Guid("824eddf3-58d1-4a0a-824a-0153dcd374ee");

	internal static LandMotionRuntime Runtime;

	private Harmony harmony;

	private void Awake()
	{
		if (typeof(ClientEngine).Module.ModuleVersionId != SupportedMvid)
		{
			base.Logger.LogWarning("Land motion disabled: unsupported Trebuchet build; native movement remains active.");
			return;
		}
		Runtime = new LandMotionRuntime(base.Logger);
		try
		{
			harmony = new Harmony("local.scom.land-motion");
			harmony.PatchAll(Assembly.GetExecutingAssembly());
			base.Logger.LogInfo("Land motion registered: render-only dry-land height/terrain-tilt filter.");
		}
		catch (Exception exception)
		{
			harmony?.UnpatchSelf();
			Runtime.Disable(exception);
		}
	}

	private void OnDestroy()
	{
		Runtime?.Clear(ref ClientEngine.Data.localEngineData, restore: true);
		harmony?.UnpatchSelf();
		Runtime = null;
	}
}
