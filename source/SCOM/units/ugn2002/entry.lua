UnitTemplate = Import("scom/units/ugn2002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugn2002", "SCOM unit identity mismatch: ugn2002")
