UnitTemplate = Import("scom/units/uss2102/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2102", "SCOM unit identity mismatch: uss2102")
