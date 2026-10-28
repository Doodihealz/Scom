UnitTemplate = Import("scom/units/ucl1002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl1002", "SCOM unit identity mismatch: ucl1002")
