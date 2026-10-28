UnitTemplate = Import("scom/units/ucs2513/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2513", "SCOM unit identity mismatch: ucs2513")
