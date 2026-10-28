UnitTemplate = Import("scom/units/ugn1002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugn1002", "SCOM unit identity mismatch: ugn1002")
