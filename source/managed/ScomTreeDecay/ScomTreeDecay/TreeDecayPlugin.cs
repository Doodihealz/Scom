using System;
using BepInEx;
using EM.DOTS.Engine.Loader;
using EM.Engine.Rendering;
using HarmonyLib;

namespace ScomTreeDecay;

[BepInPlugin("local.scom.tree-decay", "SCOM Tree Decay", "1.0.0")]
public sealed class TreeDecayPlugin : BaseUnityPlugin
{
	private Harmony harmony;

	private void Awake()
	{
		if (typeof(TxRenderSystem_MeshRenderingSystem).Module.ModuleVersionId != new Guid("824eddf3-58d1-4a0a-824a-0153dcd374ee"))
		{
			throw new InvalidOperationException("SCOM tree decay: native renderer build changed.");
		}
		harmony = new Harmony("local.scom.tree-decay");
		try
		{
			harmony.Patch(AccessTools.Method(typeof(TxRenderSystem_MeshRenderingSystem), "ScheduleCounts"), new HarmonyMethod(typeof(TreeDecayPlugin), "BeforeCounts"));
			harmony.Patch(AccessTools.Method(typeof(TxRenderSystem_MeshRenderingSystem), "Dispose"), null, new HarmonyMethod(typeof(TreeDecayPlugin), "AfterDispose"));
			harmony.Patch(AccessTools.Method(typeof(RenderingGroupsLoader), "Clear"), null, new HarmonyMethod(typeof(TreeDecayRuntime), "Clear"));
		}
		catch
		{
			harmony.UnpatchSelf();
			harmony = null;
			throw;
		}
		base.Logger.LogInfo("Tree decay renderer registered (32 shared fade steps; marked fallen foliage only).");
	}

	private static void BeforeCounts(TxRenderSystem_MeshRenderingSystem __instance)
	{
		TreeDecayRuntime.Update(__instance);
	}

	private static void AfterDispose(TxRenderSystem_MeshRenderingSystem __instance)
	{
		TreeDecayRuntime.Destroy(__instance);
	}

	private void OnDestroy()
	{
		if (harmony == null)
		{
			return;
		}
		try
		{
			TreeDecayRuntime.Restore();
		}
		finally
		{
			harmony.Unpatch(AccessTools.Method(typeof(TxRenderSystem_MeshRenderingSystem), "ScheduleCounts"), HarmonyPatchType.Prefix, harmony.Id);
		}
	}
}
