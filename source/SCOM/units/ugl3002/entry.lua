UnitTemplate = Import("scom/units/ugl3002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl3002", "SCOM unit identity mismatch: ugl3002")
