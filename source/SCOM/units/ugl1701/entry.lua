UnitTemplate = Import("scom/units/ugl1701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl1701", "SCOM unit identity mismatch: ugl1701")
