UnitTemplate = Import("scom/units/ucs5004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs5004", "SCOM unit identity mismatch: ucs5004")
