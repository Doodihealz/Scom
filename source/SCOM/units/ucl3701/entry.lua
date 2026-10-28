UnitTemplate = Import("scom/units/ucl3701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl3701", "SCOM unit identity mismatch: ucl3701")
