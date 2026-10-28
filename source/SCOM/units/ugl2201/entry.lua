UnitTemplate = Import("scom/units/ugl2201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl2201", "SCOM unit identity mismatch: ugl2201")
