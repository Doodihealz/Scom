using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Resources;
using System.Text;
using ScomRepair20260913;
using SupremeCommanderOverhaul.Shared;

namespace CommanderEnhancementsCachePatcher;

public static class CachePatcherRuntime
{
	private enum Placement
	{
		Append,
		BeforeTerminalReturn
	}

	private sealed class PatchSpec
	{
		public string Path { get; }

		public string ResourceName { get; }

		public string Description { get; }

		public Placement Placement { get; }

		public string[] RequiredStockTokens { get; }

		public PatchSpec(string path, string resourceName, string description, Placement placement, params string[] requiredStockTokens)
		{
			Path = path;
			ResourceName = resourceName;
			Description = description;
			Placement = placement;
			RequiredStockTokens = requiredStockTokens;
		}
	}

	private sealed class CacheResource
	{
		public string Path { get; }

		public object Value { get; }

		public CacheResource(string path, object value)
		{
			Path = path;
			Value = value;
		}
	}

	private sealed class Mutation
	{
		public string Path { get; }

		public object? Stock { get; }

		public object Replacement { get; }

		public string Description { get; }

		public bool IsInsertion => Stock == null;

		public bool AssignmentAttempted { get; set; }

		public Mutation(string path, object? stock, object replacement, string description)
		{
			Path = path;
			Stock = stock;
			Replacement = replacement;
			Description = description;
		}
	}

	internal const string Marker = "-- Supreme Commander Overhaul commander enhancements 1.0.0";

	internal const string ContractPath = "LJ/lua/common/systems/scoCommanderEnhancements.lua";

	internal const string PodTemplatePath = "LJ/lua/common/units/unitsTemplates/uea0001/uea0001.santp";

	internal const string ShieldEntityNameMarker = "-- SCOM commander shield entity-name compatibility 1.0.0";

	internal const string TorpedoMuzzleAliasMarker = "-- SCOM commander torpedo muzzle alias 1.0.0";

	internal const string UefPodSpawnBonesMarker = "-- SCOM UEF commander pod spawn bones 1.0.0";

	internal const string TorpedoMuzzleAliasName = "SCOTorpedoMuzzle";

	internal const string TorpedoSourceMuzzleName = "Turret_Muzzle_03";

	private const string ResourcePrefix = "CommanderEnhancements.";

	private static readonly IReadOnlyDictionary<string, string[]> ResourceBundles = new Dictionary<string, string[]>(StringComparer.Ordinal)
	{
		["commander_enhancement_host_appendix.lua"] = new string[4] { "commander_enhancement_assist_appendix.lua", "commander_pod_host_appendix.lua", "commander_cloak_host_appendix.lua", "commander_ability_host_appendix.lua" },
		["commander_enhancement_commands_appendix.lua"] = new string[1] { "commander_ability_commands_appendix.lua" },
		["commander_enhancement_client_listener_appendix.lua"] = new string[1] { "commander_ability_target_input_appendix.lua" },
		["commander_enhancement_client_visual_appendix.lua"] = new string[1] { "commander_ability_client_visual_appendix.lua" },
		["commander_enhancement_construction_panel_appendix.lua"] = new string[1] { "commander_ability_ui_appendix.lua" }
	};

	private const string TerminalReturnToken = "\nreturn {";

	private static readonly string[] CommanderIds = new string[4] { "uel0000", "ugl0000", "ucl0000", "usl0000" };

	private static readonly PatchSpec[] PatchSpecs = BuildPatchSpecs();

	private static bool _isApplied;

	public static void Apply()
	{
		if (_isApplied)
		{
			return;
		}
		CommanderEnhancementRules.Validate();
		object obj = null;
		List<Mutation> list = new List<Mutation>();
		try
		{
			obj = GetLuaFileCache();
			QueueShieldEntityNameCompatibility(obj, list);
			QueueVirtualContract(obj, list);
			QueueVirtualPodTemplate(obj, list);
			PatchSpec[] patchSpecs = PatchSpecs;
			foreach (PatchSpec spec in patchSpecs)
			{
				QueuePatch(obj, list, spec);
			}
			if (list.Count == 0)
			{
				_isApplied = true;
				Log("The Forged Alliance commander-enhancement system is already active.");
			}
			else
			{
				Commit(obj, list);
				_isApplied = true;
				Log("Installed four-faction commander enhancement economy, state, effects, and native UI.");
			}
		}
		catch (Exception ex)
		{
			Exception ex2 = null;
			if (obj != null)
			{
				try
				{
					RollBackAndDispose(obj, list);
				}
				catch (Exception ex3)
				{
					ex2 = ex3;
				}
			}
			else
			{
				DisposeUncommitted(list);
			}
			if (ex2 != null)
			{
				throw new AggregateException("Commander-enhancement cache installation and rollback both failed.", ex, ex2);
			}
			throw new InvalidOperationException("Commander-enhancement cache installation failed after a complete rollback: " + ex.GetBaseException().Message, ex);
		}
	}

	private static void QueueShieldEntityNameCompatibility(object cache, ICollection<Mutation> mutations)
	{
		QueueUnitTemplateLoaderCompatibility(cache, mutations);
		QueueExactTransform(cache, mutations, "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua", "host shield entity-name lookup", "    local result = Engine.GetGlobalBone(self.id, self.tp.defence.shields[i].boneName..'ShieldEntity', bone)", "    local shieldTp = self.tp.defence.shields[i]\n    local shieldEntityName = shieldTp.entityName\n        or shieldTp.boneName..'ShieldEntity'\n    local result = Engine.GetGlobalBone(self.id, shieldEntityName, bone)", "local shieldEntityName = shieldTp.entityName", "Engine.GetGlobalBone(self.id, shieldEntityName, bone)", "rawget(_G, \"SCO_CommanderEnhancementHostTransfer\")", ("            newUnit:SCOSetVeterancyKills(self.scoVeterancyKills or 0, true)", "            newUnit:SCOSetVeterancyKills(self.scoVeterancyKills or 0, true)\n            local transfer = rawget(_G, \"SCO_CommanderEnhancementHostTransfer\")\n            if type(transfer) == \"function\" then\n                pcall(transfer, self, newUnit)\n            end"), ("        elseif self:BuildBehaviorIsValidFor(assistedUnit) then", "        elseif self.SCOHasCommanderEnhancementWork\n            and self:SCOHasCommanderEnhancementWork(assistedUnit) then\n            self:SCOAssistCommanderEnhancement(assistedUnit, 'assist')\n        elseif self:BuildBehaviorIsValidFor(assistedUnit) then"), ("function HostUnit:RepairBehaviorThread()\n    local target = self.repairBehaviorTarget", "function HostUnit:RepairBehaviorThread()\n    local target = self.repairBehaviorTarget\n    if self.SCOHasCommanderEnhancementWork\n        and self:SCOHasCommanderEnhancementWork(target) then\n        self:SCOAssistCommanderEnhancement(target, 'repair')\n        if not self.repairBehaviorIsActive then return end\n    end"), ("        self:StartRepairRoutine(target)\n        WaitUntil(function() return self:GetPause() or not self:RepairBehaviorIsValidFor(target) or not self.constructionDetectorCollider:IsCollidingWithGlobalID(target.id) end)\n\n        if self:IsRepairing(target) then\n            self:EndRepairRoutine(target)\n        end", "        if self.SCOHasCommanderEnhancementWork\n            and self:SCOHasCommanderEnhancementWork(target) then\n            self:SCOAssistCommanderEnhancement(target, 'repair')\n            if not self.repairBehaviorIsActive then return end\n        else\n            self:StartRepairRoutine(target)\n            WaitUntil(function() return self:GetPause() or not self:RepairBehaviorIsValidFor(target)\n                or not self.constructionDetectorCollider:IsCollidingWithGlobalID(target.id)\n                or (self.SCOHasCommanderEnhancementWork and self:SCOHasCommanderEnhancementWork(target)) end)\n\n            if self:IsRepairing(target) then\n                self:EndRepairRoutine(target)\n            end\n        end"));
		QueueExactTransform(cache, mutations, "LJ/lua/client/units/unitsClasses/unitsBaseClass.lua", "client shield entity-name lookup", "        local shieldLocalID = self:GetBoneId(shieldTp.boneName..'ShieldEntity')", "        local shieldEntityName = shieldTp.entityName\n            or shieldTp.boneName..'ShieldEntity'\n        local shieldLocalID = self:GetBoneId(shieldEntityName)", "local shieldEntityName = shieldTp.entityName", "self:GetBoneId(shieldEntityName)", "self:GetBoneId(shieldEntityName..'_Glow')", ("        local shieldGlowLocalID = self:GetBoneId(shieldTp.boneName..'ShieldEntity_Glow')", "        local shieldGlowLocalID = self:GetBoneId(shieldEntityName..'_Glow')"));
	}

	private static void QueueUnitTemplateLoaderCompatibility(object cache, ICollection<Mutation> mutations)
	{
		CacheResource cachedResource = GetCachedResource(cache, "LJ/lua/common/loading/unitTemplateLoader.lua", "commander shield, UEF pod bones, and Cybran torpedo muzzle compatibility");
		string text = ReadText(cachedResource.Value);
		string text2 = PatchUnitTemplateLoaderForVerification(text);
		if (!string.Equals(text, text2, StringComparison.Ordinal))
		{
			object replacement = CreateNativeArray(cachedResource.Value.GetType(), text2);
			mutations.Add(new Mutation(cachedResource.Path, cachedResource.Value, replacement, "commander shield, UEF pod bones, and Cybran torpedo muzzle compatibility"));
		}
	}

	internal static string PatchUnitTemplateLoaderForVerification(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string newValue = "    local navmapModifierTemplates = {}\n    if tp.general and tp.general.tpId == \"ugl0000\" then\n        local aliasName = \"SCOTorpedoMuzzle\"\n        local sourceName = \"Turret_Muzzle_03\"\n        local sourceIndex = entityNameToHierarchyIndex[sourceName]\n        local sourceEntity = sourceIndex and hierarchyEntities[sourceIndex]\n        if sourceEntity == nil\n            or sourceEntity.parentEntityName ~= \"Center_Turret\"\n            or entityNameToHierarchyIndex[aliasName] ~= nil\n        then\n            error(\"SCOM Cybran torpedo muzzle hierarchy drifted\")\n        end\n        table.insert(hierarchyEntities, EngineClasses.EntityTemplate(\n            aliasName, sourceName, EngineClasses.float3(),\n            1, GetIdentityQuaternion(), true))\n        entityNameToHierarchyIndex[aliasName] = #hierarchyEntities\n    end";
		string newValue2 = "    local navmapModifierTemplates = {}\n    if tp.general and tp.general.tpId == \"uel0000\" then\n        local podSpawnBones = {\n            { name = \"AttachSpecial02\", parent = \"Left_Arm_B01\" },\n            { name = \"AttachSpecial01\", parent = \"Right_Arm_B01\" },\n        }\n        for _, specification in ipairs(podSpawnBones) do\n            local index = entityNameToHierarchyIndex[specification.name]\n            local entity = index and hierarchyEntities[index]\n            if entity == nil\n                or entity.parentEntityName ~= specification.parent\n            then\n                error(\"SCOM UEF commander pod-bone hierarchy drifted: \"\n                    .. specification.name)\n            end\n            entity.forceSimulated = true\n        end\n    end";
		int num = Count(source, "-- SCOM commander shield entity-name compatibility 1.0.0");
		int num2 = Count(source, "-- SCOM commander torpedo muzzle alias 1.0.0");
		int num3 = Count(source, "-- SCOM UEF commander pod spawn bones 1.0.0");
		if (num > 1 || num2 > 1 || num3 > 1)
		{
			throw new InvalidOperationException("Commander unit-template loader compatibility markers are duplicated.");
		}
		string text = source;
		if (num == 0)
		{
			if (Count(text, "            local shieldEntityName = shield.boneName..'ShieldEntity'") != 1)
			{
				throw new InvalidOperationException("Expected exactly one stock shield entity-name lookup in unitTemplateLoader.lua.");
			}
			text = text.Replace("            local shieldEntityName = shield.boneName..'ShieldEntity'", "            local shieldEntityName = shield.entityName\n                or shield.boneName..'ShieldEntity'");
		}
		if (num2 == 0)
		{
			if (Count(text, "    local navmapModifierTemplates = {}") != 1)
			{
				throw new InvalidOperationException("Expected exactly one navmap-modifier list anchor in unitTemplateLoader.lua.");
			}
			text = text.Replace("    local navmapModifierTemplates = {}", newValue);
		}
		if (num3 == 0)
		{
			if (Count(text, "    local navmapModifierTemplates = {}") != 1)
			{
				throw new InvalidOperationException("Expected exactly one navmap-modifier list anchor for UEF pod bones in unitTemplateLoader.lua.");
			}
			text = text.Replace("    local navmapModifierTemplates = {}", newValue2);
		}
		if (num == 0)
		{
			text = text.TrimEnd(Array.Empty<char>()) + "\n\n-- SCOM commander shield entity-name compatibility 1.0.0\n";
		}
		if (num2 == 0)
		{
			text = text.TrimEnd(Array.Empty<char>()) + "\n\n-- SCOM commander torpedo muzzle alias 1.0.0\n";
		}
		if (num3 == 0)
		{
			text = text.TrimEnd(Array.Empty<char>()) + "\n\n-- SCOM UEF commander pod spawn bones 1.0.0\n";
		}
		RequireTokens(text, "commander unit-template loader compatibility", new string[14]
		{
			"local shieldEntityName = shield.entityName", "ShieldTemplateLoader.CreateShieldEntity(tp, shield, shieldEntityName", "local aliasName = \"SCOTorpedoMuzzle\"", "local sourceName = \"Turret_Muzzle_03\"", "sourceEntity.parentEntityName ~= \"Center_Turret\"", "aliasName, sourceName, EngineClasses.float3()", "1, GetIdentityQuaternion(), true", "entityNameToHierarchyIndex[aliasName] = #hierarchyEntities", "local podSpawnBones = {", "{ name = \"AttachSpecial02\", parent = \"Left_Arm_B01\" }",
			"{ name = \"AttachSpecial01\", parent = \"Right_Arm_B01\" }", "local entity = index and hierarchyEntities[index]", "entity.parentEntityName ~= specification.parent", "entity.forceSimulated = true"
		});
		if (Count(text, "-- SCOM commander shield entity-name compatibility 1.0.0") != 1 || Count(text, "-- SCOM commander torpedo muzzle alias 1.0.0") != 1 || Count(text, "-- SCOM UEF commander pod spawn bones 1.0.0") != 1)
		{
			throw new InvalidOperationException("Commander unit-template loader compatibility markers were not installed exactly once.");
		}
		return EnsureTerminalNewline(text);
	}

	private static void QueueExactTransform(object cache, ICollection<Mutation> mutations, string path, string description, string oldValue, string newValue, string requiredToken, string secondRequiredToken, string? thirdRequiredToken = null, (string Old, string New)? secondReplacement = null, params (string Old, string New)[] additionalReplacements)
	{
		CacheResource cachedResource = GetCachedResource(cache, path, description);
		string text = ReadText(cachedResource.Value);
		int num = Count(text, "-- SCOM commander shield entity-name compatibility 1.0.0");
		switch (num)
		{
		case 1:
			RequireTokens(text, description, additionalReplacements.Select(((string Old, string New) item) => item.New));
			RequireTokens(text, description, new string[2] { requiredToken, secondRequiredToken }.Concat((thirdRequiredToken == null) ? Array.Empty<string>() : new string[1] { thirdRequiredToken }));
			break;
		default:
			throw new InvalidOperationException($"Expected zero or one shield compatibility marker in {description}; found {num}.");
		case 0:
		{
			if (Count(text, oldValue) != 1)
			{
				throw new InvalidOperationException("Expected exactly one stock shield lookup in " + description + ".");
			}
			string text2 = text.Replace(oldValue, newValue);
			if (secondReplacement.HasValue)
			{
				if (Count(text2, secondReplacement.Value.Old) != 1)
				{
					throw new InvalidOperationException("Expected exactly one stock shield-glow lookup in " + description + ".");
				}
				text2 = text2.Replace(secondReplacement.Value.Old, secondReplacement.Value.New);
			}
			for (int i = 0; i < additionalReplacements.Length; i++)
			{
				(string, string) tuple = additionalReplacements[i];
				if (Count(text2, tuple.Item1) != 1)
				{
					throw new InvalidOperationException("Expected one native assist dispatch in " + description + ".");
				}
				text2 = text2.Replace(tuple.Item1, tuple.Item2);
			}
			text2 = text2.TrimEnd(Array.Empty<char>()) + "\n\n-- SCOM commander shield entity-name compatibility 1.0.0\n";
			RequireTokens(text2, description, new string[2] { requiredToken, secondRequiredToken }.Concat((thirdRequiredToken == null) ? Array.Empty<string>() : new string[1] { thirdRequiredToken }));
			object replacement = CreateNativeArray(cachedResource.Value.GetType(), text2);
			mutations.Add(new Mutation(cachedResource.Path, cachedResource.Value, replacement, description));
			break;
		}
		}
	}

	private static PatchSpec[] BuildPatchSpecs()
	{
		List<PatchSpec> list = new List<PatchSpec>();
		list.Add(new PatchSpec("LJ/lua/common/systems/import.lua", "commander_enhancement_import_appendix.lua", "UEA0001 virtual unit-template directory scanner", Placement.Append, "function ScanDir(directory)", "Engine.GetFoldersInsideDirectory"));
		string[] commanderIds = CommanderIds;
		foreach (string text in commanderIds)
		{
			list.Add(new PatchSpec("LJ/lua/common/units/unitsTemplates/" + text + "/" + text + ".santp", "commander_enhancement_template_appendix.lua", text + " enhancement template contract", Placement.Append, "UnitTemplate", text));
		}
		list.Add(new PatchSpec("LJ/lua/host/units/unitsClasses/unitsDefault.lua", "commander_enhancement_host_appendix.lua", "authoritative commander enhancement lifecycle", Placement.Append, "HostCommander = Class(\"Commander\", HostEngineer)", "function HostCommander:OnStopBeingBuilt()"));
		list.Add(new PatchSpec("LJ/lua/host/units/weaponsClasses/beam.lua", "commander_enhancement_beam_appendix.lua", "scoped Cybran commander microwave beam cadence", Placement.BeforeTerminalReturn, "function HostBeam:Update()", "return {", "CreateHostBeam = CreateHostBeam"));
		list.Add(new PatchSpec("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "commander_enhancement_weapon_target_appendix.lua", "scoped commander anti-naval target filter", Placement.Append, "HostWeapon = Class(\"Weapon\")", "function HostWeapon:CanShootAt(targetUnit)"));
		list.Add(new PatchSpec("LJ/lua/host/collisionUpdate.lua", "commander_ability_collision_appendix.lua", "host-authoritative counted commander missile impacts", Placement.BeforeTerminalReturn, "function ProcessRayCollisionEvent(rayCollisionEvent)", "function ProcessAreaDamage(", "DestroyProjectile"));
		list.Add(new PatchSpec("LJ/lua/host/shield.lua", "commander_enhancement_shield_appendix.lua", "scoped FA commander shield recharge semantics", Placement.Append, "function HostShield:SetEnableable(value, skipRecharge)", "function HostShield:TakeDamage(damage)", "function HostShield:RechargeThread()"));
		list.Add(new PatchSpec("LJ/lua/common/commands/definitions/session.lua", "commander_enhancement_commands_appendix.lua", "authenticated commander enhancement request boundary", Placement.Append, "function ExecuteHostFunction.Receive(data)", "ExecuteHostFunction = Registry.RegisterCommand", "function ExecuteClientFunction.Send(functionName, functionData)"));
		list.Add(new PatchSpec("LJ/lua/client/clientListeners.lua", "commander_enhancement_client_listener_appendix.lua", "owner-scoped commander enhancement client state", Placement.Append, "functions = {}", "function functions.InitClient(data)"));
		list.Add(new PatchSpec("LJ/lua/client/units/unitsClasses/unitsDefault.lua", "commander_enhancement_client_visual_appendix.lua", "per-render commander upgrade-bone projection", Placement.Append, "ClientCommander = Class(\"Commander\", ClientMobileUnit)", "function ClientCommander:OnEndCommanderDash()"));
		list.Add(new PatchSpec("LJ/lua/client/units/unitsUpdate.lua", "commander_enhancement_client_retirement_appendix.lua", "retiring commander upgrade-bone projection", Placement.Append, "function DeleteUnit(id)", "function RenderUpdateUnits()"));
		list.Add(new PatchSpec("LJ/lua/client/ui/button.lua", "commander_enhancement_button_pool_appendix.lua", "construction-button pooled interactable reset", Placement.Append, "Button = Class(\"Button\")", "function Button:Clear()", "function Button:SetDisabled(disabled)"));
		list.Add(new PatchSpec("LJ/lua/client/ui/constructionPanel.lua", "commander_enhancement_construction_panel_appendix.lua", "native commander enhancement construction panel", Placement.BeforeTerminalReturn, "function ConstructionPanel:UpdateConstructionPanel", "self.constructionFilteringButtons:ClearButtons()", "return {"));
		list.Add(new PatchSpec("LJ/lua/common/utilities/buildQueueUtils.lua", "commander_enhancement_build_queue_appendix.lua", "dynamic commander engineering-suite build categories", Placement.Append, "function buildQueueUtils.GetBuildableTags(unit)", "function buildQueueUtils.CanBuild(unit, tpId, maxIndex, isPredicted)"));
		return list.ToArray();
	}

	private static void QueueVirtualContract(object cache, ICollection<Mutation> mutations)
	{
		QueueVirtualResource(cache, mutations, "LJ/lua/common/systems/scoCommanderEnhancements.lua", "commander_enhancement_contract.lua", "commander enhancement contract", "contractId = \"stock-fa-acu-enhancements\"", "commanders = {");
	}

	private static void QueueVirtualPodTemplate(object cache, ICollection<Mutation> mutations)
	{
		QueueVirtualResource(cache, mutations, "LJ/lua/common/units/unitsTemplates/uea0001/uea0001.santp", "uea0001.santp", "UEA0001 engineering-drone template", "tpId = \"uea0001\"", "\"unitsDefaultEDA\"", "\"EDAAirUnit\"", "buildPower = 5", "speed = 4");
	}

	private static void QueueVirtualResource(object cache, ICollection<Mutation> mutations, string path, string resourceName, string description, params string[] requiredTokens)
	{
		string source = ReadEmbeddedText(resourceName);
		ValidateAppendix(source, description);
		RequireTokens(source, description, requiredTokens);
		CacheResource cacheResource = TryGetCachedResource(cache, path);
		if (cacheResource != null)
		{
			if (Normalize(ReadText(cacheResource.Value)) == Normalize(source))
			{
				return;
			}
			if (path == "LJ/lua/common/units/unitsTemplates/uea0001/uea0001.santp")
			{
				CacheCompatibilityRepair.RequireUnit(ReadText(cacheResource.Value), "uea0001", "|unitsDefaultEDA:EDAAirUnit|", "EDA");
				if (CacheCompatibilityRepair.HasString(ReadText(cacheResource.Value), "ENGINEER"))
				{
					goto IL_0090;
				}
			}
			throw new InvalidOperationException("Commander enhancement migration refused a foreign resource or incompatible engineering drone.");
		}
		goto IL_0090;
		IL_0090:
		object replacement = CreateNativeArray(GetNativeArrayType(cache), EnsureTerminalNewline(source));
		if (cacheResource != null)
		{
			mutations.Add(new Mutation(cacheResource.Path, cacheResource.Value, replacement, description));
		}
		else
		{
			mutations.Add(new Mutation(ResolveNewCachePath(cache, path), null, replacement, description));
		}
	}

	private static void QueuePatch(object cache, ICollection<Mutation> mutations, PatchSpec spec)
	{
		CacheResource cachedResource = GetCachedResource(cache, spec.Path, spec.Description);
		string text = ReadText(cachedResource.Value);
		string text2 = ReadPatchBundle(spec);
		int num = Count(text, "-- Supreme Commander Overhaul commander enhancements 1.0.0");
		switch (num)
		{
		case 1:
			if (text.IndexOf(text2.Trim(), StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("The marked " + spec.Description + " does not match this release.");
			}
			break;
		default:
			throw new InvalidOperationException($"Expected zero or one commander-enhancement marker in {spec.Description}; found {num}.");
		case 0:
		{
			RequireTokens(text, spec.Description, spec.RequiredStockTokens);
			string text3 = Compose(text, text2, spec.Placement, spec.Description);
			if (Count(text3, "-- Supreme Commander Overhaul commander enhancements 1.0.0") != 1 || text3.IndexOf(text2.Trim(), StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("The composed " + spec.Description + " lost its exact enhancement appendix.");
			}
			object replacement = CreateNativeArray(cachedResource.Value.GetType(), text3);
			mutations.Add(new Mutation(cachedResource.Path, cachedResource.Value, replacement, spec.Description));
			break;
		}
		}
	}

	private static string ReadPatchBundle(PatchSpec spec)
	{
		string text = ReadEmbeddedText(spec.ResourceName);
		ValidateAppendix(text, spec.Description);
		List<string> list = new List<string> { text.Trim() };
		if (!ResourceBundles.TryGetValue(spec.ResourceName, out string[] value))
		{
			return text;
		}
		string[] array = value;
		foreach (string text2 in array)
		{
			string text3 = ReadEmbeddedText(text2);
			if (string.IsNullOrWhiteSpace(text3) || Count(text3, "-- Supreme Commander Overhaul commander enhancements 1.0.0") != 0)
			{
				throw new InvalidOperationException("Embedded bundled commander-enhancement resource " + text2 + " must be non-empty and must not duplicate the release marker.");
			}
			list.Add(text3.Trim());
		}
		return string.Join("\n\n", list) + "\n";
	}

	internal static string ComposeForVerification(string source, string appendix, bool beforeTerminalReturn)
	{
		return Compose(source, appendix, beforeTerminalReturn ? Placement.BeforeTerminalReturn : Placement.Append, "verification fixture");
	}

	private static string Compose(string source, string appendix, Placement placement, string description)
	{
		string text = "\n\n" + appendix.Trim() + "\n";
		if (placement == Placement.Append)
		{
			return source.TrimEnd(Array.Empty<char>()) + text;
		}
		int num = source.LastIndexOf("\nreturn {", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Could not locate the terminal module return in " + description + ".");
		}
		return source.Substring(0, num).TrimEnd(Array.Empty<char>()) + text + source.Substring(num);
	}

	private static void ValidateAppendix(string source, string description)
	{
		if (Count(source, "-- Supreme Commander Overhaul commander enhancements 1.0.0") != 1)
		{
			throw new InvalidOperationException("Embedded " + description + " must contain exactly one -- Supreme Commander Overhaul commander enhancements 1.0.0 marker.");
		}
	}

	private static string ReadEmbeddedText(string fileName)
	{
		string text = "CommanderEnhancements." + fileName;
		using Stream stream = typeof(CachePatcherRuntime).Assembly.GetManifestResourceStream(text) ?? throw new MissingManifestResourceException("Missing embedded commander-enhancement resource " + text + ".");
		using StreamReader streamReader = new StreamReader(stream, Encoding.UTF8, detectEncodingFromByteOrderMarks: true);
		return streamReader.ReadToEnd();
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CacheResource GetCachedResource(object cache, string relativePath, string description)
	{
		return TryGetCachedResource(cache, relativePath) ?? throw new FileNotFoundException("The required " + description + " was absent from Sanctuary's Lua cache.", relativePath);
	}

	private static CacheResource? TryGetCachedResource(object cache, string relativePath)
	{
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string text = ResolveNewCachePath(cache, relativePath);
		object obj2 = obj.Invoke(cache, new object[1] { text });
		if (obj2 is bool && (bool)obj2)
		{
			object value = propertyInfo.GetValue(cache, new object[1] { text }) ?? throw new InvalidOperationException("Cached " + relativePath + " has no value.");
			EnsureNativeArray(value, relativePath);
			return new CacheResource(text, value);
		}
		string value2 = "/" + relativePath.Replace('\\', '/');
		CacheResource cacheResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text2 && text2.Replace('\\', '/').EndsWith(value2, StringComparison.OrdinalIgnoreCase))
			{
				if (cacheResource != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + relativePath + ".");
				}
				object value3 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("Cached " + relativePath + " has no value.");
				EnsureNativeArray(value3, relativePath);
				cacheResource = new CacheResource(text2, value3);
			}
		}
		return cacheResource;
	}

	private static string ResolveNewCachePath(object cache, string relativePath)
	{
		foreach (object item in (IEnumerable)cache)
		{
			if (item.GetType().GetProperty("Key")?.GetValue(item) is string text)
			{
				int num = text.Replace('\\', '/').LastIndexOf("/LJ/lua/", StringComparison.OrdinalIgnoreCase);
				if (num >= 0)
				{
					return Path.GetFullPath(Path.Combine(text.Substring(0, num), relativePath.Replace('/', Path.DirectorySeparatorChar)));
				}
			}
		}
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static Type GetNativeArrayType(object cache)
	{
		foreach (object item in (IEnumerable)cache)
		{
			object obj = item.GetType().GetProperty("Value")?.GetValue(item);
			if (obj != null)
			{
				EnsureNativeArray(obj, "Lua cache seed resource");
				return obj.GetType();
			}
		}
		throw new InvalidOperationException("Sanctuary's Lua cache has no seed resource.");
	}

	private static object CreateNativeArray(Type nativeArrayType, string source)
	{
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, Encoding.UTF8.GetBytes(source));
	}

	private static byte[] GetBytes(object nativeArray)
	{
		return (byte[])(nativeArray.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArray.GetType().FullName, "ToArray")).Invoke(nativeArray, null);
	}

	private static string ReadText(object nativeArray)
	{
		EnsureNativeArray(nativeArray, "Lua cache resource");
		return Encoding.UTF8.GetString(GetBytes(nativeArray));
	}

	private static void EnsureNativeArray(object value, string description)
	{
		object value2 = (value.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(value.GetType().FullName, "IsCreated")).GetValue(value);
		if (!(value2 is bool) || !(bool)value2)
		{
			throw new InvalidOperationException("The cached " + description + " is not an initialized NativeArray<byte>.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void RemoveCachedResource(object cache, string path)
	{
		object obj = (cache.GetType().GetMethod("Remove", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "Remove")).Invoke(cache, new object[1] { path });
		if (!(obj is bool) || !(bool)obj)
		{
			throw new InvalidOperationException("Could not remove inserted cache resource " + path + ".");
		}
	}

	private static void VerifyAssigned(object cache, Mutation mutation)
	{
		if (!GetBytes((TryGetCachedResource(cache, mutation.Path) ?? throw new InvalidOperationException("Assigned " + mutation.Description + " disappeared from the Lua cache.")).Value).SequenceEqual(GetBytes(mutation.Replacement)))
		{
			throw new InvalidOperationException("Assigned " + mutation.Description + " failed byte-identity verification.");
		}
	}

	private static void Commit(object cache, IReadOnlyList<Mutation> mutations)
	{
		foreach (Mutation mutation in mutations)
		{
			mutation.AssignmentAttempted = true;
			SetCachedResource(cache, mutation.Path, mutation.Replacement);
			VerifyAssigned(cache, mutation);
		}
		foreach (Mutation mutation2 in mutations)
		{
			if (mutation2.Stock != null)
			{
				TryDispose(mutation2.Stock, "superseded " + mutation2.Description);
			}
			mutation2.AssignmentAttempted = false;
		}
	}

	private static void RollBackAndDispose(object cache, IEnumerable<Mutation> mutations)
	{
		List<Exception> list = new List<Exception>();
		foreach (Mutation item in mutations.Reverse())
		{
			if (item.AssignmentAttempted)
			{
				try
				{
					if (item.IsInsertion)
					{
						RemoveCachedResource(cache, item.Path);
					}
					else
					{
						SetCachedResource(cache, item.Path, item.Stock);
						if (!GetBytes((TryGetCachedResource(cache, item.Path) ?? throw new InvalidOperationException("Restored " + item.Description + " disappeared.")).Value).SequenceEqual(GetBytes(item.Stock)))
						{
							throw new InvalidOperationException("Restored " + item.Description + " failed byte identity.");
						}
					}
					item.AssignmentAttempted = false;
				}
				catch (Exception innerException)
				{
					list.Add(new InvalidOperationException("Could not restore " + item.Description + ".", innerException));
				}
			}
			if (!item.AssignmentAttempted)
			{
				try
				{
					Dispose(item.Replacement);
				}
				catch (Exception innerException2)
				{
					list.Add(new InvalidOperationException("Could not dispose rolled-back " + item.Description + ".", innerException2));
				}
			}
		}
		if (list.Count != 0)
		{
			throw new AggregateException("Commander-enhancement cache rollback was incomplete.", list);
		}
	}

	private static void DisposeUncommitted(IEnumerable<Mutation> mutations)
	{
		foreach (Mutation mutation in mutations)
		{
			TryDispose(mutation.Replacement, "uncommitted " + mutation.Description);
		}
	}

	private static void Dispose(object nativeArray)
	{
		object obj = nativeArray.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public)?.GetValue(nativeArray);
		if (obj is bool && (bool)obj)
		{
			(nativeArray.GetType().GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArray.GetType().FullName, "Dispose")).Invoke(nativeArray, null);
		}
	}

	private static void TryDispose(object nativeArray, string description)
	{
		try
		{
			Dispose(nativeArray);
		}
		catch (Exception ex)
		{
			Log("Could not dispose " + description + ": " + ex.GetBaseException().Message);
		}
	}

	private static void RequireTokens(string source, string description, IEnumerable<string> requiredTokens)
	{
		foreach (string requiredToken in requiredTokens)
		{
			if (source.IndexOf(requiredToken, StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("The cached " + description + " is missing expected token '" + requiredToken + "'.");
			}
		}
	}

	private static int Count(string source, string token)
	{
		int num = 0;
		int startIndex = 0;
		while (true)
		{
			int num2 = source.IndexOf(token, startIndex, StringComparison.Ordinal);
			if (num2 < 0)
			{
				break;
			}
			num++;
			startIndex = num2 + token.Length;
		}
		return num;
	}

	private static string Normalize(string source)
	{
		return source.Replace("\r\n", "\n").Trim();
	}

	private static string EnsureTerminalNewline(string source)
	{
		return source.TrimEnd(Array.Empty<char>()) + "\n";
	}

	private static void Log(string message)
	{
		string text = "[SCOM Commander Enhancements] " + message;
		Console.WriteLine(text);
		try
		{
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}
}
