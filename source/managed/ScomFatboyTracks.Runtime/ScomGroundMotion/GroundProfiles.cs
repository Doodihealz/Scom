using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Text;

namespace ScomGroundMotion;

public static class GroundProfiles
{
	private sealed class Numeric
	{
		internal string Text;
	}

	private sealed class Table
	{
		internal readonly Dictionary<string, object> Fields = new Dictionary<string, object>(StringComparer.Ordinal);

		internal readonly List<object> Items = new List<object>();
	}

	private sealed class DataParser
	{
		private readonly string source;

		private int position;

		private int tokens;

		internal DataParser(string text)
		{
			if (text == null || text.Length > 524288)
			{
				throw Bad("File exceeds 512 KiB.");
			}
			source = text;
		}

		internal Table Parse()
		{
			Skip();
			if (Identifier() != "return")
			{
				throw Error("Expected return table.");
			}
			Table obj = ParseValue(0) as Table;
			Skip();
			if (obj == null || position != source.Length)
			{
				throw Error("Only one returned data table is allowed.");
			}
			return obj;
		}

		private InvalidDataException Error(string message)
		{
			return Bad(message + " At character " + position + ".");
		}

		private void Skip()
		{
			while (position < source.Length)
			{
				if (char.IsWhiteSpace(source[position]))
				{
					position++;
					continue;
				}
				if (position + 1 < source.Length && source[position] == '-' && source[position + 1] == '-')
				{
					while (position < source.Length && source[position] != '\n')
					{
						position++;
					}
					continue;
				}
				break;
			}
		}

		private string Identifier()
		{
			Skip();
			int num = position;
			while (position < source.Length && (char.IsLetterOrDigit(source[position]) || source[position] == '_'))
			{
				position++;
			}
			return source.Substring(num, position - num);
		}

		private object ParseValue(int depth)
		{
			Skip();
			if (++tokens > 100000 || depth > 12 || position >= source.Length)
			{
				throw Error("Data complexity or syntax limit exceeded.");
			}
			char c = source[position];
			switch (c)
			{
			case '{':
			{
				position++;
				Table table = new Table();
				Skip();
				while (position < source.Length && source[position] != '}')
				{
					if (char.IsLetter(source[position]) || source[position] == '_')
					{
						string text = Identifier();
						Skip();
						if (position >= source.Length || source[position++] != '=')
						{
							throw Error("Expected named data field.");
						}
						if (table.Fields.ContainsKey(text))
						{
							throw Error("Duplicate field " + text);
						}
						table.Fields.Add(text, ParseValue(depth + 1));
					}
					else
					{
						table.Items.Add(ParseValue(depth + 1));
					}
					Skip();
					if (position < source.Length && (source[position] == ',' || source[position] == ';'))
					{
						position++;
						Skip();
					}
					else if (position >= source.Length || source[position] != '}')
					{
						throw Error("Expected comma or closing brace.");
					}
				}
				if (position >= source.Length)
				{
					throw Error("Unclosed table.");
				}
				position++;
				return table;
			}
			case '"':
			case '\'':
			{
				position++;
				StringBuilder stringBuilder = new StringBuilder();
				while (position < source.Length && source[position] != c)
				{
					char c2 = source[position++];
					switch (c2)
					{
					case '\n':
					case '\r':
						throw Error("Newline inside string.");
					case '\\':
						if (position >= source.Length)
						{
							throw Error("Unclosed string escape.");
						}
						c2 = source[position++];
						if (c2 != '\\' && c2 != '"' && c2 != '\'')
						{
							throw Error("Only quote/backslash escapes are supported.");
						}
						break;
					}
					stringBuilder.Append(c2);
					if (stringBuilder.Length > 128)
					{
						throw Error("String exceeds 128 characters.");
					}
				}
				if (position >= source.Length)
				{
					throw Error("Unclosed string.");
				}
				position++;
				return stringBuilder.ToString();
			}
			default:
			{
				int num = position;
				while (position < source.Length && "0123456789+-.eE".IndexOf(source[position]) >= 0)
				{
					position++;
				}
				if (num == position || position - num > 48)
				{
					throw Error("Only literal numbers, strings and tables are supported.");
				}
				return new Numeric
				{
					Text = source.Substring(num, position - num)
				};
			}
			}
		}
	}

	private static Profile[] all;

	internal static Profile[] All
	{
		get
		{
			EnsureLoaded();
			return all;
		}
	}

	public static string LastError { get; private set; }

	public static void Initialize(string modRoot)
	{
		if (all != null)
		{
			return;
		}
		try
		{
			all = LoadFromRoot(modRoot);
		}
		catch (Exception ex)
		{
			all = ForeignGroundProfiles.All;
			LastError = ex.Message;
			Console.Error.WriteLine("[SCOM ground motion] Authored SCOM tracks disabled: " + ex.Message);
		}
	}

	private static void EnsureLoaded()
	{
		if (all != null)
		{
			return;
		}
		Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
		foreach (Assembly assembly in assemblies)
		{
			if (assembly.GetType("ScomFatboyTracks.TrackHooks", throwOnError: false) != null && !string.IsNullOrEmpty(assembly.Location))
			{
				Initialize(Path.GetDirectoryName(assembly.Location));
				return;
			}
		}
		Initialize(null);
	}

	public static bool IsAnimatedMesh(string name)
	{
		if (name == null)
		{
			return false;
		}
		Profile[] array = All;
		for (int i = 0; i < array.Length; i++)
		{
			if (array[i].MeshName == name)
			{
				return true;
			}
		}
		return false;
	}

	internal static Profile[] LoadFromRoot(string root)
	{
		if (string.IsNullOrEmpty(root))
		{
			throw new InvalidDataException("The owning SCOM assembly directory is unavailable.");
		}
		using FileStream fileStream = new FileStream(Path.Combine(Path.GetFullPath(root), "lua", "native", "groundMotion.lua"), FileMode.Open, FileAccess.Read, FileShare.Read);
		if (fileStream.Length > 524288)
		{
			throw new InvalidDataException("groundMotion.lua exceeds 512 KiB.");
		}
		using StreamReader streamReader = new StreamReader(fileStream, new UTF8Encoding(encoderShouldEmitUTF8Identifier: false, throwOnInvalidBytes: true), detectEncodingFromByteOrderMarks: true);
		return Parse(streamReader.ReadToEnd());
	}

	internal static Profile[] Parse(string source)
	{
		Table table = new DataParser(source).Parse();
		Keys(table, "version", "textureProperties", "profiles");
		if (Integer(Value(table, "version"), 1, 1) != 1)
		{
			throw Bad("Unsupported version.");
		}
		List<object> list = Array(Value(table, "textureProperties"), 1, 16);
		string[] array = new string[list.Count];
		HashSet<string> hashSet = new HashSet<string>(StringComparer.Ordinal);
		for (int i = 0; i < list.Count; i++)
		{
			array[i] = Text(list[i]);
			if (!array[i].StartsWith("_", StringComparison.Ordinal) || !hashSet.Add(array[i]))
			{
				throw Bad("Texture properties must be unique shader property names.");
			}
		}
		List<object> list2 = Array(Value(table, "profiles"), 0, 512);
		List<Profile> list3 = new List<Profile>();
		HashSet<string> hashSet2 = new HashSet<string>(StringComparer.Ordinal);
		int num = 0;
		foreach (object item in list2)
		{
			Table table2 = Map(item);
			Keys(table2, "mesh", "vertexCount", "bindPoseCount", "bands", "textureQuality");
			string text = Text(Value(table2, "mesh"));
			if (!IsScomMesh(text) || !hashSet2.Add(text))
			{
				throw Bad("Expected a unique SCOM mesh name: " + text);
			}
			Profile profile = new Profile
			{
				MeshName = text,
				VertexCount = Integer(Value(table2, "vertexCount"), 1, 1000000),
				BindPoseCount = Integer(Value(table2, "bindPoseCount"), 1, 65535),
				TextureProperties = array
			};
			List<object> list4 = Array(Value(table2, "bands"), 1, 64);
			profile.Bands = new Band[list4.Count];
			HashSet<int> hashSet3 = new HashSet<int>();
			for (int j = 0; j < list4.Count; j++)
			{
				Table table3 = Map(list4[j]);
				Keys(table3, "ranges", "axis", "uvPerMetre", "centerX", "period");
				List<object> list5 = Array(Value(table3, "ranges"), 2, 20000);
				if (list5.Count % 2 != 0)
				{
					throw Bad("ranges must contain start/count pairs.");
				}
				List<int> list6 = new List<int>();
				for (int k = 0; k < list5.Count; k += 2)
				{
					int num2 = Integer(list5[k], 0, profile.VertexCount - 1);
					int num3 = Integer(list5[k + 1], 1, profile.VertexCount - num2);
					if (num3 > 1000000 - num)
					{
						throw Bad("Total expanded vertex budget exceeded.");
					}
					num += num3;
					for (int l = num2; l < num2 + num3; l++)
					{
						if (!hashSet3.Add(l))
						{
							throw Bad("Overlapping track vertices: " + text);
						}
						list6.Add(l);
					}
				}
				float num4 = Number(Value(table3, "uvPerMetre"), -10000f, 10000f);
				if (num4 == 0f)
				{
					throw Bad("uvPerMetre must be nonzero.");
				}
				profile.Bands[j] = new Band
				{
					Vertices = list6.ToArray(),
					Axis = Integer(Value(table3, "axis"), 0, 1),
					UVPerMetre = num4,
					CenterX = Number(Value(table3, "centerX"), -100000f, 100000f),
					Period = Number(Value(table3, "period"), 1E-06f, 10000f)
				};
			}
			if (table2.Fields.TryGetValue("textureQuality", out var value))
			{
				List<object> list7 = Array(value, 0, 16);
				profile.TextureQuality = new TextureQuality[list7.Count];
				HashSet<string> hashSet4 = new HashSet<string>(StringComparer.Ordinal);
				for (int m = 0; m < list7.Count; m++)
				{
					Table table4 = Map(list7[m]);
					Keys(table4, "property", "expectedName", "anisoLevel", "filterMode", "mipMapBias");
					string text2 = Text(Value(table4, "property"));
					string text3 = Text(Value(table4, "expectedName"));
					if (!hashSet.Contains(text2) || !hashSet4.Add(text2) || text3.IndexOfAny(new char[3] { '/', '\\', ':' }) >= 0)
					{
						throw Bad("Texture quality must identify one configured texture by basename.");
					}
					profile.TextureQuality[m] = new TextureQuality
					{
						Property = text2,
						ExpectedName = text3,
						AnisoLevel = Integer(Value(table4, "anisoLevel"), 0, 16),
						FilterMode = Integer(Value(table4, "filterMode"), 0, 2),
						MipMapBias = Number(Value(table4, "mipMapBias"), -3f, 3f)
					};
				}
			}
			list3.Add(profile);
		}
		list3.AddRange(ForeignGroundProfiles.All);
		return list3.ToArray();
	}

	private static bool IsScomMesh(string name)
	{
		if (name.Length != 12 || name[0] != 'u' || "ecgs".IndexOf(name[1]) < 0 || name[2] < 'a' || name[2] > 'z' || name.Substring(7) != "_lod0")
		{
			return false;
		}
		for (int i = 3; i < 7; i++)
		{
			if (name[i] < '0' || name[i] > '9')
			{
				return false;
			}
		}
		return true;
	}

	private static InvalidDataException Bad(string message)
	{
		return new InvalidDataException("groundMotion.lua: " + message);
	}

	private static object Value(Table table, string key)
	{
		if (!table.Fields.TryGetValue(key, out var value))
		{
			throw Bad("Missing field " + key);
		}
		return value;
	}

	private static Table Map(object value)
	{
		if (!(value is Table table) || table.Items.Count != 0)
		{
			throw Bad("Expected a named table.");
		}
		return table;
	}

	private static List<object> Array(object value, int minimum, int maximum)
	{
		if (!(value is Table table) || table.Fields.Count != 0 || table.Items.Count < minimum || table.Items.Count > maximum)
		{
			throw Bad("Array length or shape is invalid.");
		}
		return table.Items;
	}

	private static void Keys(Table table, params string[] allowed)
	{
		if (table.Items.Count != 0)
		{
			throw Bad("Expected named fields.");
		}
		HashSet<string> hashSet = new HashSet<string>(allowed, StringComparer.Ordinal);
		foreach (string key in table.Fields.Keys)
		{
			if (!hashSet.Contains(key))
			{
				throw Bad("Unknown field " + key);
			}
		}
	}

	private static string Text(object value)
	{
		string text = value as string;
		if (string.IsNullOrEmpty(text) || text.Length > 128)
		{
			throw Bad("Expected a bounded string.");
		}
		return text;
	}

	private static int Integer(object value, int minimum, int maximum)
	{
		if (!(value is Numeric numeric) || !int.TryParse(numeric.Text, NumberStyles.AllowLeadingSign, CultureInfo.InvariantCulture, out var result) || result < minimum || result > maximum)
		{
			throw Bad("Integer is outside the allowed range.");
		}
		return result;
	}

	private static float Number(object value, float minimum, float maximum)
	{
		if (!(value is Numeric numeric) || !float.TryParse(numeric.Text, NumberStyles.Float, CultureInfo.InvariantCulture, out var result) || float.IsNaN(result) || float.IsInfinity(result) || result < minimum || result > maximum)
		{
			throw Bad("Number is not finite or outside the allowed range.");
		}
		return result;
	}
}
