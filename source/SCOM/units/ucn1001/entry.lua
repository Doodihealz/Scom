UnitTemplate = Import("scom/units/ucn1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucn1001", "SCOM unit identity mismatch: ucn1001")
