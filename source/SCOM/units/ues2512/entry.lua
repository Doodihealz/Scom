UnitTemplate = Import("scom/units/ues2512/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2512", "SCOM unit identity mismatch: ues2512")
