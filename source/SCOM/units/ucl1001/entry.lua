UnitTemplate = Import("scom/units/ucl1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl1001", "SCOM unit identity mismatch: ucl1001")
