UnitTemplate = Import("scom/units/ucl2201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl2201", "SCOM unit identity mismatch: ucl2201")
