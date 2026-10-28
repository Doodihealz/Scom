UnitTemplate = Import("scom/units/ues3512/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues3512", "SCOM unit identity mismatch: ues3512")
