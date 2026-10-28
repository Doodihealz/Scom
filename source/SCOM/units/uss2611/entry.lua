UnitTemplate = Import("scom/units/uss2611/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2611", "SCOM unit identity mismatch: uss2611")
