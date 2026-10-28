UnitTemplate = Import("scom/units/ucs2501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2501", "SCOM unit identity mismatch: ucs2501")
