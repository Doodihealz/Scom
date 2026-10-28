UnitTemplate = Import("scom/units/uss2301/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2301", "SCOM unit identity mismatch: uss2301")
