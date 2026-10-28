using System;
using System.Collections.Generic;

namespace SupremeCommanderOverhaulSeaParity;

public sealed class SeaTemplateSpec
{
	public string TargetId { get; }

	public string SourceId { get; }

	public string FactionTag { get; }

	public int Tier { get; }

	public SeaTemplateKind Kind { get; }

	public string ClassModule { get; }

	public string RuntimeClass { get; }

	public string? UpgradeTo { get; }

	public string? PlatformBone { get; }

	public IReadOnlyList<string> BuildBones { get; }

	public bool RequiresWater => Kind != SeaTemplateKind.AirFactory;

	public SeaTemplateSpec(string targetId, string sourceId, string factionTag, int tier, SeaTemplateKind kind, string classModule, string runtimeClass, string? upgradeTo = null, string? platformBone = null, params string[] buildBones)
	{
		TargetId = targetId;
		SourceId = sourceId;
		FactionTag = factionTag;
		Tier = tier;
		Kind = kind;
		ClassModule = classModule;
		RuntimeClass = runtimeClass;
		UpgradeTo = upgradeTo;
		PlatformBone = platformBone;
		BuildBones = Array.AsReadOnly(buildBones ?? Array.Empty<string>());
	}
}
