using System;
using System.Collections.Generic;
using System.Linq;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulCachePatcher;

internal static class ElapsedAnimationSampleBridge
{
	internal static void Install(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		MethodDefinition methodDefinition = PlayAnimation(assembly);
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction instruction = instructions.SingleOrDefault(delegate(Instruction i)
		{
			if (i.OpCode == OpCodes.Stfld)
			{
				object operand = i.Operand;
				FieldReference fieldReference = (FieldReference)((operand is FieldReference) ? operand : null);
				if (fieldReference != null && fieldReference.DeclaringType.FullName == "EM.Components.SimulationAnimationComponent" && fieldReference.Name == "currentClipTime" && instructions.IndexOf(i) > 0)
				{
					return IsFloat(instructions[instructions.IndexOf(i) - 1], 0f);
				}
			}
			return false;
		});
		if (instruction == null)
		{
			throw new InvalidOperationException("Elapsed animation transport requires the native terminal currentClipTime store.");
		}
		int num = instructions.IndexOf(instruction);
		if (num < 9)
		{
			throw new InvalidOperationException("Native animation sample decoder is incomplete.");
		}
		Instruction instruction2 = instructions[num - 1];
		Instruction instruction3 = instructions[num - 2];
		Instruction instruction4 = instructions[num - 3];
		Instruction instruction5 = instructions[num - 4];
		Instruction instruction6 = instructions[num - 5];
		if (instruction3.OpCode != OpCodes.Br || instruction3.Operand != instruction || instruction4.OpCode != OpCodes.Add || !IsFloat(instruction5, 10000f) || instruction6.OpCode != OpCodes.Ldarg_2)
		{
			throw new InvalidOperationException("Elapsed animation transport requires the exact legacy sampled-time decoder.");
		}
		List<Instruction> list = Prefix(instruction6, instruction);
		bool flag = instructions.Any((Instruction i) => IsFloat(i, -20000f) || IsFloat(i, 20000f));
		int num2 = instructions.IndexOf(instruction6) - (flag ? list.Count : 0);
		if (num2 < 3 || instructions[num2 - 3].OpCode != OpCodes.Ldarg_2 || !IsFloat(instructions[num2 - 2], -9000f) || instructions[num2 - 1].OpCode != OpCodes.Bgt_Un || instructions[num2 - 1].Operand != instruction2)
		{
			throw new InvalidOperationException("Native animation sample guard changed; refusing an elapsed-clock partial patch.");
		}
		if (flag)
		{
			if (instructions.Count((Instruction i) => IsFloat(i, -20000f)) != 1 || instructions.Count((Instruction i) => IsFloat(i, 20000f)) != 1 || !instructions.Skip(num2).Take(list.Count).Zip(list, Same)
				.All((bool equal) => equal))
			{
				throw new InvalidOperationException("Installed elapsed animation decoder differs from its supported instruction sequence.");
			}
			return;
		}
		ILProcessor iLProcessor = methodDefinition.Body.GetILProcessor();
		foreach (Instruction item in list)
		{
			iLProcessor.InsertBefore(instruction6, item);
		}
		methodDefinition.Body.MaxStackSize = Math.Max(methodDefinition.Body.MaxStackSize, 4);
	}

	internal static MethodDefinition PlayAnimation(AssemblyDefinition assembly)
	{
		MethodDefinition[] array = (assembly.MainModule.Types.SingleOrDefault((TypeDefinition t) => t.FullName == "EM.Lua.Host.HostLuaInterface") ?? throw new TypeLoadException("Native HostLuaInterface missing.")).Methods.Where((MethodDefinition m) => m.Name == "PlayAnimation" && m.IsStatic && m.HasBody && m.Parameters.Select((ParameterDefinition p) => p.ParameterType.FullName).SequenceEqual(new string[3] { "EM.Core.GlobalID&", "System.Int32", "System.Single" })).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException("Native PlayAnimation signature changed.");
		}
		return array[0];
	}

	private static List<Instruction> Prefix(Instruction legacy, Instruction store)
	{
		return new List<Instruction>
		{
			Instruction.Create(OpCodes.Ldarg_2),
			Instruction.Create(OpCodes.Ldc_R4, -20000f),
			Instruction.Create(OpCodes.Bgt_Un, legacy),
			Instruction.Create(OpCodes.Ldarg_2),
			Instruction.Create(OpCodes.Neg),
			Instruction.Create(OpCodes.Ldc_R4, 20000f),
			Instruction.Create(OpCodes.Sub),
			Instruction.Create(OpCodes.Br, store)
		};
	}

	private static bool Same(Instruction actual, Instruction expected)
	{
		if (actual.OpCode == expected.OpCode)
		{
			return object.Equals(actual.Operand, expected.Operand);
		}
		return false;
	}

	private static bool IsFloat(Instruction instruction, float value)
	{
		if (instruction.OpCode == OpCodes.Ldc_R4 && instruction.Operand is float num)
		{
			return num == value;
		}
		return false;
	}
}
