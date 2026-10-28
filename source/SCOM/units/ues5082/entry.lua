UnitTemplate = Import("scom/units/ues5082/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5082", "SCOM unit identity mismatch: ues5082")
