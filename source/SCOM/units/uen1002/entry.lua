UnitTemplate = Import("scom/units/uen1002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uen1002", "SCOM unit identity mismatch: uen1002")
