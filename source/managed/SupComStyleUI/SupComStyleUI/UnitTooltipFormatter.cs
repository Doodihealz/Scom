using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

namespace SupComStyleUI;

internal static class UnitTooltipFormatter
{
	private sealed class WeaponGroup
	{
		public readonly UnitWeaponStats Weapon;

		public int Count;

		public WeaponGroup(UnitWeaponStats weapon)
		{
			Weapon = weapon;
			Count = 1;
		}
	}

	private const string Accent = "#73D7E3";

	private const string Heading = "#F0A13A";

	private const string Primary = "#E4F0F2";

	private const string Secondary = "#B8CCD0";

	private static readonly string[] TraitPriority = new string[32]
	{
		"TECH1", "TECH2", "TECH3", "TECH4", "CHOSEN", "EDA", "GUARD", "SERAPHIM", "AIR", "LAND",
		"NAVAL", "AMPHIBIOUS", "MOBILE", "STRUCTURE", "COMMAND", "EXPERIMENTAL", "FIGHTER", "BOMBER", "GUNSHIP", "ARTILLERY",
		"ANTIAIR", "ANTI_AIR", "ANTI_SURFACE", "ANTI_NAVAL", "DIRECT_FIRE", "INDIRECT_FIRE", "ENGINEER", "FACTORY", "SCOUT", "SHIELD",
		"STEALTH_FIELD", "STEALTH"
	};

	public static string BuildTitle(UnitTooltipData data)
	{
		string text = Clean(data.Name);
		string text2 = Clean(data.DisplayName);
		if (text.Length == 0)
		{
			text = ((text2.Length > 0) ? text2 : data.TemplateId);
			text2 = string.Empty;
		}
		if (text2.Length == 0 || string.Equals(text, text2, StringComparison.OrdinalIgnoreCase))
		{
			return text;
		}
		return text + "  |  " + text2;
	}

	public static string BuildBody(UnitTooltipData data)
	{
		StringBuilder stringBuilder = new StringBuilder(1024);
		AppendColoredLine(stringBuilder, "#B8CCD0", BuildSummary(data));
		string text = BuildTraits(data);
		if (text.Length > 0)
		{
			AppendColoredLine(stringBuilder, "#73D7E3", text);
		}
		stringBuilder.AppendLine();
		AppendDefense(stringBuilder, data);
		AppendMobility(stringBuilder, data);
		AppendEconomy(stringBuilder, data);
		AppendIntel(stringBuilder, data);
		AppendConstruction(stringBuilder, data);
		AppendWeapons(stringBuilder, data);
		return stringBuilder.ToString().TrimEnd(Array.Empty<char>());
	}

	public static float? CalculateDps(UnitWeaponStats weapon)
	{
		float num = weapon.Damage;
		int num2 = Math.Max(0, weapon.MuzzleCount);
		if (weapon.BeamLifetime < 0f)
		{
			return num * (float)num2 * 10f;
		}
		if (weapon.BeamLifetime > 0f)
		{
			num *= weapon.BeamLifetime;
		}
		float num3 = Math.Max(weapon.ReloadTime, weapon.ReloadTime + (float)(weapon.SalvoSize - 1) * weapon.SalvoDelay);
		if (num3 <= 0f)
		{
			return 0f;
		}
		return (num * (float)num2 + weapon.DamageOverTime) / num3;
	}

	private static void AppendDefense(StringBuilder text, UnitTooltipData data)
	{
		List<string> values = new List<string>();
		AddMetric(values, "Health", data.Health);
		if (data.HealthRegen.HasValue && Math.Abs(data.HealthRegen.Value) > 0.001f)
		{
			AddMetric(values, "Regen", data.HealthRegen, "/s");
		}
		AddMetric(values, "Shield", data.Shield);
		if (data.ShieldRegen.HasValue && Math.Abs(data.ShieldRegen.Value) > 0.001f)
		{
			AddMetric(values, "Shield regen", data.ShieldRegen, "/s");
		}
		AppendSectionLine(text, "Defense", values);
	}

	private static void AppendMobility(StringBuilder text, UnitTooltipData data)
	{
		List<string> list = new List<string>();
		if (!string.IsNullOrWhiteSpace(data.MovementType))
		{
			list.Add(FriendlyMovement(data.MovementType));
		}
		AddMetric(list, "Speed", data.Speed);
		AddMetric(list, "Accel", data.Acceleration);
		AppendSectionLine(text, "Mobility", list);
	}

	private static void AppendEconomy(StringBuilder text, UnitTooltipData data)
	{
		List<string> list = new List<string>();
		AddMetric(list, "Energy", data.EnergyCost);
		AddMetric(list, "Alloy", data.AlloyCost);
		if (data.BuildTime.HasValue)
		{
			list.Add("Build " + FormatDuration(data.BuildTime.Value));
		}
		AppendSectionLine(text, "Economy", list);
		list.Clear();
		AddSignedMetric(list, "Energy", data.EnergyProduction, data.EnergyMaintenance);
		AddSignedMetric(list, "Alloy", data.AlloyProduction, data.AlloyMaintenance);
		AddMetric(list, "Energy cap", data.EnergyStorage);
		AddMetric(list, "Alloy cap", data.AlloyStorage);
		AppendSectionLine(text, "Operation", list);
	}

	private static void AppendIntel(StringBuilder text, UnitTooltipData data)
	{
		List<string> values = new List<string>();
		AddMetric(values, "Vision", data.VisionRadius);
		AddMetric(values, "Radar", data.RadarRadius);
		AddMetric(values, "Sonar", data.SonarRadius);
		AppendSectionLine(text, "Intel", values);
	}

	private static void AppendConstruction(StringBuilder text, UnitTooltipData data)
	{
		List<string> values = new List<string>();
		AddMetric(values, "Build power", data.BuildPower);
		AddMetric(values, "Range", data.BuildRange);
		AppendSectionLine(text, "Construction", values);
	}

	private static void AppendWeapons(StringBuilder text, UnitTooltipData data)
	{
		if (data.Weapons.Count == 0)
		{
			return;
		}
		List<WeaponGroup> list = GroupWeapons(data.Weapons);
		text.AppendLine();
		text.Append("<color=").Append("#F0A13A").Append("><b>Weapons</b></color>");
		float num = 0f;
		bool flag = false;
		for (int i = 0; i < list.Count; i++)
		{
			WeaponGroup weaponGroup = list[i];
			if (weaponGroup.Weapon.Dps.HasValue)
			{
				num += weaponGroup.Weapon.Dps.Value * (float)weaponGroup.Count;
				flag = true;
			}
			if (i < 3)
			{
				text.AppendLine();
				text.Append("<color=").Append("#73D7E3").Append("><b>")
					.Append(Escape(weaponGroup.Weapon.Label))
					.Append("</b></color>");
				if (weaponGroup.Count > 1)
				{
					text.Append(" x").Append(weaponGroup.Count.ToString(CultureInfo.InvariantCulture));
				}
				text.AppendLine();
				text.Append("  ").Append(FormatNumber(weaponGroup.Weapon.Damage)).Append(" dmg");
				if (weaponGroup.Weapon.SalvoSize > 1 || weaponGroup.Weapon.MuzzleCount > 1)
				{
					text.Append(" x").Append(Math.Max(weaponGroup.Weapon.SalvoSize, weaponGroup.Weapon.MuzzleCount).ToString(CultureInfo.InvariantCulture));
				}
				if (weaponGroup.Weapon.ReloadTime > 0f)
				{
					text.Append("  |  ").Append(FormatNumber(weaponGroup.Weapon.ReloadTime)).Append("s reload");
				}
				if (weaponGroup.Weapon.RangeMax > 0f)
				{
					text.Append("  |  ").Append(FormatNumber(weaponGroup.Weapon.RangeMax)).Append(" range");
				}
				if (weaponGroup.Weapon.Dps.HasValue)
				{
					float value = weaponGroup.Weapon.Dps.Value * (float)weaponGroup.Count;
					text.Append("  |  ").Append(FormatNumber(value)).Append(" DPS");
				}
			}
		}
		if (list.Count > 3)
		{
			text.AppendLine();
			text.Append("<color=").Append("#B8CCD0").Append(">+")
				.Append((list.Count - 3).ToString(CultureInfo.InvariantCulture))
				.Append(" more weapon systems</color>");
		}
		if (list.Count > 1 && flag)
		{
			text.AppendLine();
			text.Append("<color=").Append("#F0A13A").Append(">Total listed DPS: </color>")
				.Append(FormatNumber(num));
		}
	}

	private static List<WeaponGroup> GroupWeapons(List<UnitWeaponStats> weapons)
	{
		List<WeaponGroup> list = new List<WeaponGroup>();
		for (int i = 0; i < weapons.Count; i++)
		{
			UnitWeaponStats unitWeaponStats = weapons[i];
			WeaponGroup weaponGroup = null;
			for (int j = 0; j < list.Count; j++)
			{
				if (Equivalent(list[j].Weapon, unitWeaponStats))
				{
					weaponGroup = list[j];
					break;
				}
			}
			if (weaponGroup == null)
			{
				list.Add(new WeaponGroup(unitWeaponStats));
			}
			else
			{
				weaponGroup.Count++;
			}
		}
		return list;
	}

	private static bool Equivalent(UnitWeaponStats left, UnitWeaponStats right)
	{
		if (string.Equals(left.Label, right.Label, StringComparison.OrdinalIgnoreCase) && NearlyEqual(left.Damage, right.Damage) && NearlyEqual(left.RangeMax, right.RangeMax) && NearlyEqual(left.ReloadTime, right.ReloadTime) && left.SalvoSize == right.SalvoSize && NearlyEqual(left.SalvoDelay, right.SalvoDelay) && left.MuzzleCount == right.MuzzleCount && NearlyEqual(left.BeamLifetime, right.BeamLifetime))
		{
			return NearlyEqual(left.DamageOverTime, right.DamageOverTime);
		}
		return false;
	}

	private static bool NearlyEqual(float left, float right)
	{
		return Math.Abs(left - right) < 0.001f;
	}

	private static void AppendSectionLine(StringBuilder text, string heading, List<string> values)
	{
		if (values.Count == 0)
		{
			return;
		}
		text.Append("<color=").Append("#F0A13A").Append("><b>")
			.Append(heading)
			.Append("</b></color>  ");
		for (int i = 0; i < values.Count; i++)
		{
			if (i > 0)
			{
				text.Append("  |  ");
			}
			text.Append(values[i]);
		}
		text.AppendLine();
	}

	private static void AddMetric(List<string> values, string label, float? value, string suffix = "")
	{
		if (value.HasValue)
		{
			values.Add(label + " " + FormatNumber(value.Value) + suffix);
		}
	}

	private static void AddSignedMetric(List<string> values, string label, float? production, float? maintenance)
	{
		if (production.HasValue && Math.Abs(production.Value) > 0.001f)
		{
			values.Add(label + " +" + FormatNumber(production.Value) + "/s");
		}
		if (maintenance.HasValue && Math.Abs(maintenance.Value) > 0.001f)
		{
			values.Add(label + " -" + FormatNumber(Math.Abs(maintenance.Value)) + "/s");
		}
	}

	private static string BuildSummary(UnitTooltipData data)
	{
		if (HasTag(data, "ENGINEER") || HasTag(data, "CONSTRUCTION"))
		{
			return "Construction unit for building, assisting, and repairing friendly forces.";
		}
		if (HasTag(data, "FACTORY") || HasTag(data, "AIR_FACTORY") || HasTag(data, "LAND_FACTORY") || HasTag(data, "NAVAL_FACTORY"))
		{
			return "Production structure for deploying new combat and support units.";
		}
		if (HasTag(data, "SCOUT") || HasTag(data, "RADAR") || HasTag(data, "SONAR"))
		{
			return "Reconnaissance unit for extending vision and sensor coverage.";
		}
		if (HasTag(data, "SHIELD"))
		{
			return "Defensive support unit that protects nearby friendly forces.";
		}
		if (HasTag(data, "TRANSPORT") || HasTag(data, "SCFA_TRANSPORTATION"))
		{
			return "Transport for ferrying friendly land units. Load units, fly to a destination, then unload.";
		}
		if (HasTag(data, "BOMBER"))
		{
			return "Strike aircraft designed to attack surface targets.";
		}
		if (HasTag(data, "FIGHTER"))
		{
			return "Air-superiority unit designed to engage hostile aircraft.";
		}
		if (HasTag(data, "ANTIAIR") || HasTag(data, "ANTI_AIR"))
		{
			return "Anti-air unit designed to defend against hostile aircraft.";
		}
		if (HasTag(data, "ARTILLERY") || HasTag(data, "INDIRECT_FIRE"))
		{
			return "Long-range fire-support unit for engaging surface targets.";
		}
		if (HasTag(data, "STEALTH_FIELD") || HasTag(data, "STEALTH"))
		{
			return "Support unit that reduces the visibility of nearby friendly forces.";
		}
		if (HasTag(data, "STRUCTURE"))
		{
			if (data.Weapons.Count <= 0)
			{
				return "Stationary support structure.";
			}
			return "Stationary combat structure for battlefield defense.";
		}
		if (data.Weapons.Count > 0)
		{
			return "Mobile combat unit for direct battlefield engagement.";
		}
		return "Mobile support unit.";
	}

	private static string BuildTraits(UnitTooltipData data)
	{
		List<string> list = new List<string>();
		HashSet<string> hashSet = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
		string text = string.Empty;
		for (int num = 4; num >= 1; num--)
		{
			string text2 = "TECH" + num.ToString(CultureInfo.InvariantCulture);
			if (HasTag(data, text2))
			{
				text = text2;
				break;
			}
		}
		if (text.Length > 0 || !string.IsNullOrWhiteSpace(data.Tech))
		{
			string item = FriendlyTag((text.Length > 0) ? text : data.Tech);
			list.Add(item);
			hashSet.Add(item);
		}
		string text3 = (HasTag(data, "SCFA_UEF") ? "UEF" : (HasTag(data, "SCFA_AEON") ? "Aeon" : (HasTag(data, "SCFA_CYBRAN") ? "Cybran" : (HasTag(data, "SCFA_SERAPHIM") ? "Seraphim" : string.Empty))));
		if (text3.Length > 0)
		{
			list.Add(text3);
			hashSet.Add(text3);
		}
		for (int i = 0; i < TraitPriority.Length && list.Count < 7; i++)
		{
			string text4 = TraitPriority[i];
			if (text4.StartsWith("TECH", StringComparison.OrdinalIgnoreCase))
			{
				continue;
			}
			if (text3.Length > 0)
			{
				switch (text4)
				{
				case "EDA":
				case "CHOSEN":
				case "GUARD":
				case "SERAPHIM":
					continue;
				}
			}
			if (HasTag(data, text4))
			{
				string item2 = FriendlyTag(text4);
				if (hashSet.Add(item2))
				{
					list.Add(item2);
				}
			}
		}
		return string.Join("  |  ", list.ToArray());
	}

	private static bool HasTag(UnitTooltipData data, string tag)
	{
		for (int i = 0; i < data.Tags.Count; i++)
		{
			if (string.Equals(data.Tags[i], tag, StringComparison.OrdinalIgnoreCase))
			{
				return true;
			}
		}
		return false;
	}

	private static string FriendlyTag(string value)
	{
		string text = value.Trim().ToUpperInvariant();
		switch (text)
		{
		case "TECH1":
		case "T1":
			return "T1";
		case "TECH2":
		case "T2":
			return "T2";
		case "TECH3":
		case "T3":
			return "T3";
		case "TECH4":
		case "T4":
			return "T4";
		case "ANTI_AIR":
		case "ANTIAIR":
			return "Anti-air";
		case "STEALTH_FIELD":
			return "Stealth field";
		case "ANTI_SURFACE":
			return "Anti-surface";
		case "ANTI_NAVAL":
			return "Anti-naval";
		case "DIRECT_FIRE":
			return "Direct fire";
		case "INDIRECT_FIRE":
			return "Indirect fire";
		default:
			return TitleCase(text.Replace('_', ' '));
		}
	}

	private static string FriendlyMovement(string value)
	{
		return TitleCase(value.Replace("TracksLand", "Tracked").Replace("WheelsLand", "Wheeled").Replace("HoverLand", "Hover")
			.Replace("AmphibiousLand", "Amphibious")
			.Replace('_', ' '));
	}

	private static string TitleCase(string value)
	{
		if (value.Length == 0)
		{
			return value;
		}
		return CultureInfo.InvariantCulture.TextInfo.ToTitleCase(value.ToLowerInvariant());
	}

	private static string FormatDuration(float seconds)
	{
		int num = Math.Max(0, (int)Math.Round(seconds));
		if (num < 60)
		{
			return num.ToString(CultureInfo.InvariantCulture) + "s";
		}
		int num2 = num / 60;
		int num3 = num % 60;
		return num2.ToString(CultureInfo.InvariantCulture) + ":" + num3.ToString("00", CultureInfo.InvariantCulture);
	}

	private static string FormatNumber(float value)
	{
		float num = Math.Abs(value);
		if (num >= 1000000f)
		{
			return (value / 1000000f).ToString("0.##", CultureInfo.InvariantCulture) + "M";
		}
		if (num >= 10000f)
		{
			return (value / 1000f).ToString("0.#", CultureInfo.InvariantCulture) + "K";
		}
		return value.ToString((num >= 100f) ? "0" : "0.##", CultureInfo.InvariantCulture);
	}

	private static string Clean(string value)
	{
		if (!string.IsNullOrWhiteSpace(value))
		{
			return value.Trim();
		}
		return string.Empty;
	}

	private static string Escape(string value)
	{
		return Clean(value).Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;");
	}

	private static void AppendColoredLine(StringBuilder text, string color, string value)
	{
		text.Append("<color=").Append(color).Append('>')
			.Append(Escape(value))
			.Append("</color>")
			.AppendLine();
	}
}
