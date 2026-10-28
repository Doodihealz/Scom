using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;

namespace ScomEditableSources;

public static class SourceRuntime
{
	private sealed class Edit
	{
		internal string Path;

		internal string SourcePath;

		internal string BeforeHash;

		internal string CleanBeforeHash;

		internal byte[] Source;

		internal byte[] Anchor;

		internal int Offset;

		internal int Length;

		internal bool Add;

		internal bool WholeFile;
	}

	private sealed class Pending
	{
		internal string Path;

		internal string InputHash;

		internal string OutputHash;

		internal object Before;

		internal object After;

		internal byte[] Bytes;

		internal bool Existed;
	}

	private const string ManifestName = "lua/source-manifest.tsv";

	private const int MaximumSourceBytes = 33554432;

	private static readonly UTF8Encoding Utf8 = new UTF8Encoding(encoderShouldEmitUTF8Identifier: false, throwOnInvalidBytes: true);

	private static readonly Dictionary<string, string> LastOutputs = new Dictionary<string, string>(StringComparer.Ordinal);

	private static readonly Dictionary<string, string> LastInputs = new Dictionary<string, string>(StringComparer.Ordinal);

	private static object lastCache;

	private static Comparison<Edit> CS_0024_003C_003E9__CachedAnonymousMethodDelegate3;

	public static void Apply()
	{
		string location = typeof(SourceRuntime).Assembly.Location;
		if (string.IsNullOrEmpty(location))
		{
			throw new InvalidOperationException("SCOM editable sources: canonical assembly has no filesystem location.");
		}
		ApplyFromRoot(Path.GetDirectoryName(location));
	}

	public static void ApplyFromRoot(string sourceRoot)
	{
		try
		{
			ApplyChecked(Path.GetFullPath(sourceRoot));
		}
		catch (Exception ex)
		{
			throw new InvalidOperationException("SCOM editable sources failed; Lua startup must stop. " + ex.Message, ex);
		}
	}

	private static void ApplyChecked(string root)
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: true);
		FieldInfo field = type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic);
		IDictionary dictionary = ((field == null) ? null : (field.GetValue(null) as IDictionary));
		if (dictionary == null)
		{
			throw new InvalidOperationException("Native FilesCache dictionary is unavailable.");
		}
		string engineRoot = FindEngineRoot(dictionary);
		MethodInfo method = type.GetMethod("RebuildDirectoryIndex", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic, null, Type.EmptyTypes, null);
		if (method == null)
		{
			throw new InvalidOperationException("Native directory-index rebuild is unavailable.");
		}
		if (!object.ReferenceEquals(lastCache, dictionary))
		{
			LastOutputs.Clear();
			LastInputs.Clear();
			lastCache = dictionary;
		}
		string manifest = ReadText(ScopedPath(root, "lua/source-manifest.tsv"), 1048576);
		Dictionary<string, List<Edit>> dictionary2 = Parse(root, engineRoot, manifest);
		List<Pending> list = new List<Pending>();
		foreach (KeyValuePair<string, List<Edit>> item in dictionary2)
		{
			bool flag = dictionary.Contains(item.Key);
			object obj = (flag ? dictionary[item.Key] : null);
			byte[] array = (flag ? NativeBytes(obj) : null);
			string text = InputIdentity(item.Value);
			if (!flag || !LastOutputs.TryGetValue(item.Key, out var value) || !LastInputs.TryGetValue(item.Key, out var value2) || !(value2 == text) || !(value == Hash(array)))
			{
				byte[] bytes = Compose(item.Key, array, item.Value);
				list.Add(new Pending
				{
					Path = item.Key,
					Existed = flag,
					Before = obj,
					Bytes = bytes,
					InputHash = text,
					OutputHash = Hash(bytes)
				});
			}
		}
		if (list.Count == 0)
		{
			return;
		}
		Type type2 = field.FieldType.GetGenericArguments()[1];
		Type type3 = type2.Assembly.GetType("Unity.Collections.Allocator", throwOnError: false) ?? Type.GetType("Unity.Collections.Allocator, Unity.Collections", throwOnError: true);
		ConstructorInfo constructor = type2.GetConstructor(new Type[2]
		{
			typeof(byte[]),
			type3
		});
		if (constructor == null)
		{
			throw new InvalidOperationException("Native cache allocation signature changed.");
		}
		object obj2 = Enum.Parse(type3, "Persistent");
		try
		{
			foreach (Pending item2 in list)
			{
				item2.After = constructor.Invoke(new object[2] { item2.Bytes, obj2 });
			}
		}
		catch
		{
			foreach (Pending item3 in list)
			{
				Dispose(item3.After);
			}
			throw;
		}
		try
		{
			foreach (Pending item4 in list)
			{
				dictionary[item4.Path] = item4.After;
			}
			method.Invoke(null, null);
		}
		catch
		{
			foreach (Pending item5 in list)
			{
				if (item5.Existed)
				{
					dictionary[item5.Path] = item5.Before;
				}
				else
				{
					dictionary.Remove(item5.Path);
				}
			}
			try
			{
				method.Invoke(null, null);
			}
			finally
			{
				foreach (Pending item6 in list)
				{
					Dispose(item6.After);
				}
			}
			throw;
		}
		foreach (Pending item7 in list)
		{
			if (item7.Existed)
			{
				Dispose(item7.Before);
			}
			LastOutputs[item7.Path] = item7.OutputHash;
			LastInputs[item7.Path] = item7.InputHash;
		}
		Console.WriteLine("[SCOM editable sources] Loaded " + list.Count + " Lua cache entries.");
	}

	private static Dictionary<string, List<Edit>> Parse(string root, string engineRoot, string manifest)
	{
		Dictionary<string, List<Edit>> dictionary = new Dictionary<string, List<Edit>>(StringComparer.Ordinal);
		HashSet<string> hashSet = new HashSet<string>(StringComparer.Ordinal);
		int num = 0;
		bool flag = false;
		bool flag2 = false;
		long num2 = 0L;
		string[] array = manifest.Split(new char[1] { '\n' });
		foreach (string text in array)
		{
			num++;
			string text2 = text.TrimEnd(new char[1] { '\r' });
			if (text2.Length == 0 || text2[0] == '#')
			{
				continue;
			}
			if (!flag)
			{
				if (text2 != "SCOM-LUA-1" && text2 != "SCOM-LUA-2")
				{
					throw new InvalidDataException("Unsupported source manifest header.");
				}
				flag2 = text2 == "SCOM-LUA-2";
				flag = true;
				continue;
			}
			string[] array2 = text2.Split(new char[1] { '\t' });
			bool flag3 = array2[0] == "add";
			bool flag4 = array2[0] == "replace-file";
			if (flag3 || flag4 || !(array2[0] != "replace"))
			{
				bool num3;
				if (!flag3)
				{
					if (!flag4)
					{
						if (array2.Length == 6)
						{
							goto IL_0168;
						}
						num3 = array2.Length != 7;
					}
					else
					{
						if (!flag2)
						{
							goto IL_014d;
						}
						num3 = array2.Length != 5;
					}
				}
				else
				{
					num3 = array2.Length != 3;
				}
				if (!num3)
				{
					goto IL_0168;
				}
			}
			goto IL_014d;
			IL_014d:
			throw new InvalidDataException("Invalid source manifest row " + num + ".");
			IL_0168:
			string text3 = array2[1];
			if (!text3.StartsWith("LJ/lua/", StringComparison.Ordinal) || (!text3.EndsWith(".lua", StringComparison.Ordinal) && !text3.EndsWith(".santp", StringComparison.Ordinal)))
			{
				throw new InvalidDataException("Invalid Lua cache target: " + text3);
			}
			string text4 = ScopedPath(engineRoot, text3);
			string text5 = ScopedPath(root, array2[2]);
			if (!text5.EndsWith(".lua", StringComparison.OrdinalIgnoreCase))
			{
				throw new InvalidDataException("Editable sources must be .lua files: " + array2[2]);
			}
			string s = ReadText(text5, 33554432);
			byte[] bytes = Utf8.GetBytes(s);
			num2 += bytes.Length;
			if (num2 > 100663296)
			{
				throw new InvalidDataException("Editable source set exceeds 96 MiB.");
			}
			Edit edit = new Edit();
			edit.Path = text4;
			edit.SourcePath = array2[2];
			edit.Source = bytes;
			edit.Add = flag3;
			edit.WholeFile = flag4;
			Edit edit2 = edit;
			if (flag4)
			{
				if (!text3.StartsWith("LJ/lua/common/units/unitsTemplates/", StringComparison.Ordinal))
				{
					throw new InvalidDataException("Whole replacements must target unit templates: " + text3);
				}
				string[] array3 = text3.Substring("LJ/lua/common/units/unitsTemplates/".Length).Split(new char[1] { '/' });
				if (array3.Length != 2 || array3[1] != array3[0] + ".santp" || array2[2] != "units/" + array3[0] + "/entry.lua")
				{
					throw new InvalidDataException("Invalid whole-template route: " + text3);
				}
				if (!IsHash(array2[3]) || !IsHash(array2[4]) || string.Equals(array2[3], array2[4], StringComparison.OrdinalIgnoreCase))
				{
					throw new InvalidDataException("Invalid whole-template preimages at row " + num + ".");
				}
				edit2.BeforeHash = array2[3].ToUpperInvariant();
				edit2.CleanBeforeHash = array2[4].ToUpperInvariant();
			}
			else if (!flag3)
			{
				if (!int.TryParse(array2[3], out edit2.Offset) || edit2.Offset < 0 || !int.TryParse(array2[4], out edit2.Length) || edit2.Length <= 0 || !IsHash(array2[5]))
				{
					throw new InvalidDataException("Invalid span identity at row " + num + ".");
				}
				edit2.BeforeHash = array2[5].ToUpperInvariant();
				if (array2.Length == 7 && array2[6].Length != 0)
				{
					edit2.Anchor = Convert.FromBase64String(array2[6]);
					if (edit2.Anchor.Length == 0 || edit2.Anchor.Length > 96 || edit2.Anchor.Length > edit2.Length)
					{
						throw new InvalidDataException("Invalid span anchor at row " + num + ".");
					}
				}
			}
			string item = text4 + "\n" + (flag3 ? "add" : edit2.Offset.ToString());
			if (!hashSet.Add(item))
			{
				throw new InvalidDataException("Duplicate source manifest target span: " + text3);
			}
			if (!dictionary.TryGetValue(text4, out var value))
			{
				value = new List<Edit>();
				dictionary.Add(text4, value);
			}
			if (value.Count != 0 && (flag4 || value[0].WholeFile))
			{
				throw new InvalidDataException("Mixed whole-template rows for " + text3);
			}
			value.Add(edit2);
		}
		if (!flag || dictionary.Count == 0)
		{
			throw new InvalidDataException("Source manifest is empty.");
		}
		return dictionary;
	}

	private static byte[] Compose(string path, byte[] before, List<Edit> edits)
	{
		if (edits[0].Add)
		{
			if (before != null || edits.Count != 1)
			{
				throw new InvalidDataException("New source already exists in cache: " + path);
			}
			return edits[0].Source;
		}
		if (before == null)
		{
			throw new InvalidDataException("Source target is absent from cache: " + path);
		}
		if (edits[0].WholeFile)
		{
			if (edits.Count != 1 || before.Length > 33554432)
			{
				throw new InvalidDataException("Invalid whole-template source for " + path);
			}
			string text = Hash(before);
			Edit edit = edits[0];
			if (text != edit.BeforeHash && text != edit.CleanBeforeHash)
			{
				throw new InvalidDataException("Source preimage changed for " + path + " (" + edit.SourcePath + ").");
			}
			return edit.Source;
		}
		foreach (Edit edit2 in edits)
		{
			if (edit2.Add || edit2.WholeFile)
			{
				throw new InvalidDataException("Mixed source rows for " + path);
			}
			if (Matches(before, edit2.Offset, edit2.Length, edit2.BeforeHash))
			{
				continue;
			}
			int num = -1;
			if (edit2.Anchor != null)
			{
				for (int i = 0; i <= before.Length - edit2.Length; i++)
				{
					if (At(before, i, edit2.Anchor) && Matches(before, i, edit2.Length, edit2.BeforeHash))
					{
						if (num >= 0)
						{
							throw new InvalidDataException("Ambiguous source span for " + path);
						}
						num = i;
					}
				}
			}
			if (num < 0)
			{
				throw new InvalidDataException("Source preimage changed for " + path + " (" + edit2.SourcePath + ").");
			}
			edit2.Offset = num;
		}
		if (CS_0024_003C_003E9__CachedAnonymousMethodDelegate3 == null)
		{
			CS_0024_003C_003E9__CachedAnonymousMethodDelegate3 = (Edit left, Edit right) => left.Offset.CompareTo(right.Offset);
		}
		edits.Sort(CS_0024_003C_003E9__CachedAnonymousMethodDelegate3);
		using MemoryStream memoryStream = new MemoryStream();
		int num2 = 0;
		foreach (Edit edit3 in edits)
		{
			if (edit3.Offset < num2)
			{
				throw new InvalidDataException("Overlapping source spans for " + path);
			}
			memoryStream.Write(before, num2, edit3.Offset - num2);
			memoryStream.Write(edit3.Source, 0, edit3.Source.Length);
			num2 = checked(edit3.Offset + edit3.Length);
		}
		memoryStream.Write(before, num2, before.Length - num2);
		byte[] array = memoryStream.ToArray();
		if (array.Length > 33554432)
		{
			throw new InvalidDataException("Composed Lua source exceeds 32 MiB: " + path);
		}
		Utf8.GetString(array);
		return array;
	}

	private static string FindEngineRoot(IDictionary cache)
	{
		string text = null;
		foreach (object key in cache.Keys)
		{
			if (key is string text2 && text2.Replace('\\', '/').EndsWith("/LJ/lua/common/loading/unitTemplateLoader.lua", StringComparison.Ordinal))
			{
				if (text != null)
				{
					throw new InvalidDataException("Ambiguous native Lua cache root.");
				}
				text = text2.Substring(0, text2.Length - "LJ/lua/common/loading/unitTemplateLoader.lua".Length);
			}
		}
		if (text == null)
		{
			throw new InvalidDataException("Native unit template loader is absent from cache.");
		}
		return Path.GetFullPath(text);
	}

	private static string ScopedPath(string root, string relative)
	{
		if (string.IsNullOrEmpty(relative) || Path.IsPathRooted(relative) || relative.IndexOf('\\') >= 0 || relative.IndexOf(':') >= 0)
		{
			throw new InvalidDataException("Expected a scoped forward-slash relative path: " + relative);
		}
		string[] array = relative.Split(new char[1] { '/' });
		foreach (string text in array)
		{
			if (text.Length == 0 || text == "." || text == "..")
			{
				throw new InvalidDataException("Invalid path component: " + relative);
			}
		}
		string text2 = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
		string fullPath = Path.GetFullPath(Path.Combine(text2, relative.Replace('/', Path.DirectorySeparatorChar)));
		if (!fullPath.StartsWith(text2, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidDataException("Source path escaped the SCOM folder.");
		}
		string text3 = fullPath;
		while (text3.Length >= text2.Length)
		{
			if ((File.Exists(text3) || Directory.Exists(text3)) && (File.GetAttributes(text3) & FileAttributes.ReparsePoint) != 0)
			{
				throw new InvalidDataException("Reparse points are not supported in editable source paths: " + relative);
			}
			text3 = Path.GetDirectoryName(text3);
		}
		return fullPath;
	}

	private static string ReadText(string path, int maximum)
	{
		FileInfo fileInfo = new FileInfo(path);
		if (!fileInfo.Exists)
		{
			throw new FileNotFoundException("Required editable source is missing.", path);
		}
		if (fileInfo.Length > maximum)
		{
			throw new InvalidDataException("Editable source exceeds size limit: " + path);
		}
		byte[] array = File.ReadAllBytes(path);
		if (array.Length > maximum)
		{
			throw new InvalidDataException("Editable source grew beyond size limit: " + path);
		}
		string text = Utf8.GetString(array);
		if (text.IndexOf('\0') >= 0 || (text.Length != 0 && text[0] == '\ufeff'))
		{
			throw new InvalidDataException("Editable source must be UTF-8 without NUL or BOM: " + path);
		}
		return text;
	}

	private static byte[] NativeBytes(object array)
	{
		if (array == null)
		{
			throw new InvalidDataException("Native cache contains a null allocation.");
		}
		return (byte[])array.GetType().GetMethod("ToArray", Type.EmptyTypes).Invoke(array, null);
	}

	private static void Dispose(object array)
	{
		array?.GetType().GetMethod("Dispose", Type.EmptyTypes).Invoke(array, null);
	}

	private static bool At(byte[] bytes, int offset, byte[] anchor)
	{
		for (int i = 0; i < anchor.Length; i++)
		{
			if (bytes[offset + i] != anchor[i])
			{
				return false;
			}
		}
		return true;
	}

	private static bool Matches(byte[] bytes, int offset, int length, string hash)
	{
		if (offset < 0 || length > bytes.Length - offset)
		{
			return false;
		}
		using SHA256 sHA = SHA256.Create();
		return Hex(sHA.ComputeHash(bytes, offset, length)) == hash;
	}

	private static bool IsHash(string text)
	{
		if (text.Length != 64)
		{
			return false;
		}
		foreach (char character in text)
		{
			if (!Uri.IsHexDigit(character))
			{
				return false;
			}
		}
		return true;
	}

	private static string Hash(byte[] bytes)
	{
		using SHA256 sHA = SHA256.Create();
		return Hex(sHA.ComputeHash(bytes));
	}

	private static string Hex(byte[] bytes)
	{
		return BitConverter.ToString(bytes).Replace("-", "");
	}

	private static string InputIdentity(List<Edit> edits)
	{
		using MemoryStream memoryStream = new MemoryStream();
		foreach (Edit edit in edits)
		{
			string text = (edit.Add ? "add" : (edit.WholeFile ? "replace-file" : "replace"));
			byte[] bytes = Utf8.GetBytes(text + "\n" + edit.SourcePath + "\n" + edit.Offset + "\n" + edit.Length + "\n" + edit.BeforeHash + "\n" + edit.CleanBeforeHash + "\n" + Hash(edit.Source) + "\n");
			memoryStream.Write(bytes, 0, bytes.Length);
		}
		return Hash(memoryStream.ToArray());
	}

	private static int _003CCompose_003Eb__2(Edit left, Edit right)
	{
		return left.Offset.CompareTo(right.Offset);
	}
}
