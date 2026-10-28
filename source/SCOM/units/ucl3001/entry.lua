UnitTemplate = Import("scom/units/ucl3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl3001", "SCOM unit identity mismatch: ucl3001")
