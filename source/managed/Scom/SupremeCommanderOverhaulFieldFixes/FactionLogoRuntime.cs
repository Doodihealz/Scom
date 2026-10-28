using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using ScomSeraphimLogo;

namespace SupremeCommanderOverhaulFieldFixes;

public static class FactionLogoRuntime
{
	private static readonly string[] ScomFactionNames = new string[4] { "UEF", "Aeon", "Cybran", "Seraphim" };

	private const string PrometheanFactionName = "Prometheans";

	private static readonly string[] ExactSpritePaths = new string[3] { "UI/Sprites/Icons/Factions/uef.sansprite", "UI/Sprites/Icons/Factions/aeon.sansprite", "UI/Sprites/Icons/Factions/cybran.sansprite" };

	private static readonly object Gate = new object();

	private static readonly object?[] CachedSprites = new object[3];

	private static string? _lastFailure;

	public static void ConfigureFactionLogos(object playerListItem)
	{
		try
		{
			if (playerListItem == null)
			{
				throw new ArgumentNullException("playerListItem");
			}
			object obj = playerListItem.GetType().GetField("factionDropdown", BindingFlags.Instance | BindingFlags.NonPublic)?.GetValue(playerListItem);
			if (obj == null)
			{
				return;
			}
			Type type = obj.GetType();
			if (!((type.GetField("items", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingFieldException(type.FullName, "items")).GetValue(obj) is IList list))
			{
				throw new InvalidOperationException("Faction dropdown items are not an IList.");
			}
			RequireSupportedLayout(list);
			MethodInfo methodInfo = type.GetMethod("Initialize", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, "Initialize()");
			FieldInfo fieldInfo = type.GetField("selectedItemIndex", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingFieldException(type.FullName, "selectedItemIndex");
			if (fieldInfo.FieldType != typeof(int))
			{
				throw new InvalidOperationException("Faction selection is not an integer index.");
			}
			int num = (int)fieldInfo.GetValue(obj);
			if (num < 0 || num >= list.Count)
			{
				throw new InvalidOperationException("Faction selection is outside the item list.");
			}
			MethodInfo methodInfo2 = type.GetMethod("SetDropdownIndex", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(int) }, null) ?? throw new MissingMethodException(type.FullName, "SetDropdownIndex(Int32)");
			FieldInfo fieldInfo2 = type.GetField("enableIcon", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingFieldException(type.FullName, "enableIcon");
			if (fieldInfo2.FieldType != typeof(bool) || fieldInfo2.IsInitOnly)
			{
				throw new InvalidOperationException("Faction header icon setting is not writable.");
			}
			bool flag = (bool)fieldInfo2.GetValue(obj);
			object[] array = ExactSpritePaths.Select((string path, int index) => LoadSprite(path, index)).ToArray();
			List<Tuple<object, FieldInfo, object>> list2 = new List<Tuple<object, FieldInfo, object>>(array.Length);
			try
			{
				for (int num2 = 0; num2 < array.Length; num2++)
				{
					object obj2 = list[num2] ?? throw new InvalidOperationException($"Faction option {num2} is null.");
					FieldInfo fieldInfo3 = obj2.GetType().GetField("itemIcon", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingFieldException(obj2.GetType().FullName, "itemIcon");
					if (fieldInfo3.IsInitOnly || !fieldInfo3.FieldType.IsInstanceOfType(array[num2]))
					{
						throw new InvalidOperationException($"Faction option {num2} cannot accept the packaged sprite.");
					}
					object value = fieldInfo3.GetValue(obj2);
					if (value != array[num2])
					{
						fieldInfo3.SetValue(obj2, array[num2]);
						list2.Add(new Tuple<object, FieldInfo, object>(obj2, fieldInfo3, value));
					}
				}
				fieldInfo2.SetValue(obj, true);
				if (list2.Count != 0 || !flag)
				{
					methodInfo.Invoke(obj, null);
					methodInfo2.Invoke(obj, new object[1] { num });
				}
			}
			catch
			{
				fieldInfo2.SetValue(obj, flag);
				fieldInfo.SetValue(obj, num);
				foreach (Tuple<object, FieldInfo, object> item in list2.AsEnumerable().Reverse())
				{
					try
					{
						item.Item2.SetValue(item.Item1, item.Item3);
					}
					catch
					{
					}
				}
				throw;
			}
			ConfigureCaptionLayout(obj);
			_lastFailure = null;
		}
		catch (Exception ex)
		{
			LogFailure(ex.GetBaseException().Message);
		}
	}

	private static void ConfigureCaptionLayout(object dropdown)
	{
		Type type = dropdown.GetType();
		object obj = type.GetField("headerText")?.GetValue(dropdown) ?? throw new InvalidOperationException("Faction caption text is unavailable.");
		object obj2 = type.GetField("headerImage")?.GetValue(dropdown) ?? throw new InvalidOperationException("Faction caption icon is unavailable.");
		object obj3 = ReadProperty(ReadProperty(obj, "rectTransform"), "parent");
		object target = GetComponent(obj3, FindLoadedType("UnityEngine.UI.HorizontalLayoutGroup")) ?? throw new InvalidOperationException("Faction header layout is unavailable.");
		object obj4 = ReadProperty(ReadProperty(obj2, "rectTransform"), "sizeDelta");
		float num = (float)obj4.GetType().GetField("x").GetValue(obj4);
		float num2 = (float)ReadProperty(obj, ((bool)ReadProperty(obj, "enableAutoSizing")) ? "fontSizeMax" : "fontSize");
		if (num <= 0f || float.IsNaN(num) || float.IsInfinity(num) || num2 <= 0f || float.IsNaN(num2) || float.IsInfinity(num2))
		{
			throw new InvalidOperationException("Faction caption dimensions are invalid.");
		}
		object obj5 = ReadProperty(obj3, "offsetMax");
		obj5.GetType().GetField("x").SetValue(obj5, -32f);
		WriteProperty(obj3, "offsetMax", obj5);
		object obj6 = ReadProperty(target, "padding");
		WriteProperty(obj6, "left", 8);
		WriteProperty(target, "padding", obj6);
		WriteProperty(target, "spacing", 6f);
		Type type2 = FindLoadedType("UnityEngine.UI.LayoutElement");
		object obj7 = GetComponent(obj2, type2);
		if (obj7 == null)
		{
			object obj8 = ReadProperty(obj2, "gameObject");
			obj7 = obj8.GetType().GetMethod("AddComponent", new Type[1] { typeof(Type) }).Invoke(obj8, new object[1] { type2 }) ?? throw new InvalidOperationException("Faction icon layout could not be created.");
		}
		WriteProperty(obj7, "minWidth", num);
		WriteProperty(obj7, "preferredWidth", num);
		WriteProperty(obj7, "flexibleWidth", 0f);
		WriteProperty(target, "childControlWidth", true);
		WriteProperty(target, "childForceExpandWidth", false);
		WriteProperty(obj, "fontSizeMax", num2);
		WriteProperty(obj, "fontSizeMin", Math.Min(12f, num2));
		WriteProperty(obj, "enableAutoSizing", true);
		PropertyInfo propertyInfo = obj.GetType().GetProperty("textWrappingMode") ?? throw new MissingMemberException(obj.GetType().FullName, "textWrappingMode");
		propertyInfo.SetValue(obj, Enum.Parse(propertyInfo.PropertyType, "NoWrap"), null);
		LogoBridge.Configure(dropdown);
	}

	private static object? GetComponent(object component, Type type)
	{
		return component.GetType().GetMethod("GetComponent", new Type[1] { typeof(Type) }).Invoke(component, new object[1] { type });
	}

	private static object ReadProperty(object target, string name)
	{
		return target.GetType().GetProperty(name)?.GetValue(target, null) ?? throw new MissingMemberException(target.GetType().FullName, name);
	}

	private static void WriteProperty(object target, string name, object value)
	{
		(target.GetType().GetProperty(name) ?? throw new MissingMemberException(target.GetType().FullName, name)).SetValue(target, value, null);
	}

	private static void RequireSupportedLayout(IList options)
	{
		bool flag = options.Count == ScomFactionNames.Length || options.Count >= ScomFactionNames.Length + 1;
		int num = 0;
		while (flag && num < ScomFactionNames.Length)
		{
			flag = string.Equals(ReadOptionText(options[num]), ScomFactionNames[num], StringComparison.Ordinal);
			num++;
		}
		if (flag && options.Count >= ScomFactionNames.Length + 1)
		{
			flag = string.Equals(ReadOptionText(options[ScomFactionNames.Length]), "Prometheans", StringComparison.Ordinal);
		}
		if (flag)
		{
			return;
		}
		throw new InvalidOperationException("Unsupported faction dropdown layout. Expected exactly [UEF, Aeon, Cybran, Seraphim] or prefix [UEF, Aeon, Cybran, Seraphim, Prometheans]; found " + DescribeLayout(options) + ".");
	}

	private static string? ReadOptionText(object? option)
	{
		return option?.GetType().GetField("itemName", BindingFlags.Instance | BindingFlags.Public)?.GetValue(option) as string;
	}

	private static string DescribeLayout(IList options)
	{
		string[] array = new string[options.Count];
		for (int i = 0; i < options.Count; i++)
		{
			array[i] = ReadOptionText(options[i]) ?? "<missing>";
		}
		return "[" + string.Join(", ", array) + "]";
	}

	private static object LoadSprite(string path, int index)
	{
		lock (Gate)
		{
			if (CachedSprites[index] != null)
			{
				return CachedSprites[index];
			}
			Type type = FindLoadedType("EM.Gamedata.Data");
			MethodInfo methodInfo = type.GetMethod("GetFileEntry", BindingFlags.Static | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "GetFileEntry(String)");
			object entry = methodInfo.Invoke(null, new object[1] { path }) ?? throw new FileNotFoundException("The exact-case faction sprite is unavailable.", path);
			Type type2 = FindLoadedType("EM.Gamedata.Load");
			object obj = (type2.GetMethods(BindingFlags.Static | BindingFlags.Public).SingleOrDefault((MethodInfo method) => method.Name == "LoadGamedataSprite" && method.GetParameters().Length == 1 && method.GetParameters()[0].ParameterType.IsInstanceOfType(entry)) ?? throw new MissingMethodException(type2.FullName, "LoadGamedataSprite(IGamedataEntry)")).Invoke(null, new object[1] { entry }) ?? throw new InvalidOperationException("LoadGamedataSprite returned null for " + path + ".");
			object obj2 = obj.GetType().GetMethod("GetSprite", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null)?.Invoke(obj, null) ?? throw new InvalidOperationException("The packaged entry produced no Unity sprite: " + path);
			CachedSprites[index] = obj2;
			return obj2;
		}
	}

	private static Type FindLoadedType(string fullName)
	{
		Type[] array = (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType(fullName, throwOnError: false) into type
			where type != null
			select type).Cast<Type>().ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException($"Expected one loaded {fullName} type, found {array.Length}.");
		}
		return array[0];
	}

	private static void LogFailure(string message)
	{
		if (string.Equals(_lastFailure, message, StringComparison.Ordinal))
		{
			return;
		}
		_lastFailure = message;
		try
		{
			Console.WriteLine("[SCOM Field Fixes] Faction-logo update skipped: " + message);
		}
		catch
		{
		}
	}
}
