UnitTemplate = Import("scom/units/uen1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uen1001", "SCOM unit identity mismatch: uen1001")
