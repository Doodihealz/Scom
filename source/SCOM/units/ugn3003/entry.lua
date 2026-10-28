UnitTemplate = Import("scom/units/ugn3003/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugn3003", "SCOM unit identity mismatch: ugn3003")
