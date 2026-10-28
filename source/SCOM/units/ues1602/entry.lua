UnitTemplate = Import("scom/units/ues1602/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues1602", "SCOM unit identity mismatch: ues1602")
