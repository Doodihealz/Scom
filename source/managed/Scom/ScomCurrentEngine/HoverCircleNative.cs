using System;
using Mono.Cecil;
using Mono.Cecil.Cil;

namespace ScomCurrentEngine;

public static class HoverCircleNative
{
	private const string PredicateName = "ScomRunsCenterFacingCircleOrOrbit";

	public static void Install(AssemblyDefinition native)
	{
		ModuleDefinition mainModule = native.MainModule;
		if (mainModule.Mvid.ToString() != "824eddf3-58d1-4a0a-824a-0153dcd374ee")
		{
			throw new InvalidOperationException("SCOM circle-facing native identity changed.");
		}
		TypeDefinition typeDefinition = RequireType(mainModule, "EM.Components.MovementComponent");
		TypeDefinition typeDefinition2 = RequireType(mainModule, "EM.Components.MovementPattern");
		TypeDefinition typeDefinition3 = RequireType(mainModule, "EM.Engine.Simulation.TxBothSystem_Movement_Rotation/UpdateMovementRotationsJob");
		MethodDefinition methodDefinition = RequireMethod(typeDefinition3, "Execute", 3);
		MethodDefinition methodDefinition2 = RequireMethod(typeDefinition, "get_IsOrbiting", 0);
		MethodDefinition runsGoal = RequireMethod(typeDefinition, "get_RunsGoalPattern", 0);
		FieldDefinition active = RequireField(typeDefinition, "activePattern", typeDefinition2.FullName);
		FieldDefinition mode = RequireField(typeDefinition2, "mode", "EM.Components.PatternMode");
		FieldDefinition mask = RequireField(typeDefinition, "collisionMask", "System.UInt32");
		RequireField(typeDefinition2, "orbitFacing", "EM.Components.OrbitFacing");
		RequireField(typeDefinition2, "orbitMaxSpeed", "System.Single");
		MethodDefinition methodDefinition3 = BuildPredicate(mainModule, typeDefinition, methodDefinition2, runsGoal, active, mode, mask);
		MethodDefinition methodDefinition4 = null;
		foreach (MethodDefinition method in typeDefinition3.Methods)
		{
			if (method.Name == "ScomRunsCenterFacingCircleOrOrbit")
			{
				if (methodDefinition4 != null)
				{
					throw new InvalidOperationException("Duplicate SCOM circle predicate.");
				}
				methodDefinition4 = method;
			}
		}
		Instruction instruction = null;
		int num = 0;
		int num2 = 0;
		foreach (Instruction instruction2 in methodDefinition.Body.Instructions)
		{
			if (instruction2.Operand is MethodReference methodReference)
			{
				if (methodReference.FullName == methodDefinition2.FullName)
				{
					num++;
					instruction = instruction2;
				}
				if (methodReference.Name == "ScomRunsCenterFacingCircleOrOrbit" && methodReference.DeclaringType.FullName == typeDefinition3.FullName)
				{
					num2++;
				}
			}
		}
		if (methodDefinition4 != null)
		{
			if (num != 0 || num2 != 1 || !SameBody(methodDefinition4, methodDefinition3))
			{
				throw new InvalidOperationException("SCOM circle-facing replay state changed.");
			}
			return;
		}
		if (num != 1 || num2 != 0 || instruction.OpCode != OpCodes.Call || (instruction.Next.OpCode != OpCodes.Brfalse && instruction.Next.OpCode != OpCodes.Brfalse_S))
		{
			throw new InvalidOperationException("Native orbit rotation branch changed.");
		}
		typeDefinition3.Methods.Add(methodDefinition3);
		instruction.Operand = methodDefinition3;
	}

	private static MethodDefinition BuildPredicate(ModuleDefinition module, TypeDefinition movement, MethodDefinition orbit, MethodDefinition runsGoal, FieldDefinition active, FieldDefinition mode, FieldDefinition mask)
	{
		MethodDefinition methodDefinition = new MethodDefinition("ScomRunsCenterFacingCircleOrOrbit", MethodAttributes.Private | MethodAttributes.Static | MethodAttributes.HideBySig, module.TypeSystem.Boolean);
		methodDefinition.Parameters.Add(new ParameterDefinition("movement", ParameterAttributes.None, new ByReferenceType(movement)));
		ILProcessor iLProcessor = methodDefinition.Body.GetILProcessor();
		Instruction instruction = iLProcessor.Create(OpCodes.Ldc_I4_1);
		Instruction instruction2 = iLProcessor.Create(OpCodes.Ldc_I4_0);
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ldarg_0));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Call, orbit));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Brtrue, instruction));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ldarg_0));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Call, runsGoal));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Brfalse, instruction2));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ldarg_0));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ldflda, active));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ldfld, mode));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ldc_I4_2));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Bne_Un, instruction2));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ldarg_0));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ldfld, mask));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ldc_I4, 1073741824));
		iLProcessor.Append(iLProcessor.Create(OpCodes.And));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ldc_I4_0));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Cgt_Un));
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ret));
		iLProcessor.Append(instruction);
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ret));
		iLProcessor.Append(instruction2);
		iLProcessor.Append(iLProcessor.Create(OpCodes.Ret));
		methodDefinition.Body.MaxStackSize = 2;
		return methodDefinition;
	}

	private static bool SameBody(MethodDefinition left, MethodDefinition right)
	{
		if (!left.IsStatic || left.Parameters.Count != 1 || left.Parameters[0].ParameterType.FullName != right.Parameters[0].ParameterType.FullName || left.ReturnType.FullName != "System.Boolean" || !left.HasBody || left.Body.Instructions.Count != right.Body.Instructions.Count)
		{
			return false;
		}
		for (int i = 0; i < left.Body.Instructions.Count; i++)
		{
			Instruction instruction = left.Body.Instructions[i];
			Instruction instruction2 = right.Body.Instructions[i];
			if (instruction.OpCode != instruction2.OpCode)
			{
				return false;
			}
			Instruction instruction3 = instruction.Operand as Instruction;
			Instruction instruction4 = instruction2.Operand as Instruction;
			if (instruction3 != null || instruction4 != null)
			{
				if (instruction3 == null || instruction4 == null || left.Body.Instructions.IndexOf(instruction3) != right.Body.Instructions.IndexOf(instruction4))
				{
					return false;
				}
			}
			else if (Convert.ToString(instruction.Operand) != Convert.ToString(instruction2.Operand))
			{
				return false;
			}
		}
		return true;
	}

	private static TypeDefinition RequireType(ModuleDefinition module, string name)
	{
		TypeDefinition type = module.GetType(name);
		if (type == null)
		{
			throw new MissingMemberException(name);
		}
		return type;
	}

	private static MethodDefinition RequireMethod(TypeDefinition type, string name, int parameters)
	{
		MethodDefinition methodDefinition = null;
		foreach (MethodDefinition method in type.Methods)
		{
			if (method.Name == name && method.Parameters.Count == parameters)
			{
				if (methodDefinition != null)
				{
					throw new InvalidOperationException("Ambiguous " + type.FullName + "." + name);
				}
				methodDefinition = method;
			}
		}
		if (methodDefinition == null || !methodDefinition.HasBody)
		{
			throw new MissingMethodException(type.FullName, name);
		}
		return methodDefinition;
	}

	private static FieldDefinition RequireField(TypeDefinition type, string name, string fieldType)
	{
		foreach (FieldDefinition field in type.Fields)
		{
			if (field.Name == name && field.FieldType.FullName == fieldType)
			{
				return field;
			}
		}
		throw new MissingFieldException(type.FullName, name);
	}
}
