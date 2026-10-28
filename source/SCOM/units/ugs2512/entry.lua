UnitTemplate = Import("scom/units/ugs2512/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2512", "SCOM unit identity mismatch: ugs2512")
