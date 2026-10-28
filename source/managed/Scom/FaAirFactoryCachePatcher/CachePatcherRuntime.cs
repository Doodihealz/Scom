using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using ScomDeterministicLua;
using SupremeCommanderOverhaul.Shared;

namespace FaAirFactoryCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class FactorySpec
	{
		public string TargetId { get; }

		public string SourceId { get; }

		public string Faction { get; }

		public string ExpectedClassOwner { get; }

		public string ExpectedUnitClass { get; }

		public string RuntimeClass { get; }

		public string SourceBlueprintPath { get; }

		public string SourceBlueprintSha256 { get; }

		public string SourceScriptPath { get; }

		public string SourceScriptSha256 { get; }

		public int Tier { get; }

		public int Health { get; }

		public int BuildPower { get; }

		public int BuildTime { get; }

		public int Mass { get; }

		public int Energy { get; }

		public int AlloyStorage { get; }

		public double SelectionX { get; }

		public double SelectionZ { get; }

		public string PlatformBone { get; }

		public string[] BuildBones { get; }

		public int BuildFrames { get; }

		public double BuildDuration { get; }

		public string BuildSource { get; }

		public int PlatformFrames { get; }

		public double PlatformDuration { get; }

		public int? UpgradeFrames { get; }

		public double? UpgradeDuration { get; }

		public double ReturnSeconds { get; }

		public string RelativePath => "LJ/lua/common/units/unitsTemplates/" + TargetId + "/" + TargetId + ".santp";

		public string Description => TargetId + " <- " + SourceId + " air-factory template";

		public FactorySpec(string targetId, string sourceId, string faction, string expectedClassOwner, string expectedUnitClass, string runtimeClass, string sourceBlueprintPath, string sourceBlueprintSha256, string sourceScriptPath, string sourceScriptSha256, int tier, int health, int buildPower, int buildTime, int mass, int energy, int alloyStorage, double selectionX, double selectionZ, string platformBone, string[] buildBones, int buildFrames, double buildDuration, string buildSource, int platformFrames, double platformDuration, int? upgradeFrames, double? upgradeDuration, double returnSeconds)
		{
			TargetId = targetId;
			SourceId = sourceId;
			Faction = faction;
			ExpectedClassOwner = expectedClassOwner;
			ExpectedUnitClass = expectedUnitClass;
			RuntimeClass = runtimeClass;
			SourceBlueprintPath = sourceBlueprintPath;
			SourceBlueprintSha256 = sourceBlueprintSha256;
			SourceScriptPath = sourceScriptPath;
			SourceScriptSha256 = sourceScriptSha256;
			Tier = tier;
			Health = health;
			BuildPower = buildPower;
			BuildTime = buildTime;
			Mass = mass;
			Energy = energy;
			AlloyStorage = alloyStorage;
			SelectionX = selectionX;
			SelectionZ = selectionZ;
			PlatformBone = platformBone;
			BuildBones = buildBones;
			BuildFrames = buildFrames;
			BuildDuration = buildDuration;
			BuildSource = buildSource;
			PlatformFrames = platformFrames;
			PlatformDuration = platformDuration;
			UpgradeFrames = upgradeFrames;
			UpgradeDuration = upgradeDuration;
			ReturnSeconds = returnSeconds;
		}
	}

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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Air Factories 1.0.0";

	internal const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	internal const string SourceLuaArchiveSha256 = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb";

	private const string HostDefaultRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefault.lua";

	private const string ClientDefaultRelativePath = "LJ/lua/client/units/unitsClasses/unitsDefault.lua";

	private const string HostEdaRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua";

	private const string ClientEdaRelativePath = "LJ/lua/client/units/unitsClasses/unitsDefaultEDA.lua";

	private const string HostGuardRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	private const string ClientGuardRelativePath = "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua";

	private const string SpawnLoaderRelativePath = "LJ/lua/common/loading/constructionSpawnPositionLoader.lua";

	private static readonly FactorySpec[] FactorySpecs = new FactorySpec[4]
	{
		new FactorySpec("ues2512", "UEB0202", "uef", "unitsDefaultEDA", "EDAAirFactory", "EDAFaUefAirFactory", "units/UEB0202/UEB0202_unit.bp", "a548f94be1a5e5ef2022eb13d002aa3ead9a08be7d5124c93032416382490121", "units/UEB0202/UEB0202_script.lua", "ca090b1f981299ce5f3624f8565a4fced7488d57e2bdccba152147c9a963072c", 2, 9000, 40, 1800, 630, 11700, 160, 3.2, 3.1, "Attachpoint", new string[2] { "Muzzle01", "Muzzle02" }, 19, 0.6, "procedural UEB0202 sliders", 16, 0.5, 201, 6.666666507720947, 0.15),
		new FactorySpec("ues3512", "UEB0302", "uef", "unitsDefaultEDA", "EDAAirFactory", "EDAFaUefAirFactory", "units/UEB0302/UEB0302_unit.bp", "213ba2a3d9aac7127d7f4aeb8345eef367dfd298e3d078954a20a71fa666d2d7", "units/UEB0302/UEB0302_script.lua", "4413a4f0f2498b9ed1e93fd35838173a3fd5e8a16b15cca2321acb72e697a6cc", 3, 22000, 60, 8400, 3150, 105000, 320, 3.2, 3.1, "Attachpoint", new string[3] { "Muzzle01", "Muzzle02", "Muzzle03" }, 31, 1.0, "procedural UEB0302 sliders", 71, 2.3333332538604736, null, null, 0.125),
		new FactorySpec("ugs2512", "URB0202", "cybran", "unitsDefaultGuard", "GuardAirFactory", "GuardFaCybranAirFactory", "units/URB0202/URB0202_unit.bp", "9f67bda320e5993f0987b1fb11b6c24e2871fc1c925177fb66971b6e6a17afef", "units/URB0202/URB0202_script.lua", "4dc35d2263f87df996d4f4f797ae2f533184d0cb640b2c8d0c37763e6cafeaff", 2, 7800, 40, 1800, 630, 11700, 160, 3.0, 3.0, "Build_Point", new string[4] { "Arm01_Muzzle", "Arm02_Muzzle", "Arm03_Muzzle", "Arm04_Muzzle" }, 221, 7.333333492279053, "units/URB0202/URB0202_Abuild.sca", 131, 4.333333492279053, 141, 4.666666507720947, 0.1),
		new FactorySpec("ugs3512", "URB0302", "cybran", "unitsDefaultGuard", "GuardAirFactory", "GuardFaCybranAirFactory", "units/URB0302/URB0302_unit.bp", "e9aa49c6eed7fafde2fb543cb853e2ed8b53c10924481539d224d925c4bacae3", "units/URB0302/URB0302_script.lua", "6983ea728f70d1195d67e4688bb84a8100fcce0e90daff60304aeac69e2843e2", 3, 19000, 60, 8400, 3150, 105000, 320, 3.0, 3.0, "Build_Point", new string[6] { "Arm01_Muzzle", "Arm02_Muzzle", "Arm03_Muzzle", "Arm04_Muzzle", "Arm05_Muzzle", "Arm06_Muzzle" }, 221, 7.333333492279053, "units/URB0302/URB0302_Abuild.sca", 131, 4.333333492279053, null, null, 0.1)
	};

	private const string HostLifecycleOverride = "\n\n-- Supreme Commander Overhaul FA Air Factories 1.0.0\n-- Generic host sampler for authored or script-derived factory build clips.\n-- Keep the sampled clock continuous: native rendering interpolates clip time\n-- before applying Loop. Resend the held sample during pause because native\n-- simulation may still advance its local clock between host samples.\nlocal SCOFaAirFactoryElapsedSentinelBase = -20000\nlocal SCOFaAirFactorySampleSeconds = 0.1\nlocal SCOFaAirFactoryLifecycle = {}\n\nlocal function SCOFaAirFactoryIsAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function SCOFaAirFactoryIsUpgrade(factory, targetUnit)\n    local upgradesTo = factory.tp.construction and factory.tp.construction.upgradesTo\n    return upgradesTo ~= nil and targetUnit ~= nil and targetUnit.tpId == upgradesTo\nend\n\nfunction SCOFaAirFactoryLifecycle.BindPlatform(factory)\n    local config = factory.tp.additions and factory.tp.additions.faAirFactoryLifecycle\n    local boneName = config and config.platformBoneName\n    if not boneName then\n        error(\"FA air factory has no source platform-bone contract.\")\n    end\n    local bone = factory:GetBoneId(boneName)\n    if not bone then\n        error(\"FA air factory could not resolve source platform bone \" .. boneName .. \".\")\n    end\n    factory.platformBone = bone\nend\n\nfunction SCOFaAirFactoryLifecycle.SampleBuildThread(factory, targetUnit, animationId)\n    local elapsed = factory.faAirFactoryBuildElapsed or 0\n    Engine.PlayAnimation(\n        factory.id,\n        animationId,\n        SCOFaAirFactoryElapsedSentinelBase - elapsed\n    )\n    while SCOFaAirFactoryIsAlive(factory)\n        and SCOFaAirFactoryIsAlive(targetUnit)\n        and factory.faAirFactoryBuildTarget == targetUnit\n    do\n        WaitTicks(1)\n        if not factory:GetPause() then\n            if not factory:IsBuilding(targetUnit) then\n                break\n            end\n            elapsed = elapsed + Constants.TickTimeStep\n            factory.faAirFactoryBuildElapsed = elapsed\n        end\n        Engine.PlayAnimation(\n            factory.id,\n            animationId,\n            SCOFaAirFactoryElapsedSentinelBase - elapsed\n        )\n    end\n    if factory.faAirFactoryBuildTarget == targetUnit then\n        factory.faAirFactoryBuildThread = nil\n    end\nend\n\nfunction SCOFaAirFactoryLifecycle.StartBuild(factory, targetUnit)\n    if SCOFaAirFactoryIsUpgrade(factory, targetUnit) then\n        return\n    end\n    if factory.faAirFactoryBuildTarget == targetUnit\n        and factory.faAirFactoryBuildThread\n    then\n        return\n    end\n    SCOFaAirFactoryLifecycle.CancelBuild(factory)\n    local config = factory.tp.additions and factory.tp.additions.faAirFactoryLifecycle\n    local animations = factory.tp.visuals and factory.tp.visuals.animations\n    local animation = animations and animations.build\n    local durationSeconds = config and config.buildDurationSeconds\n    if not animation or not animation.id or type(durationSeconds) ~= \"number\" or durationSeconds <= 0 then\n        error(\"FA air factory build-animation contract is incomplete.\")\n    end\n    factory.faAirFactoryBuildTarget = targetUnit\n    factory.faAirFactoryBuildElapsed = 0\n    factory.faAirFactoryBuildThread = factory:NewThread(\n        SCOFaAirFactoryLifecycle.SampleBuildThread,\n        targetUnit,\n        animation.id\n    )\nend\n\nfunction SCOFaAirFactoryLifecycle.CancelBuild(factory)\n    if factory.faAirFactoryBuildThread then\n        KillThread(factory.faAirFactoryBuildThread)\n    end\n    factory.faAirFactoryBuildThread = nil\n    factory.faAirFactoryBuildTarget = nil\n    factory.faAirFactoryBuildElapsed = nil\nend\n\nfunction SCOFaAirFactoryLifecycle.StopBuild(factory, targetUnit)\n    if factory.faAirFactoryBuildTarget ~= targetUnit then\n        return\n    end\n    -- Sanctuary brackets a production pause with EndBuildRoutine followed by\n    -- StartBuildRoutine.  FA pauses its animator rate at that boundary, so\n    -- retain the same sampler thread and elapsed phase until production resumes.\n    if factory:GetPause() then\n        return\n    end\n    SCOFaAirFactoryLifecycle.CancelBuild(factory)\n    if not SCOFaAirFactoryIsAlive(factory) then\n        return\n    end\n    local config = factory.tp.additions and factory.tp.additions.faAirFactoryLifecycle\n    local animations = factory.tp.visuals and factory.tp.visuals.animations\n    local rest = animations and animations.walk\n    if rest and rest.id then\n        Engine.PlayAnimation(factory.id, rest.id, config.returnSeconds or 0.1)\n    end\nend\n\n_G.SCOFaAirFactoryLifecycle = SCOFaAirFactoryLifecycle";

	private const string ClientLifecycleOverride = "\n\n-- Supreme Commander Overhaul FA Air Factories 1.0.0\n-- Cosmetic construction beams only. Animation remains exclusively on the\n-- replicated native host animation path above.\nlocal SCOFaAirFactoryCreateConstructionBeam =\n    Import(\"client/entities/constructionBeam.lua\").CreateConstructionBeam\n_G.SCOFaAirFactoryBeamPrefabIDs = _G.SCOFaAirFactoryBeamPrefabIDs or {}\nlocal SCOFaAirFactoryBeamPrefabIDs = _G.SCOFaAirFactoryBeamPrefabIDs\nlocal SCOFaAirFactoryBeamGroup = {}\nSCOFaAirFactoryBeamGroup.__index = SCOFaAirFactoryBeamGroup\n\nlocal function SCOFaAirFactoryBeamMaterial(factory)\n    if factory:HasTags(Tags.EDA) then\n        return \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n    end\n    return \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\nend\n\nlocal function SCOFaAirFactoryGetBeamPrefabID(materialPath)\n    local existing = SCOFaAirFactoryBeamPrefabIDs[materialPath]\n    if existing then\n        return existing\n    end\n    local prefabName = materialPath == \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        and \"SupremeCommanderOverhaulFaAirFactoryBeamGuard\"\n        or \"SupremeCommanderOverhaulFaAirFactoryBeamEda\"\n    local prefab = EngineClasses.PrefabTemplate(prefabName)\n    local head = EngineClasses.EntityTemplate()\n    head.entityName = TemplateHeadEntityName\n    head.localTranslation = EngineClasses.float3(0, 0, 0)\n    head.localScale = 1\n    head.localRotation = GetIdentityQuaternion()\n    head.forceSimulated = false\n    table.insert(prefab.hierarchyTemplate.entities, head)\n    local beamEntity = EngineClasses.EntityTemplate()\n    beamEntity.entityName = \"Construction Beam\"\n    beamEntity.parentEntityName = TemplateHeadEntityName\n    beamEntity.localTranslation = EngineClasses.float3(0, 0, 0)\n    beamEntity.localScale = 1\n    beamEntity.localRotation = GetIdentityQuaternion()\n    beamEntity.forceSimulated = false\n    table.insert(prefab.hierarchyTemplate.entities, beamEntity)\n    table.insert(prefab.localTemplate.meshTemplates, EngineClasses.MeshTemplate(\n        \"Construction Beam\",\n        \"VFX/Models/Static/ConstructionBeam.sanmodel\",\n        materialPath,\n        EngineClasses.float3(0.05, 1, 1),\n        ShadowCastingMode.Off,\n        EngineClasses.float4(),\n        EngineClasses.float4(),\n        false\n    ))\n    local errorCode, prefabID = Engine.CreatePrefab(prefab)\n    if errorCode ~= EngineErrorCode.Success then\n        Engine.Error(\"Unable to create the FA air-factory construction-beam prefab.\")\n        return nil\n    end\n    SCOFaAirFactoryBeamPrefabIDs[materialPath] = prefabID\n    return prefabID\nend\n\nfunction SCOFaAirFactoryBeamGroup:SetTarget(target)\n    if self.deleted then return end\n    if target == nil or target.localId == nil\n        or not Engine.IsValidLocalID(target.localId)\n    then\n        self:RemoveTarget()\n        return\n    end\n    for _, state in ipairs(self.beams) do state.beam:SetTarget(target) end\n    self:RenderUpdate()\nend\n\nfunction SCOFaAirFactoryBeamGroup:RemoveTarget()\n    self.enabled = false\n    for _, state in ipairs(self.beams) do\n        state.beam:SetEnabled(false)\n        state.beam:RemoveTarget()\n    end\nend\n\nfunction SCOFaAirFactoryBeamGroup:SetEnabled(enabled)\n    if self.deleted then return end\n    self.enabled = enabled == true\n    for _, state in ipairs(self.beams) do\n        state.beam:SetEnabled(self.enabled and state.beam.targetUnit ~= nil)\n    end\n    self:RenderUpdate()\nend\n\nfunction SCOFaAirFactoryBeamGroup:Update()\n    -- ClientUnit's simulation-rate BuildThread calls this. Loose visual roots\n    -- are updated once in RenderUpdateBeams instead.\nend\n\nfunction SCOFaAirFactoryBeamGroup:RenderUpdate()\n    if self.deleted or not self.enabled then return end\n    for _, state in ipairs(self.beams) do\n        local target = state.beam.targetUnit\n        if target ~= nil and target.localId ~= nil\n            and Engine.IsValidLocalID(target.localId)\n            and Engine.IsValidLocalID(state.rootID)\n            and Engine.IsValidLocalID(state.muzzleID)\n        then\n            Engine.GetLocalEntityWorldPosition(state.muzzleID, state.muzzlePosition)\n            Engine.SetLocalEntityLocalPosition(state.rootID, state.muzzlePosition)\n            state.beam:Update()\n        else\n            state.beam:SetEnabled(false)\n            state.beam:RemoveTarget()\n        end\n    end\nend\n\nfunction SCOFaAirFactoryBeamGroup:Delete()\n    if self.deleted then return end\n    self.deleted = true\n    self.enabled = false\n    for _, state in ipairs(self.beams) do\n        state.beam:SetEnabled(false)\n        state.beam:RemoveTarget()\n        if Engine.IsValidLocalID(state.rootID) then Engine.DeletePrefabInstance(state.rootID) end\n    end\n    self.beams = {}\nend\n\nlocal SCOFaAirFactoryClientLifecycle = {}\n\nfunction SCOFaAirFactoryClientLifecycle.Dispose(factory)\n    local group = factory.constructionBeam\n    factory.constructionBeam = nil\n    factory.constructionBeamEnabled = false\n    if group and group.Delete then group:Delete() end\nend\n\nfunction SCOFaAirFactoryClientLifecycle.Prepare(factory)\n    SCOFaAirFactoryClientLifecycle.Dispose(factory)\n    local bones = factory.tp.additions and factory.tp.additions.buildBeamBones\n    if not bones or #bones == 0 then return end\n    local prefabID = SCOFaAirFactoryGetBeamPrefabID(SCOFaAirFactoryBeamMaterial(factory))\n    if not prefabID then return end\n    local group = setmetatable({ beams = {}, deleted = false, enabled = false }, SCOFaAirFactoryBeamGroup)\n    local initialPosition = factory:GetPosition()\n    for _, boneName in ipairs(bones) do\n        local muzzleID = factory:GetBoneId(boneName)\n        if not Engine.IsValidLocalID(muzzleID) then\n            group:Delete()\n            Engine.Error(\"FA air factory is missing build-beam bone \" .. boneName .. \".\")\n            return\n        end\n        local errorCode, rootID = Engine.InstantiatePrefab(\n            prefabID, initialPosition, EngineClasses.float3(1, 1, 1), GetIdentityQuaternion())\n        if errorCode ~= EngineErrorCode.Success or not Engine.IsValidLocalID(rootID) then\n            if Engine.IsValidLocalID(rootID) then Engine.DeletePrefabInstance(rootID) end\n            group:Delete()\n            Engine.Error(\"Unable to instantiate an FA air-factory construction beam.\")\n            return\n        end\n        table.insert(group.beams, {\n            rootID = rootID,\n            muzzleID = muzzleID,\n            muzzlePosition = EngineClasses.float3(),\n            beam = SCOFaAirFactoryCreateConstructionBeam(rootID),\n        })\n    end\n    factory.constructionBeam = group\nend\n\nfunction SCOFaAirFactoryClientLifecycle.Render(factory)\n    local group = factory.constructionBeam\n    if group and group.RenderUpdate then group:RenderUpdate() end\nend\n\n_G.SCOFaAirFactoryClientLifecycle = SCOFaAirFactoryClientLifecycle";

	private const string ExplicitPlatformLoaderNeedle = "function GetConstructorSpawnBones(tp, skeletonBones)\n    local prefix = tp.general.tpId:sub(1, 3)";

	private static readonly string ExplicitPlatformLoaderReplacement = "function GetConstructorSpawnBones(tp, skeletonBones)\n    -- Supreme Commander Overhaul FA Air Factories 1.0.0\n    -- An imported factory can name its exact FA build attachment. Validate it\n    -- instead of replacing it with a faction substring heuristic.\n    local explicitBoneName = tp.construction and tp.construction.platformBoneName\n    if explicitBoneName then\n        for _, bone in ipairs(skeletonBones) do\n            if bone.boneName == explicitBoneName then\n                return\n            end\n        end\n        error(\"Explicit factory platform bone is absent: \" .. explicitBoneName)\n    end\n\n    local prefix = tp.general.tpId:sub(1, 3)";

	public static void Apply()
	{
		ValidatePinnedScope();
		object obj = null;
		List<CacheMutation> mutations = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			if (Preflight(obj))
			{
				Log("The four exact FA air factories are already active.");
				return;
			}
			FactorySpec[] factorySpecs = FactorySpecs;
			foreach (FactorySpec spec in factorySpecs)
			{
				QueueAppend(obj, mutations, spec.RelativePath, spec.Description, delegate(string source)
				{
					ValidateStockTemplate(source, spec);
				}, BuildTemplateOverride(spec), delegate(string source)
				{
					ValidateTemplate(source, spec);
				});
			}
			QueueAppend(obj, mutations, "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "generic FA factory host animation sampler", ValidateStockHostDefault, "\n\n-- Supreme Commander Overhaul FA Air Factories 1.0.0\n-- Generic host sampler for authored or script-derived factory build clips.\n-- Keep the sampled clock continuous: native rendering interpolates clip time\n-- before applying Loop. Resend the held sample during pause because native\n-- simulation may still advance its local clock between host samples.\nlocal SCOFaAirFactoryElapsedSentinelBase = -20000\nlocal SCOFaAirFactorySampleSeconds = 0.1\nlocal SCOFaAirFactoryLifecycle = {}\n\nlocal function SCOFaAirFactoryIsAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function SCOFaAirFactoryIsUpgrade(factory, targetUnit)\n    local upgradesTo = factory.tp.construction and factory.tp.construction.upgradesTo\n    return upgradesTo ~= nil and targetUnit ~= nil and targetUnit.tpId == upgradesTo\nend\n\nfunction SCOFaAirFactoryLifecycle.BindPlatform(factory)\n    local config = factory.tp.additions and factory.tp.additions.faAirFactoryLifecycle\n    local boneName = config and config.platformBoneName\n    if not boneName then\n        error(\"FA air factory has no source platform-bone contract.\")\n    end\n    local bone = factory:GetBoneId(boneName)\n    if not bone then\n        error(\"FA air factory could not resolve source platform bone \" .. boneName .. \".\")\n    end\n    factory.platformBone = bone\nend\n\nfunction SCOFaAirFactoryLifecycle.SampleBuildThread(factory, targetUnit, animationId)\n    local elapsed = factory.faAirFactoryBuildElapsed or 0\n    Engine.PlayAnimation(\n        factory.id,\n        animationId,\n        SCOFaAirFactoryElapsedSentinelBase - elapsed\n    )\n    while SCOFaAirFactoryIsAlive(factory)\n        and SCOFaAirFactoryIsAlive(targetUnit)\n        and factory.faAirFactoryBuildTarget == targetUnit\n    do\n        WaitTicks(1)\n        if not factory:GetPause() then\n            if not factory:IsBuilding(targetUnit) then\n                break\n            end\n            elapsed = elapsed + Constants.TickTimeStep\n            factory.faAirFactoryBuildElapsed = elapsed\n        end\n        Engine.PlayAnimation(\n            factory.id,\n            animationId,\n            SCOFaAirFactoryElapsedSentinelBase - elapsed\n        )\n    end\n    if factory.faAirFactoryBuildTarget == targetUnit then\n        factory.faAirFactoryBuildThread = nil\n    end\nend\n\nfunction SCOFaAirFactoryLifecycle.StartBuild(factory, targetUnit)\n    if SCOFaAirFactoryIsUpgrade(factory, targetUnit) then\n        return\n    end\n    if factory.faAirFactoryBuildTarget == targetUnit\n        and factory.faAirFactoryBuildThread\n    then\n        return\n    end\n    SCOFaAirFactoryLifecycle.CancelBuild(factory)\n    local config = factory.tp.additions and factory.tp.additions.faAirFactoryLifecycle\n    local animations = factory.tp.visuals and factory.tp.visuals.animations\n    local animation = animations and animations.build\n    local durationSeconds = config and config.buildDurationSeconds\n    if not animation or not animation.id or type(durationSeconds) ~= \"number\" or durationSeconds <= 0 then\n        error(\"FA air factory build-animation contract is incomplete.\")\n    end\n    factory.faAirFactoryBuildTarget = targetUnit\n    factory.faAirFactoryBuildElapsed = 0\n    factory.faAirFactoryBuildThread = factory:NewThread(\n        SCOFaAirFactoryLifecycle.SampleBuildThread,\n        targetUnit,\n        animation.id\n    )\nend\n\nfunction SCOFaAirFactoryLifecycle.CancelBuild(factory)\n    if factory.faAirFactoryBuildThread then\n        KillThread(factory.faAirFactoryBuildThread)\n    end\n    factory.faAirFactoryBuildThread = nil\n    factory.faAirFactoryBuildTarget = nil\n    factory.faAirFactoryBuildElapsed = nil\nend\n\nfunction SCOFaAirFactoryLifecycle.StopBuild(factory, targetUnit)\n    if factory.faAirFactoryBuildTarget ~= targetUnit then\n        return\n    end\n    -- Sanctuary brackets a production pause with EndBuildRoutine followed by\n    -- StartBuildRoutine.  FA pauses its animator rate at that boundary, so\n    -- retain the same sampler thread and elapsed phase until production resumes.\n    if factory:GetPause() then\n        return\n    end\n    SCOFaAirFactoryLifecycle.CancelBuild(factory)\n    if not SCOFaAirFactoryIsAlive(factory) then\n        return\n    end\n    local config = factory.tp.additions and factory.tp.additions.faAirFactoryLifecycle\n    local animations = factory.tp.visuals and factory.tp.visuals.animations\n    local rest = animations and animations.walk\n    if rest and rest.id then\n        Engine.PlayAnimation(factory.id, rest.id, config.returnSeconds or 0.1)\n    end\nend\n\n_G.SCOFaAirFactoryLifecycle = SCOFaAirFactoryLifecycle", ValidateHostLifecycle);
			QueueAppend(obj, mutations, "LJ/lua/client/units/unitsClasses/unitsDefault.lua", "generic FA factory client beam lifecycle", ValidateStockClientDefault, "\n\n-- Supreme Commander Overhaul FA Air Factories 1.0.0\n-- Cosmetic construction beams only. Animation remains exclusively on the\n-- replicated native host animation path above.\nlocal SCOFaAirFactoryCreateConstructionBeam =\n    Import(\"client/entities/constructionBeam.lua\").CreateConstructionBeam\n_G.SCOFaAirFactoryBeamPrefabIDs = _G.SCOFaAirFactoryBeamPrefabIDs or {}\nlocal SCOFaAirFactoryBeamPrefabIDs = _G.SCOFaAirFactoryBeamPrefabIDs\nlocal SCOFaAirFactoryBeamGroup = {}\nSCOFaAirFactoryBeamGroup.__index = SCOFaAirFactoryBeamGroup\n\nlocal function SCOFaAirFactoryBeamMaterial(factory)\n    if factory:HasTags(Tags.EDA) then\n        return \"VFX/Materials/ConstructionBeams/EDA_ConstructionBeam.sanmaterial\"\n    end\n    return \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\nend\n\nlocal function SCOFaAirFactoryGetBeamPrefabID(materialPath)\n    local existing = SCOFaAirFactoryBeamPrefabIDs[materialPath]\n    if existing then\n        return existing\n    end\n    local prefabName = materialPath == \"VFX/Materials/ConstructionBeams/Guard_ConstructionBeam.sanmaterial\"\n        and \"SupremeCommanderOverhaulFaAirFactoryBeamGuard\"\n        or \"SupremeCommanderOverhaulFaAirFactoryBeamEda\"\n    local prefab = EngineClasses.PrefabTemplate(prefabName)\n    local head = EngineClasses.EntityTemplate()\n    head.entityName = TemplateHeadEntityName\n    head.localTranslation = EngineClasses.float3(0, 0, 0)\n    head.localScale = 1\n    head.localRotation = GetIdentityQuaternion()\n    head.forceSimulated = false\n    table.insert(prefab.hierarchyTemplate.entities, head)\n    local beamEntity = EngineClasses.EntityTemplate()\n    beamEntity.entityName = \"Construction Beam\"\n    beamEntity.parentEntityName = TemplateHeadEntityName\n    beamEntity.localTranslation = EngineClasses.float3(0, 0, 0)\n    beamEntity.localScale = 1\n    beamEntity.localRotation = GetIdentityQuaternion()\n    beamEntity.forceSimulated = false\n    table.insert(prefab.hierarchyTemplate.entities, beamEntity)\n    table.insert(prefab.localTemplate.meshTemplates, EngineClasses.MeshTemplate(\n        \"Construction Beam\",\n        \"VFX/Models/Static/ConstructionBeam.sanmodel\",\n        materialPath,\n        EngineClasses.float3(0.05, 1, 1),\n        ShadowCastingMode.Off,\n        EngineClasses.float4(),\n        EngineClasses.float4(),\n        false\n    ))\n    local errorCode, prefabID = Engine.CreatePrefab(prefab)\n    if errorCode ~= EngineErrorCode.Success then\n        Engine.Error(\"Unable to create the FA air-factory construction-beam prefab.\")\n        return nil\n    end\n    SCOFaAirFactoryBeamPrefabIDs[materialPath] = prefabID\n    return prefabID\nend\n\nfunction SCOFaAirFactoryBeamGroup:SetTarget(target)\n    if self.deleted then return end\n    if target == nil or target.localId == nil\n        or not Engine.IsValidLocalID(target.localId)\n    then\n        self:RemoveTarget()\n        return\n    end\n    for _, state in ipairs(self.beams) do state.beam:SetTarget(target) end\n    self:RenderUpdate()\nend\n\nfunction SCOFaAirFactoryBeamGroup:RemoveTarget()\n    self.enabled = false\n    for _, state in ipairs(self.beams) do\n        state.beam:SetEnabled(false)\n        state.beam:RemoveTarget()\n    end\nend\n\nfunction SCOFaAirFactoryBeamGroup:SetEnabled(enabled)\n    if self.deleted then return end\n    self.enabled = enabled == true\n    for _, state in ipairs(self.beams) do\n        state.beam:SetEnabled(self.enabled and state.beam.targetUnit ~= nil)\n    end\n    self:RenderUpdate()\nend\n\nfunction SCOFaAirFactoryBeamGroup:Update()\n    -- ClientUnit's simulation-rate BuildThread calls this. Loose visual roots\n    -- are updated once in RenderUpdateBeams instead.\nend\n\nfunction SCOFaAirFactoryBeamGroup:RenderUpdate()\n    if self.deleted or not self.enabled then return end\n    for _, state in ipairs(self.beams) do\n        local target = state.beam.targetUnit\n        if target ~= nil and target.localId ~= nil\n            and Engine.IsValidLocalID(target.localId)\n            and Engine.IsValidLocalID(state.rootID)\n            and Engine.IsValidLocalID(state.muzzleID)\n        then\n            Engine.GetLocalEntityWorldPosition(state.muzzleID, state.muzzlePosition)\n            Engine.SetLocalEntityLocalPosition(state.rootID, state.muzzlePosition)\n            state.beam:Update()\n        else\n            state.beam:SetEnabled(false)\n            state.beam:RemoveTarget()\n        end\n    end\nend\n\nfunction SCOFaAirFactoryBeamGroup:Delete()\n    if self.deleted then return end\n    self.deleted = true\n    self.enabled = false\n    for _, state in ipairs(self.beams) do\n        state.beam:SetEnabled(false)\n        state.beam:RemoveTarget()\n        if Engine.IsValidLocalID(state.rootID) then Engine.DeletePrefabInstance(state.rootID) end\n    end\n    self.beams = {}\nend\n\nlocal SCOFaAirFactoryClientLifecycle = {}\n\nfunction SCOFaAirFactoryClientLifecycle.Dispose(factory)\n    local group = factory.constructionBeam\n    factory.constructionBeam = nil\n    factory.constructionBeamEnabled = false\n    if group and group.Delete then group:Delete() end\nend\n\nfunction SCOFaAirFactoryClientLifecycle.Prepare(factory)\n    SCOFaAirFactoryClientLifecycle.Dispose(factory)\n    local bones = factory.tp.additions and factory.tp.additions.buildBeamBones\n    if not bones or #bones == 0 then return end\n    local prefabID = SCOFaAirFactoryGetBeamPrefabID(SCOFaAirFactoryBeamMaterial(factory))\n    if not prefabID then return end\n    local group = setmetatable({ beams = {}, deleted = false, enabled = false }, SCOFaAirFactoryBeamGroup)\n    local initialPosition = factory:GetPosition()\n    for _, boneName in ipairs(bones) do\n        local muzzleID = factory:GetBoneId(boneName)\n        if not Engine.IsValidLocalID(muzzleID) then\n            group:Delete()\n            Engine.Error(\"FA air factory is missing build-beam bone \" .. boneName .. \".\")\n            return\n        end\n        local errorCode, rootID = Engine.InstantiatePrefab(\n            prefabID, initialPosition, EngineClasses.float3(1, 1, 1), GetIdentityQuaternion())\n        if errorCode ~= EngineErrorCode.Success or not Engine.IsValidLocalID(rootID) then\n            if Engine.IsValidLocalID(rootID) then Engine.DeletePrefabInstance(rootID) end\n            group:Delete()\n            Engine.Error(\"Unable to instantiate an FA air-factory construction beam.\")\n            return\n        end\n        table.insert(group.beams, {\n            rootID = rootID,\n            muzzleID = muzzleID,\n            muzzlePosition = EngineClasses.float3(),\n            beam = SCOFaAirFactoryCreateConstructionBeam(rootID),\n        })\n    end\n    factory.constructionBeam = group\nend\n\nfunction SCOFaAirFactoryClientLifecycle.Render(factory)\n    local group = factory.constructionBeam\n    if group and group.RenderUpdate then group:RenderUpdate() end\nend\n\n_G.SCOFaAirFactoryClientLifecycle = SCOFaAirFactoryClientLifecycle", ValidateClientLifecycle);
			QueueAppend(obj, mutations, "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", "EDA FA UEF air-factory host class", ValidateStockHostEda, BuildHostClassOverride(uef: true), delegate(string source)
			{
				ValidateHostClass(source, uef: true);
			});
			QueueAppend(obj, mutations, "LJ/lua/client/units/unitsClasses/unitsDefaultEDA.lua", "EDA FA UEF air-factory client class", ValidateStockClientEda, BuildClientClassOverride(uef: true), delegate(string source)
			{
				ValidateClientClass(source, uef: true);
			});
			QueueAppend(obj, mutations, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Guard FA Cybran air-factory host class", ValidateStockHostGuard, BuildHostClassOverride(uef: false), delegate(string source)
			{
				ValidateHostClass(source, uef: false);
			});
			QueueAppend(obj, mutations, "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua", "Guard FA Cybran air-factory client class", ValidateStockClientGuard, BuildClientClassOverride(uef: false), delegate(string source)
			{
				ValidateClientClass(source, uef: false);
			});
			QueueTransform(obj, mutations, "LJ/lua/common/loading/constructionSpawnPositionLoader.lua", "explicit imported-factory platform loader", ValidateStockSpawnLoader, TransformSpawnLoader, ValidateSpawnLoader);
			Commit(obj, mutations);
			Log("Applied exact UEB0202/UEB0302/URB0202/URB0302 factory gameplay, rigs, and source lifecycle bindings.");
		}
		catch (Exception arg)
		{
			if (obj != null)
			{
				RollBack(obj, mutations);
			}
			else
			{
				DisposeUncommitted(mutations);
			}
			Log($"Failed to apply the FA air-factory transaction: {arg}");
			throw;
		}
	}

	private static void ValidatePinnedScope()
	{
		(string, string)[] expected = new(string, string)[4]
		{
			("ues2512", "UEB0202"),
			("ues3512", "UEB0302"),
			("ugs2512", "URB0202"),
			("ugs3512", "URB0302")
		};
		if (FactorySpecs.Length != expected.Length || FactorySpecs.Select((FactorySpec spec) => (TargetId: spec.TargetId, SourceId: spec.SourceId)).Where(delegate((string TargetId, string SourceId) pair, int index)
		{
			(string, string) tuple = pair;
			(string, string) tuple2 = expected[index];
			return tuple.Item1 != tuple2.Item1 || tuple.Item2 != tuple2.Item2;
		}).Any() || FactorySpecs.Select((FactorySpec spec) => spec.TargetId).Distinct<string>(StringComparer.Ordinal).Count() != expected.Length || FactorySpecs.Any((FactorySpec spec) => spec.SourceBlueprintSha256.Length != 64 || spec.SourceScriptSha256.Length != 64))
		{
			throw new InvalidOperationException("The FA air-factory scope changed from its reviewed four routes.");
		}
	}

	private static bool Preflight(object cache)
	{
		List<(string, Action<string>)> list = new List<(string, Action<string>)>();
		FactorySpec[] factorySpecs = FactorySpecs;
		foreach (FactorySpec spec in factorySpecs)
		{
			string resourceText = GetResourceText(GetCachedResource(cache, spec.RelativePath, spec.Description).Stock);
			list.Add((resourceText, delegate(string value)
			{
				ValidateTemplate(value, spec);
			}));
		}
		AddPreflightSource(cache, list, "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "host default", ValidateHostLifecycle);
		AddPreflightSource(cache, list, "LJ/lua/client/units/unitsClasses/unitsDefault.lua", "client default", ValidateClientLifecycle);
		AddPreflightSource(cache, list, "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", "host EDA", delegate(string value)
		{
			ValidateHostClass(value, uef: true);
		});
		AddPreflightSource(cache, list, "LJ/lua/client/units/unitsClasses/unitsDefaultEDA.lua", "client EDA", delegate(string value)
		{
			ValidateClientClass(value, uef: true);
		});
		AddPreflightSource(cache, list, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "host Guard", delegate(string value)
		{
			ValidateHostClass(value, uef: false);
		});
		AddPreflightSource(cache, list, "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua", "client Guard", delegate(string value)
		{
			ValidateClientClass(value, uef: false);
		});
		AddPreflightSource(cache, list, "LJ/lua/common/loading/constructionSpawnPositionLoader.lua", "construction spawn loader", ValidateSpawnLoader);
		bool[] source = list.Select<(string, Action<string>), bool>(((string Source, Action<string> Validate) item) => ContainsOverride(item.Source)).ToArray();
		if (source.Any((bool value) => value) && !source.All((bool value) => value))
		{
			throw new InvalidOperationException("The FA air-factory cache is partially marked; refusing a mixed generation.");
		}
		if (!source.Any((bool value) => value))
		{
			return false;
		}
		foreach (var item in list)
		{
			item.Item2(item.Item1);
		}
		return true;
	}

	private static void AddPreflightSource(object cache, ICollection<(string Source, Action<string> Validate)> sources, string path, string description, Action<string> validate)
	{
		sources.Add((GetResourceText(GetCachedResource(cache, path, description).Stock), validate));
	}

	private static string BuildTemplateOverride(FactorySpec spec)
	{
		string text = "Units/" + spec.TargetId + "/LOD0/" + spec.TargetId + ".sananimation";
		string text2 = string.Join(", ", spec.BuildBones.Select((string bone) => "\"" + bone + "\""));
		string text3 = ((!spec.UpgradeDuration.HasValue) ? string.Empty : ("    upgrade = {\n        clipName = \"AnimUpgrade\",\n        sanAnimationPath = \"" + text + "\",\n        playbackMode = 0,\n    },"));
		string text4 = ((!spec.UpgradeDuration.HasValue) ? "UnitTemplate.additions.progressBoundUpgradeAnimation = nil" : ("    UnitTemplate.additions.progressBoundUpgradeAnimation = {\n        animationKey = \"upgrade\",\n        durationSeconds = " + Lua(spec.UpgradeDuration.Value) + ",\n        restAnimationKey = \"walk\",\n    }"));
		string text5 = ((!spec.UpgradeDuration.HasValue) ? "upgrade = nil," : $"upgrade = {{ clip = \"AnimUpgrade\", frames = {spec.UpgradeFrames}, durationSeconds = {Lua(spec.UpgradeDuration.Value)}, progressBound = true }},");
		string text6 = ((!(spec.Faction == "uef")) ? "proceduralArms = nil," : ((spec.Tier == 2) ? "proceduralArms = { Arm01 = { goalY = -6, speed = 20 }, Arm02 = { goalY = 6, speed = 20 }, stopSpeed = 40, sourceScale = 0.1 }," : "proceduralArms = { Arm01 = { goalY = -5, speed = 20 }, Arm02 = { goalY = 2, speed = 10, alternatesDirection = true }, Arm03 = { goalY = 5, speed = 20 }, stopSpeed = 40, sourceScale = 0.1 },"));
		string text7 = ((spec.Tier == 2) ? ("UnitTemplate.construction.upgradesTo = \"" + ((spec.Faction == "uef") ? "ues3512" : "ugs3512") + "\"") : string.Empty);
		string text8 = ((spec.Faction == "uef") ? "EDA" : "Guard");
		return string.Format("\n\n{0}\n-- {1} -> {2}. The imported model is converted in\n-- the same south-facing native structure space as the commander reference.\nUnitTemplate.additions = UnitTemplate.additions or {{}}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = {{ {3} }}\nUnitTemplate.additions.buildBeamEffectName = nil\nUnitTemplate.additions.selectionHit = {{\n    size = {{ x = {4}, y = {5} }},\n    offset = {{ x = 0, y = 0, z = 0 }},\n}}\nUnitTemplate.additions.tarmacSize = {{ x = 12.8, y = 12.8 }}\nUnitTemplate.additions.faAirFactoryLifecycle = {{\n    platformBoneName = \"{6}\",\n    buildDurationSeconds = {7},\n    buildSampleSeconds = 0.1,\n    returnSeconds = {8},\n    animationOwner = \"host Engine.PlayAnimation sentinel sampler\",\n}}\nUnitTemplate.additions.faSourceContract = {{\n    sourceId = \"{9}\",\n    targetId = \"{10}\",\n    sourceArchiveSha256 = \"{11}\",\n    sourceLuaArchiveSha256 = \"{12}\",\n    sourceBlueprint = \"{13}\",\n    sourceBlueprintSha256 = \"{14}\",\n    sourceScript = \"{15}\",\n    sourceScriptSha256 = \"{16}\",\n    sourceClassBase = \"{17}/{18}\",\n    runtimeClass = \"{19}/{20}\",\n    collision = {{ size = {{ x = 3.5, y = 0.75, z = 3.5 }}, offset = {{ x = 0, y = 0, z = 0 }} }},\n    selection = {{ size = {{ x = {21}, y = {22} }}, thickness = {23} }},\n    footprint = {{ x = 5, y = 5 }},\n    skirt = {{ x = 8, y = 8, sourceOffsetX = -1.5, sourceOffsetZ = -1.5 }},\n    platform = {{\n        clip = \"AnimPlatform\",\n        frames = {24},\n        durationSeconds = {25},\n        sourceEvent = \"AnimationFinishBuildLand\",\n        reachableForAirProduction = false,\n        reason = \"FA gates this clip to LAND while this factory builds AIR\",\n    }},\n    build = {{ clip = \"AnimBuild\", frames = {26}, durationSeconds = {27}, source = \"{28}\", loops = true, pauses = true }},\n    {29}\n    {30}\n    sourceVfx = {{ blinkingLightsImported = false, constructionBeamMaterial = \"{31} compatibility\" }},\n}}\n\nUnitTemplate.general.class = {{ \"{32}\", \"{33}\" }}\nUnitTemplate.general.displayName = \"Tier {34}: FA {35} Air Factory\"\nUnitTemplate.general.name = \"{36} Air Factory\"\n\nUnitTemplate.collisionInfo = {{\n    centerOffset = {{ x = 0, y = 0, z = 0 }},\n    collisionSize = {{ x = 3.5, y = 0.75, z = 3.5 }},\n}}\nUnitTemplate.footprint = {{ x = 5, y = 5 }}\nUnitTemplate.skirtSize = {{ x = 8, y = 8 }}\nUnitTemplate.defence.health = {{ max = {37}, regen = 0, value = {38} }}\nUnitTemplate.economy = {{\n    buildTime = {39},\n    cost = {{ alloys = {40}, energy = {41} }},\n    storage = {{ alloys = {42}, energy = 0 }},\n}}\nUnitTemplate.intel = {{ visionRadius = 20 }}\nUnitTemplate.construction.buildPower = {43}\nUnitTemplate.construction.platformBoneName = \"{44}\"\n{45}\n\nUnitTemplate.visuals.selection = {{\n    size = {{ x = {46}, y = {47} }},\n    offset = {{ x = 0, y = 0, z = 0 }},\n}}\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.effectsWhenActive = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.animations = {{\n    walk = {{ clipName = \"Rest\", sanAnimationPath = \"{48}\", playbackMode = 0 }},\n    build = {{ clipName = \"AnimBuild\", sanAnimationPath = \"{49}\" }},\n    platform = {{ clipName = \"AnimPlatform\", sanAnimationPath = \"{50}\", playbackMode = 0 }},\n{51}\n}}\n{52}\n\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend", "-- Supreme Commander Overhaul FA Air Factories 1.0.0", spec.SourceId, spec.TargetId, text2, Lua(spec.SelectionX), Lua(spec.SelectionZ), spec.PlatformBone, Lua(spec.BuildDuration), Lua(spec.ReturnSeconds), spec.SourceId, spec.TargetId, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb", spec.SourceBlueprintPath, spec.SourceBlueprintSha256, spec.SourceScriptPath, spec.SourceScriptSha256, spec.ExpectedClassOwner, spec.ExpectedUnitClass, spec.ExpectedClassOwner, spec.RuntimeClass, Lua(spec.SelectionX), Lua(spec.SelectionZ), (spec.Faction == "uef") ? "0.3" : "0.33", spec.PlatformFrames, Lua(spec.PlatformDuration), spec.BuildFrames, Lua(spec.BuildDuration), spec.BuildSource, text5, text6, text8, spec.ExpectedClassOwner, spec.RuntimeClass, spec.Tier, (spec.Faction == "uef") ? "UEF" : "Cybran", spec.SourceId, spec.Health, spec.Health, spec.BuildTime, spec.Mass, spec.Energy, spec.AlloyStorage, spec.BuildPower, spec.PlatformBone, text7, Lua(spec.SelectionX), Lua(spec.SelectionZ), text, text, text, text3, text4).Replace("\r\n", "\n");
	}

	private static string BuildHostClassOverride(bool uef)
	{
		string text = (uef ? "EDAAirFactory" : "GuardAirFactory");
		string text2 = (uef ? "HostEDAAirFactory" : "HostGuardAirFactory");
		string text3 = (uef ? "EDAFaUefAirFactory" : "GuardFaCybranAirFactory");
		string text4 = "Host" + text3;
		return "\n\n-- Supreme Commander Overhaul FA Air Factories 1.0.0\nlocal SCOFaAirFactoryHostBase = " + text2 + " or " + text + "\nlocal SCOFaAirFactoryLifecycle = _G.SCOFaAirFactoryLifecycle\nif not SCOFaAirFactoryHostBase or not SCOFaAirFactoryLifecycle then\n    error(\"FA air-factory host dependencies are unavailable.\")\nend\n" + text4 + " = Class(\"" + text3 + "\", SCOFaAirFactoryHostBase)\nlocal SCOFaAirFactoryHostClass = " + text4 + "\n\nfunction SCOFaAirFactoryHostClass:__init(id, army, template, progress, builder)\n    SCOFaAirFactoryHostBase.__init(self, id, army, template, progress, builder)\n    SCOFaAirFactoryLifecycle.BindPlatform(self)\nend\n\nfunction SCOFaAirFactoryHostClass:UpdateAnimations()\n    -- Static factory clips have one lifecycle writer and no Movement state.\nend\n\nfunction SCOFaAirFactoryHostClass:OnStartBuildRoutine(targetUnit)\n    SCOFaAirFactoryHostBase.OnStartBuildRoutine(self, targetUnit)\n    SCOFaAirFactoryLifecycle.StartBuild(self, targetUnit)\nend\n\nfunction SCOFaAirFactoryHostClass:OnStopBuildRoutine(targetUnit)\n    SCOFaAirFactoryHostBase.OnStopBuildRoutine(self, targetUnit)\n    SCOFaAirFactoryLifecycle.StopBuild(self, targetUnit)\nend\n\nfunction SCOFaAirFactoryHostClass:OnPauseProduction()\n    SCOFaAirFactoryHostBase.OnPauseProduction(self)\nend\n\nfunction SCOFaAirFactoryHostClass:OnUnpauseProduction()\n    SCOFaAirFactoryHostBase.OnUnpauseProduction(self)\nend\n\nfunction SCOFaAirFactoryHostClass:OnDestroy(isDelete)\n    SCOFaAirFactoryLifecycle.CancelBuild(self)\n    SCOFaAirFactoryHostBase.OnDestroy(self, isDelete)\nend";
	}

	private static string BuildClientClassOverride(bool uef)
	{
		string text = (uef ? "EDAAirFactory" : "GuardAirFactory");
		string text2 = (uef ? "ClientEDAAirFactory" : "ClientGuardAirFactory");
		string text3 = (uef ? "EDAFaUefAirFactory" : "GuardFaCybranAirFactory");
		string text4 = "Client" + text3;
		return "\n\n-- Supreme Commander Overhaul FA Air Factories 1.0.0\nlocal SCOFaAirFactoryClientBase = " + text2 + " or " + text + "\nlocal SCOFaAirFactoryClientLifecycle = _G.SCOFaAirFactoryClientLifecycle\nif not SCOFaAirFactoryClientBase or not SCOFaAirFactoryClientLifecycle then\n    error(\"FA air-factory client dependencies are unavailable.\")\nend\n" + text4 + " = Class(\"" + text3 + "\", SCOFaAirFactoryClientBase)\nlocal SCOFaAirFactoryClientClass = " + text4 + "\n\nfunction SCOFaAirFactoryClientClass:OnStartBuildRoutine(buildableId)\n    SCOFaAirFactoryClientLifecycle.Prepare(self)\n    SCOFaAirFactoryClientBase.OnStartBuildRoutine(self, buildableId)\nend\n\nfunction SCOFaAirFactoryClientClass:ClientOnStopBuilding()\n    SCOFaAirFactoryClientBase.ClientOnStopBuilding(self)\n    SCOFaAirFactoryClientLifecycle.Dispose(self)\nend\n\nfunction SCOFaAirFactoryClientClass:OnEndUpgrading(upgrade)\n    SCOFaAirFactoryClientBase.OnEndUpgrading(self, upgrade)\n    SCOFaAirFactoryClientLifecycle.Dispose(self)\nend\n\nfunction SCOFaAirFactoryClientClass:RenderUpdateBeams()\n    SCOFaAirFactoryClientBase.RenderUpdateBeams(self)\n    SCOFaAirFactoryClientLifecycle.Render(self)\nend\n\nfunction SCOFaAirFactoryClientClass:OnDestroy(isDelete)\n    SCOFaAirFactoryClientLifecycle.Dispose(self)\n    SCOFaAirFactoryClientBase.OnDestroy(self, isDelete)\nend";
	}

	private static string TransformSpawnLoader(string source)
	{
		string newValue = ((source.IndexOf("\r\n", StringComparison.Ordinal) >= 0) ? "\r\n" : "\n");
		return ReplaceOnce(source, "function GetConstructorSpawnBones(tp, skeletonBones)\n    local prefix = tp.general.tpId:sub(1, 3)".Replace("\n", newValue), ExplicitPlatformLoaderReplacement.Replace("\n", newValue), "construction-spawn function entry");
	}

	private static void ValidateStockTemplate(string source, FactorySpec spec)
	{
		if (source.Contains("\"" + spec.ExpectedUnitClass + "\""))
		{
			RequireTokens(source, "UnitTemplate =", "tpId = \"" + spec.TargetId + "\"", "\"" + spec.ExpectedClassOwner + "\"", "\"" + spec.ExpectedUnitClass + "\"", "buildPower", "rollOffPoints", "footprint", "skirtSize");
			RequireNotContains(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0");
		}
		else
		{
			RequireTokens(source, "UnitTemplate =", "tpId = \"" + spec.TargetId + "\"", "\"" + spec.ExpectedClassOwner + "\"", "\"" + spec.RuntimeClass + "\"", "buildPower", "rollOffPoints", "footprint", "skirtSize");
			RequireNotContains(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0");
		}
	}

	private static void ValidateTemplate(string source, FactorySpec spec)
	{
		string source2 = OwnedAppendix(source);
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, spec.TargetId + " marker");
		RequireTokens(source2, spec.SourceId, spec.TargetId, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb", spec.SourceBlueprintPath, spec.SourceBlueprintSha256, spec.SourceScriptPath, spec.SourceScriptSha256, "UnitTemplate.general.class = { \"" + spec.ExpectedClassOwner + "\", \"" + spec.RuntimeClass + "\" }", "collisionSize = { x = 3.5, y = 0.75, z = 3.5 }", "UnitTemplate.footprint = { x = 5, y = 5 }", "UnitTemplate.skirtSize = { x = 8, y = 8 }", $"max = {spec.Health}", $"buildTime = {spec.BuildTime}", $"alloys = {spec.Mass}", $"energy = {spec.Energy}", $"buildPower = {spec.BuildPower}", "visionRadius = 20", "platformBoneName = \"" + spec.PlatformBone + "\"", $"frames = {spec.BuildFrames}", "durationSeconds = " + Lua(spec.BuildDuration), $"frames = {spec.PlatformFrames}", "durationSeconds = " + Lua(spec.PlatformDuration), "reachableForAirProduction = false", "sourceEvent = \"AnimationFinishBuildLand\"", "clipName = \"AnimBuild\"", "clipName = \"AnimPlatform\"", "playbackMode = 0", "loops = true", "pauses = true");
		string[] buildBones = spec.BuildBones;
		foreach (string text in buildBones)
		{
			RequireTokens(source2, "\"" + text + "\"");
		}
		if (spec.UpgradeDuration.HasValue)
		{
			RequireTokens(source2, "clipName = \"AnimUpgrade\"", "progressBoundUpgradeAnimation", $"frames = {spec.UpgradeFrames}", "durationSeconds = " + Lua(spec.UpgradeDuration.Value));
		}
		else
		{
			RequireTokens(source2, "progressBoundUpgradeAnimation = nil", "upgrade = nil");
		}
		RequireNotContains(source2, "BuildArm01", "Ring_T1_Rotator", "Ring_T2_Rotator", "Ring_T3_Rotator");
	}

	private static void ValidateStockHostDefault(string source)
	{
		RequireTokens(source, "HostFactory = Class", "ProgressAnimationSentinelBase = -10000", "StartProgressBoundUpgradeAnimation", "function SCOProgressAnimationUnit:OnStartUpgrading");
	}

	private static void ValidateHostLifecycle(string source)
	{
		string source2 = OwnedAppendix(source);
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, "host lifecycle marker");
		RequireTokens(source2, "SCOFaAirFactoryElapsedSentinelBase = -20000", "SCOFaAirFactoryLifecycle.SampleBuildThread", "Constants.TickTimeStep", "factory:GetPause()", "factory.faAirFactoryBuildElapsed = elapsed", "SCOFaAirFactoryLifecycle.BindPlatform", "SCOFaAirFactoryLifecycle.StartBuild", "SCOFaAirFactoryLifecycle.StopBuild", "SCOFaAirFactoryLifecycle.CancelBuild", "SCOFaAirFactoryIsUpgrade", "Engine.PlayAnimation");
		RequireExactly(source2, "Engine.PlayAnimation(", 3, "host lifecycle animation call");
		RequireExactly(source2, "SCOFaAirFactoryElapsedSentinelBase - elapsed", 2, "continuous factory elapsed sample");
		RequireNotContains(source2, "SetLocalEntityLocalPosition", "SendClient", "math.floor(elapsed / durationSeconds)", "SCOFaAirFactoryProgressSentinelBase");
	}

	private static void ValidateStockClientDefault(string source)
	{
		RequireTokens(source, "ClientFactory = Class", "ClientAirFactory = Class");
	}

	private static void ValidateClientLifecycle(string source)
	{
		string source2 = OwnedAppendix(source);
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, "client lifecycle marker");
		RequireTokens(source2, "SCOFaAirFactoryBeamGroup", "SCOFaAirFactoryClientLifecycle.Prepare", "SCOFaAirFactoryClientLifecycle.Dispose", "SCOFaAirFactoryClientLifecycle.Render", "EDA_ConstructionBeam.sanmaterial", "Guard_ConstructionBeam.sanmaterial", "Engine.SetLocalEntityLocalPosition", "CreateConstructionBeam", "_G.SCOFaAirFactoryBeamPrefabIDs", "SupremeCommanderOverhaulFaAirFactoryBeamEda", "SupremeCommanderOverhaulFaAirFactoryBeamGuard", "Engine.IsValidLocalID(target.localId)", "state.beam:RemoveTarget()");
		RequireNotContains(source2, "Engine.PlayAnimation", "AnimBuild", "AnimUpgrade", "AnimPlatform", "PrefabTemplate(\"SupremeCommanderOverhaulFaAirFactoryBeam\")", "local SCOFaAirFactoryBeamPrefabIDs = {}");
	}

	private static void ValidateStockHostEda(string source)
	{
		RequireTokens(source, "HostEDAAirFactory = Class(\"EDAAirFactory\", AirFactory)");
	}

	private static void ValidateStockClientEda(string source)
	{
		RequireTokens(source, "ClientEDAAirFactory = Class(\"EDAAirFactory\", AirFactory)");
	}

	private static void ValidateStockHostGuard(string source)
	{
		RequireTokens(source, "HostGuardAirFactory = Class(\"GuardAirFactory\", AirFactory)");
	}

	private static void ValidateStockClientGuard(string source)
	{
		RequireTokens(source, "ClientGuardAirFactory = Class(\"GuardAirFactory\", AirFactory)");
	}

	private static void ValidateHostClass(string source, bool uef)
	{
		string source2 = OwnedAppendix(source);
		string text = (uef ? "HostEDAAirFactory" : "HostGuardAirFactory");
		string text2 = (uef ? "HostEDAFaUefAirFactory" : "HostGuardFaCybranAirFactory");
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, text2 + " marker");
		RequireTokens(source2, text, text2, "SCOFaAirFactoryLifecycle.BindPlatform(self)", "OnStartBuildRoutine(targetUnit)", "StartBuild(self, targetUnit)", "OnStopBuildRoutine(targetUnit)", "StopBuild(self, targetUnit)", "OnPauseProduction()", "OnUnpauseProduction()", "OnDestroy(isDelete)", "function SCOFaAirFactoryHostClass:UpdateAnimations()");
		RequireExactly(source2, "StartBuild(self, targetUnit)", 1, "host build-animation start");
		RequireExactly(source2, "StopBuild(self, targetUnit)", 1, "host build-animation stop");
	}

	private static void ValidateClientClass(string source, bool uef)
	{
		string source2 = OwnedAppendix(source);
		string text = (uef ? "ClientEDAAirFactory" : "ClientGuardAirFactory");
		string text2 = (uef ? "ClientEDAFaUefAirFactory" : "ClientGuardFaCybranAirFactory");
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, text2 + " marker");
		RequireTokens(source2, text, text2, "OnStartBuildRoutine(buildableId)", "SCOFaAirFactoryClientLifecycle.Prepare(self)", "ClientOnStopBuilding()", "SCOFaAirFactoryClientLifecycle.Dispose(self)", "OnEndUpgrading(upgrade)", "RenderUpdateBeams()", "OnDestroy(isDelete)");
		RequireNotContains(source2, "Engine.PlayAnimation", "SetLocalEntityLocalPosition");
	}

	private static void ValidateStockSpawnLoader(string source)
	{
		RequireExactly(source.Replace("\r\n", "\n"), "function GetConstructorSpawnBones(tp, skeletonBones)\n    local prefix = tp.general.tpId:sub(1, 3)", 1, "construction-spawn function entry");
		RequireNotContains(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0");
	}

	private static void ValidateSpawnLoader(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, "platform-loader marker");
		RequireTokens(source, "local explicitBoneName = tp.construction and tp.construction.platformBoneName", "if bone.boneName == explicitBoneName then", "return", "error(\"Explicit factory platform bone is absent: \" .. explicitBoneName)", "local prefix = tp.general.tpId:sub(1, 3)");
	}

	private static void QueueAppend(object cache, List<CacheMutation> mutations, string relativePath, string description, Action<string> validateStock, string appendix, Action<string> validatePatched)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		validateStock(resourceText);
		QueueReplacement(mutations, cachedResource, description, AppendOverride(resourceText, appendix), validatePatched);
	}

	private static void QueueTransform(object cache, List<CacheMutation> mutations, string relativePath, string description, Action<string> validateStock, Func<string, string> transform, Action<string> validatePatched)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		validateStock(resourceText);
		QueueReplacement(mutations, cachedResource, description, transform(resourceText), validatePatched);
	}

	private static void QueueReplacement(ICollection<CacheMutation> mutations, CacheResource resource, string description, string replacementSource, Action<string> validate)
	{
		object obj = CreateNativeArrayFromText(resource.Stock.GetType(), replacementSource);
		try
		{
			validate(GetResourceText(obj));
			mutations.Add(new CacheMutation(resource.Path, resource.Stock, obj, description));
		}
		catch
		{
			TryDisposeNativeArray(obj, "uncommitted " + description);
			throw;
		}
	}

	private static void Commit(object cache, IReadOnlyList<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			mutation.Assigned = true;
			SetCachedResource(cache, mutation.Path, mutation.Replacement);
		}
		foreach (CacheMutation mutation2 in mutations)
		{
			TryDisposeNativeArray(mutation2.Stock, "stock " + mutation2.Description);
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
				TryDisposeNativeArray(item.Replacement, "replacement " + item.Description);
			}
		}
	}

	private static void DisposeUncommitted(IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			TryDisposeNativeArray(mutation.Replacement, "uncommitted " + mutation.Description);
		}
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
		string text = ResolvePath(relativePath);
		object obj2 = obj.Invoke(cache, new object[1] { text });
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
			object obj3 = propertyInfo.GetValue(cache, new object[1] { text }) ?? throw new InvalidOperationException("The cached " + description + " has no value.");
			EnsureNativeArray(obj3, description);
			return new CacheResource(text, obj3);
		}
		string value = "/" + relativePath.Replace('\\', '/');
		CacheResource cacheResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text2 && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cacheResource != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + relativePath + ".");
				}
				object obj4 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("The cached " + description + " has no value.");
				EnsureNativeArray(obj4, description);
				cacheResource = new CacheResource(text2, obj4);
			}
		}
		return cacheResource ?? throw new FileNotFoundException("The required " + description + " was not present in Sanctuary's Lua cache.", relativePath);
	}

	private static string ResolvePath(string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, Encoding.UTF8.GetBytes(source));
	}

	private static string GetResourceText(object resource)
	{
		EnsureNativeArray(resource, "Lua cache resource");
		MethodInfo methodInfo = resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray");
		return Encoding.UTF8.GetString((byte[])methodInfo.Invoke(resource, null));
	}

	private static void EnsureNativeArray(object resource, string description)
	{
		object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource);
		if (!(value is bool) || !(bool)value)
		{
			throw new InvalidOperationException("The cached " + description + " is not an initialized NativeArray.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void TryDisposeNativeArray(object resource, string description)
	{
		try
		{
			object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource);
			if (value is bool && (bool)value)
			{
				(resource.GetType().GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "Dispose")).Invoke(resource, null);
			}
		}
		catch (Exception arg)
		{
			Log($"Could not dispose {description}: {arg}");
		}
	}

	private static string AppendOverride(string source, string appendix)
	{
		if (!source.EndsWith("\n", StringComparison.Ordinal))
		{
			return source + "\n" + appendix;
		}
		return source + appendix;
	}

	private static string ReplaceOnce(string source, string needle, string replacement, string description)
	{
		int num = source.IndexOf(needle, StringComparison.Ordinal);
		if (num < 0 || source.IndexOf(needle, num + needle.Length, StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("Expected exactly one " + description + ".");
		}
		return source.Substring(0, num) + replacement + source.Substring(num + needle.Length);
	}

	private static string OwnedAppendix(string source)
	{
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Air Factories 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("The FA air-factory marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA Air Factories 1.0.0".Length, StringComparison.Ordinal);
		if (num2 >= 0)
		{
			return source.Substring(num, num2 - num);
		}
		return source.Substring(num);
	}

	private static bool ContainsOverride(string source)
	{
		return source.IndexOf("-- Supreme Commander Overhaul FA Air Factories 1.0.0", StringComparison.Ordinal) >= 0;
	}

	private static string Lua(double value)
	{
		return StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture);
	}

	private static void RequireTokens(string source, params string[] tokens)
	{
		foreach (string text in tokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Expected cached Lua source to contain '" + text + "'.");
			}
		}
	}

	private static void RequireNotContains(string source, params string[] tokens)
	{
		foreach (string text in tokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) >= 0)
			{
				throw new InvalidOperationException("FA air-factory-owned source must not contain '" + text + "'.");
			}
		}
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(token, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += token.Length;
		}
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {description}, found {num}.");
		}
	}

	private static void Log(string message)
	{
		string text = "[FA Air Factory Cache Patcher] " + message;
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
