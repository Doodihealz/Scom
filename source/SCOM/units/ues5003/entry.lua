UnitTemplate = Import("scom/units/ues5003/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5003", "SCOM unit identity mismatch: ues5003")
