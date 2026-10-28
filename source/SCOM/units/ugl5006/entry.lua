UnitTemplate = Import("scom/units/ugl5006/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl5006", "SCOM unit identity mismatch: ugl5006")
