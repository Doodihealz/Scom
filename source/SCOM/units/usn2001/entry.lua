UnitTemplate = Import("scom/units/usn2001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usn2001", "SCOM unit identity mismatch: usn2001")
