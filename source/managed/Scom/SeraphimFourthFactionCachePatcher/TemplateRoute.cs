namespace SeraphimFourthFactionCachePatcher;

internal readonly struct TemplateRoute
{
	public string SeraphimId { get; }

	public string ChosenId { get; }

	public TemplateRoute(string seraphimId, string chosenId)
	{
		SeraphimId = seraphimId;
		ChosenId = chosenId;
	}
}
