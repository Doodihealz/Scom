UnitTemplate = Import("scom/units/ucl4005/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl4005", "SCOM unit identity mismatch: ucl4005")
