UnitTemplate = Import("scom/units/uss2512/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2512", "SCOM unit identity mismatch: uss2512")
