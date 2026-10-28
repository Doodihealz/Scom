UnitTemplate = Import("scom/units/ucl1701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl1701", "SCOM unit identity mismatch: ucl1701")
