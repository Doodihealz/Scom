using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading;
using Mono.Cecil;
using SupremeCommanderOverhaulCachePatcher;

namespace SupremeCommanderOverhaulCanonical;

internal static class CanonicalAssemblyContract
{
	internal const string AssemblyName = "SupremeCommanderOverhaul-CachePatcher";

	private static int _publicPatcherSurfaceVerified;

	private static readonly HashSet<string> AllowedPreloaderAssemblyNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase) { "mscorlib", "Mono.Cecil", "System", "System.Core", "System.IO.Compression" };

	private static readonly HashSet<string> RetiredAssemblyNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
	{
		"ZZZZZZZ-Aeon-Resource-Marker-CachePatcher", "ZZZZZZZZ-SupremeCommanderOverhaul-MonkeylordFix-CachePatcher", "ZZZZZZZZZ-SupremeCommanderOverhaul-AudioCompat-CachePatcher", "ZZZZZZZZZZ-SupremeCommanderOverhaul-GeneratorBuildability-CachePatcher", "ZZZZZZZZZZZ-SupremeCommanderOverhaul-SeraphimEcoBuildUI-CachePatcher", "ZZZZZZZZZZZZ-SupremeCommanderOverhaul-IdleReset-CachePatcher", "ZZZZZZZZZZZZZ-SupremeCommanderOverhaul-UpgradeAnimationFix-CachePatcher", "ZZZZZZZZZZZZZZ-SupremeCommanderOverhaul-HydroDisable-CachePatcher", "ZZZZZZZZZZZ-SupremeCommanderOverhaul-SeaParity-CachePatcher", "ZZZZZZZZZZZZ-SupremeCommanderOverhaul-BuildBoxParity-CachePatcher",
		"ZZZZZZZZZZZZZZZZ-SupremeCommanderOverhaul-GameplayCorrections-CachePatcher", "ZZZZZZZZZZZZZZZZZ-SupremeCommanderOverhaul-AeonStructureMotion-CachePatcher", "ZZZZZZZZZZZZZZZZZZ-SupremeCommanderOverhaul-FieldFixes-CachePatcher", "ZZZZZZZZZZZZZZZZZZZZ-Sanctuary-HostCommandDrainTrace-Patcher", "ZZZZZZZZZZZZZZZZZZZZZ-Sanctuary-HostPrefabTempRelease-Patcher"
	};

	internal static void RequireCanonicalTypes(params string[] fullNames)
	{
		if (fullNames == null || fullNames.Length == 0)
		{
			throw new ArgumentException("At least one canonical runtime type is required.", "fullNames");
		}
		Assembly assembly = typeof(CachePatcherRuntime).Assembly;
		if (!string.Equals(assembly.GetName().Name, "SupremeCommanderOverhaul-CachePatcher", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("Canonical SCOM assembly name drifted: expected SupremeCommanderOverhaul-CachePatcher, found " + assembly.GetName().Name + ".");
		}
		foreach (string fullName in fullNames)
		{
			Type[] array = (from assembly2 in AppDomain.CurrentDomain.GetAssemblies()
				select assembly2.GetType(fullName, throwOnError: false) into type
				where type != null
				select type).Cast<Type>().ToArray();
			if (array.Length != 1)
			{
				throw new InvalidOperationException($"Expected exactly one loaded {fullName} type, found {array.Length}.");
			}
			if ((object)array[0].Assembly != assembly)
			{
				throw new InvalidOperationException(fullName + " is owned by " + array[0].Assembly.GetName().Name + ", not the canonical SCOM assembly.");
			}
		}
		string[] array2 = (from assembly2 in AppDomain.CurrentDomain.GetAssemblies()
			select assembly2.GetName().Name into name
			where name != null && RetiredAssemblyNames.Contains(name)
			select name).Cast<string>().OrderBy<string, string>((string name) => name, StringComparer.OrdinalIgnoreCase).ToArray();
		if (array2.Length != 0)
		{
			throw new InvalidOperationException("Retired SCOM repair assemblies are still loaded: " + string.Join(", ", array2));
		}
	}

	internal static void RequireSinglePublicPatcherEntryPoint()
	{
		if (Volatile.Read(ref _publicPatcherSurfaceVerified) != 0)
		{
			return;
		}
		using AssemblyDefinition assemblyDefinition = AssemblyDefinition.ReadAssembly(typeof(CachePatcher).Assembly.Location, new ReaderParameters
		{
			InMemory = false,
			ReadSymbols = false
		});
		TypeDefinition[] array = (from type in EnumerateTypes(assemblyDefinition.MainModule.Types)
			where !type.IsInterface && (!type.IsAbstract || type.IsSealed)
			where type.Methods.Any((MethodDefinition method) => string.Equals(method.Name, "get_TargetDLLs", StringComparison.InvariantCultureIgnoreCase) && method.IsPublic && method.IsStatic && method.ReturnType.FullName == "System.Collections.Generic.IEnumerable`1<System.String>")
			where type.Methods.Any((MethodDefinition method) => string.Equals(method.Name, "Patch", StringComparison.Ordinal) && method.IsPublic && method.IsStatic && method.ReturnType.FullName == "System.Void" && method.Parameters.Count == 1 && (method.Parameters[0].ParameterType.FullName == "Mono.Cecil.AssemblyDefinition" || method.Parameters[0].ParameterType.FullName == "Mono.Cecil.AssemblyDefinition&"))
			select type).ToArray();
		if (array.Length != 1 || array[0].FullName != "SupremeCommanderOverhaulCachePatcher.CachePatcher")
		{
			throw new InvalidOperationException("Canonical SCOM must expose exactly one public BepInEx patcher entry point; internal declaring types with public TargetDLLs/Patch members are discoverable too.");
		}
		string[] array2 = assemblyDefinition.MainModule.AssemblyReferences.Select((AssemblyNameReference reference) => reference.Name).ToArray();
		if (array2.Length != AllowedPreloaderAssemblyNames.Count || !AllowedPreloaderAssemblyNames.SetEquals(array2))
		{
			throw new InvalidOperationException("Canonical SCOM preloader assembly-reference allowlist changed: " + string.Join(", ", array2.OrderBy<string, string>((string name) => name, StringComparer.OrdinalIgnoreCase)));
		}
		string[] array3 = (from scope in (from reference in assemblyDefinition.MainModule.GetTypeReferences()
				select reference.Scope).OfType<AssemblyNameReference>()
			select scope.Name into name
			where !AllowedPreloaderAssemblyNames.Contains(name)
			select name).Distinct(StringComparer.OrdinalIgnoreCase).OrderBy<string, string>((string name) => name, StringComparer.OrdinalIgnoreCase).ToArray();
		if (array3.Length != 0)
		{
			throw new InvalidOperationException("Canonical SCOM preloader type-reference scope escaped the allowlist: " + string.Join(", ", array3));
		}
		Interlocked.Exchange(ref _publicPatcherSurfaceVerified, 1);
	}

	private static IEnumerable<TypeDefinition> EnumerateTypes(IEnumerable<TypeDefinition> types)
	{
		foreach (TypeDefinition type in types)
		{
			yield return type;
			foreach (TypeDefinition item in EnumerateTypes(type.NestedTypes))
			{
				yield return item;
			}
		}
	}

	internal static void RequireNoRetiredReferences(AssemblyDefinition assembly)
	{
		string[] array = assembly.MainModule.AssemblyReferences.Select((AssemblyNameReference reference) => reference.Name).Where(RetiredAssemblyNames.Contains).OrderBy<string, string>((string name) => name, StringComparer.OrdinalIgnoreCase)
			.ToArray();
		if (array.Length != 0)
		{
			throw new InvalidOperationException("Patched Trebuchet still references retired SCOM repair assemblies: " + string.Join(", ", array));
		}
	}
}
