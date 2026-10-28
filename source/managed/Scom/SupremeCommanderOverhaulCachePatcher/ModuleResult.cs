using System;

namespace SupremeCommanderOverhaulCachePatcher;

internal sealed class ModuleResult
{
	public ModuleSpec Module { get; }

	public ModuleStatus Status { get; }

	public string Detail { get; }

	public Exception? Exception { get; }

	private ModuleResult(ModuleSpec module, ModuleStatus status, string detail, Exception? exception)
	{
		Module = module;
		Status = status;
		Detail = detail;
		Exception = exception;
	}

	public static ModuleResult Applied(ModuleSpec module)
	{
		return new ModuleResult(module, ModuleStatus.Applied, "applied", null);
	}

	public static ModuleResult Failed(ModuleSpec module, Exception exception)
	{
		return new ModuleResult(module, ModuleStatus.Failed, exception.Message, exception);
	}

	public static ModuleResult Skipped(ModuleSpec module, string detail)
	{
		return new ModuleResult(module, ModuleStatus.Skipped, detail, null);
	}
}
