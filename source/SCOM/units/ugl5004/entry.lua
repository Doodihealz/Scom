UnitTemplate = Import("scom/units/ugl5004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl5004", "SCOM unit identity mismatch: ugl5004")
