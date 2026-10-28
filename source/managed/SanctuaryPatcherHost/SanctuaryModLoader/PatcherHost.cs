using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using Mono.Cecil;

namespace SanctuaryModLoader;

public static class PatcherHost
{
	private sealed class PatcherAssembly
	{
		public string Path;

		public string RelativePath;

		public string[] TypeNames;
	}

	private sealed class PatcherMethod
	{
		public string RelativePath;

		public string[] Targets;

		public PropertyInfo TargetProperty;

		public MethodInfo Patch;

		public MethodInfo Initializer;

		public MethodInfo Finalizer;
	}

	private static readonly object Gate = new object();

	private static readonly StringComparer PathComparer = StringComparer.OrdinalIgnoreCase;

	private static PatcherAssembly[] _discovered;

	private static PatcherMethod[] _enabled;

	private static bool _initialized;

	private static bool _finished;

	private static string GameRoot
	{
		get
		{
			string baseDirectory = AppDomain.CurrentDomain.BaseDirectory;
			if (File.Exists(Path.Combine(baseDirectory, "Sanctuary.exe")))
			{
				return baseDirectory;
			}
			return Directory.GetParent(Directory.GetParent(Directory.GetParent(typeof(PatcherHost).Assembly.Location).FullName).FullName).FullName;
		}
	}

	private static string ModsRoot => Path.Combine(GameRoot, "SanctuaryMods");

	public static IEnumerable<string> TargetDLLs
	{
		get
		{
			lock (Gate)
			{
				Initialize();
				return _enabled.SelectMany((PatcherMethod patcher) => patcher.Targets).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
			}
		}
	}

	public static string[] PatcherPaths()
	{
		lock (Gate)
		{
			Discover();
			return _discovered.Select((PatcherAssembly patcher) => patcher.RelativePath).ToArray();
		}
	}

	public static string[] ActivePatcherPaths()
	{
		lock (Gate)
		{
			LoadEnabled();
			return _enabled.Select((PatcherMethod patcher) => patcher.RelativePath).Distinct(PathComparer).ToArray();
		}
	}

	public static string[] RequirementsFor(string folderName)
	{
		lock (Gate)
		{
			return new ModRequirements(ModsRoot, (string _) => true).RequirementsFor(folderName);
		}
	}

	public static void Initialize()
	{
		lock (Gate)
		{
			LoadEnabled();
			if (_initialized)
			{
				return;
			}
			PatcherMethod[] enabled = _enabled;
			foreach (PatcherMethod patcherMethod in enabled)
			{
				try
				{
					patcherMethod.Initializer?.Invoke(null, null);
					patcherMethod.Targets = ((IEnumerable<string>)patcherMethod.TargetProperty.GetValue(null, null)).ToArray();
					if (patcherMethod.Targets.Any(string.IsNullOrWhiteSpace))
					{
						throw new InvalidOperationException("Patcher has an empty target DLL name.");
					}
				}
				catch (TargetInvocationException ex)
				{
					throw new InvalidOperationException("Initializing patcher " + patcherMethod.RelativePath + " failed", ex.InnerException ?? ex);
				}
			}
			_initialized = true;
		}
	}

	public static void Finish()
	{
		lock (Gate)
		{
			if (_finished)
			{
				return;
			}
			Initialize();
			PatcherMethod[] enabled = _enabled;
			foreach (PatcherMethod patcherMethod in enabled)
			{
				try
				{
					patcherMethod.Finalizer?.Invoke(null, null);
				}
				catch (TargetInvocationException ex)
				{
					throw new InvalidOperationException("Finishing patcher " + patcherMethod.RelativePath + " failed", ex.InnerException ?? ex);
				}
			}
			_finished = true;
		}
	}

	public static void Patch(ref AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		lock (Gate)
		{
			Initialize();
			string text = assembly.Name.Name + ".dll";
			PatcherMethod[] enabled = _enabled;
			foreach (PatcherMethod patcherMethod in enabled)
			{
				if (patcherMethod.Targets.Contains(text, StringComparer.OrdinalIgnoreCase))
				{
					Console.WriteLine("[SanctuaryPatcherHost] Running " + patcherMethod.RelativePath + " on " + text);
					try
					{
						object[] array = new object[1] { assembly };
						patcherMethod.Patch.Invoke(null, array);
						assembly = (array[0] as AssemblyDefinition) ?? throw new InvalidOperationException("Patcher replaced the target with a non-assembly value.");
					}
					catch (TargetInvocationException ex)
					{
						throw new InvalidOperationException("Patcher " + patcherMethod.RelativePath + " failed on " + text, ex.InnerException ?? ex);
					}
				}
			}
		}
	}

	private static void Discover()
	{
		if (_discovered != null)
		{
			return;
		}
		if (!Directory.Exists(ModsRoot))
		{
			_discovered = new PatcherAssembly[0];
			return;
		}
		List<PatcherAssembly> list = new List<PatcherAssembly>();
		string[] files = Directory.GetFiles(ModsRoot, "*.dll", SearchOption.AllDirectories);
		foreach (string text in files)
		{
			string relativePath = text.Substring(ModsRoot.Length).TrimStart(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar).Replace('\\', '/');
			if (!FolderName(relativePath).StartsWith(".", StringComparison.Ordinal))
			{
				string[] array = PatcherDiscovery.FindPatcherTypes(text);
				if (array.Length != 0)
				{
					list.Add(new PatcherAssembly
					{
						Path = text,
						RelativePath = relativePath,
						TypeNames = array
					});
				}
			}
		}
		_discovered = list.OrderBy((PatcherAssembly patcher) => Path.GetFileName(patcher.Path), PathComparer).ThenBy((PatcherAssembly patcher) => patcher.RelativePath, StringComparer.Ordinal).ToArray();
	}

	private static void LoadEnabled()
	{
		if (_enabled != null)
		{
			return;
		}
		Discover();
		HashSet<string> disabled = ReadDisabled("Patchers", normalizePaths: true);
		HashSet<string> disabledPacks = ReadDisabled("Packs", normalizePaths: false);
		ModRequirements modRequirements = new ModRequirements(ModsRoot, delegate(string folderName)
		{
			string path = Path.Combine(ModsRoot, folderName, "packs");
			string[] source = (Directory.Exists(path) ? Directory.GetFiles(path, "*", SearchOption.AllDirectories) : new string[0]);
			if (source.Any((string text) => !text.EndsWith(".sanpack", StringComparison.Ordinal)))
			{
				return false;
			}
			PatcherAssembly[] array = _discovered.Where((PatcherAssembly patcher) => FolderName(patcher.RelativePath).Equals(folderName, StringComparison.OrdinalIgnoreCase)).ToArray();
			if (array.Length != 0)
			{
				return array.Any((PatcherAssembly patcher) => !disabled.Contains(patcher.RelativePath));
			}
			return !source.Any() || !disabledPacks.Contains(folderName);
		});
		List<PatcherMethod> list = new List<PatcherMethod>();
		PatcherAssembly[] discovered = _discovered;
		foreach (PatcherAssembly patcherAssembly in discovered)
		{
			if (disabled.Contains(patcherAssembly.RelativePath))
			{
				continue;
			}
			if (!modRequirements.IsEnabled(FolderName(patcherAssembly.RelativePath), out var reason))
			{
				Console.WriteLine("[SanctuaryPatcherHost] Skipping " + patcherAssembly.RelativePath + ": " + reason);
				continue;
			}
			try
			{
				Assembly assembly = Assembly.LoadFile(patcherAssembly.Path);
				string[] typeNames = patcherAssembly.TypeNames;
				foreach (string name in typeNames)
				{
					Type type = assembly.GetType(name, throwOnError: true);
					PropertyInfo property = type.GetProperty("TargetDLLs", BindingFlags.Static | BindingFlags.Public);
					MethodInfo methodInfo = type.GetMethod("Patch", BindingFlags.Static | BindingFlags.Public, null, new Type[1] { typeof(AssemblyDefinition).MakeByRefType() }, null) ?? type.GetMethod("Patch", BindingFlags.Static | BindingFlags.Public, null, new Type[1] { typeof(AssemblyDefinition) }, null);
					if (property == null || methodInfo == null)
					{
						throw new InvalidOperationException("Patcher entry point changed after metadata scan.");
					}
					list.Add(new PatcherMethod
					{
						RelativePath = patcherAssembly.RelativePath,
						TargetProperty = property,
						Patch = methodInfo,
						Initializer = OptionalHook(type, "Initialize"),
						Finalizer = OptionalHook(type, "Finish")
					});
				}
			}
			catch (Exception innerException)
			{
				throw new InvalidOperationException("Could not load patcher " + patcherAssembly.RelativePath, innerException);
			}
		}
		_enabled = list.ToArray();
	}

	private static string FolderName(string relativePath)
	{
		return relativePath.Split(new char[1] { '/' })[0];
	}

	private static MethodInfo OptionalHook(Type type, string name)
	{
		return type.GetMethod(name, BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic, null, Type.EmptyTypes, null);
	}

	private static HashSet<string> ReadDisabled(string sectionName, bool normalizePaths)
	{
		return new HashSet<string>(PathComparer);
	}
}
