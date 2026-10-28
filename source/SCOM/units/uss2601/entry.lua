UnitTemplate = Import("scom/units/uss2601/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2601", "SCOM unit identity mismatch: uss2601")
