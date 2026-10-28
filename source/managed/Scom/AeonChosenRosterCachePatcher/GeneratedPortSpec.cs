namespace AeonChosenRosterCachePatcher;

internal sealed class GeneratedPortSpec
{
	internal string TargetId { get; }

	internal string SourceId { get; }

	internal string Role { get; }

	internal string ClassName { get; }

	internal string DisplayName { get; }

	internal bool Structure { get; }

	internal bool RosterVisible { get; }

	internal bool HasVisualAsset { get; }

	internal string SourceBlueprintEntry { get; }

	internal string SourceBlueprintHash { get; }

	internal string[] SourceCategories { get; }

	internal string SourceUpgradeFrom { get; }

	internal string SourceUpgradeTo { get; }

	internal double Health { get; }

	internal double Regeneration { get; }

	internal double CollisionX { get; }

	internal double CollisionY { get; }

	internal double CollisionZ { get; }

	internal double CollisionOffsetX { get; }

	internal double CollisionOffsetY { get; }

	internal double CollisionOffsetZ { get; }

	internal double SelectionX { get; }

	internal double SelectionZ { get; }

	internal string ConstructionBone { get; }

	internal string[] AnimationClips { get; }

	internal GeneratedPlacementSpec Placement { get; }

	internal GeneratedIntelSpec Intel { get; }

	internal GeneratedShieldSpec Shield { get; }

	internal GeneratedMovementSpec Movement { get; }

	internal GeneratedEconomySpec Economy { get; }

	internal GeneratedWeaponSpec[] Weapons { get; }

	internal GeneratedCzarBeamHook CzarBeam { get; }

	internal GeneratedPortSpec(string targetId, string sourceId, string role, string className, string displayName, bool structure, bool rosterVisible, bool hasVisualAsset, string sourceBlueprintEntry, string sourceBlueprintHash, string[] sourceCategories, string sourceUpgradeFrom, string sourceUpgradeTo, double health, double regeneration, double collisionX, double collisionY, double collisionZ, double collisionOffsetX, double collisionOffsetY, double collisionOffsetZ, double selectionX, double selectionZ, string constructionBone, string[] animationClips, GeneratedPlacementSpec placement, GeneratedIntelSpec intel, GeneratedShieldSpec shield, GeneratedMovementSpec movement, GeneratedEconomySpec economy, GeneratedWeaponSpec[] weapons, GeneratedCzarBeamHook czarBeam)
	{
		TargetId = targetId;
		SourceId = sourceId;
		Role = role;
		ClassName = className;
		DisplayName = displayName;
		Structure = structure;
		RosterVisible = rosterVisible;
		HasVisualAsset = hasVisualAsset;
		SourceBlueprintEntry = sourceBlueprintEntry;
		SourceBlueprintHash = sourceBlueprintHash;
		SourceCategories = sourceCategories;
		SourceUpgradeFrom = sourceUpgradeFrom;
		SourceUpgradeTo = sourceUpgradeTo;
		Health = health;
		Regeneration = regeneration;
		CollisionX = collisionX;
		CollisionY = collisionY;
		CollisionZ = collisionZ;
		CollisionOffsetX = collisionOffsetX;
		CollisionOffsetY = collisionOffsetY;
		CollisionOffsetZ = collisionOffsetZ;
		SelectionX = selectionX;
		SelectionZ = selectionZ;
		ConstructionBone = constructionBone;
		AnimationClips = animationClips;
		Placement = placement;
		Intel = intel;
		Shield = shield;
		Movement = movement;
		Economy = economy;
		Weapons = weapons;
		CzarBeam = czarBeam;
	}
}
