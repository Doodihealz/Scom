using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using ScomDeterministicLua;
using ScomFieldFixes;
using ScomRepair20260913;
using SupremeCommanderOverhaulCanonical;

namespace SupremeCommanderOverhaulFieldFixes;

public static class CachePatcherRuntime
{
	private sealed class CachedResource
	{
		public string Path { get; }

		public object Value { get; }

		public CachedResource(string path, object value)
		{
			Path = path;
			Value = value;
		}
	}

	private sealed class CacheMutation
	{
		public CachedResource Resource { get; }

		public string Description { get; }

		public string OldSource { get; }

		public string NewSource { get; }

		public bool NeedsWrite => !string.Equals(OldSource, NewSource, StringComparison.Ordinal);

		public object? Replacement { get; set; }

		public bool Assigned { get; set; }

		public CacheMutation(CachedResource resource, string description, string oldSource, string newSource)
		{
			Resource = resource;
			Description = description;
			OldSource = oldSource;
			NewSource = newSource;
		}
	}

	private sealed class CacheInsertion
	{
		public string Path { get; }

		public Type ResourceType { get; }

		public string Description { get; }

		public string NewSource { get; }

		public bool AlreadyPresent { get; }

		public bool NeedsWrite => !AlreadyPresent;

		public object? Replacement { get; set; }

		public bool Assigned { get; set; }

		public CacheInsertion(string path, Type resourceType, string description, string newSource, bool alreadyPresent)
		{
			Path = path;
			ResourceType = resourceType;
			Description = description;
			NewSource = newSource;
			AlreadyPresent = alreadyPresent;
		}
	}

	public const string Marker = "-- Supreme Commander Overhaul field fixes 1.0.0";

	private const string ClientUnitConstructionPaletteMarker = "-- SCOM Field Fix: upgrade presentation, team construction color, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.14";

	private const string LegacyClientUnitNeutralBlueprintMarker = "-- SCOM Field Fix: upgrade presentation, neutral construction blueprints, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.12";

	private const string LegacyClientUnitNeutralBlueprintAppendixSha256 = "1D9FBB83660A5DE19C408800F57C7103B49C3A3FFC0130BDD65E4248C455B594";

	private const string LegacyClientUnitPaletteMarker = "-- SCOM Field Fix: upgrade presentation, faction construction palette, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.11";

	private const string LegacyClientUnitAppendixSha256 = "9CCB0E621782BD70E9D1864005A80A5F38BE6D3B6F4705F72BFF0CE3978EBB17";

	private const string StrategicMuzzleSimulationMarker = "-- SCOM Field Fix: strategic silo simulated muzzle 1.0.0";

	private const string ApocalypseFlightMarker = "-- SCOM Apocalypse source flight 4.0.0";

	private const string ApocalypseVfxLoaderMarker = "-- SCOM Field Fix: Apocalypse impact VFX and commander audio prefabs 1.1.0";

	private const string FactionTarmacMarker = "-- SCOM faction tarmacs 1.0.0";

	private const string FactionTarmacDecalPrefix = "ScomFieldFixes.Tarmac.Decal.";

	private const string FactionShieldPaletteMarker = "-- SCOM faction shield palettes 1.0.0";

	private const string LongestRangeRingMarker = "-- SCOM Field Fix: longest range ring per material 1.0.0";

	public const string ProjectileMarker = "-- Supreme Commander Overhaul projectile field fixes 1.0.1";

	public const string ColossusMarker = "-- SCOM Field Fix: isolated Galactic Colossus eye calibration 1.0.2";

	private const string SourceAnimationPlaybackMarker = "-- SCOM Field Fix: source animation playback mode 1.0.0";

	private const string ArtilleryWaterColliderMarker = "-- SCOM Field Fix: Supreme Commander artillery water collider 1.0.0";

	private const string ArtilleryWaterLayerMarker = "-- SCOM Field Fix: Supreme Commander artillery water layer 1.0.0";

	private const string ScathisVisibleMuzzleMarker = "-- SCOM Field Fix: Scathis visible muzzle parity 1.0.0";

	private const string ScathisAnimatorOwnershipMarker = "-- SCOM Field Fix: Scathis deployed animator ownership 1.0.0";

	private const string MegalithEnemyRightClickMarker = "-- SCOM Field Fix: Megalith enemy right-click attacks 1.0.0";

	private const string UnitTemplateLoaderPath = "LJ/lua/common/loading/unitTemplateLoader.lua";

	private const string ProjectileTemplateLoaderPath = "LJ/lua/common/loading/projectileTemplateLoader.lua";

	private const string ShieldTemplateLoaderPath = "LJ/lua/common/loading/shieldTemplateLoader.lua";

	private const string CollisionLayersPath = "LJ/lua/common/layers.lua";

	private const string TemplateSystemLoaderPath = "LJ/lua/common/systems/templateLoader.lua";

	private const string ImportPath = "LJ/lua/common/systems/import.lua";

	private const string ClientMainPath = "LJ/lua/client/clientMain.lua";

	private const string ClientHostCommandsPath = "LJ/lua/client/commands.lua";

	private const string SurvivalPath = "LJ/lua/host/survival/survival.lua";

	private const string HostTestUtilsPath = "LJ/lua/host/testUtils.lua";

	private const string HostListenersPath = "LJ/lua/host/hostListeners.lua";

	private const string HostBuildOrderPath = "LJ/lua/host/managers/orders/orderClasses/hostBuildOrder.lua";

	private const string ConstructionPreviewPath = "LJ/lua/client/input/constructionPreviewSystem.lua";

	private const string ClientUnitBasePath = "LJ/lua/client/units/unitsClasses/unitsBaseClass.lua";

	private const string ConstructionBeamPath = "LJ/lua/client/entities/constructionBeam.lua";

	private const string HostUnitBasePath = "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua";

	private const string HostUnitDefaultPath = "LJ/lua/host/units/unitsClasses/unitsDefault.lua";

	private const string CommandsPath = "LJ/lua/common/commands/definitions/buildQueue.lua";

	private const string ClientUnitCommandsPath = "LJ/lua/common/commands/definitions/units.lua";

	private const string ClientListenersPath = "LJ/lua/client/clientListeners.lua";

	private const string ClientInputEventsPath = "LJ/lua/client/inputEventsFunctions.lua";

	private const string ClientInputActionsPath = "LJ/lua/client/input/inputActions.lua";

	private const string OrdersPanelPath = "LJ/lua/client/ui/ordersPanel.lua";

	private const string InformationPanelPath = "LJ/lua/client/ui/informationPanel.lua";

	private const string CollisionUpdatePath = "LJ/lua/host/collisionUpdate.lua";

	private const string HostChosenPath = "LJ/lua/host/units/unitsClasses/unitsDefaultChosen.lua";

	private const string ClientChosenPath = "LJ/lua/client/units/unitsClasses/unitsDefaultChosen.lua";

	private const string HostWeaponsBasePath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string ClientMuzzlePath = "LJ/lua/client/units/weaponsClasses/clientMuzzleClass.lua";

	private const string HostSeraphimPath = "LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua";

	private const string ClientSeraphimPath = "LJ/lua/client/units/unitsClasses/unitsDefaultSeraphim.lua";

	private const string YthothaProjectilePath = "LJ/lua/common/projectiles/projectilesTemplates/psu404s/psu404s.santp";

	private const string PercivalTemplatePath = "LJ/lua/common/units/unitsTemplates/uel3401/uel3401.santp";

	private const string PercivalProjectilePath = "LJ/lua/common/projectiles/projectilesTemplates/pep305/pep305.santp";

	private const string DemolisherTemplatePath = "LJ/lua/common/units/unitsTemplates/uel3101/uel3101.santp";

	private const string HostEdaUnitsPath = "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua";

	private static readonly IReadOnlyList<(string Path, string Resource)> NukeProjectiles = new(string, string)[5]
	{
		("LJ/lua/common/projectiles/projectilesTemplates/psn001/psn001.santp", "ScomFieldFixes.psn001.santp"),
		("LJ/lua/common/projectiles/projectilesTemplates/psn002/psn002.santp", "ScomFieldFixes.psn002.santp"),
		("LJ/lua/common/projectiles/projectilesTemplates/psn003/psn003.santp", "ScomFieldFixes.psn003.santp"),
		("LJ/lua/common/projectiles/projectilesTemplates/psn004/psn004.santp", "ScomFieldFixes.psn004.santp"),
		("LJ/lua/common/projectiles/projectilesTemplates/psn005/psn005.santp", "ScomFieldFixes.psn005.santp")
	};

	private static readonly IReadOnlyList<(string Path, string Resource)> ArtilleryProjectiles = new(string, string)[2]
	{
		("LJ/lua/common/projectiles/projectilesTemplates/psk201/psk201.santp", "ScomFieldFixes.psk201.santp"),
		("LJ/lua/common/projectiles/projectilesTemplates/psm401/psm401.santp", "ScomFieldFixes.psm401.santp")
	};

	private const string MainRuntimeType = "SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime";

	private const string GameplayRuntimeType = "SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime";

	private const string MotionRuntimeType = "SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime";

	private const string SeaRuntimeType = "SupremeCommanderOverhaulSeaParity.CachePatcherRuntime";

	private const string BuildBoxRuntimeType = "SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime";

	private const string MainMvid = "48dd1991-b31b-4297-bd60-0597d33328b5";

	private const long MainBytes = 3819520L;

	private const string MainSha256 = "3EED7306200D5910786221547FF0FB959FA8CF92C85C99D62B98A12175C28B76";

	private static bool isApplied;

	private static bool isColossusHotfixApplied;

	private static bool isStartupCriticalApplied;

	[ThreadStatic]
	private static object luaCacheLookupCache;

	[ThreadStatic]
	private static int luaCacheLookupCount;

	[ThreadStatic]
	private static Dictionary<string, List<string>> luaCachePathsBySuffix;

	public static void ApplyGalacticColossusHotfix()
	{
		if (isColossusHotfixApplied)
		{
			return;
		}
		object obj = null;
		CacheMutation[] array = Array.Empty<CacheMutation>();
		try
		{
			ValidateColossusHotfixUpstreamIdentity();
			obj = GetLuaFileCache();
			array = new CacheMutation[3]
			{
				CreateMutation(obj, "LJ/lua/common/loading/unitTemplateLoader.lua", "isolated Galactic Colossus eye template calibration", PatchGalacticColossusUnitTemplateLoader),
				CreateMutation(obj, "LJ/lua/client/units/unitsClasses/unitsDefaultChosen.lua", "isolated Galactic Colossus eye client calibration", PatchGalacticColossusClientChosen),
				CreateMutation(obj, "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "isolated Galactic Colossus off-target beam gate", PatchGalacticColossusHostWeapons)
			};
			ClearLuaCacheLookupIndex();
			if (array.All((CacheMutation mutation) => !mutation.NeedsWrite))
			{
				isColossusHotfixApplied = true;
				Log("The isolated Galactic Colossus eye calibration is already active.");
				return;
			}
			foreach (CacheMutation item2 in array.Where((CacheMutation cacheMutation2) => cacheMutation2.NeedsWrite))
			{
				item2.Replacement = CreateNativeArray(item2.Resource.Value.GetType(), item2.NewSource);
			}
			foreach (CacheMutation item3 in array.Where((CacheMutation cacheMutation2) => cacheMutation2.NeedsWrite))
			{
				item3.Assigned = true;
				SetCachedResource(obj, item3.Resource.Path, item3.Replacement);
				if (!string.Equals(ReadText(GetExactCachedResource(obj, item3.Resource.Path)), item3.NewSource, StringComparison.Ordinal))
				{
					throw new InvalidOperationException(item3.Description + " cache write verification failed.");
				}
			}
			foreach (CacheMutation item4 in array.Where((CacheMutation cacheMutation2) => cacheMutation2.NeedsWrite))
			{
				TryDispose(item4.Resource.Value, "replaced " + item4.Description);
			}
			isColossusHotfixApplied = true;
			Log("Committed the isolated Galactic Colossus eye calibration before Aeon Motion.");
		}
		catch (Exception ex)
		{
			ClearLuaCacheLookupIndex();
			List<Exception> list = new List<Exception>();
			if (obj != null)
			{
				foreach (CacheMutation item5 in array.Reverse())
				{
					if (!item5.Assigned)
					{
						continue;
					}
					try
					{
						SetCachedResource(obj, item5.Resource.Path, item5.Resource.Value);
						if (!string.Equals(ReadText(GetExactCachedResource(obj, item5.Resource.Path)), item5.OldSource, StringComparison.Ordinal))
						{
							throw new InvalidOperationException(item5.Description + " cache rollback verification failed.");
						}
						item5.Assigned = false;
					}
					catch (Exception item)
					{
						list.Add(item);
					}
				}
			}
			CacheMutation[] array2 = array;
			foreach (CacheMutation cacheMutation in array2)
			{
				if (!cacheMutation.Assigned && cacheMutation.Replacement != null)
				{
					TryDispose(cacheMutation.Replacement, "rolled-back " + cacheMutation.Description);
				}
			}
			isColossusHotfixApplied = false;
			if (list.Count != 0)
			{
				Log("Galactic Colossus calibration failed and rollback was incomplete: " + ex.GetBaseException().Message);
				throw new AggregateException("Galactic Colossus calibration and rollback both failed.", new Exception[1] { ex }.Concat(list));
			}
			Log("Canonical Galactic Colossus calibration failed after a complete rollback: " + ex.GetBaseException().Message);
			throw;
		}
	}

	public static void Apply()
	{
		if (isApplied)
		{
			return;
		}
		object cache = null;
		CacheMutation[] array = Array.Empty<CacheMutation>();
		CacheInsertion[] array2 = Array.Empty<CacheInsertion>();
		try
		{
			ValidateUpstreamIdentity();
			cache = GetLuaFileCache();
			CommitStartupCriticalTemplatePolicy(cache);
			CacheMutation[] obj = new CacheMutation[53]
			{
				CreateMutation(cache, "LJ/lua/common/layers.lua", "Supreme Commander artillery water collision layer", PatchFaArtilleryCollisionLayers),
				CreateMutation(cache, "LJ/lua/common/gameUtils.lua", "Forged Alliance player and AI starting resources", PatchStartingResources),
				CreateMutation(cache, "LJ/lua/common/loading/projectileTemplateLoader.lua", "Cybran projectile-template policy", PatchProjectileTemplateLoader),
				CreateMutation(cache, "LJ/lua/common/loading/vfxTemplateLoader.lua", "Yolona delayed impact particle lifetime", PatchYolonaVfxLifetime),
				CreateMutation(cache, "LJ/lua/common/loading/shieldTemplateLoader.lua", "four-faction shield palettes", PatchFactionShieldPalette),
				CreateMutation(cache, "LJ/lua/common/systems/templateLoader.lua", "longest range ring and Apocalypse VFX preload", (string source) => PatchFactionTarmacPreload(PatchTemplateSystemLoader(source))),
				CreateMutation(cache, "LJ/lua/common/systems/import.lua", "cache-only projectile folder registration", PatchImportScanner),
				CreateMutation(cache, "LJ/lua/common/units/availableUnits.lua", "source roster and native Chosen availability", (string source) => AppendReviewedRuntime(AppendReviewedRuntime(Normalize(source), LoadEmbeddedText("ScomFieldFixes.Roster.available.lua")), "-- SCOM native Chosen Creative availability 1.0.0\nAvailableUnits.ucl9505 = true\n")),
				CreateMutation(cache, "LJ/lua/common/units/quickLaunchUnits.lua", "source roster and native Chosen quick launch availability", (string source) => AppendReviewedRuntime(AppendReviewedRuntime(Normalize(source), LoadEmbeddedText("ScomFieldFixes.Roster.quick_launch.lua")), "-- SCOM native Chosen Creative quick launch 1.0.0\nQuickLaunchUnits.ucl9505 = true\n")),
				CreateAppendMutation(cache, "LJ/lua/common/utilities/buildQueueUtils.lua", "Creative-only hydro construction eligibility", "ScomFieldFixes.Roster.source_hydro_build_queue.lua"),
				CreateMutation(cache, "LJ/lua/host/projectiles/projectilesClasses/projectilesBaseClass.lua", "source projectile physics lifecycle", (string source) => AppendReviewedRuntime(AppendReviewedRuntime(PatchProjectileWaterDamage(source), LoadEmbeddedText("ScomFieldFixes.source_projectile_host_appendix.lua")), "-- SCOM source projectile motion installation 1.0.0\nlocal sourceMotion = Import('common/systems/scoSourceProjectileMotion.lua')\nsourceMotion.Configure(Import('common/systems/scoSourceProjectileMotionContract.lua'))\nsourceMotion.InstallProjectile(HostProjectile)\n_G.SCO_SourceProjectileIntercepted = sourceMotion.Intercepted")),
				CreateMutation(cache, "LJ/lua/client/projectiles/projectilesClasses/projectilesBaseClass.lua", "source nuclear launch phases, Yolona impact lifetime and torpedo water splashes", (string source) => PatchWaterSplashImpact(AppendReviewedRuntime(AppendReviewedRuntime(source, LoadEmbeddedText("ScomFieldFixes.Roster.source_nuke_client.lua")), LoadEmbeddedText("ScomFieldFixes.Roster.yolona_impact_client.lua")))),
				CreateAppendMutation(cache, "LJ/lua/client/units/unitsUpdate.lua", "source support commander optional parts", "ScomFieldFixes.Roster.source_support_commander_render.lua"),
				CreateMutation(cache, "LJ/lua/common/commands/definitions/props.lua", "Naval wreck appearance at seabed contact", NavalWreckPresentationPolicy.PatchCommands),
				CreateMutation(cache, "LJ/lua/host/props/propsClasses/wreckageClass.lua", "Naval wreck reclaim and lifetime begin after sinking", NavalWreckPresentationPolicy.PatchHostWreck),
				CreateMutation(cache, "LJ/lua/host/props/wreckCrash.lua", "Naval gentle sinking and immediate seabed settling", NavalWreckMotionPolicy.Patch),
				CreateMutation(cache, "LJ/lua/host/props/propsUtilities.lua", "source aircraft wreck impact ownership", (string source) => AppendReviewedRuntime(source, "-- SCOM source aircraft crash registration 1.0.0\nlocal sourceCrash = Import('common/systems/scoMissingCrash.lua')\nsourceCrash.Configure(Import('common/systems/scoMissingCrashRegistry.lua'))\nCreateWreckageFromUnit = sourceCrash.WrapCreateWreckage(CreateWreckageFromUnit)")),
				CreateMutation(cache, "LJ/lua/host/survival/survival.lua", "land-safe Chosen survival pool", PatchSurvival),
				CreateAppendMutation(cache, "LJ/lua/common/units/unitsTemplates/uel3401/uel3401.santp", "Percival locomotion state binding", "ScomFieldFixes.uef_t3_percival_template_appendix.lua"),
				CreateAppendMutation(cache, "LJ/lua/common/projectiles/projectilesTemplates/pep305/pep305.santp", "Percival commander-plasma projectile presentation", "ScomFieldFixes.uef_t3_percival_projectile_appendix.lua"),
				CreateAppendMutation(cache, "LJ/lua/common/units/unitsTemplates/uel3101/uel3101.santp", "Demolisher source artillery firing envelope", "ScomFieldFixes.uef_t3_demolisher_template_appendix.lua"),
				CreateAppendMutation(cache, "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", "Demolisher deploy-to-aim animation handoff", "ScomFieldFixes.uef_t3_demolisher_host_appendix.lua"),
				CreateAppendMutation(cache, "LJ/lua/host/testUtils.lua", "scoped Creative strategic-silo spawn context", "ScomFieldFixes.strategic_silo_creative_spawn_appendix.lua"),
				CreateAppendMutation(cache, "LJ/lua/host/hostListeners.lua", "direct Creative Apocalypse host boundary", "ScomFieldFixes.strategic_silo_creative_host_listener_appendix.lua"),
				CreateMutation(cache, "LJ/lua/host/managers/orders/orderClasses/hostBuildOrder.lua", "UEF shallow-water, Hive and source hydro host placement", (string source) => AppendReviewedRuntime(PatchHostBuildOrder(source), LoadEmbeddedText("ScomFieldFixes.Roster.source_hydro_host.lua"))),
				CreateMutation(cache, "LJ/lua/client/input/constructionPreviewSystem.lua", "UEF shallow-water, Hive and source hydro construction preview", (string source) => AppendReviewedRuntime(PatchConstructionPreview(source), LoadEmbeddedText("ScomFieldFixes.Roster.source_hydro_client.lua"), "return {\n    UpdateConstructionPreview = UpdateConstructionPreview")),
				CreateMutation(cache, "LJ/lua/client/units/unitsClasses/unitsDefault.lua", "private FA air-factory construction palette", ConstructionBeamPalette.PatchFactoryBeams),
				CreateMutation(cache, "LJ/lua/client/units/unitsClasses/unitsDefaultEDA.lua", "private UEF factory construction palette", ConstructionBeamPalette.PatchFactoryBeams),
				CreateMutation(cache, "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua", "private Cybran factory construction palette", ConstructionBeamPalette.PatchFactoryBeams),
				CreateMutation(cache, "LJ/lua/client/units/unitsClasses/unitsBaseClass.lua", "upgrade-target and strategic stockpile presentation", (string source) => NavalWreckMotionPolicy.PatchClientDeath(AppendReviewedRuntime(AppendReviewedRuntime(AppendReviewedRuntime(PatchFactionTarmacClient(AppendReviewedRuntime(AppendReviewedRuntime(AppendReviewedRuntime(AppendReviewedRuntime(PatchClientUnitBase(source), LoadEmbeddedText("ScomFieldFixes.Roster.source_special_units_client.lua")), LoadEmbeddedText("ScomFieldFixes.Roster.source_secondary_visuals_client.lua")), LoadEmbeddedText("ScomFieldFixes.Roster.source_dynamic_visuals_client.lua")), LoadEmbeddedText("ScomFieldFixes.FactoryEgress.factory_clearance_client.lua"))), LoadEmbeddedText("ScomFieldFixes.Roster.source_yolona_missile_client.lua")), LoadEmbeddedText("ScomFieldFixes.Roster.atlantis_cargo_visibility.lua")), LoadEmbeddedText("ScomFieldFixes.Roster.source_interceptor_audio_client.lua")))),
				CreateInsertBeforeMutation(cache, "LJ/lua/client/entities/constructionBeam.lua", "construction-beam target and parent lifecycle", "return {\n    CreateConstructionBeam = CreateConstructionBeam\n}", "ScomFieldFixes.construction_beam_lifecycle_appendix.lua"),
				CreateMutation(cache, "LJ/lua/client/ui/informationPanel.lua", "strategic silo information progress", PatchInformationPanel),
				CreateMutation(cache, "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Supreme Commander UEF artillery firing parity", (string source) => AppendReviewedRuntime(AppendReviewedRuntime(PatchFaArtilleryHostWeapons(source), "\n-- SCOM tactical stock-weapon exclusion 1.0.0\ndo\n    if not HostWeapon.scoTacticalUpdateInstalled then\n        local previous = HostWeapon.Update\n        function HostWeapon:Update(...)\n            if self.tp and self.tp.scoTacticalOwned == true then return end\n            return previous(self, ...)\n        end\n        HostWeapon.scoTacticalUpdateInstalled = true\n    end\nend\n"), "-- SCOM source weapon runtime installation 1.0.0\nImport('common/systems/scoSourceWeaponRuntime.lua').InstallWeapon(HostWeapon,WeaponState)\nImport('common/systems/scoSourceSpecialWeapons.lua').InstallWeapon(HostWeapon)\nImport('common/systems/scoSourceContinuousBeams.lua').InstallWeapon(HostWeapon,WeaponState)\nImport('common/systems/scoSourceProjectileMotion.lua').InstallWeapon(HostWeapon)\nImport('common/systems/scoSourceUnitModes.lua').InstallWeapon(HostWeapon,WeaponState)\nImport('common/systems/scoSourceDynamicVisuals.lua').InstallWeapon(HostWeapon,WeaponState)\nImport('common/systems/scoTorpedoWeapons.lua').InstallWeapon(HostWeapon,WeaponState)")),
				CreateMutation(cache, "LJ/lua/host/units/weaponsClasses/beam.lua", "source beam pulse and splash binding", (string source) => AppendReviewedRuntime(source, "-- SCOM source beam runtime installation 1.0.0\nImport('common/systems/scoSourceWeaponRuntime.lua').InstallBeam(HostBeam)\nImport('common/systems/scoSourceSpecialWeapons.lua').InstallBeam(HostBeam)\nImport('common/systems/scoSourceContinuousBeams.lua').InstallBeam(HostBeam)", "return {\n    CreateHostBeam = CreateHostBeam\n}")),
				CreateMutation(cache, "LJ/lua/host/units/weaponsClasses/muzzleClass.lua", "release destroyed muzzle registry entries", PatchHostMuzzleDeletion),
				CreateMutation(cache, "LJ/lua/client/units/weaponsClasses/clientMuzzleClass.lua", "Supreme Commander artillery client muzzle and recoil parity", (string source) => AppendReviewedRuntime(PatchFaArtilleryClientMuzzle(source), LoadEmbeddedText("ScomFieldFixes.Roster.beam_muzzle_runtime.lua"), "return {\n    RegisterClientMuzzle = RegisterClientMuzzle,")),
				CreateMutation(cache, "LJ/lua/client/entities/beam.lua", "source orbital beam reach and endpoint effect ownership", (string source) => AppendReviewedRuntime(PatchClientOrbitalBeamRange(source), LoadEmbeddedText("ScomFieldFixes.Roster.beam_endpoint_runtime.lua"), "return { ClientBeam = ClientBeam }")),
				CreateMutation(cache, "LJ/lua/client/entities/clientBeamFactory.lua", "source orbital beam follows aim for its host-owned lifetime", PatchClientOrbitalBeamFactory),
				CreateHostAssistMutation(cache, "ScomFieldFixes.strategic_silo_host_appendix.lua", "ScomFieldFixes.strategic_silo_state_host_bridge_appendix.lua", "ScomFieldFixes.strategic_silo_assist_appendix.lua", "ScomFieldFixes.tactical_missile_host_appendix.lua", "ScomFieldFixes.tactical_missile_commands_appendix.lua", "ScomFieldFixes.Roster.source_interception_runtime.lua", "ScomFieldFixes.Roster.MissingWeapons.runtime_registry.lua", "ScomFieldFixes.Roster.source_cargo_host.lua", "ScomFieldFixes.Roster.source_death_host.lua", "ScomFieldFixes.Roster.source_special_units_host.lua", "ScomFieldFixes.Roster.source_soothsayer_host.lua", "ScomFieldFixes.Roster.source_pods_host.lua", "ScomFieldFixes.Roster.source_hydro_construction.lua", "ScomFieldFixes.Roster.source_unit_modes_host.lua", "ScomFieldFixes.Roster.source_secondary_visuals_install.lua", "ScomFieldFixes.Roster.source_dynamic_visuals_install.lua", "ScomFieldFixes.Roster.source_seraphim_build_facing_host.lua", "ScomFieldFixes.mantis_assist_host_appendix.lua", "ScomFieldFixes.Roster.source_hive_autowork_host.lua", "ScomFieldFixes.Roster.source_yolona_missile_host.lua"),
				CreateMutation(cache, "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "strategic structure assistance and source submarine targeting", (string source) => AppendReviewedRuntime(AppendReviewedRuntime(AppendReviewedRuntime(source, LoadEmbeddedText("ScomFieldFixes.strategic_silo_structure_assist_appendix.lua")), LoadEmbeddedText("ScomFieldFixes.Roster.source_upgrade_host.lua")), "Import('common/systems/scoSourceSubmarineTargeting.lua').InstallNavalUnit(HostNavalUnit)")),
				CreateAppendMutation(cache, "LJ/lua/common/commands/definitions/buildQueue.lua", "validated strategic silo, rally, and toggle commands", "ScomFieldFixes.strategic_silo_commands_appendix.lua"),
				CreateAppendMutation(cache, "LJ/lua/host/managers/orders/hostOrderManager.lua", "cancel cargo reservations with native orders", "ScomFieldFixes.Roster.source_cargo_orders.lua"),
				CreateAppendSequenceMutation(cache, "LJ/lua/common/commands/definitions/units.lua", "resilient client intel and unit progress commands", "ScomFieldFixes.client_command_resilience_appendix.lua", "ScomFieldFixes.Roster.source_cargo_commands.lua", "ScomFieldFixes.Roster.source_special_units_commands.lua", "ScomFieldFixes.Roster.source_unit_modes_commands.lua", "ScomFieldFixes.Roster.source_pods_commands.lua", "ScomFieldFixes.Roster.source_dynamic_visuals_commands.lua", "ScomFieldFixes.FactoryEgress.factory_clearance_commands.lua"),
				CreateMutation(cache, "LJ/lua/client/inputEventsFunctions.lua", "Megalith combat routing, factory right-click, and strategic silo target input", PatchClientInputEvents),
				CreateAppendSequenceMutation(cache, "LJ/lua/client/clientListeners.lua", "strategic silo client-state listener", "ScomFieldFixes.strategic_silo_client_listener_appendix.lua", "ScomFieldFixes.tactical_missile_client_appendix.lua"),
				CreateAppendSequenceMutation(cache, "LJ/lua/client/input/inputActions.lua", "strategic silo Escape handling", "ScomFieldFixes.strategic_silo_escape_input_appendix.lua", "ScomFieldFixes.Roster.source_cargo_input.lua"),
				CreateAppendSequenceMutation(cache, "LJ/lua/client/ui/ordersPanel.lua", "strategic silo order buttons", "ScomFieldFixes.strategic_silo_orders_panel_appendix.lua", "ScomFieldFixes.Roster.source_cargo_panel.lua", "ScomFieldFixes.Roster.source_unit_modes_panel.lua", "ScomFieldFixes.Roster.source_pods_panel.lua"),
				CreateMutation(cache, "LJ/lua/host/collisionUpdate.lua", "strategic silo collision and Supreme Commander friendly splash", (string source) => AppendReviewedRuntime(AppendReviewedRuntime(AppendReviewedRuntime(PatchFaArtilleryCollisionUpdate(source), LoadEmbeddedText("ScomFieldFixes.tactical_missile_collision_appendix.lua"), "return {\n    CollisionUpdate = CollisionUpdate,"), LoadEmbeddedText("ScomFieldFixes.Roster.source_interception_collision.lua"), "return {\n    CollisionUpdate = CollisionUpdate,"), "-- SCOM source aircraft crash collision installation 1.0.0\nCollisionUpdate = Import('common/systems/scoMissingCrash.lua').WrapCollisionUpdate(CollisionUpdate, ProcessAreaDamage)\nProcessRayCollisionEvent = Import('common/systems/scoSourceProjectileMotion.lua').WrapRayCollision(ProcessRayCollisionEvent)\nlocal sourceMotionCollision = CollisionUpdate\nCollisionUpdate = function(...)\n    sourceMotionCollision(...)\n    Import('common/systems/scoSourceProjectileMotion.lua').TickDamage()\nend", "return {\n    CollisionUpdate = CollisionUpdate,")),
				CreateAppendMutation(cache, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Hoplite source death animation", "ScomFieldFixes.Roster.Animation.unitsDefaultGuard.ugl2101.lua"),
				CreateAppendMutation(cache, "LJ/lua/host/units/unitsClasses/unitsDefaultChosen.lua", "Aeon host lifecycle", "ScomFieldFixes.host_chosen_appendix.lua"),
				CreateAppendMutation(cache, "LJ/lua/client/units/unitsClasses/unitsDefaultChosen.lua", "Aeon client presentation", "ScomFieldFixes.client_chosen_appendix.lua"),
				CreateAppendMutation(cache, "LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua", "Seraphim host lifecycle", "ScomFieldFixes.host_seraphim_appendix.lua"),
				CreateAppendMutation(cache, "LJ/lua/client/units/unitsClasses/unitsDefaultSeraphim.lua", "Seraphim client presentation", "ScomFieldFixes.client_seraphim_appendix.lua")
			};
			CacheMutation[] array3 = obj;
			CacheMutation[] coreMutations = obj;
			array = array3;
			int num = Array.FindIndex(coreMutations, (CacheMutation mutation) => mutation.Resource.Path.Replace('\\', '/').EndsWith("/LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", StringComparison.OrdinalIgnoreCase));
			string edaSource = coreMutations[num].NewSource;
			coreMutations[num] = CreateMutation(cache, "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", "UEF source lifecycle animations", (string source) => AppendReviewedRuntime(edaSource, LoadEmbeddedText("ScomFieldFixes.Roster.Animation.unitsDefaultEDA.uen3001.lua")));
			CacheMutation[] array4 = TacticalMissileContracts.UnitIds.Union<string>(RosterContracts.ExistingIds, StringComparer.Ordinal).Select(delegate(string id)
			{
				string path = "LJ/lua/common/units/unitsTemplates/" + id + "/" + id + ".santp";
				CacheMutation upstream = coreMutations.SingleOrDefault((CacheMutation mutation) => mutation.Resource.Path.Replace('\\', '/').EndsWith("/" + path, StringComparison.OrdinalIgnoreCase));
				return CreateMutation(cache, path, "source unit completion " + id, (string source) => PatchSourceUnitCompletion(upstream?.NewSource ?? source, id));
			}).ToArray();
			HashSet<string> completedPaths = new HashSet<string>(array4.Select((CacheMutation mutation) => mutation.Resource.Path), StringComparer.OrdinalIgnoreCase);
			CacheMutation[] projectileParents;
			array = (projectileParents = coreMutations.Where((CacheMutation mutation) => !completedPaths.Contains(mutation.Resource.Path)).Concat<CacheMutation>(array4).ToArray());
			CacheMutation[] array5 = new string[6] { "pxd003", "pei241", "pgr305t", "psu404s", "pep305", "pgd471" }.Where((string id) => TryGetCachedResource(cache, "LJ/lua/common/projectiles/projectilesTemplates/" + id + "/" + id + ".santp") != null).Select(delegate(string id)
			{
				string path = "LJ/lua/common/projectiles/projectilesTemplates/" + id + "/" + id + ".santp";
				CacheMutation upstream = projectileParents.FirstOrDefault((CacheMutation mutation) => mutation.Resource.Path.Replace('\\', '/').EndsWith("/" + path, StringComparison.OrdinalIgnoreCase));
				return CreateMutation(cache, path, "source projectile visual completion " + id, (string source) => PatchExistingSourceProjectile(upstream?.NewSource ?? source, id));
			}).ToArray();
			HashSet<string> completedProjectilePaths = new HashSet<string>(array5.Select((CacheMutation mutation) => mutation.Resource.Path), StringComparer.OrdinalIgnoreCase);
			CacheMutation[] supportParents;
			array = (supportParents = projectileParents.Where((CacheMutation mutation) => !completedProjectilePaths.Contains(mutation.Resource.Path)).Concat<CacheMutation>(array5).ToArray());
			CacheMutation[] array6 = SupportCommanderIntegration.CachePaths.Select(delegate(string path)
			{
				CacheMutation upstream = supportParents.SingleOrDefault((CacheMutation mutation) => mutation.Resource.Path.Replace('\\', '/').EndsWith("/" + path, StringComparison.OrdinalIgnoreCase));
				return CreateMutation(cache, path, "source support commander enhancements", (string source) => SupportCommanderIntegration.Patch(path, upstream?.NewSource ?? source));
			}).ToArray();
			HashSet<string> supportPaths = new HashSet<string>(array6.Select((CacheMutation mutation) => mutation.Resource.Path), StringComparer.OrdinalIgnoreCase);
			CacheMutation[] factoryParents;
			array = (factoryParents = supportParents.Where((CacheMutation mutation) => !supportPaths.Contains(mutation.Resource.Path)).Concat<CacheMutation>(array6).ToArray());
			CacheMutation[] array7 = new string[4] { "unitsDefaultEDA", "unitsDefaultGuard", "unitsDefaultChosen", "unitsDefaultSeraphim" }.Select(delegate(string name)
			{
				string path = "LJ/lua/host/units/unitsClasses/" + name + ".lua";
				CacheMutation upstream = factoryParents.SingleOrDefault((CacheMutation mutation) => mutation.Resource.Path.Replace('\\', '/').EndsWith("/" + path, StringComparison.OrdinalIgnoreCase));
				return CreateMutation(cache, path, "source factory egress " + name, (string source) => AppendReviewedRuntime(upstream?.NewSource ?? source, LoadEmbeddedText("ScomFieldFixes.FactoryEgress." + name + ".lua")));
			}).ToArray();
			HashSet<string> factoryPaths = new HashSet<string>(array7.Select((CacheMutation mutation) => mutation.Resource.Path), StringComparer.OrdinalIgnoreCase);
			array = factoryParents.Where((CacheMutation mutation) => !factoryPaths.Contains(mutation.Resource.Path)).Concat<CacheMutation>(array7).ToArray();
			string[] array8 = (from name in typeof(CachePatcherRuntime).Assembly.GetManifestResourceNames()
				where name.StartsWith("ScomFieldFixes.Tarmac.Decal.", StringComparison.Ordinal) && name.EndsWith(".sandecal", StringComparison.Ordinal)
				select name).OrderBy<string, string>((string name) => name, StringComparer.Ordinal).ToArray();
			if (array8.Length != 24)
			{
				throw new InvalidOperationException("Faction tarmac decal resource coverage drifted.");
			}
			array2 = new CacheInsertion[26]
			{
				CreateInsertion(cache, "LJ/lua/common/units/unitsTemplates/ucl9505/ucl9505.santp", "native Chosen T5 Creative unit", "ScomFieldFixes.NativeChosen.ucl9505.santp"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoFactionTarmacs.lua", "source faction tarmac presentation", "ScomFieldFixes.Tarmac.runtime.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoFactoryEgress.lua", "source factory egress lifecycle", "ScomFieldFixes.FactoryEgress.factory_egress_host.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoFactoryProductBounds.lua", "measured factory product clearance", "ScomFieldFixes.FactoryEgress.factory_product_bounds.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoSourceWeaponRuntime.lua", "source weapon lifecycle module", "ScomFieldFixes.Roster.source_weapon_runtime.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoSourceHydroPlacement.lua", "source hydro deposit requirements", "ScomFieldFixes.Roster.source_hydro_placement.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoSourceUnitModes.lua", "source weapon modes and construction weapon restrictions", "ScomFieldFixes.Roster.source_unit_modes.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoSourceSecondaryVisuals.lua", "source rotator lifecycle", "ScomFieldFixes.Roster.source_secondary_visuals_host.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoSourceDynamicVisuals.lua", "source wing and weapon visual phases", "ScomFieldFixes.Roster.source_dynamic_visuals_host.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoSourceSpecialWeapons.lua", "source orbital and residual weapon module", "ScomFieldFixes.Roster.source_special_weapons.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoConstructionTarget.lua", "visible structure construction targets", "ScomFieldFixes.construction_target.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoSourceContinuousBeams.lua", "source continuous beam ownership", "ScomFieldFixes.Roster.source_continuous_beams.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoSourceProjectileMotion.lua", "source projectile motion lifecycle", "ScomFieldFixes.Roster.source_projectile_motion.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoTorpedoVisuals.lua", "shared offensive torpedo model and wake", "ScomFieldFixes.Roster.source_torpedo_visuals.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoTorpedoWeapons.lua", "torpedo dispatch water and firing layer gates", "ScomFieldFixes.Roster.source_torpedo_weapons.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoSourceSubmarineTargeting.lua", "source submarine hull targeting", "ScomFieldFixes.Roster.source_submarine_targeting.lua"),
				CreateInsertion(cache, "LJ/lua/host/units/unitsClasses/scoAtlantisCarrier.lua", "Atlantis paid production and submarine lifecycle", "ScomFieldFixes.Roster.atlantis_carrier_host.lua"),
				CreateInsertion(cache, "LJ/lua/client/units/unitsClasses/scoAtlantisCarrier.lua", "Atlantis mobile submarine presentation", "ScomFieldFixes.Roster.atlantis_carrier_client.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoSourceProjectileMotionContract.lua", "source projectile motion identity registry", "ScomFieldFixes.Roster.source_projectile_motion_contract.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoMissingCrash.lua", "source aircraft crash lifecycle module", "ScomFieldFixes.Roster.source_missing_crash_runtime.lua"),
				CreateInsertion(cache, "LJ/lua/common/systems/scoMissingCrashRegistry.lua", "source aircraft crash identity registry", "ScomFieldFixes.Roster.MissingWeapons.crash_registry.lua"),
				CreateInsertion(cache, "LJ/lua/common/projectiles/projectilesTemplates/psu404s/psu404s.santp", "dedicated Ythotha Sinn-Uthe projectile template", "ScomFieldFixes.psu404s.santp"),
				CreateInsertion(cache, "Environment/SCOM/Footsteps/colossus_left.sandecal", "SCOM ground footprint decal", "ScomFieldFixes.Footsteps.Decal.colossus_left.sandecal"),
				CreateInsertion(cache, "Environment/SCOM/Footsteps/colossus_right.sandecal", "SCOM ground footprint decal", "ScomFieldFixes.Footsteps.Decal.colossus_right.sandecal"),
				CreateInsertion(cache, "Environment/SCOM/Footsteps/commander.sandecal", "SCOM ground footprint decal", "ScomFieldFixes.Footsteps.Decal.commander.sandecal"),
				CreateInsertion(cache, "Environment/SCOM/Footsteps/contact.sandecal", "SCOM ground footprint decal", "ScomFieldFixes.Footsteps.Decal.contact.sandecal")
			}.Concat<CacheInsertion>(array8.Select((string resource) => CreateInsertion(cache, "Environment/SCOM/Tarmacs/" + resource.Substring("ScomFieldFixes.Tarmac.Decal.".Length), "source faction tarmac decal", resource))).Concat<CacheInsertion>(NukeProjectiles.Select(((string Path, string Resource) projectile) => CreateInsertion(cache, projectile.Path, "dedicated strategic nuke projectile template", projectile.Resource))).Concat<CacheInsertion>(ArtilleryProjectiles.Select(((string Path, string Resource) projectile) => CreateInsertion(cache, projectile.Path, "dedicated Supreme Commander artillery projectile template", projectile.Resource)))
				.Concat<CacheInsertion>(TacticalMissileContracts.ProjectileIds.Select((string id) => CreateInsertion(cache, "LJ/lua/common/projectiles/projectilesTemplates/" + id + "/" + id + ".santp", "source tactical projectile " + id, "ScomFieldFixes.Tactical." + id + ".santp")))
				.Concat<CacheInsertion>(from id in RosterContracts.ProjectileIds
					where id != "pxd003"
					select CreateInsertion(cache, "LJ/lua/common/projectiles/projectilesTemplates/" + id + "/" + id + ".santp", "source roster projectile " + id, "ScomFieldFixes.Roster.Projectile." + id + ".santp"))
				.Concat<CacheInsertion>(RosterContracts.NewIds.Select((string id) => CreateInsertion(cache, "LJ/lua/common/units/unitsTemplates/" + id + "/" + id + ".santp", "source roster unit " + id, "ScomFieldFixes.Roster.Unit." + id + ".santp")))
				.ToArray();
			ClearLuaCacheLookupIndex();
			if (array.All((CacheMutation mutation) => !mutation.NeedsWrite) && array2.All((CacheInsertion insertion) => !insertion.NeedsWrite))
			{
				isApplied = true;
				Log("All reviewed field-fix cache mutations are already active.");
				return;
			}
			foreach (CacheMutation item4 in array.Where((CacheMutation cacheMutation2) => cacheMutation2.NeedsWrite))
			{
				item4.Replacement = CreateNativeArray(item4.Resource.Value.GetType(), item4.NewSource);
			}
			foreach (CacheInsertion item5 in array2.Where((CacheInsertion cacheInsertion2) => cacheInsertion2.NeedsWrite))
			{
				item5.Replacement = CreateNativeArray(item5.ResourceType, item5.NewSource);
			}
			foreach (CacheMutation item6 in array.Where((CacheMutation cacheMutation2) => cacheMutation2.NeedsWrite))
			{
				item6.Assigned = true;
				SetCachedResource(cache, item6.Resource.Path, item6.Replacement);
				if (!string.Equals(ReadText(GetExactCachedResource(cache, item6.Resource.Path)), item6.NewSource, StringComparison.Ordinal))
				{
					throw new InvalidOperationException(item6.Description + " cache write verification failed.");
				}
			}
			foreach (CacheInsertion item7 in array2.Where((CacheInsertion cacheInsertion2) => cacheInsertion2.NeedsWrite))
			{
				item7.Assigned = true;
				SetCachedResource(cache, item7.Path, item7.Replacement);
				if (!string.Equals(ReadText(GetExactCachedResource(cache, item7.Path)), item7.NewSource, StringComparison.Ordinal))
				{
					throw new InvalidOperationException(item7.Description + " cache insertion verification failed.");
				}
			}
			if (array2.Any((CacheInsertion insertion) => insertion.Assigned))
			{
				RebuildLuaDirectoryIndex();
			}
			foreach (CacheMutation item8 in array.Where((CacheMutation cacheMutation2) => cacheMutation2.NeedsWrite))
			{
				TryDispose(item8.Resource.Value, "replaced " + item8.Description);
			}
			isApplied = true;
			Log("Committed the field-report template, placement, survival, and lifecycle transaction.");
		}
		catch (Exception ex)
		{
			ClearLuaCacheLookupIndex();
			List<Exception> list = new List<Exception>();
			bool flag = array2.Any((CacheInsertion insertion) => insertion.Assigned);
			if (cache != null)
			{
				foreach (CacheInsertion item9 in array2.Reverse())
				{
					if (!item9.Assigned)
					{
						continue;
					}
					try
					{
						RemoveCachedResource(cache, item9.Path);
						if (ContainsExactCachedPath(cache, item9.Path))
						{
							throw new InvalidOperationException(item9.Description + " cache insertion rollback verification failed.");
						}
						item9.Assigned = false;
					}
					catch (Exception item)
					{
						list.Add(item);
					}
				}
				if (flag)
				{
					try
					{
						RebuildLuaDirectoryIndex();
					}
					catch (Exception item2)
					{
						list.Add(item2);
					}
				}
				foreach (CacheMutation item10 in array.Reverse())
				{
					if (!item10.Assigned)
					{
						continue;
					}
					try
					{
						SetCachedResource(cache, item10.Resource.Path, item10.Resource.Value);
						if (!string.Equals(ReadText(GetExactCachedResource(cache, item10.Resource.Path)), item10.OldSource, StringComparison.Ordinal))
						{
							throw new InvalidOperationException(item10.Description + " cache rollback verification failed.");
						}
						item10.Assigned = false;
					}
					catch (Exception item3)
					{
						list.Add(item3);
					}
				}
			}
			CacheMutation[] array3 = array;
			foreach (CacheMutation cacheMutation in array3)
			{
				if (!cacheMutation.Assigned && cacheMutation.Replacement != null)
				{
					TryDispose(cacheMutation.Replacement, "rolled-back " + cacheMutation.Description);
				}
			}
			CacheInsertion[] array9 = array2;
			foreach (CacheInsertion cacheInsertion in array9)
			{
				if (!cacheInsertion.Assigned && cacheInsertion.Replacement != null)
				{
					TryDispose(cacheInsertion.Replacement, "rolled-back " + cacheInsertion.Description);
				}
			}
			isApplied = false;
			if (list.Count != 0)
			{
				Log("Mutation failed and rollback was incomplete: " + ex.GetBaseException().Message);
				throw new AggregateException("Field-fix mutation and rollback both failed.", new Exception[1] { ex }.Concat(list));
			}
			Log("Canonical field-fix transaction failed after a complete rollback: " + ex.GetBaseException().Message);
			throw;
		}
	}

	private static void CommitStartupCriticalTemplatePolicy(object cache)
	{
		if (isStartupCriticalApplied)
		{
			return;
		}
		CacheMutation cacheMutation = CreateMutation(cache, "LJ/lua/common/loading/unitTemplateLoader.lua", "startup-critical unit-template and prefab policy", PatchUnitTemplateLoader);
		if (!cacheMutation.NeedsWrite)
		{
			isStartupCriticalApplied = true;
			Log("The startup-critical unit-template and prefab policy is already active.");
			return;
		}
		cacheMutation.Replacement = CreateNativeArray(cacheMutation.Resource.Value.GetType(), cacheMutation.NewSource);
		try
		{
			cacheMutation.Assigned = true;
			SetCachedResource(cache, cacheMutation.Resource.Path, cacheMutation.Replacement);
			if (!string.Equals(ReadText(GetExactCachedResource(cache, cacheMutation.Resource.Path)), cacheMutation.NewSource, StringComparison.Ordinal))
			{
				throw new InvalidOperationException(cacheMutation.Description + " cache write verification failed.");
			}
			TryDispose(cacheMutation.Resource.Value, "replaced " + cacheMutation.Description);
			isStartupCriticalApplied = true;
			Log("Committed the startup-critical unit-template and prefab transaction.");
		}
		catch (Exception ex)
		{
			List<Exception> list = new List<Exception>();
			if (cacheMutation.Assigned)
			{
				try
				{
					SetCachedResource(cache, cacheMutation.Resource.Path, cacheMutation.Resource.Value);
					if (!string.Equals(ReadText(GetExactCachedResource(cache, cacheMutation.Resource.Path)), cacheMutation.OldSource, StringComparison.Ordinal))
					{
						throw new InvalidOperationException(cacheMutation.Description + " cache rollback verification failed.");
					}
					cacheMutation.Assigned = false;
				}
				catch (Exception item)
				{
					list.Add(item);
				}
			}
			if (!cacheMutation.Assigned && cacheMutation.Replacement != null)
			{
				TryDispose(cacheMutation.Replacement, "rolled-back " + cacheMutation.Description);
			}
			if (list.Count != 0)
			{
				throw new AggregateException("Startup-critical template mutation and rollback both failed.", new Exception[1] { ex }.Concat(list));
			}
			throw;
		}
	}

	private static string PatchUnitTemplateLoader(string source)
	{
		string source2 = PatchCommanderProgressDescriptors(Normalize(source));
		if (Count(source2, "-- Supreme Commander Overhaul field fixes 1.0.0") == 1)
		{
			string source3 = PatchSourceFinalTemplatePolicy(source2);
			ValidateUnitTemplateLoader(source3);
			return CacheCompatibilityRepair.AppendStartupDiagnostics(ConstructionBeamPalette.PatchUnitLoader(source3));
		}
		RequireExactly(source2, "-- Supreme Commander Overhaul field fixes 1.0.0", 0, "preexisting field-fix loader marker");
		RequireExactly(source2, "-- Supreme Commander Overhaul construction beam faction palette 1.3.3", 1, "Gameplay Corrections 1.3.3 palette marker");
		RequireExactly(source2, "-- SCOM Field Fix: isolated Galactic Colossus eye calibration 1.0.2", 1, "isolated Galactic Colossus loader marker");
		RequireExactly(source2, "function CreateUnitPrefab(tp)", 4, "upstream wrapped prefab loaders");
		source2 = PatchStrategicSiloMuzzleSimulation(source2);
		source2 = PatchSourceAnimationPlayback(source2);
		string appendix = string.Join("\n\n", "-- Supreme Commander Overhaul field fixes 1.0.0", LoadEmbeddedText("ScomFieldFixes.universal_uef.lua").Trim(), LoadEmbeddedText("ScomFieldFixes.cybran.lua").Trim(), LoadEmbeddedText("ScomFieldFixes.aeon_seraphim.lua").Trim(), LoadEmbeddedText("ScomFieldFixes.prefab_validation_policy.lua").Trim(), LoadEmbeddedText("ScomFieldFixes.template_loader_appendix.lua").Trim()) + "\n";
		string source4 = PatchSourceFinalTemplatePolicy(Append(source2, appendix));
		ValidateUnitTemplateLoader(source4);
		return CacheCompatibilityRepair.AppendStartupDiagnostics(ConstructionBeamPalette.PatchUnitLoader(source4));
	}

	private static string PatchCommanderProgressDescriptors(string source)
	{
		RequireExactly(source, "    table.insert(progressBarsTemplates, EngineClasses.ProgressBarsTemplate(TemplateHeadEntityName, progressBarsList, 1.0, false))", 1, "native progress-bar composition boundary");
		if (Count(source, "-- SCOM commander native progress descriptors 1.0.0") == 1)
		{
			RequireExactly(source, "tp.scoNativeProgressBars = table.deepCopy(progressBarsList)", 1, "commander native progress descriptor capture");
			return source;
		}
		RequireExactly(source, "-- SCOM commander native progress descriptors 1.0.0", 0, "preexisting commander progress descriptor marker");
		string text = "    -- SCOM commander native progress descriptors 1.0.0\n    if tp.general.tpId == \"uel0000\" or tp.general.tpId == \"ucl0000\"\n        or tp.general.tpId == \"ugl0000\" or tp.general.tpId == \"usl0000\"\n    then\n        tp.scoNativeProgressBars = table.deepCopy(progressBarsList)\n    end\n";
		return source.Replace("    table.insert(progressBarsTemplates, EngineClasses.ProgressBarsTemplate(TemplateHeadEntityName, progressBarsList, 1.0, false))", text + "    table.insert(progressBarsTemplates, EngineClasses.ProgressBarsTemplate(TemplateHeadEntityName, progressBarsList, 1.0, false))");
	}

	private static string PatchSourceFinalTemplatePolicy(string source)
	{
		StringBuilder stringBuilder = new StringBuilder("-- SCOM source final template policy 1.1.0\nSCO_SourceFinalizerOwnsIdleResetTurretRest = true\nlocal SCO_SourceFinalizers = {}\n");
		string[] array = new string[17]
		{
			"ScomFieldFixes.Roster.Weapons.", "ScomFieldFixes.Roster.Aim.", "ScomFieldFixes.Roster.MissingWeapons.", "ScomFieldFixes.Roster.Interception.", "ScomFieldFixes.Roster.Beams.", "ScomFieldFixes.Roster.Muzzles.", "ScomFieldFixes.Roster.Special.", "ScomFieldFixes.Roster.Hydro.", "ScomFieldFixes.Roster.Soothsayer.", "ScomFieldFixes.Roster.Modes.",
			"ScomFieldFixes.Roster.Pods.", "ScomFieldFixes.Roster.Secondary.", "ScomFieldFixes.Roster.Support.", "ScomFieldFixes.Roster.Dynamic.", "ScomFieldFixes.FactoryEgress.Template.", "ScomFieldFixes.FactoryEgress.Routing.", "ScomFieldFixes.FactoryEgress.Posture."
		};
		foreach (string prefix in array)
		{
			foreach (string item in (from name in typeof(CachePatcherRuntime).Assembly.GetManifestResourceNames()
				where name.StartsWith(prefix, StringComparison.Ordinal) && name.EndsWith(".lua", StringComparison.Ordinal)
				where !name.EndsWith(".crash_registry.lua", StringComparison.Ordinal) && !name.EndsWith(".runtime_registry.lua", StringComparison.Ordinal)
				where prefix != "ScomFieldFixes.Roster.Interception." || name.Substring(prefix.Length).StartsWith("u", StringComparison.Ordinal)
				select name).OrderBy<string, string>((string name) => name, StringComparer.Ordinal))
			{
				string value = item.Substring(prefix.Length, item.Length - prefix.Length - 4);
				stringBuilder.Append("do\nlocal previous = SCO_SourceFinalizers['").Append(value).Append("']\n")
					.Append("SCO_SourceFinalizers['")
					.Append(value)
					.Append("'] = function(UnitTemplate)\n")
					.Append("if previous then previous(UnitTemplate) end\n")
					.Append(LoadEmbeddedText(item))
					.Append("\nend\nend\n");
			}
		}
		stringBuilder.Append(LoadEmbeddedText("ScomFieldFixes.source_commander_storage.lua")).Append("\n");
		stringBuilder.Append(LoadEmbeddedText("ScomFieldFixes.Roster.source_air_death_visuals.lua")).Append("\n");
		stringBuilder.Append(LoadEmbeddedText("ScomFieldFixes.Roster.source_torpedo_templates.lua")).Append("\n");
		stringBuilder.Append(LoadEmbeddedText("ScomFieldFixes.Roster.source_commander_muzzle_visuals.lua")).Append("\n");
		stringBuilder.Append(LoadEmbeddedText("ScomFieldFixes.Roster.atlantis_cargo_template.lua")).Append("\n");
		stringBuilder.Append("function SCO_SourceFinalizeTemplate(tp)\n").Append("    local finalizer = SCO_SourceFinalizers[tp.general.tpId]\n").Append("    if finalizer then finalizer(tp) end\n")
			.Append("    SCO_ApplyCommanderStorage(tp)\n")
			.Append("    SCO_ApplyAirDeathVisuals(tp)\n    SCO_ApplyAeonDeathSmokeVisuals(tp)\n")
			.Append("    SCO_ApplyStructureAnimationPolicy(tp)\n")
			.Append("    SCO_ApplySourceUpgradeLinks(tp)\n")
			.Append("    SCO_ApplySourceWeaponAudio(tp)\n")
			.Append("    Import('common/systems/scoSourceSubmarineTargeting.lua').PrepareTemplate(tp)\n")
			.Append("    SCO_ApplyTorpedoWeapons(tp)\n")
			.Append("    SCO_ApplyCommanderMuzzleVisuals(tp)\n")
			.Append("    SCO_ApplyAtlantisCarrier(tp)\n")
			.Append("    -- Restrict replacement-faction construction after every source rewrite.\n")
			.Append("    local tags = {}\n")
			.Append("    for _, tag in ipairs(tp.tags or {}) do tags[tag] = true end\n")
			.Append("    if not tags.PROMETHEAN and (tags.EDA or tags.CHOSEN or tags.GUARD or tags.SERAPHIM) then\n")
			.Append("        if not tags.SCFA_ALLUNITS and tp.general.tpId ~= 'ucl9505' then\n")
			.Append("            Import('common/units/availableUnits.lua').AvailableUnits[tp.general.tpId] = nil\n")
			.Append("        end\n")
			.Append("        local construction = tp.construction\n")
			.Append("        if construction and construction.canBuild ~= nil then\n")
			.Append("            assert(type(construction.canBuild) == 'string', 'Invalid SCOM construction category')\n")
			.Append("            local suffix = ' * Tags.SCFA_ALLUNITS'\n")
			.Append("            if construction.canBuild:sub(-#suffix) ~= suffix then\n")
			.Append("                construction.canBuild = '(' .. construction.canBuild .. ')' .. suffix\n")
			.Append("            end\n")
			.Append("        end\n")
			.Append("    end\n")
			.Append("    SCO_IdleResetFinalizeSourceTemplate(tp)\n    SCO_FieldFixPostSourceUnitCorrections(tp)\n    -- SCOM Fatboy private template module 1.0.0\n    if tp.general.tpId == \"uel4511\" then\n        local candidate, applied = SCOMUnitLibrary.ConfigureTemplate(tp, \"scom/units/uel4511/template.lua\")\n        if applied then\n            -- Native class and range registries retain these immutable branches.\n            candidate.general = tp.general\n            candidate.ranges = tp.ranges\n            -- Preserve the original template object held by the native loader.\n            -- Validation finished on a detached candidate; this commit cannot yield.\n            for key in pairs(tp) do tp[key] = nil end\n            for key, value in pairs(candidate) do tp[key] = value end\n        end\n    end\n")
			.Append("end\n");
		string text = stringBuilder.ToString();
		RequireExactly(text, "-- The EyeWeapon's own one-shot land impact makes the death damage pulse visible.\nUnitTemplate.additions.scoSpecial.effects.deathPulse = {path=\"VFX/SCOM/Source/psf0125/impact_land.sanvfx\",bone=\"Root\",offset={0,0,0},loop=false}\n", 1, "Ythotha death pulse template contract");
		if (Count(source, "-- SCOM source final template policy 1.1.0") == 1 && Count(source, text) == 0)
		{
			string text2 = text.Replace("-- The EyeWeapon's own one-shot land impact makes the death damage pulse visible.\nUnitTemplate.additions.scoSpecial.effects.deathPulse = {path=\"VFX/SCOM/Source/psf0125/impact_land.sanvfx\",bone=\"Root\",offset={0,0,0},loop=false}\n", "");
			RequireExactly(source, text2, 1, "previous source finalizer for Ythotha death pulse migration");
			source = source.Replace(text2, text);
		}
		if (Count(source, "-- SCOM source final template policy 1.1.0") == 0)
		{
			RequireExactly(source, "-- SCOM source final template policy ", 0, "preexisting source finalizer marker family");
			int num = source.IndexOf("function CreateUnitPrefab(tp)\n", StringComparison.Ordinal);
			if (num < 0)
			{
				throw new InvalidOperationException("Native prefab entry missing");
			}
			source = Append(source.Insert(num + "function CreateUnitPrefab(tp)\n".Length, "    SCO_SourceFinalizeTemplate(tp)\n    SCO_ApplyCommanderWeaponBrightness(tp)\n"), text);
		}
		RequireExactly(source, text, 1, "source finalizer definitions");
		RequireExactly(source, "    SCO_SourceFinalizeTemplate(tp)\n    SCO_ApplyCommanderWeaponBrightness(tp)\n", 1, "native source finalizer invocation");
		source = AppendReviewedRuntime(source, LoadEmbeddedText("ScomFieldFixes.Roster.source_structure_animation_loader.lua"));
		source = AppendReviewedRuntime(source, LoadEmbeddedText("ScomFieldFixes.Roster.source_upgrade_loader.lua"));
		source = AppendReviewedRuntime(source, LoadEmbeddedText("ScomFieldFixes.Roster.source_audio_loader.lua"));
		source = AppendReviewedRuntime(source, LoadEmbeddedText("ScomFieldFixes.Roster.source_split_mesh_loader.lua"));
		source = AppendReviewedRuntime(source, LoadEmbeddedText("ScomFieldFixes.Roster.source_sniper_loader.lua"));
		source = AppendReviewedRuntime(source, LoadEmbeddedText("ScomFieldFixes.Roster.source_secondary_visuals_loader.lua"));
		source = AppendReviewedRuntime(source, LoadEmbeddedText("ScomFieldFixes.Roster.source_dynamic_visuals_loader.lua"));
		source = AppendReviewedRuntime(source, LoadEmbeddedText("ScomFieldFixes.Roster.uef_gunship_aim_loader.lua"));
		source = AppendReviewedRuntime(source, LoadEmbeddedText("ScomFieldFixes.FactoryEgress.factory_clearance_loader.lua"));
		source = AppendReviewedRuntime(source, LoadEmbeddedText("ScomFieldFixes.Roster.source_yolona_missile_loader.lua"));
		if (Count(source, "    meshPath = SCO_SourceBodyModel(tp, meshPath)\n") == 0)
		{
			RequireExactly(source, "    local meshPath = unitPath..\"_lod0.sanmodel\"\n", 1, "native source mesh path");
			source = source.Replace("    local meshPath = unitPath..\"_lod0.sanmodel\"\n", "    local meshPath = unitPath..\"_lod0.sanmodel\"\n    meshPath = SCO_SourceBodyModel(tp, meshPath)\n");
		}
		if (Count(source, "    SCO_SourceShellMeshes(tp, hierarchyEntities, skinnedMeshTemplates, skinnedMeshBoneTemplates,\n        lodTemplates, cullingTemplates, skeletonBones, renderDistance)\n\n") == 0)
		{
			RequireExactly(source, "    -- NOTE: As of 9/11/24, the following entity attachments are populated by Lua at runtime when creating a unit.", 1, "native source shell insertion point");
			source = source.Replace("    -- NOTE: As of 9/11/24, the following entity attachments are populated by Lua at runtime when creating a unit.", "    SCO_SourceShellMeshes(tp, hierarchyEntities, skinnedMeshTemplates, skinnedMeshBoneTemplates,\n        lodTemplates, cullingTemplates, skeletonBones, renderDistance)\n\n    -- NOTE: As of 9/11/24, the following entity attachments are populated by Lua at runtime when creating a unit.");
		}
		RequireExactly(source, "    meshPath = SCO_SourceBodyModel(tp, meshPath)\n", 1, "native source body model routing");
		RequireExactly(source, "    SCO_SourceShellMeshes(tp, hierarchyEntities, skinnedMeshTemplates, skinnedMeshBoneTemplates,\n        lodTemplates, cullingTemplates, skeletonBones, renderDistance)\n\n", 1, "native source shell renderer routing");
		if (Count(source, "    SCO_SourceSecondaryVisuals(tp, prefabTemplate)\n    SCO_SourceSniperPrefab(tp, prefabTemplate)\n    SCO_SourceDynamicVisuals(tp, prefabTemplate)\n    SCO_FactoryClearancePrefab(tp, prefabTemplate)\n") == 0)
		{
			RequireExactly(source, "    return Engine.CreatePrefab(prefabTemplate)", 1, "native secondary prefab insertion point");
			source = source.Replace("    return Engine.CreatePrefab(prefabTemplate)", "    SCO_SourceSecondaryVisuals(tp, prefabTemplate)\n    SCO_SourceSniperPrefab(tp, prefabTemplate)\n    SCO_SourceDynamicVisuals(tp, prefabTemplate)\n    SCO_FactoryClearancePrefab(tp, prefabTemplate)\n    return Engine.CreatePrefab(prefabTemplate)");
		}
		RequireExactly(source, "    SCO_SourceSecondaryVisuals(tp, prefabTemplate)\n    SCO_SourceSniperPrefab(tp, prefabTemplate)\n    SCO_SourceDynamicVisuals(tp, prefabTemplate)\n    SCO_FactoryClearancePrefab(tp, prefabTemplate)\n", 1, "native secondary visual routing");
		if (Count(source, "    SCO_SourcePodAttachments(tp, prefabTemplate)\n") == 0)
		{
			RequireExactly(source, "    SCO_FactoryClearancePrefab(tp, prefabTemplate)\n    return Engine.CreatePrefab(prefabTemplate)", 1, "Kennel pod attachment insertion point");
			source = source.Replace("    SCO_FactoryClearancePrefab(tp, prefabTemplate)\n    return Engine.CreatePrefab(prefabTemplate)", "    SCO_FactoryClearancePrefab(tp, prefabTemplate)\n    SCO_SourcePodAttachments(tp, prefabTemplate)\n    return Engine.CreatePrefab(prefabTemplate)");
		}
		RequireExactly(source, "    SCO_SourcePodAttachments(tp, prefabTemplate)\n", 1, "Kennel pod attachment routing");
		source = AppendReviewedRuntime(source, "-- SCOM Kennel host pod attachments 1.0.0\nfunction SCO_SourcePodAttachments(tp, prefab)\n    local id = tp.general.tpId\n    local expected = id == 'ues2501' and {'AttachSpecial01'}\n        or id == 'ues3501' and {'AttachSpecial01', 'AttachSpecial02'}\n    if not expected then return end\n    local config = tp.additions and tp.additions.scoSourcePods\n    assert(config and config.kind == 'tower' and config.targetId == id\n        and #config.slots == #expected, 'Kennel pod configuration drift: '..id)\n    local entities = {}\n    for _, entity in ipairs(prefab.hierarchyTemplate.entities) do\n        entities[entity.entityName] = entity\n    end\n    for index, bone in ipairs(expected) do\n        local entity = entities[bone]\n        assert(config.slots[index].bone == bone and entity\n            and entity.parentEntityName == 'B01', 'Kennel pod bone drift: '..id..'/'..bone)\n        entity.forceSimulated = true\n    end\nend\n");
		return source;
	}

	private static string PatchSourceAnimationPlayback(string source)
	{
		if (Count(source, "-- SCOM Field Fix: source animation playback mode 1.0.0") == 1)
		{
			RequireExactly(source, "                AnimationPlaybackMode.Loop,", 0, "unrouted animation playback-mode argument");
			RequireExactly(source, "                -- SCOM Field Fix: source animation playback mode 1.0.0\n                animationInfo.playbackMode or AnimationPlaybackMode.Loop,", 1, "source animation playback-mode routing");
			return source;
		}
		RequireExactly(source, "-- SCOM Field Fix: source animation playback mode 1.0.0", 0, "preexisting source animation playback marker");
		int num = Count(source, "                AnimationPlaybackMode.Loop,");
		int num2 = Count(source, "                animationInfo.playbackMode or AnimationPlaybackMode.Loop,");
		if (num == 1 && num2 == 0)
		{
			return source.Replace("                AnimationPlaybackMode.Loop,", "                -- SCOM Field Fix: source animation playback mode 1.0.0\n                animationInfo.playbackMode or AnimationPlaybackMode.Loop,");
		}
		if (num == 0 && num2 == 1)
		{
			return source.Replace("                animationInfo.playbackMode or AnimationPlaybackMode.Loop,", "                -- SCOM Field Fix: source animation playback mode 1.0.0\n                animationInfo.playbackMode or AnimationPlaybackMode.Loop,");
		}
		throw new InvalidOperationException("Animation playback-mode routing has unsupported stock/routed counts " + num + "/" + num2 + ".");
	}

	private static string PatchFactionTarmacClient(string source)
	{
		return AppendReviewedRuntime(source, "-- SCOM faction tarmacs 1.0.0\nImport(\"common/systems/scoFactionTarmacs.lua\").Install(ClientUnit)\n");
	}

	private static string PatchFactionTarmacPreload(string source)
	{
		RequireExactly(source, "_G.TarmacGuardPrefabID = DecalTemplateLoader.CreateDecalPrefab(\"Environment/Common/Decals/tarmac_guard.sandecal\")", 1, "native tarmac preload anchor");
		if (Count(source, "-- SCOM faction tarmacs 1.0.0") == 1)
		{
			RequireExactly(source, "Import(\"common/systems/scoFactionTarmacs.lua\").Initialize()", 1, "source faction tarmac preload");
			return source;
		}
		RequireExactly(source, "-- SCOM faction tarmacs 1.0.0", 0, "preexisting faction tarmac marker");
		RequireExactly(source, "Import(\"common/systems/scoFactionTarmacs.lua\").Initialize()", 0, "preexisting faction tarmac preload");
		return source.Replace("_G.TarmacGuardPrefabID = DecalTemplateLoader.CreateDecalPrefab(\"Environment/Common/Decals/tarmac_guard.sandecal\")", "_G.TarmacGuardPrefabID = DecalTemplateLoader.CreateDecalPrefab(\"Environment/Common/Decals/tarmac_guard.sandecal\")\n-- SCOM faction tarmacs 1.0.0\n    Import(\"common/systems/scoFactionTarmacs.lua\").Initialize()");
	}

	private static string PatchYolonaVfxLifetime(string source)
	{
		string text = Normalize(source);
		if (Count(text, "            vfxPath,\n            vfxPath ~= 'VFX/SCOM/Source/psf0136/impact.sanvfx',\n            true\n") == 1)
		{
			RequireExactly(text, "            vfxPath,\n            true,\n            true\n", 0, "unrouted Yolona VFX lifetime");
			return text;
		}
		RequireExactly(text, "            vfxPath,\n            true,\n            true\n", 1, "native VFX particle lifetime constructor");
		RequireExactly(text, "            vfxPath,\n            vfxPath ~= 'VFX/SCOM/Source/psf0136/impact.sanvfx',\n            true\n", 0, "preexisting Yolona VFX lifetime route");
		return text.Replace("            vfxPath,\n            true,\n            true\n", "            vfxPath,\n            vfxPath ~= 'VFX/SCOM/Source/psf0136/impact.sanvfx',\n            true\n");
	}

	private static string PatchFactionShieldPalette(string source)
	{
		string text = Normalize(source);
		if (Count(text, "-- SCOM faction shield palettes 1.0.0") == 1)
		{
			ValidateFactionShieldPalette(text);
			return text;
		}
		RequireExactly(text, "-- SCOM faction shield palettes 1.0.0", 0, "preexisting faction shield palette marker");
		RequireExactly(text, "    elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then\n        shieldMaterialPath = \"VFX/Shields/Shield Forcefield Chosen.sanmaterial\"", 1, "combined Aeon/Seraphim forcefield route");
		RequireExactly(text, "    elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then\n        glowMaterialPath = \"VFX/Shields/Shield Edge Detail Chosen.sanmaterial\"", 1, "combined Aeon/Seraphim shield-edge route");
		RequireExactly(text, "VFX/Shields/Shield Forcefield EDA.sanmaterial", 2, "native UEF forcefield routes");
		RequireExactly(text, "VFX/Shields/Shield Forcefield Guard.sanmaterial", 1, "native Cybran forcefield route");
		RequireExactly(text, "VFX/Shields/Shield Edge Detail EDA.sanmaterial", 2, "native UEF shield-edge routes");
		RequireExactly(text, "VFX/Shields/Shield Edge Detail Guard.sanmaterial", 1, "native Cybran shield-edge route");
		string text2 = Append(text.Replace("    elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then\n        shieldMaterialPath = \"VFX/Shields/Shield Forcefield Chosen.sanmaterial\"", "    elseif table.find(tp.tags, \"CHOSEN\") then\n        shieldMaterialPath = \"VFX/SCOM/FieldFixes/Shields/aeon_forcefield.sanmaterial\"\n    elseif table.find(tp.tags, \"SERAPHIM\") then\n        shieldMaterialPath = \"VFX/SCOM/FieldFixes/Shields/seraphim_forcefield.sanmaterial\"").Replace("    elseif table.find(tp.tags, \"CHOSEN\") or table.find(tp.tags, \"SERAPHIM\") then\n        glowMaterialPath = \"VFX/Shields/Shield Edge Detail Chosen.sanmaterial\"", "    elseif table.find(tp.tags, \"CHOSEN\") then\n        glowMaterialPath = \"VFX/SCOM/FieldFixes/Shields/aeon_edge.sanmaterial\"\n    elseif table.find(tp.tags, \"SERAPHIM\") then\n        glowMaterialPath = \"VFX/SCOM/FieldFixes/Shields/seraphim_edge.sanmaterial\"").Replace("VFX/Shields/Shield Forcefield EDA.sanmaterial", "VFX/SCOM/FieldFixes/Shields/uef_forcefield.sanmaterial")
			.Replace("VFX/Shields/Shield Forcefield Guard.sanmaterial", "VFX/SCOM/FieldFixes/Shields/cybran_forcefield.sanmaterial")
			.Replace("VFX/Shields/Shield Edge Detail EDA.sanmaterial", "VFX/SCOM/FieldFixes/Shields/uef_edge.sanmaterial")
			.Replace("VFX/Shields/Shield Edge Detail Guard.sanmaterial", "VFX/SCOM/FieldFixes/Shields/cybran_edge.sanmaterial"), "-- SCOM faction shield palettes 1.0.0\n");
		ValidateFactionShieldPalette(text2);
		return text2;
	}

	private static void ValidateFactionShieldPalette(string source)
	{
		RequireExactly(source, "-- SCOM faction shield palettes 1.0.0", 1, "faction shield palette marker");
		RequireExactly(source, "VFX/SCOM/FieldFixes/Shields/uef_forcefield.sanmaterial", 2, "UEF forcefield routes including the safe default");
		RequireExactly(source, "VFX/SCOM/FieldFixes/Shields/aeon_forcefield.sanmaterial", 1, "Aeon forcefield route");
		RequireExactly(source, "VFX/SCOM/FieldFixes/Shields/cybran_forcefield.sanmaterial", 1, "Cybran forcefield route");
		RequireExactly(source, "VFX/SCOM/FieldFixes/Shields/seraphim_forcefield.sanmaterial", 1, "Seraphim forcefield route");
		RequireExactly(source, "VFX/SCOM/FieldFixes/Shields/uef_edge.sanmaterial", 2, "UEF shield-edge routes including the safe default");
		RequireExactly(source, "VFX/SCOM/FieldFixes/Shields/aeon_edge.sanmaterial", 1, "Aeon shield-edge route");
		RequireExactly(source, "VFX/SCOM/FieldFixes/Shields/cybran_edge.sanmaterial", 1, "Cybran shield-edge route");
		RequireExactly(source, "VFX/SCOM/FieldFixes/Shields/seraphim_edge.sanmaterial", 1, "Seraphim shield-edge route");
		RequireExactly(source, "VFX/Shields/Shield Forcefield EDA.sanmaterial", 0, "unrouted native UEF forcefields");
		RequireExactly(source, "VFX/Shields/Shield Forcefield Chosen.sanmaterial", 0, "unrouted native Aeon forcefield");
		RequireExactly(source, "VFX/Shields/Shield Forcefield Guard.sanmaterial", 0, "unrouted native Cybran forcefield");
		RequireExactly(source, "VFX/Shields/Shield Edge Detail EDA.sanmaterial", 0, "unrouted native UEF shield edges");
		RequireExactly(source, "VFX/Shields/Shield Edge Detail Chosen.sanmaterial", 0, "unrouted native Aeon shield edge");
		RequireExactly(source, "VFX/Shields/Shield Edge Detail Guard.sanmaterial", 0, "unrouted native Cybran shield edge");
	}

	private static string PatchTemplateSystemLoader(string source)
	{
		string text = PatchLongestRangeRingPerMaterial(Normalize(source));
		text = text.Replace("            tp.buildingSmokeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(\"VFX/Death/vxd2321_death_building_large_smoke.sanvfx\")\n            tp.unitSmokeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(\"VFX/Death/vxd1321_death_unit_large_smoke.sanvfx\")", "-- SCOM Field Fix: Aeon mint death smoke 1.0.0\n            local buildingSmokeVFXPath = \"VFX/Death/vxd2321_death_building_large_smoke.sanvfx\"\n            local unitSmokeVFXPath = \"VFX/Death/vxd1321_death_unit_large_smoke.sanvfx\"\n            if tp.hasTags.SCFA_AEON then\n                buildingSmokeVFXPath = \"VFX/SCOM/FieldFixes/AeonDeathSmoke/building_large_smoke.sanvfx\"\n                unitSmokeVFXPath = \"VFX/SCOM/FieldFixes/AeonDeathSmoke/unit_large_smoke.sanvfx\"\n            end\n            tp.buildingSmokeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(buildingSmokeVFXPath)\n            tp.unitSmokeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(unitSmokeVFXPath)");
		RequireExactly(text, "-- SCOM Field Fix: Aeon mint death smoke 1.0.0\n", 1, "Aeon death smoke template routing");
		if (Count(text, "-- SCOM Field Fix: Apocalypse impact VFX and commander audio prefabs 1.1.0") == 1)
		{
			RequireExactly(text, "_G.SCO_ApocalypseNukeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(\"VFX/SCOM/Apocalypse/apoc_impact.sanvfx\")", 1, "Apocalypse impact prefab registration");
			RequireExactly(text, "local SCOApocalypseAudioPrefabLoader = Import(\"common/loading/audioPrefabLoader.lua\")", 1, "Apocalypse commander audio loader");
			RequireExactly(text, "_G.SCO_ApocalypseCommanderExplosionAudioPrefabID = SCOApocalypseAudioPrefabLoader.CreateOneShotAudioPrefab(\"SCOM_Apocalypse_CommanderExplosion\", \"acod0000\", \"impacts\")", 1, "Apocalypse commander audio prefab registration");
			string text2 = CacheCompatibilityRepair.AppendTypedEffectPreload(text).Replace("    CreateUnitWreckHierarchyMaps(Templates.Units, Templates.Props)\n\n    if #faultyTemplates > 0 then", "    CreateUnitWreckHierarchyMaps(Templates.Units, Templates.Props)\n\n    -- SCOM Field Fix: shared strategic nuke impact prefab 1.0.0\n    if IsClient then\n        Engine.LoadEffect(\"VFX/Impact/vei2401_missile_nuclear_impact.sanvfx\")\n    end\n    _G.SCO_StrategicNukeImpactVFXPrefabID =\n        VFXTemplateLoader.GetOrCreateVFXPrefab(\"VFX/Impact/vei2401_missile_nuclear_impact.sanvfx\")\n\n    if #faultyTemplates > 0 then");
			RequireExactly(text2, "-- SCOM Field Fix: shared strategic nuke impact prefab 1.0.0\n    if IsClient then\n        Engine.LoadEffect(\"VFX/Impact/vei2401_missile_nuclear_impact.sanvfx\")\n    end\n    _G.SCO_StrategicNukeImpactVFXPrefabID =\n        VFXTemplateLoader.GetOrCreateVFXPrefab(\"VFX/Impact/vei2401_missile_nuclear_impact.sanvfx\")", 1, "shared strategic nuke prefab registration");
			return text2;
		}
		RequireExactly(text, "-- SCOM Field Fix: Apocalypse impact VFX and commander audio prefabs 1.1.0", 0, "preexisting Apocalypse impact prefab marker");
		RequireExactly(text, "_G.NukeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(\"VFX/Death/vcd0301_death_rdu.sanvfx\")", 1, "stock nuke prefab registration");
		RequireExactly(text, "_G.SCO_ApocalypseNukeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(\"VFX/SCOM/Apocalypse/apoc_impact.sanvfx\")", 0, "preexisting Apocalypse impact prefab registration");
		RequireExactly(text, "local SCOApocalypseAudioPrefabLoader = Import(\"common/loading/audioPrefabLoader.lua\")", 0, "preexisting Apocalypse commander audio loader");
		RequireExactly(text, "_G.SCO_ApocalypseCommanderExplosionAudioPrefabID = SCOApocalypseAudioPrefabLoader.CreateOneShotAudioPrefab(\"SCOM_Apocalypse_CommanderExplosion\", \"acod0000\", \"impacts\")", 0, "preexisting Apocalypse commander audio prefab registration");
		string text3 = CacheCompatibilityRepair.AppendTypedEffectPreload(text.Replace("_G.NukeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(\"VFX/Death/vcd0301_death_rdu.sanvfx\")", "_G.NukeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(\"VFX/Death/vcd0301_death_rdu.sanvfx\")\n\n-- SCOM Field Fix: Apocalypse impact VFX and commander audio prefabs 1.1.0\n_G.SCO_ApocalypseNukeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(\"VFX/SCOM/Apocalypse/apoc_impact.sanvfx\")\nlocal SCOApocalypseAudioPrefabLoader = Import(\"common/loading/audioPrefabLoader.lua\")\n_G.SCO_ApocalypseCommanderExplosionAudioPrefabID = SCOApocalypseAudioPrefabLoader.CreateOneShotAudioPrefab(\"SCOM_Apocalypse_CommanderExplosion\", \"acod0000\", \"impacts\")")).Replace("    CreateUnitWreckHierarchyMaps(Templates.Units, Templates.Props)\n\n    if #faultyTemplates > 0 then", "    CreateUnitWreckHierarchyMaps(Templates.Units, Templates.Props)\n\n    -- SCOM Field Fix: shared strategic nuke impact prefab 1.0.0\n    if IsClient then\n        Engine.LoadEffect(\"VFX/Impact/vei2401_missile_nuclear_impact.sanvfx\")\n    end\n    _G.SCO_StrategicNukeImpactVFXPrefabID =\n        VFXTemplateLoader.GetOrCreateVFXPrefab(\"VFX/Impact/vei2401_missile_nuclear_impact.sanvfx\")\n\n    if #faultyTemplates > 0 then");
		RequireExactly(text3, "-- SCOM Field Fix: shared strategic nuke impact prefab 1.0.0\n    if IsClient then\n        Engine.LoadEffect(\"VFX/Impact/vei2401_missile_nuclear_impact.sanvfx\")\n    end\n    _G.SCO_StrategicNukeImpactVFXPrefabID =\n        VFXTemplateLoader.GetOrCreateVFXPrefab(\"VFX/Impact/vei2401_missile_nuclear_impact.sanvfx\")", 1, "shared strategic nuke prefab registration");
		return text3;
	}

	private static string PatchLongestRangeRingPerMaterial(string source)
	{
		if (Count(source, "-- SCOM Field Fix: longest range ring per material 1.0.0") == 1)
		{
			RequireExactly(source, "                local material = RangeRingMaterials.GetRangeRingMaterialByType(weapon.rangeRingType)\n                local currentRange = ranges[material]\n                -- SCOM Field Fix: longest range ring per material 1.0.0\n                if not currentRange or weapon.rangeMax > currentRange.outerRadius then\n                    ranges[material] = { outerRadius = weapon.rangeMax, innerRadius = weapon.rangeMin }\n                end", 1, "longest range-ring aggregation");
			RequireExactly(source, "                local material = RangeRingMaterials.GetRangeRingMaterialByType(weapon.rangeRingType)\n                ranges[material] = { outerRadius = weapon.rangeMax, innerRadius = weapon.rangeMin }", 0, "unpatched range-ring aggregation");
			return source;
		}
		RequireExactly(source, "-- SCOM Field Fix: longest range ring per material 1.0.0", 0, "preexisting longest range-ring marker");
		RequireExactly(source, "                local material = RangeRingMaterials.GetRangeRingMaterialByType(weapon.rangeRingType)\n                ranges[material] = { outerRadius = weapon.rangeMax, innerRadius = weapon.rangeMin }", 1, "stock range-ring aggregation");
		return source.Replace("                local material = RangeRingMaterials.GetRangeRingMaterialByType(weapon.rangeRingType)\n                ranges[material] = { outerRadius = weapon.rangeMax, innerRadius = weapon.rangeMin }", "                local material = RangeRingMaterials.GetRangeRingMaterialByType(weapon.rangeRingType)\n                local currentRange = ranges[material]\n                -- SCOM Field Fix: longest range ring per material 1.0.0\n                if not currentRange or weapon.rangeMax > currentRange.outerRadius then\n                    ranges[material] = { outerRadius = weapon.rangeMax, innerRadius = weapon.rangeMin }\n                end");
	}

	private static string PatchStrategicSiloMuzzleSimulation(string source)
	{
		RequireExactly(source, "-- SCOM Field Fix: strategic silo simulated muzzle 1.0.0", 0, "preexisting strategic silo simulated-muzzle marker");
		RequireExactly(source, "    local entityNameToHierarchyIndex = {}\n    for index, template in ipairs(hierarchyEntities) do\n        entityNameToHierarchyIndex[template.entityName] = index\n    end\n\n    if tp.construction then", 1, "stock unit-prefab hierarchy index boundary");
		return source.Replace("    local entityNameToHierarchyIndex = {}\n    for index, template in ipairs(hierarchyEntities) do\n        entityNameToHierarchyIndex[template.entityName] = index\n    end\n\n    if tp.construction then", "    local entityNameToHierarchyIndex = {}\n    for index, template in ipairs(hierarchyEntities) do\n        entityNameToHierarchyIndex[template.entityName] = index\n    end\n\n    -- SCOM Field Fix: strategic silo simulated muzzle 1.0.0\n    SCO_FieldFixStrategicSiloMuzzleHierarchy(\n        tp, entityNameToHierarchyIndex, hierarchyEntities)\n    SCO_UefGunshipAimHierarchy(tp, entityNameToHierarchyIndex, hierarchyEntities)\n\n    if tp.construction then");
	}

	private static void ValidateUnitTemplateLoader(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul field fixes 1.0.0", 1, "field-fix loader marker");
		RequireExactly(source, "-- Supreme Commander Overhaul locomotion and weapon idle reset 1.3.0", 1, "Idle Reset loader marker");
		RequireExactly(source, "local SCO_IdleResetCreateUnitPrefab = CreateUnitPrefab", 1, "Idle Reset loader capture");
		RequireExactly(source, "local function SCO_IdleResetFinalizeSourceTemplate(tp)", 1, "Idle Reset source-final hook declaration");
		RequireExactly(source, "-- SCOM source final template policy 1.1.0", 1, "source-finalizer policy marker");
		RequireExactly(source, "SCO_SourceFinalizerOwnsIdleResetTurretRest = true", 1, "source-finalizer IdleReset ownership flag");
		RequireExactly(source, "\n    SCO_IdleResetFinalizeSourceTemplate(tp)\n", 1, "post-source-finalizer turret-rest dispatch");
		RequireExactly(source, "-- Supreme Commander Overhaul gameplay corrections 1.0.2", 1, "Gameplay Corrections loader marker");
		RequireExactly(source, "local SCO_GameplayCreateUnitPrefab = CreateUnitPrefab", 1, "Gameplay Corrections loader capture");
		RequireExactly(source, "-- Supreme Commander Overhaul construction beam faction palette 1.3.3", 1, "Gameplay Corrections palette marker");
		RequireExactly(source, "-- SCOM Field Fix: isolated Galactic Colossus eye calibration 1.0.2", 1, "isolated Galactic Colossus loader marker");
		RequireExactly(source, "function SCO_FieldFixGalacticColossusEye(tp, tpId)", 1, "isolated Galactic Colossus mutator");
		RequireExactly(source, "function SCO_FieldFixUniversalUef(tp, tpId)", 1, "Universal/UEF mutator");
		RequireExactly(source, "    local resourceVersion = \"1.1.2\"", 1, "Universal/UEF resource marker");
		RequireExactly(source, "    local faArtillerySpecs = {", 1, "Supreme Commander UEF artillery source contracts");
		RequireExactly(source, "            projectile = \"psk201\", projectileLifetime = 15,", 1, "Klink Hammer projectile contract");
		RequireExactly(source, "            damage = 2000, damageRadius = 3, damageFriendly = true,", 1, "Klink Hammer damage contract");
		RequireExactly(source, "            energyRequired = 1000, energyDrainPerSecond = 100,", 1, "Klink Hammer energy contract");
		RequireExactly(source, "            projectile = \"psm401\", projectileLifetime = 1000,", 1, "Mavor projectile contract");
		RequireExactly(source, "            damage = 12000, damageRadius = 7, damageFriendly = true,", 1, "Mavor damage contract");
		RequireExactly(source, "            projectileSpeed = 160, muzzleVelocityRandom = 0.7,", 1, "Mavor projectile-speed contract");
		RequireExactly(source, "                        aimGravity = { x = 0, y = -4.9, z = 0 },", 1, "Supreme Commander artillery ballistic-gravity contract");
		RequireExactly(source, "            energyRequired = 30000, energyDrainPerSecond = 7500,", 1, "Mavor energy contract");
		RequireExactly(source, "        tp.additions.scoFaArtillery = spec", 1, "Supreme Commander UEF artillery runtime contract publication");
		RequireExactly(source, "-- SCOM Apocalypse source flight 4.0.0", 1, "Apocalypse source-flight policy marker");
		RequireExactly(source, "function SCO_FieldFixStrategicSiloMuzzleHierarchy(", 1, "strategic silo muzzle hierarchy policy");
		RequireExactly(source, "    SCO_UefGunshipAimHierarchy(tp, entityNameToHierarchyIndex, hierarchyEntities)", 1, "UEF gunship independent aim axes invocation");
		RequireExactly(source, "-- SCOM Field Fix: strategic silo simulated muzzle 1.0.0", 1, "strategic silo simulated-muzzle marker");
		RequireExactly(source, "-- SCOM Field Fix: source animation playback mode 1.0.0", 1, "source animation playback-mode marker");
		RequireExactly(source, "animationInfo.playbackMode or AnimationPlaybackMode.Loop,", 1, "source animation playback-mode argument");
		RequireExactly(source, "                AnimationPlaybackMode.Loop,", 0, "unrouted stock animation playback-mode argument");
		RequireExactly(source, "    SCO_FieldFixStrategicSiloMuzzleHierarchy(\n        tp, entityNameToHierarchyIndex, hierarchyEntities)", 1, "strategic silo simulated-muzzle invocation");
		RequireExactly(source, "function SCO_FieldFixCybran(tp, tpId)", 1, "Cybran mutator");
		RequireExactly(source, "function SCO_FieldFixAeonSeraphim(tp, tpId)", 1, "Aeon/Seraphim mutator");
		RequireExactly(source, "function SCO_FieldFixPrefabCompletion(tp, tpId)", 1, "prefab-validation completion mutator");
		RequireExactly(source, "-- SCOM Field Fix: exact prefab-validation completion 1.0.1", 1, "prefab-validation completion marker");
		RequireExactly(source, "local SCO_FieldFixPreviousCreateUnitPrefab = CreateUnitPrefab", 1, "captured prefab loader");
		RequireExactly(source, "    SCO_FieldFixUniversalUef(tp, tpId)", 1, "Universal/UEF dispatcher call");
		RequireExactly(source, "    SCO_FieldFixCybran(tp, tpId)", 1, "Cybran dispatcher call");
		RequireExactly(source, "    SCO_FieldFixAeonSeraphim(tp, tpId)", 1, "Aeon/Seraphim dispatcher call");
		RequireExactly(source, "-- SCOM Field Fix: Aeon AI factory tag-index synchronization 1.0.0", 1, "Aeon AI factory tag-index synchronization marker");
		RequireExactly(source, "    local routing = tp.additions and tp.additions.scoFieldFixAeonFactoryRouting", 1, "Aeon AI factory routing guard");
		RequireExactly(source, "    if type(routing) == \"table\" and routing.aiVisible == true then", 1, "reviewed Aeon AI factory routing contract guard");
		RequireExactly(source, "    if type(routing) == \"table\" and routing.aiVisible == true then\n        Tags(tp)\n    end", 1, "Aeon AI factory tag-index synchronization call");
		RequireExactly(source, "    SCO_FieldFixPrefabCompletion(tp, tpId)", 1, "prefab-validation completion dispatcher call");
		RequireExactly(source, "    local errorCode, unitPrefabId = SCO_FieldFixPreviousCreateUnitPrefab(tp)", 1, "field-fix loader invocation");
		RequireExactly(source, "-- SCOM Field Fix: fail-closed prefab result validation 1.0.0", 1, "fail-closed prefab result validation marker");
		RequireExactly(source, "    if errorCode ~= EngineErrorCode.Success or unitPrefabId == nil then", 1, "fail-closed prefab result guard");
		RequireExactly(source, "        error(\"SCOM field-fix prefab creation failed for \" .. tpId", 1, "fail-closed prefab result diagnostic");
		RequireExactly(source, "    return errorCode, unitPrefabId", 1, "field-fix loader return forwarding");
		RequireExactly(source, "function CreateUnitPrefab(tp)", 5, "wrapped prefab loaders");
	}

	private static string PatchGalacticColossusUnitTemplateLoader(string source)
	{
		string text = Normalize(source);
		if (Count(text, "-- SCOM Field Fix: isolated Galactic Colossus eye calibration 1.0.2") == 1)
		{
			ValidateGalacticColossusUnitTemplateLoader(text);
			return text;
		}
		RequireExactly(text, "-- SCOM Field Fix: isolated Galactic Colossus eye calibration 1.0.2", 0, "preexisting Galactic Colossus loader marker");
		RequireExactly(text, "-- Supreme Commander Overhaul locomotion and weapon idle reset 1.3.0", 1, "Idle Reset loader marker");
		int num = Count(text, "function CreateUnitPrefab(tp)");
		if (num != 2 && num != 3)
		{
			throw new InvalidOperationException("Expected two or three upstream unit-prefab loaders, found " + num + ".");
		}
		string appendix = string.Join("\n\n", LoadEmbeddedText("ScomFieldFixes.galactic_colossus_hotfix.lua").Trim(), LoadEmbeddedText("ScomFieldFixes.galactic_colossus_loader_appendix.lua").Trim()) + "\n";
		string text2 = Append(text, appendix);
		ValidateGalacticColossusUnitTemplateLoader(text2);
		return text2;
	}

	private static void ValidateGalacticColossusUnitTemplateLoader(string source)
	{
		RequireExactly(source, "-- SCOM Field Fix: isolated Galactic Colossus eye calibration 1.0.2", 1, "Galactic Colossus loader marker");
		RequireExactly(source, "function SCO_FieldFixGalacticColossusEye(tp, tpId)", 1, "Galactic Colossus template mutator");
		RequireExactly(source, "local SCO_GalacticColossusPreviousCreateUnitPrefab = CreateUnitPrefab", 1, "captured Galactic Colossus prefab loader");
		RequireExactly(source, "    SCO_FieldFixGalacticColossusEye(tp, tpId)", 1, "Galactic Colossus dispatcher call");
		RequireExactly(source, "return SCO_GalacticColossusPreviousCreateUnitPrefab(tp)", 1, "Galactic Colossus loader return forwarding");
		int num = Count(source, "function CreateUnitPrefab(tp)");
		if (num != 3 && num != 4 && num != 5)
		{
			throw new InvalidOperationException("Expected three to five composed unit-prefab loaders, found " + num + ".");
		}
	}

	private static string PatchGalacticColossusClientChosen(string source)
	{
		string text = Normalize(source);
		string text2 = LoadEmbeddedText("ScomFieldFixes.client_chosen_appendix.lua").Trim();
		string token = text2.Split(new char[1] { '\n' })[0];
		int num = Count(text, token);
		switch (num)
		{
		case 0:
			text = Append(text, text2 + "\n");
			break;
		default:
			throw new InvalidOperationException("Galactic Colossus client calibration marker count is " + num + ".");
		case 1:
			break;
		}
		RequireExactly(text, token, 1, "Galactic Colossus client marker");
		RequireExactly(text, "or additions.scoFieldFixGalacticColossusEye == \"1.0.1\")", 1, "isolated Galactic Colossus client contract gate");
		RequireExactly(text, "Engine.SetMeshRendererScale(submeshId, scale)", 1, "Galactic Colossus beam-width call");
		RequireExactly(text, "Applied Galactic Colossus eye scale 0.6 to both client beam layers.", 1, "Galactic Colossus client scale telemetry");
		RequireExactly(text, "local SCO_FieldFixColossusRetargetContinuityVersion = \"1.0.2\"", 1, "Galactic Colossus retarget-continuity version");
		RequireExactly(text, "or beam.fadeOutTime ~= 0.6", 1, "Galactic Colossus authored fade-window contract");
		RequireExactly(text, "self.disableTime = now - resumeAfterlife", 1, "Galactic Colossus continuous retarget fade");
		RequireExactly(text, "self.scoFieldFixColossusRetargetHolding == true", 2, "Galactic Colossus seamless retarget-resume gate");
		RequireExactly(text, "function beam:GetAfterlife(lifetime)", 1, "Galactic Colossus intensity-preserving resume fade");
		RequireExactly(text, "function beam:RenderUpdate()", 1, "Galactic Colossus fade-expiry cleanup");
		RequireExactly(text, "Engine.GetLocalEntityWorldPosition(", 1, "Galactic Colossus stock-only muzzle-position reads");
		RequireExactly(text, "Engine.GetLocalEntityForwardDirection(", 0, "Galactic Colossus afterlife muzzle-direction reads");
		RequireExactly(text, "function beam:CleanupImpactEffect()", 1, "Galactic Colossus stale-impact guard");
		RequireExactly(text, "if Engine.IsValidLocalID(effectId) then", 1, "Galactic Colossus impact-handle validation");
		RequireExactly(text, "function muzzle:Cleanup()", 1, "Galactic Colossus native terminal cleanup");
		RequireExactly(text, "return stockSetBeamEnabled(self, false)", 0, "Galactic Colossus complete local shutdown ownership");
		return text;
	}

	private static string PatchGalacticColossusHostWeapons(string source)
	{
		string text = Normalize(source);
		string text2 = LoadEmbeddedText("ScomFieldFixes.galactic_colossus_host_weapon_appendix.lua").Trim();
		string token = text2.Split(new char[1] { '\n' })[0];
		int num = Count(text, token);
		switch (num)
		{
		case 0:
			RequireExactly(text, "-- SCO_GalacticColossusTractor", 1, "main SCOM Galactic Colossus host contract");
			RequireExactly(text, "function HostWeapon:UpdateBeam(isOnTarget)", 1, "stock HostWeapon beam update");
			text = Append(text, text2 + "\n");
			break;
		default:
			throw new InvalidOperationException("Galactic Colossus host beam-gate marker count is " + num + ".");
		case 1:
			break;
		}
		RequireExactly(text, token, 1, "Galactic Colossus host beam-gate marker");
		RequireExactly(text, "local SCO_GalacticColossusStockUpdateBeam = HostWeapon.UpdateBeam", 1, "captured HostWeapon beam update");
		RequireExactly(text, "function HostWeapon:UpdateBeam(isOnTarget)", 2, "wrapped HostWeapon beam updates");
		RequireExactly(text, "        if eyeState == false then\n            if not self.scoGalacticColossusAimSuspended then\n                self:SetMuzzlesFiring(false)", 1, "corrupt-contract beam shutdown");
		RequireExactly(text, "        if active and not isOnTarget then\n            if not self.scoGalacticColossusAimSuspended then\n                self:SetMuzzlesFiring(false)", 1, "off-target persistent-beam suspension");
		RequireExactly(text, "                self:SetMuzzlesFiring(true)\n                self.scoGalacticColossusAimSuspended = nil", 1, "on-target persistent-beam resumption");
		RequireExactly(text, "return SCO_GalacticColossusStockUpdateBeam(self, isOnTarget)", 1, "HostWeapon beam-update return forwarding");
		RequireExactly(text, "Matched the Galactic Colossus 1.0.1 host eye contract.", 1, "Galactic Colossus host contract telemetry");
		return text;
	}

	private static string PatchFaArtilleryHostWeapons(string source)
	{
		string text = PatchScathisHostAnimatorOwnership(Normalize(source));
		string text2 = LoadEmbeddedText("ScomFieldFixes.uef_artillery_host_weapon_appendix.lua").Trim();
		string token = text2.Split(new char[1] { '\n' })[0];
		int num = Count(text, token);
		switch (num)
		{
		case 0:
		{
			RequireExactly(text, "-- SCOM Field Fix: Galactic Colossus off-target beam gate 1.0.1", 1, "composed Galactic Colossus host marker");
			RequireExactly(text, "Engine.SetCurvedProjectileSpeed(projectileID, desiredProjectileSpeed)", 1, "stock curved-projectile speed call");
			RequireExactly(text, "Engine.SetCurvedProjectileSpeed(projectileID, SCO_FieldFixArtilleryProjectileSpeed(self, desiredProjectileSpeed, muzzlePosition, targetBoneID))", 0, "preexisting artillery projectile-speed route");
			int num2 = Count(text, "Projectiles[projectileID.index] = Projectile(projectileID, self.unit.army.id, self.projectileTemplate, self.tp.damage or 0, self.tp.damageRadius or 0, self.tp.projectileLifetime, muzzleID)");
			int num3 = Count(text, "Projectiles[projectileID.index] = Projectile(projectileID, self.unit.army.id, self.projectileTemplate, self.tp.damage or 0, self.tp.damageRadius or 0, self.tp.projectileLifetime, muzzleID, self.unit)");
			if (num2 + num3 != 1)
			{
				throw new InvalidOperationException("Expected exactly one supported host projectile constructor, found stock=" + num2 + " and veterancy=" + num3 + ".");
			}
			string text3 = ((num3 == 1) ? "Projectiles[projectileID.index] = Projectile(projectileID, self.unit.army.id, self.projectileTemplate, self.tp.damage or 0, self.tp.damageRadius or 0, self.tp.projectileLifetime, muzzleID, self.unit)" : "Projectiles[projectileID.index] = Projectile(projectileID, self.unit.army.id, self.projectileTemplate, self.tp.damage or 0, self.tp.damageRadius or 0, self.tp.projectileLifetime, muzzleID)");
			RequireExactly(text, "Projectiles[projectileID.index].damageFriendly = self.tp.damageFriendly == true", 0, "preexisting projectile friendly-damage propagation");
			RequireExactly(text, "                    local firingRotation = ApplyFiringRandomness(\n                        launchRotation,\n                        self.tp.firingRandomness or 1.0)", 1, "composed host firing-rotation call");
			RequireExactly(text, "                    local firingRotation = SCO_FieldFixFatboyGaussFiringRotation(\n                        self,\n                        targetBoneID,\n                        muzzlePosition,\n                        launchRotation,\n                        desiredProjectileSpeed,\n                        projectileGravity)\n                    firingRotation = ApplyFiringRandomness(\n                        firingRotation,\n                        self.tp.firingRandomness or 1.0)", 0, "preexisting Fatboy Gauss firing-rotation route");
			text = text.Replace("Engine.SetCurvedProjectileSpeed(projectileID, desiredProjectileSpeed)", "Engine.SetCurvedProjectileSpeed(projectileID, SCO_FieldFixArtilleryProjectileSpeed(self, desiredProjectileSpeed, muzzlePosition, targetBoneID))");
			text = text.Replace(text3, text3 + "\n                    Projectiles[projectileID.index].damageFriendly = self.tp.damageFriendly == true");
			text = text.Replace("                    local firingRotation = ApplyFiringRandomness(\n                        launchRotation,\n                        self.tp.firingRandomness or 1.0)", "                    local firingRotation = SCO_FieldFixFatboyGaussFiringRotation(\n                        self,\n                        targetBoneID,\n                        muzzlePosition,\n                        launchRotation,\n                        desiredProjectileSpeed,\n                        projectileGravity)\n                    firingRotation = ApplyFiringRandomness(\n                        firingRotation,\n                        self.tp.firingRandomness or 1.0)");
			text = Append(text, text2 + "\n");
			break;
		}
		default:
			throw new InvalidOperationException("Supreme Commander UEF artillery host marker count is " + num + ".");
		case 1:
			break;
		}
		RequireExactly(text, token, 1, "Supreme Commander UEF artillery host marker");
		RequireExactly(text, text2, 1, "Supreme Commander UEF artillery host appendix bytes");
		RequireExactly(text, "Engine.SetCurvedProjectileSpeed(projectileID, desiredProjectileSpeed)", 0, "unrouted curved-projectile speed call");
		RequireExactly(text, "Engine.SetCurvedProjectileSpeed(projectileID, SCO_FieldFixArtilleryProjectileSpeed(self, desiredProjectileSpeed, muzzlePosition, targetBoneID))", 1, "artillery projectile-speed route");
		int num4 = Count(text, "Projectiles[projectileID.index] = Projectile(projectileID, self.unit.army.id, self.projectileTemplate, self.tp.damage or 0, self.tp.damageRadius or 0, self.tp.projectileLifetime, muzzleID)") + Count(text, "Projectiles[projectileID.index] = Projectile(projectileID, self.unit.army.id, self.projectileTemplate, self.tp.damage or 0, self.tp.damageRadius or 0, self.tp.projectileLifetime, muzzleID, self.unit)");
		if (num4 != 1)
		{
			throw new InvalidOperationException("Expected exactly one supported host projectile constructor after patching, found " + num4 + ".");
		}
		RequireExactly(text, "Projectiles[projectileID.index].damageFriendly = self.tp.damageFriendly == true", 1, "projectile friendly-damage propagation");
		RequireExactly(text, "                    local firingRotation = SCO_FieldFixFatboyGaussFiringRotation(\n                        self,\n                        targetBoneID,\n                        muzzlePosition,\n                        launchRotation,\n                        desiredProjectileSpeed,\n                        projectileGravity)\n                    firingRotation = ApplyFiringRandomness(\n                        firingRotation,\n                        self.tp.firingRandomness or 1.0)", 1, "Fatboy Gauss firing-rotation route");
		RequireExactly(text, "function SCO_FieldFixFatboyGaussFiringRotation(", 1, "Fatboy Gauss firing-rotation helper");
		RequireExactly(text, "template.projectileTemplate ~= \"psf401\"", 1, "Fatboy Gauss projectile guard");
		RequireExactly(text, "template.projectileTemplate == \"psf0154\"", 1, "Fatboy final projectile range guard");
		RequireExactly(text, "template.projectileTemplate ~= \"psf0154\"", 1, "Fatboy final projectile launch guard");
		return text;
	}

	private static string PatchScathisHostAnimatorOwnership(string source)
	{
		string text = Normalize(source);
		int num = Count(text, "-- SCOM Field Fix: Scathis deployed animator ownership 1.0.0");
		switch (num)
		{
		case 0:
			RequireExactly(text, "-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", 1, "composed Scathis host-weapon marker");
			RequireExactly(text, "local function SCO_PlayScathisAnimation(self, key)\n    local animation = self.unit.tp.visuals and self.unit.tp.visuals.animations\n        and self.unit.tp.visuals.animations[key]\n    if not animation or not animation.id then\n        error(\"Scathis requires source animation \" .. tostring(key))\n    end\n    Engine.PlayAnimation(self.unit.id, animation.id, 0.1)\nend\n\nlocal SCO_ScathisOpenSeconds = 16.66666603088379\nlocal SCO_ScathisPitchGoalTolerance = 0.05\nlocal SCO_ScathisSampleSentinel = -10000\n\nlocal function SCO_SampleScathisDeployment(self, progress)", 1, "Scathis source-animation and sample entry");
			RequireExactly(text, "local function SCO_BeginScathisPitchAlignment(self, now)\n    if not self.scoScathisPitchBases then", 1, "Scathis pitch-alignment entry");
			text = text.Replace("local function SCO_PlayScathisAnimation(self, key)\n    local animation = self.unit.tp.visuals and self.unit.tp.visuals.animations\n        and self.unit.tp.visuals.animations[key]\n    if not animation or not animation.id then\n        error(\"Scathis requires source animation \" .. tostring(key))\n    end\n    Engine.PlayAnimation(self.unit.id, animation.id, 0.1)\nend\n\nlocal SCO_ScathisOpenSeconds = 16.66666603088379\nlocal SCO_ScathisPitchGoalTolerance = 0.05\nlocal SCO_ScathisSampleSentinel = -10000\n\nlocal function SCO_SampleScathisDeployment(self, progress)", "local function SCO_PlayScathisAnimation(self, key)\n    local animation = self.unit.tp.visuals and self.unit.tp.visuals.animations\n        and self.unit.tp.visuals.animations[key]\n    if not animation or not animation.id then\n        error(\"Scathis requires source animation \" .. tostring(key))\n    end\n    local enableResult = Engine.SetAnimatorEnabled(self.unit.id, true)\n    if enableResult ~= EngineErrorCode.Success then\n        error(\"Scathis could not enable source animation \" .. tostring(key))\n    end\n    self.scoScathisAnimatorSampling = true\n    Engine.PlayAnimation(self.unit.id, animation.id, 0.1)\nend\n\nlocal SCO_ScathisOpenSeconds = 16.66666603088379\nlocal SCO_ScathisPitchGoalTolerance = 0.05\nlocal SCO_ScathisSampleSentinel = -10000\n\nlocal function SCO_SampleScathisDeployment(self, progress)\n    if not self.scoScathisAnimatorSampling then\n        local enableResult = Engine.SetAnimatorEnabled(self.unit.id, true)\n        if enableResult ~= EngineErrorCode.Success then\n            error(\"Scathis could not enable source deployment sampling\")\n        end\n        self.scoScathisAnimatorSampling = true\n    end").Replace("local function SCO_BeginScathisPitchAlignment(self, now)\n    if not self.scoScathisPitchBases then", "local function SCO_BeginScathisPitchAlignment(self, now)\n    -- SCOM Field Fix: Scathis deployed animator ownership 1.0.0\n    -- AnimOpen keys all six B01 pitch bones. Freeze the sampled pose before\n    -- manual pitch alignment, including target reacquisition.\n    if self.scoScathisAnimatorSampling then\n        local disableResult = Engine.SetAnimatorEnabled(self.unit.id, false)\n        if disableResult ~= EngineErrorCode.Success then\n            error(\"Scathis could not freeze its deployed source pose\")\n        end\n        self.scoScathisAnimatorSampling = nil\n    end\n    if not self.scoScathisPitchBases then");
			break;
		default:
			throw new InvalidOperationException("Scathis animator-ownership marker count is " + num + ".");
		case 1:
			break;
		}
		RequireExactly(text, "scoScathisDeployDeadline", 0, "stale Scathis deployment deadline");
		RequireExactly(text, "local function SCO_PlayScathisAnimation(self, key)\n    local animation = self.unit.tp.visuals and self.unit.tp.visuals.animations\n        and self.unit.tp.visuals.animations[key]\n    if not animation or not animation.id then\n        error(\"Scathis requires source animation \" .. tostring(key))\n    end\n    local enableResult = Engine.SetAnimatorEnabled(self.unit.id, true)\n    if enableResult ~= EngineErrorCode.Success then\n        error(\"Scathis could not enable source animation \" .. tostring(key))\n    end\n    self.scoScathisAnimatorSampling = true\n    Engine.PlayAnimation(self.unit.id, animation.id, 0.1)\nend\n\nlocal SCO_ScathisOpenSeconds = 16.66666603088379\nlocal SCO_ScathisPitchGoalTolerance = 0.05\nlocal SCO_ScathisSampleSentinel = -10000\n\nlocal function SCO_SampleScathisDeployment(self, progress)\n    if not self.scoScathisAnimatorSampling then\n        local enableResult = Engine.SetAnimatorEnabled(self.unit.id, true)\n        if enableResult ~= EngineErrorCode.Success then\n            error(\"Scathis could not enable source deployment sampling\")\n        end\n        self.scoScathisAnimatorSampling = true\n    end", 1, "Scathis animation re-enable and sample route");
		RequireExactly(text, "local function SCO_BeginScathisPitchAlignment(self, now)\n    -- SCOM Field Fix: Scathis deployed animator ownership 1.0.0\n    -- AnimOpen keys all six B01 pitch bones. Freeze the sampled pose before\n    -- manual pitch alignment, including target reacquisition.\n    if self.scoScathisAnimatorSampling then\n        local disableResult = Engine.SetAnimatorEnabled(self.unit.id, false)\n        if disableResult ~= EngineErrorCode.Success then\n            error(\"Scathis could not freeze its deployed source pose\")\n        end\n        self.scoScathisAnimatorSampling = nil\n    end\n    if not self.scoScathisPitchBases then", 1, "Scathis deployed animation freeze route");
		return text;
	}

	private static string PatchClientOrbitalBeamRange(string source)
	{
		string text = Normalize(source);
		RequireExactly(text, "function ClientBeam:Raycast()", 1, "native client beam raycast method");
		if (Count(text, "    local weaponTemplate = self.muzzle.weapon.tp\n    local rangeMax = weaponTemplate.scoSpecialOrbital and weaponTemplate.scoSpecialOrbital.maximumLength or weaponTemplate.rangeMax") == 0)
		{
			RequireExactly(text, "    local rangeMax = self.muzzle.weapon.tp.rangeMax", 1, "native client beam range");
			text = text.Replace("    local rangeMax = self.muzzle.weapon.tp.rangeMax", "    local weaponTemplate = self.muzzle.weapon.tp\n    local rangeMax = weaponTemplate.scoSpecialOrbital and weaponTemplate.scoSpecialOrbital.maximumLength or weaponTemplate.rangeMax");
		}
		RequireExactly(text, "    local rangeMax = self.muzzle.weapon.tp.rangeMax", 0, "unpatched client beam range");
		RequireExactly(text, "    local weaponTemplate = self.muzzle.weapon.tp\n    local rangeMax = weaponTemplate.scoSpecialOrbital and weaponTemplate.scoSpecialOrbital.maximumLength or weaponTemplate.rangeMax", 1, "source orbital client beam range");
		return text;
	}

	private static string PatchHostMuzzleDeletion(string source)
	{
		string text = Normalize(source);
		RequireExactly(text, "    __Muzzles[self.id.index] = nil", 1, "native muzzle deletion registry key");
		return text.Replace("    __Muzzles[self.id.index] = nil", "    if __Muzzles[self.id.index] == self then\n        __Muzzles[self.id.index] = nil\n    end");
	}

	private static string PatchFaArtilleryClientMuzzle(string source)
	{
		return InsertEmbeddedBefore(PatchScathisClientMuzzleParity(PatchClientOrbitalMuzzleLifetime(source)), "Supreme Commander UEF artillery client recoil", "return {\n    RegisterClientMuzzle = RegisterClientMuzzle,", "ScomFieldFixes.uef_artillery_client_muzzle_appendix.lua");
	}

	private static string PatchClientOrbitalBeamFactory(string source)
	{
		string text = Normalize(source);
		if (Count(text, "    if beamLifetime > 0 and not muzzle.weapon.tp.scoSpecialOrbital then") == 0)
		{
			RequireExactly(text, "    if beamLifetime > 0 then", 1, "native client pulse-beam selection");
			text = text.Replace("    if beamLifetime > 0 then", "    if beamLifetime > 0 and not muzzle.weapon.tp.scoSpecialOrbital then");
		}
		RequireExactly(text, "    if beamLifetime > 0 then", 0, "unpatched client pulse-beam selection");
		RequireExactly(text, "    if beamLifetime > 0 and not muzzle.weapon.tp.scoSpecialOrbital then", 1, "source orbital continuous-beam selection");
		return text;
	}

	private static string PatchClientOrbitalMuzzleLifetime(string source)
	{
		string text = Normalize(source);
		if (Count(text, "    if self.beam and (enabled or self.weapon.tp.scoSpecialOrbital or (self.weapon.tp.beamLifetime or -1) < 0) then") == 0)
		{
			RequireExactly(text, "    if self.beam and (enabled or (self.weapon.tp.beamLifetime or -1) < 0) then", 1, "native client muzzle beam lifetime gate");
			text = text.Replace("    if self.beam and (enabled or (self.weapon.tp.beamLifetime or -1) < 0) then", "    if self.beam and (enabled or self.weapon.tp.scoSpecialOrbital or (self.weapon.tp.beamLifetime or -1) < 0) then");
		}
		RequireExactly(text, "    if self.beam and (enabled or (self.weapon.tp.beamLifetime or -1) < 0) then", 0, "unpatched client muzzle beam lifetime gate");
		RequireExactly(text, "    if self.beam and (enabled or self.weapon.tp.scoSpecialOrbital or (self.weapon.tp.beamLifetime or -1) < 0) then", 1, "source orbital beam stop gate");
		return text;
	}

	private static string PatchScathisClientMuzzleParity(string source)
	{
		string text = Normalize(source);
		int num = Count(text, "-- SCOM Field Fix: Scathis visible muzzle parity 1.0.0");
		switch (num)
		{
		case 0:
			RequireExactly(text, "-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", 1, "composed Scathis client-muzzle marker");
			RequireExactly(text, "    if self.boneName == \"Turret_Aim_Barrel_Muzzle\" then\n        local result = SCO_ScathisStockFireMuzzle(self)\n        SCO_StartScathisRecoil(self, \"Turret_Aim_Barrel\")\n        return result\n    end", 1, "legacy hidden-muzzle effects route");
			RequireExactly(text, "    -- The host emits exactly one selected fake muzzle event per real shot.\n    -- Suppress duplicate stock muzzle/audio while preserving source recoil.\n    SCO_StartScathisRecoil(self, recoilBone)\nend", 1, "legacy outer-muzzle suppression route");
			RequireExactly(text, "    local recoilBone = string.gsub(self.boneName, \"_B03$\", \"_B02\")", 1, "legacy B03 recoil route");
			text = text.Replace("    if self.boneName == \"Turret_Aim_Barrel_Muzzle\" then\n        local result = SCO_ScathisStockFireMuzzle(self)\n        SCO_StartScathisRecoil(self, \"Turret_Aim_Barrel\")\n        return result\n    end", "    if self.boneName == \"Turret_Aim_Barrel_Muzzle\" then\n        -- SCOM Field Fix: Scathis visible muzzle parity 1.0.0\n        -- FA launches the projectile from this hidden aim muzzle, but its\n        -- visible flash and fire audio belong to the selected outer barrel.\n        SCO_StartScathisRecoil(self, \"Turret_Aim_Barrel\")\n        return\n    end").Replace("    -- The host emits exactly one selected fake muzzle event per real shot.\n    -- Suppress duplicate stock muzzle/audio while preserving source recoil.\n    SCO_StartScathisRecoil(self, recoilBone)\nend", "    -- The host emits exactly one selected outer-barrel event per real shot.\n    -- Run stock effects here so the flash and audio follow F,E,D,C,B,A.\n    local result = SCO_ScathisStockFireMuzzle(self)\n    SCO_StartScathisRecoil(self, recoilBone)\n    return result\nend").Replace("    local recoilBone = string.gsub(self.boneName, \"_B03$\", \"_B02\")", "    local recoilBone = string.gsub(self.boneName, \"_Muzzle$\", \"_B02\")");
			break;
		default:
			throw new InvalidOperationException("Scathis visible-muzzle marker count is " + num + ".");
		case 1:
			break;
		}
		RequireExactly(text, "    if self.boneName == \"Turret_Aim_Barrel_Muzzle\" then\n        local result = SCO_ScathisStockFireMuzzle(self)\n        SCO_StartScathisRecoil(self, \"Turret_Aim_Barrel\")\n        return result\n    end", 0, "legacy hidden-muzzle effects route");
		RequireExactly(text, "    -- The host emits exactly one selected fake muzzle event per real shot.\n    -- Suppress duplicate stock muzzle/audio while preserving source recoil.\n    SCO_StartScathisRecoil(self, recoilBone)\nend", 0, "legacy outer-muzzle suppression route");
		RequireExactly(text, "    local recoilBone = string.gsub(self.boneName, \"_B03$\", \"_B02\")", 0, "legacy B03 recoil route");
		RequireExactly(text, "    if self.boneName == \"Turret_Aim_Barrel_Muzzle\" then\n        -- SCOM Field Fix: Scathis visible muzzle parity 1.0.0\n        -- FA launches the projectile from this hidden aim muzzle, but its\n        -- visible flash and fire audio belong to the selected outer barrel.\n        SCO_StartScathisRecoil(self, \"Turret_Aim_Barrel\")\n        return\n    end", 1, "central projectile and recoil-only route");
		RequireExactly(text, "    -- The host emits exactly one selected outer-barrel event per real shot.\n    -- Run stock effects here so the flash and audio follow F,E,D,C,B,A.\n    local result = SCO_ScathisStockFireMuzzle(self)\n    SCO_StartScathisRecoil(self, recoilBone)\n    return result\nend", 1, "selected outer-barrel effects and recoil route");
		RequireExactly(text, "    local recoilBone = string.gsub(self.boneName, \"_Muzzle$\", \"_B02\")", 1, "terminal outer-muzzle to B02 recoil route");
		return text;
	}

	private static string PatchFaArtilleryCollisionLayers(string source)
	{
		string newValue = "    Props = 16,\n    -- SCOM Field Fix: Supreme Commander artillery water layer 1.0.0\n    Water = 32,\n\n    -- Bitmask where all bits are enabled.";
		string text = Normalize(source);
		int num = Count(text, "-- SCOM Field Fix: Supreme Commander artillery water layer 1.0.0");
		switch (num)
		{
		case 0:
			if (Count(text, "    Props = 16,\n    Water = 32,\n\n    -- Bitmask where all bits are enabled.") == 1)
			{
				RequireExactly(text, "    Water = 32,", 1, "native collision water layer");
				text = text.Replace("    Props = 16,\n    Water = 32,\n\n    -- Bitmask where all bits are enabled.", newValue);
			}
			else
			{
				RequireExactly(text, "    Props = 16,\n\n    -- Bitmask where all bits are enabled.", 1, "stock collision-layer table tail");
				RequireExactly(text, "    Water = 32,", 0, "preexisting collision water layer");
				text = text.Replace("    Props = 16,\n\n    -- Bitmask where all bits are enabled.", newValue);
			}
			break;
		default:
			throw new InvalidOperationException("Supreme Commander artillery water-layer marker count is " + num + ".");
		case 1:
			break;
		}
		RequireExactly(text, "-- SCOM Field Fix: Supreme Commander artillery water layer 1.0.0", 1, "Supreme Commander artillery water-layer marker");
		RequireExactly(text, "    Props = 16,\n    -- SCOM Field Fix: Supreme Commander artillery water layer 1.0.0\n    Water = 32,", 1, "Supreme Commander artillery water-layer assignment");
		RequireExactly(text, "    All = bit.lshift(1, 32)", 1, "collision-layer all-bits mask");
		return text;
	}

	private static string PatchProjectileWaterDamage(string source)
	{
		string text = Normalize(source);
		if (Count(text, "CollisionUpdate.ProcessAreaDamage(hitPosition, self.damageRadius, self.damage, Armies[self.armyId], self.damageFriendly == true, self.sourceUnit)") == 0)
		{
			RequireExactly(text, "CollisionUpdate.ProcessAreaDamage(hitPosition, self.damageRadius, self.damage, Armies[self.armyId], false)", 1, "native water splash damage");
			text = text.Replace("CollisionUpdate.ProcessAreaDamage(hitPosition, self.damageRadius, self.damage, Armies[self.armyId], false)", "CollisionUpdate.ProcessAreaDamage(hitPosition, self.damageRadius, self.damage, Armies[self.armyId], self.damageFriendly == true, self.sourceUnit)");
		}
		RequireExactly(text, "CollisionUpdate.ProcessAreaDamage(hitPosition, self.damageRadius, self.damage, Armies[self.armyId], false)", 0, "unrouted water splash damage");
		RequireExactly(text, "CollisionUpdate.ProcessAreaDamage(hitPosition, self.damageRadius, self.damage, Armies[self.armyId], self.damageFriendly == true, self.sourceUnit)", 1, "friendly-aware credited water splash damage");
		return text;
	}

	private static string PatchFaArtilleryCollisionUpdate(string source)
	{
		string text = Normalize(source);
		string text2 = LoadEmbeddedText("ScomFieldFixes.strategic_silo_collision_appendix.lua").Trim();
		string token = text2.Split(new char[1] { '\n' })[0];
		int num = Count(text, token);
		switch (num)
		{
		case 0:
		{
			int num2 = Count(text, "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, false)");
			int num3 = Count(text, "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, false, projectile.sourceUnit)");
			if ((num2 != 3 || num3 != 0) && (num2 != 0 || num3 != 3))
			{
				throw new InvalidOperationException("Expected exactly one supported collision area-damage form, found stock=" + num2 + " and veterancy=" + num3 + ".");
			}
			RequireExactly(text, "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, projectile.damageFriendly == true)", 0, "preexisting stock friendly area-damage routes");
			RequireExactly(text, "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, projectile.damageFriendly == true, projectile.sourceUnit)", 0, "preexisting veterancy friendly area-damage routes");
			RequireExactly(text, "return {\n    CollisionUpdate = CollisionUpdate,", 1, "strategic silo collision insertion anchor");
			text = ((num3 != 3) ? text.Replace("ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, false)", "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, projectile.damageFriendly == true)") : text.Replace("ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, false, projectile.sourceUnit)", "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, projectile.damageFriendly == true, projectile.sourceUnit)"));
			text = text.Replace("return {\n    CollisionUpdate = CollisionUpdate,", text2 + "\n\nreturn {\n    CollisionUpdate = CollisionUpdate,");
			break;
		}
		default:
			throw new InvalidOperationException("Strategic silo collision marker count is " + num + ".");
		case 1:
			break;
		}
		RequireExactly(text, "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, false)", 0, "unrouted stock collision area-damage calls");
		RequireExactly(text, "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, false, projectile.sourceUnit)", 0, "unrouted veterancy collision area-damage calls");
		int num4 = Count(text, "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, projectile.damageFriendly == true)") + Count(text, "ProcessAreaDamage(hitPosition, projectile.damageRadius, projectile.damage, projectileArmy, projectile.damageFriendly == true, projectile.sourceUnit)");
		if (num4 != 3)
		{
			throw new InvalidOperationException("Expected three friendly-aware collision area-damage routes, found " + num4 + ".");
		}
		ValidateInsertedSequence(text, "strategic silo collision and Supreme Commander friendly splash", "return {\n    CollisionUpdate = CollisionUpdate,", new string[1] { text2 });
		return text;
	}

	private static string PatchProjectileTemplateLoader(string source)
	{
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul projectile field fixes 1.0.1") == 1)
		{
			ValidateProjectileTemplateLoader(text);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul projectile field fixes 1.0.1", 0, "preexisting projectile field-fix marker");
		RequireExactly(text, "function CreateProjectilePrefab(tp)", 1, "stock projectile-prefab loader");
		RequireExactly(text, "EngineClasses.HierarchyTemplate(hierarchyEntities),", 1, "stock projectile hierarchy constructor");
		text = PatchFaArtilleryProjectileWaterCollider(text);
		string appendix = string.Join("\n\n", "-- Supreme Commander Overhaul projectile field fixes 1.0.1", LoadEmbeddedText("ScomFieldFixes.cybran.lua").Trim(), LoadEmbeddedText("ScomFieldFixes.projectile_loader_seraphim_appendix.lua").Trim(), LoadEmbeddedText("ScomFieldFixes.projectile_loader_appendix.lua").Trim(), LoadEmbeddedText("ScomFieldFixes.projectile_mesh_loader_appendix.lua").Trim(), LoadEmbeddedText("ScomFieldFixes.Roster.source_nuke_loader.lua").Trim()) + "\n";
		string text2 = Append(text, appendix).Replace("EngineClasses.HierarchyTemplate(hierarchyEntities),", "EngineClasses.HierarchyTemplate(SCO_FieldFixSeraphimProjectileHierarchy(tp, hierarchyEntities)),");
		RequireExactly(text2, "    local errorCode = Engine.CreatePrefab(prefabTemplate, projectilePrefabID)", 1, "native projectile prefab registration");
		string text3 = text2.Replace("    local errorCode = Engine.CreatePrefab(prefabTemplate, projectilePrefabID)", "    SCO_FieldFixAttachProjectileMesh(tp, prefabTemplate)\n    SCO_SourceNukeParticles(tp, prefabTemplate)\n    local errorCode = Engine.CreatePrefab(prefabTemplate, projectilePrefabID)");
		ValidateProjectileTemplateLoader(text3);
		return text3;
	}

	private static string PatchFaArtilleryProjectileWaterCollider(string source)
	{
		RequireExactly(source, "EngineClasses.RayColliderTemplate(WaterColliderEntityName,\n            EngineClasses.float3(0, 0, 0),\n            CollisionWorld.EnvironmentCollision,\n            CollisionLayer.Projectiles,\n            CollisionLayer.Water,\n            ColliderFlags.EventsDisabled\n        )", 1, "native projectile water collider");
		string text = "    -- SCOM Field Fix: Supreme Commander artillery water collider 1.0.0\n    -- Use the native water child collider and preserve its event lifecycle.\n";
		if (Count(source, "-- SCOM Field Fix: Supreme Commander artillery water collider 1.0.0") == 1)
		{
			RequireExactly(source, text, 1, "native water collider ownership");
			return source;
		}
		RequireExactly(source, "-- SCOM Field Fix: Supreme Commander artillery water collider 1.0.0", 0, "preexisting water collider marker");
		RequireExactly(source, "    local globalVolumeColliderTemplates = {", 1, "native projectile global collider anchor");
		return source.Replace("    local globalVolumeColliderTemplates = {", text + "    local globalVolumeColliderTemplates = {");
	}

	private static string PatchStartingResources(string source)
	{
		source = Normalize(source);
		string text = Normalize(LoadEmbeddedText("ScomFieldFixes.source_starting_resources.lua")).Trim();
		if (Count(source, text.Split(new char[1] { '\n' })[0]) == 0)
		{
			RequireExactly(source, "                CreateUnit(i, Factions.FactionsData[army.faction].initialUnit, startingPos)", 1, "native initial unit creation");
			RequireExactly(source, "function SpawnInitialUnits()", 1, "native initial unit entry");
			source = source.Replace("function SpawnInitialUnits()", text + "\n\nfunction SpawnInitialUnits()").Replace("                CreateUnit(i, Factions.FactionsData[army.faction].initialUnit, startingPos)", "                local initialUnit = CreateUnit(i, Factions.FactionsData[army.faction].initialUnit, startingPos)\n                SCO_GiveStartingResources(army, initialUnit)");
		}
		RequireExactly(source, text, 1, "starting resource helper");
		RequireExactly(source, "                local initialUnit = CreateUnit(i, Factions.FactionsData[army.faction].initialUnit, startingPos)\n                SCO_GiveStartingResources(army, initialUnit)", 1, "starting resource grant placement");
		return source;
	}

	private static string AppendReviewedRuntime(string source, string appendix, string? anchor = null)
	{
		appendix = Normalize(appendix).Trim();
		string token = appendix.Split(new char[1] { '\n' })[0];
		if (Count(source, token) == 0)
		{
			if (anchor == null)
			{
				source = Append(source, appendix + "\n");
			}
			else
			{
				RequireExactly(source, anchor, 1, "runtime insertion boundary");
				source = source.Replace(anchor, appendix + "\n\n" + anchor);
			}
		}
		RequireExactly(source, token, 1, "runtime appendix marker");
		RequireExactly(source, appendix, 1, "runtime appendix bytes");
		return source;
	}

	private static string PatchSourceUnitCompletion(string source, string id)
	{
		if (id == "ues3102")
		{
			source = RosterContracts.Unit(id);
		}
		if (TacticalMissileContracts.UnitIds.Contains<string>(id))
		{
			source = AppendReviewedRuntime(source, TacticalMissileContracts.UnitOverride(id));
		}
		if (RosterContracts.AllIds.Contains<string>(id))
		{
			source = AppendReviewedRuntime(source, RosterContracts.Tags(id));
		}
		source = AppendOptionalRosterResource(source, "ScomFieldFixes.Roster.Animation." + id + ".lua");
		source = AppendOptionalRosterResource(source, "ScomFieldFixes.Roster.Cargo." + id + ".lua");
		source = AppendOptionalRosterResource(source, "ScomFieldFixes.Roster.Hydro." + id + ".lua");
		return source;
	}

	private static string PatchExistingSourceProjectile(string source, string id)
	{
		if (id == "pei241")
		{
			source = AppendReviewedRuntime(source, "-- SCOM native missile registration scale 1.0.0\nProjectileTemplate.nonUniformScale = ProjectileTemplate.nonUniformScale or { x = 1, y = 1, z = 1 }\n");
		}
		if (id == "pxd003")
		{
			string text = LoadEmbeddedText("ScomFieldFixes.Roster.Projectile.pxd003.santp");
			if (source == text)
			{
				return source;
			}
			using SHA256 sHA = SHA256.Create();
			if (BitConverter.ToString(sHA.ComputeHash(Encoding.UTF8.GetBytes(source))).Replace("-", "") != "DD3EB45AB935F6040953CEC53B5BC7BD8B24B44AC39BC52A0E9D6E43EDA06405")
			{
				throw new InvalidOperationException("Legacy commander beam endpoint source changed");
			}
			return text;
		}
		source = AppendOptionalRosterResource(source, "ScomFieldFixes.Roster.ProjectileVisuals." + id + ".lua");
		return AppendOptionalRosterResource(source, "ScomFieldFixes.Roster.YolonaEffects." + id + ".lua");
	}

	private static string AppendOptionalRosterResource(string source, string name)
	{
		using Stream stream = typeof(CachePatcherRuntime).Assembly.GetManifestResourceStream(name);
		if (stream == null)
		{
			return source;
		}
		using StreamReader streamReader = new StreamReader(stream);
		return AppendReviewedRuntime(source, "-- SCOM optional roster resource " + name + "\n" + streamReader.ReadToEnd());
	}

	private static string PatchImportScanner(string source)
	{
		string source2 = Normalize(source);
		if (Count(source2, "-- SCOM Field Fixes cache-only projectile folders 1.0.0") == 1)
		{
			ValidateImportScanner(source2, "-- SCOM Field Fixes cache-only projectile folders 1.0.0");
			return AppendReviewedRuntime(source2, RosterScannerAppendix());
		}
		RequireExactly(source2, "-- SCOM Field Fixes cache-only projectile folders 1.0.0", 0, "preexisting field-fix projectile-folder marker");
		RequireExactly(source2, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, "Sea Parity import-scanner marker");
		RequireExactly(source2, "local SCOSeaParityPreviousScanDir = ScanDir", 1, "Sea Parity ScanDir capture");
		RequireExactly(source2, "    elseif directory == \"common/projectiles/projectilesTemplates/\" then\n        generated = {\n            \"psu302g\",\n            \"psu302a\",\n        }", 1, "Sea Parity projectile-directory block");
		string appendix = "\n-- SCOM Field Fixes cache-only projectile folders 1.0.0\n-- FilesCache indexes physical directories only, so expose every template inserted by this transaction.\nlocal SCOFieldFixPreviousScanDir = ScanDir\nlocal SCOFieldFixGeneratedProjectileFolders = {\n    \"psn001\",\n    \"psn002\",\n    \"psn003\",\n    \"psn004\",\n    \"psn005\",\n    \"psk201\",\n    \"psm401\",\n    \"psu404s\",\n    \"pst001\", \"pst002\", \"pst003\", \"pst004\", \"pst005\",\n    \"pst006\", \"pst007\", \"pst008\", \"pst009\",\n}\nfunction ScanDir(directory)\n    local folders = SCOFieldFixPreviousScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n    local known = {}\n    for _, folder in ipairs(folders) do\n        known[string.lower(folder)] = true\n    end\n    for _, templateId in ipairs(SCOFieldFixGeneratedProjectileFolders) do\n        local folder = directory .. templateId\n        local folderKey = string.lower(folder)\n        if not known[folderKey] then\n            table.insert(folders, folder)\n            known[folderKey] = true\n        end\n    end\n    return folders\nend\n";
		string source3 = Append(source2, appendix);
		ValidateImportScanner(source3, "-- SCOM Field Fixes cache-only projectile folders 1.0.0");
		return AppendReviewedRuntime(source3, RosterScannerAppendix());
	}

	private static string RosterScannerAppendix()
	{
		return "-- SCOM source roster cache folders 1.0.0\nlocal previousSourceRosterScan = ScanDir\nlocal sourceRosterFolders = {\n    ['common/units/unitsTemplates/'] = { " + Ids(RosterContracts.NewIds.Concat<string>(new string[1] { "ucl9505" }).ToArray()) + " },\n    ['common/projectiles/projectilesTemplates/'] = { " + Ids(RosterContracts.ProjectileIds) + " },\n}\nfunction ScanDir(directory)\n    local folders = previousSourceRosterScan(directory)\n    local ids = sourceRosterFolders[directory]\n    if not ids then return folders end\n    local known = {}\n    for _, folder in ipairs(folders) do known[string.lower(folder)] = true end\n    for _, id in ipairs(ids) do\n        local path = directory .. id\n        if not known[string.lower(path)] then folders[#folders + 1] = path; known[string.lower(path)] = true end\n    end\n    return folders\nend\n";
		static string Ids(string[] ids)
		{
			return string.Join(", ", ids.Select((string id) => "\"" + id + "\""));
		}
	}

	private static void ValidateImportScanner(string source, string marker)
	{
		RequireExactly(source, marker, 1, "field-fix projectile-folder marker");
		RequireExactly(source, "local SCOFieldFixPreviousScanDir = ScanDir", 1, "field-fix ScanDir capture");
		RequireExactly(source, "local folders = SCOFieldFixPreviousScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then", 1, "field-fix projectile-directory guard");
		string[] array = new string[8] { "psn001", "psn002", "psn003", "psn004", "psn005", "psk201", "psm401", "psu404s" };
		foreach (string text in array)
		{
			RequireExactly(source, "    \"" + text + "\",", 1, text + " cache-only projectile registration");
		}
		RequireExactly(source, "for _, templateId in ipairs(SCOFieldFixGeneratedProjectileFolders) do", 1, "cache-only projectile registration loop");
		RequireExactly(source, "known[string.lower(folder)] = true", 1, "case-insensitive existing-folder registration");
		RequireExactly(source, "local folderKey = string.lower(folder)", 1, "case-insensitive generated-folder key");
		RequireExactly(source, "local SCOFieldFixPreviousScanDir = ScanDir\nlocal SCOFieldFixGeneratedProjectileFolders = {", 1, "field-fix ScanDir wrapper anchor");
	}

	private static void ValidateProjectileTemplateLoader(string source)
	{
		RequireExactly(source, "    SCO_FieldFixAttachProjectileMesh(tp, prefabTemplate)", 1, "source projectile mesh registration binding");
		RequireExactly(source, "-- Supreme Commander Overhaul projectile field fixes 1.0.1", 1, "projectile field-fix marker");
		RequireExactly(source, "-- SCOM Field Fix: Supreme Commander artillery water collider 1.0.0", 1, "Supreme Commander artillery water-collider marker");
		PatchFaArtilleryProjectileWaterCollider(source);
		RequireExactly(source, "function SCO_FieldFixCybran(tp, tpId)", 1, "projectile-local Cybran mutator");
		RequireExactly(source, "local SCO_FieldFixPreviousCreateProjectilePrefab = CreateProjectilePrefab", 1, "captured projectile-prefab loader");
		RequireExactly(source, "    SCO_FieldFixCybran(tp, tpId)", 1, "Cybran projectile dispatcher call");
		RequireExactly(source, "return SCO_FieldFixPreviousCreateProjectilePrefab(tp)", 1, "projectile-loader return forwarding");
		RequireExactly(source, "-- SCOM Field Fixes 1.3.1 - owned presentation-only projectile hierarchies.", 1, "owned projectile hierarchy marker");
		RequireExactly(source, "local function appendPresentationChild(tp, hierarchyEntities)", 1, "Ythotha projectile hierarchy mutator");
		RequireExactly(source, "local function appendTitanPresentationChild(tp, hierarchyEntities)", 1, "Titan projectile hierarchy mutator");
		RequireExactly(source, "local function appendAhwassaPresentationChild(tp, hierarchyEntities)", 1, "Ahwassa projectile hierarchy mutator");
		RequireExactly(source, "local SCO_FieldFixSeraphimProjectileHierarchyVersion = \"1.3.1\"", 1, "Seraphim projectile hierarchy appendix version");
		RequireExactly(source, "local titanProjectileId = \"per303\"", 1, "Titan dedicated projectile presentation ID");
		RequireExactly(source, "local titanChildName = \"SCO_Titan_Commander_Projectile_Visual\"", 1, "Titan dedicated projectile presentation child");
		RequireExactly(source, "local titanScale = 0.65", 1, "Titan smaller commander-projectile scale");
		RequireExactly(source, "VFX/Trails/vct2101_rocket_antitank_small_trail.sanvfx", 1, "Titan commander-projectile trail donor");
		RequireExactly(source, "local ahwassaProjectileId = \"psb402\"", 1, "Ahwassa dedicated projectile presentation ID");
		RequireExactly(source, "local ahwassaChildName = \"SCO_Ahwassa_Commander_Projectile_Visual\"", 1, "Ahwassa dedicated projectile presentation child");
		RequireExactly(source, "local ahwassaScale = 6", 1, "Ahwassa scale-six mesh-core presentation contract");
		RequireExactly(source, "tp.nonUniformScale", 3, "projectile scale metadata must remain validation-only");
		RequireExactly(source, "local ahwassaScaleMetadata = tp.nonUniformScale", 1, "Ahwassa scale metadata validation read");
		RequireExactly(source, "local ahwassaHierarchyScale = 1", 1, "Ahwassa neutral projectile hierarchy scale");
		RequireExactly(source, "VFX/SCOM/FieldFixes/Ahwassa/ahwassa_strategic_bomb_6x.sanvfx", 1, "Ahwassa dedicated mesh-backed projectile VFX");
		RequireExactly(source, "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx", 1, "Ahwassa commander-projectile impact donor");
		RequireExactly(source, "local function appendOwnedPresentationChildren(tp, hierarchyEntities)", 1, "owned projectile presentation dispatcher");
		RequireExactly(source, "hierarchyEntities = appendPresentationChild(tp, hierarchyEntities)", 1, "Ythotha projectile presentation dispatch");
		RequireExactly(source, "hierarchyEntities = appendTitanPresentationChild(tp, hierarchyEntities)", 1, "Titan projectile presentation dispatch");
		RequireExactly(source, "return appendAhwassaPresentationChild(tp, hierarchyEntities)", 1, "Ahwassa projectile presentation dispatch");
		RequireExactly(source, "EngineClasses.HierarchyTemplate(SCO_FieldFixSeraphimProjectileHierarchy(tp, hierarchyEntities)),", 1, "Ythotha projectile hierarchy routing");
		RequireExactly(source, "EngineClasses.HierarchyTemplate(hierarchyEntities),", 0, "unrouted stock projectile hierarchy constructor");
		RequireExactly(source, "function CreateProjectilePrefab(tp)", 2, "wrapped projectile-prefab loaders");
	}

	private static string PatchClientUnitBase(string source)
	{
		string text = Normalize(source);
		string text2 = LoadEmbeddedText("ScomFieldFixes.client_unit_appendix.lua").Trim();
		if (Count(text, "-- SCOM Field Fix: upgrade presentation, team construction color, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.14") == 1)
		{
			RequireExactly(text, "-- SCOM Field Fix: upgrade presentation, faction construction palette, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.13", 0, "retired faction construction-color marker");
			RequireExactly(text, "-- SCOM Field Fix: upgrade presentation, neutral construction blueprints, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.12", 0, "retired neutral construction-blueprint marker");
			RequireExactly(text, "-- SCOM Field Fix: upgrade presentation, faction construction palette, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.11", 0, "retired faction construction-palette marker");
			ValidateClientUnitBase(text, "-- SCOM Field Fix: upgrade presentation, team construction color, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.14");
			return text;
		}
		RequireExactly(text, "-- SCOM Field Fix: upgrade presentation, team construction color, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.14", 0, "preexisting construction-palette marker");
		if (Count(text, "-- SCOM Field Fix: upgrade presentation, faction construction palette, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.13") == 1)
		{
			RequireExactly(text, "-- SCOM Field Fix: upgrade presentation, neutral construction blueprints, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.12", 0, "mixed neutral construction-blueprint marker");
			RequireExactly(text, "-- SCOM Field Fix: upgrade presentation, faction construction palette, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.11", 0, "mixed faction construction-palette marker");
			int num = text.IndexOf("-- SCOM Field Fix: upgrade presentation, faction construction palette, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.13", StringComparison.Ordinal);
			int num2 = text.IndexOf("\n\nlocal SCO_ConstructionTargets", num, StringComparison.Ordinal);
			if (num2 < 0)
			{
				throw new InvalidOperationException("Client-unit appendix boundary changed; refusing an unbounded construction-color migration.");
			}
			string text3 = text.Substring(num, num2 - num).Trim();
			using SHA256 sHA = SHA256.Create();
			string text4 = BitConverter.ToString(sHA.ComputeHash(Encoding.UTF8.GetBytes(text3))).Replace("-", "");
			if (text4 != "7BB2242D1F64F526C6BAAF26ECD16C663A68D878FC3BEE127EDA7B22A7B7AECC" && text4 != "292B5BEB2F4A7E2FBCA24F41C38FA4A5C68B59921A54AF6F804E25E9670BECC5")
			{
				throw new InvalidOperationException("Existing client-unit appendix drifted; refusing construction-color migration.");
			}
			string text5 = text3.Replace("-- SCOM Field Fix: upgrade presentation, faction construction palette, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.13", "-- SCOM Field Fix: upgrade presentation, team construction color, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.14");
			int num3 = text5.IndexOf("local SCO_FieldFixConstructionColors = {", StringComparison.Ordinal);
			int num4 = text5.IndexOf("local function SCO_FieldFixCopyColor(color)", num3, StringComparison.Ordinal);
			int num5 = text2.IndexOf("local function SCO_FieldFixResolveConstructionColor(unit)", StringComparison.Ordinal);
			int num6 = text2.IndexOf("local function SCO_FieldFixRememberConstructionRestoreColor(unit, fallback)", num5, StringComparison.Ordinal);
			if (num3 < 0 || num4 < 0 || num5 < 0 || num6 < 0)
			{
				throw new InvalidOperationException("Construction-color helper boundary changed; refusing migration.");
			}
			text5 = text5.Substring(0, num3) + text5.Substring(num4);
			int num7 = text5.IndexOf("local function SCO_FieldFixResolveConstructionColor(unit)", StringComparison.Ordinal);
			int num8 = text5.IndexOf("local function SCO_FieldFixRememberConstructionRestoreColor(unit, fallback)", num7, StringComparison.Ordinal);
			if (num7 < 0 || num8 < 0)
			{
				throw new InvalidOperationException("Construction-color resolver boundary changed; refusing migration.");
			}
			text5 = text5.Substring(0, num7) + text2.Substring(num5, num6 - num5) + text5.Substring(num8);
			text = text.Substring(0, num) + text5 + text.Substring(num2);
			ValidateClientUnitBase(text, "-- SCOM Field Fix: upgrade presentation, team construction color, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.14");
			return text;
		}
		RequireExactly(text, "-- SCOM Field Fix: upgrade presentation, faction construction palette, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.13", 0, "preexisting faction construction-color marker");
		int num9 = Count(text, "-- SCOM Field Fix: upgrade presentation, neutral construction blueprints, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.12");
		int num10 = Count(text, "-- SCOM Field Fix: upgrade presentation, faction construction palette, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.11");
		if (num9 != 0 || num10 != 0)
		{
			if (num9 + num10 != 1)
			{
				throw new InvalidOperationException("Mixed legacy client-unit color appendices; refusing migration.");
			}
			string value = ((num9 == 1) ? "-- SCOM Field Fix: upgrade presentation, neutral construction blueprints, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.12" : "-- SCOM Field Fix: upgrade presentation, faction construction palette, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.11");
			string expectedSha = ((num9 == 1) ? "1D9FBB83660A5DE19C408800F57C7103B49C3A3FFC0130BDD65E4248C455B594" : "9CCB0E621782BD70E9D1864005A80A5F38BE6D3B6F4705F72BFF0CE3978EBB17");
			string description = ((num9 == 1) ? "legacy neutral construction-blueprint appendix" : "legacy faction construction-palette appendix");
			int num11 = text.IndexOf(value, StringComparison.Ordinal);
			int num12 = text.IndexOf("\n\nlocal SCO_ConstructionTargets", num11, StringComparison.Ordinal);
			if (num12 < 0)
			{
				throw new InvalidOperationException("Legacy client-unit appendix boundary changed; refusing an unbounded migration.");
			}
			RequireTextSha256(text.Substring(num11, num12 - num11).Trim(), expectedSha, description);
			text = text.Substring(0, num11) + text2 + text.Substring(num12);
			ValidateClientUnitBase(text, "-- SCOM Field Fix: upgrade presentation, team construction color, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.14");
			return text;
		}
		RequireExactly(text, "function ClientUnit:SetRenderBuildProgress(fractionComplete)", 1, "stock render-build-progress method");
		RequireExactly(text, "function ClientUnit:SetColor(color)", 1, "stock renderer-color method");
		RequireExactly(text, "function ClientUnit:OnCompleted()", 1, "stock completion callback");
		RequireExactly(text, "function ClientUnit:OnStartUpgrade(upgrader)", 1, "stock upgrade-start callback");
		RequireExactly(text, "function ClientUnit:OnEndUpgrade(upgrader)", 1, "stock upgrade-end callback");
		RequireExactly(text, "function ClientUnit:OnEndUpgrading(upgrade)", 1, "stock upgrader-end callback");
		RequireExactly(text, "function ClientUnit:OnIntelVision()", 1, "stock intel-vision callback");
		RequireExactly(text, "function ClientUnit:UpdateProgressBars(health, maxHealth)", 1, "stock progress-bars callback");
		RequireExactly(text, "function ClientUnit:SetUpConstructionBeam()", 1, "stock construction-beam setup callback");
		RequireExactly(text, "function ClientUnit:RenderUpdateBeams()", 0, "stock construction-beam render callback");
		RequireExactly(text, "-- SCOM Field Fix: opt-in multi-endpoint construction beams 1.0.0", 0, "preexisting multi-construction-beam marker");
		RequireExactly(text, "local function SCO_CreateCybranBuildDroneBeam(", 0, "preexisting Cybran construction-drone controller");
		string text6 = LoadEmbeddedText("ScomFieldFixes.cybran_build_drones_appendix.lua").Trim();
		string text7 = LoadEmbeddedText("ScomFieldFixes.construction_target_appendix.lua").Trim();
		string text8 = LoadEmbeddedText("ScomFieldFixes.multi_construction_beam_appendix.lua").Trim();
		string text9 = Append(text, text2 + "\n\n" + text7 + "\n\n" + text6 + "\n\n" + text8 + "\n");
		ValidateClientUnitBase(text9, "-- SCOM Field Fix: upgrade presentation, team construction color, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.14");
		return text9;
	}

	private static void ValidateClientUnitBase(string source, string marker)
	{
		RequireExactly(source, marker, 1, "upgrade-overlay marker");
		string token = LoadEmbeddedText("ScomFieldFixes.client_unit_appendix.lua").Trim();
		if (Count(source, token) != 1)
		{
			RequireExactly(source, token, 0, "client-unit appendix bytes");
			int num = source.IndexOf(marker, StringComparison.Ordinal);
			int num2 = source.IndexOf("\n\nlocal SCO_ConstructionTargets", num, StringComparison.Ordinal);
			if (num < 0 || num2 < 0)
			{
				throw new InvalidOperationException("Migrated client-unit appendix boundary changed.");
			}
			RequireTextSha256(source.Substring(num, num2 - num).Trim(), "BFE61EEF62C262F9F8157683796FBA05654F51BDE42E81D78E63B85111619F23", "migrated live client-unit appendix");
		}
		RequireExactly(source, LoadEmbeddedText("ScomFieldFixes.construction_target_appendix.lua").Trim(), 1, "construction-target appendix bytes");
		RequireExactly(source, LoadEmbeddedText("ScomFieldFixes.cybran_build_drones_appendix.lua").Trim(), 1, "Cybran construction-drone appendix bytes");
		RequireExactly(source, "local function SCO_CreateCybranBuildDroneBeam(", 1, "Cybran construction-drone controller factory");
		RequireExactly(source, "and SCO_CreateCybranBuildDroneBeam(self, self.constructionBeam)", 1, "Cybran construction-drone setup dispatch");
		RequireExactly(source, LoadEmbeddedText("ScomFieldFixes.multi_construction_beam_appendix.lua").Trim(), 1, "multi-construction-beam appendix bytes");
		RequireExactly(source, "local SCO_FieldFixStockClientUnitInit = ClientUnit.__init", 1, "captured client-unit constructor");
		RequireExactly(source, "local SCO_FieldFixStockSetColor = ClientUnit.SetColor", 1, "captured renderer-color method");
		RequireExactly(source, "local function SCO_FieldFixSetStrategicIconTeamColor(unit, color)", 1, "team-owned strategic-icon color helper");
		RequireExactly(source, "local function SCO_FieldFixCurrentTeamColor(unit, fallback)", 1, "current team-color resolver");
		RequireExactly(source, "local teamColor = SCO_FieldFixCurrentTeamColor(unit, color)", 1, "owning-army strategic-icon color source");
		RequireExactly(source, "SCO_FieldFixSetStrategicIconTeamColor(self, color)", 1, "team-color propagation through completed-unit color changes");
		RequireExactly(source, "SCO_FieldFixSetStrategicIconTeamColor(unit, teamColor)", 1, "team-color propagation during construction");
		RequireExactly(source, "SCO_FieldFixSetStrategicIconTeamColor(unit, restore)", 1, "team-color propagation through construction completion");
		RequireExactly(source, "SCO_FieldFixSetStrategicIconTeamColor(self, iconTeamColor)", 1, "team-color correction after initial icon creation");
		RequireExactly(source, "local SCO_FieldFixStockSetRenderBuildProgress = ClientUnit.SetRenderBuildProgress", 1, "captured render-build-progress method");
		RequireExactly(source, "local SCO_FieldFixStockOnCompleted = ClientUnit.OnCompleted", 1, "captured completion callback");
		RequireExactly(source, "local SCO_FieldFixStockOnStartUpgrade = ClientUnit.OnStartUpgrade", 1, "captured upgrade-start callback");
		RequireExactly(source, "local SCO_FieldFixStockOnEndUpgrade = ClientUnit.OnEndUpgrade", 1, "captured upgrade-end callback");
		RequireExactly(source, "local SCO_FieldFixStockOnEndUpgrading = ClientUnit.OnEndUpgrading", 1, "captured upgrader-end callback");
		RequireExactly(source, "local SCO_FieldFixStockOnIntelVision = ClientUnit.OnIntelVision", 1, "captured intel-vision callback");
		RequireExactly(source, "local SCO_FieldFixStockUpdateProgressBars = ClientUnit.UpdateProgressBars", 1, "captured progress-bars callback");
		RequireExactly(source, "local SCO_FieldFixStockClientUnitOnDestroy = ClientUnit.OnDestroy", 1, "captured client-unit destroy callback");
		RequireExactly(source, "local SCO_FieldFixStockClientUnitOnDelete = ClientUnit.OnDelete", 1, "captured client-unit delete callback");
		RequireExactly(source, "local SCO_FieldFixStockRenderUpdateBeams = ClientUnit.RenderUpdateBeams or function() end", 1, "captured client-unit render callback");
		RequireExactly(source, "function ClientUnit:SetRenderBuildProgress(fractionComplete)", 2, "wrapped render-build-progress methods");
		RequireExactly(source, "function ClientUnit:SetColor(color)", 2, "wrapped renderer-color methods");
		RequireExactly(source, "function ClientUnit:OnCompleted()", 2, "wrapped completion callbacks");
		RequireExactly(source, "local SCO_FieldFixConstructionColors = {", 0, "retired faction construction-color table");
		RequireExactly(source, "local SCO_FieldFixConstructionFactionTags = {", 0, "retired faction-tag filter");
		RequireExactly(source, "local function SCO_FieldFixResolveConstructionColor(unit)", 1, "construction-color resolver");
		RequireExactly(source, "if not unit:HasTags(Tags.STRUCTURE) then return nil end", 1, "structure-only construction-color ownership");
		RequireExactly(source, "return SCO_FieldFixCurrentTeamColor(unit, nil)", 1, "dynamic owning-team construction color");
		RequireExactly(source, "local function SCO_FieldFixApplyConstructionColor(unit, fractionComplete)", 1, "construction-color lifecycle owner");
		RequireExactly(source, "if unit:IsPlacementGhost() then return end", 1, "placement-preview construction-color exclusion");
		RequireExactly(source, "if self:IsPlacementGhost() then\n        return SCO_FieldFixStockSetColor(self, color)\n    end", 1, "stock placement-preview renderer delegation");
		RequireExactly(source, "SCO_FieldFixStockSetColor(unit, color)", 1, "team construction renderer write");
		RequireExactly(source, "return SCO_FieldFixStockSetColor(self, palette)", 1, "mid-construction team-color enforcement");
		RequireExactly(source, "local function SCO_FieldFixRestoreConstructionColor(unit)", 1, "current-team completion restore");
		RequireExactly(source, "local restore = SCO_FieldFixCurrentTeamColor(\n        unit,\n        unit.scoFieldFixConstructionRestoreColor)", 1, "current team preferred over stale restore state");
		RequireExactly(source, "SCO_FieldFixApplyConstructionColor(self, fraction)", 1, "constructor construction-color enforcement");
		RequireExactly(source, "SCO_FieldFixApplyConstructionColor(self, fractionComplete)", 1, "progress-update construction-color enforcement");
		RequireExactly(source, "local SCO_FieldFixNeutralBlueprintColor", 0, "retired white blueprint override");
		RequireExactly(source, "scoFieldFixBlueprint", 0, "retired blueprint color ownership state");
		RequireExactly(source, "function ClientUnit:OnStartUpgrade(upgrader)", 2, "wrapped upgrade-start callbacks");
		RequireExactly(source, "function ClientUnit:OnEndUpgrade(upgrader)", 2, "wrapped upgrade-end callbacks");
		RequireExactly(source, "function ClientUnit:OnEndUpgrading(upgrade)", 2, "wrapped upgrader-end callbacks");
		RequireExactly(source, "function ClientUnit:OnIntelVision()", 2, "wrapped intel-vision callbacks");
		RequireExactly(source, "function ClientUnit:UpdateProgressBars", 2, "wrapped progress-bars callbacks");
		RequireExactly(source, "function ClientUnit:OnDestroy", 3, "wrapped client-unit destroy callbacks");
		RequireExactly(source, "function ClientUnit:OnDelete", 3, "wrapped client-unit delete callbacks");
		RequireExactly(source, "function ClientUnit:SetUpConstructionBeam()", 2, "wrapped multi-construction-beam setup callbacks");
		RequireExactly(source, "function ClientUnit:RenderUpdateBeams", 2, "wrapped artillery and multi-construction-beam render callbacks");
		RequireExactly(source, "function ClientUnit:__init(\n    globalId,", 1, "field-fix client-unit constructor wrapper");
		RequireExactly(source, "function ClientUnit:ClientOnRepaired", 2, "wrapped repaired terminal callbacks");
		RequireExactly(source, "function ClientUnit:ClientOnCaptured", 2, "wrapped captured terminal callbacks");
		RequireExactly(source, "SCO_FieldFixStopConstructionLifecycle(self)", 13, "client construction-lifecycle cleanup calls");
		RequireExactly(source, "function SCO_FieldFixStartFaArtilleryRecoil(unit, contract)", 1, "FA artillery recoil start bridge");
		RequireExactly(source, "SCO_FieldFixApplyFaArtilleryRecoil(", 2, "FA artillery recoil definition and render dispatch");
		RequireExactly(source, "SCO_FieldFixResetFaArtilleryRecoil(self, true)", 2, "FA artillery recoil terminal resets");
		RequireExactly(source, "SCO_FieldFixStockSetRenderBuildProgress(self, fraction)", 1, "constructor build-progress initialization");
		RequireExactly(source, "local result = SCO_FieldFixStockSetRenderBuildProgress(\n        self,\n        fractionComplete)", 1, "render-build-progress forwarding");
		RequireExactly(source, "local function SCO_FieldFixHasProgressBoundUpgrade(unit)", 1, "progress-owned upgrade predicate");
		RequireExactly(source, "local function SCO_FieldFixIsStructureUpgradePair(target, source)", 1, "structure upgrade-pair predicate");
		RequireExactly(source, "local function SCO_FieldFixOwnsUpgradePresentation(target, source)", 1, "upgrade-presentation ownership predicate");
		RequireExactly(source, "if SCO_FieldFixOwnsUpgradePresentation(self, upgrader) then", 1, "structure-aware replacement hiding");
		RequireExactly(source, "local retireSource = SCO_FieldFixOwnsUpgradePresentation(upgrade, self)", 1, "structure-aware source retirement");
		RequireExactly(source, "self.scoFieldFixProgressUpgradeTargetHidden = true", 1, "progress-owned replacement hiding");
		RequireExactly(source, "self.scoFieldFixProgressUpgradeSourceRetiring = true", 1, "completed source retirement");
		RequireExactly(source, "local completed = wasHidden and self:IsCompleted()", 1, "completed replacement reveal independent of retired source lifetime");
		RequireExactly(source, "and not upgrader.dead", 0, "obsolete completed-source reveal dependency");
		RequireExactly(source, "SCO_FieldFixSetUpgradeVisualHidden(self)", 4, "upgrade visual single-owner enforcement");
		RequireExactly(source, "elseif SCO_FieldFixIsFactoryUpgradeBuild(self) then", 1, "factory self-upgrade beam guard");
		RequireExactly(source, "SCO_FieldFixDisableConstructionBeam(self)", 1, "factory self-upgrade beam suppression");
		RequireExactly(source, "        fractionComplete = 1", 0, "retired eager upgrade completion override");
		RequireExactly(source, "local result = SCO_FieldFixStockUpdateProgressBars(self, ...)", 1, "stock-first progress-bars forwarding");
		RequireExactly(source, "local commanderState = self.scoCommanderEnhancementState", 1, "commander enhancement progress state lookup");
		RequireExactly(source, "local commanderActive = type(commanderState) == \"table\"", 1, "active commander enhancement lookup");
		RequireExactly(source, "local commanderFraction = type(commanderActive) == \"table\"", 1, "commander enhancement fraction lookup");
		RequireExactly(source, "and commanderFraction == commanderFraction", 1, "commander enhancement NaN rejection");
		RequireExactly(source, "and commanderFraction > -math.huge", 1, "commander enhancement negative-infinity rejection");
		RequireExactly(source, "and commanderFraction < math.huge", 1, "commander enhancement positive-infinity rejection");
		RequireExactly(source, "local progress = math.max(0, math.min(1, commanderFraction))", 1, "bounded commander enhancement progress");
		RequireExactly(source, "        bar:SetMaxValue(1)", 1, "commander enhancement WorkProgress maximum");
		RequireExactly(source, "local getState = _G.SCO_GetStrategicSiloClientState", 1, "strategic silo state lookup");
		RequireExactly(source, "progress = math.max(0, math.min(1, state.work / state.buildTime))", 1, "bounded strategic silo progress");
		RequireExactly(source, "bar:SetValue(progress)", 2, "shared WorkProgress values");
		RequireExactly(source, "bar:SetEnabled(true)", 2, "shared WorkProgress enables");
		RequireExactly(source, "    return result", 21, "client callback return forwarding");
		RequireExactly(source, "return SCO_ProwlerStockRecalculatePersistentEffectsState(self)", 1, "Prowler stock persistent-effect forwarding");
		RequireExactly(source, "if not SCO_IsProwlerExhaustOwner(self) then\n        return result\n    end\n    local moving = false", 1, "Prowler non-owner audio forwarding");
		RequireExactly(source, "self:RecalculatePersistentEffectsState()\n    end\n    return result\nend", 1, "Prowler owned audio forwarding");
		RequireExactly(source, "local SCO_MultiBeamGroup = {}", 1, "multi-construction-beam composite declaration");
		RequireExactly(source, "scoMultiConstructionBeam = true", 1, "multi-construction-beam ownership tag");
		RequireExactly(source, "Engine.SetLocalEntityLocalPosition(\n                state.rootId,\n                state.muzzlePosition)", 1, "render-rate multi-beam endpoint pinning");
		RequireExactly(source, "Engine.DeletePrefabInstance(state.rootId)", 1, "multi-beam loose-root cleanup");
		RequireExactly(source, "function SCO_MultiBeamGroup:SetTarget(target)", 1, "multi-beam target fan-out");
		RequireExactly(source, "function SCO_MultiBeamGroup:SetEnabled(enabled)", 1, "multi-beam visibility fan-out");
		RequireExactly(source, "function SCO_MultiBeamGroup:RemoveTarget()", 1, "multi-beam target cleanup");
	}

	private static string PatchInformationPanel(string source)
	{
		string text = Normalize(source);
		if (Count(text, "-- SCOM Field Fix: strategic silo information-panel progress 1.0.0") == 1)
		{
			ValidateInformationPanel(text, "-- SCOM Field Fix: strategic silo information-panel progress 1.0.0", "function InformationPanel:UpdateUnitInformationPanel(unit)", "    local unitName = unit.tp.general.name\n", "function InformationPanel:UpdateUnitInformationPanelTemplate(tp)", "        isConstructionPercentEnabled = false,\n        constructionPercent = 0,", "        isConstructionPercentEnabled = false,\n        constructionPercent = 0,", "        isConstructionPercentEnabled = scoSiloBuilding,\n        constructionPercent = scoSiloProgress,", "    local scoSiloBuilding, scoSiloProgress =\n        SCOGetStrategicSiloInformationProgress(unit)\n");
			return text;
		}
		RequireExactly(text, "-- SCOM Field Fix: strategic silo information-panel progress 1.0.0", 0, "strategic silo information-progress marker");
		RequireExactly(text, "function InformationPanel:UpdateUnitInformationPanel(unit)", 1, "information-panel real-unit method");
		RequireExactly(text, "    local unitName = unit.tp.general.name\n", 1, "information-panel real-unit branch");
		RequireExactly(text, "function InformationPanel:UpdateUnitInformationPanelTemplate(tp)", 1, "information-panel template method");
		RequireExactly(text, "        isConstructionPercentEnabled = false,\n        constructionPercent = 0,", 2, "real-unit stock information-panel construction fields");
		RequireExactly(text, "        isConstructionPercentEnabled = false,\n        constructionPercent = 0,", 2, "template stock information-panel construction fields");
		string text2 = LoadEmbeddedText("ScomFieldFixes.strategic_silo_information_panel_appendix.lua").Trim();
		string text3 = text.Replace("function InformationPanel:UpdateUnitInformationPanel(unit)", text2 + "\n\nfunction InformationPanel:UpdateUnitInformationPanel(unit)").Replace("    local unitName = unit.tp.general.name\n", "    local unitName = unit.tp.general.name\n    local scoSiloBuilding, scoSiloProgress =\n        SCOGetStrategicSiloInformationProgress(unit)\n");
		int num = text3.IndexOf("function InformationPanel:UpdateUnitInformationPanelTemplate(tp)", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Information-panel template boundary disappeared during patching.");
		}
		string text4 = text3.Substring(0, num);
		string text5 = text3.Substring(num);
		RequireExactly(text4, "        isConstructionPercentEnabled = false,\n        constructionPercent = 0,", 1, "real-unit stock construction fields");
		RequireExactly(text5, "        isConstructionPercentEnabled = false,\n        constructionPercent = 0,", 1, "template stock construction fields");
		text4 = text4.Replace("        isConstructionPercentEnabled = false,\n        constructionPercent = 0,", "        isConstructionPercentEnabled = scoSiloBuilding,\n        constructionPercent = scoSiloProgress,");
		string text6 = text4 + text5;
		ValidateInformationPanel(text6, "-- SCOM Field Fix: strategic silo information-panel progress 1.0.0", "function InformationPanel:UpdateUnitInformationPanel(unit)", "    local unitName = unit.tp.general.name\n", "function InformationPanel:UpdateUnitInformationPanelTemplate(tp)", "        isConstructionPercentEnabled = false,\n        constructionPercent = 0,", "        isConstructionPercentEnabled = false,\n        constructionPercent = 0,", "        isConstructionPercentEnabled = scoSiloBuilding,\n        constructionPercent = scoSiloProgress,", "    local scoSiloBuilding, scoSiloProgress =\n        SCOGetStrategicSiloInformationProgress(unit)\n");
		return text6;
	}

	private static void ValidateInformationPanel(string source, string marker, string methodAnchor, string realUnitAnchor, string templateAnchor, string stockFields, string templateStockFields, string siloFields, string stateBinding)
	{
		RequireExactly(source, marker, 1, "strategic silo information-progress marker");
		RequireExactly(source, LoadEmbeddedText("ScomFieldFixes.strategic_silo_information_panel_appendix.lua").Trim(), 1, "strategic silo information-progress helper bytes");
		RequireExactly(source, methodAnchor, 1, "information-panel real-unit method");
		RequireExactly(source, realUnitAnchor, 1, "information-panel real-unit branch");
		RequireExactly(source, templateAnchor, 1, "information-panel template method");
		RequireExactly(source, stateBinding, 1, "strategic silo information-progress state binding");
		RequireExactly(source, "local function SCOGetStrategicSiloInformationProgress(unit)", 1, "strategic silo information-progress helper");
		RequireExactly(source, "progress = math.max(0, math.min(1, state.work / state.buildTime))", 1, "bounded information-panel progress");
		int num = source.IndexOf(marker, StringComparison.Ordinal);
		int num2 = source.IndexOf(methodAnchor, StringComparison.Ordinal);
		int num3 = source.IndexOf(realUnitAnchor, StringComparison.Ordinal);
		int num4 = source.IndexOf(stateBinding, StringComparison.Ordinal);
		int num5 = source.IndexOf(templateAnchor, StringComparison.Ordinal);
		if (num < 0 || num2 < 0 || num3 < 0 || num4 < 0 || num5 < 0 || num >= num2 || num2 >= num3 || num3 >= num4 || num4 >= num5)
		{
			throw new InvalidOperationException("Information-panel strategic progress hooks are out of order.");
		}
		string source2 = source.Substring(0, num5);
		string source3 = source.Substring(num5);
		RequireExactly(source2, siloFields, 1, "real-unit strategic silo construction fields");
		RequireExactly(source2, stockFields, 0, "real-unit stock construction fields");
		RequireExactly(source3, templateStockFields, 1, "unchanged template construction fields");
		RequireExactly(source3, siloFields, 0, "template strategic silo construction fields");
	}

	private static string PatchSurvival(string source)
	{
		string text = Normalize(source);
		if (Count(text, "-- SCOM Field Fix: land-safe Chosen T4 survival pool 1.0.1") == 1)
		{
			RequireExactly(text, "{ \"ucl4004\" },             -- T4", 1, "land-safe Chosen T4 pool");
			RequireExactly(text, "-- SCOM Field Fix: land-safe Chosen T4 survival pool 1.0.0", 0, "obsolete survival marker");
			return text;
		}
		RequireExactly(text, "-- SCOM Field Fix: land-safe Chosen T4 survival pool 1.0.1", 0, "survival marker");
		if (Count(text, "-- SCOM Field Fix: land-safe Chosen T4 survival pool 1.0.0") == 1)
		{
			RequireExactly(text, "{ \"ucl4001\" },             -- T4", 1, "obsolete naval Chosen T4 pool");
			return text.Replace("{ \"ucl4001\" },             -- T4", "{ \"ucl4004\" },             -- T4").Replace("-- SCOM Field Fix: land-safe Chosen T4 survival pool 1.0.0", "-- SCOM Field Fix: land-safe Chosen T4 survival pool 1.0.1");
		}
		RequireExactly(text, "-- SCOM Field Fix: land-safe Chosen T4 survival pool 1.0.0", 0, "obsolete survival marker");
		RequireExactly(text, "{ \"ucl4001\", \"ucl4003\" },             -- T4", 1, "Tempest survival entry");
		return Append(text.Replace("{ \"ucl4001\", \"ucl4003\" },             -- T4", "{ \"ucl4004\" },             -- T4"), "-- SCOM Field Fix: land-safe Chosen T4 survival pool 1.0.1\n");
	}

	private static string PatchHostBuildOrder(string source)
	{
		string text = Normalize(source);
		if (Count(text, "-- SCOM Field Fix: UEF naval minimum depth 0.5 host 1.0.0") == 1 && Count(text, "-- SCOM Field Fix: Cybran Hive half-cell host spawn 1.0.0") == 1)
		{
			ValidateDepthEntries(text, 0.5);
			ValidateHiveHostPlacement(text, "-- SCOM Field Fix: Cybran Hive half-cell host spawn 1.0.0");
			return text;
		}
		RequireExactly(text, "-- SCOM Field Fix: UEF naval minimum depth 0.5 host 1.0.0", 0, "host-depth marker");
		RequireExactly(text, "-- SCOM Field Fix: Cybran Hive half-cell host spawn 1.0.0", 0, "Hive host-placement marker");
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, "SeaParity host marker");
		RequireExactly(text, "function HostBuildOrder:OrderStart()", 3, "upstream HostBuildOrder OrderStart methods");
		string text2 = string.Join("\n", "-- SCOM Field Fix: Cybran Hive half-cell host spawn 1.0.0", "local SCO_FieldFixPreviousHostBuildOrderOrderStart = HostBuildOrder.OrderStart", string.Empty, "local function SCO_FieldFixGetHiveSpawnPosition(tp, logicalPosition)", "    local contract = tp and tp.additions", "        and tp.additions.scoFieldFixHivePlacement", "    if contract == nil then return nil end", "    local tpId = tp.general and tp.general.tpId", "    local offset = contract.offset", "    local skirt = tp.skirtSize", "    if (tpId ~= \"ugs2501\" and tpId ~= \"ugs3501\")", "        or contract.version ~= \"1.0.0\"", "        or contract.owner ~= \"SCO_FieldFixHivePlacementRuntime\"", "        or type(offset) ~= \"table\"", "        or offset.x ~= -0.5 or offset.z ~= -0.5", "        or type(skirt) ~= \"table\"", "        or skirt.x ~= 2 or skirt.y ~= 2", "        or logicalPosition == nil", "        or type(logicalPosition.x) ~= \"number\"", "        or type(logicalPosition.y) ~= \"number\"", "        or type(logicalPosition.z) ~= \"number\"", "    then", "        error(\"Invalid SCO Cybran Hive placement contract.\", 2)", "    end", "    return EngineClasses.float3(", "        logicalPosition.x + offset.x,", "        logicalPosition.y,", "        logicalPosition.z + offset.z)", "end", string.Empty, "function HostBuildOrder:OrderStart()", "    local spawnPosition = SCO_FieldFixGetHiveSpawnPosition(", "        self.tp, self.positionFloat3)", "    if spawnPosition == nil then", "        return SCO_FieldFixPreviousHostBuildOrderOrderStart(self)", "    end", "    HostBaseOrder:OrderStart()", "    self.unitGettingBuilt = CreateUnit(", "        self.armyId, self.tp.general.tpId, spawnPosition, nil, 0)", "end");
		string text3 = Append(ReplaceDepthEntries(text, 1.5, 0.5), "-- SCOM Field Fix: UEF naval minimum depth 0.5 host 1.0.0\n\n" + text2 + "\n");
		ValidateDepthEntries(text3, 0.5);
		ValidateHiveHostPlacement(text3, "-- SCOM Field Fix: Cybran Hive half-cell host spawn 1.0.0");
		return text3;
	}

	private static void ValidateHiveHostPlacement(string source, string marker)
	{
		RequireExactly(source, marker, 1, "Hive host-placement marker");
		RequireExactly(source, "local SCO_FieldFixPreviousHostBuildOrderOrderStart = HostBuildOrder.OrderStart", 1, "captured host build-order start");
		RequireExactly(source, "local function SCO_FieldFixGetHiveSpawnPosition(tp, logicalPosition)", 1, "Hive physical-position helper");
		RequireExactly(source, "    if (tpId ~= \"ugs2501\" and tpId ~= \"ugs3501\")", 1, "exact Hive template gate");
		RequireExactly(source, "        and tp.additions.scoFieldFixHivePlacement", 1, "Hive placement contract lookup");
		RequireExactly(source, "        or offset.x ~= -0.5 or offset.z ~= -0.5", 1, "Hive half-cell offset validation");
		RequireExactly(source, "    local spawnPosition = SCO_FieldFixGetHiveSpawnPosition(", 1, "derived Hive spawn position");
		RequireExactly(source, "        return SCO_FieldFixPreviousHostBuildOrderOrderStart(self)", 1, "ordinary build-order delegation");
		RequireExactly(source, "        self.armyId, self.tp.general.tpId, spawnPosition, nil, 0)", 1, "Hive physical-position CreateUnit call");
		RequireExactly(source, "self.positionFloat3 = spawnPosition", 0, "Hive mutation of the logical order position");
		RequireExactly(source, "function HostBuildOrder:OrderStart()", 4, "wrapped HostBuildOrder OrderStart methods");
	}

	private static string PatchConstructionPreview(string source)
	{
		string source2 = Normalize(source);
		if (Count(source2, "-- SCOM Field Fix: UEF naval minimum depth 0.5 preview 1.0.0") == 1 && Count(source2, "-- SCOM Field Fix: Cybran Hive half-cell preview 1.0.0") == 1)
		{
			ValidateDepthEntries(source2, 0.5);
			RequireExactly(source2, "local function SCOSeaParityPreviewPointIsSubmerged(tp, position, waterLevel)\n    local minimumDepth = SCOSeaParityMinimumDepth(tp)\n    if minimumDepth == nil then return false end\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend", (Count(source2, "-- Supreme Commander Overhaul final naval placement depth 1.0.0") == 1) ? 1 : 0, "final authored preview-depth function");
			RequireExactly(source2, "local function SCOSeaParityPreviewPointIsSubmerged(tp, position, waterLevel)\n    local id = tp and tp.general and tp.general.tpId\n    local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return minimumDepth ~= nil\n        and errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend", (Count(source2, "local function SCOSeaParityPreviewPointIsSubmerged(tp, position, waterLevel)\n    local minimumDepth = SCOSeaParityMinimumDepth(tp)\n    if minimumDepth == nil then return false end\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend") != 1) ? 1 : 0, "legacy per-template preview-depth function");
			ValidateHivePreviewPlacement(source2, "-- SCOM Field Fix: Cybran Hive half-cell preview 1.0.0", "            local _, ghostID = Engine.InstantiatePrefab(buildTemplateID, position, EngineClasses.float3(1.0, 1.0, 1.0), GetIdentityQuaternion())");
			return PatchPlacementGhostColor(source2, "            local _, ghostID = Engine.InstantiatePrefab(buildTemplateID, ghostPosition, EngineClasses.float3(1.0, 1.0, 1.0), GetIdentityQuaternion())", "            -- SCOM Field Fix: construction preview team color 1.0.0\n            local previewArmy = Armies[GetFocusArmy()]\n            if previewArmy then\n                Engine.SetRendererInstanceData0(ghostID, previewArmy:GetColor())\n            end");
		}
		RequireExactly(source2, "-- SCOM Field Fix: UEF naval minimum depth 0.5 preview 1.0.0", 0, "preview-depth marker");
		RequireExactly(source2, "-- SCOM Field Fix: Cybran Hive half-cell preview 1.0.0", 0, "Hive preview marker");
		RequireExactly(source2, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, "SeaParity preview markers");
		RequireExactly(source2, "            local _, ghostID = Engine.InstantiatePrefab(buildTemplateID, position, EngineClasses.float3(1.0, 1.0, 1.0), GetIdentityQuaternion())", 1, "stock construction-ghost instantiation");
		bool flag = Count(source2, "local function SCOSeaParityPreviewPointIsSubmerged(tp, position, waterLevel)\n    local minimumDepth = SCOSeaParityMinimumDepth(tp)\n    if minimumDepth == nil then return false end\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend") == 1;
		string text;
		if (flag)
		{
			RequireExactly(source2, "local function SCOSeaParityPreviewPointIsSubmerged(position, waterLevel)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - SCOSeaParityPreviewMargin\nend", 0, "obsolete global-margin preview function");
			RequireExactly(source2, "local function SCOSeaParityPreviewPointIsSubmerged(tp, position, waterLevel)\n    local id = tp and tp.general and tp.general.tpId\n    local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return minimumDepth ~= nil\n        and errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend", 0, "legacy per-template preview-depth function");
			text = ReplaceDepthEntries(source2, 1.5, 0.5);
		}
		else
		{
			RequireExactly(source2, "local function SCOSeaParityPreviewPointIsSubmerged(position, waterLevel)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - SCOSeaParityPreviewMargin\nend", 1, "global-margin preview function");
			RequireExactly(source2, "local function SCOSeaParityPreviewPointIsSubmerged(tp, position, waterLevel)\n    local id = tp and tp.general and tp.general.tpId\n    local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return minimumDepth ~= nil\n        and errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend", 0, "premature per-template preview-depth function");
			text = ReplaceDepthEntries(source2, 1.5, 0.5).Replace("local function SCOSeaParityPreviewPointIsSubmerged(position, waterLevel)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - SCOSeaParityPreviewMargin\nend", "local function SCOSeaParityPreviewPointIsSubmerged(tp, position, waterLevel)\n    local id = tp and tp.general and tp.general.tpId\n    local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return minimumDepth ~= nil\n        and errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend");
			RequireExactly(text, "SCOSeaParityPreviewPointIsSubmerged(routePoint, waterLevel)", 1, "route-point preview call");
			RequireExactly(text, "SCOSeaParityPreviewPointIsSubmerged(exitPoint, waterLevel)", 1, "exit-point preview call");
			text = text.Replace("SCOSeaParityPreviewPointIsSubmerged(routePoint, waterLevel)", "SCOSeaParityPreviewPointIsSubmerged(tp, routePoint, waterLevel)");
			text = text.Replace("SCOSeaParityPreviewPointIsSubmerged(exitPoint, waterLevel)", "SCOSeaParityPreviewPointIsSubmerged(tp, exitPoint, waterLevel)");
		}
		string newValue = string.Join("\n", "            -- SCOM Field Fix: Cybran Hive half-cell preview 1.0.0", "            local ghostPosition = position", "            local hiveContract = unitTemplate.additions", "                and unitTemplate.additions.scoFieldFixHivePlacement", "            if hiveContract ~= nil then", "                local tpId = unitTemplate.general and unitTemplate.general.tpId", "                local offset = hiveContract.offset", "                local skirt = unitTemplate.skirtSize", "                if (tpId ~= \"ugs2501\" and tpId ~= \"ugs3501\")", "                    or hiveContract.version ~= \"1.0.0\"", "                    or hiveContract.owner ~= \"SCO_FieldFixHivePlacementRuntime\"", "                    or type(offset) ~= \"table\"", "                    or offset.x ~= -0.5 or offset.z ~= -0.5", "                    or type(skirt) ~= \"table\"", "                    or skirt.x ~= 2 or skirt.y ~= 2", "                then", "                    error(\"Invalid SCO Cybran Hive preview contract.\", 2)", "                end", "                ghostPosition = EngineClasses.float3(", "                    position.x + offset.x,", "                    position.y,", "                    position.z + offset.z)", "            end", "            local _, ghostID = Engine.InstantiatePrefab(buildTemplateID, ghostPosition, EngineClasses.float3(1.0, 1.0, 1.0), GetIdentityQuaternion())");
		text = text.Replace("            local _, ghostID = Engine.InstantiatePrefab(buildTemplateID, position, EngineClasses.float3(1.0, 1.0, 1.0), GetIdentityQuaternion())", newValue);
		text = Append(text, "-- SCOM Field Fix: UEF naval minimum depth 0.5 preview 1.0.0\n");
		ValidateDepthEntries(text, 0.5);
		RequireExactly(text, "local function SCOSeaParityPreviewPointIsSubmerged(tp, position, waterLevel)\n    local minimumDepth = SCOSeaParityMinimumDepth(tp)\n    if minimumDepth == nil then return false end\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend", flag ? 1 : 0, "final authored preview-depth function");
		RequireExactly(text, "local function SCOSeaParityPreviewPointIsSubmerged(tp, position, waterLevel)\n    local id = tp and tp.general and tp.general.tpId\n    local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return minimumDepth ~= nil\n        and errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend", (!flag) ? 1 : 0, "legacy per-template preview-depth function");
		ValidateHivePreviewPlacement(text, "-- SCOM Field Fix: Cybran Hive half-cell preview 1.0.0", "            local _, ghostID = Engine.InstantiatePrefab(buildTemplateID, position, EngineClasses.float3(1.0, 1.0, 1.0), GetIdentityQuaternion())");
		return PatchPlacementGhostColor(text, "            local _, ghostID = Engine.InstantiatePrefab(buildTemplateID, ghostPosition, EngineClasses.float3(1.0, 1.0, 1.0), GetIdentityQuaternion())", "            -- SCOM Field Fix: construction preview team color 1.0.0\n            local previewArmy = Armies[GetFocusArmy()]\n            if previewArmy then\n                Engine.SetRendererInstanceData0(ghostID, previewArmy:GetColor())\n            end");
	}

	private static void ValidateHivePreviewPlacement(string source, string marker, string stockGhostInstantiation)
	{
		RequireExactly(source, marker, 1, "Hive preview marker");
		RequireExactly(source, stockGhostInstantiation, 0, "unshifted construction-ghost instantiation");
		RequireExactly(source, "            local ghostPosition = position", 1, "logical-to-ghost position derivation");
		RequireExactly(source, "                and unitTemplate.additions.scoFieldFixHivePlacement", 1, "Hive preview contract lookup");
		RequireExactly(source, "                if (tpId ~= \"ugs2501\" and tpId ~= \"ugs3501\")", 1, "exact Hive preview template gate");
		RequireExactly(source, "                    or offset.x ~= -0.5 or offset.z ~= -0.5", 1, "Hive preview offset validation");
		RequireExactly(source, "                ghostPosition = EngineClasses.float3(", 1, "derived Hive ghost position");
		RequireExactly(source, "            local _, ghostID = Engine.InstantiatePrefab(buildTemplateID, ghostPosition, EngineClasses.float3(1.0, 1.0, 1.0), GetIdentityQuaternion())", 1, "shifted construction-ghost instantiation");
		RequireExactly(source, "position = ghostPosition", 0, "logical preview-position mutation");
	}

	private static string ReplaceDepthEntries(string source, double oldValue, double newValue)
	{
		string[] array = new string[3] { "ues1513", "ues2513", "ues3513" };
		foreach (string text in array)
		{
			string text2 = "[\"" + text + "\"] = " + Lua(oldValue) + ",";
			string newValue2 = "[\"" + text + "\"] = " + Lua(newValue) + ",";
			RequireExactly(source, text2, 1, text + " old water-depth entry");
			source = source.Replace(text2, newValue2);
		}
		return source;
	}

	private static void ValidateDepthEntries(string source, double value)
	{
		string[] array = new string[3] { "ues1513", "ues2513", "ues3513" };
		foreach (string text in array)
		{
			RequireExactly(source, "[\"" + text + "\"] = " + Lua(value) + ",", 1, text + " water-depth entry");
		}
	}

	private static CacheMutation CreateAppendMutation(object cache, string path, string description, string resourceName)
	{
		return CreateMutation(cache, path, description, delegate(string source)
		{
			string text = Normalize(source);
			string text2 = LoadEmbeddedText(resourceName).Trim();
			string token = text2.Split(new char[1] { '\n' })[0];
			int num = Count(text, token);
			switch (num)
			{
			case 1:
				RequireExactly(text, text2, 1, description + " appendix bytes");
				return text;
			default:
				throw new InvalidOperationException(description + " marker count is " + num + ".");
			case 0:
			{
				string text3 = Append(text, text2 + "\n");
				RequireExactly(text3, text2, 1, description + " appendix bytes");
				return text3;
			}
			}
		});
	}

	private static CacheMutation CreateHostAssistMutation(object cache, params string[] resourceNames)
	{
		CacheMutation cacheMutation = CreateAppendSequenceMutation(cache, "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua", "strategic silo lifecycle and Mantis construction assistance", resourceNames);
		string text = cacheMutation.NewSource;
		if (Count(text, "self:FollowBehaviorStart(assistedUnit, (self.tp and self.tp.construction and self.tp.construction.range) or 10)") == 0)
		{
			RequireExactly(text, "self:FollowBehaviorStart(assisted, (self.tp and self.tp.construction and self.tp.construction.range) or 10)", 1, "native idle-assist follow target");
			text = text.Replace("self:FollowBehaviorStart(assisted, (self.tp and self.tp.construction and self.tp.construction.range) or 10)", "self:FollowBehaviorStart(assistedUnit, (self.tp and self.tp.construction and self.tp.construction.range) or 10)");
		}
		RequireExactly(text, "self:FollowBehaviorStart(assisted, (self.tp and self.tp.construction and self.tp.construction.range) or 10)", 0, "undefined idle-assist target");
		RequireExactly(text, "self:FollowBehaviorStart(assistedUnit, (self.tp and self.tp.construction and self.tp.construction.range) or 10)", 1, "corrected idle-assist target");
		text = NavalWreckMotionPolicy.PatchHostDeath(text);
		return new CacheMutation(cacheMutation.Resource, cacheMutation.Description, cacheMutation.OldSource, text);
	}

	private static CacheMutation CreateAppendSequenceMutation(object cache, string path, string description, params string[] resourceNames)
	{
		if (resourceNames.Length == 0)
		{
			throw new ArgumentException("At least one appendix resource is required.", "resourceNames");
		}
		return CreateMutation(cache, path, description, delegate(string source)
		{
			string normalized = Normalize(source);
			normalized = UpgradeYthothaHostDeathAppendix(normalized);
			string[] array = resourceNames.Select((string resourceName) => LoadEmbeddedText(resourceName).Trim()).ToArray();
			int[] source2 = array.Select((string appendix) => Count(normalized, appendix.Split(new char[1] { '\n' })[0])).ToArray();
			if (source2.All((int count) => count == 1))
			{
				ValidateAppendixSequence(normalized, description, array);
				return normalized;
			}
			if (source2.Any((int count) => count != 0))
			{
				throw new InvalidOperationException(description + " has a partial or duplicate appendix sequence.");
			}
			string text = normalized;
			string[] array2 = array;
			foreach (string text2 in array2)
			{
				text = Append(text, text2 + "\n");
			}
			ValidateAppendixSequence(text, description, array);
			return text;
		});
	}

	private static string PatchClientInputEvents(string source)
	{
		string source2 = PatchMegalithEnemyRightClick(source);
		source2 = InsertEmbeddedBefore(source2, "factory right-click and strategic silo target input", "return {\n    OnMouseLeftDown = OnMouseLeftDown,", "ScomFieldFixes.factory_ground_right_click_appendix.lua", "ScomFieldFixes.strategic_silo_target_input_appendix.lua", "ScomFieldFixes.Roster.source_cargo_client.lua", "ScomFieldFixes.Roster.source_pods_client.lua");
		if (Count(source2, "    SCOUnloadSelectedCargo = SCOUnloadSelectedCargo,\n    SCOSelectedPodAction = SCOSelectedPodAction,\n") == 0)
		{
			source2 = source2.Replace("return {\n    OnMouseLeftDown = OnMouseLeftDown,", "return {\n    SCOUnloadSelectedCargo = SCOUnloadSelectedCargo,\n    SCOSelectedPodAction = SCOSelectedPodAction,\n    OnMouseLeftDown = OnMouseLeftDown,");
		}
		RequireExactly(source2, "    SCOUnloadSelectedCargo = SCOUnloadSelectedCargo,\n    SCOSelectedPodAction = SCOSelectedPodAction,\n", 1, "cargo unload input export");
		return PatchPlacementGhostColor(source2, "        local _, predictedUnitLocalID = Engine.InstantiatePrefab(unitTemplate.general.placementGhostPrefabID, position, defaultScale, defaultRotation)", "        -- SCOM Field Fix: predicted build ghost team color 1.0.0\n        Engine.SetRendererInstanceData0(predictedUnitLocalID, Armies[builderArmyId]:GetColor())");
	}

	private static string PatchMegalithEnemyRightClick(string source)
	{
		string text = Normalize(source);
		switch (Count(text, "-- SCOM Field Fix: Megalith enemy right-click attacks 1.0.0"))
		{
		case 1:
			RequireExactly(text, "local isMegalith = firstUnit.tpId == \"ugl4002\"", 1, "Megalith enemy right-click identity check");
			RequireExactly(text, "if firstUnit:HasTags(Tags.COMMAND) or isMegalith then", 1, "Megalith enemy right-click attack branch");
			return text;
		default:
			throw new InvalidOperationException("Megalith enemy right-click patch marker is duplicated.");
		case 0:
		{
			RequireExactly(text, "                    if firstUnit:HasTags(Tags.COMMAND) then", 1, "Megalith enemy right-click stock command branch");
			string text2 = text.Replace("                    if firstUnit:HasTags(Tags.COMMAND) then", "                    -- SCOM Field Fix: Megalith enemy right-click attacks 1.0.0\n                    local isMegalith = firstUnit.tpId == \"ugl4002\"\n                        or (firstUnit.tp\n                            and firstUnit.tp.general\n                            and firstUnit.tp.general.tpId == \"ugl4002\")\n                    if firstUnit:HasTags(Tags.COMMAND) or isMegalith then");
			RequireExactly(text2, "-- SCOM Field Fix: Megalith enemy right-click attacks 1.0.0", 1, "Megalith enemy right-click patch marker");
			RequireExactly(text2, "if firstUnit:HasTags(Tags.COMMAND) or isMegalith then", 1, "Megalith enemy right-click attack branch");
			return text2;
		}
		}
	}

	private static CacheMutation CreateInsertBeforeMutation(object cache, string path, string description, string anchor, params string[] resourceNames)
	{
		if (resourceNames.Length == 0)
		{
			throw new ArgumentException("At least one appendix resource is required.", "resourceNames");
		}
		return CreateMutation(cache, path, description, (string source) => InsertEmbeddedBefore(source, description, anchor, resourceNames));
	}

	private static string InsertEmbeddedBefore(string source, string description, string anchor, params string[] resourceNames)
	{
		string normalized = Normalize(source);
		string[] array = resourceNames.Select((string resourceName) => LoadEmbeddedText(resourceName).Trim()).ToArray();
		int[] source2 = array.Select((string appendix) => Count(normalized, appendix.Split(new char[1] { '\n' })[0])).ToArray();
		if (source2.All((int count) => count == 1))
		{
			ValidateInsertedSequence(normalized, description, anchor, array);
			return normalized;
		}
		if (source2.Any((int count) => count != 0))
		{
			throw new InvalidOperationException(description + " has a partial or duplicate appendix sequence.");
		}
		RequireExactly(normalized, anchor, 1, description + " insertion anchor");
		string newValue = string.Join("\n\n", array) + "\n\n" + anchor;
		string text = normalized.Replace(anchor, newValue);
		ValidateInsertedSequence(text, description, anchor, array);
		return text;
	}

	private static void ValidateAppendixSequence(string source, string description, IReadOnlyList<string> appendices)
	{
		int num = -1;
		foreach (string appendix in appendices)
		{
			RequireExactly(source, appendix, 1, description + " appendix bytes");
			int num2 = source.IndexOf(appendix, StringComparison.Ordinal);
			if (num2 <= num)
			{
				throw new InvalidOperationException(description + " appendices are out of order.");
			}
			num = num2;
		}
	}

	private static void ValidateInsertedSequence(string source, string description, string anchor, IReadOnlyList<string> appendices)
	{
		RequireExactly(source, anchor, 1, description + " insertion anchor");
		ValidateAppendixSequence(source, description, appendices);
		int num = source.IndexOf(anchor, StringComparison.Ordinal);
		if (source.IndexOf(appendices[appendices.Count - 1], StringComparison.Ordinal) >= num)
		{
			throw new InvalidOperationException(description + " appendices do not precede their return anchor.");
		}
	}

	private static CacheMutation CreateMutation(object cache, string relativePath, string description, Func<string, string> transform)
	{
		CachedResource cachedResource = GetCachedResource(cache, relativePath);
		string text = ReadText(cachedResource.Value);
		string newSource = transform(text);
		return new CacheMutation(cachedResource, description, text, newSource);
	}

	private static CacheInsertion CreateInsertion(object cache, string relativePath, string description, string resourceName)
	{
		string text = LoadEmbeddedText(resourceName);
		if (resourceName == "ScomFieldFixes.Tarmac.runtime.lua")
		{
			text = LoadEmbeddedText("ScomFieldFixes.Tarmac.data.lua") + "\n" + text;
		}
		if (relativePath.StartsWith("LJ/lua/common/units/unitsTemplates/", StringComparison.Ordinal))
		{
			text = PatchSourceUnitCompletion(text, Path.GetFileNameWithoutExtension(relativePath));
		}
		if (relativePath.StartsWith("LJ/lua/common/projectiles/projectilesTemplates/", StringComparison.Ordinal))
		{
			text = AppendOptionalRosterResource(text, "ScomFieldFixes.Roster.Interception." + Path.GetFileNameWithoutExtension(relativePath) + ".lua");
			text = AppendOptionalRosterResource(text, "ScomFieldFixes.Roster.ProjectileVisuals." + Path.GetFileNameWithoutExtension(relativePath) + ".lua");
			text = AppendOptionalRosterResource(text, "ScomFieldFixes.Roster.YolonaEffects." + Path.GetFileNameWithoutExtension(relativePath) + ".lua");
		}
		CachedResource cachedResource = TryGetCachedResource(cache, relativePath);
		if (cachedResource != null)
		{
			ReadText(cachedResource.Value);
			_ = 4;
			return new CacheInsertion(cachedResource.Path, cachedResource.Value.GetType(), description, text, alreadyPresent: true);
		}
		CachedResource cachedResource2 = GetCachedResource(cache, "LJ/lua/common/loading/unitTemplateLoader.lua");
		string text2 = cachedResource2.Path.Replace('\\', '/');
		string text3 = "/LJ/lua/common/loading/unitTemplateLoader.lua";
		if (!text2.EndsWith(text3, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Could not derive the Lua cache root from " + cachedResource2.Path + ".");
		}
		string text4 = text2.Substring(0, text2.Length - text3.Length) + "/" + relativePath.Replace('\\', '/');
		return new CacheInsertion((cachedResource2.Path.IndexOf('\\') >= 0) ? text4.Replace('/', '\\') : text4, cachedResource2.Value.GetType(), description, text, alreadyPresent: false);
	}

	private static void ValidateUpstreamIdentity()
	{
		if (!string.Equals(FindLoadedType("EM.Lua.FilesCache").Module.ModuleVersionId.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Trebuchet.dll MVID drifted.");
		}
		CanonicalAssemblyContract.RequireCanonicalTypes("SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime", "SupremeCommanderOverhaulSeaParity.CachePatcherRuntime", "SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime", "SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime", "SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime", "SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime");
	}

	private static void ValidateColossusHotfixUpstreamIdentity()
	{
		if (!string.Equals(FindLoadedType("EM.Lua.FilesCache").Module.ModuleVersionId.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Trebuchet.dll MVID drifted.");
		}
		CanonicalAssemblyContract.RequireCanonicalTypes("SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime", "SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime");
	}

	private static void ValidateSameAssembly(Type runtimeType, Assembly expectedAssembly, string description)
	{
		if ((object)runtimeType.Assembly != expectedAssembly)
		{
			throw new InvalidOperationException(description + " is not linked into the consolidated patcher.");
		}
	}

	private static void ValidateAssembly(Assembly assembly, string expectedMvid, long expectedBytes, string expectedSha256, string description)
	{
		string text = assembly.ManifestModule.ModuleVersionId.ToString("D");
		if (!string.Equals(text, expectedMvid, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException(description + " MVID drifted: " + text + ".");
		}
		string location = assembly.Location;
		if (string.IsNullOrWhiteSpace(location) || !File.Exists(location))
		{
			throw new InvalidOperationException(description + " has no verifiable file location.");
		}
		if (new FileInfo(location).Length != expectedBytes)
		{
			throw new InvalidOperationException(description + " size drifted.");
		}
		using FileStream inputStream = File.OpenRead(location);
		using SHA256 sHA = SHA256.Create();
		if (!string.Equals(BitConverter.ToString(sHA.ComputeHash(inputStream)).Replace("-", ""), expectedSha256, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException(description + " SHA-256 drifted.");
		}
	}

	private static Type FindLoadedType(string fullName)
	{
		Type[] array = (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType(fullName, throwOnError: false) into type
			where type != null
			select type).Cast<Type>().ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException("Expected one loaded " + fullName + " type, found " + array.Length + ".");
		}
		return array[0];
	}

	private static object GetLuaFileCache()
	{
		Type type = FindLoadedType("EM.Lua.FilesCache");
		object result = (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
		ClearLuaCacheLookupIndex();
		return result;
	}

	private static void RebuildLuaDirectoryIndex()
	{
		Type type = FindLoadedType("EM.Lua.FilesCache");
		(type.GetMethod("RebuildDirectoryIndex", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, "RebuildDirectoryIndex")).Invoke(null, null);
	}

	private static CachedResource GetCachedResource(object cache, string relativePath)
	{
		return TryGetCachedResource(cache, relativePath) ?? throw new FileNotFoundException("Required cached Lua source is unavailable.", relativePath);
	}

	private static CachedResource? TryGetCachedResource(object cache, string relativePath)
	{
		int num = (int)(cache.GetType().GetProperty("Count", BindingFlags.Instance | BindingFlags.Public)?.GetValue(cache, null) ?? throw new MissingMemberException(cache.GetType().FullName, "Count"));
		if (luaCacheLookupCache != cache || luaCachePathsBySuffix == null || luaCacheLookupCount != num)
		{
			luaCachePathsBySuffix = BuildLuaCacheLookupIndex(cache);
			luaCacheLookupCache = cache;
			luaCacheLookupCount = num;
		}
		string key = relativePath.Replace('\\', '/');
		for (int i = 0; i < 2; i++)
		{
			if (!luaCachePathsBySuffix.TryGetValue(key, out List<string> value))
			{
				return null;
			}
			CachedResource cachedResource = null;
			bool flag = false;
			foreach (string item in value)
			{
				if (cachedResource != null)
				{
					throw new InvalidOperationException("Multiple Lua cache resources match " + relativePath + ".");
				}
				object value2;
				try
				{
					value2 = (cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { item });
				}
				catch (TargetInvocationException ex) when (i == 0 && ex.InnerException is KeyNotFoundException)
				{
					luaCachePathsBySuffix = BuildLuaCacheLookupIndex(cache);
					flag = true;
					break;
				}
				if (value2 == null)
				{
					throw new InvalidOperationException("Cached " + relativePath + " has no value.");
				}
				EnsureCreated(value2, relativePath);
				cachedResource = new CachedResource(item, value2);
			}
			if (!flag)
			{
				return cachedResource;
			}
		}
		throw new InvalidOperationException("Lua cache lookup retry did not complete.");
	}

	private static string ReadText(object resource)
	{
		EnsureCreated(resource, "Lua cache resource");
		byte[] bytes = ((resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null) as byte[]) ?? throw new InvalidOperationException("NativeArray.ToArray returned null.");
		return Encoding.UTF8.GetString(bytes);
	}

	private static object CreateNativeArray(Type type, string source)
	{
		if (!type.IsGenericType || type.GetGenericArguments().Length != 1 || type.GetGenericArguments()[0] != typeof(byte))
		{
			throw new ArgumentException("Expected Unity NativeArray<byte>.", "type");
		}
		Type type2 = type.Assembly.GetType("Unity.Collections.Allocator", throwOnError: false) ?? (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType("Unity.Collections.Allocator", throwOnError: false)).FirstOrDefault((Type candidate) => candidate != null) ?? throw new TypeLoadException("Unity.Collections.Allocator is unavailable.");
		return (type.GetConstructor(BindingFlags.Instance | BindingFlags.Public, null, new Type[2]
		{
			typeof(byte[]),
			type2
		}, null) ?? throw new MissingMethodException(type.FullName, ".ctor(Byte[], Allocator)")).Invoke(new object[2]
		{
			Encoding.UTF8.GetBytes(source),
			Enum.Parse(type2, "Persistent")
		});
	}

	private static void EnsureCreated(object resource, string description)
	{
		object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource, null);
		if (!(value is bool) || !(bool)value)
		{
			throw new InvalidOperationException("Cached " + description + " is not initialized.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static bool ContainsExactCachedPath(object cache, string path)
	{
		foreach (object item in (IEnumerable)cache)
		{
			if (string.Equals(item.GetType().GetProperty("Key")?.GetValue(item, null) as string, path, StringComparison.OrdinalIgnoreCase))
			{
				return true;
			}
		}
		return false;
	}

	private static void RemoveCachedResource(object cache, string path)
	{
		object obj = (cache.GetType().GetMethod("Remove", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "Remove(string)")).Invoke(cache, new object[1] { path });
		if (obj is bool && !(bool)obj && ContainsExactCachedPath(cache, path))
		{
			throw new InvalidOperationException("Cache refused to remove " + path + ".");
		}
	}

	private static object GetExactCachedResource(object cache, string path)
	{
		return (cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("Cache returned null for " + path + ".");
	}

	private static void TryDispose(object resource, string description)
	{
		try
		{
			Type type = resource.GetType();
			object obj = type.GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public)?.GetValue(resource, null);
			if (obj is bool && (bool)obj)
			{
				(type.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, "Dispose")).Invoke(resource, null);
			}
		}
		catch (Exception ex)
		{
			Log("NativeArray cleanup warning for " + description + ": " + ex.GetBaseException().Message);
		}
	}

	private static string LoadEmbeddedText(string name)
	{
		string text = CacheCompatibilityRepair.ReadMockHydroResource(name);
		if (text != null)
		{
			return text;
		}
		return CacheCompatibilityRepair.ReadOriginalFieldResource(name);
	}

	private static string Append(string source, string appendix)
	{
		source = Normalize(source);
		appendix = Normalize(appendix);
		if (!source.EndsWith("\n", StringComparison.Ordinal))
		{
			return source + "\n" + appendix.TrimStart(new char[1] { '\n' });
		}
		return source + appendix.TrimStart(new char[1] { '\n' });
	}

	private static string Normalize(string source)
	{
		return source.Replace("\r\n", "\n").Replace('\r', '\n');
	}

	private static void RequireTextSha256(string source, string expectedSha256, string description)
	{
		using SHA256 sHA = SHA256.Create();
		if (!string.Equals(BitConverter.ToString(sHA.ComputeHash(Encoding.UTF8.GetBytes(source))).Replace("-", ""), expectedSha256, StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException(description + " SHA-256 drifted.");
		}
	}

	private static string Lua(double value)
	{
		return StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture);
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

	private static string PatchWaterSplashImpact(string source)
	{
		string text = LoadEmbeddedText("ScomFieldFixes.Roster.source_water_splash_pose.lua").Replace("\r\n", "\n").TrimEnd(Array.Empty<char>()) + "\n\n";
		source = source.Replace("\r\n", "\n");
		if (source.StartsWith(text, StringComparison.Ordinal))
		{
			RequireExactly(source, "function ClientProjectile:CreateImpactEffects(position, orientation, hitGlobalId)\n    if not self:IsIntelVisionVisible() then\n        return\n    end\n\n    local shield = Shields[hitGlobalId.index]\n\n    if shield then\n        shield:PlayImpactEffect(position, self.impactSizeIndex)\n    elseif SCO_PlayProjectileWaterSplash(position, hitGlobalId) then\n        -- Water visuals are handled; keep the native audio path below.\n    else\n        local visuals = self.tp.visuals\n        local data = visuals and visuals.onImpactEffects\n\n        if visuals and visuals.onWaterImpactEffects and _G.WaterGlobalPrefabID\n            and Engine.IsValidGlobalID(hitGlobalId) then\n\n            local errorCode, hitPrefabID = Engine.GetGlobalEntityPrefabID(hitGlobalId)\n\n            if errorCode == EngineErrorCode.Success and hitPrefabID.Value == _G.WaterGlobalPrefabID.Value then\n                data = visuals.onWaterImpactEffects\n            end\n        end\n\n        if data then\n            local effectData = table.random(data)\n            local effects = table.random(effectData.effects)\n            local particlePrefabID = effects.particlePrefabID\n            if particlePrefabID then\n                local instantiatedID = {}\n                local effectPosition, effectOrientation = SCO_WaterSplashPose(effects.particleName, position, orientation)\n                Engine.InstantiatePrefab(particlePrefabID, effectPosition, { x = 1.0, y = 1.0, z = 1.0 }, effectOrientation, instantiatedID)\n            end\n        end\n    end\n\n    AudioManager.NotifyCombatActivity()\n\n    if not (shield and shield:PlayImpactAudio(position, orientation)) then\n        local impactAudio = self.tp.audio and self.tp.audio.onImpact\n\n        if impactAudio and impactAudio.prefabID then\n            AudioManager.PlayOneShot(impactAudio.prefabID, position, orientation)\n        end\n    end\nend", 1, "waterline splash placement");
			RequireExactly(source, "function ClientProjectile:CreateImpactEffects(position, orientation, hitGlobalId)\n    if not self:IsIntelVisionVisible() then\n        return\n    end\n\n    local shield = Shields[hitGlobalId.index]\n\n    if shield then\n        shield:PlayImpactEffect(position, self.impactSizeIndex)\n    else\n        local visuals = self.tp.visuals\n        local data = visuals and visuals.onImpactEffects\n\n        if visuals and visuals.onWaterImpactEffects and _G.WaterGlobalPrefabID\n            and Engine.IsValidGlobalID(hitGlobalId) then\n\n            local errorCode, hitPrefabID = Engine.GetGlobalEntityPrefabID(hitGlobalId)\n\n            if errorCode == EngineErrorCode.Success and hitPrefabID.Value == _G.WaterGlobalPrefabID.Value then\n                data = visuals.onWaterImpactEffects\n            end\n        end\n\n        if data then\n            local effectData = table.random(data)\n            local effects = table.random(effectData.effects)\n            local particlePrefabID = effects.particlePrefabID\n            if particlePrefabID then\n                local instantiatedID = {}\n                Engine.InstantiatePrefab(particlePrefabID, position, { x = 1.0, y = 1.0, z = 1.0 }, orientation, instantiatedID)\n            end\n        end\n    end\n\n    AudioManager.NotifyCombatActivity()\n\n    if not (shield and shield:PlayImpactAudio(position, orientation)) then\n        local impactAudio = self.tp.audio and self.tp.audio.onImpact\n\n        if impactAudio and impactAudio.prefabID then\n            AudioManager.PlayOneShot(impactAudio.prefabID, position, orientation)\n        end\n    end\nend", 0, "unrouted projectile impact placement");
			return source;
		}
		RequireExactly(source, "function ClientProjectile:CreateImpactEffects(position, orientation, hitGlobalId)\n    if not self:IsIntelVisionVisible() then\n        return\n    end\n\n    local shield = Shields[hitGlobalId.index]\n\n    if shield then\n        shield:PlayImpactEffect(position, self.impactSizeIndex)\n    else\n        local visuals = self.tp.visuals\n        local data = visuals and visuals.onImpactEffects\n\n        if visuals and visuals.onWaterImpactEffects and _G.WaterGlobalPrefabID\n            and Engine.IsValidGlobalID(hitGlobalId) then\n\n            local errorCode, hitPrefabID = Engine.GetGlobalEntityPrefabID(hitGlobalId)\n\n            if errorCode == EngineErrorCode.Success and hitPrefabID.Value == _G.WaterGlobalPrefabID.Value then\n                data = visuals.onWaterImpactEffects\n            end\n        end\n\n        if data then\n            local effectData = table.random(data)\n            local effects = table.random(effectData.effects)\n            local particlePrefabID = effects.particlePrefabID\n            if particlePrefabID then\n                local instantiatedID = {}\n                Engine.InstantiatePrefab(particlePrefabID, position, { x = 1.0, y = 1.0, z = 1.0 }, orientation, instantiatedID)\n            end\n        end\n    end\n\n    AudioManager.NotifyCombatActivity()\n\n    if not (shield and shield:PlayImpactAudio(position, orientation)) then\n        local impactAudio = self.tp.audio and self.tp.audio.onImpact\n\n        if impactAudio and impactAudio.prefabID then\n            AudioManager.PlayOneShot(impactAudio.prefabID, position, orientation)\n        end\n    end\nend", 1, "native projectile impact placement");
		return text + source.Replace("function ClientProjectile:CreateImpactEffects(position, orientation, hitGlobalId)\n    if not self:IsIntelVisionVisible() then\n        return\n    end\n\n    local shield = Shields[hitGlobalId.index]\n\n    if shield then\n        shield:PlayImpactEffect(position, self.impactSizeIndex)\n    else\n        local visuals = self.tp.visuals\n        local data = visuals and visuals.onImpactEffects\n\n        if visuals and visuals.onWaterImpactEffects and _G.WaterGlobalPrefabID\n            and Engine.IsValidGlobalID(hitGlobalId) then\n\n            local errorCode, hitPrefabID = Engine.GetGlobalEntityPrefabID(hitGlobalId)\n\n            if errorCode == EngineErrorCode.Success and hitPrefabID.Value == _G.WaterGlobalPrefabID.Value then\n                data = visuals.onWaterImpactEffects\n            end\n        end\n\n        if data then\n            local effectData = table.random(data)\n            local effects = table.random(effectData.effects)\n            local particlePrefabID = effects.particlePrefabID\n            if particlePrefabID then\n                local instantiatedID = {}\n                Engine.InstantiatePrefab(particlePrefabID, position, { x = 1.0, y = 1.0, z = 1.0 }, orientation, instantiatedID)\n            end\n        end\n    end\n\n    AudioManager.NotifyCombatActivity()\n\n    if not (shield and shield:PlayImpactAudio(position, orientation)) then\n        local impactAudio = self.tp.audio and self.tp.audio.onImpact\n\n        if impactAudio and impactAudio.prefabID then\n            AudioManager.PlayOneShot(impactAudio.prefabID, position, orientation)\n        end\n    end\nend", "function ClientProjectile:CreateImpactEffects(position, orientation, hitGlobalId)\n    if not self:IsIntelVisionVisible() then\n        return\n    end\n\n    local shield = Shields[hitGlobalId.index]\n\n    if shield then\n        shield:PlayImpactEffect(position, self.impactSizeIndex)\n    elseif SCO_PlayProjectileWaterSplash(position, hitGlobalId) then\n        -- Water visuals are handled; keep the native audio path below.\n    else\n        local visuals = self.tp.visuals\n        local data = visuals and visuals.onImpactEffects\n\n        if visuals and visuals.onWaterImpactEffects and _G.WaterGlobalPrefabID\n            and Engine.IsValidGlobalID(hitGlobalId) then\n\n            local errorCode, hitPrefabID = Engine.GetGlobalEntityPrefabID(hitGlobalId)\n\n            if errorCode == EngineErrorCode.Success and hitPrefabID.Value == _G.WaterGlobalPrefabID.Value then\n                data = visuals.onWaterImpactEffects\n            end\n        end\n\n        if data then\n            local effectData = table.random(data)\n            local effects = table.random(effectData.effects)\n            local particlePrefabID = effects.particlePrefabID\n            if particlePrefabID then\n                local instantiatedID = {}\n                local effectPosition, effectOrientation = SCO_WaterSplashPose(effects.particleName, position, orientation)\n                Engine.InstantiatePrefab(particlePrefabID, effectPosition, { x = 1.0, y = 1.0, z = 1.0 }, effectOrientation, instantiatedID)\n            end\n        end\n    end\n\n    AudioManager.NotifyCombatActivity()\n\n    if not (shield and shield:PlayImpactAudio(position, orientation)) then\n        local impactAudio = self.tp.audio and self.tp.audio.onImpact\n\n        if impactAudio and impactAudio.prefabID then\n            AudioManager.PlayOneShot(impactAudio.prefabID, position, orientation)\n        end\n    end\nend");
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = Count(source, token);
		if (num != expected)
		{
			throw new InvalidOperationException("Expected " + expected + " " + description + ", found " + num + ".");
		}
	}

	private static void Log(string message)
	{
		string text = "[SCOM Field Fixes] " + message;
		try
		{
			Console.WriteLine(text);
		}
		catch
		{
		}
		try
		{
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}

	private static string PatchPlacementGhostColor(string source, string anchor, string appendix)
	{
		string token = appendix.Split(new char[1] { '\n' })[0];
		switch (Count(source, token))
		{
		case 1:
			RequireExactly(source, anchor, 1, "placement ghost team-color anchor");
			RequireExactly(source, anchor + "\n" + appendix, 1, "placement ghost team-color sequence");
			return source;
		case 0:
			RequireExactly(source, anchor, 1, "placement ghost team-color anchor");
			return source.Replace(anchor, anchor + "\n" + appendix);
		default:
			throw new InvalidOperationException("Placement ghost team-color marker is duplicated.");
		}
	}

	private static string UpgradeYthothaHostDeathAppendix(string source)
	{
		string text = LoadEmbeddedText("ScomFieldFixes.Roster.source_special_units_host.lua").Trim();
		RequireExactly(text, "    Event(self,\"deathPulse\")\n", 1, "Ythotha death pulse host event");
		RequireExactly(text, "    -- Air movement's zero altitude-change rate snaps straight to altitude 75.\n    -- The native takeoff curve starts at the launcher lift's final position.\n    self:TakeoffBehaviourStart()\n", 1, "Novax gradual satellite release");
		RequireExactly(text, "    if not Alive(self) or not Alive(child) then return end\n    local result,point=Engine.GetGlobalEntityWorldPosition(bone)\n    if result==EngineErrorCode.Success then\n        child:SetPosition(point)\n        child:SetOrientation(self:GetOrientation())\n    end\n", 1, "Novax final launcher lift sample");
		string token = text.Split(new char[1] { '\n' })[0];
		if (Count(source, token) == 0 || Count(source, text) == 1)
		{
			return source;
		}
		string text2 = text.Replace("    -- Air movement's zero altitude-change rate snaps straight to altitude 75.\n    -- The native takeoff curve starts at the launcher lift's final position.\n    self:TakeoffBehaviourStart()\n", "    self.isAirborne=true\n    if self.ApplyAirborneLayers then self:ApplyAirborneLayers() end\n    Engine.SetMovementEnabled(self.id,true)\n").Replace("    if not Alive(self) or not Alive(child) then return end\n    local result,point=Engine.GetGlobalEntityWorldPosition(bone)\n    if result==EngineErrorCode.Success then\n        child:SetPosition(point)\n        child:SetOrientation(self:GetOrientation())\n    end\n", "");
		if (Count(source, text2) == 1)
		{
			return source.Replace(text2, text);
		}
		string text3 = text2.Replace("    Event(self,\"deathPulse\")\n", "");
		RequireExactly(source, text3, 1, "previous special-unit host appendix migration");
		return source.Replace(text3, text);
	}

	private static Dictionary<string, List<string>> BuildLuaCacheLookupIndex(object cache)
	{
		Dictionary<string, List<string>> dictionary = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase);
		foreach (object item in (IEnumerable)cache)
		{
			if (!(item.GetType().GetProperty("Key")?.GetValue(item, null) is string text))
			{
				continue;
			}
			string text2 = text.Replace('\\', '/');
			for (int num = text2.IndexOf('/'); num >= 0; num = text2.IndexOf('/', num + 1))
			{
				string key = text2.Substring(num + 1);
				if (!dictionary.TryGetValue(key, out var value))
				{
					value = new List<string>();
					dictionary.Add(key, value);
				}
				value.Add(text);
			}
		}
		return dictionary;
	}

	private static void ClearLuaCacheLookupIndex()
	{
		luaCacheLookupCache = null;
		luaCacheLookupCount = 0;
		luaCachePathsBySuffix = null;
	}
}
