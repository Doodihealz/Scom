using System;
using System.Collections.Generic;

namespace SupremeCommanderOverhaulCachePatcher;

internal sealed class ModuleSpec
{
	public string Id { get; }

	public string Name { get; }

	public Action Apply { get; }

	public IReadOnlyList<string> RequiredModuleIds { get; }

	public ModuleSpec(string id, string name, Action apply, params string[] requiredModuleIds)
	{
		Id = id ?? throw new ArgumentNullException("id");
		Name = name ?? throw new ArgumentNullException("name");
		Apply = apply ?? throw new ArgumentNullException("apply");
		RequiredModuleIds = requiredModuleIds ?? throw new ArgumentNullException("requiredModuleIds");
	}
}
