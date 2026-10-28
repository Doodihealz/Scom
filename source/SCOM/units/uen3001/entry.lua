UnitTemplate = Import("scom/units/uen3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uen3001", "SCOM unit identity mismatch: uen3001")
