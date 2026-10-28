UnitTemplate = Import("scom/units/ucn3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucn3001", "SCOM unit identity mismatch: ucn3001")
