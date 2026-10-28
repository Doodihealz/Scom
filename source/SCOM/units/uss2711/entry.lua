UnitTemplate = Import("scom/units/uss2711/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2711", "SCOM unit identity mismatch: uss2711")
