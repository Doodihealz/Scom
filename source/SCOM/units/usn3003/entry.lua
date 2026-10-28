UnitTemplate = Import("scom/units/usn3003/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usn3003", "SCOM unit identity mismatch: usn3003")
