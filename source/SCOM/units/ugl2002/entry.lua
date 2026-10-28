UnitTemplate = Import("scom/units/ugl2002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl2002", "SCOM unit identity mismatch: ugl2002")
