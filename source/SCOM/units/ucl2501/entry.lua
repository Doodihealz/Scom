UnitTemplate = Import("scom/units/ucl2501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl2501", "SCOM unit identity mismatch: ucl2501")
