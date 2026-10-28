UnitTemplate = Import("scom/units/ugl1002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl1002", "SCOM unit identity mismatch: ugl1002")
