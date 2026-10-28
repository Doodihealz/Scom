UnitTemplate = Import("scom/units/ugl1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl1001", "SCOM unit identity mismatch: ugl1001")
