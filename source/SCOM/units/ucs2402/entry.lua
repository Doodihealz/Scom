UnitTemplate = Import("scom/units/ucs2402/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2402", "SCOM unit identity mismatch: ucs2402")
