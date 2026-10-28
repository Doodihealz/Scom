UnitTemplate = Import("scom/units/ugn3005/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugn3005", "SCOM unit identity mismatch: ugn3005")
