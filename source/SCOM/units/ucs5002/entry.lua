UnitTemplate = Import("scom/units/ucs5002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs5002", "SCOM unit identity mismatch: ucs5002")
