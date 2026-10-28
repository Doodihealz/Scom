UnitTemplate = Import("scom/units/ucs5006/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs5006", "SCOM unit identity mismatch: ucs5006")
