UnitTemplate = Import("scom/units/ucs2711/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2711", "SCOM unit identity mismatch: ucs2711")
