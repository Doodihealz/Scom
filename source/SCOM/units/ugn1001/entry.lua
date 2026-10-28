UnitTemplate = Import("scom/units/ugn1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugn1001", "SCOM unit identity mismatch: ugn1001")
