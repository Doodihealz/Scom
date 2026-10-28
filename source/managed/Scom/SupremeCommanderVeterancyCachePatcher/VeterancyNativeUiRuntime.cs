using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;

namespace SupremeCommanderVeterancyCachePatcher;

public static class VeterancyNativeUiRuntime
{
	private sealed class IconRow
	{
		private readonly object[] images;

		private string? templateId;

		private string? faction;

		private int kills = -1;

		public IconRow(object[] images)
		{
			this.images = images;
		}

		public void Apply(string newTemplateId, string newFaction, int newKills, int level)
		{
			if (templateId == newTemplateId && kills == newKills && faction == newFaction)
			{
				return;
			}
			if (!string.Equals(faction, newFaction, StringComparison.Ordinal))
			{
				object factionSprite = GetFactionSprite(newFaction);
				object[] array = images;
				for (int i = 0; i < array.Length; i++)
				{
					SetProperty(array[i], "sprite", factionSprite);
				}
			}
			for (int j = 0; j < images.Length; j++)
			{
				SetGameObjectActive(images[j], j < level);
			}
			templateId = newTemplateId;
			faction = newFaction;
			kills = newKills;
		}

		public void Hide(string newTemplateId, int newKills)
		{
			if (!(templateId == newTemplateId) || kills != newKills || faction != null)
			{
				object[] array = images;
				for (int i = 0; i < array.Length; i++)
				{
					SetGameObjectActive(array[i], active: false);
				}
				templateId = newTemplateId;
				faction = null;
				kills = newKills;
			}
		}
	}

	private const float BadgeSize = 16f;

	private const float FirstBadgeX = -5f;

	private const float BadgeStepX = 13f;

	private const float BadgeY = -18f;

	private static readonly ConditionalWeakTable<object, IconRow> Rows = new ConditionalWeakTable<object, IconRow>();

	private static readonly ConcurrentDictionary<Type, FieldInfo> VeterancyFields = new ConcurrentDictionary<Type, FieldInfo>();

	private static readonly ConcurrentDictionary<Type, FieldInfo> TemplateFields = new ConcurrentDictionary<Type, FieldInfo>();

	private static readonly Dictionary<string, object> SpriteCache = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);

	private static readonly object SpriteGate = new object();

	private static bool failureLogged;

	public static void UpdateVeterancyIcons(object panel, object values)
	{
		if (panel == null || values == null)
		{
			return;
		}
		try
		{
			string templateId = GetTemplateId(panel);
			int kills = GetKills(values);
			string faction = GetFaction(templateId);
			int num = ((faction != null) ? VeterancyRules.Get(templateId).GetLevel(kills) : 0);
			if (num <= 0 || faction == null)
			{
				if (Rows.TryGetValue(panel, out IconRow value))
				{
					value.Hide(templateId, kills);
				}
			}
			else
			{
				Rows.GetValue(panel, CreateIconRow).Apply(templateId, faction, kills, num);
			}
		}
		catch (Exception arg)
		{
			if (!failureLogged)
			{
				failureLogged = true;
				Log($"Veterancy badges were disabled after a native UI failure: {arg}");
			}
		}
	}

	private static int GetKills(object values)
	{
		object value = VeterancyFields.GetOrAdd(values.GetType(), (Type type) => type.GetField("veterancy", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "veterancy")).GetValue(values) ?? throw new InvalidOperationException("UIInformationValues.veterancy was null.");
		return Math.Max(0, (int)Math.Floor(Convert.ToDouble(value, CultureInfo.InvariantCulture)));
	}

	private static string GetTemplateId(object panel)
	{
		object obj = TemplateFields.GetOrAdd(panel.GetType(), (Type type) => type.GetField("unitTemplateId", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "unitTemplateId")).GetValue(panel) ?? throw new InvalidOperationException("InformationPanelUI.unitTemplateId was null.");
		return ((obj.GetType().GetProperty("text", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(obj.GetType().FullName, "text")).GetValue(obj) as string) ?? string.Empty;
	}

	private static string? GetFaction(string templateId)
	{
		if (templateId.StartsWith("ue", StringComparison.OrdinalIgnoreCase))
		{
			return "uef";
		}
		if (templateId.StartsWith("uc", StringComparison.OrdinalIgnoreCase))
		{
			return "aeon";
		}
		if (templateId.StartsWith("ug", StringComparison.OrdinalIgnoreCase))
		{
			return "cybran";
		}
		if (templateId.StartsWith("us", StringComparison.OrdinalIgnoreCase))
		{
			return "seraphim";
		}
		return null;
	}

	private static IconRow CreateIconRow(object panel)
	{
		object property = GetProperty(panel.GetType().GetField("veterancy", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic)?.GetValue(panel) ?? throw new MissingFieldException(panel.GetType().FullName, "veterancy"), "transform");
		Type type = FindLoadedType("UnityEngine.GameObject");
		Type type2 = FindLoadedType("UnityEngine.RectTransform");
		Type type3 = FindLoadedType("UnityEngine.UI.Image");
		ConstructorInfo constructorInfo = type.GetConstructor(new Type[2]
		{
			typeof(string),
			typeof(Type[])
		}) ?? throw new MissingMethodException(type.FullName, ".ctor(String, Type[])");
		MethodInfo methodInfo = type.GetMethod("GetComponent", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(Type) }, null) ?? throw new MissingMethodException(type.FullName, "GetComponent(Type)");
		object[] array = new object[5];
		for (int i = 0; i < array.Length; i++)
		{
			object obj = constructorInfo.Invoke(new object[2]
			{
				$"SCO Veterancy Badge {i + 1}",
				new Type[2] { type2, type3 }
			}) ?? throw new InvalidOperationException("Unity did not create a veterancy badge GameObject.");
			SetParent(GetProperty(obj, "transform"), property);
			ConfigureRectTransform(methodInfo.Invoke(obj, new object[1] { type2 }) ?? throw new InvalidOperationException("A veterancy badge has no RectTransform."), i);
			object obj2 = methodInfo.Invoke(obj, new object[1] { type3 }) ?? throw new InvalidOperationException("A veterancy badge has no Image.");
			SetProperty(obj2, "raycastTarget", false);
			SetProperty(obj2, "preserveAspect", true);
			SetGameObjectActive(obj2, active: false);
			array[i] = obj2;
		}
		return new IconRow(array);
	}

	private static void SetParent(object transform, object parent)
	{
		(transform.GetType().GetMethods(BindingFlags.Instance | BindingFlags.Public).SingleOrDefault((MethodInfo candidate) => candidate.Name == "SetParent" && candidate.GetParameters().Length == 2 && candidate.GetParameters()[1].ParameterType == typeof(bool)) ?? throw new MissingMethodException(transform.GetType().FullName, "SetParent(Transform, Boolean)")).Invoke(transform, new object[2] { parent, false });
	}

	private static void ConfigureRectTransform(object rectTransform, int index)
	{
		Type vector2Type = FindLoadedType("UnityEngine.Vector2");
		object value = CreateVector2(vector2Type, 0f, 0f);
		SetProperty(rectTransform, "anchorMin", value);
		SetProperty(rectTransform, "anchorMax", value);
		SetProperty(rectTransform, "pivot", CreateVector2(vector2Type, 0f, 1f));
		SetProperty(rectTransform, "sizeDelta", CreateVector2(vector2Type, 16f, 16f));
		SetProperty(rectTransform, "anchoredPosition", CreateVector2(vector2Type, -5f + 13f * (float)index, -18f));
	}

	private static object CreateVector2(Type vector2Type, float x, float y)
	{
		return Activator.CreateInstance(vector2Type, x, y) ?? throw new InvalidOperationException("UnityEngine.Vector2 construction returned null.");
	}

	private static object GetFactionSprite(string faction)
	{
		lock (SpriteGate)
		{
			if (SpriteCache.TryGetValue(faction, out object value))
			{
				return value;
			}
			string text = "UI/Sprites/Icons/Veterancy/" + faction + "-veteran.sansprite";
			Type type = FindLoadedType("EM.Gamedata.Data");
			MethodInfo methodInfo = type.GetMethod("GetFileEntry", BindingFlags.Static | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "GetFileEntry(String)");
			object entry = methodInfo.Invoke(null, new object[1] { text }) ?? throw new FileNotFoundException("The packaged Forged Alliance veterancy sprite was not found.", text);
			Type type2 = FindLoadedType("EM.Gamedata.Load");
			object obj = (type2.GetMethods(BindingFlags.Static | BindingFlags.Public).SingleOrDefault((MethodInfo method) => method.Name == "LoadGamedataSprite" && method.GetParameters().Length == 1 && method.GetParameters()[0].ParameterType.IsInstanceOfType(entry)) ?? throw new MissingMethodException(type2.FullName, "LoadGamedataSprite(IGamedataEntry)")).Invoke(null, new object[1] { entry }) ?? throw new InvalidOperationException("LoadGamedataSprite returned null for a veterancy badge.");
			object obj2 = (obj.GetType().GetMethod("GetSprite", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(obj.GetType().FullName, "GetSprite")).Invoke(obj, null) ?? throw new InvalidOperationException("The veterancy .sansprite did not produce a Unity Sprite.");
			SpriteCache.Add(faction, obj2);
			return obj2;
		}
	}

	private static object GetProperty(object target, string name)
	{
		return (target.GetType().GetProperty(name, BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(target.GetType().FullName, name)).GetValue(target) ?? throw new InvalidOperationException(target.GetType().FullName + "." + name + " was null.");
	}

	private static void SetProperty(object target, string name, object value)
	{
		(target.GetType().GetProperty(name, BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(target.GetType().FullName, name)).SetValue(target, value, null);
	}

	private static void SetGameObjectActive(object component, bool active)
	{
		object property = GetProperty(component, "gameObject");
		(property.GetType().GetMethod("SetActive", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(bool) }, null) ?? throw new MissingMethodException(property.GetType().FullName, "SetActive(Boolean)")).Invoke(property, new object[1] { active });
	}

	private static Type FindLoadedType(string fullName)
	{
		Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
		for (int i = 0; i < assemblies.Length; i++)
		{
			Type type = assemblies[i].GetType(fullName, throwOnError: false);
			if ((object)type != null)
			{
				return type;
			}
		}
		throw new TypeLoadException("The required runtime type was not loaded: " + fullName);
	}

	private static void Log(string message)
	{
		string text = "[Supreme Commander Veterancy HUD] " + message;
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
}
