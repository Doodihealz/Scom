using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;

namespace SupremeCommanderOverhaulMonkeylordFix;

public static class CachePatcherRuntime
{
	private sealed class PendingPatch
	{
		public CacheResource Resource { get; }

		public string Source { get; }

		public string PatchedSource { get; }

		public object? Replacement { get; set; }

		public bool Changed => !string.Equals(Source, PatchedSource, StringComparison.Ordinal);

		public PendingPatch(CacheResource resource, string source, string patchedSource)
		{
			Resource = resource;
			Source = source;
			PatchedSource = patchedSource;
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

	private const string TemplatePath = "LJ/lua/common/units/unitsTemplates/ugl4001/ugl4001.santp";

	private const string HostWeaponPath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string ScomMarker = "-- Guard Cybran Monkeylord Cache Patcher 1.4.0";

	private const string Marker = "-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0";

	private const string HostWeaponMarker = "-- Supreme Commander Overhaul Monkeylord collider aim fix 1.3.0";

	private const string OldSlider = "sliderGoal = -1,";

	private const string HostWeaponAppendix = "\n\n-- Supreme Commander Overhaul Monkeylord collider aim fix 1.3.0\nlocal SCOM_MonkeylordPreviousGetRandomTargetBoneID =\n    HostWeapon.GetRandomTargetBoneID\n\nfunction HostWeapon:GetRandomTargetBoneID(targetUnit)\n    if self.tp and self.tp.scomAimAtTargetCollider then\n        local targetCollider = targetUnit and targetUnit.targetCollider\n        local targetColliderID = targetCollider and targetCollider.id\n        if targetColliderID and Engine.IsValidGlobalID(targetColliderID) then\n            return targetColliderID\n        end\n    end\n    return SCOM_MonkeylordPreviousGetRandomTargetBoneID(self, targetUnit)\nend";

	private const string Appendix = "\n\n-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0\ndo\n    if not UnitTemplate.general or UnitTemplate.general.tpId ~= \"ugl4001\" then\n        error(\"Monkeylord fix expected ugl4001.\")\n    end\n    local weapon = UnitTemplate.weapons and UnitTemplate.weapons[1]\n    if not weapon or not weapon.scoMonkeylordMicrowave then\n        error(\"Monkeylord microwave weapon contract is missing.\")\n    end\n\n    if UnitTemplate.visuals.effectsPersistent ~= nil then\n        error(\"Monkeylord expected the SCOM exhaust mapping to be cleared.\")\n    end\n\n    -- The local derivative keeps one Guard burst/spark/smoke plume and removes\n    -- its donor-level position. Each instance now inherits the authored\n    -- URL0402 exhaust socket's exact position and rotation.\n    local monkeylordExhaustParticle =\n        \"VFX/SupremeCommanderOverhaul/Monkeylord/monkeylord_exhaust_socket.sanvfx\"\n    UnitTemplate.visuals.effectsPersistent = {\n        {\n            boneName = \"Exhaust01\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust02\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust03\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust05\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust06\",\n            particleName = monkeylordExhaustParticle,\n        },\n    }\n\n    -- The 1.4 experiment translated and spun Center_Turret_Barrel even though\n    -- it owns visible mesh vertices and the real muzzle is its sibling. Drop\n    -- that experiment so the scoped HostBeam/ClientBeam wrappers use stock.\n    UnitTemplate.additions.rotators = nil\n    weapon.scoMonkeylordMicrowave = nil\n    weapon.scoAboveWaterFireOnly = nil\n    weapon.scoAboveWaterTargetsOnly = nil\n    weapon.scoMonkeylordWaterGate = nil\n\n    -- Restore the reviewed Sanctuary primary-laser simulation and renderer.\n    -- Only its aim/muzzle bones change to the imported URL0402 rig.\n    weapon.audio = {\n        onFire = {\n            looping = true,\n            name = \"aglm5140\",\n        },\n    }\n    weapon.beam = {\n        cullDistance = 500,\n        fadeInTime = 1,\n        fadeOutTime = 2,\n        subMesh = {\n            {\n                material = \"VFX/Materials/Beam/Beam ugl4001_01.sanmaterial\",\n                model = \"VFX/Models/Beams/BeamBasicLongSingle.sanmodel\",\n            },\n            {\n                material = \"VFX/Materials/Beam/Beam ugl4001_02.sanmaterial\",\n                model = \"VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel\",\n            },\n        },\n    }\n    weapon.beamLifetime = -1\n    weapon.damage = 50\n    weapon.damageFriendly = nil\n    weapon.damageRadius = 1\n    weapon.damageType = \"Normal\"\n    weapon.effects = {\n        onFire = \"VFX/Muzzle/vgm7401_beam_plasma_huge_muzzle_loop.sanvfx\",\n    }\n    weapon.layerTargetLimits = { \"Land\", \"WaterSurface\" }\n    weapon.layerWeaponLimits = { \"Land\" }\n    weapon.projectileLifetime = 2\n    weapon.projectileTemplate = \"pgd471\"\n    weapon.rangeMax = 30\n    weapon.rangeMin = 4\n    weapon.rangeTracking = 1.1\n    weapon.reloadTime = 2\n    weapon.targetWaterLimits = \"Above\"\n    -- Sanctuary normally chooses a random target bone. Several legal bones\n    -- sit outside a unit's collision box, so a continuous ray can pass over\n    -- the collider and render to maximum range. Aim this beam at the target's\n    -- TargetCollider entity, which is located at collisionInfo.centerOffset.\n    weapon.scomAimAtTargetCollider = true\n    weapon.aimControllers = {\n        {\n            aimBone = \"Center_Turret_Muzzle\",\n            aimTolerance = 2,\n            defaultPitchAdjustment = -20,\n            defaultYawAdjustment = 0,\n            leadTarget = false,\n            pitchBone = \"Center_Turret\",\n            pitchMax = 70,\n            pitchMin = -110,\n            pitchSpeed = 20,\n            poseResetTime = 3,\n            projectileSpeed = 30,\n            solverType = \"NoArc\",\n            -- Sanctuary requires distinct yaw and pitch bones; otherwise it\n            -- silently drops pitch. Use the verified parent-yaw/child-pitch\n            -- chain while retaining the authentic muzzle endpoint.\n            yawBone = \"Center_Turret_B01\",\n            yawMax = 180,\n            yawMin = -180,\n            yawSpeed = 40,\n        },\n    }\n    weapon.muzzleGroups = {\n        {\n            muzzles = {\n                \"Center_Turret_Muzzle\",\n                \"Center_Turret_Muzzle_Dual\",\n            },\n        },\n    }\n    weapon.muzzles = {\n        [\"Center_Turret_Muzzle\"] = {\n            aimController = \"Center_Turret_Muzzle\",\n        },\n        [\"Center_Turret_Muzzle_Dual\"] = {\n            aimController = \"Center_Turret_Muzzle\",\n        },\n    }\n\n    -- Restore the source 64-unit reach of both ground bolters independently of\n    -- the 30-unit microwave laser. AA and torpedo ranges remain untouched.\n    local function requireBolter(index, muzzle)\n        local bolter = UnitTemplate.weapons[index]\n        local controller = bolter\n            and bolter.aimControllers\n            and bolter.aimControllers[1]\n        local muzzleGroup = bolter\n            and bolter.muzzleGroups\n            and bolter.muzzleGroups[1]\n        local muzzleMap = bolter\n            and bolter.muzzles\n            and bolter.muzzles[muzzle]\n        if not bolter\n            or bolter.projectileTemplate ~= \"pgr402b\"\n            or bolter.rangeMax ~= 64\n            or not controller\n            or controller.aimBone ~= muzzle\n            or not muzzleGroup\n            or not muzzleGroup.muzzles\n            or muzzleGroup.muzzles[1] ~= muzzle\n            or muzzleGroup.muzzles[2] ~= nil\n            or not muzzleMap\n            or muzzleMap.aimController ~= muzzle\n        then\n            error(\"Monkeylord bolter contract drifted at weapon \" .. index)\n        end\n        return bolter\n    end\n\n    local rightBolter = requireBolter(2, \"Right_Turret_Muzzle\")\n    local leftBolter = requireBolter(3, \"Left_Turret_Muzzle\")\n    rightBolter.rangeMax = 64\n    rightBolter.rangeMin = 0\n    leftBolter.rangeMax = 64\n    leftBolter.rangeMin = 0\n\n    local torpedo = UnitTemplate.weapons[6]\n    if not torpedo\n        or torpedo.projectileTemplate ~= \"pgr402t\"\n        or torpedo.rangeMax ~= 45\n        or torpedo.rangeMin ~= 0\n        or torpedo.rangeRingType ~= \"AntiNavy\"\n    then\n        error(\"Monkeylord torpedo range-ring contract drifted.\")\n    end\n\n    -- Sanctuary calls this material AntiNaval. AntiNavy maps to the\n    -- 65535 None sentinel, which its Burst range renderer cannot index.\n    torpedo.rangeRingType = \"AntiNaval\"\n\n    local validRangeRingTypes = {\n        Engineering = true,\n        AntiAir = true,\n        AntiNaval = true,\n        AttackCounter = true,\n        DirectFire = true,\n        IndirectFire = true,\n        IntelCounter = true,\n        IntelOmni = true,\n        Radar = true,\n        Sonar = true,\n        FogOfWar = true,\n        Vision = true,\n        WaterVision = true,\n    }\n    for index, candidate in ipairs(UnitTemplate.weapons) do\n        local rangeRingType = candidate.rangeRingType\n        if rangeRingType ~= nil and not validRangeRingTypes[rangeRingType] then\n            error(\"Monkeylord invalid range-ring type at weapon \" .. index)\n        end\n    end\nend";

	private static bool _applied;

	public static void Apply()
	{
		if (_applied)
		{
			return;
		}
		object luaFileCache = GetLuaFileCache();
		try
		{
			CacheResource cachedResource = GetCachedResource(luaFileCache, "LJ/lua/common/units/unitsTemplates/ugl4001/ugl4001.santp");
			CacheResource cachedResource2 = GetCachedResource(luaFileCache, "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua");
			PendingPatch[] array = new PendingPatch[2]
			{
				CreatePendingPatch(cachedResource, PatchTemplateSource),
				CreatePendingPatch(cachedResource2, PatchHostWeaponSource)
			}.Where((PendingPatch patch) => patch.Changed).ToArray();
			if (array.Length == 0)
			{
				_applied = true;
				Log("Monkeylord comprehensive fix already applied.");
				return;
			}
			PendingPatch[] array2 = array;
			PendingPatch[] array3;
			try
			{
				array3 = array2;
				foreach (PendingPatch pendingPatch in array3)
				{
					pendingPatch.Replacement = CreateNativeArrayFromText(pendingPatch.Resource.Value.GetType(), pendingPatch.PatchedSource);
				}
			}
			catch
			{
				array3 = array2;
				foreach (PendingPatch pendingPatch2 in array3)
				{
					if (pendingPatch2.Replacement != null)
					{
						TryDisposeNativeArray(pendingPatch2.Replacement.GetType(), pendingPatch2.Replacement);
					}
				}
				throw;
			}
			List<PendingPatch> list = new List<PendingPatch>();
			try
			{
				array2 = array;
				array3 = array2;
				foreach (PendingPatch pendingPatch3 in array3)
				{
					list.Add(pendingPatch3);
					SetCachedResource(luaFileCache, pendingPatch3.Resource.Path, pendingPatch3.Replacement);
					VerifyCachedResource(luaFileCache, pendingPatch3.Resource.Path, pendingPatch3.PatchedSource, "Published");
				}
			}
			catch (Exception ex)
			{
				List<Exception> list2 = new List<Exception>();
				HashSet<PendingPatch> hashSet = new HashSet<PendingPatch>();
				for (int num2 = list.Count - 1; num2 >= 0; num2--)
				{
					PendingPatch pendingPatch4 = list[num2];
					try
					{
						SetCachedResource(luaFileCache, pendingPatch4.Resource.Path, pendingPatch4.Resource.Value);
						VerifyCachedResource(luaFileCache, pendingPatch4.Resource.Path, pendingPatch4.Source, "Rolled-back");
						hashSet.Add(pendingPatch4);
					}
					catch (Exception innerException)
					{
						list2.Add(new InvalidOperationException("Failed to roll back " + pendingPatch4.Resource.Path + ".", innerException));
					}
				}
				array2 = array;
				array3 = array2;
				foreach (PendingPatch pendingPatch5 in array3)
				{
					if (pendingPatch5.Replacement != null && (!list.Contains(pendingPatch5) || hashSet.Contains(pendingPatch5)))
					{
						TryDisposeNativeArray(pendingPatch5.Replacement.GetType(), pendingPatch5.Replacement);
					}
				}
				if (list2.Count != 0)
				{
					throw new AggregateException("Monkeylord cache transaction failed and rollback was incomplete.", new Exception[1] { ex }.Concat(list2));
				}
				throw;
			}
			array2 = array;
			array3 = array2;
			foreach (PendingPatch pendingPatch6 in array3)
			{
				TryDisposeNativeArray(pendingPatch6.Resource.Value.GetType(), pendingPatch6.Resource.Value);
			}
			_applied = true;
			Log("Applied Monkeylord collider-center laser, distinct yaw/pitch aim, five socket-bound Guard exhaust plumes, 30-range land weapons, and a safe AntiNaval torpedo range ring.");
		}
		catch (InvalidOperationException ex2)
		{
			_applied = true;
			Log("Skipped Monkeylord fix; incompatible cached source: " + ex2.Message);
		}
		catch (FileNotFoundException ex3)
		{
			_applied = true;
			Log("Skipped Monkeylord fix; required cache resource unavailable: " + ex3.Message);
		}
	}

	private static PendingPatch CreatePendingPatch(CacheResource resource, Func<string, string> transform)
	{
		string resourceText = GetResourceText(resource.Value);
		return new PendingPatch(resource, resourceText, transform(resourceText));
	}

	public static string PatchTemplateSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = source.Replace("\r\n", "\n").Replace("\r", "\n");
		int num = Count(text, "-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0");
		switch (num)
		{
		case 1:
			Require(text, "\n\n-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0\ndo\n    if not UnitTemplate.general or UnitTemplate.general.tpId ~= \"ugl4001\" then\n        error(\"Monkeylord fix expected ugl4001.\")\n    end\n    local weapon = UnitTemplate.weapons and UnitTemplate.weapons[1]\n    if not weapon or not weapon.scoMonkeylordMicrowave then\n        error(\"Monkeylord microwave weapon contract is missing.\")\n    end\n\n    if UnitTemplate.visuals.effectsPersistent ~= nil then\n        error(\"Monkeylord expected the SCOM exhaust mapping to be cleared.\")\n    end\n\n    -- The local derivative keeps one Guard burst/spark/smoke plume and removes\n    -- its donor-level position. Each instance now inherits the authored\n    -- URL0402 exhaust socket's exact position and rotation.\n    local monkeylordExhaustParticle =\n        \"VFX/SupremeCommanderOverhaul/Monkeylord/monkeylord_exhaust_socket.sanvfx\"\n    UnitTemplate.visuals.effectsPersistent = {\n        {\n            boneName = \"Exhaust01\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust02\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust03\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust05\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust06\",\n            particleName = monkeylordExhaustParticle,\n        },\n    }\n\n    -- The 1.4 experiment translated and spun Center_Turret_Barrel even though\n    -- it owns visible mesh vertices and the real muzzle is its sibling. Drop\n    -- that experiment so the scoped HostBeam/ClientBeam wrappers use stock.\n    UnitTemplate.additions.rotators = nil\n    weapon.scoMonkeylordMicrowave = nil\n    weapon.scoAboveWaterFireOnly = nil\n    weapon.scoAboveWaterTargetsOnly = nil\n    weapon.scoMonkeylordWaterGate = nil\n\n    -- Restore the reviewed Sanctuary primary-laser simulation and renderer.\n    -- Only its aim/muzzle bones change to the imported URL0402 rig.\n    weapon.audio = {\n        onFire = {\n            looping = true,\n            name = \"aglm5140\",\n        },\n    }\n    weapon.beam = {\n        cullDistance = 500,\n        fadeInTime = 1,\n        fadeOutTime = 2,\n        subMesh = {\n            {\n                material = \"VFX/Materials/Beam/Beam ugl4001_01.sanmaterial\",\n                model = \"VFX/Models/Beams/BeamBasicLongSingle.sanmodel\",\n            },\n            {\n                material = \"VFX/Materials/Beam/Beam ugl4001_02.sanmaterial\",\n                model = \"VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel\",\n            },\n        },\n    }\n    weapon.beamLifetime = -1\n    weapon.damage = 50\n    weapon.damageFriendly = nil\n    weapon.damageRadius = 1\n    weapon.damageType = \"Normal\"\n    weapon.effects = {\n        onFire = \"VFX/Muzzle/vgm7401_beam_plasma_huge_muzzle_loop.sanvfx\",\n    }\n    weapon.layerTargetLimits = { \"Land\", \"WaterSurface\" }\n    weapon.layerWeaponLimits = { \"Land\" }\n    weapon.projectileLifetime = 2\n    weapon.projectileTemplate = \"pgd471\"\n    weapon.rangeMax = 30\n    weapon.rangeMin = 4\n    weapon.rangeTracking = 1.1\n    weapon.reloadTime = 2\n    weapon.targetWaterLimits = \"Above\"\n    -- Sanctuary normally chooses a random target bone. Several legal bones\n    -- sit outside a unit's collision box, so a continuous ray can pass over\n    -- the collider and render to maximum range. Aim this beam at the target's\n    -- TargetCollider entity, which is located at collisionInfo.centerOffset.\n    weapon.scomAimAtTargetCollider = true\n    weapon.aimControllers = {\n        {\n            aimBone = \"Center_Turret_Muzzle\",\n            aimTolerance = 2,\n            defaultPitchAdjustment = -20,\n            defaultYawAdjustment = 0,\n            leadTarget = false,\n            pitchBone = \"Center_Turret\",\n            pitchMax = 70,\n            pitchMin = -110,\n            pitchSpeed = 20,\n            poseResetTime = 3,\n            projectileSpeed = 30,\n            solverType = \"NoArc\",\n            -- Sanctuary requires distinct yaw and pitch bones; otherwise it\n            -- silently drops pitch. Use the verified parent-yaw/child-pitch\n            -- chain while retaining the authentic muzzle endpoint.\n            yawBone = \"Center_Turret_B01\",\n            yawMax = 180,\n            yawMin = -180,\n            yawSpeed = 40,\n        },\n    }\n    weapon.muzzleGroups = {\n        {\n            muzzles = {\n                \"Center_Turret_Muzzle\",\n                \"Center_Turret_Muzzle_Dual\",\n            },\n        },\n    }\n    weapon.muzzles = {\n        [\"Center_Turret_Muzzle\"] = {\n            aimController = \"Center_Turret_Muzzle\",\n        },\n        [\"Center_Turret_Muzzle_Dual\"] = {\n            aimController = \"Center_Turret_Muzzle\",\n        },\n    }\n\n    -- Restore the source 64-unit reach of both ground bolters independently of\n    -- the 30-unit microwave laser. AA and torpedo ranges remain untouched.\n    local function requireBolter(index, muzzle)\n        local bolter = UnitTemplate.weapons[index]\n        local controller = bolter\n            and bolter.aimControllers\n            and bolter.aimControllers[1]\n        local muzzleGroup = bolter\n            and bolter.muzzleGroups\n            and bolter.muzzleGroups[1]\n        local muzzleMap = bolter\n            and bolter.muzzles\n            and bolter.muzzles[muzzle]\n        if not bolter\n            or bolter.projectileTemplate ~= \"pgr402b\"\n            or bolter.rangeMax ~= 64\n            or not controller\n            or controller.aimBone ~= muzzle\n            or not muzzleGroup\n            or not muzzleGroup.muzzles\n            or muzzleGroup.muzzles[1] ~= muzzle\n            or muzzleGroup.muzzles[2] ~= nil\n            or not muzzleMap\n            or muzzleMap.aimController ~= muzzle\n        then\n            error(\"Monkeylord bolter contract drifted at weapon \" .. index)\n        end\n        return bolter\n    end\n\n    local rightBolter = requireBolter(2, \"Right_Turret_Muzzle\")\n    local leftBolter = requireBolter(3, \"Left_Turret_Muzzle\")\n    rightBolter.rangeMax = 64\n    rightBolter.rangeMin = 0\n    leftBolter.rangeMax = 64\n    leftBolter.rangeMin = 0\n\n    local torpedo = UnitTemplate.weapons[6]\n    if not torpedo\n        or torpedo.projectileTemplate ~= \"pgr402t\"\n        or torpedo.rangeMax ~= 45\n        or torpedo.rangeMin ~= 0\n        or torpedo.rangeRingType ~= \"AntiNavy\"\n    then\n        error(\"Monkeylord torpedo range-ring contract drifted.\")\n    end\n\n    -- Sanctuary calls this material AntiNaval. AntiNavy maps to the\n    -- 65535 None sentinel, which its Burst range renderer cannot index.\n    torpedo.rangeRingType = \"AntiNaval\"\n\n    local validRangeRingTypes = {\n        Engineering = true,\n        AntiAir = true,\n        AntiNaval = true,\n        AttackCounter = true,\n        DirectFire = true,\n        IndirectFire = true,\n        IntelCounter = true,\n        IntelOmni = true,\n        Radar = true,\n        Sonar = true,\n        FogOfWar = true,\n        Vision = true,\n        WaterVision = true,\n    }\n    for index, candidate in ipairs(UnitTemplate.weapons) do\n        local rangeRingType = candidate.rangeRingType\n        if rangeRingType ~= nil and not validRangeRingTypes[rangeRingType] then\n            error(\"Monkeylord invalid range-ring type at weapon \" .. index)\n        end\n    end\nend", 1, "complete fix appendix");
			if (!text.TrimEnd(Array.Empty<char>()).EndsWith("\n\n-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0\ndo\n    if not UnitTemplate.general or UnitTemplate.general.tpId ~= \"ugl4001\" then\n        error(\"Monkeylord fix expected ugl4001.\")\n    end\n    local weapon = UnitTemplate.weapons and UnitTemplate.weapons[1]\n    if not weapon or not weapon.scoMonkeylordMicrowave then\n        error(\"Monkeylord microwave weapon contract is missing.\")\n    end\n\n    if UnitTemplate.visuals.effectsPersistent ~= nil then\n        error(\"Monkeylord expected the SCOM exhaust mapping to be cleared.\")\n    end\n\n    -- The local derivative keeps one Guard burst/spark/smoke plume and removes\n    -- its donor-level position. Each instance now inherits the authored\n    -- URL0402 exhaust socket's exact position and rotation.\n    local monkeylordExhaustParticle =\n        \"VFX/SupremeCommanderOverhaul/Monkeylord/monkeylord_exhaust_socket.sanvfx\"\n    UnitTemplate.visuals.effectsPersistent = {\n        {\n            boneName = \"Exhaust01\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust02\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust03\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust05\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust06\",\n            particleName = monkeylordExhaustParticle,\n        },\n    }\n\n    -- The 1.4 experiment translated and spun Center_Turret_Barrel even though\n    -- it owns visible mesh vertices and the real muzzle is its sibling. Drop\n    -- that experiment so the scoped HostBeam/ClientBeam wrappers use stock.\n    UnitTemplate.additions.rotators = nil\n    weapon.scoMonkeylordMicrowave = nil\n    weapon.scoAboveWaterFireOnly = nil\n    weapon.scoAboveWaterTargetsOnly = nil\n    weapon.scoMonkeylordWaterGate = nil\n\n    -- Restore the reviewed Sanctuary primary-laser simulation and renderer.\n    -- Only its aim/muzzle bones change to the imported URL0402 rig.\n    weapon.audio = {\n        onFire = {\n            looping = true,\n            name = \"aglm5140\",\n        },\n    }\n    weapon.beam = {\n        cullDistance = 500,\n        fadeInTime = 1,\n        fadeOutTime = 2,\n        subMesh = {\n            {\n                material = \"VFX/Materials/Beam/Beam ugl4001_01.sanmaterial\",\n                model = \"VFX/Models/Beams/BeamBasicLongSingle.sanmodel\",\n            },\n            {\n                material = \"VFX/Materials/Beam/Beam ugl4001_02.sanmaterial\",\n                model = \"VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel\",\n            },\n        },\n    }\n    weapon.beamLifetime = -1\n    weapon.damage = 50\n    weapon.damageFriendly = nil\n    weapon.damageRadius = 1\n    weapon.damageType = \"Normal\"\n    weapon.effects = {\n        onFire = \"VFX/Muzzle/vgm7401_beam_plasma_huge_muzzle_loop.sanvfx\",\n    }\n    weapon.layerTargetLimits = { \"Land\", \"WaterSurface\" }\n    weapon.layerWeaponLimits = { \"Land\" }\n    weapon.projectileLifetime = 2\n    weapon.projectileTemplate = \"pgd471\"\n    weapon.rangeMax = 30\n    weapon.rangeMin = 4\n    weapon.rangeTracking = 1.1\n    weapon.reloadTime = 2\n    weapon.targetWaterLimits = \"Above\"\n    -- Sanctuary normally chooses a random target bone. Several legal bones\n    -- sit outside a unit's collision box, so a continuous ray can pass over\n    -- the collider and render to maximum range. Aim this beam at the target's\n    -- TargetCollider entity, which is located at collisionInfo.centerOffset.\n    weapon.scomAimAtTargetCollider = true\n    weapon.aimControllers = {\n        {\n            aimBone = \"Center_Turret_Muzzle\",\n            aimTolerance = 2,\n            defaultPitchAdjustment = -20,\n            defaultYawAdjustment = 0,\n            leadTarget = false,\n            pitchBone = \"Center_Turret\",\n            pitchMax = 70,\n            pitchMin = -110,\n            pitchSpeed = 20,\n            poseResetTime = 3,\n            projectileSpeed = 30,\n            solverType = \"NoArc\",\n            -- Sanctuary requires distinct yaw and pitch bones; otherwise it\n            -- silently drops pitch. Use the verified parent-yaw/child-pitch\n            -- chain while retaining the authentic muzzle endpoint.\n            yawBone = \"Center_Turret_B01\",\n            yawMax = 180,\n            yawMin = -180,\n            yawSpeed = 40,\n        },\n    }\n    weapon.muzzleGroups = {\n        {\n            muzzles = {\n                \"Center_Turret_Muzzle\",\n                \"Center_Turret_Muzzle_Dual\",\n            },\n        },\n    }\n    weapon.muzzles = {\n        [\"Center_Turret_Muzzle\"] = {\n            aimController = \"Center_Turret_Muzzle\",\n        },\n        [\"Center_Turret_Muzzle_Dual\"] = {\n            aimController = \"Center_Turret_Muzzle\",\n        },\n    }\n\n    -- Restore the source 64-unit reach of both ground bolters independently of\n    -- the 30-unit microwave laser. AA and torpedo ranges remain untouched.\n    local function requireBolter(index, muzzle)\n        local bolter = UnitTemplate.weapons[index]\n        local controller = bolter\n            and bolter.aimControllers\n            and bolter.aimControllers[1]\n        local muzzleGroup = bolter\n            and bolter.muzzleGroups\n            and bolter.muzzleGroups[1]\n        local muzzleMap = bolter\n            and bolter.muzzles\n            and bolter.muzzles[muzzle]\n        if not bolter\n            or bolter.projectileTemplate ~= \"pgr402b\"\n            or bolter.rangeMax ~= 64\n            or not controller\n            or controller.aimBone ~= muzzle\n            or not muzzleGroup\n            or not muzzleGroup.muzzles\n            or muzzleGroup.muzzles[1] ~= muzzle\n            or muzzleGroup.muzzles[2] ~= nil\n            or not muzzleMap\n            or muzzleMap.aimController ~= muzzle\n        then\n            error(\"Monkeylord bolter contract drifted at weapon \" .. index)\n        end\n        return bolter\n    end\n\n    local rightBolter = requireBolter(2, \"Right_Turret_Muzzle\")\n    local leftBolter = requireBolter(3, \"Left_Turret_Muzzle\")\n    rightBolter.rangeMax = 64\n    rightBolter.rangeMin = 0\n    leftBolter.rangeMax = 64\n    leftBolter.rangeMin = 0\n\n    local torpedo = UnitTemplate.weapons[6]\n    if not torpedo\n        or torpedo.projectileTemplate ~= \"pgr402t\"\n        or torpedo.rangeMax ~= 45\n        or torpedo.rangeMin ~= 0\n        or torpedo.rangeRingType ~= \"AntiNavy\"\n    then\n        error(\"Monkeylord torpedo range-ring contract drifted.\")\n    end\n\n    -- Sanctuary calls this material AntiNaval. AntiNavy maps to the\n    -- 65535 None sentinel, which its Burst range renderer cannot index.\n    torpedo.rangeRingType = \"AntiNaval\"\n\n    local validRangeRingTypes = {\n        Engineering = true,\n        AntiAir = true,\n        AntiNaval = true,\n        AttackCounter = true,\n        DirectFire = true,\n        IndirectFire = true,\n        IntelCounter = true,\n        IntelOmni = true,\n        Radar = true,\n        Sonar = true,\n        FogOfWar = true,\n        Vision = true,\n        WaterVision = true,\n    }\n    for index, candidate in ipairs(UnitTemplate.weapons) do\n        local rangeRingType = candidate.rangeRingType\n        if rangeRingType ~= nil and not validRangeRingTypes[rangeRingType] then\n            error(\"Monkeylord invalid range-ring type at weapon \" .. index)\n        end\n    end\nend", StringComparison.Ordinal))
			{
				throw new InvalidOperationException("Fix appendix is not the template tail.");
			}
			return text;
		default:
			throw new InvalidOperationException($"Expected zero or one fix markers, found {num}.");
		case 0:
		{
			Require(text, "-- Guard Cybran Monkeylord Cache Patcher 1.4.0", 1, "SCOM Monkeylord marker");
			Require(text, "tpId = \"ugl4001\"", 1, "ugl4001 tpId");
			Require(text.Substring(text.IndexOf("-- Guard Cybran Monkeylord Cache Patcher 1.4.0", StringComparison.Ordinal)), "sliderGoal = -1,", 1, "unscaled source slider goal");
			Require(text.Substring(text.IndexOf("-- Guard Cybran Monkeylord Cache Patcher 1.4.0", StringComparison.Ordinal)), "scoMonkeylordMicrowave = {", 1, "microwave configuration");
			Require(text.Substring(text.IndexOf("-- Guard Cybran Monkeylord Cache Patcher 1.4.0", StringComparison.Ordinal)), "\"Center_Turret_Muzzle\"", 4, "central muzzle references");
			Require(text.Substring(text.IndexOf("-- Guard Cybran Monkeylord Cache Patcher 1.4.0", StringComparison.Ordinal)), "defaultPitchAdjustment = -20,", 1, "source pitch center");
			Require(text.Substring(text.IndexOf("-- Guard Cybran Monkeylord Cache Patcher 1.4.0", StringComparison.Ordinal)), "pitchMax = 70,", 1, "source maximum pitch");
			Require(text.Substring(text.IndexOf("-- Guard Cybran Monkeylord Cache Patcher 1.4.0", StringComparison.Ordinal)), "pitchMin = -110,", 1, "source minimum pitch");
			string text2 = text.TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0\ndo\n    if not UnitTemplate.general or UnitTemplate.general.tpId ~= \"ugl4001\" then\n        error(\"Monkeylord fix expected ugl4001.\")\n    end\n    local weapon = UnitTemplate.weapons and UnitTemplate.weapons[1]\n    if not weapon or not weapon.scoMonkeylordMicrowave then\n        error(\"Monkeylord microwave weapon contract is missing.\")\n    end\n\n    if UnitTemplate.visuals.effectsPersistent ~= nil then\n        error(\"Monkeylord expected the SCOM exhaust mapping to be cleared.\")\n    end\n\n    -- The local derivative keeps one Guard burst/spark/smoke plume and removes\n    -- its donor-level position. Each instance now inherits the authored\n    -- URL0402 exhaust socket's exact position and rotation.\n    local monkeylordExhaustParticle =\n        \"VFX/SupremeCommanderOverhaul/Monkeylord/monkeylord_exhaust_socket.sanvfx\"\n    UnitTemplate.visuals.effectsPersistent = {\n        {\n            boneName = \"Exhaust01\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust02\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust03\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust05\",\n            particleName = monkeylordExhaustParticle,\n        },\n        {\n            boneName = \"Exhaust06\",\n            particleName = monkeylordExhaustParticle,\n        },\n    }\n\n    -- The 1.4 experiment translated and spun Center_Turret_Barrel even though\n    -- it owns visible mesh vertices and the real muzzle is its sibling. Drop\n    -- that experiment so the scoped HostBeam/ClientBeam wrappers use stock.\n    UnitTemplate.additions.rotators = nil\n    weapon.scoMonkeylordMicrowave = nil\n    weapon.scoAboveWaterFireOnly = nil\n    weapon.scoAboveWaterTargetsOnly = nil\n    weapon.scoMonkeylordWaterGate = nil\n\n    -- Restore the reviewed Sanctuary primary-laser simulation and renderer.\n    -- Only its aim/muzzle bones change to the imported URL0402 rig.\n    weapon.audio = {\n        onFire = {\n            looping = true,\n            name = \"aglm5140\",\n        },\n    }\n    weapon.beam = {\n        cullDistance = 500,\n        fadeInTime = 1,\n        fadeOutTime = 2,\n        subMesh = {\n            {\n                material = \"VFX/Materials/Beam/Beam ugl4001_01.sanmaterial\",\n                model = \"VFX/Models/Beams/BeamBasicLongSingle.sanmodel\",\n            },\n            {\n                material = \"VFX/Materials/Beam/Beam ugl4001_02.sanmaterial\",\n                model = \"VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel\",\n            },\n        },\n    }\n    weapon.beamLifetime = -1\n    weapon.damage = 50\n    weapon.damageFriendly = nil\n    weapon.damageRadius = 1\n    weapon.damageType = \"Normal\"\n    weapon.effects = {\n        onFire = \"VFX/Muzzle/vgm7401_beam_plasma_huge_muzzle_loop.sanvfx\",\n    }\n    weapon.layerTargetLimits = { \"Land\", \"WaterSurface\" }\n    weapon.layerWeaponLimits = { \"Land\" }\n    weapon.projectileLifetime = 2\n    weapon.projectileTemplate = \"pgd471\"\n    weapon.rangeMax = 30\n    weapon.rangeMin = 4\n    weapon.rangeTracking = 1.1\n    weapon.reloadTime = 2\n    weapon.targetWaterLimits = \"Above\"\n    -- Sanctuary normally chooses a random target bone. Several legal bones\n    -- sit outside a unit's collision box, so a continuous ray can pass over\n    -- the collider and render to maximum range. Aim this beam at the target's\n    -- TargetCollider entity, which is located at collisionInfo.centerOffset.\n    weapon.scomAimAtTargetCollider = true\n    weapon.aimControllers = {\n        {\n            aimBone = \"Center_Turret_Muzzle\",\n            aimTolerance = 2,\n            defaultPitchAdjustment = -20,\n            defaultYawAdjustment = 0,\n            leadTarget = false,\n            pitchBone = \"Center_Turret\",\n            pitchMax = 70,\n            pitchMin = -110,\n            pitchSpeed = 20,\n            poseResetTime = 3,\n            projectileSpeed = 30,\n            solverType = \"NoArc\",\n            -- Sanctuary requires distinct yaw and pitch bones; otherwise it\n            -- silently drops pitch. Use the verified parent-yaw/child-pitch\n            -- chain while retaining the authentic muzzle endpoint.\n            yawBone = \"Center_Turret_B01\",\n            yawMax = 180,\n            yawMin = -180,\n            yawSpeed = 40,\n        },\n    }\n    weapon.muzzleGroups = {\n        {\n            muzzles = {\n                \"Center_Turret_Muzzle\",\n                \"Center_Turret_Muzzle_Dual\",\n            },\n        },\n    }\n    weapon.muzzles = {\n        [\"Center_Turret_Muzzle\"] = {\n            aimController = \"Center_Turret_Muzzle\",\n        },\n        [\"Center_Turret_Muzzle_Dual\"] = {\n            aimController = \"Center_Turret_Muzzle\",\n        },\n    }\n\n    -- Restore the source 64-unit reach of both ground bolters independently of\n    -- the 30-unit microwave laser. AA and torpedo ranges remain untouched.\n    local function requireBolter(index, muzzle)\n        local bolter = UnitTemplate.weapons[index]\n        local controller = bolter\n            and bolter.aimControllers\n            and bolter.aimControllers[1]\n        local muzzleGroup = bolter\n            and bolter.muzzleGroups\n            and bolter.muzzleGroups[1]\n        local muzzleMap = bolter\n            and bolter.muzzles\n            and bolter.muzzles[muzzle]\n        if not bolter\n            or bolter.projectileTemplate ~= \"pgr402b\"\n            or bolter.rangeMax ~= 64\n            or not controller\n            or controller.aimBone ~= muzzle\n            or not muzzleGroup\n            or not muzzleGroup.muzzles\n            or muzzleGroup.muzzles[1] ~= muzzle\n            or muzzleGroup.muzzles[2] ~= nil\n            or not muzzleMap\n            or muzzleMap.aimController ~= muzzle\n        then\n            error(\"Monkeylord bolter contract drifted at weapon \" .. index)\n        end\n        return bolter\n    end\n\n    local rightBolter = requireBolter(2, \"Right_Turret_Muzzle\")\n    local leftBolter = requireBolter(3, \"Left_Turret_Muzzle\")\n    rightBolter.rangeMax = 64\n    rightBolter.rangeMin = 0\n    leftBolter.rangeMax = 64\n    leftBolter.rangeMin = 0\n\n    local torpedo = UnitTemplate.weapons[6]\n    if not torpedo\n        or torpedo.projectileTemplate ~= \"pgr402t\"\n        or torpedo.rangeMax ~= 45\n        or torpedo.rangeMin ~= 0\n        or torpedo.rangeRingType ~= \"AntiNavy\"\n    then\n        error(\"Monkeylord torpedo range-ring contract drifted.\")\n    end\n\n    -- Sanctuary calls this material AntiNaval. AntiNavy maps to the\n    -- 65535 None sentinel, which its Burst range renderer cannot index.\n    torpedo.rangeRingType = \"AntiNaval\"\n\n    local validRangeRingTypes = {\n        Engineering = true,\n        AntiAir = true,\n        AntiNaval = true,\n        AttackCounter = true,\n        DirectFire = true,\n        IndirectFire = true,\n        IntelCounter = true,\n        IntelOmni = true,\n        Radar = true,\n        Sonar = true,\n        FogOfWar = true,\n        Vision = true,\n        WaterVision = true,\n    }\n    for index, candidate in ipairs(UnitTemplate.weapons) do\n        local rangeRingType = candidate.rangeRingType\n        if rangeRingType ~= nil and not validRangeRingTypes[rangeRingType] then\n            error(\"Monkeylord invalid range-ring type at weapon \" .. index)\n        end\n    end\nend\n";
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", 1, "fix marker");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "weapon.scoMonkeylordMicrowave = nil", 1, "disabled microwave experiment");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "\"Center_Turret_Muzzle_Dual\"", 2, "dual muzzle references");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "BeamBasicLongSingle.sanmodel", 1, "primary beam model");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "BeamBasicLongSingle_2X.sanmodel", 1, "secondary beam model");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "defaultPitchAdjustment = -20,", 1, "source pitch center");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "pitchMax = 70,", 1, "source maximum pitch");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "pitchMin = -110,", 1, "source minimum pitch");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "VFX/SupremeCommanderOverhaul/Monkeylord/monkeylord_exhaust_socket.sanvfx", 1, "socket-local Guard exhaust graph");
			string[] array = new string[5] { "Exhaust01", "Exhaust02", "Exhaust03", "Exhaust05", "Exhaust06" };
			foreach (string text3 in array)
			{
				Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "boneName = \"" + text3 + "\"", 1, text3 + " exhaust attachment");
			}
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "yawBone = \"Center_Turret_B01\",", 1, "distinct central yaw parent");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "weapon.scomAimAtTargetCollider = true", 1, "collider-center beam aim opt-in");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "weapon.rangeMax = 30", 1, "source laser maximum range");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "weapon.rangeMin = 4", 1, "source laser minimum range");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "rightBolter.rangeMax = 64", 1, "right bolter maximum range");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "leftBolter.rangeMax = 64", 1, "left bolter maximum range");
			Require(text2.Substring(text2.IndexOf("-- Supreme Commander Overhaul Monkeylord comprehensive fix 1.4.0", StringComparison.Ordinal)), "torpedo.rangeRingType = \"AntiNaval\"", 1, "safe torpedo range-ring material");
			return text2;
		}
		}
	}

	public static string PatchHostWeaponSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = source.Replace("\r\n", "\n").Replace("\r", "\n");
		int num = Count(text, "-- Supreme Commander Overhaul Monkeylord collider aim fix 1.3.0");
		switch (num)
		{
		case 1:
			Require(text, "\n\n-- Supreme Commander Overhaul Monkeylord collider aim fix 1.3.0\nlocal SCOM_MonkeylordPreviousGetRandomTargetBoneID =\n    HostWeapon.GetRandomTargetBoneID\n\nfunction HostWeapon:GetRandomTargetBoneID(targetUnit)\n    if self.tp and self.tp.scomAimAtTargetCollider then\n        local targetCollider = targetUnit and targetUnit.targetCollider\n        local targetColliderID = targetCollider and targetCollider.id\n        if targetColliderID and Engine.IsValidGlobalID(targetColliderID) then\n            return targetColliderID\n        end\n    end\n    return SCOM_MonkeylordPreviousGetRandomTargetBoneID(self, targetUnit)\nend", 1, "complete collider-aim appendix");
			if (!text.TrimEnd(Array.Empty<char>()).EndsWith("\n\n-- Supreme Commander Overhaul Monkeylord collider aim fix 1.3.0\nlocal SCOM_MonkeylordPreviousGetRandomTargetBoneID =\n    HostWeapon.GetRandomTargetBoneID\n\nfunction HostWeapon:GetRandomTargetBoneID(targetUnit)\n    if self.tp and self.tp.scomAimAtTargetCollider then\n        local targetCollider = targetUnit and targetUnit.targetCollider\n        local targetColliderID = targetCollider and targetCollider.id\n        if targetColliderID and Engine.IsValidGlobalID(targetColliderID) then\n            return targetColliderID\n        end\n    end\n    return SCOM_MonkeylordPreviousGetRandomTargetBoneID(self, targetUnit)\nend", StringComparison.Ordinal))
			{
				throw new InvalidOperationException("Collider-aim appendix is not the Host weapon class tail.");
			}
			return text;
		default:
			throw new InvalidOperationException($"Expected zero or one collider-aim markers, found {num}.");
		case 0:
		{
			Require(text, "-- Guard Cybran Monkeylord Cache Patcher 1.4.0", 1, "SCOM Host weapon marker");
			Require(text, "local SCO_MonkeylordStockCanShootAt = HostWeapon.CanShootAt", 1, "SCOM Monkeylord Host weapon wrapper");
			Require(text, "function HostWeapon:GetRandomTargetBoneID(targetUnit)", 1, "stock target-bone selector");
			string text2 = text.TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul Monkeylord collider aim fix 1.3.0\nlocal SCOM_MonkeylordPreviousGetRandomTargetBoneID =\n    HostWeapon.GetRandomTargetBoneID\n\nfunction HostWeapon:GetRandomTargetBoneID(targetUnit)\n    if self.tp and self.tp.scomAimAtTargetCollider then\n        local targetCollider = targetUnit and targetUnit.targetCollider\n        local targetColliderID = targetCollider and targetCollider.id\n        if targetColliderID and Engine.IsValidGlobalID(targetColliderID) then\n            return targetColliderID\n        end\n    end\n    return SCOM_MonkeylordPreviousGetRandomTargetBoneID(self, targetUnit)\nend\n";
			Require(text2, "-- Supreme Commander Overhaul Monkeylord collider aim fix 1.3.0", 1, "collider-aim marker");
			Require(text2, "function HostWeapon:GetRandomTargetBoneID(targetUnit)", 2, "wrapped target-bone selectors");
			Require(text2, "local targetCollider = targetUnit and targetUnit.targetCollider", 1, "target collider-center selection");
			return text2;
		}
		}
	}

	private static void Require(string source, string token, int expected, string label)
	{
		int num = Count(source, token);
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {label}, found {num}.");
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

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("EM.Lua.FilesCache is unavailable.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CacheResource GetCachedResource(object cache, string relativePath)
	{
		string value = "/" + relativePath.Replace('\\', '/');
		CacheResource cacheResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type = item.GetType();
			if (type.GetProperty("Key")?.GetValue(item, null) is string text && text.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cacheResource != null)
				{
					throw new InvalidOperationException("Multiple cached resources matched " + relativePath + ".");
				}
				object obj = type.GetProperty("Value")?.GetValue(item, null) ?? throw new InvalidOperationException("Cached resource has no value: " + relativePath + ".");
				EnsureCreated(obj);
				cacheResource = new CacheResource(text, obj);
			}
		}
		return cacheResource ?? throw new FileNotFoundException("The required SCOM resource was not cached: " + relativePath + ".", relativePath);
	}

	private static string GetResourceText(object resource)
	{
		EnsureCreated(resource);
		byte[] bytes = ((resource.GetType().GetMethod("ToArray", Type.EmptyTypes) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null) as byte[]) ?? throw new InvalidOperationException("NativeArray.ToArray returned null.");
		return Encoding.UTF8.GetString(bytes);
	}

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		Type type = nativeArrayType.Assembly.GetType("Unity.Collections.Allocator", throwOnError: false) ?? (from a in AppDomain.CurrentDomain.GetAssemblies()
			select a.GetType("Unity.Collections.Allocator", throwOnError: false)).FirstOrDefault((Type t) => t != null) ?? throw new TypeLoadException("Unity.Collections.Allocator is unavailable.");
		return (nativeArrayType.GetConstructor(new Type[2]
		{
			typeof(byte[]),
			type
		}) ?? throw new MissingMethodException(nativeArrayType.FullName, ".ctor(Byte[], Allocator)")).Invoke(new object[2]
		{
			Encoding.UTF8.GetBytes(source),
			Enum.Parse(type, "Persistent")
		});
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item") ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void VerifyCachedResource(object cache, string path, string expectedSource, string operation)
	{
		if (!string.Equals(GetResourceText((cache.GetType().GetProperty("Item") ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException(operation + " cache resource was unavailable: " + path + ".")), expectedSource, StringComparison.Ordinal))
		{
			throw new InvalidOperationException(operation + " cache resource failed readback: " + path + ".");
		}
	}

	private static void EnsureCreated(object resource)
	{
		object value = (resource.GetType().GetProperty("IsCreated") ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource, null);
		if (!(value is bool) || !(bool)value)
		{
			throw new InvalidOperationException("Cached template NativeArray is not created.");
		}
	}

	private static void TryDisposeNativeArray(Type type, object value)
	{
		try
		{
			type.GetMethod("Dispose", Type.EmptyTypes)?.Invoke(value, null);
		}
		catch (Exception ex)
		{
			Log("NativeArray cleanup warning: " + ex.GetBaseException().Message);
		}
	}

	private static void Log(string message)
	{
		Console.WriteLine("[SCOM Monkeylord Fix] " + message);
	}
}
