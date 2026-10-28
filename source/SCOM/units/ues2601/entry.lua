UnitTemplate = Import("scom/units/ues2601/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2601", "SCOM unit identity mismatch: ues2601")
