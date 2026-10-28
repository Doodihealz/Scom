UnitTemplate = Import("scom/units/uen3005/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uen3005", "SCOM unit identity mismatch: uen3005")
