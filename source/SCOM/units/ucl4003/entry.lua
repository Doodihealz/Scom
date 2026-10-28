UnitTemplate = Import("scom/units/ucl4003/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl4003", "SCOM unit identity mismatch: ucl4003")
