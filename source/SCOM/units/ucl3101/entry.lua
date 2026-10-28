UnitTemplate = Import("scom/units/ucl3101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl3101", "SCOM unit identity mismatch: ucl3101")
