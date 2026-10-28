UnitTemplate = Import("scom/units/ucs5007/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs5007", "SCOM unit identity mismatch: ucs5007")
