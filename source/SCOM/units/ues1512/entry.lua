UnitTemplate = Import("scom/units/ues1512/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues1512", "SCOM unit identity mismatch: ues1512")
