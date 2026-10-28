UnitTemplate = Import("scom/units/ucs2611/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2611", "SCOM unit identity mismatch: ucs2611")
