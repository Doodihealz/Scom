UnitTemplate = Import("scom/units/ugl4002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl4002", "SCOM unit identity mismatch: ugl4002")
