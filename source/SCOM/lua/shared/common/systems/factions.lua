FactionsData = {
    {
        name = "EDA",
        tpLetter = "ue",
        tag = "EDA",
        initialUnit = "uel0000",
    },
    {
        name = "Chosen",
        tpLetter = "uc",
        tag = "CHOSEN",
        initialUnit = "ucl0000",
    },
    {
        name = "Guard",
        tpLetter = "ug",
        tag = "GUARD",
        initialUnit = "ugl0000",
    },
}

function GetUnitFactionData(unit)
    for i, fac in pairs(FactionsData) do
        if unit:HasTags(Tags[fac.tag]) then
            return i, fac.name, fac.tag
        end
    end
    Warn("Faction - GetUnitFactionData: Unknown faction, unit: "..unit.id.index..", tpId: "..unit.tp.general.tpId.." has no faction tag.")
end

-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0
-- Native enum value 3 maps to this Lua table index 4 (`faction + 1`).
do
    if FactionsData[4] ~= nil then
        error("Seraphim fourth-faction patch expected FactionsData[4] to be unused.")
    end

    FactionsData[4] = {
        name = "Seraphim",
        tpLetter = "us",
        tag = "SERAPHIM",
        initialUnit = "usl0000",
    }
end