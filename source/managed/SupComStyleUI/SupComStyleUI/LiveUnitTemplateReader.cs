using System;
using System.Collections.Generic;
using System.Text;
using EM.Lua.Client;

namespace SupComStyleUI;

internal sealed class LiveUnitTemplateReader
{
	private readonly Dictionary<string, UnitTooltipData> cache = new Dictionary<string, UnitTooltipData>(StringComparer.OrdinalIgnoreCase);

	public bool TryRead(string templateId, out UnitTooltipData data, out string error)
	{
		data = null;
		error = string.Empty;
		if (!IsSafeTemplateId(templateId))
		{
			error = "The hovered unit supplied an invalid template ID.";
			return false;
		}
		if (cache.TryGetValue(templateId, out data))
		{
			return true;
		}
		lua_State luaState;
		try
		{
			luaState = ClientLuaInterface.Data.luaState;
		}
		catch (Exception ex)
		{
			error = "The client Lua state is unavailable: " + ex.Message;
			return false;
		}
		if (!TryRead(luaState, templateId, out data, out error))
		{
			return false;
		}
		cache[templateId] = data;
		return true;
	}

	public void Clear()
	{
		cache.Clear();
	}

	internal static bool TryRead(lua_State luaState, string templateId, out UnitTooltipData data, out string error)
	{
		data = null;
		error = string.Empty;
		if (luaState.IsNull)
		{
			error = "The client Lua state is not initialized.";
			return false;
		}
		if (!IsSafeTemplateId(templateId))
		{
			error = "The hovered unit supplied an invalid template ID.";
			return false;
		}
		int idx = LuaJIT.lua_gettop(luaState);
		try
		{
			if (LuaJIT.lua_checkstack(luaState, 64) == 0)
			{
				error = "The client Lua stack cannot reserve tooltip workspace.";
				return false;
			}
			PushRawField(luaState, -10002, "__Templates");
			if (LuaJIT.lua_istable(luaState, -1) == 0)
			{
				error = "The live template registry is unavailable.";
				return false;
			}
			PushRawField(luaState, AbsoluteIndex(luaState, -1), "Units");
			if (LuaJIT.lua_istable(luaState, -1) == 0)
			{
				error = "The live unit-template registry is unavailable.";
				return false;
			}
			PushRawField(luaState, AbsoluteIndex(luaState, -1), templateId);
			if (LuaJIT.lua_istable(luaState, -1) == 0)
			{
				error = "No live unit template exists for " + templateId + ".";
				return false;
			}
			int unitIndex = AbsoluteIndex(luaState, -1);
			UnitTooltipData unitTooltipData = new UnitTooltipData
			{
				TemplateId = templateId
			};
			ReadGeneral(luaState, unitIndex, unitTooltipData);
			ReadTags(luaState, unitIndex, unitTooltipData);
			ReadDefense(luaState, unitIndex, unitTooltipData);
			ReadEconomy(luaState, unitIndex, unitTooltipData);
			ReadMovement(luaState, unitIndex, unitTooltipData);
			ReadIntel(luaState, unitIndex, unitTooltipData);
			ReadConstruction(luaState, unitIndex, unitTooltipData);
			ReadWeapons(luaState, unitIndex, unitTooltipData);
			if (string.IsNullOrWhiteSpace(unitTooltipData.TemplateId))
			{
				unitTooltipData.TemplateId = templateId;
			}
			data = unitTooltipData;
			return true;
		}
		catch (Exception ex)
		{
			error = "Could not read the live " + templateId + " template: " + ex.Message;
			return false;
		}
		finally
		{
			LuaJIT.lua_settop(luaState, idx);
		}
	}

	private static void ReadGeneral(lua_State luaState, int unitIndex, UnitTooltipData data)
	{
		if (PushTableField(luaState, unitIndex, "general"))
		{
			int parentIndex = AbsoluteIndex(luaState, -1);
			data.Name = ReadStringField(luaState, parentIndex, "name");
			data.DisplayName = ReadStringField(luaState, parentIndex, "displayName");
			data.UnitTypeName = ReadStringField(luaState, parentIndex, "unitTypeName");
			string templateId = ReadStringField(luaState, parentIndex, "tpId");
			if (IsSafeTemplateId(templateId))
			{
				data.TemplateId = templateId;
			}
			data.Threat = ReadNumberField(luaState, parentIndex, "threat");
			if (PushTableField(luaState, parentIndex, "icon"))
			{
				data.Tech = ReadStringField(luaState, AbsoluteIndex(luaState, -1), "tech");
				LuaJIT.lua_pop(luaState, 1);
			}
			LuaJIT.lua_pop(luaState, 1);
		}
	}

	private static void ReadTags(lua_State luaState, int unitIndex, UnitTooltipData data)
	{
		if (!PushTableField(luaState, unitIndex, "tags"))
		{
			return;
		}
		int num = AbsoluteIndex(luaState, -1);
		int num2 = BoundedArrayLength(luaState, num, 128);
		for (int i = 1; i <= num2; i++)
		{
			LuaJIT.lua_rawgeti(luaState, num, i);
			string text = ReadString(luaState, -1);
			LuaJIT.lua_pop(luaState, 1);
			if (!string.IsNullOrWhiteSpace(text))
			{
				data.Tags.Add(text);
			}
		}
		LuaJIT.lua_pop(luaState, 1);
	}

	private static void ReadDefense(lua_State luaState, int unitIndex, UnitTooltipData data)
	{
		if (!PushTableField(luaState, unitIndex, "defence"))
		{
			return;
		}
		int parentIndex = AbsoluteIndex(luaState, -1);
		if (PushTableField(luaState, parentIndex, "health"))
		{
			int parentIndex2 = AbsoluteIndex(luaState, -1);
			data.Health = ReadNumberField(luaState, parentIndex2, "max") ?? ReadNumberField(luaState, parentIndex2, "value");
			data.HealthRegen = ReadNumberField(luaState, parentIndex2, "regen");
			LuaJIT.lua_pop(luaState, 1);
		}
		if (PushTableField(luaState, parentIndex, "shields"))
		{
			int num = AbsoluteIndex(luaState, -1);
			int num2 = BoundedArrayLength(luaState, num, 16);
			float num3 = 0f;
			float num4 = 0f;
			bool flag = false;
			bool flag2 = false;
			for (int i = 1; i <= num2; i++)
			{
				LuaJIT.lua_rawgeti(luaState, num, i);
				if (LuaJIT.lua_istable(luaState, -1) != 0)
				{
					int parentIndex3 = AbsoluteIndex(luaState, -1);
					float? num5 = ReadNumberField(luaState, parentIndex3, "max");
					float? num6 = ReadNumberField(luaState, parentIndex3, "regen");
					if (num5.HasValue)
					{
						num3 += num5.Value;
						flag = true;
					}
					if (num6.HasValue)
					{
						num4 += num6.Value;
						flag2 = true;
					}
				}
				LuaJIT.lua_pop(luaState, 1);
			}
			data.Shield = (flag ? new float?(num3) : ((float?)null));
			data.ShieldRegen = (flag2 ? new float?(num4) : ((float?)null));
			LuaJIT.lua_pop(luaState, 1);
		}
		LuaJIT.lua_pop(luaState, 1);
	}

	private static void ReadEconomy(lua_State luaState, int unitIndex, UnitTooltipData data)
	{
		if (PushTableField(luaState, unitIndex, "economy"))
		{
			int parentIndex = AbsoluteIndex(luaState, -1);
			data.BuildTime = ReadNumberField(luaState, parentIndex, "buildTime");
			ReadResourcePair(luaState, parentIndex, "cost", out data.EnergyCost, out data.AlloyCost);
			ReadResourcePair(luaState, parentIndex, "production", out data.EnergyProduction, out data.AlloyProduction);
			ReadResourcePair(luaState, parentIndex, "maintenanceConsumption", out data.EnergyMaintenance, out data.AlloyMaintenance);
			ReadResourcePair(luaState, parentIndex, "storage", out data.EnergyStorage, out data.AlloyStorage);
			LuaJIT.lua_pop(luaState, 1);
		}
	}

	private static void ReadResourcePair(lua_State luaState, int parentIndex, string field, out float? energy, out float? alloy)
	{
		energy = null;
		alloy = null;
		if (PushTableField(luaState, parentIndex, field))
		{
			int parentIndex2 = AbsoluteIndex(luaState, -1);
			energy = ReadNumberField(luaState, parentIndex2, "energy");
			alloy = ReadNumberField(luaState, parentIndex2, "alloys");
			LuaJIT.lua_pop(luaState, 1);
		}
	}

	private static void ReadMovement(lua_State luaState, int unitIndex, UnitTooltipData data)
	{
		if (PushTableField(luaState, unitIndex, "movement"))
		{
			int parentIndex = AbsoluteIndex(luaState, -1);
			data.MovementType = ReadStringField(luaState, parentIndex, "type");
			data.Speed = ReadNumberField(luaState, parentIndex, "speed");
			data.Acceleration = ReadNumberField(luaState, parentIndex, "acceleration");
			LuaJIT.lua_pop(luaState, 1);
		}
	}

	private static void ReadIntel(lua_State luaState, int unitIndex, UnitTooltipData data)
	{
		if (PushTableField(luaState, unitIndex, "intel"))
		{
			int parentIndex = AbsoluteIndex(luaState, -1);
			data.VisionRadius = ReadNumberField(luaState, parentIndex, "visionRadius");
			data.RadarRadius = ReadNumberField(luaState, parentIndex, "radarRadius");
			data.SonarRadius = ReadNumberField(luaState, parentIndex, "sonarRadius");
			LuaJIT.lua_pop(luaState, 1);
		}
	}

	private static void ReadConstruction(lua_State luaState, int unitIndex, UnitTooltipData data)
	{
		if (PushTableField(luaState, unitIndex, "construction"))
		{
			int parentIndex = AbsoluteIndex(luaState, -1);
			data.BuildPower = ReadNumberField(luaState, parentIndex, "buildPower");
			data.BuildRange = ReadNumberField(luaState, parentIndex, "range");
			LuaJIT.lua_pop(luaState, 1);
		}
	}

	private static void ReadWeapons(lua_State luaState, int unitIndex, UnitTooltipData data)
	{
		if (!PushTableField(luaState, unitIndex, "weapons"))
		{
			return;
		}
		int num = AbsoluteIndex(luaState, -1);
		int num2 = BoundedArrayLength(luaState, num, 64);
		for (int i = 1; i <= num2; i++)
		{
			LuaJIT.lua_rawgeti(luaState, num, i);
			if (LuaJIT.lua_istable(luaState, -1) != 0)
			{
				UnitWeaponStats unitWeaponStats = ReadWeapon(luaState, AbsoluteIndex(luaState, -1));
				if (!string.Equals(unitWeaponStats.Category, "DeathExplosion", StringComparison.OrdinalIgnoreCase) && (unitWeaponStats.Damage > 0f || unitWeaponStats.DamageOverTime > 0f))
				{
					unitWeaponStats.Dps = UnitTooltipFormatter.CalculateDps(unitWeaponStats);
					data.Weapons.Add(unitWeaponStats);
				}
			}
			LuaJIT.lua_pop(luaState, 1);
		}
		LuaJIT.lua_pop(luaState, 1);
	}

	private static UnitWeaponStats ReadWeapon(lua_State luaState, int weaponIndex)
	{
		UnitWeaponStats unitWeaponStats = new UnitWeaponStats
		{
			Category = ReadStringField(luaState, weaponIndex, "category"),
			DamageType = ReadStringField(luaState, weaponIndex, "damageType"),
			Damage = ReadNumberField(luaState, weaponIndex, "damage").GetValueOrDefault(),
			DamageRadius = ReadNumberField(luaState, weaponIndex, "damageRadius").GetValueOrDefault(),
			RangeMin = ReadNumberField(luaState, weaponIndex, "rangeMin").GetValueOrDefault(),
			RangeMax = ReadNumberField(luaState, weaponIndex, "rangeMax").GetValueOrDefault(),
			ReloadTime = (ReadNumberField(luaState, weaponIndex, "reloadTime") ?? 1f),
			SalvoSize = (int)Math.Round(ReadNumberField(luaState, weaponIndex, "muzzleSalvoSize") ?? 1f),
			SalvoDelay = ReadNumberField(luaState, weaponIndex, "muzzleSalvoDelay").GetValueOrDefault(),
			BeamLifetime = ReadNumberField(luaState, weaponIndex, "beamLifetime").GetValueOrDefault()
		};
		float valueOrDefault = ReadNumberField(luaState, weaponIndex, "damageOverTimePulseCount").GetValueOrDefault();
		float valueOrDefault2 = ReadNumberField(luaState, weaponIndex, "damageOverTimePulseDamage").GetValueOrDefault();
		unitWeaponStats.DamageOverTime = valueOrDefault * valueOrDefault2;
		unitWeaponStats.MuzzleCount = ReadMuzzleCount(luaState, weaponIndex, unitWeaponStats.SalvoSize);
		unitWeaponStats.TargetLayers = ReadStringArrayField(luaState, weaponIndex, "layerTargetLimits", 16);
		string text = ReadStringField(luaState, weaponIndex, "name");
		if (string.IsNullOrWhiteSpace(text))
		{
			text = ReadStringField(luaState, weaponIndex, "label");
		}
		if (string.IsNullOrWhiteSpace(text))
		{
			text = ReadStringField(luaState, weaponIndex, "rangeRingType");
		}
		unitWeaponStats.Label = FriendlyWeaponLabel(text, unitWeaponStats.TargetLayers);
		return unitWeaponStats;
	}

	private static int ReadMuzzleCount(lua_State luaState, int weaponIndex, int salvoSize)
	{
		if (!PushTableField(luaState, weaponIndex, "muzzleGroups"))
		{
			return salvoSize;
		}
		int num = AbsoluteIndex(luaState, -1);
		int num2 = BoundedArrayLength(luaState, num, 64);
		if (num2 < 1)
		{
			LuaJIT.lua_pop(luaState, 1);
			return salvoSize;
		}
		int num3 = 0;
		for (int i = 1; i <= salvoSize; i++)
		{
			int n = (i - 1) % num2 + 1;
			LuaJIT.lua_rawgeti(luaState, num, n);
			if (LuaJIT.lua_istable(luaState, -1) != 0)
			{
				int num4 = AbsoluteIndex(luaState, -1);
				if (PushTableField(luaState, num4, "muzzles"))
				{
					num3 += BoundedArrayLength(luaState, AbsoluteIndex(luaState, -1), 128);
					LuaJIT.lua_pop(luaState, 1);
				}
				else
				{
					num3 += BoundedArrayLength(luaState, num4, 128);
				}
			}
			LuaJIT.lua_pop(luaState, 1);
		}
		LuaJIT.lua_pop(luaState, 1);
		return num3;
	}

	private static string ReadStringArrayField(lua_State luaState, int parentIndex, string field, int maximum)
	{
		if (!PushTableField(luaState, parentIndex, field))
		{
			return string.Empty;
		}
		int num = AbsoluteIndex(luaState, -1);
		int num2 = BoundedArrayLength(luaState, num, maximum);
		List<string> list = new List<string>(num2);
		for (int i = 1; i <= num2; i++)
		{
			LuaJIT.lua_rawgeti(luaState, num, i);
			string text = ReadString(luaState, -1);
			LuaJIT.lua_pop(luaState, 1);
			if (!string.IsNullOrWhiteSpace(text))
			{
				list.Add(text);
			}
		}
		LuaJIT.lua_pop(luaState, 1);
		return string.Join(",", list.ToArray());
	}

	private static string FriendlyWeaponLabel(string label, string targetLayers)
	{
		string text = (label ?? string.Empty).Trim();
		if (text.Length == 0)
		{
			if (targetLayers.IndexOf("Air", StringComparison.OrdinalIgnoreCase) >= 0)
			{
				return "Anti-air weapon";
			}
			if (targetLayers.IndexOf("Water", StringComparison.OrdinalIgnoreCase) >= 0)
			{
				return "Anti-naval weapon";
			}
			return "Weapon system";
		}
		return text.ToUpperInvariant() switch
		{
			"ANTIAIR" => "Anti-air weapon", 
			"DIRECTFIRE" => "Direct-fire weapon", 
			"INDIRECTFIRE" => "Indirect-fire weapon", 
			"TORPEDO" => "Torpedo weapon", 
			_ => SplitIdentifier(text), 
		};
	}

	private static string SplitIdentifier(string value)
	{
		StringBuilder stringBuilder = new StringBuilder(value.Length + 8);
		for (int i = 0; i < value.Length; i++)
		{
			char c = value[i];
			if (c == '_' || c == '-')
			{
				stringBuilder.Append(' ');
				continue;
			}
			if (i > 0 && char.IsUpper(c) && char.IsLower(value[i - 1]))
			{
				stringBuilder.Append(' ');
			}
			stringBuilder.Append(c);
		}
		string text = stringBuilder.ToString().Trim();
		if (text.Length == 0)
		{
			return "Weapon system";
		}
		return char.ToUpperInvariant(text[0]) + text.Substring(1);
	}

	private static bool PushTableField(lua_State luaState, int parentIndex, string field)
	{
		PushRawField(luaState, parentIndex, field);
		if (LuaJIT.lua_istable(luaState, -1) != 0)
		{
			return true;
		}
		LuaJIT.lua_pop(luaState, 1);
		return false;
	}

	private static string ReadStringField(lua_State luaState, int parentIndex, string field)
	{
		PushRawField(luaState, parentIndex, field);
		string result = ReadString(luaState, -1);
		LuaJIT.lua_pop(luaState, 1);
		return result;
	}

	private static string ReadString(lua_State luaState, int index)
	{
		if (LuaJIT.lua_isstring(luaState, index) == 0)
		{
			return string.Empty;
		}
		return LuaJIT.lua_tostring(luaState, index) ?? string.Empty;
	}

	private static float? ReadNumberField(lua_State luaState, int parentIndex, string field)
	{
		PushRawField(luaState, parentIndex, field);
		float? result = null;
		if (LuaJIT.lua_isnumber(luaState, -1) != 0)
		{
			double num = LuaJIT.lua_tonumber(luaState, -1);
			if (!double.IsNaN(num) && !double.IsInfinity(num) && num <= 3.4028234663852886E+38 && num >= -3.4028234663852886E+38)
			{
				result = (float)num;
			}
		}
		LuaJIT.lua_pop(luaState, 1);
		return result;
	}

	private static int BoundedArrayLength(lua_State luaState, int tableIndex, int maximum)
	{
		ulong num = LuaJIT.lua_objlen(luaState, tableIndex);
		if (num > (ulong)maximum)
		{
			return maximum;
		}
		return (int)num;
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

	private static bool IsSafeTemplateId(string templateId)
	{
		if (string.IsNullOrWhiteSpace(templateId) || templateId.Length > 64)
		{
			return false;
		}
		foreach (char c in templateId)
		{
			bool num = (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z');
			bool flag = c >= '0' && c <= '9';
			if (!num && !flag && c != '_' && c != '-')
			{
				return false;
			}
		}
		return true;
	}
}
