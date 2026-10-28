UnitTemplate = Import("scom/units/ugl0000/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl0000", "SCOM unit identity mismatch: ugl0000")
