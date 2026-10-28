local collisionLayer = Import("common/layers.lua").CollisionLayer
local mapUtils = Import("common/mapUtils.lua")
local water = Import("common/water.lua")
local mouseCursor = Import("client/input/mouseCursor.lua")
local playableAreaManager = Import("client/managers/playableArea/clientPlayableAreaManager.lua")

local degreesToRadians = math.pi / 180
local radiansToDegrees = 180 / math.pi

local axisX = EngineClasses.float3(1, 0, 0)
local axisY = EngineClasses.float3(0, 1, 0)
local axisZ = EngineClasses.float3(0, 0, 1)

local cameraLocalRotation = Engine.EulerToQuaternion(EngineClasses.float3(90 * degreesToRadians, 0, 0), RotationOrder.Default)

--- Closest the camera may get to the ground when zooming in.
local minDistance = 2
--- Over the last stretch of a zoom in, the camera stops steering towards the cursor and straightens
--- out into its own forward, this is how much of that stretch, in world units, the straightening is spread over.
local minDistanceNoDirection = 3
--- How far off the ground the straightening above begins.
local minDistanceNoDirectionOffset = 0
--- How much more than the playable area has to fit in frame when fully zoomed out, so the map does not sit exactly against the screen edges.
local maxDistanceFactor = 1.15
--- Scroll wheel movement that counts as one zoom step, and the size of the step it takes.
local scrollStep = 0.033 * 2
--- How quickly the camera rotation eases towards the angle the player is asking for.
local rotationSmoothSpeed = 14
--- Spreads a scroll across several frames. Smoother to play with, jumpy when recording.
local scrollSteps = true
--- Zoom out along the cursor ray rather than along the camera forward.
local scrollOutMouseDirection = false
--- Zoom out back along whichever ray was last zoomed in on. Takes priority over the option above.
local scrollOutLastDirection = false
--- How close to the edge of the screen, in pixels, the cursor has to be to pan the camera.
local edgePanBorderSize = 8
--- How much more than the target bounds has to fit in frame when fitting the camera to a set of positions.
local fitBoundsMarginFactor = 1.3
--- Lowest height a fit may bring the camera down to, so fitting a lone unit does not drop the camera onto the deck. (Control groups)
local fitBoundsMinHeight = 30

-- Animation curve for the rotation based on the height. A cubic hermite curve: two keyframes, each
-- with a value and a slope, joined by the cubic that matches all four.
local rotationCurveStartHeight = 0
local rotationCurveStartPitch = 55
local rotationCurveStartSlope = -0.84219754
local rotationCurveEndHeight = 180
local rotationCurveEndPitch = 0
local rotationCurveEndSlope = 0

local settings = {
    scrollSpeed = 1.8,
    scrollSmoothTime = 0.09,
    rotationSpeed = 3600,
    panSpeed = 1.2,
    panArrowsSpeed = 5,
    fieldOfView = 50,
    edgePanSpeedMultiplier = 1,
    keyboardPanSpeedMultiplier = 1,
}

--- World position of the pivot: the point on the ground the camera sits above and looks at.
local pivotPosition = EngineClasses.float3(0, 0, 0)
--- Pitch (degrees) the zoom drives the pivot to. The pivot base rotation is only ever a rotation about the world X axis
local pivotBasePitch = 0
--- Full pivot rotation as of the last update
local pivotRotation = EngineClasses.quaternion(EngineClasses.float4(0, 0, 0, 1))

local cameraLocalPosition = EngineClasses.float3(0, 0, 0)
local lastLocalCameraPosition = EngineClasses.float3(0, 0, 0)
local targetLocalCameraPosition = EngineClasses.float3(0, 0, 0)
local zoomVelocity = EngineClasses.float3(0, 0, 0)

local rotationAdd = EngineClasses.float3(0, 0, 0)
local rotationAddSmooth = EngineClasses.float3(0, 0, 0)

local panSmooth = EngineClasses.float3(0, 0, 0)
local panVelocity = EngineClasses.float3(0, 0, 0)
local panOffsetX = EngineClasses.float3(0, 0, 0)
local panOffsetZ = EngineClasses.float3(0, 0, 0)

local lastRayInOrigin = EngineClasses.float3(0, 0, 0)
local lastRayInDirection = EngineClasses.float3(0, 0, 1)
local lastZoomPosition = EngineClasses.float3(0, 0, 0)
local mouseScrollSteps = 0

local maxDistance = 200
local waterLevel = 0
local mapHasWater = false
local mapSizeX = 512
local mapSizeZ = 512
local playableAreaSizeX = 512
local playableAreaSizeZ = 512
local playableAreaCenter = EngineClasses.float2(256, 256)

local previousMousePosition = EngineClasses.float2(0, 0)
local initialised = false
local lastUpdateTime = nil

local input = {
    zoomDelta = 0,
    panDirection = EngineClasses.float2(0, 0),
    isRotating = false,
    isPanning = false,
    rotationDelta = EngineClasses.float2(0, 0),
    freeCamera = false,
    edgePanEnabled = true,
}

local isCursorCurrentlyLocked = nil

---@param position float3
---@return number height
local function SampleHeight(position)
    local errorCode, height = Engine.SampleTerrainHeight(position)
    if errorCode ~= EngineErrorCode.Success then
        return waterLevel
    end
    return math.max(waterLevel, height)
end

--- Slice of the map the pivot is allowed into at a given height. The playable area narrows to a
--- point as the camera rises, so the map edges stay out of frame.
---@param height number
---@return number minX
---@return number minZ
---@return number maxX
---@return number maxZ
local function SamplePyramid(height)
    local centerX = playableAreaCenter.x
    local centerZ = playableAreaCenter.y

    local factor = math.clamp(1 - height / maxDistance, 0, 1)
    local halfX = playableAreaSizeX * factor * 0.5
    local halfZ = playableAreaSizeZ * factor * 0.5

    return centerX - halfX, centerZ - halfZ, centerX + halfX, centerZ + halfZ
end

---@param position float3
---@return float3 clampedPosition
local function GetMapClampedXZPoint(position)
    local minX, minZ, maxX, maxZ = SamplePyramid(0)

    return EngineClasses.float3(
        math.clamp(position.x, minX, maxX),
        position.y,
        math.clamp(position.z, minZ, maxZ))
end

--- Casts against the horizontal plane through the pivot. The fallback for when nothing solid is
--- under the ray.
---@param origin float3
---@param direction float3
---@return boolean hit
---@return float3? hitPoint
---@return number? hitDistance
local function TryRaycastPlane(origin, direction)
    -- No hit when the ray runs parallel to the plane or points away from it.
    if math.abs(direction.y) < 1e-6 then
        return false
    end

    local enter = (pivotPosition.y - origin.y) / direction.y
    if enter <= 0 then
        return false
    end

    local planePoint = GetMapClampedXZPoint(math3D.add(origin, math3D.scale(direction, enter)))
    planePoint.y = SampleHeight(planePoint)

    return true, planePoint, math3D.distance(origin, planePoint)
end

---@param origin float3
---@param direction float3
---@param maxRaycastDistance number
---@return boolean hit
---@return float3? hitPoint
---@return number? hitDistance
local function TryRaycastTerrain(origin, direction, maxRaycastDistance)
    local hitPoint, hitDistance
    local hits = Engine.RayCast(CollisionWorld.EnvironmentCollision, origin, direction, maxRaycastDistance, collisionLayer.None)

    for _, hit in ipairs(hits) do
        if hit.colliderLocalID.index == 0 then
            hitPoint, hitDistance = hit.hitPosition, hit.hitDistance
            break
        end
    end

    if mapHasWater and math.abs(direction.y) > 1e-6 then
        local waterDistance = (waterLevel - origin.y) / direction.y

        if waterDistance > 0 and waterDistance <= maxRaycastDistance and (hitDistance == nil or waterDistance < hitDistance) then
            local waterPoint = math3D.add(origin, math3D.scale(direction, waterDistance))

            if waterPoint.x >= 0 and waterPoint.x <= mapSizeX and waterPoint.z >= 0 and waterPoint.z <= mapSizeZ then
                hitPoint, hitDistance = waterPoint, waterDistance
            end
        end
    end

    if hitPoint ~= nil then
        return true, hitPoint, hitDistance
    end

    return TryRaycastPlane(origin, direction)
end

---@return float3 position
local function GetCameraWorldPosition()
    return math3D.add(pivotPosition, Engine.QuaternionRotateVector(pivotRotation, cameraLocalPosition))
end

---@return quaternion rotation
local function GetCameraWorldRotation()
    return Engine.QuaternionMultiply(pivotRotation, cameraLocalRotation)
end

---@return float3 forward
local function GetCameraForward()
    return Engine.QuaternionRotateVector(GetCameraWorldRotation(), axisZ)
end

---@param direction float3
---@return float3 localDirection
local function InverseTransformDirection(direction)
    return Engine.QuaternionRotateVector(math3D.invert(pivotRotation), direction)
end

---@param point float3
---@return float3 localPoint
local function InverseTransformPoint(point)
    return Engine.QuaternionRotateVector(math3D.invert(pivotRotation), math3D.sub(point, pivotPosition))
end

--- Distance that fits the given frustum height in view at the given vertical field of view.
---@param frustumHeight number
---@param fieldOfView number
---@return number distance
local function FrustumHeightDistance(frustumHeight, fieldOfView)
    return frustumHeight * 0.5 / math.tan(fieldOfView * 0.5 * degreesToRadians)
end

--- Height that fits the whole playable area in view, which is as far out as the camera may zoom.
---@return number distance
local function CalculateMaxDistance()
    local screenSize = Engine.GetScreenSizeInPixels()
    local aspect = screenSize.x / screenSize.y

    local distanceHeight = FrustumHeightDistance(playableAreaSizeZ * maxDistanceFactor, settings.fieldOfView)

    local horizontalFieldOfView = 2 * math.atan(math.tan(settings.fieldOfView * 0.5 * degreesToRadians) * aspect) * radiansToDegrees
    local distanceWidth = FrustumHeightDistance(playableAreaSizeX * maxDistanceFactor, horizontalFieldOfView)

    return math.max(distanceHeight, distanceWidth)
end

--- Pulls the pivot back inside the pyramid slice for its current height and re-seats it on the
--- terrain.
local function ClampPivotXZPlane()
    local minX, minZ, maxX, maxZ = SamplePyramid(lastLocalCameraPosition.y)

    local clamped = GetMapClampedXZPoint(EngineClasses.float3(
        math.clamp(pivotPosition.x, minX, maxX),
        0,
        math.clamp(pivotPosition.z, minZ, maxZ)))

    clamped.y = SampleHeight(clamped)
    pivotPosition = clamped
end

--- Re-seats the pivot under the given world point, keeping the camera where it is by folding the
--- difference back into the zoom target.
---@param position float3
local function SetNewPivotPosition(position)
    local cameraWorldPosition = GetCameraWorldPosition()

    pivotPosition = EngineClasses.float3(position.x, SampleHeight(position), position.z)

    local localPosition = InverseTransformPoint(cameraWorldPosition)

    -- The camera must always be above the pivot y position, so do this to make sure this is the case
    localPosition.y = math.max(localPosition.y, minDistance * 0.5)

    local offset = math3D.sub(cameraLocalPosition, localPosition)

    cameraLocalPosition = localPosition
    lastLocalCameraPosition = EngineClasses.float3(localPosition.x, localPosition.y, localPosition.z)
    targetLocalCameraPosition = math3D.sub(targetLocalCameraPosition, offset)
end

local function TryRecalculatePivotPosition()
    local hit, hitPoint = TryRaycastTerrain(GetCameraWorldPosition(), GetCameraForward(), maxDistance * 2)
    if hit then
        SetNewPivotPosition(hitPoint)
    end
end

--- How fast a single scroll step moves the camera. Scales with how far the ground is, so zooming feels the same whether you are on the deck or up at strategic height.
---@return number speed
local function SampleCameraSpeed()
    local origin = math3D.add(pivotPosition, Engine.QuaternionRotateVector(pivotRotation, targetLocalCameraPosition))

    local hit, _, hitDistance = TryRaycastTerrain(origin, GetCameraForward(), maxDistance * 2)
    if not hit then
        return 0
    end

    return math.max(hitDistance * 2.6, 5) * settings.scrollSpeed
end

---A single cubic hermite segment between the two keyframes, clamping to the end values outside them.
---@param height number
---@return number pitch
local function SampleRotationPerHeight(height)
    local width = rotationCurveEndHeight - rotationCurveStartHeight

    local t = math.clamp((height - rotationCurveStartHeight) / width, 0, 1)
    local t2 = t * t
    local t3 = t2 * t

    local startTangent = rotationCurveStartSlope * width
    local endTangent = rotationCurveEndSlope * width

    return (2 * t3 - 3 * t2 + 1) * rotationCurveStartPitch
        + (t3 - 2 * t2 + t) * startTangent
        + (t3 - t2) * endTangent
        + (-2 * t3 + 3 * t2) * rotationCurveEndPitch
end

--- Pitch the pivot wants for the height the camera is at. Zero while free camera is on, which lets the player hold whatever angle they like.
---@return number pitchOffset
local function CalculateRotateAroundOffset()
    if input.freeCamera then
        return 0
    end

    return -SampleRotationPerHeight(cameraLocalPosition.y) - pivotBasePitch
end

---@param rayOrigin float3
---@param rayDirection float3
---@param steps number
local function ZoomIn(rayOrigin, rayDirection, steps)
    if targetLocalCameraPosition.y <= minDistance + 0.1 then
        return
    end

    local hit, hitPoint, hitDistance = TryRaycastTerrain(rayOrigin, rayDirection, maxDistance * 2)
    if not hit then
        return
    end

    -- Zoom towards the cursor when there is room, and straighten up into the camera forward as the ground gets close
    lastRayInDirection = math3D.slerp(
        GetCameraForward(),
        math3D.normalizeSafe(math3D.sub(hitPoint, rayOrigin)),
        (hitDistance - minDistanceNoDirectionOffset) / minDistanceNoDirection)
    lastRayInOrigin = EngineClasses.float3(rayOrigin.x, rayOrigin.y, rayOrigin.z)
    lastZoomPosition = hitPoint

    local cameraRayDirection = InverseTransformDirection(lastRayInDirection)
    local scrollCameraSpeed = steps * SampleCameraSpeed()

    targetLocalCameraPosition = math3D.moveTowards(
        targetLocalCameraPosition,
        math3D.add(targetLocalCameraPosition, math3D.scale(cameraRayDirection, scrollCameraSpeed)),
        math.max(hitDistance - minDistance, 0))
end

---@param rayOrigin float3
---@param rayDirection float3
---@param steps number
local function ZoomOut(rayOrigin, rayDirection, steps)
    if scrollOutLastDirection then
        rayOrigin, rayDirection = lastRayInOrigin, lastRayInDirection
    elseif not scrollOutMouseDirection then
        rayOrigin, rayDirection = GetCameraWorldPosition(), GetCameraForward()
    end

    if targetLocalCameraPosition.y >= maxDistance - 0.1 then
        return
    end

    local hit, hitPoint = TryRaycastTerrain(rayOrigin, rayDirection, maxDistance * 2)
    if not hit then
        return
    end

    lastZoomPosition = hitPoint

    local cameraRayDirection = InverseTransformDirection(rayDirection)
    local scrollCameraSpeed = steps * SampleCameraSpeed()

    targetLocalCameraPosition = math3D.moveTowards(
        targetLocalCameraPosition,
        math3D.sub(targetLocalCameraPosition, math3D.scale(cameraRayDirection, scrollCameraSpeed)),
        maxDistance)
end

local function ReadSettings()
    settings.scrollSpeed, settings.scrollSmoothTime, settings.rotationSpeed, settings.panSpeed, settings.panArrowsSpeed, settings.fieldOfView = Engine.GetCameraDebugSettings()

    local userSettings = Engine.GetUserSettings()
    settings.scrollSpeed = settings.scrollSpeed * userSettings.zoomSpeedMultiplier
    settings.edgePanSpeedMultiplier = userSettings.edgePanSpeedMultiplier
    settings.keyboardPanSpeedMultiplier = userSettings.keyboardPanSpeedMultiplier
    input.edgePanEnabled = userSettings.edgePanEnabled

    if userSettings.lockCursor ~= isCursorCurrentlyLocked then
        isCursorCurrentlyLocked = userSettings.lockCursor
        if not input.isRotating then
            Engine.SetMouseLockMode(isCursorCurrentlyLocked and CursorLockMode.Confined or CursorLockMode.None)
        end
    end
end

---@param area Area
local function ApplyPlayableArea(area)
    playableAreaCenter = EngineClasses.float2(area.position.x, area.position.y)
    playableAreaSizeX = area.size.x
    playableAreaSizeZ = area.size.y
end

--- Puts the camera in the middle of the playable area, zoomed all the way out and looking straight
--- down.
function RestartCamera()
    if not GameInfo or not GameInfo.MapInfo then
        return
    end

    mapSizeX, mapSizeZ = mapUtils.GetMapSize()

    ApplyPlayableArea(playableAreaManager.GetPlayableArea() or mapUtils.GetDefaultPlayableArea())

    mapHasWater = water.HasWater()
    waterLevel = water.GetLevel() or 0

    ReadSettings()

    local position = EngineClasses.float3(playableAreaCenter.x, 0, playableAreaCenter.y)
    position.y = math.clamp(SampleHeight(position), waterLevel, maxDistance)

    rotationAdd = EngineClasses.float3(0, 0, 0)
    rotationAddSmooth = EngineClasses.float3(0, 0, 0)

    maxDistance = CalculateMaxDistance()

    -- The camera must always be above the pivot y position, so do this to make sure this is the case
    cameraLocalPosition = EngineClasses.float3(0, math.max(maxDistance - position.y, minDistance * 0.5), 0)
    pivotBasePitch = 0
    pivotRotation = EngineClasses.quaternion(EngineClasses.float4(0, 0, 0, 1))
    pivotPosition = position

    lastLocalCameraPosition = EngineClasses.float3(0, cameraLocalPosition.y, 0)
    targetLocalCameraPosition = EngineClasses.float3(0, cameraLocalPosition.y, 0)
    panOffsetX = EngineClasses.float3(0, 0, 0)
    panOffsetZ = EngineClasses.float3(0, 0, 0)
    panSmooth = EngineClasses.float3(0, 0, 0)
    panVelocity = EngineClasses.float3(0, 0, 0)
    zoomVelocity = EngineClasses.float3(0, 0, 0)
    mouseScrollSteps = 0

    initialised = true
end

---@param area Area
function SetPlayableArea(area)
    ApplyPlayableArea(area)

    if not initialised then
        return
    end

    maxDistance = CalculateMaxDistance()

    local maxHeight = math.max(maxDistance, minDistance * 0.5)
    cameraLocalPosition.y = math.min(cameraLocalPosition.y, maxHeight)
    lastLocalCameraPosition.y = math.min(lastLocalCameraPosition.y, maxHeight)
    targetLocalCameraPosition.y = math.min(targetLocalCameraPosition.y, maxHeight)

    ClampPivotXZPlane()
end

--- Pan direction from the cursor resting against the edges of the screen
---@param pointerPosition float2
---@return number x
---@return number y
local function GetEdgePanDirection(pointerPosition)
    if not input.edgePanEnabled or input.isRotating or not Engine.IsApplicationFocused() then
        return 0, 0
    end

    local screenSize = Engine.GetScreenSizeInPixels()

    local x = 0
    if pointerPosition.x <= edgePanBorderSize then
        x = -1
    elseif pointerPosition.x >= screenSize.x - edgePanBorderSize then
        x = 1
    end

    local y = 0
    if pointerPosition.y <= edgePanBorderSize then
        y = -1
    elseif pointerPosition.y >= screenSize.y - edgePanBorderSize then
        y = 1
    end

    return x, y
end

---@param deltaTime number
local function DoInput(deltaTime)
    local pointerPosition = mouseCursor.GetMouseScreenPosition2D()

    if mouseCursor.IsCursorInGameView() then
        local rayOrigin, rayDirection = Engine.ScreenPointToRay(pointerPosition)

        local newScrollSteps = math.truncateToInt(input.zoomDelta / scrollStep)
        input.zoomDelta = 0

        if newScrollSteps ~= 0 then
            mouseScrollSteps = mouseScrollSteps + newScrollSteps
        end

        while mouseScrollSteps ~= 0 do
            if mouseScrollSteps > 0 then
                ZoomIn(rayOrigin, rayDirection, scrollStep)
                mouseScrollSteps = mouseScrollSteps - 1
            else
                ZoomOut(rayOrigin, rayDirection, scrollStep)
                mouseScrollSteps = mouseScrollSteps + 1
            end

            if not scrollSteps then
                break
            end
        end
    end

    targetLocalCameraPosition.y = math.clamp(targetLocalCameraPosition.y, minDistance * 0.5, maxDistance * 1.01)
    lastLocalCameraPosition, zoomVelocity = math3D.smoothDamp(lastLocalCameraPosition, targetLocalCameraPosition, zoomVelocity, settings.scrollSmoothTime, 10000, deltaTime)

    if math3D.lengthSquared(zoomVelocity) > 0.0001 then
        cameraLocalPosition = EngineClasses.float3(lastLocalCameraPosition.x, lastLocalCameraPosition.y, lastLocalCameraPosition.z)

        local rotationOffset = CalculateRotateAroundOffset()
        if rotationOffset ~= 0 then
            -- Rotate the rig around the point the zoom is aiming at. The pivot base rotation is a
            -- pure world X rotation and the camera right axis stays on world X with it, so the pitch
            -- simply accumulates while the pivot swings around the zoom point.
            local rotation = Engine.QuaternionAxisAngle(Engine.QuaternionRotateVector(pivotRotation, axisX), rotationOffset * degreesToRadians)
            pivotPosition = math3D.add(
                lastZoomPosition,
                Engine.QuaternionRotateVector(rotation, math3D.sub(pivotPosition, lastZoomPosition)))

            pivotBasePitch = pivotBasePitch + rotationOffset
            pivotRotation = Engine.QuaternionAxisAngle(axisX, pivotBasePitch * degreesToRadians)
        end

        TryRecalculatePivotPosition()
        ClampPivotXZPlane()

        -- Re-seating the pivot can push the camera past the zoom limit
        local maxHeight = maxDistance * 1.01
        targetLocalCameraPosition.y = math.min(targetLocalCameraPosition.y, maxHeight)
        lastLocalCameraPosition.y = math.min(lastLocalCameraPosition.y, maxHeight)

        cameraLocalPosition = EngineClasses.float3(lastLocalCameraPosition.x, lastLocalCameraPosition.y, lastLocalCameraPosition.z)
    else
        lastLocalCameraPosition = EngineClasses.float3(
            cameraLocalPosition.x, cameraLocalPosition.y, cameraLocalPosition.z)
    end

    local isCameraBeingRotated = false

    if input.isRotating then
        local screenSize = Engine.GetScreenSizeInPixels()

        rotationAdd.y = rotationAdd.y + input.rotationDelta.x / screenSize.x * settings.rotationSpeed
        rotationAdd.x = rotationAdd.x - input.rotationDelta.y / screenSize.y * settings.rotationSpeed

        isCameraBeingRotated = true
    end

    input.rotationDelta.x = 0
    input.rotationDelta.y = 0

    -- Let the rotation fall back to the resting angle as soon as nothing is holding it.
    if not (input.freeCamera or isCameraBeingRotated) then
        rotationAdd.x = 0
        rotationAdd.y = 0
    end

    if input.isPanning then
        -- Drag the world under the cursor: whatever was under the pointer last frame is pulled back
        -- under it this frame.
        local currentOrigin, currentDirection = Engine.ScreenPointToRay(pointerPosition)
        local currentHit, currentPoint = TryRaycastPlane(currentOrigin, currentDirection)

        if currentHit then
            local previousOrigin, previousDirection = Engine.ScreenPointToRay(previousMousePosition)
            local previousHit, previousPoint = TryRaycastPlane(previousOrigin, previousDirection)

            if previousHit then
                local panVector = math3D.sub(previousPoint, currentPoint)
                panOffsetX = EngineClasses.float3(panVector.x * settings.panSpeed, 0, 0)
                panOffsetZ = EngineClasses.float3(0, 0, panVector.z * settings.panSpeed)
            end
        end
    end

    local targetPanOffset = EngineClasses.float3(0, 0, 0)

    local panDirectionX, panDirectionY = 0, 0
    if not input.isPanning then
        local edgePanX, edgePanY = GetEdgePanDirection(pointerPosition)

        local keyboardMultiplier = settings.keyboardPanSpeedMultiplier
        local edgeMultiplier = settings.edgePanSpeedMultiplier
        local maxMultiplier = math.max(keyboardMultiplier, edgeMultiplier)
        panDirectionX = math.clamp(input.panDirection.x * keyboardMultiplier + edgePanX * edgeMultiplier, -maxMultiplier, maxMultiplier)
        panDirectionY = math.clamp(input.panDirection.y * keyboardMultiplier + edgePanY * edgeMultiplier, -maxMultiplier, maxMultiplier)
    end

    if panDirectionX * panDirectionX + panDirectionY * panDirectionY > 0.00001 then
        -- The pivot forward and right flattened onto the ground plane. Deliberately not normalised,
        -- so a tilted camera pans a little slower.
        local forwardDirection = Engine.QuaternionRotateVector(pivotRotation, axisZ)
        local rightDirection = Engine.QuaternionRotateVector(pivotRotation, axisX)
        forwardDirection.y = 0
        rightDirection.y = 0

        -- Pan faster the further out the camera is, so crossing the map takes a similar time at
        -- any zoom level.
        local speed = lastLocalCameraPosition.y ^ 0.6667 * settings.panArrowsSpeed * deltaTime
        targetPanOffset = math3D.scale(
            math3D.add(math3D.scale(rightDirection, panDirectionX), math3D.scale(forwardDirection, panDirectionY)),
            speed)
    end

    panSmooth, panVelocity = math3D.smoothDamp(panSmooth, targetPanOffset, panVelocity, deltaTime * 10, math.huge, deltaTime)

    pivotPosition = math3D.add(pivotPosition, panSmooth)

    if math3D.lengthSquared(panOffsetX) > 0.0001 then
        pivotPosition = math3D.add(pivotPosition, panOffsetX)
        panOffsetX = EngineClasses.float3(0, 0, 0)
    end

    if math3D.lengthSquared(panOffsetZ) > 0.0001 then
        pivotPosition = math3D.add(pivotPosition, panOffsetZ)
        panOffsetZ = EngineClasses.float3(0, 0, 0)
    end

    ClampPivotXZPlane()

    previousMousePosition = pointerPosition
end

function Update()
    if GameInfo == nil or GameInfo.MapInfo == nil then
        lastUpdateTime = nil
        initialised = false
        return
    end

    if not initialised then
        RestartCamera()
    end

    ReadSettings()

    local now = Engine.GetCurrentRealtimeInSeconds()
    local deltaTime = lastUpdateTime and (now - lastUpdateTime) or 0
    lastUpdateTime = now

    -- Between 1000 and 10 fps, to prevent spike jumps
    deltaTime = math.clamp(deltaTime, 0.001, 0.1)

    DoInput(deltaTime)

    -- Keep the total pitch between straight down and 80 degrees off it.
    local pitch = pivotBasePitch % 360
    if pitch > 180 then
        pitch = pitch - 360
    end
    rotationAdd.x = math.clamp(rotationAdd.x, -80 - pitch, 0 - pitch)

    rotationAddSmooth = math3D.lerpClamped(rotationAddSmooth, rotationAdd, deltaTime * rotationSmoothSpeed)

    pivotRotation = Engine.QuaternionMultiply(
        Engine.EulerToQuaternion(EngineClasses.float3(rotationAddSmooth.x * degreesToRadians, rotationAddSmooth.y * degreesToRadians, rotationAddSmooth.z * degreesToRadians), RotationOrder.Default),
        Engine.QuaternionAxisAngle(axisX, pivotBasePitch * degreesToRadians))

    local position = GetCameraWorldPosition()
    local rotation = GetCameraWorldRotation()

    -- Flatten any roll off the rotation, so the horizon stays level.
    local forward = Engine.QuaternionRotateVector(rotation, axisZ)
    local right = Engine.QuaternionRotateVector(rotation, axisX)
    right.y = 0
    right = math3D.normalizeSafe(right)
    rotation = Engine.QuaternionMultiply(
        Engine.QuaternionLookRotation(right, math3D.cross(forward, right)),
        Engine.QuaternionAxisAngle(axisY, -90 * degreesToRadians))

    Engine.SetCameraFieldOfView(settings.fieldOfView)
    Engine.SetCameraFocusDistance(math3D.length(cameraLocalPosition))
    Engine.SetCameraTransform(position, rotation)
end

---@param zoomDelta number
function SetZoomAmount(zoomDelta)
    input.zoomDelta = input.zoomDelta + zoomDelta / 10
end

local panDirectionMap = {
    left = 0,
    right = 0,
    up = 0,
    down = 0,
}

-- The opposing directions sum, so holding left and right at once cancels out.
local function OnPanDirectionChanged()
    input.panDirection.x = panDirectionMap.right - panDirectionMap.left
    input.panDirection.y = panDirectionMap.up - panDirectionMap.down
end

---@param isPanningLeft boolean
function SetPanLeft(isPanningLeft)
    panDirectionMap.left = isPanningLeft and 1 or 0
    OnPanDirectionChanged()
end

---@param isPanningRight boolean
function SetPanRight(isPanningRight)
    panDirectionMap.right = isPanningRight and 1 or 0
    OnPanDirectionChanged()
end

---@param isPanningUp boolean
function SetPanUp(isPanningUp)
    panDirectionMap.up = isPanningUp and 1 or 0
    OnPanDirectionChanged()
end

---@param isPanningDown boolean
function SetPanDown(isPanningDown)
    panDirectionMap.down = isPanningDown and 1 or 0
    OnPanDirectionChanged()
end

---@param isPanning boolean
function SetCameraPan(isPanning)
    input.isPanning = isPanning
    previousMousePosition = mouseCursor.GetMouseScreenPosition2D()
end

---@param isRotating boolean
function SetCameraRotation(isRotating)
    input.isRotating = isRotating

    if isRotating then
        input.rotationDelta.x = 0
        input.rotationDelta.y = 0
    end

    Engine.SetMouseLockMode(isRotating and CursorLockMode.Locked or (isCursorCurrentlyLocked and CursorLockMode.Confined or CursorLockMode.None))

    local rendering = Import("client/rendering/rendering.lua")
    rendering.SetIconsVisibility(not isRotating)
end

--- Raw mouse movement, only consumed while the rotate button is held.
---@param delta number
function AddRotationDeltaX(delta)
    input.rotationDelta.x = input.rotationDelta.x + delta
end

---@param delta number
function AddRotationDeltaY(delta)
    input.rotationDelta.y = input.rotationDelta.y + delta
end

function ToggleFreeCamera()
    input.freeCamera = not input.freeCamera
end

---@param positions float3[]
function FitCameraToPositions(positions)
    if not initialised or not next(positions) then
        return
    end

    local minX, minZ = math.huge, math.huge
    local maxX, maxZ = -math.huge, -math.huge

    for _, position in ipairs(positions) do
        minX = math.min(minX, position.x)
        maxX = math.max(maxX, position.x)
        minZ = math.min(minZ, position.z)
        maxZ = math.max(maxZ, position.z)
    end

    local screenSize = Engine.GetScreenSizeInPixels()
    local aspect = screenSize.x / screenSize.y
    local horizontalFieldOfView = 2 * math.atan(math.tan(settings.fieldOfView * 0.5 * degreesToRadians) * aspect) * radiansToDegrees

    local distanceHeight = FrustumHeightDistance((maxZ - minZ) * fitBoundsMarginFactor, settings.fieldOfView)
    local distanceWidth = FrustumHeightDistance((maxX - minX) * fitBoundsMarginFactor, horizontalFieldOfView)
    local fitHeight = math.clamp(math.max(distanceHeight, distanceWidth, fitBoundsMinHeight), minDistance, maxDistance)
    local height = math.max(fitHeight, targetLocalCameraPosition.y)

    local position = GetMapClampedXZPoint(EngineClasses.float3((minX + maxX) * 0.5, 0, (minZ + maxZ) * 0.5))
    position.y = SampleHeight(position)

    pivotPosition = position
    if not input.freeCamera then
        pivotBasePitch = -SampleRotationPerHeight(height)
    end
    pivotRotation = Engine.QuaternionAxisAngle(axisX, pivotBasePitch * degreesToRadians)

    cameraLocalPosition = EngineClasses.float3(0, height, 0)
    lastLocalCameraPosition = EngineClasses.float3(0, height, 0)
    targetLocalCameraPosition = EngineClasses.float3(0, height, 0)
    zoomVelocity = EngineClasses.float3(0, 0, 0)
    lastZoomPosition = position
end


-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0
-- Insert in client/input/cameraController.lua before its final module return.
-- This stays in the native rig's scope; renderer and intel state are untouched.
local SCOArrivalCameraState = nil
local SCOArrivalNativeUpdate = Update
local SCOArrivalNativeDoInput = DoInput
local SCOArrivalNativeSetCameraRotation = SetCameraRotation

local function SCOArrivalCopyVector(value)
    return EngineClasses.float3(value.x, value.y, value.z)
end

local function SCOArrivalFiniteNumber(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function SCOArrivalCameraStillOwnsView(state)
    return GameInfo and GameInfo.MapInfo == state.mapInfo
        and type(IsObserver) == "function" and not IsObserver()
        and type(GetFocusArmy) == "function" and GetFocusArmy() == state.armyId
        and not Engine.IsReplayPlayback()
end

local function SCOArrivalApplyCameraPan(state, eased)
    pivotPosition = math3D.lerpClamped(state.startPivot, state.targetPivot, eased)
    cameraLocalPosition = math3D.lerpClamped(state.startLocalPosition, state.targetLocalPosition, eased)
    lastLocalCameraPosition = SCOArrivalCopyVector(cameraLocalPosition)
    targetLocalCameraPosition = SCOArrivalCopyVector(cameraLocalPosition)
    pivotBasePitch = state.startPitch + (state.targetPitch - state.startPitch) * eased
    rotationAdd = math3D.scale(state.startRotation, 1 - eased)
    rotationAddSmooth = SCOArrivalCopyVector(rotationAdd)
    ClampPivotXZPlane()
    lastZoomPosition = SCOArrivalCopyVector(pivotPosition)
end

local function SCOArrivalClearCameraInput()
    input.zoomDelta = 0
    input.rotationDelta.x = 0
    input.rotationDelta.y = 0
    input.panDirection.x = 0
    input.panDirection.y = 0
    input.isPanning = false
    input.isRotating = false
    for direction in pairs(panDirectionMap) do
        panDirectionMap[direction] = 0
    end
    mouseScrollSteps = 0
    zoomVelocity = EngineClasses.float3(0, 0, 0)
    panSmooth = EngineClasses.float3(0, 0, 0)
    panVelocity = EngineClasses.float3(0, 0, 0)
    panOffsetX = EngineClasses.float3(0, 0, 0)
    panOffsetZ = EngineClasses.float3(0, 0, 0)
    previousMousePosition = mouseCursor.GetMouseScreenPosition2D()
    SCOArrivalNativeSetCameraRotation(false)
end

---@param finishPan? boolean Pass true only for authoritative match-start release.
function StopSCOMCommanderArrivalCamera(finishPan)
    local state = SCOArrivalCameraState
    if state == nil then
        return false
    end
    if finishPan == true and SCOArrivalCameraStillOwnsView(state) then
        SCOArrivalApplyCameraPan(state, 1)
    end
    SCOArrivalCameraState = nil
    input.freeCamera = state.freeCamera
    SCOArrivalClearCameraInput()
    lastLocalCameraPosition = SCOArrivalCopyVector(cameraLocalPosition)
    targetLocalCameraPosition = SCOArrivalCopyVector(cameraLocalPosition)
    lastZoomPosition = SCOArrivalCopyVector(pivotPosition)
    return true
end

---@param armyId ArmyId Owning army from the authoritative arrival event.
---@param position float3 Authoritative position of that army's initial commander.
---@param duration? number Host sequence duration, default 4; authoritative Stop releases control.
---@return boolean started
function StartSCOMCommanderArrivalCamera(armyId, position, duration)
    if SCOArrivalCameraState ~= nil or not GameInfo or not GameInfo.MapInfo then
        return false
    end
    if type(IsObserver) ~= "function" or IsObserver() or Engine.IsReplayPlayback() then
        return false
    end
    local focusArmy = type(GetFocusArmy) == "function" and GetFocusArmy() or nil
    if not SCOArrivalFiniteNumber(focusArmy) or focusArmy <= 0 or armyId ~= focusArmy then
        return false
    end
    local validPosition, x, y, z = pcall(function()
        return position.x, position.y, position.z
    end)
    if not validPosition or not SCOArrivalFiniteNumber(x) or not SCOArrivalFiniteNumber(y) or not SCOArrivalFiniteNumber(z) then
        return false
    end
    duration = duration == nil and 4 or duration
    if not SCOArrivalFiniteNumber(duration) or duration <= 0 or duration > 30 then
        return false
    end
    local now = Engine.GetCurrentRealtimeInSeconds()
    if not SCOArrivalFiniteNumber(now) then
        return false
    end
    if not initialised then
        RestartCamera()
    end
    local target = GetMapClampedXZPoint(EngineClasses.float3(x, y, z))
    target.y = SampleHeight(target)
    local height = math.clamp(fitBoundsMinHeight, minDistance, math.max(minDistance, maxDistance))
    SCOArrivalCameraState = {
        armyId = armyId,
        mapInfo = GameInfo.MapInfo,
        renderedElapsed = 0,
        moveDuration = math.min(1.5, duration * 0.4),
        startPivot = SCOArrivalCopyVector(pivotPosition),
        targetPivot = target,
        startLocalPosition = SCOArrivalCopyVector(cameraLocalPosition),
        targetLocalPosition = EngineClasses.float3(0, height, 0),
        startPitch = pivotBasePitch,
        targetPitch = -SampleRotationPerHeight(height),
        startRotation = SCOArrivalCopyVector(rotationAddSmooth),
        freeCamera = input.freeCamera,
    }
    SCOArrivalClearCameraInput()
    input.freeCamera = false
    return true
end

DoInput = function(deltaTime)
    local state = SCOArrivalCameraState
    if state == nil then
        return SCOArrivalNativeDoInput(deltaTime)
    end
    if SCOArrivalFiniteNumber(deltaTime) then
        state.renderedElapsed = state.renderedElapsed + math.clamp(deltaTime, 0, 0.1)
    end
    local fraction = math.clamp(state.renderedElapsed / state.moveDuration, 0, 1)
    local eased = fraction * fraction * (3 - 2 * fraction)
    SCOArrivalApplyCameraPan(state, eased)
    state.panComplete = fraction >= 1
end

function IsSCOMCommanderArrivalPanComplete()
    local state = SCOArrivalCameraState
    return state ~= nil and state.panComplete == true and SCOArrivalCameraStillOwnsView(state)
end

function Update()
    local state = SCOArrivalCameraState
    if state ~= nil and not SCOArrivalCameraStillOwnsView(state) then
        StopSCOMCommanderArrivalCamera()
    end
    SCOArrivalNativeUpdate()
    -- Native clientMain resolves this module Update on every rendered frame.
    -- Run the handshake after the camera transform was applied to that frame.
    local arrival = rawget(_G, "SCO_CommanderArrivalVisuals")
    if arrival then arrival.RenderUpdate() end
end

-- Ignore input while the native rig is being animated, including rotation's cursor-lock side effect.
local function SCOArrivalBlockCameraInput(nativeFunction)
    return function(...)
        if SCOArrivalCameraState == nil then
            return nativeFunction(...)
        end
    end
end

SetZoomAmount = SCOArrivalBlockCameraInput(SetZoomAmount)
SetPanLeft = SCOArrivalBlockCameraInput(SetPanLeft)
SetPanRight = SCOArrivalBlockCameraInput(SetPanRight)
SetPanUp = SCOArrivalBlockCameraInput(SetPanUp)
SetPanDown = SCOArrivalBlockCameraInput(SetPanDown)
SetCameraPan = SCOArrivalBlockCameraInput(SetCameraPan)
SetCameraRotation = SCOArrivalBlockCameraInput(SetCameraRotation)
AddRotationDeltaX = SCOArrivalBlockCameraInput(AddRotationDeltaX)
AddRotationDeltaY = SCOArrivalBlockCameraInput(AddRotationDeltaY)
ToggleFreeCamera = SCOArrivalBlockCameraInput(ToggleFreeCamera)
FitCameraToPositions = SCOArrivalBlockCameraInput(FitCameraToPositions)
RestartCamera = SCOArrivalBlockCameraInput(RestartCamera)

return {
    StartSCOMCommanderArrivalCamera = StartSCOMCommanderArrivalCamera,
    StopSCOMCommanderArrivalCamera = StopSCOMCommanderArrivalCamera,
    IsSCOMCommanderArrivalPanComplete = IsSCOMCommanderArrivalPanComplete,
    Update = Update,
    RestartCamera = RestartCamera,
    SetPlayableArea = SetPlayableArea,
    SetZoomAmount = SetZoomAmount,
    SetPanLeft = SetPanLeft,
    SetPanRight = SetPanRight,
    SetPanUp = SetPanUp,
    SetPanDown = SetPanDown,
    SetCameraPan = SetCameraPan,
    SetCameraRotation = SetCameraRotation,
    AddRotationDeltaX = AddRotationDeltaX,
    AddRotationDeltaY = AddRotationDeltaY,
    ToggleFreeCamera = ToggleFreeCamera,
    FitCameraToPositions = FitCameraToPositions,
}
