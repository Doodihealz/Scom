UnitTemplate = Import("scom/units/uss2402/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2402", "SCOM unit identity mismatch: uss2402")
