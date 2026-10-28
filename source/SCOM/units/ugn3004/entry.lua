UnitTemplate = Import("scom/units/ugn3004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugn3004", "SCOM unit identity mismatch: ugn3004")
