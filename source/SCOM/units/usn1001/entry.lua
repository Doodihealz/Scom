UnitTemplate = Import("scom/units/usn1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usn1001", "SCOM unit identity mismatch: usn1001")
