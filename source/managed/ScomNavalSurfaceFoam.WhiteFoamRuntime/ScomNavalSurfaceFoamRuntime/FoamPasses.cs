using System;
using UnityEngine;

namespace ScomNavalSurfaceFoamRuntime;

public static class FoamPasses
{
	private static FoamOwner owner;

	public static void Install(Material source)
	{
		if (source == null || source.shader == null || source.shader.name != "RTS/Particles/Unlit")
		{
			throw new ArgumentException("The native foam particle material is unavailable.");
		}
		if (source.GetTexture("_MainTex") == null)
		{
			throw new ArgumentException("The native foam coverage texture is unavailable.");
		}
		if (owner != null)
		{
			owner.UpdateMaterial(source);
			return;
		}
		GameObject gameObject = new GameObject("SCOM Naval Foam Composition");
		UnityEngine.Object.DontDestroyOnLoad(gameObject);
		try
		{
			owner = gameObject.AddComponent<FoamOwner>();
			owner.Initialize(source);
		}
		catch
		{
			owner = null;
			UnityEngine.Object.Destroy(gameObject);
			throw;
		}
	}
}
