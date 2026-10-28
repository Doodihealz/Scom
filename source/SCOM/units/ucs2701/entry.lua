UnitTemplate = Import("scom/units/ucs2701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2701", "SCOM unit identity mismatch: ucs2701")
