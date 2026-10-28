UnitTemplate = Import("scom/units/ues2701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2701", "SCOM unit identity mismatch: ues2701")
