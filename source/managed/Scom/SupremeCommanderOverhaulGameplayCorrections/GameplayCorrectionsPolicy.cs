using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using ScomDeterministicLua;

namespace SupremeCommanderOverhaulGameplayCorrections;

public static class GameplayCorrectionsPolicy
{
	public const string LoaderMarker = "-- Supreme Commander Overhaul gameplay corrections 1.0.2";

	public const string HostMarker = "-- Supreme Commander Overhaul engineer medium probe 1.0.0";

	public const string NavalWreckSinkMarker = "-- Supreme Commander Overhaul naval wreck sinking 1.1.0";

	public const string IdleResetMarker = "-- Supreme Commander Overhaul locomotion and weapon idle reset 1.3.0";

	public const string EngineerWaterMarker = "-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0";

	public const string SeraphimFactoryOrientationMarker = "-- Supreme Commander Overhaul Seraphim factory orientation correction 1.1.0";

	public const string HostOrientationApiMarker = "-- Supreme Commander Overhaul host orientation API correction 1.2.0";

	public const string ConstructionBeamPaletteMarker = "-- Supreme Commander Overhaul construction beam faction palette 1.3.3";

	public const string EdaLandFactoryBeamMarker = "-- Supreme Commander Overhaul UEF land-factory beam palette 1.3.0";

	public const string FaAirFactoryBeamMarker = "-- Supreme Commander Overhaul UEF air-factory beam palette 1.3.0";

	public const string T1ExtractorVisionVersion = "1.1.0";

	public const int T1ExtractorVisionRadius = 15;

	public const string GuardBeamMaterial = "VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial";

	public const string AeonBeamMaterial = "VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial";

	public const string SeraphimBeamMaterial = "VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial";

	public const string UefBeamMaterial = "VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial";

	public const string PrometheanBeamMaterial = "Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial";

	private const string SeraphimFactoryUpstreamMarker = "-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0";

	private const string SeraphimDeathUpstreamMarker = "-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0";

	private const string SeraphimUnscopedRampGuard = "    if not SCO_SeraphimFactoryAlive(target) or not ramp then return end";

	private const string SeraphimMobileRampGuard = "    if not SCO_SeraphimFactoryAlive(target) or not target:HasTags(Tags.MOBILE) or not ramp then return end";

	private const string BrokenHostOrientationMethod = "function HostEntity:SetOrientation(orientation)\n    Engine.SetGlobalEntityRotation(self.id, orientation)\nend";

	private const string SupportedHostOrientationMethod = "function HostEntity:SetOrientation(orientation)\n    Engine.SetGlobalEntityLocalRotation(self.id, orientation)\nend";

	private const string CreatePrefabSignature = "function CreateUnitPrefab(tp)";

	private const string CommanderBeamVersion = "1.3.0";

	private const string EngineerBeamVersion = "1.0.0";

	private const int T1ExtractorUncorrectedVisionRadius = 0;

	private const double CommanderBeamShrink = 0.05;

	private const string OldMediumProbe = "    local requiredDepth = previous and SCOFaEngineerWaterExitDepth or SCOFaEngineerWaterEnterDepth\n    return terrainHeight < waterLevel - requiredDepth";

	private const string NewMediumProbe = "    local requiredDepth = previous and SCOFaEngineerWaterExitDepth or SCOFaEngineerWaterEnterDepth\n    -- Bathymetry alone misclassifies units standing above submerged terrain.\n    if position.y > waterLevel + requiredDepth then return false end\n    return terrainHeight < waterLevel - requiredDepth";

	private const string NavalUnitClassAnchor = "---@class HostNavalUnit: HostMobileUnit\nHostNavalUnit = Class(\"NavalUnit\", HostMobileUnit)";

	private const string NativeNavalWreckSpawn = "function HostNavalUnit:OnSpawnWreckage(overkillRatio)\n    local _, hasWater = Engine.HasWater()\n\n    if not hasWater then\n        return HostUnit.OnSpawnWreckage(self, overkillRatio)\n    end\n\n    WreckCrash.StartWreckCrash(self, overkillRatio, true)\nend";

	private const string StockWreckCrashSignature = "local function WreckCrashThread(wreck, position, velocity, headingRadians, deleteAtRest, crashScale)";

	private const string CompatibleWreckCrashSignature = "local function WreckCrashThread(wreck, position, velocity, headingRadians, deleteAtRest, crashScale, startSinking)";

	private const string StockWreckCrashState = "    local sinking = false";

	private const string CompatibleWreckCrashState = "    local sinking = startSinking == true";

	private const string NavalWreckSinkBlock = "---@class HostNavalUnit: HostMobileUnit\nHostNavalUnit = Class(\"NavalUnit\", HostMobileUnit)\n\n-- Supreme Commander Overhaul naval wreck sinking 1.1.0\nlocal function SCOGameplayStartWreckCrash(unit, overkillRatio, startSinking)\n    local dt = Constants.TickTimeStep\n\n    local _, speedPerTick = Engine.GetMovementCurrentSpeed(unit.id)\n    local _, headingDegrees = Engine.GetMovementHeadingDegrees(unit.id)\n    local headingRadians = math.rad(headingDegrees)\n    local speed = speedPerTick / dt\n    local velocity = EngineClasses.float3(\n        math.sin(headingRadians) * speed,\n        0,\n        math.cos(headingRadians) * speed)\n    local _, position = Engine.GetGlobalEntityWorldPosition(unit.id)\n\n    local deleteAtRest = (overkillRatio or 0) >= 1\n        or not unit.spawnsWreck\n        or unit:GetFractionComplete() < 0.5\n    local crashScale = (unit:HasTags(Tags.TECH4)\n        or unit:HasTags(Tags.TECH5))\n        and CrashScaleLarge\n        or CrashScaleDefault\n    local wreckage = CreateWreckageFromUnit(unit)\n\n    if wreckage then\n        wreckage:NewThread(function()\n            WreckCrashThread(\n                wreckage,\n                position,\n                velocity,\n                headingRadians,\n                deleteAtRest,\n                crashScale,\n                startSinking)\n        end)\n    end\nend\n\nfunction HostNavalUnit:DeathThread(overkillRatio)\n    SCOGameplayStartWreckCrash(self, overkillRatio, true)\n    self:Delete()\nend";

	private const string OldConstructionBeamMaterialBlock = "        local constructionBeamMaterialPath\n        -- SCO_AeonConstructionBeamMaterial\n        if (tp.additions and tp.additions.faSourceContract)\n            or (\n                tp.general.tpId == \"ucl0000\"\n                and tp.construction.beam.boneName == \"Left_Turret_Muzzle\"\n            )\n        then\n            constructionBeamMaterialPath = \"VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        else\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have a faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        end";

	private const string PrometheanConstructionBeamMaterialBlock = "        local constructionBeamMaterialPath\n        -- SCO_AeonConstructionBeamMaterial\n        if (tp.additions and tp.additions.faSourceContract)\n            or (\n                tp.general.tpId == \"ucl0000\"\n                and tp.construction.beam.boneName == \"Left_Turret_Muzzle\"\n            )\n        then\n            constructionBeamMaterialPath = \"VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") or table.find(tp.tags, \"PROMETHEAN\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        else\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have a faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        end";

	private const string CurrentPrometheanConstructionBeamMaterialBlock = "        local constructionBeamMaterialPath\n        if table.find(tp.tags, \"PROMETHEAN\") then\n            constructionBeamMaterialPath = \"Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"CHOSEN\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        else\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have a faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        end";

	private const string NewConstructionBeamMaterialBlock = "        local constructionBeamMaterialPath\n        -- Supreme Commander Overhaul construction beam faction palette 1.3.3\n        local SCO_GameplayBeamFactionCount = 0\n        if type(tp.tags) == \"table\" then\n            for _, factionTag in ipairs({ \"EDA\", \"CHOSEN\", \"GUARD\", \"PROMETHEAN\", \"SERAPHIM\" }) do\n                if table.find(tp.tags, factionTag) then\n                    SCO_GameplayBeamFactionCount = SCO_GameplayBeamFactionCount + 1\n                end\n            end\n        end\n        if SCO_GameplayBeamFactionCount ~= 1 then\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have exactly one faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") or table.find(tp.tags, \"PROMETHEAN\") then\n            if table.find(tp.tags, \"PROMETHEAN\") then\n                constructionBeamMaterialPath = \"Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial\"\n            else\n                constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n            end\n        elseif table.find(tp.tags, \"CHOSEN\") then\n            constructionBeamMaterialPath = \"VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial\"\n        elseif table.find(tp.tags, \"SERAPHIM\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        else\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        end";

	private const string OldEdaLandFactoryBeamSnippet = "        \"VFX/Models/Static/ConstructionBeam.sanmodel\",\n        \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\",\n        EngineClasses.float3(0.05, 1, 1),";

	private const string NewEdaLandFactoryBeamSnippet = "        \"VFX/Models/Static/ConstructionBeam.sanmodel\",\n        -- Supreme Commander Overhaul UEF land-factory beam palette 1.3.0\n        \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\",\n        EngineClasses.float3(0.05, 1, 1),";

	private const string OldFaAirFactoryBeamFunction = "local function SCOFaAirFactoryBeamMaterial(factory)\n    if factory:HasTags(Tags.EDA) then\n        return \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n    end\n    return \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\nend";

	private const string NewFaAirFactoryBeamFunction = "local function SCOFaAirFactoryBeamMaterial(factory)\n    -- Supreme Commander Overhaul UEF air-factory beam palette 1.3.0\n    if factory:HasTags(Tags.EDA) then\n        return \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n    end\n    return \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\nend";

	private static readonly string[] T1ExtractorVisionEntries;

	private static readonly EngineerCorrectionSpec[] EngineerEntries;

	private static readonly CommanderBeamCorrectionSpec[] CommanderBeamEntries;

	private static readonly EngineerBeamCorrectionSpec[] EngineerBeamEntries;

	private static readonly ArtilleryCorrectionSpec[] ArtilleryEntries;

	private const string PreviousLoaderMarker = "-- Supreme Commander Overhaul gameplay corrections 1.0.1";

	private const string LoaderMarkerPrefix = "-- Supreme Commander Overhaul gameplay corrections ";

	public static IReadOnlyList<EngineerCorrectionSpec> Engineers => EngineerEntries;

	public static IReadOnlyList<EngineerBeamCorrectionSpec> EngineerBeams => EngineerBeamEntries;

	public static IReadOnlyList<CommanderBeamCorrectionSpec> CommanderBeams => CommanderBeamEntries;

	public static IReadOnlyList<ArtilleryCorrectionSpec> Artillery => ArtilleryEntries;

	public static IReadOnlyList<string> T1ExtractorVisionIds => T1ExtractorVisionEntries;

	static GameplayCorrectionsPolicy()
	{
		T1ExtractorVisionEntries = new string[4] { "ues1601", "ucs1601", "ugs1601", "uss1601" };
		EngineerEntries = new EngineerCorrectionSpec[6]
		{
			new EngineerCorrectionSpec("ugl1501", "URL0105", disableMalformedWaterAnimation: false),
			new EngineerCorrectionSpec("ugl2501", "URL0208", disableMalformedWaterAnimation: false),
			new EngineerCorrectionSpec("ugl3501", "URL0309", disableMalformedWaterAnimation: false),
			new EngineerCorrectionSpec("uel1501", "UEL0105", disableMalformedWaterAnimation: false),
			new EngineerCorrectionSpec("uel2501", "UEL0208", disableMalformedWaterAnimation: false),
			new EngineerCorrectionSpec("uel3501", "UEL0309", disableMalformedWaterAnimation: false)
		};
		CommanderBeamEntries = new CommanderBeamCorrectionSpec[6]
		{
			new CommanderBeamCorrectionSpec("uel0000", "EDA", "Left_Arm_Muzzle", 1.0, "Left_Arm_Muzzle"),
			new CommanderBeamCorrectionSpec("ugl0000", "GUARD", "Turret_Muzzle_01", 1.0, "Turret_Muzzle_01"),
			new CommanderBeamCorrectionSpec("ucl0000", "CHOSEN", "Left_Turret_Muzzle", 1.0, "Left_Turret_Muzzle"),
			new CommanderBeamCorrectionSpec("usl0000", "SERAPHIM", "AttachPoint", 1.0, "Left_Turret_Muzzle"),
			new CommanderBeamCorrectionSpec("ucl4002", "CHOSEN", "AttachPoint", 0.3, "Arm_Right_Build"),
			new CommanderBeamCorrectionSpec("usl4002", "SERAPHIM", null, null, "Left_Arm_Muzzle")
		};
		EngineerBeamEntries = new EngineerBeamCorrectionSpec[12]
		{
			new EngineerBeamCorrectionSpec("uel1501", "EDA", 0.3, "Turret_Muzzle", "Turret_Muzzle"),
			new EngineerBeamCorrectionSpec("uel2501", "EDA", 0.4, "Turret_Muzzle_01", "Turret_Muzzle_01", "Turret_Muzzle_02"),
			new EngineerBeamCorrectionSpec("uel3501", "EDA", 0.5, "Turret_Muzzle02", "Turret_Muzzle01", "Turret_Muzzle02", "Turret_Muzzle03"),
			new EngineerBeamCorrectionSpec("ugl1501", "GUARD", 1.0, "Buildpoint_Center", "Buildpoint_Center"),
			new EngineerBeamCorrectionSpec("ugl2501", "GUARD", 1.0, "Buildpoint_Left", "Buildpoint_Left", "Buildpoint_Right"),
			new EngineerBeamCorrectionSpec("ugl3501", "GUARD", 1.0, "Buildpoint_Center", "Buildpoint_Left", "Buildpoint_Center", "Buildpoint_Right"),
			new EngineerBeamCorrectionSpec("ucl1501", "CHOSEN", 0.3, "Muzzle", "Muzzle"),
			new EngineerBeamCorrectionSpec("ucl2501", "CHOSEN", 0.3, "Muzzle", "Muzzle"),
			new EngineerBeamCorrectionSpec("ucl3501", "CHOSEN", 0.3, "Muzzle", "Muzzle"),
			new EngineerBeamCorrectionSpec("usl1501", "SERAPHIM", 0.3, "AttachPoint", new string[1] { "AttachPoint" }, "Turret_Muzzle", "Turret_Muzzle"),
			new EngineerBeamCorrectionSpec("usl2501", "SERAPHIM", 0.4, "AttachPoint", new string[1] { "AttachPoint" }, "Turret_Muzzle", "Turret_Muzzle", "Turret_Muzzle1"),
			new EngineerBeamCorrectionSpec("usl3501", "SERAPHIM", 0.5, "AttachPoint", new string[1] { "AttachPoint" }, "Turret_Muzzle2", "Turret_Muzzle2", "Turret_Muzzle1")
		};
		ArtilleryEntries = new ArtilleryCorrectionSpec[4]
		{
			new ArtilleryCorrectionSpec("ucl1101", "pai111", 5.0, 2.0, reduceVelocity: false, 2.6785714286, "Turret_Muzzle", "Turret_Barrel", "Turret", "Turret_Barrel", 45.0),
			new ArtilleryCorrectionSpec("uel1101", "peu103f", 5.0, 10.0, reduceVelocity: true, 20.0),
			new ArtilleryCorrectionSpec("ugl1101", "pcg103", 5.0, 5.0, reduceVelocity: true, 20.0),
			new ArtilleryCorrectionSpec("usl1101", "pci211", 6.0, 2.857142857142857, reduceVelocity: true, 20.0, "Turret_Muzzle", "Turret", "Turret", "Turret_Barrel", 45.0, "Turret")
		};
		ValidateManifest();
	}

	public static string PatchUnitTemplateLoaderSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = PatchConstructionBeamMaterialRouting(Normalize(source));
		int num = Count(text, "-- Supreme Commander Overhaul gameplay corrections ");
		if (num == 1 && Count(text, "-- Supreme Commander Overhaul gameplay corrections 1.0.2") == 1)
		{
			ValidatePatchedLoader(text);
			return text;
		}
		if (num == 1 && Count(text, "-- Supreme Commander Overhaul gameplay corrections 1.0.1") == 1)
		{
			string text2 = ReplaceExactly(text, "-- Supreme Commander Overhaul gameplay corrections 1.0.1", "-- Supreme Commander Overhaul gameplay corrections 1.0.2", "previous gameplay-corrections marker");
			(string, string)[] array = new(string, string)[3]
			{
				("ugl1501", "URL0105"),
				("ugl2501", "URL0208"),
				("ugl3501", "URL0309")
			};
			for (int i = 0; i < array.Length; i++)
			{
				(string, string) tuple = array[i];
				string item = tuple.Item1;
				string item2 = tuple.Item2;
				string text3 = "[\"" + item + "\"] = { sourceId = \"" + item2 + "\", disableMalformedWaterAnimation = ";
				text2 = ReplaceExactly(text2, text3 + "true },", text3 + "false },", item + " previous water-animation gate");
			}
			ValidatePatchedLoader(text2);
			return text2;
		}
		if (num != 0)
		{
			throw new InvalidOperationException($"Expected zero or one supported gameplay-corrections marker, found {num}.");
		}
		RequireExactly(text, "-- Supreme Commander Overhaul locomotion and weapon idle reset 1.3.0", 1, "idle-reset upstream marker");
		RequireExactly(text, "function CreateUnitPrefab(tp)", 2, "stock and idle-reset unit-prefab loaders");
		string text4 = Normalize(text.TrimEnd(Array.Empty<char>()) + "\n\n" + BuildLoaderAppendix().Trim() + "\n");
		ValidatePatchedLoader(text4);
		return text4;
	}

	public static string PatchEdaClientDefaultSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul UEF land-factory beam palette 1.3.0");
		switch (num)
		{
		case 1:
			ValidatePatchedEdaClientDefault(text);
			return text;
		default:
			throw new InvalidOperationException($"Expected zero or one UEF land-factory beam markers, found {num}.");
		case 0:
		{
			RequireExactly(text, "SupremeCommanderOverhaulEdaUefFactoryConstructionBeam", 1, "UEF land-factory beam prefab");
			RequireExactly(text, "        \"VFX/Models/Static/ConstructionBeam.sanmodel\",\n        -- Supreme Commander Overhaul UEF land-factory beam palette 1.3.0\n        \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\",\n        EngineClasses.float3(0.05, 1, 1),", 0, "corrected UEF land-factory beam snippet");
			string text2 = ReplaceExactly(text, "        \"VFX/Models/Static/ConstructionBeam.sanmodel\",\n        \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\",\n        EngineClasses.float3(0.05, 1, 1),", "        \"VFX/Models/Static/ConstructionBeam.sanmodel\",\n        -- Supreme Commander Overhaul UEF land-factory beam palette 1.3.0\n        \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\",\n        EngineClasses.float3(0.05, 1, 1),", "UEF land-factory beam snippet");
			ValidatePatchedEdaClientDefault(text2);
			return text2;
		}
		}
	}

	public static string PatchGenericClientDefaultSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul UEF air-factory beam palette 1.3.0");
		switch (num)
		{
		case 1:
			ValidatePatchedGenericClientDefault(text);
			return text;
		default:
			throw new InvalidOperationException($"Expected zero or one UEF air-factory beam markers, found {num}.");
		case 0:
		{
			RequireExactly(text, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, "FA air-factory upstream marker");
			RequireExactly(text, "local function SCOFaAirFactoryBeamMaterial(factory)\n    -- Supreme Commander Overhaul UEF air-factory beam palette 1.3.0\n    if factory:HasTags(Tags.EDA) then\n        return \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n    end\n    return \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\nend", 0, "corrected FA air-factory material function");
			string text2 = ReplaceExactly(text, "local function SCOFaAirFactoryBeamMaterial(factory)\n    if factory:HasTags(Tags.EDA) then\n        return \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n    end\n    return \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\nend", "local function SCOFaAirFactoryBeamMaterial(factory)\n    -- Supreme Commander Overhaul UEF air-factory beam palette 1.3.0\n    if factory:HasTags(Tags.EDA) then\n        return \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n    end\n    return \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\nend", "FA air-factory material function");
			ValidatePatchedGenericClientDefault(text2);
			return text2;
		}
		}
	}

	public static string PatchHostDefaultSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul engineer medium probe 1.0.0");
		if ((uint)num > 1u)
		{
			throw new InvalidOperationException($"Expected zero or one engineer-probe markers, found {num}.");
		}
		string source2 = text;
		if (num == 0)
		{
			RequireExactly(source2, "-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0", 1, "engineer-water marker");
			RequireExactly(source2, "    local requiredDepth = previous and SCOFaEngineerWaterExitDepth or SCOFaEngineerWaterEnterDepth\n    return terrainHeight < waterLevel - requiredDepth", 1, "bathymetry-only medium probe");
			RequireExactly(source2, "    local requiredDepth = previous and SCOFaEngineerWaterExitDepth or SCOFaEngineerWaterEnterDepth\n    -- Bathymetry alone misclassifies units standing above submerged terrain.\n    if position.y > waterLevel + requiredDepth then return false end\n    return terrainHeight < waterLevel - requiredDepth", 0, "height-aware medium probe");
			source2 = ReplaceExactly(source2, "    local requiredDepth = previous and SCOFaEngineerWaterExitDepth or SCOFaEngineerWaterEnterDepth\n    return terrainHeight < waterLevel - requiredDepth", "    local requiredDepth = previous and SCOFaEngineerWaterExitDepth or SCOFaEngineerWaterEnterDepth\n    -- Bathymetry alone misclassifies units standing above submerged terrain.\n    if position.y > waterLevel + requiredDepth then return false end\n    return terrainHeight < waterLevel - requiredDepth", "engineer medium probe");
			source2 = Normalize(source2.TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul engineer medium probe 1.0.0\n");
		}
		source2 = PatchNavalWreckSink(source2);
		ValidatePatchedHost(source2);
		return source2;
	}

	private static string PatchNavalWreckSink(string source)
	{
		int num = Count(source, "-- Supreme Commander Overhaul naval wreck sinking 1.1.0");
		switch (num)
		{
		case 1:
			ValidateNavalWreckSink(source);
			return source;
		default:
			throw new InvalidOperationException($"Expected zero or one naval-wreck markers, found {num}.");
		case 0:
		{
			if (source.Contains("local WreckCrash = Import(\"host/props/wreckCrash.lua\")"))
			{
				string text = source.TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul naval wreck sinking 1.1.0\n";
				ValidateNavalWreckSink(text);
				return text;
			}
			RequireExactly(source, "local function WreckCrashThread(wreck, position, velocity, headingRadians, deleteAtRest, crashScale)", 1, "stock wreck-crash signature");
			RequireExactly(source, "local function WreckCrashThread(wreck, position, velocity, headingRadians, deleteAtRest, crashScale, startSinking)", 0, "compatible wreck-crash signature");
			RequireExactly(source, "    local sinking = false", 1, "stock wreck-crash initial state");
			RequireExactly(source, "    local sinking = startSinking == true", 0, "compatible wreck-crash initial state");
			RequireExactly(source, "---@class HostNavalUnit: HostMobileUnit\nHostNavalUnit = Class(\"NavalUnit\", HostMobileUnit)", 1, "naval-unit class anchor");
			RequireExactly(source, "---@class HostNavalUnit: HostMobileUnit\nHostNavalUnit = Class(\"NavalUnit\", HostMobileUnit)\n\n-- Supreme Commander Overhaul naval wreck sinking 1.1.0\nlocal function SCOGameplayStartWreckCrash(unit, overkillRatio, startSinking)\n    local dt = Constants.TickTimeStep\n\n    local _, speedPerTick = Engine.GetMovementCurrentSpeed(unit.id)\n    local _, headingDegrees = Engine.GetMovementHeadingDegrees(unit.id)\n    local headingRadians = math.rad(headingDegrees)\n    local speed = speedPerTick / dt\n    local velocity = EngineClasses.float3(\n        math.sin(headingRadians) * speed,\n        0,\n        math.cos(headingRadians) * speed)\n    local _, position = Engine.GetGlobalEntityWorldPosition(unit.id)\n\n    local deleteAtRest = (overkillRatio or 0) >= 1\n        or not unit.spawnsWreck\n        or unit:GetFractionComplete() < 0.5\n    local crashScale = (unit:HasTags(Tags.TECH4)\n        or unit:HasTags(Tags.TECH5))\n        and CrashScaleLarge\n        or CrashScaleDefault\n    local wreckage = CreateWreckageFromUnit(unit)\n\n    if wreckage then\n        wreckage:NewThread(function()\n            WreckCrashThread(\n                wreckage,\n                position,\n                velocity,\n                headingRadians,\n                deleteAtRest,\n                crashScale,\n                startSinking)\n        end)\n    end\nend\n\nfunction HostNavalUnit:DeathThread(overkillRatio)\n    SCOGameplayStartWreckCrash(self, overkillRatio, true)\n    self:Delete()\nend", 0, "naval-wreck sink block");
			string text2 = ReplaceExactly(ReplaceExactly(ReplaceExactly(source, "local function WreckCrashThread(wreck, position, velocity, headingRadians, deleteAtRest, crashScale)", "local function WreckCrashThread(wreck, position, velocity, headingRadians, deleteAtRest, crashScale, startSinking)", "wreck-crash signature"), "    local sinking = false", "    local sinking = startSinking == true", "wreck-crash initial state"), "---@class HostNavalUnit: HostMobileUnit\nHostNavalUnit = Class(\"NavalUnit\", HostMobileUnit)", "---@class HostNavalUnit: HostMobileUnit\nHostNavalUnit = Class(\"NavalUnit\", HostMobileUnit)\n\n-- Supreme Commander Overhaul naval wreck sinking 1.1.0\nlocal function SCOGameplayStartWreckCrash(unit, overkillRatio, startSinking)\n    local dt = Constants.TickTimeStep\n\n    local _, speedPerTick = Engine.GetMovementCurrentSpeed(unit.id)\n    local _, headingDegrees = Engine.GetMovementHeadingDegrees(unit.id)\n    local headingRadians = math.rad(headingDegrees)\n    local speed = speedPerTick / dt\n    local velocity = EngineClasses.float3(\n        math.sin(headingRadians) * speed,\n        0,\n        math.cos(headingRadians) * speed)\n    local _, position = Engine.GetGlobalEntityWorldPosition(unit.id)\n\n    local deleteAtRest = (overkillRatio or 0) >= 1\n        or not unit.spawnsWreck\n        or unit:GetFractionComplete() < 0.5\n    local crashScale = (unit:HasTags(Tags.TECH4)\n        or unit:HasTags(Tags.TECH5))\n        and CrashScaleLarge\n        or CrashScaleDefault\n    local wreckage = CreateWreckageFromUnit(unit)\n\n    if wreckage then\n        wreckage:NewThread(function()\n            WreckCrashThread(\n                wreckage,\n                position,\n                velocity,\n                headingRadians,\n                deleteAtRest,\n                crashScale,\n                startSinking)\n        end)\n    end\nend\n\nfunction HostNavalUnit:DeathThread(overkillRatio)\n    SCOGameplayStartWreckCrash(self, overkillRatio, true)\n    self:Delete()\nend", "naval-unit wreck lifecycle");
			ValidateNavalWreckSink(text2);
			return text2;
		}
		}
	}

	public static string PatchHostEntitySource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul host orientation API correction 1.2.0");
		switch (num)
		{
		case 1:
			ValidatePatchedHostEntity(text);
			return text;
		default:
			throw new InvalidOperationException($"Expected zero or one host-orientation API markers, found {num}.");
		case 0:
		{
			RequireExactly(text, "function HostEntity:SetOrientation(orientation)\n    Engine.SetGlobalEntityLocalRotation(self.id, orientation)\nend", 0, "supported host-orientation method");
			string text2 = Normalize(ReplaceExactly(text, "function HostEntity:SetOrientation(orientation)\n    Engine.SetGlobalEntityRotation(self.id, orientation)\nend", "function HostEntity:SetOrientation(orientation)\n    Engine.SetGlobalEntityLocalRotation(self.id, orientation)\nend", "broken host-orientation method").TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul host orientation API correction 1.2.0\n");
			ValidatePatchedHostEntity(text2);
			return text2;
		}
		}
	}

	public static string PatchSeraphimFactoryHostSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul Seraphim factory orientation correction 1.1.0");
		switch (num)
		{
		case 1:
			ValidatePatchedSeraphimFactoryHost(text);
			return text;
		default:
			throw new InvalidOperationException($"Expected zero or one Seraphim factory-orientation markers, found {num}.");
		case 0:
		{
			RequireExactly(text, "-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0", 1, "Seraphim land-factory upstream marker");
			RequireExactly(text, "-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0", 1, "Seraphim death-animation upstream marker");
			RequireExactly(text, "function SeraphimLandFactory:OnStartBuildRoutine(target)", 1, "Seraphim land-factory build-start hook");
			RequireExactly(text, "function SeraphimLandFactory:OnStopBuildRoutine(target)", 1, "Seraphim land-factory build-stop hook");
			RequireExactly(text, "    if not SCO_SeraphimFactoryAlive(target) or not target:HasTags(Tags.MOBILE) or not ramp then return end", 0, "mobile-only ramp guard");
			string text2 = Normalize(ReplaceExactly(text, "    if not SCO_SeraphimFactoryAlive(target) or not ramp then return end", "    if not SCO_SeraphimFactoryAlive(target) or not target:HasTags(Tags.MOBILE) or not ramp then return end", "unscoped Seraphim ramp guard").TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul Seraphim factory orientation correction 1.1.0\n");
			ValidatePatchedSeraphimFactoryHost(text2);
			return text2;
		}
		}
	}

	public static string BuildLoaderAppendix()
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul gameplay corrections 1.0.2");
		stringBuilder.AppendLine("-- Restore reviewed movement, artillery, T1 extractor vision, commander-beam, and faction-palette contracts.");
		stringBuilder.AppendLine("local SCO_GameplayT1ExtractorVisionIds = {");
		string[] t1ExtractorVisionEntries = T1ExtractorVisionEntries;
		foreach (string value in t1ExtractorVisionEntries)
		{
			stringBuilder.Append("    [\"").Append(value).AppendLine("\"] = true,");
		}
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local SCO_GameplayEngineerSpecs = {");
		EngineerCorrectionSpec[] engineerEntries = EngineerEntries;
		foreach (EngineerCorrectionSpec engineerCorrectionSpec in engineerEntries)
		{
			stringBuilder.Append("    [\"").Append(engineerCorrectionSpec.TargetId).Append("\"] = { sourceId = \"")
				.Append(engineerCorrectionSpec.SourceId)
				.Append("\", disableMalformedWaterAnimation = ")
				.Append(engineerCorrectionSpec.DisableMalformedWaterAnimation ? "true" : "false")
				.AppendLine(" },");
		}
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local SCO_GameplayEngineerBeamSpecs = {");
		EngineerBeamCorrectionSpec[] engineerBeamEntries = EngineerBeamEntries;
		foreach (EngineerBeamCorrectionSpec engineerBeamCorrectionSpec in engineerBeamEntries)
		{
			stringBuilder.Append("    [\"").Append(engineerBeamCorrectionSpec.TargetId).Append("\"] = { faction = \"")
				.Append(engineerBeamCorrectionSpec.FactionTag)
				.Append("\", oldShrink = ")
				.Append(Number(engineerBeamCorrectionSpec.OldShrink))
				.Append(", oldBone = \"")
				.Append(engineerBeamCorrectionSpec.OldBoneName)
				.Append("\", oldBones = {");
			foreach (string oldBuildBeamBone in engineerBeamCorrectionSpec.OldBuildBeamBones)
			{
				stringBuilder.Append(" \"").Append(oldBuildBeamBone).Append("\",");
			}
			stringBuilder.Append(" }, bone = \"").Append(engineerBeamCorrectionSpec.BoneName).Append("\", bones = {");
			foreach (string buildBeamBone in engineerBeamCorrectionSpec.BuildBeamBones)
			{
				stringBuilder.Append(" \"").Append(buildBeamBone).Append("\",");
			}
			stringBuilder.AppendLine(" } },");
		}
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local SCO_GameplayCommanderBeamSpecs = {");
		CommanderBeamCorrectionSpec[] commanderBeamEntries = CommanderBeamEntries;
		foreach (CommanderBeamCorrectionSpec commanderBeamCorrectionSpec in commanderBeamEntries)
		{
			stringBuilder.Append("    [\"").Append(commanderBeamCorrectionSpec.TargetId).Append("\"] = { faction = \"")
				.Append(commanderBeamCorrectionSpec.FactionTag)
				.Append("\", oldBone = ");
			if (commanderBeamCorrectionSpec.OldBoneName == null)
			{
				stringBuilder.Append("false, oldShrink = false");
			}
			else
			{
				stringBuilder.Append("\"").Append(commanderBeamCorrectionSpec.OldBoneName).Append("\", oldShrink = ")
					.Append(Number(commanderBeamCorrectionSpec.OldShrink.Value));
			}
			stringBuilder.Append(", bone = \"").Append(commanderBeamCorrectionSpec.BoneName).AppendLine("\" },");
		}
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local SCO_GameplayArtillerySpecs = {");
		ArtilleryCorrectionSpec[] artilleryEntries = ArtilleryEntries;
		foreach (ArtilleryCorrectionSpec artilleryCorrectionSpec in artilleryEntries)
		{
			stringBuilder.Append("    [\"").Append(artilleryCorrectionSpec.TargetId).Append("\"] = { projectile = \"")
				.Append(artilleryCorrectionSpec.ProjectileId)
				.Append("\", rangeMin = ")
				.Append(Number(artilleryCorrectionSpec.RangeMin))
				.Append(", reload = ")
				.Append(Number(artilleryCorrectionSpec.ReloadTime))
				.Append(", reduce = ")
				.Append(artilleryCorrectionSpec.ReduceVelocity ? "true" : "false")
				.Append(", lifetime = ")
				.Append(Number(artilleryCorrectionSpec.ProjectileLifetime));
			if (artilleryCorrectionSpec.YawBone != null)
			{
				stringBuilder.Append(", aim = \"").Append(artilleryCorrectionSpec.AimBone).Append("\", oldYaw = \"")
					.Append(artilleryCorrectionSpec.OldYawBone)
					.Append("\", yaw = \"")
					.Append(artilleryCorrectionSpec.YawBone)
					.Append("\", oldPitch = \"")
					.Append(artilleryCorrectionSpec.OldPitchBone)
					.Append("\", pitch = \"")
					.Append(artilleryCorrectionSpec.PitchBone)
					.Append('"');
			}
			if (artilleryCorrectionSpec.DefaultPitchAdjustment.HasValue)
			{
				stringBuilder.Append(", pitchAdjustment = ").Append(Number(artilleryCorrectionSpec.DefaultPitchAdjustment.Value));
			}
			stringBuilder.AppendLine(" },");
		}
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GameplayNearlyEqual(left, right)");
		stringBuilder.AppendLine("    return type(left) == \"number\" and math.abs(left - right) <= 0.000001");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GameplayWarn(tpId, reason)");
		stringBuilder.AppendLine("    if Warn then");
		stringBuilder.AppendLine("        Warn(\"[SCOM Gameplay Corrections] Skipped \" .. tostring(tpId) .. \"; \" .. reason)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GameplayPrepareT1ExtractorVision(tp, tpId)");
		stringBuilder.AppendLine("    local additions = tp.additions");
		stringBuilder.AppendLine("    local intel = tp.intel");
		stringBuilder.AppendLine("    local ranges = tp.ranges");
		stringBuilder.AppendLine("    local visionRange = ranges and ranges[RangeRingMaterial.Vision]");
		stringBuilder.AppendLine("    local fogRange = ranges and ranges[RangeRingMaterial.FogOfWar]");
		stringBuilder.AppendLine("    local marker = additions and additions.scoGameplayT1ExtractorVision");
		stringBuilder.AppendLine("    if type(additions) ~= \"table\" or type(intel) ~= \"table\"");
		stringBuilder.AppendLine("        or type(visionRange) ~= \"table\" or type(fogRange) ~= \"table\"");
		stringBuilder.AppendLine("        or visionRange.innerRadius ~= 0 or fogRange.innerRadius ~= 0");
		stringBuilder.AppendLine("    then");
		stringBuilder.AppendLine("        SCO_GameplayWarn(tpId, \"T1 extractor vision shape drifted\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if marker == \"1.1.0\" then");
		stringBuilder.AppendLine("        if intel.visionRadius ~= " + 15);
		stringBuilder.AppendLine("            or visionRange.outerRadius ~= " + 15);
		stringBuilder.AppendLine("            or fogRange.outerRadius ~= " + 15);
		stringBuilder.AppendLine("        then");
		stringBuilder.AppendLine("            SCO_GameplayWarn(tpId, \"marked T1 extractor vision contract drifted\")");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if marker ~= nil then");
		stringBuilder.AppendLine("        SCO_GameplayWarn(tpId, \"unknown T1 extractor vision marker\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local legacyMatches = intel.visionRadius == " + 0);
		stringBuilder.AppendLine("        and visionRange.outerRadius == " + 0);
		stringBuilder.AppendLine("        and fogRange.outerRadius == " + 0);
		stringBuilder.AppendLine("    local correctedMatches = intel.visionRadius == " + 15);
		stringBuilder.AppendLine("        and visionRange.outerRadius == " + 15);
		stringBuilder.AppendLine("        and fogRange.outerRadius == " + 15);
		stringBuilder.AppendLine("    if not legacyMatches and not correctedMatches then");
		stringBuilder.AppendLine("        SCO_GameplayWarn(tpId, \"unmarked T1 extractor vision contract drifted\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    intel.visionRadius = " + 15);
		stringBuilder.AppendLine("    visionRange.outerRadius = " + 15);
		stringBuilder.AppendLine("    fogRange.outerRadius = " + 15);
		stringBuilder.AppendLine("    additions.scoGameplayT1ExtractorVision = \"1.1.0\"");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local SCO_GameplayFactionTags = { \"EDA\", \"CHOSEN\", \"GUARD\", \"SERAPHIM\" }");
		stringBuilder.AppendLine("local function SCO_GameplayHasOnlyFaction(tp, expected)");
		stringBuilder.AppendLine("    local count = 0");
		stringBuilder.AppendLine("    local found = false");
		stringBuilder.AppendLine("    for _, factionTag in ipairs(SCO_GameplayFactionTags) do");
		stringBuilder.AppendLine("        if table.find(tp.tags, factionTag) then");
		stringBuilder.AppendLine("            count = count + 1");
		stringBuilder.AppendLine("            if factionTag == expected then found = true end");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    return count == 1 and found");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GameplayCommanderBeamMatches(tp, boneName, shrink)");
		stringBuilder.AppendLine("    local additions = tp.additions");
		stringBuilder.AppendLine("    local construction = tp.construction");
		stringBuilder.AppendLine("    local beam = construction and construction.beam");
		stringBuilder.AppendLine("    local bones = additions and additions.buildBeamBones");
		stringBuilder.AppendLine("    local offset = beam and beam.offset");
		stringBuilder.AppendLine("    return type(bones) == \"table\" and #bones == 1 and bones[1] == boneName");
		stringBuilder.AppendLine("        and type(beam) == \"table\" and beam.boneName == boneName");
		stringBuilder.AppendLine("        and SCO_GameplayNearlyEqual(beam.shrink, shrink)");
		stringBuilder.AppendLine("        and type(offset) == \"table\" and offset.x == 0 and offset.y == 0 and offset.z == 0");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GameplayEngineerBeamMatches(tp, boneName, expectedBones, shrink)");
		stringBuilder.AppendLine("    local additions = tp.additions");
		stringBuilder.AppendLine("    local construction = tp.construction");
		stringBuilder.AppendLine("    local beam = construction and construction.beam");
		stringBuilder.AppendLine("    local bones = additions and additions.buildBeamBones");
		stringBuilder.AppendLine("    local offset = beam and beam.offset");
		stringBuilder.AppendLine("    if type(bones) ~= \"table\" or #bones ~= #expectedBones then return false end");
		stringBuilder.AppendLine("    for index, bone in ipairs(expectedBones) do");
		stringBuilder.AppendLine("        if bones[index] ~= bone then return false end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    return type(beam) == \"table\" and beam.boneName == boneName");
		stringBuilder.AppendLine("        and SCO_GameplayNearlyEqual(beam.shrink, shrink)");
		stringBuilder.AppendLine("        and type(offset) == \"table\" and offset.x == 0 and offset.y == 0 and offset.z == 0");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GameplayPrepareEngineerBeam(tp, tpId, spec)");
		stringBuilder.AppendLine("    local additions = tp.additions");
		stringBuilder.AppendLine("    local construction = tp.construction");
		stringBuilder.AppendLine("    local marker = additions and additions.scoGameplayEngineerBeam");
		stringBuilder.AppendLine("    if type(additions) ~= \"table\" or type(construction) ~= \"table\"");
		stringBuilder.AppendLine("        or type(tp.tags) ~= \"table\" or not SCO_GameplayHasOnlyFaction(tp, spec.faction)");
		stringBuilder.AppendLine("    then");
		stringBuilder.AppendLine("        SCO_GameplayWarn(tpId, \"engineer construction-beam faction/shape drifted\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if marker == \"1.0.0\" then");
		stringBuilder.AppendLine("        if not SCO_GameplayEngineerBeamMatches(tp, spec.bone, spec.bones, " + Number(0.05) + ") then");
		stringBuilder.AppendLine("            SCO_GameplayWarn(tpId, \"marked engineer construction-beam contract drifted\")");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if marker ~= nil then");
		stringBuilder.AppendLine("        SCO_GameplayWarn(tpId, \"unknown engineer construction-beam marker\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if not SCO_GameplayEngineerBeamMatches(tp, spec.oldBone, spec.oldBones, spec.oldShrink) then");
		stringBuilder.AppendLine("        SCO_GameplayWarn(tpId, \"unmarked engineer construction-beam contract drifted\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    construction.beam.boneName = spec.bone");
		stringBuilder.AppendLine("    construction.beam.shrink = " + Number(0.05));
		stringBuilder.AppendLine("    additions.buildBeamBones = spec.bones");
		stringBuilder.AppendLine("    additions.scoGameplayEngineerBeam = \"1.0.0\"");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GameplayPrepareCommanderBeam(tp, tpId, spec)");
		stringBuilder.AppendLine("    local additions = tp.additions");
		stringBuilder.AppendLine("    local construction = tp.construction");
		stringBuilder.AppendLine("    local marker = additions and additions.scoGameplayCommanderBeam");
		stringBuilder.AppendLine("    if type(additions) ~= \"table\" or type(construction) ~= \"table\"");
		stringBuilder.AppendLine("        or type(tp.tags) ~= \"table\" or not SCO_GameplayHasOnlyFaction(tp, spec.faction)");
		stringBuilder.AppendLine("    then");
		stringBuilder.AppendLine("        SCO_GameplayWarn(tpId, \"commander construction-beam faction/shape drifted\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if marker == \"1.3.0\" then");
		stringBuilder.AppendLine("        if not SCO_GameplayCommanderBeamMatches(tp, spec.bone, " + Number(0.05) + ") then");
		stringBuilder.AppendLine("            SCO_GameplayWarn(tpId, \"marked commander construction-beam contract drifted\")");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if marker ~= nil then");
		stringBuilder.AppendLine("        SCO_GameplayWarn(tpId, \"unknown commander construction-beam marker\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local oldMatches");
		stringBuilder.AppendLine("    if spec.oldBone == false then");
		stringBuilder.AppendLine("        oldMatches = additions.buildBeamBones == nil and construction.beam == nil");
		stringBuilder.AppendLine("    else");
		stringBuilder.AppendLine("        oldMatches = SCO_GameplayCommanderBeamMatches(tp, spec.oldBone, spec.oldShrink)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if not oldMatches then");
		stringBuilder.AppendLine("        SCO_GameplayWarn(tpId, \"unmarked commander construction-beam contract drifted\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local beam = construction.beam or {}");
		stringBuilder.AppendLine("    beam.boneName = spec.bone");
		stringBuilder.AppendLine("    beam.offset = { x = 0, y = 0, z = 0 }");
		stringBuilder.AppendLine("    beam.shrink = " + Number(0.05));
		stringBuilder.AppendLine("    construction.beam = beam");
		stringBuilder.AppendLine("    additions.buildBeamBones = { spec.bone }");
		stringBuilder.AppendLine("    additions.scoGameplayCommanderBeam = \"1.3.0\"");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GameplayPrepareEngineer(tp, tpId, spec)");
		stringBuilder.AppendLine("    local additions = tp.additions");
		stringBuilder.AppendLine("    local source = additions and additions.faSourceContract");
		stringBuilder.AppendLine("    local water = additions and additions.faEngineerWaterAnimation");
		stringBuilder.AppendLine("    local movement = tp.movement");
		stringBuilder.AppendLine("    local animations = tp.visuals and tp.visuals.animations");
		stringBuilder.AppendLine("    local marker = additions and additions.scoGameplayEngineerFloating");
		stringBuilder.AppendLine("    local expectedMapping = spec.sourceId .. \" -> \" .. tpId");
		stringBuilder.AppendLine("    local expectedAltitude = marker == true and \"GroundOrWater\" or \"Ground\"");
		stringBuilder.AppendLine("    local waterIsValid = type(water) == \"table\"");
		stringBuilder.AppendLine("        and water.mapping == expectedMapping and water.sourceRate == 1");
		stringBuilder.AppendLine("        and type(animations) == \"table\"");
		stringBuilder.AppendLine("        and type(animations.waterTransform) == \"table\"");
		stringBuilder.AppendLine("        and animations.waterTransform.clipName == \"AnimWater\"");
		stringBuilder.AppendLine("    if marker == true and spec.disableMalformedWaterAnimation then");
		stringBuilder.AppendLine("        waterIsValid = water == nil and type(animations) == \"table\"");
		stringBuilder.AppendLine("            and animations.waterTransform == nil");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if type(additions) ~= \"table\"");
		stringBuilder.AppendLine("        or type(source) ~= \"table\" or source.mapping ~= expectedMapping");
		stringBuilder.AppendLine("        or not waterIsValid");
		stringBuilder.AppendLine("        or type(movement) ~= \"table\" or movement.type ~= \"TracksAmphibious\"");
		stringBuilder.AppendLine("        or movement.preferredAltitude ~= 0");
		stringBuilder.AppendLine("        or movement.referenceAltitude ~= expectedAltitude");
		stringBuilder.AppendLine("        or type(animations) ~= \"table\"");
		stringBuilder.AppendLine("        or type(animations.walk) ~= \"table\" or animations.walk.clipName ~= \"Rest\"");
		stringBuilder.AppendLine("        or (marker ~= nil and marker ~= true)");
		stringBuilder.AppendLine("    then");
		stringBuilder.AppendLine("        SCO_GameplayWarn(tpId, \"engineer movement/water contract drifted\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    movement.referenceAltitude = \"GroundOrWater\"");
		stringBuilder.AppendLine("    if spec.disableMalformedWaterAnimation then");
		stringBuilder.AppendLine("        additions.faEngineerWaterAnimation = nil");
		stringBuilder.AppendLine("        animations.waterTransform = nil");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    additions.scoGameplayEngineerFloating = true");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GameplayPrepareArtillery(tp, tpId, spec)");
		stringBuilder.AppendLine("    local additions = tp.additions");
		stringBuilder.AppendLine("    local weapon = tp.weapons and tp.weapons[1]");
		stringBuilder.AppendLine("    local controllers = weapon and weapon.aimControllers");
		stringBuilder.AppendLine("    local aim = controllers and controllers[1]");
		stringBuilder.AppendLine("    local marker = additions and additions.scoGameplayT1ArtilleryArc");
		stringBuilder.AppendLine("    local gravity = aim and aim.aimGravity");
		stringBuilder.AppendLine("    local gravityIsValid = gravity == nil");
		stringBuilder.AppendLine("        or (type(gravity) == \"table\"");
		stringBuilder.AppendLine("            and gravity.x == 0 and gravity.y == -4.9 and gravity.z == 0)");
		stringBuilder.AppendLine("    local reduce = aim and aim.reduceMuzzleVelocityToTarget");
		stringBuilder.AppendLine("    local reduceIsValid = marker == true and reduce == true");
		stringBuilder.AppendLine("        or marker == nil and (reduce == nil or reduce == spec.reduce or reduce == true)");
		stringBuilder.AppendLine("    local lifetimeIsValid = marker == true");
		stringBuilder.AppendLine("        and SCO_GameplayNearlyEqual(weapon and weapon.projectileLifetime, 20)");
		stringBuilder.AppendLine("        or marker == nil and (SCO_GameplayNearlyEqual(weapon and weapon.projectileLifetime, spec.lifetime)");
		stringBuilder.AppendLine("            or SCO_GameplayNearlyEqual(weapon and weapon.projectileLifetime, 20))");
		stringBuilder.AppendLine("    local yawIsValid = spec.yaw == nil");
		stringBuilder.AppendLine("        or marker == true and aim and aim.yawBone == spec.yaw");
		stringBuilder.AppendLine("        or marker == nil and aim and (aim.yawBone == spec.oldYaw or aim.yawBone == spec.yaw)");
		stringBuilder.AppendLine("    local pitchIsValid = spec.pitch == nil");
		stringBuilder.AppendLine("        or marker == true and aim and aim.pitchBone == spec.pitch");
		stringBuilder.AppendLine("        or marker == nil and aim and (aim.pitchBone == spec.oldPitch or aim.pitchBone == spec.pitch)");
		stringBuilder.AppendLine("    local lead = aim and aim.leadTarget");
		stringBuilder.AppendLine("    local leadIsValid = marker == true and lead == false");
		stringBuilder.AppendLine("        or marker == nil and (lead == nil or type(lead) == \"boolean\")");
		stringBuilder.AppendLine("    local pitchAdjustment = aim and aim.defaultPitchAdjustment");
		stringBuilder.AppendLine("    local pitchAdjustmentIsValid = spec.pitchAdjustment == nil");
		stringBuilder.AppendLine("        or marker == true and pitchAdjustment == spec.pitchAdjustment");
		stringBuilder.AppendLine("        or marker == nil and (pitchAdjustment == nil or pitchAdjustment == 0");
		stringBuilder.AppendLine("            or pitchAdjustment == spec.pitchAdjustment)");
		stringBuilder.AppendLine("    if type(additions) ~= \"table\"");
		stringBuilder.AppendLine("        or type(weapon) ~= \"table\" or tp.weapons[2] ~= nil");
		stringBuilder.AppendLine("        or weapon.projectileTemplate ~= spec.projectile");
		stringBuilder.AppendLine("        or weapon.rangeMax ~= 30 or weapon.rangeMin ~= spec.rangeMin");
		stringBuilder.AppendLine("        or not SCO_GameplayNearlyEqual(weapon.reloadTime, spec.reload)");
		stringBuilder.AppendLine("        or not lifetimeIsValid");
		stringBuilder.AppendLine("        or type(controllers) ~= \"table\" or controllers[2] ~= nil");
		stringBuilder.AppendLine("        or type(aim) ~= \"table\" or aim.projectileSpeed ~= 14");
		stringBuilder.AppendLine("        or aim.solverType ~= \"HighArc\"");
		stringBuilder.AppendLine("        or not reduceIsValid");
		stringBuilder.AppendLine("        or not gravityIsValid");
		stringBuilder.AppendLine("        or not leadIsValid");
		stringBuilder.AppendLine("        or not pitchAdjustmentIsValid");
		stringBuilder.AppendLine("        or not pitchIsValid");
		stringBuilder.AppendLine("        or (spec.yaw ~= nil and (aim.aimBone ~= spec.aim");
		stringBuilder.AppendLine("            or not yawIsValid))");
		stringBuilder.AppendLine("        or (marker ~= nil and marker ~= true)");
		stringBuilder.AppendLine("    then");
		stringBuilder.AppendLine("        SCO_GameplayWarn(tpId, \"T1 artillery ballistic contract drifted\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    aim.aimGravity = { x = 0, y = -4.9, z = 0 }");
		stringBuilder.AppendLine("    aim.leadTarget = false");
		stringBuilder.AppendLine("    aim.reduceMuzzleVelocityToTarget = true");
		stringBuilder.AppendLine("    if spec.yaw ~= nil then aim.yawBone = spec.yaw end");
		stringBuilder.AppendLine("    if spec.pitch ~= nil then aim.pitchBone = spec.pitch end");
		stringBuilder.AppendLine("    if spec.pitchAdjustment ~= nil then");
		stringBuilder.AppendLine("        aim.defaultPitchAdjustment = spec.pitchAdjustment");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    weapon.projectileLifetime = 20");
		stringBuilder.AppendLine("    additions.scoGameplayT1ArtilleryArc = true");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GameplayPrepareTemplate(tp)");
		stringBuilder.AppendLine("    local tpId = tp and tp.general and tp.general.tpId");
		stringBuilder.AppendLine("    if tpId and SCO_GameplayT1ExtractorVisionIds[tpId] then");
		stringBuilder.AppendLine("        SCO_GameplayPrepareT1ExtractorVision(tp, tpId)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local engineer = tpId and SCO_GameplayEngineerSpecs[tpId]");
		stringBuilder.AppendLine("    if engineer then SCO_GameplayPrepareEngineer(tp, tpId, engineer) end");
		stringBuilder.AppendLine("    local engineerBeam = tpId and SCO_GameplayEngineerBeamSpecs[tpId]");
		stringBuilder.AppendLine("    if engineerBeam then SCO_GameplayPrepareEngineerBeam(tp, tpId, engineerBeam) end");
		stringBuilder.AppendLine("    local commander = tpId and SCO_GameplayCommanderBeamSpecs[tpId]");
		stringBuilder.AppendLine("    if commander then SCO_GameplayPrepareCommanderBeam(tp, tpId, commander) end");
		stringBuilder.AppendLine("    local artillery = tpId and SCO_GameplayArtillerySpecs[tpId]");
		stringBuilder.AppendLine("    if artillery then SCO_GameplayPrepareArtillery(tp, tpId, artillery) end");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local SCO_GameplayCreateUnitPrefab = CreateUnitPrefab");
		stringBuilder.AppendLine("function CreateUnitPrefab(tp)");
		stringBuilder.AppendLine("    SCO_GameplayPrepareTemplate(tp)");
		stringBuilder.AppendLine("    return SCO_GameplayCreateUnitPrefab(tp)");
		stringBuilder.AppendLine("end");
		return stringBuilder.ToString();
	}

	private static string PatchConstructionBeamMaterialRouting(string source)
	{
		int num = Count(source, "-- Supreme Commander Overhaul construction beam faction palette 1.3.3");
		switch (num)
		{
		case 1:
			ValidatePatchedConstructionBeamMaterialRouting(source);
			return source;
		default:
			throw new InvalidOperationException($"Expected zero or one construction-beam palette markers, found {num}.");
		case 0:
		{
			RequireExactly(source, "        local constructionBeamMaterialPath\n        -- Supreme Commander Overhaul construction beam faction palette 1.3.3\n        local SCO_GameplayBeamFactionCount = 0\n        if type(tp.tags) == \"table\" then\n            for _, factionTag in ipairs({ \"EDA\", \"CHOSEN\", \"GUARD\", \"PROMETHEAN\", \"SERAPHIM\" }) do\n                if table.find(tp.tags, factionTag) then\n                    SCO_GameplayBeamFactionCount = SCO_GameplayBeamFactionCount + 1\n                end\n            end\n        end\n        if SCO_GameplayBeamFactionCount ~= 1 then\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have exactly one faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/uef.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") or table.find(tp.tags, \"PROMETHEAN\") then\n            if table.find(tp.tags, \"PROMETHEAN\") then\n                constructionBeamMaterialPath = \"Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial\"\n            else\n                constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/cybran.sanmaterial\"\n            end\n        elseif table.find(tp.tags, \"CHOSEN\") then\n            constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/aeon.sanmaterial\"\n        elseif table.find(tp.tags, \"SERAPHIM\") then\n            constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/seraphim.sanmaterial\"\n        else\n            constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/uef.sanmaterial\"\n        end", 0, "corrected construction-beam material block");
			int num2 = Count(source, "        local constructionBeamMaterialPath\n        -- SCO_AeonConstructionBeamMaterial\n        if (tp.additions and tp.additions.faSourceContract)\n            or (\n                tp.general.tpId == \"ucl0000\"\n                and tp.construction.beam.boneName == \"Left_Turret_Muzzle\"\n            )\n        then\n            constructionBeamMaterialPath = \"VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        else\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have a faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        end");
			int num3 = Count(source, "        local constructionBeamMaterialPath\n        -- SCO_AeonConstructionBeamMaterial\n        if (tp.additions and tp.additions.faSourceContract)\n            or (\n                tp.general.tpId == \"ucl0000\"\n                and tp.construction.beam.boneName == \"Left_Turret_Muzzle\"\n            )\n        then\n            constructionBeamMaterialPath = \"VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") or table.find(tp.tags, \"PROMETHEAN\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        else\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have a faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        end");
			int num4 = Count(source, "        local constructionBeamMaterialPath\n        if table.find(tp.tags, \"PROMETHEAN\") then\n            constructionBeamMaterialPath = \"Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"CHOSEN\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        else\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have a faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        end");
			if (num2 + num3 + num4 != 1)
			{
				throw new InvalidOperationException("Expected exactly one supported upstream construction-beam material block; " + $"found {num2} uncomposed and " + $"{num3} legacy Promethean-composed and " + $"{num4} current Promethean-composed blocks.");
			}
			string oldValue = ((num2 == 1) ? "        local constructionBeamMaterialPath\n        -- SCO_AeonConstructionBeamMaterial\n        if (tp.additions and tp.additions.faSourceContract)\n            or (\n                tp.general.tpId == \"ucl0000\"\n                and tp.construction.beam.boneName == \"Left_Turret_Muzzle\"\n            )\n        then\n            constructionBeamMaterialPath = \"VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        else\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have a faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        end" : ((num3 == 1) ? "        local constructionBeamMaterialPath\n        -- SCO_AeonConstructionBeamMaterial\n        if (tp.additions and tp.additions.faSourceContract)\n            or (\n                tp.general.tpId == \"ucl0000\"\n                and tp.construction.beam.boneName == \"Left_Turret_Muzzle\"\n            )\n        then\n            constructionBeamMaterialPath = \"VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") or table.find(tp.tags, \"PROMETHEAN\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        else\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have a faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        end" : "        local constructionBeamMaterialPath\n        if table.find(tp.tags, \"PROMETHEAN\") then\n            constructionBeamMaterialPath = \"Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"CHOSEN\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        else\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have a faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        end"));
			string text = ReplaceExactly(source, oldValue, "        local constructionBeamMaterialPath\n        -- Supreme Commander Overhaul construction beam faction palette 1.3.3\n        local SCO_GameplayBeamFactionCount = 0\n        if type(tp.tags) == \"table\" then\n            for _, factionTag in ipairs({ \"EDA\", \"CHOSEN\", \"GUARD\", \"PROMETHEAN\", \"SERAPHIM\" }) do\n                if table.find(tp.tags, factionTag) then\n                    SCO_GameplayBeamFactionCount = SCO_GameplayBeamFactionCount + 1\n                end\n            end\n        end\n        if SCO_GameplayBeamFactionCount ~= 1 then\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have exactly one faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/uef.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") or table.find(tp.tags, \"PROMETHEAN\") then\n            if table.find(tp.tags, \"PROMETHEAN\") then\n                constructionBeamMaterialPath = \"Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial\"\n            else\n                constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/cybran.sanmaterial\"\n            end\n        elseif table.find(tp.tags, \"CHOSEN\") then\n            constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/aeon.sanmaterial\"\n        elseif table.find(tp.tags, \"SERAPHIM\") then\n            constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/seraphim.sanmaterial\"\n        else\n            constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/uef.sanmaterial\"\n        end", "upstream construction-beam material block");
			ValidatePatchedConstructionBeamMaterialRouting(text);
			return text;
		}
		}
	}

	private static void ValidateManifest()
	{
		if (T1ExtractorVisionEntries.Length != 4 || T1ExtractorVisionEntries.Distinct<string>(StringComparer.Ordinal).Count() != 4 || T1ExtractorVisionEntries.Any((string targetId) => targetId.Length != 7 || !targetId.EndsWith("1601", StringComparison.Ordinal)) || EngineerEntries.Length != 6 || EngineerBeamEntries.Length != 12 || CommanderBeamEntries.Length != 6 || ArtilleryEntries.Length != 4 || EngineerEntries.Select((EngineerCorrectionSpec spec) => spec.TargetId).Concat<string>(EngineerBeamEntries.Select((EngineerBeamCorrectionSpec spec) => spec.TargetId)).Concat<string>(CommanderBeamEntries.Select((CommanderBeamCorrectionSpec spec) => spec.TargetId))
			.Concat<string>(ArtilleryEntries.Select((ArtilleryCorrectionSpec spec) => spec.TargetId))
			.Distinct(StringComparer.Ordinal)
			.Count() != 22 || EngineerEntries.Any((EngineerCorrectionSpec spec) => spec.TargetId.Length != 7 || spec.SourceId.Length != 7) || EngineerBeamEntries.Any((EngineerBeamCorrectionSpec spec) => spec.TargetId.Length != 7 || !new string[4] { "EDA", "CHOSEN", "GUARD", "SERAPHIM" }.Contains<string>(spec.FactionTag, StringComparer.Ordinal) || spec.OldShrink <= 0.0 || string.IsNullOrWhiteSpace(spec.OldBoneName) || spec.OldBuildBeamBones.Count == 0 || spec.OldBuildBeamBones.Any(string.IsNullOrWhiteSpace) || !spec.OldBuildBeamBones.Contains<string>(spec.OldBoneName, StringComparer.Ordinal) || string.IsNullOrWhiteSpace(spec.BoneName) || spec.BuildBeamBones.Count == 0 || spec.BuildBeamBones.Any(string.IsNullOrWhiteSpace) || !spec.BuildBeamBones.Contains<string>(spec.BoneName, StringComparer.Ordinal)) || CommanderBeamEntries.Any((CommanderBeamCorrectionSpec spec) => spec.TargetId.Length != 7 || !new string[4] { "EDA", "CHOSEN", "GUARD", "SERAPHIM" }.Contains<string>(spec.FactionTag, StringComparer.Ordinal) || string.IsNullOrWhiteSpace(spec.BoneName) || spec.OldBoneName == null != !spec.OldShrink.HasValue || (spec.OldShrink.HasValue && spec.OldShrink <= 0.0)) || ArtilleryEntries.Any(delegate(ArtilleryCorrectionSpec spec)
		{
			bool flag = spec.TargetId.Length != 7 || string.IsNullOrWhiteSpace(spec.ProjectileId) || spec.RangeMin <= 0.0 || spec.ReloadTime <= 0.0 || spec.ProjectileLifetime <= 0.0;
			if (!flag)
			{
				int num = new string[5] { spec.AimBone, spec.OldYawBone, spec.YawBone, spec.OldPitchBone, spec.PitchBone }.Count((string value) => value != null);
				flag = (num != 0 && num != 5) || 1 == 0;
			}
			return flag || (spec.YawBone != null && (string.Equals(spec.YawBone, spec.PitchBone, StringComparison.Ordinal) || (string.Equals(spec.OldYawBone, spec.YawBone, StringComparison.Ordinal) && string.Equals(spec.OldPitchBone, spec.PitchBone, StringComparison.Ordinal))));
		}) || !(from spec in ArtilleryEntries
			where spec.YawBone != null
			select spec.TargetId).OrderBy<string, string>((string targetId) => targetId, StringComparer.Ordinal).SequenceEqual(new string[2] { "ucl1101", "usl1101" }, StringComparer.Ordinal))
		{
			throw new InvalidOperationException("The reviewed T1 extractor vision, engineer, engineer-beam, commander-beam, or artillery scope is invalid.");
		}
	}

	private static void ValidatePatchedLoader(string source)
	{
		ValidatePatchedConstructionBeamMaterialRouting(source);
		RequireExactly(source, "-- Supreme Commander Overhaul gameplay corrections 1.0.2", 1, "gameplay-corrections marker");
		RequireExactly(source, "-- Supreme Commander Overhaul gameplay corrections ", 1, "gameplay-corrections marker family");
		RequireExactly(source, "[\"ugl1501\"] = { sourceId = \"URL0105\", disableMalformedWaterAnimation = true },", 0, "ugl1501 retired water-animation gate");
		RequireExactly(source, "[\"ugl2501\"] = { sourceId = \"URL0208\", disableMalformedWaterAnimation = true },", 0, "ugl2501 retired water-animation gate");
		RequireExactly(source, "[\"ugl3501\"] = { sourceId = \"URL0309\", disableMalformedWaterAnimation = true },", 0, "ugl3501 retired water-animation gate");
		RequireExactly(source, "-- Supreme Commander Overhaul locomotion and weapon idle reset 1.3.0", 1, "idle-reset upstream marker");
		RequireExactly(source, "function CreateUnitPrefab(tp)", 3, "wrapped unit-prefab loaders");
		RequireExactly(source, "local SCO_GameplayCreateUnitPrefab = CreateUnitPrefab", 1, "captured prefab loader");
		RequireExactly(source, "local function SCO_GameplayPrepareT1ExtractorVision(tp, tpId)", 1, "T1 extractor vision correction function");
		RequireExactly(source, "local function SCO_GameplayPrepareEngineer(tp, tpId, spec)", 1, "engineer correction function");
		RequireExactly(source, "local function SCO_GameplayPrepareEngineerBeam(tp, tpId, spec)", 1, "engineer construction-beam correction function");
		RequireExactly(source, "local function SCO_GameplayPrepareCommanderBeam(tp, tpId, spec)", 1, "commander construction-beam correction function");
		RequireExactly(source, "local function SCO_GameplayPrepareArtillery(tp, tpId, spec)", 1, "artillery correction function");
		RequireExactly(source, "local function SCO_GameplayPrepareTemplate(tp)", 1, "template correction dispatcher");
		RequireExactly(source, "        SCO_GameplayPrepareT1ExtractorVision(tp, tpId)", 1, "T1 extractor vision correction invocation");
		RequireExactly(source, "    intel.visionRadius = " + 15, 1, "T1 extractor vision assignment");
		RequireExactly(source, "    visionRange.outerRadius = " + 15, 1, "T1 extractor visible-vision range assignment");
		RequireExactly(source, "    fogRange.outerRadius = " + 15, 1, "T1 extractor fog-of-war range assignment");
		RequireExactly(source, "    additions.scoGameplayT1ExtractorVision = \"1.1.0\"", 1, "T1 extractor vision marker assignment");
		RequireExactly(source, "    SCO_GameplayPrepareTemplate(tp)", 1, "template correction invocation");
		RequireExactly(source, "    return SCO_GameplayCreateUnitPrefab(tp)", 1, "captured prefab-loader return");
		RequireExactly(source, "movement.referenceAltitude = \"GroundOrWater\"", 1, "engineer floating-altitude assignment");
		RequireExactly(source, "aim.aimGravity = { x = 0, y = -4.9, z = 0 }", 1, "artillery gravity assignment");
		RequireExactly(source, "    beam.shrink = " + Number(0.05), 1, "commander construction-beam shrink assignment");
		RequireExactly(source, "    construction.beam.shrink = " + Number(0.05), 1, "engineer construction-beam shrink assignment");
		RequireExactly(source, "    if spec.yaw ~= nil then aim.yawBone = spec.yaw end", 1, "Fervor yaw assignment");
		string[] t1ExtractorVisionEntries = T1ExtractorVisionEntries;
		foreach (string text in t1ExtractorVisionEntries)
		{
			RequireExactly(source, "[\"" + text + "\"] = true,", 1, text + " T1 extractor vision allowlist entry");
		}
		EngineerCorrectionSpec[] engineerEntries = EngineerEntries;
		foreach (EngineerCorrectionSpec engineerCorrectionSpec in engineerEntries)
		{
			RequireExactly(source, "[\"" + engineerCorrectionSpec.TargetId + "\"] = { sourceId = \"" + engineerCorrectionSpec.SourceId + "\", disableMalformedWaterAnimation = " + (engineerCorrectionSpec.DisableMalformedWaterAnimation ? "true" : "false") + " },", 1, engineerCorrectionSpec.TargetId + " manifest entry");
		}
		EngineerBeamCorrectionSpec[] engineerBeamEntries = EngineerBeamEntries;
		foreach (EngineerBeamCorrectionSpec engineerBeamCorrectionSpec in engineerBeamEntries)
		{
			string text2 = string.Concat(engineerBeamCorrectionSpec.OldBuildBeamBones.Select((string bone) => " \"" + bone + "\","));
			string text3 = string.Concat(engineerBeamCorrectionSpec.BuildBeamBones.Select((string bone) => " \"" + bone + "\","));
			string token = "[\"" + engineerBeamCorrectionSpec.TargetId + "\"] = { faction = \"" + engineerBeamCorrectionSpec.FactionTag + "\", oldShrink = " + Number(engineerBeamCorrectionSpec.OldShrink) + ", oldBone = \"" + engineerBeamCorrectionSpec.OldBoneName + "\", oldBones = {" + text2 + " }, bone = \"" + engineerBeamCorrectionSpec.BoneName + "\", bones = {" + text3 + " } },";
			RequireExactly(source, token, 1, engineerBeamCorrectionSpec.TargetId + " engineer-beam entry");
		}
		CommanderBeamCorrectionSpec[] commanderBeamEntries = CommanderBeamEntries;
		foreach (CommanderBeamCorrectionSpec commanderBeamCorrectionSpec in commanderBeamEntries)
		{
			string text4 = ((commanderBeamCorrectionSpec.OldBoneName == null) ? "oldBone = false, oldShrink = false" : ("oldBone = \"" + commanderBeamCorrectionSpec.OldBoneName + "\", oldShrink = " + Number(commanderBeamCorrectionSpec.OldShrink.Value)));
			string token2 = "[\"" + commanderBeamCorrectionSpec.TargetId + "\"] = { faction = \"" + commanderBeamCorrectionSpec.FactionTag + "\", " + text4 + ", bone = \"" + commanderBeamCorrectionSpec.BoneName + "\" },";
			RequireExactly(source, token2, 1, commanderBeamCorrectionSpec.TargetId + " commander-beam entry");
		}
		ArtilleryCorrectionSpec[] artilleryEntries = ArtilleryEntries;
		foreach (ArtilleryCorrectionSpec artilleryCorrectionSpec in artilleryEntries)
		{
			string text5 = "[\"" + artilleryCorrectionSpec.TargetId + "\"] = { projectile = \"" + artilleryCorrectionSpec.ProjectileId + "\", rangeMin = " + Number(artilleryCorrectionSpec.RangeMin) + ", reload = " + Number(artilleryCorrectionSpec.ReloadTime) + ", reduce = " + (artilleryCorrectionSpec.ReduceVelocity ? "true" : "false") + ", lifetime = " + Number(artilleryCorrectionSpec.ProjectileLifetime);
			if (artilleryCorrectionSpec.YawBone != null)
			{
				text5 = text5 + ", aim = \"" + artilleryCorrectionSpec.AimBone + "\", oldYaw = \"" + artilleryCorrectionSpec.OldYawBone + "\", yaw = \"" + artilleryCorrectionSpec.YawBone + "\", oldPitch = \"" + artilleryCorrectionSpec.OldPitchBone + "\", pitch = \"" + artilleryCorrectionSpec.PitchBone + "\"";
			}
			if (artilleryCorrectionSpec.DefaultPitchAdjustment.HasValue)
			{
				text5 = text5 + ", pitchAdjustment = " + Number(artilleryCorrectionSpec.DefaultPitchAdjustment.Value);
			}
			text5 += " },";
			RequireExactly(source, text5, 1, artilleryCorrectionSpec.TargetId + " manifest entry");
		}
	}

	private static void ValidatePatchedConstructionBeamMaterialRouting(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul construction beam faction palette 1.3.3", 1, "construction-beam palette marker");
		RequireExactly(source, "        local constructionBeamMaterialPath\n        -- SCO_AeonConstructionBeamMaterial\n        if (tp.additions and tp.additions.faSourceContract)\n            or (\n                tp.general.tpId == \"ucl0000\"\n                and tp.construction.beam.boneName == \"Left_Turret_Muzzle\"\n            )\n        then\n            constructionBeamMaterialPath = \"VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        else\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have a faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        end", 0, "obsolete construction-beam material block");
		RequireExactly(source, "        local constructionBeamMaterialPath\n        -- SCO_AeonConstructionBeamMaterial\n        if (tp.additions and tp.additions.faSourceContract)\n            or (\n                tp.general.tpId == \"ucl0000\"\n                and tp.construction.beam.boneName == \"Left_Turret_Muzzle\"\n            )\n        then\n            constructionBeamMaterialPath = \"VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") or table.find(tp.tags, \"PROMETHEAN\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        else\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have a faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        end", 0, "obsolete Promethean-composed construction-beam material block");
		RequireExactly(source, "        local constructionBeamMaterialPath\n        if table.find(tp.tags, \"PROMETHEAN\") then\n            constructionBeamMaterialPath = \"Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"CHOSEN\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") then\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        else\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have a faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n        end", 0, "obsolete current Promethean-composed construction-beam material block");
		RequireExactly(source, "        local constructionBeamMaterialPath\n        -- Supreme Commander Overhaul construction beam faction palette 1.3.3\n        local SCO_GameplayBeamFactionCount = 0\n        if type(tp.tags) == \"table\" then\n            for _, factionTag in ipairs({ \"EDA\", \"CHOSEN\", \"GUARD\", \"PROMETHEAN\", \"SERAPHIM\" }) do\n                if table.find(tp.tags, factionTag) then\n                    SCO_GameplayBeamFactionCount = SCO_GameplayBeamFactionCount + 1\n                end\n            end\n        end\n        if SCO_GameplayBeamFactionCount ~= 1 then\n            Engine.Error(\"UnitTemplate:\"..tp.general.tpId..\" did not have exactly one faction tag. ConstructionBeam materials will use the default EDA material.\")\n            constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/uef.sanmaterial\"\n        elseif table.find(tp.tags, \"GUARD\") or table.find(tp.tags, \"PROMETHEAN\") then\n            if table.find(tp.tags, \"PROMETHEAN\") then\n                constructionBeamMaterialPath = \"Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial\"\n            else\n                constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/cybran.sanmaterial\"\n            end\n        elseif table.find(tp.tags, \"CHOSEN\") then\n            constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/aeon.sanmaterial\"\n        elseif table.find(tp.tags, \"SERAPHIM\") then\n            constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/seraphim.sanmaterial\"\n        else\n            constructionBeamMaterialPath = \"VFX/SCOM/ConstructionBeams/uef.sanmaterial\"\n        end", 1, "corrected construction-beam material block");
	}

	private static void ValidatePatchedEdaClientDefault(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul UEF land-factory beam palette 1.3.0", 1, "UEF land-factory beam marker");
		RequireExactly(source, "SupremeCommanderOverhaulEdaUefFactoryConstructionBeam", 1, "UEF land-factory beam prefab");
		RequireExactly(source, "        \"VFX/Models/Static/ConstructionBeam.sanmodel\",\n        \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\",\n        EngineClasses.float3(0.05, 1, 1),", 0, "obsolete UEF land-factory beam snippet");
		RequireExactly(source, "        \"VFX/Models/Static/ConstructionBeam.sanmodel\",\n        -- Supreme Commander Overhaul UEF land-factory beam palette 1.3.0\n        \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\",\n        EngineClasses.float3(0.05, 1, 1),", 1, "corrected UEF land-factory beam snippet");
	}

	private static void ValidatePatchedGenericClientDefault(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul UEF air-factory beam palette 1.3.0", 1, "UEF air-factory beam marker");
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, "FA air-factory upstream marker");
		RequireExactly(source, "local function SCOFaAirFactoryBeamMaterial(factory)\n    if factory:HasTags(Tags.EDA) then\n        return \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n    end\n    return \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\nend", 0, "obsolete FA air-factory material function");
		RequireExactly(source, "local function SCOFaAirFactoryBeamMaterial(factory)\n    -- Supreme Commander Overhaul UEF air-factory beam palette 1.3.0\n    if factory:HasTags(Tags.EDA) then\n        return \"VFX/Materials/ConstructionBeams/Chosen_ConstructionBeam.sanmaterial\"\n    end\n    return \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\nend", 1, "corrected FA air-factory material function");
	}

	private static void ValidatePatchedHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul engineer medium probe 1.0.0", 1, "engineer-probe marker");
		RequireExactly(source, "-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0", 1, "engineer-water marker");
		RequireExactly(source, "    local requiredDepth = previous and SCOFaEngineerWaterExitDepth or SCOFaEngineerWaterEnterDepth\n    return terrainHeight < waterLevel - requiredDepth", 0, "bathymetry-only medium probe");
		RequireExactly(source, "    local requiredDepth = previous and SCOFaEngineerWaterExitDepth or SCOFaEngineerWaterEnterDepth\n    -- Bathymetry alone misclassifies units standing above submerged terrain.\n    if position.y > waterLevel + requiredDepth then return false end\n    return terrainHeight < waterLevel - requiredDepth", 1, "height-aware medium probe");
		ValidateNavalWreckSink(source);
	}

	private static void ValidateNavalWreckSink(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul naval wreck sinking 1.1.0", 1, "naval-wreck marker");
		RequireExactly(source, "---@class HostNavalUnit: HostMobileUnit\nHostNavalUnit = Class(\"NavalUnit\", HostMobileUnit)", 1, "naval-unit class anchor");
		if (source.Contains("local WreckCrash = Import(\"host/props/wreckCrash.lua\")"))
		{
			RequireExactly(source, "local WreckCrash = Import(\"host/props/wreckCrash.lua\")", 1, "native wreck-controller import");
			RequireExactly(source, "function HostNavalUnit:OnSpawnWreckage(overkillRatio)\n    local hasWater = Water.HasWater()\n\n    if not hasWater then\n        return HostUnit.OnSpawnWreckage(self, overkillRatio)\n    end\n\n    WreckCrash.StartWreckCrash(self, overkillRatio, true)\nend", 1, "native naval sinking dispatch");
			RequireExactly(source, "function HostNavalUnit:OnSpawnWreckage(overkillRatio)", 1, "native naval wreck owner");
			RequireExactly(source, "function HostNavalUnit:DeathThread(overkillRatio)", 0, "obsolete naval death-thread override");
			RequireExactly(source, "local function SCOGameplayStartWreckCrash", 0, "obsolete copied wreck controller");
		}
		else
		{
			RequireExactly(source, "---@class HostNavalUnit: HostMobileUnit\nHostNavalUnit = Class(\"NavalUnit\", HostMobileUnit)\n\n-- Supreme Commander Overhaul naval wreck sinking 1.1.0\nlocal function SCOGameplayStartWreckCrash(unit, overkillRatio, startSinking)\n    local dt = Constants.TickTimeStep\n\n    local _, speedPerTick = Engine.GetMovementCurrentSpeed(unit.id)\n    local _, headingDegrees = Engine.GetMovementHeadingDegrees(unit.id)\n    local headingRadians = math.rad(headingDegrees)\n    local speed = speedPerTick / dt\n    local velocity = EngineClasses.float3(\n        math.sin(headingRadians) * speed,\n        0,\n        math.cos(headingRadians) * speed)\n    local _, position = Engine.GetGlobalEntityWorldPosition(unit.id)\n\n    local deleteAtRest = (overkillRatio or 0) >= 1\n        or not unit.spawnsWreck\n        or unit:GetFractionComplete() < 0.5\n    local crashScale = (unit:HasTags(Tags.TECH4)\n        or unit:HasTags(Tags.TECH5))\n        and CrashScaleLarge\n        or CrashScaleDefault\n    local wreckage = CreateWreckageFromUnit(unit)\n\n    if wreckage then\n        wreckage:NewThread(function()\n            WreckCrashThread(\n                wreckage,\n                position,\n                velocity,\n                headingRadians,\n                deleteAtRest,\n                crashScale,\n                startSinking)\n        end)\n    end\nend\n\nfunction HostNavalUnit:DeathThread(overkillRatio)\n    SCOGameplayStartWreckCrash(self, overkillRatio, true)\n    self:Delete()\nend", 1, "naval-wreck sink block");
			RequireExactly(source, "local function WreckCrashThread(wreck, position, velocity, headingRadians, deleteAtRest, crashScale)", 0, "obsolete wreck-crash signature");
			RequireExactly(source, "local function WreckCrashThread(wreck, position, velocity, headingRadians, deleteAtRest, crashScale, startSinking)", 1, "compatible wreck-crash signature");
			RequireExactly(source, "    local sinking = false", 0, "obsolete wreck-crash initial state");
			RequireExactly(source, "    local sinking = startSinking == true", 1, "compatible wreck-crash initial state");
			RequireExactly(source, "SCOGameplayStartWreckCrash(self, overkillRatio, true)", 1, "naval-wreck sinking call");
			RequireExactly(source, "Import(\"host/props/wreckCrash.lua\")", 0, "removed wreck-crash module import");
			RequireExactly(source, "function HostNavalUnit:DeathThread(overkillRatio)", 1, "naval death-thread override");
		}
	}

	private static void ValidatePatchedHostEntity(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul host orientation API correction 1.2.0", 1, "host-orientation API marker");
		RequireExactly(source, "function HostEntity:SetOrientation(orientation)\n    Engine.SetGlobalEntityRotation(self.id, orientation)\nend", 0, "broken host-orientation method");
		RequireExactly(source, "function HostEntity:SetOrientation(orientation)\n    Engine.SetGlobalEntityLocalRotation(self.id, orientation)\nend", 1, "supported host-orientation method");
		RequireExactly(source, "Engine.SetGlobalEntityRotation(self.id, orientation)", 0, "unavailable host-orientation engine call");
	}

	private static void ValidatePatchedSeraphimFactoryHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Seraphim factory orientation correction 1.1.0", 1, "Seraphim factory-orientation marker");
		RequireExactly(source, "-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0", 1, "Seraphim land-factory upstream marker");
		RequireExactly(source, "-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0", 1, "Seraphim death-animation upstream marker");
		RequireExactly(source, "    if not SCO_SeraphimFactoryAlive(target) or not ramp then return end", 0, "unscoped ramp guard");
		RequireExactly(source, "    if not SCO_SeraphimFactoryAlive(target) or not target:HasTags(Tags.MOBILE) or not ramp then return end", 1, "mobile-only ramp guard");
		RequireExactly(source, "SCO_SeraphimFaceRamp(target, SCO_SeraphimSelectRamp(self, target))", 1, "Seraphim build-start ramp-facing call");
		RequireExactly(source, "SCO_SeraphimFaceRamp(target, ramp)", 3, "Seraphim ramp-facing definition/completion uses");
		RequireExactly(source, "local completed = SCO_SeraphimFactoryAlive(target)\n        and target:HasTags(Tags.MOBILE)\n        and target:IsCompleted()", 1, "completed-mobile ramp gate");
		RequireExactly(source, "function SeraphimLandFactory:RollOffUnit(target)", 1, "Seraphim land-factory roll-off hook");
	}

	private static string ReplaceExactly(string source, string oldValue, string newValue, string description)
	{
		RequireExactly(source, oldValue, 1, description);
		return source.Replace(oldValue, newValue);
	}

	private static string Number(double value)
	{
		return StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture);
	}

	private static string Normalize(string source)
	{
		return source.Replace("\r\n", "\n").Replace("\r", "\n");
	}

	private static int Count(string source, string token)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(token, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += token.Length;
		}
		return num;
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = Count(source, token);
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {description} occurrence(s), found {num}.");
		}
	}
}
