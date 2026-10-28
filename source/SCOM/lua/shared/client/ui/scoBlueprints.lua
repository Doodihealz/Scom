-- Sanctuary Construction Plans 2.1.0
-- Persistent, client-owned construction layouts. Placement still
-- emits only Sanctuary's stock host-authoritative BUILD orders.
local MAX_SLOTS = 8
local DEFAULT_SLOT = 1
local MAX_ENTRIES = 20
local MAX_OFFSET = 8192
local SCHEMA_VERSION = 2
local LEGACY_SCHEMA_VERSION = 1
local PlacementUtils = Import("common/systems/placementUtils.lua")
local TempBuildMode = Import("client/input/buildmodeTemp.lua")
local slots = {}
local plansLoadState = "unloaded"
local nextPlanRevision = 1
local blueprintPanelActive = false
local ShowBrowser
local ShowPlanActions
local ShowDeleteConfirmation
local ShowOverwriteConfirmation
local EnsurePlansLoaded

local function Notify(text)
    Engine.UI_AddLogText("Construction Plans: " .. text, 5)
end

local function IsFiniteInteger(value, maximumMagnitude)
    return type(value) == "number"
        and value == value
        and math.abs(value) <= maximumMagnitude
        and value == math.floor(value)
end

local function IsFiniteCoordinate(value, maximumMagnitude)
    return type(value) == "number"
        and value == value
        and math.abs(value) <= maximumMagnitude
end

local function IsDenseArray(value, maximumLength)
    if type(value) ~= "table" or #value > maximumLength then
        return false
    end

    local count = 0
    for key in pairs(value) do
        if type(key) ~= "number"
            or key ~= math.floor(key)
            or key < 1
            or key > #value then
            return false
        end
        count = count + 1
    end
    return count == #value
end

local function IsSlot(slot)
    return IsFiniteInteger(slot, MAX_SLOTS)
        and slot >= 1
        and slot <= MAX_SLOTS
end

local function GetTemplateId(unit)
    if not unit or not unit.tp or not unit.tp.general then
        return nil
    end
    return unit.tp.general.tpId
end

local function IsEligibleTemplateId(tpId)
    if type(tpId) ~= "string"
        or #tpId == 0
        or #tpId > 64
        or not string.match(tpId, "^[%w_%-]+$") then
        return false
    end

    local template = __Templates.Units[tpId]
    local skirt = template and template.skirtSize
    return template
        and template.general
        and skirt
        and IsFiniteInteger(skirt.x, 128)
        and IsFiniteInteger(skirt.y, 128)
        and skirt.x > 0
        and skirt.y > 0
        and Tags.STRUCTURE[tpId]
        and not Tags.ALLOYS_EXTRACTION[tpId]
end

local function IsCaptureCandidate(unit)
    local tpId = GetTemplateId(unit)
    return unit
        and unit.entityType == "unit"
        and IsEligibleTemplateId(tpId)
        and unit.armyId == GetFocusArmy()
        and unit.IsCompleted
        and unit:IsCompleted()
end

local function HasIdentityBuildOrientation(unit)
    if not unit or type(unit.GetSimOrientation) ~= "function" then
        return false
    end
    local orientation = unit:GetSimOrientation()
    local value = orientation and orientation.value
    if type(value) ~= "table"
        or not IsFiniteCoordinate(value.x, 2)
        or not IsFiniteCoordinate(value.y, 2)
        or not IsFiniteCoordinate(value.z, 2)
        or not IsFiniteCoordinate(value.w, 2) then
        return false
    end

    -- Sanctuary's BUILD payload has no rotation field and the
    -- host creates structures at identity. Refuse rotated source
    -- structures instead of silently producing a different copy.
    local vectorSquared = value.x * value.x
        + value.y * value.y
        + value.z * value.z
    return vectorSquared <= 0.00000001
        and math.abs(math.abs(value.w) - 1) <= 0.0001
end

local function AddArea(areas, position, size)
    if type(size) ~= "table"
        or not IsFiniteInteger(size.x, 128)
        or not IsFiniteInteger(size.y, 128)
        or size.x <= 0
        or size.y <= 0 then
        return false
    end

    local minX, minZ, maxX, maxZ =
        PlacementUtils.GetPlacementBounds(position, size)
    table.insert(areas, {
        minX = minX,
        minZ = minZ,
        maxX = maxX,
        maxZ = maxZ,
    })
    return true
end

local function GetEntryAreas(entry)
    if type(entry) ~= "table"
        or not IsEligibleTemplateId(entry.tpId)
        or not IsFiniteCoordinate(entry.dx, MAX_OFFSET)
        or not IsFiniteCoordinate(entry.dz, MAX_OFFSET) then
        return nil
    end

    local template = __Templates.Units[entry.tpId]
    local areas = {}
    local position = { x = entry.dx, z = entry.dz }
    if not AddArea(areas, position, template.skirtSize) then
        return nil
    end

    local additions = template.additions
    local reservations = additions and additions.placementReservations or {}
    if not IsDenseArray(reservations, 16) then
        return nil
    end
    for _, reservation in ipairs(reservations) do
        if type(reservation) ~= "table" then
            return nil
        end
        local offset = reservation.offset or {}
        if type(offset) ~= "table"
            or not IsFiniteInteger(offset.x or 0, 128)
            or not IsFiniteInteger(offset.z or 0, 128)
            or not AddArea(
                areas,
                {
                    x = entry.dx + (offset.x or 0),
                    z = entry.dz + (offset.z or 0),
                },
                reservation.size) then
            return nil
        end
    end
    return areas
end

local function AreasOverlap(first, second)
    return first.minX <= second.maxX
        and second.minX <= first.maxX
        and first.minZ <= second.maxZ
        and second.minZ <= first.maxZ
end

local function ValidateEntries(entries)
    if not IsDenseArray(entries, MAX_ENTRIES)
        or #entries == 0 then
        return false
    end

    local areasByEntry = {}
    for index, entry in ipairs(entries) do
        local areas = GetEntryAreas(entry)
        if not areas then
            return false
        end
        areasByEntry[index] = areas
    end

    for firstIndex = 1, #areasByEntry do
        for secondIndex = firstIndex + 1, #areasByEntry do
            for _, firstArea in ipairs(areasByEntry[firstIndex]) do
                for _, secondArea in ipairs(areasByEntry[secondIndex]) do
                    if AreasOverlap(firstArea, secondArea) then
                        return false
                    end
                end
            end
        end
    end
    return true
end

local function CaptureEntries(units)
    local captured = {}
    for _, unit in pairs(units or {}) do
        if not IsCaptureCandidate(unit) then
            return nil
        end

        if not HasIdentityBuildOrientation(unit) then
            return nil
        end

        -- Capture the authoritative simulation center. Rendering
        -- positions can be interpolated, and truncating either
        -- coordinate destroys mixed whole/half-cell spacing.
        local position = unit:GetSimPosition()
        if not position
            or not IsFiniteCoordinate(position.x, MAX_OFFSET)
            or not IsFiniteCoordinate(position.z, MAX_OFFSET) then
            return nil
        end
        table.insert(captured, {
            tpId = GetTemplateId(unit),
            x = position.x,
            z = position.z,
        })
        if #captured > MAX_ENTRIES then
            return nil
        end
    end

    if #captured == 0 then
        return nil
    end

    table.sort(captured, function(a, b)
        if a.x ~= b.x then return a.x < b.x end
        if a.z ~= b.z then return a.z < b.z end
        return a.tpId < b.tpId
    end)

    local minX = captured[1].x
    local minZ = captured[1].z
    for _, entry in ipairs(captured) do
        minX = math.min(minX, entry.x)
        minZ = math.min(minZ, entry.z)
    end

    -- Keep the layout's phase within the placement grid. Using
    -- the raw minimum as origin would preserve pairwise distance
    -- but silently move every fractional center onto a new phase.
    local originX = math.floor(minX)
    local originZ = math.floor(minZ)

    local entries = {}
    for _, entry in ipairs(captured) do
        table.insert(entries, {
            tpId = entry.tpId,
            dx = entry.x - originX,
            dz = entry.z - originZ,
        })
    end
    return ValidateEntries(entries) and entries or nil
end

local function IsStoredPlan(plan)
    return type(plan) == "table"
        and type(plan.iconTpId) == "string"
        and IsFiniteInteger(plan.revision, 2147483647)
        and plan.revision > 0
        and ValidateEntries(plan.entries)
        and plan.iconTpId == plan.entries[1].tpId
end

local function TakeNextRevision()
    local revision = nextPlanRevision
    nextPlanRevision = nextPlanRevision + 1
    return revision
end

local function CopyPlan(plan)
    if not IsStoredPlan(plan) then
        return nil
    end

    local entries = {}
    for _, entry in ipairs(plan.entries) do
        table.insert(entries, {
            tpId = entry.tpId,
            dx = entry.dx,
            dz = entry.dz,
        })
    end
    return {
        iconTpId = entries[1].tpId,
        entries = entries,
    }
end

local function CloneSlots()
    local cloned = {}
    for slot = 1, MAX_SLOTS do
        local plan = slots[slot]
        if plan then
            local copy = CopyPlan(plan)
            if not copy then
                return nil
            end
            copy.revision = plan.revision
            cloned[slot] = copy
        end
    end
    return cloned
end

local function PersistCandidate(candidate)
    local envelope = {
        schemaVersion = SCHEMA_VERSION,
        slots = {},
    }
    for slot = 1, MAX_SLOTS do
        local plan = candidate[slot]
        if plan then
            if not IsStoredPlan(plan) then
                Notify("the plan set is invalid; no changes were saved.")
                return false
            end
            table.insert(envelope.slots, {
                slot = slot,
                entries = CopyPlan(plan).entries,
            })
        end
    end

    local encodedOk, encoded = pcall(json.encode, envelope)
    if not encodedOk or type(encoded) ~= "string" then
        Notify("the plan set could not be encoded; no changes were saved.")
        return false
    end

    local save = _G.SCO_SaveConstructionPlansJson
    if type(save) ~= "function" then
        Notify("persistent storage is unavailable; no changes were made.")
        return false
    end
    local callOk, saved, errorText = pcall(save, encoded)
    if not callOk or not saved then
        Notify(tostring(errorText or saved or "save failed") .. " No changes were made.")
        return false
    end
    return true
end

local function DecodePersistedPlans(document)
    local decodeOk, envelope = pcall(json.decode, document)
    if not decodeOk
        or type(envelope) ~= "table"
        or not IsDenseArray(envelope.slots, MAX_SLOTS) then
        return nil, "invalid"
    end
    if envelope.schemaVersion == LEGACY_SCHEMA_VERSION then
        -- Version 1 discarded fractional grid phase and stored no
        -- orientation provenance. It cannot be promoted to an
        -- exact plan without recapturing the source structures.
        return nil, "legacy"
    end
    if envelope.schemaVersion ~= SCHEMA_VERSION then
        return nil, "invalid"
    end

    local loaded = {}
    for _, record in ipairs(envelope.slots) do
        if type(record) ~= "table"
            or not IsSlot(record.slot)
            or loaded[record.slot]
            or not ValidateEntries(record.entries) then
            return nil, "invalid"
        end

        local entries = {}
        for _, entry in ipairs(record.entries) do
            table.insert(entries, {
                tpId = entry.tpId,
                dx = entry.dx,
                dz = entry.dz,
            })
        end
        loaded[record.slot] = {
            iconTpId = entries[1].tpId,
            revision = TakeNextRevision(),
            entries = entries,
        }
    end
    return loaded, nil
end

EnsurePlansLoaded = function()
    if plansLoadState == "loaded" then
        return true
    end
    if plansLoadState == "failed" or plansLoadState == "loading" then
        return false
    end
    plansLoadState = "loading"

    local load = _G.SCO_LoadConstructionPlansJson
    if type(load) ~= "function" then
        plansLoadState = "failed"
        Notify("persistent storage is unavailable; plans could not be loaded.")
        return false
    end

    local callOk, document, errorText = pcall(load)
    if not callOk then
        plansLoadState = "failed"
        Notify("saved plans could not be loaded.")
        return false
    end
    if document == nil then
        if errorText then
            plansLoadState = "failed"
            Notify(tostring(errorText))
            return false
        end
        plansLoadState = "loaded"
        return true
    end
    if type(document) ~= "string" then
        plansLoadState = "failed"
        Notify("the saved plan file is invalid and was ignored.")
        return false
    end

    local loaded, loadError = DecodePersistedPlans(document)
    if loadError == "legacy" then
        slots = {}
        plansLoadState = "loaded"
        return true
    end
    if not loaded then
        plansLoadState = "failed"
        Notify("the saved plan file is invalid or outdated and was ignored.")
        return false
    end
    slots = loaded
    plansLoadState = "loaded"
    return true
end

local function RequireWritablePlans()
    if EnsurePlansLoaded() then
        return true
    end
    Notify("saved plans are locked to protect the existing file; restart after correcting storage.")
    return false
end

local function GetStoredPlan(slot)
    EnsurePlansLoaded()
    if not IsSlot(slot) then
        return nil
    end

    local plan = slots[slot]
    if plan and not IsStoredPlan(plan) then
        slots[slot] = nil
        return nil
    end
    return plan
end

local function GetCurrentPlan(slot, revision)
    local plan = GetStoredPlan(slot)
    if not plan or plan.revision ~= revision then
        return nil
    end
    return plan
end

local function GetCurrentSelectedUnits()
    return Import("client/input/selectionSystem.lua").GetSelectedUnits() or {}
end

local function CancelPlacementForPlan(slot, revision)
    local Placement = Import("client/input/scoBlueprintPlacement.lua")
    local succeeded = pcall(Placement.CancelIfSourceSlot, slot, revision)
    if not succeeded then
        pcall(Placement.Cancel)
    end
end

local function FindFirstFreeSlot()
    for slot = DEFAULT_SLOT, MAX_SLOTS do
        if not GetStoredPlan(slot) then
            return slot
        end
    end
    return nil
end

local function CountSavedPlans()
    local count = 0
    for slot = 1, MAX_SLOTS do
        if GetStoredPlan(slot) then
            count = count + 1
        end
    end
    return count
end

local function GetPlanTitle(slot, plan)
    return "Plan " .. slot .. " (" .. #plan.entries .. " structures)"
end

local function SetTooltip(button, title, description)
    Engine.UI_SetButtonTooltip(button.buttonID, title, description)
end

local function ButtonData(text, plan, fallbackTpId)
    local iconTpId = plan and plan.iconTpId or fallbackTpId
    local template = iconTpId and __Templates.Units[iconTpId] or nil
    return {
        text = text,
        foreground = template and template.general.foregroundIconID or { index = 0 },
        background = template and template.general.backgroundIconID or { index = 0 },
        frame = { index = 0 },
        icon = template and template.general.strategicIconID or { index = 0 },
        iconGlowColor = template and template.general.strategicIconGlowColor
            or EngineClasses.float3(0, 0, 0),
        emitClickEvents = true,
        emitHoverEvents = false,
    }
end

local function MarkBlueprintFilterActive(panel, activeButton)
    for _, button in pairs(panel.constructionFilteringButtons.buttons) do
        button:SetActive(button.buttonID.id == activeButton.buttonID.id)
    end
end

function CanCaptureSelection(units)
    return CaptureEntries(units) ~= nil
end

function CaptureIntoSlot(slot, units, expectedRevision, requireEmpty)
    if not RequireWritablePlans() then
        return false
    end
    if not IsSlot(slot) then
        return false
    end

    local previousPlan = GetStoredPlan(slot)
    if requireEmpty and previousPlan then
        Notify("Plan " .. tostring(slot) .. " changed; choose the slot again.")
        return false
    end
    if expectedRevision ~= nil
        and (not previousPlan or previousPlan.revision ~= expectedRevision) then
        Notify("Plan " .. tostring(slot) .. " changed; reopen its confirmation.")
        return false
    end

    local entries = CaptureEntries(units)
    if not entries then
        Notify("select 1-20 non-overlapping completed friendly unrotated structures; extractors are excluded.")
        return false
    end

    local candidate = CloneSlots()
    if not candidate then
        Notify("the current plan set is invalid; no changes were made.")
        return false
    end
    candidate[slot] = {
        iconTpId = entries[1].tpId,
        revision = TakeNextRevision(),
        entries = entries,
    }
    if not PersistCandidate(candidate) then
        return false
    end

    slots = candidate
    if previousPlan then
        CancelPlacementForPlan(slot, previousPlan.revision)
    end
    Notify(
        GetPlanTitle(slot, slots[slot])
            .. (previousPlan and " replaced. " or " saved. ")
            .. "Select builders, then click BP > P"
            .. slot
            .. " or press Alt+"
            .. slot
            .. " to place it.")
    return true
end

function CaptureDefaultPlan(units)
    local slot = FindFirstFreeSlot()
    if not slot then
        Notify("all 8 plan slots are occupied; delete a plan before saving.")
        return false
    end
    return CaptureIntoSlot(slot, units, nil, true)
end

function DuplicatePlan(slot, revision)
    if not RequireWritablePlans() then
        return false
    end
    local plan = GetCurrentPlan(slot, revision)
    if not plan then
        Notify("Plan " .. tostring(slot) .. " changed; reopen its action menu.")
        return false
    end

    local targetSlot = FindFirstFreeSlot()
    if not targetSlot then
        Notify("all 8 plan slots are occupied; delete a plan before copying.")
        return false
    end

    local candidate = CloneSlots()
    local copied = CopyPlan(plan)
    if not candidate or not copied then
        Notify("Plan " .. tostring(slot) .. " is invalid and cannot be copied.")
        return false
    end
    copied.revision = TakeNextRevision()
    candidate[targetSlot] = copied
    if not PersistCandidate(candidate) then
        return false
    end
    slots = candidate
    Notify(GetPlanTitle(slot, plan) .. " copied to Plan " .. targetSlot .. ".")
    return true
end

function DeletePlan(slot, revision)
    if not RequireWritablePlans() then
        return false
    end
    local plan = GetCurrentPlan(slot, revision)
    if not plan then
        Notify("Plan " .. tostring(slot) .. " changed; reopen its action menu.")
        return false
    end

    local candidate = CloneSlots()
    if not candidate then
        Notify("the current plan set is invalid; no changes were made.")
        return false
    end
    candidate[slot] = nil
    if not PersistCandidate(candidate) then
        return false
    end

    slots = candidate
    CancelPlacementForPlan(slot, plan.revision)
    Notify("Plan " .. slot .. " deleted.")
    return true
end

function IsPlanBuildable(plan, units)
    if not IsStoredPlan(plan) then
        return false
    end
    return Import("client/input/scoBlueprintPlacement.lua").CanBuildEntries(
        plan.entries,
        units or {})
end

local function BeginPlan(slot, plan, selectedUnits)
    local Placement = Import("client/input/scoBlueprintPlacement.lua")
    if not Placement.Begin(plan, selectedUnits, slot, plan.revision) then
        Notify("select builders that can each construct every part of " .. GetPlanTitle(slot, plan) .. ".")
        return false
    end

    blueprintPanelActive = false
    Import("client/ui/uiManager.lua").SetUIDirty()
    return true
end

function ActivatePlanSlot(slot, selectedUnits)
    EnsurePlansLoaded()
    local plan = GetStoredPlan(slot)
    if not plan then
        Notify("Plan " .. tostring(slot) .. " is empty.")
        return false
    end
    selectedUnits = selectedUnits or GetCurrentSelectedUnits()
    if not IsPlanBuildable(plan, selectedUnits) then
        Notify("select compatible engineers or a commander before placing Plan " .. slot .. ".")
        return false
    end
    return BeginPlan(slot, plan, selectedUnits)
end

local function ShowCaptureDeck(panel, units)
    EnsurePlansLoaded()
    units = GetCurrentSelectedUnits()
    local captureEntries = CaptureEntries(units)
    local captureIconTpId = captureEntries and captureEntries[1].tpId or nil
    blueprintPanelActive = true
    panel.hoveredTemplate = nil
    panel.constructionButtons:ClearButtons()
    for slot = 1, MAX_SLOTS do
        local plan = GetStoredPlan(slot)
        local payload = {
            panel = panel,
            slot = slot,
            revision = plan and plan.revision or nil,
            hasPlan = plan ~= nil,
        }
        local button = panel.constructionButtons:AddButton(
            ButtonData(plan and ("P" .. slot) or ("+P" .. slot), plan, captureIconTpId),
            function(_, clickPayload)
                if clickPayload.hasPlan then
                    ShowPlanActions(
                        clickPayload.panel,
                        GetCurrentSelectedUnits(),
                        clickPayload.slot,
                        clickPayload.revision)
                elseif CaptureIntoSlot(
                    clickPayload.slot,
                    GetCurrentSelectedUnits(),
                    nil,
                    true) then
                    ShowCaptureDeck(clickPayload.panel, GetCurrentSelectedUnits())
                end
            end,
            function(_, clickPayload)
                if clickPayload.hasPlan then
                    ShowOverwriteConfirmation(
                        clickPayload.panel,
                        GetCurrentSelectedUnits(),
                        clickPayload.slot,
                        clickPayload.revision)
                end
            end,
            nil,
            nil,
            payload)
        local description = plan
            and ("Left-click opens actions for " .. GetPlanTitle(slot, plan)
                .. "; right-click replaces it with the selected layout.")
            or "Save the selected layout in this empty slot."
        SetTooltip(button, plan and GetPlanTitle(slot, plan) or ("Save Plan " .. slot), description)
    end
    panel:SetConstructionEnabled(true)
end

ShowOverwriteConfirmation = function(panel, units, slot, revision)
    units = GetCurrentSelectedUnits()
    local plan = GetCurrentPlan(slot, revision)
    if not plan then
        Notify("Plan " .. tostring(slot) .. " changed; reopen the capture deck.")
        ShowCaptureDeck(panel, units)
        return
    end

    blueprintPanelActive = true
    panel.hoveredTemplate = nil
    panel.constructionButtons:ClearButtons()

    local replacePayload = { panel = panel, slot = slot, revision = revision }
    local replaceButton = panel.constructionButtons:AddButton(
        ButtonData("YES", plan),
        function(_, clickPayload)
            CaptureIntoSlot(
                clickPayload.slot,
                GetCurrentSelectedUnits(),
                clickPayload.revision,
                false)
            ShowCaptureDeck(clickPayload.panel, GetCurrentSelectedUnits())
        end,
        nil,
        nil,
        nil,
        replacePayload)
    SetTooltip(
        replaceButton,
        "Replace " .. GetPlanTitle(slot, plan),
        "Save the selected structures over this plan.")

    local cancelButton = panel.constructionButtons:AddButton(
        ButtonData("NO", plan),
        function(_, clickPayload)
            ShowCaptureDeck(clickPayload.panel, GetCurrentSelectedUnits())
        end,
        nil,
        nil,
        nil,
        { panel = panel })
    SetTooltip(cancelButton, "Keep Plan", "Return without replacing the plan.")
    panel:SetConstructionEnabled(true)
end

ShowDeleteConfirmation = function(panel, units, slot, revision)
    units = GetCurrentSelectedUnits()
    local plan = GetCurrentPlan(slot, revision)
    if not plan then
        Notify("Plan " .. tostring(slot) .. " changed; reopen its action menu.")
        ShowBrowser(panel, units)
        return
    end

    blueprintPanelActive = true
    panel.hoveredTemplate = nil
    panel.constructionButtons:ClearButtons()

    local deletePayload = { panel = panel, slot = slot, revision = revision }
    local deleteButton = panel.constructionButtons:AddButton(
        ButtonData("DEL", plan),
        function(_, clickPayload)
            DeletePlan(clickPayload.slot, clickPayload.revision)
            ShowBrowser(clickPayload.panel, GetCurrentSelectedUnits())
        end,
        nil,
        nil,
        nil,
        deletePayload)
    SetTooltip(
        deleteButton,
        "Delete " .. GetPlanTitle(slot, plan),
        "Permanently remove this saved plan.")

    local keepPayload = { panel = panel, slot = slot, revision = revision }
    local keepButton = panel.constructionButtons:AddButton(
        ButtonData("KEEP", plan),
        function(_, clickPayload)
            ShowPlanActions(
                clickPayload.panel,
                GetCurrentSelectedUnits(),
                clickPayload.slot,
                clickPayload.revision)
        end,
        nil,
        nil,
        nil,
        keepPayload)
    SetTooltip(keepButton, "Keep Plan", "Return to this plan's actions.")
    panel:SetConstructionEnabled(true)
end

ShowPlanActions = function(panel, units, slot, revision)
    units = GetCurrentSelectedUnits()
    local plan = GetCurrentPlan(slot, revision)
    if not plan then
        Notify("Plan " .. tostring(slot) .. " changed; reopen the plan browser.")
        ShowBrowser(panel, units)
        return
    end

    Import("client/input/scoBlueprintPlacement.lua").Cancel()
    blueprintPanelActive = true
    panel.hoveredTemplate = nil
    panel.constructionButtons:ClearButtons()

    local placePayload = { panel = panel, slot = slot, revision = revision }
    local placeButton = panel.constructionButtons:AddButton(
        ButtonData("PLACE", plan),
        function(_, clickPayload)
            local currentPlan =
                GetCurrentPlan(clickPayload.slot, clickPayload.revision)
            if not currentPlan then
                Notify("Plan " .. tostring(clickPayload.slot) .. " changed.")
                ShowBrowser(clickPayload.panel, GetCurrentSelectedUnits())
            else
                ActivatePlanSlot(clickPayload.slot, GetCurrentSelectedUnits())
            end
        end,
        nil,
        nil,
        nil,
        placePayload)
    SetTooltip(
        placeButton,
        "Place " .. GetPlanTitle(slot, plan),
        "Start world placement with the currently selected compatible builders.")

    local copyPayload = { panel = panel, slot = slot, revision = revision }
    local copyButton = panel.constructionButtons:AddButton(
        ButtonData("COPY", plan),
        function(_, clickPayload)
            DuplicatePlan(clickPayload.slot, clickPayload.revision)
            ShowBrowser(clickPayload.panel, GetCurrentSelectedUnits())
        end,
        nil,
        nil,
        nil,
        copyPayload)
    SetTooltip(copyButton, "Copy " .. GetPlanTitle(slot, plan), "Copy this layout to the first empty slot.")

    local deletePayload = { panel = panel, slot = slot, revision = revision }
    local deleteButton = panel.constructionButtons:AddButton(
        ButtonData("DEL", plan),
        function(_, clickPayload)
            ShowDeleteConfirmation(
                clickPayload.panel,
                GetCurrentSelectedUnits(),
                clickPayload.slot,
                clickPayload.revision)
        end,
        nil,
        nil,
        nil,
        deletePayload)
    SetTooltip(deleteButton, "Delete Plan " .. slot, "Open the delete confirmation.")

    local backButton = panel.constructionButtons:AddButton(
        ButtonData("BACK", plan),
        function(_, clickPayload)
            ShowBrowser(clickPayload.panel, GetCurrentSelectedUnits())
        end,
        nil,
        nil,
        nil,
        { panel = panel })
    SetTooltip(backButton, "Back", "Return to all saved plans.")
    panel:SetConstructionEnabled(true)
end

ShowBrowser = function(panel, units)
    EnsurePlansLoaded()
    units = GetCurrentSelectedUnits()
    blueprintPanelActive = true
    panel.hoveredTemplate = nil
    panel.constructionButtons:ClearButtons()
    for slot = 1, MAX_SLOTS do
        local plan = GetStoredPlan(slot)
        if plan then
            local canBuild = IsPlanBuildable(plan, units)
            local payload = {
                panel = panel,
                slot = slot,
                revision = plan.revision,
            }
            local button = panel.constructionButtons:AddButton(
                ButtonData("P" .. slot, plan),
                function(_, clickPayload)
                    local currentPlan =
                        GetCurrentPlan(clickPayload.slot, clickPayload.revision)
                    if not currentPlan then
                        Notify("Plan " .. tostring(clickPayload.slot) .. " changed.")
                        ShowBrowser(clickPayload.panel, GetCurrentSelectedUnits())
                    else
                        ActivatePlanSlot(
                            clickPayload.slot,
                            GetCurrentSelectedUnits())
                    end
                end,
                function(_, clickPayload)
                    ShowPlanActions(
                        clickPayload.panel,
                        GetCurrentSelectedUnits(),
                        clickPayload.slot,
                        clickPayload.revision)
                end,
                nil,
                nil,
                payload)
            local description = "Left-click places this plan; right-click opens its actions. Alt+"
                .. slot
                .. " also places it."
            if not canBuild then
                description = "Select compatible builders to place this plan. Right-click still opens its actions."
            end
            SetTooltip(button, GetPlanTitle(slot, plan), description)
        end
    end
    panel:SetConstructionEnabled(true)
end

function ShowBlueprintTab(panel, units)
    TempBuildMode.SetBuildMode(false)
    units = GetCurrentSelectedUnits()
    if CanCaptureSelection(units) then
        ShowCaptureDeck(panel, units)
    else
        ShowBrowser(panel, units)
    end
end

function AddBlueprintFilter(panel, units, canCapture)
    EnsurePlansLoaded()
    local payload = { panel = panel, canCapture = canCapture }
    local button = panel.constructionFilteringButtons:AddButton(
        ButtonData("BP", nil),
        function(_, clickPayload)
            MarkBlueprintFilterActive(clickPayload.panel, clickPayload.button)
            ShowBlueprintTab(clickPayload.panel, GetCurrentSelectedUnits())
        end,
        nil,
        nil,
        nil,
        payload)
    payload.button = button
    if blueprintPanelActive then
        MarkBlueprintFilterActive(panel, button)
    end

    -- Stock hides the filter strip for ordinary structures. Keep
    -- the inactive BP affordance visible without opening its deck.
    panel:SetConstructionFilterEnabled(true)

    local savedPlans = CountSavedPlans()
    local description = canCapture
        and "Save the selected structures with +P1 through +P8."
        or "Open saved plans. Left-click a plan to place it."
    SetTooltip(
        button,
        "Construction Plans",
        description
            .. " Shift+T saves to the first empty slot; Alt+1 through Alt+8 place plans directly. "
            .. savedPlans
            .. " of "
            .. MAX_SLOTS
            .. " slots used.")
end

function CloseBlueprintPanel()
    blueprintPanelActive = false
end

function LeaveBlueprintUI()
    CloseBlueprintPanel()
    Import("client/input/scoBlueprintPlacement.lua").Cancel()
end

function IsBlueprintUIActive()
    return blueprintPanelActive
end

return {
    ActivatePlanSlot = ActivatePlanSlot,
    AddBlueprintFilter = AddBlueprintFilter,
    CanCaptureSelection = CanCaptureSelection,
    CaptureDefaultPlan = CaptureDefaultPlan,
    CaptureIntoSlot = CaptureIntoSlot,
    CloseBlueprintPanel = CloseBlueprintPanel,
    DeletePlan = DeletePlan,
    DuplicatePlan = DuplicatePlan,
    IsPlanBuildable = IsPlanBuildable,
    IsBlueprintUIActive = IsBlueprintUIActive,
    LeaveBlueprintUI = LeaveBlueprintUI,
    ShowBlueprintTab = ShowBlueprintTab,
}
