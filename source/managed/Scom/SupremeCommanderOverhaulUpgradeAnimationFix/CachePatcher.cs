using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulUpgradeAnimationFix;

internal static class CachePatcher
{
	private sealed class LuaShape
	{
		public MethodDefinition Method { get; }

		public Instruction[] OwnCalls { get; }

		public Instruction[] ScomCalls { get; }

		public Instruction[] RebuildCalls { get; }

		public Instruction[] WatcherCalls { get; }

		public Instruction[] Returns { get; }

		public string? Failure { get; }

		public bool IsSupported => Failure == null;

		public Instruction WatcherAnchor => WatcherCalls[0];

		public LuaShape(MethodDefinition method, Instruction[] ownCalls, Instruction[] scomCalls, Instruction[] rebuildCalls, Instruction[] watcherCalls, Instruction[] returns, string? failure)
		{
			Method = method;
			OwnCalls = ownCalls;
			ScomCalls = scomCalls;
			RebuildCalls = rebuildCalls;
			WatcherCalls = watcherCalls;
			Returns = returns;
			Failure = failure;
		}
	}

	private enum DelegateState
	{
		Unsupported,
		Stock,
		Installed
	}

	private sealed class DelegateShape
	{
		public DelegateState State { get; }

		public TypeDefinition Generated { get; }

		public TypeDefinition PlayDelegate { get; }

		public MethodDefinition PlayAnimation { get; }

		public MethodDefinition DelegateConstructor { get; }

		public FieldDefinition HostDelegate { get; }

		public FieldDefinition BurstPointer { get; }

		public MethodDefinition StaticConstructor { get; }

		public Instruction StockLoad { get; }

		public Instruction Store { get; }

		public string? Failure { get; }

		public DelegateShape(DelegateState state, TypeDefinition generated, TypeDefinition playDelegate, MethodDefinition playAnimation, MethodDefinition delegateConstructor, FieldDefinition hostDelegate, FieldDefinition burstPointer, MethodDefinition staticConstructor, Instruction stockLoad, Instruction store, string? failure)
		{
			State = state;
			Generated = generated;
			PlayDelegate = playDelegate;
			PlayAnimation = playAnimation;
			DelegateConstructor = delegateConstructor;
			HostDelegate = hostDelegate;
			BurstPointer = burstPointer;
			StaticConstructor = staticConstructor;
			StockLoad = stockLoad;
			Store = store;
			Failure = failure;
		}

		private DelegateShape(string failure)
		{
			State = DelegateState.Unsupported;
			Failure = failure;
			Generated = null;
			PlayDelegate = null;
			PlayAnimation = null;
			DelegateConstructor = null;
			HostDelegate = null;
			BurstPointer = null;
			StaticConstructor = null;
			StockLoad = null;
			Store = null;
		}

		public static DelegateShape Unsupported(string failure)
		{
			return new DelegateShape(failure);
		}
	}

	private sealed class BranchEdge
	{
		public Instruction Source { get; }

		public Instruction Target { get; }

		public BranchEdge(Instruction source, Instruction target)
		{
			Source = source;
			Target = target;
		}
	}

	public const string SupportedGameMvid = "2cc1c6fa-e909-410e-8fd9-2f307b231dfb";

	private const string ScomApplyFullName = "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()";

	private const string OwnApplyFullName = "System.Void SupremeCommanderOverhaulUpgradeAnimationFix.CachePatcherRuntime::Apply()";

	private const string RebuildDirectoryIndexFullName = "System.Void EM.Lua.FilesCache::RebuildDirectoryIndex()";

	private const string WatcherDataGetterFullName = "EM.GameUtils.DebugManager/UnmanagedDebugProperties& EM.GameUtils.DebugManager::get_data()";

	private const string GeneratedDelegatesTypeName = "EM.Lua.Host.GeneratedDelegates";

	private const string PlayDelegateTypeName = "EM.Lua.Host.GeneratedDelegates/PlayAnimation";

	private const string HostLuaInterfaceTypeName = "EM.Lua.Host.HostLuaInterface";

	internal static IEnumerable<string> TargetDLLs
	{
		get
		{
			yield return "Trebuchet.dll";
		}
	}

	public static void ValidateMvid(Guid mvid)
	{
		string text = mvid.ToString("D");
		if (!string.Equals(text, "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Unsupported Trebuchet.dll MVID " + text + "; expected 2cc1c6fa-e909-410e-8fd9-2f307b231dfb.");
		}
	}

	internal static void Patch(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		if (!IsSupportedMvid(assembly.MainModule.Mvid))
		{
			LogSkip("unsupported Trebuchet.dll MVID " + assembly.MainModule.Mvid.ToString("D"));
			return;
		}
		MethodDefinition methodDefinition = FindStaticMethod(assembly, "EM.Lua.FilesCache", "CreateFileCache");
		if (methodDefinition == null)
		{
			LogSkip("EM.Lua.FilesCache.CreateFileCache() is unavailable");
			return;
		}
		LuaShape luaShape = InspectLuaShape(methodDefinition);
		DelegateShape delegateShape = InspectDelegateShape(assembly);
		if (luaShape.OwnCalls.Length > 1)
		{
			throw new InvalidOperationException("Upgrade-animation callback installation is ambiguous.");
		}
		bool flag = luaShape.OwnCalls.Length == 1;
		bool flag2 = delegateShape.State == DelegateState.Installed;
		if (flag != flag2)
		{
			throw new InvalidOperationException("The managed PlayAnimation route and Lua callback are only partially installed.");
		}
		if (!luaShape.IsSupported || delegateShape.State == DelegateState.Unsupported)
		{
			if (flag || flag2)
			{
				throw new InvalidOperationException("Installed upgrade-animation hooks no longer match the pinned layout.");
			}
			LogSkip(luaShape.Failure ?? delegateShape.Failure ?? "unsupported managed delegate layout");
			return;
		}
		if (flag)
		{
			ValidateLuaCall(luaShape, luaShape.OwnCalls[0]);
			ValidateInstalledDelegate(delegateShape);
			return;
		}
		MethodReference method = ImportRuntimeMethod(assembly);
		Instruction instruction = Instruction.Create(OpCodes.Call, method);
		Instruction instruction2 = null;
		Instruction instruction3 = null;
		TypeReference fieldType = delegateShape.HostDelegate.FieldType;
		try
		{
			delegateShape.HostDelegate.FieldType = delegateShape.PlayDelegate;
			delegateShape.StockLoad.OpCode = OpCodes.Ldnull;
			delegateShape.StockLoad.Operand = null;
			instruction2 = Instruction.Create(OpCodes.Ldftn, delegateShape.PlayAnimation);
			instruction3 = Instruction.Create(OpCodes.Newobj, delegateShape.DelegateConstructor);
			ILProcessor iLProcessor = delegateShape.StaticConstructor.Body.GetILProcessor();
			iLProcessor.InsertAfter(delegateShape.StockLoad, instruction2);
			iLProcessor.InsertAfter(instruction2, instruction3);
			methodDefinition.Body.GetILProcessor().InsertBefore(luaShape.WatcherAnchor, instruction);
			ValidateInstalledDelegate(InspectDelegateShape(assembly));
			ValidateLuaCall(InspectLuaShape(methodDefinition), instruction);
		}
		catch (Exception ex)
		{
			List<Exception> list = new List<Exception>();
			try
			{
				if (methodDefinition.Body.Instructions.Contains(instruction))
				{
					methodDefinition.Body.GetILProcessor().Remove(instruction);
				}
			}
			catch (Exception item)
			{
				list.Add(item);
			}
			try
			{
				Collection<Instruction> instructions = delegateShape.StaticConstructor.Body.Instructions;
				ILProcessor iLProcessor2 = delegateShape.StaticConstructor.Body.GetILProcessor();
				if (instruction3 != null && instructions.Contains(instruction3))
				{
					iLProcessor2.Remove(instruction3);
				}
				if (instruction2 != null && instructions.Contains(instruction2))
				{
					iLProcessor2.Remove(instruction2);
				}
				delegateShape.StockLoad.OpCode = OpCodes.Ldsfld;
				delegateShape.StockLoad.Operand = delegateShape.BurstPointer;
				delegateShape.HostDelegate.FieldType = fieldType;
			}
			catch (Exception item2)
			{
				list.Add(item2);
			}
			if (list.Count != 0)
			{
				throw new AggregateException("Upgrade-animation preloader mutation and rollback both failed.", new Exception[1] { ex }.Concat(list));
			}
			LogSkip("transactional hook installation failed and was rolled back: " + ex.GetBaseException().Message);
		}
	}

	private static LuaShape InspectLuaShape(MethodDefinition method)
	{
		Collection<Instruction> instructions = method.Body.Instructions;
		Instruction[] ownCalls = CallsTo(instructions, "System.Void SupremeCommanderOverhaulUpgradeAnimationFix.CachePatcherRuntime::Apply()");
		Instruction[] array = CallsTo(instructions, "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()");
		Instruction[] array2 = CallsTo(instructions, "System.Void EM.Lua.FilesCache::RebuildDirectoryIndex()");
		Instruction[] array3 = CallsTo(instructions, "EM.GameUtils.DebugManager/UnmanagedDebugProperties& EM.GameUtils.DebugManager::get_data()");
		Instruction[] array4 = instructions.Where((Instruction instruction) => instruction.OpCode == OpCodes.Ret).ToArray();
		string failure = null;
		if (array.Length != 1)
		{
			failure = $"expected one main SCOM callback, found {array.Length}";
		}
		else if (array2.Length != 1 || array3.Length != 1)
		{
			failure = "cache rebuild or watcher anchor is unavailable";
		}
		else if (array4.Length != 1)
		{
			failure = $"expected one CreateFileCache return, found {array4.Length}";
		}
		else if (!HasSupportedExceptionHandlerLayout(method.Body, instructions, array3[0]))
		{
			failure = "CreateFileCache exception regions reach the watcher anchor";
		}
		return new LuaShape(method, ownCalls, array, array2, array3, array4, failure);
	}

	private static DelegateShape InspectDelegateShape(AssemblyDefinition assembly)
	{
		try
		{
			TypeDefinition typeDefinition = RequireSingleType(assembly, "EM.Lua.Host.GeneratedDelegates");
			TypeDefinition typeDefinition2 = RequireSingleType(assembly, "EM.Lua.Host.GeneratedDelegates/PlayAnimation");
			MethodDefinition methodDefinition = RequireSingle(RequireSingleType(assembly, "EM.Lua.Host.HostLuaInterface").Methods, (MethodDefinition method) => method.Name == "PlayAnimation" && method.IsStatic && method.Parameters.Count == 3 && method.HasBody, "HostLuaInterface.PlayAnimation");
			MethodDefinition methodDefinition2 = RequireSingle(typeDefinition2.Methods, (MethodDefinition method) => method.Name == ".ctor" && method.Parameters.Count == 2, "PlayAnimation delegate constructor");
			ValidatePlayDelegateContract(typeDefinition2, methodDefinition, methodDefinition2);
			ValidateManagedRegistrationRoute(assembly);
			FieldDefinition fieldDefinition = RequireSingle(typeDefinition.Fields, (FieldDefinition field) => field.Name == "PlayAnimationHostDelegate" && field.IsStatic && field.IsPublic, "PlayAnimationHostDelegate field");
			string hostDelegateFullName = fieldDefinition.FullName;
			string hostDelegateDeclaringType = ((MemberReference)fieldDefinition).DeclaringType.FullName;
			FieldDefinition fieldDefinition2 = RequireSingle(typeDefinition.Fields, (FieldDefinition field) => field.Name == "PlayAnimationBurstPointer" && field.IsStatic, "PlayAnimationBurstPointer field");
			MethodDefinition methodDefinition3 = RequireSingle(typeDefinition.Methods, (MethodDefinition method) => method.Name == ".cctor" && method.HasBody, "GeneratedDelegates static constructor");
			if (methodDefinition3.Body.ExceptionHandlers.Count != 0)
			{
				return DelegateShape.Unsupported("GeneratedDelegates static constructor gained exception regions");
			}
			if (CountFloatLiteral(methodDefinition, -9000f) != 2 || CountFloatLiteral(methodDefinition, -10000f) != 1 || CountFloatLiteral(methodDefinition, 10000f) != 1)
			{
				return DelegateShape.Unsupported("the main SCOM managed PlayAnimation sentinel bridge is unavailable");
			}
			if (CountFloatLiteral(RequireSingle(RequireSingleType(assembly, "EM.Engine.Simulation.TxBothSystem_AnimateSimulationBones/AnimateSimulationBonesJob").Methods, (MethodDefinition method) => method.FullName == "System.Void EM.Engine.Simulation.TxBothSystem_AnimateSimulationBones/AnimateSimulationBonesJob::Execute(System.Int32,EM.Entities.World&)" && method.HasBody, "AnimateSimulationBonesJob.Execute"), -9000f) != 1)
			{
				return DelegateShape.Unsupported("the main SCOM managed bone-job sentinel bridge is incomplete");
			}
			Instruction[] array = methodDefinition3.Body.Instructions.Where((Instruction instruction2) => instruction2.OpCode == OpCodes.Stsfld && IsField(instruction2.Operand, hostDelegateFullName)).ToArray();
			if (array.Length != 1)
			{
				return DelegateShape.Unsupported($"expected one PlayAnimationHostDelegate store, found {array.Length}");
			}
			int num = (from method in EnumerateTypes(assembly.MainModule.Types).SelectMany((TypeDefinition type) => type.Methods)
				where method.HasBody
				select method).SelectMany((MethodDefinition method) => method.Body.Instructions).Count(delegate(Instruction instruction2)
			{
				object operand = instruction2.Operand;
				FieldReference fieldReference = (FieldReference)((operand is FieldReference) ? operand : null);
				if (fieldReference == null)
				{
					return false;
				}
				return fieldReference.Name == "PlayAnimationHostDelegate" && fieldReference.DeclaringType.FullName == hostDelegateDeclaringType && IsField(fieldReference, hostDelegateFullName);
			});
			if (num != 1)
			{
				return DelegateShape.Unsupported($"expected one assembly-wide PlayAnimationHostDelegate reference, found {num}");
			}
			Instruction instruction = array[0];
			string fullName = fieldDefinition2.FieldType.FullName;
			if (fieldDefinition.FieldType.FullName == fullName && instruction.Previous != null && instruction.Previous.OpCode == OpCodes.Ldsfld && IsField(instruction.Previous.Operand, fieldDefinition2.FullName))
			{
				return new DelegateShape(DelegateState.Stock, typeDefinition, typeDefinition2, methodDefinition, methodDefinition2, fieldDefinition, fieldDefinition2, methodDefinition3, instruction.Previous, instruction, null);
			}
			if (fieldDefinition.FieldType.FullName == typeDefinition2.FullName)
			{
				OpCode? opCode = instruction.Previous?.OpCode;
				OpCode newobj = OpCodes.Newobj;
				if (opCode.HasValue && opCode.GetValueOrDefault() == newobj && IsMethod(instruction.Previous.Operand, methodDefinition2.FullName))
				{
					opCode = instruction.Previous.Previous?.OpCode;
					newobj = OpCodes.Ldftn;
					if (opCode.HasValue && opCode.GetValueOrDefault() == newobj && IsMethod(instruction.Previous.Previous.Operand, methodDefinition.FullName) && instruction.Previous.Previous.Previous?.OpCode == OpCodes.Ldnull)
					{
						return new DelegateShape(DelegateState.Installed, typeDefinition, typeDefinition2, methodDefinition, methodDefinition2, fieldDefinition, fieldDefinition2, methodDefinition3, instruction.Previous.Previous.Previous, instruction, null);
					}
				}
			}
			return DelegateShape.Unsupported("PlayAnimationHostDelegate has an unsupported type or initializer");
		}
		catch (Exception ex)
		{
			return DelegateShape.Unsupported(ex.GetBaseException().Message);
		}
	}

	private static void ValidatePlayDelegateContract(TypeDefinition playDelegate, MethodDefinition playAnimation, MethodDefinition constructor)
	{
		if (playDelegate.IsSealed && !playDelegate.HasGenericParameters && !(playDelegate.BaseType?.FullName != "System.MulticastDelegate"))
		{
			if (constructor.ReturnType.FullName != "System.Void" || constructor.Parameters[0].ParameterType.FullName != "System.Object" || constructor.Parameters[1].ParameterType.FullName != "System.IntPtr")
			{
				throw new InvalidOperationException("PlayAnimation delegate constructor signature drifted.");
			}
			MethodDefinition methodDefinition = RequireSingle(playDelegate.Methods, (MethodDefinition method) => method.Name == "Invoke" && method.Parameters.Count == 3, "PlayAnimation delegate Invoke");
			if (methodDefinition.ReturnType.FullName != playAnimation.ReturnType.FullName || !methodDefinition.Parameters.Zip(playAnimation.Parameters, (ParameterDefinition delegateParameter, ParameterDefinition targetParameter) => UnmodifiedTypeName(delegateParameter.ParameterType) == UnmodifiedTypeName(targetParameter.ParameterType)).All((bool equal) => equal))
			{
				throw new InvalidOperationException("PlayAnimation delegate and managed target signatures differ.");
			}
			CustomAttribute customAttribute = RequireSingle(playDelegate.CustomAttributes, (CustomAttribute attribute) => attribute.AttributeType.FullName == "System.Runtime.InteropServices.UnmanagedFunctionPointerAttribute", "PlayAnimation unmanaged calling convention");
			if (customAttribute.ConstructorArguments.Count == 1 && Convert.ToInt32(customAttribute.ConstructorArguments[0].Value) == 2)
			{
				if (RequireSingle(playAnimation.CustomAttributes, (CustomAttribute attribute) => attribute.AttributeType.FullName == "Unity.Burst.BurstCompileAttribute", "managed PlayAnimation Burst attribute").Properties.Count(delegate(Mono.Cecil.CustomAttributeNamedArgument property)
				{
					bool flag = false;
					int num;
					if (property.Name == "DisableDirectCall")
					{
						object value2 = property.Argument.Value;
						if (value2 is bool)
						{
							flag = (bool)value2;
							num = 1;
						}
						else
						{
							num = 0;
						}
					}
					else
					{
						num = 0;
					}
					return (byte)(num & (flag ? 1 : 0)) != 0;
				}) != 1)
				{
					throw new InvalidOperationException("Managed PlayAnimation no longer disables Burst direct calls.");
				}
				CustomAttribute customAttribute2 = RequireSingle(playAnimation.CustomAttributes, (CustomAttribute attribute) => attribute.AttributeType.FullName == "AOT.MonoPInvokeCallbackAttribute", "managed PlayAnimation callback root");
				if (customAttribute2.ConstructorArguments.Count == 1)
				{
					object value = customAttribute2.ConstructorArguments[0].Value;
					TypeReference typeReference = (TypeReference)((value is TypeReference) ? value : null);
					if (typeReference != null && !(typeReference.FullName != playDelegate.FullName))
					{
						return;
					}
				}
				throw new InvalidOperationException("Managed PlayAnimation callback type drifted.");
			}
			throw new InvalidOperationException("PlayAnimation delegate is not pinned to the Cdecl calling convention.");
		}
		throw new InvalidOperationException("PlayAnimation is not the pinned non-generic delegate type.");
	}

	private static void ValidateManagedRegistrationRoute(AssemblyDefinition assembly)
	{
		Collection<Instruction> instructions = RequireSingle(RequireSingleType(assembly, "EM.Lua.LuaInterface").Methods, (MethodDefinition method) => method.Name == "RegisterDelegatesForWorld" && method.IsStatic && method.HasBody, "LuaInterface.RegisterDelegatesForWorld").Body.Instructions;
		Instruction[] array = instructions.Where((Instruction instruction2) => IsMethod(instruction2.Operand, "System.Boolean System.Type::get_IsGenericType()")).ToArray();
		Instruction[] array2 = instructions.Where(delegate(Instruction instruction2)
		{
			object operand = instruction2.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			return methodReference != null && methodReference.DeclaringType.FullName == "System.Runtime.InteropServices.Marshal" && methodReference.Name == "GetFunctionPointerForDelegate";
		}).ToArray();
		if (array.Length == 1 && array2.Length == 1 && (!(array[0].Next?.OpCode != OpCodes.Brfalse_S) || !(array[0].Next?.OpCode != OpCodes.Brfalse)))
		{
			object obj = array[0].Next?.Operand;
			Instruction instruction = (Instruction)((obj is Instruction) ? obj : null);
			if (instruction != null && instruction.Next == array2[0])
			{
				return;
			}
		}
		throw new InvalidOperationException("Lua delegate registration no longer routes non-generic delegates through Marshal.");
	}

	private static string UnmodifiedTypeName(TypeReference type)
	{
		while (true)
		{
			RequiredModifierType requiredModifierType = (RequiredModifierType)((type is RequiredModifierType) ? type : null);
			if (requiredModifierType == null)
			{
				break;
			}
			type = requiredModifierType.ElementType;
		}
		while (true)
		{
			OptionalModifierType optionalModifierType = (OptionalModifierType)((type is OptionalModifierType) ? type : null);
			if (optionalModifierType == null)
			{
				break;
			}
			type = optionalModifierType.ElementType;
		}
		return type.FullName;
	}

	private static void ValidateInstalledDelegate(DelegateShape shape)
	{
		if (shape.State != DelegateState.Installed)
		{
			throw new InvalidOperationException(shape.Failure ?? "The managed PlayAnimation delegate route was not installed.");
		}
		string hostDelegateFullName = shape.HostDelegate.FullName;
		int num = shape.StaticConstructor.Body.Instructions.Count((Instruction instruction) => IsField(instruction.Operand, hostDelegateFullName));
		if (num != 1)
		{
			throw new InvalidOperationException($"Expected one rooted managed PlayAnimation delegate reference, found {num}.");
		}
	}

	private static void ValidateLuaCall(LuaShape shape, Instruction ownCall)
	{
		if (!shape.IsSupported)
		{
			throw new InvalidOperationException(shape.Failure);
		}
		Collection<Instruction> instructions = shape.Method.Body.Instructions;
		int ownIndex = instructions.IndexOf(ownCall);
		if (instructions.IndexOf(shape.ScomCalls[0]) >= ownIndex || instructions.IndexOf(shape.RebuildCalls[0]) >= ownIndex)
		{
			throw new InvalidOperationException("Upgrade-animation callback does not run after SCOM and cache rebuild.");
		}
		if (ownCall.Next != shape.WatcherAnchor)
		{
			throw new InvalidOperationException("Upgrade-animation callback does not immediately precede the watcher branch.");
		}
		BranchEdge[] source = EnumerateBranchEdges(instructions).ToArray();
		if (source.Any((BranchEdge edge) => instructions.IndexOf(edge.Source) < ownIndex && instructions.IndexOf(edge.Target) > ownIndex))
		{
			throw new InvalidOperationException("A CreateFileCache control-flow edge bypasses the upgrade-animation callback.");
		}
		if (!source.Any((BranchEdge edge) => edge.Target == shape.Returns[0] && instructions.IndexOf(edge.Source) > ownIndex))
		{
			throw new InvalidOperationException("The post-callback watcher early-return edge is unavailable.");
		}
	}

	private static MethodReference ImportRuntimeMethod(AssemblyDefinition assembly)
	{
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, "Apply");
		MethodReference methodReference = assembly.MainModule.ImportReference(method);
		if (!string.Equals(methodReference.FullName, "System.Void SupremeCommanderOverhaulUpgradeAnimationFix.CachePatcherRuntime::Apply()", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("Imported upgrade-animation callback identity drifted: " + methodReference.FullName);
		}
		return methodReference;
	}

	private static MethodDefinition? FindStaticMethod(AssemblyDefinition assembly, string typeName, string methodName)
	{
		TypeDefinition[] array = (from type in EnumerateTypes(assembly.MainModule.Types)
			where type.FullName == typeName
			select type).ToArray();
		if (array.Length != 1)
		{
			return null;
		}
		MethodDefinition[] array2 = array[0].Methods.Where((MethodDefinition method) => method.Name == methodName && method.IsStatic && method.Parameters.Count == 0 && method.HasBody).ToArray();
		if (array2.Length != 1)
		{
			return null;
		}
		return array2[0];
	}

	private static TypeDefinition RequireSingleType(AssemblyDefinition assembly, string fullName)
	{
		return RequireSingle(EnumerateTypes(assembly.MainModule.Types), (TypeDefinition type) => type.FullName == fullName, fullName + " type");
	}

	private static T RequireSingle<T>(IEnumerable<T> values, Func<T, bool> predicate, string description)
	{
		T[] array = values.Where(predicate).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException($"Expected one {description}, found {array.Length}.");
		}
		return array[0];
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

	private static int CountFloatLiteral(MethodDefinition method, float value)
	{
		return method.Body.Instructions.Count((Instruction instruction) => instruction.OpCode == OpCodes.Ldc_R4 && instruction.Operand is float num && num.Equals(value));
	}

	private static Instruction[] CallsTo(IEnumerable<Instruction> instructions, string fullName)
	{
		return instructions.Where((Instruction instruction) => IsMethod(instruction.Operand, fullName) && (instruction.OpCode == OpCodes.Call || instruction.OpCode == OpCodes.Callvirt)).ToArray();
	}

	private static bool IsMethod(object? operand, string fullName)
	{
		MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
		if (methodReference != null)
		{
			return methodReference.FullName == fullName;
		}
		return false;
	}

	private static bool IsField(object? operand, string fullName)
	{
		FieldReference fieldReference = (FieldReference)((operand is FieldReference) ? operand : null);
		if (fieldReference != null)
		{
			return fieldReference.FullName == fullName;
		}
		return false;
	}

	private static IEnumerable<BranchEdge> EnumerateBranchEdges(IEnumerable<Instruction> instructions)
	{
		foreach (Instruction instruction in instructions)
		{
			object operand = instruction.Operand;
			Instruction instruction2 = (Instruction)((operand is Instruction) ? operand : null);
			if (instruction2 != null)
			{
				yield return new BranchEdge(instruction, instruction2);
			}
			else if (instruction.Operand is Instruction[] array)
			{
				Instruction[] array2 = array;
				Instruction[] array3 = array2;
				foreach (Instruction target in array3)
				{
					yield return new BranchEdge(instruction, target);
				}
			}
		}
	}

	private static bool HasSupportedExceptionHandlerLayout(Mono.Cecil.Cil.MethodBody body, IList<Instruction> instructions, Instruction insertionAnchor)
	{
		int num = instructions.IndexOf(insertionAnchor);
		IEnumerator<ExceptionHandler> enumerator = body.ExceptionHandlers.GetEnumerator();
		try
		{
			while (enumerator.MoveNext())
			{
				ExceptionHandler current = enumerator.Current;
				int num2 = instructions.IndexOf(current.TryStart);
				int num3 = instructions.IndexOf(current.TryEnd);
				int num4 = instructions.IndexOf(current.HandlerStart);
				int num5 = instructions.IndexOf(current.HandlerEnd);
				int num6 = ((current.FilterStart != null) ? instructions.IndexOf(current.FilterStart) : 0);
				if (num2 < 0 || num3 < 0 || num4 < 0 || num5 < 0 || num6 < 0 || num2 >= num3 || num4 >= num5 || num2 >= num || num3 >= num || num4 >= num || num5 >= num || num6 >= num)
				{
					return false;
				}
			}
		}
		finally
		{
			enumerator.Dispose();
		}
		return true;
	}

	private static bool IsSupportedMvid(Guid mvid)
	{
		return string.Equals(mvid.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase);
	}

	private static void LogSkip(string reason)
	{
		try
		{
			Console.WriteLine("[SCOM Upgrade Animation Fix] Preloader skipped: " + reason + ".");
		}
		catch
		{
		}
	}
}
