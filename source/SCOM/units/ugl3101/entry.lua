UnitTemplate = Import("scom/units/ugl3101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl3101", "SCOM unit identity mismatch: ugl3101")
