UnitTemplate = Import("scom/units/ues2101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2101", "SCOM unit identity mismatch: ues2101")
