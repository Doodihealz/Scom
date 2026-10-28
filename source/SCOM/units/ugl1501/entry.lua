UnitTemplate = Import("scom/units/ugl1501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl1501", "SCOM unit identity mismatch: ugl1501")
