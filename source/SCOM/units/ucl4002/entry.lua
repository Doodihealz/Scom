UnitTemplate = Import("scom/units/ucl4002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl4002", "SCOM unit identity mismatch: ucl4002")
