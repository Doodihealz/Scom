UnitTemplate = Import("scom/units/ues5090/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5090", "SCOM unit identity mismatch: ues5090")
