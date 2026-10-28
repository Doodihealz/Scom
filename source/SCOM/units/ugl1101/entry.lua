UnitTemplate = Import("scom/units/ugl1101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl1101", "SCOM unit identity mismatch: ugl1101")
