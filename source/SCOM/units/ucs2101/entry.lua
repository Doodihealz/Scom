UnitTemplate = Import("scom/units/ucs2101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2101", "SCOM unit identity mismatch: ucs2101")
