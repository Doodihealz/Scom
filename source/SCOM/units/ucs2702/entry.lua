UnitTemplate = Import("scom/units/ucs2702/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2702", "SCOM unit identity mismatch: ucs2702")
