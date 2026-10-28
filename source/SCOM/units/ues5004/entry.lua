UnitTemplate = Import("scom/units/ues5004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5004", "SCOM unit identity mismatch: ues5004")
