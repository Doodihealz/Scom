UnitTemplate = Import("scom/units/usn3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usn3001", "SCOM unit identity mismatch: usn3001")
