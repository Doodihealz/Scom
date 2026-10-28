using System;
using System.IO;

namespace ScomFieldFixes;

internal static class TacticalMissileContracts
{
	internal static readonly string[] UnitIds = new string[8] { "ues2102", "ucs2102", "ugs2102", "uss2102", "ues2402", "ucs2402", "ugs2402", "uss2402" };

	internal static readonly string[] ProjectileIds = new string[9] { "pst001", "pst002", "pst003", "pst004", "pst005", "pst006", "pst007", "pst008", "pst009" };

	internal const string WeaponAppendix = "\n-- SCOM tactical stock-weapon exclusion 1.0.0\ndo\n    if not HostWeapon.scoTacticalUpdateInstalled then\n        local previous = HostWeapon.Update\n        function HostWeapon:Update(...)\n            if self.tp and self.tp.scoTacticalOwned == true then return end\n            return previous(self, ...)\n        end\n        HostWeapon.scoTacticalUpdateInstalled = true\n    end\nend\n";

	internal static string UnitOverride(string id)
	{
		if (Array.IndexOf<string>(UnitIds, id) < 0)
		{
			throw new ArgumentException("Unscoped tactical unit", "id");
		}
		return Read("ScomFieldFixes.Tactical." + id + ".santp");
	}

	internal static string ProjectileTemplate(string id)
	{
		if (Array.IndexOf<string>(ProjectileIds, id) < 0)
		{
			throw new ArgumentException("Unscoped tactical projectile", "id");
		}
		return Read("ScomFieldFixes.Tactical." + id + ".santp");
	}

	private static string Read(string name)
	{
		using Stream stream = typeof(TacticalMissileContracts).Assembly.GetManifestResourceStream(name) ?? throw new InvalidOperationException("Missing tactical embedded resource " + name);
		using StreamReader streamReader = new StreamReader(stream);
		return streamReader.ReadToEnd().Replace("\r\n", "\n");
	}
}
