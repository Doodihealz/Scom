UnitTemplate = Import("scom/units/ucs4102/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs4102", "SCOM unit identity mismatch: ucs4102")
