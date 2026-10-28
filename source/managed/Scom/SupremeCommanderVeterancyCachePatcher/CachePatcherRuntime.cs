using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace SupremeCommanderVeterancyCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class CacheResource
	{
		public string Path { get; }

		public object Stock { get; }

		public CacheResource(string path, object stock)
		{
			Path = path;
			Stock = stock;
		}
	}

	private sealed class CacheMutation
	{
		public string Path { get; }

		public object Stock { get; }

		public object Replacement { get; }

		public string Description { get; }

		public bool Assigned { get; set; }

		public CacheMutation(string path, object stock, object replacement, string description)
		{
			Path = path;
			Stock = stock;
			Replacement = replacement;
			Description = description;
		}
	}

	internal const string OverrideMarker = "-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0";

	private const string HostUnitsRelativePath = "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua";

	private const string HostDashBehaviorRelativePath = "LJ/lua/host/interfaces/behaviors/dashBehavior.lua";

	private const string HostDashBehaviorImport = "local DashBehavior = Import(\"host/interfaces/behaviors/dashBehavior.lua\").DashBehavior";

	private const string HostUnitsDefaultRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefault.lua";

	private const string HostProjectilesRelativePath = "LJ/lua/host/projectiles/projectilesClasses/projectilesBaseClass.lua";

	private const string HostWeaponsRelativePath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string HostCollisionRelativePath = "LJ/lua/host/collisionUpdate.lua";

	private const string HostBeamRelativePath = "LJ/lua/host/units/weaponsClasses/beam.lua";

	private const string ClientUnitsRelativePath = "LJ/lua/client/units/unitsClasses/unitsBaseClass.lua";

	private const string CommandsRelativePath = "LJ/lua/common/systems/commands.lua";

	private const string UnitCommandsRelativePath = "LJ/lua/common/commands/definitions/units.lua";

	private const string UnitCommandsImport = "local UnitCommands    = Import(\"common/commands/definitions/units.lua\")";

	private const string InformationPanelRelativePath = "LJ/lua/client/ui/informationPanel.lua";

	private const string HostUnitsAppendix = "\nlocal SCO_StockUnitInit = HostUnit.__init\nfunction HostUnit:__init(...)\n    SCO_StockUnitInit(self, ...)\n\n    local health = self.tp.defence and self.tp.defence.health or nil\n    self.scoVeterancyBaseMaxHealth = (health and health.max) or self:GetMaxHealth()\n    self.scoVeterancyBaseRegen = (health and health.regen) or self:GetHealthRegen()\n    self.scoVeterancyKills = 0\n    self.scoVeterancyLevel = 0\nend\n\nfunction HostUnit:SCOApplyVeterancyLevel(level)\n    local rule = SCO_GetVeterancyRule(self.tpId)\n    local oldMaxHealth = self:GetMaxHealth()\n    local newMaxHealth = (self.scoVeterancyBaseMaxHealth or oldMaxHealth) * (1 + level * 0.1)\n\n    self:SetMaxHealth(newMaxHealth)\n\n    local currentHealth = self:GetHealth()\n    if newMaxHealth > oldMaxHealth then\n        self:SetHealth(math.min(currentHealth + newMaxHealth - oldMaxHealth, newMaxHealth))\n    else\n        self:SetHealth(math.min(currentHealth, newMaxHealth))\n    end\n\n    self:SetHealthRegen((self.scoVeterancyBaseRegen or 0) + (rule.regen[level] or 0))\nend\n\nfunction HostUnit:SCOSetVeterancyKills(kills, synchronize)\n    kills = math.max(0, math.floor(kills or 0))\n    self.scoVeterancyKills = kills\n\n    local rule = SCO_GetVeterancyRule(self.tpId)\n    local desiredLevel = 0\n    while desiredLevel < #rule.kills and kills >= rule.kills[desiredLevel + 1] do\n        desiredLevel = desiredLevel + 1\n    end\n\n    local currentLevel = self.scoVeterancyLevel or 0\n    if desiredLevel > currentLevel then\n        while currentLevel < desiredLevel do\n            currentLevel = currentLevel + 1\n            self.scoVeterancyLevel = currentLevel\n            self:SCOApplyVeterancyLevel(currentLevel)\n        end\n    elseif desiredLevel ~= currentLevel then\n        self.scoVeterancyLevel = desiredLevel\n        self:SCOApplyVeterancyLevel(desiredLevel)\n    end\n\n    if synchronize then\n        Commands.HostCustomCommands.SetVeterancyCommand.HostSend(self.id, kills)\n    end\nend\n\nfunction HostUnit:SCOOnKilledUnit(unitKilled)\n    self:SCOSetVeterancyKills((self.scoVeterancyKills or 0) + 1, true)\nend\n\nlocal SCO_StockUnitDestroy = HostUnit.Destroy\nfunction HostUnit:Destroy(overkillRatio, destroyType, instigator)\n    -- This deliberately matches Forged Alliance's Unit.OnKilled rule: any\n    -- supplied Unit instigator receives one KILLS stat, with no enemy,\n    -- completion, or alive-state filter added here.\n    if self.canBeKilled and not self.dead and instigator and instigator.entityType == \"unit\" then\n        instigator:SCOOnKilledUnit(self)\n    end\n\n    return SCO_StockUnitDestroy(self, overkillRatio, destroyType)\nend\n\nfunction HostUnit:TakeDamage(amount, destroyType, instigator)\n    if not self.canTakeDamage then\n        return\n    elseif self.dead then\n        return\n    end\n\n    local finalDamage = self:ProcessDamage(amount)\n    self:DoCallbacks(\"OnDamaged\", finalDamage)\n\n    local currentHP = self:GetHealth()\n    local newHP = currentHP - finalDamage\n\n    if newHP > 0 then\n        self:SetHealth(newHP)\n    else\n        local maxHP = self:GetMaxHealth()\n        local overkillRatio = -newHP / maxHP\n\n        self:SetHealth(0)\n\n        self:Destroy(overkillRatio, destroyType, instigator)\n    end\nend\n\nlocal SCO_StockUnitOnEndUpgrade = HostUnit.OnEndUpgrade\nfunction HostUnit:OnEndUpgrade(upgrader)\n    SCO_StockUnitOnEndUpgrade(self, upgrader)\n\n    if self:IsCompleted() and not upgrader.dead then\n        self:SCOSetVeterancyKills(upgrader.scoVeterancyKills or 0, true)\n    end\nend";

	private const string ClientUnitsAppendix = "\n-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0\n_G.SCOClientVeterancyPending = _G.SCOClientVeterancyPending or {}\n\nlocal function SCO_GetClientVeterancyKey(unitID)\n    return tostring(unitID.index) .. \":\" .. tostring(unitID.version)\nend\n\nfunction ClientUnit:SCOSetVeterancyKills(kills)\n    self.scoVeterancyKills = math.max(0, math.floor(kills or 0))\n    self:SetUIDirtyIfSelected()\nend\n\nlocal SCO_StockClientUnitInit = ClientUnit.__init\nfunction ClientUnit:__init(...)\n    SCO_StockClientUnitInit(self, ...)\n    self.scoVeterancyKills = 0\n\n    local key = SCO_GetClientVeterancyKey(self.id)\n    local pendingKills = _G.SCOClientVeterancyPending[key]\n    if pendingKills ~= nil then\n        _G.SCOClientVeterancyPending[key] = nil\n        self:SCOSetVeterancyKills(pendingKills)\n    end\nend\n\n-- Cached Lua resources run in isolated environments, so expose this client\n-- handler through the shared global table for common/systems/commands.lua.\n_G.SCO_SetClientVeterancyKills = function(unitID, kills)\n    local unit = GetUnitById(unitID)\n    if unit then\n        unit:SCOSetVeterancyKills(kills)\n        return\n    end\n\n    _G.SCOClientVeterancyPending[SCO_GetClientVeterancyKey(unitID)] = kills\nend";

	private const string CommandsAppendix = "\n-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0\ncommandFormats.SetVeterancyCommand = {\n    { key = \"unitID\", type = globalIdType },\n    { key = \"kills\", type = \"int\" },\n}\n\nfunction ReceiveSetVeterancyCommand(command)\n    local data = BinarySerialization.Deserialize(commandFormats.SetVeterancyCommand, command.commandData)\n    _G.SCO_SetClientVeterancyKills(data.unitID, data.kills)\nend\n\nfunction SendSetVeterancyCommand(unitID, kills)\n    local data = {\n        unitID = unitID,\n        kills = kills,\n    }\n    local commandString = BinarySerialization.Serialize(commandFormats.SetVeterancyCommand, data)\n    Engine.CreateCustomCommand(HostCustomCommands.SetVeterancyCommand.CommandID, commandString)\nend\n\nHostCustomCommands.SetVeterancyCommand = {\n    HostSend = SendSetVeterancyCommand,\n    ClientReceive = ReceiveSetVeterancyCommand,\n}\n\n-- The stock table assigned ids before this cache appendix was added. Reassign\n-- the full sorted table before Host/Client simulation starts so both sides use\n-- the same stable wire id for every command.\ndo\n    local nextCommandID = 0\n    local sortedKeys = {}\n    for key in pairs(HostCustomCommands) do\n        sortedKeys[#sortedKeys + 1] = key\n    end\n    table.sort(sortedKeys)\n    for _, key in ipairs(sortedKeys) do\n        HostCustomCommands[key].CommandID = nextCommandID\n        nextCommandID = nextCommandID + 1\n    end\nend";

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			string resourceText = GetResourceText(GetCachedResource(obj, "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua", "host units").Stock);
			bool flag = resourceText.Contains("local DashBehavior = Import(\"host/interfaces/behaviors/dashBehavior.lua\").DashBehavior");
			bool num = resourceText.Contains("local UnitCommands    = Import(\"common/commands/definitions/units.lua\")");
			QueueTransform(obj, list, "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua", "host unit death, upgrade, and capture rules", TransformHostUnits, ValidateHostUnits);
			if (flag)
			{
				QueueTransform(obj, list, "LJ/lua/host/interfaces/behaviors/dashBehavior.lua", "host dash damage attribution", TransformHostDashBehavior, ValidateHostDashBehavior);
			}
			QueueTransform(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "host commander and tech-centre damage attribution", TransformHostUnitsDefault, ValidateHostUnitsDefault);
			QueueTransform(obj, list, "LJ/lua/host/projectiles/projectilesClasses/projectilesBaseClass.lua", "host projectile source ownership", TransformHostProjectiles, ValidateHostProjectiles);
			QueueTransform(obj, list, "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "host weapon projectile creation", TransformHostWeapons, ValidateHostWeapons);
			QueueTransform(obj, list, "LJ/lua/host/collisionUpdate.lua", "host direct and area damage attribution", TransformHostCollision, ValidateHostCollision);
			QueueTransform(obj, list, "LJ/lua/host/units/weaponsClasses/beam.lua", "host beam damage attribution", TransformHostBeam, ValidateHostBeam);
			QueueTransform(obj, list, "LJ/lua/client/units/unitsClasses/unitsBaseClass.lua", "client veterancy state", TransformClientUnits, ValidateClientUnits);
			if (num)
			{
				QueueTransform(obj, list, "LJ/lua/common/commands/definitions/units.lua", "registered host-to-client veterancy command", TransformUnitCommands, ValidateUnitCommands);
			}
			else
			{
				QueueTransform(obj, list, "LJ/lua/common/systems/commands.lua", "host-to-client veterancy command", TransformCommands, ValidateCommands);
			}
			QueueTransform(obj, list, "LJ/lua/client/ui/informationPanel.lua", "unit information veterancy value", TransformInformationPanel, ValidateInformationPanel);
			if (list.Count == 0)
			{
				Log("Forged Alliance veterancy resources are already active.");
				return;
			}
			Commit(obj, list);
			Log("Installed Forged Alliance kill-credit veterancy, health/regen ranks, unit-panel kills, and faction badges.");
		}
		catch (Exception arg)
		{
			if (obj != null)
			{
				RollBack(obj, list);
			}
			Log($"Failed to apply Forged Alliance veterancy transaction: {arg}");
			throw;
		}
	}

	private static string TransformHostUnits(string source)
	{
		if (ContainsMarker(source))
		{
			ValidateHostUnits(source);
			return source;
		}
		RequireTokens(source, "function HostUnit:Destroy(overkillRatio, destroyType)", "function HostUnit:TakeDamage(amount, destroyType)", "function HostUnit:OnEndUpgrade(upgrader)", "function HostUnit:OnCaptureProcessEnded(army)", "CollisionUpdate.ProcessAreaDamage(self:GetPosition(), weapon.damageRadius, weapon.damage, self.army, weapon.damageFriendly or false)");
		if (source.Contains("local DashBehavior = Import(\"host/interfaces/behaviors/dashBehavior.lua\").DashBehavior"))
		{
			ValidateHostDashBehaviorComposition(source);
			RequireCount(source, "unit:TakeDamage(damage, DestroyType.Dissolve)", 0, "obsolete inline dash damage");
		}
		else
		{
			source = ReplaceExactly(source, "unit:TakeDamage(damage, DestroyType.Dissolve)", "unit:TakeDamage(damage, DestroyType.Dissolve, self)", 1, "dash damage source");
		}
		source = ReplaceExactly(source, "CollisionUpdate.ProcessAreaDamage(self:GetPosition(), weapon.damageRadius, weapon.damage, self.army, weapon.damageFriendly or false)", "CollisionUpdate.ProcessAreaDamage(self:GetPosition(), weapon.damageRadius, weapon.damage, self.army, weapon.damageFriendly or false, self)", 1, "death-explosion source attribution");
		source = ReplaceExactly(source, "        if newUnit then\n            Engine.CopyHierarchy(self.id, newUnit.id)\n        end", "        if newUnit then\n            Engine.CopyHierarchy(self.id, newUnit.id)\n            newUnit:SCOSetVeterancyKills(self.scoVeterancyKills or 0, true)\n        end", 1, "capture veterancy transfer");
		string text = BuildHostUnitAppendix();
		if (source.Contains("local UnitCommands    = Import(\"common/commands/definitions/units.lua\")"))
		{
			text = ReplaceExactly(text, "Commands.HostCustomCommands.SetVeterancyCommand.HostSend(self.id, kills)", "UnitCommands.SetVeterancyCommand.Send(self.id, kills)", 1, "registered veterancy sender");
		}
		return source + text;
	}

	private static void ValidateHostDashBehaviorComposition(string source)
	{
		RequireTokens(source, "local DashBehavior = Import(\"host/interfaces/behaviors/dashBehavior.lua\").DashBehavior", "HostUnit = Class(\"UnitBase\", HostEntity, Worker, Workable, DashBehavior)", "DashBehavior.__init(self)");
	}

	private static string TransformHostDashBehavior(string source)
	{
		if (ContainsMarker(source))
		{
			ValidateHostDashBehavior(source);
			return source;
		}
		RequireTokens(source, "function DashBehavior:CheckDashCollisionsWithUnits(currentPosition, targetPosition)", "local unit = Units[collisionEvent.colliderGlobalID.index]", "if unit and self.army:IsEnemy(unit.army) then");
		return ReplaceExactly(source, "unit:TakeDamage(damage, DestroyType.Dissolve)", "unit:TakeDamage(damage, DestroyType.Dissolve, self)", 1, "dash behavior source attribution") + MarkerAppendix();
	}

	private static void ValidateHostDashBehavior(string source)
	{
		RequireMarker(source, "host dash behavior");
		RequireTokens(source, "function DashBehavior:CheckDashCollisionsWithUnits(currentPosition, targetPosition)", "local unit = Units[collisionEvent.colliderGlobalID.index]", "if unit and self.army:IsEnemy(unit.army) then");
		RequireCount(source, "unit:TakeDamage(damage, DestroyType.Dissolve, self)", 1, "dash behavior source call");
		RequireCount(source, "unit:TakeDamage(damage, DestroyType.Dissolve)", 0, "unattributed dash behavior source call");
	}

	private static string TransformHostProjectiles(string source)
	{
		RequireTokens(source, "function HostProjectile:__init", "self.muzzleId = muzzleId or EngineClasses.GlobalID()");
		source = ReplaceExactly(source, "function HostProjectile:__init(globalId, armyId, template, damage, damageRadius, lifetime, muzzleId)", "function HostProjectile:__init(globalId, armyId, template, damage, damageRadius, lifetime, muzzleId, sourceUnit)", 1, "HostProjectile constructor signature");
		source = ReplaceExactly(source, "self.muzzleId = muzzleId or EngineClasses.GlobalID()", "self.muzzleId = muzzleId or EngineClasses.GlobalID()\n    self.sourceUnit = sourceUnit", 1, "Projectile source-unit storage");
		return source + MarkerAppendix();
	}

	private static string TransformHostUnitsDefault(string source)
	{
		RequireTokens(source, "function HostCommander:Destroy(overkillRatio, destroyType)", "HostUnit.Destroy(self, overkillRatio, destroyType)");
		source = ReplaceExactly(source, "function HostCommander:Destroy(overkillRatio, destroyType)", "function HostCommander:Destroy(overkillRatio, destroyType, instigator)", 1, "Commander destroy signature");
		source = ReplaceExactly(source, "HostUnit.Destroy(self, overkillRatio, destroyType)", "HostUnit.Destroy(self, overkillRatio, destroyType, instigator)", 1, "Commander destroy source propagation");
		return source + MarkerAppendix();
	}

	private static string TransformHostWeapons(string source)
	{
		RequireTokens(source, "Projectiles[projectileID.index] = Projectile(projectileID, self.unit.army.id, self.projectileTemplate, self.tp.damage or 0, self.tp.damageRadius or 0, self.tp.projectileLifetime, muzzleID)");
		return ReplaceExactly(source, "Projectiles[projectileID.index] = Projectile(projectileID, self.unit.army.id, self.projectileTemplate, self.tp.damage or 0, self.tp.damageRadius or 0, self.tp.projectileLifetime, muzzleID)", "Projectiles[projectileID.index] = Projectile(projectileID, self.unit.army.id, self.projectileTemplate, self.tp.damage or 0, self.tp.damageRadius or 0, self.tp.projectileLifetime, muzzleID, self.unit)", 1, "Projectile firing-unit propagation") + MarkerAppendix();
	}

	private static string TransformHostCollision(string source)
	{
		source = ReplaceExactly(source, "unit:TakeDamage(unitDamage, DestroyType.Kinetic)", "unit:TakeDamage(unitDamage, DestroyType.Kinetic, sourceUnit)", 1, "shield-reduced area-damage unit attribution");
		RequireTokens(source, "function ProcessAreaDamage(position, radius, damage, army, damageFriendly)", "unit:TakeDamage(damage, DestroyType.Kinetic)", "unit:TakeDamage(projectile.damage, DestroyType.Kinetic)", "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, false)");
		source = ReplaceExactly(source, "function ProcessAreaDamage(position, radius, damage, army, damageFriendly)", "function ProcessAreaDamage(position, radius, damage, army, damageFriendly, sourceUnit)", 1, "ProcessAreaDamage source parameter");
		source = ReplaceExactly(source, "unit:TakeDamage(damage, DestroyType.Kinetic)", "unit:TakeDamage(damage, DestroyType.Kinetic, sourceUnit)", 1, "area-damage unit attribution");
		source = ReplaceExactly(source, "unit:TakeDamage(projectile.damage, DestroyType.Kinetic)", "unit:TakeDamage(projectile.damage, DestroyType.Kinetic, projectile.sourceUnit)", 1, "direct projectile unit attribution");
		source = ReplaceExactly(source, "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, false)", "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, false, projectile.sourceUnit)", 3, "projectile area-damage source propagation");
		return source + MarkerAppendix();
	}

	private static string TransformHostBeam(string source)
	{
		int num = CountOccurrences(source, "unit:TakeDamage(self.damage)");
		int num2 = CountOccurrences(source, "unit:TakeDamage(self.damage, DestroyType.Kinetic)");
		if (num + num2 != 1)
		{
			throw new InvalidOperationException("HostBeam must contain exactly one supported direct-damage call " + $"(legacy={num}, current={num2}).");
		}
		string oldValue = ((num2 == 1) ? "unit:TakeDamage(self.damage, DestroyType.Kinetic)" : "unit:TakeDamage(self.damage)");
		return ReplaceExactly(source, oldValue, "unit:TakeDamage(self.damage, DestroyType.Kinetic, self.unit)", 1, "beam source-unit attribution") + MarkerAppendix();
	}

	private static string TransformClientUnits(string source)
	{
		RequireTokens(source, "function ClientUnit:__init(globalId, localId, armyId, template, fractionComplete)", "function ClientUnit:SetUIDirtyIfSelected()");
		return source + "\n-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0\n_G.SCOClientVeterancyPending = _G.SCOClientVeterancyPending or {}\n\nlocal function SCO_GetClientVeterancyKey(unitID)\n    return tostring(unitID.index) .. \":\" .. tostring(unitID.version)\nend\n\nfunction ClientUnit:SCOSetVeterancyKills(kills)\n    self.scoVeterancyKills = math.max(0, math.floor(kills or 0))\n    self:SetUIDirtyIfSelected()\nend\n\nlocal SCO_StockClientUnitInit = ClientUnit.__init\nfunction ClientUnit:__init(...)\n    SCO_StockClientUnitInit(self, ...)\n    self.scoVeterancyKills = 0\n\n    local key = SCO_GetClientVeterancyKey(self.id)\n    local pendingKills = _G.SCOClientVeterancyPending[key]\n    if pendingKills ~= nil then\n        _G.SCOClientVeterancyPending[key] = nil\n        self:SCOSetVeterancyKills(pendingKills)\n    end\nend\n\n-- Cached Lua resources run in isolated environments, so expose this client\n-- handler through the shared global table for common/systems/commands.lua.\n_G.SCO_SetClientVeterancyKills = function(unitID, kills)\n    local unit = GetUnitById(unitID)\n    if unit then\n        unit:SCOSetVeterancyKills(kills)\n        return\n    end\n\n    _G.SCOClientVeterancyPending[SCO_GetClientVeterancyKey(unitID)] = kills\nend";
	}

	private static string TransformCommands(string source)
	{
		RequireTokens(source, "local commandFormats = {", "HostCustomCommands = {", "Automatically assign unique CommandIDs");
		return source + "\n-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0\ncommandFormats.SetVeterancyCommand = {\n    { key = \"unitID\", type = globalIdType },\n    { key = \"kills\", type = \"int\" },\n}\n\nfunction ReceiveSetVeterancyCommand(command)\n    local data = BinarySerialization.Deserialize(commandFormats.SetVeterancyCommand, command.commandData)\n    _G.SCO_SetClientVeterancyKills(data.unitID, data.kills)\nend\n\nfunction SendSetVeterancyCommand(unitID, kills)\n    local data = {\n        unitID = unitID,\n        kills = kills,\n    }\n    local commandString = BinarySerialization.Serialize(commandFormats.SetVeterancyCommand, data)\n    Engine.CreateCustomCommand(HostCustomCommands.SetVeterancyCommand.CommandID, commandString)\nend\n\nHostCustomCommands.SetVeterancyCommand = {\n    HostSend = SendSetVeterancyCommand,\n    ClientReceive = ReceiveSetVeterancyCommand,\n}\n\n-- The stock table assigned ids before this cache appendix was added. Reassign\n-- the full sorted table before Host/Client simulation starts so both sides use\n-- the same stable wire id for every command.\ndo\n    local nextCommandID = 0\n    local sortedKeys = {}\n    for key in pairs(HostCustomCommands) do\n        sortedKeys[#sortedKeys + 1] = key\n    end\n    table.sort(sortedKeys)\n    for _, key in ipairs(sortedKeys) do\n        HostCustomCommands[key].CommandID = nextCommandID\n        nextCommandID = nextCommandID + 1\n    end\nend";
	}

	private static string TransformUnitCommands(string source)
	{
		if (ContainsMarker(source))
		{
			ValidateUnitCommands(source);
			return source;
		}
		RequireTokens(source, "local Registry = Import(\"common/commands/registry.lua\")", "local Layouts  = Import(\"common/commands/layouts.lua\")", "CreateUnit = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {", "function CreateUnit.Send(unitID, progress, armyID)", "function CreateUnit.Receive(data)");
		RequireCount(source, "SetVeterancyCommand", 0, "pre-existing registered veterancy command");
		return source + MarkerAppendix() + "\nSetVeterancyCommand = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {\n    { key = \"unitID\", type = Layouts.GlobalID },\n    { key = \"kills\", type = \"int\" },\n})\n\nfunction SetVeterancyCommand.Send(unitID, kills)\n    return { unitID = unitID, kills = kills }\nend\n\nfunction SetVeterancyCommand.Receive(data)\n    _G.SCO_SetClientVeterancyKills(data.unitID, data.kills)\nend\n";
	}

	private static void ValidateUnitCommands(string source)
	{
		RequireMarker(source, "registered unit commands");
		RequireTokens(source, "local Registry = Import(\"common/commands/registry.lua\")", "local Layouts  = Import(\"common/commands/layouts.lua\")", "{ key = \"unitID\", type = Layouts.GlobalID }", "{ key = \"kills\", type = \"int\" }", "return { unitID = unitID, kills = kills }", "_G.SCO_SetClientVeterancyKills(data.unitID, data.kills)");
		RequireCount(source, "SetVeterancyCommand = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {", 1, "registered veterancy command");
		RequireCount(source, "function SetVeterancyCommand.Send(unitID, kills)", 1, "registered veterancy payload builder");
		RequireCount(source, "function SetVeterancyCommand.Receive(data)", 1, "registered veterancy receiver");
	}

	private static string TransformInformationPanel(string source)
	{
		RequireTokens(source, "function InformationPanel:UpdateUnitInformationPanel(unit)", "function InformationPanel:UpdateUnitInformationPanelTemplate(tp)");
		source = ReplaceOccurrence(source, "veterancy = 0,", "veterancy = unit.scoVeterancyKills or 0,", 2, 0, "the real-unit veterancy field");
		return source + MarkerAppendix();
	}

	private static void ValidateHostUnits(string source)
	{
		RequireMarker(source, "host units");
		RequireTokens(source, "newUnit:SCOSetVeterancyKills(self.scoVeterancyKills or 0, true)", "function HostUnit:SCOSetVeterancyKills(kills, synchronize)", "function HostUnit:SCOOnKilledUnit(unitKilled)", "function HostUnit:Destroy(overkillRatio, destroyType, instigator)", "function HostUnit:TakeDamage(amount, destroyType, instigator)", "function HostUnit:OnEndUpgrade(upgrader)", "SCO_StockUnitInit", "weapon.damageFriendly or false, self)");
		if (source.Contains("local DashBehavior = Import(\"host/interfaces/behaviors/dashBehavior.lua\").DashBehavior"))
		{
			ValidateHostDashBehaviorComposition(source);
			RequireCount(source, "unit:TakeDamage(damage, DestroyType.Dissolve)", 0, "obsolete inline dash damage");
		}
		else
		{
			RequireCount(source, "unit:TakeDamage(damage, DestroyType.Dissolve, self)", 1, "inline dash source call");
		}
		RequireCount(source, "function HostUnit:SCOSetVeterancyKills(kills, synchronize)", 1, "veterancy state setter");
		if (source.Contains("local UnitCommands    = Import(\"common/commands/definitions/units.lua\")"))
		{
			RequireCount(source, "UnitCommands.SetVeterancyCommand.Send(self.id, kills)", 1, "registered veterancy sender");
			RequireCount(source, "Commands.HostCustomCommands.SetVeterancyCommand.HostSend(self.id, kills)", 0, "obsolete veterancy sender");
		}
	}

	private static void ValidateHostProjectiles(string source)
	{
		RequireMarker(source, "host projectiles");
		RequireTokens(source, "function HostProjectile:__init(globalId, armyId, template, damage, damageRadius, lifetime, muzzleId, sourceUnit)", "self.sourceUnit = sourceUnit");
		RequireCount(source, "function HostProjectile:__init(globalId, armyId, template, damage, damageRadius, lifetime, muzzleId, sourceUnit)", 1, "HostProjectile source-unit constructor");
		RequireCount(source, "function Projectile:__init", 0, "obsolete Projectile constructor");
	}

	private static void ValidateHostUnitsDefault(string source)
	{
		RequireMarker(source, "host unit defaults");
		RequireTokens(source, "function HostCommander:Destroy(overkillRatio, destroyType, instigator)", "HostUnit.Destroy(self, overkillRatio, destroyType, instigator)");
	}

	private static void ValidateHostWeapons(string source)
	{
		RequireMarker(source, "host weapons");
		RequireTokens(source, "self.tp.projectileLifetime, muzzleID, self.unit)");
	}

	private static void ValidateHostCollision(string source)
	{
		RequireCount(source, "unit:TakeDamage(unitDamage, DestroyType.Kinetic, sourceUnit)", 1, "shield-reduced area-damage source call");
		RequireCount(source, "unit:TakeDamage(unitDamage, DestroyType.Kinetic)", 0, "unattributed shield-reduced area-damage call");
		RequireMarker(source, "host collision");
		RequireTokens(source, "function ProcessAreaDamage(position, radius, damage, army, damageFriendly, sourceUnit)", "unit:TakeDamage(damage, DestroyType.Kinetic, sourceUnit)", "unit:TakeDamage(projectile.damage, DestroyType.Kinetic, projectile.sourceUnit)", "false, projectile.sourceUnit)");
		RequireCount(source, "unit:TakeDamage(damage, DestroyType.Kinetic, sourceUnit)", 1, "area-damage source calls");
		RequireCount(source, "false, projectile.sourceUnit)", 3, "projectile area-damage source calls");
	}

	private static void ValidateHostBeam(string source)
	{
		RequireMarker(source, "host beams");
		RequireCount(source, "unit:TakeDamage(self.damage, DestroyType.Kinetic, self.unit)", 1, "beam source call");
	}

	private static void ValidateClientUnits(string source)
	{
		RequireMarker(source, "client units");
		RequireTokens(source, "SCOClientVeterancyPending", "function ClientUnit:SCOSetVeterancyKills(kills)", "_G.SCO_SetClientVeterancyKills = function(unitID, kills)");
		RequireCount(source, "function ClientUnit:SCOSetVeterancyKills(kills)", 1, "client veterancy setter");
	}

	private static void ValidateCommands(string source)
	{
		RequireMarker(source, "commands");
		RequireTokens(source, "commandFormats.SetVeterancyCommand", "function ReceiveSetVeterancyCommand(command)", "_G.SCO_SetClientVeterancyKills(data.unitID, data.kills)", "function SendSetVeterancyCommand(unitID, kills)", "HostCustomCommands.SetVeterancyCommand");
		RequireCount(source, "HostCustomCommands.SetVeterancyCommand", 2, "veterancy command registration and command id assignment");
	}

	private static void ValidateInformationPanel(string source)
	{
		RequireMarker(source, "information panel");
		RequireCount(source, "veterancy = unit.scoVeterancyKills or 0,", 1, "real-unit kill display");
		RequireCount(source, "veterancy = 0,", 1, "predicted-unit zero veterancy display");
	}

	private static string BuildHostUnitAppendix()
	{
		return "\n\n-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0\n" + VeterancyRules.BuildLuaRuleTable() + "\nlocal SCO_StockUnitInit = HostUnit.__init\nfunction HostUnit:__init(...)\n    SCO_StockUnitInit(self, ...)\n\n    local health = self.tp.defence and self.tp.defence.health or nil\n    self.scoVeterancyBaseMaxHealth = (health and health.max) or self:GetMaxHealth()\n    self.scoVeterancyBaseRegen = (health and health.regen) or self:GetHealthRegen()\n    self.scoVeterancyKills = 0\n    self.scoVeterancyLevel = 0\nend\n\nfunction HostUnit:SCOApplyVeterancyLevel(level)\n    local rule = SCO_GetVeterancyRule(self.tpId)\n    local oldMaxHealth = self:GetMaxHealth()\n    local newMaxHealth = (self.scoVeterancyBaseMaxHealth or oldMaxHealth) * (1 + level * 0.1)\n\n    self:SetMaxHealth(newMaxHealth)\n\n    local currentHealth = self:GetHealth()\n    if newMaxHealth > oldMaxHealth then\n        self:SetHealth(math.min(currentHealth + newMaxHealth - oldMaxHealth, newMaxHealth))\n    else\n        self:SetHealth(math.min(currentHealth, newMaxHealth))\n    end\n\n    self:SetHealthRegen((self.scoVeterancyBaseRegen or 0) + (rule.regen[level] or 0))\nend\n\nfunction HostUnit:SCOSetVeterancyKills(kills, synchronize)\n    kills = math.max(0, math.floor(kills or 0))\n    self.scoVeterancyKills = kills\n\n    local rule = SCO_GetVeterancyRule(self.tpId)\n    local desiredLevel = 0\n    while desiredLevel < #rule.kills and kills >= rule.kills[desiredLevel + 1] do\n        desiredLevel = desiredLevel + 1\n    end\n\n    local currentLevel = self.scoVeterancyLevel or 0\n    if desiredLevel > currentLevel then\n        while currentLevel < desiredLevel do\n            currentLevel = currentLevel + 1\n            self.scoVeterancyLevel = currentLevel\n            self:SCOApplyVeterancyLevel(currentLevel)\n        end\n    elseif desiredLevel ~= currentLevel then\n        self.scoVeterancyLevel = desiredLevel\n        self:SCOApplyVeterancyLevel(desiredLevel)\n    end\n\n    if synchronize then\n        Commands.HostCustomCommands.SetVeterancyCommand.HostSend(self.id, kills)\n    end\nend\n\nfunction HostUnit:SCOOnKilledUnit(unitKilled)\n    self:SCOSetVeterancyKills((self.scoVeterancyKills or 0) + 1, true)\nend\n\nlocal SCO_StockUnitDestroy = HostUnit.Destroy\nfunction HostUnit:Destroy(overkillRatio, destroyType, instigator)\n    -- This deliberately matches Forged Alliance's Unit.OnKilled rule: any\n    -- supplied Unit instigator receives one KILLS stat, with no enemy,\n    -- completion, or alive-state filter added here.\n    if self.canBeKilled and not self.dead and instigator and instigator.entityType == \"unit\" then\n        instigator:SCOOnKilledUnit(self)\n    end\n\n    return SCO_StockUnitDestroy(self, overkillRatio, destroyType)\nend\n\nfunction HostUnit:TakeDamage(amount, destroyType, instigator)\n    if not self.canTakeDamage then\n        return\n    elseif self.dead then\n        return\n    end\n\n    local finalDamage = self:ProcessDamage(amount)\n    self:DoCallbacks(\"OnDamaged\", finalDamage)\n\n    local currentHP = self:GetHealth()\n    local newHP = currentHP - finalDamage\n\n    if newHP > 0 then\n        self:SetHealth(newHP)\n    else\n        local maxHP = self:GetMaxHealth()\n        local overkillRatio = -newHP / maxHP\n\n        self:SetHealth(0)\n\n        self:Destroy(overkillRatio, destroyType, instigator)\n    end\nend\n\nlocal SCO_StockUnitOnEndUpgrade = HostUnit.OnEndUpgrade\nfunction HostUnit:OnEndUpgrade(upgrader)\n    SCO_StockUnitOnEndUpgrade(self, upgrader)\n\n    if self:IsCompleted() and not upgrader.dead then\n        self:SCOSetVeterancyKills(upgrader.scoVeterancyKills or 0, true)\n    end\nend";
	}

	private static string MarkerAppendix()
	{
		return "\n\n-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0\n";
	}

	private static void QueueTransform(object cache, List<CacheMutation> mutations, string relativePath, string description, Func<string, string> transform, Action<string> validatePatched)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string text = NormalizeLineEndings(GetResourceText(cachedResource.Stock));
		if (ContainsMarker(text))
		{
			validatePatched(text);
			return;
		}
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), transform(text));
		try
		{
			string obj2 = NormalizeLineEndings(GetResourceText(obj));
			validatePatched(obj2);
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, description));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + description + " replacement");
			throw;
		}
	}

	private static void RequireMarker(string source, string description)
	{
		RequireCount(source, "-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0", 1, description + " veterancy marker");
	}

	private static string ReplaceExactly(string source, string oldValue, string newValue, int expectedOccurrences, string description)
	{
		RequireCount(source, oldValue, expectedOccurrences, description);
		return source.Replace(oldValue, newValue);
	}

	private static string ReplaceOccurrence(string source, string oldValue, string newValue, int expectedOccurrences, int occurrenceIndex, string description)
	{
		RequireCount(source, oldValue, expectedOccurrences, description);
		if (occurrenceIndex < 0 || occurrenceIndex >= expectedOccurrences)
		{
			throw new ArgumentOutOfRangeException("occurrenceIndex");
		}
		int num = 0;
		for (int i = 0; i <= occurrenceIndex; i++)
		{
			num = source.IndexOf(oldValue, num, StringComparison.Ordinal);
			if (num < 0)
			{
				throw new InvalidOperationException("The " + description + " disappeared during replacement.");
			}
			if (i != occurrenceIndex)
			{
				num += oldValue.Length;
			}
		}
		return source.Substring(0, num) + newValue + source.Substring(num + oldValue.Length);
	}

	private static void RequireTokens(string source, params string[] requiredTokens)
	{
		foreach (string text in requiredTokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Expected cached Lua source to contain '" + text + "'.");
			}
		}
	}

	private static void RequireCount(string source, string needle, int expectedCount, string description)
	{
		int num = CountOccurrences(source, needle);
		if (num != expectedCount)
		{
			throw new InvalidOperationException($"Expected {expectedCount} {description}, found {num}.");
		}
	}

	private static int CountOccurrences(string source, string needle)
	{
		int num = 0;
		int startIndex = 0;
		while (true)
		{
			int num2 = source.IndexOf(needle, startIndex, StringComparison.Ordinal);
			if (num2 < 0)
			{
				break;
			}
			num++;
			startIndex = num2 + needle.Length;
		}
		return num;
	}

	private static bool ContainsMarker(string source)
	{
		return source.IndexOf("-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0", StringComparison.Ordinal) >= 0;
	}

	private static string NormalizeLineEndings(string source)
	{
		return source.Replace("\r\n", "\n").Replace("\r", "\n");
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CacheResource GetCachedResource(object cache, string relativePath, string description)
	{
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string fullPath = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
		object obj2 = obj.Invoke(cache, new object[1] { fullPath });
		bool flag = false;
		int num;
		if (obj2 is bool)
		{
			flag = (bool)obj2;
			num = 1;
		}
		else
		{
			num = 0;
		}
		if (((uint)num & (flag ? 1u : 0u)) != 0)
		{
			object obj3 = propertyInfo.GetValue(cache, new object[1] { fullPath }) ?? throw new InvalidOperationException("The cached " + description + " has no value.");
			EnsureNativeArray(obj3, description);
			return new CacheResource(fullPath, obj3);
		}
		string value = "/" + relativePath.Replace('\\', '/');
		string text = null;
		object obj4 = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text2 && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (text != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + relativePath + ".");
				}
				object obj5 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("The cached " + description + " has no value.");
				EnsureNativeArray(obj5, description);
				text = text2;
				obj4 = obj5;
			}
		}
		if (text == null || obj4 == null)
		{
			throw new FileNotFoundException("The required " + description + " was not present in Sanctuary's Lua file cache.", relativePath);
		}
		return new CacheResource(text, obj4);
	}

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, Encoding.UTF8.GetBytes(source));
	}

	private static string GetResourceText(object resource)
	{
		EnsureNativeArray(resource, "Lua cache resource");
		Type type = resource.GetType();
		byte[] bytes = (byte[])((type.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, "ToArray")).Invoke(resource, null) ?? throw new InvalidOperationException(type.FullName + ".ToArray returned null."));
		return Encoding.UTF8.GetString(bytes);
	}

	private static void EnsureNativeArray(object value, string description)
	{
		object value2 = (value.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(value.GetType().FullName, "IsCreated")).GetValue(value);
		if (!(value2 is bool) || !(bool)value2)
		{
			throw new InvalidOperationException("The cached " + description + " is not an initialized NativeArray.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void Commit(object cache, IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			mutation.Assigned = true;
			SetCachedResource(cache, mutation.Path, mutation.Replacement);
		}
		foreach (CacheMutation mutation2 in mutations)
		{
			TryDisposeNativeArray(mutation2.Stock.GetType(), mutation2.Stock, "stock " + mutation2.Description);
		}
	}

	private static void RollBack(object cache, IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation item in mutations.Reverse())
		{
			if (item.Assigned)
			{
				try
				{
					SetCachedResource(cache, item.Path, item.Stock);
					item.Assigned = false;
				}
				catch (Exception arg)
				{
					Log($"Rollback failed for {item.Description}: {arg}");
				}
			}
			if (!item.Assigned)
			{
				TryDisposeNativeArray(item.Replacement.GetType(), item.Replacement, "replacement " + item.Description);
			}
		}
	}

	private static void TryDisposeNativeArray(Type nativeArrayType, object nativeArray, string description)
	{
		try
		{
			object value = (nativeArrayType.GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(nativeArrayType.FullName, "IsCreated")).GetValue(nativeArray);
			if (value is bool && (bool)value)
			{
				(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
			}
		}
		catch (Exception arg)
		{
			Log($"Could not dispose {description}: {arg}");
		}
	}

	private static void Log(string message)
	{
		string text = "[Supreme Commander Veterancy Cache Patcher] " + message;
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
