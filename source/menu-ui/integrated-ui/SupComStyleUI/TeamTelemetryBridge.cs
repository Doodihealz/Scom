using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Reflection;
using EM.Lua.Client;

namespace SupComStyleUI;

internal sealed class TeamTelemetryBridge : IDisposable
{
	private const string BridgeGlobal = "__SupComStyleUITeamTelemetry";

	private const string ResourceSuffix = ".TeamTelemetry.lua";

	private const string ChunkName = "@SupComStyleUI/TeamTelemetry.lua";

	private const int BridgeVersion = 2;

	private const int LuaGlobalsIndex = -10002;

	private const int LuaTypeString = 4;

	private const int MaximumScriptBytes = 131072;

	private const int MaximumPayloadBytes = 65536;

	private const int MaximumRows = 64;

	private const int MaximumTeamKeyLength = 64;

	private const int MaximumTeamNameLength = 120;

	private const double MaximumStrength = 1000000000000.0;

	private const long MaximumCumulativeFires = 9007199254740991L;

	private lua_State loadedState;

	private byte[] scriptBytes;

	private bool disposed;

	public bool EnsureLoaded(out string error)
	{
		error = string.Empty;
		if (disposed)
		{
			error = "The team telemetry bridge has been disposed.";
			return false;
		}
		if (!TryGetCurrentState(out var luaState, out error))
		{
			loadedState = default(lua_State);
			return false;
		}
		if (loadedState.IsNotNull && loadedState != luaState)
		{
			loadedState = default(lua_State);
		}
		if (loadedState == luaState && HasBridgeContract(luaState))
		{
			return true;
		}
		if (!TryGetScriptBytes(out var source, out error))
		{
			return false;
		}
		if (!ExecuteChunk(luaState, source, out error))
		{
			return false;
		}
		if (!HasBridgeContract(luaState))
		{
			error = "The embedded team telemetry script did not publish its expected API.";
			return false;
		}
		loadedState = luaState;
		return true;
	}

	public bool Sample(out IReadOnlyList<TeamTelemetrySample> teams, out string error)
	{
		teams = Array.Empty<TeamTelemetrySample>();
		if (!EnsureLoaded(out error))
		{
			return false;
		}
		if (!InvokeString(loadedState, "SampleTsv", out var result, out error))
		{
			return false;
		}
		return TryParsePayload(result, out teams, out error);
	}

	public bool Reset(out string error)
	{
		if (!EnsureLoaded(out error))
		{
			return false;
		}
		return InvokeNoResult(loadedState, "Reset", out error);
	}

	public void Cleanup()
	{
		if (loadedState.IsNull)
		{
			return;
		}
		try
		{
			if (TryGetCurrentState(out var luaState, out var error) && luaState == loadedState)
			{
				InvokeNoResult(luaState, "Cleanup", out error);
			}
		}
		finally
		{
			loadedState = default(lua_State);
		}
	}

	public void Dispose()
	{
		if (!disposed)
		{
			Cleanup();
			disposed = true;
		}
	}

	private static bool TryGetCurrentState(out lua_State luaState, out string error)
	{
		luaState = default(lua_State);
		error = string.Empty;
		try
		{
			luaState = ClientLuaInterface.Data.luaState;
		}
		catch (Exception ex)
		{
			error = "The client Lua state is unavailable: " + SanitizeError(ex.Message);
			return false;
		}
		if (luaState.IsNull)
		{
			error = "The client Lua state is not initialized.";
			return false;
		}
		return true;
	}

	private bool TryGetScriptBytes(out byte[] source, out string error)
	{
		if (scriptBytes != null)
		{
			source = scriptBytes;
			error = string.Empty;
			return true;
		}
		source = null;
		error = string.Empty;
		Assembly assembly = typeof(TeamTelemetryBridge).Assembly;
		string text = null;
		string[] manifestResourceNames = assembly.GetManifestResourceNames();
		foreach (string text2 in manifestResourceNames)
		{
			if (text2.EndsWith(".TeamTelemetry.lua", StringComparison.OrdinalIgnoreCase))
			{
				if (text != null)
				{
					error = "More than one embedded TeamTelemetry.lua resource was found.";
					return false;
				}
				text = text2;
			}
		}
		if (text == null)
		{
			error = "The embedded TeamTelemetry.lua resource is missing.";
			return false;
		}
		try
		{
			using Stream stream = assembly.GetManifestResourceStream(text);
			if (stream == null)
			{
				error = "The embedded TeamTelemetry.lua resource could not be opened.";
				return false;
			}
			using MemoryStream memoryStream = new MemoryStream();
			byte[] array = new byte[4096];
			int num = 0;
			int num2;
			while ((num2 = stream.Read(array, 0, array.Length)) > 0)
			{
				num += num2;
				if (num > 131072)
				{
					error = "The embedded TeamTelemetry.lua resource is too large.";
					return false;
				}
				memoryStream.Write(array, 0, num2);
			}
			source = memoryStream.ToArray();
		}
		catch (Exception ex)
		{
			error = "The embedded TeamTelemetry.lua resource could not be read: " + SanitizeError(ex.Message);
			return false;
		}
		if (source.Length == 0)
		{
			error = "The embedded TeamTelemetry.lua resource is empty.";
			return false;
		}
		for (int j = 0; j < source.Length; j++)
		{
			if (source[j] > 127)
			{
				error = "The embedded TeamTelemetry.lua resource must contain ASCII only.";
				return false;
			}
		}
		scriptBytes = source;
		return true;
	}

	private static bool ExecuteChunk(lua_State luaState, byte[] source, out string error)
	{
		error = string.Empty;
		int idx = LuaJIT.lua_gettop(luaState);
		try
		{
			if (LuaJIT.lua_checkstack(luaState, 32) == 0)
			{
				error = "The client Lua stack cannot reserve team telemetry workspace.";
				return false;
			}
			if (LuaJIT.luaL_loadbuffer(luaState, source, (ulong)source.Length, "@SupComStyleUI/TeamTelemetry.lua") != 0)
			{
				error = "The team telemetry script could not be loaded: " + ReadLuaError(luaState);
				return false;
			}
			if (LuaJIT.lua_pcall(luaState, 0, 1, 0) != 0)
			{
				error = "The team telemetry script could not be initialized: " + ReadLuaError(luaState);
				return false;
			}
			if (LuaJIT.lua_istable(luaState, -1) == 0)
			{
				error = "The team telemetry script returned an invalid bridge object.";
				return false;
			}
			return true;
		}
		catch (Exception ex)
		{
			error = "The team telemetry script failed: " + SanitizeError(ex.Message);
			return false;
		}
		finally
		{
			LuaJIT.lua_settop(luaState, idx);
		}
	}

	private static bool HasBridgeContract(lua_State luaState)
	{
		int idx = LuaJIT.lua_gettop(luaState);
		try
		{
			if (LuaJIT.lua_checkstack(luaState, 16) == 0)
			{
				return false;
			}
			PushRawField(luaState, -10002, "__SupComStyleUITeamTelemetry");
			if (LuaJIT.lua_istable(luaState, -1) == 0)
			{
				return false;
			}
			int num = AbsoluteIndex(luaState, -1);
			PushRawField(luaState, num, "version");
			bool num2 = LuaJIT.lua_isnumber(luaState, -1) != 0 && LuaJIT.lua_tonumber(luaState, -1) == 2.0;
			LuaJIT.lua_pop(luaState, 1);
			if (!num2)
			{
				return false;
			}
			return HasFunction(luaState, num, "EnsureWrapped") && HasFunction(luaState, num, "SampleTsv") && HasFunction(luaState, num, "Reset") && HasFunction(luaState, num, "Cleanup");
		}
		catch
		{
			return false;
		}
		finally
		{
			LuaJIT.lua_settop(luaState, idx);
		}
	}

	private static bool HasFunction(lua_State luaState, int tableIndex, string field)
	{
		PushRawField(luaState, tableIndex, field);
		bool result = LuaJIT.lua_isfunction(luaState, -1) != 0;
		LuaJIT.lua_pop(luaState, 1);
		return result;
	}

	private static bool InvokeString(lua_State luaState, string functionName, out string result, out string error)
	{
		result = string.Empty;
		error = string.Empty;
		int idx = LuaJIT.lua_gettop(luaState);
		try
		{
			if (LuaJIT.lua_checkstack(luaState, 16) == 0)
			{
				error = "The client Lua stack cannot reserve team telemetry workspace.";
				return false;
			}
			if (!PushBridgeFunction(luaState, functionName, out error))
			{
				return false;
			}
			if (LuaJIT.lua_pcall(luaState, 0, 1, 0) != 0)
			{
				error = "The team telemetry sample failed: " + ReadLuaError(luaState);
				return false;
			}
			if (LuaJIT.lua_type(luaState, -1) != 4)
			{
				error = "The team telemetry sample was not a TSV string.";
				return false;
			}
			if (LuaJIT.lua_objlen(luaState, -1) > 65536)
			{
				error = "The team telemetry sample exceeded its size limit.";
				return false;
			}
			result = LuaJIT.lua_tostring(luaState, -1) ?? string.Empty;
			return true;
		}
		catch (Exception ex)
		{
			error = "The team telemetry sample failed: " + SanitizeError(ex.Message);
			return false;
		}
		finally
		{
			LuaJIT.lua_settop(luaState, idx);
		}
	}

	private static bool InvokeNoResult(lua_State luaState, string functionName, out string error)
	{
		error = string.Empty;
		int idx = LuaJIT.lua_gettop(luaState);
		try
		{
			if (LuaJIT.lua_checkstack(luaState, 16) == 0)
			{
				error = "The client Lua stack cannot reserve team telemetry workspace.";
				return false;
			}
			if (!PushBridgeFunction(luaState, functionName, out error))
			{
				return false;
			}
			if (LuaJIT.lua_pcall(luaState, 0, 0, 0) != 0)
			{
				error = "The team telemetry " + functionName + " call failed: " + ReadLuaError(luaState);
				return false;
			}
			return true;
		}
		catch (Exception ex)
		{
			error = "The team telemetry " + functionName + " call failed: " + SanitizeError(ex.Message);
			return false;
		}
		finally
		{
			LuaJIT.lua_settop(luaState, idx);
		}
	}

	private static bool PushBridgeFunction(lua_State luaState, string functionName, out string error)
	{
		error = string.Empty;
		PushRawField(luaState, -10002, "__SupComStyleUITeamTelemetry");
		if (LuaJIT.lua_istable(luaState, -1) == 0)
		{
			error = "The team telemetry bridge is unavailable.";
			return false;
		}
		int parentIndex = AbsoluteIndex(luaState, -1);
		PushRawField(luaState, parentIndex, functionName);
		if (LuaJIT.lua_isfunction(luaState, -1) == 0)
		{
			error = "The team telemetry bridge is missing " + functionName + ".";
			return false;
		}
		return true;
	}

	private static bool TryParsePayload(string payload, out IReadOnlyList<TeamTelemetrySample> teams, out string error)
	{
		teams = Array.Empty<TeamTelemetrySample>();
		error = string.Empty;
		if (payload == null || payload.Length > 65536 || payload.IndexOf('\0') >= 0)
		{
			error = "The team telemetry TSV payload is invalid or oversized.";
			return false;
		}
		if (payload.Length == 0)
		{
			return true;
		}
		string[] array = payload.Split(new char[1] { '\n' }, StringSplitOptions.None);
		if (array.Length > 64)
		{
			error = "The team telemetry TSV payload contains too many teams.";
			return false;
		}
		List<TeamTelemetrySample> list = new List<TeamTelemetrySample>(array.Length);
		HashSet<string> hashSet = new HashSet<string>(StringComparer.Ordinal);
		for (int i = 0; i < array.Length; i++)
		{
			string[] array2 = array[i].Split(new char[1] { '\t' }, StringSplitOptions.None);
			if (array2.Length != 4)
			{
				error = "Team telemetry TSV row " + (i + 1).ToString(CultureInfo.InvariantCulture) + " does not have four fields.";
				return false;
			}
			string text = array2[0];
			string text2 = array2[1];
			if (!IsSafeTeamKey(text) || !IsSafeTeamName(text2) || !hashSet.Add(text))
			{
				error = "Team telemetry TSV row " + (i + 1).ToString(CultureInfo.InvariantCulture) + " has an invalid or duplicate team identity.";
				return false;
			}
			if (!double.TryParse(array2[2], NumberStyles.Float, CultureInfo.InvariantCulture, out var result) || !IsFinite(result) || result < 0.0 || result > 1000000000000.0)
			{
				error = "Team telemetry TSV row " + (i + 1).ToString(CultureInfo.InvariantCulture) + " has an invalid strength.";
				return false;
			}
			if (!long.TryParse(array2[3], NumberStyles.None, CultureInfo.InvariantCulture, out var result2) || result2 < 0 || result2 > 9007199254740991L)
			{
				error = "Team telemetry TSV row " + (i + 1).ToString(CultureInfo.InvariantCulture) + " has an invalid fire count.";
				return false;
			}
			list.Add(new TeamTelemetrySample(text, text2, result, result2));
		}
		teams = list.AsReadOnly();
		return true;
	}

	private static bool IsSafeTeamKey(string value)
	{
		if (string.IsNullOrEmpty(value) || value.Length > 64)
		{
			return false;
		}
		foreach (char c in value)
		{
			bool num = (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z');
			bool flag = c >= '0' && c <= '9';
			if (!num && !flag && c != ':' && c != '.' && c != '_' && c != '-')
			{
				return false;
			}
		}
		return true;
	}

	private static bool IsSafeTeamName(string value)
	{
		if (string.IsNullOrWhiteSpace(value) || value.Length > 120)
		{
			return false;
		}
		for (int i = 0; i < value.Length; i++)
		{
			if (char.IsControl(value[i]))
			{
				return false;
			}
		}
		return value == value.Trim();
	}

	private static bool IsFinite(double value)
	{
		if (!double.IsNaN(value))
		{
			return !double.IsInfinity(value);
		}
		return false;
	}

	private static string ReadLuaError(lua_State luaState)
	{
		return SanitizeError(LuaJIT.lua_tostring(luaState, -1) ?? "unknown Lua error");
	}

	private static string SanitizeError(string value)
	{
		if (string.IsNullOrEmpty(value))
		{
			return "unknown error";
		}
		char[] array = value.ToCharArray();
		for (int i = 0; i < array.Length; i++)
		{
			if (char.IsControl(array[i]))
			{
				array[i] = ' ';
			}
		}
		string text = new string(array).Trim();
		if (text.Length > 512)
		{
			text = text.Substring(0, 512);
		}
		if (text.Length != 0)
		{
			return text;
		}
		return "unknown error";
	}

	private static void PushRawField(lua_State luaState, int parentIndex, string field)
	{
		LuaJIT.lua_pushstring(luaState, field);
		LuaJIT.lua_rawget(luaState, parentIndex);
	}

	private static int AbsoluteIndex(lua_State luaState, int index)
	{
		if (index > 0 || index <= -10000)
		{
			return index;
		}
		return LuaJIT.lua_gettop(luaState) + index + 1;
	}
}
