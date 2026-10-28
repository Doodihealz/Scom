UnitTemplate = Import("scom/units/uss2510/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2510", "SCOM unit identity mismatch: uss2510")
