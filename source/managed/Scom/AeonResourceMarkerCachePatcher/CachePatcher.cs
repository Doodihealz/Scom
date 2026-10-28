using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;

namespace AeonResourceMarkerCachePatcher;

internal static class CachePatcher
{
	internal static IEnumerable<string> TargetDLLs
	{
		get
		{
			yield return "Trebuchet.dll";
		}
	}

	internal static void Patch(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		TypeDefinition filesCache = assembly.MainModule.Types.FirstOrDefault((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache") ?? throw new TypeLoadException("EM.Lua.FilesCache was not found.");
		MethodDefinition methodDefinition = filesCache.Methods.FirstOrDefault((MethodDefinition methodDefinition2) => methodDefinition2.Name == "CreateFileCache" && methodDefinition2.Parameters.Count == 0) ?? throw new MissingMethodException(filesCache.FullName, "CreateFileCache");
		Instruction instruction = methodDefinition.Body.Instructions.FirstOrDefault(delegate(Instruction instruction3)
		{
			if (instruction3.OpCode == OpCodes.Call || instruction3.OpCode == OpCodes.Callvirt)
			{
				object operand = instruction3.Operand;
				MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
				if (methodReference != null && methodReference.DeclaringType.FullName == filesCache.FullName)
				{
					return methodReference.Name == "LoadFiles";
				}
			}
			return false;
		}) ?? throw new MissingMethodException(filesCache.FullName, "LoadFiles");
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, "Apply");
		MethodReference applyReference = assembly.MainModule.ImportReference(method);
		if (!methodDefinition.Body.Instructions.Any(delegate(Instruction instruction3)
		{
			object operand = instruction3.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			return methodReference != null && methodReference.FullName == applyReference.FullName;
		}))
		{
			Instruction instruction2 = instruction;
			while (IsPostLoadPatcherCall(instruction2.Next))
			{
				instruction2 = instruction2.Next;
			}
			methodDefinition.Body.GetILProcessor().InsertAfter(instruction2, methodDefinition.Body.GetILProcessor().Create(OpCodes.Call, applyReference));
		}
	}

	private static bool IsPostLoadPatcherCall(Instruction? instruction)
	{
		if (instruction != null && (!(instruction.OpCode != OpCodes.Call) || !(instruction.OpCode != OpCodes.Callvirt)))
		{
			object operand = instruction.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			if (methodReference != null)
			{
				if (methodReference.Name == "Apply" && methodReference.Parameters.Count == 0 && methodReference.ReturnType.FullName == "System.Void")
				{
					return methodReference.DeclaringType.Name == "CachePatcherRuntime";
				}
				return false;
			}
		}
		return false;
	}
}
