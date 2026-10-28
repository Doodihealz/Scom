UnitTemplate = Import("scom/units/usn1002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usn1002", "SCOM unit identity mismatch: usn1002")
