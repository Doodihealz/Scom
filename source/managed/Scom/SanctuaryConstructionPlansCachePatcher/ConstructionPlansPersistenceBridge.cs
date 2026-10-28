using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;

namespace SanctuaryConstructionPlansCachePatcher;

public static class ConstructionPlansPersistenceBridge
{
	[UnmanagedFunctionPointer(CallingConvention.Cdecl)]
	private delegate int LuaCallback(UIntPtr state);

	internal const string LoadFunctionName = "SCO_LoadConstructionPlansJson";

	internal const string SaveFunctionName = "SCO_SaveConstructionPlansJson";

	internal const int MaximumDocumentBytes = 65536;

	private const int LuaGlobalsIndex = -10002;

	private const int LuaTypeString = 4;

	private const string RelativeDirectory = "My Games\\Enhearten Media\\Sanctuary\\Config\\SupremeCommanderOverhaul";

	private const string FileName = "construction-plans.json";

	private static readonly UTF8Encoding StrictUtf8 = new UTF8Encoding(encoderShouldEmitUTF8Identifier: false, throwOnInvalidBytes: true);

	private static readonly object FileLock = new object();

	private static readonly LuaCallback LoadCallback = Load;

	private static readonly LuaCallback SaveCallback = Save;

	public static void Register(UIntPtr state)
	{
		if (state == UIntPtr.Zero)
		{
			Console.WriteLine("[SCOM Startup Repair 2.1.88.4] Client Lua state is null; Construction Plans persistence registration was not attempted. Check the preceding Lua initialization error.");
			return;
		}
		RegisterGlobal(state, "SCO_LoadConstructionPlansJson", LoadCallback);
		RegisterGlobal(state, "SCO_SaveConstructionPlansJson", SaveCallback);
	}

	private static void RegisterGlobal(UIntPtr state, string name, LuaCallback callback)
	{
		LuaPushCClosure(state, callback, 0);
		LuaSetField(state, -10002, name);
	}

	private static int Load(UIntPtr state)
	{
		try
		{
			string plansPath = GetPlansPath();
			byte[] array;
			lock (FileLock)
			{
				if (!File.Exists(plansPath))
				{
					LuaPushNil(state);
					LuaPushNil(state);
					return 2;
				}
				using FileStream fileStream = new FileStream(plansPath, FileMode.Open, FileAccess.Read, FileShare.Read);
				if (fileStream.Length < 0 || fileStream.Length > 65536)
				{
					throw new InvalidDataException($"The Construction Plans document exceeds {65536} bytes.");
				}
				array = new byte[(int)fileStream.Length];
				int num;
				for (int i = 0; i < array.Length; i += num)
				{
					num = fileStream.Read(array, i, array.Length - i);
					if (num == 0)
					{
						throw new EndOfStreamException("The Construction Plans document changed while it was being read.");
					}
				}
			}
			StrictUtf8.GetString(array);
			PushBytes(state, array);
			LuaPushNil(state);
			return 2;
		}
		catch (Exception arg)
		{
			Log($"Could not load Construction Plans: {arg}");
			LuaPushNil(state);
			PushUtf8(state, "Construction Plans could not read the saved plan file.");
			return 2;
		}
	}

	private static int Save(UIntPtr state)
	{
		try
		{
			if (LuaGetTop(state) != 1 || LuaType(state, 1) != 4)
			{
				return PushSaveResult(state, saved: false, "Construction Plans received an invalid save request.");
			}
			byte[] array = ReadBytes(state, 1);
			if (array.Length > 65536)
			{
				return PushSaveResult(state, saved: false, "The Construction Plans save is too large.");
			}
			StrictUtf8.GetString(array);
			WriteAtomically(array);
			return PushSaveResult(state, saved: true, null);
		}
		catch (Exception arg)
		{
			Log($"Could not save Construction Plans: {arg}");
			return PushSaveResult(state, saved: false, "Construction Plans could not write the saved plan file.");
		}
	}

	private static byte[] ReadBytes(UIntPtr state, int index)
	{
		UIntPtr length;
		IntPtr intPtr = LuaToLString(state, index, out length);
		ulong num = length.ToUInt64();
		if (intPtr == IntPtr.Zero || num > 65536 || num > int.MaxValue)
		{
			throw new InvalidDataException("The Construction Plans save payload is invalid or too large.");
		}
		byte[] array = new byte[(uint)num];
		if (array.Length != 0)
		{
			Marshal.Copy(intPtr, array, 0, array.Length);
		}
		return array;
	}

	private static void WriteAtomically(byte[] bytes)
	{
		string plansPath = GetPlansPath();
		string obj = Path.GetDirectoryName(plansPath) ?? throw new InvalidOperationException("Construction Plans has no storage directory.");
		Directory.CreateDirectory(obj);
		string text = Path.Combine(obj, string.Format(".{0}.{1:N}.tmp", "construction-plans.json", Guid.NewGuid()));
		lock (FileLock)
		{
			try
			{
				using (FileStream fileStream = new FileStream(text, FileMode.CreateNew, FileAccess.Write, FileShare.None, 4096, FileOptions.WriteThrough))
				{
					fileStream.Write(bytes, 0, bytes.Length);
					fileStream.Flush(flushToDisk: true);
				}
				if (File.Exists(plansPath))
				{
					File.Replace(text, plansPath, null, ignoreMetadataErrors: true);
				}
				else
				{
					File.Move(text, plansPath);
				}
			}
			finally
			{
				if (File.Exists(text))
				{
					File.Delete(text);
				}
			}
		}
	}

	private static string GetPlansPath()
	{
		string folderPath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
		if (string.IsNullOrWhiteSpace(folderPath))
		{
			throw new DirectoryNotFoundException("Windows did not provide a Documents folder.");
		}
		return Path.Combine(folderPath, "My Games\\Enhearten Media\\Sanctuary\\Config\\SupremeCommanderOverhaul", "construction-plans.json");
	}

	private static int PushSaveResult(UIntPtr state, bool saved, string? error)
	{
		LuaPushBoolean(state, saved ? 1 : 0);
		if (error == null)
		{
			LuaPushNil(state);
		}
		else
		{
			PushUtf8(state, error);
		}
		return 2;
	}

	private static void PushUtf8(UIntPtr state, string text)
	{
		PushBytes(state, StrictUtf8.GetBytes(text));
	}

	private static void PushBytes(UIntPtr state, byte[] bytes)
	{
		IntPtr intPtr = Marshal.AllocHGlobal(Math.Max(1, bytes.Length));
		try
		{
			if (bytes.Length != 0)
			{
				Marshal.Copy(bytes, 0, intPtr, bytes.Length);
			}
			LuaPushLString(state, intPtr, new UIntPtr((uint)bytes.Length));
		}
		finally
		{
			Marshal.FreeHGlobal(intPtr);
		}
	}

	private static void Log(string message)
	{
		string text = "[Supreme Commander Overhaul / Construction Plans] " + message;
		Console.WriteLine(text);
		try
		{
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => (object)type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}

	[DllImport("lua51", CallingConvention = CallingConvention.Cdecl, EntryPoint = "lua_gettop")]
	private static extern int LuaGetTop(UIntPtr state);

	[DllImport("lua51", CallingConvention = CallingConvention.Cdecl, EntryPoint = "lua_type")]
	private static extern int LuaType(UIntPtr state, int index);

	[DllImport("lua51", CallingConvention = CallingConvention.Cdecl, EntryPoint = "lua_tolstring")]
	private static extern IntPtr LuaToLString(UIntPtr state, int index, out UIntPtr length);

	[DllImport("lua51", CallingConvention = CallingConvention.Cdecl, EntryPoint = "lua_pushnil")]
	private static extern void LuaPushNil(UIntPtr state);

	[DllImport("lua51", CallingConvention = CallingConvention.Cdecl, EntryPoint = "lua_pushboolean")]
	private static extern void LuaPushBoolean(UIntPtr state, int value);

	[DllImport("lua51", CallingConvention = CallingConvention.Cdecl, EntryPoint = "lua_pushlstring")]
	private static extern void LuaPushLString(UIntPtr state, IntPtr text, UIntPtr length);

	[DllImport("lua51", CallingConvention = CallingConvention.Cdecl, EntryPoint = "lua_pushcclosure")]
	private static extern void LuaPushCClosure(UIntPtr state, LuaCallback callback, int upvalueCount);

	[DllImport("lua51", CallingConvention = CallingConvention.Cdecl, EntryPoint = "lua_setfield")]
	private static extern void LuaSetField(UIntPtr state, int index, string name);
}
