UnitTemplate = Import("scom/units/usn2002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usn2002", "SCOM unit identity mismatch: usn2002")
