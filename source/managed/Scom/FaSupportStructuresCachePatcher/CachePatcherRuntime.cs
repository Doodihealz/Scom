using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace FaSupportStructuresCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class ShieldVisualContract
	{
		private string RotatorAnchorBone { get; }

		private string ShieldAnchorBone { get; }

		private double ShieldOffsetX { get; }

		private double ShieldOffsetY { get; }

		private double ShieldOffsetZ { get; }

		private string? GeneratorCoreSource { get; }

		private string? GeneratorCoreEffect { get; }

		private string? GeneratorCoreAnchorBone { get; }

		private double GeneratorCoreOffsetX { get; }

		private double GeneratorCoreOffsetY { get; }

		private double GeneratorCoreOffsetZ { get; }

		private IReadOnlyList<RotatorContract> SteadyRotators { get; }

		private IReadOnlyList<RotatorContract> InitialRotators { get; }

		private IReadOnlyList<RotatorContract>? UpgradeRotators { get; }

		private int SourceInitialSpeed { get; }

		private int SourceAcceleration { get; }

		private ShieldVisualContract(string rotatorAnchorBone, string shieldAnchorBone, double shieldOffsetX, double shieldOffsetY, double shieldOffsetZ, IReadOnlyList<RotatorContract> steadyRotators, IReadOnlyList<RotatorContract> initialRotators, IReadOnlyList<RotatorContract>? upgradeRotators, int sourceInitialSpeed, int sourceAcceleration, string? generatorCoreSource = null, string? generatorCoreEffect = null, string? generatorCoreAnchorBone = null, double generatorCoreOffsetX = 0.0, double generatorCoreOffsetY = 0.0, double generatorCoreOffsetZ = 0.0)
		{
			int num;
			if (generatorCoreSource == null && generatorCoreEffect == null)
			{
				num = ((generatorCoreAnchorBone != null) ? 1 : 0);
				if (num == 0)
				{
					goto IL_0041;
				}
			}
			else
			{
				num = 1;
			}
			if (string.IsNullOrWhiteSpace(generatorCoreSource) || string.IsNullOrWhiteSpace(generatorCoreEffect) || string.IsNullOrWhiteSpace(generatorCoreAnchorBone))
			{
				throw new ArgumentException("Shield generator core source, effect, and anchor bone must be configured together.");
			}
			goto IL_0041;
			IL_0041:
			if (num == 0 && (generatorCoreOffsetX != 0.0 || generatorCoreOffsetY != 0.0 || generatorCoreOffsetZ != 0.0))
			{
				throw new ArgumentException("Shield generator core offsets require a configured generator core.");
			}
			RotatorAnchorBone = rotatorAnchorBone;
			ShieldAnchorBone = shieldAnchorBone;
			ShieldOffsetX = shieldOffsetX;
			ShieldOffsetY = shieldOffsetY;
			ShieldOffsetZ = shieldOffsetZ;
			GeneratorCoreSource = generatorCoreSource;
			GeneratorCoreEffect = generatorCoreEffect;
			GeneratorCoreAnchorBone = generatorCoreAnchorBone;
			GeneratorCoreOffsetX = generatorCoreOffsetX;
			GeneratorCoreOffsetY = generatorCoreOffsetY;
			GeneratorCoreOffsetZ = generatorCoreOffsetZ;
			SteadyRotators = steadyRotators;
			InitialRotators = initialRotators;
			UpgradeRotators = upgradeRotators;
			SourceInitialSpeed = sourceInitialSpeed;
			SourceAcceleration = sourceAcceleration;
		}

		public static ShieldVisualContract CybranT2()
		{
			return new ShieldVisualContract("Shaft", "Root", 0.0, 1.5202198, 0.0, new RotatorContract[1]
			{
				new RotatorContract(0, 0, 10)
			}, new RotatorContract[1]
			{
				new RotatorContract(0, 0, 30)
			}, null, 30, 5);
		}

		public static ShieldVisualContract UefT2()
		{
			return new ShieldVisualContract("Spinner", "Root", -0.001356448010150935, 2.0057950977740857, 0.00403711433919604, new RotatorContract[2]
			{
				new RotatorContract(0, 10, 0),
				new RotatorContract(0, 0, -10)
			}, new RotatorContract[2]
			{
				new RotatorContract(0, 10, 0),
				new RotatorContract(0, 0, -10)
			}, new RotatorContract[2]
			{
				new RotatorContract(0, 90, 0),
				new RotatorContract(0, 0, 90)
			}, 10, 5, "VFX/Unit/veu1221_active_shield_generator.sanvfx", "VFX/SCOM/FieldFixes/Shields/uef_core_t2.sanvfx", "Root", 0.0, 0.0, 2.9);
		}

		public static ShieldVisualContract UefT3()
		{
			return new ShieldVisualContract("Spinner", "Root", -0.001356448010150935, 2.0057950977740857, 0.00403711433919604, new RotatorContract[2]
			{
				new RotatorContract(0, 10, 0),
				new RotatorContract(0, 0, -10)
			}, new RotatorContract[2]
			{
				new RotatorContract(0, 10, 0),
				new RotatorContract(0, 0, -10)
			}, null, 10, 5, "VFX/Unit/veu1222_active_shield_generator.sanvfx", "VFX/SCOM/FieldFixes/Shields/uef_core_t3.sanvfx", "Root", 0.0, 0.0, 2.9);
		}

		public string BuildRotatorsLua()
		{
			string text = string.Join("\n", SteadyRotators.Select((RotatorContract rotator, int index) => string.Format("{{\n    boneName = \"{0}\",\n    speed = {{ x = {1}, y = {2}, z = {3} }},\n}},", (index == 0) ? RotatorAnchorBone : "B01", rotator.X, rotator.Y, rotator.Z)));
			string text2 = BuildSpeedTable(SteadyRotators);
			string text3 = BuildSpeedTable(InitialRotators);
			string text4 = ((UpgradeRotators == null) ? "nil" : BuildSpeedTable(UpgradeRotators));
			string text5 = ((UpgradeRotators == null) ? "false" : "true");
			return $"-- Source shield rotors are driven by actual shield state. The host\n-- bridge below corrects Sanctuary's recharge-window enablement and\n-- applies the UEF T2 upgrade speed where the source script does.\nUnitTemplate.additions.rotators = {{\n    {text}\n}}\nUnitTemplate.additions.faSupportShield = {{\n    energyDrainRechargeTime = 5,\n    steadyRotatorSpeeds = {text2},\n    initialRotatorSpeeds = {text3},\n    upgradeRotatorSpeeds = {text4},\n    sourceInitialSpeed = {SourceInitialSpeed},\n    sourceAcceleration = {SourceAcceleration},\n    sanctuaryAccelerationSupported = false,\n    sourceUpgradeSpinDown = {text5},\n    sanctuarySpinDownSupported = false,\n}}";
		}

		private static string BuildSpeedTable(IEnumerable<RotatorContract> rotators)
		{
			return "{ " + string.Join(", ", rotators.Select((RotatorContract rotator) => $"{{ x = {rotator.X}, y = {rotator.Y}, z = {rotator.Z} }}")) + " }";
		}

		public string BuildShieldOverrideLua()
		{
			string text = string.Empty;
			if (GeneratorCoreEffect != null && GeneratorCoreSource != null && GeneratorCoreAnchorBone != null)
			{
				text = "\n        shield.effectsPersistent = {\n            {\n                boneName = \"" + GeneratorCoreAnchorBone + "\",\n                positionOffset = {\n                    x = " + Lua(GeneratorCoreOffsetX) + ",\n                    y = " + Lua(GeneratorCoreOffsetY) + ",\n                    z = " + Lua(GeneratorCoreOffsetZ) + ",\n                },\n                particleName = \"" + GeneratorCoreEffect + "\",\n            },\n        }";
			}
			string text2 = string.Empty;
			if (GeneratorCoreEffect != null && GeneratorCoreSource != null && GeneratorCoreAnchorBone != null)
			{
				text2 = "\nUnitTemplate.additions.faSupportShield.generatorCore = {\n    sourceEffect = \"" + GeneratorCoreSource + "\",\n    effect = \"" + GeneratorCoreEffect + "\",\n    boneName = \"" + GeneratorCoreAnchorBone + "\",\n    positionOffset = {\n        x = " + Lua(GeneratorCoreOffsetX) + ",\n        y = " + Lua(GeneratorCoreOffsetY) + ",\n        z = " + Lua(GeneratorCoreOffsetZ) + ",\n    },\n    visibleTransformScale = 0.3,\n    rotatesWithMechanicalAnchor = false,\n}";
			}
			return "-- Keep the shield bubble and generator core on their audited\n-- non-rotating model anchor. Mechanical rotators retain independent bones.\nif UnitTemplate.defence and UnitTemplate.defence.shields then\n    for _, shield in ipairs(UnitTemplate.defence.shields) do\n        shield.boneName = \"" + ShieldAnchorBone + "\"\n        shield.offset = { x = " + Lua(ShieldOffsetX) + ", y = " + Lua(ShieldOffsetY) + ", z = " + Lua(ShieldOffsetZ) + " }" + text + "\n    end\nend" + text2;
		}

		private static string Lua(double value)
		{
			return value.ToString("0.#######", CultureInfo.InvariantCulture);
		}
	}

	private sealed class RotatorContract
	{
		public int X { get; }

		public int Y { get; }

		public int Z { get; }

		public RotatorContract(int x, int y, int z)
		{
			X = x;
			Y = y;
			Z = z;
		}
	}

	private sealed class PatchSpec
	{
		public string RelativePath { get; }

		public string Description { get; }

		public string Appendix { get; }

		public PatchSpec(string relativePath, string description, string appendix)
		{
			RelativePath = relativePath;
			Description = description;
			Appendix = "\n\n-- FA Support Structures Cache Patcher 1.1.2\n" + appendix.TrimStart('\r', '\n');
		}
	}

	private sealed class CachedResource
	{
		public PatchSpec Spec { get; }

		public string Path { get; }

		public object Stock { get; }

		public object? Replacement { get; set; }

		public bool ReplacementWasAssigned { get; set; }

		public CachedResource(PatchSpec spec, string path, object stock)
		{
			Spec = spec;
			Path = path;
			Stock = stock;
		}
	}

	private const string OverrideMarker = "-- FA Support Structures Cache Patcher 1.1.2";

	private const string FaUnitsArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	private static readonly PatchSpec[] PatchSpecs = new PatchSpec[9]
	{
		new PatchSpec("LJ/lua/common/units/unitsTemplates/ugs1602/ugs1602.santp", "Guard T1 alloy storage template", SupportTemplateOverride(0.12, -0.02, 1.4, 1.8, 1.2, 1.1, 0.9, 1.4, 1.2, 1.4, 1.2, 2, 2, StorageGameplayOverride("URB1106", "ugs1602", "323ac892e188940daad815df6ee42ffe2f75585376591ede1965706ca51055f7", "511a2b6ca2f189f4124d57430375f65004e1b075159c8a113dcaaec725fdf642", 1600, 250, 200, 1500, "alloys", 500, "T1AlloyStorageAdjacencyBuff", "B01", "MASS", "z = 0.61"))),
		new PatchSpec("LJ/lua/common/units/unitsTemplates/ugs1612/ugs1612.santp", "Guard T1 energy storage template", SupportTemplateOverride(0.2, -0.07, 1.5, 2.3, 1.4, 1.2, 1.1, 1.5, 1.4, 1.5, 1.4, 2, 2, StorageGameplayOverride("URB1105", "ugs1612", "5f7f46eea3ee0e1ddd37db354fb54ff30fe197aa5b2c45e04ab21706f0427e59", "1909147d9e28cc86fca23ce2a8029a9449c1c94b6105ef8501a9ff7463dadfec", 500, 200, 250, 1200, "energy", 5000, "T1EnergyStorageAdjacencyBuff", "Lift", "ENERGY", "y = 0.8"))),
		new PatchSpec("LJ/lua/common/units/unitsTemplates/ugs2401/ugs2401.santp", "Guard T2 shield template", SupportTemplateOverride(1.62, 0.24, 4.7, 6.9, 4.7, 4.4, 4.5, 4.7, 4.7, 4.7, 4.7, 5, 5, ShieldGameplayOverride("URB4202", "ugs2401", "4053e6d1379b4bfa280932e1790346a4a722e8368dcf3be77325b5fa08bd12c4", "015e26800449fb3cbff51580931227dda794e631c06b2990ccbb46074228bf6d", 500, 400, 160, 2000, 100, 20, 4000, 18, 45, 1, 18, 10, "URB4204", "ugs3401", "ugs3401/URB4207", pauseSupported: true), ShieldVisualContract.CybranT2())),
		new PatchSpec("LJ/lua/common/units/unitsTemplates/ues1602/ues1602.santp", "EDA T1 alloy storage template", SupportTemplateOverride(0.53, 0.0, 1.4, 1.5, 1.4, 1.1, 1.1, 1.4, 1.4, 1.4, 1.4, 2, 2, StorageGameplayOverride("UEB1106", "ues1602", "3c728933dfe3567a969b4ee8a6663fac7e600dca163873e4eba6374fa0d549a7", "23cd41a64f390ec4c9eb3cbb65f22c5d374a3fcbf8c59109925263dfabac4d8e", 1600, 250, 200, 1500, "alloys", 500, "T1AlloyStorageAdjacencyBuff", "Block", "MASS", "z = -0.3"))),
		new PatchSpec("LJ/lua/common/units/unitsTemplates/ues1612/ues1612.santp", "EDA T1 energy storage template", SupportTemplateOverride(0.57, 0.0, 1.6, 2.6, 1.6, 1.3, 1.3, 1.6, 1.6, 1.6, 1.6, 2, 2, StorageGameplayOverride("UEB1105", "ues1612", "c034747eef467a9ce0895dcc670384b6ef404b2427e3fffa7ad0c3a6d4200384", "ef742df5a6fd50f475894cc6ad50069ede2e4ca658adee02df8cd64d217a98a0", 500, 200, 250, 1200, "energy", 5000, "T1EnergyStorageAdjacencyBuff", "B01", "ENERGY", "z = -0.6"))),
		new PatchSpec("LJ/lua/common/units/unitsTemplates/ues2401/ues2401.santp", "EDA T2 shield template", SupportTemplateOverride(2.05, 0.32, 3.8, 4.5, 3.4, 3.6, 3.2, 3.8, 3.4, 3.8, 3.4, 4, 4, ShieldGameplayOverride("UEB4202", "ues2401", "7b9219f640e6034389a5945c71d4d5b90d29f134a51e3a102d93b79003f6df56", "ef4fddb1e0b30e8b686c542f70375346224ab98b1d124b55c2b0991a2b6cae93", 250, 600, 600, 6000, 200, 20, 9000, 15, 120, 1, 26, 15, "UEB4301", "ues3401", "ues3401/UEB4301", pauseSupported: true), ShieldVisualContract.UefT2())),
		new PatchSpec("LJ/lua/common/units/unitsTemplates/ues3401/ues3401.santp", "EDA T3 shield template", SupportTemplateOverride(2.05, -0.21, 4.4, 4.5, 4.4, 4.2, 4.2, 4.4, 4.4, 4.4, 4.4, 5, 5, ShieldGameplayOverride("UEB4301", "ues3401", "8e86fefc485a76ad1aa1e55894d0dbb3823cec2f58b175dccfbc6d67c6b67e78", "67abce0dbcd88803957cdad1a01a6e0931a553fcfa583083e682d238ee0a0bd9", 500, 3750, 3000, 50000, 400, 20, 15000, 23, 131, 1, 44, 0, null, null, null, pauseSupported: false), ShieldVisualContract.UefT3())),
		new PatchSpec("LJ/lua/host/units/unitsClasses/unitsBaseClass.lua", "support-shield owner lifecycle", "\n-- Exact FA support-shield rotor lifecycle. Sanctuary normally enables a\n-- shield unit's rotators throughout the recharge window; FA starts them\n-- only when the shield is actually enabled (or while UEB4202 upgrades).\nlocal SCO_FaSupportShieldUnit = HostUnit or Unit\nif not SCO_FaSupportShieldUnit then\n    error(\"FA support shields could not resolve the host unit base class.\")\nend\nlocal SCO_FaSupportStockCheckShieldState = SCO_FaSupportShieldUnit.CheckShieldState\nlocal SCO_FaSupportStockOnStopBeingBuilt = SCO_FaSupportShieldUnit.OnStopBeingBuilt\nlocal SCO_FaSupportStockOnStartUpgrading = SCO_FaSupportShieldUnit.OnStartUpgrading\nlocal SCO_FaSupportStockOnEndUpgrading = SCO_FaSupportShieldUnit.OnEndUpgrading\n\nfunction SCO_FaSupportShieldUnit:SCOApplySupportShieldRotators(enabled, upgrading, initial)\n    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield\n    if not contract or not self.shields or not self.rotatorIds then\n        return\n    end\n    local speeds = initial and contract.initialRotatorSpeeds\n        or (upgrading and contract.upgradeRotatorSpeeds)\n        or contract.steadyRotatorSpeeds\n    for index, speed in ipairs(speeds or {}) do\n        local rotatorId = self.rotatorIds and self.rotatorIds[index]\n        if rotatorId then\n            Engine.SetRotatorSpeed(\n                rotatorId,\n                EngineClasses.float3(speed.x, speed.y, speed.z)\n            )\n        end\n    end\n    self:SetRotatorsEnabled(enabled)\nend\n\nfunction SCO_FaSupportShieldUnit:CheckShieldState(skipRecharge)\n    SCO_FaSupportStockCheckShieldState(self, skipRecharge)\n    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield\n    if not contract then\n        return\n    end\n    local actualShieldEnabled = false\n    for _, shield in pairs(self.shields or {}) do\n        if shield.enabled then\n            actualShieldEnabled = true\n            break\n        end\n    end\n    local upgrading = self.scoFaSupportShieldUpgrading == true\n    self:SCOApplySupportShieldRotators(actualShieldEnabled or upgrading, upgrading)\nend\n\nfunction SCO_FaSupportShieldUnit:OnStopBeingBuilt()\n    SCO_FaSupportStockOnStopBeingBuilt(self)\n    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield\n    if not contract then\n        return\n    end\n    local actualShieldEnabled = false\n    for _, shield in pairs(self.shields or {}) do\n        if shield.enabled then\n            actualShieldEnabled = true\n            break\n        end\n    end\n    self:SCOApplySupportShieldRotators(actualShieldEnabled, false, true)\nend\n\nfunction SCO_FaSupportShieldUnit:OnStartUpgrading(targetUnit)\n    SCO_FaSupportStockOnStartUpgrading(self, targetUnit)\n    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield\n    if contract and contract.upgradeRotatorSpeeds then\n        self.scoFaSupportShieldUpgrading = true\n        self:SCOApplySupportShieldRotators(true, true)\n    end\nend\n\nfunction SCO_FaSupportShieldUnit:OnEndUpgrading(targetUnit)\n    SCO_FaSupportStockOnEndUpgrading(self, targetUnit)\n    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield\n    if not contract then\n        return\n    end\n    self.scoFaSupportShieldUpgrading = false\n    if self.dead or self.deleted then\n        return\n    end\n    local actualShieldEnabled = false\n    for _, shield in pairs(self.shields or {}) do\n        if shield.enabled then\n            actualShieldEnabled = true\n            break\n        end\n    end\n    self:SCOApplySupportShieldRotators(actualShieldEnabled, false)\nend"),
		new PatchSpec("LJ/lua/host/shield.lua", "support-shield recharge lifecycle", "\n-- FA uses ShieldRechargeTime after damage and restores the bubble at full\n-- health. Manual disable and an energy stall preserve current HP and use\n-- the independent ShieldEnergyDrainRechargeTime (5 seconds).\nlocal SCO_FaSupportStockShieldSetEnableable = HostShield.SetEnableable\nlocal SCO_FaSupportStockShieldSetEnabled = HostShield.SetEnabled\n\nlocal function SCO_FaSupportShieldContract(shield)\n    local owner = shield.owner\n    return owner\n        and owner.tp\n        and owner.tp.additions\n        and owner.tp.additions.faSupportShield\nend\n\nfunction HostShield:SCOFaSupportEnergyRechargeThread()\n    local contract = SCO_FaSupportShieldContract(self)\n    if not contract then\n        self.rechargeThread = nil\n        return\n    end\n    WaitSeconds(contract.energyDrainRechargeTime)\n    if not self.isEnableable then\n        self.rechargeThread = nil\n        return\n    end\n    local maximum = self:GetMaxHealth()\n    local restored = self.scoFaSupportOffHealth or maximum\n    if restored <= 0 then\n        restored = maximum\n    end\n    self:SetEnabled(true)\n    self:SetRegenEnabled(true)\n    self:SetHealth(math.min(restored, maximum))\n    self.scoFaSupportOffHealth = nil\n    self.rechargeThread = nil\nend\n\nfunction HostShield:SetEnableable(value, skipRecharge)\n    local contract = SCO_FaSupportShieldContract(self)\n    if not contract then\n        return SCO_FaSupportStockShieldSetEnableable(self, value, skipRecharge)\n    end\n    if value == self.isEnableable then\n        return\n    end\n    self.isEnableable = value\n    if value then\n        if skipRecharge then\n            self:SetEnabled(true)\n            self:SetRegenEnabled(true)\n            self:SetHealth(self:GetMaxHealth())\n            self.scoFaSupportOffHealth = nil\n        else\n            self.rechargeThread = self:NewThread(self.SCOFaSupportEnergyRechargeThread)\n        end\n        return\n    end\n    if self.rechargeThread then\n        KillThread(self.rechargeThread)\n        self.rechargeThread = nil\n    end\n    if self.regenAfterDelayThread then\n        KillThread(self.regenAfterDelayThread)\n        self.regenAfterDelayThread = nil\n    end\n    self.scoFaSupportOffHealth = self:GetHealth()\n    self:SetEnabled(false)\n    self:SetRegenEnabled(false)\nend\n\nfunction HostShield:SetEnabled(value)\n    local wasEnabled = self.enabled\n    SCO_FaSupportStockShieldSetEnabled(self, value)\n    if self.enabled == wasEnabled then\n        return\n    end\n    local owner = self.owner\n    local contract = SCO_FaSupportShieldContract(self)\n    if owner and contract then\n        local upgrading = owner.scoFaSupportShieldUpgrading == true\n        owner:SCOApplySupportShieldRotators(self.enabled or upgrading, upgrading)\n    end\nend")
	};

	private const string SupportShieldOwnerLifecycleOverride = "\n-- Exact FA support-shield rotor lifecycle. Sanctuary normally enables a\n-- shield unit's rotators throughout the recharge window; FA starts them\n-- only when the shield is actually enabled (or while UEB4202 upgrades).\nlocal SCO_FaSupportShieldUnit = HostUnit or Unit\nif not SCO_FaSupportShieldUnit then\n    error(\"FA support shields could not resolve the host unit base class.\")\nend\nlocal SCO_FaSupportStockCheckShieldState = SCO_FaSupportShieldUnit.CheckShieldState\nlocal SCO_FaSupportStockOnStopBeingBuilt = SCO_FaSupportShieldUnit.OnStopBeingBuilt\nlocal SCO_FaSupportStockOnStartUpgrading = SCO_FaSupportShieldUnit.OnStartUpgrading\nlocal SCO_FaSupportStockOnEndUpgrading = SCO_FaSupportShieldUnit.OnEndUpgrading\n\nfunction SCO_FaSupportShieldUnit:SCOApplySupportShieldRotators(enabled, upgrading, initial)\n    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield\n    if not contract or not self.shields or not self.rotatorIds then\n        return\n    end\n    local speeds = initial and contract.initialRotatorSpeeds\n        or (upgrading and contract.upgradeRotatorSpeeds)\n        or contract.steadyRotatorSpeeds\n    for index, speed in ipairs(speeds or {}) do\n        local rotatorId = self.rotatorIds and self.rotatorIds[index]\n        if rotatorId then\n            Engine.SetRotatorSpeed(\n                rotatorId,\n                EngineClasses.float3(speed.x, speed.y, speed.z)\n            )\n        end\n    end\n    self:SetRotatorsEnabled(enabled)\nend\n\nfunction SCO_FaSupportShieldUnit:CheckShieldState(skipRecharge)\n    SCO_FaSupportStockCheckShieldState(self, skipRecharge)\n    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield\n    if not contract then\n        return\n    end\n    local actualShieldEnabled = false\n    for _, shield in pairs(self.shields or {}) do\n        if shield.enabled then\n            actualShieldEnabled = true\n            break\n        end\n    end\n    local upgrading = self.scoFaSupportShieldUpgrading == true\n    self:SCOApplySupportShieldRotators(actualShieldEnabled or upgrading, upgrading)\nend\n\nfunction SCO_FaSupportShieldUnit:OnStopBeingBuilt()\n    SCO_FaSupportStockOnStopBeingBuilt(self)\n    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield\n    if not contract then\n        return\n    end\n    local actualShieldEnabled = false\n    for _, shield in pairs(self.shields or {}) do\n        if shield.enabled then\n            actualShieldEnabled = true\n            break\n        end\n    end\n    self:SCOApplySupportShieldRotators(actualShieldEnabled, false, true)\nend\n\nfunction SCO_FaSupportShieldUnit:OnStartUpgrading(targetUnit)\n    SCO_FaSupportStockOnStartUpgrading(self, targetUnit)\n    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield\n    if contract and contract.upgradeRotatorSpeeds then\n        self.scoFaSupportShieldUpgrading = true\n        self:SCOApplySupportShieldRotators(true, true)\n    end\nend\n\nfunction SCO_FaSupportShieldUnit:OnEndUpgrading(targetUnit)\n    SCO_FaSupportStockOnEndUpgrading(self, targetUnit)\n    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield\n    if not contract then\n        return\n    end\n    self.scoFaSupportShieldUpgrading = false\n    if self.dead or self.deleted then\n        return\n    end\n    local actualShieldEnabled = false\n    for _, shield in pairs(self.shields or {}) do\n        if shield.enabled then\n            actualShieldEnabled = true\n            break\n        end\n    end\n    self:SCOApplySupportShieldRotators(actualShieldEnabled, false)\nend";

	private const string SupportShieldRechargeLifecycleOverride = "\n-- FA uses ShieldRechargeTime after damage and restores the bubble at full\n-- health. Manual disable and an energy stall preserve current HP and use\n-- the independent ShieldEnergyDrainRechargeTime (5 seconds).\nlocal SCO_FaSupportStockShieldSetEnableable = HostShield.SetEnableable\nlocal SCO_FaSupportStockShieldSetEnabled = HostShield.SetEnabled\n\nlocal function SCO_FaSupportShieldContract(shield)\n    local owner = shield.owner\n    return owner\n        and owner.tp\n        and owner.tp.additions\n        and owner.tp.additions.faSupportShield\nend\n\nfunction HostShield:SCOFaSupportEnergyRechargeThread()\n    local contract = SCO_FaSupportShieldContract(self)\n    if not contract then\n        self.rechargeThread = nil\n        return\n    end\n    WaitSeconds(contract.energyDrainRechargeTime)\n    if not self.isEnableable then\n        self.rechargeThread = nil\n        return\n    end\n    local maximum = self:GetMaxHealth()\n    local restored = self.scoFaSupportOffHealth or maximum\n    if restored <= 0 then\n        restored = maximum\n    end\n    self:SetEnabled(true)\n    self:SetRegenEnabled(true)\n    self:SetHealth(math.min(restored, maximum))\n    self.scoFaSupportOffHealth = nil\n    self.rechargeThread = nil\nend\n\nfunction HostShield:SetEnableable(value, skipRecharge)\n    local contract = SCO_FaSupportShieldContract(self)\n    if not contract then\n        return SCO_FaSupportStockShieldSetEnableable(self, value, skipRecharge)\n    end\n    if value == self.isEnableable then\n        return\n    end\n    self.isEnableable = value\n    if value then\n        if skipRecharge then\n            self:SetEnabled(true)\n            self:SetRegenEnabled(true)\n            self:SetHealth(self:GetMaxHealth())\n            self.scoFaSupportOffHealth = nil\n        else\n            self.rechargeThread = self:NewThread(self.SCOFaSupportEnergyRechargeThread)\n        end\n        return\n    end\n    if self.rechargeThread then\n        KillThread(self.rechargeThread)\n        self.rechargeThread = nil\n    end\n    if self.regenAfterDelayThread then\n        KillThread(self.regenAfterDelayThread)\n        self.regenAfterDelayThread = nil\n    end\n    self.scoFaSupportOffHealth = self:GetHealth()\n    self:SetEnabled(false)\n    self:SetRegenEnabled(false)\nend\n\nfunction HostShield:SetEnabled(value)\n    local wasEnabled = self.enabled\n    SCO_FaSupportStockShieldSetEnabled(self, value)\n    if self.enabled == wasEnabled then\n        return\n    end\n    local owner = self.owner\n    local contract = SCO_FaSupportShieldContract(self)\n    if owner and contract then\n        local upgrading = owner.scoFaSupportShieldUpgrading == true\n        owner:SCOApplySupportShieldRotators(self.enabled or upgrading, upgrading)\n    end\nend";

	private static string SupportTemplateOverride(double centerY, double centerZ, double collisionX, double collisionY, double collisionZ, double tarmacX, double tarmacZ, double selectionX, double selectionZ, double footprintX, double footprintZ, int skirtX, int skirtZ, string gameplayOverride, ShieldVisualContract? shieldVisual = null)
	{
		string text = ((shieldVisual == null) ? "UnitTemplate.additions.rotators = nil" : shieldVisual.BuildRotatorsLua());
		string text2 = shieldVisual?.BuildShieldOverrideLua() ?? string.Empty;
		return $"\n-- Imported source art uses its own static rig. Remove donor visual\n-- hooks whose bones cannot exist, then apply the pinned FA gameplay\n-- contract below without replacing the model-safe placement values.\nUnitTemplate.additions = UnitTemplate.additions or {{}}\n{text}\nUnitTemplate.additions.tarmacSize = {{\n    x = {Lua(tarmacX)},\n    y = {Lua(tarmacZ)},\n}}\nUnitTemplate.additions.selectionHit = {{\n    size = {{\n        x = {Lua(selectionX)},\n        y = {Lua(selectionZ)},\n    }},\n    offset = {{\n        x = 0,\n        y = {Lua(centerY)},\n        z = {Lua(centerZ)},\n    }},\n}}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.holes = nil\n\nUnitTemplate.collisionInfo = {{\n    centerOffset = {{\n        x = 0,\n        y = {Lua(centerY)},\n        z = {Lua(centerZ)},\n    }},\n    collisionSize = {{\n        x = {Lua(collisionX)},\n        y = {Lua(collisionY)},\n        z = {Lua(collisionZ)},\n    }},\n}}\nUnitTemplate.visuals.selection = {{\n    offset = {{\n        x = 0,\n        y = {Lua(centerY)},\n        z = {Lua(centerZ)},\n    }},\n    size = {{\n        x = {Lua(selectionX)},\n        y = {Lua(selectionZ)},\n    }},\n}}\nUnitTemplate.footprint = {{\n    x = {Lua(footprintX)},\n    y = {Lua(footprintZ)},\n}}\nUnitTemplate.skirtSize = {{\n    x = {skirtX},\n    y = {skirtZ},\n}}\n{gameplayOverride}\n{text2}\n\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do\n            effect.boneName = \"Root\"\n        end\n    end\nend";
		static string Lua(double value)
		{
			return value.ToString("0.##", CultureInfo.InvariantCulture);
		}
	}

	private static string StorageGameplayOverride(string sourceId, string targetId, string sourceBlueprintSha256, string sourceScriptSha256, int health, int buildTime, int alloys, int energy, string storageKey, int storageValue, string adjacency, string manipulationBone, string manipulationResource, string manipulationOffset)
	{
		string text = ((sourceId == "UEB1105") ? "UEB1105_Script.lua" : (sourceId + "_script.lua"));
		string text2 = ((storageKey == "alloys") ? "T1MassStorageAdjacencyBuffs" : "T1EnergyStorageAdjacencyBuffs");
		string text3 = ((storageKey == "alloys") ? "ALLOYS_STORAGE" : "ENERGY_STORAGE");
		return string.Format("-- Exact FA storage gameplay. The source blueprints omit Intel.VisionRadius,\n-- which FA resolves to zero; retaining the Sanctuary donor's radius 10\n-- would therefore be a gameplay change.\nUnitTemplate.additions = UnitTemplate.additions or {{}}\nUnitTemplate.additions.faSourceContract = {{\n    mapping = \"{0} -> {1}\",\n    sourceArchiveSha256 = \"{2}\",\n    sourceBlueprint = \"units/{3}/{4}_unit.bp\",\n    sourceBlueprintSha256 = \"{5}\",\n    sourceScript = \"units/{6}/{7}\",\n    sourceScriptSha256 = \"{8}\",\n    sourceVisionRadiusDeclared = false,\n    resolvedSourceVisionRadius = 0,\n    sourceAdjacency = \"{9}\",\n    sanctuaryAdjacency = \"{10}\",\n    sourceStorageManipulation = {{\n        bone = \"{11}\",\n        resource = \"{12}\",\n        offset = {{ {13} }},\n    }},\n    sanctuaryStorageFillManipulationSupported = false,\n    sourceCommanderBuildCategoriesSupported = false,\n    audio = {{\n        sourceBanksImported = false,\n        sourceActiveLoopSupported = false,\n        sourceCompletionCueSupported = false,\n        donorRootPersistentLoopRetained = false,\n    }},\n}}\nUnitTemplate.adjacency = \"{14}\"\nUnitTemplate.defence = UnitTemplate.defence or {{}}\nUnitTemplate.defence.health = {{ max = {15}, regen = 0, value = {16} }}\nUnitTemplate.economy = {{\n    buildTime = {17},\n    cost = {{ alloys = {18}, energy = {19} }},\n    storage = {{ {20} = {21} }},\n}}\nUnitTemplate.intel = {{ visionRadius = 0 }}\n\nlocal SCO_SupportStorageTags = {{}}\nfor _, tag in ipairs(UnitTemplate.tags or {{}}) do\n    if tag ~= \"ALLOYS_STORAGE\" and tag ~= \"ENERGY_STORAGE\" then\n        table.insert(SCO_SupportStorageTags, tag)\n    end\nend\ntable.insert(SCO_SupportStorageTags, \"{22}\")\nUnitTemplate.tags = SCO_SupportStorageTags\n\nlocal SCO_SupportDestroyedAudio = UnitTemplate.audio and UnitTemplate.audio.onDestroyed\nUnitTemplate.audio = SCO_SupportDestroyedAudio\n    and {{ onDestroyed = SCO_SupportDestroyedAudio }}\n    or nil", sourceId, targetId, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", sourceId, sourceId, sourceBlueprintSha256, sourceId, text, sourceScriptSha256, text2, adjacency, manipulationBone, manipulationResource, manipulationOffset, adjacency, health, health, buildTime, alloys, energy, storageKey, storageValue, text3);
	}

	private static string ShieldGameplayOverride(string sourceId, string targetId, string sourceBlueprintSha256, string sourceScriptSha256, int health, int buildTime, int alloys, int energy, int maintenanceEnergy, int visionRadius, int shieldHealth, int damageRechargeTime, int shieldRegen, int shieldRegenDelay, int sourceShieldDiameter, int buildPower, string? sourceUpgradesTo, string? sanctuaryUpgradesTo, string? progressionSubstitution, bool pauseSupported)
	{
		string text = ((buildPower > 0) ? $"UnitTemplate.construction = {{\n    buildPower = {buildPower},\n    canBuild = \"Tags.{sanctuaryUpgradesTo}\",\n    upgradesTo = \"{sanctuaryUpgradesTo}\",\n}}" : "UnitTemplate.construction = nil");
		string text2 = ((sourceUpgradesTo == null) ? "sourceUpgradesTo = nil,\n                sanctuaryUpgradesTo = nil," : ("sourceUpgradesTo = \"" + sourceUpgradesTo + "\",\nsanctuaryUpgradesTo = \"" + sanctuaryUpgradesTo + "\",\nprogressionSubstitution = \"" + progressionSubstitution + "\","));
		string text3 = (pauseSupported ? "{ Pause = false, Shield = true }" : "{ Shield = true }");
		int num = sourceShieldDiameter / 2;
		return string.Format("-- Exact FA shield health, economy, toggle, and recharge semantics.\nUnitTemplate.additions = UnitTemplate.additions or {{}}\nUnitTemplate.additions.faSourceContract = {{\n    mapping = \"{0} -> {1}\",\n    sourceArchiveSha256 = \"{2}\",\n    sourceBlueprint = \"units/{3}/{4}_unit.bp\",\n    sourceBlueprintSha256 = \"{5}\",\n    sourceScript = \"units/{6}/{7}_script.lua\",\n    sourceScriptSha256 = \"{8}\",\n    {9}\n    sourceShieldSizeDiameter = {10},\n    sanctuaryShieldRadius = {11},\n    sourceShieldVerticalOffset = {12},\n    modelSafeShieldAnchorUsed = true,\n    sourceShieldEnergyDrainRechargeTime = 5,\n    separateEnergyDrainRechargeSupported = true,\n    sourceDamageRechargeRestoresFullHealth = true,\n    sanctuaryDamageRechargeHPRatio = 1,\n    sourceRegenAssistMultiplier = 60,\n    sanctuaryRegenAssistMultiplierSupported = false,\n    sourceEmitterGraphSupported = false,\n    sourceShieldAudioBanksImported = false,\n    donorShieldLoopRetained = false,\n    sourceSkirtOffsetSupported = false,\n}}\nUnitTemplate.defence = UnitTemplate.defence or {{}}\nUnitTemplate.defence.health = {{ max = {13}, regen = 0, value = {14} }}\nlocal SCO_SupportShield = UnitTemplate.defence.shields and UnitTemplate.defence.shields[1] or {{}}\nUnitTemplate.defence.shields = {{ SCO_SupportShield }}\nSCO_SupportShield.max = {15}\nSCO_SupportShield.value = {16}\nSCO_SupportShield.name = \"Bubble Shield\"\nSCO_SupportShield.radii = {{ x = {17}, y = {18}, z = {19} }}\nSCO_SupportShield.rechargeHPRatio = 1\nSCO_SupportShield.rechargeTime = {20}\nSCO_SupportShield.regen = {21}\nSCO_SupportShield.regenDelay = {22}\nSCO_SupportShield.type = 0\nSCO_SupportShield.effectsPersistent = nil\nSCO_SupportShield.audio = nil\nUnitTemplate.economy = {{\n    buildTime = {23},\n    cost = {{ alloys = {24}, energy = {25} }},\n    maintenanceConsumption = {{ energy = {26} }},\n}}\nUnitTemplate.intel = {{ visionRadius = {27} }}\nUnitTemplate.general.toggles = {28}\n{29}\n\nlocal SCO_SupportDestroyedAudio = UnitTemplate.audio and UnitTemplate.audio.onDestroyed\nUnitTemplate.audio = SCO_SupportDestroyedAudio\n    and {{ onDestroyed = SCO_SupportDestroyedAudio }}\n    or nil", sourceId, targetId, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", sourceId, sourceId, sourceBlueprintSha256, sourceId, sourceId, sourceScriptSha256, text2, sourceShieldDiameter, num, (sourceId == "UEB4301") ? (-6) : (-3), health, health, shieldHealth, shieldHealth, num, num, num, damageRechargeTime, shieldRegen, shieldRegenDelay, buildTime, alloys, energy, maintenanceEnergy, visionRadius, text3, text);
	}

	public static void Apply()
	{
		List<CachedResource> list = new List<CachedResource>(PatchSpecs.Length);
		object obj = null;
		bool flag = false;
		try
		{
			obj = GetLuaFileCache();
			PatchSpec[] patchSpecs = PatchSpecs;
			foreach (PatchSpec patchSpec in patchSpecs)
			{
				if (!TryGetCachedResource(obj, patchSpec, out CachedResource resource))
				{
					throw new FileNotFoundException("The required " + patchSpec.Description + " was not present in Sanctuary's Lua file cache.", patchSpec.RelativePath);
				}
				list.Add(resource);
			}
			int num = list.Count((CachedResource cachedResource) => ContainsOverride(cachedResource.Stock));
			if (num == list.Count)
			{
				Log("All direct FA support-structure templates already contain the override.");
				return;
			}
			if (num != 0)
			{
				throw new InvalidOperationException("A partial support-structure cache override was found; the patcher will not mix cached template generations.");
			}
			foreach (CachedResource item in list)
			{
				item.Replacement = CreateReplacement(item.Stock, item.Spec);
				if (!ContainsOverride(item.Replacement))
				{
					throw new InvalidOperationException("The replacement " + item.Spec.Description + " did not retain its override marker.");
				}
			}
			foreach (CachedResource item2 in list)
			{
				item2.ReplacementWasAssigned = true;
				SetCachedResource(obj, item2.Path, item2.Replacement);
			}
			flag = true;
			foreach (CachedResource item3 in list)
			{
				TryDisposeNativeArray(item3.Stock.GetType(), item3.Stock, "stock " + item3.Spec.Description);
			}
			Log("Applied seven exact FA storage/shield gameplay contracts, measured placement, and scoped shield recharge/rotor lifecycle.");
		}
		catch (Exception arg)
		{
			if (!flag)
			{
				if (obj != null)
				{
					RollBackAndDispose(obj, list);
				}
				else
				{
					foreach (CachedResource item4 in list)
					{
						if (item4.Replacement != null && IsNativeArrayCreated(item4.Replacement))
						{
							TryDisposeNativeArray(item4.Replacement.GetType(), item4.Replacement, "replacement " + item4.Spec.Description);
						}
					}
				}
			}
			Log($"Failed to replace the cached direct FA support templates: {arg}");
			throw;
		}
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static bool TryGetCachedResource(object cache, PatchSpec spec, out CachedResource resource)
	{
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string fullPath = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), spec.RelativePath));
		if ((bool)obj.Invoke(cache, new object[1] { fullPath }))
		{
			object obj2 = propertyInfo.GetValue(cache, new object[1] { fullPath }) ?? throw new InvalidOperationException("The cached " + spec.Description + " has no value.");
			if (!IsNativeArrayCreated(obj2))
			{
				throw new InvalidOperationException("The cached " + spec.Description + " is not an initialized NativeArray.");
			}
			resource = new CachedResource(spec, fullPath, obj2);
			return true;
		}
		string value = "/" + spec.RelativePath;
		string text = null;
		object obj3 = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			string text2 = (string)type2.GetProperty("Key")?.GetValue(item);
			if (text2 != null && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (text != null)
				{
					throw new InvalidOperationException("More than one cached resource matches the exact " + spec.RelativePath + " suffix.");
				}
				object obj4 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("The cached " + spec.Description + " has no value.");
				if (!IsNativeArrayCreated(obj4))
				{
					throw new InvalidOperationException("The cached " + spec.Description + " is not an initialized NativeArray.");
				}
				text = text2;
				obj3 = obj4;
			}
		}
		if (text == null || obj3 == null)
		{
			resource = null;
			return false;
		}
		resource = new CachedResource(spec, text, obj3);
		return true;
	}

	private static object CreateReplacement(object stockResource, PatchSpec spec)
	{
		Type type = stockResource.GetType();
		byte[] nativeArrayBytes = GetNativeArrayBytes(type, stockResource);
		string text = Encoding.UTF8.GetString(nativeArrayBytes).Replace("\r\n", "\n");
		byte[] bytes = Encoding.UTF8.GetBytes(text + spec.Appendix);
		return NativeArrayByteFactory.CreatePersistent(type, bytes);
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void RollBackAndDispose(object cache, IEnumerable<CachedResource> resources)
	{
		foreach (CachedResource item in resources.Reverse())
		{
			bool flag = !item.ReplacementWasAssigned;
			if (item.ReplacementWasAssigned)
			{
				try
				{
					SetCachedResource(cache, item.Path, item.Stock);
					flag = true;
				}
				catch (Exception arg)
				{
					Log($"Rollback failed for {item.Spec.Description}: {arg}");
				}
			}
			if (flag && item.Replacement != null && IsNativeArrayCreated(item.Replacement))
			{
				TryDisposeNativeArray(item.Replacement.GetType(), item.Replacement, "replacement " + item.Spec.Description);
			}
		}
	}

	private static byte[] GetNativeArrayBytes(Type nativeArrayType, object nativeArray)
	{
		return (byte[])(nativeArrayType.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "ToArray")).Invoke(nativeArray, null);
	}

	private static bool IsNativeArrayCreated(object nativeArray)
	{
		return (bool)(nativeArray.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(nativeArray.GetType().FullName, "IsCreated")).GetValue(nativeArray);
	}

	private static void TryDisposeNativeArray(Type nativeArrayType, object nativeArray, string description)
	{
		try
		{
			(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
		}
		catch (Exception arg)
		{
			Log($"Could not dispose {description}: {arg}");
		}
	}

	private static bool ContainsOverride(object resource)
	{
		if (IsNativeArrayCreated(resource))
		{
			return Encoding.UTF8.GetString(GetNativeArrayBytes(resource.GetType(), resource)).IndexOf("-- FA Support Structures Cache Patcher 1.1.2", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	private static void Log(string message)
	{
		string text = "[FA Support Structures Cache Patcher] " + message;
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
