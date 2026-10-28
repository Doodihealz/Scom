UnitTemplate = Import("scom/units/ugl5001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl5001", "SCOM unit identity mismatch: ugl5001")
