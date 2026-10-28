using System;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;

namespace SeraphimFourthFactionCachePatcher;

public static class CachePatcher
{
	public static void Install(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		CachePatcherRuntime.SetNativeRegistrationEnabled(enabled: true);
		if (UsesDynamicNavigationLayerProfile(assembly))
		{
			Console.WriteLine("[Seraphim Fourth Faction Cache Patcher] Using Sanctuary's dynamic navigation-layer profile.");
		}
		AddSeraphimFactionEnumValue(assembly);
		InstallFactionDropdownHook(assembly);
	}

	private static bool UsesDynamicNavigationLayerProfile(AssemblyDefinition assembly)
	{
		bool num = assembly.MainModule.Types.FirstOrDefault((TypeDefinition type) => type.FullName == "EM.Pathfinding.Navmap")?.Methods.Any((MethodDefinition method) => method.Name == "Create" && method.IsStatic && method.Parameters.Count == 3 && method.ReturnType.FullName == "EM.Pathfinding.Navmap" && method.Parameters[1].ParameterType.FullName == "Unity.Collections.NativeArray`1<EM.Pathfinding.NavmapLayerConfig>") ?? false;
		bool flag = assembly.MainModule.Types.FirstOrDefault((TypeDefinition type) => type.FullName == "EM.Engine.GlobalNavmapManager")?.Methods.Any((MethodDefinition method) => method.Name == "CreateNavigationLayer" && !method.IsStatic && method.ReturnType.FullName == "System.Void" && method.Parameters.Count == 6 && method.Parameters[5].ParameterType.FullName == "System.Int32&") ?? false;
		return num && flag;
	}

	private static void AddSeraphimFactionEnumValue(AssemblyDefinition assembly)
	{
		TypeDefinition typeDefinition = assembly.MainModule.Types.FirstOrDefault((TypeDefinition type) => type.FullName == "EM.Core.Faction") ?? throw new TypeLoadException("EM.Core.Faction was not found.");
		if (!typeDefinition.IsEnum)
		{
			throw new InvalidOperationException("EM.Core.Faction is no longer a CLR enum.");
		}
		ValidateNativeFaction(typeDefinition, "EDA", 0);
		ValidateNativeFaction(typeDefinition, "Chosen", 1);
		ValidateNativeFaction(typeDefinition, "Guard", 2);
		FieldDefinition fieldDefinition = typeDefinition.Fields.FirstOrDefault((FieldDefinition field) => field.Name == "Seraphim");
		if (fieldDefinition != null)
		{
			if (!fieldDefinition.IsStatic || !fieldDefinition.IsLiteral || Convert.ToInt32(fieldDefinition.Constant) != 3)
			{
				throw new InvalidOperationException("EM.Core.Faction.Seraphim exists but is not literal enum value 3.");
			}
		}
		else
		{
			typeDefinition.Fields.Add(new FieldDefinition("Seraphim", Mono.Cecil.FieldAttributes.Public | Mono.Cecil.FieldAttributes.Static | Mono.Cecil.FieldAttributes.Literal | Mono.Cecil.FieldAttributes.HasDefault, typeDefinition)
			{
				Constant = 3
			});
		}
	}

	private static void ValidateNativeFaction(TypeDefinition factionType, string name, int expectedValue)
	{
		FieldDefinition fieldDefinition = factionType.Fields.FirstOrDefault((FieldDefinition candidate) => candidate.Name == name) ?? throw new InvalidOperationException("EM.Core.Faction." + name + " was not found.");
		if (!fieldDefinition.IsStatic || !fieldDefinition.IsLiteral || Convert.ToInt32(fieldDefinition.Constant) != expectedValue)
		{
			throw new InvalidOperationException($"EM.Core.Faction.{name} must remain literal enum value {expectedValue}.");
		}
	}

	private static void InstallCacheHook(AssemblyDefinition assembly)
	{
		TypeDefinition filesCache = assembly.MainModule.Types.FirstOrDefault((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache") ?? throw new TypeLoadException("EM.Lua.FilesCache was not found.");
		MethodDefinition methodDefinition = filesCache.Methods.FirstOrDefault((MethodDefinition methodDefinition2) => methodDefinition2.Name == "CreateFileCache" && methodDefinition2.Parameters.Count == 0) ?? throw new MissingMethodException(filesCache.FullName, "CreateFileCache");
		Instruction target = methodDefinition.Body.Instructions.FirstOrDefault(delegate(Instruction instruction)
		{
			if (instruction.OpCode == OpCodes.Call || instruction.OpCode == OpCodes.Callvirt)
			{
				object operand = instruction.Operand;
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
		if (!methodDefinition.Body.Instructions.Any(delegate(Instruction instruction)
		{
			object operand = instruction.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			return methodReference != null && methodReference.FullName == applyReference.FullName;
		}))
		{
			methodDefinition.Body.GetILProcessor().InsertAfter(target, methodDefinition.Body.GetILProcessor().Create(OpCodes.Call, applyReference));
		}
	}

	private static void InstallFactionDropdownHook(AssemblyDefinition assembly)
	{
		TypeDefinition typeDefinition = assembly.MainModule.Types.FirstOrDefault((TypeDefinition type) => type.FullName == "EM.UI.PlayerListItem") ?? throw new TypeLoadException("EM.UI.PlayerListItem was not found.");
		MethodDefinition methodDefinition = typeDefinition.Methods.FirstOrDefault((MethodDefinition methodDefinition2) => methodDefinition2.Name == "Awake" && methodDefinition2.Parameters.Count == 0 && methodDefinition2.ReturnType.FullName == "System.Void" && methodDefinition2.HasBody) ?? throw new MissingMethodException(typeDefinition.FullName, "Awake");
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod("ConfigureFactionDropdown", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, "ConfigureFactionDropdown");
		MethodReference configureReference = assembly.MainModule.ImportReference(method);
		if (!methodDefinition.Body.Instructions.Any(delegate(Instruction instruction2)
		{
			object operand = instruction2.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			return methodReference != null && methodReference.FullName == configureReference.FullName;
		}))
		{
			Instruction[] array = methodDefinition.Body.Instructions.Where((Instruction instruction2) => instruction2.OpCode == OpCodes.Ret).ToArray();
			if (array.Length == 0)
			{
				throw new InvalidOperationException("EM.UI.PlayerListItem.Awake has no return instruction.");
			}
			ILProcessor iLProcessor = methodDefinition.Body.GetILProcessor();
			Instruction[] array2 = array;
			foreach (Instruction target in array2)
			{
				Instruction instruction = iLProcessor.Create(OpCodes.Ldarg_0);
				iLProcessor.InsertBefore(target, instruction);
				iLProcessor.InsertAfter(instruction, iLProcessor.Create(OpCodes.Call, configureReference));
			}
		}
	}
}
