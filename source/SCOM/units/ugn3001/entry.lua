UnitTemplate = Import("scom/units/ugn3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugn3001", "SCOM unit identity mismatch: ugn3001")
