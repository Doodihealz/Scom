UnitTemplate = Import("scom/units/uen3004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uen3004", "SCOM unit identity mismatch: uen3004")
