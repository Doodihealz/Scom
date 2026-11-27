using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Scom.Playtest26907462
{
    public static class ObserverEconomyRepairs
    {
        public static void Apply(string engineRoot, IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result)
        {
            Edit(engineRoot, stock, result, "client/ui/playerListPanel.lua", new Func<string, string>(RepairPlayerList));
            Edit(engineRoot, stock, result, "client/ui/uiManager.lua", new Func<string, string>(RepairUIManager));
            Edit(engineRoot, stock, result, "client/ui/economyPanel.lua", new Func<string, string>(RepairEconomyPanel));
        }

        private static string RepairPlayerList(string text)
        {
            text = Replace(text, "local ticksPerSecond = 10", "local ticksPerSecond = Constants.TickRate");
            text = Replace(text, "    if GetFocusArmy() == armyId then", "    if not IsObserver() or Armies[armyId] == nil then return end\n    if GetFocusArmy() == armyId then");
            return Replace(text, "Engine.UI_SetButtonDisabled(entryID, focus ~= -1 and focus ~= armyId)", "Engine.UI_SetButtonDisabled(entryID, false)");
        }

        private static string RepairUIManager(string text)
        {
            return Replace(text,
                "    if GetFocusArmy() > -1 then\n        Panels.EconomyPanel:UpdateEconomy(Armies[GetFocusArmy()].economy)\n    end",
                "    local focusId = GetFocusArmy()\n" +
                "    local focusArmy = Armies[focusId]\n" +
                "    -- In observer All view, selection chooses displayed economy only.\n" +
                "    -- Explicit focus, fog, selection and control authority stay native.\n" +
                "    if focusId == -1 and IsObserver() then\n" +
                "        local selectedArmyId, mixedSelection = nil, false\n" +
                "        for _, entity in pairs(selectedEntities) do\n" +
                "            local armyId = entity.armyId\n" +
                "            local army = Armies[armyId]\n" +
                "            local options = army and army.lobbyOptions\n" +
                "            if not army or army.civilian or (options and options.isEmptySlot)\n" +
                "                or entity.dead or entity.deleted then\n" +
                "                mixedSelection = true\n" +
                "                break\n" +
                "            end\n" +
                "            if selectedArmyId ~= nil and selectedArmyId ~= armyId then\n" +
                "                mixedSelection = true\n" +
                "                break\n" +
                "            end\n" +
                "            selectedArmyId = armyId\n" +
                "        end\n" +
                "        if not mixedSelection then focusArmy = Armies[selectedArmyId] end\n" +
                "    end\n" +
                "    Panels.EconomyPanel:UpdateEconomy(focusArmy and focusArmy.economy)");
        }

        private static string RepairEconomyPanel(string text)
        {
            text = Replace(text, "function EconomyPanel:UpdateEconomy(data)", "function EconomyPanel:UpdateEconomy(data)\n    data = data or {}\n    local alloys = data.alloys or {}\n    local energy = data.energy or {}");
            return text.Replace("data.alloys.", "alloys.").Replace("data.energy.", "energy.");
        }

        private static void Edit(string engine, IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result, string route, Func<string, string> transform)
        {
            string key = Path.Combine(engine, "lua", route.Replace('/', Path.DirectorySeparatorChar));
            byte[] bytes;
            if (!result.TryGetValue(key, out bytes) && !stock.TryGetValue(key, out bytes)) throw new InvalidDataException("Missing observer UI source: " + key);
            string text = Encoding.UTF8.GetString(bytes).Replace("\r\n", "\n");
            result[key] = Encoding.UTF8.GetBytes(transform(text));
        }

        private static string Replace(string text, string before, string after)
        {
            int first = text.IndexOf(before, StringComparison.Ordinal);
            if (first < 0 || text.IndexOf(before, first + before.Length, StringComparison.Ordinal) >= 0)
                throw new InvalidDataException("Observer UI anchor missing or repeated: " + before);
            return text.Substring(0, first) + after + text.Substring(first + before.Length);
        }
    }
}
