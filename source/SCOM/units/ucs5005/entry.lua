UnitTemplate = Import("scom/units/ucs5005/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs5005", "SCOM unit identity mismatch: ucs5005")
