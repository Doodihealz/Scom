UnitTemplate = Import("scom/units/ucl4401/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl4401", "SCOM unit identity mismatch: ucl4401")
