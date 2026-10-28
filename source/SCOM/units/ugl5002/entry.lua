UnitTemplate = Import("scom/units/ugl5002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl5002", "SCOM unit identity mismatch: ugl5002")
