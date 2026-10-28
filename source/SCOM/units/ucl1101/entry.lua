UnitTemplate = Import("scom/units/ucl1101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl1101", "SCOM unit identity mismatch: ucl1101")
