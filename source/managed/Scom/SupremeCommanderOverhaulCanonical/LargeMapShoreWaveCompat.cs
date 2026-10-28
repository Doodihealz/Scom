using System;
using System.Linq;
using System.Reflection;
using System.Threading;
using Mono.Cecil;
using Mono.Cecil.Cil;

namespace SupremeCommanderOverhaulCanonical;

public static class LargeMapShoreWaveCompat
{
	public const int BypassResolution = 2049;

	private const string WaterTerrainValuesType = "EM.Map.WaterTerrainValues";

	private const string MapManagerType = "EM.Map.MapManager";

	private const string TerrainType = "UnityEngine.Terrain";

	private static int _shoreWaveBypassLogged;

	private static int _waterSdfBypassLogged;

	private static int _inspectionFailureLogged;

	internal static void Install(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		TypeDefinition type = assembly.MainModule.Types.Single((TypeDefinition val4) => val4.FullName == "EM.Map.WaterTerrainValues");
		MethodDefinition method = FindTerrainMethod(type, "GenerateShoreWaves");
		MethodDefinition method2 = FindTerrainMethod(type, "GenerateWaterSDF");
		MethodDefinition method3 = assembly.MainModule.Types.Single((TypeDefinition val4) => val4.FullName == "EM.Map.MapManager").Methods.Single((MethodDefinition val4) => val4.Name == "GenerateWaterSDF" && !val4.IsStatic && val4.ReturnType.FullName == "System.Void" && val4.Parameters.Count == 0 && val4.HasBody);
		MethodReference methodReference = ImportCallback(assembly, "ShouldBypassLargeMap", new Type[1] { typeof(object) });
		MethodReference methodReference2 = ImportCallback(assembly, "ShouldBypassLargeMapWaterSdf", new Type[1] { typeof(object) });
		MethodReference methodReference3 = ImportCallback(assembly, "ShouldBypassCurrentLargeMapWaterSdf", new Type[1] { typeof(object) });
		Instruction[] array = CallsTo(method, methodReference.FullName);
		Instruction[] array2 = CallsTo(method2, methodReference2.FullName);
		Instruction[] array3 = CallsTo(method3, methodReference3.FullName);
		if (array.Length == 1 && array2.Length == 1 && array3.Length == 1)
		{
			RequireInstalledTerrainPrefix(array[0]);
			RequireInstalledTerrainPrefix(array2[0]);
			RequireInstalledNoArgumentPrefix(array3[0]);
			return;
		}
		if (array.Length != 0 || array2.Length != 0 || array3.Length != 0)
		{
			throw new InvalidOperationException("Large-map renderer guards are partial or duplicated.");
		}
		InstallTerrainGuard(method, methodReference);
		InstallTerrainGuard(method2, methodReference2);
		InstallNoArgumentGuard(method3, methodReference3);
		RequireInstalledTerrainPrefix(CallsTo(method, methodReference.FullName).Single());
		RequireInstalledTerrainPrefix(CallsTo(method2, methodReference2.FullName).Single());
		RequireInstalledNoArgumentPrefix(CallsTo(method3, methodReference3.FullName).Single());
	}

	public static bool ShouldBypassLargeMap(object? terrain)
	{
		return ShouldBypassTerrainFeature(terrain, ref _shoreWaveBypassLogged, "shore-wave generation");
	}

	public static bool ShouldBypassLargeMapWaterSdf(object? terrain)
	{
		return ShouldBypassTerrainFeature(terrain, ref _waterSdfBypassLogged, "full-map water-distance-field generation");
	}

	public static bool ShouldBypassCurrentLargeMapWaterSdf(object? mapManager)
	{
		if (mapManager == null)
		{
			return false;
		}
		try
		{
			PropertyInfo property = mapManager.GetType().GetProperty("GetHeightmapResolution", BindingFlags.Static | BindingFlags.Public);
			if (property == null || property.PropertyType != typeof(int) || property.GetMethod == null || !property.GetMethod.IsStatic)
			{
				return false;
			}
			object value = property.GetValue(null, null);
			return value != null && ShouldBypassResolution(Convert.ToInt32(value), ref _waterSdfBypassLogged, "full-map water-distance-field generation");
		}
		catch (Exception error)
		{
			LogInspectionFailure(error);
			return false;
		}
	}

	private static bool ShouldBypassTerrainFeature(object? terrain, ref int bypassLogged, string feature)
	{
		if (terrain == null)
		{
			return false;
		}
		try
		{
			object obj = terrain.GetType().GetProperty("terrainData", BindingFlags.Instance | BindingFlags.Public)?.GetValue(terrain, null);
			object obj2 = obj?.GetType().GetProperty("heightmapResolution", BindingFlags.Instance | BindingFlags.Public)?.GetValue(obj, null);
			if (obj2 == null)
			{
				return false;
			}
			return ShouldBypassResolution(Convert.ToInt32(obj2), ref bypassLogged, feature);
		}
		catch (Exception error)
		{
			LogInspectionFailure(error);
			return false;
		}
	}

	private static bool ShouldBypassResolution(int resolution, ref int bypassLogged, string feature)
	{
		bool num = resolution >= 2049;
		if (num && Interlocked.Exchange(ref bypassLogged, 1) == 0)
		{
			Console.WriteLine("[SCOM Large Map Load Compat] Skipped renderer-only " + feature + $" at heightmap resolution {resolution}.");
		}
		return num;
	}

	private static void LogInspectionFailure(Exception error)
	{
		if (Interlocked.Exchange(ref _inspectionFailureLogged, 1) == 0)
		{
			Console.WriteLine("[SCOM Large Map Load Compat] Could not inspect terrain resolution; preserving stock renderer generation: " + error.Message);
		}
	}

	private static MethodDefinition FindTerrainMethod(TypeDefinition type, string methodName)
	{
		return type.Methods.Single((MethodDefinition method) => method.Name == methodName && !method.IsStatic && method.ReturnType.FullName == "System.Void" && method.Parameters.Count == 1 && method.Parameters[0].ParameterType.FullName == "UnityEngine.Terrain" && method.HasBody);
	}

	private static MethodReference ImportCallback(AssemblyDefinition assembly, string methodName, Type[] parameterTypes)
	{
		MethodInfo method = typeof(LargeMapShoreWaveCompat).GetMethod(methodName, BindingFlags.Static | BindingFlags.Public, null, parameterTypes, null) ?? throw new MissingMethodException(typeof(LargeMapShoreWaveCompat).FullName, methodName);
		return assembly.MainModule.ImportReference(method);
	}

	private static void InstallTerrainGuard(MethodDefinition method, MethodReference callback)
	{
		Instruction target = method.Body.Instructions.First();
		ILProcessor iLProcessor = method.Body.GetILProcessor();
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ldarg_1));
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Call, callback));
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Brfalse, target));
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ret));
	}

	private static void InstallNoArgumentGuard(MethodDefinition method, MethodReference callback)
	{
		Instruction target = method.Body.Instructions.First();
		ILProcessor iLProcessor = method.Body.GetILProcessor();
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ldarg_0));
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Call, callback));
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Brfalse, target));
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ret));
	}

	private static void RequireInstalledTerrainPrefix(Instruction call)
	{
		if (call.Previous?.OpCode != OpCodes.Ldarg_1)
		{
			throw new InvalidOperationException("A large-map terrain guard does not load its terrain argument.");
		}
		RequireInstalledPrefix(call);
	}

	private static void RequireInstalledNoArgumentPrefix(Instruction call)
	{
		if (call.Previous?.OpCode != OpCodes.Ldarg_0)
		{
			throw new InvalidOperationException("The large-map map guard does not load its MapManager instance.");
		}
		RequireInstalledPrefix(call);
	}

	private static void RequireInstalledPrefix(Instruction call)
	{
		Instruction next = call.Next;
		Instruction instruction = next?.Next;
		Instruction instruction2 = instruction?.Next;
		OpCode? opCode = next?.OpCode;
		OpCode brfalse = OpCodes.Brfalse;
		if (opCode.HasValue && !(opCode.GetValueOrDefault() != brfalse) && next.Operand == instruction2)
		{
			opCode = instruction?.OpCode;
			brfalse = OpCodes.Ret;
			if (opCode.HasValue && !(opCode.GetValueOrDefault() != brfalse) && instruction2 != null)
			{
				return;
			}
		}
		throw new InvalidOperationException("A large-map renderer guard prefix is incomplete or malformed.");
	}

	private static Instruction[] CallsTo(MethodDefinition method, string fullName)
	{
		return method.Body.Instructions.Where((Instruction instruction) => IsCallTo(instruction, fullName)).ToArray();
	}

	private static bool IsCallTo(Instruction instruction, string fullName)
	{
		if (instruction.OpCode == OpCodes.Call || instruction.OpCode == OpCodes.Callvirt)
		{
			object operand = instruction.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			if (methodReference != null)
			{
				return string.Equals(methodReference.FullName, fullName, StringComparison.Ordinal);
			}
		}
		return false;
	}
}
