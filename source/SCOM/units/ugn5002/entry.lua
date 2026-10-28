UnitTemplate = Import("scom/units/ugn5002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugn5002", "SCOM unit identity mismatch: ugn5002")
