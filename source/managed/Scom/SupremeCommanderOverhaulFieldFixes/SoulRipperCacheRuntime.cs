using System;
using System.Collections;
using System.IO;
using System.Reflection;
using System.Resources;
using System.Security.Cryptography;
using System.Text;
using Mono.Cecil;
using Mono.Cecil.Cil;

namespace SupremeCommanderOverhaulFieldFixes;

public static class SoulRipperCacheRuntime
{
	private const string TrebuchetMvid = "2cc1c6fa-e909-410e-8fd9-2f307b231dfb";

	private const string FieldFixCall = "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::Apply()";

	private const string MigrationCall = "System.Void SupremeCommanderOverhaulFieldFixes.SoulRipperCacheRuntime::Apply()";

	private const string Path = "LJ/lua/common/units/unitsTemplates/uga5007/uga5007.santp";

	private const string Resource = "ScomFieldFixes.Roster.Unit.uga5007.santp";

	private const string Marker = "-- SCOM Soul Ripper ground-rocket gravity 1.0.0";

	private const string LegacyBaseSha256 = "229581EA90BD76140E33068B3EE9C6EF091C36A71661BDECAEBB86A50DE48134";

	private const string CurrentBaseSha256 = "D7D96A190E7B895E8A40349D266593EA50A9C45ACF0CF5D75746053C8D9CD0D2";

	private const string LegacyCompletedSha256 = "B219B109CFCA49681EA56AC9F13999FBB16191E6723357359D75ACE39577F882";

	public static void Install(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		if (!string.Equals(assembly.MainModule.Mvid.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Soul Ripper migration requires the pinned Trebuchet.dll MVID.");
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
				if (!(method2.Name != "CreateFileCache") && method2.IsStatic && method2.Parameters.Count == 0 && method2.HasBody)
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
		foreach (Instruction instruction3 in methodDefinition.Body.Instructions)
		{
			if (instruction3.OpCode != OpCodes.Call || !(instruction3.Operand is MethodReference methodReference))
			{
				continue;
			}
			if (methodReference.FullName == "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::Apply()")
			{
				if (instruction != null)
				{
					throw new InvalidOperationException("Duplicate Field Fixes callback.");
				}
				instruction = instruction3;
			}
			else if (methodReference.FullName == "System.Void SupremeCommanderOverhaulFieldFixes.SoulRipperCacheRuntime::Apply()")
			{
				if (instruction2 != null)
				{
					throw new InvalidOperationException("Duplicate Soul Ripper migration callback.");
				}
				instruction2 = instruction3;
			}
		}
		if (instruction == null)
		{
			throw new InvalidOperationException("Soul Ripper migration requires Field Fixes callback.");
		}
		if (instruction2 == null)
		{
			MethodInfo method = typeof(SoulRipperCacheRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(SoulRipperCacheRuntime).FullName, "Apply");
			MethodReference methodReference2 = assembly.MainModule.ImportReference(method);
			if (methodReference2.FullName != "System.Void SupremeCommanderOverhaulFieldFixes.SoulRipperCacheRuntime::Apply()")
			{
				throw new InvalidOperationException("Soul Ripper callback identity drifted.");
			}
			instruction2 = Instruction.Create(OpCodes.Call, methodReference2);
			methodDefinition.Body.GetILProcessor().InsertBefore(instruction, instruction2);
		}
		if (instruction2.Next != instruction)
		{
			throw new InvalidOperationException("Soul Ripper migration must immediately precede Field Fixes.");
		}
	}

	public static void Apply()
	{
		Type type = FindLoadedType("EM.Lua.FilesCache");
		if (!string.Equals(type.Module.ModuleVersionId.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Soul Ripper runtime Trebuchet.dll MVID drifted.");
		}
		ApplyToCache((type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache."));
	}

	private static void ApplyToCache(object cache)
	{
		if (!TryFindCachedResource(cache, out var path, out var value))
		{
			return;
		}
		string text = ReadText(value);
		string text2 = Transform(text);
		if (text == text2)
		{
			return;
		}
		object obj = CreateNativeArray(value.GetType(), text2);
		bool flag = false;
		try
		{
			flag = true;
			SetCachedResource(cache, path, obj);
			if (ReadText(GetExactCachedResource(cache, path)) != text2)
			{
				throw new InvalidOperationException("Soul Ripper cache write verification failed.");
			}
			TryDispose(value);
		}
		catch (Exception ex)
		{
			if (flag)
			{
				try
				{
					SetCachedResource(cache, path, value);
					if (ReadText(GetExactCachedResource(cache, path)) != text)
					{
						throw new InvalidOperationException("Soul Ripper cache rollback verification failed.");
					}
					flag = false;
				}
				catch (Exception ex2)
				{
					throw new AggregateException("Soul Ripper migration and rollback failed.", ex, ex2);
				}
			}
			if (!flag)
			{
				TryDispose(obj);
			}
			throw;
		}
	}

	private static string Transform(string cachedText)
	{
		string text = LoadEmbeddedText("ScomFieldFixes.Roster.Unit.uga5007.santp");
		if (Sha256(text) != "D7D96A190E7B895E8A40349D266593EA50A9C45ACF0CF5D75746053C8D9CD0D2")
		{
			throw new InvalidOperationException("Soul Ripper corrected resource drifted.");
		}
		int num = text.IndexOf("-- SCOM Soul Ripper ground-rocket gravity 1.0.0", StringComparison.Ordinal);
		if (num < 0 || text.IndexOf("-- SCOM Soul Ripper ground-rocket gravity 1.0.0", num + "-- SCOM Soul Ripper ground-rocket gravity 1.0.0".Length, StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("Soul Ripper correction marker is absent or duplicated.");
		}
		string text2 = text.Substring(0, num);
		if (Sha256(text2) != "229581EA90BD76140E33068B3EE9C6EF091C36A71661BDECAEBB86A50DE48134")
		{
			throw new InvalidOperationException("Soul Ripper source prefix drifted.");
		}
		string text3 = Complete(text2);
		if (Sha256(text3) != "B219B109CFCA49681EA56AC9F13999FBB16191E6723357359D75ACE39577F882")
		{
			throw new InvalidOperationException("Soul Ripper legacy completion drifted.");
		}
		string text4 = Complete(text);
		if (text4.IndexOf("-- SCOM Soul Ripper ground-rocket gravity 1.0.0", StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("Soul Ripper completion lost its correction.");
		}
		if (string.Equals(cachedText, text4, StringComparison.Ordinal))
		{
			return cachedText;
		}
		if (string.Equals(cachedText, text3, StringComparison.Ordinal))
		{
			return text4;
		}
		throw new InvalidOperationException("Soul Ripper cached template is neither exact legacy nor current bytes.");
	}

	private static string Complete(string source)
	{
		MethodInfo methodInfo = typeof(CachePatcherRuntime).GetMethod("PatchSourceUnitCompletion", BindingFlags.Static | BindingFlags.NonPublic) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, "PatchSourceUnitCompletion");
		if (methodInfo.ReturnType != typeof(string) || methodInfo.GetParameters().Length != 2)
		{
			throw new InvalidOperationException("Soul Ripper completion method signature drifted.");
		}
		return (methodInfo.Invoke(null, new object[2] { source, "uga5007" }) as string) ?? throw new InvalidOperationException("Soul Ripper completion returned no source.");
	}

	private static string LoadEmbeddedText(string name)
	{
		using Stream stream = typeof(SoulRipperCacheRuntime).Assembly.GetManifestResourceStream(name) ?? throw new MissingManifestResourceException("Missing Soul Ripper resource " + name);
		using StreamReader streamReader = new StreamReader(stream, new UTF8Encoding(encoderShouldEmitUTF8Identifier: false), detectEncodingFromByteOrderMarks: true);
		return streamReader.ReadToEnd().Replace("\r\n", "\n").Replace('\r', '\n');
	}

	private static string Sha256(string text)
	{
		using SHA256 sHA = SHA256.Create();
		return BitConverter.ToString(sHA.ComputeHash(Encoding.UTF8.GetBytes(text))).Replace("-", "");
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

	private static bool TryFindCachedResource(object cache, out string path, out object value)
	{
		path = null;
		value = null;
		string value2 = "/" + "LJ/lua/common/units/unitsTemplates/uga5007/uga5007.santp".Replace('\\', '/');
		foreach (object item in (IEnumerable)cache)
		{
			Type type = item.GetType();
			if (type.GetProperty("Key")?.GetValue(item, null) is string text && text.Replace('\\', '/').EndsWith(value2, StringComparison.OrdinalIgnoreCase))
			{
				if (path != null)
				{
					throw new InvalidOperationException("Duplicate cached Soul Ripper path.");
				}
				path = text;
				value = type.GetProperty("Value")?.GetValue(item, null) ?? throw new InvalidOperationException("Null cached Soul Ripper resource.");
			}
		}
		return path != null;
	}

	private static string ReadText(object resource)
	{
		object obj = resource.GetType().GetProperty("IsCreated")?.GetValue(resource, null);
		if (!(obj is bool) || !(bool)obj)
		{
			throw new InvalidOperationException("Uninitialized Soul Ripper cache resource.");
		}
		byte[] bytes = ((resource.GetType().GetMethod("ToArray", Type.EmptyTypes) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null) as byte[]) ?? throw new InvalidOperationException("Soul Ripper cache ToArray returned null.");
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
		return (cache.GetType().GetProperty("Item") ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("Soul Ripper cached path vanished: " + path);
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
