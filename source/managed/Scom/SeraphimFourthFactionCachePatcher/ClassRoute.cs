namespace SeraphimFourthFactionCachePatcher;

internal sealed class ClassRoute
{
	public string ChosenClassName { get; }

	public string SeraphimClassName { get; }

	public string BaseClassName { get; }

	public ClassRoute(string chosenClassName, string seraphimClassName, string baseClassName)
	{
		ChosenClassName = chosenClassName;
		SeraphimClassName = seraphimClassName;
		BaseClassName = baseClassName;
	}
}
