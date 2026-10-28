UnitTemplate = Import("scom/units/uss2101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2101", "SCOM unit identity mismatch: uss2101")
