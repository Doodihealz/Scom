UnitTemplate = Import("scom/units/ucl0000/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl0000", "SCOM unit identity mismatch: ucl0000")
