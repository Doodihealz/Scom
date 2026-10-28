UnitTemplate = Import("scom/units/ucs2512/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2512", "SCOM unit identity mismatch: ucs2512")
