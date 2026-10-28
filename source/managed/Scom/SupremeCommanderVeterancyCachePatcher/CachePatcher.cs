using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderVeterancyCachePatcher;

public static class CachePatcher
{
	public static void Install(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		TypeDefinition typeDefinition = EnumerateTypes(assembly.MainModule.Types).SingleOrDefault((TypeDefinition type) => type.FullName == "SanctuaryUI.InformationPanelUI") ?? throw new TypeLoadException("SanctuaryUI.InformationPanelUI was not found.");
		MethodDefinition methodDefinition = typeDefinition.Methods.SingleOrDefault((MethodDefinition methodDefinition2) => methodDefinition2.Name == "SetValues" && methodDefinition2.Parameters.Count == 1 && methodDefinition2.ReturnType.MetadataType == MetadataType.Void && methodDefinition2.HasBody) ?? throw new MissingMethodException(typeDefinition.FullName, "SetValues(in UIInformationValues)");
		MethodInfo method = typeof(VeterancyNativeUiRuntime).GetMethod("UpdateVeterancyIcons", BindingFlags.Static | BindingFlags.Public, null, new Type[2]
		{
			typeof(object),
			typeof(object)
		}, null) ?? throw new MissingMethodException(typeof(VeterancyNativeUiRuntime).FullName, "UpdateVeterancyIcons");
		MethodReference callbackReference = assembly.MainModule.ImportReference(method);
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction[] array = instructions.Where((Instruction instruction) => instruction.OpCode == OpCodes.Ret).ToArray();
		if (array.Length == 0)
		{
			throw new InvalidOperationException("InformationPanelUI.SetValues has no return instruction.");
		}
		int num = instructions.Count(delegate(Instruction instruction)
		{
			object operand = instruction.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			return methodReference != null && methodReference.FullName == callbackReference.FullName;
		});
		if (num != array.Length)
		{
			if (num != 0)
			{
				throw new InvalidOperationException("A partial Supreme Commander veterancy HUD hook was found; refusing to mix IL revisions.");
			}
			ILProcessor iLProcessor = methodDefinition.Body.GetILProcessor();
			Instruction[] array2 = array;
			foreach (Instruction target in array2)
			{
				iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ldarg_0));
				iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ldarg_1));
				iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ldobj, assembly.MainModule.TypeSystem.Object));
				iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Call, callbackReference));
			}
			methodDefinition.Body.MaxStackSize = Math.Max(methodDefinition.Body.MaxStackSize, 2);
			if (methodDefinition.Body.Instructions.Count(delegate(Instruction instruction)
			{
				object operand = instruction.Operand;
				MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
				return methodReference != null && methodReference.FullName == callbackReference.FullName;
			}) != array.Length)
			{
				throw new InvalidOperationException("The Supreme Commander veterancy HUD hook did not install completely.");
			}
		}
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
}
