UnitTemplate = Import("scom/units/uss4102/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss4102", "SCOM unit identity mismatch: uss4102")
