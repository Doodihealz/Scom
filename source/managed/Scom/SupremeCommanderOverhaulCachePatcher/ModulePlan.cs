using System;
using System.Collections.Generic;
using System.Linq;

namespace SupremeCommanderOverhaulCachePatcher;

internal static class ModulePlan
{
	public static IReadOnlyList<ModuleResult> Run(IReadOnlyList<ModuleSpec> modules)
	{
		if (modules == null)
		{
			throw new ArgumentNullException("modules");
		}
		IGrouping<string, ModuleSpec> grouping = modules.GroupBy<ModuleSpec, string>((ModuleSpec module) => module.Id, StringComparer.Ordinal).FirstOrDefault((IGrouping<string, ModuleSpec> group) => group.Count() > 1);
		if (grouping != null)
		{
			throw new InvalidOperationException("The module plan contains duplicate id '" + grouping.Key + "'.");
		}
		List<ModuleResult> list = new List<ModuleResult>(modules.Count);
		Dictionary<string, ModuleResult> resultsById = new Dictionary<string, ModuleResult>(StringComparer.Ordinal);
		foreach (ModuleSpec module in modules)
		{
			string[] array = (from dependency in module.RequiredModuleIds.Select(delegate(string requiredId)
				{
					resultsById.TryGetValue(requiredId, out ModuleResult value);
					return (requiredId: requiredId, result: value);
				})
				where dependency.result == null || dependency.result.Status != ModuleStatus.Applied
				select dependency.requiredId).ToArray();
			ModuleResult moduleResult;
			if (array.Length != 0)
			{
				moduleResult = ModuleResult.Skipped(module, "required module(s) unavailable: " + string.Join(", ", array));
			}
			else
			{
				try
				{
					module.Apply();
					moduleResult = ModuleResult.Applied(module);
				}
				catch (Exception exception)
				{
					moduleResult = ModuleResult.Failed(module, exception);
				}
			}
			list.Add(moduleResult);
			resultsById.Add(module.Id, moduleResult);
		}
		return list;
	}
}
