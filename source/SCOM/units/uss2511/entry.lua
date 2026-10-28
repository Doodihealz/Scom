UnitTemplate = Import("scom/units/uss2511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2511", "SCOM unit identity mismatch: uss2511")
