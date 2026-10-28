UnitTemplate = Import("scom/units/ucl3501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl3501", "SCOM unit identity mismatch: ucl3501")
