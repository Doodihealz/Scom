UnitTemplate = Import("scom/units/ucs3702/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3702", "SCOM unit identity mismatch: ucs3702")
