UnitTemplate = Import("scom/units/ucs3512/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3512", "SCOM unit identity mismatch: ucs3512")
