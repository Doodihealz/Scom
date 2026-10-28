UnitTemplate = Import("scom/units/uen2001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uen2001", "SCOM unit identity mismatch: uen2001")
