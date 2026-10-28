UnitTemplate = Import("scom/units/ugl3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl3001", "SCOM unit identity mismatch: ugl3001")
