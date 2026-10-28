using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace SanctuaryModLoader;

internal sealed class ModRequirements
{
	private readonly Dictionary<string, string> _folders;

	private readonly Func<string, bool> _locallyEnabled;

	internal ModRequirements(string modsRoot, Func<string, bool> locallyEnabled)
	{
		_folders = (Directory.Exists(modsRoot) ? (from path in Directory.GetDirectories(modsRoot)
			where !Path.GetFileName(path).StartsWith(".", StringComparison.Ordinal)
			select path).ToDictionary(Path.GetFileName, StringComparer.OrdinalIgnoreCase) : new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase));
		_locallyEnabled = locallyEnabled;
	}

	internal string[] RequirementsFor(string folderName)
	{
		if (string.IsNullOrWhiteSpace(folderName))
		{
			return new string[0];
		}
		if (!_folders.TryGetValue(folderName, out var value))
		{
			return new string[0];
		}
		string text = Path.Combine(value, "requires.txt");
		if (!File.Exists(text))
		{
			return new string[0];
		}
		List<string> list = new List<string>();
		string[] array = File.ReadAllLines(text);
		for (int i = 0; i < array.Length; i++)
		{
			string text2 = array[i].Trim();
			if (text2.Length != 0 && !text2.StartsWith("#", StringComparison.Ordinal))
			{
				if (text2 == "." || text2 == ".." || text2.IndexOfAny(new char[3] { '/', '\\', ':' }) >= 0)
				{
					throw new InvalidDataException("Invalid folder name in " + text + ": " + text2);
				}
				if (!list.Contains(text2, StringComparer.OrdinalIgnoreCase))
				{
					list.Add(text2);
				}
			}
		}
		return list.ToArray();
	}

	internal bool IsEnabled(string folderName, out string reason)
	{
		return IsEnabled(folderName, new HashSet<string>(StringComparer.OrdinalIgnoreCase), out reason);
	}

	private bool IsEnabled(string folderName, HashSet<string> visiting, out string reason)
	{
		if (!_folders.ContainsKey(folderName))
		{
			reason = folderName + " is missing";
			return false;
		}
		if (!visiting.Add(folderName))
		{
			reason = "dependency cycle at " + folderName;
			return false;
		}
		try
		{
			if (!_locallyEnabled(folderName))
			{
				reason = folderName + " is switched off";
				return false;
			}
			string[] array = RequirementsFor(folderName);
			foreach (string text in array)
			{
				if (!IsEnabled(text, visiting, out var reason2))
				{
					reason = folderName + " requires " + text + ": " + reason2;
					return false;
				}
			}
			reason = null;
			return true;
		}
		catch (Exception ex) when (ex is IOException || ex is InvalidDataException || ex is UnauthorizedAccessException)
		{
			reason = folderName + " has an unreadable requires.txt: " + ex.Message;
			return false;
		}
		finally
		{
			visiting.Remove(folderName);
		}
	}
}
