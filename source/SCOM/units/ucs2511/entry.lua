UnitTemplate = Import("scom/units/ucs2511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2511", "SCOM unit identity mismatch: ucs2511")
