using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using BepInEx;
using EM.Gamedata;
using HarmonyLib;
using Mono.Cecil;
using UnityEngine;

namespace SanctuaryModLoader;

[BepInPlugin("com.sanctuarydb.modloader", "Sanctuary Mod Loader", "1.4.0")]
public class LoaderPlugin : BaseUnityPlugin
{
	private sealed class Managed
	{
		public Type Type;

		public string Guid;

		public string Name;

		public BaseUnityPlugin Instance;
	}

	private sealed class PackFolder
	{
		public string Name;

		public string Path;

		public string[] PatcherPaths;

		public bool HasPacks;

		public bool HasInvalidPackFiles;
	}

	private const string LoaderGuid = "com.sanctuarydb.modloader";

	private static LoaderPlugin _instance;

	private string _modsDir;

	private PackFolder[] _packFolders = new PackFolder[0];

	private string[] _activePackFolders = new string[0];

	private readonly Dictionary<string, string> _disabledFolders = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

	private Harmony _harmony;

	private bool _reportedPackPaths;

	private readonly Dictionary<string, DateTime> _loadedStamps = new Dictionary<string, DateTime>(StringComparer.OrdinalIgnoreCase);

	private readonly Dictionary<string, DateTime> _patcherStamps = new Dictionary<string, DateTime>(StringComparer.OrdinalIgnoreCase);

	private readonly Dictionary<string, DateTime> _blockedStamps = new Dictionary<string, DateTime>(StringComparer.OrdinalIgnoreCase);

	private readonly Dictionary<string, List<Managed>> _live = new Dictionary<string, List<Managed>>(StringComparer.OrdinalIgnoreCase);

	private readonly Dictionary<string, int> _loadCounts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

	private float _pollAccum;

	private void Awake()
	{
		_instance = this;
		_modsDir = Path.Combine(Paths.GameRootPath, "SanctuaryMods");
		_packFolders = DiscoverPackFolders();
		SelectModFolders();
		_harmony = new Harmony("com.sanctuarydb.modloader");
		_harmony.Patch(AccessTools.PropertyGetter(typeof(Data), "LoadGamedataPaths"), null, new HarmonyMethod(typeof(LoaderPlugin).GetMethod("AppendManagedPackPaths", BindingFlags.Static | BindingFlags.NonPublic)));
		base.Logger.LogInfo("Mods loader ready; watching " + _modsDir + " for mod DLLs (auto-reload on change, F6 forces).");
		LoadChanged(force: true);
	}

	private void OnDestroy()
	{
		if ((object)_instance == this)
		{
			_instance = null;
		}
		_harmony?.UnpatchSelf();
	}

	private void Update()
	{
		if (Input.GetKeyDown(KeyCode.F6))
		{
			LoadChanged(force: true);
			return;
		}
		_pollAccum += Time.unscaledDeltaTime;
		if (!(_pollAccum < 1f))
		{
			_pollAccum = 0f;
			LoadChanged(force: false);
		}
	}

	private void LoadChanged(bool force)
	{
		if (!Directory.Exists(_modsDir))
		{
			return;
		}
		string[] files = Directory.GetFiles(_modsDir, "*.dll", SearchOption.AllDirectories);
		foreach (string item in _loadedStamps.Keys.Except(files, StringComparer.OrdinalIgnoreCase).ToList())
		{
			TearDown(item);
			_loadedStamps.Remove(item);
			base.Logger.LogInfo(Path.GetFileName(item) + " removed; its plugin(s) destroyed.");
		}
		foreach (string item2 in _patcherStamps.Keys.Except(files, StringComparer.OrdinalIgnoreCase).ToList())
		{
			_patcherStamps.Remove(item2);
		}
		foreach (string item3 in _blockedStamps.Keys.Except(files, StringComparer.OrdinalIgnoreCase).ToList())
		{
			_blockedStamps.Remove(item3);
		}
		List<string> list = new List<string>();
		string[] array = files;
		foreach (string text in array)
		{
			DateTime lastWriteTimeUtc = File.GetLastWriteTimeUtc(text);
			if ((!force && _loadedStamps.TryGetValue(text, out var value) && value == lastWriteTimeUtc) || (!force && _patcherStamps.TryGetValue(text, out var value2) && value2 == lastWriteTimeUtc) || (!force && _blockedStamps.TryGetValue(text, out var value3) && value3 == lastWriteTimeUtc))
			{
				continue;
			}
			if (PatcherDiscovery.FindPatcherTypes(text).Length != 0)
			{
				TearDown(text);
				_loadedStamps.Remove(text);
				_patcherStamps[text] = lastWriteTimeUtc;
				base.Logger.LogInfo(Path.GetFileName(text) + " is a preloader patcher; runtime loading skipped.");
				continue;
			}
			_patcherStamps.Remove(text);
			string folderName = text.Substring(_modsDir.Length).TrimStart(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar).Split(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)[0];
			if (_disabledFolders.TryGetValue(folderName, out var value4) || (!_packFolders.Any((PackFolder folder) => folder.Name.Equals(folderName, StringComparison.OrdinalIgnoreCase)) && (File.Exists(Path.Combine(_modsDir, folderName, "requires.txt")) || Directory.Exists(Path.Combine(_modsDir, folderName, "packs")))))
			{
				TearDown(text);
				_loadedStamps.Remove(text);
				_blockedStamps[text] = lastWriteTimeUtc;
				base.Logger.LogInfo(Path.GetFileName(text) + " held back until restart: " + (value4 ?? "new managed mod folder") + ".");
			}
			else
			{
				_blockedStamps.Remove(text);
				if (TryLoadAssembly(text, lastWriteTimeUtc))
				{
					list.Add(text);
				}
			}
		}
		if (list.Count == 0)
		{
			return;
		}
		HashSet<string> hashSet = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
		foreach (string item4 in list)
		{
			int num = 0;
			List<string> list2 = new List<string>();
			foreach (Managed item5 in _live[item4])
			{
				if (hashSet.Contains(item5.Guid))
				{
					list2.Add(item5.Name);
				}
				else if (StartPlugin(item5))
				{
					num++;
				}
			}
			int num2 = _loadCounts[item4];
			base.Logger.LogInfo($"Hot-loaded {num} plugin(s) from {Path.GetFileName(item4)} (built {_loadedStamps[item4]:HH:mm:ss} UTC)" + ((list2.Count > 0) ? ("; held back " + string.Join(", ", list2) + ", switched off on the Mods page") : "") + ((num2 > 1) ? $". Copy {num2} of this assembly this session: earlier copies can't be unloaded and stay in memory until the game exits." : "."));
		}
	}

	private void TearDown(string path)
	{
		if (!_live.TryGetValue(path, out var value))
		{
			return;
		}
		foreach (Managed item in value)
		{
			if (item.Instance != null)
			{
				UnityEngine.Object.Destroy(item.Instance);
			}
			item.Instance = null;
		}
		_live.Remove(path);
	}

	private bool TryLoadAssembly(string path, DateTime stamp)
	{
		byte[] array;
		try
		{
			array = File.ReadAllBytes(path);
		}
		catch (IOException)
		{
			return false;
		}
		TearDown(path);
		_loadedStamps[path] = stamp;
		try
		{
			using (MemoryStream memoryStream = new MemoryStream())
			{
				using (MemoryStream stream = new MemoryStream(array, writable: false))
				{
					using AssemblyDefinition assemblyDefinition = AssemblyDefinition.ReadAssembly(stream);
					assemblyDefinition.Name.Name = $"{assemblyDefinition.Name.Name}-{DateTime.UtcNow.Ticks}";
					assemblyDefinition.Write(memoryStream);
				}
				array = memoryStream.ToArray();
			}
			Assembly assembly = Assembly.Load(array);
			_loadCounts[path] = ((!_loadCounts.TryGetValue(path, out var value)) ? 1 : (value + 1));
			List<Managed> list = new List<Managed>();
			foreach (Type item in from t in GetTypesSafe(assembly)
				where typeof(BaseUnityPlugin).IsAssignableFrom(t) && !t.IsAbstract
				select t)
			{
				BepInPlugin bepInPlugin = null;
				try
				{
					bepInPlugin = item.GetCustomAttributes(typeof(BepInPlugin), inherit: false).OfType<BepInPlugin>().FirstOrDefault();
				}
				catch (Exception ex2)
				{
					base.Logger.LogWarning(item.FullName + ": unreadable [BepInPlugin] (" + ex2.Message + ").");
				}
				list.Add(new Managed
				{
					Type = item,
					Guid = (bepInPlugin?.GUID ?? item.FullName),
					Name = (bepInPlugin?.Name ?? item.Name)
				});
			}
			_live[path] = list;
			return true;
		}
		catch (Exception arg)
		{
			base.Logger.LogError($"Hot reload of {Path.GetFileName(path)} failed: {arg}");
			return false;
		}
	}

	private bool StartPlugin(Managed plugin)
	{
		if (plugin.Instance != null)
		{
			return true;
		}
		try
		{
			plugin.Instance = (BaseUnityPlugin)base.gameObject.AddComponent(plugin.Type);
		}
		catch (Exception arg)
		{
			base.Logger.LogError($"Starting {plugin.Name} failed: {arg}");
			plugin.Instance = null;
		}
		return plugin.Instance != null;
	}

	private static IEnumerable<Type> GetTypesSafe(Assembly assembly)
	{
		try
		{
			return assembly.GetTypes();
		}
		catch (ReflectionTypeLoadException ex)
		{
			return ex.Types.Where((Type t) => t != null);
		}
	}

	private PackFolder[] DiscoverPackFolders()
	{
		if (!Directory.Exists(_modsDir))
		{
			return new PackFolder[0];
		}
		List<PackFolder> list = new List<PackFolder>();
		foreach (string item in (from path2 in Directory.GetDirectories(_modsDir)
			where !Path.GetFileName(path2).StartsWith(".", StringComparison.Ordinal)
			select path2).OrderBy((string path2) => Path.GetFileName(path2), StringComparer.OrdinalIgnoreCase).ThenBy((string path2) => Path.GetFileName(path2), StringComparer.Ordinal))
		{
			string path = Path.Combine(item, "packs");
			string[] array = (Directory.Exists(path) ? Directory.GetFiles(path, "*", SearchOption.AllDirectories) : new string[0]);
			string text = array.FirstOrDefault((string text2) => !text2.EndsWith(".sanpack", StringComparison.Ordinal));
			if (text != null)
			{
				base.Logger.LogWarning("Pack folder " + Path.GetFileName(item) + " contains a non-.sanpack file (" + Path.GetFileName(text) + "); skipping it.");
			}
			list.Add(new PackFolder
			{
				Name = Path.GetFileName(item),
				Path = path,
				HasPacks = (array.Length != 0 && text == null),
				HasInvalidPackFiles = (text != null),
				PatcherPaths = (from text2 in Directory.GetFiles(item, "*.dll", SearchOption.AllDirectories)
					where PatcherDiscovery.FindPatcherTypes(text2).Length != 0
					select text2.Substring(_modsDir.Length).TrimStart(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar).Replace('\\', '/')).ToArray()
			});
		}
		return list.ToArray();
	}

	private void SelectModFolders()
	{
		HashSet<string> disabledPatchers = ReadDisabled("Patchers", normalizePaths: true);
		HashSet<string> disabledPacks = ReadDisabled("Packs", normalizePaths: false);
		Dictionary<string, PackFolder> byName = _packFolders.ToDictionary((PackFolder folder) => folder.Name, StringComparer.OrdinalIgnoreCase);
		ModRequirements modRequirements = new ModRequirements(_modsDir, delegate(string name)
		{
			if (!byName.TryGetValue(name, out var value) || value.HasInvalidPackFiles)
			{
				return false;
			}
			if (value.PatcherPaths.Length != 0)
			{
				return value.PatcherPaths.Any((string path) => !disabledPatchers.Contains(path));
			}
			return !value.HasPacks || !disabledPacks.Contains(name);
		});
		PackFolder[] packFolders = _packFolders;
		foreach (PackFolder packFolder in packFolders)
		{
			if (!modRequirements.IsEnabled(packFolder.Name, out var reason))
			{
				_disabledFolders[packFolder.Name] = reason;
			}
		}
	}

	private static void AppendManagedPackPaths(ref string[] __result)
	{
		LoaderPlugin instance = _instance;
		if (instance == null || !Data.AllowMods || __result == null)
		{
			return;
		}
		string[] array = __result;
		List<string> managed = new List<string>();
		foreach (PackFolder item in instance._packFolders.Where((PackFolder folder) => folder.HasPacks))
		{
			if (instance._disabledFolders.TryGetValue(item.Name, out var value))
			{
				if (!instance._reportedPackPaths)
				{
					instance.Logger.LogInfo("Skipping managed pack folder " + item.Name + ": " + value + ".");
				}
			}
			else if (Directory.Exists(item.Path) && !array.Contains(item.Path, StringComparer.OrdinalIgnoreCase))
			{
				managed.Add(item.Path);
			}
		}
		instance._activePackFolders = (from folder in instance._packFolders
			where managed.Contains(folder.Path, StringComparer.OrdinalIgnoreCase)
			select folder.Name).ToArray();
		__result = array.Concat(managed).ToArray();
		if (!instance._reportedPackPaths)
		{
			instance._reportedPackPaths = true;
			instance.Logger.LogInfo("Managed pack roots: " + ((managed.Count == 0) ? "none" : string.Join(", ", managed)) + ".");
		}
	}

	private HashSet<string> ReadDisabled(string sectionName, bool normalizePaths)
	{
		return new HashSet<string>(StringComparer.OrdinalIgnoreCase);
	}

	public static Type[] PluginTypes()
	{
		if (!(_instance == null))
		{
			return (from p in _instance._live.Values.SelectMany((List<Managed> l) => l)
				select p.Type).ToArray();
		}
		return new Type[0];
	}

	public static string[] PackFolders()
	{
		if (!(_instance == null))
		{
			return (from folder in _instance._packFolders
				where folder.HasPacks && folder.PatcherPaths.Length == 0
				select folder.Name).ToArray();
		}
		return new string[0];
	}

	public static string[] ActivePackFolders()
	{
		if (!(_instance == null))
		{
			return _instance._activePackFolders.ToArray();
		}
		return new string[0];
	}

	public static BaseUnityPlugin InstanceOf(Type type)
	{
		Managed managed = ((_instance == null) ? null : _instance.Find(type));
		if (managed == null || !(managed.Instance != null))
		{
			return null;
		}
		return managed.Instance;
	}

	public static BaseUnityPlugin SetPluginEnabled(Type type, bool enabled)
	{
		LoaderPlugin instance = _instance;
		Managed managed = ((instance == null) ? null : instance.Find(type));
		if (managed == null)
		{
			return null;
		}
		if (enabled)
		{
			instance.StartPlugin(managed);
		}
		else if (managed.Instance != null)
		{
			UnityEngine.Object.Destroy(managed.Instance);
			managed.Instance = null;
		}
		if (!(managed.Instance != null))
		{
			return null;
		}
		return managed.Instance;
	}

	private Managed Find(Type type)
	{
		if (!(type == null))
		{
			return _live.Values.SelectMany((List<Managed> l) => l).FirstOrDefault((Managed p) => p.Type == type);
		}
		return null;
	}
}
