UnitTemplate = Import("scom/units/ucl4004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl4004", "SCOM unit identity mismatch: ucl4004")
