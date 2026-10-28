UnitTemplate = Import("scom/units/ucs3401/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3401", "SCOM unit identity mismatch: ucs3401")
