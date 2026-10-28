UnitTemplate = Import("scom/units/ugs1602/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs1602", "SCOM unit identity mismatch: ugs1602")
