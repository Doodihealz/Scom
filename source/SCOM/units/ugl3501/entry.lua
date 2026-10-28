UnitTemplate = Import("scom/units/ugl3501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl3501", "SCOM unit identity mismatch: ugl3501")
