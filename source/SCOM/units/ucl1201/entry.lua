UnitTemplate = Import("scom/units/ucl1201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl1201", "SCOM unit identity mismatch: ucl1201")
