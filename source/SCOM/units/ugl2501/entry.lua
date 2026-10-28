UnitTemplate = Import("scom/units/ugl2501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl2501", "SCOM unit identity mismatch: ugl2501")
