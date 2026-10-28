using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Mono.Cecil;

namespace SanctuaryModLoader;

internal static class PatcherDiscovery
{
	internal static string[] FindPatcherTypes(string path)
	{
		try
		{
			using AssemblyDefinition assemblyDefinition = AssemblyDefinition.ReadAssembly(path);
			return (from type in AllTypes(assemblyDefinition.MainModule.Types).Where(IsPatcherType)
				select type.FullName.Replace('/', '+')).ToArray();
		}
		catch (BadImageFormatException)
		{
			return new string[0];
		}
		catch (IOException)
		{
			return new string[0];
		}
	}

	private static IEnumerable<TypeDefinition> AllTypes(IEnumerable<TypeDefinition> types)
	{
		foreach (TypeDefinition type in types)
		{
			yield return type;
			foreach (TypeDefinition item in AllTypes(type.NestedTypes))
			{
				yield return item;
			}
		}
	}

	private static bool IsPatcherType(TypeDefinition type)
	{
		if (!type.IsPublic && !type.IsNestedPublic)
		{
			return false;
		}
		MethodDefinition methodDefinition = (from property in type.Properties
			where property.Name == "TargetDLLs"
			select property.GetMethod).FirstOrDefault((MethodDefinition method) => method != null && method.IsPublic && method.IsStatic);
		if (methodDefinition == null || methodDefinition.ReturnType.FullName != "System.Collections.Generic.IEnumerable`1<System.String>")
		{
			return false;
		}
		return type.Methods.Any((MethodDefinition method) => method.Name == "Patch" && method.IsPublic && method.IsStatic && method.ReturnType.FullName == "System.Void" && method.Parameters.Count == 1 && (method.Parameters[0].ParameterType.FullName == typeof(AssemblyDefinition).FullName || method.Parameters[0].ParameterType.FullName == typeof(AssemblyDefinition).FullName + "&"));
	}
}
