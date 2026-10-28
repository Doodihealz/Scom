UnitTemplate = Import("scom/units/ucs2510/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2510", "SCOM unit identity mismatch: ucs2510")
