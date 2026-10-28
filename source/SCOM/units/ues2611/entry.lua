UnitTemplate = Import("scom/units/ues2611/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2611", "SCOM unit identity mismatch: ues2611")
