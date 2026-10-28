UnitTemplate = Import("scom/units/ucl5001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl5001", "SCOM unit identity mismatch: ucl5001")
