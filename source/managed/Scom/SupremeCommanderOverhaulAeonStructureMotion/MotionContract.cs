using System.Collections.Generic;
using System.Linq;

namespace SupremeCommanderOverhaulAeonStructureMotion;

public sealed class MotionContract
{
	public string TargetId { get; }

	public string SourceId { get; }

	public string ClassName { get; }

	public string Role { get; }

	public string Kind { get; }

	public MotionStatus Status { get; }

	public string SourceArchiveSha256 => "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	public string SourceBlueprintPath => "units/" + SourceId + "/" + SourceId + "_unit.bp";

	public string SourceBlueprintSha256 { get; }

	public string SourceScriptPath => "units/" + SourceId + "/" + SourceId + "_script.lua";

	public string SourceScriptSha256 { get; }

	public string SourceModelPath => "units/" + SourceId + "/" + SourceId + "_lod0.scm";

	public string SourceModelSha256 { get; }

	public string TemplatePath => "LJ/lua/common/units/unitsTemplates/" + TargetId + "/" + TargetId + ".santp";

	public AssetPin TargetModel { get; }

	public AssetPin TargetSkeleton { get; }

	public AssetPin TargetAnimation { get; }

	public int TargetClipCount { get; }

	public IReadOnlyList<string> RequiredBones { get; }

	public IReadOnlyList<string> RotatorBones { get; }

	public IReadOnlyList<ClipPin> Clips { get; }

	public StorageClipPin? StorageClip { get; }

	public string StateContract { get; }

	public string Blocker { get; }

	public string FutureRequirement { get; }

	public string AuditedLimitation { get; }

	public bool HasUpgradeClip => Clips.Any((ClipPin clip) => clip.Role == "upgrade");

	public ClipPin? DeathClip => Clips.SingleOrDefault((ClipPin clip) => clip.Role == "death");

	public MotionContract(string targetId, string sourceId, string className, string role, string kind, MotionStatus status, string sourceBlueprintSha256, string sourceScriptSha256, string sourceModelSha256, AssetPin targetModel, AssetPin targetSkeleton, AssetPin targetAnimation, int targetClipCount, IEnumerable<string> requiredBones, IEnumerable<ClipPin> clips, string stateContract, string blocker = "", string futureRequirement = "", string auditedLimitation = "", IEnumerable<string>? rotatorBones = null, StorageClipPin? storageClip = null)
	{
		TargetId = targetId;
		SourceId = sourceId;
		ClassName = className;
		Role = role;
		Kind = kind;
		Status = status;
		SourceBlueprintSha256 = sourceBlueprintSha256;
		SourceScriptSha256 = sourceScriptSha256;
		SourceModelSha256 = sourceModelSha256;
		TargetModel = targetModel;
		TargetSkeleton = targetSkeleton;
		TargetAnimation = targetAnimation;
		TargetClipCount = targetClipCount;
		RequiredBones = requiredBones.ToArray();
		RotatorBones = (rotatorBones ?? requiredBones).ToArray();
		Clips = clips.ToArray();
		StorageClip = storageClip;
		StateContract = stateContract;
		Blocker = blocker;
		FutureRequirement = futureRequirement;
		AuditedLimitation = auditedLimitation;
	}
}
