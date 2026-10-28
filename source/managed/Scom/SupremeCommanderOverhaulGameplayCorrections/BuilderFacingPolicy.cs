using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SupremeCommanderOverhaulGameplayCorrections;

public static class BuilderFacingPolicy
{
	public const string LoaderMarker = "-- Supreme Commander Overhaul builder facing controllers 1.1.0";

	private const string HostMarkerPrefix = "-- Supreme Commander Overhaul commander/engineer build facing ";

	public const string HostMarker = "-- Supreme Commander Overhaul commander/engineer build facing 1.2.3";

	private const string LoaderHeaderAnchor = "local function InsertAudioTemplate";

	private const string LoaderListAnchor = "    local aimControllerTemplates = {}\n    local navmapModifierTemplates = {}";

	private const string LoaderListReplacement = "    local aimControllerTemplates = {}\n    SCO_BuildFacingInstallControllers(\n        tp, hierarchyEntities, entityNameToHierarchyIndex,\n        aimControllerTemplates)\n    local navmapModifierTemplates = {}";

	private static readonly BuildFacingUnitSpec[] UnitEntries;

	private const string PreviousHostMarker = "-- Supreme Commander Overhaul commander/engineer build facing 1.2.2";

	private const string PreviousTargetGate = "        or (not SCO_BuildFacingIsACU(self) and not targetUnit:HasTags(Tags.STRUCTURE))";

	private const string TargetGate = "        or (not SCO_BuildFacingIsACU(self) and self.tpId ~= 'uel2501' and not targetUnit:HasTags(Tags.STRUCTURE))";

	public static IReadOnlyList<BuildFacingUnitSpec> Units => UnitEntries;

	static BuilderFacingPolicy()
	{
		UnitEntries = new BuildFacingUnitSpec[16]
		{
			new BuildFacingUnitSpec("uel0000", false, new BuildFacingControllerSpec(1, "Left_Arm_Muzzle", "Torso", "Left_Arm_Barrel")),
			new BuildFacingUnitSpec("ugl0000", false, new BuildFacingControllerSpec(1, "Turret_Muzzle_01", "Torso", "Left_Turret")),
			new BuildFacingUnitSpec("ucl0000", false, new BuildFacingControllerSpec(1, "Left_Turret_Muzzle", "Torso", "Left_Turret")),
			new BuildFacingUnitSpec("usl0000", false, new BuildFacingControllerSpec(1, "Left_Turret_Muzzle", "Torso", "Left_Arm_B02")),
			new BuildFacingUnitSpec("uel1501", false, new BuildFacingControllerSpec(1, "Turret_Muzzle", "Turret", "Turret_Barrel")),
			new BuildFacingUnitSpec("uel2501", false, new BuildFacingControllerSpec(1, "Turret_Muzzle_01", "Turret", "Turret_Barrel")),
			new BuildFacingUnitSpec("uel3501", false, new BuildFacingControllerSpec(1, "Turret_Muzzle02", "Turret", "Turret_Barrel")),
			new BuildFacingUnitSpec("ugl1501", true),
			new BuildFacingUnitSpec("ugl2501", true),
			new BuildFacingUnitSpec("ugl3501", true),
			new BuildFacingUnitSpec("ucl1501", true),
			new BuildFacingUnitSpec("ucl2501", true),
			new BuildFacingUnitSpec("ucl3501", true),
			new BuildFacingUnitSpec("usl1501", false, new BuildFacingControllerSpec(1, "Turret_Muzzle", "Arm_Yaw", "Arm_Pitch")),
			new BuildFacingUnitSpec("usl2501", false, new BuildFacingControllerSpec(1, "Turret_Muzzle", "Arm_Yaw", "Arm_Pitch"), new BuildFacingControllerSpec(2, "Turret_Muzzle1", "Arm_Yaw1", "Arm_Pitch1")),
			new BuildFacingUnitSpec("usl3501", false, new BuildFacingControllerSpec(1, "Turret_Muzzle2", "Arm_Yaw", "Arm_Pitch"), new BuildFacingControllerSpec(2, "Turret_Muzzle1", "Arm_Yaw1", "Arm_Pitch1"))
		};
		ValidateManifest();
	}

	public static string PatchUnitTemplateLoaderSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul builder facing controllers 1.1.0");
		switch (num)
		{
		case 1:
			ValidatePatchedLoader(text);
			return text;
		default:
			throw new InvalidOperationException($"Expected zero or one builder-facing loader markers, found {num}.");
		case 0:
		{
			RequireExactly(text, "local function InsertAudioTemplate", 1, "unit-loader header anchor");
			RequireExactly(text, "    local aimControllerTemplates = {}\n    local navmapModifierTemplates = {}", 1, "unit-loader global-list anchor");
			string text2 = BuildLoaderHelpers().TrimEnd(Array.Empty<char>());
			string text3 = Normalize(ReplaceExactly(ReplaceExactly(text, "local function InsertAudioTemplate", text2 + "\n\nlocal function InsertAudioTemplate", "unit-loader header anchor"), "    local aimControllerTemplates = {}\n    local navmapModifierTemplates = {}", "    local aimControllerTemplates = {}\n    SCO_BuildFacingInstallControllers(\n        tp, hierarchyEntities, entityNameToHierarchyIndex,\n        aimControllerTemplates)\n    local navmapModifierTemplates = {}", "unit-loader global-list anchor"));
			ValidatePatchedLoader(text3);
			return text3;
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
		int num = Count(text, "-- Supreme Commander Overhaul commander/engineer build facing 1.2.3");
		int num2 = Count(text, "-- Supreme Commander Overhaul commander/engineer build facing ");
		if (num == 1 && num2 == 1)
		{
			ValidatePatchedHost(text);
			return text;
		}
		if (Count(text, "-- Supreme Commander Overhaul commander/engineer build facing 1.2.2") == 1 && num2 == 1)
		{
			RequireExactly(text, "        or (not SCO_BuildFacingIsACU(self) and not targetUnit:HasTags(Tags.STRUCTURE))", 1, "previous builder-facing target gate");
			RequireExactly(text, "function HostEngineer:OnStartBuildRoutine(targetUnit)", 1, "previous engineer build-start wrapper");
			RequireExactly(text, "function HostEngineer:OnStopBuildRoutine(targetUnit)", 1, "previous engineer build-stop wrapper");
			string text2 = ReplaceExactly(ReplaceExactly(text, "-- Supreme Commander Overhaul commander/engineer build facing 1.2.2", "-- Supreme Commander Overhaul commander/engineer build facing 1.2.3", "previous builder-facing host marker"), "        or (not SCO_BuildFacingIsACU(self) and not targetUnit:HasTags(Tags.STRUCTURE))", "        or (not SCO_BuildFacingIsACU(self) and self.tpId ~= 'uel2501' and not targetUnit:HasTags(Tags.STRUCTURE))", "previous builder-facing target gate");
			ValidatePatchedHost(text2);
			return text2;
		}
		if (num2 != 0)
		{
			throw new InvalidOperationException("Expected no existing builder-facing host marker or exactly one " + $"current marker, found {num2} marker-family entries.");
		}
		RequireExactly(text, "HostEngineer = Class(\"Engineer\", HostMobileUnit)", 1, "HostEngineer definition");
		RequireExactly(text, "HostCommander = Class(\"Commander\", HostEngineer)", 1, "HostCommander definition");
		string text3 = Normalize(text.TrimEnd(Array.Empty<char>()) + "\n\n" + BuildHostAppendix().Trim() + "\n");
		ValidatePatchedHost(text3);
		return text3;
	}

	private static string BuildLoaderHelpers()
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul builder facing controllers 1.1.0");
		stringBuilder.AppendLine("local SCO_BuildFacingSpecs = {");
		BuildFacingUnitSpec[] unitEntries = UnitEntries;
		foreach (BuildFacingUnitSpec buildFacingUnitSpec in unitEntries)
		{
			stringBuilder.AppendLine("    [\"" + buildFacingUnitSpec.TargetId + "\"] = {");
			stringBuilder.AppendLine("        faceWholeUnit = " + (buildFacingUnitSpec.FaceWholeUnit ? "true" : "false") + ",");
			stringBuilder.AppendLine("        torsoYawOnly = " + (buildFacingUnitSpec.TorsoYawOnly ? "true" : "false") + ",");
			stringBuilder.AppendLine("        controllers = {");
			foreach (BuildFacingControllerSpec controller in buildFacingUnitSpec.Controllers)
			{
				stringBuilder.AppendLine("            {");
				stringBuilder.AppendLine("                aimBone = \"" + controller.AimBone + "\",");
				stringBuilder.AppendLine("                yawBone = \"" + controller.YawBone + "\",");
				stringBuilder.AppendLine("                pitchBone = \"" + controller.PitchBone + "\",");
				stringBuilder.AppendLine("                yawEntity = \"" + controller.YawEntity + "\",");
				stringBuilder.AppendLine("                pitchEntity = \"" + controller.PitchEntity + "\",");
				stringBuilder.AppendLine("            },");
			}
			stringBuilder.AppendLine("        },");
			stringBuilder.AppendLine("    },");
		}
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingReindex(hierarchyEntities, entityNameToHierarchyIndex)");
		stringBuilder.AppendLine("    for entityName in pairs(entityNameToHierarchyIndex) do");
		stringBuilder.AppendLine("        entityNameToHierarchyIndex[entityName] = nil");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    for index, entity in ipairs(hierarchyEntities) do");
		stringBuilder.AppendLine("        if entityNameToHierarchyIndex[entity.entityName] then");
		stringBuilder.AppendLine("            error(\"SCOM builder facing found duplicate hierarchy entity \" .. entity.entityName)");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        entityNameToHierarchyIndex[entity.entityName] = index");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingIsDescendant(hierarchyEntities, entityNameToHierarchyIndex, childName, ancestorName)");
		stringBuilder.AppendLine("    local cursor = childName");
		stringBuilder.AppendLine("    local seen = {}");
		stringBuilder.AppendLine("    while cursor do");
		stringBuilder.AppendLine("        if cursor == ancestorName then return true end");
		stringBuilder.AppendLine("        if seen[cursor] then return false end");
		stringBuilder.AppendLine("        seen[cursor] = true");
		stringBuilder.AppendLine("        local index = entityNameToHierarchyIndex[cursor]");
		stringBuilder.AppendLine("        local entity = index and hierarchyEntities[index]");
		stringBuilder.AppendLine("        cursor = entity and entity.parentEntityName or nil");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    return false");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingInsertIdentityParent(hierarchyEntities, entityNameToHierarchyIndex, childName, wrapperName, preservePivot)");
		stringBuilder.AppendLine("    local childIndex = entityNameToHierarchyIndex[childName]");
		stringBuilder.AppendLine("    local child = childIndex and hierarchyEntities[childIndex]");
		stringBuilder.AppendLine("    if not child or not child.parentEntityName then");
		stringBuilder.AppendLine("        error(\"SCOM builder facing could not parent \" .. childName)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if entityNameToHierarchyIndex[wrapperName] then");
		stringBuilder.AppendLine("        error(\"SCOM builder facing wrapper already exists: \" .. wrapperName)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local position = EngineClasses.float3()");
		stringBuilder.AppendLine("    local offsetName = wrapperName .. \"Offset\"");
		stringBuilder.AppendLine("    if preservePivot then");
		stringBuilder.AppendLine("        if entityNameToHierarchyIndex[offsetName] or not child.localTranslation then");
		stringBuilder.AppendLine("            error(\"SCOM builder facing pivot contract drifted: \" .. childName)");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        local p = child.localTranslation");
		stringBuilder.AppendLine("        position = EngineClasses.float3(p.x, p.y, p.z)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local wrapper = EngineClasses.EntityTemplate(");
		stringBuilder.AppendLine("        wrapperName, child.parentEntityName, position,");
		stringBuilder.AppendLine("        1, GetIdentityQuaternion(), true)");
		stringBuilder.AppendLine("    child.parentEntityName = preservePivot and offsetName or wrapperName");
		stringBuilder.AppendLine("    table.insert(hierarchyEntities, childIndex, wrapper)");
		stringBuilder.AppendLine("    if preservePivot then");
		stringBuilder.AppendLine("        -- Keep authored bone translations unchanged while rotating at their joint.");
		stringBuilder.AppendLine("        table.insert(hierarchyEntities, childIndex + 1, EngineClasses.EntityTemplate(");
		stringBuilder.AppendLine("            offsetName, wrapperName, EngineClasses.float3(-position.x, -position.y, -position.z),");
		stringBuilder.AppendLine("            1, GetIdentityQuaternion(), true))");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    SCO_BuildFacingReindex(hierarchyEntities, entityNameToHierarchyIndex)");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingAimBoneIsUnowned(tp, aimBone)");
		stringBuilder.AppendLine("    for _, weapon in ipairs(tp.weapons or {}) do");
		stringBuilder.AppendLine("        for _, controller in ipairs(weapon.aimControllers or {}) do");
		stringBuilder.AppendLine("            if controller.aimBone == aimBone then return false end");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    return true");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingInstallControllers(tp, hierarchyEntities, entityNameToHierarchyIndex, aimControllerTemplates)");
		stringBuilder.AppendLine("    local tpId = tp and tp.general and tp.general.tpId");
		stringBuilder.AppendLine("    local spec = tpId and SCO_BuildFacingSpecs[tpId]");
		stringBuilder.AppendLine("    if not spec then return end");
		stringBuilder.AppendLine("    local preservePivot = tpId == \"uel1501\" or tpId == \"uel2501\" or tpId == \"uel3501\"");
		stringBuilder.AppendLine("    if tp.additions ~= nil and type(tp.additions) ~= \"table\" then");
		stringBuilder.AppendLine("        error(\"SCOM builder facing found invalid additions for \" .. tpId)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    for _, controller in ipairs(spec.controllers) do");
		stringBuilder.AppendLine("        if not SCO_BuildFacingAimBoneIsUnowned(tp, controller.aimBone)");
		stringBuilder.AppendLine("            or not SCO_BuildFacingIsDescendant(hierarchyEntities, entityNameToHierarchyIndex, controller.aimBone, controller.pitchBone)");
		stringBuilder.AppendLine("            or not SCO_BuildFacingIsDescendant(hierarchyEntities, entityNameToHierarchyIndex, controller.pitchBone, controller.yawBone)");
		stringBuilder.AppendLine("        then");
		stringBuilder.AppendLine("            error(\"SCOM builder facing rig contract drifted for \" .. tpId)");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        SCO_BuildFacingInsertIdentityParent(");
		stringBuilder.AppendLine("            hierarchyEntities, entityNameToHierarchyIndex,");
		stringBuilder.AppendLine("            controller.yawBone, controller.yawEntity, preservePivot)");
		stringBuilder.AppendLine("        if not spec.torsoYawOnly then");
		stringBuilder.AppendLine("            SCO_BuildFacingInsertIdentityParent(");
		stringBuilder.AppendLine("                hierarchyEntities, entityNameToHierarchyIndex,");
		stringBuilder.AppendLine("                controller.pitchBone, controller.pitchEntity, preservePivot)");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        hierarchyEntities[entityNameToHierarchyIndex[controller.aimBone]].forceSimulated = true");
		stringBuilder.AppendLine("        table.insert(aimControllerTemplates, EngineClasses.AimControllerTemplate(");
		stringBuilder.AppendLine("            controller.aimBone, controller.aimBone,");
		stringBuilder.AppendLine("            controller.yawEntity, not spec.torsoYawOnly and controller.pitchEntity or nil,");
		stringBuilder.AppendLine("            BallisticType.None,");
		stringBuilder.AppendLine("            -180, 180, 360, EngineClasses.float3(0, 1, 0),");
		stringBuilder.AppendLine("            -90, 90, 360, EngineClasses.float3(1, 0, 0),");
		stringBuilder.AppendLine("            0.2, 0, 1000, 1000, _G.defaultGravityAcceleration,");
		stringBuilder.AppendLine("            0, 0, false, false, false))");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if #spec.controllers > 0 then");
		stringBuilder.AppendLine("        if entityNameToHierarchyIndex.SCOConstructionTarget then");
		stringBuilder.AppendLine("            error(\"SCOM builder facing target marker already exists: \" .. tpId)");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        table.insert(hierarchyEntities, EngineClasses.EntityTemplate(");
		stringBuilder.AppendLine("            \"SCOConstructionTarget\", TemplateHeadEntityName, EngineClasses.float3(),");
		stringBuilder.AppendLine("            1, GetIdentityQuaternion(), true))");
		stringBuilder.AppendLine("        SCO_BuildFacingReindex(hierarchyEntities, entityNameToHierarchyIndex)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if spec.torsoYawOnly then");
		stringBuilder.AppendLine("        -- Unskinned muzzle markers pitch the shot without moving the arm mesh.");
		stringBuilder.AppendLine("        -- Independent weapons retain their own articulation.");
		stringBuilder.AppendLine("        for _, weapon in ipairs(tp.weapons or {}) do");
		stringBuilder.AppendLine("            for _, controller in ipairs(weapon.aimControllers or {}) do");
		stringBuilder.AppendLine("                if controller.yawBone == \"Torso\" then controller.pitchBone = controller.aimBone end");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    tp.additions = tp.additions or {}");
		stringBuilder.AppendLine("    tp.additions.scomBuildFacing = spec");
		stringBuilder.AppendLine("end");
		return stringBuilder.ToString();
	}

	private static string BuildHostAppendix()
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul commander/engineer build facing 1.2.3");
		stringBuilder.AppendLine("local SCO_BuildFacingStart = HostEngineer.OnStartBuildRoutine");
		stringBuilder.AppendLine("local SCO_BuildFacingStop = HostEngineer.OnStopBuildRoutine");
		stringBuilder.AppendLine("local SCO_BuildFacingRepairStart = HostEngineer.OnStartRepairRoutine");
		stringBuilder.AppendLine("local SCO_BuildFacingRepairStop = HostEngineer.OnStopRepairRoutine");
		stringBuilder.AppendLine("if type(SCO_BuildFacingStart) ~= \"function\"");
		stringBuilder.AppendLine("    or type(SCO_BuildFacingStop) ~= \"function\"");
		stringBuilder.AppendLine("    or type(SCO_BuildFacingRepairStart) ~= \"function\"");
		stringBuilder.AppendLine("    or type(SCO_BuildFacingRepairStop) ~= \"function\"");
		stringBuilder.AppendLine("then");
		stringBuilder.AppendLine("    error(\"SCOM builder facing could not capture HostEngineer build callbacks\")");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingIsACU(unit)");
		stringBuilder.AppendLine("    return unit.tpId == 'uel0000' or unit.tpId == 'ugl0000'");
		stringBuilder.AppendLine("        or unit.tpId == 'ucl0000' or unit.tpId == 'usl0000'");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingCanAimRepair(unit)");
		stringBuilder.AppendLine("    return SCO_BuildFacingIsACU(unit) or unit.tpId == 'uel1501'");
		stringBuilder.AppendLine("        or unit.tpId == 'uel2501' or unit.tpId == 'uel3501'");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingGetSpec(unit)");
		stringBuilder.AppendLine("    local additions = unit.tp and unit.tp.additions");
		stringBuilder.AppendLine("    local spec = type(additions) == \"table\" and additions.scomBuildFacing");
		stringBuilder.AppendLine("    if type(spec) ~= \"table\" then return nil end");
		stringBuilder.AppendLine("    return spec");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingResolveControllers(unit, spec)");
		stringBuilder.AppendLine("    if type(spec.controllers) ~= \"table\" or spec.controllers[1] == nil then");
		stringBuilder.AppendLine("        return nil");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local controllerIDs = {}");
		stringBuilder.AppendLine("    for _, controller in ipairs(spec.controllers) do");
		stringBuilder.AppendLine("        local resultCode, controllerID = Engine.GetGlobalBone(unit.id, controller.aimBone)");
		stringBuilder.AppendLine("        if resultCode ~= EngineErrorCode.Success then");
		stringBuilder.AppendLine("            Warn(\"SCOM builder facing could not resolve \" .. unit.tpId .. \" bone \" .. tostring(controller.aimBone))");
		stringBuilder.AppendLine("            return nil");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        table.insert(controllerIDs, controllerID)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    return controllerIDs");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingFaceWholeUnit(unit, targetUnit)");
		stringBuilder.AppendLine("    local directionResult, forward = Engine.GetGlobalEntityForwardDirection(unit.id)");
		stringBuilder.AppendLine("    local restoreDirection = nil");
		stringBuilder.AppendLine("    if directionResult == EngineErrorCode.Success then");
		stringBuilder.AppendLine("        local forwardLength = math.sqrt(forward.x * forward.x + forward.z * forward.z)");
		stringBuilder.AppendLine("        if forwardLength > 0.000001 then");
		stringBuilder.AppendLine("            restoreDirection = EngineClasses.float2(");
		stringBuilder.AppendLine("                forward.x / forwardLength, forward.z / forwardLength)");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local source = unit:GetPosition()");
		stringBuilder.AppendLine("    local target = targetUnit:GetPosition()");
		stringBuilder.AppendLine("    local x = target.x - source.x");
		stringBuilder.AppendLine("    local y = target.z - source.z");
		stringBuilder.AppendLine("    local length = math.sqrt(x * x + y * y)");
		stringBuilder.AppendLine("    if length <= 0.000001 then return nil end");
		stringBuilder.AppendLine("    unit:SetMovementPatterns(\"hold\")\n    local faceResult = Engine.MovementStop(");
		stringBuilder.AppendLine("        unit.id, EngineClasses.float2(x / length, y / length))");
		stringBuilder.AppendLine("    if faceResult ~= EngineErrorCode.Success then return nil end");
		stringBuilder.AppendLine("    return restoreDirection");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingRelease(unit, resolveMissing)");
		stringBuilder.AppendLine("    local ownership = unit.scoBuildFacingOwnership");
		stringBuilder.AppendLine("    if not ownership and resolveMissing then");
		stringBuilder.AppendLine("        local spec = SCO_BuildFacingGetSpec(unit)");
		stringBuilder.AppendLine("        if spec and not spec.faceWholeUnit then");
		stringBuilder.AppendLine("            local controllerIDs = SCO_BuildFacingResolveControllers(unit, spec)");
		stringBuilder.AppendLine("            if controllerIDs then");
		stringBuilder.AppendLine("                ownership = { controllerIDs = controllerIDs }");
		stringBuilder.AppendLine("                unit.scoBuildFacingOwnership = ownership");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if not ownership then return true end");
		stringBuilder.AppendLine("    if ownership.thread then");
		stringBuilder.AppendLine("        KillThread(ownership.thread)");
		stringBuilder.AppendLine("        ownership.thread = nil");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local success = true");
		stringBuilder.AppendLine("    if ownership.controllerIDs then");
		stringBuilder.AppendLine("        local noTarget = EngineClasses.GlobalID()");
		stringBuilder.AppendLine("        for _, controllerID in ipairs(ownership.controllerIDs) do");
		stringBuilder.AppendLine("            local enabledResult = Engine.SetAimControllerEnabled(controllerID, true)");
		stringBuilder.AppendLine("            local targetResult = Engine.SetAimControllerTarget(controllerID, noTarget)");
		stringBuilder.AppendLine("            local stateResult = Engine.SetAimControllerState(");
		stringBuilder.AppendLine("                controllerID, AimControllerState.Rest)");
		stringBuilder.AppendLine("            if enabledResult ~= EngineErrorCode.Success");
		stringBuilder.AppendLine("                or targetResult ~= EngineErrorCode.Success");
		stringBuilder.AppendLine("                or stateResult ~= EngineErrorCode.Success");
		stringBuilder.AppendLine("            then");
		stringBuilder.AppendLine("                success = false");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    elseif ownership.restoreDirection then");
		stringBuilder.AppendLine("        success = Engine.MovementStop(unit.id, ownership.restoreDirection)");
		stringBuilder.AppendLine("            == EngineErrorCode.Success");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if success then");
		stringBuilder.AppendLine("        unit.scoBuildFacingOwnership = nil");
		stringBuilder.AppendLine("    else");
		stringBuilder.AppendLine("        Warn(\"SCOM builder facing could not release \" .. unit.tpId)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    return success");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local SCO_BuildFacingConstructionTarget");
		stringBuilder.AppendLine("local SCO_BuildFacingAcuMarkerRange = 32");
		stringBuilder.AppendLine("local SCO_BuildFacingAcuDeadZone = 0.25");
		stringBuilder.AppendLine("local function SCO_BuildFacingGetTargetPosition(targetUnit)");
		stringBuilder.AppendLine("    if not SCO_BuildFacingConstructionTarget then");
		stringBuilder.AppendLine("        SCO_BuildFacingConstructionTarget = Import(\"common/systems/scoConstructionTarget.lua\")");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    return SCO_BuildFacingConstructionTarget.GetPosition(targetUnit)");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingResolveControllerPoint(unit, spec, ownership, targetUnit)");
		stringBuilder.AppendLine("    local point = SCO_BuildFacingGetTargetPosition(targetUnit)");
		stringBuilder.AppendLine("    if not spec.torsoYawOnly then return point end");
		stringBuilder.AppendLine("    point = point or targetUnit:GetPosition()");
		stringBuilder.AppendLine("    if not point then return nil end");
		stringBuilder.AppendLine("    local source = unit:GetPosition()");
		stringBuilder.AppendLine("    local x = point.x - source.x");
		stringBuilder.AppendLine("    local z = point.z - source.z");
		stringBuilder.AppendLine("    local length = math.sqrt(x * x + z * z)");
		stringBuilder.AppendLine("    local direction = ownership.lastDirection");
		stringBuilder.AppendLine("    if length > SCO_BuildFacingAcuDeadZone then");
		stringBuilder.AppendLine("        direction = EngineClasses.float2(x / length, z / length)");
		stringBuilder.AppendLine("        ownership.lastDirection = direction");
		stringBuilder.AppendLine("    elseif not direction then");
		stringBuilder.AppendLine("        return nil");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    -- A distant horizontal target removes the close-range muzzle/yaw feedback");
		stringBuilder.AppendLine("    -- loop while preserving the intended torso heading. Beam placement stays native.");
		stringBuilder.AppendLine("    return EngineClasses.float3(");
		stringBuilder.AppendLine("        source.x + direction.x * SCO_BuildFacingAcuMarkerRange,");
		stringBuilder.AppendLine("        source.y,");
		stringBuilder.AppendLine("        source.z + direction.y * SCO_BuildFacingAcuMarkerRange)");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingSetTargetPosition(unit, marker, point)");
		stringBuilder.AppendLine("    -- GlobalID identifies the entity; this setter writes parent-local translation.");
		stringBuilder.AppendLine("    -- The marker is a direct child of the unit head, spawned at unit scale.");
		stringBuilder.AppendLine("    local offset = math3D.sub(point, unit:GetPosition())");
		stringBuilder.AppendLine("    local rotation = math3D.invert(unit:GetOrientation())");
		stringBuilder.AppendLine("    local localPoint = Engine.QuaternionRotateVector(rotation, offset)");
		stringBuilder.AppendLine("    return Engine.SetGlobalEntityPosition(marker, localPoint)");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingTrackTarget(unit, spec, ownership, targetUnit)");
		stringBuilder.AppendLine("    -- The controller belongs to this work routine, never to combat targeting.");
		stringBuilder.AppendLine("    WaitTicks(1)");
		stringBuilder.AppendLine("    while unit.scoBuildFacingOwnership == ownership do");
		stringBuilder.AppendLine("        if unit.dead or unit.deleted or targetUnit.dead or targetUnit.deleted");
		stringBuilder.AppendLine("            or unit:GetPause()");
		stringBuilder.AppendLine("            or (not unit:IsBuilding(targetUnit) and not unit:IsRepairing(targetUnit))");
		stringBuilder.AppendLine("        then");
		stringBuilder.AppendLine("            break");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        local point = SCO_BuildFacingResolveControllerPoint(");
		stringBuilder.AppendLine("            unit, spec, ownership, targetUnit)");
		stringBuilder.AppendLine("        if not point then break end");
		stringBuilder.AppendLine("        if SCO_BuildFacingSetTargetPosition(unit, ownership.marker, point) ~= EngineErrorCode.Success then");
		stringBuilder.AppendLine("            Warn(\"SCOM builder facing could not update work point for \" .. unit.tpId)");
		stringBuilder.AppendLine("            break");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        WaitTicks(1)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    ownership.thread = nil");
		stringBuilder.AppendLine("    if unit.scoBuildFacingOwnership == ownership then");
		stringBuilder.AppendLine("        SCO_BuildFacingRelease(unit, false)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_BuildFacingAim(self, targetUnit)");
		stringBuilder.AppendLine("    if not SCO_BuildFacingRelease(self, false) then return end");
		stringBuilder.AppendLine("    local spec = SCO_BuildFacingGetSpec(self)");
		stringBuilder.AppendLine("    if not spec or not targetUnit or targetUnit.dead or targetUnit.deleted");
		stringBuilder.AppendLine("        or (not SCO_BuildFacingIsACU(self) and self.tpId ~= 'uel2501' and not targetUnit:HasTags(Tags.STRUCTURE))");
		stringBuilder.AppendLine("    then");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if spec.faceWholeUnit == true then");
		stringBuilder.AppendLine("        local restoreDirection = SCO_BuildFacingFaceWholeUnit(self, targetUnit)");
		stringBuilder.AppendLine("        if restoreDirection then");
		stringBuilder.AppendLine("            self.scoBuildFacingOwnership = {");
		stringBuilder.AppendLine("                restoreDirection = restoreDirection,");
		stringBuilder.AppendLine("            }");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local controllerIDs = SCO_BuildFacingResolveControllers(self, spec)");
		stringBuilder.AppendLine("    local targetCollider = targetUnit.targetCollider");
		stringBuilder.AppendLine("    if not controllerIDs or not targetCollider or not targetCollider.id then return end");
		stringBuilder.AppendLine("    local ownership = { controllerIDs = controllerIDs }");
		stringBuilder.AppendLine("    local targetID = targetCollider.id");
		stringBuilder.AppendLine("    local point = SCO_BuildFacingResolveControllerPoint(");
		stringBuilder.AppendLine("        self, spec, ownership, targetUnit)");
		stringBuilder.AppendLine("    if spec.torsoYawOnly and not point then return end");
		stringBuilder.AppendLine("    self.scoBuildFacingOwnership = ownership");
		stringBuilder.AppendLine("    if point then");
		stringBuilder.AppendLine("        local markerResult, marker = Engine.GetGlobalBone(self.id, \"SCOConstructionTarget\")");
		stringBuilder.AppendLine("        if markerResult ~= EngineErrorCode.Success or not marker");
		stringBuilder.AppendLine("            or SCO_BuildFacingSetTargetPosition(self, marker, point) ~= EngineErrorCode.Success");
		stringBuilder.AppendLine("        then");
		stringBuilder.AppendLine("            Warn(\"SCOM builder facing could not resolve work point for \" .. self.tpId)");
		stringBuilder.AppendLine("            SCO_BuildFacingRelease(self, false)");
		stringBuilder.AppendLine("            return");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        ownership.marker = marker");
		stringBuilder.AppendLine("        targetID = marker");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    for _, controllerID in ipairs(controllerIDs) do");
		stringBuilder.AppendLine("        local targetResult = Engine.SetAimControllerTarget(");
		stringBuilder.AppendLine("            controllerID, targetID)");
		stringBuilder.AppendLine("        local enabledResult = Engine.SetAimControllerEnabled(controllerID, true)");
		stringBuilder.AppendLine("        local stateResult = Engine.SetAimControllerState(");
		stringBuilder.AppendLine("            controllerID, AimControllerState.Aiming)");
		stringBuilder.AppendLine("        if targetResult ~= EngineErrorCode.Success");
		stringBuilder.AppendLine("            or enabledResult ~= EngineErrorCode.Success");
		stringBuilder.AppendLine("            or stateResult ~= EngineErrorCode.Success");
		stringBuilder.AppendLine("        then");
		stringBuilder.AppendLine("            Warn(\"SCOM builder facing could not activate \" .. self.tpId)");
		stringBuilder.AppendLine("            SCO_BuildFacingRelease(self, false)");
		stringBuilder.AppendLine("            return");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if ownership.marker then");
		stringBuilder.AppendLine("        ownership.thread = self:NewThread(");
		stringBuilder.AppendLine("            SCO_BuildFacingTrackTarget, spec, ownership, targetUnit)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("function HostEngineer:OnStartBuildRoutine(targetUnit)");
		stringBuilder.AppendLine("    SCO_BuildFacingStart(self, targetUnit)");
		stringBuilder.AppendLine("    SCO_BuildFacingAim(self, targetUnit)");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("function HostEngineer:OnStopBuildRoutine(targetUnit)");
		stringBuilder.AppendLine("    SCO_BuildFacingStop(self, targetUnit)");
		stringBuilder.AppendLine("    SCO_BuildFacingRelease(self, true)");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("function HostEngineer:OnStartRepairRoutine(targetUnit)");
		stringBuilder.AppendLine("    SCO_BuildFacingRepairStart(self, targetUnit)");
		stringBuilder.AppendLine("    if SCO_BuildFacingCanAimRepair(self) then SCO_BuildFacingAim(self, targetUnit) end");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("function HostEngineer:OnStopRepairRoutine(targetUnit)");
		stringBuilder.AppendLine("    SCO_BuildFacingRepairStop(self, targetUnit)");
		stringBuilder.AppendLine("    if SCO_BuildFacingCanAimRepair(self) then SCO_BuildFacingRelease(self, true) end");
		stringBuilder.AppendLine("end");
		return stringBuilder.ToString();
	}

	private static void ValidateManifest()
	{
		BuildFacingControllerSpec[] array = UnitEntries.SelectMany((BuildFacingUnitSpec unit) => unit.Controllers).ToArray();
		if (UnitEntries.Length != 16 || UnitEntries.Select((BuildFacingUnitSpec unit) => unit.TargetId).Distinct<string>(StringComparer.Ordinal).Count() != UnitEntries.Length || UnitEntries.Any((BuildFacingUnitSpec unit) => unit.TargetId.Length != 7) || UnitEntries.Count((BuildFacingUnitSpec unit) => unit.FaceWholeUnit) != 6 || UnitEntries.Any((BuildFacingUnitSpec unit) => unit.FaceWholeUnit != (unit.Controllers.Count == 0)) || array.Length != 12 || UnitEntries.Any((BuildFacingUnitSpec unit) => unit.Controllers.Select((BuildFacingControllerSpec controller) => controller.Ordinal).Distinct().Count() != unit.Controllers.Count) || UnitEntries.Any((BuildFacingUnitSpec unit) => !(from controller in unit.Controllers
			select controller.Ordinal into value
			orderby value
			select value).SequenceEqual(Enumerable.Range(1, unit.Controllers.Count))) || array.Any((BuildFacingControllerSpec controller) => string.IsNullOrWhiteSpace(controller.AimBone) || string.IsNullOrWhiteSpace(controller.YawBone) || string.IsNullOrWhiteSpace(controller.PitchBone) || string.Equals(controller.AimBone, controller.YawBone, StringComparison.Ordinal) || string.Equals(controller.AimBone, controller.PitchBone, StringComparison.Ordinal) || string.Equals(controller.YawBone, controller.PitchBone, StringComparison.Ordinal)))
		{
			throw new InvalidOperationException("The reviewed commander/engineer builder-facing scope is invalid.");
		}
	}

	private static void ValidatePatchedLoader(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul builder facing controllers 1.1.0", 1, "builder-facing loader marker");
		int num = source.IndexOf("-- Supreme Commander Overhaul builder facing controllers 1.1.0", StringComparison.Ordinal);
		int num2 = source.IndexOf("\n\nlocal function InsertAudioTemplate", num, StringComparison.Ordinal);
		if (num < 0 || num2 <= num)
		{
			throw new InvalidOperationException("The builder-facing loader block is not independently bounded.");
		}
		string source2 = source.Substring(num, num2 - num);
		RequireExactly(source2, "local function SCO_BuildFacingInstallControllers(", 1, "builder-facing loader function");
		RequireExactly(source, "    SCO_BuildFacingInstallControllers(\n        tp, hierarchyEntities, entityNameToHierarchyIndex,\n        aimControllerTemplates)", 1, "builder-facing loader invocation");
		RequireExactly(source2, "table.insert(aimControllerTemplates, EngineClasses.AimControllerTemplate(", 1, "dedicated construction controller creation");
		RequireExactly(source2, "            controller.aimBone, controller.aimBone,\n            controller.yawEntity, not spec.torsoYawOnly and controller.pitchEntity or nil,", 1, "construction controller ownership");
		RequireExactly(source2, "    tp.additions.scomBuildFacing = spec", 1, "builder-facing template metadata");
		RequireExactly(source2, "    child.parentEntityName = preservePivot and offsetName or wrapperName", 1, "identity-wrapper reparenting");
		RequireExactly(source2, "    local preservePivot = tpId == \"uel1501\" or tpId == \"uel2501\" or tpId == \"uel3501\"", 1, "UEF engineer joint-pivot scope");
		RequireExactly(source2, "offsetName, wrapperName, EngineClasses.float3(-position.x, -position.y, -position.z)", 1, "authored bone-translation compensation");
		RequireExactly(source2, "    SCO_BuildFacingReindex(hierarchyEntities, entityNameToHierarchyIndex)", 2, "hierarchy reindexing");
		RequireExactly(source2, "\"SCOConstructionTarget\", TemplateHeadEntityName, EngineClasses.float3(),", 1, "dedicated construction target marker");
		BuildFacingUnitSpec[] unitEntries = UnitEntries;
		foreach (BuildFacingUnitSpec buildFacingUnitSpec in unitEntries)
		{
			RequireExactly(source2, "    [\"" + buildFacingUnitSpec.TargetId + "\"] = {", 1, buildFacingUnitSpec.TargetId + " builder-facing manifest entry");
			foreach (BuildFacingControllerSpec controller in buildFacingUnitSpec.Controllers)
			{
				RequireExactly(source2, "                aimBone = \"" + controller.AimBone + "\",", CountManifestMatches(controller.AimBone), controller.AimBone + " construction aim bone");
			}
		}
	}

	private static int CountManifestMatches(string aimBone)
	{
		return UnitEntries.SelectMany((BuildFacingUnitSpec unit) => unit.Controllers).Count((BuildFacingControllerSpec controller) => string.Equals(controller.AimBone, aimBone, StringComparison.Ordinal));
	}

	private static void ValidatePatchedHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul commander/engineer build facing 1.2.3", 1, "builder-facing host marker");
		RequireExactly(source, "-- Supreme Commander Overhaul commander/engineer build facing ", 1, "builder-facing host marker family");
		RequireExactly(source, "        or (not SCO_BuildFacingIsACU(self) and self.tpId ~= 'uel2501' and not targetUnit:HasTags(Tags.STRUCTURE))", 1, "builder-facing target gate");
		RequireExactly(source, "        or (not SCO_BuildFacingIsACU(self) and not targetUnit:HasTags(Tags.STRUCTURE))", 0, "previous builder-facing target gate");
		RequireExactly(source, "local SCO_BuildFacingStart = HostEngineer.OnStartBuildRoutine", 1, "captured engineer build-start callback");
		RequireExactly(source, "local SCO_BuildFacingStop = HostEngineer.OnStopBuildRoutine", 1, "captured engineer build-stop callback");
		RequireExactly(source, "function HostEngineer:OnStartBuildRoutine(targetUnit)", 1, "engineer build-start wrapper");
		RequireExactly(source, "function HostEngineer:OnStopBuildRoutine(targetUnit)", 1, "engineer build-stop wrapper");
		RequireExactly(source, "    SCO_BuildFacingStart(self, targetUnit)", 1, "preserved build-start callback");
		RequireExactly(source, "    SCO_BuildFacingStop(self, targetUnit)", 1, "preserved build-stop callback");
		RequireExactly(source, "    local directionResult, forward = Engine.GetGlobalEntityForwardDirection(unit.id)", 1, "whole-unit heading snapshot");
		RequireExactly(source, "local function SCO_BuildFacingRelease(unit, resolveMissing)", 1, "builder-facing release helper");
		RequireExactly(source, "            controllerID, AimControllerState.Aiming)", 1, "construction aiming state");
		RequireExactly(source, "                controllerID, AimControllerState.Rest)", 1, "construction rest state");
		RequireExactly(source, "        Engine.SetAimControllerEnabled(controllerID, false)", 0, "construction-controller freeze");
		RequireExactly(source, "Import(\"common/systems/scoConstructionTarget.lua\")", 1, "shared visible construction target");
		RequireExactly(source, "            SCO_BuildFacingTrackTarget, spec, ownership, targetUnit)", 1, "active construction target tracking");
		RequireExactly(source, "local function SCO_BuildFacingResolveControllerPoint(unit, spec, ownership, targetUnit)", 1, "stable ACU controller target");
		RequireExactly(source, "local SCO_BuildFacingAcuMarkerRange = 32", 1, "ACU marker range");
		RequireExactly(source, "local SCO_BuildFacingAcuDeadZone = 0.25", 1, "ACU marker dead zone");
	}

	private static string ReplaceExactly(string source, string oldValue, string newValue, string description)
	{
		RequireExactly(source, oldValue, 1, description);
		return source.Replace(oldValue, newValue);
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
