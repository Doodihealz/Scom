using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Resources;
using System.Security.Cryptography;
using System.Text;
using Mono.Cecil;
using Mono.Cecil.Cil;

namespace SupremeCommanderOverhaulFieldFixes;

public static class FollowupCacheRuntime
{
	private const string TrebuchetMvid = "2cc1c6fa-e909-410e-8fd9-2f307b231dfb";

	private const string FieldFixCall = "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::Apply()";

	private const string LargeMapCall = "System.Void SupremeCommanderOverhaulCanonical.LargeMapPlacementGridCompat::Apply()";

	private const string FollowupCall = "System.Void SupremeCommanderOverhaulFieldFixes.FollowupCacheRuntime::Apply()";

	private const string LegacyDemolisherMarker = "-- SCOM Field Fix: Demolisher stable deployed aim 1.1.0";

	private const int LegacyDemolisherLength = 1802;

	private const string LegacyDemolisherSha256 = "21D3971AA4A874D220700B1F6E531AD4DE216E2003D3C207E8307FFD5661DC2D";

	private static readonly string[] Paths = new string[5] { "LJ/lua/host/hostListeners.lua", "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "LJ/lua/client/clientListeners.lua", "LJ/lua/client/managers/orders/clientOrderManager.lua", "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua" };

	private static readonly string[] RallyResources = new string[4] { "ScomFieldFixes.FactoryRally.host_listener.lua", "ScomFieldFixes.FactoryRally.host_default.lua", "ScomFieldFixes.FactoryRally.client_listener.lua", "ScomFieldFixes.FactoryRally.client_orders.lua" };

	private const string PreviousDemolisherMarker = "-- SCOM Field Fix: Demolisher reversible source deployment 1.2.0";

	private const int PreviousDemolisherLength = 4583;

	private const string PreviousDemolisherSha256 = "E1B9E1CBA541300949C3362C3602F3119AA79403C9A44CE1624155E30BCA5A7C";

	public static void Install(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		if (!string.Equals(assembly.MainModule.Mvid.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Follow-up requires the pinned Trebuchet.dll MVID.");
		}
		MethodDefinition methodDefinition = null;
		foreach (TypeDefinition type in assembly.MainModule.Types)
		{
			if (type.FullName != "EM.Lua.FilesCache")
			{
				continue;
			}
			foreach (MethodDefinition method2 in type.Methods)
			{
				if (method2.Name == "CreateFileCache" && method2.IsStatic && method2.Parameters.Count == 0 && method2.HasBody)
				{
					if (methodDefinition != null)
					{
						throw new InvalidOperationException("Duplicate CreateFileCache method.");
					}
					methodDefinition = method2;
				}
			}
		}
		if (methodDefinition == null)
		{
			throw new MissingMethodException("EM.Lua.FilesCache", "CreateFileCache");
		}
		Instruction instruction = null;
		Instruction instruction2 = null;
		Instruction instruction3 = null;
		foreach (Instruction instruction4 in methodDefinition.Body.Instructions)
		{
			if (instruction4.OpCode != OpCodes.Call || !(instruction4.Operand is MethodReference methodReference))
			{
				continue;
			}
			if (methodReference.FullName == "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::Apply()")
			{
				if (instruction != null)
				{
					throw new InvalidOperationException("Duplicate Field Fixes callback.");
				}
				instruction = instruction4;
			}
			else if (methodReference.FullName == "System.Void SupremeCommanderOverhaulCanonical.LargeMapPlacementGridCompat::Apply()")
			{
				if (instruction2 != null)
				{
					throw new InvalidOperationException("Duplicate Large Map callback.");
				}
				instruction2 = instruction4;
			}
			else if (methodReference.FullName == "System.Void SupremeCommanderOverhaulFieldFixes.FollowupCacheRuntime::Apply()")
			{
				if (instruction3 != null)
				{
					throw new InvalidOperationException("Duplicate follow-up callback.");
				}
				instruction3 = instruction4;
			}
		}
		if (instruction == null || instruction2 == null || instruction2.Previous != instruction)
		{
			throw new InvalidOperationException("Follow-up requires adjacent Field Fixes and Large Map callbacks.");
		}
		if (instruction3 == null)
		{
			MethodInfo method = typeof(FollowupCacheRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(FollowupCacheRuntime).FullName, "Apply");
			MethodReference methodReference2 = assembly.MainModule.ImportReference(method);
			if (methodReference2.FullName != "System.Void SupremeCommanderOverhaulFieldFixes.FollowupCacheRuntime::Apply()")
			{
				throw new InvalidOperationException("Follow-up callback identity drifted.");
			}
			instruction3 = Instruction.Create(OpCodes.Call, methodReference2);
			methodDefinition.Body.GetILProcessor().InsertAfter(instruction2, instruction3);
		}
		if (instruction3.Previous != instruction2)
		{
			throw new InvalidOperationException("Follow-up callback order drifted.");
		}
	}

	public static void Apply()
	{
		Type type = FindLoadedType("EM.Lua.FilesCache");
		if (!string.Equals(type.Module.ModuleVersionId.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Follow-up runtime Trebuchet.dll MVID drifted.");
		}
		ApplyToCache((type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache."));
	}

	private static void ApplyToCache(object cache)
	{
		string[] array = new string[Paths.Length];
		object[] array2 = new object[Paths.Length];
		object[] array3 = new object[Paths.Length];
		string[] array4 = new string[Paths.Length];
		string[] array5 = new string[Paths.Length];
		bool[] array6 = new bool[Paths.Length];
		bool flag = false;
		try
		{
			for (int i = 0; i < Paths.Length; i++)
			{
				FindCachedResource(cache, Paths[i], out array[i], out array2[i]);
				array4[i] = ReadText(array2[i]);
				array5[i] = Transform(i, array4[i]);
			}
			for (int j = 0; j < Paths.Length; j++)
			{
				if (array4[j] != array5[j])
				{
					array3[j] = CreateNativeArray(array2[j].GetType(), array5[j]);
				}
			}
			for (int k = 0; k < Paths.Length; k++)
			{
				if (array3[k] != null)
				{
					array6[k] = true;
					SetCachedResource(cache, array[k], array3[k]);
					if (ReadText(GetExactCachedResource(cache, array[k])) != array5[k])
					{
						throw new InvalidOperationException("Follow-up cache verification failed for " + Paths[k]);
					}
				}
			}
			flag = true;
		}
		catch (Exception item)
		{
			List<Exception> list = new List<Exception>();
			for (int num = Paths.Length - 1; num >= 0; num--)
			{
				if (array6[num])
				{
					try
					{
						SetCachedResource(cache, array[num], array2[num]);
						if (ReadText(GetExactCachedResource(cache, array[num])) != array4[num])
						{
							throw new InvalidOperationException("Follow-up rollback verification failed for " + Paths[num]);
						}
						array6[num] = false;
					}
					catch (Exception item2)
					{
						list.Add(item2);
					}
				}
			}
			if (list.Count != 0)
			{
				list.Insert(0, item);
				throw new AggregateException("Follow-up transaction and rollback failed.", list);
			}
			throw;
		}
		finally
		{
			for (int l = 0; l < Paths.Length; l++)
			{
				if (flag)
				{
					if (array3[l] != null)
					{
						TryDispose(array2[l]);
					}
				}
				else if (!array6[l] && array3[l] != null)
				{
					TryDispose(array3[l]);
				}
			}
		}
	}

	private static string Transform(int index, string source)
	{
		source = Normalize(source);
		switch (index)
		{
		case 4:
			return TransformDemolisher(source);
		case 0:
			RequireAppendix(source, "ScomFieldFixes.strategic_silo_creative_host_listener_appendix.lua");
			break;
		case 1:
			RequireAppendix(source, "ScomFieldFixes.strategic_silo_structure_assist_appendix.lua");
			RequireAppendix(source, "ScomFieldFixes.Roster.source_upgrade_host.lua");
			break;
		case 2:
			RequireAppendix(source, "ScomFieldFixes.strategic_silo_client_listener_appendix.lua");
			RequireAppendix(source, "ScomFieldFixes.tactical_missile_client_appendix.lua");
			break;
		case 3:
			RequireCount(source, "function UpdateOrderDraw()", 1, "native order drawing");
			RequireCount(source, "local ClientOrderRenderer = Import(\"client/managers/orders/interfaces/clientOrderRenderer.lua\").ClientOrderRenderer", 1, "native selection import");
			break;
		}
		return AppendExact(source, LoadEmbeddedText(RallyResources[index]));
	}

	private static string TransformDemolisher(string source)
	{
		string text = LoadEmbeddedText("ScomFieldFixes.uef_t3_demolisher_host_appendix.lua").Trim();
		string token = FirstLine(text);
		int num = Count(source, "-- SCOM Field Fix: Demolisher stable deployed aim 1.1.0");
		int num2 = Count(source, "-- SCOM Field Fix: Demolisher reversible source deployment 1.2.0");
		int num3 = Count(source, token);
		if (num + num2 + num3 != 1)
		{
			throw new InvalidOperationException("Demolisher appendix is absent, mixed, or duplicated.");
		}
		if (num == 1 || num2 == 1)
		{
			string value = ((num == 1) ? "-- SCOM Field Fix: Demolisher stable deployed aim 1.1.0" : "-- SCOM Field Fix: Demolisher reversible source deployment 1.2.0");
			int num4 = ((num == 1) ? 1802 : 4583);
			string text2 = ((num == 1) ? "21D3971AA4A874D220700B1F6E531AD4DE216E2003D3C207E8307FFD5661DC2D" : "E1B9E1CBA541300949C3362C3602F3119AA79403C9A44CE1624155E30BCA5A7C");
			int num5 = source.IndexOf(value, StringComparison.Ordinal);
			int num6 = num5 + num4;
			if (num6 > source.Length || (num6 < source.Length && source[num6] != '\n'))
			{
				throw new InvalidOperationException("Previous Demolisher appendix boundary drifted.");
			}
			if (Sha256(source.Substring(num5, num4)) != text2)
			{
				throw new InvalidOperationException("Previous Demolisher appendix bytes drifted.");
			}
			source = source.Substring(0, num5) + text + source.Substring(num6);
		}
		RequireCount(source, "-- SCOM Field Fix: Demolisher stable deployed aim 1.1.0", 0, "retired Demolisher appendix");
		RequireCount(source, "-- SCOM Field Fix: Demolisher reversible source deployment 1.2.0", 0, "previous Demolisher appendix");
		RequireCount(source, token, 1, "current Demolisher marker");
		RequireCount(source, text, 1, "current Demolisher bytes");
		return source;
	}

	private static void RequireAppendix(string source, string resource)
	{
		string text = LoadEmbeddedText(resource).Trim();
		RequireCount(source, FirstLine(text), 1, resource + " marker");
		RequireCount(source, text, 1, resource + " bytes");
	}

	private static string AppendExact(string source, string resource)
	{
		string text = Normalize(resource).Trim();
		string text2 = FirstLine(text);
		switch (Count(source, text2))
		{
		case 0:
			source = source + (source.EndsWith("\n", StringComparison.Ordinal) ? "" : "\n") + text + "\n";
			break;
		default:
			throw new InvalidOperationException("Duplicate follow-up marker " + text2);
		case 1:
			break;
		}
		RequireCount(source, text2, 1, "follow-up marker");
		RequireCount(source, text, 1, "follow-up bytes");
		return source;
	}

	private static string FirstLine(string value)
	{
		int num = value.IndexOf('\n');
		if (num >= 0)
		{
			return value.Substring(0, num);
		}
		return value;
	}

	private static void RequireCount(string source, string token, int expected, string description)
	{
		int num = Count(source, token);
		if (num != expected)
		{
			throw new InvalidOperationException(description + " count is " + num + ", expected " + expected);
		}
	}

	private static int Count(string source, string token)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(token, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += token.Length;
		}
		return num;
	}

	private static string Normalize(string source)
	{
		return source.Replace("\r\n", "\n").Replace('\r', '\n');
	}

	private static string Sha256(string source)
	{
		using SHA256 sHA = SHA256.Create();
		return BitConverter.ToString(sHA.ComputeHash(Encoding.UTF8.GetBytes(source))).Replace("-", "");
	}

	private static string LoadEmbeddedText(string name)
	{
		using Stream stream = typeof(FollowupCacheRuntime).Assembly.GetManifestResourceStream(name) ?? throw new MissingManifestResourceException("Missing follow-up resource " + name);
		using StreamReader streamReader = new StreamReader(stream, new UTF8Encoding(encoderShouldEmitUTF8Identifier: false), detectEncodingFromByteOrderMarks: true);
		return Normalize(streamReader.ReadToEnd());
	}

	private static Type FindLoadedType(string fullName)
	{
		Type type = null;
		Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
		for (int i = 0; i < assemblies.Length; i++)
		{
			Type type2 = assemblies[i].GetType(fullName, throwOnError: false);
			if (!(type2 == null))
			{
				if (type != null)
				{
					throw new InvalidOperationException("Duplicate loaded type " + fullName);
				}
				type = type2;
			}
		}
		return type ?? throw new TypeLoadException(fullName);
	}

	private static void FindCachedResource(object cache, string relativePath, out string path, out object value)
	{
		path = null;
		value = null;
		string value2 = "/" + relativePath.Replace('\\', '/');
		foreach (object item in (IEnumerable)cache)
		{
			Type type = item.GetType();
			if (type.GetProperty("Key")?.GetValue(item, null) is string text && text.Replace('\\', '/').EndsWith(value2, StringComparison.OrdinalIgnoreCase))
			{
				if (path != null)
				{
					throw new InvalidOperationException("Duplicate cached path " + relativePath);
				}
				path = text;
				value = type.GetProperty("Value")?.GetValue(item, null) ?? throw new InvalidOperationException("Null cached resource " + relativePath);
			}
		}
		if (path == null)
		{
			throw new FileNotFoundException("Missing follow-up cache path", relativePath);
		}
	}

	private static string ReadText(object resource)
	{
		object obj = resource.GetType().GetProperty("IsCreated")?.GetValue(resource, null);
		if (!(obj is bool) || !(bool)obj)
		{
			throw new InvalidOperationException("Uninitialized Lua cache resource.");
		}
		byte[] bytes = ((resource.GetType().GetMethod("ToArray", Type.EmptyTypes) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null) as byte[]) ?? throw new InvalidOperationException("Lua cache ToArray returned null.");
		return Encoding.UTF8.GetString(bytes);
	}

	private static object CreateNativeArray(Type type, string source)
	{
		if (!type.IsGenericType || type.GetGenericArguments().Length != 1 || type.GetGenericArguments()[0] != typeof(byte))
		{
			throw new InvalidOperationException("Expected NativeArray<byte>.");
		}
		Type type2 = type.Assembly.GetType("Unity.Collections.Allocator", throwOnError: false) ?? FindLoadedType("Unity.Collections.Allocator");
		return (type.GetConstructor(new Type[2]
		{
			typeof(byte[]),
			type2
		}) ?? throw new MissingMethodException(type.FullName, ".ctor(Byte[], Allocator)")).Invoke(new object[2]
		{
			Encoding.UTF8.GetBytes(source),
			Enum.Parse(type2, "Persistent")
		});
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item") ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static object GetExactCachedResource(object cache, string path)
	{
		return (cache.GetType().GetProperty("Item") ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("Cached path vanished: " + path);
	}

	private static void TryDispose(object resource)
	{
		try
		{
			object obj = resource.GetType().GetProperty("IsCreated")?.GetValue(resource, null);
			bool flag = default(bool);
			int num;
			if (obj is bool)
			{
				flag = (bool)obj;
				num = 1;
			}
			else
			{
				num = 0;
			}
			if (((uint)num & (flag ? 1u : 0u)) != 0)
			{
				resource.GetType().GetMethod("Dispose", Type.EmptyTypes)?.Invoke(resource, null);
			}
		}
		catch
		{
		}
	}
}
