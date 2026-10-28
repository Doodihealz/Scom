UnitTemplate = Import("scom/units/ucs2601/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2601", "SCOM unit identity mismatch: ucs2601")
