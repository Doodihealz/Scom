UnitTemplate = Import("scom/units/ucn5001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucn5001", "SCOM unit identity mismatch: ucn5001")
