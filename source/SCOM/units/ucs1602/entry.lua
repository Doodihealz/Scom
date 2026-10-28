UnitTemplate = Import("scom/units/ucs1602/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1602", "SCOM unit identity mismatch: ucs1602")
