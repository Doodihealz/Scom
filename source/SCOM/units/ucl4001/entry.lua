UnitTemplate = Import("scom/units/ucl4001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl4001", "SCOM unit identity mismatch: ucl4001")
