UnitTemplate = Import("scom/units/ugl2101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl2101", "SCOM unit identity mismatch: ugl2101")
