
-- This file has been auto-generated, any changes will be overwritten

---@enum Platform 
Platform = {
    Unknown = 0,
    Windows = 1,
    Linux = 2,
    Mac = 3,
}
---@enum LuaProfilingTarget 
LuaProfilingTarget = {
    Disabled = 0,
    Host = 1,
    Client = 2,
}
---@enum RotationOrder 
RotationOrder = {
    XYZ = 0,
    XZY = 1,
    YXZ = 2,
    YZX = 3,
    ZXY = 4,
    Default = 4,
    ZYX = 5,
}
---@enum EngineErrorCode 
EngineErrorCode = {
    Success = 0,
    InvalidGlobalID = 1,
    InvalidLocalID = 2,
    InvalidGridID = 3,
    InvalidGridCellSize = 4,
    InvalidComponentStack = 5,
    IndexOutOfBounds = 6,
    InvalidPlayerID = 7,
    InvalidByteArray = 8,
    ProgressBarTypeInvalid = 9,
    IconNameInvalid = 10,
    IconIndexInvalid = 11,
    IconTypeInvalid = 12,
    RangeRingMaterialInvalid = 13,
    BoneNameInvalid = 14,
    HierarchyNotFound = 15,
    InvalidPrefabID = 16,
    TemplateNameEmtpy = 17,
    EntityNameEmpty = 18,
    EntityNameDuplicate = 19,
    RootEntityNull = 20,
    RootEntityDuplicate = 21,
    ParentEntityNameInvalid = 22,
    InvalidHierarchyMap = 23,
    InvalidOperation = 24,
    InvalidPlanarVector = 25,
    OutOfTerrainBounds = 26,
    TerrainNull = 27,
    InvalidMesh = 28,
    InvalidSkeleton = 29,
    InvalidMovementAltitudes = 30,
    InvalidStartPosition = 31,
    InvalidAnimationClipID = 32,
    NavigationLayerLimitReached = 33,
    NavigationLayerNameInvalid = 34,
    NavigationLayerNameDuplicate = 35,
    NavigationLayerRegistrationClosed = 36,
    InvalidAudioEventID = 37,
    InvalidAudioCategoryID = 38,
    AudioCategoryLimitReached = 39,
    AudioEventPostFailed = 40,
    InvalidAudioRtpcID = 41,
    InvalidAudioStateGroupID = 42,
    InvalidAudioStateID = 43,
    InvalidAudioSwitchGroupID = 44,
    InvalidAudioSwitchID = 45,
    InvalidAudioBankPath = 46,
    AudioBankLoadFailed = 47,
    MovementPatternInvalid = 48,
    MovementPatternLimitReached = 49,
}
---@enum MovementEventType 
MovementEventType = {
    -- Movement entity reached its target position within the requested range.
    Arrived = 0,
    -- Movement entity could not reach exact target; stopped at the nearest navigable cell instead.
    ArrivedBestEffort = 1,
    -- Movement entity finished rotating in place to face its target direction.
    Aligned = 2,
    -- Movement entity finished changing altitude.
    AltitudeReached = 3,
}
---@enum ColliderType 
ColliderType = {
    Invalid = 0,
    Box = 1,
    Sphere = 2,
    Circle = 3,
}
---@enum VolumeCollisionEventMode Chooses how much volume collision data a collision world records each tick. Higher tiers cost more memory and time, so pick the lowest one the scripts actually need. Set on CreateCollisionWorld and fixed for the lifetime of the world.
VolumeCollisionEventMode = {
    -- No events are tracked. GetCollisionWorldVolumeEvents returns nothing and GetVolumeColliderCollisions returns no hits. Colliders in this world still collide, they just report nothing. Use this for worlds only queried with casts.
    Disabled = 0,
    -- Enter and exit events are tracked. GetCollisionWorldVolumeEvents and GetVolumeColliderCollisions both return events, but hit positions on them are not filled in.
    EnterExit = 1,
    -- Enter and exit events are tracked, and each one carries the world space position of the hit. Everything EnterExit does, plus the position. The most expensive mode.
    EnterExitWithPosition = 2,
}
---@enum FileEventType What happened to a file reported by GetFileEvents.
FileEventType = {
    Created = 0,
    Changed = 1,
    Deleted = 2,
}
---@enum BallisticType 
BallisticType = {
    None = 0,
    LowArc = 1,
    HighArc = 2,
}
---@enum ReferenceAltitude 
ReferenceAltitude = {
    Ground = 0,
    GroundOrWater = 1,
    Water = 2,
    Length = 3,
}
---@enum HomingType 
HomingType = {
    TargetPosition = 0,
    TargetGlobalID = 1,
}
---@enum AimControllerState 
AimControllerState = {
    Rest = 0,
    Aiming = 1,
    Frozen = 2,
}
---@enum PatternMode 
PatternMode = {
    None = 0,
    Orbit = 1,
    Circle = 2,
    Strafe = 3,
}
---@enum OrbitFacing 
OrbitFacing = {
    Center = 0,
    Travel = 1,
    Hold = 2,
}
---@enum PlayerType 
PlayerType = {
    Empty = 0,
    Player = 1,
    Observer = 2,
    AI = 3,
}
---@enum Faction 
Faction = {
    EDA = 0,
    Chosen = 1,
    Guard = 2,
}
---@enum NavmapLineCastResult 
NavmapLineCastResult = {
    Hit = 0,
    NoHit = 1,
    OutOfTerrainBounds = 2,
    InvalidStartPosition = 3,
}
---@enum CommandType 
CommandType = {
    Empty = 0,
    EngineCommand = 1,
    CustomCommand = 2,
}
---@enum ClientEngineCommandType Types of commands from the host we report to client Lua.
ClientEngineCommandType = {
    PlayerDisconnected = 0,
    CustomCommand = 1,
}
---@enum ColliderFlags 
ColliderFlags = {
    None = 0,
    Disabled = 1,
    SelfHit = 2,
    Hollow = 4,
    EventsDisabled = 8,
}
---@enum ProjectileMovementType 
ProjectileMovementType = {
    Curved = 1,
    Homing = 2,
}
---@enum AnimationPlaybackMode 
AnimationPlaybackMode = {
    Clamp = 0,
    Loop = 1,
    PingPong = 2,
}
---@enum ShadowCastingMode 
ShadowCastingMode = {
    Off = 0,
    On = 1,
    TwoSided = 2,
    ShadowsOnly = 3,
}
---@enum LinePointType 
LinePointType = {
    Position = 0,
    Entity = 1,
}
---@enum LineType 
LineType = {
    Line = 0,
    Curve = 1,
}
---@enum RangeRingMaterial 
RangeRingMaterial = {
    Build = 0,
    Assist = 1,
    IntelRadar = 2,
    IntelSonar = 3,
    IntelOmni = 4,
    IntelCounter = 5,
    AttackDirect = 6,
    AttackIndirect = 7,
    AttackAntiAir = 8,
    AttackAntiNavy = 9,
    AttackCounter = 10,
    BuildHighlighted = 11,
    AssistHighlighted = 12,
    IntelRadarHighlighted = 13,
    IntelSonarHighlighted = 14,
    IntelOmniHighlighted = 15,
    IntelCounterHighlighted = 16,
    AttackDirectHighlighted = 17,
    AttackIndirectHighlighted = 18,
    AttackAntiAirHighlighted = 19,
    AttackAntiNavyHighlighted = 20,
    AttackCounterHighlighted = 21,
    BuildSelected = 22,
    AssistSelected = 23,
    IntelRadarSelected = 24,
    IntelSonarSelected = 25,
    IntelOmniSelected = 26,
    IntelCounterSelected = 27,
    AttackDirectSelected = 28,
    AttackIndirectSelected = 29,
    AttackAntiAirSelected = 30,
    AttackAntiNavySelected = 31,
    AttackCounterSelected = 32,
    FogOfWar = 33,
    Vision = 34,
    WaterVision = 35,
    -- Total number of range ring materials.
    Count = 36,
    None = 65535,
}
---@enum ProgressBarType 
ProgressBarType = {
    Health = 0,
    Orange = 1,
    Blue = 2,
}
---@enum ChatChannel The audience a chat message is addressed to.
ChatChannel = {
    All = 0,
    Team = 1,
    Observers = 2,
}


-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0
Faction.Seraphim = 3