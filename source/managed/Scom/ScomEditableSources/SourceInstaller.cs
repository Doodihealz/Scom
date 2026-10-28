using System;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;

namespace ScomEditableSources;

public static class SourceInstaller
{
	public static void Install(AssemblyDefinition native)
	{
		TypeDefinition type = native.MainModule.GetType("EM.Lua.FilesCache");
		MethodDefinition methodDefinition = null;
		foreach (MethodDefinition method2 in type.Methods)
		{
			if (method2.Name == "CreateFileCache")
			{
				if (methodDefinition != null)
				{
					throw new InvalidOperationException("Native CreateFileCache overload changed.");
				}
				methodDefinition = method2;
			}
		}
		if (methodDefinition == null)
		{
			throw new InvalidOperationException("Native CreateFileCache is missing.");
		}
		Instruction instruction = null;
		Instruction instruction2 = null;
		foreach (Instruction instruction3 in methodDefinition.Body.Instructions)
		{
			if (!(instruction3.Operand is MethodReference methodReference))
			{
				continue;
			}
			if (methodReference.FullName == "System.Void SupremeCommanderOverhaulFieldFixes.FollowupCacheRuntime::Apply()")
			{
				if (instruction != null)
				{
					throw new InvalidOperationException("Duplicate SCOM final cache callback.");
				}
				instruction = instruction3;
			}
			if (methodReference.FullName == "System.Void ScomEditableSources.SourceRuntime::Apply()")
			{
				if (instruction2 != null)
				{
					throw new InvalidOperationException("Duplicate SCOM editable source callback.");
				}
				instruction2 = instruction3;
			}
		}
		if (instruction == null)
		{
			throw new InvalidOperationException("SCOM final cache callback is missing.");
		}
		if (instruction2 != null)
		{
			if (instruction.Next != instruction2)
			{
				throw new InvalidOperationException("SCOM editable source callback order changed.");
			}
		}
		else
		{
			MethodInfo method = typeof(SourceRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public);
			methodDefinition.Body.GetILProcessor().InsertAfter(instruction, Instruction.Create(OpCodes.Call, native.MainModule.ImportReference(method)));
		}
	}
}
