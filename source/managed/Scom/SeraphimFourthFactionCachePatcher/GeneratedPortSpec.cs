namespace SeraphimFourthFactionCachePatcher;

internal sealed class GeneratedPortSpec
{
	public string TargetId { get; }

	public string SourceId { get; }

	public string Role { get; }

	public string DisplayName { get; }

	public bool Structure { get; }

	public bool IsMobile => !Structure;

	public string ClassName { get; }

	public double CollisionX { get; }

	public double CollisionY { get; }

	public double CollisionZ { get; }

	public double CollisionOffsetX { get; }

	public double CollisionOffsetY { get; }

	public double CollisionOffsetZ { get; }

	public double SelectionX { get; }

	public double SelectionZ { get; }

	public string ConstructionBone { get; }

	public string WalkClip { get; }

	public string BuildClip { get; }

	public double MovementSpeed { get; }

	public double MovementAcceleration { get; }

	public double MovementDeceleration { get; }

	public double MovementRotationSpeed { get; }

	public string MovementType { get; }

	public double MovementMinSpeed { get; }

	public double MovementElevation { get; }

	public bool MovementAirHover { get; }

	public bool MovementLarge { get; }

	public double AnimationWalkRate { get; }

	public double AnimationAuthoredSpeed { get; }

	public string[] AnimationClips { get; }

	public GeneratedWeaponRig[] WeaponRigs { get; }

	public double MaxHealth { get; }

	public double RegenRate { get; }

	public GeneratedEconomySpec Economy { get; }

	public GeneratedIntelSpec Intel { get; }

	public GeneratedShieldSpec? Shield { get; }

	public GeneratedPlacementSpec Placement { get; }

	public string[] AddTags { get; }

	public string[] RemoveTags { get; }

	public string EconomyProfile { get; }

	public GeneratedPortSpec(string targetId, string sourceId, string role, string displayName, bool structure, string className, double collisionX, double collisionY, double collisionZ, double collisionOffsetX, double collisionOffsetY, double collisionOffsetZ, double selectionX, double selectionZ, string constructionBone, string walkClip, string buildClip, double movementSpeed, double movementAcceleration, double movementDeceleration, double movementRotationSpeed, string movementType, double movementMinSpeed, double movementElevation, bool movementAirHover, bool movementLarge, double animationWalkRate, double animationAuthoredSpeed, string[] animationClips, GeneratedWeaponRig[] weaponRigs, double maxHealth, double regenRate, GeneratedEconomySpec economy, GeneratedIntelSpec intel, GeneratedShieldSpec? shield, GeneratedPlacementSpec placement, string[] addTags, string[] removeTags, string economyProfile)
	{
		TargetId = targetId;
		SourceId = sourceId;
		Role = role;
		DisplayName = displayName;
		Structure = structure;
		ClassName = className;
		CollisionX = collisionX;
		CollisionY = collisionY;
		CollisionZ = collisionZ;
		CollisionOffsetX = collisionOffsetX;
		CollisionOffsetY = collisionOffsetY;
		CollisionOffsetZ = collisionOffsetZ;
		SelectionX = selectionX;
		SelectionZ = selectionZ;
		ConstructionBone = constructionBone;
		WalkClip = walkClip;
		BuildClip = buildClip;
		MovementSpeed = movementSpeed;
		MovementAcceleration = movementAcceleration;
		MovementDeceleration = movementDeceleration;
		MovementRotationSpeed = movementRotationSpeed;
		MovementType = movementType;
		MovementMinSpeed = movementMinSpeed;
		MovementElevation = movementElevation;
		MovementAirHover = movementAirHover;
		MovementLarge = movementLarge;
		AnimationWalkRate = animationWalkRate;
		AnimationAuthoredSpeed = animationAuthoredSpeed;
		AnimationClips = animationClips;
		WeaponRigs = weaponRigs;
		MaxHealth = maxHealth;
		RegenRate = regenRate;
		Economy = economy;
		Intel = intel;
		Shield = shield;
		Placement = placement;
		AddTags = addTags;
		RemoveTags = removeTags;
		EconomyProfile = economyProfile;
	}
}
