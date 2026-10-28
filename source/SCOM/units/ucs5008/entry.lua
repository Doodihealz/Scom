UnitTemplate = Import("scom/units/ucs5008/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs5008", "SCOM unit identity mismatch: ucs5008")
