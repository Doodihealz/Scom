using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace SanctuaryConstructionPlansCachePatcher;

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

		public object? Stock { get; }

		public object Replacement { get; }

		public bool Added { get; }

		public string Description { get; }

		public bool Assigned { get; set; }

		public CacheMutation(string path, object? stock, object replacement, bool added, string description)
		{
			Path = path;
			Stock = stock;
			Replacement = replacement;
			Added = added;
			Description = description;
		}
	}

	internal const string OverrideMarker = "-- Sanctuary Construction Plans 2.1.0";

	internal const string ConstructionPanelPath = "LJ/lua/client/ui/constructionPanel.lua";

	internal const string InputEventsPath = "LJ/lua/client/inputEventsFunctions.lua";

	internal const string ClientMainPath = "LJ/lua/client/clientMain.lua";

	internal const string InputActionsPath = "LJ/lua/client/input/inputActions.lua";

	internal const string ConstructionPreviewPath = "LJ/lua/client/input/constructionPreviewSystem.lua";

	internal const string BlueprintsModulePath = "LJ/lua/client/ui/scoBlueprints.lua";

	internal const string PlacementModulePath = "LJ/lua/client/input/scoBlueprintPlacement.lua";

	internal const string PlacementWaterParityMarker = "-- Sanctuary Construction Plans naval water placement 1.0.0";

	private static readonly string ConstructionPanelAppendix = BuildConstructionPanelAppendix();

	private static readonly string InputEventsAppendix = BuildInputEventsAppendix();

	private static readonly string ClientMainAppendix = BuildClientMainAppendix();

	private static readonly string InputActionsAppendix = BuildInputActionsAppendix();

	private static readonly string ConstructionPreviewAppendix = BuildConstructionPreviewAppendix();

	private static readonly string BlueprintsModuleSource = BuildBlueprintsModuleSource();

	private static readonly string PlacementModuleSource = UpgradePlacementModuleWaterParity(BuildPlacementModuleSource());

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			QueueAppend(obj, list, "LJ/lua/client/ui/constructionPanel.lua", "construction-plan panel integration", ConstructionPanelAppendix, delegate(string source)
			{
				RequireTokens(source, "function ConstructionPanel:UpdateConstructionPanel", "self.constructionFilteringButtons:ClearButtons()", "function ConstructionClickFunction", "function TriggerConstructionHotkey");
			}, delegate(string source)
			{
				RequireTokens(source, "SCO_StockUpdateConstructionPanel", "SCO_StockConstructionClickFunction", "SCO_Blueprints.AddBlueprintFilter", "SCO_Blueprints.CloseBlueprintPanel()", "self.constructionFilteringButtons:ClearButtons()");
				RequireNotContains(source, "SCO_Blueprints.ShowStandaloneDeck", "SCO_Blueprints.ShowBlueprintTab(self, units)");
			}, "\nreturn {\n    TriggerConstructionHotkey = TriggerConstructionHotkey,\n    IsConstructionPanelEnabled = IsConstructionPanelEnabled,\n}");
			QueueAppend(obj, list, "LJ/lua/client/inputEventsFunctions.lua", "construction-plan mouse routing", InputEventsAppendix, delegate(string source)
			{
				RequireTokens(source, "function OnMouseLeftDown()", "function OnMouseLeftUp()", "function OnMouseRightDown()", "function OnMouseRightUp()", "local isAppendingToQueue = false");
			}, delegate(string source)
			{
				RequireTokens(source, "SCO_StockOnMouseLeftDown", "SCO_BlueprintPlacement.OnMouseLeftUp(isAppendingToQueue)", "SCO_BlueprintPlacement.OnMouseRightUp()");
			}, "\n-- Only for annotations\nreturn {\n");
			QueueAppend(obj, list, "LJ/lua/client/clientMain.lua", "construction-plan preview update", ClientMainAppendix, delegate(string source)
			{
				RequireTokens(source, "function _G.OnRenderUpdate()", "constructionPreviewSystem.UpdateConstructionPreview()");
			}, delegate(string source)
			{
				RequireTokens(source, "scoBlueprintPlacement", "scoBlueprintPlacement.UpdatePreview()");
			});
			QueueAppend(obj, list, "LJ/lua/client/input/inputActions.lua", "construction-plan hotkeys and mouse consumption", InputActionsAppendix, delegate(string source)
			{
				RequireTokens(source, "InputActions.Construction = {", "Priority = 10");
			}, delegate(string source)
			{
				RequireTokens(source, "InputActions.ConstructionPlans", "Capture Construction Plan", "Shift-T", "Alt-Digit1", "Alt-Digit8", "Import(\"client/inputEventsFunctions.lua\").OnMouseLeftDown()", "return false");
			});
			QueueAppend(obj, list, "LJ/lua/client/input/constructionPreviewSystem.lua", "construction-preview invalid-template guard", ConstructionPreviewAppendix, delegate(string source)
			{
				RequireTokens(source, "function UpdateConstructionPreview()", "buildmodeTemp.GetBuildMode()", "buildmodeTemp.GetBuildTpId()", "unitTemplate.skirtSize");
			}, delegate(string source)
			{
				RequireTokens(source, "SCO_StockUpdateConstructionPreview", "SCO_InvalidBuildTemplateWarningShown", "not unitTemplate or not unitTemplate.skirtSize");
			}, "\n--Only for annotataions\nreturn {\n    UpdateConstructionPreview = UpdateConstructionPreview\n}");
			QueueVirtualModule(obj, list, "LJ/lua/client/ui/scoBlueprints.lua", "persistent construction-plan deck module", BlueprintsModuleSource, ValidateBlueprintsModule);
			QueueVirtualModule(obj, list, "LJ/lua/client/input/scoBlueprintPlacement.lua", "construction-plan placement module", PlacementModuleSource, ValidatePlacementModule, "-- Sanctuary Construction Plans naval water placement 1.0.0");
			if (list.Count == 0)
			{
				Log("Construction Plans are already active.");
				return;
			}
			Commit(obj, list);
			Log("Installed persistent Construction Plans, compact BP controls, direct slot hotkeys, and the host-validated multi-structure placement route.");
		}
		catch (Exception arg)
		{
			if (obj != null)
			{
				RollBack(obj, list);
			}
			else
			{
				DisposeUncommitted(list);
			}
			Log($"Failed to apply Construction Plans: {arg}");
			throw;
		}
	}

	private static void QueueAppend(object cache, List<CacheMutation> mutations, string relativePath, string description, string appendix, Action<string> validateStock, Action<string> validatePatched, string? insertionAnchor = null)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string text = NormalizeLineEndings(GetResourceText(cachedResource.Stock));
		if (ContainsMarker(text))
		{
			validatePatched(text);
			RequireExactly(text, "-- Sanctuary Construction Plans 2.1.0", 1, description + " marker");
			return;
		}
		validateStock(text);
		string source = ((insertionAnchor == null) ? AppendOverride(text, appendix) : InsertBeforeExactlyOnce(text, insertionAnchor, appendix, description));
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), source);
		try
		{
			string resourceText = GetResourceText(obj);
			validatePatched(resourceText);
			RequireExactly(resourceText, "-- Sanctuary Construction Plans 2.1.0", 1, description + " marker");
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + description + " replacement");
			throw;
		}
	}

	private static void QueueVirtualModule(object cache, List<CacheMutation> mutations, string relativePath, string description, string source, Action<string> validate, string? upgradeMarker = null)
	{
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, description);
		if (cacheResource != null)
		{
			string text = NormalizeLineEndings(GetResourceText(cacheResource.Stock));
			if (!ContainsMarker(text))
			{
				throw new InvalidOperationException("The reserved " + description + " path already exists without the Construction Plans marker: " + relativePath);
			}
			if (upgradeMarker != null && text.IndexOf(upgradeMarker, StringComparison.Ordinal) < 0)
			{
				validate(source);
				object obj = CreateNativeArrayFromText(cacheResource.Stock.GetType(), source);
				try
				{
					validate(GetResourceText(obj));
					mutations.Add(new CacheMutation(cacheResource.Path, cacheResource.Stock, obj, added: false, description));
					return;
				}
				catch
				{
					TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + description + " upgrade");
					throw;
				}
			}
			validate(text);
			return;
		}
		validate(source);
		object obj3 = CreateNativeArrayFromText(GetNativeArrayType(cache), source);
		try
		{
			validate(GetResourceText(obj3));
			mutations.Add(new CacheMutation(ResolvePath(relativePath), null, obj3, added: true, description));
		}
		catch
		{
			TryDisposeNativeArray(obj3.GetType(), obj3, "uncommitted " + description + " replacement");
			throw;
		}
	}

	private static void ValidateBlueprintsModule(string source)
	{
		RequireExactly(source, "-- Sanctuary Construction Plans 2.1.0", 1, "Construction Plans deck marker");
		RequireTokens(source, "local MAX_SLOTS = 8", "local DEFAULT_SLOT = 1", "local nextPlanRevision = 1", "local MAX_ENTRIES = 20", "local SCHEMA_VERSION = 2", "local LEGACY_SCHEMA_VERSION = 1", "local MAX_OFFSET = 8192", "local function IsFiniteCoordinate(value, maximumMagnitude)", "local function HasIdentityBuildOrientation(unit)", "local plansLoadState = \"unloaded\"", "plansLoadState = \"failed\"", "local function RequireWritablePlans()", "SCO_LoadConstructionPlansJson", "SCO_SaveConstructionPlansJson", "pcall(json.encode, envelope)", "pcall(json.decode, document)", "local function PersistCandidate(candidate)", "local function DecodePersistedPlans(document)", "if envelope.schemaVersion == LEGACY_SCHEMA_VERSION then", "return nil, \"legacy\"", "if not PersistCandidate(candidate) then", "function ActivatePlanSlot(slot, selectedUnits)", "function CanCaptureSelection(units)", "function CaptureDefaultPlan(units)", "function CloseBlueprintPanel()", "function IsBlueprintUIActive()", "function DuplicatePlan(slot, revision)", "function DeletePlan(slot, revision)", "function AddBlueprintFilter(panel, units, canCapture)", "ShowPlanActions", "ShowDeleteConfirmation", "ShowOverwriteConfirmation", "revision = TakeNextRevision()", "local position = unit:GetSimPosition()", "local originX = math.floor(minX)", "local originZ = math.floor(minZ)", "ButtonData(plan and (\"P\" .. slot) or (\"+P\" .. slot)", "scoBlueprintPlacement.lua");
		RequireNotContains(source, "io.open", "loadfile", "os.execute", "RefreshUI", "unit:GetPosition()", "math.truncateToInt(position.x)", "math.truncateToInt(position.z)", "session-local", "legacy plans were not loaded because exact placement cannot be verified; recapture them.", "Saved P", "Ctrl-Digit");
	}

	private static void ValidatePlacementModule(string source)
	{
		RequireTokens(source, "Import(\"common/commands/definitions/buildQueue.lua\")", ".RequestQueueAmountForUnits(");
		RequireNotContains(source, "common/systems/commands.lua", ".SendUpdateQueueAmountCommand(");
		RequireExactly(source, "-- Sanctuary Construction Plans 2.1.0", 1, "Construction Plans placement marker");
		RequireExactly(source, "-- Sanctuary Construction Plans naval water placement 1.0.0", 1, "Construction Plans naval-water marker");
		RequireTokens(source, "function Begin(plan, selectedUnits, sourceSlot, sourceRevision)", "function CanBuildEntries(entries, units)", "function CancelIfSourceSlot(slot, revision)", "CancelIfSourceSlot = CancelIfSourceSlot", "function OnMouseLeftUp(isAppendingToQueue)", "function OnMouseLeftDown()\n    return false\nend", "function OnMouseRightDown()\n    return false\nend", "function UpdatePreview()", "local function GetCompatibleBuilders(entries, units)", "local function IsFiniteCoordinate(value, maximumMagnitude)", "additions.placementReservations", "local function GetMinimumWaterDepth(template)", "faContract.minimumWaterDepth", "local function IsClearArea(area, template)", "PlacementUtils.IsCellValidForPlacement(result.flags, domain, false)", "local function CanPlaceWaterFactory(template, position)", "additions and additions.rollOffRamps", "ramp and ramp.clearanceOffset", "IsClearArea(area, template)", "local function AreasOverlap(first, second)", "#compatibleBuilders == 0", "buildQueueUtils.CanBuild", "OrderTasks.BUILD", "ClientOrderManager.ClientIssueOrder", "allValid", "MAX_ENTRIES = 20");
		RequireNotContains(source, "local function CanBuildEntries", "IsFiniteInteger(entry.dx, MAX_OFFSET)", "IsFiniteInteger(entry.dz, MAX_OFFSET)", "local function IsClearArea(area)\n", "result.flags ~= PlacementLayer.None", "waterLevel - 0.05", "HostBuildOrder", "OrderTasks.BLUEPRINT", "io.open", "loadfile", "os.execute", "SelectionSystem.GetSelectedUnits(),\n                    shouldAppend");
	}

	private static string BuildConstructionPanelAppendix()
	{
		return AppendMarker("local SCO_Blueprints = Import(\"client/ui/scoBlueprints.lua\")\nlocal SCO_StockUpdateConstructionPanel = ConstructionPanel.UpdateConstructionPanel\nlocal SCO_StockConstructionClickFunction = ConstructionClickFunction\nlocal SCO_StockConstructionFilterLeftClickFunction = ConstructionFilterLeftClickFunction\nlocal SCO_StockTriggerConstructionHotkey = TriggerConstructionHotkey\n\nfunction ConstructionPanel:UpdateConstructionPanel(units, constructionOptions, hasEngineerOptions, hasFactoryOptions)\n    local canCapture = SCO_Blueprints.CanCaptureSelection(units)\n    -- A selection refresh always returns ownership of the visible\n    -- tab to Sanctuary. BP is entered only by clicking its filter.\n    SCO_Blueprints.CloseBlueprintPanel()\n    SCO_StockUpdateConstructionPanel(self, units, constructionOptions, hasEngineerOptions, hasFactoryOptions)\n    if hasEngineerOptions ~= hasFactoryOptions or canCapture then\n        if not hasEngineerOptions and not hasFactoryOptions then\n            self.constructionFilteringButtons:ClearButtons()\n        end\n        SCO_Blueprints.AddBlueprintFilter(self, units, canCapture)\n    end\nend\n\nfunction ConstructionFilterLeftClickFunction(data, payload)\n    SCO_Blueprints.LeaveBlueprintUI()\n    return SCO_StockConstructionFilterLeftClickFunction(data, payload)\nend\n\nfunction ConstructionClickFunction(clickData, payload)\n    SCO_Blueprints.LeaveBlueprintUI()\n    return SCO_StockConstructionClickFunction(clickData, payload)\nend\n\nfunction TriggerConstructionHotkey(hotkey)\n    SCO_Blueprints.LeaveBlueprintUI()\n    return SCO_StockTriggerConstructionHotkey(hotkey)\nend");
	}

	private static string BuildInputEventsAppendix()
	{
		return AppendMarker("local SCO_BlueprintPlacement = Import(\"client/input/scoBlueprintPlacement.lua\")\nlocal SCO_StockOnMouseLeftDown = OnMouseLeftDown\nlocal SCO_StockOnMouseLeftUp = OnMouseLeftUp\nlocal SCO_StockOnMouseRightDown = OnMouseRightDown\nlocal SCO_StockOnMouseRightUp = OnMouseRightUp\n\nfunction OnMouseLeftDown()\n    if SCO_BlueprintPlacement.IsActive() then\n        return SCO_BlueprintPlacement.OnMouseLeftDown()\n    end\n    return SCO_StockOnMouseLeftDown()\nend\n\nfunction OnMouseLeftUp()\n    if SCO_BlueprintPlacement.IsActive() then\n        return SCO_BlueprintPlacement.OnMouseLeftUp(isAppendingToQueue)\n    end\n    return SCO_StockOnMouseLeftUp()\nend\n\nfunction OnMouseRightDown()\n    if SCO_BlueprintPlacement.IsActive() then\n        return SCO_BlueprintPlacement.OnMouseRightDown()\n    end\n    return SCO_StockOnMouseRightDown()\nend\n\nfunction OnMouseRightUp()\n    if SCO_BlueprintPlacement.IsActive() then\n        return SCO_BlueprintPlacement.OnMouseRightUp()\n    end\n    return SCO_StockOnMouseRightUp()\nend");
	}

	private static string BuildClientMainAppendix()
	{
		return AppendMarker("local SCO_StockOnRenderUpdate = _G.OnRenderUpdate\n\nfunction _G.OnRenderUpdate()\n    local stockSucceeded, stockError = pcall(SCO_StockOnRenderUpdate)\n    local scoBlueprintPlacement = Import(\"client/input/scoBlueprintPlacement.lua\")\n    scoBlueprintPlacement.UpdatePreview()\n    local arrival = _G.SCO_CommanderArrivalVisuals\n    if stockSucceeded and arrival then arrival.Update() end\n    if not stockSucceeded then\n        error(stockError)\n    end\nend\n-- SCO_CommanderArrivalClientReset_v1\nlocal SCOArrivalStockClientInit = Init\nfunction Init()\n    local arrival = _G.SCO_CommanderArrivalVisuals\n    if arrival then arrival.Reset() end\n    return SCOArrivalStockClientInit()\nend");
	}

	private static string BuildInputActionsAppendix()
	{
		return AppendMarker("-- Always let inputSystem update its pressed/released state. Routing\n-- exclusivity lives in inputEventsFunctions, not in event consumption.\nInputActions.MouseControls.MouseLeftClick.defaultActions.press =\n    function()\n        Import(\"client/inputEventsFunctions.lua\").OnMouseLeftDown()\n        return false\n    end\nInputActions.MouseControls.MouseLeftClick.defaultActions.release =\n    function()\n        Import(\"client/inputEventsFunctions.lua\").OnMouseLeftUp()\n        return false\n    end\nInputActions.MouseControls.MouseRightClick.defaultActions.press =\n    function()\n        Import(\"client/inputEventsFunctions.lua\").OnMouseRightDown()\n        return false\n    end\nInputActions.MouseControls.MouseRightClick.defaultActions.release =\n    function()\n        Import(\"client/inputEventsFunctions.lua\").OnMouseRightUp()\n        return false\n    end\n\nInputActions.ConstructionPlans = {\n    Priority = 11,\n    CapturePlan = {\n        defaultActions = {\n            press = function()\n                local SelectionSystem = Import(\"client/input/selectionSystem.lua\")\n                local Blueprints = Import(\"client/ui/scoBlueprints.lua\")\n                local saved = Blueprints.CaptureDefaultPlan(SelectionSystem.GetSelectedUnits())\n                if saved then\n                    Import(\"client/ui/uiManager.lua\").SetUIDirty()\n                end\n                return saved\n            end,\n        },\n        uiDescription = \"Capture Construction Plan\",\n        uiCategory = \"Construction\",\n        defaultHotkeys = { \"Shift-T\" },\n    },\n}\n\nlocal SCO_PlanHotkeys = {\n    \"Alt-Digit1\",\n    \"Alt-Digit2\",\n    \"Alt-Digit3\",\n    \"Alt-Digit4\",\n    \"Alt-Digit5\",\n    \"Alt-Digit6\",\n    \"Alt-Digit7\",\n    \"Alt-Digit8\",\n}\nlocal function SCO_CreatePlacePlanAction(planSlot)\n    return function()\n        local SelectionSystem = Import(\"client/input/selectionSystem.lua\")\n        local Blueprints = Import(\"client/ui/scoBlueprints.lua\")\n        Blueprints.ActivatePlanSlot(planSlot, SelectionSystem.GetSelectedUnits())\n        return true\n    end\nend\nfor slot, hotkey in ipairs(SCO_PlanHotkeys) do\n    InputActions.ConstructionPlans[\"PlacePlan\" .. slot] = {\n        defaultActions = {\n            press = SCO_CreatePlacePlanAction(slot),\n        },\n        uiDescription = \"Place Construction Plan \" .. slot,\n        uiCategory = \"Construction\",\n        defaultHotkeys = { hotkey },\n    }\nend");
	}

	private static string BuildConstructionPreviewAppendix()
	{
		return AppendMarker("local SCO_StockUpdateConstructionPreview = UpdateConstructionPreview\nlocal SCO_InvalidBuildTemplateWarningShown = false\n\nfunction UpdateConstructionPreview()\n    if buildmodeTemp.GetBuildMode() then\n        local tpId = buildmodeTemp.GetBuildTpId()\n        local unitTemplate = tpId and __Templates.Units[tpId] or nil\n        if not unitTemplate or not unitTemplate.skirtSize then\n            buildmodeTemp.SetBuildMode(false)\n            if not SCO_InvalidBuildTemplateWarningShown then\n                SCO_InvalidBuildTemplateWarningShown = true\n                Engine.UI_AddLogText(\n                    \"Construction: cancelled an invalid build template instead of breaking the UI.\",\n                    5)\n            end\n            return\n        end\n    end\n\n    return SCO_StockUpdateConstructionPreview()\nend");
	}

	private static string BuildBlueprintsModuleSource()
	{
		return "-- Sanctuary Construction Plans 2.1.0\n-- Persistent, client-owned construction layouts. Placement still\n-- emits only Sanctuary's stock host-authoritative BUILD orders.\nlocal MAX_SLOTS = 8\nlocal DEFAULT_SLOT = 1\nlocal MAX_ENTRIES = 20\nlocal MAX_OFFSET = 8192\nlocal SCHEMA_VERSION = 2\nlocal LEGACY_SCHEMA_VERSION = 1\nlocal PlacementUtils = Import(\"common/systems/placementUtils.lua\")\nlocal TempBuildMode = Import(\"client/input/buildmodeTemp.lua\")\nlocal slots = {}\nlocal plansLoadState = \"unloaded\"\nlocal nextPlanRevision = 1\nlocal blueprintPanelActive = false\nlocal ShowBrowser\nlocal ShowPlanActions\nlocal ShowDeleteConfirmation\nlocal ShowOverwriteConfirmation\nlocal EnsurePlansLoaded\n\nlocal function Notify(text)\n    Engine.UI_AddLogText(\"Construction Plans: \" .. text, 5)\nend\n\nlocal function IsFiniteInteger(value, maximumMagnitude)\n    return type(value) == \"number\"\n        and value == value\n        and math.abs(value) <= maximumMagnitude\n        and value == math.floor(value)\nend\n\nlocal function IsFiniteCoordinate(value, maximumMagnitude)\n    return type(value) == \"number\"\n        and value == value\n        and math.abs(value) <= maximumMagnitude\nend\n\nlocal function IsDenseArray(value, maximumLength)\n    if type(value) ~= \"table\" or #value > maximumLength then\n        return false\n    end\n\n    local count = 0\n    for key in pairs(value) do\n        if type(key) ~= \"number\"\n            or key ~= math.floor(key)\n            or key < 1\n            or key > #value then\n            return false\n        end\n        count = count + 1\n    end\n    return count == #value\nend\n\nlocal function IsSlot(slot)\n    return IsFiniteInteger(slot, MAX_SLOTS)\n        and slot >= 1\n        and slot <= MAX_SLOTS\nend\n\nlocal function GetTemplateId(unit)\n    if not unit or not unit.tp or not unit.tp.general then\n        return nil\n    end\n    return unit.tp.general.tpId\nend\n\nlocal function IsEligibleTemplateId(tpId)\n    if type(tpId) ~= \"string\"\n        or #tpId == 0\n        or #tpId > 64\n        or not string.match(tpId, \"^[%w_%-]+$\") then\n        return false\n    end\n\n    local template = __Templates.Units[tpId]\n    local skirt = template and template.skirtSize\n    return template\n        and template.general\n        and skirt\n        and IsFiniteInteger(skirt.x, 128)\n        and IsFiniteInteger(skirt.y, 128)\n        and skirt.x > 0\n        and skirt.y > 0\n        and Tags.STRUCTURE[tpId]\n        and not Tags.ALLOYS_EXTRACTION[tpId]\nend\n\nlocal function IsCaptureCandidate(unit)\n    local tpId = GetTemplateId(unit)\n    return unit\n        and unit.entityType == \"unit\"\n        and IsEligibleTemplateId(tpId)\n        and unit.armyId == GetFocusArmy()\n        and unit.IsCompleted\n        and unit:IsCompleted()\nend\n\nlocal function HasIdentityBuildOrientation(unit)\n    if not unit or type(unit.GetSimOrientation) ~= \"function\" then\n        return false\n    end\n    local orientation = unit:GetSimOrientation()\n    local value = orientation and orientation.value\n    if type(value) ~= \"table\"\n        or not IsFiniteCoordinate(value.x, 2)\n        or not IsFiniteCoordinate(value.y, 2)\n        or not IsFiniteCoordinate(value.z, 2)\n        or not IsFiniteCoordinate(value.w, 2) then\n        return false\n    end\n\n    -- Sanctuary's BUILD payload has no rotation field and the\n    -- host creates structures at identity. Refuse rotated source\n    -- structures instead of silently producing a different copy.\n    local vectorSquared = value.x * value.x\n        + value.y * value.y\n        + value.z * value.z\n    return vectorSquared <= 0.00000001\n        and math.abs(math.abs(value.w) - 1) <= 0.0001\nend\n\nlocal function AddArea(areas, position, size)\n    if type(size) ~= \"table\"\n        or not IsFiniteInteger(size.x, 128)\n        or not IsFiniteInteger(size.y, 128)\n        or size.x <= 0\n        or size.y <= 0 then\n        return false\n    end\n\n    local minX, minZ, maxX, maxZ =\n        PlacementUtils.GetPlacementBounds(position, size)\n    table.insert(areas, {\n        minX = minX,\n        minZ = minZ,\n        maxX = maxX,\n        maxZ = maxZ,\n    })\n    return true\nend\n\nlocal function GetEntryAreas(entry)\n    if type(entry) ~= \"table\"\n        or not IsEligibleTemplateId(entry.tpId)\n        or not IsFiniteCoordinate(entry.dx, MAX_OFFSET)\n        or not IsFiniteCoordinate(entry.dz, MAX_OFFSET) then\n        return nil\n    end\n\n    local template = __Templates.Units[entry.tpId]\n    local areas = {}\n    local position = { x = entry.dx, z = entry.dz }\n    if not AddArea(areas, position, template.skirtSize) then\n        return nil\n    end\n\n    local additions = template.additions\n    local reservations = additions and additions.placementReservations or {}\n    if not IsDenseArray(reservations, 16) then\n        return nil\n    end\n    for _, reservation in ipairs(reservations) do\n        if type(reservation) ~= \"table\" then\n            return nil\n        end\n        local offset = reservation.offset or {}\n        if type(offset) ~= \"table\"\n            or not IsFiniteInteger(offset.x or 0, 128)\n            or not IsFiniteInteger(offset.z or 0, 128)\n            or not AddArea(\n                areas,\n                {\n                    x = entry.dx + (offset.x or 0),\n                    z = entry.dz + (offset.z or 0),\n                },\n                reservation.size) then\n            return nil\n        end\n    end\n    return areas\nend\n\nlocal function AreasOverlap(first, second)\n    return first.minX <= second.maxX\n        and second.minX <= first.maxX\n        and first.minZ <= second.maxZ\n        and second.minZ <= first.maxZ\nend\n\nlocal function ValidateEntries(entries)\n    if not IsDenseArray(entries, MAX_ENTRIES)\n        or #entries == 0 then\n        return false\n    end\n\n    local areasByEntry = {}\n    for index, entry in ipairs(entries) do\n        local areas = GetEntryAreas(entry)\n        if not areas then\n            return false\n        end\n        areasByEntry[index] = areas\n    end\n\n    for firstIndex = 1, #areasByEntry do\n        for secondIndex = firstIndex + 1, #areasByEntry do\n            for _, firstArea in ipairs(areasByEntry[firstIndex]) do\n                for _, secondArea in ipairs(areasByEntry[secondIndex]) do\n                    if AreasOverlap(firstArea, secondArea) then\n                        return false\n                    end\n                end\n            end\n        end\n    end\n    return true\nend\n\nlocal function CaptureEntries(units)\n    local captured = {}\n    for _, unit in pairs(units or {}) do\n        if not IsCaptureCandidate(unit) then\n            return nil\n        end\n\n        if not HasIdentityBuildOrientation(unit) then\n            return nil\n        end\n\n        -- Capture the authoritative simulation center. Rendering\n        -- positions can be interpolated, and truncating either\n        -- coordinate destroys mixed whole/half-cell spacing.\n        local position = unit:GetSimPosition()\n        if not position\n            or not IsFiniteCoordinate(position.x, MAX_OFFSET)\n            or not IsFiniteCoordinate(position.z, MAX_OFFSET) then\n            return nil\n        end\n        table.insert(captured, {\n            tpId = GetTemplateId(unit),\n            x = position.x,\n            z = position.z,\n        })\n        if #captured > MAX_ENTRIES then\n            return nil\n        end\n    end\n\n    if #captured == 0 then\n        return nil\n    end\n\n    table.sort(captured, function(a, b)\n        if a.x ~= b.x then return a.x < b.x end\n        if a.z ~= b.z then return a.z < b.z end\n        return a.tpId < b.tpId\n    end)\n\n    local minX = captured[1].x\n    local minZ = captured[1].z\n    for _, entry in ipairs(captured) do\n        minX = math.min(minX, entry.x)\n        minZ = math.min(minZ, entry.z)\n    end\n\n    -- Keep the layout's phase within the placement grid. Using\n    -- the raw minimum as origin would preserve pairwise distance\n    -- but silently move every fractional center onto a new phase.\n    local originX = math.floor(minX)\n    local originZ = math.floor(minZ)\n\n    local entries = {}\n    for _, entry in ipairs(captured) do\n        table.insert(entries, {\n            tpId = entry.tpId,\n            dx = entry.x - originX,\n            dz = entry.z - originZ,\n        })\n    end\n    return ValidateEntries(entries) and entries or nil\nend\n\nlocal function IsStoredPlan(plan)\n    return type(plan) == \"table\"\n        and type(plan.iconTpId) == \"string\"\n        and IsFiniteInteger(plan.revision, 2147483647)\n        and plan.revision > 0\n        and ValidateEntries(plan.entries)\n        and plan.iconTpId == plan.entries[1].tpId\nend\n\nlocal function TakeNextRevision()\n    local revision = nextPlanRevision\n    nextPlanRevision = nextPlanRevision + 1\n    return revision\nend\n\nlocal function CopyPlan(plan)\n    if not IsStoredPlan(plan) then\n        return nil\n    end\n\n    local entries = {}\n    for _, entry in ipairs(plan.entries) do\n        table.insert(entries, {\n            tpId = entry.tpId,\n            dx = entry.dx,\n            dz = entry.dz,\n        })\n    end\n    return {\n        iconTpId = entries[1].tpId,\n        entries = entries,\n    }\nend\n\nlocal function CloneSlots()\n    local cloned = {}\n    for slot = 1, MAX_SLOTS do\n        local plan = slots[slot]\n        if plan then\n            local copy = CopyPlan(plan)\n            if not copy then\n                return nil\n            end\n            copy.revision = plan.revision\n            cloned[slot] = copy\n        end\n    end\n    return cloned\nend\n\nlocal function PersistCandidate(candidate)\n    local envelope = {\n        schemaVersion = SCHEMA_VERSION,\n        slots = {},\n    }\n    for slot = 1, MAX_SLOTS do\n        local plan = candidate[slot]\n        if plan then\n            if not IsStoredPlan(plan) then\n                Notify(\"the plan set is invalid; no changes were saved.\")\n                return false\n            end\n            table.insert(envelope.slots, {\n                slot = slot,\n                entries = CopyPlan(plan).entries,\n            })\n        end\n    end\n\n    local encodedOk, encoded = pcall(json.encode, envelope)\n    if not encodedOk or type(encoded) ~= \"string\" then\n        Notify(\"the plan set could not be encoded; no changes were saved.\")\n        return false\n    end\n\n    local save = _G.SCO_SaveConstructionPlansJson\n    if type(save) ~= \"function\" then\n        Notify(\"persistent storage is unavailable; no changes were made.\")\n        return false\n    end\n    local callOk, saved, errorText = pcall(save, encoded)\n    if not callOk or not saved then\n        Notify(tostring(errorText or saved or \"save failed\") .. \" No changes were made.\")\n        return false\n    end\n    return true\nend\n\nlocal function DecodePersistedPlans(document)\n    local decodeOk, envelope = pcall(json.decode, document)\n    if not decodeOk\n        or type(envelope) ~= \"table\"\n        or not IsDenseArray(envelope.slots, MAX_SLOTS) then\n        return nil, \"invalid\"\n    end\n    if envelope.schemaVersion == LEGACY_SCHEMA_VERSION then\n        -- Version 1 discarded fractional grid phase and stored no\n        -- orientation provenance. It cannot be promoted to an\n        -- exact plan without recapturing the source structures.\n        return nil, \"legacy\"\n    end\n    if envelope.schemaVersion ~= SCHEMA_VERSION then\n        return nil, \"invalid\"\n    end\n\n    local loaded = {}\n    for _, record in ipairs(envelope.slots) do\n        if type(record) ~= \"table\"\n            or not IsSlot(record.slot)\n            or loaded[record.slot]\n            or not ValidateEntries(record.entries) then\n            return nil, \"invalid\"\n        end\n\n        local entries = {}\n        for _, entry in ipairs(record.entries) do\n            table.insert(entries, {\n                tpId = entry.tpId,\n                dx = entry.dx,\n                dz = entry.dz,\n            })\n        end\n        loaded[record.slot] = {\n            iconTpId = entries[1].tpId,\n            revision = TakeNextRevision(),\n            entries = entries,\n        }\n    end\n    return loaded, nil\nend\n\nEnsurePlansLoaded = function()\n    if plansLoadState == \"loaded\" then\n        return true\n    end\n    if plansLoadState == \"failed\" or plansLoadState == \"loading\" then\n        return false\n    end\n    plansLoadState = \"loading\"\n\n    local load = _G.SCO_LoadConstructionPlansJson\n    if type(load) ~= \"function\" then\n        plansLoadState = \"failed\"\n        Notify(\"persistent storage is unavailable; plans could not be loaded.\")\n        return false\n    end\n\n    local callOk, document, errorText = pcall(load)\n    if not callOk then\n        plansLoadState = \"failed\"\n        Notify(\"saved plans could not be loaded.\")\n        return false\n    end\n    if document == nil then\n        if errorText then\n            plansLoadState = \"failed\"\n            Notify(tostring(errorText))\n            return false\n        end\n        plansLoadState = \"loaded\"\n        return true\n    end\n    if type(document) ~= \"string\" then\n        plansLoadState = \"failed\"\n        Notify(\"the saved plan file is invalid and was ignored.\")\n        return false\n    end\n\n    local loaded, loadError = DecodePersistedPlans(document)\n    if loadError == \"legacy\" then\n        slots = {}\n        plansLoadState = \"loaded\"\n        return true\n    end\n    if not loaded then\n        plansLoadState = \"failed\"\n        Notify(\"the saved plan file is invalid or outdated and was ignored.\")\n        return false\n    end\n    slots = loaded\n    plansLoadState = \"loaded\"\n    return true\nend\n\nlocal function RequireWritablePlans()\n    if EnsurePlansLoaded() then\n        return true\n    end\n    Notify(\"saved plans are locked to protect the existing file; restart after correcting storage.\")\n    return false\nend\n\nlocal function GetStoredPlan(slot)\n    EnsurePlansLoaded()\n    if not IsSlot(slot) then\n        return nil\n    end\n\n    local plan = slots[slot]\n    if plan and not IsStoredPlan(plan) then\n        slots[slot] = nil\n        return nil\n    end\n    return plan\nend\n\nlocal function GetCurrentPlan(slot, revision)\n    local plan = GetStoredPlan(slot)\n    if not plan or plan.revision ~= revision then\n        return nil\n    end\n    return plan\nend\n\nlocal function GetCurrentSelectedUnits()\n    return Import(\"client/input/selectionSystem.lua\").GetSelectedUnits() or {}\nend\n\nlocal function CancelPlacementForPlan(slot, revision)\n    local Placement = Import(\"client/input/scoBlueprintPlacement.lua\")\n    local succeeded = pcall(Placement.CancelIfSourceSlot, slot, revision)\n    if not succeeded then\n        pcall(Placement.Cancel)\n    end\nend\n\nlocal function FindFirstFreeSlot()\n    for slot = DEFAULT_SLOT, MAX_SLOTS do\n        if not GetStoredPlan(slot) then\n            return slot\n        end\n    end\n    return nil\nend\n\nlocal function CountSavedPlans()\n    local count = 0\n    for slot = 1, MAX_SLOTS do\n        if GetStoredPlan(slot) then\n            count = count + 1\n        end\n    end\n    return count\nend\n\nlocal function GetPlanTitle(slot, plan)\n    return \"Plan \" .. slot .. \" (\" .. #plan.entries .. \" structures)\"\nend\n\nlocal function SetTooltip(button, title, description)\n    Engine.UI_SetButtonTooltip(button.buttonID, title, description)\nend\n\nlocal function ButtonData(text, plan, fallbackTpId)\n    local iconTpId = plan and plan.iconTpId or fallbackTpId\n    local template = iconTpId and __Templates.Units[iconTpId] or nil\n    return {\n        text = text,\n        foreground = template and template.general.foregroundIconID or { index = 0 },\n        background = template and template.general.backgroundIconID or { index = 0 },\n        frame = { index = 0 },\n        icon = template and template.general.strategicIconID or { index = 0 },\n        iconGlowColor = template and template.general.strategicIconGlowColor\n            or EngineClasses.float3(0, 0, 0),\n        emitClickEvents = true,\n        emitHoverEvents = false,\n    }\nend\n\nlocal function MarkBlueprintFilterActive(panel, activeButton)\n    for _, button in pairs(panel.constructionFilteringButtons.buttons) do\n        button:SetActive(button.buttonID.id == activeButton.buttonID.id)\n    end\nend\n\nfunction CanCaptureSelection(units)\n    return CaptureEntries(units) ~= nil\nend\n\nfunction CaptureIntoSlot(slot, units, expectedRevision, requireEmpty)\n    if not RequireWritablePlans() then\n        return false\n    end\n    if not IsSlot(slot) then\n        return false\n    end\n\n    local previousPlan = GetStoredPlan(slot)\n    if requireEmpty and previousPlan then\n        Notify(\"Plan \" .. tostring(slot) .. \" changed; choose the slot again.\")\n        return false\n    end\n    if expectedRevision ~= nil\n        and (not previousPlan or previousPlan.revision ~= expectedRevision) then\n        Notify(\"Plan \" .. tostring(slot) .. \" changed; reopen its confirmation.\")\n        return false\n    end\n\n    local entries = CaptureEntries(units)\n    if not entries then\n        Notify(\"select 1-20 non-overlapping completed friendly unrotated structures; extractors are excluded.\")\n        return false\n    end\n\n    local candidate = CloneSlots()\n    if not candidate then\n        Notify(\"the current plan set is invalid; no changes were made.\")\n        return false\n    end\n    candidate[slot] = {\n        iconTpId = entries[1].tpId,\n        revision = TakeNextRevision(),\n        entries = entries,\n    }\n    if not PersistCandidate(candidate) then\n        return false\n    end\n\n    slots = candidate\n    if previousPlan then\n        CancelPlacementForPlan(slot, previousPlan.revision)\n    end\n    Notify(\n        GetPlanTitle(slot, slots[slot])\n            .. (previousPlan and \" replaced. \" or \" saved. \")\n            .. \"Select builders, then click BP > P\"\n            .. slot\n            .. \" or press Alt+\"\n            .. slot\n            .. \" to place it.\")\n    return true\nend\n\nfunction CaptureDefaultPlan(units)\n    local slot = FindFirstFreeSlot()\n    if not slot then\n        Notify(\"all 8 plan slots are occupied; delete a plan before saving.\")\n        return false\n    end\n    return CaptureIntoSlot(slot, units, nil, true)\nend\n\nfunction DuplicatePlan(slot, revision)\n    if not RequireWritablePlans() then\n        return false\n    end\n    local plan = GetCurrentPlan(slot, revision)\n    if not plan then\n        Notify(\"Plan \" .. tostring(slot) .. \" changed; reopen its action menu.\")\n        return false\n    end\n\n    local targetSlot = FindFirstFreeSlot()\n    if not targetSlot then\n        Notify(\"all 8 plan slots are occupied; delete a plan before copying.\")\n        return false\n    end\n\n    local candidate = CloneSlots()\n    local copied = CopyPlan(plan)\n    if not candidate or not copied then\n        Notify(\"Plan \" .. tostring(slot) .. \" is invalid and cannot be copied.\")\n        return false\n    end\n    copied.revision = TakeNextRevision()\n    candidate[targetSlot] = copied\n    if not PersistCandidate(candidate) then\n        return false\n    end\n    slots = candidate\n    Notify(GetPlanTitle(slot, plan) .. \" copied to Plan \" .. targetSlot .. \".\")\n    return true\nend\n\nfunction DeletePlan(slot, revision)\n    if not RequireWritablePlans() then\n        return false\n    end\n    local plan = GetCurrentPlan(slot, revision)\n    if not plan then\n        Notify(\"Plan \" .. tostring(slot) .. \" changed; reopen its action menu.\")\n        return false\n    end\n\n    local candidate = CloneSlots()\n    if not candidate then\n        Notify(\"the current plan set is invalid; no changes were made.\")\n        return false\n    end\n    candidate[slot] = nil\n    if not PersistCandidate(candidate) then\n        return false\n    end\n\n    slots = candidate\n    CancelPlacementForPlan(slot, plan.revision)\n    Notify(\"Plan \" .. slot .. \" deleted.\")\n    return true\nend\n\nfunction IsPlanBuildable(plan, units)\n    if not IsStoredPlan(plan) then\n        return false\n    end\n    return Import(\"client/input/scoBlueprintPlacement.lua\").CanBuildEntries(\n        plan.entries,\n        units or {})\nend\n\nlocal function BeginPlan(slot, plan, selectedUnits)\n    local Placement = Import(\"client/input/scoBlueprintPlacement.lua\")\n    if not Placement.Begin(plan, selectedUnits, slot, plan.revision) then\n        Notify(\"select builders that can each construct every part of \" .. GetPlanTitle(slot, plan) .. \".\")\n        return false\n    end\n\n    blueprintPanelActive = false\n    Import(\"client/ui/uiManager.lua\").SetUIDirty()\n    return true\nend\n\nfunction ActivatePlanSlot(slot, selectedUnits)\n    EnsurePlansLoaded()\n    local plan = GetStoredPlan(slot)\n    if not plan then\n        Notify(\"Plan \" .. tostring(slot) .. \" is empty.\")\n        return false\n    end\n    selectedUnits = selectedUnits or GetCurrentSelectedUnits()\n    if not IsPlanBuildable(plan, selectedUnits) then\n        Notify(\"select compatible engineers or a commander before placing Plan \" .. slot .. \".\")\n        return false\n    end\n    return BeginPlan(slot, plan, selectedUnits)\nend\n\nlocal function ShowCaptureDeck(panel, units)\n    EnsurePlansLoaded()\n    units = GetCurrentSelectedUnits()\n    local captureEntries = CaptureEntries(units)\n    local captureIconTpId = captureEntries and captureEntries[1].tpId or nil\n    blueprintPanelActive = true\n    panel.hoveredTemplate = nil\n    panel.constructionButtons:ClearButtons()\n    for slot = 1, MAX_SLOTS do\n        local plan = GetStoredPlan(slot)\n        local payload = {\n            panel = panel,\n            slot = slot,\n            revision = plan and plan.revision or nil,\n            hasPlan = plan ~= nil,\n        }\n        local button = panel.constructionButtons:AddButton(\n            ButtonData(plan and (\"P\" .. slot) or (\"+P\" .. slot), plan, captureIconTpId),\n            function(_, clickPayload)\n                if clickPayload.hasPlan then\n                    ShowPlanActions(\n                        clickPayload.panel,\n                        GetCurrentSelectedUnits(),\n                        clickPayload.slot,\n                        clickPayload.revision)\n                elseif CaptureIntoSlot(\n                    clickPayload.slot,\n                    GetCurrentSelectedUnits(),\n                    nil,\n                    true) then\n                    ShowCaptureDeck(clickPayload.panel, GetCurrentSelectedUnits())\n                end\n            end,\n            function(_, clickPayload)\n                if clickPayload.hasPlan then\n                    ShowOverwriteConfirmation(\n                        clickPayload.panel,\n                        GetCurrentSelectedUnits(),\n                        clickPayload.slot,\n                        clickPayload.revision)\n                end\n            end,\n            nil,\n            nil,\n            payload)\n        local description = plan\n            and (\"Left-click opens actions for \" .. GetPlanTitle(slot, plan)\n                .. \"; right-click replaces it with the selected layout.\")\n            or \"Save the selected layout in this empty slot.\"\n        SetTooltip(button, plan and GetPlanTitle(slot, plan) or (\"Save Plan \" .. slot), description)\n    end\n    panel:SetConstructionEnabled(true)\nend\n\nShowOverwriteConfirmation = function(panel, units, slot, revision)\n    units = GetCurrentSelectedUnits()\n    local plan = GetCurrentPlan(slot, revision)\n    if not plan then\n        Notify(\"Plan \" .. tostring(slot) .. \" changed; reopen the capture deck.\")\n        ShowCaptureDeck(panel, units)\n        return\n    end\n\n    blueprintPanelActive = true\n    panel.hoveredTemplate = nil\n    panel.constructionButtons:ClearButtons()\n\n    local replacePayload = { panel = panel, slot = slot, revision = revision }\n    local replaceButton = panel.constructionButtons:AddButton(\n        ButtonData(\"YES\", plan),\n        function(_, clickPayload)\n            CaptureIntoSlot(\n                clickPayload.slot,\n                GetCurrentSelectedUnits(),\n                clickPayload.revision,\n                false)\n            ShowCaptureDeck(clickPayload.panel, GetCurrentSelectedUnits())\n        end,\n        nil,\n        nil,\n        nil,\n        replacePayload)\n    SetTooltip(\n        replaceButton,\n        \"Replace \" .. GetPlanTitle(slot, plan),\n        \"Save the selected structures over this plan.\")\n\n    local cancelButton = panel.constructionButtons:AddButton(\n        ButtonData(\"NO\", plan),\n        function(_, clickPayload)\n            ShowCaptureDeck(clickPayload.panel, GetCurrentSelectedUnits())\n        end,\n        nil,\n        nil,\n        nil,\n        { panel = panel })\n    SetTooltip(cancelButton, \"Keep Plan\", \"Return without replacing the plan.\")\n    panel:SetConstructionEnabled(true)\nend\n\nShowDeleteConfirmation = function(panel, units, slot, revision)\n    units = GetCurrentSelectedUnits()\n    local plan = GetCurrentPlan(slot, revision)\n    if not plan then\n        Notify(\"Plan \" .. tostring(slot) .. \" changed; reopen its action menu.\")\n        ShowBrowser(panel, units)\n        return\n    end\n\n    blueprintPanelActive = true\n    panel.hoveredTemplate = nil\n    panel.constructionButtons:ClearButtons()\n\n    local deletePayload = { panel = panel, slot = slot, revision = revision }\n    local deleteButton = panel.constructionButtons:AddButton(\n        ButtonData(\"DEL\", plan),\n        function(_, clickPayload)\n            DeletePlan(clickPayload.slot, clickPayload.revision)\n            ShowBrowser(clickPayload.panel, GetCurrentSelectedUnits())\n        end,\n        nil,\n        nil,\n        nil,\n        deletePayload)\n    SetTooltip(\n        deleteButton,\n        \"Delete \" .. GetPlanTitle(slot, plan),\n        \"Permanently remove this saved plan.\")\n\n    local keepPayload = { panel = panel, slot = slot, revision = revision }\n    local keepButton = panel.constructionButtons:AddButton(\n        ButtonData(\"KEEP\", plan),\n        function(_, clickPayload)\n            ShowPlanActions(\n                clickPayload.panel,\n                GetCurrentSelectedUnits(),\n                clickPayload.slot,\n                clickPayload.revision)\n        end,\n        nil,\n        nil,\n        nil,\n        keepPayload)\n    SetTooltip(keepButton, \"Keep Plan\", \"Return to this plan's actions.\")\n    panel:SetConstructionEnabled(true)\nend\n\nShowPlanActions = function(panel, units, slot, revision)\n    units = GetCurrentSelectedUnits()\n    local plan = GetCurrentPlan(slot, revision)\n    if not plan then\n        Notify(\"Plan \" .. tostring(slot) .. \" changed; reopen the plan browser.\")\n        ShowBrowser(panel, units)\n        return\n    end\n\n    Import(\"client/input/scoBlueprintPlacement.lua\").Cancel()\n    blueprintPanelActive = true\n    panel.hoveredTemplate = nil\n    panel.constructionButtons:ClearButtons()\n\n    local placePayload = { panel = panel, slot = slot, revision = revision }\n    local placeButton = panel.constructionButtons:AddButton(\n        ButtonData(\"PLACE\", plan),\n        function(_, clickPayload)\n            local currentPlan =\n                GetCurrentPlan(clickPayload.slot, clickPayload.revision)\n            if not currentPlan then\n                Notify(\"Plan \" .. tostring(clickPayload.slot) .. \" changed.\")\n                ShowBrowser(clickPayload.panel, GetCurrentSelectedUnits())\n            else\n                ActivatePlanSlot(clickPayload.slot, GetCurrentSelectedUnits())\n            end\n        end,\n        nil,\n        nil,\n        nil,\n        placePayload)\n    SetTooltip(\n        placeButton,\n        \"Place \" .. GetPlanTitle(slot, plan),\n        \"Start world placement with the currently selected compatible builders.\")\n\n    local copyPayload = { panel = panel, slot = slot, revision = revision }\n    local copyButton = panel.constructionButtons:AddButton(\n        ButtonData(\"COPY\", plan),\n        function(_, clickPayload)\n            DuplicatePlan(clickPayload.slot, clickPayload.revision)\n            ShowBrowser(clickPayload.panel, GetCurrentSelectedUnits())\n        end,\n        nil,\n        nil,\n        nil,\n        copyPayload)\n    SetTooltip(copyButton, \"Copy \" .. GetPlanTitle(slot, plan), \"Copy this layout to the first empty slot.\")\n\n    local deletePayload = { panel = panel, slot = slot, revision = revision }\n    local deleteButton = panel.constructionButtons:AddButton(\n        ButtonData(\"DEL\", plan),\n        function(_, clickPayload)\n            ShowDeleteConfirmation(\n                clickPayload.panel,\n                GetCurrentSelectedUnits(),\n                clickPayload.slot,\n                clickPayload.revision)\n        end,\n        nil,\n        nil,\n        nil,\n        deletePayload)\n    SetTooltip(deleteButton, \"Delete Plan \" .. slot, \"Open the delete confirmation.\")\n\n    local backButton = panel.constructionButtons:AddButton(\n        ButtonData(\"BACK\", plan),\n        function(_, clickPayload)\n            ShowBrowser(clickPayload.panel, GetCurrentSelectedUnits())\n        end,\n        nil,\n        nil,\n        nil,\n        { panel = panel })\n    SetTooltip(backButton, \"Back\", \"Return to all saved plans.\")\n    panel:SetConstructionEnabled(true)\nend\n\nShowBrowser = function(panel, units)\n    EnsurePlansLoaded()\n    units = GetCurrentSelectedUnits()\n    blueprintPanelActive = true\n    panel.hoveredTemplate = nil\n    panel.constructionButtons:ClearButtons()\n    for slot = 1, MAX_SLOTS do\n        local plan = GetStoredPlan(slot)\n        if plan then\n            local canBuild = IsPlanBuildable(plan, units)\n            local payload = {\n                panel = panel,\n                slot = slot,\n                revision = plan.revision,\n            }\n            local button = panel.constructionButtons:AddButton(\n                ButtonData(\"P\" .. slot, plan),\n                function(_, clickPayload)\n                    local currentPlan =\n                        GetCurrentPlan(clickPayload.slot, clickPayload.revision)\n                    if not currentPlan then\n                        Notify(\"Plan \" .. tostring(clickPayload.slot) .. \" changed.\")\n                        ShowBrowser(clickPayload.panel, GetCurrentSelectedUnits())\n                    else\n                        ActivatePlanSlot(\n                            clickPayload.slot,\n                            GetCurrentSelectedUnits())\n                    end\n                end,\n                function(_, clickPayload)\n                    ShowPlanActions(\n                        clickPayload.panel,\n                        GetCurrentSelectedUnits(),\n                        clickPayload.slot,\n                        clickPayload.revision)\n                end,\n                nil,\n                nil,\n                payload)\n            local description = \"Left-click places this plan; right-click opens its actions. Alt+\"\n                .. slot\n                .. \" also places it.\"\n            if not canBuild then\n                description = \"Select compatible builders to place this plan. Right-click still opens its actions.\"\n            end\n            SetTooltip(button, GetPlanTitle(slot, plan), description)\n        end\n    end\n    panel:SetConstructionEnabled(true)\nend\n\nfunction ShowBlueprintTab(panel, units)\n    TempBuildMode.SetBuildMode(false)\n    units = GetCurrentSelectedUnits()\n    if CanCaptureSelection(units) then\n        ShowCaptureDeck(panel, units)\n    else\n        ShowBrowser(panel, units)\n    end\nend\n\nfunction AddBlueprintFilter(panel, units, canCapture)\n    EnsurePlansLoaded()\n    local payload = { panel = panel, canCapture = canCapture }\n    local button = panel.constructionFilteringButtons:AddButton(\n        ButtonData(\"BP\", nil),\n        function(_, clickPayload)\n            MarkBlueprintFilterActive(clickPayload.panel, clickPayload.button)\n            ShowBlueprintTab(clickPayload.panel, GetCurrentSelectedUnits())\n        end,\n        nil,\n        nil,\n        nil,\n        payload)\n    payload.button = button\n    if blueprintPanelActive then\n        MarkBlueprintFilterActive(panel, button)\n    end\n\n    -- Stock hides the filter strip for ordinary structures. Keep\n    -- the inactive BP affordance visible without opening its deck.\n    panel:SetConstructionFilterEnabled(true)\n\n    local savedPlans = CountSavedPlans()\n    local description = canCapture\n        and \"Save the selected structures with +P1 through +P8.\"\n        or \"Open saved plans. Left-click a plan to place it.\"\n    SetTooltip(\n        button,\n        \"Construction Plans\",\n        description\n            .. \" Shift+T saves to the first empty slot; Alt+1 through Alt+8 place plans directly. \"\n            .. savedPlans\n            .. \" of \"\n            .. MAX_SLOTS\n            .. \" slots used.\")\nend\n\nfunction CloseBlueprintPanel()\n    blueprintPanelActive = false\nend\n\nfunction LeaveBlueprintUI()\n    CloseBlueprintPanel()\n    Import(\"client/input/scoBlueprintPlacement.lua\").Cancel()\nend\n\nfunction IsBlueprintUIActive()\n    return blueprintPanelActive\nend\n\nreturn {\n    ActivatePlanSlot = ActivatePlanSlot,\n    AddBlueprintFilter = AddBlueprintFilter,\n    CanCaptureSelection = CanCaptureSelection,\n    CaptureDefaultPlan = CaptureDefaultPlan,\n    CaptureIntoSlot = CaptureIntoSlot,\n    CloseBlueprintPanel = CloseBlueprintPanel,\n    DeletePlan = DeletePlan,\n    DuplicatePlan = DuplicatePlan,\n    IsPlanBuildable = IsPlanBuildable,\n    IsBlueprintUIActive = IsBlueprintUIActive,\n    LeaveBlueprintUI = LeaveBlueprintUI,\n    ShowBlueprintTab = ShowBlueprintTab,\n}\n";
	}

	private static string BuildPlacementModuleSource()
	{
		return "-- Sanctuary Construction Plans 2.1.0\n-- Bounded client placement. Every structure remains an ordinary\n-- Sanctuary BUILD order independently validated by the host.\nlocal bit = require(\"bit\")\nlocal MAX_ENTRIES = 20\nlocal MAX_OFFSET = 8192\nlocal PREVIEW_REFRESH_SECONDS = 0.1\nlocal TempBuildMode = Import(\"client/input/buildmodeTemp.lua\")\nlocal MouseCursor = Import(\"client/input/mouseCursor.lua\")\nlocal SelectionSystem = Import(\"client/input/selectionSystem.lua\")\nlocal ClientOrderManager = Import(\"client/managers/orders/clientOrderManager.lua\")\nlocal OrderTasks = Import(\"common/commonOrders.lua\").OrderTasks\nlocal PredictedUnit = Import(\"client/entities/predictedUnit.lua\").PredictedUnit\nlocal Layers = Import(\"common/layers.lua\")\nlocal PlacementLayer = Layers.PlacementLayer\nlocal PlacementDomain = Layers.PlacementDomain\nlocal PlacementUtils = Import(\"common/systems/placementUtils.lua\")\n\nlocal activePlan = nil\nlocal planGhosts = {}\nlocal previewAnchorX = nil\nlocal previewAnchorZ = nil\nlocal nextPreviewRefreshTime = nil\nlocal previewReuseUnavailable = false\n\nlocal function Notify(text)\n    Engine.UI_AddLogText(\"Construction Plans: \" .. text, 5)\nend\n\nlocal function IsFiniteNumber(value, maximumMagnitude)\n    return type(value) == \"number\"\n        and value == value\n        and math.abs(value) <= maximumMagnitude\nend\n\nlocal function IsFiniteInteger(value, maximumMagnitude)\n    return IsFiniteNumber(value, maximumMagnitude)\n        and value == math.floor(value)\nend\n\nlocal function IsFiniteCoordinate(value, maximumMagnitude)\n    return IsFiniteNumber(value, maximumMagnitude)\nend\n\nlocal function IsDenseArray(value, maximumLength)\n    if type(value) ~= \"table\"\n        or #value > maximumLength then\n        return false\n    end\n\n    local count = 0\n    for key in pairs(value) do\n        if type(key) ~= \"number\"\n            or key ~= math.floor(key)\n            or key < 1\n            or key > #value then\n            return false\n        end\n        count = count + 1\n    end\n    return count == #value\nend\n\nlocal function IsPlanBuilder(unit)\n    if not unit or not unit.tp or not unit.tp.general then\n        return false\n    end\n    local tpId = unit.tp.general.tpId\n    return unit.armyId == GetFocusArmy()\n        and unit.IsCompleted\n        and unit:IsCompleted()\n        and (Tags.ENGINEER[tpId]\n            or Tags.COMMAND[tpId]\n            or Tags.ENGINEERING_STATION[tpId])\nend\n\nlocal function IsPlanEntry(entry)\n    local tpId = entry and entry.tpId\n    local template = tpId and __Templates.Units[tpId]\n    local skirt = template and template.skirtSize\n    return type(tpId) == \"string\"\n        and #tpId > 0\n        and #tpId <= 64\n        and string.match(tpId, \"^[%w_%-]+$\") ~= nil\n        and template\n        and template.general\n        and template.general.placementGhostPrefabID\n        and skirt\n        and IsFiniteInteger(skirt.x, 128)\n        and IsFiniteInteger(skirt.y, 128)\n        and skirt.x > 0\n        and skirt.y > 0\n        and Tags.STRUCTURE[tpId]\n        and not Tags.ALLOYS_EXTRACTION[tpId]\n        and IsFiniteCoordinate(entry.dx, MAX_OFFSET)\n        and IsFiniteCoordinate(entry.dz, MAX_OFFSET)\nend\n\nlocal function AddArea(areas, position, size)\n    if type(size) ~= \"table\"\n        or not IsFiniteInteger(size.x, 128)\n        or not IsFiniteInteger(size.y, 128)\n        or size.x <= 0\n        or size.y <= 0 then\n        return false\n    end\n\n    local minX, minZ, maxX, maxZ =\n        PlacementUtils.GetPlacementBounds(position, size)\n    table.insert(areas, {\n        minX = minX,\n        minZ = minZ,\n        maxX = maxX,\n        maxZ = maxZ,\n    })\n    return true\nend\n\nlocal function GetTemplateAreas(position, template)\n    if not template or not template.skirtSize then\n        return nil\n    end\n\n    local areas = {}\n    if not AddArea(areas, position, template.skirtSize) then\n        return nil\n    end\n\n    local additions = template.additions\n    local reservations = additions and additions.placementReservations or {}\n    if not IsDenseArray(reservations, 16) then\n        return nil\n    end\n    for _, reservation in ipairs(reservations) do\n        if type(reservation) ~= \"table\" then\n            return nil\n        end\n        local offset = reservation.offset or {}\n        if type(offset) ~= \"table\"\n            or not IsFiniteInteger(offset.x or 0, 128)\n            or not IsFiniteInteger(offset.z or 0, 128)\n            or not AddArea(\n                areas,\n                EngineClasses.float3(\n                    position.x + (offset.x or 0),\n                    position.y or 0,\n                    position.z + (offset.z or 0)),\n                reservation.size) then\n            return nil\n        end\n    end\n    return areas\nend\n\nlocal function AreasOverlap(first, second)\n    return first.minX <= second.maxX\n        and second.minX <= first.maxX\n        and first.minZ <= second.maxZ\n        and second.minZ <= first.maxZ\nend\n\nlocal function EntriesOverlap(first, second)\n    local firstTemplate = __Templates.Units[first.tpId]\n    local secondTemplate = __Templates.Units[second.tpId]\n    local firstAreas = GetTemplateAreas(\n        EngineClasses.float3(first.dx, 0, first.dz),\n        firstTemplate)\n    local secondAreas = GetTemplateAreas(\n        EngineClasses.float3(second.dx, 0, second.dz),\n        secondTemplate)\n    if not firstAreas or not secondAreas then\n        return true\n    end\n    for _, firstArea in ipairs(firstAreas) do\n        for _, secondArea in ipairs(secondAreas) do\n            if AreasOverlap(firstArea, secondArea) then\n                return true\n            end\n        end\n    end\n    return false\nend\n\nlocal function CopyPlan(plan)\n    if type(plan) ~= \"table\"\n        or not IsDenseArray(plan.entries, MAX_ENTRIES)\n        or #plan.entries == 0 then\n        return nil\n    end\n\n    local copied = {}\n    for _, entry in ipairs(plan.entries) do\n        if not IsPlanEntry(entry) then\n            return nil\n        end\n        table.insert(copied, {\n            tpId = entry.tpId,\n            dx = entry.dx,\n            dz = entry.dz,\n        })\n    end\n    for firstIndex = 1, #copied do\n        for secondIndex = firstIndex + 1, #copied do\n            if EntriesOverlap(copied[firstIndex], copied[secondIndex]) then\n                return nil\n            end\n        end\n    end\n    return copied\nend\n\nlocal function GetCompatibleBuilders(entries, units)\n    local compatible = {}\n    for _, unit in pairs(units or {}) do\n        if IsPlanBuilder(unit) then\n            local canBuildAll = true\n            for _, entry in ipairs(entries) do\n                local callSucceeded, canBuild =\n                    pcall(buildQueueUtils.CanBuild, unit, entry.tpId, nil, true)\n                if not callSucceeded or not canBuild then\n                    canBuildAll = false\n                    break\n                end\n            end\n            if canBuildAll then\n                table.insert(compatible, unit)\n            end\n        end\n    end\n    return compatible\nend\n\nfunction CanBuildEntries(entries, units)\n    local copied = CopyPlan({ entries = entries })\n    return copied ~= nil and #GetCompatibleBuilders(copied, units) > 0\nend\n\nlocal function RemovePreview()\n    for _, ghost in pairs(planGhosts) do\n        Engine.SetRangeRingsEnabled(ghost.id, false)\n        Engine.DeletePrefabInstance(ghost.id)\n    end\n    table.clear(planGhosts)\n    previewAnchorX = nil\n    previewAnchorZ = nil\n    nextPreviewRefreshTime = nil\nend\n\n-- Sanctuary Construction Plans naval water placement 1.0.0\nlocal function RequiresWaterPlacement(template)\n    return template\n        and template.general\n        and template.general.requiresWaterPlacement == true\nend\n\nlocal function GetMinimumWaterDepth(template)\n    local additions = template and template.additions\n    local faContract = additions and additions.faSourceContract\n    local authored = faContract and faContract.minimumWaterDepth\n    if type(authored) == \"number\" and authored >= 0 then\n        return authored\n    end\n    return 1.5\nend\n\nlocal function IsClearArea(area, template)\n    local min = EngineClasses.int2(area.minX, area.minZ)\n    local max = EngineClasses.int2(area.maxX, area.maxZ)\n    local results = {}\n    local errorCode = Engine.GetLocalGridCellFlags(\n        _G.localBuildingPlacementGridID,\n        min,\n        max,\n        results)\n    local expectedCells =\n        (area.maxX - area.minX + 1) * (area.maxZ - area.minZ + 1)\n    if errorCode ~= EngineErrorCode.Success or #results ~= expectedCells then\n        return false\n    end\n    local domain = RequiresWaterPlacement(template)\n        and PlacementDomain.Water or PlacementUtils.GetPlacementDomain(template)\n    for _, result in ipairs(results) do\n        if not PlacementUtils.IsCellValidForPlacement(result.flags, domain, false)\n            or bit.band(result.flags, PlacementLayer.Default) ~= 0 then\n            return false\n        end\n    end\n    return true\nend\n\nlocal function GetWaterLevel()\n    local hasWaterErrorCode, hasWater = Engine.HasWater()\n    if hasWaterErrorCode ~= EngineErrorCode.Success or not hasWater then\n        return nil\n    end\n    local waterLevelErrorCode, waterLevel = Engine.GetWaterLevel()\n    if waterLevelErrorCode ~= EngineErrorCode.Success then\n        return nil\n    end\n    return waterLevel\nend\n\nlocal function IsSubmergedCell(cell, waterLevel, minimumDepth)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeightFromCell(cell)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend\n\nlocal function IsSubmergedPoint(position, waterLevel, minimumDepth)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend\n\nlocal function CanPlaceWaterFactory(template, position)\n    if not RequiresWaterPlacement(template) then\n        return true\n    end\n\n    local waterLevel = GetWaterLevel()\n    local minimumDepth = GetMinimumWaterDepth(template)\n    if not waterLevel or minimumDepth == nil then\n        return false\n    end\n    local minX, minZ, maxX, maxZ =\n        PlacementUtils.GetPlacementBounds(position, template.skirtSize)\n    for x = minX, maxX do\n        for z = minZ, maxZ do\n            if not IsSubmergedCell(\n                EngineClasses.int2(x, z),\n                waterLevel,\n                minimumDepth) then\n                return false\n            end\n        end\n    end\n\n    local construction = template.construction\n    local additions = template.additions\n    local routes = construction and construction.rollOffPoints\n    local ramps = additions and additions.rollOffRamps\n    if routes and (not IsDenseArray(routes, 2) or #routes ~= 2) then\n        return false\n    end\n    if ramps and (not IsDenseArray(ramps, 2) or #ramps ~= 2) then\n        return false\n    end\n    if not routes and not ramps then\n        return false\n    end\n    for index = 1, 2 do\n        local route = routes and routes[index]\n        local ramp = ramps and ramps[index]\n        local routeOffset = route and route.offset or ramp and ramp.rampOffset\n        local exitOffset = ramp and ramp.clearanceOffset\n            or routeOffset and {\n                x = (routeOffset.x or 0) * ((route and route.exitScale) or 2),\n                z = (routeOffset.z or 0) * ((route and route.exitScale) or 2),\n            }\n        if type(routeOffset) == \"table\"\n            and type(exitOffset) == \"table\"\n            and IsFiniteNumber(routeOffset.x or 0, 128)\n            and IsFiniteNumber(routeOffset.z or 0, 128)\n            and IsFiniteNumber(exitOffset.x or 0, 256)\n            and IsFiniteNumber(exitOffset.z or 0, 256) then\n            local routePoint = EngineClasses.float3(\n                position.x + (routeOffset.x or 0),\n                waterLevel,\n                position.z + (routeOffset.z or 0))\n            local exitPoint = EngineClasses.float3(\n                position.x + (exitOffset.x or 0),\n                waterLevel,\n                position.z + (exitOffset.z or 0))\n            if IsSubmergedPoint(routePoint, waterLevel, minimumDepth)\n                and IsSubmergedPoint(exitPoint, waterLevel, minimumDepth) then\n                return true\n            end\n        end\n    end\n    return false\nend\n\nlocal function GetPlacementHeight(template, point)\n    if RequiresWaterPlacement(template)\n        or PlacementUtils.GetPlacementDomain(template) == PlacementDomain.Water then\n        local waterLevel = GetWaterLevel()\n        return waterLevel or 0, waterLevel ~= nil\n    end\n    local terrainErrorCode, terrainHeight =\n        Engine.SampleTerrainHeight(EngineClasses.float3(point.x, 0, point.z))\n    if terrainErrorCode ~= EngineErrorCode.Success then\n        return 0, false\n    end\n    return terrainHeight, true\nend\n\nlocal function GetPlacementEntries(anchor)\n    if not activePlan then\n        return {}, false\n    end\n\n    anchor = anchor or MouseCursor.GetMousePosition()\n    anchor.x = math.truncateToInt(anchor.x)\n    anchor.z = math.truncateToInt(anchor.z)\n    local entries = {}\n    local allValid = true\n    local mapSizeX = GameInfo.MapInfo.size[1]\n    local mapSizeZ = GameInfo.MapInfo.size[2]\n\n    -- Read every stock/reservation cell before creating plan ghosts.\n    for _, entry in ipairs(activePlan.entries) do\n        local template = __Templates.Units[entry.tpId]\n        local point = {\n            x = anchor.x + entry.dx,\n            z = anchor.z + entry.dz,\n        }\n        local placementHeight, heightValid = GetPlacementHeight(template, point)\n        local position = EngineClasses.float3(\n            point.x,\n            placementHeight,\n            point.z)\n        local areas = GetTemplateAreas(position, template)\n        local valid = heightValid\n            and areas ~= nil\n            and CanPlaceWaterFactory(template, position)\n        for _, area in ipairs(areas or {}) do\n            local withinBounds = area.minX >= 0\n                and area.minZ >= 0\n                and area.maxX <= mapSizeX\n                and area.maxZ <= mapSizeZ\n            if not withinBounds or not IsClearArea(area, template) then\n                valid = false\n            end\n        end\n        table.insert(entries, {\n            tpId = entry.tpId,\n            position = position,\n            areas = areas or {},\n            valid = valid,\n        })\n        if not valid then\n            allValid = false\n        end\n    end\n\n    -- A single grid read cannot see the other not-yet-issued plan\n    -- entries, so reject core or factory-reservation overlap here.\n    for firstIndex = 1, #entries do\n        for secondIndex = firstIndex + 1, #entries do\n            for _, firstArea in ipairs(entries[firstIndex].areas) do\n                for _, secondArea in ipairs(entries[secondIndex].areas) do\n                    if AreasOverlap(firstArea, secondArea) then\n                        entries[firstIndex].valid = false\n                        entries[secondIndex].valid = false\n                        allValid = false\n                    end\n                end\n            end\n        end\n    end\n    return entries, allValid\nend\n\nlocal function SetGhostGrid(ghostID, template, valid)\n    for x = 1, template.skirtSize.x do\n        for z = 1, template.skirtSize.y do\n            local boneID = {}\n            Engine.GetLocalBone(ghostID, \"Grid\" .. x .. \" \" .. z .. \"On\", boneID)\n            Engine.SetRendererEnabled(boneID, valid)\n            Engine.GetLocalBone(ghostID, \"Grid\" .. x .. \" \" .. z .. \"Off\", boneID)\n            Engine.SetRendererEnabled(boneID, not valid)\n            Engine.GetLocalBone(ghostID, \"Grid\" .. x .. \" \" .. z .. \"Neutral\", boneID)\n            Engine.SetRendererEnabled(boneID, false)\n        end\n    end\nend\n\nlocal function CreatePrediction(entry, builders, builderArmyId, shouldAppend)\n    local template = __Templates.Units[entry.tpId]\n    local payload = { tpId = entry.tpId, armyId = builderArmyId }\n    local iconColor = Armies[builderArmyId]:GetColor()\n    iconColor.w = PlacementGhostIconAlpha\n    local _, predictedUnitLocalID = Engine.InstantiatePrefab(\n        template.general.placementGhostPrefabID,\n        entry.position,\n        EngineClasses.float3(1, 1, 1),\n        GetIdentityQuaternion())\n    Engine.SetIconColor(predictedUnitLocalID, 0, iconColor)\n    _G.PredictedUnits[predictedUnitLocalID.index] =\n        PredictedUnit(predictedUnitLocalID, GetFocusArmy(), template)\n    payload.predictedUnitLocalID = predictedUnitLocalID\n    ClientOrderManager.ClientIssueOrder(\n        OrderTasks.BUILD,\n        builders,\n        shouldAppend,\n        entry.position,\n        payload,\n        function(accepted, newUnitGlobalID)\n            local predictedUnit =\n                _G.PredictedUnits[predictedUnitLocalID.index]\n            if accepted and predictedUnit and newUnitGlobalID then\n                local targetUnit = _G.GetUnitById(newUnitGlobalID)\n                if targetUnit then\n                    local transferSucceeded = pcall(function()\n                        targetUnit.predictedBuildQueue =\n                            predictedUnit.predictedBuildQueue\n                        targetUnit.predictedBuildQueueIdCounter =\n                            predictedUnit.predictedBuildQueueIdCounter\n                        local units = {\n                            [newUnitGlobalID.index] = targetUnit,\n                        }\n                        for queueIndex, queueItem in ipairs(\n                            predictedUnit.predictedBuildQueue) do\n                            Import(\"common/commands/definitions/buildQueue.lua\")\n                                .RequestQueueAmountForUnits(\n                                    units,\n                                    queueItem.tpId,\n                                    queueItem.count,\n                                    queueIndex)\n                        end\n                    end)\n                    if not transferSucceeded then\n                        Notify(\"a predicted build queue could not be transferred.\")\n                    end\n                end\n            end\n            if predictedUnit then\n                predictedUnit:Delete()\n            end\n        end)\nend\n\nfunction Begin(plan, selectedUnits, sourceSlot, sourceRevision)\n    local copied = CopyPlan(plan)\n    if not copied or #GetCompatibleBuilders(copied, selectedUnits) == 0 then\n        return false\n    end\n    Cancel()\n    TempBuildMode.SetBuildMode(false)\n    activePlan = {\n        entries = copied,\n        sourceSlot = sourceSlot,\n        sourceRevision = sourceRevision,\n    }\n    Notify(\"plan ready: left-click a clear area to place it; right-click cancels.\")\n    return true\nend\n\nfunction IsActive()\n    return activePlan ~= nil\nend\n\nfunction Cancel()\n    activePlan = nil\n    RemovePreview()\n    previewReuseUnavailable = false\nend\n\nfunction CancelIfSourceSlot(slot, revision)\n    if not activePlan\n        or activePlan.sourceSlot ~= slot\n        or activePlan.sourceRevision ~= revision then\n        return false\n    end\n    Cancel()\n    return true\nend\n\nfunction OnMouseLeftDown()\n    return false\nend\n\nfunction OnMouseLeftUp(isAppendingToQueue)\n    if not MouseCursor.IsCursorInGameView() or Engine.IsMouseOverUI() then\n        return false\n    end\n\n    RemovePreview()\n    local plan = activePlan\n    if not plan then\n        return false\n    end\n    local entries, allValid = GetPlacementEntries()\n    local compatibleBuilders =\n        GetCompatibleBuilders(plan.entries, SelectionSystem.GetSelectedUnits())\n    local placeable = {}\n    for _, entry in ipairs(entries) do\n        if entry.valid then\n            table.insert(placeable, entry)\n        end\n    end\n    if #entries == 0\n        or #placeable == 0\n        or #compatibleBuilders == 0 then\n        Notify(\"placement is blocked or the selected builders are no longer compatible.\")\n        return false\n    end\n\n    local builderArmyId = compatibleBuilders[1].armyId\n    local shouldAppend = isAppendingToQueue == true\n    for _, entry in ipairs(placeable) do\n        CreatePrediction(\n            entry,\n            compatibleBuilders,\n            builderArmyId,\n            shouldAppend)\n        shouldAppend = true\n    end\n    if not allValid then\n        Notify(\"submitted \" .. #placeable .. \"/\" .. #entries\n            .. \" build orders; \" .. (#entries - #placeable) .. \" blocked.\")\n    end\n    if not isAppendingToQueue then\n        Cancel()\n    end\n    return false\nend\n\nfunction OnMouseRightDown()\n    return false\nend\n\nfunction OnMouseRightUp()\n    Cancel()\n    if MouseCursor.IsCursorInGameView() and not Engine.IsMouseOverUI() then\n        Notify(\"plan placement cancelled.\")\n    end\n    return false\nend\n\nlocal function CreatePreviewGhost(entry, visualOnly)\n    local template = __Templates.Units[entry.tpId]\n    local errorCode, ghostID = Engine.InstantiatePrefab(\n        template.general.placementGhostPrefabID,\n        entry.position,\n        EngineClasses.float3(1, 1, 1),\n        GetIdentityQuaternion())\n    if errorCode ~= EngineErrorCode.Success or not ghostID then\n        return nil\n    end\n    if visualOnly then\n        local disableCode = Engine.SetLocalGridModifierEnabled(ghostID, false)\n        local readCode, enabled = Engine.GetLocalGridModifierEnabled(ghostID)\n        if disableCode ~= EngineErrorCode.Success\n            or readCode ~= EngineErrorCode.Success or enabled then\n            Engine.DeletePrefabInstance(ghostID)\n            return nil\n        end\n    end\n    Engine.SetIconsEnabled(ghostID, false)\n    Engine.SetRangeRingsEnabled(ghostID, true)\n    SetGhostGrid(ghostID, template, entry.valid)\n    return {\n        id = ghostID,\n        valid = entry.valid,\n        x = entry.position.x,\n        y = entry.position.y,\n        z = entry.position.z,\n    }\nend\n\nlocal function DrawLegacyPreview(entries)\n    for _, entry in ipairs(entries) do\n        local ghost = CreatePreviewGhost(entry, false)\n        if ghost then\n            table.insert(planGhosts, ghost)\n        end\n    end\nend\n\nfunction UpdatePreview()\n    if not activePlan then\n        return\n    end\n\n    local anchor = MouseCursor.GetMousePosition()\n    anchor.x = math.truncateToInt(anchor.x)\n    anchor.z = math.truncateToInt(anchor.z)\n    if previewReuseUnavailable then\n        RemovePreview()\n        DrawLegacyPreview(GetPlacementEntries(anchor))\n        return\n    end\n\n    local now = Engine.GetCurrentRealtimeInSeconds()\n    local anchorChanged = anchor.x ~= previewAnchorX\n        or anchor.z ~= previewAnchorZ\n    if not anchorChanged and nextPreviewRefreshTime\n        and type(now) == \"number\"\n        and now == now\n        and now < nextPreviewRefreshTime then\n        return\n    end\n\n    -- Preview ghosts are visual only: their own grid modifiers must not\n    -- contaminate later occupancy checks while the prefabs are retained.\n    local entries = GetPlacementEntries(anchor)\n    for index, entry in ipairs(entries) do\n        local ghost = planGhosts[index]\n        if not ghost then\n            ghost = CreatePreviewGhost(entry, true)\n            if not ghost then\n                previewReuseUnavailable = true\n                RemovePreview()\n                DrawLegacyPreview(entries)\n                return\n            end\n            planGhosts[index] = ghost\n        else\n            if ghost.x ~= entry.position.x\n                or ghost.y ~= entry.position.y\n                or ghost.z ~= entry.position.z then\n                if Engine.SetLocalEntityLocalPosition(ghost.id, entry.position)\n                    ~= EngineErrorCode.Success then\n                    previewReuseUnavailable = true\n                    RemovePreview()\n                    DrawLegacyPreview(entries)\n                    return\n                end\n                ghost.x = entry.position.x\n                ghost.y = entry.position.y\n                ghost.z = entry.position.z\n            end\n            if ghost.valid ~= entry.valid then\n                SetGhostGrid(ghost.id, __Templates.Units[entry.tpId], entry.valid)\n                ghost.valid = entry.valid\n            end\n        end\n    end\n    previewAnchorX = anchor.x\n    previewAnchorZ = anchor.z\n    nextPreviewRefreshTime = type(now) == \"number\" and now == now\n        and now + PREVIEW_REFRESH_SECONDS or nil\nend\n\nreturn {\n    Begin = Begin,\n    Cancel = Cancel,\n    CancelIfSourceSlot = CancelIfSourceSlot,\n    CanBuildEntries = CanBuildEntries,\n    IsActive = IsActive,\n    OnMouseLeftDown = OnMouseLeftDown,\n    OnMouseLeftUp = OnMouseLeftUp,\n    OnMouseRightDown = OnMouseRightDown,\n    OnMouseRightUp = OnMouseRightUp,\n    UpdatePreview = UpdatePreview,\n}\n";
	}

	private static string UpgradePlacementModuleWaterParity(string source)
	{
		string text = NormalizeLineEndings(source);
		int num = CountOccurrences(text, "-- Sanctuary Construction Plans naval water placement 1.0.0");
		switch (num)
		{
		case 1:
			return text;
		default:
			throw new InvalidOperationException($"Expected zero or one Construction Plans naval-water markers, found {num}.");
		case 0:
		{
			RequireExactly(text, "local function IsClearArea(area)\n    local min = EngineClasses.int2(area.minX, area.minZ)\n    local max = EngineClasses.int2(area.maxX, area.maxZ)\n    local results = {}\n    local errorCode = Engine.GetLocalGridCellFlags(\n        _G.localBuildingPlacementGridID,\n        min,\n        max,\n        results)\n    if errorCode ~= EngineErrorCode.Success or #results == 0 then\n        return false\n    end\n    for _, result in ipairs(results) do\n        if result.flags ~= PlacementLayer.None then\n            return false\n        end\n    end\n    return true\nend\n\nlocal function RequiresWaterPlacement(template)\n    return template\n        and template.general\n        and template.general.requiresWaterPlacement == true\nend\n\nlocal function GetWaterLevel()\n    local hasWaterErrorCode, hasWater = Engine.HasWater()\n    if hasWaterErrorCode ~= EngineErrorCode.Success or not hasWater then\n        return nil\n    end\n    local waterLevelErrorCode, waterLevel = Engine.GetWaterLevel()\n    if waterLevelErrorCode ~= EngineErrorCode.Success then\n        return nil\n    end\n    return waterLevel\nend\n\nlocal function IsSubmergedCell(cell, waterLevel)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeightFromCell(cell)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight < waterLevel - 0.05\nend\n\nlocal function IsSubmergedPoint(position, waterLevel)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight < waterLevel - 0.05\nend\n\nlocal function CanPlaceWaterFactory(template, position)\n    if not RequiresWaterPlacement(template) then\n        return true\n    end\n\n    local waterLevel = GetWaterLevel()\n    if not waterLevel then\n        return false\n    end\n    local minX, minZ, maxX, maxZ =\n        PlacementUtils.GetPlacementBounds(position, template.skirtSize)\n    for x = minX, maxX do\n        for z = minZ, maxZ do\n            if not IsSubmergedCell(\n                EngineClasses.int2(x, z),\n                waterLevel) then\n                return false\n            end\n        end\n    end\n\n    local rollOffPoints =\n        (template.construction and template.construction.rollOffPoints) or {}\n    if not IsDenseArray(rollOffPoints, 16) then\n        return false\n    end\n    for _, rollOff in ipairs(rollOffPoints) do\n        local offset = type(rollOff) == \"table\" and rollOff.offset or nil\n        if type(offset) ~= \"table\"\n            or not IsFiniteNumber(offset.x, 128)\n            or not IsFiniteNumber(offset.z, 128) then\n            return false\n        end\n        local spawnPoint = EngineClasses.float3(\n            position.x + offset.x,\n            waterLevel,\n            position.z + offset.z)\n        local rallyPoint = EngineClasses.float3(\n            position.x + offset.x * 2,\n            waterLevel,\n            position.z + offset.z * 2)\n        if IsSubmergedPoint(spawnPoint, waterLevel)\n            and IsSubmergedPoint(rallyPoint, waterLevel) then\n            return true\n        end\n    end\n    return false\nend\n", 1, "legacy Construction Plans water block");
			string text2 = text.Replace("local function IsClearArea(area)\n    local min = EngineClasses.int2(area.minX, area.minZ)\n    local max = EngineClasses.int2(area.maxX, area.maxZ)\n    local results = {}\n    local errorCode = Engine.GetLocalGridCellFlags(\n        _G.localBuildingPlacementGridID,\n        min,\n        max,\n        results)\n    if errorCode ~= EngineErrorCode.Success or #results == 0 then\n        return false\n    end\n    for _, result in ipairs(results) do\n        if result.flags ~= PlacementLayer.None then\n            return false\n        end\n    end\n    return true\nend\n\nlocal function RequiresWaterPlacement(template)\n    return template\n        and template.general\n        and template.general.requiresWaterPlacement == true\nend\n\nlocal function GetWaterLevel()\n    local hasWaterErrorCode, hasWater = Engine.HasWater()\n    if hasWaterErrorCode ~= EngineErrorCode.Success or not hasWater then\n        return nil\n    end\n    local waterLevelErrorCode, waterLevel = Engine.GetWaterLevel()\n    if waterLevelErrorCode ~= EngineErrorCode.Success then\n        return nil\n    end\n    return waterLevel\nend\n\nlocal function IsSubmergedCell(cell, waterLevel)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeightFromCell(cell)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight < waterLevel - 0.05\nend\n\nlocal function IsSubmergedPoint(position, waterLevel)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight < waterLevel - 0.05\nend\n\nlocal function CanPlaceWaterFactory(template, position)\n    if not RequiresWaterPlacement(template) then\n        return true\n    end\n\n    local waterLevel = GetWaterLevel()\n    if not waterLevel then\n        return false\n    end\n    local minX, minZ, maxX, maxZ =\n        PlacementUtils.GetPlacementBounds(position, template.skirtSize)\n    for x = minX, maxX do\n        for z = minZ, maxZ do\n            if not IsSubmergedCell(\n                EngineClasses.int2(x, z),\n                waterLevel) then\n                return false\n            end\n        end\n    end\n\n    local rollOffPoints =\n        (template.construction and template.construction.rollOffPoints) or {}\n    if not IsDenseArray(rollOffPoints, 16) then\n        return false\n    end\n    for _, rollOff in ipairs(rollOffPoints) do\n        local offset = type(rollOff) == \"table\" and rollOff.offset or nil\n        if type(offset) ~= \"table\"\n            or not IsFiniteNumber(offset.x, 128)\n            or not IsFiniteNumber(offset.z, 128) then\n            return false\n        end\n        local spawnPoint = EngineClasses.float3(\n            position.x + offset.x,\n            waterLevel,\n            position.z + offset.z)\n        local rallyPoint = EngineClasses.float3(\n            position.x + offset.x * 2,\n            waterLevel,\n            position.z + offset.z * 2)\n        if IsSubmergedPoint(spawnPoint, waterLevel)\n            and IsSubmergedPoint(rallyPoint, waterLevel) then\n            return true\n        end\n    end\n    return false\nend\n", "-- Sanctuary Construction Plans naval water placement 1.0.0\nlocal function RequiresWaterPlacement(template)\n    return template\n        and template.general\n        and template.general.requiresWaterPlacement == true\nend\n\nlocal function GetMinimumWaterDepth(template)\n    local additions = template and template.additions\n    local faContract = additions and additions.faSourceContract\n    local authored = faContract and faContract.minimumWaterDepth\n    if type(authored) == \"number\" and authored >= 0 then\n        return authored\n    end\n    return 1.5\nend\n\nlocal function IsClearArea(area, template)\n    local min = EngineClasses.int2(area.minX, area.minZ)\n    local max = EngineClasses.int2(area.maxX, area.maxZ)\n    local results = {}\n    local errorCode = Engine.GetLocalGridCellFlags(\n        _G.localBuildingPlacementGridID,\n        min,\n        max,\n        results)\n    local expectedCells =\n        (area.maxX - area.minX + 1) * (area.maxZ - area.minZ + 1)\n    if errorCode ~= EngineErrorCode.Success or #results ~= expectedCells then\n        return false\n    end\n    local expectedFlags = RequiresWaterPlacement(template)\n        and PlacementLayer.Water or PlacementLayer.None\n    for _, result in ipairs(results) do\n        if result.flags ~= expectedFlags then\n            return false\n        end\n    end\n    return true\nend\n\nlocal function GetWaterLevel()\n    local hasWaterErrorCode, hasWater = Engine.HasWater()\n    if hasWaterErrorCode ~= EngineErrorCode.Success or not hasWater then\n        return nil\n    end\n    local waterLevelErrorCode, waterLevel = Engine.GetWaterLevel()\n    if waterLevelErrorCode ~= EngineErrorCode.Success then\n        return nil\n    end\n    return waterLevel\nend\n\nlocal function IsSubmergedCell(cell, waterLevel, minimumDepth)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeightFromCell(cell)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend\n\nlocal function IsSubmergedPoint(position, waterLevel, minimumDepth)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend\n\nlocal function CanPlaceWaterFactory(template, position)\n    if not RequiresWaterPlacement(template) then\n        return true\n    end\n\n    local waterLevel = GetWaterLevel()\n    local minimumDepth = GetMinimumWaterDepth(template)\n    if not waterLevel or minimumDepth == nil then\n        return false\n    end\n    local minX, minZ, maxX, maxZ =\n        PlacementUtils.GetPlacementBounds(position, template.skirtSize)\n    for x = minX, maxX do\n        for z = minZ, maxZ do\n            if not IsSubmergedCell(\n                EngineClasses.int2(x, z),\n                waterLevel,\n                minimumDepth) then\n                return false\n            end\n        end\n    end\n\n    local construction = template.construction\n    local additions = template.additions\n    local routes = construction and construction.rollOffPoints\n    local ramps = additions and additions.rollOffRamps\n    if routes and (not IsDenseArray(routes, 2) or #routes ~= 2) then\n        return false\n    end\n    if ramps and (not IsDenseArray(ramps, 2) or #ramps ~= 2) then\n        return false\n    end\n    if not routes and not ramps then\n        return false\n    end\n    for index = 1, 2 do\n        local route = routes and routes[index]\n        local ramp = ramps and ramps[index]\n        local routeOffset = route and route.offset or ramp and ramp.rampOffset\n        local exitOffset = ramp and ramp.clearanceOffset\n            or routeOffset and {\n                x = (routeOffset.x or 0) * ((route and route.exitScale) or 2),\n                z = (routeOffset.z or 0) * ((route and route.exitScale) or 2),\n            }\n        if type(routeOffset) == \"table\"\n            and type(exitOffset) == \"table\"\n            and IsFiniteNumber(routeOffset.x or 0, 128)\n            and IsFiniteNumber(routeOffset.z or 0, 128)\n            and IsFiniteNumber(exitOffset.x or 0, 256)\n            and IsFiniteNumber(exitOffset.z or 0, 256) then\n            local routePoint = EngineClasses.float3(\n                position.x + (routeOffset.x or 0),\n                waterLevel,\n                position.z + (routeOffset.z or 0))\n            local exitPoint = EngineClasses.float3(\n                position.x + (exitOffset.x or 0),\n                waterLevel,\n                position.z + (exitOffset.z or 0))\n            if IsSubmergedPoint(routePoint, waterLevel, minimumDepth)\n                and IsSubmergedPoint(exitPoint, waterLevel, minimumDepth) then\n                return true\n            end\n        end\n    end\n    return false\nend\n");
			RequireExactly(text2, "IsClearArea(area)", 1, "legacy Construction Plans clear-area call");
			return text2.Replace("IsClearArea(area)", "IsClearArea(area, template)");
		}
		}
	}

	private static string AppendMarker(string source)
	{
		return "\n-- Sanctuary Construction Plans 2.1.0\n" + source.Trim() + "\n";
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
			if (mutation2.Stock != null)
			{
				TryDisposeNativeArray(mutation2.Stock.GetType(), mutation2.Stock, "stock " + mutation2.Description);
			}
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
					if (item.Added)
					{
						RemoveCachedResource(cache, item.Path);
					}
					else
					{
						SetCachedResource(cache, item.Path, item.Stock ?? throw new InvalidOperationException(item.Description + " has no stock cache resource."));
					}
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

	private static void DisposeUncommitted(IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			TryDisposeNativeArray(mutation.Replacement.GetType(), mutation.Replacement, "uncommitted " + mutation.Description);
		}
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CacheResource GetCachedResource(object cache, string relativePath, string description)
	{
		return TryGetCachedResource(cache, relativePath, description) ?? throw new FileNotFoundException("The required " + description + " was not present in Sanctuary's Lua file cache.", relativePath);
	}

	private static CacheResource? TryGetCachedResource(object cache, string relativePath, string description)
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
		return cacheResource;
	}

	private static Type GetNativeArrayType(object cache)
	{
		foreach (object item in (IEnumerable)cache)
		{
			object obj = item.GetType().GetProperty("Value")?.GetValue(item);
			if (obj != null)
			{
				EnsureNativeArray(obj, "Lua cache resource");
				return obj.GetType();
			}
		}
		throw new InvalidOperationException("Sanctuary's Lua file cache contains no NativeArray resource type.");
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

	private static void RemoveCachedResource(object cache, string path)
	{
		(cache.GetType().GetMethod("Remove", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "Remove")).Invoke(cache, new object[1] { path });
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

	private static string AppendOverride(string source, string appendix)
	{
		if (!source.EndsWith("\n", StringComparison.Ordinal))
		{
			return source + "\n" + appendix;
		}
		return source + appendix;
	}

	private static string InsertBeforeExactlyOnce(string source, string anchor, string appendix, string description)
	{
		int num = source.IndexOf(anchor, StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Expected " + description + " to contain its final return anchor.");
		}
		if (source.IndexOf(anchor, num + anchor.Length, StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("Expected exactly one final return anchor in " + description + ".");
		}
		return source.Substring(0, num) + appendix + source.Substring(num);
	}

	private static string NormalizeLineEndings(string source)
	{
		return source.Replace("\r\n", "\n").Replace("\r", "\n");
	}

	private static bool ContainsMarker(string source)
	{
		return source.IndexOf("-- Sanctuary Construction Plans 2.1.0", StringComparison.Ordinal) >= 0;
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
				throw new InvalidOperationException("Construction Plans must not contain '" + text + "'.");
			}
		}
	}

	private static int CountOccurrences(string source, string token)
	{
		if (token.Length == 0)
		{
			throw new ArgumentException("Token cannot be empty.", "token");
		}
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
		int num = CountOccurrences(source, token);
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {description}, found {num}.");
		}
	}

	private static void Log(string message)
	{
		string text = "[Sanctuary Construction Plans Cache Patcher] " + message;
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
