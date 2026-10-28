using System;
using Mono.Cecil;
using Mono.Cecil.Cil;

namespace SupremeCommanderOverhaulFieldFixes;

public static class LobbyFactionLabels
{
	public static string DisplayName(string name)
	{
		return name switch
		{
			"EDA" => "UEF", 
			"Chosen" => "Aeon", 
			"Guard" => "Cybran", 
			_ => name, 
		};
	}

	public static void Install(AssemblyDefinition native)
	{
		if (native.MainModule.Mvid.ToString() != "824eddf3-58d1-4a0a-824a-0153dcd374ee")
		{
			throw new InvalidOperationException("Lobby faction label native identity changed.");
		}
		TypeDefinition type = native.MainModule.GetType("EM.UI.PlayerListItem");
		MethodDefinition methodDefinition = null;
		if (type != null)
		{
			foreach (MethodDefinition method in type.Methods)
			{
				if (method.Name == "UpdatePlayerFactionDropdown")
				{
					if (methodDefinition != null)
					{
						throw new InvalidOperationException("Ambiguous lobby faction update.");
					}
					methodDefinition = method;
				}
			}
		}
		if (methodDefinition == null || !methodDefinition.HasBody || methodDefinition.Parameters.Count != 1 || methodDefinition.Parameters[0].ParameterType.FullName != "System.Boolean" || methodDefinition.ReturnType.FullName != "System.Void")
		{
			throw new InvalidOperationException("Lobby faction update signature changed.");
		}
		MethodReference methodReference = native.MainModule.ImportReference(typeof(LobbyFactionLabels).GetMethod("DisplayName"));
		Instruction instruction = null;
		int num = 0;
		foreach (Instruction instruction7 in methodDefinition.Body.Instructions)
		{
			if (IsCall(instruction7, methodReference.FullName))
			{
				num++;
			}
			if (!IsCall(instruction7, "System.String System.Object::ToString()"))
			{
				continue;
			}
			Instruction previous = instruction7.Previous;
			Instruction instruction2 = previous?.Previous;
			Instruction instruction3 = instruction2?.Previous;
			Instruction instruction4 = instruction3?.Previous;
			Instruction instruction5 = instruction4?.Previous;
			Instruction instruction6 = instruction5?.Previous;
			if (previous == null || instruction4 == null || instruction5 == null || instruction6 == null || previous.OpCode != OpCodes.Constrained || ((TypeReference)previous.Operand).FullName != "EM.Core.Faction" || !IsField(instruction2, OpCodes.Ldflda, "EM.Core.Faction EM.Network.Lobby.LobbyPlayer::faction") || !IsField(instruction3, OpCodes.Ldfld, "EM.Network.Lobby.LobbyPlayer EM.UI.PlayerListItem::player") || instruction4.OpCode != OpCodes.Ldarg_0 || !IsField(instruction5, OpCodes.Ldfld, "TMPro.TextMeshProUGUI EM.UI.PlayerListItem::factionText") || instruction6.OpCode != OpCodes.Ldarg_0)
			{
				continue;
			}
			Instruction next = instruction7.Next;
			if (IsCall(next, methodReference.FullName))
			{
				next = next.Next;
			}
			if (IsCall(next, "System.Void TMPro.TMP_Text::set_text(System.String)"))
			{
				if (instruction != null)
				{
					throw new InvalidOperationException("Ambiguous lobby faction label assignment.");
				}
				instruction = instruction7;
			}
		}
		if (instruction == null || num > 1 || (num == 1 && !IsCall(instruction.Next, methodReference.FullName)))
		{
			throw new InvalidOperationException("Lobby faction label assignment changed.");
		}
		if (num == 0)
		{
			methodDefinition.Body.GetILProcessor().InsertAfter(instruction, Instruction.Create(OpCodes.Call, methodReference));
		}
	}

	private static bool IsField(Instruction instruction, OpCode code, string name)
	{
		if (instruction != null && instruction.OpCode == code && instruction.Operand is FieldReference)
		{
			return ((FieldReference)instruction.Operand).FullName == name;
		}
		return false;
	}

	private static bool IsCall(Instruction instruction, string name)
	{
		if (instruction != null && instruction.Operand is MethodReference)
		{
			return ((MethodReference)instruction.Operand).FullName == name;
		}
		return false;
	}
}
