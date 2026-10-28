UnitTemplate = Import("scom/units/ucs2803/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2803", "SCOM unit identity mismatch: ucs2803")
