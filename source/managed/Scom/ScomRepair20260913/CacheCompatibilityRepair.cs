using System;
using System.IO;
using System.Resources;
using System.Text;
using System.Text.RegularExpressions;
using ScomFieldFixes;
using SupremeCommanderOverhaulFieldFixes;
using SupremeCommanderOverhaulSeaParity;

namespace ScomRepair20260913;

internal static class CacheCompatibilityRepair
{
	public static string[] Lex(string P_0)
	{
		if (P_0 != null && P_0.Length <= 2000000)
		{
			MatchCollection matchCollection = Regex.Matches(P_0, "\\G(?:(?<skip>\\s+|--\\[(?<ceq>=*)\\[[\\s\\S]*?\\]\\k<ceq>\\]|--(?!\\[=*\\[)[^\\r\\n]*)|\"(?:\\\\[\\s\\S]|[^\"\\\\])*\"|'(?:\\\\[\\s\\S]|[^'\\\\])*'|\\[(?<seq>=*)\\[[\\s\\S]*?\\]\\k<seq>\\]|[A-Za-z_][A-Za-z_0-9]*|(?:0[xX][0-9a-fA-F]+|[0-9]+(?:\\.[0-9]*)?(?:[eE][+-]?[0-9]+)?)|(?!\\[=*\\[)[^\\s\"'])");
			string[] array = new string[matchCollection.Count + 1];
			int i = 0;
			int num = 0;
			int num2 = 0;
			for (; i < matchCollection.Count; i++)
			{
				Match match = matchCollection[i];
				num2 = match.Index + match.Length;
				if (!match.Groups["skip"].Success)
				{
					array[num] = match.Value;
					num++;
				}
			}
			if (num2 == P_0.Length)
			{
				return array;
			}
		}
		throw new InvalidOperationException("Cache repair rejected an empty, oversized, or lexically incomplete Lua resource.");
	}

	public static string PlainString(string P_0)
	{
		if (P_0 != null)
		{
			int length = P_0.Length;
			if (length >= 2)
			{
				int num = P_0[0];
				if ((num == 34 || num == 39) && P_0[length - 1] == num && P_0.IndexOf("\\", StringComparison.Ordinal) < 0)
				{
					return P_0.Substring(1, length - 2);
				}
			}
		}
		return null;
	}

	public static string LastStringAssignment(string P_0, string P_1)
	{
		string[] array = Lex(P_0);
		string result = null;
		for (int i = 0; i + 2 < array.Length; i++)
		{
			if (array[i] == P_1)
			{
				if (array[i + 1] == "=")
				{
					result = PlainString(array[i + 2]);
				}
			}
			else if (i + 4 < array.Length && array[i + 0] == "[" && array[i + 2] == "]" && array[i + 3] == "=" && PlainString(array[i + 1]) == P_1)
			{
				result = PlainString(array[i + 4]);
			}
		}
		return result;
	}

	public static bool HasString(string P_0, string P_1)
	{
		string[] array = Lex(P_0);
		int num = 0;
		while (true)
		{
			if (num < array.Length)
			{
				if (PlainString(array[num]) == P_1)
				{
					break;
				}
				num++;
				continue;
			}
			return false;
		}
		return true;
	}

	public static bool HasWord(string P_0, string P_1)
	{
		string[] array = Lex(P_0);
		int num = 0;
		while (true)
		{
			if (num < array.Length)
			{
				if (array[num] == P_1)
				{
					break;
				}
				num++;
				continue;
			}
			return false;
		}
		return true;
	}

	public static string LastClass(string P_0)
	{
		string[] array = Lex(P_0);
		string text = null;
		string text2 = null;
		for (int i = 0; i + 5 < array.Length; i++)
		{
			if (!(array[i] == "class"))
			{
				continue;
			}
			if (array[i + 1] == "=")
			{
				text = null;
				text2 = null;
				if (array[i + 2] == "{" && array[i + 4] == ",")
				{
					text = PlainString(array[i + 3]);
					text2 = PlainString(array[i + 5]);
				}
			}
			else if (array[i + 1] == "[" && array[i + 3] == "]" && array[i + 4] == "=")
			{
				if (array[i + 2] == "1")
				{
					text = PlainString(array[i + 5]);
				}
				else if (array[i + 2] == "2")
				{
					text2 = PlainString(array[i + 5]);
				}
			}
		}
		if (text != null && text2 != null)
		{
			return text + ":" + text2;
		}
		return null;
	}

	public static void RequireUnit(string P_0, string P_1, string P_2, string P_3)
	{
		if (HasWord(P_0, "UnitTemplate") && LastStringAssignment(P_0, "tpId") == P_1)
		{
			string text = LastClass(P_0);
			if (text != null && P_2.IndexOf("|" + text + "|", StringComparison.Ordinal) >= 0 && HasString(P_0, P_3))
			{
				return;
			}
		}
		throw new InvalidOperationException("Cache repair refused incompatible unit identity, class, or faction: " + P_1);
	}

	public static void RequirePrometheanUnit(string P_0, string P_1)
	{
		if (HasWord(P_0, "UnitTemplate") && LastStringAssignment(P_0, "tpId") == P_1 && LastClass(P_0) != null && (HasString(P_0, "PROMETHEAN") || HasString(P_0, "PROMETHEANS")))
		{
			return;
		}
		throw new InvalidOperationException("Existing resource is not an identified Promethean unit: " + P_1);
	}

	public static void RequireMegalithInput(string P_0, string P_1, bool P_2, string P_3)
	{
		if (P_2)
		{
			if (P_1 == "ugl4002")
			{
				RequireUnit(P_0, P_1, "|unitsDefaultGuard:GuardFaCybranMegalith|unitsDefaultGuard:GuardLandUnit|", "GUARD");
				return;
			}
			RequireUnit(P_0, P_1, "|unitsDefaultGuard:GuardMegalithEgg|", "GUARD");
			if (HasString(P_0, "MEGALITH_EGG"))
			{
				return;
			}
		}
		else if (HasWord(P_0, "ProjectileTemplate") && LastStringAssignment(P_0, "tpId") == P_1)
		{
			string text = LastStringAssignment(P_0, "sourceId");
			if (text != null && text == LastStringAssignment(P_3, "sourceId"))
			{
				return;
			}
			text = LastStringAssignment(P_0, "name");
			if (text != null && text.IndexOf("Megalith", StringComparison.Ordinal) == 0)
			{
				return;
			}
		}
		throw new InvalidOperationException("Megalith migration refused a resource with a different identity or role.");
	}

	public static void RequireSeaInput(string P_0, string P_1, SeaTemplateSpec P_2)
	{
		string factionTag = P_2.FactionTag;
		string text = "|" + LastClass(P_1) + "|";
		text = string.Concat(text + P_2.ClassModule + ":", P_2.RuntimeClass, "|");
		string text2 = ((!(factionTag == "EDA")) ? "unitsDefaultGuard:Guard" : "unitsDefaultEDA:EDA");
		if (P_2.Kind == SeaTemplateKind.NavalUnit)
		{
			text = text + text2 + "NavalUnit|";
		}
		else
		{
			text = text + text2 + "NavalFactory|";
			text = text + text2 + "AirFactory|";
			text = text + text2 + "Structure|";
		}
		RequireUnit(P_0, P_2.TargetId, text, factionTag);
	}

	public static string AppendStartupDiagnostics(string P_0)
	{
		if (P_0.IndexOf("-- SCOM startup prefab diagnostics 2.1.88.4", StringComparison.Ordinal) >= 0)
		{
			return P_0;
		}
		return P_0 + "\n\n-- SCOM startup prefab diagnostics 2.1.88.4\ndo\n    local original = CreateUnitPrefab\n    if type(original) ~= \"function\" then\n        error(\"SCOM startup: completed prefab loader is unavailable\", 0)\n    end\n    CreateUnitPrefab = function(tp)\n        local id = type(tp) == \"table\" and type(tp.general) == \"table\"\n            and tp.general.tpId or \"<missing template identity>\"\n        local ok, errorCode, prefabId = pcall(original, tp)\n        if not ok then\n            error(\"SCOM startup prefab \" .. tostring(id) .. \": \" .. tostring(errorCode), 0)\n        end\n        return errorCode, prefabId\n    end\nend\n";
	}

	internal static string CanonicalLuaForProgress(string P_0)
	{
		return string.Join(" ", Lex(P_0));
	}

	internal static int LastCodeDeclarationIndex(string P_0, string P_1, string P_2)
	{
		MatchCollection matchCollection = Regex.Matches(P_0, "\"(?:\\\\[\\s\\S]|[^\"\\\\])*\"|'(?:\\\\[\\s\\S]|[^'\\\\])*'|\\[(?<longEq>=*)\\[[\\s\\S]*?\\]\\k<longEq>\\]|(?<decl>(?<![A-Za-z0-9_])" + Regex.Escape(P_1) + ")");
		int i = 0;
		int num = -1;
		for (; i < matchCollection.Count; i++)
		{
			Match match = matchCollection[i];
			if (match.Groups["decl"].Success)
			{
				num = match.Index;
			}
		}
		if (num < 0)
		{
			throw new InvalidOperationException(P_2 + " has no active literal declaration.");
		}
		return num;
	}

	internal static string AppendTypedEffectPreload(string P_0)
	{
		if (P_0.IndexOf("-- SCOM typed effect preload 2.1.88.5", StringComparison.Ordinal) >= 0)
		{
			return P_0;
		}
		if (P_0.IndexOf("function LoadUnitEffects(", StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("SCOM typed effect preload: required native loader declaration is missing: function LoadUnitEffects(");
		}
		if (P_0.IndexOf("function LoadEffect(", StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("SCOM typed effect preload: required native loader declaration is missing: function LoadEffect(");
		}
		return P_0 + "\n-- SCOM typed effect preload 2.1.88.5\ndo\n    local previousLoadUnitEffects = LoadUnitEffects\n    local previousLoadEffect = LoadEffect\n    assert(type(previousLoadUnitEffects) == \"function\" and type(previousLoadEffect) == \"function\",\n        \"SCOM typed effect preload: native loader functions are unavailable\")\n\n    local function copy(value)\n        local result = {}\n        for key, item in pairs(value) do result[key] = item end\n        return result\n    end\n    local function requirePath(value, context)\n        if type(value) ~= \"string\" or #value == 0 or string.find(value, \"\\0\", 1, true) then\n            error(\"SCOM effect asset must be a nonempty string at \" .. context .. \"; received \" .. type(value), 0)\n        end\n        return value\n    end\n    local function scalarDescriptor(value, context)\n        if type(value) == \"string\" then return requirePath(value, context) end\n        if type(value) ~= \"table\" then return requirePath(value, context) end\n        -- Only lossless single-path wrappers are convertible. Multiple effects,\n        -- transform descriptors and arbitrary tables are not silently discarded.\n        local key, path = next(value)\n        if key ~= nil and next(value, key) == nil\n            and (key == 1 or key == \"particleName\" or key == \"path\") then\n            return requirePath(path, context .. \".\" .. tostring(key))\n        end\n        error(\"SCOM unsupported effect descriptor at \" .. context .. \"; an actual asset path is required\", 0)\n    end\n\n    LoadEffect = function(path)\n        return previousLoadEffect(requirePath(path, \"LoadEffect\"))\n    end\n\n    LoadUnitEffects = function(templates)\n        assert(type(templates) == \"table\", \"SCOM effect preload requires a template table\")\n        local views, pending = {}, {}\n        for id, tp in pairs(templates) do\n            assert(type(tp) == \"table\", \"SCOM effect preload found a non-table template: \" .. tostring(id))\n            local unitId = tp.general and tp.general.tpId or tostring(id)\n            local view = copy(tp)\n            if tp.weapons ~= nil then\n                assert(type(tp.weapons) == \"table\", \"SCOM invalid weapons table: \" .. unitId)\n                local weapons = {}\n                for index, weapon in ipairs(tp.weapons) do\n                    assert(type(weapon) == \"table\", \"SCOM invalid weapon: \" .. unitId .. \":\" .. index)\n                    local weaponView = copy(weapon)\n                    if weapon.effects ~= nil then\n                        assert(type(weapon.effects) == \"table\", \"SCOM invalid weapon effects: \" .. unitId .. \":\" .. index)\n                        local effectView, actualEffects = {}, nil\n                        for key, value in pairs(weapon.effects) do\n                            local context = unitId .. \".weapons[\" .. index .. \"].effects.\" .. tostring(key)\n                            local runtimeId = type(key) == \"string\" and string.sub(key, -8) == \"PrefabID\"\n                            local event = type(key) == \"string\" and string.sub(key, 1, 2) == \"on\"\n                            if runtimeId then\n                                -- GetOrCreateVFXPrefab writes LocalID handles into this\n                                -- same dictionary. These are never resource filenames.\n                            elseif type(value) == \"string\" then\n                                effectView[key] = requirePath(value, context)\n                            elseif event and value ~= false then\n                                local path = scalarDescriptor(value, context)\n                                effectView[key] = path\n                                actualEffects = actualEffects or copy(weapon.effects)\n                                actualEffects[key] = path\n                            elseif event or type(value) == \"table\" or type(value) == \"number\"\n                                or type(value) == \"boolean\" or type(value) == \"cdata\" then\n                                -- Disabled events and non-event source metadata stay on\n                                -- the real template, but do not cross the UTF-8 FFI API.\n                            else\n                                error(\"SCOM unsupported effect field at \" .. context .. \": \" .. type(value), 0)\n                            end\n                        end\n                        if actualEffects then\n                            pending[#pending + 1] = { weapon = weapon, effects = actualEffects }\n                        end\n                        weaponView.effects = effectView\n                    end\n                    weapons[index] = weaponView\n                end\n                view.weapons = weapons\n            end\n            -- Validate the native visual paths with a precise unit/slot context.\n            local visuals = tp.visuals or {}\n            local deaths = visuals.effectsInstant and visuals.effectsInstant.onDeath or {}\n            for index, effect in pairs(deaths) do\n                requirePath(type(effect) == \"table\" and effect.particleName,\n                    unitId .. \".visuals.effectsInstant.onDeath[\" .. tostring(index) .. \"]\")\n            end\n            for _, slot in ipairs({ \"effectsPersistent\", \"effectsWhenActive\" }) do\n                for index, effect in pairs(visuals[slot] or {}) do\n                    requirePath(type(effect) == \"table\" and effect.particleName,\n                        unitId .. \".visuals.\" .. slot .. \"[\" .. tostring(index) .. \"]\")\n                end\n            end\n            views[id] = view\n        end\n        -- Keep the native traversal and all its additional preload behavior.\n        -- Commit lossless event unwrapping only after every input was validated\n        -- and the native preload succeeded. Do not swallow native load failures.\n        local result = previousLoadUnitEffects(views)\n        for _, update in ipairs(pending) do update.weapon.effects = update.effects end\n        return result\n    end\nend\n";
	}

	internal static string NormalizeMockHydroText(string P_0)
	{
		return P_0.Replace("\r\n", "\n").Replace("\r", "\n");
	}

	internal static string AppendMockHydroPolicy(string P_0, string P_1, string P_2)
	{
		if (string.IsNullOrWhiteSpace(P_0))
		{
			throw new InvalidOperationException("SCOM mock Hydro: input source is empty.");
		}
		string text = NormalizeMockHydroText(P_0).Replace(P_2, "");
		if (text.IndexOf("-- Supreme Commander Overhaul hydro build disable 1.0.0", StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("SCOM mock Hydro: unrecognized legacy disable block; refusing a partial migration.");
		}
		if (CountMockHydroToken(text, "-- SCOM mock Hydro placement 2.1.88.6") != 0)
		{
			if (CountMockHydroToken(text, "-- SCOM mock Hydro placement 2.1.88.6") == 1 && text.IndexOf(P_1, StringComparison.Ordinal) >= 0)
			{
				return text;
			}
			throw new InvalidOperationException("SCOM mock Hydro: duplicate or altered policy block.");
		}
		return text + P_1;
	}

	internal static string ReadMockHydroResource(string P_0)
	{
		return P_0 switch
		{
			"ScomFieldFixes.Roster.Hydro.ucs1614.lua" => "-- SCOM mock Hydro 2.1.88.6: native land placement; source provenance retained.\nassert(UnitTemplate.general.tpId==\"ucs1614\",\"Hydro source identity changed\")\nUnitTemplate.additions=UnitTemplate.additions or {}\nUnitTemplate.additions.scoHydroPlacement={[\"sourceId\"]=\"UAB1102\",[\"targetId\"]=\"ucs1614\",[\"sourceBlueprint\"]={[\"archive\"]=\"units.scd\",[\"entry\"]=\"units/UAB1102/UAB1102_unit.bp\",[\"sha256\"]=\"226e38c51f687f906d0d30ba449d032223b40eed65aaff7bb8c0607b021f25b6\",[\"bytes\"]=5485},[\"sourceRequirement\"]=\"RULEUBR_OnHydrocarbonDeposit\",[\"normalConstructionSupported\"]=true,[\"reason\"]=\"Mock Hydro uses ordinary native land placement; no deposit is required.\",[\"creativeDirectSpawnPreserved\"]=true,[\"nativeResourceTypes\"]={\"alloys\"},[\"fallback\"]=\"mock_land_placement\"}\nUnitTemplate.additions.faHydrocarbonPlacement={sourceRequirement=\"hydrocarbon_deposit\",supported=true,mock=true,nativeResourceSupported=false,fallback=\"mock_land_placement\"}\nImport(\"common/systems/scoSourceHydroPlacement.lua\").PrepareTemplate(UnitTemplate)\n", 
			"ScomFieldFixes.Roster.Hydro.ues5015.lua" => "-- SCOM mock Hydro 2.1.88.6: native land placement; source provenance retained.\nassert(UnitTemplate.general.tpId==\"ues5015\",\"Hydro source identity changed\")\nUnitTemplate.additions=UnitTemplate.additions or {}\nUnitTemplate.additions.scoHydroPlacement={[\"sourceId\"]=\"UEB1102\",[\"targetId\"]=\"ues5015\",[\"sourceBlueprint\"]={[\"archive\"]=\"units.scd\",[\"entry\"]=\"units/UEB1102/UEB1102_unit.bp\",[\"sha256\"]=\"c881c49165ff33b9644eb62910fad3ed2075fdf732f1fc5dceb028b673f710fc\",[\"bytes\"]=5342},[\"sourceRequirement\"]=\"RULEUBR_OnHydrocarbonDeposit\",[\"normalConstructionSupported\"]=true,[\"reason\"]=\"Mock Hydro uses ordinary native land placement; no deposit is required.\",[\"creativeDirectSpawnPreserved\"]=true,[\"nativeResourceTypes\"]={\"alloys\"},[\"fallback\"]=\"mock_land_placement\"}\nUnitTemplate.additions.faHydrocarbonPlacement={sourceRequirement=\"hydrocarbon_deposit\",supported=true,mock=true,nativeResourceSupported=false,fallback=\"mock_land_placement\"}\nImport(\"common/systems/scoSourceHydroPlacement.lua\").PrepareTemplate(UnitTemplate)\n", 
			"ScomFieldFixes.Roster.Hydro.ugs5003.lua" => "-- SCOM mock Hydro 2.1.88.6: native land placement; source provenance retained.\nassert(UnitTemplate.general.tpId==\"ugs5003\",\"Hydro source identity changed\")\nUnitTemplate.additions=UnitTemplate.additions or {}\nUnitTemplate.additions.scoHydroPlacement={[\"sourceId\"]=\"URB1102\",[\"targetId\"]=\"ugs5003\",[\"sourceBlueprint\"]={[\"archive\"]=\"units.scd\",[\"entry\"]=\"units/URB1102/URB1102_unit.bp\",[\"sha256\"]=\"5d744a449a2f1c66a8523324b5f37581b2bea656169fc6c260b7d096316bcd99\",[\"bytes\"]=5202},[\"sourceRequirement\"]=\"RULEUBR_OnHydrocarbonDeposit\",[\"normalConstructionSupported\"]=true,[\"reason\"]=\"Mock Hydro uses ordinary native land placement; no deposit is required.\",[\"creativeDirectSpawnPreserved\"]=true,[\"nativeResourceTypes\"]={\"alloys\"},[\"fallback\"]=\"mock_land_placement\"}\nUnitTemplate.additions.faHydrocarbonPlacement={sourceRequirement=\"hydrocarbon_deposit\",supported=true,mock=true,nativeResourceSupported=false,fallback=\"mock_land_placement\"}\nImport(\"common/systems/scoSourceHydroPlacement.lua\").PrepareTemplate(UnitTemplate)\n", 
			"ScomFieldFixes.Roster.Hydro.uss1614.lua" => "-- SCOM mock Hydro 2.1.88.6: native land placement; source provenance retained.\nassert(UnitTemplate.general.tpId==\"uss1614\",\"Hydro source identity changed\")\nUnitTemplate.additions=UnitTemplate.additions or {}\nUnitTemplate.additions.scoHydroPlacement={[\"sourceId\"]=\"XSB1102\",[\"targetId\"]=\"uss1614\",[\"sourceBlueprint\"]={[\"archive\"]=\"units.scd\",[\"entry\"]=\"units/XSB1102/XSB1102_unit.bp\",[\"sha256\"]=\"3c83b8f1ac1224e0d65768164ff3e9b791e22ca81fa4a3d17a214a2130692473\",[\"bytes\"]=5800},[\"sourceRequirement\"]=\"RULEUBR_OnHydrocarbonDeposit\",[\"normalConstructionSupported\"]=true,[\"reason\"]=\"Mock Hydro uses ordinary native land placement; no deposit is required.\",[\"creativeDirectSpawnPreserved\"]=true,[\"nativeResourceTypes\"]={\"alloys\"},[\"fallback\"]=\"mock_land_placement\"}\nUnitTemplate.additions.faHydrocarbonPlacement={sourceRequirement=\"hydrocarbon_deposit\",supported=true,mock=true,nativeResourceSupported=false,fallback=\"mock_land_placement\"}\nImport(\"common/systems/scoSourceHydroPlacement.lua\").PrepareTemplate(UnitTemplate)\n", 
			"ScomFieldFixes.Roster.source_hydro_placement.lua" => "-- SCOM mock Hydro placement provider 2.1.88.6\nlocal policies = {[\"ucs1614\"]={[\"sourceId\"]=\"UAB1102\",[\"targetId\"]=\"ucs1614\",[\"sourceBlueprint\"]={[\"archive\"]=\"units.scd\",[\"entry\"]=\"units/UAB1102/UAB1102_unit.bp\",[\"sha256\"]=\"226e38c51f687f906d0d30ba449d032223b40eed65aaff7bb8c0607b021f25b6\",[\"bytes\"]=5485},[\"sourceRequirement\"]=\"RULEUBR_OnHydrocarbonDeposit\",[\"normalConstructionSupported\"]=true,[\"reason\"]=\"Mock Hydro uses ordinary native land placement; no deposit is required.\",[\"creativeDirectSpawnPreserved\"]=true,[\"nativeResourceTypes\"]={\"alloys\"},[\"fallback\"]=\"mock_land_placement\"},[\"ues5015\"]={[\"sourceId\"]=\"UEB1102\",[\"targetId\"]=\"ues5015\",[\"sourceBlueprint\"]={[\"archive\"]=\"units.scd\",[\"entry\"]=\"units/UEB1102/UEB1102_unit.bp\",[\"sha256\"]=\"c881c49165ff33b9644eb62910fad3ed2075fdf732f1fc5dceb028b673f710fc\",[\"bytes\"]=5342},[\"sourceRequirement\"]=\"RULEUBR_OnHydrocarbonDeposit\",[\"normalConstructionSupported\"]=true,[\"reason\"]=\"Mock Hydro uses ordinary native land placement; no deposit is required.\",[\"creativeDirectSpawnPreserved\"]=true,[\"nativeResourceTypes\"]={\"alloys\"},[\"fallback\"]=\"mock_land_placement\"},[\"ugs5003\"]={[\"sourceId\"]=\"URB1102\",[\"targetId\"]=\"ugs5003\",[\"sourceBlueprint\"]={[\"archive\"]=\"units.scd\",[\"entry\"]=\"units/URB1102/URB1102_unit.bp\",[\"sha256\"]=\"5d744a449a2f1c66a8523324b5f37581b2bea656169fc6c260b7d096316bcd99\",[\"bytes\"]=5202},[\"sourceRequirement\"]=\"RULEUBR_OnHydrocarbonDeposit\",[\"normalConstructionSupported\"]=true,[\"reason\"]=\"Mock Hydro uses ordinary native land placement; no deposit is required.\",[\"creativeDirectSpawnPreserved\"]=true,[\"nativeResourceTypes\"]={\"alloys\"},[\"fallback\"]=\"mock_land_placement\"},[\"uss1614\"]={[\"sourceId\"]=\"XSB1102\",[\"targetId\"]=\"uss1614\",[\"sourceBlueprint\"]={[\"archive\"]=\"units.scd\",[\"entry\"]=\"units/XSB1102/XSB1102_unit.bp\",[\"sha256\"]=\"3c83b8f1ac1224e0d65768164ff3e9b791e22ca81fa4a3d17a214a2130692473\",[\"bytes\"]=5800},[\"sourceRequirement\"]=\"RULEUBR_OnHydrocarbonDeposit\",[\"normalConstructionSupported\"]=true,[\"reason\"]=\"Mock Hydro uses ordinary native land placement; no deposit is required.\",[\"creativeDirectSpawnPreserved\"]=true,[\"nativeResourceTypes\"]={\"alloys\"},[\"fallback\"]=\"mock_land_placement\"}}\n-- The source rule is retained as provenance only. This mock does not fabricate\n-- a native resource type or reserve an alloy deposit. Native construction owns\n-- terrain, obstruction, faction/builder eligibility, payment, and occupancy.\nlocal M = {}\nlocal function Id(value)\n    if type(value) == \"table\" then\n        if type(value.general) == \"table\" then return value.general.tpId end\n        return value.tpId\n    end\n    if type(value) == \"string\" then return value end\nend\nfunction M.GetPolicy(value)\n    return policies[Id(value)]\nend\nfunction M.CanBuildNormally(value)\n    -- Other units are unaffected; Hydro-specific wrappers delegate to native\n    -- routines rather than reporting a fabricated positive placement result.\n    return true\nend\nlocal function Copy(value, name, id)\n    assert(value == nil or type(value) == \"table\", \"SCOM mock Hydro: invalid \" .. name .. \" (\" .. id .. \")\")\n    local result = {}\n    for key, item in pairs(value or {}) do result[key] = item end\n    return result\nend\nfunction M.PrepareTemplate(tp)\n    local id = Id(tp)\n    local policy = policies[id]\n    if not policy then return end\n    assert(type(tp) == \"table\" and type(tp.tags) == \"table\", \"SCOM mock Hydro: missing template/tags (\" .. id .. \")\")\n    assert(tp.additions == nil or type(tp.additions) == \"table\", \"SCOM mock Hydro: invalid additions (\" .. id .. \")\")\n    local additions = tp.additions or {}\n    local fa = Copy(additions.faHydrocarbonPlacement, \"faHydrocarbonPlacement\", id)\n    local sco = Copy(additions.scoHydroPlacement or policy, \"scoHydroPlacement\", id)\n    local seen = {}\n    for _, tag in ipairs(tp.tags) do\n        assert(type(tag) == \"string\", \"SCOM mock Hydro: non-string tag (\" .. id .. \")\")\n        seen[tag] = true\n    end\n    fa.sourceRequirement = \"hydrocarbon_deposit\"\n    fa.supported = true\n    fa.mock = true\n    fa.nativeResourceSupported = false\n    fa.fallback = \"mock_land_placement\"\n    sco.normalConstructionSupported = true\n    sco.mock = true\n    sco.nativeResourceSupported = false\n    sco.nativePlacementValidation = true\n    sco.creativeDirectSpawnPreserved = true\n    sco.fallback = \"mock_land_placement\"\n    sco.reason = \"Mock Hydro uses ordinary native land placement; no deposit is required.\"\n    sco.mockPlacementVersion = \"2.1.88.6\"\n    tp.additions = additions\n    additions.faHydrocarbonPlacement = fa\n    additions.scoHydroPlacement = sco\n    for _, tag in ipairs({\"BUILDABLE_BY_T1_ENGINEER\", \"BUILDABLE_BY_T2_ENGINEER\", \"BUILDABLE_BY_T3_ENGINEER\"}) do\n        if not seen[tag] then tp.tags[#tp.tags + 1] = tag; seen[tag] = true end\n    end\nend\nfor _, policy in pairs(policies) do\n    policy.mock = true\n    policy.nativeResourceSupported = false\n    policy.nativePlacementValidation = true\n    policy.mockPlacementVersion = \"2.1.88.6\"\nend\n-- Sanctuary's Import uses the module environment. Preserve that Lua 5.1 API.\nlocal moduleEnvironment = getfenv(1)\nfor name, value in pairs(M) do moduleEnvironment[name] = value end\nreturn M\n", 
			_ => null, 
		};
	}

	internal static int CountMockHydroToken(string P_0, string P_1)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = P_0.IndexOf(P_1, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += P_1.Length;
		}
		return num;
	}

	internal static string ReadOriginalFieldResource(string P_0)
	{
		using Stream stream = typeof(SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime).Assembly.GetManifestResourceStream(P_0) ?? throw new MissingManifestResourceException("Missing embedded resource " + P_0);
		using StreamReader streamReader = new StreamReader(stream, new UTF8Encoding(encoderShouldEmitUTF8Identifier: false), detectEncodingFromByteOrderMarks: true);
		return NormalizeMockHydroText(streamReader.ReadToEnd());
	}

	internal static string ReadOriginalRosterResource(string P_0)
	{
		using Stream stream = typeof(RosterContracts).Assembly.GetManifestResourceStream(P_0) ?? throw new InvalidOperationException("Missing roster resource " + P_0);
		using StreamReader streamReader = new StreamReader(stream);
		return streamReader.ReadToEnd().Replace("\r\n", "\n");
	}
}
