UnitTemplate = Import("scom/units/ucl2002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl2002", "SCOM unit identity mismatch: ucl2002")
