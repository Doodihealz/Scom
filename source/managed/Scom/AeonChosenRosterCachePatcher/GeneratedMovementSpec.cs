namespace AeonChosenRosterCachePatcher;

internal sealed class GeneratedMovementSpec
{
	internal bool Enabled { get; }

	internal string SourceMotionType { get; }

	internal string SanctuaryType { get; }

	internal string CompatibilityNote { get; }

	internal double Elevation { get; }

	internal double LiftCoefficient { get; }

	internal double LiftDamping { get; }

	internal double LiftFactor { get; }

	internal double ConstructionSurfaceClearance { get; }

	internal string ConstructionSurfaceModelEntry { get; }

	internal string ConstructionSurfaceModelSha256 { get; }

	internal double Speed { get; }

	internal double MinSpeed { get; }

	internal double Acceleration { get; }

	internal double SourceMaxBrake { get; }

	internal bool HasSourceMaxBrake { get; }

	internal double RotationSpeed { get; }

	internal bool Air { get; }

	internal bool AirHover { get; }

	internal string RunClip { get; }

	internal double WalkRate { get; }

	internal double AuthoredSpeed { get; }

	internal GeneratedMovementSpec(bool enabled, string sourceMotionType, string sanctuaryType, string compatibilityNote, double elevation, double liftCoefficient, double liftDamping, double liftFactor, double constructionSurfaceClearance, string constructionSurfaceModelEntry, string constructionSurfaceModelSha256, double speed, double minSpeed, double acceleration, double sourceMaxBrake, bool hasSourceMaxBrake, double rotationSpeed, bool air, bool airHover, string runClip, double walkRate, double authoredSpeed)
	{
		Enabled = enabled;
		SourceMotionType = sourceMotionType;
		SanctuaryType = sanctuaryType;
		CompatibilityNote = compatibilityNote;
		Elevation = elevation;
		LiftCoefficient = liftCoefficient;
		LiftDamping = liftDamping;
		LiftFactor = liftFactor;
		ConstructionSurfaceClearance = constructionSurfaceClearance;
		ConstructionSurfaceModelEntry = constructionSurfaceModelEntry;
		ConstructionSurfaceModelSha256 = constructionSurfaceModelSha256;
		Speed = speed;
		MinSpeed = minSpeed;
		Acceleration = acceleration;
		SourceMaxBrake = sourceMaxBrake;
		HasSourceMaxBrake = hasSourceMaxBrake;
		RotationSpeed = rotationSpeed;
		Air = air;
		AirHover = airHover;
		RunClip = runClip;
		WalkRate = walkRate;
		AuthoredSpeed = authoredSpeed;
	}
}
