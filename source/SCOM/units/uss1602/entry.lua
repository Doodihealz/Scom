UnitTemplate = Import("scom/units/uss1602/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss1602", "SCOM unit identity mismatch: uss1602")
