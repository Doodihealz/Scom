using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using ScomDeterministicLua;

namespace SupremeCommanderOverhaulIdleReset;

public static class IdleResetPolicy
{
	public const string Marker = "-- Supreme Commander Overhaul locomotion and weapon idle reset 1.3.0";

	public const string HostMarker = "-- Supreme Commander Overhaul locomotion death guard 1.1.0";

	private const string CreatePrefabSignature = "function CreateUnitPrefab(tp)";

	private static readonly WalkerGait[] WalkerGaitEntries;

	private static readonly TurretRestAdjustment[] TurretRestEntries;

	public static IReadOnlyList<WalkerGait> WalkerGaits => WalkerGaitEntries;

	public static IReadOnlyList<TurretRestAdjustment> TurretRestAdjustments => TurretRestEntries;

	static IdleResetPolicy()
	{
		WalkerGaitEntries = new WalkerGait[11]
		{
			new WalkerGait("ucl0000", "AnimWalk01"),
			new WalkerGait("uel0000", "AnimWalk01"),
			new WalkerGait("uel3001", "AnimWalk"),
			new WalkerGait("ugl0000", "AnimWalk01"),
			new WalkerGait("ugl1001", "AnimWalk"),
			new WalkerGait("ugl1002", "AnimWalk01"),
			new WalkerGait("ugl1701", "AnimWalk"),
			new WalkerGait("ugl2101", "AnimWalk01"),
			new WalkerGait("ugl3001", "AnimWalk"),
			new WalkerGait("ugl3002", "AnimWalk"),
			new WalkerGait("ugl4001", "AnimWalk01")
		};
		if (WalkerGaitEntries.Length != 11 || WalkerGaitEntries.Select((WalkerGait entry) => entry.UnitId).Distinct<string>(StringComparer.Ordinal).Count() != WalkerGaitEntries.Length || WalkerGaitEntries.Any((WalkerGait entry) => entry.UnitId.Length == 0 || entry.ClipName.Length == 0) || !WalkerGaitEntries.Select((WalkerGait entry) => entry.UnitId).SequenceEqual<string>(WalkerGaitEntries.Select((WalkerGait entry) => entry.UnitId).OrderBy<string, string>((string unitId) => unitId, StringComparer.Ordinal), StringComparer.Ordinal))
		{
			throw new InvalidOperationException("The reviewed 11-walker idle-reset scope is invalid or out of order.");
		}
		TurretRestEntries = new TurretRestAdjustment[20]
		{
			new TurretRestAdjustment("ucl4004", 1, 1, "Head_Muzzle", "Head", "Head_Muzzle", -20.0, 0.0),
			new TurretRestAdjustment("ucn1001", 2, 1, "Turret_Back_Muzzle", "Turret_Back", "Turret_Back_Barrel", 10.0, 0.0),
			new TurretRestAdjustment("ucn3001", 3, 1, "Turret_Back_Muzzle", "Turret_Back", "Turret_Back_Barrel01", 10.0, 0.0),
			new TurretRestAdjustment("ucs3101", 1, 1, "Turret_Muzzle", "Turret", "Turret_B01", 30.0, 0.0),
			new TurretRestAdjustment("ucs3201", 1, 1, "Turret_Muzzle01", "Turret", "Turret_Barrel", 25.0, -1.0),
			new TurretRestAdjustment("uel5006", 1, 1, "Turret_Muzzle_Left", "Turret", "Turret_Barrel", 35.0, 0.0),
			new TurretRestAdjustment("uel5006", 1, 2, "Turret_Muzzle_Right", "Turret", "Turret_Barrel", 35.0, 0.0),
			new TurretRestAdjustment("uen5003", 2, 1, "Back_Turret_Muzzle01", "Back_Turret", "Back_Turret_Barrel", 10.0, 0.0),
			new TurretRestAdjustment("ues2201", 1, 1, "Turret_Barrel", "Turret", "Turret_Barrel", 35.0, 0.0),
			new TurretRestAdjustment("ues3201", 1, 1, "Turret_Barrel", "Turret", "Turret_Barrel", 25.0, 0.0),
			new TurretRestAdjustment("ugl4001", 1, 1, "Center_Turret_Muzzle", "Center_Turret_B01", "Center_Turret", -20.0, 0.0),
			new TurretRestAdjustment("ugl4001", 2, 1, "Right_Turret_Muzzle", "Right_Turret", "Right_Turret_Barrel", -10.0, 0.0),
			new TurretRestAdjustment("ugl4001", 3, 1, "Left_Turret_Muzzle", "Left_Turret", "Left_Turret_Barrel", -10.0, 0.0),
			new TurretRestAdjustment("ugs1001", 1, 1, "Turret_Muzzle", "Turret", "Turret_Barrel", 10.0, 0.0),
			new TurretRestAdjustment("ugs1201", 1, 1, "Turret_Muzzle_01", "Turret", "Turret_Barrel", 45.0, 0.0),
			new TurretRestAdjustment("ugs2001", 1, 1, "Turret_Muzzle01", "Turret_B01", "Turret_B02", 10.0, 0.0),
			new TurretRestAdjustment("ugs2101", 1, 1, "Turret_Muzzle", "Turret", "Turret_Barrel", 30.0, 0.0),
			new TurretRestAdjustment("ugs2201", 1, 1, "Turret_Recoil01_Muzzle01", "Turret", "Turret_Barrel", 35.0, 0.0),
			new TurretRestAdjustment("ugs3201", 1, 1, "Turret_Left_Muzzle01", "Turret", "Turret_Barrel", 25.0, 0.0),
			new TurretRestAdjustment("usn2001", 2, 1, "Back_Turret_Muzzle", "Back_Turret", "Back_Turret_Barrel", 10.0, 0.0)
		};
		TurretRestAdjustment[] second = TurretRestEntries.OrderBy<TurretRestAdjustment, string>((TurretRestAdjustment entry) => entry.UnitId, StringComparer.Ordinal).ThenBy((TurretRestAdjustment entry) => entry.WeaponIndex).ThenBy((TurretRestAdjustment entry) => entry.ControllerIndex)
			.ToArray();
		if (TurretRestEntries.Length != 20 || !TurretRestEntries.SequenceEqual<TurretRestAdjustment>(second) || TurretRestEntries.Any((TurretRestAdjustment entry) => entry.UnitId.Length == 0 || entry.WeaponIndex <= 0 || entry.ControllerIndex <= 0 || entry.ExpectedAimBone.Length == 0 || entry.ExpectedYawBone.Length == 0 || entry.ExpectedPitchBone.Length == 0 || entry.ExpectedDefaultPitch == entry.RestDefaultPitch) || (from entry in TurretRestEntries
			group entry by new { entry.UnitId, entry.WeaponIndex }).Any(group => !group.Select((TurretRestAdjustment entry) => entry.ControllerIndex).SequenceEqual(Enumerable.Range(1, group.Count()))))
		{
			throw new InvalidOperationException("The reviewed 20-controller turret-rest manifest is invalid or out of order.");
		}
	}

	public static string PatchUnitTemplateLoaderSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul locomotion and weapon idle reset 1.3.0");
		switch (num)
		{
		case 1:
			ValidatePatchedSource(text);
			return text;
		default:
			throw new InvalidOperationException($"Expected zero or one idle-reset markers, found {num}.");
		case 0:
		{
			ValidateUpstreamSource(text);
			string text2 = Normalize(text.TrimEnd(Array.Empty<char>()) + "\n\n" + BuildLuaAppendix().Trim() + "\n");
			ValidatePatchedSource(text2);
			return text2;
		}
		}
	}

	public static string PatchHostUnitSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul locomotion death guard 1.1.0");
		switch (num)
		{
		case 1:
			ValidatePatchedHostSource(text);
			return text;
		default:
			throw new InvalidOperationException($"Expected zero or one death-guard markers, found {num}.");
		case 0:
		{
			ValidateUpstreamHostSource(text);
			string text2 = Normalize(text.TrimEnd(Array.Empty<char>()) + "\n\n" + BuildHostLuaAppendix().Trim() + "\n");
			ValidatePatchedHostSource(text2);
			return text2;
		}
		}
	}

	public static string BuildLuaAppendix()
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul locomotion and weapon idle reset 1.3.0");
		stringBuilder.AppendLine("-- A movement-scaled gait freezes at its current frame when velocity reaches zero.");
		stringBuilder.AppendLine("-- Promote each audited gait to `run`; `walk` becomes the packaged Rest pose.");
		stringBuilder.AppendLine("local SCO_IdleResetExpectedGaits = {");
		WalkerGait[] walkerGaitEntries = WalkerGaitEntries;
		foreach (WalkerGait walkerGait in walkerGaitEntries)
		{
			stringBuilder.Append("    [\"").Append(walkerGait.UnitId).Append("\"] = \"")
				.Append(walkerGait.ClipName)
				.AppendLine("\",");
		}
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine();
		stringBuilder.Append(BuildTurretRestManifest());
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local SCO_IdleResetDelayedDeathClips = {");
		stringBuilder.AppendLine("    [\"uel3001\"] = { death01 = \"AnimDeath01\", death02 = \"AnimDeath02\" },");
		stringBuilder.AppendLine("    [\"ugl3001\"] = { death01 = \"AnimDeath01\", death02 = \"AnimDeath02\", death03 = \"AnimDeath03\" },");
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_IdleResetWarn(tpId, reason)");
		stringBuilder.AppendLine("    if Warn then");
		stringBuilder.AppendLine("        Warn(\"[SCOM Idle Reset] Skipped \" .. tostring(tpId) .. \"; \" .. reason)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_IdleResetPrepareTurretRest(tp, tpId)");
		stringBuilder.AppendLine("    local specs = SCO_IdleResetTurretRest[tpId]");
		stringBuilder.AppendLine("    if not specs then return end");
		stringBuilder.AppendLine("    local weapons = tp.weapons");
		stringBuilder.AppendLine("    if type(weapons) ~= \"table\" then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(tpId, \"missing turret-rest weapon table\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local additions");
		stringBuilder.AppendLine("    if tpId == \"ugl4001\" then");
		stringBuilder.AppendLine("        additions = tp.additions");
		stringBuilder.AppendLine("        if additions == nil then");
		stringBuilder.AppendLine("            additions = {}");
		stringBuilder.AppendLine("        elseif type(additions) ~= \"table\" then");
		stringBuilder.AppendLine("            SCO_IdleResetWarn(tpId, \"invalid additions table for combined aim reset\")");
		stringBuilder.AppendLine("            return");
		stringBuilder.AppendLine("        elseif additions.scoIdleResetAimPose ~= nil");
		stringBuilder.AppendLine("            and additions.scoIdleResetAimPose ~= true");
		stringBuilder.AppendLine("        then");
		stringBuilder.AppendLine("            SCO_IdleResetWarn(tpId, \"conflicting combined aim-reset marker\")");
		stringBuilder.AppendLine("            return");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local pending = {}");
		stringBuilder.AppendLine("    local sourceCount = 0");
		stringBuilder.AppendLine("    local restCount = 0");
		stringBuilder.AppendLine("    local monkeylordAlreadyReset = tpId == \"ugl4001\"");
		stringBuilder.AppendLine("        and additions.scoIdleResetAimPose == true");
		stringBuilder.AppendLine("    local legacyMonkeylordPrimaryRest = false");
		stringBuilder.AppendLine("    for _, spec in ipairs(specs) do");
		stringBuilder.AppendLine("        local weapon = weapons[spec.weaponIndex]");
		stringBuilder.AppendLine("        local controllers = weapon and weapon.aimControllers");
		stringBuilder.AppendLine("        if type(controllers) ~= \"table\" or #controllers ~= #spec.controllers then");
		stringBuilder.AppendLine("            SCO_IdleResetWarn(tpId, \"weapon \" .. spec.weaponIndex .. \" turret-rest controller roster drifted\")");
		stringBuilder.AppendLine("            return");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        for controllerIndex, expected in ipairs(spec.controllers) do");
		stringBuilder.AppendLine("            local controller = controllers[controllerIndex]");
		stringBuilder.AppendLine("            if type(controller) ~= \"table\" or type(expected) ~= \"table\"");
		stringBuilder.AppendLine("                or type(expected.expected) ~= \"number\" or type(expected.rest) ~= \"number\"");
		stringBuilder.AppendLine("            then");
		stringBuilder.AppendLine("                SCO_IdleResetWarn(tpId, \"weapon \" .. spec.weaponIndex .. \" turret-rest manifest drifted\")");
		stringBuilder.AppendLine("                return");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine("            if controller.aimBone ~= expected.aimBone");
		stringBuilder.AppendLine("                or controller.yawBone ~= expected.yawBone");
		stringBuilder.AppendLine("                or controller.pitchBone ~= expected.pitchBone");
		stringBuilder.AppendLine("            then");
		stringBuilder.AppendLine("                SCO_IdleResetWarn(tpId, \"weapon \" .. spec.weaponIndex .. \" controller \" .. controllerIndex .. \" identity drifted\")");
		stringBuilder.AppendLine("                return");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine("            local currentDefault = controller.defaultPitchAdjustment");
		stringBuilder.AppendLine("            if currentDefault == expected.expected then");
		stringBuilder.AppendLine("                sourceCount = sourceCount + 1");
		stringBuilder.AppendLine("            elseif currentDefault == expected.rest then");
		stringBuilder.AppendLine("                restCount = restCount + 1");
		stringBuilder.AppendLine("                legacyMonkeylordPrimaryRest = tpId == \"ugl4001\"");
		stringBuilder.AppendLine("                    and spec.weaponIndex == 1 and controllerIndex == 1");
		stringBuilder.AppendLine("                    and monkeylordAlreadyReset");
		stringBuilder.AppendLine("                    or legacyMonkeylordPrimaryRest");
		stringBuilder.AppendLine("            else");
		stringBuilder.AppendLine("                SCO_IdleResetWarn(tpId, \"weapon \" .. spec.weaponIndex .. \" controller \" .. controllerIndex .. \" default pitch drifted\")");
		stringBuilder.AppendLine("                return");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine("            pending[#pending + 1] = { controller = controller, value = expected.rest }");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local legacyMonkeylordUpgrade = legacyMonkeylordPrimaryRest");
		stringBuilder.AppendLine("        and sourceCount == 2 and restCount == 1");
		stringBuilder.AppendLine("    if tpId == \"ugl4001\" and monkeylordAlreadyReset");
		stringBuilder.AppendLine("        and sourceCount == #pending");
		stringBuilder.AppendLine("    then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(tpId, \"marked combined aim-reset reverted to source values\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if tpId == \"ugl4001\" and not monkeylordAlreadyReset");
		stringBuilder.AppendLine("        and restCount == #pending");
		stringBuilder.AppendLine("    then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(tpId, \"unmarked combined aim-reset already uses rest values\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if sourceCount > 0 and restCount > 0 and not legacyMonkeylordUpgrade then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(tpId, \"partially applied turret-rest manifest\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if sourceCount > 0 then");
		stringBuilder.AppendLine("        for _, change in ipairs(pending) do");
		stringBuilder.AppendLine("            change.controller.defaultPitchAdjustment = change.value");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if tpId == \"ugl4001\" then");
		stringBuilder.AppendLine("        additions.scoIdleResetAimPose = true");
		stringBuilder.AppendLine("        tp.additions = additions");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_IdleResetFinalizeSourceTemplate(tp)");
		stringBuilder.AppendLine("    local general = tp and tp.general");
		stringBuilder.AppendLine("    local tpId = general and general.tpId");
		stringBuilder.AppendLine("    SCO_IdleResetPrepareTurretRest(tp, tpId)");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_IdleResetPrepareDelayedDeathPlayback(tp, tpId)");
		stringBuilder.AppendLine("    local expected = SCO_IdleResetDelayedDeathClips[tpId]");
		stringBuilder.AppendLine("    if not expected then return end");
		stringBuilder.AppendLine("    local animations = tp.visuals and tp.visuals.animations");
		stringBuilder.AppendLine("    local expectedPath = \"Units/\" .. tpId .. \"/LOD0/\" .. tpId .. \".sananimation\"");
		stringBuilder.AppendLine("    if type(animations) ~= \"table\" then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(tpId, \"missing delayed-death animation table\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    for key, clipName in pairs(expected) do");
		stringBuilder.AppendLine("        local clip = animations[key]");
		stringBuilder.AppendLine("        if type(clip) ~= \"table\" or clip.clipName ~= clipName");
		stringBuilder.AppendLine("            or clip.sanAnimationPath ~= expectedPath");
		stringBuilder.AppendLine("            or (clip.playbackMode ~= nil");
		stringBuilder.AppendLine("                and clip.playbackMode ~= AnimationPlaybackMode.Clamp)");
		stringBuilder.AppendLine("        then");
		stringBuilder.AppendLine("            SCO_IdleResetWarn(tpId, \"delayed-death clip contract drifted for \" .. key)");
		stringBuilder.AppendLine("            return");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    for key in pairs(expected) do");
		stringBuilder.AppendLine("        animations[key].playbackMode = AnimationPlaybackMode.Clamp");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local SCO_IdleResetSummitMainTurrets = {");
		stringBuilder.AppendLine("    { weaponIndex = 1, name = \"FrontTurret01\", bone = \"Front_Turret01\" },");
		stringBuilder.AppendLine("    { weaponIndex = 2, name = \"FrontTurret02\", bone = \"Front_Turret02\" },");
		stringBuilder.AppendLine("    { weaponIndex = 3, name = \"BackTurret\", bone = \"Back_Turret\" },");
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine("local SCO_IdleResetSummitAntiAir = {");
		stringBuilder.AppendLine("    { weaponIndex = 4, name = \"RightAAGun01\", bone = \"Right_Turret01\" },");
		stringBuilder.AppendLine("    { weaponIndex = 5, name = \"RightAAGun02\", bone = \"Right_Turret03\" },");
		stringBuilder.AppendLine("    { weaponIndex = 6, name = \"LeftAAGun01\", bone = \"Left_Turret01\" },");
		stringBuilder.AppendLine("    { weaponIndex = 7, name = \"LeftAAGun02\", bone = \"Left_Turret03\" },");
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_IdleResetPrepareSummitAim(tp, alreadyReset)");
		stringBuilder.AppendLine("    local weapons = tp.weapons");
		stringBuilder.AppendLine("    local expectedDefault = alreadyReset and 0 or 10");
		stringBuilder.AppendLine("    if type(weapons) ~= \"table\" or weapons[8] ~= nil then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(\"uen3001\", \"weapon roster drifted\")");
		stringBuilder.AppendLine("        return false");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    for _, spec in ipairs(SCO_IdleResetSummitMainTurrets) do");
		stringBuilder.AppendLine("        local weapon = weapons[spec.weaponIndex]");
		stringBuilder.AppendLine("        local controllers = weapon and weapon.aimControllers");
		stringBuilder.AppendLine("        local yawController = controllers and controllers[1]");
		stringBuilder.AppendLine("        if not weapon or weapon.name ~= spec.name");
		stringBuilder.AppendLine("            or weapon.projectileTemplate ~= \"psu302g\"");
		stringBuilder.AppendLine("            or weapon.rangeMin ~= 0 or weapon.rangeMax ~= 150");
		stringBuilder.AppendLine("            or type(controllers) ~= \"table\" or controllers[5] ~= nil");
		stringBuilder.AppendLine("            or type(yawController) ~= \"table\"");
		stringBuilder.AppendLine("            or yawController.aimBone ~= spec.bone");
		stringBuilder.AppendLine("            or yawController.yawBone ~= spec.bone");
		stringBuilder.AppendLine("            or yawController.pitchBone ~= nil");
		stringBuilder.AppendLine("            or yawController.defaultYawAdjustment ~= 0");
		stringBuilder.AppendLine("            or yawController.yawMin ~= -140 or yawController.yawMax ~= 140");
		stringBuilder.AppendLine("            or yawController.yawSpeed ~= 25");
		stringBuilder.AppendLine("        then");
		stringBuilder.AppendLine("            SCO_IdleResetWarn(\"uen3001\", spec.name .. \" weapon contract drifted\")");
		stringBuilder.AppendLine("            return false");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        for barrelIndex = 1, 3 do");
		stringBuilder.AppendLine("            local suffix = \"0\" .. barrelIndex");
		stringBuilder.AppendLine("            local controller = controllers[barrelIndex + 1]");
		stringBuilder.AppendLine("            if type(controller) ~= \"table\"");
		stringBuilder.AppendLine("                or controller.aimBone ~= spec.bone .. \"_Muzzle\" .. suffix");
		stringBuilder.AppendLine("                or controller.pitchBone ~= spec.bone .. \"_Barrel\" .. suffix");
		stringBuilder.AppendLine("                or controller.yawBone ~= nil");
		stringBuilder.AppendLine("                or controller.defaultPitchAdjustment ~= expectedDefault");
		stringBuilder.AppendLine("                or controller.pitchMin ~= -20 or controller.pitchMax ~= 20");
		stringBuilder.AppendLine("                or controller.pitchSpeed ~= 10");
		stringBuilder.AppendLine("            then");
		stringBuilder.AppendLine("                SCO_IdleResetWarn(\"uen3001\", spec.name .. \" barrel \" .. barrelIndex .. \" aim contract drifted\")");
		stringBuilder.AppendLine("                return false");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    for _, spec in ipairs(SCO_IdleResetSummitAntiAir) do");
		stringBuilder.AppendLine("        local weapon = weapons[spec.weaponIndex]");
		stringBuilder.AppendLine("        local controllers = weapon and weapon.aimControllers");
		stringBuilder.AppendLine("        local controller = controllers and controllers[1]");
		stringBuilder.AppendLine("        if not weapon or weapon.name ~= spec.name");
		stringBuilder.AppendLine("            or weapon.projectileTemplate ~= \"psu302a\"");
		stringBuilder.AppendLine("            or type(controllers) ~= \"table\" or controllers[2] ~= nil");
		stringBuilder.AppendLine("            or type(controller) ~= \"table\"");
		stringBuilder.AppendLine("            or controller.aimBone ~= spec.bone .. \"_Muzzle01\"");
		stringBuilder.AppendLine("            or controller.pitchBone ~= spec.bone .. \"_Barrel01\"");
		stringBuilder.AppendLine("            or controller.defaultPitchAdjustment ~= 45");
		stringBuilder.AppendLine("            or controller.pitchMin ~= -40 or controller.pitchMax ~= 40");
		stringBuilder.AppendLine("            or controller.pitchSpeed ~= 180");
		stringBuilder.AppendLine("        then");
		stringBuilder.AppendLine("            SCO_IdleResetWarn(\"uen3001\", spec.name .. \" anti-air contract drifted\")");
		stringBuilder.AppendLine("            return false");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if not alreadyReset then");
		stringBuilder.AppendLine("        for _, spec in ipairs(SCO_IdleResetSummitMainTurrets) do");
		stringBuilder.AppendLine("            local controllers = weapons[spec.weaponIndex].aimControllers");
		stringBuilder.AppendLine("            for barrelIndex = 1, 3 do");
		stringBuilder.AppendLine("                controllers[barrelIndex + 1].defaultPitchAdjustment = 0");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    return true");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_IdleResetPrepareAimPose(tp, tpId)");
		stringBuilder.AppendLine("    if tpId ~= \"uen3001\" then");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local additions = tp.additions");
		stringBuilder.AppendLine("    if additions == nil then");
		stringBuilder.AppendLine("        additions = {}");
		stringBuilder.AppendLine("    elseif type(additions) ~= \"table\" then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(tpId, \"invalid additions table for aim reset\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local marker = additions.scoIdleResetAimPose");
		stringBuilder.AppendLine("    if marker ~= nil and marker ~= true then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(tpId, \"conflicting aim-reset marker\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local alreadyReset = marker == true");
		stringBuilder.AppendLine("    local valid = SCO_IdleResetPrepareSummitAim(tp, alreadyReset)");
		stringBuilder.AppendLine("    if valid and not alreadyReset then");
		stringBuilder.AppendLine("        additions.scoIdleResetAimPose = true");
		stringBuilder.AppendLine("        tp.additions = additions");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_IdleResetPrepareTemplate(tp)");
		stringBuilder.AppendLine("    local general = tp and tp.general");
		stringBuilder.AppendLine("    local tpId = general and general.tpId");
		stringBuilder.AppendLine("    SCO_IdleResetPrepareDelayedDeathPlayback(tp, tpId)");
		stringBuilder.AppendLine("    SCO_IdleResetPrepareAimPose(tp, tpId)");
		stringBuilder.AppendLine("    if SCO_SourceFinalizerOwnsIdleResetTurretRest ~= true then");
		stringBuilder.AppendLine("        SCO_IdleResetFinalizeSourceTemplate(tp)");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local expectedGait = tpId and SCO_IdleResetExpectedGaits[tpId]");
		stringBuilder.AppendLine("    if not expectedGait then");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("    local animations = tp.visuals and tp.visuals.animations");
		stringBuilder.AppendLine("    if type(animations) ~= \"table\" then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(tpId, \"missing audited SCOM animation table\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("    local idle = animations.walk");
		stringBuilder.AppendLine("    local gait = animations.run");
		stringBuilder.AppendLine("    local needsPromotion = gait == nil");
		stringBuilder.AppendLine("    if gait then");
		stringBuilder.AppendLine("        if gait.clipName ~= expectedGait then");
		stringBuilder.AppendLine("            SCO_IdleResetWarn(tpId, \"unexpected SCOM run clip \" .. tostring(gait.clipName))");
		stringBuilder.AppendLine("            return");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        if type(idle) ~= \"table\" or idle.clipName == expectedGait then");
		stringBuilder.AppendLine("            SCO_IdleResetWarn(tpId, \"missing distinct stopped animation\")");
		stringBuilder.AppendLine("            return");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    else");
		stringBuilder.AppendLine("        gait = idle");
		stringBuilder.AppendLine("        if type(gait) ~= \"table\" or gait.clipName ~= expectedGait then");
		stringBuilder.AppendLine("            SCO_IdleResetWarn(tpId, \"unexpected SCOM locomotion binding \" .. tostring(gait and gait.clipName))");
		stringBuilder.AppendLine("            return");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("        if type(gait.sanAnimationPath) ~= \"string\" or gait.sanAnimationPath == \"\" then");
		stringBuilder.AppendLine("            SCO_IdleResetWarn(tpId, \"missing SCOM locomotion animation path\")");
		stringBuilder.AppendLine("            return");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("    local authoredSpeed = gait.authoredSpeed");
		stringBuilder.AppendLine("    if authoredSpeed == nil and tp.movement and tp.movement.walkAnimation then");
		stringBuilder.AppendLine("        authoredSpeed = tp.movement.walkAnimation.authoredSpeed");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if type(authoredSpeed) ~= \"number\" or authoredSpeed <= 0 then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(tpId, \"missing positive SCOM gait authored speed\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local startSpeed = gait.startSpeed");
		stringBuilder.AppendLine("    if startSpeed == nil then");
		stringBuilder.AppendLine("        startSpeed = 0.05");
		stringBuilder.AppendLine("    elseif type(startSpeed) ~= \"number\" or startSpeed <= 0 then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(tpId, \"invalid SCOM gait start speed\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("    local additions = tp.additions");
		stringBuilder.AppendLine("    if additions == nil then");
		stringBuilder.AppendLine("        additions = {}");
		stringBuilder.AppendLine("    elseif type(additions) ~= \"table\" then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(tpId, \"invalid additions table\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if additions.scoIdleResetLocomotion ~= nil");
		stringBuilder.AppendLine("        and additions.scoIdleResetLocomotion ~= true");
		stringBuilder.AppendLine("    then");
		stringBuilder.AppendLine("        SCO_IdleResetWarn(tpId, \"conflicting idle-reset marker\")");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("    if needsPromotion then");
		stringBuilder.AppendLine("        animations.run = gait");
		stringBuilder.AppendLine("        animations.walk = {");
		stringBuilder.AppendLine("            clipName = \"Rest\",");
		stringBuilder.AppendLine("            sanAnimationPath = gait.sanAnimationPath,");
		stringBuilder.AppendLine("        }");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    gait.authoredSpeed = authoredSpeed");
		stringBuilder.AppendLine("    gait.startSpeed = startSpeed");
		stringBuilder.AppendLine("    additions.scoIdleResetLocomotion = true");
		stringBuilder.AppendLine("    tp.additions = additions");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local SCO_IdleResetCreateUnitPrefab = CreateUnitPrefab");
		stringBuilder.AppendLine("function CreateUnitPrefab(tp)");
		stringBuilder.AppendLine("    SCO_IdleResetPrepareTemplate(tp)");
		stringBuilder.AppendLine("    return SCO_IdleResetCreateUnitPrefab(tp)");
		stringBuilder.AppendLine("end");
		return stringBuilder.ToString();
	}

	public static string BuildHostLuaAppendix()
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("-- Supreme Commander Overhaul locomotion death guard 1.1.0");
		stringBuilder.AppendLine("-- Quiesce imported weapons before stock muzzle deletion.");
		stringBuilder.AppendLine("-- SCOM aircraft crash momentum 1.0.0\n-- Native SimVelocity is the consecutive simulation-position delta / tick time.\nlocal function SCO_AircraftCrashIsAirborne(unit)\n    if unit.isAirborne == false or not (unit.tp and unit.tp.movement)\n        or not unit:HasTags(Tags.AIR) then return false end\n    if Tags.NAVAL and unit:HasTags(Tags.NAVAL) then return false end\n    if Tags.ORBITAL and unit:HasTags(Tags.ORBITAL) then return false end\n    return true\nend\n\nlocal function SCO_AircraftCrashFinite(value)\n    return type(value) == \"number\" and value == value\n        and value > -math.huge and value < math.huge\nend\n\nlocal function SCO_AircraftCrashReadPose(unit)\n    local result, position = Engine.GetGlobalEntityWorldPosition(unit.id)\n    if result ~= EngineErrorCode.Success or not position\n        or not SCO_AircraftCrashFinite(position.x)\n        or not SCO_AircraftCrashFinite(position.y)\n        or not SCO_AircraftCrashFinite(position.z) then return end\n    local tick = Engine.GetSimulationTick()\n    if not SCO_AircraftCrashFinite(tick) or tick < 0 or tick % 1 ~= 0 then return end\n    return position, tick\nend\n\nlocal function SCO_AircraftCrashRecordMotion(unit)\n    if unit.dead or unit.deleted or not SCO_AircraftCrashIsAirborne(unit) then\n        unit.scoAircraftCrashSamples = nil\n        return\n    end\n    local position, tick = SCO_AircraftCrashReadPose(unit)\n    if not position then return end\n    local sample = unit.scoAircraftCrashSamples\n    if sample and sample.tick == tick then return end\n    if not sample then\n        sample = {}\n        unit.scoAircraftCrashSamples = sample\n    end\n    if sample.tick == tick - 1 then\n        sample.previousTick, sample.previousX, sample.previousY, sample.previousZ =\n            sample.tick, sample.x, sample.y, sample.z\n    else\n        sample.previousTick, sample.previousX, sample.previousY, sample.previousZ = nil, nil, nil, nil\n    end\n    sample.tick, sample.x, sample.y, sample.z = tick, position.x, position.y, position.z\nend\n\nlocal function SCO_AircraftCrashCaptureVelocity(unit)\n    if unit.dead or unit.deleted or not SCO_AircraftCrashIsAirborne(unit) then return end\n    local dt = Constants.TickTimeStep\n    if not SCO_AircraftCrashFinite(dt) or dt <= 0 then return end\n    local position, tick = SCO_AircraftCrashReadPose(unit)\n    local sample = unit.scoAircraftCrashSamples\n    local x, y, z\n    if position and sample then\n        if sample.tick == tick - 1 then\n            x, y, z = sample.x, sample.y, sample.z\n        elseif sample.tick == tick and sample.previousTick == tick - 1 then\n            x, y, z = sample.previousX, sample.previousY, sample.previousZ\n        end\n    end\n    if x ~= nil then\n        local vx, vy, vz = (position.x - x) / dt, (position.y - y) / dt, (position.z - z) / dt\n        if SCO_AircraftCrashFinite(vx) and SCO_AircraftCrashFinite(vy)\n            and SCO_AircraftCrashFinite(vz) then\n            unit.scoAircraftCrashVelocity = EngineClasses.float3(vx, vy, vz)\n            return\n        end\n    end\n    -- No consecutive live pose: retain native signed horizontal travel, never nose yaw.\n    local speedResult, speedPerTick = Engine.GetMovementCurrentSpeed(unit.id)\n    local headingResult, headingDegrees = Engine.GetMovementHeadingDegrees(unit.id)\n    if speedResult == EngineErrorCode.Success and headingResult == EngineErrorCode.Success\n        and SCO_AircraftCrashFinite(speedPerTick) and SCO_AircraftCrashFinite(headingDegrees) then\n        local speed, heading = speedPerTick / dt, math.rad(headingDegrees)\n        unit.scoAircraftCrashVelocity = EngineClasses.float3(\n            math.sin(heading) * speed, 0, math.cos(heading) * speed)\n    end\nend\n\n-- These two flying engineer classes inherit the ground-only base wreck dispatch.\nlocal SCO_AircraftCrashPodSpawnWreckage = HostUnit.OnSpawnWreckage\nfunction HostUnit:OnSpawnWreckage(overkillRatio)\n    if (self.tpId == \"uea5002\" or self.tpId == \"uea5011\")\n        and SCO_AircraftCrashIsAirborne(self) then\n        return Import(\"host/props/wreckCrash.lua\").StartWreckCrash(self, overkillRatio, false)\n    end\n    return SCO_AircraftCrashPodSpawnWreckage(self, overkillRatio)\nend\n\nlocal SCO_IdleResetOnDestroy = HostUnit.OnDestroy\n");
		stringBuilder.AppendLine("function HostUnit:OnDestroy(destroyType)\n    SCO_AircraftCrashCaptureVelocity(self)\n");
		stringBuilder.AppendLine("    local delayedSourceDeath = self.tpId == \"ugl3001\" or self.tpId == \"uel3001\" or self.tpId == \"uel1002\" or self.tpId == \"uel3401\"");
		stringBuilder.AppendLine("    -- Imported death animations may retain the unit until their final frame.");
		stringBuilder.AppendLine("    for _, tag in ipairs(self.tp and self.tp.tags or {}) do");
		stringBuilder.AppendLine("        if tag == \"SCFA_ALLUNITS\" then delayedSourceDeath = true; break end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if delayedSourceDeath then");
		stringBuilder.AppendLine("        for _, weapon in ipairs(self.weapons or {}) do");
		stringBuilder.AppendLine("            if weapon:IsEnabled() then weapon:SetEnabled(false) end");
		stringBuilder.AppendLine("            weapon:SetAimTarget(nil)");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    local result = SCO_IdleResetOnDestroy(self, destroyType)");
		stringBuilder.AppendLine("    if delayedSourceDeath then self.weapons = {} end");
		stringBuilder.AppendLine("    return result");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("-- A stopped transition must not overwrite a delayed source death clip.");
		stringBuilder.AppendLine("local SCO_IdleResetUpdateAnimations = HostUnit.UpdateAnimations");
		stringBuilder.AppendLine("function HostUnit:UpdateAnimations()");
		stringBuilder.AppendLine("    SCO_AircraftCrashRecordMotion(self)\n    local additions = self.tp and self.tp.additions\n");
		stringBuilder.AppendLine("    if self.dead and additions and additions.scoIdleResetLocomotion then");
		stringBuilder.AppendLine("        return");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    if not (self.tp and self.tp.movement and self.tp.visuals and self.tp.visuals.animations and self.tp.visuals.animations.run) then return end\r\n    return SCO_IdleResetUpdateAnimations(self)");
		stringBuilder.AppendLine("end");
		return stringBuilder.ToString();
	}

	private static void ValidateUpstreamSource(string source)
	{
		RequireExactly(source, "function CreateUnitPrefab(tp)", 1, "unit-prefab loader function");
		ValidateLoaderAnimationContract(source);
	}

	private static void ValidatePatchedSource(string source)
	{
		ValidateUpstreamSourceWithoutFunctionCount(source);
		RequireExactly(source, "-- Supreme Commander Overhaul locomotion and weapon idle reset 1.3.0", 1, "idle-reset marker");
		RequireExactly(source, "function CreateUnitPrefab(tp)", 2, "stock and wrapped unit-prefab loaders");
		RequireExactly(source, "local SCO_IdleResetCreateUnitPrefab = CreateUnitPrefab", 1, "captured unit-prefab loader");
		RequireExactly(source, "animations.run = gait", 1, "locomotion promotion");
		RequireExactly(source, "clipName = \"Rest\"", 1, "stopped Rest binding");
		RequireExactly(source, "additions.scoIdleResetLocomotion = true", 1, "template death-guard marker");
		RequireExactly(source, "controllers[barrelIndex + 1].defaultPitchAdjustment = 0", 1, "Summit idle-pitch reset");
		RequireExactly(source, BuildTurretRestManifest(), 1, "exact turret-rest manifest");
		RequireExactly(source, "SCO_IdleResetPrepareTurretRest(tp, tpId)", 2, "turret-rest definition and dispatch");
		RequireExactly(source, "local function SCO_IdleResetFinalizeSourceTemplate(tp)", 1, "source-final turret-rest hook");
		RequireExactly(source, "    if SCO_SourceFinalizerOwnsIdleResetTurretRest ~= true then", 1, "standalone turret-rest fallback");
		RequireExactly(source, "        SCO_IdleResetFinalizeSourceTemplate(tp)", 1, "standalone turret-rest dispatch");
		RequireExactly(source, "change.controller.defaultPitchAdjustment = change.value", 1, "turret-rest assignment");
		RequireExactly(source, "SCO_IdleResetPrepareMonkeylordAim", 0, "retired split Monkeylord reset");
		RequireExactly(source, "additions.scoIdleResetAimPose = true", 2, "combined Monkeylord and Summit idle-reset markers");
		RequireExactly(source, "local monkeylordAlreadyReset = tpId == \"ugl4001\"", 1, "Monkeylord provenance owner");
		RequireExactly(source, "marked combined aim-reset reverted to source values", 1, "marked Monkeylord rollback guard");
		RequireExactly(source, "unmarked combined aim-reset already uses rest values", 1, "unmarked Monkeylord rest guard");
		RequireExactly(source, "animations[key].playbackMode = AnimationPlaybackMode.Clamp", 1, "delayed-death clamp assignment");
		RequireExactly(source, "[\"uel3001\"] = { death01 = \"AnimDeath01\", death02 = \"AnimDeath02\" }", 1, "Titan death-clip map");
		RequireExactly(source, "[\"ugl3001\"] = { death01 = \"AnimDeath01\", death02 = \"AnimDeath02\", death03 = \"AnimDeath03\" }", 1, "Brick death-clip map");
		WalkerGait[] walkerGaitEntries = WalkerGaitEntries;
		foreach (WalkerGait walkerGait in walkerGaitEntries)
		{
			RequireExactly(source, "[\"" + walkerGait.UnitId + "\"] = \"" + walkerGait.ClipName + "\"", 1, walkerGait.UnitId + " gait mapping");
		}
	}

	private static string BuildTurretRestManifest()
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("local SCO_IdleResetTurretRest = {");
		foreach (IGrouping<string, TurretRestAdjustment> item in from entry in TurretRestEntries
			group entry by entry.UnitId)
		{
			stringBuilder.Append("    [\"").Append(item.Key).AppendLine("\"] = {");
			foreach (IGrouping<int, TurretRestAdjustment> item2 in from entry in item
				group entry by entry.WeaponIndex)
			{
				stringBuilder.AppendLine(BuildTurretRestWeaponManifestLine(item2.Key, item2));
			}
			stringBuilder.AppendLine("    },");
		}
		return Normalize(stringBuilder.AppendLine("}").ToString());
	}

	private static string BuildTurretRestWeaponManifestLine(int weaponIndex, IEnumerable<TurretRestAdjustment> adjustments)
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.Append("        { weaponIndex = ").Append(weaponIndex).Append(", controllers = { ");
		foreach (TurretRestAdjustment adjustment in adjustments)
		{
			stringBuilder.Append("{ aimBone = \"").Append(adjustment.ExpectedAimBone).Append("\", yawBone = \"")
				.Append(adjustment.ExpectedYawBone)
				.Append("\", pitchBone = \"")
				.Append(adjustment.ExpectedPitchBone)
				.Append("\", expected = ")
				.Append(FormatLuaNumber(adjustment.ExpectedDefaultPitch))
				.Append(", rest = ")
				.Append(FormatLuaNumber(adjustment.RestDefaultPitch))
				.Append(" }, ");
		}
		return stringBuilder.Append("} },").ToString();
	}

	private static void ValidateUpstreamSourceWithoutFunctionCount(string source)
	{
		ValidateLoaderAnimationContract(source);
	}

	private static void ValidateLoaderAnimationContract(string source)
	{
		RequireContains(source, "if tp.visuals.animations then", "EngineClasses.AnimationClipTemplate(");
		bool num = source.IndexOf("tp.visuals.animations.walk.sanAnimationPath", StringComparison.Ordinal) >= 0;
		bool flag = source.IndexOf("local defaultAnimation = tp.visuals.animations.rest\n            or tp.visuals.animations.walk", StringComparison.Ordinal) >= 0 && source.IndexOf("defaultAnimation.sanAnimationPath", StringComparison.Ordinal) >= 0;
		if (num == flag)
		{
			throw new InvalidOperationException("Unit-template loader must expose exactly one supported default-animation shape.");
		}
	}

	private static void ValidateUpstreamHostSource(string source)
	{
		RequireExactly(source, "function HostUnit:UpdateAnimations()", 1, "stock host animation updater");
		RequireContains(source, "Engine.GetMovementCurrentSpeed(self.id)", "function HostUnit:OnDestroy(destroyType)", "self.dead = true", "if not self.isWalking and self.tp.visuals.animations.run then", "if self.isWalking and self.tp.visuals.animations.run then");
	}

	private static void ValidatePatchedHostSource(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul locomotion death guard 1.1.0", 1, "death-guard marker");
		RequireExactly(source, "function HostUnit:OnDestroy(destroyType)", 2, "stock and delayed-death host destroy handlers");
		RequireExactly(source, "local SCO_IdleResetOnDestroy = HostUnit.OnDestroy", 1, "captured host destroy handler");
		RequireExactly(source, "local delayedSourceDeath = self.tpId == \"ugl3001\" or self.tpId == \"uel3001\" or self.tpId == \"uel1002\" or self.tpId == \"uel3401\"", 1, "Brick/Titan/Mech Marine/Percival delayed-death scope");
		RequireExactly(source, "if tag == \"SCFA_ALLUNITS\" then delayedSourceDeath = true; break end", 1, "imported unit death cleanup scope");
		RequireExactly(source, "if weapon:IsEnabled() then weapon:SetEnabled(false) end", 1, "pre-delete weapon disable");
		RequireExactly(source, "weapon:SetAimTarget(nil)", 1, "pre-delete aim clear");
		RequireExactly(source, "if delayedSourceDeath then self.weapons = {} end", 1, "post-delete weapon-list clear");
		RequireExactly(source, "function HostUnit:UpdateAnimations()", 2, "stock and death-guard host animation updaters");
		RequireExactly(source, "local SCO_IdleResetUpdateAnimations = HostUnit.UpdateAnimations", 1, "captured host animation updater");
		RequireExactly(source, "if self.dead and additions and additions.scoIdleResetLocomotion then", 1, "targeted death guard");
		RequireContains(source, "Engine.GetMovementCurrentSpeed(self.id)", "function HostUnit:OnDestroy(destroyType)", "self.dead = true", "if not self.isWalking and self.tp.visuals.animations.run then", "if self.isWalking and self.tp.visuals.animations.run then");
	}

	private static void RequireContains(string source, params string[] tokens)
	{
		foreach (string text in tokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Unit-template loader is missing required token: " + text);
			}
		}
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = Count(source, token);
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {description}, found {num}.");
		}
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

	private static string FormatLuaNumber(double value)
	{
		return StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture);
	}

	private static string Normalize(string source)
	{
		return source.Replace("\r\n", "\n").Replace("\r", "\n");
	}
}
