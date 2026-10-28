UnitTemplate = Import("scom/units/ugs2601/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2601", "SCOM unit identity mismatch: ugs2601")
