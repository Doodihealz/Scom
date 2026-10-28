UnitTemplate = Import("scom/units/usn3004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usn3004", "SCOM unit identity mismatch: usn3004")
