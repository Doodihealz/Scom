UnitTemplate = Import("scom/units/ucl9505/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl9505", "SCOM unit identity mismatch: ucl9505")
