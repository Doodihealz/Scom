using System.Collections.Generic;
using Scom.CurrentRepairs;
using Scom.Playtest26880003;
using Scom.Playtest26907462;

namespace Scom.Playtest
{
    public static class GameplayPresentation
    {
        public static void Apply(string engine, string mod, IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result)
        {
            GroundContacts.Apply(engine, mod, stock, result);
            ObserverEconomyRepairs.Apply(engine, stock, result);
            TransportColossus.Apply(engine, mod, stock, result);
        }
    }
}
