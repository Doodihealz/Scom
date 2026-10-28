UnitTemplate = Import("scom/units/ucl2101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl2101", "SCOM unit identity mismatch: ucl2101")
