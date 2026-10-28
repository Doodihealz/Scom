namespace CommanderEnhancementsCachePatcher;

internal sealed class RemovalRule
{
	internal string Id { get; }

	internal string Name { get; }

	internal string NameLocKey { get; }

	internal EnhancementCost Cost { get; }

	internal CapabilityRule Capabilities { get; }

	internal string Runtime { get; }

	internal RemovalRule(string id, string name, string nameLocKey, EnhancementCost cost, CapabilityRule capabilities, string runtime)
	{
		Id = id;
		Name = name;
		NameLocKey = nameLocKey;
		Cost = cost;
		Capabilities = capabilities;
		Runtime = runtime;
	}
}
