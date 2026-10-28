UnitTemplate = Import("scom/units/uss2201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2201", "SCOM unit identity mismatch: uss2201")
