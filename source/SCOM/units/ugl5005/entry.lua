UnitTemplate = Import("scom/units/ugl5005/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl5005", "SCOM unit identity mismatch: ugl5005")
